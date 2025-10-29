import Foundation
import Security
import CryptoKit

/// Secure keychain manager for storing sensitive trial data
@MainActor
class KeychainManager: ObservableObject {
    static let shared = KeychainManager()
    
    private init() {}
    
    // MARK: - Keychain Keys
    private enum KeychainKey: String {
        case trialStartDate = "com.clio.trial.start_date"
        case trialExpiryDate = "com.clio.trial.expiry_date"
        case trialChecksum = "com.clio.trial.checksum"
        case deviceFingerprint = "com.clio.device.fingerprint"
        case secureTrialData = "com.clio.trial.secure_data"
        case secureTrialKey = "com.clio.trial.secure_key"
    }
    
    // MARK: - Trial Data Management
    
    /// Store trial start and expiry dates securely
    func setTrialDates(startDate: Date, expiryDate: Date) -> Bool {
        // Create data to store
        let trialData = TrialData(
            startDate: startDate,
            expiryDate: expiryDate,
            deviceId: DeviceFingerprintService.shared.getDeviceId()
        )
        
        guard let encodedData = try? JSONEncoder().encode(trialData),
              let checksum = generateChecksum(for: trialData) else {
            return false
        }
        
        // Store trial dates and checksum
        let startSuccess = setKeychainData(encodedData, for: .trialStartDate)
        let checksumSuccess = setKeychainData(checksum.data(using: .utf8)!, for: .trialChecksum)
        
        return startSuccess && checksumSuccess
    }
    
    /// Retrieve trial dates with integrity validation
    func getTrialDates() -> (startDate: Date, expiryDate: Date)? {
        guard let trialData = getKeychainData(for: .trialStartDate),
              let decodedTrialData = try? JSONDecoder().decode(TrialData.self, from: trialData),
              let checksumData = getKeychainData(for: .trialChecksum),
              let storedChecksum = String(data: checksumData, encoding: .utf8) else {
            return nil
        }
        
        // Validate integrity
        guard let expectedChecksum = generateChecksum(for: decodedTrialData),
              expectedChecksum == storedChecksum else {
            print("⚠️ Trial data integrity check failed - possible tampering detected")
            return nil
        }
        
        // Validate device ID hasn't changed
        let currentDeviceId = DeviceFingerprintService.shared.getDeviceId()
        guard decodedTrialData.deviceId == currentDeviceId else {
            print("ℹ️ Device ID mismatch detected - this can happen after system updates or hardware changes")
            print("   Stored: \(decodedTrialData.deviceId)")
            print("   Current: \(currentDeviceId)")
            // Clear the inconsistent data and allow regeneration
            _ = clearTrialData()
            return nil
        }
        
        return (startDate: decodedTrialData.startDate, expiryDate: decodedTrialData.expiryDate)
    }
    
    /// Check if trial data exists
    func hasTrialData() -> Bool {
        return getKeychainData(for: .trialStartDate) != nil
    }
    
    /// Remove all trial data (for testing or trial reset)
    func clearTrialData() -> Bool {
        let startSuccess = deleteKeychainData(for: .trialStartDate)
        let checksumSuccess = deleteKeychainData(for: .trialChecksum)
        
        return startSuccess && checksumSuccess
    }
    
    // MARK: - Generic Keychain Operations
    
    private func setKeychainData(_ data: Data, for key: KeychainKey) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.clio.app",
            kSecAttrAccount as String: key.rawValue,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        // Delete existing item first
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    private func getKeychainData(for key: KeychainKey) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.clio.app",
            kSecAttrAccount as String: key.rawValue,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess {
            return result as? Data
        }
        
        return nil
    }
    
    private func deleteKeychainData(for key: KeychainKey) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.clio.app",
            kSecAttrAccount as String: key.rawValue
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
    
    // MARK: - Secure Trial Data Management
    
    func storeSecureTrialData(_ trialData: SecureTrialData) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(trialData)
        
        // Additional encryption layer using CryptoKit
        let key = SymmetricKey(size: .bits256)
        let encryptedData = try AES.GCM.seal(data, using: key)
        
        // Store both the encrypted data and key separately
        let combinedData = encryptedData.combined ?? Data()
        let keyData = key.withUnsafeBytes { Data($0) }
        
        let success1 = setKeychainData(combinedData, for: .secureTrialData)
        let success2 = setKeychainData(keyData, for: .secureTrialKey)
        
        if !success1 || !success2 {
            throw KeychainError.storeFailed
        }
    }
    
    func getSecureTrialData() -> SecureTrialData? {
        guard let encryptedData = getKeychainData(for: .secureTrialData),
              let keyData = getKeychainData(for: .secureTrialKey) else {
            return nil
        }
        
        do {
            let key = SymmetricKey(data: keyData)
            let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
            let decryptedData = try AES.GCM.open(sealedBox, using: key)
            
            let decoder = JSONDecoder()
            return try decoder.decode(SecureTrialData.self, from: decryptedData)
        } catch {
            print("❌ [KEYCHAIN] Failed to decrypt secure trial data: \(error)")
            return nil
        }
    }
    
    func removeSecureTrialData() {
        _ = deleteKeychainData(for: .secureTrialData)
        _ = deleteKeychainData(for: .secureTrialKey)
    }
    
    // MARK: - Integrity Checking
    
    private func generateChecksum(for trialData: TrialData) -> String? {
        // Create a deterministic string from trial data
        let dataString = "\(trialData.startDate.timeIntervalSince1970)|\(trialData.expiryDate.timeIntervalSince1970)|\(trialData.deviceId)"
        
        guard let data = dataString.data(using: .utf8) else { return nil }
        
        // Use SHA256 for integrity checking
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - Supporting Types

private struct TrialData: Codable {
    let startDate: Date
    let expiryDate: Date
    let deviceId: String
}

enum KeychainError: Error {
    case storeFailed
    case retrievalFailed
    case encryptionFailed
    case decryptionFailed
}