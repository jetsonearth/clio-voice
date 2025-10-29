import Foundation
import OSLog

/// Maintains Railway edge connection alive using NSBackgroundActivityScheduler
/// to prevent timer coalescing during audio recording sessions
final class RailwayKeepAlive {
    static let shared = RailwayKeepAlive()
    
    private let logger = Logger(subsystem: "com.cliovoice.clio", category: "RailwayKeepAlive")
    private let pingURL = URL(string: APIConfig.healthCheckURL)!
    private lazy var session: URLSession = {
        // Create Railway-optimized session using factory
        return URLSessionFactory.createRailwaySession()
    }()
    private let scheduler = NSBackgroundActivityScheduler(identifier: "com.cliovoice.clio.keepalive")
    
    private var isActive = false
    
    private init() {
        setupScheduler()
    }
    
    private func setupScheduler() {
        scheduler.interval = 40        // Fire every ~40s (under Railway's 60s limit)
        scheduler.tolerance = 5        // Allow system to coalesce within 5s window
        scheduler.repeats = true       // Continuous keep-alive
        scheduler.qualityOfService = .utility  // Background priority
    }
    
    /// Start sending keep-alive pings to maintain Railway connection
    func start() {
        guard !isActive else {
            logger.notice("🔄 Keep-alive already active - skipping start")
            return
        }
        
        logger.notice("🚀 Starting Railway keep-alive (40s intervals)")
        isActive = true
        
        scheduler.schedule { [weak self] completion in
            Task {
                await self?.sendKeepAlive()
                completion(.finished)
            }
        }
    }
    
    /// Stop sending keep-alive pings
    func stop() {
        guard isActive else {
            logger.notice("⏹️ Keep-alive already stopped - skipping stop")
            return
        }
        
        logger.notice("⏹️ Stopping Railway keep-alive")
        scheduler.invalidate()
        isActive = false
    }
    
    /// Send lightweight HEAD request to /health endpoint
    private func sendKeepAlive() async {
        guard isActive else { return }
        
        do {
            var request = URLRequest(url: pingURL)
            request.httpMethod = "HEAD"
            request.timeoutInterval = 10
            request.setValue("Railway-KeepAlive/1.0", forHTTPHeaderField: "User-Agent")
            
            let startTime = CFAbsoluteTimeGetCurrent()
            let (_, response) = try await session.data(for: request)
            let responseTime = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    logger.notice("💓 Keep-alive successful (⚡ \(String(format: "%.1f", responseTime))ms)")
                } else {
                    logger.warning("⚠️ Keep-alive returned status \(httpResponse.statusCode)")
                }
            }
        } catch {
            logger.error("❌ Keep-alive failed: \(error.localizedDescription)")
            // Don't stop on single failure - network might be temporarily unavailable
        }
    }
    
    /// Get current keep-alive status
    var status: KeepAliveStatus {
        return isActive ? .active : .inactive
    }
}

extension RailwayKeepAlive {
    enum KeepAliveStatus {
        case active
        case inactive
        
        var description: String {
            switch self {
            case .active:
                return "🟢 Active (40s intervals)"
            case .inactive:
                return "🔴 Inactive"
            }
        }
    }
}