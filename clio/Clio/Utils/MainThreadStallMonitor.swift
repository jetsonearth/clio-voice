import Foundation
import AppKit

/// Public diagnostic notification to request a state snapshot from subsystems.
public extension Notification.Name {
    static let diagnosticsSnapshot = Notification.Name("DiagnosticsSnapshotRequest")
}

/// Lightweight main-thread stall monitor.
/// When enabled, schedules a 60 Hz timer on the main run loop and logs when frame gaps exceed a threshold.
final class MainThreadStallMonitor {
    static let shared = MainThreadStallMonitor()

    private var timer: Timer?
    private var lastFire: Date?
    private var lastLogAt: Date?

    /// Threshold in milliseconds for considering a stall.
    private var thresholdMs: Int {
        let v = UserDefaults.standard.object(forKey: "StallThresholdMs") as? Int
        return (v ?? 120) > 0 ? (v ?? 120) : 120
    }

    /// Minimum seconds between consecutive stall logs to prevent spam.
    private var minLogIntervalSec: TimeInterval {
        let v = UserDefaults.standard.object(forKey: "StallLogIntervalSec") as? Double
        return (v ?? 1.0) > 0 ? (v ?? 1.0) : 1.0
    }

    private init() {}

    func start() {
        stop()
        lastFire = Date()
        // ~60 Hz
        timer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        lastFire = nil
    }

    private func tick() {
        guard let previous = lastFire else { lastFire = Date(); return }
        let now = Date()
        let deltaMs = Int(now.timeIntervalSince(previous) * 1000)
        lastFire = now
        if deltaMs > thresholdMs {
            // Throttle logging
            if let last = lastLogAt, now.timeIntervalSince(last) < minLogIntervalSec {
                return
            }
            lastLogAt = now
            StructuredLog.shared.log(cat: .sys, evt: "main_stall", lvl: .warn, [
                "delta_ms": deltaMs,
                "threshold_ms": thresholdMs
            ])
            // Ask subsystems to emit their snapshots at the moment of stall
            NotificationCenter.default.post(name: .diagnosticsSnapshot, object: nil)
        }
    }
}
