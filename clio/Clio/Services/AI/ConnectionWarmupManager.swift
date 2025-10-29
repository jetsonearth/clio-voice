import Foundation
import AVFoundation
import os

final class ConnectionWarmupManager {
    struct Config {
        var keepaliveInterval: TimeInterval
        var systemKeepaliveInterval: TimeInterval
        var coldStartThresholdSeconds: TimeInterval
    }

    // Callbacks provided by owner
    var onActiveKeepaliveTick: (() async -> Void)?
    var isStreamingProvider: (() -> Bool)?
    var onColdStartReinitializeURLSession: (() -> Void)?

    private let logger: Logger
    private var config: Config
    private var lastSystemWarmup: Date?
    private var lastStreamingTimestamp: Date?

    private var activeKeepaliveTimer: Timer?
    private var systemKeepaliveTimer: Timer?

    init(config: Config, logger: Logger) {
        self.config = config
        self.logger = logger
    }

    // MARK: - Active keepalive during streaming
    func startActiveKeepalive() {
        stopActiveKeepalive()
        activeKeepaliveTimer = Timer.scheduledTimer(withTimeInterval: config.keepaliveInterval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { [weak self] in
                guard let self = self else { return }
                // Only tick when streaming
                if self.isStreamingProvider?() == true {
                    await self.onActiveKeepaliveTick?()
                }
            }
        }
        logger.debug("🔄 Keepalive timer started (interval: \(self.config.keepaliveInterval)s)")
    }

    func stopActiveKeepalive() {
        activeKeepaliveTimer?.invalidate()
        activeKeepaliveTimer = nil
        logger.debug("⏹️ Keepalive timer stopped")
    }

    // MARK: - System keepalive between sessions
    func startSystemKeepalive() {
        stopSystemKeepalive()
        systemKeepaliveTimer = Timer.scheduledTimer(withTimeInterval: config.systemKeepaliveInterval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { [weak self] in
                await self?.performSystemWarmup()
            }
        }
        logger.notice("🔄 System keepalive started (interval: \(Int(self.config.systemKeepaliveInterval/60)) minutes)")
    }

    func stopSystemKeepalive() {
        systemKeepaliveTimer?.invalidate()
        systemKeepaliveTimer = nil
        logger.debug("⏹️ System keepalive stopped")
    }

    // MARK: - Cold start policy
    func isColdStart() -> Bool {
        if let last = lastStreamingTimestamp {
            return Date().timeIntervalSince(last) > config.coldStartThresholdSeconds
        }
        return true
    }

    func markStreamSuccessful() {
        lastStreamingTimestamp = Date()
        logger.debug("💾 [COLD-START] Updated successful streaming timestamp")
    }

    // MARK: - Warmups
    func prewarmASRTransport() async {
        await prewarmDNSResolution()
        await prewarmConnectionPool()
    }

    func performColdStartWarmup() async {
        // DNS and pool warmup
        await prewarmDNSResolution()
        await prewarmConnectionPool()

        // Audio warmup depending on capture backend
        await warmupAudioSystemIfNeeded()

        // Network/token warmup and temp key cache prefetch
        await warmupNetworkConnections()
        await TempKeyCache.shared.integrateWithSystemWarmup()

        // Ask owner to reinitialize URLSession with cold-start configuration
        onColdStartReinitializeURLSession?()

        logger.notice("✅ [COLD-START] Warm-up complete with network stack optimization")
    }

    func performSystemWarmup() async {
        // Skip if currently streaming
        if isStreamingProvider?() == true {
            logger.debug("🔥 [SYSTEM-WARMUP] Skipping warmup - already streaming")
            return
        }

        // Recency guard: 30 minutes
        if let last = lastSystemWarmup, Date().timeIntervalSince(last) < 30 * 60 {
            logger.debug("🔥 [SYSTEM-WARMUP] Skipping warmup - recent warmup detected")
            return
        }

        logger.notice("🔥 [SYSTEM-WARMUP] Starting background system warm-up")
        lastSystemWarmup = Date()

        do {
            await warmupAudioSystemIfNeeded()
            await warmupAVCaptureIfNeeded()
            await warmupNetworkConnections()
            await TempKeyCache.shared.integrateWithSystemWarmup()
            lastStreamingTimestamp = Date()
            logger.notice("✅ [SYSTEM-WARMUP] Background warm-up completed successfully")
        } catch {
            logger.warning("⚠️ [SYSTEM-WARMUP] Background warm-up failed: \(error.localizedDescription)")
        }
    }

    func cancelAll() {
        stopActiveKeepalive()
        stopSystemKeepalive()
    }

    // MARK: - Internals
    private func warmupAudioSystemIfNeeded() async {
        if RuntimeConfig.captureBackend != .audioEngine {
            logger.debug("⏭️ [SYSTEM-WARMUP] Skipping audio warmup (backend=AVCapture)")
            return
        }
        logger.debug("🔥 [SYSTEM-WARMUP] Warming up audio system (AVAudioEngine backend)")
        do {
            let warmupEngine = AVAudioEngine()
            let warmupInput = warmupEngine.inputNode
            let hardwareFormat = warmupInput.inputFormat(forBus: 0)
            warmupInput.installTap(onBus: 0, bufferSize: 256, format: hardwareFormat) { _, _ in }
            try warmupEngine.start()
            try await Task.sleep(nanoseconds: 50_000_000)
            warmupEngine.stop()
            warmupInput.removeTap(onBus: 0)
            logger.debug("✅ [SYSTEM-WARMUP] Audio system warmed up")
        } catch {
            logger.warning("⚠️ [SYSTEM-WARMUP] Audio warm-up failed: \(error)")
        }
    }

    private func warmupAVCaptureIfNeeded() async {
        guard RuntimeConfig.captureBackend != .audioEngine else { return }
        logger.debug("🎤 [SYSTEM-WARMUP] Warming up AVCapture backend")
        do {
            let id = AudioTapIdentifier(serviceName: "Warmup")
            try await UnifiedAudioManager.shared.registerAudioTap(
                identifier: id,
                format: nil,
                bufferSize: 256,
                tapBlock: { _, _ in }
            )
            try await UnifiedAudioManager.shared.startCapture()
            try? await Task.sleep(nanoseconds: 150_000_000)
            await UnifiedAudioManager.shared.stopCapture()
            await UnifiedAudioManager.shared.unregisterAudioTap(identifier: id)
            logger.debug("✅ [SYSTEM-WARMUP] AVCapture warmed up")
        } catch {
            logger.warning("⚠️ [SYSTEM-WARMUP] AVCapture warm-up failed: \(error.localizedDescription)")
        }
    }

    private func warmupNetworkConnections() async {
        logger.debug("🔥 [SYSTEM-WARMUP] Warming up network connections")
        do {
            _ = try await TokenManager.shared.getValidToken()
            logger.debug("✅ [SYSTEM-WARMUP] JWT token pre-fetched")
        } catch {
            logger.warning("⚠️ [SYSTEM-WARMUP] Network warm-up failed: \(error)")
        }
    }

    private func prewarmDNSResolution() async {
        if RuntimeConfig.enableVerboseLogging && !RuntimeConfig.shouldSilenceAllLogs { logger.debug("🔥 [COLD-START] Pre-warming DNS resolution") }
        let hosts = ["stt-rt.soniox.com", "www.cliovoice.com"]
        await withTaskGroup(of: Void.self) { group in
            for host in hosts {
                group.addTask {
                    guard let url = URL(string: "https://\(host)") else { return }
                    var request = URLRequest(url: url, timeoutInterval: 5.0)
                    request.httpMethod = "HEAD"
                    _ = try? await URLSession.shared.data(for: request)
                }
            }
        }
    }

    private func prewarmConnectionPool() async {
        logger.debug("🔥 [COLD-START] Pre-warming connection pool")
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        config.timeoutIntervalForResource = 30
        config.httpMaximumConnectionsPerHost = 4
        config.requestCachePolicy = .reloadIgnoringCacheData
        config.urlCache = nil
        let warmupSession = URLSession(configuration: config)
        let endpoints = ["https://stt-rt.soniox.com", "https://www.cliovoice.com/api"]
        await withTaskGroup(of: Void.self) { group in
            for endpoint in endpoints {
                group.addTask {
                    guard let url = URL(string: endpoint) else { return }
                    var request = URLRequest(url: url, timeoutInterval: 8.0)
                    request.httpMethod = "HEAD"
                    _ = try? await warmupSession.data(for: request)
                }
            }
        }
        warmupSession.finishTasksAndInvalidate()
    }
}


