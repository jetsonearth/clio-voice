import Foundation

extension SonioxStreamingService {
    /// Restart only the audio capture path (engine/tap) without dropping the active WebSocket
    func restartAudioCaptureWithoutClosingWebSocket() async {
        // Grace window after promotion: avoid stop/start that causes mic-indicator flicker
        if let promoAt = promotionAt {
            let elapsed = Date().timeIntervalSince(promoAt)
            let grace = Double(RuntimeConfig.captureRestartGraceMs) / 1000.0
            if elapsed < grace {
                logger.debug("⏳ [CAPTURE RECOVERY] Skipping restart within grace (elapsed=\(String(format: "%.3f", elapsed))s)")
                return
            }
        }
        // Gate recovery while a connection is being established to avoid buffer/state corruption.
        if isConnecting {
            logger.warning("⏸️ [CAPTURE RECOVERY] Skipping capture restart while connecting — deferring")
            pendingCaptureRestart = true
            // Retry shortly; if still connecting, it will set the flag again.
            timers.scheduleOnce(.firstBufferEngineRestart, after: 0.3) { [weak self] in
                guard let self = self else { return }
                Task { [weak self] in
                    guard let self = self else { return }
                    if !self.isConnecting && self.firstBufferReceivedAt == nil {
                        await self.restartAudioCaptureWithoutClosingWebSocket()
                    }
                }
            }
            return
        }
        logger.warning("🔄 [CAPTURE RECOVERY] Restarting audio capture without closing WebSocket")

        // Restart unified capture path (keep WebSocket open)
        do {
            if RuntimeConfig.captureBackend == .avCaptureSession {
                // Soft refresh for AVCapture: rebind delegate without stopping session to avoid mic indicator blink
                await UnifiedAudioManager.shared.refreshAVCaptureTap()
                logger.notice("✅ [CAPTURE RECOVERY] Soft refreshed AVCapture delegate (no session stop)")
            } else {
                // AVAudioEngine path (not default): stop and restart engine
                await UnifiedAudioManager.shared.stopCapture()
                if let id = unifiedTapId {
                    await UnifiedAudioManager.shared.unregisterAudioTap(identifier: id)
                }
                try? await Task.sleep(nanoseconds: 150_000_000)
                let id = AudioTapIdentifier(serviceName: "Soniox")
                unifiedTapId = id
                try await UnifiedAudioManager.shared.registerAudioTap(
                    identifier: id,
                    format: nil,
                    bufferSize: 1024,
                    tapBlock: { [weak self] buffer, _ in
                        guard let self = self else { return }
                        Task { await self.processAudioBuffer(buffer) }
                    }
                )
                try await UnifiedAudioManager.shared.startCapture()
            }

            // Reset metrics for the fresh capture
            maxAudioLevelSinceStart = 0.0
            lastAudioDataReceivedTime = nil
            hasReceivedAudioData = false
            await scheduleFirstBufferWatchdogs()
        } catch {
            logger.error("❌ [CAPTURE RECOVERY] Failed to refresh/restart capture: \(error.localizedDescription)")
            await stopStreaming()
            await MainActor.run { self.connectionStatus = .error("Audio capture recovery failed – please try again (\(error.localizedDescription))") }
        }
    }
}

