// import Foundation
// import Security
// @MainActor
// class SupabaseService: ObservableObject {
    
//     // MARK: - Configuration
//     private let supabaseURL: String
//     private let supabaseKey: String
//     private let urlSession: URLSession
    
//     // MARK: - State
//     @Published var currentSession: UserSession?
//     @Published private(set) var isLoading = false
//     @Published var errorMessage: String?
//     @Published var isInitialized = false
    
//     // MARK: - Constants
//     private let keychainService = "com.jetsonai.clio.auth"
//     private let sessionKey = "userSession"
//     private let savedCredentialsKey = "savedCredentials"
    
//     init(supabaseURL: String = "", supabaseKey: String = "") {
//         // Get credentials from environment variables or use provided values
//         let envURL = ProcessInfo.processInfo.environment["SUPABASE_URL"] ?? ""
//         let envKey = ProcessInfo.processInfo.environment["SUPABASE_KEY"] ?? ""
        
//         // Priority: passed parameters > environment variables > fallback to Info.plist
//         if !supabaseURL.isEmpty {
//             self.supabaseURL = supabaseURL
//         } else if !envURL.isEmpty {
//             self.supabaseURL = envURL
//         } else {
//             // Fallback to Info.plist configuration
//             self.supabaseURL = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String ?? ""
//             assert(!self.supabaseURL.isEmpty, "SUPABASE_URL must be configured in environment variables or Info.plist")
//         }
        
//         if !supabaseKey.isEmpty {
//             self.supabaseKey = supabaseKey
//         } else if !envKey.isEmpty {
//             self.supabaseKey = envKey
//         } else {
//             // Fallback to Info.plist configuration
//             self.supabaseKey = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_KEY") as? String ?? ""
//             assert(!self.supabaseKey.isEmpty, "SUPABASE_KEY must be configured in environment variables or Info.plist")
//         }
        
//         // Configure URLSession with very generous timeouts for authentication
//         let config = URLSessionConfiguration.default
//         config.timeoutIntervalForRequest = 60   // 60 seconds for individual requests
//         config.timeoutIntervalForResource = 120  // 2 minutes total
//         config.allowsCellularAccess = true
//         config.waitsForConnectivity = true  // Wait for connectivity
//         config.requestCachePolicy = .reloadIgnoringLocalCacheData  // Don't use cache
//         config.networkServiceType = .responsiveData  // Prioritize reliability
//         self.urlSession = URLSession(configuration: config)
        
//         // Load stored session on init
//         print("🚀 [AUTH] SupabaseService initializing...")
//         loadStoredSession()
//     }
    
//     // MARK: - Session Management
    
//     private func loadStoredSession() {
//         print("🔍 [AUTH] Starting session loading process...")
        
//         // Try keychain first
//         var sessionData = getFromKeychain(key: sessionKey)
        
//         // Fallback to UserDefaults if keychain is empty
//         if sessionData == nil {
//             sessionData = UserDefaults.standard.data(forKey: "SupabaseSession")
//             if sessionData != nil {
//                 print("📱 [AUTH] Loading session from UserDefaults fallback")
//             }
//         }
        
//         if let sessionData = sessionData,
//            let session = try? JSONDecoder().decode(UserSession.self, from: sessionData) {
            
//             if !session.isExpired {
//                 self.currentSession = session
//                 print("✅ [AUTH] Loaded existing session for: \(session.user.email)")
//                 print("🔍 [AUTH] User subscription status: \(session.user.subscriptionStatus)")
//                 print("🔍 [AUTH] User subscription plan: \(session.user.subscriptionPlan?.rawValue ?? "nil")")
                
//                 // Wait for subscription manager to process the session before marking as initialized
//                 DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                     self.isInitialized = true
//                     print("✅ [AUTH] SupabaseService initialization complete (with session)")
//                 }
                
//                 // Check if we need to refresh the token
//                 if session.shouldRefresh {
//                     Task {
//                         try? await refreshSession()
//                     }
//                 }
//             } else {
//                 // Session expired, try to refresh it first
//                 print("⏰ [AUTH] Session expired, attempting refresh...")
                
//                 Task {
//                     do {
//                         // Temporarily set the expired session so refresh can work
//                         self.currentSession = session
//                         try await self.refreshSession()
//                         print("✅ [AUTH] Successfully refreshed expired session")
                        
//                         DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                             self.isInitialized = true
//                             print("✅ [AUTH] SupabaseService initialization complete (refreshed session)")
//                         }
//                     } catch {
//                         print("❌ [AUTH] Failed to refresh session: \(error)")
                        
//                         // Only clear session if it's definitely invalid (not just network issues)
//                         if let authError = error as? AuthError {
//                             switch authError {
//                             case .invalidCredentials, .unauthorized:
//                                 // Actually invalid - clear the session
//                                 self.currentSession = nil
//                                 self.removeFromKeychain(key: self.sessionKey)
//                                 UserDefaults.standard.removeObject(forKey: "SupabaseSession")
//                                 print("🗑️ [AUTH] Removed invalid session after failed refresh")
//                             default:
//                                 // Network or temporary issue - keep session but log out for now
//                                 self.currentSession = nil
//                                 print("⚠️ [AUTH] Temporarily logged out due to network/server issue, session preserved")
//                             }
//                         } else {
//                             // Unknown error - don't clear stored session (could be network issue)
//                             self.currentSession = nil
//                             print("⚠️ [AUTH] Temporarily logged out due to unknown error, session preserved")
//                         }
                        
//                         // Try automatic sign-in with saved credentials
//                         await self.attemptAutomaticSignIn()
                        
//                         DispatchQueue.main.async {
//                             self.isInitialized = true
//                             print("✅ [AUTH] SupabaseService initialization complete (expired session)")
//                         }
//                     }
//                 }
//             }
//         } else {
//             print("📭 [AUTH] No stored session found during initialization")
            
//             // Try automatic sign-in with saved credentials
//             Task {
//                 await self.attemptAutomaticSignIn()
                
//                 DispatchQueue.main.async {
//                     self.isInitialized = true
//                     print("✅ [AUTH] SupabaseService initialization complete (no session)")
//                 }
//             }
//         }
//     }
    
//     private func storeSession(_ session: UserSession) {
//         // Set session immediately in memory
//         self.currentSession = session
//         // Debug: print token prefix each time we persist a session
//         print("💾 Persisted RT prefix:", session.refreshToken.prefix(8))
//         print("✅ [AUTH] Session set in memory for: \(session.user.email)")
        
//         if let sessionData = try? JSONEncoder().encode(session) {
//             storeInKeychain(key: sessionKey, data: sessionData)
            
//             // Always store in UserDefaults as backup (keychain is failing)
//             UserDefaults.standard.set(sessionData, forKey: "SupabaseSession")
//             print("💾 [AUTH] Session stored in UserDefaults as backup")
            
//             print("✅ [AUTH] Session stored successfully")
//         }
//     }
    
//     private func clearSession() {
//         removeFromKeychain(key: sessionKey)
//         UserDefaults.standard.removeObject(forKey: "SupabaseSession")
//         self.currentSession = nil
//         print("🗑️ [AUTH] Cleared all session data")
//     }
    
//     // MARK: - Password Management
    
//     func saveCredentials(email: String, password: String) {
//         let credentials = SavedCredentials(email: email, password: password)
//         if let credentialsData = try? JSONEncoder().encode(credentials) {
//             storeInKeychain(key: savedCredentialsKey, data: credentialsData)
//         }
//     }
    
//     func getSavedCredentials() -> SavedCredentials? {
//         guard let credentialsData = getFromKeychain(key: savedCredentialsKey),
//               let credentials = try? JSONDecoder().decode(SavedCredentials.self, from: credentialsData) else {
//             return nil
//         }
//         return credentials
//     }
    
//     func clearSavedCredentials() {
//         removeFromKeychain(key: savedCredentialsKey)
//     }
    
//     // MARK: - Authentication API
    
//     func signUp(credentials: RegisterCredentials) async throws -> User {
//         isLoading = true
//         errorMessage = nil
//         defer { isLoading = false }
        
//         let url = URL(string: "\(supabaseURL)/auth/v1/signup")!
//         var request = URLRequest(url: url)
//         request.httpMethod = "POST"
//         request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//         request.setValue("Bearer \(supabaseKey)", forHTTPHeaderField: "Authorization")
//         request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
        
//         let body: [String: Any] = [
//             "email": credentials.email,
//             "password": credentials.password,
//             "data": [
//                 "full_name": credentials.fullName ?? ""
//             ]
//         ]
        
//         request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
//         let (data, httpResponse) = try await performRequestWithRetry(request: request, maxRetries: 2)
        
//         try validateHTTPResponse(httpResponse, data: data)
        
//         // Debug: Print the response to see what we're getting
//         if let responseString = String(data: data, encoding: .utf8) {
//             print("🔍 Sign-up response: \(responseString)")
//         }
        
//         // For sign-up, Supabase might return a different structure
//         guard let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
//             throw AuthError.serverError("Invalid response format")
//         }
        
//         print("🔍 Sign-up JSON response: \(jsonResponse)")
        
//         // Get user info from the response (user data is at root level for sign-up)
//         guard let userId = jsonResponse["id"] as? String,
//               let userEmail = jsonResponse["email"] as? String else {
//             throw AuthError.serverError("Invalid user data in response")
//         }
        
//         // For sign-up, we create a minimal user object for display purposes only
//         // The user profile will NOT be created in the database until email confirmation
//         let userData: [String: Any] = [
//             "id": userId,
//             "email": userEmail,
//             "full_name": credentials.fullName ?? "",
//             "avatar_url": NSNull(),
//             "created_at": ISO8601DateFormatter().string(from: Date()),
//             "updated_at": ISO8601DateFormatter().string(from: Date()),
//             // No subscription data until email confirmation
//             "subscription_status": "pending_verification",
//             "subscription_plan": NSNull(),
//             "subscription_expires_at": NSNull(),
//             "trial_ends_at": NSNull(),
//             // No features enabled until email confirmation
//             "unlimited_transcriptions": false,
//             "ai_enhancement": false,
//             "cloud_sync": false,
//             "advanced_settings": false,
//             "priority_support": false,
//             "team_features": false
//         ]
        
//         print("📝 Created minimal user object for email verification (no database entry)")
//         return try User(from: userData)
//     }
    
//     func signIn(credentials: AuthCredentials) async throws -> User {
//         isLoading = true
//         errorMessage = nil
//         defer { isLoading = false }
        
//         let url = URL(string: "\(supabaseURL)/auth/v1/token?grant_type=password")!
//         var request = URLRequest(url: url)
//         request.httpMethod = "POST"
//         request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//         request.setValue("Bearer \(supabaseKey)", forHTTPHeaderField: "Authorization")
//         request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
        
//         let body: [String: Any] = [
//             "email": credentials.email,
//             "password": credentials.password
//         ]
        
//         request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
//         let (data, httpResponse) = try await urlSession.data(for: request)
        
//         try validateHTTPResponse(httpResponse, data: data)
        
//         let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
        
//         // Try to fetch user profile from user_profiles table
//         var user: User
//         do {
//             user = try await fetchUserProfile(userId: authResponse.user.id, accessToken: authResponse.accessToken)
//             print("✅ Found existing user profile in database")
//         } catch {
//             // User profile doesn't exist yet - this means they're signing in for the first time after email confirmation
//             print("📝 No user profile found, creating one (this is first sign-in after email confirmation)")
            
//             // Get full name from pending credentials if available
//             let fullName = UserDefaults.standard.string(forKey: "PendingSignUpFullName") ?? ""
            
//             user = try await createUserProfileAfterConfirmation(
//                 userId: authResponse.user.id,
//                 email: authResponse.user.email,
//                 fullName: fullName,
//                 accessToken: authResponse.accessToken
//             )
//         }
        
//         // Store the session
//         let session = UserSession(
//             accessToken: authResponse.accessToken,
//             refreshToken: authResponse.refreshToken,
//             expiresAt: Date().addingTimeInterval(TimeInterval(authResponse.expiresIn)),
//             user: user
//         )
        
//         storeSession(session)
        
//         return user
//     }
    
//     func signOut() async throws {
//         isLoading = true
//         defer { isLoading = false }
        
//         // If we have a session, try to logout from server
//         if let session = currentSession {
//             let url = URL(string: "\(supabaseURL)/auth/v1/logout")!
//             var request = URLRequest(url: url)
//             request.httpMethod = "POST"
//             request.setValue("Bearer \(session.accessToken)", forHTTPHeaderField: "Authorization")
//             request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
            
//             // Don't throw if logout fails - still clear local session
//             _ = try? await urlSession.data(for: request)
//         }
        
//         clearSession()
//         // Optionally clear saved credentials on sign out
//         // clearSavedCredentials()
//     }
    
//     func refreshSession() async throws {
//         guard let session = currentSession else {
//             throw AuthError.noSession
//         }
        
//         let url = URL(string: "\(supabaseURL)/auth/v1/token?grant_type=refresh_token")!
//         // Debug: show refresh token prefix to ensure we are persisting the latest value
//         print("🔑 Refresh attempt, RT prefix:", session.refreshToken.prefix(8))
//         var request = URLRequest(url: url)
//         request.httpMethod = "POST"
//         request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//         request.setValue("Bearer \(supabaseKey)", forHTTPHeaderField: "Authorization")
//         request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
        
//         let body: [String: Any] = [
//             "refresh_token": session.refreshToken
//         ]
        
//         request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
//         let (data, httpResponse) = try await urlSession.data(for: request)
        
//         try validateHTTPResponse(httpResponse, data: data)
        
//         let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
        
//         // Update the session with new tokens but keep the existing user
//         let newSession = UserSession(
//             accessToken: authResponse.accessToken,
//             refreshToken: authResponse.refreshToken,
//             expiresAt: Date().addingTimeInterval(TimeInterval(authResponse.expiresIn)),
//             user: session.user  // Keep the existing user from the current session
//         )
        
//         storeSession(newSession)
//         // Debug: confirm the new refresh token was persisted
//         print("💾 Persisted RT prefix after refresh:", newSession.refreshToken.prefix(8))
//     }
    
//     private func attemptAutomaticSignIn() async {
//         // Check if we have saved credentials
//         guard let credentials = loadSavedCredentials(),
//               !credentials.email.isEmpty,
//               !credentials.password.isEmpty else {
//             print("🔐 [AUTH] No saved credentials available for automatic sign-in")
//             return
//         }
        
//         print("🔄 [AUTH] Attempting automatic sign-in with saved credentials for: \(credentials.email)")
        
//         do {
//             // Attempt to sign in with saved credentials
//             try await signIn(email: credentials.email, password: credentials.password)
//             print("✅ [AUTH] Automatic sign-in successful")
            
//             // Update UserProfileService to sync the user info
//             if let user = currentSession?.user {
//                 await MainActor.run {
//                     UserProfileService.shared.signIn(
//                         name: user.fullName ?? user.email.components(separatedBy: "@").first ?? "User",
//                         email: user.email
//                     )
//                 }
//             }
//         } catch {
//             print("❌ [AUTH] Automatic sign-in failed: \(error)")
//             // Clear saved credentials if they're invalid
//             if let authError = error as? AuthError,
//                case .invalidCredentials = authError {
//                 removeSavedCredentials()
//                 print("🗑️ [AUTH] Removed invalid saved credentials")
//             }
//         }
//     }
    
//     func sendPasswordResetEmail(email: String) async throws {
//         isLoading = true
//         defer { isLoading = false }
        
//         let url = URL(string: "\(supabaseURL)/auth/v1/recover")!
//         var request = URLRequest(url: url)
//         request.httpMethod = "POST"
//         request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//         request.setValue("Bearer \(supabaseKey)", forHTTPHeaderField: "Authorization")
//         request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
        
//         let body: [String: Any] = [
//             "email": email
//         ]
        
//         request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
//         let (data, httpResponse) = try await urlSession.data(for: request)
        
//         try validateHTTPResponse(httpResponse, data: data)
//     }
    
//     // MARK: - User Management API
    
//     func updateProfile(fullName: String?, avatarUrl: String?) async throws -> User {
//         guard let session = currentSession else {
//             throw AuthError.noSession
//         }
        
//         let url = URL(string: "\(supabaseURL)/auth/v1/user")!
//         var request = URLRequest(url: url)
//         request.httpMethod = "PUT"
//         request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//         request.setValue("Bearer \(session.accessToken)", forHTTPHeaderField: "Authorization")
//         request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
        
//         var data: [String: Any] = [:]
//         if let fullName = fullName {
//             data["full_name"] = fullName
//         }
//         if let avatarUrl = avatarUrl {
//             data["avatar_url"] = avatarUrl
//         }
        
//         let body: [String: Any] = ["data": data]
//         request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
//         let (responseData, httpResponse) = try await urlSession.data(for: request)
        
//         try validateHTTPResponse(httpResponse, data: responseData)
        
//         let updatedUser = try JSONDecoder().decode(User.self, from: responseData)
        
//         // Update stored session with new user data
//         let updatedSession = UserSession(
//             accessToken: session.accessToken,
//             refreshToken: session.refreshToken,
//             expiresAt: session.expiresAt,
//             user: updatedUser
//         )
        
//         storeSession(updatedSession)
        
//         return updatedUser
//     }
    
//     func getUserProfile() async throws -> User {
//         guard let session = currentSession else {
//             throw AuthError.noSession
//         }
        
//         let url = URL(string: "\(supabaseURL)/auth/v1/user")!
//         var request = URLRequest(url: url)
//         request.httpMethod = "GET"
//         request.setValue("Bearer \(session.accessToken)", forHTTPHeaderField: "Authorization")
//         request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
        
//         let (data, httpResponse) = try await urlSession.data(for: request)
        
//         try validateHTTPResponse(httpResponse, data: data)
        
//         let user = try JSONDecoder().decode(User.self, from: data)
        
//         // Update stored session with latest user data
//         let updatedSession = UserSession(
//             accessToken: session.accessToken,
//             refreshToken: session.refreshToken,
//             expiresAt: session.expiresAt,
//             user: user
//         )
        
//         storeSession(updatedSession)
        
//         return user
//     }
    
//     // MARK: - Subscription Management API
    
//     func updateSubscription(plan: SubscriptionPlan, status: SubscriptionStatus) async throws {
//         guard let session = currentSession else {
//             throw AuthError.noSession
//         }
        
//         let url = URL(string: "\(supabaseURL)/rest/v1/user_subscriptions")!
//         var request = URLRequest(url: url)
//         request.httpMethod = "POST"
//         request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//         request.setValue("Bearer \(session.accessToken)", forHTTPHeaderField: "Authorization")
//         request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
//         request.setValue("return=minimal", forHTTPHeaderField: "Prefer")
        
//         let body: [String: Any] = [
//             "user_id": session.user.id,
//             "plan": plan.rawValue,
//             "status": status.rawValue,
//             "updated_at": ISO8601DateFormatter().string(from: Date())
//         ]
        
//         request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
//         let (data, httpResponse) = try await urlSession.data(for: request)
        
//         try validateHTTPResponse(httpResponse, data: data)
//     }
    
//     // MARK: - Legacy License Migration
    
//     func migrateLegacyLicense(_ migration: LicenseUserMigration) async throws {
//         guard let session = currentSession else {
//             throw AuthError.noSession
//         }
        
//         let url = URL(string: "\(supabaseURL)/rest/v1/legacy_license_migrations")!
//         var request = URLRequest(url: url)
//         request.httpMethod = "POST"
//         request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//         request.setValue("Bearer \(session.accessToken)", forHTTPHeaderField: "Authorization")
//         request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
//         request.setValue("return=minimal", forHTTPHeaderField: "Prefer")
        
//         let body: [String: Any] = [
//             "user_id": session.user.id,
//             "legacy_license_key": migration.legacyLicenseKey ?? NSNull(),
//             "legacy_activation_id": migration.legacyActivationId ?? NSNull(),
//             "legacy_trial_start_date": migration.legacyTrialStartDate?.timeIntervalSince1970 ?? NSNull(),
//             "has_launched_before": migration.hasLaunchedBefore,
//             "migrated_at": ISO8601DateFormatter().string(from: Date())
//         ]
        
//         request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
//         let (data, httpResponse) = try await urlSession.data(for: request)
        
//         try validateHTTPResponse(httpResponse, data: data)
//     }
    
//     // MARK: - Private Helpers
    
//     private func fetchUserProfile(userId: String, accessToken: String) async throws -> User {
//         let url = URL(string: "\(supabaseURL)/rest/v1/user_profiles?select=*&id=eq.\(userId)")!
//         var request = URLRequest(url: url)
//         request.httpMethod = "GET"
//         request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
//         request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
        
//         let (data, httpResponse) = try await urlSession.data(for: request)
        
//         try validateHTTPResponse(httpResponse, data: data)
        
//         // Parse the response as an array and get the first user
//         guard let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]],
//               let userDict = jsonArray.first else {
//             throw AuthError.serverError("No user profile found")
//         }
        
//         return try User(from: userDict)
//     }
    
//     private func createUserProfileAfterConfirmation(userId: String, email: String, fullName: String, accessToken: String) async throws -> User {
//         // Create user profile with trial features after email confirmation
//         let userData: [String: Any] = [
//             "id": userId,
//             "email": email,
//             "full_name": fullName,
//             "avatar_url": NSNull(),
//             "created_at": ISO8601DateFormatter().string(from: Date()),
//             "updated_at": ISO8601DateFormatter().string(from: Date()),
//             "subscription_status": "trial",
//             "subscription_plan": NSNull(),
//             "subscription_expires_at": NSNull(),
//             "trial_ends_at": ISO8601DateFormatter().string(from: Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()),
//             // Trial features enabled after email confirmation
//             "unlimited_transcriptions": true,
//             "ai_enhancement": true,
//             "cloud_sync": false,
//             "advanced_settings": true,
//             "priority_support": false,
//             "team_features": false
//         ]
        
//         // Insert the user profile into the database
//         let url = URL(string: "\(supabaseURL)/rest/v1/user_profiles")!
//         var request = URLRequest(url: url)
//         request.httpMethod = "POST"
//         request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//         request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
//         request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
//         request.setValue("return=minimal", forHTTPHeaderField: "Prefer")
        
//         request.httpBody = try JSONSerialization.data(withJSONObject: userData)
        
//         let (_, httpResponse) = try await urlSession.data(for: request)
//         try validateHTTPResponse(httpResponse, data: Data())
        
//         print("✅ Successfully created user profile in database after email confirmation")
//         return try User(from: userData)
//     }
    
//     private func createUserProfile(from authResponse: AuthResponse, credentials: RegisterCredentials) async throws -> User {
//         // This method is now deprecated - we create profiles after email confirmation instead
//         // Create a basic user profile structure matching your database schema
//         let userData: [String: Any] = [
//             "id": authResponse.user.id,
//             "email": credentials.email,
//             "full_name": credentials.fullName ?? "",
//             "avatar_url": NSNull(),
//             "created_at": ISO8601DateFormatter().string(from: Date()),
//             "updated_at": ISO8601DateFormatter().string(from: Date()),
//             "subscription_status": "trial",
//             "subscription_plan": NSNull(),
//             "subscription_expires_at": NSNull(),
//             "trial_ends_at": ISO8601DateFormatter().string(from: Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()),
//             // Default feature flags for new users (trial features)
//             "unlimited_transcriptions": true,
//             "ai_enhancement": true,
//             "cloud_sync": false,
//             "advanced_settings": true,
//             "priority_support": false,
//             "team_features": false
//         ]
        
//         // Try to insert the user profile into the database
//         do {
//             let url = URL(string: "\(supabaseURL)/rest/v1/user_profiles")!
//             var request = URLRequest(url: url)
//             request.httpMethod = "POST"
//             request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//             request.setValue("Bearer \(authResponse.accessToken)", forHTTPHeaderField: "Authorization")
//             request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
//             request.setValue("return=minimal", forHTTPHeaderField: "Prefer")
            
//             request.httpBody = try JSONSerialization.data(withJSONObject: userData)
            
//             let (_, httpResponse) = try await urlSession.data(for: request)
//             try validateHTTPResponse(httpResponse, data: Data())
//         } catch {
//             // If database insert fails, we'll still return a user object
//             // This ensures sign-up doesn't fail even if database is not set up
//             print("Warning: Could not create user profile in database: \(error)")
//         }
        
//         return try User(from: userData)
//     }
    
//     private func validateHTTPResponse(_ response: URLResponse?, data: Data) throws {
//         guard let httpResponse = response as? HTTPURLResponse else {
//             throw AuthError.networkError
//         }
        
//         // If status code is success just return
//         if (200...299).contains(httpResponse.statusCode) {
//             return
//         }
        
//         // Try to decode Supabase error payload once so we can reuse it
//         var errorData: [String: Any]? = nil
//         if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
//             errorData = json
//         }
        
//         // Extract convenience fields
//         let errorCode = errorData?["error_code"] as? String
//         let message = errorData?["message"] as? String ?? errorData?["error_description"] as? String
        
//         // Debug-print full body for easier troubleshooting
//         if let raw = String(data: data, encoding: .utf8) {
//             print("HTTP Error \(httpResponse.statusCode): \(raw)")
//         }
        
//         // Handle known Supabase / GoTrue error codes first so callers can react precisely
//         if httpResponse.statusCode == 400 {
//             switch errorCode {
//             case "email_not_confirmed":
//                 throw AuthError.emailNotConfirmed
//             case "refresh_token_not_found":
//                 // Refresh token has been revoked or already rotated – treat as invalid credentials so session is cleared.
//                 throw AuthError.invalidCredentials
//             default:
//                 break
//             }
//         }
        
//         // Fallback handling based on status code
//         switch httpResponse.statusCode {
//         case 400:
//             throw AuthError.invalidCredentials
//         case 401:
//             throw AuthError.unauthorized
//         case 422:
//             throw AuthError.validationError
//         case 429:
//             throw AuthError.rateLimited
//         default:
//             throw AuthError.serverError(message ?? "HTTP \(httpResponse.statusCode)")
//         }
//     }
    
//     // MARK: - Network Helpers
    
//     private func performRequestWithRetry(request: URLRequest, maxRetries: Int = 1) async throws -> (Data, URLResponse) {
//         var lastError: Error?
        
//         for attempt in 0...maxRetries {
//             do {
//                 print("🔄 Attempting request (attempt \(attempt + 1)/\(maxRetries + 1))")
//                 let result = try await urlSession.data(for: request)
//                 print("✅ Request succeeded on attempt \(attempt + 1)")
//                 return result
//             } catch {
//                 lastError = error
//                 print("❌ Request failed on attempt \(attempt + 1): \(error.localizedDescription)")
                
//                 // Check if this is a timeout error
//                 if let urlError = error as? URLError {
//                     switch urlError.code {
//                     case .timedOut, .networkConnectionLost:
//                         print("🕐 Network timeout detected")
//                     case .notConnectedToInternet:
//                         print("📶 No internet connection")
//                     default:
//                         print("🌐 Other network error: \(urlError.code.rawValue)")
//                     }
//                 }
                
//                 // Don't retry on the last attempt
//                 if attempt < maxRetries {
//                     // Short retry delay
//                     try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
//                 }
//             }
//         }
        
//         // Check what type of error to throw
//         if let urlError = lastError as? URLError {
//             switch urlError.code {
//             case .timedOut, .networkConnectionLost:
//                 throw AuthError.networkTimeout
//             case .notConnectedToInternet:
//                 throw AuthError.networkError
//             default:
//                 throw AuthError.networkError
//             }
//         }
        
//         throw lastError ?? AuthError.networkError
//     }
    
//     // MARK: - Keychain Helpers
    
//     private func storeInKeychain(key: String, data: Data) {
//         let query: [String: Any] = [
//             kSecClass as String: kSecClassGenericPassword,
//             kSecAttrService as String: keychainService,
//             kSecAttrAccount as String: key,
//             kSecValueData as String: data
//         ]
        
//         // Delete existing item first
//         SecItemDelete(query as CFDictionary)
        
//         // Add new item
//         let status = SecItemAdd(query as CFDictionary, nil)
//         if status != errSecSuccess {
//             print("Failed to store in keychain: \(status)")
//         }
//     }
    
//     private func getFromKeychain(key: String) -> Data? {
//         let query: [String: Any] = [
//             kSecClass as String: kSecClassGenericPassword,
//             kSecAttrService as String: keychainService,
//             kSecAttrAccount as String: key,
//             kSecReturnData as String: true,
//             kSecMatchLimit as String: kSecMatchLimitOne
//         ]
        
//         var result: AnyObject?
//         let status = SecItemCopyMatching(query as CFDictionary, &result)
        
//         if status == errSecSuccess {
//             return result as? Data
//         }
        
//         return nil
//     }
    
//     private func removeFromKeychain(key: String) {
//         let query: [String: Any] = [
//             kSecClass as String: kSecClassGenericPassword,
//             kSecAttrService as String: keychainService,
//             kSecAttrAccount as String: key
//         ]
        
//         SecItemDelete(query as CFDictionary)
//     }
    
//     // MARK: - Public API Access
    
//     var apiURL: String { supabaseURL }
//     var apiKey: String { supabaseKey }
    
//     // MARK: - Singleton
//     static let shared = SupabaseService()
// }

// // MARK: - Error Types

// enum AuthError: Error, LocalizedError {
//     case noSession
//     case invalidCredentials
//     case unauthorized
//     case networkError
//     case networkTimeout
//     case validationError
//     case serverError(String)
//     case rateLimited
//     case emailNotConfirmed
    
//     var errorDescription: String? {
//         switch self {
//         case .noSession:
//             return "No active session found. Please sign in."
//         case .invalidCredentials:
//             return "Invalid email or password."
//         case .unauthorized:
//             return "Session expired. Please sign in again."
//         case .networkError:
//             return "Network connection error. Please check your internet connection and try again."
//         case .networkTimeout:
//             return "Connection timed out. Please check your internet connection and try again."
//         case .validationError:
//             return "Please check your input and try again."
//         case .serverError(let message):
//             return "Server error: \(message)"
//         case .rateLimited:
//             return "Too many requests. Please wait a moment and try again."
//         case .emailNotConfirmed:
//             return "Please check your email and click the verification link to complete sign-up."
//         }
//     }
// }

// // MARK: - Saved Credentials

// struct SavedCredentials: Codable {
//     let email: String
//     let password: String
// }
