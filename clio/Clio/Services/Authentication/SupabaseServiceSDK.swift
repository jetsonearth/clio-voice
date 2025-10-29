import Foundation
import SwiftUI
import Supabase

@MainActor
class SupabaseServiceSDK: ObservableObject {
    static let shared = SupabaseServiceSDK()
    
    // MARK: - Published Properties
    @Published var currentUser: User?
    @Published var currentSession: UserSession?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isInitialized = false
    
    // MARK: - Private Properties
    private let client: SupabaseClient
    private let supabaseURLString: String
    private let supabaseKeyString: String
    
    // Compatibility: expose Supabase URL & key for services that still build manual requests
    var apiURL: String {
        supabaseURLString
    }
    
    var apiKey: String {
        supabaseKeyString
    }
    
    private var sessionTask: Task<Void, Never>?
    
    private init() {
        // Initialize Supabase client
        guard let supabaseURL = ProcessInfo.processInfo.environment["SUPABASE_URL"] ?? 
                               Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String,
              let supabaseKey = ProcessInfo.processInfo.environment["SUPABASE_KEY"] ?? 
                               Bundle.main.object(forInfoDictionaryKey: "SUPABASE_KEY") as? String,
              let url = URL(string: supabaseURL) else {
            fatalError("Missing Supabase configuration")
        }
        
        self.supabaseURLString = supabaseURL
        self.supabaseKeyString = supabaseKey
        
        self.client = SupabaseClient(
            supabaseURL: url,
            supabaseKey: supabaseKey,
            options: SupabaseClientOptions(
                auth: .init(
                    autoRefreshToken: true
                ),
                global: .init(
                    logger: SupabaseLoggerImpl()
                )
            )
        )
        
        // Set up auth state listener
        setupAuthListener()
        
        // Check for existing session
        Task {
            await checkSession()
        }
    }
    
    // MARK: - Auth State Management
    
    private func setupAuthListener() {
        sessionTask = Task {
            for await (event, session) in client.auth.authStateChanges {
                await handleAuthStateChange(event: event, session: session)
            }
        }
    }
    
    private func handleAuthStateChange(event: AuthChangeEvent, session: Session?) async {
        DebugLogger.debug("State changed: \(event)", category: .auth)
        
        switch event {
        case .initialSession, .signedIn, .tokenRefreshed:
            if let session = session {
                await updateUserFromSession(session)
                isAuthenticated = true
                DebugLogger.success("User authenticated: \(currentUser?.email ?? "unknown")", category: .auth)
                
                // Sync with UserProfileService
                UserProfileService.shared.signIn(
                    name: currentUser?.fullName ?? currentUser?.email.components(separatedBy: "@").first ?? "User",
                    email: currentUser?.email ?? ""
                )
            }
            
        case .signedOut:
            currentUser = nil
            isAuthenticated = false
            UserProfileService.shared.signOut()
            clearLicenseCaches()
            print("👋 [AUTH] User signed out")
            
        case .passwordRecovery, .userUpdated:
            // Handle these if needed
            break
            
        @unknown default:
            break
        }
        
        // Mark as initialized after first auth state
        if !isInitialized {
            isInitialized = true
        }
    }
    
    private func checkSession() async {
        do {
            // Try to get current session (non-optional API)
            let session = try await client.auth.session
            await updateUserFromSession(session)
            isAuthenticated = true
            print("✅ [AUTH] Restored session for: \(currentUser?.email ?? "unknown")")
        } catch {
            // Most likely there is no stored session yet
            print("📭 [AUTH] No existing session (or failed to load): \(error)")
            await attemptAutomaticSignIn()
        }
        isInitialized = true
    }
    
    private func updateUserFromSession(_ session: Session) async {
        do {
            // Fetch user profile from database
            let profile: UserProfile = try await client
                .from("user_profiles")
                .select()
                .eq("id", value: session.user.id.uuidString)
                .single()
                .execute()
                .value
            
            let userData: [String: Any] = [
                "id": session.user.id.uuidString,
                "email": session.user.email ?? "",
                "full_name": profile.fullName ?? NSNull(),
                "avatar_url": profile.avatarUrl ?? NSNull(),
                "created_at": ISO8601DateFormatter().string(from: session.user.createdAt),
                "updated_at": ISO8601DateFormatter().string(from: profile.updatedAt ?? session.user.updatedAt),
                "subscription_status": profile.subscriptionStatus,
                "subscription_plan": profile.subscriptionPlan ?? NSNull(),
                "subscription_expires_at": profile.subscriptionExpiresAt != nil ? ISO8601DateFormatter().string(from: profile.subscriptionExpiresAt!) : NSNull(),
                "trial_ends_at": profile.trialEndsAt != nil ? ISO8601DateFormatter().string(from: profile.trialEndsAt!) : NSNull(),
                "polar_customer_id": profile.polarCustomerId ?? NSNull(),
                "unlimited_transcriptions": profile.unlimitedTranscriptions ?? false,
                "ai_enhancement": profile.aiEnhancement ?? false,
                "cloud_sync": profile.cloudSync ?? false,
                "advanced_settings": profile.advancedSettings ?? false,
                "priority_support": profile.prioritySupport ?? false,
                "team_features": profile.teamFeatures ?? false
            ]
            guard let user = try? User(from: userData) else {
                print("⚠️ [AUTH] Failed to decode user from profile data")
                return
            }
            currentUser = user
            let expiryDate = Date(timeIntervalSince1970: session.expiresAt ?? Date().addingTimeInterval(3600).timeIntervalSince1970)
            currentSession = UserSession(
                accessToken: session.accessToken,
                refreshToken: session.refreshToken,
                expiresAt: expiryDate,
                user: user
            )
        } catch {
            print("⚠️ [AUTH] Using basic user info (profile fetch failed): \(error)")
            // Fall back to basic user info
            let fallbackData: [String: Any] = [
                "id": session.user.id.uuidString,
                "email": session.user.email,
                "full_name": NSNull(),
                "avatar_url": NSNull(),
                "created_at": ISO8601DateFormatter().string(from: session.user.createdAt),
                "updated_at": ISO8601DateFormatter().string(from: session.user.updatedAt),
                "subscription_status": "free"
            ]
            guard let user = try? User(from: fallbackData) else {
                print("⚠️ [AUTH] Failed to decode fallback user")
                return
            }
            currentUser = user
            let expiryDate2 = Date(timeIntervalSince1970: session.expiresAt ?? Date().addingTimeInterval(3600).timeIntervalSince1970)
            currentSession = UserSession(
                accessToken: session.accessToken,
                refreshToken: session.refreshToken,
                expiresAt: expiryDate2,
                user: user
            )
        }
    }

    // MARK: - Lightweight polling after portal actions
    func pollProfile(for seconds: TimeInterval = 30, interval: TimeInterval = 3) {
        Task.detached { [weak self] in
            let start = Date()
            while Date().timeIntervalSince(start) < seconds {
                do { try await self?.refreshSession() } catch { }
                let ns = UInt64(max(0.5, interval) * 1_000_000_000)
                try? await Task.sleep(nanoseconds: ns)
            }
        }
    }
    
    // MARK: - Authentication Methods
    
    enum OAuthProvider: String, CaseIterable {
        case google
        case apple
        case kakao
        case github
        case twitter
        
        var supabaseProvider: Provider {
            switch self {
            case .google: return .google
            case .apple: return .apple
            case .kakao: return .kakao
            case .github: return .github
            case .twitter: return .twitter
            }
        }
    }
    
    /// Build the app's custom redirect URL used by Supabase OAuth on macOS
    private func makeRedirectURL() -> URL? {
        // Use bundle identifier as a stable base for URL scheme
        let bundleId = Bundle.main.bundleIdentifier ?? "com.cliovoice.clio"
        // We prefer a readable scheme (com.cliovoice.clio) but iOS/macOS allow any string
        // Make sure Info.plist has CFBundleURLTypes with this scheme
        let scheme = bundleId
        var comps = URLComponents()
        comps.scheme = scheme
        comps.host = "auth"
        comps.path = "/callback"
        return comps.url
    }
    
    func signInWithOAuth(_ provider: OAuthProvider) async throws {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        guard let redirectURL = makeRedirectURL() else {
            throw AuthError.serverError("Missing OAuth redirect URL. Check CFBundleURLTypes in Info.plist")
        }
        
        do {
            // Use ASWebAuthenticationSession under the hood (Supabase SDK handles on macOS)
            _ = try await client.auth.signInWithOAuth(
                provider: provider.supabaseProvider,
                redirectTo: redirectURL
            )
            // Auth flow will continue in external browser/session and return via handleOpenURL
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    /// Forward only OAuth callback URLs into Supabase SDK.
    /// Returns true if this URL was an auth callback we consumed; false otherwise
    /// so other app deep-links (e.g. com.cliovoice.clio://activate) continue to work.
    func handleOpenURL(_ url: URL) -> Bool {
        let expectedScheme = Bundle.main.bundleIdentifier ?? "com.cliovoice.clio"
        // Match the redirect we construct in makeRedirectURL(): scheme://auth/callback
        let isAuthCallback = (url.scheme == expectedScheme && url.host == "auth" && url.path == "/callback")
        guard isAuthCallback else { return false }
        client.auth.handle(url)
        return true
    }
    
    func signIn(email: String, password: String) async throws -> User {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            _ = try await client.auth.signIn(
                email: email,
                password: password
            )
            
            print("✅ [AUTH] Sign in successful")
            
            // Wait for auth state to update
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            
            guard let user = currentUser else {
                throw AuthError.invalidCredentials
            }
            
            return user
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    func signIn(credentials: AuthCredentials) async throws -> User {
        try await signIn(email: credentials.email, password: credentials.password)
    }
    
    func signUp(credentials: RegisterCredentials) async throws -> User {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let metadata: [String: AnyJSON] = credentials.fullName != nil ?
                ["full_name": .string(credentials.fullName!)] : [:]
            
            let response = try await client.auth.signUp(
                email: credentials.email,
                password: credentials.password,
                data: metadata
            )
            
            print("✅ [AUTH] Sign up successful")
            // Return the user even if email confirmation is required
            // Create minimal user object
            let userId = response.user.id.uuidString
            let userEmail = response.user.email
            
            // Use User(from:) initializer with dictionary
            let userData: [String: Any] = [
                "id": userId,
                "email": userEmail,
                "full_name": credentials.fullName ?? "",
                "avatar_url": NSNull(),
                "created_at": ISO8601DateFormatter().string(from: response.user.createdAt ?? Date()),
                "updated_at": ISO8601DateFormatter().string(from: response.user.updatedAt ?? Date()),
                "subscription_status": "pending_verification",
                "subscription_plan": NSNull(),
                "subscription_expires_at": NSNull(),
                "trial_ends_at": NSNull(),
                "unlimited_transcriptions": false,
                "ai_enhancement": false,
                "cloud_sync": false,
                "advanced_settings": false,
                "priority_support": false,
                "team_features": false
            ]
            
            let user = try User(from: userData)
            
            return user
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    func signOut() async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await client.auth.signOut()
            print("✅ [AUTH] Sign out successful")
            removeSavedCredentials()
            clearLicenseCaches()
        } catch {
            print("❌ [AUTH] Sign out failed: \(error)")
            // Even if network sign-out fails, clear local session & saved credentials
            removeSavedCredentials()
            clearLicenseCaches()
            currentUser = nil
            isAuthenticated = false
            UserProfileService.shared.signOut()
        }
    }

    // MARK: - Cleanup helpers
    private func clearLicenseCaches() {
        // Clear any locally cached license keys to avoid cross-account portal sessions
        LicenseSyncService.shared.clearStoredLicense()
        let defaults = UserDefaults.standard
        let keysToRemove = [
            "PolarLicenseKey",            // legacy
            "polar_license_key",         // canonical
            "polar_customer_portal_license_key", // portal helper
            "IoLicense"                   // very old key
        ]
        for key in keysToRemove { defaults.removeObject(forKey: key) }
    }
    
    func sendPasswordResetEmail(email: String) async throws {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            try await client.auth.resetPasswordForEmail(email)
            print("✅ [AUTH] Password reset email sent")
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    func updateProfile(fullName: String?, avatarUrl: String?) async throws -> User {
        guard let session = currentSession else {
            throw AuthError.noSession
        }
        
        // Update user metadata via auth API
        var metadata: [String: AnyJSON] = [:]
        if let fullName = fullName {
            metadata["full_name"] = .string(fullName)
        }
        if let avatarUrl = avatarUrl {
            metadata["avatar_url"] = .string(avatarUrl)
        }
        
        _ = try await client.auth.update(user: .init(data: metadata))
        
        // Fetch updated session (non-optional)
        let updatedSession = try await client.auth.session
        await updateUserFromSession(updatedSession)
        
        guard let updatedUser = currentUser else {
            throw AuthError.noSession
        }
        
        return updatedUser
    }
    
    func migrateLegacyLicense(_ migration: LicenseUserMigration) async throws {
        guard let session = currentSession else {
            throw AuthError.noSession
        }
        
        // Call Supabase function or API to handle legacy license migration
        let migrationData: [String: AnyJSON] = [
            "user_id": .string(session.user.id),
            "legacy_license_key": migration.legacyLicenseKey != nil ? .string(migration.legacyLicenseKey!) : .null,
            "legacy_activation_id": migration.legacyActivationId != nil ? .string(migration.legacyActivationId!) : .null,
            "legacy_trial_start_date": migration.legacyTrialStartDate != nil ? .string(ISO8601DateFormatter().string(from: migration.legacyTrialStartDate!)) : .null,
            "has_launched_before": .bool(migration.hasLaunchedBefore)
        ]
        
        _ = try await client
            .from("legacy_license_migrations")
            .insert(migrationData)
            .execute()
        
        print("✅ Legacy license migration recorded")
    }
    
    func updateWelcomeSource(_ source: String) async throws {
        guard let session = currentSession else {
            throw AuthError.noSession
        }
        
        // Update welcome_source in user_profiles table
        _ = try await client
            .from("user_profiles")
            .update(["welcome_source": source])
            .eq("id", value: session.user.id)
            .execute()
        
        print("✅ Welcome source updated: \(source)")
        
        // Update local user session to reflect the change
        let updatedSession = try await client.auth.session
        await updateUserFromSession(updatedSession)
    }
    
    func updateSubscriptionInfo(status: String, plan: String?, expiresAt: Date?, trialEndsAt: Date? = nil) async throws {
        guard let session = currentSession else {
            throw AuthError.noSession
        }
        
        // Prepare update data
        var updateData: [String: AnyJSON] = [
            "subscription_status": .string(status)
        ]
        
        if let plan = plan {
            updateData["subscription_plan"] = .string(plan)
        }
        
        if let expiresAt = expiresAt {
            updateData["subscription_expires_at"] = .string(ISO8601DateFormatter().string(from: expiresAt))
        } else {
            updateData["subscription_expires_at"] = .null
        }
        
        if let tEnd = trialEndsAt {
            updateData["trial_ends_at"] = .string(ISO8601DateFormatter().string(from: tEnd))
        } else {
            // Explicitly clear when not a trial
            updateData["trial_ends_at"] = .null
        }
        
        // Update subscription info in user_profiles table
        _ = try await client
            .from("user_profiles")
            .update(updateData)
            .eq("id", value: session.user.id)
            .execute()
        
        print("✅ Subscription info updated: status=\(status), plan=\(plan ?? "nil"), expires=\(expiresAt?.description ?? "nil")")
        
        // Update local user session to reflect the change
        let updatedSession = try await client.auth.session
        await updateUserFromSession(updatedSession)
    }
    
    // MARK: - Session Management
    
    func refreshSession() async throws {
        do {
            _ = try await client.auth.refreshSession()
            // The auth state listener will automatically update our session
            print("✅ [AUTH] Session refreshed")
        } catch {
            print("❌ [AUTH] Failed to refresh session: \(error)")
            throw error
        }
    }
    
    // MARK: - Credential Management
    
    private let savedCredentialsKey = "savedCredentials"
    
    func saveCredentials(_ credentials: AuthCredentials) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(credentials) {
            UserDefaults.standard.set(encoded, forKey: savedCredentialsKey)
        }
    }
    
    func saveCredentials(email: String, password: String) {
        let credentials = AuthCredentials(email: email, password: password)
        saveCredentials(credentials)
    }
    
    func loadSavedCredentials() -> AuthCredentials? {
        guard let data = UserDefaults.standard.data(forKey: savedCredentialsKey),
              let credentials = try? JSONDecoder().decode(AuthCredentials.self, from: data) else {
            return nil
        }
        return credentials
    }
    
    func getSavedCredentials() -> AuthCredentials? {
        return loadSavedCredentials()
    }
    
    func removeSavedCredentials() {
        UserDefaults.standard.removeObject(forKey: savedCredentialsKey)
    }
    
    private func attemptAutomaticSignIn() async {
        // Check if we have saved credentials
        guard let credentials = loadSavedCredentials(),
              !credentials.email.isEmpty,
              !credentials.password.isEmpty else {
            print("🔐 [AUTH] No saved credentials available for automatic sign-in")
            return
        }
        
        print("🔄 [AUTH] Attempting automatic sign-in with saved credentials for: \(credentials.email)")
        
        do {
            // Attempt to sign in with saved credentials
            _ = try await signIn(email: credentials.email, password: credentials.password)
            print("✅ [AUTH] Automatic sign-in successful")
        } catch {
            print("❌ [AUTH] Automatic sign-in failed: \(error)")
            // Clear saved credentials if they're invalid
            removeSavedCredentials()
            print("🗑️ [AUTH] Removed invalid saved credentials")
        }
    }
    
    // MARK: - Cleanup
    
    deinit {
        sessionTask?.cancel()
    }
}


// MARK: - Helper Models

struct UserProfile: Codable {
    let id: String
    let email: String
    let fullName: String?
    let avatarUrl: String?
    let updatedAt: Date?
    let subscriptionStatus: String
    let subscriptionPlan: String?
    let subscriptionExpiresAt: Date?
    let trialEndsAt: Date?
    let unlimitedTranscriptions: Bool?
    let aiEnhancement: Bool?
    let cloudSync: Bool?
    let advancedSettings: Bool?
    let prioritySupport: Bool?
    let teamFeatures: Bool?
    let welcomeSource: String?
    let polarCustomerId: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case fullName = "full_name"
        case avatarUrl = "avatar_url"
        case updatedAt = "updated_at"
        case subscriptionStatus = "subscription_status"
        case subscriptionPlan = "subscription_plan"
        case subscriptionExpiresAt = "subscription_expires_at"
        case trialEndsAt = "trial_ends_at"
        case unlimitedTranscriptions = "unlimited_transcriptions"
        case aiEnhancement = "ai_enhancement"
        case cloudSync = "cloud_sync"
        case advancedSettings = "advanced_settings"
        case prioritySupport = "priority_support"
        case teamFeatures = "team_features"
        case welcomeSource = "welcome_source"
        case polarCustomerId = "polar_customer_id"
    }
}

// MARK: - Error Types

enum AuthError: Error, LocalizedError {
    case noSession
    case invalidCredentials
    case unauthorized
    case networkError
    case networkTimeout
    case validationError
    case serverError(String)
    case rateLimited
    case emailNotConfirmed
    
    var errorDescription: String? {
        switch self {
        case .noSession:
            return "No active session found. Please sign in."
        case .invalidCredentials:
            return "Invalid email or password."
        case .unauthorized:
            return "Session expired. Please sign in again."
        case .networkError:
            return "Network connection error. Please check your internet connection and try again."
        case .networkTimeout:
            return "Connection timed out. Please check your internet connection and try again."
        case .validationError:
            return "Please check your input and try again."
        case .serverError(let message):
            return "Server error: \(message)"
        case .rateLimited:
            return "Too many requests. Please wait a moment and try again."
        case .emailNotConfirmed:
            return "Please check your email and click the verification link to complete sign-up."
        }
    }
}

// MARK: - Logger Implementation

struct SupabaseLoggerImpl: SupabaseLogger {
    func log(message: SupabaseLogMessage) {
        switch message.level {
        case .debug:
            // Skip debug logs (begin/end messages, etc.) - too verbose for production
            break
        case .error:
            print("❌ [Supabase] \(message.message)")
        case .warning:
            print("⚠️ [Supabase] \(message.message)")
        case .verbose:
            // Skip verbose logs entirely
            break
        }
    }
}
