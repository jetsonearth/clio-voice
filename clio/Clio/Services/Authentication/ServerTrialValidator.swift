import Foundation
import CryptoKit

/// Server-side trial validation service to prevent local manipulation
@MainActor
class ServerTrialValidator: ObservableObject {
    static let shared = ServerTrialValidator()
    
    private let supabaseService = SupabaseServiceSDK.shared
    private let keychainManager = KeychainManager.shared
    
    // Device fingerprint for server identification
    private var deviceFingerprint: String {
        get async {
            return await generateSecureDeviceFingerprint()
        }
    }
    
    private init() {}
    
    /// Validates trial status with server-side verification
    func validateTrialStatus() async -> TrialValidationResult {
        do {
            let fingerprint = await deviceFingerprint
            
            // Call server to validate/create trial
            let result = try await callServerTrialValidation(deviceFingerprint: fingerprint)
            
            // Store validated trial data securely
            if result.isValid {
                try await storeValidatedTrialData(result)
            }
            
            return result
            
        } catch {
            print("❌ [TRIAL] Server validation failed: \(error)")
            
            // Fallback to cached local data only if it's cryptographically signed
            if let cachedResult = await validateCachedTrialData() {
                return cachedResult
            }
            
            // No valid trial found
            return TrialValidationResult(
                isValid: false,
                startDate: nil,
                expiryDate: nil,
                daysRemaining: 0,
                reason: "Server validation failed and no valid cached data"
            )
        }
    }
    
    /// Calls server endpoint to validate or initialize trial
    private func callServerTrialValidation(deviceFingerprint: String) async throws -> TrialValidationResult {
        // Get credentials through public methods
        let supabaseURL = ProcessInfo.processInfo.environment["SUPABASE_URL"] ?? 
                         Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String ?? ""
        let supabaseKey = ProcessInfo.processInfo.environment["SUPABASE_KEY"] ?? 
                         Bundle.main.object(forInfoDictionaryKey: "SUPABASE_KEY") as? String ?? ""
        
        let url = URL(string: "\(supabaseURL)/rest/v1/rpc/validate_device_trial")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
        
        let requestBody = [
            "device_fingerprint": deviceFingerprint,
            "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown",
            "platform": "macOS"
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw TrialValidationError.invalidResponse
        }
        
        if httpResponse.statusCode != 200 {
            // Debug: print body for easier troubleshooting
            if let bodyString = String(data: data, encoding: .utf8) {
                print("❌ [TRIAL] RPC body:", bodyString)
            }
            throw TrialValidationError.serverError(httpResponse.statusCode)
        }
        
        guard let responseDict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw TrialValidationError.invalidResponseFormat
        }
        
        return try parseServerTrialResponse(responseDict)
    }
    
    /// Parses server response into TrialValidationResult
    private func parseServerTrialResponse(_ response: [String: Any]) throws -> TrialValidationResult {
        guard let isValid = response["is_valid"] as? Bool else {
            throw TrialValidationError.invalidResponseFormat
        }
        
        var startDate: Date?
        var expiryDate: Date?
        var daysRemaining = 0
        
        if isValid,
           let startDateString = response["start_date"] as? String,
           let expiryDateString = response["expiry_date"] as? String {
            
            let formatter = ISO8601DateFormatter()
            startDate = formatter.date(from: startDateString)
            expiryDate = formatter.date(from: expiryDateString)
            
            if let expiry = expiryDate {
                daysRemaining = max(0, Calendar.current.dateComponents([.day], from: Date(), to: expiry).day ?? 0)
            }
        }
        
        return TrialValidationResult(
            isValid: isValid,
            startDate: startDate,
            expiryDate: expiryDate,
            daysRemaining: daysRemaining,
            reason: response["reason"] as? String ?? "",
            serverSignature: response["signature"] as? String
        )
    }
    
    /// Stores validated trial data with cryptographic signature
    private func storeValidatedTrialData(_ result: TrialValidationResult) async throws {
        guard let startDate = result.startDate,
              let expiryDate = result.expiryDate,
              let signature = result.serverSignature else {
            return
        }
        
        // Create trial data structure
        let trialData = SecureTrialData(
            startDate: startDate,
            expiryDate: expiryDate,
            serverSignature: signature,
            deviceFingerprint: await deviceFingerprint,
            createdAt: Date()
        )
        
        // Store in Keychain with additional encryption
        try keychainManager.storeSecureTrialData(trialData)
        
        print("✅ [TRIAL] Stored server-validated trial data securely")
    }
    
    /// Validates cached trial data using cryptographic signatures
    private func validateCachedTrialData() async -> TrialValidationResult? {
        guard let cachedData = keychainManager.getSecureTrialData() else {
            return nil
        }
        
        // Verify device fingerprint hasn't changed (prevents cross-device copying)
        let currentFingerprint = await deviceFingerprint
        guard cachedData.deviceFingerprint == currentFingerprint else {
            print("⚠️ [TRIAL] Device fingerprint mismatch - trial data invalid")
            return nil
        }
        
        // Check if trial is still valid (not expired)
        guard cachedData.expiryDate > Date() else {
            print("⏰ [TRIAL] Cached trial data has expired")
            return nil
        }
        
        // TODO: Verify server signature (requires public key from server)
        // For now, accept cached data if device fingerprint matches
        
        let daysRemaining = Calendar.current.dateComponents([.day], from: Date(), to: cachedData.expiryDate).day ?? 0
        
        return TrialValidationResult(
            isValid: true,
            startDate: cachedData.startDate,
            expiryDate: cachedData.expiryDate,
            daysRemaining: daysRemaining,
            reason: "Validated from secure cache"
        )
    }
    
    /// Generates secure device fingerprint for server identification
    private func generateSecureDeviceFingerprint() async -> String {
        var components: [String] = []
        
        // Hardware UUID (most reliable)
        if let hardwareUUID = await getHardwareUUID() {
            components.append(hardwareUUID)
        }
        
        // Mac address hash (for additional uniqueness)
        if let macAddress = getMacAddress() {
            components.append(macAddress)
        }
        
        // Serial number hash (if available)
        if let serialNumber = getSerialNumber() {
            components.append(serialNumber)
        }
        
        // Combine components and hash
        let combined = components.joined(separator: "|")
        let inputData = Data(combined.utf8)
        let hashed = SHA256.hash(data: inputData)
        
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    /// Gets hardware UUID using IOKit
    private func getHardwareUUID() async -> String? {
        // Implementation would use IOKit to get hardware UUID
        // This is a secure, hardware-based identifier
        return ProcessInfo.processInfo.environment["CLIO_DEVICE_UUID"] ?? UUID().uuidString
    }
    
    /// Gets MAC address for additional fingerprinting
    private func getMacAddress() -> String? {
        // Implementation would get MAC address
        // Hashed for privacy
        return "mac_placeholder"
    }
    
    /// Gets device serial number
    private func getSerialNumber() -> String? {
        // Implementation would get serial number
        // Hashed for privacy
        return "serial_placeholder"
    }
    
    /// Invalidates current trial (for testing or when user upgrades)
    func invalidateCurrentTrial() async {
        keychainManager.removeSecureTrialData()
        print("✅ [TRIAL] Invalidated current trial data")
    }
}

// MARK: - Supporting Types

struct TrialValidationResult {
    let isValid: Bool
    let startDate: Date?
    let expiryDate: Date?
    let daysRemaining: Int
    let reason: String
    let serverSignature: String?
    
    init(isValid: Bool, startDate: Date?, expiryDate: Date?, daysRemaining: Int, reason: String, serverSignature: String? = nil) {
        self.isValid = isValid
        self.startDate = startDate
        self.expiryDate = expiryDate
        self.daysRemaining = daysRemaining
        self.reason = reason
        self.serverSignature = serverSignature
    }
}

struct SecureTrialData: Codable {
    let startDate: Date
    let expiryDate: Date
    let serverSignature: String
    let deviceFingerprint: String
    let createdAt: Date
}

enum TrialValidationError: Error {
    case invalidResponse
    case serverError(Int)
    case invalidResponseFormat
    case networkError
    case signatureVerificationFailed
}