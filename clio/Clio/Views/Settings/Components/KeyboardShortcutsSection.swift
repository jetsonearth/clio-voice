import SwiftUI
import KeyboardShortcuts
import AppKit

struct KeyboardShortcutsSection: View {
    @EnvironmentObject private var hotkeyManager: HotkeyManager
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var showShortcutCapture = false
    @State private var showQuickRecordCapture = false
    @State private var showHandsFreeCapture = false
    @State private var showAssistantCapture = false
    @State private var dictationShortcutDisplay: String = ""
    
    private var currentShortcutDescription: String {
        if !dictationShortcutDisplay.isEmpty { return dictationShortcutDisplay }
        return hotkeyManager.getCurrentShortcutDescription() ?? localizationManager.localizedString("settings.edit_key")
    }
    
    @AppStorage("handsFreeShortcutDisplay") private var handsFreeShortcutDisplay: String = ""
    @AppStorage("assistantShortcutDisplay") private var assistantShortcutDisplay: String = ""
    
    private var handsFreeDescription: String {
        handsFreeShortcutDisplay.isEmpty ? localizationManager.localizedString("settings.edit_key") : handsFreeShortcutDisplay
    }
    
    private var assistantDescription: String {
        if !assistantShortcutDisplay.isEmpty { return assistantShortcutDisplay }
        if let desc = hotkeyManager.assistantShortcut?.description, !desc.isEmpty { return desc }
        return localizationManager.localizedString("settings.edit_key")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Small header outside the card
            Text(localizationManager.localizedString("settings.keyboard_shortcuts.header"))
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(DarkTheme.textSecondary.opacity(0.8))
                .textCase(.uppercase)
                .tracking(0.5)
            
            // Unified card with multiple sections
            VStack(spacing: 0) {
                // Dictation Hotkey section
                shortcutRow(
                    icon: "square.and.pencil",
                    title: localizationManager.localizedString("settings.dictation_hotkey.title"),
                    subtitle: localizationManager.localizedString("settings.dictation_hotkey.description"),
                    description: currentShortcutDescription,
                    action: { showShortcutCapture = true },
                    resetAction: {
                        hotkeyManager.clearDictationHotkey()
                        dictationShortcutDisplay = ""
                    }
                )
                
                // Divider
                Rectangle()
                    .fill(DarkTheme.textSecondary.opacity(0.2))
                    .frame(height: 1)
                    .padding(.horizontal, 16)
                
                // Hands-free Mode section
                shortcutRow(
                    icon: "square.and.pencil",
                    title: localizationManager.localizedString("settings.hands_free_mode.title"), 
                    subtitle: localizationManager.localizedString("settings.hands_free_mode.description"),
                    description: handsFreeDescription,
                    action: { showHandsFreeCapture = true },
                    resetAction: {
                        hotkeyManager.clearHandsFreeHotkey()
                        handsFreeShortcutDisplay = ""
                    }
                )
                
                // Divider
                Rectangle()
                    .fill(DarkTheme.textSecondary.opacity(0.2))
                    .frame(height: 1)
                    .padding(.horizontal, 16)
                
                // Clio Assistant Mode section
                shortcutRow(
                    icon: "pencil.circle.fill",
                    title: localizationManager.localizedString("settings.assistant_mode.title"),
                    subtitle: localizationManager.localizedString("settings.assistant_mode.description"),
                    description: assistantDescription,
                    action: { showAssistantCapture = true },
                    resetAction: {
                        hotkeyManager.clearAssistantHotkey()
                        assistantShortcutDisplay = ""
                    }
                )
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(DarkTheme.textPrimary.opacity(0.03))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(DarkTheme.textPrimary.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .sheet(isPresented: $showShortcutCapture) {
            ShortcutCaptureModal(
                onSave: { result in
                    switch result {
                    case .shortcut(let shortcut):
                        KeyboardShortcuts.setShortcut(shortcut, for: .toggleMiniRecorder)
                        hotkeyManager.customShortcut = nil
                        hotkeyManager.isPushToTalkEnabled = false
                        dictationShortcutDisplay = shortcut.clioDescription()
                        
                    case .combination(let keys, let modifiers, let modifierKeyCodes):
                        let customShortcut = CustomShortcut(
                            keys: keys,
                            modifiers: modifiers.rawValue,
                            keyCode: nil,
                            modifierKeyCodes: modifierKeyCodes
                        )
                        KeyboardShortcuts.setShortcut(nil, for: .toggleMiniRecorder)
                        hotkeyManager.customShortcut = customShortcut
                        hotkeyManager.isPushToTalkEnabled = false
                        dictationShortcutDisplay = customShortcut.description
                        
                    case .modifierOnly(let keyCodes, let modifiers):
                        let customShortcut = CustomShortcut(
                            keys: [],
                            modifiers: modifiers.rawValue,
                            keyCode: keyCodes.first,
                            modifierKeyCodes: keyCodes
                        )
                        KeyboardShortcuts.setShortcut(nil, for: .toggleMiniRecorder)
                        hotkeyManager.customShortcut = customShortcut
                        hotkeyManager.isPushToTalkEnabled = false
                        dictationShortcutDisplay = customShortcut.description
                    }
                    hotkeyManager.updateShortcutStatus()
                    showShortcutCapture = false
                },
                onCancel: { showShortcutCapture = false }
            )
        }
        .sheet(isPresented: $showQuickRecordCapture) {
            ShortcutCaptureModal(
                onSave: { result in
                    // TODO: Handle quick record shortcuts
                    showQuickRecordCapture = false
                },
                onCancel: { showQuickRecordCapture = false }
            )
        }
        .sheet(isPresented: $showHandsFreeCapture) {
            ShortcutCaptureModal(
                onSave: { result in
                    // Persist and activate hands-free shortcut
                    switch result {
                    case .shortcut(let sc):
                        // Convert library shortcut to CustomShortcut form for unified handling
                        let keyCode = sc.key?.rawValue != nil ? UInt16(sc.key!.rawValue) : nil
                        let cs = CustomShortcut(keys: keyCode != nil ? [keyCode!] : [],
                                                modifiers: sc.modifiers.rawValue,
                                                keyCode: nil,
                                                modifierKeyCodes: nil)
                        hotkeyManager.handsFreeShortcut = cs
                        self.handsFreeShortcutDisplay = cs.description
                    case .combination(let keys, let modifiers, let modifierKeyCodes):
                        let cs = CustomShortcut(keys: keys,
                                                modifiers: modifiers.rawValue,
                                                keyCode: nil,
                                                modifierKeyCodes: modifierKeyCodes)
                        hotkeyManager.handsFreeShortcut = cs
                        self.handsFreeShortcutDisplay = cs.description
                    case .modifierOnly(let keyCodes, let modifiers):
                        let cs = CustomShortcut(keys: [],
                                                modifiers: modifiers.rawValue,
                                                keyCode: keyCodes.first,
                                                modifierKeyCodes: keyCodes)
                        hotkeyManager.handsFreeShortcut = cs
                        self.handsFreeShortcutDisplay = cs.description
                    }
                    showHandsFreeCapture = false
                },
                onCancel: { showHandsFreeCapture = false }
            )
        }
        .sheet(isPresented: $showAssistantCapture) {
            ShortcutCaptureModal(
                onSave: { result in
                    // Persist and activate assistant (command mode) shortcut
                    switch result {
                    case .shortcut(let sc):
                        let keyCode = sc.key?.rawValue != nil ? UInt16(sc.key!.rawValue) : nil
                        let cs = CustomShortcut(keys: keyCode != nil ? [keyCode!] : [],
                                                modifiers: sc.modifiers.rawValue,
                                                keyCode: nil,
                                                modifierKeyCodes: nil)
                        hotkeyManager.assistantShortcut = cs
                        self.assistantShortcutDisplay = cs.description
                    case .combination(let keys, let modifiers, let modifierKeyCodes):
                        let cs = CustomShortcut(keys: keys,
                                                modifiers: modifiers.rawValue,
                                                keyCode: nil,
                                                modifierKeyCodes: modifierKeyCodes)
                        hotkeyManager.assistantShortcut = cs
                        self.assistantShortcutDisplay = cs.description
                    case .modifierOnly(let keyCodes, let modifiers):
                        let cs = CustomShortcut(keys: [],
                                                modifiers: modifiers.rawValue,
                                                keyCode: keyCodes.first,
                                                modifierKeyCodes: keyCodes)
                        hotkeyManager.assistantShortcut = cs
                        self.assistantShortcutDisplay = cs.description
                    }
                    showAssistantCapture = false
                },
                onCancel: { showAssistantCapture = false }
            )
        }
    }
    
    private func shortcutRow(icon: String, title: String, subtitle: String, description: String, isComingSoon: Bool = false, action: @escaping () -> Void, resetAction: (() -> Void)? = nil) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.accentColor)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(DarkTheme.textPrimary)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(DarkTheme.textSecondary)
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    if isComingSoon {
                        // Coming Soon badge
                        Text(localizationManager.localizedString("common.coming_soon"))
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.accentColor)
                            )
                    } else {
                        // Regular shortcut badge
                        HStack(spacing: 8) {
                            Image(systemName: "pencil")
                                .font(.system(size: 11))
                                .foregroundColor(DarkTheme.textSecondary.opacity(0.6))
                            Text(description)
                                .font(.system(size: 13))
                                .foregroundColor(DarkTheme.textPrimary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(DarkTheme.surfaceBackground)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(DarkTheme.border.opacity(0.3), lineWidth: 1)
                                )
                        )
                        
                        // Reset button (only show if there's a shortcut and reset action is provided)
                        if !description.isEmpty && description != localizationManager.localizedString("settings.edit_key") && resetAction != nil {
                            Button(action: {
                                resetAction?()
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.system(size: 11))
                                        .foregroundColor(DarkTheme.textSecondary.opacity(0.6))
                                    Text(localizationManager.localizedString("settings.keyboard_shortcuts.reset_hotkey"))
                                        .font(.system(size: 13))
                                        .foregroundColor(DarkTheme.textPrimary)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(DarkTheme.surfaceBackground)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(DarkTheme.border.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                            .help(localizationManager.localizedString("settings.keyboard_shortcuts.reset_hotkey"))
                        }
                    }
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .disabled(isComingSoon)
    }
    
    // MARK: - Render helpers for hands-free display
    private func renderDisplay(for result: ShortcutCaptureResult) -> String {
        switch result {
        case .shortcut(let sc):
            return sc.clioDescription()
        case .combination(let keys, let modifiers, let modifierKeyCodes):
            return describeCombination(keys: keys, modifiers: modifiers, modifierKeyCodes: modifierKeyCodes)
        case .modifierOnly(let keyCodes, let modifiers):
            return describeModifiersOnly(modifiers: modifiers, keyCodes: keyCodes)
        }
    }

    private func describeCombination(keys: [UInt16], modifiers: NSEvent.ModifierFlags, modifierKeyCodes: [UInt16]) -> String {
        var parts: [String] = []
        let details = orderedModifierDescriptions(for: modifierKeyCodes)
        parts.append(contentsOf: details.labels)

        let remaining = modifiers.subtracting(details.flagsCovered)
        if remaining.contains(.function) { parts.append("fn") }
        if remaining.contains(.control) { parts.append("⌃") }
        if remaining.contains(.option) { parts.append("⌥") }
        if remaining.contains(.shift) { parts.append("⇧") }
        if remaining.contains(.command) { parts.append("⌘") }

        parts.append(contentsOf: keys.map(keyDisplayName))
        return parts.joined(separator: " + ")
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
            if modifiers.contains(.function) { parts.append("fn") }
            if modifiers.contains(.control) { parts.append("⌃") }
            if modifiers.contains(.option) { parts.append("⌥") }
            if modifiers.contains(.shift) { parts.append("⇧") }
            if modifiers.contains(.command) { parts.append("⌘") }
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
        var labels: [String] = []
        var usedLabels = Set<String>()
        ordered.forEach { element in
            flagsCovered.insert(element.flag)
            if usedLabels.insert(element.label).inserted {
                labels.append(element.label)
            }
        }
        return (labels, flagsCovered)
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
        default: return "Key \(keyCode)"
        }
    }
}
