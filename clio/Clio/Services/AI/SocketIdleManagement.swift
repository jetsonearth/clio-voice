import Foundation

extension SonioxStreamingService {
    // MARK: - Keepalive Management
    internal func startKeepaliveTimer() {
        stopKeepaliveTimer() // Ensure no duplicate timers
        timers.scheduleRepeating(.keepalive, every: keepaliveInterval) { [weak self] in
            Task { [weak self] in
                await self?.sendKeepalive()
            }
        }
        logger.debug("🔄 Keepalive timer started (interval: \(self.keepaliveInterval)s)")
    }

    internal func stopKeepaliveTimer() {
        timers.cancel(.keepalive)
        logger.debug("⏹️ Keepalive timer stopped")
    }

    internal func sendKeepalive() async {
        guard isStreaming else { return }
        // Do not emit active keepalives until START is sent on this socket
        if !startTextSentForCurrentSocket {
            logger.debug("⏸️ [KEEPALIVE] muted (start_text_sent=false)")
            return
        }
        // Temporary mute window after reuse START to avoid 400s during server state transition
        if let muteUntil = keepaliveMutedUntil, Date() < muteUntil {
            logger.debug("⏸️ [KEEPALIVE] muted until \(muteUntil.timeIntervalSince1970)")
            return
        }
        let keepaliveCmd = "{\"type\": \"keepalive\"}"
        let expectedAttempt = socketAttemptId
        do {
            try await sendControlText(keepaliveCmd, expectedAttemptId: expectedAttempt)
            logger.debug("💓 Sent keepalive (active)")
        } catch {
            logger.error("❌ Keepalive send failed: \(error.localizedDescription)")
        }
    }

    // Idle keepalive for warm-hold
    internal func sendIdleKeepalive() async {
        guard isWarmHoldActive else { return }
        // Use Soniox control keepalive to keep the session alive at the application layer
        let keepaliveCmd = "{\"type\": \"keepalive\"}"
        let expectedAttempt = socketAttemptId
        do {
            try await sendControlText(keepaliveCmd, expectedAttemptId: expectedAttempt)
            logger.debug("💤 [WARM-HOLD] idle_keepalive_tick")
            StructuredLog.shared.log(cat: .stream, evt: "idle_keepalive_tick", lvl: .info, [:])
        } catch {
            logger.error("❌ [WARM-HOLD] Keepalive send failed: \(error.localizedDescription)")
        }
    }

    internal func startWarmHold() {
        // Only when socket is ready and reuse is enabled
        guard RuntimeConfig.keepWarmSocketBetweenSessions, webSocket != nil, webSocketReady else {
            logger.debug("ℹ️ [WARM-HOLD] Not starting warm hold (socket_ready=\(self.webSocketReady))")
            return
        }
        isWarmHoldActive = true
        warmHoldStartTime = Date()

        // Schedule 60-second timeout to close socket if no new recording
        timers.scheduleOnce(.warmHoldTimeout, after: 60.0) { [weak self] in
            Task { [weak self] in
                guard let self = self else { return }
                if self.isWarmHoldActive {
                    self.logger.notice("⏱️ [WARM-HOLD] 60s timeout reached - closing socket")
                    self.stopWarmHold()
                    await self.disconnectWebSocket()
                }
            }
        }

        // Use 10s interval for keepalives to maintain connection
        timers.scheduleRepeating(.idleKeepalive, every: 10.0) { [weak self] in
            Task { [weak self] in
                await self?.sendIdleKeepalive()
            }
        }
        logger.notice("🧊 [WARM-HOLD] Started warm hold: 60s timer active, idle keepalives active")
        StructuredLog.shared.log(cat: .stream, evt: "warm_hold", lvl: .info, ["state": "start"])
    }

    internal func stopWarmHold() {
        if isWarmHoldActive {
            timers.cancel(.idleKeepalive)
            timers.cancel(.warmHoldTimeout)
            isWarmHoldActive = false
            if let startTime = warmHoldStartTime {
                let duration = Date().timeIntervalSince(startTime)
                logger.notice("🧊 [WARM-HOLD] Stopped warm hold after \(String(format: "%.1f", duration))s")
            } else {
                logger.notice("🧊 [WARM-HOLD] Stopped warm hold")
            }
            StructuredLog.shared.log(cat: .stream, evt: "warm_hold", lvl: .info, ["state": "stop"])
            warmHoldStartTime = nil
        } else {
            timers.cancel(.idleKeepalive)
            timers.cancel(.warmHoldTimeout)
        }
    }

    // Standby keepalive + TTL management
    internal func startStandbyKeepaliveAndTTL() {
        // Use dedicated standby keepalive ticking and a TTL to close if unused
        timers.cancel(.idleKeepalive)
        let interval = RuntimeConfig.standbyKeepaliveIntervalSeconds
        timers.scheduleRepeating(.idleKeepalive, every: interval) { [weak self] in
            Task { [weak self] in await self?.sendStandbyKeepalive() }
        }
        // TTL
        standbyTTLTask?.cancel()
        let ttl = RuntimeConfig.standbyTTLSeconds
        // Bind TTL to current socket/attempt so stale timers can't close a newly created socket
        let scheduledAttempt = socketAttemptId
        let scheduledSocket = currentSocketId
        standbyTTLTask = Task { [weak self] in
            do {
                try await Task.sleep(nanoseconds: UInt64(ttl * 1_000_000_000))
            } catch {
                // Task cancelled before TTL expiration; ignore
                return
            }
            guard let self = self else { return }
            // Ignore TTL if this timer was scheduled for an older socket/attempt or state changed
            guard self.isStandbySocket,
                  !self.isStreaming,
                  self.socketAttemptId == scheduledAttempt,
                  self.currentSocketId == scheduledSocket else {
                self.logger.debug("⏭️ [STANDBY] Ignoring stale TTL (scheduled_attempt=\(scheduledAttempt) current_attempt=\(self.socketAttemptId) scheduled_socket=\(scheduledSocket) current_socket=\(self.currentSocketId) standby=\(self.isStandbySocket) streaming=\(self.isStreaming))")
                return
            }
            self.logger.notice("⏱️ [STANDBY] TTL reached (\(Int(ttl))s) — closing standby socket")
            await self.disconnectWebSocket()
            self.isStandbySocket = false
            self.connectPurpose = .active
        }
        logger.notice("🧊 [STANDBY] Connected standby socket — keepalive every \(String(format: "%.1f", interval))s, TTL=\(Int(ttl))s (attempt=\(self.socketAttemptId), socket=\(self.currentSocketId))")
    }

    internal func sendStandbyKeepalive() async {
        guard isStandbySocket else { return }
        // If START hasn’t been sent (non‑eager mode), suppress keepalive cleanly
        if !startTextSentForCurrentSocket {
            logger.debug("⏸️ [STANDBY] keepalive muted (pre-START)")
            return
        }
        let keepaliveCmd = "{\"type\": \"keepalive\"}"
        let expectedAttempt = socketAttemptId
        do {
            try await sendControlText(keepaliveCmd, expectedAttemptId: expectedAttempt)
            logger.debug("💤 [STANDBY] keepalive_tick")
            StructuredLog.shared.log(cat: .stream, evt: "standby_keepalive_tick", lvl: .info, [:])
        } catch {
            logger.debug("⚠️ [STANDBY] Keepalive send failed: \(error.localizedDescription)")
        }
    }
}

