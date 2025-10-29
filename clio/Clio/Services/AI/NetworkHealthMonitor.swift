import Foundation
import Network
import os

final class NetworkHealthMonitor {
    enum ErrorType {
        case sslError
        case connectionReset
        case authenticationError
        case networkError
        case genericError
    }

    var isStreaming: (() -> Bool)?
    var isConnecting: (() -> Bool)?
    var getLastConnectedAt: (() -> Date?)?
    var onPathChangeRecover: (() async -> Void)?

    private let logger: Logger
    private let queue: DispatchQueue
    private let debounceSeconds: TimeInterval = 0.5
    private let cooldownSeconds: TimeInterval

    private var pathMonitor: NWPathMonitor?
    private var lastPathStatus: NWPath.Status?
    private var lastInterfaceType: NWInterface.InterfaceType?
    private var pathChangeDebounceWorkItem: DispatchWorkItem?

    init(logger: Logger, queueLabel: String = "com.cliovoice.clio.pathmonitor", cooldownSeconds: TimeInterval = 2.0) {
        self.logger = logger
        self.queue = DispatchQueue(label: queueLabel)
        self.cooldownSeconds = cooldownSeconds
    }

    func start() {
        stop()
        let monitor = NWPathMonitor()
        self.pathMonitor = monitor
        // Do not pre-seed status/interface so the first callback establishes a baseline
        lastPathStatus = nil
        lastInterfaceType = nil
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                self.pathChangeDebounceWorkItem?.cancel()
                let work = DispatchWorkItem { [weak self] in
                    guard let self = self else { return }
                    Task { @MainActor [weak self] in
                        guard let self = self else { return }
                        guard self.isStreaming?() == true else { return }
                        if self.isConnecting?() == true { return }

                        // If this is the very first path callback, establish a baseline and ignore
                        if self.lastPathStatus == nil && self.lastInterfaceType == nil {
                            self.lastPathStatus = path.status
                            self.lastInterfaceType = path.availableInterfaces.first?.type
                            self.logger.debug("🌐 [PATH] Initial path baseline set — no action")
                            return
                        }

                        // Ignore any path changes before the first successful connection
                        if self.getLastConnectedAt?() == nil {
                            self.lastPathStatus = path.status
                            self.lastInterfaceType = path.availableInterfaces.first?.type
                            self.logger.debug("🌐 [PATH] Update before first connection — ignored")
                            return
                        }
                        let statusChanged = (self.lastPathStatus != path.status)
                        let ifaceChanged = (self.lastInterfaceType != path.availableInterfaces.first?.type)
                        self.lastPathStatus = path.status
                        self.lastInterfaceType = path.availableInterfaces.first?.type
                        if statusChanged || ifaceChanged {
                            let statusDescription = String(describing: path.status)
                            if let last = self.getLastConnectedAt?(), Date().timeIntervalSince(last) < self.cooldownSeconds {
                                self.logger.debug("🌐 [PATH] Change within cooldown (\(self.cooldownSeconds)s) — ignoring")
                            } else {
                                self.logger.warning("🌐 [PATH] Network path changed (status=\(statusDescription, privacy: .public)) – triggering recovery")
                                await self.onPathChangeRecover?()
                            }
                        }
                    }
                }
                self.pathChangeDebounceWorkItem = work
                self.queue.asyncAfter(deadline: .now() + self.debounceSeconds, execute: work)
            }
        }
        monitor.start(queue: queue)
    }

    func stop() {
        pathMonitor?.cancel()
        pathMonitor = nil
        pathChangeDebounceWorkItem?.cancel()
        pathChangeDebounceWorkItem = nil
    }

    func classify(_ error: Error) -> ErrorType {
        let errorDescription = error.localizedDescription.lowercased()
        let code = (error as NSError).code
        if errorDescription.contains("bad record mac") || errorDescription.contains("ssl") || code == -9820 {
            return .sslError
        }
        if errorDescription.contains("connection reset") || errorDescription.contains("broken pipe") || code == 54 {
            return .connectionReset
        }
        if errorDescription.contains("keychain") || errorDescription.contains("authentication") || code == -67028 {
            return .authenticationError
        }
        if errorDescription.contains("network") || errorDescription.contains("timeout") || code == -1001 || code == -1005 || code == -1009 {
            return .networkError
        }
        return .genericError
    }
}

