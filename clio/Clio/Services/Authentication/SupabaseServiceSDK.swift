import Foundation
import SwiftUI

@MainActor
final class SupabaseServiceSDK: ObservableObject {
    static let shared = SupabaseServiceSDK()

    @Published var currentUser: User?
    @Published var currentSession: UserSession?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isInitialized = false

    var apiURL: String { "" }
    var apiKey: String { "" }

    private let savedUserKey = "community.user.profile"
    private let savedCredentialsKey = "community.user.credentials"
    private let migrationFlagKey = "community.profile.migrated.v1"

    private init() {
        runSupabaseMigrationIfNeeded()
        loadPersistedUser()
        if currentUser == nil {
            seedDefaultUser()
        }
        isInitialized = true
    }

    // MARK: - Auth Flow

    func handleOpenURL(_ url: URL) -> Bool { false }

    func signIn(credentials: AuthCredentials) async throws -> User {
        let user = User.makeLocalUser(email: credentials.email, fullName: nil)
        persist(user: user)
        saveCredentials(credentials)
        return user
    }

    func signIn(email: String, password: String) async throws -> User {
        try await signIn(credentials: AuthCredentials(email: email, password: password))
    }

    func signUp(credentials: RegisterCredentials) async throws -> User {
        let user = User.makeLocalUser(email: credentials.email, fullName: credentials.fullName)
        persist(user: user)
        saveCredentials(email: credentials.email, password: credentials.password)
        return user
    }

    func signInWithOAuth(_ provider: OAuthProvider) async throws {
        let email = "\(provider.rawValue)@cliocommunity.local"
        let user = User.makeLocalUser(email: email, fullName: provider.displayName)
        persist(user: user)
    }

    func signOut() async throws {
        currentUser = nil
        currentSession = nil
        isAuthenticated = false
        UserProfileService.shared.signOut()
        UserDefaults.standard.removeObject(forKey: savedUserKey)
    }

    func refreshSession() async throws {
        if let user = currentUser {
            persist(user: user)
        }
    }

    func pollProfile(for seconds: Int, interval: TimeInterval) {}

    func sendPasswordResetEmail(email: String) async throws {}

    func migrateLegacyLicense(_ migration: LicenseUserMigration) async throws {}

    func updateProfile(fullName: String?, avatarUrl: String?) async throws -> User {
        guard var existing = currentUser else { throw AuthError.noSession }
        existing = User.makeLocalUser(id: existing.id, email: existing.email, fullName: fullName ?? existing.fullName)
        persist(user: existing)
        return existing
    }

    // MARK: - Credential Persistence

    func saveCredentials(_ credentials: AuthCredentials) {
        if let data = try? JSONEncoder().encode(credentials) {
            UserDefaults.standard.set(data, forKey: savedCredentialsKey)
        }
    }

    func saveCredentials(email: String, password: String) {
        saveCredentials(AuthCredentials(email: email, password: password))
    }

    func loadSavedCredentials() -> AuthCredentials? {
        guard let data = UserDefaults.standard.data(forKey: savedCredentialsKey) else { return nil }
        return try? JSONDecoder().decode(AuthCredentials.self, from: data)
    }

    func getSavedCredentials() -> AuthCredentials? {
        loadSavedCredentials()
    }

    func removeSavedCredentials() {
        UserDefaults.standard.removeObject(forKey: savedCredentialsKey)
    }

    // MARK: - Helpers

    private func persist(user: User) {
        currentUser = user
        let session = UserSession(
            accessToken: UUID().uuidString,
            refreshToken: UUID().uuidString,
            expiresAt: Date().addingTimeInterval(60 * 60 * 24 * 365),
            user: user
        )
        currentSession = session
        isAuthenticated = true
        UserProfileService.shared.signIn(
            name: user.fullName ?? user.email,
            email: user.email
        )
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: savedUserKey)
        }
    }

    private func loadPersistedUser() {
        guard let data = UserDefaults.standard.data(forKey: savedUserKey),
              let user = try? JSONDecoder().decode(User.self, from: data) else { return }
        currentUser = user
        currentSession = UserSession(
            accessToken: UUID().uuidString,
            refreshToken: UUID().uuidString,
            expiresAt: Date().addingTimeInterval(60 * 60 * 24 * 365),
            user: user
        )
        isAuthenticated = true
        UserProfileService.shared.signIn(name: user.fullName ?? user.email, email: user.email)
    }
    
    private func runSupabaseMigrationIfNeeded() {
        let defaults = UserDefaults.standard
        guard !defaults.bool(forKey: migrationFlagKey) else { return }
        defaults.removeObject(forKey: savedUserKey)
        defaults.removeObject(forKey: "SupabaseSession")
        defaults.set(true, forKey: migrationFlagKey)
        UserProfileService.shared.ensureDefaultProfile()
    }
    
    private func seedDefaultUser() {
        let profile = UserProfileService.shared
        let name = profile.userName.isEmpty ? UserProfileService.fallbackDisplayName() : profile.userName
        let email = profile.userEmail.isEmpty ? UserProfileService.fallbackEmail(for: name) : profile.userEmail
        let user = User.makeLocalUser(email: email, fullName: name)
        persist(user: user)
    }
}

extension SupabaseServiceSDK {
    enum OAuthProvider: String, CaseIterable, Identifiable {
        case apple
        case google

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .apple: return "Apple"
            case .google: return "Google"
            }
        }
    }
}

enum AuthError: Error, LocalizedError {
    case noSession

    var errorDescription: String? {
        switch self {
        case .noSession:
            return "No active session."
        }
    }
}
