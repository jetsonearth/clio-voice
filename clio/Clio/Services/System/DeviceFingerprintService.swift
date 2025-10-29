import Foundation
import IOKit
import CryptoKit

@MainActor
class DeviceFingerprintService: ObservableObject {
    static let shared = DeviceFingerprintService()
    
    private let userDefaults = UserDefaults.standard
    private let deviceIdKey = "ClioDeviceId"
    private let installIdKey = "ClioInstallId"
    
    private init() {}
    
    // MARK: - Device Identification
    
    /// Get a unique device identifier that persists across app reinstalls
    func getDeviceId() -> String {
        // First check if we have a stored device ID
        if let storedId = userDefaults.string(forKey: deviceIdKey) {
            return storedId
        }
        
        // Generate a new device ID based on hardware info
        let hardwareId = getHardwareIdentifier()
        let installId = getInstallId()
        
        // Create a composite ID that includes hardware info
        let compositeId = "\(hardwareId)-\(installId)"
        let deviceId = sha256Hash(compositeId)
        
        // Store it for future use
        userDefaults.set(deviceId, forKey: deviceIdKey)
        
        return deviceId
    }
    
    /// Get install-specific ID (changes with each install)
    func getInstallId() -> String {
        if let storedId = userDefaults.string(forKey: installIdKey) {
            return storedId
        }
        
        let installId = UUID().uuidString
        userDefaults.set(installId, forKey: installIdKey)
        
        return installId
    }
    
    /// Get hardware-based identifier (persists across reinstalls)
    private func getHardwareIdentifier() -> String {
        var hardwareInfo: [String] = []
        
        // Get Mac serial number
        if let serialNumber = getMacSerialNumber() {
            hardwareInfo.append(serialNumber)
        }
        
        // Get MAC address of primary network interface
        if let macAddress = getPrimaryMACAddress() {
            hardwareInfo.append(macAddress)
        }
        
        // Get system UUID
        if let systemUUID = getSystemUUID() {
            hardwareInfo.append(systemUUID)
        }
        
        // If we couldn't get any hardware info, fallback to a generated ID
        if hardwareInfo.isEmpty {
            return UUID().uuidString
        }
        
        return hardwareInfo.joined(separator: "-")
    }
    
    /// Get Mac serial number
    private func getMacSerialNumber() -> String? {
        let platformExpert = IOServiceGetMatchingService(
            kIOMainPortDefault,
            IOServiceMatching("IOPlatformExpertDevice")
        )
        
        defer {
            IOObjectRelease(platformExpert)
        }
        
        guard platformExpert > 0 else { return nil }
        
        guard let serialNumber = IORegistryEntryCreateCFProperty(
            platformExpert,
            kIOPlatformSerialNumberKey as CFString,
            kCFAllocatorDefault,
            0
        )?.takeUnretainedValue() as? String else {
            return nil
        }
        
        return serialNumber
    }
    
    /// Get primary network interface MAC address
    private func getPrimaryMACAddress() -> String? {
        // Get list of all interfaces
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        defer { freeifaddrs(ifaddr) }
        
        var primaryMAC: String?
        var ptr = ifaddr
        
        while ptr != nil {
            defer { ptr = ptr?.pointee.ifa_next }
            
            let interface = ptr?.pointee
            let addrFamily = interface?.ifa_addr.pointee.sa_family
            
            // Check if interface is AF_LINK (hardware)
            if addrFamily == UInt8(AF_LINK) {
                let name = String(cString: (interface?.ifa_name)!)
                
                // Look for en0 (primary ethernet/wifi interface)
                if name == "en0" {
                    let addr = interface?.ifa_addr.withMemoryRebound(to: sockaddr_dl.self, capacity: 1) { $0 }
                    if let dlAddr = addr?.pointee {
                        // Simplified MAC address extraction
                        let dataPtr = withUnsafePointer(to: dlAddr.sdl_data) { ptr in
                            ptr.withMemoryRebound(to: UInt8.self, capacity: 12) { $0 }
                        }
                        
                        let offset = Int(dlAddr.sdl_nlen)
                        if offset + 6 <= 12 {
                            let macAddress = (0..<6).map { i in
                                String(format: "%02x", dataPtr[offset + i])
                            }.joined(separator: ":")
                            
                            if !macAddress.starts(with: "00:00:00") {
                                primaryMAC = macAddress
                                break
                            }
                        }
                    }
                }
            }
        }
        
        return primaryMAC
    }
    
    /// Get system UUID from IORegistry
    private func getSystemUUID() -> String? {
        let platformExpert = IOServiceGetMatchingService(
            kIOMainPortDefault,
            IOServiceMatching("IOPlatformExpertDevice")
        )
        
        defer {
            IOObjectRelease(platformExpert)
        }
        
        guard platformExpert > 0 else { return nil }
        
        guard let systemUUID = IORegistryEntryCreateCFProperty(
            platformExpert,
            kIOPlatformUUIDKey as CFString,
            kCFAllocatorDefault,
            0
        )?.takeUnretainedValue() as? String else {
            return nil
        }
        
        return systemUUID
    }
    
    /// SHA256 hash for consistent ID generation
    private func sha256Hash(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    // MARK: - Trial Management
    
    struct TrialInfo: Codable {
        let deviceId: String
        let trialStartDate: Date
        let trialUsedMinutes: Double
        let lastUsedDate: Date
    }
    
    /// Check if device has used trial
    func hasUsedTrial() -> Bool {
        return userDefaults.object(forKey: "ClioTrialInfo") != nil
    }
    
    /// Get trial info for current device
    func getTrialInfo() -> TrialInfo? {
        guard let data = userDefaults.data(forKey: "ClioTrialInfo"),
              let info = try? JSONDecoder().decode(TrialInfo.self, from: data) else {
            return nil
        }
        
        // Verify it matches current device
        if info.deviceId == getDeviceId() {
            return info
        }
        
        return nil
    }
    
    /// Start trial for current device
    func startTrial() {
        let info = TrialInfo(
            deviceId: getDeviceId(),
            trialStartDate: Date(),
            trialUsedMinutes: 0,
            lastUsedDate: Date()
        )
        
        if let data = try? JSONEncoder().encode(info) {
            userDefaults.set(data, forKey: "ClioTrialInfo")
        }
    }
    
    /// Update trial usage
    func updateTrialUsage(additionalMinutes: Double) {
        guard var info = getTrialInfo() else { return }
        
        let updatedInfo = TrialInfo(
            deviceId: info.deviceId,
            trialStartDate: info.trialStartDate,
            trialUsedMinutes: info.trialUsedMinutes + additionalMinutes,
            lastUsedDate: Date()
        )
        
        if let data = try? JSONEncoder().encode(updatedInfo) {
            userDefaults.set(data, forKey: "ClioTrialInfo")
        }
    }
    
    // DEPRECATED: Usage-based trial methods (commented out for time-based trials)
    // /// Get remaining trial minutes
    // func getRemainingTrialMinutes() -> Double {
    //     guard let info = getTrialInfo() else {
    //         return SubscriptionManager.TRIAL_DURATION_MINUTES // Default trial duration
    //     }
    //     
    //     return max(0, SubscriptionManager.TRIAL_DURATION_MINUTES - info.trialUsedMinutes)
    // }
    
    /// Get remaining trial days for time-based trials
    func getRemainingTrialDays() -> Int {
        guard let info = getTrialInfo() else {
            return SubscriptionManager.TRIAL_DURATION_DAYS // Default trial duration
        }
        
        // For device fingerprinting, we could track trial start date
        // For now, return default duration
        return SubscriptionManager.TRIAL_DURATION_DAYS
    }
    
    /// Check if trial has expired
    func isTrialExpired() -> Bool {
        return getRemainingTrialDays() <= 0
    }
    
    // MARK: - Analytics
    
    /// Get anonymous device info for analytics
    func getDeviceInfo() -> [String: Any] {
        var info: [String: Any] = [
            "device_id": getDeviceId(),
            "install_id": getInstallId(),
            "platform": "macOS",
            "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        ]
        
        // Add OS version
        let osVersion = ProcessInfo.processInfo.operatingSystemVersion
        info["os_version"] = "\(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)"
        
        // Add Mac model if available
        if let model = getMacModel() {
            info["device_model"] = model
        }
        
        return info
    }
    
    /// Get Mac model identifier
    private func getMacModel() -> String? {
        var size = 0
        sysctlbyname("hw.model", nil, &size, nil, 0)
        
        var model = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.model", &model, &size, nil, 0)
        
        return String(cString: model)
    }
}

// MARK: - Import required for network interfaces
import Darwin