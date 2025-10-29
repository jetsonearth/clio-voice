import Foundation
import os

/// Metrics collection for HTTP protocol performance analysis
struct HTTPConnectionMetrics {
    let requestId: String
    let protocolName: String           // "h2", "h3", "http/1.1", etc.
    let connectionReused: Bool
    let handshakeTime: TimeInterval    // Time for TCP + TLS handshake
    let dnsLookupTime: TimeInterval    
    let connectTime: TimeInterval      // TCP connection time
    let tlsTime: TimeInterval          // TLS handshake time
    let timeToFirstByte: TimeInterval  // TTFB - time to first response byte
    let downloadTime: TimeInterval     // Time to download response
    let totalTime: TimeInterval        // End-to-end request time
    let timestamp: Date
    let endpoint: String               // Which API endpoint was called
    
    /// Calculate the time saved by connection reuse
    var handshakeOverheadSaved: TimeInterval {
        return connectionReused ? 0 : (dnsLookupTime + connectTime + tlsTime)
    }
    
    /// Get a concise summary for logging
    var summary: String {
        let reusedStatus = connectionReused ? "✅ REUSED" : "❌ NEW"
        return "\(protocolName.uppercased()) \(reusedStatus) - Total: \(Int(totalTime * 1000))ms, TTFB: \(Int(timeToFirstByte * 1000))ms"
    }
}

/// Performance analytics for HTTP/3 vs HTTP/2 comparison
@MainActor
class HTTPProtocolMetrics: ObservableObject {
    static let shared = HTTPProtocolMetrics()
    
    private let logger = Logger(subsystem: "com.cliovoice.clio", category: "HTTPMetrics")
    private var metrics: [HTTPConnectionMetrics] = []
    
    // Statistics
    @Published private(set) var http2Stats = ProtocolStats()
    @Published private(set) var http3Stats = ProtocolStats()
    @Published private(set) var totalRequests = 0
    
    private init() {}
    
    /// Record a new connection metric
    func recordMetric(_ metric: HTTPConnectionMetrics) {
        metrics.append(metric)
        totalRequests += 1
        
        // Update protocol-specific stats
        if metric.protocolName.contains("h3") || metric.protocolName.contains("quic") {
            http3Stats.update(with: metric)
        } else if metric.protocolName.contains("h2") {
            http2Stats.update(with: metric)
        }
        
        // Log the metric
        logger.notice("📊 [HTTP METRICS] \(metric.summary)")
        
        // Clean up old metrics (keep last 1000)
        if metrics.count > 1000 {
            metrics.removeFirst(metrics.count - 1000)
        }
        
        // Log comparison every 10 requests
        if totalRequests % 10 == 0 {
            logPerformanceComparison()
        }
    }
    
    /// Get metrics for a specific time period
    func getMetrics(since: Date) -> [HTTPConnectionMetrics] {
        return metrics.filter { $0.timestamp >= since }
    }
    
    /// Get average performance for each protocol
    func getAveragePerformance() -> (http2: ProtocolStats, http3: ProtocolStats) {
        return (http2Stats, http3Stats)
    }
    
    /// Log a performance comparison between protocols
    private func logPerformanceComparison() {
        guard http2Stats.requestCount > 0 || http3Stats.requestCount > 0 else { return }
        
        logger.notice("🏁 [PERFORMANCE COMPARISON] After \(self.totalRequests) requests:")
        
        if http2Stats.requestCount > 0 {
            logger.notice("🔵 HTTP/2: \(self.http2Stats.requestCount) requests, avg \(Int(self.http2Stats.averageLatency * 1000))ms, \(Int(self.http2Stats.connectionReuseRate * 100))% reuse")
        }
        
        if http3Stats.requestCount > 0 {
            logger.notice("🟢 HTTP/3: \(self.http3Stats.requestCount) requests, avg \(Int(self.http3Stats.averageLatency * 1000))ms, \(Int(self.http3Stats.connectionReuseRate * 100))% reuse")
        }
        
        // Calculate improvement if we have both protocols
        if http2Stats.requestCount > 0 && http3Stats.requestCount > 0 {
            let latencyImprovement = ((http2Stats.averageLatency - http3Stats.averageLatency) / http2Stats.averageLatency) * 100
            let reuseImprovement = (http3Stats.connectionReuseRate - http2Stats.connectionReuseRate) * 100
            
            logger.notice("📈 HTTP/3 vs HTTP/2: \(String(format: "%.1f", latencyImprovement))% latency improvement, \(String(format: "%.1f", reuseImprovement))% better connection reuse")
        }
    }
    
    /// Create metric from URLSessionTaskMetrics
    func createMetric(from urlMetrics: URLSessionTaskMetrics, requestId: String, endpoint: String) -> HTTPConnectionMetrics? {
        guard let transaction = urlMetrics.transactionMetrics.first else { return nil }
        
        let protocolName = transaction.networkProtocolName ?? "unknown"
        let connectionReused = transaction.isReusedConnection
        
        // Calculate timing components
        let dnsTime = Self.timeDifference(from: transaction.domainLookupStartDate, to: transaction.domainLookupEndDate)
        let connectTime = Self.timeDifference(from: transaction.connectStartDate, to: transaction.connectEndDate)
        let tlsTime = Self.timeDifference(from: transaction.secureConnectionStartDate, to: transaction.secureConnectionEndDate)
        let ttfb = Self.timeDifference(from: transaction.requestStartDate, to: transaction.responseStartDate)
        let downloadTime = Self.timeDifference(from: transaction.responseStartDate, to: transaction.responseEndDate)
        
        let handshakeTime = dnsTime + connectTime + tlsTime
        let totalTime = handshakeTime + ttfb + downloadTime
        
        return HTTPConnectionMetrics(
            requestId: requestId,
            protocolName: protocolName,
            connectionReused: connectionReused,
            handshakeTime: handshakeTime,
            dnsLookupTime: dnsTime,
            connectTime: connectTime,
            tlsTime: tlsTime,
            timeToFirstByte: ttfb,
            downloadTime: downloadTime,
            totalTime: totalTime,
            timestamp: Date(),
            endpoint: endpoint
        )
    }
    
    /// Helper to calculate time difference safely
    private static func timeDifference(from start: Date?, to end: Date?) -> TimeInterval {
        guard let start = start, let end = end else { return 0 }
        return max(0, end.timeIntervalSince(start))
    }
    
    /// Export metrics for analysis
    func exportMetrics() -> String {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.dateEncodingStrategy = .iso8601
        
        do {
            let data = try jsonEncoder.encode(metrics)
            return String(data: data, encoding: .utf8) ?? "Failed to encode"
        } catch {
            return "Export failed: \(error.localizedDescription)"
        }
    }
    
    /// Clear all metrics
    func clearMetrics() {
        metrics.removeAll()
        http2Stats = ProtocolStats()
        http3Stats = ProtocolStats()
        totalRequests = 0
        logger.notice("🧹 [HTTP METRICS] Cleared all metrics")
    }
}

/// Statistics for a specific HTTP protocol
struct ProtocolStats {
    private(set) var requestCount = 0
    private(set) var totalLatency: TimeInterval = 0
    private(set) var connectionReuses = 0
    private(set) var handshakeTimesSaved: TimeInterval = 0
    
    var averageLatency: TimeInterval {
        requestCount > 0 ? totalLatency / Double(requestCount) : 0
    }
    
    var connectionReuseRate: Double {
        requestCount > 0 ? Double(connectionReuses) / Double(requestCount) : 0
    }
    
    var averageHandshakeTimeSaved: TimeInterval {
        requestCount > 0 ? handshakeTimesSaved / Double(requestCount) : 0
    }
    
    mutating func update(with metric: HTTPConnectionMetrics) {
        requestCount += 1
        totalLatency += metric.totalTime
        
        if metric.connectionReused {
            connectionReuses += 1
        }
        
        handshakeTimesSaved += metric.handshakeOverheadSaved
    }
}

// MARK: - Codable conformance for exporting

extension HTTPConnectionMetrics: Codable {}
extension ProtocolStats: Codable {}
