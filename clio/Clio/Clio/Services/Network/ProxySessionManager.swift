import Foundation
import os

/// Shared URLSession for all requests to the Clio proxy (fly.cliovoice.com)
/// Tuned to maximize connection reuse and minimize TLS handshakes.
final class ProxySessionManager {
    static let shared = ProxySessionManager()

    private(set) var session: URLSession
    private let config: URLSessionConfiguration
    private weak var delegate: URLSessionTaskDelegate?

    private init() {
        let config = URLSessionConfiguration.default

        // Prefer modern TLS; HTTP/2 or HTTP/3 negotiated by the system
        if #available(macOS 12.0, iOS 15.0, *) {
            config.tlsMaximumSupportedProtocolVersion = .TLSv13
        }

        // Encourage reuse: one connection per host (HTTP/2/3 multiplexes streams)
        config.httpMaximumConnectionsPerHost = 1
        config.httpShouldUsePipelining = false

        // Timeouts suitable for LLM requests
        config.timeoutIntervalForRequest = 60
        config.timeoutIntervalForResource = 120

        // Connection behavior
        config.waitsForConnectivity = true
        config.requestCachePolicy = .reloadIgnoringLocalCacheData

        self.config = config
        self.session = URLSession(configuration: config, delegate: nil, delegateQueue: nil)

        Logger(subsystem: "com.cliovoice.clio", category: "URLSession")
            .notice("🛜 [PROXY-SESSION] Initialized shared session (keep-alive, max 1 conn/host)")
    }

    /// Recreate the shared session with a delegate to enable URLSessionTaskMetrics collection.
    /// Call once early (e.g., after AIEnhancementService is constructed).
    func setDelegate(_ delegate: URLSessionTaskDelegate) {
        self.delegate = delegate
        rebuildSession()
    }

    /// Force a fresh URLSession instance, typically after network reachability changes
    /// or sleep/wake events that leave the underlying transport in a bad state.
    func rebuildSession() {
        session.invalidateAndCancel()
        session = URLSession(configuration: config, delegate: delegate, delegateQueue: nil)
        Logger(subsystem: "com.cliovoice.clio", category: "URLSession")
            .notice("🛜 [PROXY-SESSION] Rebuilt shared session (delegate=\(self.delegate != nil ? "yes" : "no"))")
    }
}
