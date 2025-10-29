import Foundation
import OSLog
import AppKit

/// Maintains persistent connection alive using Timer
/// Reliable timing without macOS power management interference
/// Uses LLM keep-alive endpoint for proper connection reuse to the LLM proxy
/// Optimized for Koyeb (100s timeout) with HTTP/3 support via edge termination
final class KoyebKeepAlive {
    static let shared = KoyebKeepAlive()
    
    private let logger = Logger(subsystem: "com.cliovoice.clio", category: "KoyebKeepAlive")
    private let llmKeepAliveURL = URL(string: APIConfig.llmKeepAliveURL)!
    private let tokenManager = TokenManager.shared
    
    // Always use the centralized Koyeb session for proper connection reuse
    private var session: URLSession {
        let sharedSession = KoyebSessionManager.shared.session
        logger.notice("🔗 Using centralized Koyeb session for LLM keep-alive")
        KoyebSessionManager.shared.logSessionIdentity(context: "KoyebKeepAlive.session")
        return sharedSession
    }
    
    private var keepAliveTimer: DispatchSourceTimer?
    private var activity: NSObjectProtocol?
    private var isActive = false
    
    private init() {
        // Timer-based keep-alive - no setup needed, created on demand
    }
    
    /// Start sending LLM keep-alive pings to maintain persistent connection
    func start() {
        guard !isActive else {
            logger.notice("🔄 Keep-alive already active - skipping start")
            return
        }
        
        logger.notice("🚀 Starting Koyeb DispatchSourceTimer keep-alive (45s intervals - HTTP/3 optimized)")
        isActive = true
        
        // Prevent App Nap while keep-alive is running
        activity = ProcessInfo.processInfo.beginActivity(options: [.idleSystemSleepDisabled, .latencyCritical], reason: "Koyeb LLM keep-alive")
        
        // Create DispatchSourceTimer – less susceptible to coalescing  
        // HTTP/3 optimized: 45s intervals prevent QUIC connection timeout issues
        let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global(qos: .utility))
        timer.schedule(deadline: .now() + 45, repeating: 45, leeway: .seconds(3))
        timer.setEventHandler { [weak self] in
            Task { @MainActor in
                await self?.sendLLMKeepAlive()
            }
        }
        timer.resume()
        keepAliveTimer = timer
        
        // Fire once right away to prime the connection
        Task {
            await sendLLMKeepAlive()
        }
    }
    
    /// Stop sending keep-alive pings
    func stop() {
        guard isActive else {
            logger.notice("⏹️ Keep-alive already stopped - skipping stop")
            return
        }
        
        logger.notice("⏹️ Stopping Koyeb DispatchSourceTimer keep-alive")
        keepAliveTimer?.cancel()
        keepAliveTimer = nil
        
        if let act = activity {
            ProcessInfo.processInfo.endActivity(act)
            activity = nil
        }
        
        isActive = false
    }
    
    /// Send authenticated POST request to /api/llm/keepalive endpoint
    private func sendLLMKeepAlive() async {
        guard isActive else { return }
        
        do {
            // Get valid JWT token
            let token = try await tokenManager.getValidToken()
            
            var request = URLRequest(url: llmKeepAliveURL)
            request.httpMethod = "POST"
            request.timeoutInterval = 30  // Increased for HTTP/3 connection recovery and QUIC handshakes
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Clio-Koyeb-HTTP3-KeepAlive/1.0", forHTTPHeaderField: "User-Agent")
            request.setValue("keepalive_\(Date().timeIntervalSince1970)", forHTTPHeaderField: "X-Request-Id")
            
            // Empty JSON body for POST request
            request.httpBody = "{}".data(using: .utf8)
            
            let startTime = CFAbsoluteTimeGetCurrent()
            // Use the centralized session for true connection reuse
            let (data, response) = try await session.data(for: request)
            let responseTime = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    // Parse response to check connection reuse
                    if let responseData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let connectionReused = responseData["connectionReused"] as? Bool,
                       let reuseRate = responseData["stats"] as? [String: Any],
                       let rate = reuseRate["reuseRate"] as? String {
                        
                        let status = connectionReused ? "🔄 REUSED" : "🆕 NEW"
                        logger.notice("💓 LLM keep-alive successful (\(status)) - \(rate) reuse rate (⚡ \(String(format: "%.1f", responseTime))ms)")
                    } else {
                        logger.notice("💓 LLM keep-alive successful (⚡ \(String(format: "%.1f", responseTime))ms)")
                    }
                } else {
                    logger.warning("⚠️ LLM keep-alive returned status \(httpResponse.statusCode)")
                }
            }
        } catch {
            logger.error("❌ LLM keep-alive failed: \(error.localizedDescription)")
            // Don't stop on single failure - network might be temporarily unavailable
        }
    }
    
    /// Get current keep-alive status
    var status: KeepAliveStatus {
        return isActive ? .active : .inactive
    }
}

extension KoyebKeepAlive {
    enum KeepAliveStatus {
        case active
        case inactive
        
        var description: String {
            switch self {
            case .active:
                return "🟢 Active (45s HTTP/3-optimized intervals)"
            case .inactive:
                return "🔴 Inactive"
            }
        }
    }
}