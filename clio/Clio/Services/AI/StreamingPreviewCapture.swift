import Foundation
import AVFoundation

extension SonioxStreamingService {
    // MARK: - Instant mic preview (pre‑promotion)
    /// Start capture during the promotion window. This lights the mic immediately AND buffers
    /// the converted PCM so that if the user continues to hold, we will stream all pre‑roll audio.
    /// If the user releases within the promotion window, this buffer will be discarded.
    func startPreviewCapture() async {
        // Respect runtime toggle
        if !RuntimeConfig.enablePreviewCapture { return }
        // Do not start preview if we are already streaming or already previewing
        if isStreaming || isPreviewActive { return }
        // Fresh preview session — clear any stale prebuffer and mark state
        await prebuffer.clear()
        bufferingState = .prebuffering
        do {
            let id = AudioTapIdentifier(serviceName: "SonioxPreview")
            previewTapId = id
            try await UnifiedAudioManager.shared.registerAudioTap(
                identifier: id,
                format: nil,
                bufferSize: 256,
                tapBlock: { [weak self] buffer, _ in
                    guard let self = self else { return }
                    // Convert incoming buffer to 16 kHz mono s16le and compute level
                    if let processed = self.audioProcessor.process(buffer: buffer) {
                        let audioData = processed.data
                        if !audioData.isEmpty {
                            // Accumulate into prebuffer for promotion flush (serialized by actor)
                            Task { [weak self] in
                                guard let self = self else { return }
                                await self.prebuffer.append(audioData)
                            }
                        }
                        Task { @MainActor in
                            if !self.micEngaged { self.micEngaged = true }
                            self.streamingAudioLevel = processed.level
                            self.sonioxMeter = AudioMeter(averagePower: processed.level, peakPower: processed.level)
                        }
                    }
                },
                preflight: !RuntimeConfig.skipPreflightOnPreview
            )
            // Start/ensure shared capture engine is running
            try await UnifiedAudioManager.shared.startCapture()
            // Mark preview start time for gap diagnostics
            previewStartedAt = Date()
            isPreviewActive = true
            if RuntimeConfig.enableVerboseLogging {
                logger.notice("👂 [PREVIEW] Mic engaged; buffering pre‑roll during promotion window…")
            }
        } catch {
            logger.error("❌ Failed to start preview capture: \(error.localizedDescription)")
            // Best effort cleanup
            if let id = previewTapId { await UnifiedAudioManager.shared.unregisterAudioTap(identifier: id) }
            previewTapId = nil
            isPreviewActive = false
            bufferingState = .idle
            await prebuffer.clear()
        }
    }

    /// Stop preview capture. If we did not promote to full streaming, discard any buffered audio.
    func stopPreviewCapture() async {
        guard isPreviewActive else { return }
        if let id = previewTapId {
            await UnifiedAudioManager.shared.unregisterAudioTap(identifier: id)
            previewTapId = nil
        }
        // If not actively streaming, this was a mis‑touch — trash pre‑roll audio and shut down engine
        if !isStreaming {
            await prebuffer.clear()
            bufferingState = .idle
            await UnifiedAudioManager.shared.stopCapture()
            await MainActor.run {
                self.micEngaged = false
                self.streamingAudioLevel = 0.0
            }
            if RuntimeConfig.enableVerboseLogging {
                logger.notice("🗑️ [PREVIEW] Mis‑touch: discarded pre‑roll and stopped capture")
            }
        }
        isPreviewActive = false
    }
}

