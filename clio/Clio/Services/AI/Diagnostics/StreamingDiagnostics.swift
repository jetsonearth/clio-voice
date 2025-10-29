import Foundation
import os

// Centralized, lightweight diagnostics for ASR streaming.
// Keeps SonioxStreamingService lean by providing small logging helpers.
struct StreamingDiagnostics {
    private static let logger = Logger(subsystem: "com.cliovoice.clio", category: "StreamingDiagnostics")

    // MARK: - TTFT and Receive Path
    static func logFirstAudioBufferCaptured(t0: Date) {
        let ms = Int(Date().timeIntervalSince(t0) * 1000)
        StructuredLog.shared.log(cat: .stream, evt: "first_audio_buffer_captured", lvl: .info, ["ms": ms])
    }

    static func logFirstAudioSent(t0: Date, seq: Int) {
        let ms = Int(Date().timeIntervalSince(t0) * 1000)
        StructuredLog.shared.log(cat: .stream, evt: "first_audio_sent", lvl: .info, ["ms": ms, "seq": seq])
    }

    static func logFirstPartial(t0: Date) {
        let ms = Int(Date().timeIntervalSince(t0) * 1000)
        // Also emit true TTFT from hotkey perspective
        StructuredLog.shared.log(cat: .stream, evt: "first_partial", lvl: .info, ["ms": ms])
        StructuredLog.shared.log(cat: .stream, evt: "ttft_hotkey", lvl: .info, ["ms": ms])
    }

    static func logFirstFinal(t0: Date) {
        let ms = Int(Date().timeIntervalSince(t0) * 1000)
        StructuredLog.shared.log(cat: .stream, evt: "first_final", lvl: .info, ["ms": ms])
    }

    // MARK: - WS Bind + Target Info
    static func logWsBind(socketId: String, attempt: Int, url: URL) {
        let targetHost = url.host ?? "?"
        let viaProxy = !(targetHost.lowercased().contains("soniox.com"))
        
        // Log immediately without IP to avoid blocking the calling thread
        StructuredLog.shared.log(cat: .stream, evt: "ws_bind", lvl: .info, [
            "socket": socketId,
            "attempt": attempt,
            "target_host": targetHost,
            "target_ip": "resolving...",
            "via_proxy": viaProxy,
            "path": url.path
        ])
        
        // Resolve IP asynchronously on background queue
        resolveIPAddressAsync(for: targetHost) { resolvedIP in
            StructuredLog.shared.log(cat: .stream, evt: "ws_bind_resolved", lvl: .info, [
                "socket": socketId,
                "attempt": attempt,
                "target_host": targetHost,
                "target_ip": resolvedIP ?? "n/a",
                "via_proxy": viaProxy,
                "path": url.path
            ])
        }
    }

    // MARK: - URLSessionTaskMetrics (DNS/Connect/TLS)
    static func logHandshakeMetrics(socketId: String, attempt: Int, metrics: URLSessionTaskMetrics) {
        guard let t = metrics.transactionMetrics.last else { return }
        func ms(_ a: Date?, _ b: Date?) -> Int? {
            guard let a, let b else { return nil }
            return Int(b.timeIntervalSince(a) * 1000)
        }
        let dnsMs = ms(t.domainLookupStartDate, t.domainLookupEndDate) ?? -1
        let connectMs = ms(t.connectStartDate, t.connectEndDate) ?? -1
        let tlsMs = ms(t.secureConnectionStartDate, t.secureConnectionEndDate) ?? -1
        let totalMs = ms(t.fetchStartDate, t.responseStartDate) ?? -1
        StructuredLog.shared.log(cat: .stream, evt: "ws_handshake_metrics", lvl: .info, [
            "socket": socketId,
            "attempt": attempt,
            "dns_ms": dnsMs,
            "connect_ms": connectMs,
            "tls_ms": tlsMs,
            "total_ms": totalMs,
            "proxy": t.isProxyConnection,
            "reused": t.isReusedConnection,
            "protocol": t.networkProtocolName ?? ""
        ])
    }

    // MARK: - Temp Key Fetch
    static func logTempKeyFetchStart() {
        StructuredLog.shared.log(cat: .stream, evt: "temp_key_fetch_start", lvl: .info, [:])
    }

    static func logTempKeyFetchDone(source: String, latencyMs: Int, expiresAtISO: String) {
        let expiresSeconds = computeSecondsUntil(expiresAtISO) ?? -1
        StructuredLog.shared.log(cat: .stream, evt: "temp_key_fetch", lvl: .info, [
            "source": source,
            "latency_ms": latencyMs,
            "expires_in_s": expiresSeconds
        ])
    }

    // MARK: - Utilities
    
    /// Asynchronous DNS resolution to avoid blocking high-priority threads
    private static func resolveIPAddressAsync(for host: String, completion: @escaping (String?) -> Void) {
        guard !host.isEmpty else {
            completion(nil)
            return
        }
        
        // Perform DNS resolution on a background queue to avoid priority inversion
        DispatchQueue.global(qos: .utility).async {
            let ip = resolveIPAddressSync(for: host)
            completion(ip)
        }
    }
    
    /// Synchronous DNS resolution - should only be called from background queues
    private static func resolveIPAddressSync(for host: String) -> String? {
        if host.isEmpty { return nil }
        let cf = CFHostCreateWithName(nil, host as CFString).takeRetainedValue()
        var resolved: DarwinBoolean = false
        if CFHostStartInfoResolution(cf, .addresses, nil),
           let arr = CFHostGetAddressing(cf, &resolved)?.takeUnretainedValue() as NSArray?,
           let data = arr.firstObject as? Data {
            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            data.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
                let sa = ptr.baseAddress!.assumingMemoryBound(to: sockaddr.self)
                let saLen = socklen_t(sa.pointee.sa_len)
                _ = getnameinfo(sa, saLen, &hostname, socklen_t(NI_MAXHOST), nil, 0, NI_NUMERICHOST)
            }
            let ip = String(cString: hostname)
            return ip.isEmpty ? nil : ip
        }
        return nil
    }

    private static func computeSecondsUntil(_ iso: String) -> Int? {
        let fmt = ISO8601DateFormatter()
        guard let d = fmt.date(from: iso) else { return nil }
        let s = Int(d.timeIntervalSince(Date()))
        return s
    }
}
