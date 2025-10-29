import Foundation

extension SonioxStreamingService {
    // MARK: - Readiness Watchdog (pre-speech)
    func startReadinessWatchdog() {
        guard useNewWatchdogs else { return }
        readinessDidRestartTap = false
        readinessDidReopenWS = false
        timers.cancel(.readinessWatchdog)
        timers.scheduleOnce(.readinessWatchdog, after: 2.0) { [weak self] in
            self?.onReadinessDeadline()
        }
    }

    @MainActor internal func uiSubscriberCount() -> Int { uiSubscribers }

    internal func trySatisfyReadiness() {
        guard useNewWatchdogs else { return }
        let ws = webSocketReady
        let audio = firstAudioCapturedFlag
        let subs = uiSubscribers
        if ws && audio && subs > 0 {
            timers.cancel(.readinessWatchdog)
            StructuredLog.shared.log(cat: .ui, evt: "listening_ready", lvl: .info, ["ready": true])
        }
    }

    func onReadinessDeadline() {
        // Observe-only: do not take any destructive action pre-speech.
        guard useNewWatchdogs, isStreaming, !speechLatched else { return }
        let ws = webSocketReady
        let audio = firstAudioCapturedFlag
        let subs = uiSubscribers
        if ws && audio && subs > 0 {
            timers.cancel(.readinessWatchdog)
            return
        }
        // Park quietly; periodically snapshot for debugging without restarts
        StructuredLog.shared.log(cat: .sys, evt: "main_stall", lvl: .warn, [
            "threshold_ms": 2000,
            "ui_subscribers": subs,
            "wsReady": ws,
            "firstAudio": audio
        ])
        // Reschedule observation lightly to reduce spam
        timers.scheduleOnce(.readinessWatchdog, after: 2.0) { [weak self] in
            self?.onReadinessDeadline()
        }
    }

    // MARK: - TTFT Watchdog (speech-latched)
    private enum TTFTPhase: Int { case p1 = 1, p2, p3, p4, done }
    private var ttftPhaseState: TTFTPhase { TTFTPhase(rawValue: ttftPhase) ?? .p1 }

    func startTTFTWatchdog() {
        guard useNewWatchdogs else { return }
        ttftPhase = 1
        timers.cancel(.ttftWatchdog)
        timers.scheduleOnce(.ttftWatchdog, after: 2.0) { [weak self] in
            self?.onTTFTDeadline()
        }
    }

    func maybeFulfillTTFT() {
        guard useNewWatchdogs else { return }
        if firstPartialReceived && uiPaintedFirstToken {
            timers.cancel(.ttftWatchdog)
            emitTTFTSLOIfNeeded(phase: ttftPhaseState)
        }
    }

    func onTTFTDeadline() {
        guard useNewWatchdogs, isStreaming else { return }
        // Gate: require >= 250ms of audio since latch
        if audioMsSinceLatch < 250 {
            // Extend once shortly until enough audio is sent
            timers.scheduleOnce(.ttftWatchdog, after: 0.3) { [weak self] in
                self?.onTTFTDeadline()
            }
            return
        }
        // NEW: If we've seen ANY token (partial OR final), stop escalating.
        if firstPartialReceived || hasAnyTokensReceived {
            timers.cancel(.ttftWatchdog)
            emitTTFTSLOIfNeeded(phase: ttftPhaseState)
            return
        }
        // NEW: Add a generous grace window before touching the socket mid‑speech.
        if let t0 = firstSpeechAt, Date().timeIntervalSince(t0) < 3.5 {
            timers.scheduleOnce(.ttftWatchdog, after: 0.5) { [weak self] in
                self?.onTTFTDeadline()
            }
            return
        }
        // TTFT watchdog disabled: observe-only mode
        switch ttftPhaseState {
        case .p1:
            logger.warning("🚑 [TTFT-WATCHDOG] Would restart audio tap (phase 1) - observing only")
            ttftPhase = TTFTPhase.p2.rawValue
            timers.scheduleOnce(.ttftWatchdog, after: 0.5) { [weak self] in self?.onTTFTDeadline() }
        case .p2:
            logger.warning("🚑 [TTFT-WATCHDOG] Would reopen WebSocket (phase 2) - observing only")
            ttftPhase = TTFTPhase.p3.rawValue
            timers.scheduleOnce(.ttftWatchdog, after: 1.0) { [weak self] in self?.onTTFTDeadline() }
        case .p3:
            logger.warning("🚑 [TTFT-WATCHDOG] Would rebuild audio and WS (phase 3) - observing only")
            ttftPhase = TTFTPhase.p4.rawValue
            timers.scheduleOnce(.ttftWatchdog, after: 1.0) { [weak self] in self?.onTTFTDeadline() }
        case .p4:
            logger.warning("🚑 [TTFT-WATCHDOG] Would start on-device ASR (phase 4) - observing only")
            ttftPhase = TTFTPhase.done.rawValue
            // Keep watching; a later success will cancel
            timers.scheduleOnce(.ttftWatchdog, after: 1.0) { [weak self] in self?.onTTFTDeadline() }
        case .done:
            // Do nothing further
            break
        }
    }

    private func emitTTFTSLOIfNeeded(phase: TTFTPhase) {
        guard !sloEmittedThisSession else { return }
        sloEmittedThisSession = true
        let payload: [String: Any] = [
            "t_mic_engaged": (tMicEngagedAt?.timeIntervalSince1970 ?? 0),
            "t_ws_ready": (tWsReadyAt?.timeIntervalSince1970 ?? 0),
            "t_first_audio": (tFirstAudioAt?.timeIntervalSince1970 ?? 0),
            "t_first_partial": (tFirstPartialAt?.timeIntervalSince1970 ?? 0),
            "t_ui_first_paint": (tUiFirstPaintAt?.timeIntervalSince1970 ?? 0),
            "ui_subscribers_at_start": uiSubscribers,
            "speech_latched_after_ms": firstSpeechAt.flatMap { Int(($0.timeIntervalSince(tMicEngagedAt ?? $0)) * 1000) } ?? -1,
            "ttft_ms": (tUiFirstPaintAt != nil && firstSpeechAt != nil) ? Int((tUiFirstPaintAt!.timeIntervalSince(firstSpeechAt!)) * 1000) : -1,
            "recovery_phase": String(describing: phase)
        ]
        StructuredLog.shared.log(cat: .stream, evt: "watchdog_slo", lvl: .info, payload)
    }

    // MARK: - Speech Watchdog (speech-gated stall detection)
    func maybeStartSpeechWatchdogIfEligible() {
        // Disable legacy watchdog when new TTFT watchdog is enabled
        if useNewWatchdogs { return }
        // Only if: streaming, READY, START/config already sent, actively speaking, no tokens yet, and not already scheduled
        let speakingNow: Bool = { self.speechFramesAboveThreshold > 0 }()
        guard isStreaming, webSocketReady, startTextSentForCurrentSocket, firstSpeechAt != nil, speakingNow, !hasAnyTokensReceived, speechWatchdogTask == nil else { return }
        let expectedAttempt = socketAttemptId
        let deadline = speechTokenDeadlineSeconds
        logger.debug("⏱️ [SPEECH-WATCHDOG] Arming watchdog: deadline=\(deadline)s attempt=\(expectedAttempt)")
        // Promotion: log watchdog arming gates
        logger.debug("🧪 [PROMO] speech_watchdog_arm attempt=\(expectedAttempt) speaking=\(speakingNow) bytes_threshold=\(self.minSpeechBytesForWatchdog) gates isStreaming=\(self.isStreaming) ws_ready=\(self.webSocketReady) start_sent=\(self.startTextSentForCurrentSocket) hasTokens=\(self.hasAnyTokensReceived)")
        speechWatchdogTask = Task { [weak self] in
            guard let self = self else { return }
            try? await Task.sleep(nanoseconds: UInt64(deadline * 1_000_000_000))
            guard !Task.isCancelled else { return }
            let speakingAtDeadline: Bool = { self.speechFramesAboveThreshold > 0 }()
            if self.isStreaming,
               self.webSocketReady,
               self.socketAttemptId == expectedAttempt,
               self.firstSpeechAt != nil,
               speakingAtDeadline,
               !self.hasAnyTokensReceived,
               self.bytesSinceFirstSpeech >= self.minSpeechBytesForWatchdog {
                self.logger.warning("🚑 [SPEECH-WATCHDOG] No tokens within \(deadline)s of active speech — observing only (bytes=\(self.bytesSinceFirstSpeech))")
                self.logger.warning("🧪 [PROMO] speech_watchdog_fire bytes=\(self.bytesSinceFirstSpeech) speaking_now=\(speakingAtDeadline)")
            } else {
                self.logger.debug("🟢 [SPEECH-WATCHDOG] Conditions not met at deadline (not speaking or tokens arrived or session changed)")
                self.logger.debug("🧪 [PROMO] speech_watchdog_skip speaking_now=\(speakingAtDeadline) hasTokens=\(self.hasAnyTokensReceived) bytes=\(self.bytesSinceFirstSpeech)")
            }
            self.speechWatchdogTask = nil
        }
    }

    func cancelSpeechWatchdog() {
        if let t = speechWatchdogTask {
            t.cancel()
            speechWatchdogTask = nil
            logger.debug("🛑 [SPEECH-WATCHDOG] Cancelled")
        }
    }
}
