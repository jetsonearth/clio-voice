import Foundation
import Security
import os

/// Manages JWT tokens for Clio Online services
@MainActor
final class TokenManager: ObservableObject {
    static let shared = TokenManager()
    
    @Published var isAuthenticated = false
    @Published var connectionStatus: ConnectionStatus = .offline
    
    private var apiBaseURL: String {
        return APIConfig.apiBaseURL
    }
    private let keychainService = "com.cliovoice.tokens"
    private let tokenKey = "jwt_token"
    private let deviceIdKey = "device_id"
    
    private var currentToken: String?
    private var tokenExpirationDate: Date?
    private var deviceId: String
    
    private let logger = Logger(
        subsystem: "com.cliovoice.clio",
        category: "tokenmanager"
    )
    
    enum ConnectionStatus {
        case offline
        case connecting
        case online
        case error(String)
    }
    
    private init() {
        // Generate or retrieve device ID
        if let storedDeviceId = UserDefaults.standard.string(forKey: deviceIdKey) {
            self.deviceId = storedDeviceId
        } else {
            self.deviceId = "clio_\(UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(16))"
            UserDefaults.standard.set(self.deviceId, forKey: deviceIdKey)
        }
        
        // Try to load existing token
        loadStoredToken()
    }
    
    // MARK: - Public Methods
    
    /// Get valid JWT token, refreshing if necessary
    func getValidToken() async throws -> String {
        // Check if current token is valid and not expired
        if let token = currentToken,
           let expirationDate = tokenExpirationDate,
           Date().addingTimeInterval(300) < expirationDate { // Refresh 5 minutes before expiry (optimized from 1 minute)
            
            // Start background refresh if we're within 10 minutes of expiry
            if Date().addingTimeInterval(600) >= expirationDate {
                Task {
                    do {
                        _ = try await refreshToken()
                        logger.notice("🔄 Background token refresh completed")
                    } catch {
                        logger.notice("⚠️ Background token refresh failed: \(error)")
                    }
                }
            }
            
            return token
        }
        
        // Need to get a new token
        return try await refreshToken()
    }
    
    /// Force refresh the JWT token
    func refreshToken() async throws -> String {
        connectionStatus = .connecting
        
        let url = URL(string: "\(apiBaseURL)/auth/session-inline")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = [
            "deviceId": deviceId
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw TokenError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                throw TokenError.authenticationFailed(httpResponse.statusCode)
            }
            
            let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
            
            // Store token and calculate expiration
            currentToken = tokenResponse.token
            tokenExpirationDate = Date().addingTimeInterval(TimeInterval(tokenResponse.expiresIn))
            
            // Save to keychain
            try saveTokenToKeychain(tokenResponse.token)
            
            isAuthenticated = true
            connectionStatus = .online
            
            return tokenResponse.token
            
        } catch {
            connectionStatus = .error(error.localizedDescription)
            isAuthenticated = false
            throw error
        }
    }
    
    /// Clear stored token and logout
    func logout() {
        currentToken = nil
        tokenExpirationDate = nil
        isAuthenticated = false
        connectionStatus = .offline
        
        // Clear from keychain
        deleteTokenFromKeychain()
    }
    
    // MARK: - Private Methods
    
    private func loadStoredToken() {
        guard let token = loadTokenFromKeychain() else { return }
        
        // Try to decode the token to check expiration
        if let payload = decodeJWTPayload(token),
           let exp = payload["exp"] as? TimeInterval {
            let expirationDate = Date(timeIntervalSince1970: exp)
            
            // Only use token if it's not expired
            if expirationDate > Date() {
                currentToken = token
                tokenExpirationDate = expirationDate
                isAuthenticated = true
                connectionStatus = .online
            }
        }
    }
    
    private func decodeJWTPayload(_ token: String) -> [String: Any]? {
        let segments = token.components(separatedBy: ".")
        guard segments.count == 3 else { return nil }
        
        let payloadSegment = segments[1]
        
        // Add padding if needed
        var base64String = payloadSegment
        let remainder = base64String.count % 4
        if remainder > 0 {
            base64String += String(repeating: "=", count: 4 - remainder)
        }
        
        guard let data = Data(base64Encoded: base64String) else { return nil }
        
        return try? JSONSerialization.jsonObject(with: data) as? [String: Any]
    }
    
    // MARK: - Keychain Operations
    
    private func saveTokenToKeychain(_ token: String) throws {
        let data = token.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: tokenKey,
            kSecValueData as String: data
        ]
        
        // Delete existing item first
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw TokenError.keychainError(status)
        }
    }
    
    private func loadTokenFromKeychain() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: tokenKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let token = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return token
    }
    
    private func deleteTokenFromKeychain() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: tokenKey
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}

// MARK: - Response Models

private struct TokenResponse: Codable {
    let token: String
    let expiresIn: Int
    let session: SessionInfo
}

private struct SessionInfo: Codable {
    let id: String
    let plan: String
    let dailyUsage: DailyUsage
}

private struct DailyUsage: Codable {
    let audioSeconds: Int
    let llmTokens: Int
    let lastReset: String
}

// MARK: - Errors

enum TokenError: LocalizedError {
    case invalidResponse
    case authenticationFailed(Int)
    case keychainError(OSStatus)
    case tokenExpired
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .authenticationFailed(let statusCode):
            return "Authentication failed with status \(statusCode)"
        case .keychainError(let status):
            return "Keychain error: \(status)"
        case .tokenExpired:
            return "Token has expired"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}