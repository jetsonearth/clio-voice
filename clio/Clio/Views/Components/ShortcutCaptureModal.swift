import SwiftUI
import AppKit
import KeyboardShortcuts

// Some keyboards report the Fn (Function) modifier using alternate raw key codes.
// Track a small set that we've seen in the wild so we can normalize them to 63
// (kVK_Function) everywhere inside the capture flow.
private let fnAlternateKeyCodes: Set<UInt16> = [179, 244]

private func isFnKeyCode(_ keyCode: UInt16) -> Bool {
    return keyCode == 63 || fnAlternateKeyCodes.contains(keyCode)
}

private func normalizeFnKeyCode(_ keyCode: UInt16) -> UInt16 {
    return fnAlternateKeyCodes.contains(keyCode) ? 63 : keyCode
}

private func isAnyFnKeyDown() -> Bool {
    // Check the canonical and alternate key codes so we can detect hardware
    // that reports Fn using vendor-specific scan codes.
    let codes: [UInt16] = [63] + Array(fnAlternateKeyCodes)
    return codes.contains { CGEventSource.keyState(.combinedSessionState, key: CGKeyCode($0)) }
}

enum ShortcutCaptureResult {
    case shortcut(KeyboardShortcuts.Shortcut)
    case combination(keys: [UInt16], modifiers: NSEvent.ModifierFlags, modifierKeyCodes: [UInt16])
    case modifierOnly(keyCodes: [UInt16], modifiers: NSEvent.ModifierFlags)
}

struct ShortcutCaptureModal: View {
    let onSave: (ShortcutCaptureResult) -> Void
    let onCancel: () -> Void
    
    @State private var isRecording = false
    @State private var monitor: Any?
    @State private var globalFlagsMonitor: Any?
    @State private var currentModifiers: NSEvent.ModifierFlags = []
    @State private var currentKey: UInt16?
    // Live chord building
    @State private var chordKeys: Set<UInt16> = []
    @State private var chordModifiers: NSEvent.ModifierFlags = []
    @State private var chordModifierKeyCodes: Set<UInt16> = []
    @State private var chordTimer: DispatchWorkItem?
    // Final captured combo
    @State private var capturedComboKeys: [UInt16] = []
    @State private var capturedComboModifiers: NSEvent.ModifierFlags = []
    @State private var capturedModifierKeyCode: UInt16?
    @State private var capturedModifierKeyCodes: [UInt16] = []
    @State private var modifiersTimer: DispatchWorkItem?
    // Track the largest set of modifiers observed within the debounce window so multi-modifier combos are captured
    @State private var peakModifiers: NSEvent.ModifierFlags = []
    @State private var peakModifierKeyCodes: Set<UInt16> = []
    @State private var activeModifierKeyCodes: Set<UInt16> = []
    @State private var isFnPressed = false
    @EnvironmentObject private var localizationManager: LocalizationManager
    @EnvironmentObject private var hotkeyManager: HotkeyManager
    // Scoped event-tap to capture F-keys before macOS consumes them (Dictation, etc.)
    @State private var eventTap: CFMachPort?
    @State private var eventTapRunLoopSource: CFRunLoopSource?
    @State private var eventTapRelay = EventTapRelay()
    
    var body: some View {
        StandardModal(
            title: localizationManager.localizedString("hotkey.modal.title"),
            onClose: { stopRecording(); onCancel() },
            primaryButtonTitle: localizationManager.localizedString("general.save"),
            primaryButtonAction: saveShortcut,
            isPrimaryButtonEnabled: isValidShortcut(),
            secondaryButtonTitle: localizationManager.localizedString("general.cancel"),
            secondaryButtonAction: { stopRecording(); onCancel() },
            titleFontSize: 20
        ) {
            VStack(spacing: 20) {
                // Instruction
                Text(localizationManager.localizedString("hotkey.modal.description"))
                    .font(.subheadline)
                    .foregroundColor(DarkTheme.textSecondary)
                    .multilineTextAlignment(.center)
                
                // Shortcut preview
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        Text(renderShortcutPreview())
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(DarkTheme.textPrimary)
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                        Spacer(minLength: 8)
                        if hasSelection() {
                            Button(LocalizationManager.shared.localizedString("general.clear")) {
                                clearSelection()
                            }
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(DarkTheme.textSecondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(DarkTheme.surfaceBackground)
                                    .overlay(
                                        Capsule()
                                            .stroke(DarkTheme.border, lineWidth: 1)
                                    )
                            )
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(DarkTheme.surfaceBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(DarkTheme.border, lineWidth: 1)
                            )
                    )
                }
            }
        }
.onAppear {
            hotkeyManager.inCaptureSession = true
            // Ensure the sheet's window is key before we start listening
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                NSApp.keyWindow?.makeKey()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    startRecording()
                }
            }
        }
        .onDisappear {
            stopRecording()
            hotkeyManager.inCaptureSession = false
        }
    }
    
    private func renderShortcutPreview() -> String {
        if !capturedComboKeys.isEmpty {
            return describeCombination(
                keys: capturedComboKeys,
                modifiers: capturedComboModifiers,
                modifierKeyCodes: capturedModifierKeyCodes
            )
        }
        if capturedComboModifiers.isEmpty == false {
            let codes = capturedModifierKeyCodes.isEmpty ? (capturedModifierKeyCode.map { [$0] } ?? []) : capturedModifierKeyCodes
            return describeModifiersOnly(modifiers: capturedComboModifiers, keyCodes: codes)
        }
        return isRecording ? localizationManager.localizedString("hotkey.modal.listening") : localizationManager.localizedString("hotkey.modal.description")
    }
    
    private func hasSelection() -> Bool {
        return !capturedComboKeys.isEmpty || !capturedComboModifiers.isEmpty
    }
    
    private func clearSelection() {
        chordKeys.removeAll()
        chordModifiers = []
        chordModifierKeyCodes.removeAll()
        capturedComboKeys.removeAll()
        capturedComboModifiers = []
        capturedModifierKeyCode = nil
        capturedModifierKeyCodes = []
        peakModifiers = []
        peakModifierKeyCodes.removeAll()
        activeModifierKeyCodes.removeAll()
        isFnPressed = false
    }

    private func modifiersString(_ mods: NSEvent.ModifierFlags) -> String {
        var s = ""
        // Include Fn first so it shows up in the preview
        if mods.contains(.function) { s += "fn" }
        if mods.contains(.control) { s += "⌃" }
        if mods.contains(.option) { s += "⌥" }
        if mods.contains(.shift) { s += "⇧" }
        if mods.contains(.command) { s += "⌘" }
        return s
    }

    private func describeCombination(keys: [UInt16],
                                     modifiers: NSEvent.ModifierFlags,
                                     modifierKeyCodes: [UInt16]) -> String {
        var components: [String] = []

        let details = orderedModifierDescriptions(for: modifierKeyCodes)
        components.append(contentsOf: details.labels)

        let remaining = modifiers.subtracting(details.flagsCovered)
        if remaining.contains(.function) { components.append("fn") }
        if remaining.contains(.control) { components.append("⌃") }
        if remaining.contains(.option) { components.append("⌥") }
        if remaining.contains(.shift) { components.append("⇧") }
        if remaining.contains(.command) { components.append("⌘") }

        // Add keys
        let keyNames = keys.map { keyDisplayName($0) }
        components.append(contentsOf: keyNames)

        return components.joined(separator: " + ")
    }

    private func describeModifiersOnly(modifiers: NSEvent.ModifierFlags, keyCodes: [UInt16]) -> String {
        let details = orderedModifierDescriptions(for: keyCodes)
        var parts = details.labels

        let remaining = modifiers.subtracting(details.flagsCovered)
        if remaining.contains(.function) { parts.append("fn") }
        if remaining.contains(.control) { parts.append("⌃") }
        if remaining.contains(.option) { parts.append("⌥") }
        if remaining.contains(.shift) { parts.append("⇧") }
        if remaining.contains(.command) { parts.append("⌘") }

        if parts.isEmpty {
            var fallback = ""
            if modifiers.contains(.function) { fallback += "fn" }
            if modifiers.contains(.control) { fallback += "⌃" }
            if modifiers.contains(.option) { fallback += "⌥" }
            if modifiers.contains(.shift) { fallback += "⇧" }
            if modifiers.contains(.command) { fallback += "⌘" }
            return fallback
        }

        return parts.joined(separator: " + ")
    }

    private func orderedModifierDescriptions(for keyCodes: [UInt16]) -> (labels: [String], flagsCovered: NSEvent.ModifierFlags) {
        guard !keyCodes.isEmpty else { return ([], []) }
        let mapping: [UInt16: (label: String, flag: NSEvent.ModifierFlags, order: Int)] = [
            63: ("Fn", .function, 0),
            59: ("Control ⌃", .control, 1),
            62: ("Control ⌃", .control, 1),
            58: ("Left ⌥", .option, 2),
            61: ("Right ⌥", .option, 2),
            56: ("Left ⇧", .shift, 3),
            60: ("Right ⇧", .shift, 3),
            55: ("Left ⌘", .command, 4),
            54: ("Right ⌘", .command, 4)
        ]

        var flagsCovered: NSEvent.ModifierFlags = []
        let ordered = keyCodes.compactMap { mapping[$0] }.sorted { lhs, rhs in
            if lhs.order == rhs.order { return lhs.label < rhs.label }
            return lhs.order < rhs.order
        }
        var usedLabels = Set<String>()
        var labels: [String] = []
        ordered.forEach { element in
            flagsCovered.insert(element.flag)
            if usedLabels.insert(element.label).inserted {
                labels.append(element.label)
            }
        }
        return (labels, flagsCovered)
    }

    private func keyDisplayName(_ keyCode: UInt16) -> String {
        // Friendly names for common keys
        switch keyCode {
        case 53: return "Escape"
        case 36: return "Return"
        case 48: return "Tab"
        case 49: return "Space"
        default:
            return keyName(from: keyCode)
        }
    }
    
    private func keyName(from keyCode: UInt16) -> String {
        switch keyCode {
        // Letters (US ANSI mapping)
        case 0: return "A"
        case 1: return "S"
        case 2: return "D"
        case 3: return "F"
        case 4: return "H"
        case 5: return "G"
        case 6: return "Z"
        case 7: return "X"
        case 8: return "C"
        case 9: return "V"
        case 11: return "B"
        case 12: return "Q"
        case 13: return "W"
        case 14: return "E"
        case 15: return "R"
        case 16: return "Y"
        case 17: return "T"
        case 31: return "O"
        case 32: return "U"
        case 34: return "I"
        case 35: return "P"
        case 37: return "L"
        case 38: return "J"
        case 39: return "'"
        case 40: return "K"
        case 41: return ";"
        case 42: return "\\"
        case 43: return ","
        case 44: return "/"
        case 45: return "N"
        case 46: return "M"
        case 47: return "."
        case 50: return "`"
        // Numbers (top row)
        case 18: return "1"
        case 19: return "2"
        case 20: return "3"
        case 21: return "4"
        case 22: return "6"
        case 23: return "5"
        case 25: return "9"
        case 26: return "7"
        case 28: return "8"
        case 29: return "0"
        // Symbols (top row)
        case 24: return "="
        case 27: return "-"
        case 30: return "]"
        case 33: return "["
        // Function keys
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
        // Arrows & navigation
        case 123: return "Left Arrow"
        case 124: return "Right Arrow"
        case 125: return "Down Arrow"
        case 126: return "Up Arrow"
        case 114: return "Help"
        case 115: return "Home"
        case 116: return "Page Up"
        case 119: return "End"
        case 121: return "Page Down"
        case 51: return "Delete"
        case 117: return "Forward Delete"
        case 71: return "Clear"
        case 76: return "Enter"
        case 57: return "Caps Lock"
        // Keypad (common ones)
        case 82: return "Keypad 0"
        case 83: return "Keypad 1"
        case 84: return "Keypad 2"
        case 85: return "Keypad 3"
        case 86: return "Keypad 4"
        case 87: return "Keypad 5"
        case 88: return "Keypad 6"
        case 89: return "Keypad 7"
        case 91: return "Keypad 8"
        case 92: return "Keypad 9"
        case 65: return "Keypad ."
        case 67: return "Keypad *"
        case 69: return "Keypad +"
        case 75: return "Keypad /"
        case 78: return "Keypad -"
        case 81: return "Keypad ="
        default:
            // Fallback: return the raw keyCode for transparency
            return "Key \(keyCode)"
        }
    }
    
    private func startRecording() {
        isRecording = true
        currentKey = nil
        currentModifiers = []
        peakModifiers = []
        peakModifierKeyCodes.removeAll()
        activeModifierKeyCodes.removeAll()
        chordKeys.removeAll()
        chordModifierKeyCodes.removeAll()
        capturedComboKeys.removeAll()
        capturedModifierKeyCodes = []
        chordTimer?.cancel(); chordTimer = nil
        // Ensure app is active and can receive key events
        NSApp.activate(ignoringOtherApps: true)
        
        // Try to make the window key and frontmost to capture all events
        DispatchQueue.main.async {
            if let window = NSApp.keyWindow {
                window.level = .floating
                window.makeKeyAndOrderFront(nil)
            }
        }
        
        monitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .keyUp, .flagsChanged]) { event in
            handleEvent(event)
            return nil // Consume the event to prevent system handling
        }
        // Global monitor to catch events even when app loses focus
        globalFlagsMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.flagsChanged, .keyDown]) { event in
            handleEvent(event)
        }

        // Activate a scoped CGEvent tap to capture F-keys before system features (e.g., Dictation)
        startEventTap()
    }
    
    private func stopRecording() {
        isRecording = false
        if let monitor = monitor { NSEvent.removeMonitor(monitor); self.monitor = nil }
        if let gm = globalFlagsMonitor { NSEvent.removeMonitor(gm); self.globalFlagsMonitor = nil }
        stopEventTap()
        
        // Reset window level
        DispatchQueue.main.async {
            if let window = NSApp.keyWindow {
                window.level = .normal
            }
        }
    }
    
    private func handleEvent(_ event: NSEvent) {
        print("🎹 [CAPTURE] Event: \(event.type.rawValue), keyCode: \(event.keyCode), modifiers: \(event.modifierFlags)")
        
        // Special handling for function keys - they might come as different event types
        if event.modifierFlags.contains(.function) {
            print("🎹 [CAPTURE] Function modifier detected! KeyCode: \(event.keyCode)")
        }
        
        let rawKeyCode = UInt16(event.keyCode)
        let normalizedKeyCode = normalizeFnKeyCode(rawKeyCode)

        switch event.type {
        case .flagsChanged:
            if event.modifierFlags.contains(.function) {
                isFnPressed = true
            } else if isFnPressed && !isAnyFnKeyDown() {
                isFnPressed = false
            }

            var modifiers = event.modifierFlags.intersection([.command, .option, .shift, .control])
            let fnCurrentlyDown = isFnPressed || isAnyFnKeyDown()
            if fnCurrentlyDown {
                modifiers.insert(.function)
                activeModifierKeyCodes.insert(63)
            } else {
                activeModifierKeyCodes.remove(63)
            }
            currentModifiers = modifiers

            if !isFnKeyCode(rawKeyCode) {
                updateActiveModifierKeyCodes(with: event)
            }

            capturedModifierKeyCode = normalizeFnKeyCode(rawKeyCode)
            updatePeakModifiers(with: currentModifiers, keyCodes: activeModifierKeyCodes)
            scheduleModifiersFinalize()

        case .keyDown:
            // Escape cancels when recording
            if rawKeyCode == 53 { stopRecording(); onCancel(); return }
            // Backspace/Delete clears current selection
            if rawKeyCode == 51 || rawKeyCode == 117 {
                clearSelection()
                return
            }

            if normalizedKeyCode == 63 {
                isFnPressed = true
                currentModifiers.insert(.function)
                activeModifierKeyCodes.insert(63)
                capturedModifierKeyCode = 63
                updatePeakModifiers(with: currentModifiers, keyCodes: activeModifierKeyCodes)
                scheduleModifiersFinalize()
                return
            }

            if !isModifierKey(rawKeyCode) {
                print("🎹 [CAPTURE] Non-modifier key: \(rawKeyCode) (\(keyDisplayName(rawKeyCode)))")
                // Build chord within a brief window
                chordKeys.insert(rawKeyCode)
                // Ensure Fn is reflected if it's held through hardware that doesn't set modifierFlags
                var modifiersSnapshot = currentModifiers
                if isFnPressed { modifiersSnapshot.insert(.function) }
                chordModifiers = modifiersSnapshot
                chordModifierKeyCodes = activeModifierKeyCodes
                scheduleChordFinalize()
            }

        case .keyUp:
            if normalizedKeyCode == 63 {
                isFnPressed = false
                currentModifiers.remove(.function)
                activeModifierKeyCodes.remove(63)
                capturedModifierKeyCode = 63
                updatePeakModifiers(with: currentModifiers, keyCodes: activeModifierKeyCodes)
                scheduleModifiersFinalize()
            }

        default:
            break
        }
    }

    private func scheduleChordFinalize() {
        chordTimer?.cancel()
        modifiersTimer?.cancel(); modifiersTimer = nil
        let work = DispatchWorkItem { [chordKeys, chordModifiers, chordModifierKeyCodes] in
            capturedComboKeys = Array(chordKeys).sorted()
            capturedComboModifiers = chordModifiers
            capturedModifierKeyCodes = Array(chordModifierKeyCodes).sorted()
        }
        chordTimer = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: work)
    }

    private func scheduleModifiersFinalize() {
        modifiersTimer?.cancel()
        let work = DispatchWorkItem { [peakModifiers, peakModifierKeyCodes, capturedModifierKeyCode] in
            guard capturedComboKeys.isEmpty else { return }
            capturedComboKeys = []
            capturedComboModifiers = peakModifiers
            let codes = peakModifierKeyCodes.isEmpty ? (capturedModifierKeyCode.map { [$0] } ?? []) : Array(peakModifierKeyCodes)
            capturedModifierKeyCodes = codes.sorted()
        }
        modifiersTimer = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: work)
    }
    
    private func isModifierKey(_ keyCode: UInt16) -> Bool {
        let normalized = normalizeFnKeyCode(keyCode)
        return normalized == 55 || normalized == 54 || normalized == 58 || normalized == 61 || normalized == 59 || normalized == 62 || normalized == 56 || normalized == 60 || normalized == 63
    }
    
    private func isValidShortcut() -> Bool {
        // At least one non-modifier key or a modifier-only selection
        return !capturedComboKeys.isEmpty || !capturedComboModifiers.isEmpty
    }
    
    private func saveShortcut() {
        // Prefer a key + modifiers for the library. If user chose modifiers only, create a placeholder key (e.g., F17) is not desired.
        // Here we only save when a non-modifier key is chosen; modifiers-only will be handled in HotkeyManager in future if needed.
        if capturedComboKeys.count == 1 {
            let keyCode = capturedComboKeys[0]
            let key: KeyboardShortcuts.Key = {
                switch keyCode {
                case 122: return .f1
                case 120: return .f2
                case 99: return .f3
                case 118: return .f4
                case 96: return .f5
                case 97: return .f6
                case 98: return .f7
                case 100: return .f8
                case 101: return .f9
                case 109: return .f10
                case 103: return .f11
                case 111: return .f12
                case 53: return .escape
                case 36: return .return
                case 48: return .tab
                case 49: return .space
                default:
                    return KeyboardShortcuts.Key(rawValue: Int(keyCode))
                }
            }()
            let shortcut = KeyboardShortcuts.Shortcut(key, modifiers: capturedComboModifiers)
            stopRecording()
            onSave(.shortcut(shortcut))
        } else if capturedComboKeys.count > 1 {
            stopRecording()
            onSave(.combination(keys: capturedComboKeys,
                                 modifiers: capturedComboModifiers,
                                 modifierKeyCodes: capturedModifierKeyCodes))
        } else {
            stopRecording()
            let codes = capturedModifierKeyCodes.isEmpty ? (capturedModifierKeyCode.map { [$0] } ?? []) : capturedModifierKeyCodes
            onSave(.modifierOnly(keyCodes: codes, modifiers: capturedComboModifiers))
        }
    }
}


// Helper relay class used to bridge CGEventTap callback back to Swift code
private final class EventTapRelay {
    var onEvent: ((NSEvent) -> Void)?
}

// MARK: - CGEventTap integration
extension ShortcutCaptureModal {
    private func openFirstWorkingURL(_ urls: [String]) {
        for raw in urls {
            if let url = URL(string: raw), NSWorkspace.shared.open(url) {
                return
            }
        }
    }
    private func handleKeyDownFromTap(normalizedKeyCode: UInt16) {
        if !isModifierKey(normalizedKeyCode) {
            chordKeys.insert(normalizedKeyCode)
            chordModifiers = currentModifiers
            scheduleChordFinalize()
        }
    }
    private func startEventTap() {
        // Avoid duplicate taps
        stopEventTap()
        eventTapRelay.onEvent = { nsEvent in
            handleEvent(nsEvent)
        }
        // We want keyDown/keyUp/flagsChanged
        let mask = (
            (1 << CGEventType.keyDown.rawValue) |
            (1 << CGEventType.keyUp.rawValue) |
            (1 << CGEventType.flagsChanged.rawValue)
        )
        let callback: CGEventTapCallBack = { _, type, cgEvent, refcon in
            guard let refcon = refcon else { return Unmanaged.passRetained(cgEvent) }
            let relay = Unmanaged<EventTapRelay>.fromOpaque(refcon).takeUnretainedValue()
            // Convert when possible
            if type == .keyDown || type == .keyUp || type == .flagsChanged,
               let nsEvent = NSEvent(cgEvent: cgEvent) {
                let raw = Int(cgEvent.getIntegerValueField(.keyboardEventKeycode))
                let rawU16 = UInt16(truncatingIfNeeded: raw)
                var normalized = rawU16
                if fnAlternateKeyCodes.contains(rawU16) {
                    normalized = 63
                } else if (176...187).contains(raw) {
                    normalized = UInt16(raw - 80)
                }

                let functionKeyCodes: Set<Int> = [122, 120, 99, 118, 96, 97, 98, 100, 101, 109, 103, 111]
                let isFunctionKey = functionKeyCodes.contains(Int(normalized))

                let dispatchedEvent: NSEvent
                if let copy = cgEvent.copy() {
                    copy.setIntegerValueField(.keyboardEventKeycode, value: Int64(normalized))
                    dispatchedEvent = NSEvent(cgEvent: copy) ?? nsEvent
                } else {
                    dispatchedEvent = nsEvent
                }

                DispatchQueue.main.async { relay.onEvent?(dispatchedEvent) }

                if type == .keyDown && isFunctionKey {
                    // Swallow to prevent Dictation when capturing standard F-keys
                    return nil
                }
            }
            return Unmanaged.passRetained(cgEvent)
        }
        let relayPtr = Unmanaged.passUnretained(eventTapRelay).toOpaque()
        guard let tap = CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(mask),
            callback: callback,
            userInfo: relayPtr
        ) else {
            return
        }
        eventTap = tap
        if let src = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0) {
            eventTapRunLoopSource = src
            CFRunLoopAddSource(CFRunLoopGetCurrent(), src, .commonModes)
            CGEvent.tapEnable(tap: tap, enable: true)
        }
    }
    private func stopEventTap() {
        if let src = eventTapRunLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), src, .commonModes)
            eventTapRunLoopSource = nil
        }
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
            eventTap = nil
        }
    }
}

// MARK: - Modifier aggregation helpers
extension ShortcutCaptureModal {
    private func countModifiers(_ mods: NSEvent.ModifierFlags) -> Int {
        var c = 0
        if mods.contains(.function) { c += 1 }
        if mods.contains(.control) { c += 1 }
        if mods.contains(.option) { c += 1 }
        if mods.contains(.shift) { c += 1 }
        if mods.contains(.command) { c += 1 }
        return c
    }
    private func updatePeakModifiers(with mods: NSEvent.ModifierFlags, keyCodes: Set<UInt16>) {
        // Prefer the larger set; if equal size, prefer the latest or the set with more precise side information
        let newCount = countModifiers(mods)
        let existingCount = countModifiers(peakModifiers)
        let shouldReplace = newCount > existingCount
            || (newCount == existingCount && (keyCodes.count >= peakModifierKeyCodes.count))

        if shouldReplace {
            peakModifiers = mods
            peakModifierKeyCodes = keyCodes
        }
    }

    private func updateActiveModifierKeyCodes(with event: NSEvent) {
        let rawCode = UInt16(event.keyCode)
        guard isModifierKey(rawCode) else { return }

        if isFnKeyCode(rawCode) {
            // Fn is tracked separately because some keyboards omit the modifier flag.
            return
        }

        let isPressed = CGEventSource.keyState(.combinedSessionState, key: CGKeyCode(rawCode))
        if isPressed {
            activeModifierKeyCodes.insert(normalizeFnKeyCode(rawCode))
        } else {
            activeModifierKeyCodes.remove(normalizeFnKeyCode(rawCode))
        }
    }
}
