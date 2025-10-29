import Foundation

extension SonioxStreamingService {
    // MARK: - Diagnostics
    @objc func handleDiagnosticsSnapshot() {
        Task { @MainActor in
            self.debugSnapshot(tag: "broadcast")
        }
    }

    @MainActor
    func debugSnapshot(tag: String) {
        let ready = webSocketReady
        let connecting = isConnecting
        let listenerAlive = (listenerTask != nil)
        let activeTimers = timers.activeKeys()
        StructuredLog.shared.log(cat: .stream, evt: "soniox_snapshot", lvl: .info, [
            "tag": tag,
            "isStreaming": isStreaming,
            "wsReady": ready,
            "isConnecting": connecting,
            "listener": listenerAlive,
            "activeTimers": activeTimers.joined(separator: ","),
            "standby": isStandbySocket,
            "warmHold": isWarmHoldActive
        ])
        Task { [weak self] in
            guard let self else { return }
            let q = await self.sendActor.getQueueDepth()
            StructuredLog.shared.log(cat: .stream, evt: "soniox_queue", lvl: .info, ["depth": q])
        }
        urlSession?.getAllTasks { tasks in
            let running = tasks.filter { $0.state == .running }.count
            StructuredLog.shared.log(cat: .stream, evt: "urlsession_tasks", lvl: .info, ["running": running, "total": tasks.count])
        }
    }
}

