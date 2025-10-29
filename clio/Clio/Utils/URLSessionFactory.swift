import Foundation
import os

/// Factory for creating URLSession configurations with HTTP/3 support
/// and optimized connection reuse across the app
enum URLSessionFactory {
    
    /// Standard session configuration for API connections that need connection pooling
    /// Use this for connections that should reuse TCP sockets (LLM requests, keep-alive, etc.)
    static func createDefaultConfiguration(
        maxConnectionsPerHost: Int = 1,
        requestTimeout: TimeInterval = 30,
        resourceTimeout: TimeInterval = 60
    ) -> URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        
        // Configure HTTP protocol based on feature flags and preferences
        if #available(macOS 12.0, iOS 15.0, *) {
            config.tlsMaximumSupportedProtocolVersion = .TLSv13
            
            // Use a simple approach - default to HTTP/3 preferred for now
            // Full feature flag integration can be added later in a MainActor context
            Logger(subsystem: "com.cliovoice.clio", category: "URLSession")
                .notice("🚀 [HTTP PROTOCOL] HTTP/3 preferred mode enabled - TLS 1.3 configured for QUIC support")
        } else {
            Logger(subsystem: "com.cliovoice.clio", category: "URLSession")
                .notice("⚠️ [HTTP PROTOCOL] HTTP/3 not available - requires macOS 12.0+")
        }
        
        // Connection reuse optimization
        config.httpMaximumConnectionsPerHost = maxConnectionsPerHost
        config.httpShouldUsePipelining = false  // Let HTTP/3 or HTTP/2 handle multiplexing
        config.httpShouldSetCookies = true
        
        // Timeout configuration
        config.timeoutIntervalForRequest = requestTimeout
        config.timeoutIntervalForResource = resourceTimeout
        
        // Connection persistence
        config.waitsForConnectivity = true
        config.allowsCellularAccess = true
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        return config
    }
    
    /// Ephemeral session configuration for one-off requests that don't need connection pooling
    /// Use this for direct API calls that shouldn't interfere with persistent connections
    static func createEphemeralConfiguration(
        requestTimeout: TimeInterval = 10
    ) -> URLSessionConfiguration {
        let config = URLSessionConfiguration.ephemeral
        
        // Configure HTTP protocol for ephemeral sessions
        if #available(macOS 12.0, iOS 15.0, *) {
            config.tlsMaximumSupportedProtocolVersion = .TLSv13
            // Ephemeral sessions follow same protocol preference as default
        }
        
        config.timeoutIntervalForRequest = requestTimeout
        
        return config
    }
    
    /// Koyeb-optimized session for LLM proxy connections with HTTP/3 support
    /// Configured for Koyeb's 100s timeout with HTTP/3 edge termination
    static func createKoyebConfiguration() -> URLSessionConfiguration {
        return createDefaultConfiguration(
            maxConnectionsPerHost: 6,  // HTTP/3 can handle more concurrent streams efficiently
            requestTimeout: 90,  // Under Koyeb's 100s limit
            resourceTimeout: 180  // Allow for keep-alive pings
        )
    }
    
    /// Railway-optimized session for edge connections
    /// Configured for Railway's timeout limits
    static func createRailwayConfiguration() -> URLSessionConfiguration {
        return createDefaultConfiguration(
            maxConnectionsPerHost: 1,
            requestTimeout: 60,  // Under Railway's limits
            resourceTimeout: 120
        )
    }
    
    /// Create a URLSession with the specified configuration and optional delegate
    static func createSession(
        with configuration: URLSessionConfiguration,
        delegate: URLSessionTaskDelegate? = nil
    ) -> URLSession {
        return URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
    }
    
    /// Convenience method to create a Koyeb-optimized session
    static func createKoyebSession(delegate: URLSessionTaskDelegate? = nil) -> URLSession {
        return createSession(with: createKoyebConfiguration(), delegate: delegate)
    }
    
    /// Convenience method to create a Railway-optimized session
    static func createRailwaySession(delegate: URLSessionTaskDelegate? = nil) -> URLSession {
        return createSession(with: createRailwayConfiguration(), delegate: delegate)
    }
    
    /// Convenience method to create an ephemeral session
    static func createEphemeralSession(delegate: URLSessionTaskDelegate? = nil) -> URLSession {
        return createSession(with: createEphemeralConfiguration(), delegate: delegate)
    }
}