import Foundation
import AVFoundation

extension SonioxStreamingService {
    // MARK: - Sleep/Wake handling
    @MainActor
    func prepareForSleep() async {
        logger.notice("🌙 [SLEEP] System will sleep — tearing down warm/standby socket")
        // Stop any warm-hold and close sockets to avoid post-sleep stalls
        stopWarmHold()
        await disconnectWebSocket()
        // Mute keepalives briefly after wake (defense-in-depth)
        keepaliveMutedUntil = Date().addingTimeInterval(5)
    }

    @MainActor
    func handleSystemWake() async {
        logger.notice("🌞 [WAKE] System did wake — scheduling transport rebuild")
        continuationGate.cancelIfPending(SonioxError.sessionNotConfigured)
        readinessTimeoutTask?.cancel()
        await rebuildTransport(reason: "system_wake", showBanner: isStreaming)
    }

    private func performSystemWarmup() async {
        await warmupManager.performSystemWarmup()
    }

    /// Warm up AVCapture to reduce first-run buffer delay (runs only when backend is AVCapture)
    private func warmupAVCaptureIfNeeded() async {
        guard !isStreaming else { return }
        // Only relevant when UnifiedAudioManager is using AVCapture backend
        if RuntimeConfig.captureBackend != .audioEngine {
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
                // brief run to initialize the capture pipeline
                try? await Task.sleep(nanoseconds: 150_000_000)
                await UnifiedAudioManager.shared.stopCapture()
                await UnifiedAudioManager.shared.unregisterAudioTap(identifier: id)
                logger.debug("✅ [SYSTEM-WARMUP] AVCapture warmed up")
            } catch {
                logger.warning("⚠️ [SYSTEM-WARMUP] AVCapture warm-up failed: \(error.localizedDescription)")
            }
        }
    }

    private func warmupAudioSystem() async {
        // Only warm up audio engine when using AVAudioEngine backend
        guard RuntimeConfig.captureBackend == .audioEngine else {
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
            try await Task.sleep(nanoseconds: 50_000_000) // 50ms
            warmupEngine.stop()
            warmupInput.removeTap(onBus: 0)
            logger.debug("✅ [SYSTEM-WARMUP] Audio system warmed up")
        } catch {
            logger.warning("⚠️ [SYSTEM-WARMUP] Audio warm-up failed: \(error)")
        }
    }

    /// Quick audio warmup to avoid -10877 after long idle. Runs a short engine start/stop.
    func quickFocusWarmup(durationMs: UInt64 = 150_000_000) async {
        // Avoid interfering with an active stream
        guard !isStreaming else { return }
        guard RuntimeConfig.captureBackend == .audioEngine else {
            logger.debug("⏭️ [FOCUS-WARMUP] Skipping audio warmup (backend=AVCapture)")
            return
        }
        logger.debug("🔥 [FOCUS-WARMUP] Performing quick audio warmup (")
        do {
            let warmupEngine = AVAudioEngine()
            let warmupInput = warmupEngine.inputNode
            let hardwareFormat = warmupInput.inputFormat(forBus: 0)
            warmupInput.installTap(onBus: 0, bufferSize: 256, format: hardwareFormat) { _, _ in }
            try warmupEngine.start()
            try await Task.sleep(nanoseconds: durationMs)
            warmupEngine.stop()
            warmupInput.removeTap(onBus: 0)
            logger.debug("✅ [FOCUS-WARMUP] Audio warmup completed")
        } catch {
            logger.warning("⚠️ [FOCUS-WARMUP] Audio warmup failed: \(error.localizedDescription)")
        }
    }
}
