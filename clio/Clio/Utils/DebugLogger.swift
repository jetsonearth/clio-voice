import Foundation
import os.log

/// Centralized debug logging system to control verbose output
struct DebugLogger {
    
    // MARK: - Configuration
    
    /// Master switch for all debug logging (disable in production)
    static let isDebugLoggingEnabled: Bool = {
        #if DEBUG
        return UserDefaults.standard.bool(forKey: "DebugLoggingEnabled") // Default: false unless explicitly enabled
        #else
        return false // Always disabled in release builds
        #endif
    }()
    
    /// Specific category controls
    static let enableAuthLogging = isDebugLoggingEnabled && UserDefaults.standard.bool(forKey: "DebugAuthLogging")
    static let enableSubscriptionLogging = isDebugLoggingEnabled && UserDefaults.standard.bool(forKey: "DebugSubscriptionLogging")
    static let enableAudioLogging = isDebugLoggingEnabled && UserDefaults.standard.bool(forKey: "DebugAudioLogging")
    static let enableNetworkLogging = isDebugLoggingEnabled && UserDefaults.standard.bool(forKey: "DebugNetworkLogging")
    static let enableSupabaseSDKLogging = isDebugLoggingEnabled && UserDefaults.standard.bool(forKey: "DebugSupabaseSDKLogging")
    /// Performance logging can be enabled independently of the master debug switch
    static let enablePerformanceLogging = UserDefaults.standard.bool(forKey: "DebugPerformanceLogging")
    
    // MARK: - Logging Categories
    
    enum Category: String {
        case auth = "AUTH"
        case subscription = "SUBSCRIPTION"
        case audio = "AUDIO"
        case network = "NETWORK"
        case supabase = "SUPABASE"
        case performance = "PERF"
        case general = "GENERAL"
        
        var logger: Logger {
            return Logger(subsystem: "com.cliovoice.clio", category: self.rawValue)
        }
        
        var isEnabled: Bool {
            switch self {
            case .auth: return enableAuthLogging
            case .subscription: return enableSubscriptionLogging
            case .audio: return enableAudioLogging
            case .network: return enableNetworkLogging
            case .supabase: return enableSupabaseSDKLogging
            case .performance: return enablePerformanceLogging
            case .general: return isDebugLoggingEnabled
            }
        }
    }
    
    // MARK: - Logging Methods
    
    /// Log debug information (only in debug builds with category enabled)
    static func debug(_ message: String, category: Category = .general, file: String = #file, function: String = #function, line: Int = #line) {
        guard !RuntimeConfig.shouldSilenceAllLogs, category.isEnabled else { return }
        
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        let formatted = "🔍 [\(category.rawValue)] \(message)"
        
        category.logger.debug("\(formatted, privacy: .public)")
        print(formatted) // Also print to console for immediate visibility
    }
    
    /// Log info (always shown but can be controlled by category)
    static func info(_ message: String, category: Category = .general) {
        if RuntimeConfig.shouldSilenceAllLogs { return }
        let formatted = "ℹ️ [\(category.rawValue)] \(message)"
        category.logger.info("\(formatted, privacy: .public)")
        if category.isEnabled {
            print(formatted)
        }
    }
    
    /// Log success (always shown)
    static func success(_ message: String, category: Category = .general) {
        if RuntimeConfig.shouldSilenceAllLogs { return }
        let formatted = "✅ [\(category.rawValue)] \(message)"
        category.logger.info("\(formatted, privacy: .public)")
        print(formatted)
    }
    
    /// Log errors (always shown)
    static func error(_ message: String, category: Category = .general) {
        if RuntimeConfig.shouldSilenceAllLogs { return }
        let formatted = "❌ [\(category.rawValue)] \(message)"
        category.logger.error("\(formatted, privacy: .public)")
        print(formatted)
    }
    
    /// Log warnings (always shown)
    static func warning(_ message: String, category: Category = .general) {
        if RuntimeConfig.shouldSilenceAllLogs { return }
        let formatted = "⚠️ [\(category.rawValue)] \(message)"
        category.logger.log(level: .error, "\(formatted, privacy: .public)")
        print(formatted)
    }
    
    // MARK: - Convenience Methods for Common Patterns
    
    /// Log state changes (controlled by category)
    static func stateChange(_ message: String, category: Category) {
        debug("State: \(message)", category: category)
    }
    
    /// Log performance timing (debug only)
    static func timing(_ message: String, duration: TimeInterval, category: Category) {
        debug("⏱️ \(message) (\(Int(duration * 1000))ms)", category: category)
    }
    
    /// Log start of operations (debug only)
    static func start(_ operation: String, category: Category) {
        debug("🚀 Starting: \(operation)", category: category)
    }
    
    /// Log completion of operations (info level)
    static func completed(_ operation: String, category: Category) {
        info("✅ Completed: \(operation)", category: category)
    }
}

// MARK: - UserDefaults Extension for Debug Settings

extension UserDefaults {
    /// Enable debug logging for development
    func enableDebugLogging(auth: Bool = false, subscription: Bool = false, audio: Bool = false, network: Bool = false, supabase: Bool = false, performance: Bool = false) {
        set(true, forKey: "DebugLoggingEnabled")
        set(auth, forKey: "DebugAuthLogging")
        set(subscription, forKey: "DebugSubscriptionLogging") 
        set(audio, forKey: "DebugAudioLogging")
        set(network, forKey: "DebugNetworkLogging")
        set(supabase, forKey: "DebugSupabaseSDKLogging")
        set(performance, forKey: "DebugPerformanceLogging")
    }
    
    /// Disable all debug logging
    func disableAllDebugLogging() {
        set(false, forKey: "DebugLoggingEnabled")
        set(false, forKey: "DebugAuthLogging")
        set(false, forKey: "DebugSubscriptionLogging")
        set(false, forKey: "DebugAudioLogging")
        set(false, forKey: "DebugNetworkLogging")
        set(false, forKey: "DebugSupabaseSDKLogging")
        set(false, forKey: "DebugPerformanceLogging")
    }
}
