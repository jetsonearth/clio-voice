import Foundation
import os

// MARK: - Remote Config Models

struct RemoteConfig: Codable {
    let sonioxAccounts: [RemoteSonioxAccount]
    let features: [String: Bool]
    let lastUpdated: Date
    let configVersion: String
}

struct RemoteSonioxAccount: Codable {
    let id: String
    let apiKey: String
    let maxConcurrency: Int
    let isEnabled: Bool
    let region: String?
}

// MARK: - Remote Config Service

@MainActor
class RemoteConfigService: ObservableObject {
    static let shared = RemoteConfigService()
    
    @Published private(set) var isLoading = false
    @Published private(set) var lastFetchTime: Date?
    @Published private(set) var currentConfig: RemoteConfig?
    
    private let logger = Logger(subsystem: "com.jetsonai.clio", category: "RemoteConfig")
    private let configEndpoint = "https://api.tryclio.com/v1/config"
    private let cacheKey = "CachedRemoteConfig"
    private let refreshInterval: TimeInterval = 3600 // 1 hour
    
    private init() {
        loadCachedConfig()
        Task {
            await fetchRemoteConfig()
        }
        startPeriodicRefresh()
    }
    
    // MARK: - Configuration Fetching
    
    func fetchRemoteConfig() async {
        guard !isLoading else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Build request with app info
            var request = URLRequest(url: URL(string: configEndpoint)!)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            // Add app version and platform headers
            if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                request.setValue(appVersion, forHTTPHeaderField: "X-App-Version")
            }
            request.setValue("macOS", forHTTPHeaderField: "X-Platform")
            
            // Add device ID for tracking (anonymized)
            if let deviceId = getDeviceIdentifier() {
                request.setValue(deviceId, forHTTPHeaderField: "X-Device-ID")
            }
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                logger.error("❌ Invalid response from config server")
                return
            }
            
            let config = try JSONDecoder().decode(RemoteConfig.self, from: data)
            
            // Update config and cache
            currentConfig = config
            lastFetchTime = Date()
            cacheConfig(config)
            
            // Update account pool with new accounts
            updateAccountPool(with: config)
            
            logger.notice("✅ Fetched remote config (version: \(config.configVersion), accounts: \(config.sonioxAccounts.count))")
            
        } catch {
            logger.error("❌ Failed to fetch remote config: \(error.localizedDescription)")
            // Continue using cached config
        }
    }
    
    // MARK: - Account Pool Updates
    
    private func updateAccountPool(with config: RemoteConfig) {
        // This would update SonioxAccountPool with new accounts
        // For now, we'll just log the update
        let enabledAccounts = config.sonioxAccounts.filter { $0.isEnabled }
        logger.notice("📊 Remote config has \(enabledAccounts.count) enabled Soniox accounts")
        
        // In a real implementation, you'd update the account pool:
        // SonioxAccountPool.shared.updateAccounts(enabledAccounts)
    }
    
    // MARK: - Caching
    
    private func loadCachedConfig() {
        guard let data = UserDefaults.standard.data(forKey: cacheKey),
              let config = try? JSONDecoder().decode(RemoteConfig.self, from: data) else {
            logger.notice("📭 No cached config found")
            return
        }
        
        currentConfig = config
        logger.notice("📦 Loaded cached config (version: \(config.configVersion))")
    }
    
    private func cacheConfig(_ config: RemoteConfig) {
        if let data = try? JSONEncoder().encode(config) {
            UserDefaults.standard.set(data, forKey: cacheKey)
        }
    }
    
    // MARK: - Periodic Refresh
    
    private func startPeriodicRefresh() {
        Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: true) { _ in
            Task { @MainActor in
                await self.fetchRemoteConfig()
            }
        }
    }
    
    // MARK: - Device Identification
    
    private func getDeviceIdentifier() -> String? {
        // Use a stable identifier that doesn't change across app launches
        // This could be stored in Keychain for persistence
        if let existingId = UserDefaults.standard.string(forKey: "DeviceIdentifier") {
            return existingId
        }
        
        let newId = UUID().uuidString
        UserDefaults.standard.set(newId, forKey: "DeviceIdentifier")
        return newId
    }
    
    // MARK: - Feature Flags
    
    func isFeatureEnabled(_ feature: String) -> Bool {
        currentConfig?.features[feature] ?? false
    }
}

// MARK: - Production Strategies Documentation

/*
 PRODUCTION API KEY MANAGEMENT STRATEGIES:
 
 1. **Remote Configuration Service** (Implemented above)
    - Fetch API keys from your secure backend
    - Update without app releases
    - Control which accounts are active
    - Monitor usage per account
    - A/B test different configurations
 
 2. **CloudKit Integration**
    - Use Apple's CloudKit for configuration
    - Private database for API keys
    - Push notifications for instant updates
    - No server infrastructure needed
 
 3. **Certificate Pinning + Encrypted Storage**
    - Store encrypted API keys in the app
    - Decrypt with keys from your server
    - Rotate encryption keys periodically
 
 4. **Proxy Server Architecture**
    - App connects to your proxy server
    - Proxy manages Soniox connections
    - Complete control over API key rotation
    - Add rate limiting, analytics, etc.
 
 5. **Firebase Remote Config**
    - Quick setup with Firebase
    - Real-time updates
    - User segmentation
    - A/B testing built-in
 
 RECOMMENDED APPROACH:
 
 For Clio, I recommend the Remote Configuration Service (option 1) because:
 - You maintain full control
 - Can update API keys instantly
 - Monitor usage and health per account
 - Scale by adding accounts to your backend
 - No app updates needed for new accounts
 
 The service would work like:
 1. App fetches config on launch and periodically
 2. Config includes array of Soniox accounts
 3. Account pool uses these dynamically
 4. You can disable/enable accounts remotely
 5. Add new accounts without app updates
 */