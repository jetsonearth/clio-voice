import Foundation

extension SonioxStreamingService {
    // MARK: - URLSessionWebSocketDelegate
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        if !RuntimeConfig.shouldSilenceAllLogs {
            let sid = "sock_\(ObjectIdentifier(webSocketTask).hashValue)"
            logger.notice("🔌 WebSocket did open (sid=\(sid), attemptId=\(self.socketAttemptId))")
        }
        // Accept opens when actively streaming OR when connecting a standby socket
        let acceptOpen = isStreaming || (connectPurpose == .standby)
        if !acceptOpen {
            logger.warning("ℹ️ didOpen received after stop and not standby – ignoring and canceling socket")
            webSocketTask.cancel(with: .goingAway, reason: nil)
            return
        }
        guard let current = self.webSocket, current == webSocketTask else {
            logger.warning("ℹ️ didOpen for stale socket – ignoring and canceling stale task")
            webSocketTask.cancel(with: .goingAway, reason: nil)
            return
        }
        Task { [weak self] in
            await self?.finalizeConnection()
        }
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        let sid = "sock_\(ObjectIdentifier(webSocketTask).hashValue)"
        let isBenign = (closeCode == .goingAway || closeCode == .normalClosure)
        if isBenign && (isStandbySocket || !isStreaming || isShuttingDown) {
            logger.debug("🔌 [WS] Closed (code \(closeCode.rawValue)) during standby/shutdown (sid=\(sid), attemptId=\(self.socketAttemptId))")
            StructuredLog.shared.log(cat: .stream, evt: "state", lvl: .info, ["state": "closed", "code": Int(closeCode.rawValue)])
        } else if isBenign {
            logger.notice("🔌 WebSocket did close with code \(closeCode.rawValue) (sid=\(sid), attemptId=\(self.socketAttemptId))")
            StructuredLog.shared.log(cat: .stream, evt: "state", lvl: .info, ["state": "closed", "code": Int(closeCode.rawValue)])
        } else {
            logger.warning("⚠️ WebSocket did close with code \(closeCode.rawValue) (sid=\(sid), attemptId=\(self.socketAttemptId))")
            StructuredLog.shared.log(cat: .stream, evt: "state", lvl: .warn, ["state": "closed", "code": Int(closeCode.rawValue)])
        }

        // Immediately pause the send queue to prevent frames from being pushed into a dead socket
        Task { [weak self] in
            await self?.sendActor.pauseQueue()
        }

        // If we're waiting for connection readiness, signal failure (gate covers primary path)
        self.continuationGate.cancelIfPending(SonioxError.sessionNotConfigured)

        // If we were in warm-hold, stop it and log
        if isWarmHoldActive {
            stopWarmHold()
            logger.notice("🧊 [WARM-HOLD] Socket closed by server during idle")
        }

        // Do NOT attempt mid-recording recovery. Keep capturing and buffer; finalize will handle fallback.
        if isStreaming {
            logger.notice("🧯 [NO-MIDSTREAM-RECOVERY] Will continue buffering; finalize will handle output")
        }
    }
}

