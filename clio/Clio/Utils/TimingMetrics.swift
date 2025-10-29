import Foundation
import os

// Lightweight cross-service timing aggregator for post-release E2E metrics
final class TimingMetrics {
    static let shared = TimingMetrics()
    private init() {}
    
    // Session-scoped markers
    var warmSocketAtStart: Bool = false
    var wasWarmSocketReused: Bool = false  // Track if warm socket was actually reused
    var keyUpTs: Date?
    var finTs: Date?
    // Client-side finalize when we skip waiting for <fin>
    var clientFinalizeTs: Date?
    var llmStartTs: Date?
    var llmEndTs: Date?
    var pasteStartTs: Date?
    var pasteDoneTs: Date?
    
    // Notch recorder diagnostics
    var notchIntentTs: Date?
    var notchShowCallTs: Date?
    var notchShownTs: Date?
    var notchFirstAudioTs: Date?
    var notchMode: String?

    func resetForNewSession() {
        warmSocketAtStart = false
        wasWarmSocketReused = false
        keyUpTs = nil
        finTs = nil
        clientFinalizeTs = nil
        llmStartTs = nil
        llmEndTs = nil
        pasteStartTs = nil
        pasteDoneTs = nil
    }

    // Update warm socket status dynamically
    func updateWarmSocketStatus(_ reused: Bool) {
        wasWarmSocketReused = reused
    }

    func markNotchIntent(mode: String?) {
        notchIntentTs = Date()
        notchShowCallTs = nil
        notchShownTs = nil
        notchFirstAudioTs = nil
        notchMode = mode
    }

    func markNotchShowCall() {
        notchShowCallTs = Date()
        notchShownTs = nil
        notchFirstAudioTs = nil
    }

    func markNotchShown() -> (intentToShowMs: Int?, showCallToShowMs: Int?) {
        let now = Date()
        notchShownTs = now
        return (
            deltaMs(from: notchIntentTs, to: now),
            deltaMs(from: notchShowCallTs, to: now)
        )
    }

    func markNotchFirstAudio() -> (intentToAudioMs: Int?, showCallToAudioMs: Int?, shownToAudioMs: Int?) {
        let now = Date()
        notchFirstAudioTs = now
        return (
            deltaMs(from: notchIntentTs, to: now),
            deltaMs(from: notchShowCallTs, to: now),
            deltaMs(from: notchShownTs, to: now)
        )
    }

    func deltaMs(from start: Date?, to end: Date) -> Int? {
        guard let start else { return nil }
        let delta = end.timeIntervalSince(start) * 1000.0
        return delta.isFinite ? max(0, Int(delta.rounded())) : nil
    }
}
