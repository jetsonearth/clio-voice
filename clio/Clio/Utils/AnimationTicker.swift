import Foundation
import Combine

/// High-performance shared animation ticker that consolidates multiple timers into a single 60fps source.
/// This dramatically reduces CPU wake-ups and power consumption when multiple visualizers are active.
final class AnimationTicker {
    static let shared = AnimationTicker()

    /// Publishes an incrementing integer every frame.
    let publisher: AnyPublisher<Int, Never>

    private var counter = 0
    private var timerCancellable: AnyCancellable?
    private let subject = PassthroughSubject<Int, Never>()

    private var subscriberCount = 0
    private let lock = NSLock()
    private var isHighActivity = false

    private init() {
        self.publisher = subject.eraseToAnyPublisher()
        // Optional diagnostics snapshot
        NotificationCenter.default.addObserver(forName: .diagnosticsSnapshot, object: nil, queue: .main) { [weak self] _ in
            guard let self else { return }
            StructuredLog.shared.log(cat: .ui, evt: "ticker_snapshot", lvl: .info, [
                "subscribers": self.subscriberCount,
                "highActivity": self.isHighActivity
            ])
        }
    }

    /// Call from `onAppear` of any view that wants to receive ticks.
    @MainActor
    func startTicking() {
        lock.lock(); defer { lock.unlock() }
        subscriberCount += 1
        guard subscriberCount == 1 else { return } // already running
        // Notify listeners of subscriber change
        NotificationCenter.default.post(name: .animationTickerChanged, object: nil, userInfo: ["subscribers": subscriberCount])

        // Adaptive frequency with runtime tuning
        let highFPS = RuntimeConfig.uiAnimationFPSHigh
        let lowFPS = RuntimeConfig.uiAnimationFPSLow
        // When ReducedUIEffects is enabled, clamp to low-FPS regardless of activity
        let useHigh = isHighActivity && !RuntimeConfig.reducedUIEffects
        let frequency = useHigh ? 1.0 / highFPS : 1.0 / lowFPS
        timerCancellable = Timer.publish(every: frequency, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                self.counter += 1
                self.subject.send(self.counter)
            }
    }

    /// Call from `onDisappear` when the view no longer needs ticks.
    @MainActor
    func stopTicking() {
        lock.lock(); defer { lock.unlock() }
        subscriberCount = max(0, subscriberCount - 1)
        // Notify listeners of subscriber change
        NotificationCenter.default.post(name: .animationTickerChanged, object: nil, userInfo: ["subscribers": subscriberCount])
        guard subscriberCount == 0 else { return }

        timerCancellable?.cancel()
        timerCancellable = nil
    }

    /// Set high activity mode for 60fps, low activity for 30fps
    @MainActor
    func setHighActivity(_ active: Bool) {
        guard active != isHighActivity else { return }
        isHighActivity = active
        
        // Restart timer with new frequency if running
        if subscriberCount > 0 {
            timerCancellable?.cancel()
            let highFPS = RuntimeConfig.uiAnimationFPSHigh
            let lowFPS = RuntimeConfig.uiAnimationFPSLow
            // When ReducedUIEffects is enabled, clamp to low-FPS regardless of activity
            let useHigh = isHighActivity && !RuntimeConfig.reducedUIEffects
            let frequency = useHigh ? 1.0 / highFPS : 1.0 / lowFPS
            timerCancellable = Timer.publish(every: frequency, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] _ in
                    guard let self else { return }
                    self.counter += 1
                    self.subject.send(self.counter)
                }
        }
    }
    
    deinit {
        timerCancellable?.cancel()
    }
}

// MARK: - AnimationTicker Diagnostics / Notifications
extension AnimationTicker {
    /// Thread-safe read of current subscriber count
    func currentSubscriberCount() -> Int {
        lock.lock(); defer { lock.unlock() }
        return subscriberCount
    }
}

extension Notification.Name {
    /// Emitted whenever the AnimationTicker subscriber count changes.
    static let animationTickerChanged = Notification.Name("com.cliovoice.clio.animationTickerChanged")
}
