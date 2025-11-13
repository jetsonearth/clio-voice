import Foundation
import KeyboardShortcuts
import Carbon
import AppKit

// Normalize Fn (Function) key codes across different keyboard implementations.
private let fnAlternateKeyCodes: Set<UInt16> = [179, 244]

private func normalizeFnKeyCode(_ keyCode: UInt16) -> UInt16 {
    return fnAlternateKeyCodes.contains(keyCode) ? 63 : keyCode
}

private func isFnKeyCode(_ keyCode: UInt16) -> Bool {
    return keyCode == 63 || fnAlternateKeyCodes.contains(keyCode)
}

private func anyFnKeyDown() -> Bool {
    let codes: [UInt16] = [63] + Array(fnAlternateKeyCodes)
    return codes.contains { CGEventSource.keyState(.combinedSessionState, key: CGKeyCode($0)) }
}

extension KeyboardShortcuts.Shortcut {
    /// Render a user-facing description consistent with custom shortcut formatting.
    func clioDescription() -> String {
        let customRepresentation = CustomShortcut(
            keys: key.map { [UInt16($0.rawValue)] } ?? [],
            modifiers: modifiers.rawValue,
            keyCode: nil,
            modifierKeyCodes: nil
        )
        return customRepresentation.description
    }
}

extension KeyboardShortcuts.Name {
    static let toggleMiniRecorder = Self("toggleMiniRecorder")
    static let escapeRecorder = Self("escapeRecorder")
    static let toggleEnhancement = Self("toggleEnhancement")
}

// Custom shortcut storage for keys that KeyboardShortcuts library can't handle
struct CustomShortcut: Codable {
    let keys: [UInt16]
    let modifiers: UInt
    let keyCode: UInt16? // For modifier-only shortcuts
    let modifierKeyCodes: [UInt16]? // Track physical modifiers for multi-mod combos

    var description: String {
        let modFlags = NSEvent.ModifierFlags(rawValue: modifiers)
        var components: [String] = []

        // Add modifiers with side information when available
        var matchedFlags = NSEvent.ModifierFlags()
        let normalizedModifierKeyCodes = ((modifierKeyCodes?.isEmpty == false ? modifierKeyCodes : nil) ?? (keyCode.map { [$0] }) ?? []).map(normalizeFnKeyCode)

        if !normalizedModifierKeyCodes.isEmpty {
            let detailedComponents = normalizedModifierKeyCodes.compactMap { code -> (text: String, flag: NSEvent.ModifierFlags)? in
                switch code {
                case 63: return ("Fn", .function)
                case 54: return ("Right ⌘", .command)
                case 55: return ("Left ⌘", .command)
                case 61: return ("Right ⌥", .option)
                case 58: return ("Left ⌥", .option)
                case 62, 59: return ("Control ⌃", .control)
                case 60: return ("Right ⇧", .shift)
                case 56: return ("Left ⇧", .shift)
                default:
                    return nil
                }
            }
            let ordered = detailedComponents.sorted { lhs, rhs in
                modifierDisplayOrder(for: lhs.flag) < modifierDisplayOrder(for: rhs.flag)
            }
            var usedLabels = Set<String>()
            ordered.forEach { element in
                matchedFlags.insert(element.flag)
                if usedLabels.insert(element.text).inserted {
                    components.append(element.text)
                }
            }
        }

        // Append any remaining modifiers (no side-specific data available)
        let remainingFlags = modFlags.subtracting(matchedFlags)
        if remainingFlags.contains(.function) && !components.contains("Fn") {
            components.append("Fn")
        }
        if remainingFlags.contains(.control) {
            components.append("⌃")
        }
        if remainingFlags.contains(.option) {
            components.append("⌥")
        }
        if remainingFlags.contains(.shift) {
            components.append("⇧")
        }
        if remainingFlags.contains(.command) {
            components.append("⌘")
        }

        // Add regular keys
        if !keys.isEmpty {
            let keyNames = keys.map { keyDisplayName($0) }
            components.append(contentsOf: keyNames)
        }

        return components.joined(separator: " + ")
    }

    private func modifierDisplayOrder(for flag: NSEvent.ModifierFlags) -> Int {
        switch flag {
        case .function: return 0
        case .control: return 1
        case .option: return 2
        case .shift: return 3
        case .command: return 4
        default: return 5
        }
    }

    private func keyDisplayName(_ keyCode: UInt16) -> String {
        switch keyCode {
        case 53: return "Escape"
        case 36: return "Return"
        case 48: return "Tab"
        case 49: return "Space"
        case 122: return "F1"
        case 120: return "F2"
        case 99: return "F3"
        case 118: return "F4"
        case 96: return "F5"
        case 97: return "F6"
        case 98: return "F7"
        case 100: return "F8"
        case 101: return "F9"
        case 109: return "F10"
        case 103: return "F11"
        case 111: return "F12"
        case 179, 244: return "Fn"
        case 54: return "Right Command"
        case 55: return "Left Command"
        case 61: return "Right Option"
        case 58: return "Left Option"
        case 62: return "Right Control"
        case 59, 62: return "Control"
        case 60: return "Right Shift"
        case 56: return "Left Shift"
        case 63: return "Fn"
        default: return "Key \(keyCode)"
        }
    }
}

@MainActor
class HotkeyManager: ObservableObject {
    // Input gate for 300ms promotion and generation gating
    private var inputGate: InputGate?
    @Published var isListening = false
    @Published var isShortcutConfigured = false
    @Published var showHotkeyConflict = false
    @Published var lastHotkeyRegisterStatus: OSStatus = noErr
    @Published var isHotkeyReady: Bool = false

    // Only true while the explicit Settings capture modal is active
    @Published var inCaptureSession: Bool = false
    private var suppressCustomShortcutWrite: Bool = false
    private var allowCustomShortcutMutation: Bool = false

    @Published var isPushToTalkEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isPushToTalkEnabled, forKey: "isPushToTalkEnabled")
            resetKeyStates()
            setupKeyMonitor()
        }
    }
    @Published var pushToTalkKey: PushToTalkKey {
        didSet {
            UserDefaults.standard.set(pushToTalkKey.rawValue, forKey: "pushToTalkKey")
            resetKeyStates()
        }
    }
    
    // Custom shortcut storage
    @Published var customShortcut: CustomShortcut? {
        didSet {
            // Block incidental writes unless we are in an explicit capture session
            // Allow programmatic loads during initialization to pass through
            let allowProgrammaticWrite = allowCustomShortcutMutation || inCaptureSession || isLoadingShortcuts
            if !allowProgrammaticWrite && oldValue?.description != customShortcut?.description {
                print("🛑 [SHORTCUT DEBUG] Ignoring incidental customShortcut write while not in capture session → \(customShortcut?.description ?? "nil")")
                if !suppressCustomShortcutWrite {
                    suppressCustomShortcutWrite = true
                    customShortcut = oldValue
                    suppressCustomShortcutWrite = false
                }
                return
            }
            if let shortcut = customShortcut {
                // If user explicitly set a custom shortcut during capture, clear sticky library F5
                if inCaptureSession || allowCustomShortcutMutation { stickyLibraryShortcut = nil }
                if let data = try? JSONEncoder().encode(shortcut) {
                    UserDefaults.standard.set(data, forKey: "customShortcut")
                }
            } else {
                UserDefaults.standard.removeObject(forKey: "customShortcut")
            }
        }
    }
    
    // Dedicated hands-free toggle shortcut (press once to start, press again to stop)
    @Published var handsFreeShortcut: CustomShortcut? {
        didSet {
            if let shortcut = handsFreeShortcut, let data = try? JSONEncoder().encode(shortcut) {
                UserDefaults.standard.set(data, forKey: "handsFreeShortcut")
            } else {
                UserDefaults.standard.removeObject(forKey: "handsFreeShortcut")
            }
            // Avoid installing global/local monitors before activation/setup finishes.
            // The full monitor setup will be invoked from performInitialSetupIfNeeded().
            if didPerformInitialSetup && NSApp.isActive {
                setupHandsFreeShortcutMonitor()
                // Arm or disarm F5 override if hands‑free uses plain F5
                updateF5OverrideArming(reason: "handsFreeChanged")
            }
        }
    }
    
    // Assistant Command Mode shortcut (holds to speak instruction)
    @Published var assistantShortcut: CustomShortcut? {
        didSet {
            if let shortcut = assistantShortcut, let data = try? JSONEncoder().encode(shortcut) {
                UserDefaults.standard.set(data, forKey: "assistantShortcut")
                isAssistantShortcutDisabled = false
            } else {
                UserDefaults.standard.removeObject(forKey: "assistantShortcut")
            }
            if didPerformInitialSetup && NSApp.isActive {
                setupAssistantShortcutMonitor()
            }
        }
    }
    
    
    private var recordingEngine: RecordingEngine
    private let disabled: Bool
    private let minimalMode: Bool
    private let enablePushToTalk: Bool
    private let enableCustomShortcut: Bool
    private let enableDebugMonitors: Bool
    private let enableDelayedReregistration: Bool
    private var currentKeyState = false
    private var visibilityTask: Task<Void, Never>?
    private var appLaunchTime: Date?
    private var didPerformInitialSetup = false
    private var activationObserver: Any?
    private var resignObserver: Any?
    
    // Change from single monitor to separate local and global monitors
    private var globalEventMonitor: Any?
    private var localEventMonitor: Any?
    
    // Custom shortcut monitors
    private var customShortcutGlobalMonitor: Any?
    private var customShortcutLocalMonitor: Any?
    private var customModifierPressed: Bool = false
    // Bypass incidental-write guard while loading from storage on init
    private var isLoadingShortcuts: Bool = false
    
    // Debug monitors for testing if system receives key events
    private var debugGlobalMonitor: Any?
    private var debugLocalMonitor: Any?
    private var enableSecondaryCommandMonitor: Bool = true
    private var lastRightCommandDown: Bool = false
    private let assistantShortcutDisabledKey = "assistantShortcutDisabled"

    private var isAssistantShortcutDisabled: Bool {
        get { UserDefaults.standard.bool(forKey: assistantShortcutDisabledKey) }
        set { UserDefaults.standard.set(newValue, forKey: assistantShortcutDisabledKey) }
    }
    
    // Hotkey readiness watchdog
    private var hotkeyWatchdogTask: Task<Void, Never>? = nil
    private var lastObservedToggleEventAt: Date? = nil
    private var hotkeyWatchdogAttempts: Int = 0
    private var hotkeyWatchdogEnabled: Bool = true // set false to silence in release if desired
    
    // Key handling properties (modifier PTT)
    private var keyPressStartTime: Date?
    private let briefPressThreshold = 1.0 // 1 second threshold for brief press
    private var isHandsFreeMode = false   // Track if we're in hands-free recording mode

    // Dictation hotkey PTT + double-tap hands-free
    private var dictationPTTActive = false
    @Published var isHandsFreeLocked = false
    private var lastDictationKeyDownAt: Date?
    private let doubleTapWindow: TimeInterval = 0.3

    // Add cooldown management
    private var lastShortcutTriggerTime: Date?
    private let shortcutCooldownInterval: TimeInterval = 0.7 // increase to 700ms to avoid accidental double toggles
    
    private var fnDebounceTask: Task<Void, Never>?
    private var pendingFnKeyState: Bool? = nil

    // Global F-key interception (optional) to defeat macOS Dictation while using F-keys
    private var fkeyEventTap: CFMachPort?
    private var fkeyEventTapSource: CFRunLoopSource?
    private var interceptedFunctionKeyCode: UInt16? // 96..111 normalized when active
    private var globalHotKey: GlobalHotKey?
    private var hidRemapper = HIDKeyRemapper()
    private var f5RuntimeRemapper = F5ToF16Remapper()
    private var launchAgent = LaunchAgentInstaller()
private var f5DeferredStartTask: Task<Void, Never>?
    private var stickyLibraryShortcut: KeyboardShortcuts.Shortcut?
    
    // Debounce and atomic effective shortcut application
private var updateDebounceTask: Task<Void, Never>?
    private var lastAppliedEffectiveDescription: String?
    private var hasAppliedEffectiveOnce: Bool = false
    
    // Track F5 remapper running state for deterministic verification
    private var isF5RemapperRunning: Bool = false
    
    enum PushToTalkKey: String, CaseIterable {
        case rightOption = "rightOption"
        case leftOption = "leftOption"
        case leftControl = "leftControl"
        case rightControl = "rightControl"
        case fn = "fn"
        case rightCommand = "rightCommand"
        case leftCommand = "leftCommand"
        case rightShift = "rightShift"
        case leftShift = "leftShift"
        
        var displayName: String {
            switch self {
        case .rightOption: return "Right Option (⌥)"
        case .leftOption: return "Left Option (⌥)"
        case .leftControl, .rightControl: return "Control (⌃)"
            case .fn: return "Fn"
            case .rightCommand: return "Right Command (⌘)"
            case .leftCommand: return "Left Command (⌘)"
            case .rightShift: return "Right Shift (⇧)"
            case .leftShift: return "Left Shift (⇧)"
            }
        }
        
        var keyCode: CGKeyCode {
            switch self {
            case .rightOption: return 0x3D  // 61
            case .leftOption: return 0x3A   // 58
        case .leftControl: return 0x3B  // 59
        case .rightControl: return 0x3E // 62
            case .fn: return 0x3F           // 63
            case .rightCommand: return 0x36 // 54
            case .leftCommand: return 0x37  // 55
            case .rightShift: return 0x3C   // 60
            case .leftShift: return 0x38    // 56
            }
        }
    }
    
    init(
        recordingEngine: RecordingEngine,
        disabled: Bool = false,
        minimalMode: Bool = true,
        enablePushToTalk: Bool = false,
        enableCustomShortcut: Bool = false,
        enableDebugMonitors: Bool = false,
        enableDelayedReregistration: Bool = false
    ) {
        self.isPushToTalkEnabled = UserDefaults.standard.bool(forKey: "isPushToTalkEnabled")
        self.disabled = disabled
        self.minimalMode = minimalMode
        self.enablePushToTalk = enablePushToTalk
        self.enableCustomShortcut = enableCustomShortcut
        self.enableDebugMonitors = enableDebugMonitors
        self.enableDelayedReregistration = enableDelayedReregistration
        
        // Initialize references used by other members early
        self.recordingEngine = recordingEngine
        self.inputGate = InputGate(recordingEngine: recordingEngine)
        self.appLaunchTime = Date()
        
        // PHASE 3: Connect state machine to RecordingEngine for consolidated state (defer to avoid self capture before init)
        let deferredInputGate = self.inputGate
        
        // Respect exactly what the user previously selected; no silent migrations
        let savedKey = PushToTalkKey(rawValue: UserDefaults.standard.string(forKey: "pushToTalkKey") ?? "") ?? .rightCommand
        self.pushToTalkKey = savedKey
        
        // Load persisted shortcuts without triggering incidental-write guard
        isLoadingShortcuts = true
        if let data = UserDefaults.standard.data(forKey: "customShortcut"),
           let savedShortcut = try? JSONDecoder().decode(CustomShortcut.self, from: data) {
            self.customShortcut = normalizedShortcut(savedShortcut)
        } else {
            self.customShortcut = nil
        }
        if let data = UserDefaults.standard.data(forKey: "handsFreeShortcut"),
           let savedHF = try? JSONDecoder().decode(CustomShortcut.self, from: data) {
            self.handsFreeShortcut = normalizedShortcut(savedHF)
        } else {
            self.handsFreeShortcut = nil
        }
        if let data = UserDefaults.standard.data(forKey: "assistantShortcut"),
           let savedAssistant = try? JSONDecoder().decode(CustomShortcut.self, from: data) {
            self.assistantShortcut = normalizedShortcut(savedAssistant)
        } else {
            self.assistantShortcut = nil
        }
        
        // Set default shortcuts for new users (when no shortcuts exist)
        setDefaultShortcutsIfNeeded()
        
        isLoadingShortcuts = false
        
        print("🎹 HotkeyManager initializing at \(self.appLaunchTime!)")
        print("🎹 KeyboardShortcuts library available: \(KeyboardShortcuts.Name.toggleMiniRecorder.rawValue)")
        
        // If disabled, skip setting up any monitors/handlers
        guard !disabled else { return }

        // Defer setup until the app is active to avoid activation contention and NSApp initialization timing
        activationObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.performInitialSetupIfNeeded()
        }
        resignObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            // Do not stop F5 on resignActive anymore; keeping interception avoids handing F5 to Dictation.
            // If needed, a watchdog below will handle safe re-arming on becomeActive.
            guard let _ = self else { return }
        }
        // If the app is already active (e.g., launched from Xcode), run once now; otherwise wait for didBecomeActive
        DispatchQueue.main.async { [weak self] in
            if NSApp.isActive {
                self?.performInitialSetupIfNeeded()
            } else {
                // Cold launch, app not active: perform a minimal background setup so
                // keyboard shortcut works even if the user switches focus immediately.
                self?.performBackgroundSetup()
            }
        }

        // A small delayed attempt to cover edge cases where notifications were missed
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            if NSApp.isActive {
                self?.performInitialSetupIfNeeded()
            } else {
                self?.performBackgroundSetup()
            }
        }
        
        // PHASE 3: Connect state machine to RecordingEngine after init is complete
        Task {
            if let stateMachine = await deferredInputGate?.getRecorderStateMachine() {
                await MainActor.run {
                    recordingEngine.setupRecorderStateMachine(stateMachine)
                }
            }
        }
    }

    private func performInitialSetupIfNeeded() {
        guard !didPerformInitialSetup else { return }
        didPerformInitialSetup = true
StructuredLog.shared.log(cat: .hotkey, evt: "open_config", lvl: .info, ["ready": false])

        updateShortcutStatus()
        setupEnhancementShortcut()
        setupVisibilityObserver()
        testKeyboardShortcutsLibrary()
        // Install primary shortcut handlers only after activation
        setupShortcutHandler()
        // Install dedicated monitors for hands-free and assistant command mode
        setupHandsFreeShortcutMonitor()
        setupAssistantShortcutMonitor()
        if enableDebugMonitors { setupDebugEventMonitors() }
        if enableDelayedReregistration { setupDelayedReregistration() }
StructuredLog.shared.log(cat: .hotkey, evt: "register", lvl: .info, ["ok": true])

        // Immediate arming if F5 is bound (dictation or hands-free). Works even if app is not key.
        self.updateF5OverrideArming(reason: "postActivationAutoArm", delaySeconds: 0.1)
        // Deterministic post-activation verify: after settle, ensure F5 is armed when effective
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            if self.isAnyPlainF5Assigned() && !self.isF5RemapperRunning {
                if NSApp.isActive {
                    self.updateF5OverrideArming(reason: "didBecomeActiveSettledVerify", delaySeconds: 0.0)
                } else {
                    // One-shot arming on next activation
                    NotificationCenter.default.addObserver(forName: NSApplication.didBecomeActiveNotification, object: nil, queue: .main) { [weak self] _ in
                        self?.updateF5OverrideArming(reason: "settledVerifyOnActive", delaySeconds: 0.0)
                    }
                }
            }
            // Ready only when: no F5 in use, or F5 with remapper running
            if self.isAnyPlainF5Assigned() {
                self.isHotkeyReady = self.isF5RemapperRunning
            } else {
                self.isHotkeyReady = true
            }
            print("✅ [HOTKEY READY] effective=\(self.getCurrentShortcutDescription() ?? "none"), F5Armed=\(self.isF5RemapperRunning)")
        }

        if let observer = activationObserver {
            NotificationCenter.default.removeObserver(observer)
            activationObserver = nil
        }
    }

    // Minimal, safe setup path when the app launches in background and never becomes
    // active immediately. Ensures hotkeys work and warmup/arming proceeds so first
    // dictation succeeds even if the user switches away right after launching.
    private func performBackgroundSetup() {
        // If we've already completed full setup, just ensure loading readiness
        if didPerformInitialSetup {
            beginHotkeyLoading()
            return
        }
        // Run the same initialization as foreground path
        performInitialSetupIfNeeded()
        // And explicitly kick the loading readiness cadence in case some
        // activation-gated verify steps are skipped while inactive
        beginHotkeyLoading()
    }
    
    private func testKeyboardShortcutsLibrary() {
        print("🧪 Testing KeyboardShortcuts library...")
        
        // Try to get current shortcut
        let currentShortcut = KeyboardShortcuts.getShortcut(for: .toggleMiniRecorder)
        print("🧪 Current shortcut from library: \(currentShortcut?.description ?? "none")")
        
        // Test library availability by checking current shortcut
        let testShortcut = KeyboardShortcuts.getShortcut(for: .toggleMiniRecorder)
        print("🧪 Current shortcut available: \(testShortcut?.description ?? "none")")
        
        print("🧪 KeyboardShortcuts library test completed")
    }
    
    private func resetKeyStates() {
        currentKeyState = false
        keyPressStartTime = nil
        isHandsFreeMode = false
        pendingFnKeyState = nil
        fnDebounceTask?.cancel()
        fnDebounceTask = nil
    }
    
    private func setupVisibilityObserver() {
        visibilityTask = Task { @MainActor in
            for await isVisible in recordingEngine.$isMiniRecorderVisible.values {
                if isVisible {
                    // Don't re-register the main hotkey handler - it should stay active
                    // setupShortcutHandler() // REMOVED - handler should be set once during init
                    setupEnhancementShortcut()
                } else {
                    removeEscapeShortcut()
                    removeEnhancementShortcut()
                }
                // Update Escape shortcut based on current recording state whenever visibility changes
                updateEscapeShortcut()
            }
        }
        
        // Separate observer for recording state so we can toggle Escape shortcut precisely
        Task { @MainActor in
            for await _ in recordingEngine.$isRecording.values {
                updateEscapeShortcut()
            }
        }
    }

    private func captureCurrentPushToTalkState() -> Bool {
        if pushToTalkKey == .fn {
            if NSEvent.modifierFlags.contains(.function) { return true }
            return anyFnKeyDown()
        }
        return CGEventSource.keyState(.combinedSessionState, key: pushToTalkKey.keyCode)
    }

    private func setupKeyMonitor() {
        removeKeyMonitor()
        
        guard enablePushToTalk, isPushToTalkEnabled else { return }
        
        // TEMPORARY: Allow push-to-talk for Right Command until KeyboardShortcuts is fixed
        // Check if push-to-talk key is Left Command (key code 55) - disable push-to-talk for this key
        // to prevent double-triggering with the main shortcut system
        if pushToTalkKey.keyCode == 55 { // Left Command only
            print("🎹 Push-to-talk disabled for Left Command to prevent conflicts with main shortcut system")
            return
        }

        let initialState = captureCurrentPushToTalkState()
        currentKeyState = initialState
        if pushToTalkKey == .fn {
            pendingFnKeyState = initialState
        }

        print("🎹 Push-to-talk ENABLED for key: \(pushToTalkKey.displayName) (keyCode: \(pushToTalkKey.keyCode))")

        // Global monitor for capturing flags when app is in background
        globalEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            guard let self = self else { return }
            
            Task { @MainActor in
                await self.handleNSKeyEvent(event)
            }
        }
        
        // Local monitor for capturing flags when app has focus
        localEventMonitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            guard let self = self else { return event }
            
            Task { @MainActor in
                await self.handleNSKeyEvent(event)
            }
            
            // Prevent modifier-only recording logic from interfering with generic shortcuts
            return event // Return the event to allow normal processing
        }
    }
    
    private func removeKeyMonitor() {
        if let monitor = globalEventMonitor {
            NSEvent.removeMonitor(monitor)
            globalEventMonitor = nil
        }

        if let monitor = localEventMonitor {
            NSEvent.removeMonitor(monitor)
            localEventMonitor = nil
        }

        pendingFnKeyState = nil
        fnDebounceTask?.cancel()
        fnDebounceTask = nil
    }
    
    private func handleNSKeyEvent(_ event: NSEvent) async {
        let rawKeyCode = UInt16(event.keyCode)
        let normalizedKeyCode = normalizeFnKeyCode(rawKeyCode)
        let flags = event.modifierFlags
        
        // Check if the target key is pressed based on the modifier flags
        var isKeyPressed = false
        var isTargetKey = false
        
        switch pushToTalkKey {
        case .rightOption, .leftOption:
            isKeyPressed = flags.contains(.option)
            isTargetKey = normalizedKeyCode == pushToTalkKey.keyCode
        case .leftControl, .rightControl:
            isKeyPressed = flags.contains(.control)
            isTargetKey = normalizedKeyCode == pushToTalkKey.keyCode
        case .fn:
            if flags.contains(.function) {
                isKeyPressed = true
            } else {
                isKeyPressed = anyFnKeyDown()
            }
            isTargetKey = normalizedKeyCode == pushToTalkKey.keyCode
            // Debounce only for Fn key
            if isTargetKey {
                pendingFnKeyState = isKeyPressed

                // Ignore synthetic events that mirror the current state
                if isKeyPressed == currentKeyState {
                    return
                }

                fnDebounceTask?.cancel()
                fnDebounceTask = Task { [pendingState = isKeyPressed] in
                    try? await Task.sleep(nanoseconds: 75_000_000) // 75ms
                    // Only act if the state hasn't changed during debounce
                    if pendingFnKeyState == pendingState {
                        await MainActor.run {
                            self.processPushToTalkKey(isKeyPressed: pendingState)
                        }
                    }
                }
                return
            }
        case .rightCommand, .leftCommand:
            isKeyPressed = flags.contains(.command)
            isTargetKey = normalizedKeyCode == pushToTalkKey.keyCode
        case .rightShift, .leftShift:
            isKeyPressed = flags.contains(.shift)
            isTargetKey = normalizedKeyCode == pushToTalkKey.keyCode
        }

        if isTargetKey && isKeyPressed == currentKeyState {
            return
        }

        guard isTargetKey else { return }
        processPushToTalkKey(isKeyPressed: isKeyPressed)
    }
    
    private func processPushToTalkKey(isKeyPressed: Bool) {
        guard isKeyPressed != currentKeyState else { return }
        currentKeyState = isKeyPressed

        // Dedicated hands-free key path (acts as a toggle, not hold)
        if isPushToTalkEnabled {
            if isKeyPressed {
                if recordingEngine.isRecording {
                    // Toggle off
                    isHandsFreeLocked = false
                    recordingEngine.isHandsFreeLocked = false
                    Task { @MainActor in await recordingEngine.handleToggleMiniRecorder() }
                } else {
                    // Toggle on with hands-free lock
                    isHandsFreeLocked = true
                    recordingEngine.isHandsFreeLocked = true
                    Task { @MainActor in await recordingEngine.handleToggleMiniRecorder() }
                }
            }
            return
        }
        
        // Legacy modifier hold path (kept for completeness, but disabled unless isPushToTalkEnabled is set)
        if isKeyPressed {
            keyPressStartTime = Date()
            
            // If we're in hands-free mode, stop recording
            if isHandsFreeMode {
                isHandsFreeMode = false
                Task { @MainActor in await recordingEngine.handleToggleMiniRecorder() }
                return
            }
            
            // Show recorder if not already visible
            if !recordingEngine.isMiniRecorderVisible {
                Task { @MainActor in await recordingEngine.handleToggleMiniRecorder() }
            }
        } else {
            let now = Date()
            
            // Calculate press duration
            if let startTime = keyPressStartTime {
                let pressDuration = now.timeIntervalSince(startTime)
                
                if pressDuration < briefPressThreshold {
                    // For brief presses, enter hands-free mode
                    isHandsFreeMode = true
                } else {
                    // For longer presses, stop and transcribe
                    Task { @MainActor in await recordingEngine.handleToggleMiniRecorder() }
                }
            }
            
            keyPressStartTime = nil
        }
    }
    
    private func setupEscapeShortcut() {
        KeyboardShortcuts.setShortcut(.init(.escape), for: .escapeRecorder)
        KeyboardShortcuts.onKeyDown(for: .escapeRecorder) { [weak self] in
            Task { @MainActor in
                guard let self = self else { return }

                // Allow ESC when recording in either mini or notch mode
                guard await self.recordingEngine.isRecording else { return }

                // Check if state machine is enabled
                if let inputGate = self.inputGate {
                    let useStateMachine = UserDefaults.standard.bool(forKey: "EnableRecorderStateMachine")
                    if useStateMachine {
                        // Route escape cancellation through state machine
                        if let stateMachine = await inputGate.getRecorderStateMachine(),
                           let executor = await inputGate.getCommandExecutor() {
                            let commands = await stateMachine.send(.userCancelled)
                            await executor.execute(commands)
                            
                            // Reset input gate and modifier tracking
                            await inputGate.reset()
                            self.customModifierPressed = false
                            return
                        }
                    }
                }
                
                // Fallback to existing logic for non-state-machine path
                // Direct cancel without confirmation
                // await self.recordingEngine.showCancelConfirmation()
                
                // Cancel recording immediately
                self.recordingEngine.isProcessing = false
                self.recordingEngine.isVisualizerActive = false
                self.recordingEngine.isRecording = false
                self.recordingEngine.shouldCancelRecording = true
                self.recordingEngine.isAttemptingToRecord = false
                
                // Dismiss and cleanup
                await self.recordingEngine.dismissRecorder()
                
                // Reset input gate and modifier tracking so subsequent presses work immediately
                await self.inputGate?.reset()
                self.customModifierPressed = false
                
                // Play cancel sound after cleanup
                SoundManager.shared.playEscSound()
            }
        }
    }
    
    private func removeEscapeShortcut() {
        KeyboardShortcuts.setShortcut(nil, for: .escapeRecorder)
    }
    
    private func setupEnhancementShortcut() {
        KeyboardShortcuts.onKeyDown(for: .toggleEnhancement) { [weak self] in
            Task { @MainActor in
                guard let self = self,
                      await self.recordingEngine.isMiniRecorderVisible,
                      let enhancementService = await self.recordingEngine.getEnhancementService() else { return }
                enhancementService.isEnhancementEnabled.toggle()
            }
        }
    }
    
    
    private func removeEnhancementShortcut() {
        KeyboardShortcuts.setShortcut(nil, for: .toggleEnhancement)
    }
    
    // Get the current effective shortcut (either from library or custom storage)
    func getCurrentShortcutDescription() -> String? {
        // Prefer explicitly-set custom shortcut over library value to reflect user intent
        if let customShortcut = customShortcut {
            return customShortcut.description
        } else if let libraryShortcut = KeyboardShortcuts.getShortcut(for: .toggleMiniRecorder) {
            return libraryShortcut.clioDescription()
        }
        return nil
    }
    
    func updateShortcutStatus() {
        // Debounce to collapse transient library reads and avoid churn
        updateDebounceTask?.cancel()
        updateDebounceTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 200_000_000)
            await self?.performShortcutReconfigure()
        }
    }
    
    private func performShortcutReconfigure() {
        let libraryShortcut = KeyboardShortcuts.getShortcut(for: .toggleMiniRecorder)
        // Remember last known library shortcut to prevent transient nil from tearing down
        if let lib = libraryShortcut { stickyLibraryShortcut = lib }
        // Prefer custom shortcut when present; only consider library (or sticky) when custom is nil
        let effectiveLibraryShortcut: KeyboardShortcuts.Shortcut? = (customShortcut == nil) ? (libraryShortcut ?? stickyLibraryShortcut) : nil
        isShortcutConfigured = (effectiveLibraryShortcut != nil) || customShortcut != nil
        
        print("🔍 [SHORTCUT DEBUG] Library shortcut: \(libraryShortcut?.description ?? "nil") (effective: \(effectiveLibraryShortcut?.description ?? "nil"))")
        print("🔍 [SHORTCUT DEBUG] Custom shortcut: \(customShortcut?.description ?? "nil")")
        print("🔍 [SHORTCUT DEBUG] Shortcut configured: \(isShortcutConfigured)")
        
        // Check if shortcut is corrupted (contains invalid characters)
        if let shortcut = libraryShortcut {
            let description = shortcut.description
            if description.contains("�") || description.isEmpty {
                print("🚨 [SHORTCUT DEBUG] Detected corrupted shortcut! Resetting...")
                print("🚨 [SHORTCUT DEBUG] Corrupted description: '\(description)' (length: \(description.count))")
                
                // NUCLEAR RESET: Try multiple approaches to clear the corruption
                print("🚨 [NUCLEAR RESET] Starting nuclear reset of KeyboardShortcuts data...")
                
                // Method 1: Clear all shortcuts completely
                KeyboardShortcuts.setShortcut(nil, for: .toggleMiniRecorder)
                KeyboardShortcuts.setShortcut(nil, for: .escapeRecorder)
                KeyboardShortcuts.setShortcut(nil, for: .toggleEnhancement)
                
                // Method 2: Try to clear UserDefaults entries that might be corrupted
                let userDefaults = UserDefaults.standard
                userDefaults.removeObject(forKey: "KeyboardShortcuts_toggleMiniRecorder")
                userDefaults.removeObject(forKey: "toggleMiniRecorder")
                userDefaults.synchronize()
                
                print("🚨 [NUCLEAR RESET] Cleared all shortcuts and UserDefaults entries")
                
                // Wait longer for complete cleanup
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 500_000_000) // 500ms
                    print("🚨 [NUCLEAR RESET] Attempting to set fresh shortcut...")
                    // Do not override user's choice permanently. If there's no valid shortcut, set a temporary safe default.
                    if KeyboardShortcuts.getShortcut(for: .toggleMiniRecorder) == nil {
                        let tempDefault = KeyboardShortcuts.Shortcut(.j, modifiers: .command)
                        KeyboardShortcuts.setShortcut(tempDefault, for: .toggleMiniRecorder)
                        print("✅ [NUCLEAR RESET] Temporarily set to ⌘J until user rebinds")
                    }
                    
                    // Multiple verification attempts
                    for attempt in 1...3 {
                        try? await Task.sleep(nanoseconds: 100_000_000) // 100ms between attempts
                        let verifyShortcut = KeyboardShortcuts.getShortcut(for: .toggleMiniRecorder)
                        print("🔍 [NUCLEAR RESET] Verification attempt \(attempt): '\(verifyShortcut?.description ?? "nil")'")
                        
                        if let shortcut = verifyShortcut, !shortcut.description.contains("�"), !shortcut.description.isEmpty {
                            print("✅ [NUCLEAR RESET] Success! Clean shortcut detected")
                            break
                        }
                    }
                    
                    // Update our local state
                    self.updateShortcutStatus()
                    
                    // Re-setup handlers after reset
                    self.setupShortcutHandler()
                    print("✅ [NUCLEAR RESET] Nuclear reset complete - handlers re-configured")
                }
                return
            }
        }
        
        // Enable secondary Right Command monitor ONLY when explicitly bound to Right Command modifier-only.
        if let sc = effectiveLibraryShortcut {
            let isModifierOnlyCommand = (sc.key == nil) && sc.modifiers == .command
            // Only enable if user chose command-only AND the last selected pushToTalkKey is .rightCommand
            enableSecondaryCommandMonitor = isModifierOnlyCommand && (pushToTalkKey == .rightCommand)
        } else {
            enableSecondaryCommandMonitor = false
        }

        // Build effective description for atomic comparison
        let effectiveDescription = effectiveLibraryShortcut?.description ?? customShortcut?.description ?? "none"
        if hasAppliedEffectiveOnce && effectiveDescription == lastAppliedEffectiveDescription {
            // No-op: effective binding did not change; skip reconfigure
            return
        }
        lastAppliedEffectiveDescription = effectiveDescription
        hasAppliedEffectiveOnce = true

        if isShortcutConfigured {
            // Handler is now set up during init, only setup key monitor here
            setupKeyMonitor()
            // Precedence: if a library shortcut exists, prefer it and skip custom monitors
            if effectiveLibraryShortcut == nil {
                setupCustomShortcutMonitor()
            } else {
                removeCustomShortcutMonitor()
            }
            setupHandsFreeShortcutMonitor()
            let description = effectiveLibraryShortcut?.description ?? customShortcut?.description ?? "unknown"
            print("✅ Keyboard shortcut configured: \(description)")

            // Configure F-key interception if needed (dictation hotkey side)
            if let eff = effectiveLibraryShortcut {
                configureFunctionKeyInterception(for: eff)
            } else {
                // When using a custom (non-library) shortcut for dictation, tear down dictation-side F-key interception.
                teardownFunctionKeyInterception()
            }
            // Independently arm F5 override for hands‑free when applicable
            updateF5OverrideArming(reason: "performShortcutReconfigure")
        } else {
            // No shortcut set. Do not force a key; just inform and keep listening state consistent.
            // If we previously had a sticky F5 binding, keep interception active to avoid
            // the OS stealing F5 due to transient nil reads.
            if stickyLibraryShortcut == nil {
                removeKeyMonitor()
                removeCustomShortcutMonitor()
                removeHandsFreeShortcutMonitor()
                print("⚠️ No keyboard shortcut configured - please set one in Settings → Shortcuts")
                teardownFunctionKeyInterception()
            } else {
                print("🧷 [SHORTCUT DEBUG] Sticky F5 in effect despite transient unconfigured state")
            }
        }
    }
    
    private func setupCustomShortcutMonitor() {
        removeCustomShortcutMonitor()
        
        guard enableCustomShortcut, let customShortcut = customShortcut else { return }
        
        print("🎹 Setting up custom shortcut monitor for: \(customShortcut.description)")
        
        // Global monitor for when app is in background
        customShortcutGlobalMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.keyDown, .flagsChanged]) { [weak self] event in
            guard let self = self else { return }
            Task { @MainActor in
                await self.handleCustomShortcutEvent(event, shortcut: customShortcut)
            }
        }
        
        // Local monitor for when app is in foreground
        customShortcutLocalMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .flagsChanged]) { [weak self] event in
            guard let self = self else { return event }
            Task { @MainActor in
                await self.handleCustomShortcutEvent(event, shortcut: customShortcut)
            }
            return event
        }
    }
    
    private func removeCustomShortcutMonitor() {
        if let monitor = customShortcutGlobalMonitor {
            NSEvent.removeMonitor(monitor)
            customShortcutGlobalMonitor = nil
        }
        if let monitor = customShortcutLocalMonitor {
            NSEvent.removeMonitor(monitor)
            customShortcutLocalMonitor = nil
        }
        pressedModifierKeyCodes.removeAll()
    }
    
    // MARK: - Hands-free dedicated shortcut monitors
    private var handsFreeGlobalMonitor: Any?
    private var handsFreeLocalMonitor: Any?
    private var handsFreePressed = false
    
    // Assistant shortcut monitors
    private var assistantGlobalMonitor: Any?
    private var assistantLocalMonitor: Any?
    private var assistantPressed = false
    
    private func setupHandsFreeShortcutMonitor() {
        removeHandsFreeShortcutMonitor()
        guard let hf = handsFreeShortcut else { return }
        print("🎛️ Setting up hands-free shortcut monitor for: \(hf.description)")
        
        handsFreeGlobalMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.keyDown, .flagsChanged]) { [weak self] event in
            guard let self = self else { return }
            Task { @MainActor in
                await self.handleHandsFreeShortcutEvent(event, shortcut: hf)
            }
        }
        handsFreeLocalMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .flagsChanged]) { [weak self] event in
            guard let self = self else { return event }
            Task { @MainActor in
                await self.handleHandsFreeShortcutEvent(event, shortcut: hf)
            }
            return event
        }
    }
    
    private func removeHandsFreeShortcutMonitor() {
        if let monitor = handsFreeGlobalMonitor { NSEvent.removeMonitor(monitor); handsFreeGlobalMonitor = nil }
        if let monitor = handsFreeLocalMonitor { NSEvent.removeMonitor(monitor); handsFreeLocalMonitor = nil }
        handsFreePressed = false
        pressedModifierKeyCodes.removeAll()
    }
    
    private func handleHandsFreeShortcutEvent(_ event: NSEvent, shortcut: CustomShortcut) async {
        var modifiers = event.modifierFlags.intersection([.command, .option, .shift, .control, .function])
        if !modifiers.contains(.function) && anyFnKeyDown() {
            modifiers.insert(.function)
        }
        let expectedModifiers = NSEvent.ModifierFlags(rawValue: shortcut.modifiers)
        let eventKeyCode = normalizeFnKeyCode(UInt16(event.keyCode))

        // Key + modifiers path: require exact modifier match and keyDown on one of the keys
        if !shortcut.keys.isEmpty {
            guard modifiers == expectedModifiers else { return }
            if event.type == .keyDown && shortcut.keys.contains(eventKeyCode) {
                await toggleHandsFree()
            }
            return
        }
        
        // Modifier-only path
        guard event.type == .flagsChanged else { return }
        updatePressedModifierKeyCodes(from: event)

        // Count how many distinct modifier types are expected
        let expectedCount = [NSEvent.ModifierFlags.command, .option, .shift, .control, .function].reduce(0) { acc, flag in
            expectedModifiers.contains(flag) ? acc + 1 : acc
        }
        
        // Determine if required modifiers are fully engaged
        let codesSatisfied = modifiersMatchPhysicalKeys(shortcut: shortcut)
        let isFullyPressed = modifiers.contains(expectedModifiers) && codesSatisfied
        
        if expectedCount >= 2 {
            // Multi-modifier combo: trigger once when the full set becomes active; reset on release
            if isFullyPressed && !handsFreePressed {
                handsFreePressed = true
                await toggleHandsFree()
            } else if !isFullyPressed && handsFreePressed {
                handsFreePressed = false
            }
        } else {
            // Single-modifier combo: honor side-specific keyCode when provided
            if let keyCode = shortcut.keyCode, eventKeyCode != keyCode { return }
            if isFullyPressed && !handsFreePressed {
                handsFreePressed = true
                await toggleHandsFree()
            } else if !isFullyPressed && handsFreePressed {
                handsFreePressed = false
            }
        }
    }
    
    private func toggleHandsFree() async {
        // If state machine is enabled, route start/stop through it so ESC and UI behave consistently
        let useStateMachine = UserDefaults.standard.bool(forKey: "EnableRecorderStateMachine")
        if useStateMachine, let inputGate = self.inputGate,
           let stateMachine = await inputGate.getRecorderStateMachine(),
           let executor = await inputGate.getCommandExecutor() {
            if await recordingEngine.isRecording {
                // Stop depending on current FSM state:
                // - If PTT is active, a keyUp ends recording
                // - If Hands‑free is active, a keyDown ends recording
                let current = await stateMachine.getCurrentState()
                switch current {
                case .pttActive:
                    let commands = await stateMachine.send(.keyUp)
                    await executor.execute(commands)
                case .handsFreeLocked:
                    let commands = await stateMachine.send(.keyDown)
                    await executor.execute(commands)
                default:
                    // Fallback: send cancellation for unexpected states while recording
                    let commands = await stateMachine.send(.userCancelled)
                    await executor.execute(commands)
                }
            } else {
                // Ensure a plain hands‑free start can never be misrouted into Command Mode
                await MainActor.run {
                    if self.recordingEngine.commandModeCallback != nil {
                        print("🧹 [COMMAND] Clearing stale commandModeCallback before hands-free start")
                        self.recordingEngine.commandModeCallback = nil
                    }
                }
                // Not recording: promote directly to hands‑free via a synthetic double‑tap (down + down)
                let first = await stateMachine.send(.keyDown)
                await executor.execute(first)
                let second = await stateMachine.send(.keyDown)
                await executor.execute(second)
            }
            return
        }

        // Legacy fallback (FSM off)
        if await recordingEngine.isRecording {
            SoundManager.shared.playKeyUp()
            isHandsFreeLocked = false
            recordingEngine.isHandsFreeLocked = false
            await recordingEngine.handleToggleMiniRecorder()
        } else {
            // Ensure a plain hands‑free start can never be misrouted into Command Mode
            await MainActor.run {
                if self.recordingEngine.commandModeCallback != nil {
                    print("🧹 [COMMAND] Clearing stale commandModeCallback before hands-free start")
                    self.recordingEngine.commandModeCallback = nil
                }
            }
            SoundManager.shared.playKeyDown()
            isHandsFreeLocked = true
            recordingEngine.isHandsFreeLocked = true
            await recordingEngine.handleToggleMiniRecorder()
        }
    }
    
    private func handleCustomShortcutEvent(_ event: NSEvent, shortcut: CustomShortcut) async {
        // Include the function modifier so Fn-only and Fn-combos can match
        var modifiers = event.modifierFlags.intersection([.command, .option, .shift, .control, .function])
        if !modifiers.contains(.function) && anyFnKeyDown() {
            modifiers.insert(.function)
        }
        let currentModifiers = modifiers
        let expectedModifiers = NSEvent.ModifierFlags(rawValue: shortcut.modifiers)
        let eventKeyCode = normalizeFnKeyCode(UInt16(event.keyCode))

        if !shortcut.keys.isEmpty {
            // For key-based shortcuts, require full modifier equality and matching keyCode
            guard currentModifiers == expectedModifiers else { return }
            if event.type == .keyDown && shortcut.keys.contains(eventKeyCode) {
                print("🎹 Custom shortcut (key) DOWN → dictationKeyDown: \(shortcut.description)")
                await handleDictationKeyDown()
            }
            return
        }

        // Modifier-only shortcut: transition when the full expected set becomes engaged/released
        guard event.type == .flagsChanged else { return }
        updatePressedModifierKeyCodes(from: event)

        // Count expected modifiers (used to determine single vs multi-mod behavior)
        let expectedCount = [NSEvent.ModifierFlags.command, .option, .shift, .control, .function].reduce(0) { acc, flag in
            expectedModifiers.contains(flag) ? acc + 1 : acc
        }
        
        let codesSatisfied = modifiersMatchPhysicalKeys(shortcut: shortcut)
        let isFullyPressed = currentModifiers.contains(expectedModifiers) && codesSatisfied
        
        if expectedCount >= 2 {
            // Multi-modifier combo: don't depend on a specific keyCode; fire on full set engagement
            if isFullyPressed && !customModifierPressed {
                customModifierPressed = true
                print("🎹 Custom modifiers DOWN → dictationKeyDown: \(shortcut.description) [required=\(shortcut.modifierKeyCodes ?? []) pressed=\(Array(pressedModifierKeyCodes))]")
                await handleDictationKeyDown()
            } else if !isFullyPressed && customModifierPressed {
                customModifierPressed = false
                print("🎹 Custom modifiers UP   → dictationKeyUp: \(shortcut.description) [required=\(shortcut.modifierKeyCodes ?? []) pressed=\(Array(pressedModifierKeyCodes))]")
                await handleDictationKeyUp()
            }
        } else {
            // Single-modifier combo: honor side-specific keyCode when provided
            if let keyCode = shortcut.keyCode, eventKeyCode != keyCode { return }
            if isFullyPressed && !customModifierPressed {
                customModifierPressed = true
                print("🎹 Custom modifier DOWN → dictationKeyDown: \(shortcut.description)")
                await handleDictationKeyDown()
            } else if !isFullyPressed && customModifierPressed {
                customModifierPressed = false
                print("🎹 Custom modifier UP   → dictationKeyUp: \(shortcut.description)")
                await handleDictationKeyUp()
            }
        }
    }
    
    // Side-specific physical key state helper (robust against opposite-side latching)
    private func keyIsDown(_ code: CGKeyCode) -> Bool {
        if code == 63 {
            return anyFnKeyDown()
        }
        return CGEventSource.keyState(.combinedSessionState, key: code)
    }

    private var pressedModifierKeyCodes: Set<UInt16> = []

    private func modifiersMatchPhysicalKeys(shortcut: CustomShortcut) -> Bool {
        guard let codes = shortcut.modifierKeyCodes, !codes.isEmpty else { return true }
        return Set(codes).isSubset(of: pressedModifierKeyCodes)
    }

    private func updatePressedModifierKeyCodes(from event: NSEvent) {
        guard event.type == .flagsChanged else { return }
        let rawKeyCode = UInt16(event.keyCode)
        guard let associatedFlag = modifierFlag(for: rawKeyCode) else { return }
        let normalizedCode = normalizeFnKeyCode(rawKeyCode)

        let isDown: Bool
        if associatedFlag == .function {
            if event.modifierFlags.contains(.function) {
                isDown = true
            } else {
                isDown = anyFnKeyDown()
            }
        } else {
            isDown = event.modifierFlags.contains(associatedFlag)
        }

        if isDown {
            pressedModifierKeyCodes.insert(normalizedCode)
        } else {
            pressedModifierKeyCodes.remove(normalizedCode)
        }
    }

    private func normalizedShortcut(_ shortcut: CustomShortcut?) -> CustomShortcut? {
        guard var shortcut = shortcut else { return nil }
        if shortcut.modifierKeyCodes == nil {
            var codes: [UInt16] = []
            if let keyCode = shortcut.keyCode {
                codes.append(keyCode)
            } else {
                let desc = shortcut.description
                if desc.contains("Left ⇧") { codes.append(56) }
                if desc.contains("Right ⇧") { codes.append(60) }
                if desc.contains("Left ⌥") { codes.append(58) }
                if desc.contains("Right ⌥") { codes.append(61) }
                if desc.contains("Left ⌘") { codes.append(55) }
                if desc.contains("Right ⌘") { codes.append(54) }
                if desc.contains("Right ⌃") { codes.append(62) }
                if desc.contains("Left ⌃") { codes.append(59) }
                if desc.contains("Control") && !codes.contains(59) && !codes.contains(62) { codes.append(59) }
                if desc.contains("Fn") { codes.append(63) }
            }
            if codes.isEmpty {
                let flags = NSEvent.ModifierFlags(rawValue: shortcut.modifiers)
                if flags.contains(.shift) { codes.append(56) }
                if flags.contains(.option) { codes.append(58) }
                if flags.contains(.command) { codes.append(55) }
                if flags.contains(.control) { codes.append(59) }
                if flags.contains(.function) { codes.append(63) }
            }
            codes = codes.map(normalizeFnKeyCode)
            shortcut = CustomShortcut(keys: shortcut.keys,
                                      modifiers: shortcut.modifiers,
                                      keyCode: shortcut.keyCode.map(normalizeFnKeyCode),
                                      modifierKeyCodes: codes)
        }
        return shortcut
    }

    private func modifierFlag(for keyCode: UInt16) -> NSEvent.ModifierFlags? {
        switch normalizeFnKeyCode(keyCode) {
        case 55, 54: return .command
        case 58, 61: return .option
        case 56, 60: return .shift
        case 59, 62: return .control
        case 63: return .function
        default: return nil
        }
    }
    
    // MARK: - Assistant Command Mode dedicated shortcut monitors
    private func setupAssistantShortcutMonitor() {
        // Tear down first
        if let monitor = assistantGlobalMonitor { NSEvent.removeMonitor(monitor); assistantGlobalMonitor = nil }
        if let monitor = assistantLocalMonitor { NSEvent.removeMonitor(monitor); assistantLocalMonitor = nil }
        pressedModifierKeyCodes.removeAll()
        guard let shortcut = assistantShortcut else { return }
        print("🧠 Setting up assistant command shortcut for: \(shortcut.description)")
        // Use a minimal event mask to reduce duplicate callbacks and overhead.
        // If the assistant shortcut is modifier-only, listen only to flagsChanged.
        // Otherwise (key + modifiers), listen to keyDown/Up + flagsChanged.
        let isModifierOnly = shortcut.keys.isEmpty
        let globalMask: NSEvent.EventTypeMask = isModifierOnly ? [.flagsChanged] : [.keyDown, .keyUp, .flagsChanged]
        assistantGlobalMonitor = NSEvent.addGlobalMonitorForEvents(matching: globalMask) { [weak self] event in
            guard let self = self else { return }
            Task { @MainActor in await self.handleAssistantShortcutEvent(event, shortcut: shortcut) }
        }
        // Also install a local monitor to ensure it works when the app is frontmost (no Input Monitoring required)
        let localMask: NSEvent.EventTypeMask = globalMask
        assistantLocalMonitor = NSEvent.addLocalMonitorForEvents(matching: localMask) { [weak self] event in
            guard let self = self else { return event }
            Task { @MainActor in await self.handleAssistantShortcutEvent(event, shortcut: shortcut) }
            return event
        }
        print("🧠 Assistant shortcut monitors installed (global=\(assistantGlobalMonitor != nil), local=\(assistantLocalMonitor != nil))")
    }
    
    private func handleAssistantShortcutEvent(_ event: NSEvent, shortcut: CustomShortcut) async {
        var modifiers = event.modifierFlags.intersection([.command, .option, .shift, .control, .function])
        if !modifiers.contains(.function) && anyFnKeyDown() {
            modifiers.insert(.function)
        }
        let expectedModifiers = NSEvent.ModifierFlags(rawValue: shortcut.modifiers)
        let eventKeyCode = normalizeFnKeyCode(UInt16(event.keyCode))

        // Key + modifiers path
        if !shortcut.keys.isEmpty {
            guard modifiers == expectedModifiers else { return }
            if event.type == .keyDown && shortcut.keys.contains(eventKeyCode) {
                await beginAssistantCommand()
            } else if event.type == .keyUp && shortcut.keys.contains(eventKeyCode) {
                await endAssistantCommand()
            }
            return
        }

        // Modifier-only path (press/release)
        guard event.type == .flagsChanged else { return }
        updatePressedModifierKeyCodes(from: event)
        let expectedCount = [NSEvent.ModifierFlags.command, .option, .shift, .control, .function].reduce(0) { acc, flag in
            expectedModifiers.contains(flag) ? acc + 1 : acc
        }
        let codesSatisfied = modifiersMatchPhysicalKeys(shortcut: shortcut)
        let isFullyPressed = modifiers.contains(expectedModifiers) && codesSatisfied

        if expectedCount >= 2 {
            if isFullyPressed && !assistantPressed {
                assistantPressed = true
                print("🧠 Assistant modifiers DOWN → \(shortcut.description) [required=\(shortcut.modifierKeyCodes ?? []) pressed=\(Array(pressedModifierKeyCodes))]")
                await beginAssistantCommand()
            } else if !isFullyPressed && assistantPressed {
                assistantPressed = false
                print("🧠 Assistant modifiers UP   → \(shortcut.description) [required=\(shortcut.modifierKeyCodes ?? []) pressed=\(Array(pressedModifierKeyCodes))]")
                await endAssistantCommand()
            }
        } else {
            if let keyCode = shortcut.keyCode, eventKeyCode != keyCode { return }
            if isFullyPressed && !assistantPressed {
                assistantPressed = true
                print("🧠 Assistant modifier DOWN → \(shortcut.description) [required=\(shortcut.modifierKeyCodes ?? []) pressed=\(Array(pressedModifierKeyCodes))]")
                await beginAssistantCommand()
            } else if !isFullyPressed && assistantPressed {
                assistantPressed = false
                print("🧠 Assistant modifier UP   → \(shortcut.description) [required=\(shortcut.modifierKeyCodes ?? []) pressed=\(Array(pressedModifierKeyCodes))]")
                await endAssistantCommand()
            }
        }
    }
    
    private func beginAssistantCommand() async {
        // Prepare command-mode callback then reuse dictation PTT pipeline
        let svc = await recordingEngine.getEnhancementService()
        let context = recordingEngine.modelContext
        // Defer screen-context capture + AI pre-warm until after recording actually starts
        if let svc = svc {
            Task.detached(priority: .utility) { [weak self] in
                guard let self = self else { return }
                // Wait until we are actually recording (UI shown + promotion complete)
                while true {
                    let isRec = await MainActor.run { self.recordingEngine.isRecording }
                    if isRec { break }
                    try? await Task.sleep(nanoseconds: 20_000_000) // 20ms poll
                }
                // Give a little extra headroom after the start to avoid animation overlap
                try? await Task.sleep(nanoseconds: 250_000_000) // 250ms
                // Run capture (async) then prewarm (main-safe) without blocking UI
                await svc.captureScreenContext()
                await MainActor.run { svc.prewarmConnection() }
            }
        }
        recordingEngine.commandModeCallback = { instruction in
            SelectionCommandService.run(instruction: instruction, enhancementService: svc, modelContext: context)
        }
        await handleDictationKeyDown()
    }
    
    private func endAssistantCommand() async {
        await handleDictationKeyUp()
    }
    
    private func setupShortcutHandler() {
        let timestamp = Date()
        print("🔧 [HOTKEY SETUP] Setting up shortcut handler at \(timestamp)")
        
        // Clear any existing handlers first
        KeyboardShortcuts.onKeyUp(for: .toggleMiniRecorder) { }
        KeyboardShortcuts.onKeyDown(for: .toggleMiniRecorder) { }
        print("🧹 [HOTKEY SETUP] Cleared existing handlers")
        
        // DIAGNOSTIC: Try to "activate" the KeyboardShortcuts system
        print("🔧 [HOTKEY SETUP] Attempting to activate KeyboardShortcuts system...")
        
        // Force the library to initialize its internal systems
        _ = KeyboardShortcuts.getShortcut(for: .toggleMiniRecorder)
        print("🔧 [HOTKEY SETUP] Forced library initialization")
        
        // Library should be activated now, ready to set up real handlers
        print("🔧 [HOTKEY SETUP] Library activation complete, ready for real handlers...")
        
        // Wait a bit, then set up the real handlers
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 100_000_000) // 100ms
            print("🔧 [HOTKEY SETUP] Setting up actual handlers...")
            
            // Set up dictation hotkey handlers implementing PTT + double-tap hands-free
            KeyboardShortcuts.onKeyDown(for: .toggleMiniRecorder) { [weak self] in
                Task { @MainActor in
                    self?.lastObservedToggleEventAt = Date()
                    self?.cancelHotkeyWatchdog()
                    StructuredLog.shared.log(cat: .hotkey, evt: "event", lvl: .info, ["type": "down", "delivered": true, "desc": self?.getCurrentShortcutDescription() ?? "unknown"])
                    DebugLogger.debug("perf:hotkey_down", category: .performance)
                    await self?.handleDictationKeyDown()
                }
            }
            KeyboardShortcuts.onKeyUp(for: .toggleMiniRecorder) { [weak self] in
                Task { @MainActor in
                    self?.lastObservedToggleEventAt = Date()
                    self?.cancelHotkeyWatchdog()
                    StructuredLog.shared.log(cat: .hotkey, evt: "event", lvl: .info, ["type": "up", "delivered": true, "desc": self?.getCurrentShortcutDescription() ?? "unknown"])
                    DebugLogger.debug("perf:hotkey_up", category: .performance)
                    await self?.handleDictationKeyUp()
                }
            }
            
            print("✅ [HOTKEY SETUP] Real handlers configured (keyDown + keyUp)")
            
            // Start a one-shot watchdog to verify we actually receive events
            self.startHotkeyWatchdog()
            
            print("🚀 [HOTKEY SETUP] Complete setup finished - handlers active")
        }
    }
    
    // MARK: - Dictation hotkey combined behavior
private func handleDictationKeyDown() async {
        // If a stale command-mode callback is armed but the Assistant shortcut is NOT pressed,
        // clear it so a plain dictation session cannot be misrouted into Command Mode.
        if !assistantPressed, recordingEngine.commandModeCallback != nil {
            print("🧹 [COMMAND] Clearing stale commandModeCallback before dictation keyDown")
            recordingEngine.commandModeCallback = nil
        }
        // Route all logic through InputGate (handles mis-touch, PTT, double-tap to hands-free, and stop while locked)
        await inputGate?.onKeyDown()
    }
    
private func handleDictationKeyUp() async {
        // Route through InputGate for promotion logic (includes mis-touch auto-hide and PTT finalize on release)
        await inputGate?.onKeyUp()
    }
    
    private func startHotkeyWatchdog() {
        guard hotkeyWatchdogEnabled else { return }
        // If we're already armed and ready (non-F5 or F5 with remapper), don't start
        if (!isEffectivePlainF5Active()) || (isEffectivePlainF5Active() && isF5RemapperRunning) {
            return
        }
        // Avoid stacking multiple watchdogs
        hotkeyWatchdogTask?.cancel()
        hotkeyWatchdogAttempts = 0
        hotkeyWatchdogTask = Task { [weak self] in
            guard let self = self else { return }
            while self.hotkeyWatchdogAttempts < 2 { // cap attempts
                do { try await Task.sleep(nanoseconds: 1_000_000_000) } catch { return }
                await MainActor.run {
                    // Cancel if we saw any event or are now armed
                    if self.lastObservedToggleEventAt != nil || (self.isEffectivePlainF5Active() && self.isF5RemapperRunning) {
                        self.cancelHotkeyWatchdog()
                        return
                    }
                    self.hotkeyWatchdogAttempts += 1
                    // Single compact log per attempt
                    print("⚠️ [HOTKEY WATCHDOG] No toggle events within 1s (attempt #\(self.hotkeyWatchdogAttempts)) — refreshing handlers once")
                    self.setupShortcutHandler()
                }
            }
            // After cap, auto-disable until next boot/config change
            await MainActor.run { self.cancelHotkeyWatchdog(silence: true) }
        }
    }
    
    private func cancelHotkeyWatchdog(silence: Bool = false) {
        hotkeyWatchdogTask?.cancel(); hotkeyWatchdogTask = nil
        hotkeyWatchdogEnabled = false
        hotkeyWatchdogAttempts = 0
        if !silence { /* intentionally quiet to avoid log spam */ }
    }
    
    private func handleShortcutTriggered() async {
        let timestamp = Date()
        // print("🎹 [HOTKEY DEBUG] ===============================================")
        // print("🎹 [HOTKEY DEBUG] Shortcut triggered at \(timestamp)")
        // print("🎹 [HOTKEY DEBUG] App launch time delta: \(String(format: "%.2f", timestamp.timeIntervalSince(appLaunchTime ?? timestamp)))s")
        let ts = String(format: "%.3f", Date().timeIntervalSince1970)
        // print("⏱️ [TIMING] hotkey_down @ \(ts)")

        // Avoid triggering immediately on launch
        if let launch = appLaunchTime, Date().timeIntervalSince(launch) < 1.0 {
            // print("🎹 [HOTKEY DEBUG] ❌ BLOCKED: within launch grace period")
            return
        }
        
        // Log detailed service state
        // print("🎹 [HOTKEY DEBUG] Service State:")
        // print("🎹 [HOTKEY DEBUG]   - canTranscribe: \(recordingEngine.canTranscribe)")
        // print("🎹 [HOTKEY DEBUG]   - currentModel: \(recordingEngine.currentModel?.name ?? "nil")")
        // print("🎹 [HOTKEY DEBUG]   - isRecording: \(recordingEngine.isRecording)")
        // print("🎹 [HOTKEY DEBUG]   - isMiniRecorderVisible: \(recordingEngine.isMiniRecorderVisible)")
        // print("🎹 [HOTKEY DEBUG]   - miniWindowManager exists: \(recordingEngine.miniWindowManager != nil)")
        // print("🎹 [HOTKEY DEBUG]   - isShortcutConfigured: \(isShortcutConfigured)")
        
        // Check service readiness first
        if !recordingEngine.canTranscribe {
            // print("🎹 [HOTKEY DEBUG] ❌ BLOCKED: canTranscribe is false")
            return
        }
        
        if recordingEngine.currentModel == nil {
            // print("🎹 [HOTKEY DEBUG] ❌ BLOCKED: currentModel is nil")
            return
        }
        
        // Check cooldown (increased to prevent double-triggering from keyDown+keyUp)
        if let lastTrigger = lastShortcutTriggerTime {
            let cooldownElapsed = Date().timeIntervalSince(lastTrigger)
            if cooldownElapsed < shortcutCooldownInterval {
                // print("🎹 [HOTKEY DEBUG] ❌ BLOCKED: In cooldown period (\(String(format: "%.3f", cooldownElapsed))s < \(shortcutCooldownInterval)s)")
                return
            }
        }
        
        // Update last trigger time
        lastShortcutTriggerTime = Date()
        
        // print("🎹 [HOTKEY DEBUG] ✅ All checks passed, calling recordingEngine.handleToggleMiniRecorder")
        // print("⏱️ [TIMING] toggleMiniRecorder_call @ \(String(format: "%.3f", Date().timeIntervalSince1970))")
        
        // Handle the shortcut and track what happens
        do {
            await recordingEngine.handleToggleMiniRecorder()
            // print("🎹 [HOTKEY DEBUG] ✅ handleToggleMiniRecorder completed successfully")
        } catch {
            print("🎹 [HOTKEY DEBUG] ❌ handleToggleMiniRecorder threw error: \(error)")
        }
        
        // print("🎹 [HOTKEY DEBUG] ===============================================")
    }
    
    // MARK: - Dynamic Escape Shortcut
    private func updateEscapeShortcut() {
        let isMiniActive = recordingEngine.isMiniRecorderVisible && recordingEngine.isRecording
        let isNotchActive = (recordingEngine.recorderType == "notch") && recordingEngine.isRecording && (recordingEngine.notchWindowManager?.isVisible == true)
        if isMiniActive || isNotchActive {
            setupEscapeShortcut()
        } else {
            removeEscapeShortcut()
        }
    }

    // MARK: - Hands-free stickiness: prevent unintended teardown
    // Avoid removing the F5 interception while hands-free is active; stopping
    // the tap mid-session would allow Apple Dictation to capture F5 on release.
    private func shouldProtectF5Interception() -> Bool {
        return isHandsFreeLocked || recordingEngine.isHandsFreeLocked
    }
    
    // MARK: - Loading phase setup
    func beginHotkeyLoading() {
        // Force immediate reconfigure without debounce
        performShortcutReconfigure()
        // Perform a deterministic settle/verify similar to post-activation
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            if self.isAnyPlainF5Assigned() && !self.isF5RemapperRunning {
                self.updateF5OverrideArming(reason: "loadingPhase", delaySeconds: 0.0)
            }
            if self.isAnyPlainF5Assigned() {
                self.isHotkeyReady = self.isF5RemapperRunning
            } else {
                self.isHotkeyReady = true
            }
            print("✅ [HOTKEY READY] effective=\(self.getCurrentShortcutDescription() ?? "none"), F5Armed=\(self.isF5RemapperRunning)")
        }
    }
    
    // Determine if the effective library shortcut is a plain F5 binding
    private func isEffectivePlainF5Active() -> Bool {
        // If a custom shortcut is present, library F5 is not the effective binding
        if customShortcut != nil { return false }
        let libraryShortcut = KeyboardShortcuts.getShortcut(for: .toggleMiniRecorder) ?? stickyLibraryShortcut
        if let sc = libraryShortcut {
            return (sc.key == .f5) && sc.modifiers.isEmpty
        }
        return false
    }
    
    // Check if hands‑free dedicated shortcut is set to plain F5 (no modifiers)
    private func isHandsFreePlainF5Active() -> Bool {
        guard let hf = handsFreeShortcut else { return false }
        // Plain F5 pressed as a key (not a modifier-only binding)
        return hf.modifiers == 0 && hf.keys.count == 1 && hf.keys.first == 96
    }
    
    // Any feature requires a plain F5 override (dictation or hands‑free)
    private func isAnyPlainF5Assigned() -> Bool {
        return isEffectivePlainF5Active() || isHandsFreePlainF5Active()
    }
    
    // Decide which action F5 should trigger and arm/tear down the remapper accordingly.
    // Precedence: dictation > hands‑free when both are bound to F5 simultaneously.
    private func updateF5OverrideArming(reason: String, delaySeconds: Double = 0.3) {
        let dictationF5 = isEffectivePlainF5Active()
        let handsfreeF5 = isHandsFreePlainF5Active()
        if dictationF5 {
            startF5Remapper(reason: reason, delaySeconds: delaySeconds)
            return
        }
        if handsfreeF5 {
            // Start remapper but route F5 to hands‑free toggle
            f5DeferredStartTask?.cancel()
            f5DeferredStartTask = Task { [weak self] in
                guard let self else { return }
                if delaySeconds > 0 { try? await Task.sleep(nanoseconds: UInt64(delaySeconds * 1_000_000_000)) }
                await MainActor.run {
                    self.f5RuntimeRemapper.stop()
                    self.f5RuntimeRemapper.start(onF5Down: { [weak self] in
                        Task { @MainActor in await self?.toggleHandsFree() }
                    }, onF5Up: nil)
                    self.isF5RemapperRunning = true
                    print("✅ F5 override active for Hands‑free (reason=\(reason))")
                }
            }
            return
        }
        // Neither uses F5 → ensure remapper is stopped
        stopF5Remapper(reason: "updateF5OverrideArming")
    }
    
    private func setupDebugEventMonitors() {
        print("🔍 [DEBUG] Setting up system-level event monitors for Command key")
        
        // Monitor for Command key presses globally (when app is in background)
        debugGlobalMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.flagsChanged, .keyDown, .keyUp]) { [weak self] event in
            guard let self = self else { return }
            if self.enableSecondaryCommandMonitor && event.type == .flagsChanged && event.keyCode == 54 { // Right Command
                let isDown = event.modifierFlags.contains(.command)
                if isDown && !self.lastRightCommandDown {
                    // Route through InputGate for unified behavior
                    Task { @MainActor in
                        await self.handleDictationKeyDown()
                    }
                } else if !isDown && self.lastRightCommandDown {
                    Task { @MainActor in
                        await self.handleDictationKeyUp()
                    }
                }
                self.lastRightCommandDown = isDown
            }
        }
        
        // Monitor for Command key presses locally (when app is in foreground)
        debugLocalMonitor = NSEvent.addLocalMonitorForEvents(matching: [.flagsChanged, .keyDown, .keyUp]) { [weak self] event in
            if let self = self, self.enableSecondaryCommandMonitor && event.type == .flagsChanged && event.keyCode == 54 {
                let isDown = event.modifierFlags.contains(.command)
                if isDown && !self.lastRightCommandDown {
                    Task { @MainActor in
                        await self.handleDictationKeyDown()
                    }
                } else if !isDown && self.lastRightCommandDown {
                    Task { @MainActor in
                        await self.handleDictationKeyUp()
                    }
                }
                self.lastRightCommandDown = isDown
            }
            return event
        }
        
        // print("🔍 [DEBUG] System-level monitors active")
    }
    
    private func removeDebugEventMonitors() {
        if let monitor = debugGlobalMonitor {
            NSEvent.removeMonitor(monitor)
            debugGlobalMonitor = nil
        }
        if let monitor = debugLocalMonitor {
            NSEvent.removeMonitor(monitor)
            debugLocalMonitor = nil
        }
    }
    
    private func setupDelayedReregistration() {
        print("⏰ [DELAYED] Setting up delayed re-registration as safety measure")
        
        // Try re-registering the handlers multiple times with increasing delays
        // This is to handle any potential library initialization race conditions
        
        Task { @MainActor in
            // First attempt after 2 seconds
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            print("⏰ [DELAYED] Attempt 1: Re-registering handlers after 2s")
            reregisterHandlers(attempt: 1)
            
            // Second attempt after 5 seconds
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            print("⏰ [DELAYED] Attempt 2: Re-registering handlers after 5s")
            reregisterHandlers(attempt: 2)
            
            // Third attempt after 10 seconds
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            print("⏰ [DELAYED] Attempt 3: Re-registering handlers after 10s")
            reregisterHandlers(attempt: 3)
        }
    }
    
    private func reregisterHandlers(attempt: Int) {
        print("🔁 [REREGISTER] Attempt \(attempt): Clearing and re-setting handlers")
        
        // Clear existing handlers
        KeyboardShortcuts.onKeyUp(for: .toggleMiniRecorder) { }
        KeyboardShortcuts.onKeyDown(for: .toggleMiniRecorder) { }
        
        // Set up fresh handlers with real business logic
        KeyboardShortcuts.onKeyDown(for: .toggleMiniRecorder) { [weak self] in
            print("🎹 [REREGISTER-\(attempt)] KeyDown handler triggered - calling business logic")
            Task { @MainActor in
                await self?.handleShortcutTriggered()
            }
        }
        
        // No need for KeyUp handler - the business logic handles everything in KeyDown
        
        // Verify the shortcut is still there
        let currentShortcut = KeyboardShortcuts.getShortcut(for: .toggleMiniRecorder)
        print("🔁 [REREGISTER] Attempt \(attempt): Shortcut verified: \(currentShortcut?.description ?? "none")")
        
        print("✅ [REREGISTER] Attempt \(attempt): Handlers re-registered")
    }

    // MARK: - Function key interception to override macOS Dictation at runtime (opt-in behavior via binding an F-key)
    private func configureFunctionKeyInterception(for shortcut: KeyboardShortcuts.Shortcut?) {
        // Only intercept plain F1..F12 without modifiers.
        // If shortcut is temporarily nil (library read race), DO NOT tear down
        // the existing interception. Keep current mapping sticky until a
        // definitive user change is observed.
        guard let shortcut = shortcut else { return }
        if !shortcut.modifiers.isEmpty {
            teardownFunctionKeyInterception(); return
        }
        let keyToCode: [KeyboardShortcuts.Key: UInt16] = [
            .f1: 122, .f2: 120, .f3: 99, .f4: 118, .f5: 96, .f6: 97,
            .f7: 98, .f8: 100, .f9: 101, .f10: 109, .f11: 103, .f12: 111
        ]
        guard let key = shortcut.key, let code = keyToCode[key] else {
            teardownFunctionKeyInterception(); return
        }
        interceptedFunctionKeyCode = code
        // If user bound F5, override via event tap directly (no Carbon, no remap)
        if code == 96 {
            // Plain F5: arm remapper immediately; works even if app is inactive.
            startF5Remapper(reason: "postActivationAutoArm")
        } else {
            // Non-F5 keys: use Carbon as usual
            registerCarbonHotkey(for: code)
        }
    }

    private func startFunctionKeyTap() {
        teardownFunctionKeyInterception()
        guard let code = interceptedFunctionKeyCode else { return }
        guard AXIsProcessTrusted() else {
            print("⚠️ Accessibility permission required for F-key interception"); return
        }
        // Bridge `systemDefined` from NSEvent for wider SDK compatibility
        let systemDefined = CGEventType(rawValue: UInt32(NSEvent.EventType.systemDefined.rawValue))
        let mask = (
            (1 << CGEventType.keyDown.rawValue) |
            (1 << CGEventType.keyUp.rawValue) |
            (1 << CGEventType.flagsChanged.rawValue) |
            (1 << (systemDefined?.rawValue ?? 0))
        )
        let callback: CGEventTapCallBack = { _, type, cgEvent, userInfo in
            guard let userInfo = userInfo else { return Unmanaged.passRetained(cgEvent) }
            let manager = Unmanaged<HotkeyManager>.fromOpaque(userInfo).takeUnretainedValue()
            // Handle standard keyboard keyDown/keyUp
            if type == .keyDown || type == .keyUp {
                let raw = Int(cgEvent.getIntegerValueField(.keyboardEventKeycode))
                let rawU16 = UInt16(truncatingIfNeeded: raw)
                var normalized = rawU16
                if fnAlternateKeyCodes.contains(rawU16) {
                    normalized = 63
                } else if (176...187).contains(raw) {
                    normalized = UInt16(raw - 80)
                }
                if let target = manager.interceptedFunctionKeyCode, normalized == target {
                    if type == .keyDown {
                        Task { @MainActor in await manager.handleShortcutTriggered() }
                    }
                    return nil
                }
            }
            // Handle system-defined NSEvents (Dictation) by converting the CGEvent
            if let nsEvent = NSEvent(cgEvent: cgEvent), nsEvent.type == .systemDefined, nsEvent.subtype.rawValue == 8 {
                let data1 = nsEvent.data1
                let keyCode = (data1 & 0xFFFF0000) >> 16
                // 0x82 is NX_KEYTYPE_DICTATION
                if keyCode == 0x82, manager.interceptedFunctionKeyCode != nil {
                    return nil
                }
            }
            return Unmanaged.passRetained(cgEvent)
        }
        guard let tap = CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(mask),
            callback: callback,
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else {
            print("❌ Failed to create function key event tap")
            return
        }
        fkeyEventTap = tap
        if let src = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0) {
            fkeyEventTapSource = src
            CFRunLoopAddSource(CFRunLoopGetCurrent(), src, .commonModes)
            CGEvent.tapEnable(tap: tap, enable: true)
            print("✅ Function key interception active for code \(code)")
        }
    }

    private func teardownFunctionKeyInterception() {
        stopF5Remapper(reason: "teardownFunctionKeyInterception")
        if let src = fkeyEventTapSource { CFRunLoopRemoveSource(CFRunLoopGetCurrent(), src, .commonModes); fkeyEventTapSource = nil }
        if let tap = fkeyEventTap { CGEvent.tapEnable(tap: tap, enable: false); fkeyEventTap = nil }
        interceptedFunctionKeyCode = nil
        unregisterCarbonHotkey()
        hidRemapper.revertF5MappingIfInserted()
        launchAgent.removeAgent()
    }

    private func startF5Remapper(reason: String, delaySeconds: Double = 0.3) {
        f5DeferredStartTask?.cancel()
        f5DeferredStartTask = Task { [weak self] in
            guard let self else { return }
            if delaySeconds > 0 { try? await Task.sleep(nanoseconds: UInt64(delaySeconds * 1_000_000_000)) }
            // NOTE: We no longer require NSApp.isActive. Global event taps work when app is inactive.
            await MainActor.run {
                self.f5RuntimeRemapper.stop()
                self.f5RuntimeRemapper.start(onF5Down: { [weak self] in
                    Task { @MainActor in await self?.handleDictationKeyDown() }
                }, onF5Up: { [weak self] in
                    Task { @MainActor in await self?.handleDictationKeyUp() }
                })
                self.isF5RemapperRunning = true
                print("✅ F5 override active via event tap (reason=\(reason))")
            }
        }
    }

    private func stopF5Remapper(reason: String) {
        if shouldProtectF5Interception() {
            print("🔒 [HOTKEY] Skipping F5 remapper stop (reason=\(reason)) due to hands‑free lock")
            return
        }
        f5RuntimeRemapper.stop()
        isF5RemapperRunning = false
        print("🛑 F5 override stopped (reason=\(reason))")
        // Lightweight watchdog: if we didn't stop due to a user change and F5 is still the effective binding,
        // try to re-arm shortly after, guarded by app active state.
        if reason != "userChangedShortcut" {
            let effectiveIsF5 = isEffectivePlainF5Active()
            if effectiveIsF5 || shouldProtectF5Interception() {
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 200_000_000)
                    if NSApp.isActive {
                        self.startF5Remapper(reason: "watchdogRearm")
                    } else {
                        // Re-arm on next activation
                        NotificationCenter.default.addObserver(forName: NSApplication.didBecomeActiveNotification, object: nil, queue: .main) { [weak self] _ in
                            self?.startF5Remapper(reason: "watchdogRearmOnActive")
                        }
                    }
                }
            }
        }
    }

    private func registerCarbonHotkey(for code: UInt16) {
        unregisterCarbonHotkey()
        let map: [UInt16: UInt32] = [122: UInt32(kVK_F1), 120: UInt32(kVK_F2), 99: UInt32(kVK_F3), 118: UInt32(kVK_F4), 96: UInt32(kVK_F5), 97: UInt32(kVK_F6), 98: UInt32(kVK_F7), 100: UInt32(kVK_F8), 101: UInt32(kVK_F9), 109: UInt32(kVK_F10), 103: UInt32(kVK_F11), 111: UInt32(kVK_F12)]
        guard let vk = map[code] else { return }
        let hk = GlobalHotKey()
        let status = hk.register(keyCode: vk, modifiers: 0) { [weak self] in
            Task { @MainActor in await self?.handleShortcutTriggered() }
        }
        // Record status synchronously so callers can branch on it immediately
        self.lastHotkeyRegisterStatus = status
        if status == noErr {
            globalHotKey = hk
            print("✅ Carbon hotkey registered for virtual key \(vk)")
        } else {
            print("⚠️ Carbon hotkey register failed, status: \(status)")
            DispatchQueue.main.async { [weak self] in self?.showHotkeyConflict = true }
        }
    }

    private func unregisterCarbonHotkey() {
        globalHotKey?.unregister()
        globalHotKey = nil
    }

    // MARK: - User helpers
    func openKeyboardSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.keyboard") {
            NSWorkspace.shared.open(url)
        }
    }

    func retryRegisterCurrentHotkey() {
        let libraryShortcut = KeyboardShortcuts.getShortcut(for: .toggleMiniRecorder)
        configureFunctionKeyInterception(for: libraryShortcut)
    }
    
    // MARK: - Public Reset Methods
    
    /// Clears the dictation hotkey (custom shortcut)
    func clearDictationHotkey() {
        // Clear both custom and library bindings
        allowCustomShortcutMutation = true
        customShortcut = nil
        allowCustomShortcutMutation = false
        UserDefaults.standard.removeObject(forKey: "customShortcut")
        KeyboardShortcuts.setShortcut(nil, for: .toggleMiniRecorder)
        
        // IMPORTANT: also clear the sticky cached library shortcut so a previous
        // value doesn't keep the binding effectively active after reset.
        stickyLibraryShortcut = nil
        
        // Re-evaluate and tear down any monitors/interception if nothing is set
        updateShortcutStatus()
        print("🧹 [RESET] Cleared dictation hotkey")
    }
    
    /// Clears the hands-free mode hotkey
    func clearHandsFreeHotkey() {
        handsFreeShortcut = nil
        UserDefaults.standard.removeObject(forKey: "handsFreeShortcut")
        removeHandsFreeShortcutMonitor()
        print("🧹 [RESET] Cleared hands-free hotkey")
    }
    
    /// Clears the assistant mode hotkey
    func clearAssistantHotkey() {
        assistantShortcut = nil
        UserDefaults.standard.removeObject(forKey: "assistantShortcut")
        isAssistantShortcutDisabled = true
        print("🧹 [RESET] Cleared assistant hotkey")
    }
    
    /// Clears all hotkeys
    func clearAllHotkeys() {
        clearDictationHotkey()
        clearHandsFreeHotkey()
        clearAssistantHotkey()
        print("🧹 [RESET] Cleared all hotkeys")
    }
    
    deinit {
        visibilityTask?.cancel()
        Task { @MainActor in
            removeKeyMonitor()
            removeCustomShortcutMonitor()
            removeHandsFreeShortcutMonitor()
            removeEscapeShortcut()
            removeEnhancementShortcut()
            removeDebugEventMonitors()
        }
        if let observer = resignObserver { NotificationCenter.default.removeObserver(observer) }
    }
    
    private func setDefaultShortcutsIfNeeded() {
        // Check if this is a new user (no shortcuts exist)
        let isNewUser = customShortcut == nil && handsFreeShortcut == nil && assistantShortcut == nil
        
        print("🎹 Checking shortcuts - customShortcut: \(customShortcut?.description ?? "nil"), handsFree: \(handsFreeShortcut?.description ?? "nil"), assistant: \(assistantShortcut?.description ?? "nil")")
        
        if isNewUser {
            print("🎹 New user detected - setting default hotkeys")
            
            // Set default push-to-talk: Right Option key
            let rightOptionShortcut = CustomShortcut(
                keys: [],
                modifiers: NSEvent.ModifierFlags.option.rawValue,
                keyCode: 61, // Right Option key code
                modifierKeyCodes: [61]
            )
            self.customShortcut = rightOptionShortcut
            
            // Set default hands-free: Right Command key
            let rightCommandShortcut = CustomShortcut(
                keys: [],
                modifiers: NSEvent.ModifierFlags.command.rawValue,
                keyCode: 54, // Right Command key code
                modifierKeyCodes: [54]
            )
            self.handsFreeShortcut = rightCommandShortcut
            
            if !isAssistantShortcutDisabled {
                // Set default command mode: Left Command + Left Control (modifier-only)
                let cmdCtrlFlags: NSEvent.ModifierFlags = [.command, .control]
                let commandModeShortcut = CustomShortcut(
                    keys: [],
                    modifiers: cmdCtrlFlags.rawValue,
                    keyCode: nil,
                    modifierKeyCodes: [55, 59]
                )
                self.assistantShortcut = commandModeShortcut
            } else {
                print("🎹 Assistant shortcut disabled by user – skipping default")
            }
            
            // Enable push-to-talk by default for new users
            self.isPushToTalkEnabled = true
            UserDefaults.standard.set(true, forKey: "isPushToTalkEnabled")
            
            print("🎹 Default hotkeys set: Right Option (PTT), Right Command (Hands-free), ⌘ + ⌃ (Command)")
        } else {
            print("🎹 Existing user - checking for Left Option fix + assistant default")
            // Fix existing users who have Left Option instead of Right Option
            if let currentShortcut = customShortcut, 
               currentShortcut.description == "Left ⌥" {
                print("🎹 Fixing Left Option to Right Option")
                let rightOptionShortcut = CustomShortcut(
                    keys: [],
                    modifiers: NSEvent.ModifierFlags.option.rawValue,
                    keyCode: 61,
                    modifierKeyCodes: [61]
                )
                self.customShortcut = rightOptionShortcut
            }
            // If this user never set an Assistant (Command Mode) shortcut, set our default now.
            if self.assistantShortcut == nil && !isAssistantShortcutDisabled {
                let cmdCtrlFlags: NSEvent.ModifierFlags = [.command, .control]
                let commandModeShortcut = CustomShortcut(
                    keys: [],
                    modifiers: cmdCtrlFlags.rawValue,
                    keyCode: nil,
                    modifierKeyCodes: [55, 59]
                )
                self.assistantShortcut = commandModeShortcut
                print("🎹 Assistant default applied for existing user: ⌘ + ⌃")
            } else if let assistant = self.assistantShortcut,
                      (assistant.modifierKeyCodes?.isEmpty ?? true),
                      assistant.keys.isEmpty,
                      NSEvent.ModifierFlags(rawValue: assistant.modifiers) == [.command, .control] {
                let updated = CustomShortcut(
                    keys: assistant.keys,
                    modifiers: assistant.modifiers,
                    keyCode: assistant.keyCode,
                    modifierKeyCodes: [55, 59]
                )
                self.assistantShortcut = updated
                print("🎹 Added left-side metadata to existing assistant shortcut (⌘ + ⌃)")
            }
        }
    }
}
