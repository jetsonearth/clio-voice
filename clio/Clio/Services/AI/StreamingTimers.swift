import Foundation

enum TimerKey {
    case firstBufferTapRefresh
    case firstBufferEngineRestart
    case deferredCaptureRestart
    case connectionWatchdog
    case startupWatchdog
    case keepalive
    case systemKeepalive
    case silentCapture
    // Extended keys used by SonioxStreamingService
    case idleKeepalive
    case warmHoldTimeout
    case readinessWatchdog
    case ttftWatchdog
}

struct StreamingTimers {
    private var timers: [TimerKey: DispatchSourceTimer] = [:]
    private static let queue = DispatchQueue(label: "com.cliovoice.clio.streamingTimers", qos: .utility)

    mutating func scheduleOnce(_ key: TimerKey, after: TimeInterval, _ block: @escaping () -> Void) {
        cancel(key)
        let timer = DispatchSource.makeTimerSource(queue: Self.queue)
        timer.schedule(deadline: .now() + after)
        timer.setEventHandler { block(); timer.cancel() }
        timers[key] = timer
        timer.resume()
    }

    mutating func scheduleRepeating(_ key: TimerKey, every: TimeInterval, _ block: @escaping () -> Void) {
        cancel(key)
        let timer = DispatchSource.makeTimerSource(queue: Self.queue)
        timer.schedule(deadline: .now() + every, repeating: every)
        timer.setEventHandler(handler: block)
        timers[key] = timer
        timer.resume()
    }

    mutating func cancel(_ key: TimerKey) {
        if let t = timers[key] { t.cancel(); timers.removeValue(forKey: key) }
    }

    mutating func cancelAll() {
        for (_, t) in timers { t.cancel() }
        timers.removeAll()
    }

    // Diagnostics: list active timer keys (best-effort)
    func activeKeys() -> [String] {
        timers.keys.map { String(describing: $0) }.sorted()
    }
}

final class Debouncer {
    private let delay: TimeInterval
    private var timer: DispatchSourceTimer?
    private static let queue = DispatchQueue(label: "com.cliovoice.clio.debouncer", qos: .utility)

    init(delay: TimeInterval) {
        self.delay = delay
    }

    func schedule(_ block: @escaping () -> Void) {
        timer?.cancel()
        let t = DispatchSource.makeTimerSource(queue: Self.queue)
        t.schedule(deadline: .now() + delay)
        t.setEventHandler { [weak t] in block(); t?.cancel() }
        timer = t
        t.resume()
    }

    func cancel() {
        timer?.cancel(); timer = nil
    }
}
