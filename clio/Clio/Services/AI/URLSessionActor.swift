import Foundation

actor URLSessionActor {
    private var session: URLSession?
    private weak var delegate: (URLSessionDelegate & URLSessionWebSocketDelegate & URLSessionTaskDelegate)?

    init(delegate: URLSessionDelegate & URLSessionWebSocketDelegate & URLSessionTaskDelegate) {
        self.delegate = delegate
    }

    private func makeConfiguration(isColdStart: Bool) -> URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        if isColdStart {
            // More generous timeouts for cold start scenarios
            config.timeoutIntervalForRequest = 45
            config.timeoutIntervalForResource = 600
            config.httpMaximumConnectionsPerHost = 2
        } else {
            // Standard timeouts for warm scenarios
            config.timeoutIntervalForRequest = 20
            config.timeoutIntervalForResource = 120
            config.httpMaximumConnectionsPerHost = 4
        }
        return config
    }

    func getOrCreate(isColdStart: Bool = false) -> URLSession {
        if let s = session, s.delegate != nil {
            return s
        }
        let config = makeConfiguration(isColdStart: isColdStart)
        guard let delegate = delegate else {
            // If delegate is gone, create a session without delegate (caller should recreate actor)
            let s = URLSession(configuration: config)
            session = s
            return s
        }
        let s = URLSession(configuration: config, delegate: delegate, delegateQueue: nil)
        session = s
        return s
    }

    func recreate(isColdStart: Bool = false) {
        session?.invalidateAndCancel()
        session = nil
        _ = getOrCreate(isColdStart: isColdStart)
    }

    func invalidate() {
        session?.invalidateAndCancel()
        session = nil
    }
}

