import Foundation
import os
import AppKit

actor InputGate {
    private let logger = Logger(subsystem: "com.jetsonai.clio", category: "InputGate")
    private weak var recordingEngine: RecordingEngine?
    
    // PHASE 1.2: State machine integration (proof of concept)
    private var recorderStateMachine: RecorderStateMachine?
    private var commandExecutor: RecorderCommandExecutor?
    private var useStateMachine: Bool = false // Feature flag for gradual migration

    // Promotion timing. When PTTImmediateHold is enabled, start immediately on key down.
    private var promotionWindow: TimeInterval { UserDefaults.standard.bool(forKey: "PTTImmediateHold") ? 0.0 : 0.4 }

    // State
    private var generation: UInt64 = 0
    private var keyIsDown: Bool = false
    private var started: Bool = false
    private var handsFreeLocked: Bool = false
    private var lastDownAt: Date?
    private var probationTask: Task<Void, Never>?
    private var cooldownUntil: Date? = nil
    private let cooldownInterval: TimeInterval = 0.28 // Ignore stray events during teardown
    
    // Short logical cooldown window right after promotion to ignore stray inputs (no sleep)
    private var promotionCooldownUntil: Date? = nil
    private let promotionCooldownInterval: TimeInterval = 0.15
    
    // Ensure the notch fully opens visually before we auto-hide on mis-touch.
    // When PTTImmediateHold is enabled, hide immediately on release.
    private var minimumVisibleWindow: TimeInterval { UserDefaults.standard.bool(forKey: "PTTImmediateHold") ? 0.0 : 0.40 }
    private var lastUIShowTime: Date? = nil

    // Suppress the keyUp that immediately follows a double-tap promotion to hands-free
    private var suppressNextKeyUp: Bool = false
    
    // UI generation token captured at show-time to guard against stale hides
    private var lastShownUIGenerationToken: UInt64? = nil
    
    // After promoting to hands-free, ignore stray additional downs for a short window
    private var handsFreeDebounceUntil: Date? = nil

    init(recordingEngine: RecordingEngine) {
        self.recordingEngine = recordingEngine
        
        // PHASE 1.2: Initialize state machine for testing
        if UserDefaults.standard.bool(forKey: "EnableRecorderStateMachine") {
            self.recorderStateMachine = RecorderStateMachine()
            if let stateMachine = recorderStateMachine {
                let executor = RecorderCommandExecutor(recordingEngine: recordingEngine)
                Task {
                    await executor.setStateMachine(stateMachine)
                }
                self.commandExecutor = executor
            }
            self.useStateMachine = true
            logger.info("🎯 [GATE] State machine enabled for testing")
        }
    }

    func reset() {
        generation += 1
        keyIsDown = false
        started = false
        handsFreeLocked = false
        suppressNextKeyUp = false
        handsFreeDebounceUntil = nil
        // Preserve lastDownAt so a rapid second tap can be recognized as a double-tap
        probationTask?.cancel()
        probationTask = nil
    }

    func onKeyDown() async {
        if !keyIsDown { logger.debug("🚀 [GATE SESSION START] ═══ F5 KeyDown Event ═══") }
        
        // PHASE 1.2: Route to state machine if enabled
        if useStateMachine, let stateMachine = recorderStateMachine, let executor = commandExecutor {
            // Strict level-triggered behavior: only send one keyDown while the key is physically held.
            if keyIsDown { return }
            keyIsDown = true
            lastDownAt = Date()
            logger.debug("🎯 [GATE] Routing keyDown to RecorderStateMachine")
            let commands = await stateMachine.send(.keyDown)
            await executor.execute(commands)
            return
        }
        
        // LEGACY FALLBACK (enabled when FSM flag is OFF):
        // Full PTT behavior with 300–400ms promotion window and tap-and-go mis‑touch handling.
        // 1) First down: show lightweight UI and schedule promotion
        // 2) Hold ≥ promotionWindow: promote to PTT (start recording)
        // 3) Release before promotion: quick-hide with sound (tap-and-go)
        // 4) Release after promotion: stop recording
        
        // Short-circuit if we are actively stopping/starting
        if isInPromotionCooldown() { return }
        
        let now = Date()
        // Track down time for optional double-tap logic (kept here for future use)
        let doubleTapWindow: TimeInterval = 0.40
        let isDoubleTap: Bool = {
            if let last = lastDownAt { return now.timeIntervalSince(last) <= doubleTapWindow }
            return false
        }()
        lastDownAt = now
        
        // If already locked in hands‑free (from dedicated shortcut), pressing dictation acts as STOP
        if let ws = recordingEngine, await ws.isRecording, await ws.isHandsFreeLocked {
            logger.debug("🔒 [GATE-LEGACY] HF locked; keyDown → stop")
            SoundManager.shared.playKeyUp()
            await setHandsFreeBadge(false)
            started = false
            handsFreeLocked = false
            await stopFullRecording()
            setCooldown()
            return
        }

        if !keyIsDown && !started {
            keyIsDown = true
            await showLightweightUI()           // plays keyDown sound
            schedulePTTPromotion()              // promote after ~0.3s
        }
    }

    func onKeyUp() async {
        logger.debug("🏁 [GATE SESSION END] ═══ F5 KeyUp Event ═══")
        
        // PHASE 1.2: Route to state machine if enabled
        if useStateMachine, let stateMachine = recorderStateMachine, let executor = commandExecutor {
            logger.debug("🎯 [GATE] Routing keyUp to RecorderStateMachine")
            // Reset physical state before forwarding to FSM
            keyIsDown = false
            let commands = await stateMachine.send(.keyUp)
            await executor.execute(commands)
            // Failsafe: if promotion races and we are still streaming after a short grace, force-stop
            await failsafeStopAfterRelease()
            return
        }
        
        // LEGACY FALLBACK (enabled when FSM flag is OFF):
        keyIsDown = false
        if started {
            logger.debug("🎚️ [GATE-LEGACY] keyUp → stop PTT")
            started = false
            await stopFullRecording()
            setCooldown()
        } else {
            logger.debug("👆 [GATE-LEGACY] keyUp before promotion → quick-hide (mis-touch)")
            // Cancel any pending promotion to avoid races
            probationTask?.cancel()
            _ = await quickHideMisTouch()   // plays keyUp sound
        }
        // Failsafe for legacy path as well
        await failsafeStopAfterRelease()
    }

    // MARK: - Private helpers
    
    /// Failsafe: after a short grace window for FSM/preview teardown,
    /// if streaming is still active and we're not in hands-free lock, force-stop recording.
    ///
    /// IMPORTANT: Do not fire while the stop → finalize → (optional AI) → paste pipeline
    /// is running; when that pipeline is active, the recorder should stay visible and
    /// dismiss only after paste completes.
    private func failsafeStopAfterRelease() async {
        guard let ws = recordingEngine else { return }
        // Give the normal pipeline time to run first
        try? await Task.sleep(nanoseconds: 300_000_000) // ~300ms
        // Read states on main for consistency
        let stillRecording = await MainActor.run { ws.isRecording }
        let isHF = await MainActor.run { ws.isHandsFreeLocked }
        let isProcessing = await MainActor.run { ws.isProcessing || ws.isTranscribing }
        // Consider both streaming engines (query on main actor for isolation safety)
        let streamingActive = await MainActor.run { ws.sonioxStreamingService.isStreaming }
        // Only force stop if: key is no longer down, not hands-free, NOT processing,
        // and either UI thinks recording or a stream remains open
        if !keyIsDown && !isHF && !isProcessing && (stillRecording || streamingActive) {
            Logger(subsystem: "com.jetsonai.clio", category: "InputGate").warning("🧯 [GATE FAILSAFE] keyUp completed but stream still active — forcing stop (cancelImmediate)")
            // Use immediate cancel path to avoid accidental re-starts caused by toggle races
            await MainActor.run { Task { await ws.handleIntent(.cancelImmediate) } }
        }
    }

    private func schedulePTTPromotion() {
        let myGen = generation
        probationTask?.cancel()
        probationTask = Task { [weak self] in
            guard let self = self else { return }
            do { try await Task.sleep(nanoseconds: UInt64(promotionWindow * 1_000_000_000)) } catch { return }
            await self.promoteToPTTIfStillEligible(generation: myGen)
        }
    }

    private func promoteToPTTIfStillEligible(generation: UInt64) async {
        guard generation == self.generation else { return }
        guard keyIsDown, !started else { return }
        started = true
        handsFreeLocked = false
        // Ensure UI badge reflects PTT (no lock)
        await setHandsFreeBadge(false)
        await startFullRecording()
        logger.debug("🎚️ [GATE] Promoted to PTT after hold")
    }

    private func showLightweightUI() async {
        guard let ws = recordingEngine else { return }
        await MainActor.run { Task { await ws.handleIntent(.showLightweight) } }
        // Tracking for mis-touch logic only
        self.lastShownUIGenerationToken = nil
        lastUIShowTime = Date()
        SoundManager.shared.playKeyDown()
        logger.debug("📱 [GATE] Full UI shown (heavy work deferred until promotion)")
    }

    private func quickHideMisTouch() async -> Bool {
        guard let ws = recordingEngine else { return false }
        // Ensure the notch had time to fully open before we hide
        if let shownAt = lastUIShowTime {
            let elapsed = Date().timeIntervalSince(shownAt)
            let remaining = minimumVisibleWindow - elapsed
            if remaining > 0 {
                do { try await Task.sleep(nanoseconds: UInt64(remaining * 1_000_000_000)) } catch { /* ignore */ }
            }
        }
        // RECHECK: If we were promoted to PTT or hands-free during the delay, do NOT hide
        if started || handsFreeLocked {
            logger.debug("🛑 [GATE] Abort mis-touch hide: recording started or hands-free locked")
            return false
        }
        // Delegate to centralized state machine
        await MainActor.run { Task { await ws.handleIntent(.idle) } }
        self.lastShownUIGenerationToken = nil
        lastUIShowTime = nil
        SoundManager.shared.playKeyUp()
        return true
    }

    private func startFullRecording() async {
        if let ws = recordingEngine {
            await MainActor.run { Task { await ws.handleIntent(.startPTT) } }
        }
    }

    private func stopFullRecording() async {
        await setHandsFreeBadge(false)
        if let ws = recordingEngine {
            await MainActor.run { Task { await ws.handleIntent(.stop) } }
        }
    }

    private func setHandsFreeBadge(_ locked: Bool) async {
        await MainActor.run { [weak recordingEngine] in
            recordingEngine?.isHandsFreeLocked = locked
        }
    }

    private func isInCooldown() -> Bool {
        if let until = cooldownUntil { return Date() < until }
        return false
    }

    private func isInPromotionCooldown() -> Bool {
        if let until = promotionCooldownUntil { return Date() < until }
        return false
    }

    private func setCooldown() {
        cooldownUntil = Date().addingTimeInterval(cooldownInterval)
    }

    private func setPromotionCooldown(_ duration: TimeInterval? = nil) {
        let d = duration ?? promotionCooldownInterval
        promotionCooldownUntil = Date().addingTimeInterval(d)
    }
    
    // MARK: - State Machine Integration Accessors
    
    func getRecorderStateMachine() -> RecorderStateMachine? {
        return recorderStateMachine
    }
    
    func getCommandExecutor() -> RecorderCommandExecutor? {
        return commandExecutor
    }
}
