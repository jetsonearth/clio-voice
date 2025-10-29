import Foundation
import Combine

@MainActor
class UserViewModel: ObservableObject {
    @Published var authenticationState: AuthenticationState = .unauthenticated
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingResetPasswordConfirmation = false
    
    private let supabaseService = SupabaseServiceSDK.shared
    private var cancellables = Set<AnyCancellable>()
    
    var isAuthenticated: Bool {
        authenticationState.isAuthenticated
    }
    
    var currentUser: User? {
        authenticationState.user
    }
    
    var canUseApp: Bool {
        guard let user = currentUser else { return false }
        return user.subscriptionStatus.canUseApp || isInTrialPeriod(user: user)
    }
    
    var subscriptionDisplayText: String {
        guard let user = currentUser else { return "Not signed in" }
        
        switch user.subscriptionStatus {
        case .trial:
            if let trialEnd = user.trialEndsAt {
                let formatter = RelativeDateTimeFormatter()
                return "Trial expires \(formatter.localizedString(for: trialEnd, relativeTo: Date()))"
            }
            return "Free Trial"
        case .active:
            if let plan = user.subscriptionPlan {
                return "\(plan.displayName) Plan"
            }
            return "Active Subscription"
        case .pastDue:
            return "Payment Past Due"
        case .canceled:
            return "Subscription Canceled"
        case .expired:
            return "Subscription Expired"
        case .none:
            return "Free Account"
        }
    }
    
    init() {
        setupSubscriptions()
        checkInitialAuthState()
    }
    
    private func setupSubscriptions() {
        supabaseService.$currentSession
            .receive(on: DispatchQueue.main)
            .sink { [weak self] session in
                if let session = session {
                    self?.authenticationState = .authenticated(session.user)
                } else {
                    self?.authenticationState = .unauthenticated
                }
            }
            .store(in: &cancellables)
        
        supabaseService.$isLoading
            .receive(on: DispatchQueue.main)
            .assign(to: \.isLoading, on: self)
            .store(in: &cancellables)
        
        supabaseService.$errorMessage
            .receive(on: DispatchQueue.main)
            .assign(to: \.errorMessage, on: self)
            .store(in: &cancellables)
    }
    
    private func checkInitialAuthState() {
        if let session = supabaseService.currentSession {
            authenticationState = .authenticated(session.user)
        } else {
            authenticationState = .unauthenticated
        }
    }
    
    func signUp(email: String, password: String, fullName: String?) async {
        authenticationState = .authenticating
        errorMessage = nil
        
        do {
            let credentials = RegisterCredentials(
                email: email,
                password: password,
                fullName: fullName
            )
            
            let user = try await supabaseService.signUp(credentials: credentials)
            authenticationState = .authenticated(user)
            
            // Create and store session
            let session = UserSession(
                accessToken: "temp_token", // This will be updated by the session listener
                refreshToken: "temp_refresh",
                expiresAt: Date().addingTimeInterval(3600),
                user: user
            )
            await MainActor.run {
                supabaseService.currentSession = session
            }
            
        } catch {
            authenticationState = .error(error.localizedDescription)
            errorMessage = error.localizedDescription
        }
    }
    
    func signIn(email: String, password: String) async {
        authenticationState = .authenticating
        errorMessage = nil
        
        do {
            let credentials = AuthCredentials(email: email, password: password)
            let user = try await supabaseService.signIn(credentials: credentials)
            authenticationState = .authenticated(user)
            
            // Create and store session  
            let session = UserSession(
                accessToken: "temp_token", // This will be updated by the session listener
                refreshToken: "temp_refresh", 
                expiresAt: Date().addingTimeInterval(3600),
                user: user
            )
            await MainActor.run {
                supabaseService.currentSession = session
            }
            
            await handleLegacyLicenseMigration()
            
        } catch {
            authenticationState = .error(error.localizedDescription)
            errorMessage = error.localizedDescription
        }
    }
    
    func signOut() async {
        do {
            try await supabaseService.signOut()
            authenticationState = .unauthenticated
            errorMessage = nil
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func sendPasswordResetEmail(email: String) async {
        errorMessage = nil
        
        do {
            try await supabaseService.sendPasswordResetEmail(email: email)
            showingResetPasswordConfirmation = true
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func updateProfile(fullName: String?, avatarUrl: String?) async {
        guard case .authenticated = authenticationState else { return }
        
        errorMessage = nil
        
        do {
            let updatedUser = try await supabaseService.updateProfile(
                fullName: fullName,
                avatarUrl: avatarUrl
            )
            authenticationState = .authenticated(updatedUser)
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func clearError() {
        errorMessage = nil
        if case .error = authenticationState {
            authenticationState = .unauthenticated
        }
    }
    
    private func handleLegacyLicenseMigration() async {
        let migration = LicenseUserMigration.fromUserDefaults()
        
        if migration.legacyLicenseKey != nil || migration.hasLaunchedBefore {
            do {
                try await supabaseService.migrateLegacyLicense(migration)
                print("✅ Legacy license migration completed")
            } catch {
                print("⚠️ Legacy license migration failed: \(error.localizedDescription)")
            }
        }
    }
    
    private func isInTrialPeriod(user: User) -> Bool {
        guard user.subscriptionStatus == .trial,
              let trialEnd = user.trialEndsAt else {
            return false
        }
        return Date() < trialEnd
    }
    
    func canUseFeature(_ feature: UserFeature) -> Bool {
        guard let user = currentUser else { return false }
        
        switch feature {
        case .unlimitedTranscriptions:
            return user.features.unlimitedTranscriptions
        case .aiEnhancement:
            return user.features.aiEnhancement
        case .cloudSync:
            return user.features.cloudSync
        case .advancedSettings:
            return user.features.advancedSettings
        case .prioritySupport:
            return user.features.prioritySupport
        case .teamFeatures:
            return user.features.teamFeatures
        }
    }
    
    func getFeatureLimit(for feature: UserFeature) -> Int? {
        guard let user = currentUser else { return 0 }
        
        switch feature {
        case .unlimitedTranscriptions:
            return user.features.unlimitedTranscriptions ? nil : 10
        default:
            return nil
        }
    }
}

enum UserFeature {
    case unlimitedTranscriptions
    case aiEnhancement
    case cloudSync
    case advancedSettings
    case prioritySupport
    case teamFeatures
}