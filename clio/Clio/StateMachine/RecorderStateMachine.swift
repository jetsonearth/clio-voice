import Foundation
import SwiftUI
import os

// MARK: - Clock Protocol for Testing
protocol ClockProtocol {
    func now() -> Date
    func sleep(for duration: TimeInterval) async throws
}

struct SystemClock: ClockProtocol {
    func now() -> Date {
        return Date()
    }
    
    func sleep(for duration: TimeInterval) async throws {
        try await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
    }
}

// MARK: - State Machine Types

/// Represents the current state of the F5 key recording interaction
enum RecorderState: Equatable {
    case idle
    case lightweightShown(since: Date)
    case pttActive(since: Date)
    case handsFreeLocked(since: Date)
    case stopping
    
    var isRecording: Bool {
        switch self {
        case .pttActive, .handsFreeLocked:
            return true
        case .idle, .lightweightShown, .stopping:
            return false
        }
    }
    
    var isHandsFreeLocked: Bool {
        switch self {
        case .handsFreeLocked:
            return true
        case .idle, .lightweightShown, .pttActive, .stopping:
            return false
        }
    }
    
    var isUIVisible: Bool {
        switch self {
        case .idle:
            return false
        case .lightweightShown, .pttActive, .handsFreeLocked, .stopping:
            return true
        }
    }
}

/// Events that can trigger state transitions
enum RecorderEvent: Equatable {
    case keyDown
    case keyUp
    case promotionTimeout
    case recordingComplete
    case audioLevelExceeded
    case userCancelled
    case misTouchTimeout
}

/// Commands to execute after state transitions (side effects)
enum RecorderCommand: Equatable {
    case showLightweightUI
    case startRecording(mode: RecorderMode)
    case stopRecording
    case hideUI
    case playSound(SoundType)
    case playSoundDelayed(SoundType, delay: TimeInterval)
    case markCancelled
    case updateUI(RecorderViewModel)
    case schedulePromotion(delay: TimeInterval)
    case scheduleMisTouchHide(delay: TimeInterval)
    case cancelTimers
    case clearCooldowns // PHASE 2: Clear all cooldown timers
}

enum RecorderMode: Equatable {
    case ptt
    case handsFreeLocked
}

enum SoundType: Equatable {
    case keyDown
    case keyUp
    case lock
    case cancel
}

/// Consolidated view model to replace 30+ @Published properties
struct RecorderViewModel: Equatable {
    let isRecording: Bool
    let isHandsFreeLocked: Bool
    let isAttemptingToRecord: Bool
    let isVisualizerActive: Bool
    let sessionStateDescription: String
    let canTranscribe: Bool
    
    static let idle = RecorderViewModel(
        isRecording: false,
        isHandsFreeLocked: false,
        isAttemptingToRecord: false,
        isVisualizerActive: false,
        sessionStateDescription: "idle",
        canTranscribe: true
    )
}

// MARK: - State Machine Actor

actor RecorderStateMachine {
    private let logger = Logger(subsystem: "com.jetsonai.clio", category: "RecorderStateMachine")
    private let clock: ClockProtocol
    
    // Core state
    private var currentState: RecorderState = .idle
    private var lastKeyDown: Date?
    
    // Timing constants
    // Match notch open animation (400ms) so promotion aligns with UI by default.
    // When PTTImmediateHold is enabled, make promotion and mis-touch hide effectively immediate.
    private var promotionWindow: TimeInterval { UserDefaults.standard.bool(forKey: "PTTImmediateHold") ? 0.0 : 0.4 }
    private let doubleTapWindow: TimeInterval = 0.4
    private var minimumVisibleWindow: TimeInterval { UserDefaults.standard.bool(forKey: "PTTImmediateHold") ? 0.0 : 0.4 }
    private let keyDownSoundDelay: TimeInterval = 0.06
    
    // PHASE 2: Additional timing constants migrated from InputGate
    private let cooldownInterval: TimeInterval = 0.28 // Ignore stray events during teardown
    private let promotionCooldownInterval: TimeInterval = 0.15 // Ignore inputs after promotion
    private let handsFreeDebounceInterval: TimeInterval = 0.6 // Ignore stray downs after hands-free promotion
    
    // Active timers (simplified - in practice would use Task references)
    private var promotionTask: Task<Void, Never>?
    private var misTouchTask: Task<Void, Never>?
    
    // PHASE 2: Cooldown state tracking
    private var cooldownUntil: Date?
    private var promotionCooldownUntil: Date?
    private var handsFreeDebounceUntil: Date?
    
    init(clock: ClockProtocol = SystemClock()) {
        self.clock = clock
    }
    
    // MARK: - Public Interface
    
    /// Send an event to the state machine and get commands to execute
    func send(_ event: RecorderEvent) async -> [RecorderCommand] {
        // logger.debug("🎯 [STATE MACHINE] Event: \(String(describing: event)) in state: \(String(describing: self.currentState))")
        
        let commands = await handle(event)
        
        // PHASE 2: Execute internal commands that affect state machine state
        for command in commands {
            if case .clearCooldowns = command {
                clearAllCooldowns()
                // logger.debug("🎯 [STATE MACHINE] Cleared all cooldowns")
            }
        }
        
        // logger.debug("🎯 [STATE MACHINE] Commands: \(commands.map { String(describing: $0) })")
        
        return commands
    }
    
    /// Get current state for debugging/testing
    func getCurrentState() async -> RecorderState {
        return currentState
    }
    
    /// Get current view model
    func getViewModel() async -> RecorderViewModel {
        return createViewModel()
    }
    
    // MARK: - State Transition Logic
    
    private func handle(_ event: RecorderEvent) async -> [RecorderCommand] {
        let now = clock.now()
        var commands: [RecorderCommand] = []
        
        // PHASE 2: Apply cooldown checks (except for cancellation events)
        if event != .userCancelled && event != .recordingComplete {
            // General cooldown check
            if isInCooldown() {
                // logger.debug("🎯 [STATE MACHINE] Ignoring \(String(describing: event)) during cooldown")
                return []
            }
            
            // Promotion cooldown check for new key events
            if (event == .keyDown || event == .keyUp) && isInPromotionCooldown() {
                // logger.debug("🎯 [STATE MACHINE] Ignoring \(String(describing: event)) during promotion cooldown")
                return []
            }
            
            // Hands-free debounce check for keyDown events
            if event == .keyDown && isInHandsFreeDebounce() {
                // logger.debug("🎯 [STATE MACHINE] Ignoring keyDown during hands-free debounce")
                return []
            }
        }
        
        switch (currentState, event) {
        
        // IDLE STATE
        case (.idle, .keyDown):
            // Detect double-tap from idle (down-up-down within window)
            if let lastDown = lastKeyDown, now.timeIntervalSince(lastDown) <= doubleTapWindow {
                // Promote directly to hands-free
                currentState = .handsFreeLocked(since: now)
                setPromotionCooldown()
                setHandsFreeDebounce()
                lastKeyDown = now
                commands = [
                    .cancelTimers,
                    .startRecording(mode: .handsFreeLocked),
                    .playSound(.lock),
                    .updateUI(createViewModel())
                ]
            } else {
                // First key down - show lightweight UI and schedule promotion
                lastKeyDown = now
                currentState = .lightweightShown(since: now)
                commands = [
                    .showLightweightUI,
                    .playSoundDelayed(.keyDown, delay: keyDownSoundDelay),
                    .schedulePromotion(delay: promotionWindow),
                    .updateUI(createViewModel())
                ]
            }
            
        // LIGHTWEIGHT SHOWN STATE
        case (.lightweightShown(_), .keyDown):
            // Check for double-tap
            if let lastDown = lastKeyDown,
               now.timeIntervalSince(lastDown) <= doubleTapWindow {
                // Double-tap detected - enter hands-free mode
                currentState = .handsFreeLocked(since: now)
                // PHASE 2: Set cooldowns for hands-free promotion
                setPromotionCooldown()
                setHandsFreeDebounce()
                commands = [
                    .cancelTimers,
                    .startRecording(mode: .handsFreeLocked),
                    .playSound(.lock),
                    .updateUI(createViewModel())
                ]
            } else {
                // Update last key down for potential future double-tap
                lastKeyDown = now
            }
            
        case (.lightweightShown(let since), .keyUp):
            // Key released before promotion → treat as mis-touch. Transition to idle immediately
            // and schedule hide after ensuring the UI was visible for at least the minimum window.
            currentState = .idle
            let elapsed = now.timeIntervalSince(since)
            let remaining = max(0, minimumVisibleWindow - elapsed)
            commands = [
                .cancelTimers,
                .playSound(.keyUp),
                .scheduleMisTouchHide(delay: remaining),
                .updateUI(createViewModel())
            ]
            
        case (.lightweightShown, .promotionTimeout):
            // Promote to PTT after hold time
            currentState = .pttActive(since: clock.now())
            commands = [
                .startRecording(mode: .ptt),
                .updateUI(createViewModel())
            ]
            
        case (.lightweightShown, .misTouchTimeout):
            // Ignore mis-touch timeouts while still holding; hide is scheduled on keyUp-before-promotion
            commands = []
            
        // PTT ACTIVE STATE
        case (.pttActive, .keyDown):
            // Ignore extra keyDown events while holding in PTT to avoid accidental lock
            commands = []
            
        case (.pttActive, .keyUp):
            // PTT release - stop recording
            currentState = .stopping
            // PHASE 2: Set cooldown when stopping recording
            setCooldown()
            commands = [
                .playSound(.keyUp),
                .stopRecording,
                .updateUI(createViewModel())
            ]
            
        case (.pttActive, .misTouchTimeout):
            // Ignore mis-touch timeouts while actively recording
            commands = []
            
        // HANDS-FREE LOCKED STATE
        case (.handsFreeLocked, .keyDown):
            // Key press while hands-free - stop recording
            currentState = .stopping
            // PHASE 2: Set cooldown when stopping hands-free recording
            setCooldown()
            commands = [
                .playSound(.keyUp),
                .stopRecording,
                .updateUI(createViewModel())
            ]
            
        case (.handsFreeLocked, .misTouchTimeout):
            // Ignore mis-touch timeouts while in hands-free mode
            commands = []
            
        case (.handsFreeLocked, .keyUp):
            // Key release while hands-free - ignore (hands-free continues until keyDown)
            commands = []
            
        // STOPPING STATE
        case (.stopping, .recordingComplete):
            // Recording finished - return to idle (no-op if we already hid on cancel)
            currentState = .idle
            commands = [
                .hideUI,
                .updateUI(createViewModel())
            ]
            
        case (.stopping, .keyDown), (.stopping, .keyUp), (.stopping, .misTouchTimeout), (.stopping, .promotionTimeout):
            // Ignore all input while stopping
            commands = []
            
        // CANCEL EVENTS (context-aware)
        case (.pttActive, .userCancelled), (.handsFreeLocked, .userCancelled):
            // Immediate cancel semantics: play cancel, mark cancelled, stop mic, and hide right away
            currentState = .idle
            setCooldown()
            commands = [
                .cancelTimers,
                .clearCooldowns,
                .playSound(.cancel),
                .markCancelled,
                .stopRecording,
                .hideUI,
                .updateUI(createViewModel())
            ]
        
        case (.lightweightShown, .userCancelled):
            // If UI is shown but not recording, cancel and hide immediately
            currentState = .idle
            commands = [
                .cancelTimers,
                .clearCooldowns,
                .hideUI,
                .updateUI(createViewModel())
            ]
        
        case (.stopping, .userCancelled):
            // If user cancels while stopping, ensure we hide immediately and mark cancelled
            currentState = .idle
            commands = [
                .cancelTimers,
                .playSound(.cancel),
                .markCancelled,
                .hideUI,
                .updateUI(createViewModel())
            ]
        
        case (.idle, .userCancelled):
            // Nothing to stop; ensure UI is hidden
            commands = [
                .cancelTimers,
                .clearCooldowns,
                .hideUI,
                .playSound(.cancel),
                .updateUI(createViewModel())
            ]
            
        // Handle delayed mis-touch hide even if already marked idle
        case (.idle, .misTouchTimeout):
            commands = [
                .hideUI,
                .updateUI(createViewModel())
            ]

        case (.idle, .promotionTimeout):
            // Ignore stray promotion timeouts in idle (timer should have been cancelled)
            commands = []

        case (.idle, .recordingComplete):
            // Ignore late completion after an immediate cancel
            commands = []

        // UNHANDLED COMBINATIONS
        default:
             logger.warning("🎯 [STATE MACHINE] Unhandled event \(String(describing: event)) in state \(String(describing: self.currentState))")
        }
        
        return commands
    }
    
    // MARK: - Cooldown Management (PHASE 2)
    
    private func isInCooldown() -> Bool {
        if let until = cooldownUntil { return clock.now() < until }
        return false
    }
    
    private func isInPromotionCooldown() -> Bool {
        if let until = promotionCooldownUntil { return clock.now() < until }
        return false
    }
    
    private func isInHandsFreeDebounce() -> Bool {
        if let until = handsFreeDebounceUntil { return clock.now() < until }
        return false
    }
    
    private func setCooldown() {
        cooldownUntil = clock.now().addingTimeInterval(cooldownInterval)
    }
    
    private func setPromotionCooldown() {
        promotionCooldownUntil = clock.now().addingTimeInterval(promotionCooldownInterval)
    }
    
    private func setHandsFreeDebounce() {
        handsFreeDebounceUntil = clock.now().addingTimeInterval(handsFreeDebounceInterval)
    }
    
    private func clearAllCooldowns() {
        cooldownUntil = nil
        promotionCooldownUntil = nil
        handsFreeDebounceUntil = nil
    }
    
    // MARK: - Helper Methods
    
    private func createViewModel() -> RecorderViewModel {
        switch currentState {
        case .idle:
            return RecorderViewModel(
                isRecording: false,
                isHandsFreeLocked: false,
                isAttemptingToRecord: false,
                isVisualizerActive: false,
                sessionStateDescription: "idle",
                canTranscribe: true
            )
            
        case .lightweightShown:
            return RecorderViewModel(
                isRecording: false,
                isHandsFreeLocked: false,
                isAttemptingToRecord: true,
                isVisualizerActive: true,
                sessionStateDescription: "showing lightweight",
                canTranscribe: true
            )
            
        case .pttActive:
            return RecorderViewModel(
                isRecording: true,
                isHandsFreeLocked: false,
                isAttemptingToRecord: false,
                isVisualizerActive: true,
                sessionStateDescription: "recording PTT",
                canTranscribe: true
            )
            
        case .handsFreeLocked:
            return RecorderViewModel(
                isRecording: true,
                isHandsFreeLocked: true,
                isAttemptingToRecord: false,
                isVisualizerActive: true,
                sessionStateDescription: "recording hands-free",
                canTranscribe: true
            )
            
        case .stopping:
            return RecorderViewModel(
                isRecording: false,
                isHandsFreeLocked: false,
                isAttemptingToRecord: false,
                isVisualizerActive: true,
                sessionStateDescription: "stopping",
                canTranscribe: true
            )
        }
    }
}
