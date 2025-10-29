import Foundation

extension SonioxStreamingService {
    // Runs the drain/EOS/finalize sequence and related post-steps.
    // This is a pure extraction of the existing stopStreaming() tail to improve readability.
    internal func runFinalizationSequence(fastCancel: Bool) async {
        guard !fastCancel, let webSocket = webSocket else {
            // If fastCancel or no socket, nothing to do here
            return
        }
        do {
            // Drain-before-finalize to avoid truncation on tail
            let queued = await sendActor.getQueueDepth()
            if queued > 0 {
                logger.notice("🧺 [DRAIN] Starting drain-before-finalize queued=\(queued)")
            }
            // Conditional tail wait: only when needed
            let ageMs = await sendActor.millisSinceLastSend() ?? 9999
            if queued > 0 {
                // Keep conservative tail if there are pending frames
                try? await Task.sleep(nanoseconds: 250_000_000)
            } else if ageMs < 120 {
                // Recent send: small tail to capture stragglers
                try? await Task.sleep(nanoseconds: 90_000_000)
            } // else: skip waiting entirely

            // Adaptive drain timeout
            let drainTimeout = queued > 0 ? 600 : 250
            let drained = await sendActor.waitUntilDrained(timeoutMs: drainTimeout)
            if !drained {
                let remaining = await sendActor.getQueueDepth()
                logger.warning("⏳ [DRAIN] Timeout waiting for queue to drain — proceeding with EOS (remaining=\(remaining))")
            } else if queued > 0 {
                logger.notice("✅ [DRAIN] Queue drained before finalize")
            }

            // If any preview/prebuffer audio remains and we are READY, flush it so we don't lose early speech
            if self.webSocketReady {
                let bytes = await self.prebuffer.totalBytes()
                if bytes > 0 {
                    self.logger.notice("📦 [STOP] Flushing prebuffer before EOS (bytes=\(bytes))")
                    await self.flushPrebufferNow(totalBufferedBytes: bytes, bufferDuration: 0)
                    // Allow a tiny tail so server can emit tokens
                    try? await Task.sleep(nanoseconds: 120_000_000)
                }
            }

            // Snapshot quiet window BEFORE sending EOS/control frames to avoid resetting tail checks
            let preQuietMs = await sendActor.millisSinceLastSend() ?? 9999

            // Send empty binary frame to signal end of audio
            try await webSocket.send(.data(Data()))
            logger.debug("📤 Sent end-of-stream signal")

            // Post‑EOS decision: if we saw a recent <end> just before EOS and nothing new arrived after it,
            // trust it and skip manual finalize. Otherwise, briefly wait for a post‑EOS <end>.
            let eosAt = Date()
            let softMs = RuntimeConfig.endWindowSoftMs
            let hardMs = RuntimeConfig.endWindowHardMs

            let noPendingTokens = self.partialTranscript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            let depthAfterEOS = await sendActor.getQueueDepth()
            let noUnsentAudio = depthAfterEOS == 0

            var didSendFinalize = false
            var didQuickDrop = false
            var skippedByPreEosEnd = false
            if let endAt = self.endTokenLastSeenAt, noPendingTokens, noUnsentAudio {
                let sinceEndMs = Int(eosAt.timeIntervalSince(endAt) * 1000)
                let noTokensAfterEnd = (self.lastTokenActivityAt == nil) || (self.lastTokenActivityAt! <= eosAt)
                if noTokensAfterEnd {
                    logger.notice("🏁 Using pre‑EOS <end> (last seen \(sinceEndMs)ms before EOS) — skipping manual finalize")
                    if TimingMetrics.shared.clientFinalizeTs == nil { TimingMetrics.shared.clientFinalizeTs = Date() }
                    self.transcriptionBuffer.checkAndCompleteSegment()
                    if !self.partialTranscript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        let merged = self.normalizedJoin(self.transcriptionBuffer.finalText, self.partialTranscript)
                        self.finalBuffer = merged
                    } else {
                        self.finalBuffer = self.transcriptionBuffer.finalText
                    }
                    skippedByPreEosEnd = true
                }
            }

            if !skippedByPreEosEnd {
                // Briefly wait for a post‑EOS <end> (soft window, then hard cap)
                var sawEndAfterStop = false
                let softDeadline = eosAt.addingTimeInterval(TimeInterval(softMs) / 1000.0)
                while Date() < softDeadline {
                    if let endAt = self.endTokenLastSeenAt, endAt >= eosAt { sawEndAfterStop = true; break }
                    try? await Task.sleep(nanoseconds: 20_000_000) // 20ms slices
                }
                if !sawEndAfterStop {
                    let hardDeadline = eosAt.addingTimeInterval(TimeInterval(hardMs) / 1000.0)
                    while Date() < hardDeadline {
                        if let endAt = self.endTokenLastSeenAt, endAt >= eosAt { sawEndAfterStop = true; break }
                        try? await Task.sleep(nanoseconds: 20_000_000)
                    }
                }
                if sawEndAfterStop && noPendingTokens && noUnsentAudio {
                    logger.notice("🏁 Received <end> after EOS — skipping manual finalize")
                    if TimingMetrics.shared.clientFinalizeTs == nil { TimingMetrics.shared.clientFinalizeTs = Date() }
                    self.transcriptionBuffer.checkAndCompleteSegment()
                    let currentPartial = self.partialTranscript.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !currentPartial.isEmpty {
                        let merged = self.normalizedJoin(self.transcriptionBuffer.finalText, currentPartial)
                        self.finalBuffer = merged
                    } else if !self.lastNonEmptyPartialSnapshot.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && self.hasAnyTokensReceived {
                        let merged = self.normalizedJoin(self.transcriptionBuffer.finalText, self.lastNonEmptyPartialSnapshot)
                        self.finalBuffer = merged
                        self.logger.notice("🛟 [FALLBACK] Using snapshot partial for final (pre‑EOS path)")
                    } else {
                        self.finalBuffer = self.transcriptionBuffer.finalText
                    }
                } else {
                    // Fallback: no post‑EOS <end> observed — send manual finalize and wait for <fin>
                    var strictFinalizeShortUtterance = false
                    if let t0 = self.audioFileManager.currentRecordingStartTime {
                        let connectionDelay = Date().timeIntervalSince(t0) * 1000
                        strictFinalizeShortUtterance = connectionDelay < 500
                    }
                    let finalizeCmd = "{\"type\": \"finalize\"}"
                    let expectedAttempt = socketAttemptId
                    do {
                        try await sendControlText(finalizeCmd, expectedAttemptId: expectedAttempt)
                        logger.debug("📤 Sent manual finalize request")
                    } catch {
                        logger.warning("⚠️ Failed to send manual finalize: \(error.localizedDescription)")
                    }
                    var baseTimeout = 40 // ~2s, wait up to ~1s for <fin> (20 * 50ms)
                    if strictFinalizeShortUtterance { baseTimeout = 20 }

                    logger.debug("🕐 Using finalization timeout: \(baseTimeout * 50)ms")

                    let pendingDepth = await sendActor.getQueueDepth()
                    let msSinceLast = max(preQuietMs, await sendActor.millisSinceLastSend() ?? 9999)
                    let tailMs = fastFinalizeTailMs
                    let partialEmpty = self.partialTranscript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    let noRecentTokensOkEnd: Bool = {
                        guard let t = self.lastTokenActivityAt else { return true }
                        return Int(Date().timeIntervalSince(t) * 1000) >= tailMs
                    }()
                    var skipByEnd = endTokenSeen && (pendingDepth == 0) && (msSinceLast >= tailMs) && (partialEmpty || noRecentTokensOkEnd)
                    if enableFastFinalizeSkip && endTokenSeen && pendingDepth == 0 && !skipByEnd && !RuntimeConfig.fastFinalizeUnconditionalEndSkip {
                        let remaining = max(0, tailMs - msSinceLast)
                        if remaining > 0 { try? await Task.sleep(nanoseconds: UInt64(remaining) * 1_000_000) }
                        let msAfter = await sendActor.millisSinceLastSend() ?? 9999
                        let depthAfter = await sendActor.getQueueDepth()
                        let partialEmptyAfter = self.partialTranscript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        let noRecentTokensOkAfter: Bool = {
                            guard let t = self.lastTokenActivityAt else { return true }
                            return Int(Date().timeIntervalSince(t) * 1000) >= tailMs
                        }()
                        skipByEnd = endTokenSeen && (depthAfter == 0) && (msAfter >= tailMs) && (partialEmptyAfter || noRecentTokensOkAfter)
                    }
                    let localSilenceOk: Bool = {
                        if let since = silenceBelowThresholdSince { return Int(Date().timeIntervalSince(since) * 1000) >= tailMs }
                        return false
                    }()
                    let noRecentTokensOk: Bool = {
                        guard let t = lastTokenActivityAt else { return true }
                        return Int(Date().timeIntervalSince(t) * 1000) >= tailMs
                    }()
                    let skipByHeuristic = !endTokenSeen && (pendingDepth == 0) && (msSinceLast >= tailMs) && localSilenceOk && noRecentTokensOk
                    let unconditionalEndSkip = RuntimeConfig.fastFinalizeUnconditionalEndSkip && endTokenSeen && (pendingDepth == 0)
                    let shouldOptimisticSkip = enableFastFinalizeSkip && (
                        (endTokenSeen && (unconditionalEndSkip || skipByEnd)) ||
                        (!endTokenSeen && !strictFinalizeShortUtterance && skipByHeuristic)
                    )
                    if shouldOptimisticSkip {
                        let path = unconditionalEndSkip ? "end_unconditional" : (skipByEnd ? "end" : "heuristic")
                        logger.notice("⚡ [OPTIMISTIC] Skipping wait-for-<fin> path=\(path) tail=\(tailMs)ms pending=\(pendingDepth) ms_since_last=\(msSinceLast)")
                        if TimingMetrics.shared.clientFinalizeTs == nil { TimingMetrics.shared.clientFinalizeTs = Date() }
                        self.postFinalizeTokensAfterSkipCount = 0
                        self.postFinalizeGuardUntil = Date().addingTimeInterval(Double(fastFinalizeGuardWindowMs) / 1000.0)
                        if !self.partialTranscript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            self.transcriptionBuffer.forceCompleteCurrentSegment()
                            let merged = self.normalizedJoin(self.transcriptionBuffer.finalText, self.partialTranscript)
                            self.finalBuffer = merged
                        }
                    } else {
                        logger.debug("ℹ️ [OPTIMISTIC] Not skipping: end=\(self.endTokenSeen) pending=\(pendingDepth) ms_since_last=\(msSinceLast)")
                    }
                    for _ in 0..<baseTimeout {
                        if shouldOptimisticSkip { break }
                        if finTokenReceived || finishedReceived {
                            let elapsed = Date().timeIntervalSince(eosAt) * 1000
                            logger.notice("✅ Received <fin> token after \(Int(elapsed))ms")
                            break
                        }
                        try? await Task.sleep(nanoseconds: 50_000_000)
                    }
                    if !finTokenReceived && !shouldOptimisticSkip {
                        let elapsed = Date().timeIntervalSince(eosAt) * 1000
                        logger.warning("⚠️ Timed out waiting for <fin> token after \(Int(elapsed))ms — merging partial transcript")
                        if !partialTranscript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            self.transcriptionBuffer.forceCompleteCurrentSegment()
                            let merged = self.normalizedJoin(self.transcriptionBuffer.finalText, self.partialTranscript)
                            self.finalBuffer = merged
                        }
                    }
                    if shouldOptimisticSkip, let _ = self.postFinalizeGuardUntil {
                        logger.debug("🔬 [OPTIMISTIC] tokens_after_skip=\(self.postFinalizeTokensAfterSkipCount) window_ms=\(self.fastFinalizeGuardWindowMs)")
                        self.postFinalizeGuardUntil = nil
                    }
                }
            }
        } catch {
            logger.error("❌ Failed to send finalization: \(error.localizedDescription)")
        }

        // Stop listener cleanly
        listenerTask?.cancel()
        listenerTask = nil

        // Instead of always disconnecting, optionally keep a warm socket window
        if RuntimeConfig.enableVerboseLogging {
            logger.debug("⏹️ Keepalive timer stopped")
        }
        // Stop path monitoring when not streaming
        networkMonitor.stop()
    }
}

