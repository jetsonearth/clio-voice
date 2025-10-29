import Foundation

/// HTTP Protocol configuration for testing HTTP/3 vs HTTP/2 performance
enum HTTPProtocolPreference: String, CaseIterable {
    case http2Only = "h2-only"          // Force HTTP/2 (legacy behavior)
    case http3Preferred = "h3-preferred" // Prefer HTTP/3, fallback to HTTP/2
    case automatic = "auto"              // Let URLSession decide
    
    var displayName: String {
        switch self {
        case .http2Only:
            return "HTTP/2 Only (Legacy)"
        case .http3Preferred:
            return "HTTP/3 Preferred (Default)"
        case .automatic:
            return "Automatic Negotiation"
        }
    }
    
    var description: String {
        switch self {
        case .http2Only:
            return "Force HTTP/2 connections (previous behavior)"
        case .http3Preferred:
            return "Enable HTTP/3 with automatic fallback to HTTP/2"
        case .automatic:
            return "Let URLSession automatically choose the best protocol"
        }
    }
}

/// Configuration manager for HTTP protocol preferences
@MainActor
class HTTPProtocolConfiguration: ObservableObject {
    static let shared = HTTPProtocolConfiguration()
    
    private let userDefaultsKey = "HTTPProtocolPreference"
    
    @Published var currentPreference: HTTPProtocolPreference {
        didSet {
            UserDefaults.standard.set(currentPreference.rawValue, forKey: userDefaultsKey)
            objectWillChange.send()
        }
    }
    
    private init() {
        // Load from UserDefaults or default to HTTP/3 preferred
        if let savedValue = UserDefaults.standard.string(forKey: userDefaultsKey),
           let preference = HTTPProtocolPreference(rawValue: savedValue) {
            self.currentPreference = preference
        } else {
            // Default to HTTP/3 preferred for new installations
            self.currentPreference = .http3Preferred
            UserDefaults.standard.set(HTTPProtocolPreference.http3Preferred.rawValue, forKey: userDefaultsKey)
        }
    }
    
    /// Check if HTTP/3 should be enabled based on current preference
    var isHTTP3Enabled: Bool {
        switch currentPreference {
        case .http2Only:
            return false
        case .http3Preferred, .automatic:
            return true
        }
    }
    
    /// Get remote config preference if available, otherwise use local setting
    func getEffectivePreference() -> HTTPProtocolPreference {
        // Check remote config first
        if RemoteConfigService.shared.isFeatureEnabled("forceHTTP2") {
            return .http2Only
        } else if RemoteConfigService.shared.isFeatureEnabled("enableHTTP3") {
            return .http3Preferred
        }
        
        // Fall back to local preference
        return currentPreference
    }
    
    /// Update preference for A/B testing
    func setPreferenceForTesting(_ preference: HTTPProtocolPreference) {
        currentPreference = preference
    }
    
    /// Get debug info for logging
    var debugInfo: String {
        let effective = getEffectivePreference()
        let remote = RemoteConfigService.shared.currentConfig != nil ? "remote available" : "local only"
        return "HTTP Protocol: \(effective.rawValue) (\(remote))"
    }
}