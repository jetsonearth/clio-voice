import Foundation

/// Centralized API configuration for easy switching between environments
struct APIConfig {
    // MARK: - Environment Configuration
    
    /// Current API environment
    static let environment: APIEnvironment = .direct // Community build: talk directly to providers
   
    enum APIEnvironment {
        case direct
        case vercel
        case railway
        case koyeb
        case cloudflare
        case flyio
        
        var baseURL: String {
            switch self {
            case .direct:
                return ""
            case .vercel:
                return "https://www.cliovoice.com/api"
            case .railway:
                return "https://api.cliovoice.com/api" // Custom domain with persistent connections
            case .koyeb:
                return "https://koyeb.cliovoice.com/api" // Koyeb deployment with HTTP/2 and keep-alive
            case .cloudflare:
                return "https://clio-voice-backend.jetson-earth.workers.dev/api" // Cloudflare Workers edge deployment
            case .flyio:
                return "https://fly.cliovoice.com/api" // Fly.io deployment
            }
        }
        
        var displayName: String {
            switch self {
            case .direct:
                return "Direct (User Keys)"
            case .vercel:
                return "Vercel (Legacy)"
            case .railway:
                return "Railway (Optimized)"
            case .koyeb:
                return "Koyeb (HTTP/2 + Keep-Alive)"
            case .cloudflare:
                return "Cloudflare Workers (Global Edge)"
            case .flyio:
                return "Fly.io"
            }
        }
    }
    
    // MARK: - API Endpoints
    
    /// Base API URL for current environment
    static var apiBaseURL: String {
        return environment.baseURL
    }
    
    /// LLM proxy endpoint (Groq-focused)
    static var llmProxyURL: String {
        guard environment != .direct else { return "" }
        return "\(apiBaseURL)/llm/proxy"
    }
    
    /// Gemini proxy endpoint (Gemini-focused) 
    static var geminiProxyURL: String {
        guard environment != .direct else { return "" }
        return "\(apiBaseURL)/llm/gemini"
    }
    
    /// Secure ASR temporary key endpoint (already implemented correctly)
    static var asrTempKeyURL: String {
        guard environment != .direct else { return "" }
        return "\(apiBaseURL)/asr/temp-key"
    }
    
    /// Authentication endpoint
    static var authSessionURL: String {
        guard environment != .direct else { return "" }
        switch environment {
        case .vercel, .railway:
            return "\(apiBaseURL)/auth/session-inline"
        case .koyeb, .cloudflare, .flyio:
            return "\(apiBaseURL)/auth/session"
        case .direct:
            return ""
        }
    }
    
    /// Usage tracking endpoint
    static var usageTrackURL: String {
        guard environment != .direct else { return "" }
        return "\(apiBaseURL)/usage/track"
    }
    
    /// Health check endpoint  
    static var healthCheckURL: String {
        switch environment {
        case .direct:
            return ""
        case .vercel:
            return "https://www.cliovoice.com/health"
        case .railway:
            return "https://api.cliovoice.com/health"
        case .koyeb:
            return "https://koyeb.cliovoice.com/health/ping"
        case .cloudflare:
            return "https://clio-voice-backend.jetson-earth.workers.dev/health"
        case .flyio:
            return "https://fly.cliovoice.com/health"
        }
    }
    
    /// LLM Keep-alive endpoint for maintaining proxy connection warmth
    static var llmKeepAliveURL: String {
        guard environment != .direct else { return "" }
        return "\(apiBaseURL)/llm/keepalive"
    }
    
    // MARK: - Performance Expectations
    
    /// Expected latency improvement with optimized backends
    static var expectedImprovements: [String: String] {
        switch environment {
        case .direct:
            return [
                "Network": "Requests hit Groq, Gemini, and Soniox directly with your API keys.",
                "Privacy": "Keys stay local—no proxy or hosted auth services.",
                "Flexibility": "Swap providers or regions by updating your own credentials."
            ]
        case .vercel:
            return [:]
        case .railway:
            return [
                "LLM Latency": "2400ms → 600ms (4x faster)",
                "Connection Reuse": "Cold start every request → HTTP/2 pooling",
                "Geographic Routing": "Edge routing overhead → Direct server connection",
                "Architecture": "Serverless functions → Always-on containers"
            ]
        case .koyeb:
            return [
                "Connection Reuse": "Cold start → Persistent connections with keep-alive",
                "TLS Handshake": "1600ms overhead eliminated after first request",
                "Protocol": "HTTP/1.1 workarounds → Native HTTP/2 support",
                "Keep-Alive": "60s Railway timeout → 95s + indefinite with pings"
            ]
        case .cloudflare:
            return [
                "Edge Computing": "Server round-trip → Edge processing in 200+ locations",
                "Cold Start": "Zero cold start with always-on Workers",
                "Geographic": "Automatic routing to nearest Cloudflare data center",
                "Protocol": "Native HTTP/3 and TLS 1.3 support"
            ]
        case .flyio:
            return [
                "Container Persistence": "No cold starts with always-on containers",
                "Network": "Optimized for Singapore/China connectivity",
                "Architecture": "Dedicated resources vs shared serverless"
            ]
        }
    }
    
    // MARK: - Debug Information
    
    /// Log current configuration for debugging
    static func logConfiguration() {
        print("🔧 [API-CONFIG] Environment: \(environment.displayName)")
        if environment == .direct {
            print("🔧 [API-CONFIG] Direct mode enabled – no proxy endpoints configured.")
        } else {
            print("🔧 [API-CONFIG] Base URL: \(apiBaseURL)")
            print("🔧 [API-CONFIG] Groq Proxy: \(llmProxyURL)")
            print("🔧 [API-CONFIG] Gemini Proxy: \(geminiProxyURL)")
            print("🔧 [API-CONFIG] ASR Temp Key: \(asrTempKeyURL)")
        }
        
        if environment != .vercel && environment != .direct {
            print("🚀 [API-CONFIG] Expected improvements:")
            for (key, value) in expectedImprovements {
                print("   • \(key): \(value)")
            }
        } else if environment == .direct {
            print("🚀 [API-CONFIG] Direct connections: configure API keys in Settings → AI Models.")
        }
    }
}

// MARK: - Migration Helper

extension APIConfig {
    /// Check if we're using an optimized backend
    static var isUsingOptimizedBackend: Bool {
        return environment != .vercel
    }
    
    /// Get migration status message
    static var migrationStatus: String {
        switch environment {
        case .vercel:
            return "⚠️ Using legacy Vercel backend (slow). Switch to Cloudflare Workers for 12x performance improvement."
        case .railway:
            return "✅ Using Railway backend. Consider Cloudflare Workers for global edge computing."
        case .koyeb:
            return "🚀 Using Koyeb with HTTP/2 + keep-alive. Optimal performance: ~400ms LLM latency."
        case .cloudflare:
            return "🌟 Using Cloudflare Workers - Global edge computing with <200ms latency worldwide."
        case .flyio:
            return "🎯 Using Fly.io - Optimized for Asia-Pacific users with ~300ms latency."
        case .direct:
            return "🟢 Using direct provider mode with user-supplied API keys. No hosted proxy involved."
        }
    }
}
