import SwiftUI

import SwiftData
import CoreAudio
import KeyboardShortcuts
import AVKit
import AVFoundation

// MARK: - Safe VideoPlayer Wrapper
/// A compatibility wrapper for VideoPlayer that handles potential crashes on certain macOS versions
struct SafeVideoPlayer: View {
    let player: AVPlayer
    let onAppear: () -> Void
    let onDisappear: () -> Void
    
    init(player: AVPlayer, onAppear: @escaping () -> Void = {}, onDisappear: @escaping () -> Void = {}) {
        self.player = player
        self.onAppear = onAppear
        self.onDisappear = onDisappear
    }
    
    var body: some View {
        Group {
            if #available(macOS 14.0, *) {
                // Use VideoPlayer for supported versions with error handling
                Group {
                    VideoPlayer(player: player)
                        .onAppear(perform: onAppear)
                        .onDisappear(perform: onDisappear)
                }
                .onAppear {
                    // Ensure we have a valid player item
                    if player.currentItem == nil {
                        print("⚠️ [SafeVideoPlayer] No player item found")
                    }
                }
            } else {
                // Fallback for older versions
                FallbackVideoView(player: player, onAppear: onAppear, onDisappear: onDisappear)
            }
        }
    }
}

// MARK: - Fallback Video View
struct FallbackVideoView: View {
    let player: AVPlayer
    let onAppear: () -> Void
    let onDisappear: () -> Void
    
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(DarkTheme.textPrimary.opacity(0.1))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(
                VStack(spacing: 12) {
                    Image(systemName: "play.rectangle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(DarkTheme.textPrimary.opacity(0.6))
                    
                    Text("Video Preview")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(DarkTheme.textPrimary.opacity(0.8))
                    
                    Text("Video playback not supported on this macOS version")
                        .font(.system(size: 12))
                        .foregroundColor(DarkTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }
            )
            .onAppear(perform: onAppear)
            .onDisappear(perform: onDisappear)
    }
}

// MARK: - Enhanced Setup View with Two-Column Layout
struct EnhancedSetupView: View {
    @ObservedObject var viewModel: ProfessionalOnboardingViewModel
    @Binding var hasCompletedOnboarding: Bool
    @EnvironmentObject private var hotkeyManager: HotkeyManager
    @EnvironmentObject private var whisperState: WhisperState
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var selectedKey: HotkeyManager.PushToTalkKey = .rightCommand
    // Local model selection disabled; keep placeholder only if flag is enabled.
#if CLIO_ENABLE_LOCAL_MODEL
    @State private var selectedModel: WhisperModelSize = .base
#endif
    @State private var selectedDevice: (id: AudioDeviceID, name: String)?
    @State private var currentSetupStep: SetupStep = .keyboard
    
    enum SetupStep: Int, CaseIterable {
        case keyboard = 0
        case microphone = 1
        case complete = 2
    }
    
    var body: some View {
        ZStack {
            // Main content - centered single column
            VStack(spacing: 0) {
                VStack(spacing: 32) {
                    Group {
                        switch currentSetupStep {
                        case .keyboard:
                            KeyboardSetupContent(
                                onContinue: {
                                    // Go to try it page next
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                        viewModel.nextScreen()
                                    }
                                },
                                onBack: handleBack
                            )
                        case .microphone:
                            MicrophoneSetupContent(
                                selectedDevice: $selectedDevice,
                                onContinue: {
                                    // Skip complete page, go directly to next screen
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                        viewModel.nextScreen()
                                    }
                                },
                                onBack: handleBack
                            )
                        case .complete:
                            SetupCompleteContent(
                                onContinue: {
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                        viewModel.nextScreen()
                                    }
                                },
                                onBack: handleBack
                            )
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                }
                .frame(maxWidth: 600)
                .padding(.horizontal, 60)
                .padding(.top, 40)
                .padding(.bottom, 40)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            // Header controls overlaid at top
            VStack {
                OnboardingHeaderControls()
                Spacer()
            }
        }
        .frame(minWidth: 1200, minHeight: 800)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentSetupStep)
        .onAppear {
            // Initialize selectedKey from hotkeyManager's current value
            selectedKey = hotkeyManager.pushToTalkKey
        }
    }
    
    private func handleBack() {
        if currentSetupStep == .keyboard {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                viewModel.previousScreen()
            }
        } else {
            switch currentSetupStep {
            case .microphone:
                currentSetupStep = .keyboard
            case .complete:
                currentSetupStep = .microphone
            default:
                break
            }
        }
    }
    
    private func configureDefaultMicrophone() {
        // Auto-configure MacBook Pro Microphone or system default
        let audioDeviceManager = AudioDeviceManager.shared
        audioDeviceManager.loadAvailableDevices()
        
        // First try to find MacBook Pro Microphone
        if let macbookMic = audioDeviceManager.availableDevices.first(where: { $0.name.localizedCaseInsensitiveContains("MacBook Pro Microphone") }) {
            selectedDevice = (macbookMic.id, macbookMic.name)
        } else if let defaultDevice = audioDeviceManager.availableDevices.first(where: { $0.id == audioDeviceManager.fallbackDeviceID }) {
            selectedDevice = (defaultDevice.id, defaultDevice.name)
        }
    }
}


// MARK: - Right Column Step Indicator
struct RightColumnStepIndicator: View {
    let currentStep: EnhancedSetupView.SetupStep
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach([localizationManager.localizedString("onboarding.enhanced_setup.step_keyboard"), localizationManager.localizedString("onboarding.enhanced_setup.step_microphone")], id: \.self) { stepName in
                let stepEnum = stepFromName(stepName)
                let isActive = currentStep == stepEnum
                let isCompleted = currentStep.rawValue > stepEnum.rawValue
                
                HStack(spacing: 12) {
                    // Progress line
                    VStack {
                        Circle()
                            .fill(isCompleted ? DarkTheme.textPrimary : (isActive ? DarkTheme.textPrimary.opacity(0.8) : DarkTheme.textSecondary.opacity(0.3)))
                            .frame(width: 10, height: 10)
                            .overlay(
                                Circle()
                                    .stroke(isActive ? DarkTheme.textPrimary.opacity(0.3) : Color.clear, lineWidth: 3)
                                    .scaleEffect(1.5)
                            )
                        
                        if stepName != localizationManager.localizedString("onboarding.enhanced_setup.step_microphone") {
                            Rectangle()
                                .fill(DarkTheme.textSecondary.opacity(0.2))
                                .frame(width: 1, height: 24)
                        }
                    }
                    
                    // Step label
                    VStack(alignment: .leading, spacing: 2) {
                        Text(stepName)
                            .font(.system(size: 14, weight: isActive ? .semibold : .medium))
                            .foregroundColor(isActive ? DarkTheme.textPrimary : DarkTheme.textSecondary.opacity(0.8))
                        
                        if isActive {
                            Text(localizationManager.localizedString("onboarding.enhanced_setup.in_progress"))
                                .font(.system(size: 11))
                                .foregroundColor(DarkTheme.textSecondary.opacity(0.6))
                        } else if isCompleted {
                            Text(localizationManager.localizedString("onboarding.enhanced_setup.complete"))
                                .font(.system(size: 11))
                                .foregroundColor(DarkTheme.textPrimary.opacity(0.6))
                        }
                    }
                    
                    Spacer()
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(DarkTheme.textSecondary.opacity(0.1), lineWidth: 1)
        )
    }
    
    private func stepFromName(_ name: String) -> EnhancedSetupView.SetupStep {
        switch name {
        case localizationManager.localizedString("onboarding.enhanced_setup.step_keyboard"): return .keyboard
        case localizationManager.localizedString("onboarding.enhanced_setup.step_microphone"): return .microphone
        default: return .keyboard
        }
    }
}


// MARK: - Keyboard Setup Content
struct KeyboardSetupContent: View {
    @EnvironmentObject private var localizationManager: LocalizationManager
    @EnvironmentObject private var hotkeyManager: HotkeyManager
    @State private var showShortcutCapture = false
    @State private var showHandsFreeCapture = false
    @State private var hasSetShortcut = false
    let onContinue: () -> Void
    let onBack: () -> Void
    
    private var currentShortcutDescription: String {
        return hotkeyManager.getCurrentShortcutDescription() ?? "No shortcut set"
    }
    
    @AppStorage("handsFreeShortcutDisplay") private var handsFreeShortcutDisplay: String = ""
    
    private var handsFreeDescription: String {
        handsFreeShortcutDisplay.isEmpty ? localizationManager.localizedString("settings.edit_key") : handsFreeShortcutDisplay
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 12) {
                Text(localizationManager.localizedString("onboarding.enhanced_setup.choose_hotkey"))
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(DarkTheme.textPrimary)
                
                Text(localizationManager.localizedString("onboarding.enhanced_setup.hotkey_description"))
                    .font(.system(size: 16))
                    .foregroundColor(DarkTheme.textSecondary)
            }
            
            // Keyboard shortcuts cards (same style as settings)
            VStack(spacing: 0) {
                // Dictation Hotkey section
                shortcutRow(
                    icon: "square.and.pencil",
                    title: localizationManager.localizedString("settings.dictation_hotkey.title"),
                    subtitle: localizationManager.localizedString("settings.dictation_hotkey.description"),
                    description: currentShortcutDescription,
                    action: { showShortcutCapture = true }
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
                    action: { showHandsFreeCapture = true }
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
                        
            // Two-column button layout
            HStack(spacing: 10) {
                StyledBackButton(action: onBack)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                StyledActionButton(
                    title: localizationManager.localizedString("general.continue"),
                    action: onContinue,
                    isDisabled: false // Allow continuing without setting shortcuts
                )
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.bottom, 60)
        }
        .sheet(isPresented: $showShortcutCapture) {
            ShortcutCaptureModal(
                onSave: { result in
                    switch result {
                    case .shortcut(let shortcut):
                        KeyboardShortcuts.setShortcut(shortcut, for: .toggleMiniRecorder)
                        hotkeyManager.customShortcut = nil
                        hotkeyManager.isPushToTalkEnabled = false
                        
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
                    }
                    hotkeyManager.updateShortcutStatus()
                    hasSetShortcut = true
                    showShortcutCapture = false
                },
                onCancel: { showShortcutCapture = false }
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
        .onAppear {
            // Check if a shortcut is already set
            hasSetShortcut = hotkeyManager.getCurrentShortcutDescription() != nil && hotkeyManager.getCurrentShortcutDescription() != "No shortcut set"
        }
    }
    
    // MARK: - Shortcut Row (copied from settings)
    private func shortcutRow(icon: String, title: String, subtitle: String, description: String, isComingSoon: Bool = false, action: @escaping () -> Void) -> some View {
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
}

// MARK: - Compact Key Option
struct CompactKeyOption: View {
    let key: HotkeyManager.PushToTalkKey
    let isSelected: Bool
    var isRecommended: Bool = false
    @EnvironmentObject private var localizationManager: LocalizationManager
    let action: () -> Void
    
    private var keySymbol: String {
        switch key {
        case .rightOption, .leftOption: return "⌥"
        case .leftControl, .rightControl: return "⌃"
        case .fn: return "fn"
        case .rightCommand, .leftCommand: return "⌘"
        case .rightShift, .leftShift: return "⇧"
        }
    }
    
    private var keyName: String {
        switch key {
        case .rightOption: return localizationManager.localizedString("onboarding.enhanced_setup.key_right_option")
        case .leftOption: return localizationManager.localizedString("onboarding.enhanced_setup.key_left_option")
        case .leftControl: return localizationManager.localizedString("onboarding.enhanced_setup.key_left_control")
        case .rightControl: return localizationManager.localizedString("onboarding.enhanced_setup.key_right_control")
        case .fn: return localizationManager.localizedString("onboarding.enhanced_setup.key_function")
        case .rightCommand: return localizationManager.localizedString("onboarding.enhanced_setup.key_right_command")
        case .leftCommand: return localizationManager.localizedString("onboarding.enhanced_setup.key_left_command")
        case .rightShift: return localizationManager.localizedString("onboarding.enhanced_setup.key_right_shift")
        case .leftShift: return localizationManager.localizedString("onboarding.enhanced_setup.key_left_shift")
        }
    }
    
    var body: some View {
        Button(action: action) {
            GlassmorphismCard(isSelected: isSelected, padding: 16) {
                HStack(spacing: 16) {
                    // Key icon
                    ZStack {
                        ZStack {
                            if isSelected {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(DarkTheme.textPrimary.opacity(0.1))
                            } else {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(NSColor.controlBackgroundColor).opacity(0.3))
                            }
                        }
                        .frame(width: 48, height: 48)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(DarkTheme.textPrimary.opacity(0.2), lineWidth: 1)
                        )
                        
                        Text(keySymbol)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(DarkTheme.textPrimary)
                    }
                    
                    // Key info
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(keyName)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(DarkTheme.textPrimary)
                            
                            if isRecommended {
                                Text(localizationManager.localizedString("onboarding.enhanced_setup.recommended"))
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(DarkTheme.textPrimary.opacity(0.8))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(4)
                            }
                        }
                        
                        Text(key == .rightCommand ? localizationManager.localizedString("onboarding.enhanced_setup.best_for_keyboards") : localizationManager.localizedString("onboarding.enhanced_setup.alternative_option"))
                            .font(.system(size: 14))
                            .foregroundColor(DarkTheme.textSecondary)
                    }
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(DarkTheme.textPrimary)
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Microphone Setup Content
struct MicrophoneSetupContent: View {
    @Binding var selectedDevice: (id: AudioDeviceID, name: String)?
    @StateObject private var audioDeviceManager = AudioDeviceManager.shared
    @EnvironmentObject private var localizationManager: LocalizationManager
    let onContinue: () -> Void
    let onBack: () -> Void
    @State private var showingMicPermission = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 12) {
                Text(localizationManager.localizedString("onboarding.enhanced_setup.select_microphone"))
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(DarkTheme.textPrimary)
                
                Text(localizationManager.localizedString("onboarding.enhanced_setup.microphone_description"))
                    .font(.system(size: 16))
                    .foregroundColor(DarkTheme.textSecondary)
            }
            
            // Microphone preview section
            if let selectedDevice = selectedDevice {
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(DarkTheme.textPrimary.opacity(0.1))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "mic.fill")
                                .font(.system(size: 18))
                                .foregroundColor(DarkTheme.textPrimary)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(localizationManager.localizedString("onboarding.enhanced_setup.selected_microphone"))
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(DarkTheme.textSecondary)
                            
                            Text(selectedDevice.name)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(DarkTheme.textPrimary)
                        }
                        
                        Spacer()
                        
                        // Audio level indicator (simulated)
                        HStack(spacing: 3) {
                            ForEach(0..<5) { index in
                                RoundedRectangle(cornerRadius: 1)
                                    .fill(index < 3 ? DarkTheme.textPrimary.opacity(0.6) : DarkTheme.textSecondary.opacity(0.2))
                                    .frame(width: 3, height: CGFloat(6 + index * 2))
                            }
                        }
                    }
                    .padding(16)
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(DarkTheme.textPrimary.opacity(0.1), lineWidth: 1)
                    )
                }
            }
            
            // Device list with enhanced scroll view
            if audioDeviceManager.availableDevices.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "mic.slash.circle")
                        .font(.system(size: 48))
                        .foregroundColor(DarkTheme.textSecondary)
                    
                    Text(localizationManager.localizedString("onboarding.enhanced_setup.no_microphones"))
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(DarkTheme.textPrimary)
                    
                    Text(localizationManager.localizedString("onboarding.enhanced_setup.connect_microphone"))
                        .font(.system(size: 14))
                        .foregroundColor(DarkTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(audioDeviceManager.availableDevices, id: \.id) { device in
                            EnhancedMicrophoneOption(
                                deviceId: device.id,
                                deviceName: device.name,
                                isDefault: device.id == audioDeviceManager.fallbackDeviceID,
                                isSelected: selectedDevice?.id == device.id,
                                action: {
                                    selectedDevice = (device.id, device.name)
                                }
                            )
                        }
                    }
                    .padding(.vertical, 8)
                }
                .frame(maxHeight: 280)
            }
            
            Spacer()
            
            // Two-column button layout
            HStack(spacing: 10) {
                StyledBackButton(action: onBack)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                StyledActionButton(
                    title: localizationManager.localizedString("general.continue"),
                    action: onContinue,
                    isDisabled: selectedDevice == nil
                )
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.bottom, 60)
        }
        .onAppear {
            audioDeviceManager.loadAvailableDevices()
            // Give a moment for devices to load, then select default
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if selectedDevice == nil {
                    // First try to find MacBook Pro Microphone
                    if let macbookMic = audioDeviceManager.availableDevices.first(where: { $0.name.localizedCaseInsensitiveContains("MacBook Pro Microphone") }) {
                        selectedDevice = (macbookMic.id, macbookMic.name)
                    } else if let defaultDevice = audioDeviceManager.availableDevices.first(where: { $0.id == audioDeviceManager.fallbackDeviceID }) {
                        selectedDevice = (defaultDevice.id, defaultDevice.name)
                    }
                }
            }
        }
    }
}

// MARK: - Enhanced Microphone Option
struct EnhancedMicrophoneOption: View {
    let deviceId: AudioDeviceID
    let deviceName: String
    let isDefault: Bool
    let isSelected: Bool
    @EnvironmentObject private var localizationManager: LocalizationManager
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            GlassmorphismCard(isSelected: isSelected, padding: 16) {
                HStack(spacing: 16) {
                    // Mic icon
                    ZStack {
                        Circle()
                            .fill(isSelected ? DarkTheme.textPrimary.opacity(0.2) : Color(NSColor.controlBackgroundColor))
                            .frame(width: 48, height: 48)
                            .overlay(
                                Circle()
                                    .stroke(isSelected ? DarkTheme.textPrimary : Color.secondary.opacity(0.3), lineWidth: isSelected ? 1 : 1)
                            )
                        
                        Image(systemName: "mic.fill")
                            .font(.system(size: 20))
                            .foregroundColor(isSelected ? DarkTheme.textPrimary : DarkTheme.textSecondary)
                    }
                    
                    // Device info
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(deviceName)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(DarkTheme.textPrimary)
                            
                            if isDefault {
                                Text(localizationManager.localizedString("onboarding.enhanced_setup.default"))
                                    .font(.system(size: 12))
                                    .foregroundColor(DarkTheme.textSecondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(.thinMaterial)
                                    .cornerRadius(4)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(DarkTheme.textPrimary)
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Model Setup Content (excluded when local models are disabled)
#if CLIO_ENABLE_LOCAL_MODEL
struct ModelSetupContent: View {
    @Binding var selectedModel: WhisperModelSize
    @EnvironmentObject private var whisperState: WhisperState
    @EnvironmentObject private var localizationManager: LocalizationManager
    let onContinue: () -> Void
    let onBack: () -> Void
    
    @State private var downloadingModels: Set<String> = []
    @State private var downloadProgress: [String: Double] = [:]
    @State private var selectedModelId: String = ""
    
    private var models: [(id: String, displayName: String, size: String, speed: Double, accuracy: Double, isComingSoon: Bool)] {
        return PredefinedModels.models.map { model in
            (id: model.name, displayName: model.displayName, size: model.size, speed: model.speed, accuracy: model.accuracy, isComingSoon: model.isComingSoon)
        }
    }
    
    var body: some View {
        Text("Model setup") // simplified body kept behind flag
    }
}
#endif

// MARK: - Enhanced Model Option
struct EnhancedModelOption: View {
    let modelId: String
    let displayName: String
    let size: String
    let speed: Double
    let accuracy: Double
    let isDownloaded: Bool
    let isDownloading: Bool
    let downloadProgress: Double
    let isSelected: Bool
    let isRecommended: Bool
    let isComingSoon: Bool
    @EnvironmentObject private var localizationManager: LocalizationManager
    let onSelect: () -> Void
    let onDownload: () -> Void
    
    var body: some View {
        Button(action: {
            if !isComingSoon {
                if isDownloaded {
                    onSelect()
                } else {
                    onDownload()
                }
            }
        }) {
            GlassmorphismCard(isSelected: isSelected, padding: 16) {
                HStack(spacing: 16) {
                    // Model info
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(displayName)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(DarkTheme.textPrimary)
                            
                            if isComingSoon {
                                HStack(spacing: 4) {
                                    Image(systemName: "clock.fill")
                                        .font(.system(size: 10))
                                        .foregroundColor(.orange)
                                    Text(localizationManager.localizedString("models.coming_soon"))
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(.orange)
                                )
                            } else if isRecommended {
                                Text(localizationManager.localizedString("onboarding.enhanced_setup.recommended"))
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(DarkTheme.background)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(DarkTheme.textPrimary)
                                    .cornerRadius(4)
                            }
                        }
                        
                        HStack(spacing: 16) {
                            Text(String(format: localizationManager.localizedString("onboarding.enhanced_setup.download_size"), size))
                                .font(.system(size: 13))
                                .foregroundColor(DarkTheme.textSecondary)
                            
                            Text(String(format: localizationManager.localizedString("onboarding.enhanced_setup.speed_rating"), String(format: "%.1f", speed * 10)))
                                .font(.system(size: 12))
                                .foregroundColor(DarkTheme.textSecondary)
                            
                            Text(String(format: localizationManager.localizedString("onboarding.enhanced_setup.accuracy_rating"), String(format: "%.1f", accuracy * 10)))
                                .font(.system(size: 12))
                                .foregroundColor(DarkTheme.textSecondary)
                        }
                        
                        if isDownloaded {
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 12))
                                Text(localizationManager.localizedString("onboarding.enhanced_setup.downloaded"))
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .foregroundColor(DarkTheme.textPrimary.opacity(0.7))
                        }
                    }
                    
                    Spacer()
                    
                    // Action button
                    if isDownloading {
                        // Download progress
                        VStack(spacing: 4) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: DarkTheme.textPrimary))
                                .scaleEffect(0.7)
                                .frame(width: 20, height: 20)
                            Text("\(Int(downloadProgress * 100))%")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(DarkTheme.textSecondary)
                        }
                        .frame(width: 50)
                    } else if isDownloaded {
                        ZStack {
                            Circle()
                                .fill(isSelected ? DarkTheme.textPrimary : Color.clear)
                                .frame(width: 20, height: 20)
                                .overlay(
                                    Circle()
                                        .stroke(isSelected ? DarkTheme.textPrimary : DarkTheme.textSecondary, lineWidth: 2)
                                )
                            
                            if isSelected {
                                Circle()
                                    .fill(DarkTheme.background)
                                    .frame(width: 6, height: 6)
                            }
                        }
                    } else if isComingSoon {
                        // Coming soon models - no download button
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.system(size: 13))
                            Text(localizationManager.localizedString("models.coming_soon"))
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(DarkTheme.textSecondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(DarkTheme.textSecondary.opacity(0.1))
                        )
                    } else {
                        HStack(spacing: 4) {
                            Image(systemName: size == "Cloud" ? "cloud" : "arrow.down.circle")
                                .font(.system(size: 13))
                            Text(localizationManager.localizedString(size == "Cloud" ? "onboarding.enhanced_setup.cloud_access" : "onboarding.enhanced_setup.download"))
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(DarkTheme.textPrimary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(DarkTheme.textPrimary.opacity(0.1))
                        )
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }
}


// MARK: - Setup Complete Content
struct SetupCompleteContent: View {
    let onContinue: () -> Void
    let onBack: () -> Void
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 40) {
            VStack(alignment: .leading, spacing: 16) {
                Text(localizationManager.localizedString("onboarding.enhanced_setup.all_set"))
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(DarkTheme.textPrimary)
                
                Text(localizationManager.localizedString("onboarding.enhanced_setup.ready_description"))
                    .font(.system(size: 18))
                    .foregroundColor(DarkTheme.textSecondary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            VStack(spacing: 20) {
                EnhancedFeatureCard(
                    icon: "command", 
                    title: localizationManager.localizedString("onboarding.enhanced_setup.feature_1_title"), 
                    subtitle: localizationManager.localizedString("onboarding.enhanced_setup.feature_1_subtitle"),
                    delay: 0.1
                )
                
                EnhancedFeatureCard(
                    icon: "waveform", 
                    title: localizationManager.localizedString("onboarding.enhanced_setup.feature_2_title"), 
                    subtitle: localizationManager.localizedString("onboarding.enhanced_setup.feature_2_subtitle"),
                    delay: 0.2
                )
                
                EnhancedFeatureCard(
                    icon: "brain.head.profile", 
                    title: localizationManager.localizedString("onboarding.enhanced_setup.feature_3_title"), 
                    subtitle: localizationManager.localizedString("onboarding.enhanced_setup.feature_3_subtitle"),
                    delay: 0.3
                )
                
                EnhancedFeatureCard(
                    icon: "sparkles", 
                    title: localizationManager.localizedString("onboarding.enhanced_setup.feature_4_title"), 
                    subtitle: localizationManager.localizedString("onboarding.enhanced_setup.feature_4_subtitle"),
                    delay: 0.4
                )
            }
            
            Spacer()
            
            // Two-column button layout
            HStack(spacing: 10) {
                StyledBackButton(action: onBack)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                StyledActionButton(
                    title: localizationManager.localizedString("onboarding.enhanced_setup.get_started"),
                    action: onContinue
                )
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.bottom, 60)
        }
        .onAppear {
            isAnimating = true
        }
    }
}


// MARK: - Setup Visual Column
struct SetupVisualColumn: View {
    let currentStep: EnhancedSetupView.SetupStep
    
    var body: some View {
        VStack(spacing: 0) {
            // Equal top spacing
            Rectangle()
                .fill(Color.clear)
                .frame(height: 80)
            
            // Step indicator with consistent positioning
            // HStack {
            //     Spacer()
            //     RightColumnStepIndicator(currentStep: currentStep)
            // }
            
            GlassmorphismCard(cornerRadius: 20, padding: 40) {
                Group {
                    switch currentStep {
                    case .keyboard:
                        KeyboardVisual()
                    case .microphone:
                        MicrophoneVisual()
                    case .complete:
                        CompleteVisual()
                    }
                }
                .frame(width: 340, height: 450)
                .transition(.opacity)
            }
            .frame(maxWidth: .infinity) // Center the card
            
            // Equal bottom spacing
            Rectangle()
                .fill(Color.clear)
                .frame(height: 80)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Visual Components
struct KeyboardVisual: View {
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var player: AVPlayer?
    
    var body: some View {
        Group {
            // Safe video player that handles potential crashes
            if let player = player {
                SafeVideoPlayer(
                    player: player,
                    onAppear: {
                        print("🎬 [KeyboardVisual] Starting video playback")
                        player.play()
                    },
                    onDisappear: {
                        print("🎬 [KeyboardVisual] Stopping video playback")
                        player.pause()
                    }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(DarkTheme.textPrimary.opacity(0.1))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: "play.circle")
                                .font(.system(size: 60))
                                .foregroundColor(DarkTheme.textPrimary.opacity(0.6))
                            
                            Text("Loading video...")
                                .font(.system(size: 14))
                                .foregroundColor(DarkTheme.textSecondary)
                        }
                    )
            }
        }
        .onAppear {
            setupVideoPlayer()
        }
    }
    
    private func setupVideoPlayer() {
        guard let videoURL = Bundle.main.url(forResource: "hotkey_onboard", withExtension: "mp4") else {
            print("❌ Could not find hotkey_onboard.mp4 in bundle")
            return
        }
        
        let playerItem = AVPlayerItem(url: videoURL)
        player = AVPlayer(playerItem: playerItem)
        
        // Loop the video
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { _ in
            player?.seek(to: .zero)
            player?.play()
        }
    }
}

struct MicrophoneVisual: View {
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var player: AVPlayer?
    
    var body: some View {
        Group {
            // Safe video player that handles potential crashes
            if let player = player {
                SafeVideoPlayer(
                    player: player,
                    onAppear: {
                        print("🎬 [MicrophoneVisual] Starting video playback")
                        player.play()
                    },
                    onDisappear: {
                        print("🎬 [MicrophoneVisual] Stopping video playback")
                        player.pause()
                    }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(DarkTheme.textPrimary.opacity(0.1))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: "play.circle")
                                .font(.system(size: 60))
                                .foregroundColor(DarkTheme.textPrimary.opacity(0.6))
                            
                            Text("Loading video...")
                                .font(.system(size: 14))
                                .foregroundColor(DarkTheme.textSecondary)
                        }
                    )
            }
        }
        .onAppear {
            setupVideoPlayer()
        }
    }
    
    private func setupVideoPlayer() {
        guard let videoURL = Bundle.main.url(forResource: "mic", withExtension: "mp4") else {
            print("❌ Could not find mic.mp4 in bundle")
            return
        }
        
        let playerItem = AVPlayerItem(url: videoURL)
        player = AVPlayer(playerItem: playerItem)
        
        // Loop the video
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { _ in
            player?.seek(to: .zero)
            player?.play()
        }
    }
}

// MARK: - Removed CustomVideoPlayerView (using simple VideoPlayer instead)


struct ModelVisual: View {
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "cpu")
                .font(.system(size: 80))
                .foregroundColor(DarkTheme.textPrimary)
            
            Text(localizationManager.localizedString("onboarding.enhanced_setup.visual_model_text"))
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.primary)
            
            HStack(spacing: 32) {
                VStack(spacing: 8) {
                    Image(systemName: "speedometer")
                        .font(.system(size: 30))
                        .foregroundColor(DarkTheme.textPrimary)
                    Text(localizationManager.localizedString("onboarding.enhanced_setup.visual_fast"))
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.shield")
                        .font(.system(size: 30))
                        .foregroundColor(DarkTheme.textPrimary)
                    Text(localizationManager.localizedString("onboarding.enhanced_setup.visual_accurate"))
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 8) {
                    Image(systemName: "lock.shield")
                        .font(.system(size: 30))
                        .foregroundColor(DarkTheme.textPrimary)
                    Text(localizationManager.localizedString("onboarding.enhanced_setup.visual_private"))
                        .font(.system(size: 14))
                        .foregroundColor(Color(white: 0.7))
                }
            }
        }
    }
}

struct CompleteVisual: View {
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var isAnimating = false
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 32) {
            // Success animation
            ZStack {
                // Pulsing background
                Circle()
                    .fill(DarkTheme.textPrimary.opacity(0.1))
                    .frame(width: 140, height: 140)
                    .scaleEffect(pulseScale)
                    .opacity(isAnimating ? 0.3 : 0.8)
                    .animation(
                        Animation.easeInOut(duration: 2.0)
                            .repeatForever(autoreverses: true),
                        value: pulseScale
                    )
                
                // Main circle
                Circle()
                    .fill(DarkTheme.textPrimary.opacity(0.15))
                    .frame(width: 100, height: 100)
                    .overlay(
                        Circle()
                            .stroke(DarkTheme.textPrimary.opacity(0.3), lineWidth: 2)
                    )
                
                // Checkmark with bounce animation
                Image(systemName: "checkmark")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(DarkTheme.textPrimary)
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                    .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.3), value: isAnimating)
            }
            
            VStack(spacing: 12) {
                Text(localizationManager.localizedString("onboarding.enhanced_setup.visual_perfect"))
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(DarkTheme.textPrimary)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.8).delay(0.6), value: isAnimating)
                
                Text(localizationManager.localizedString("onboarding.enhanced_setup.visual_ready"))
                    .font(.system(size: 16))
                    .foregroundColor(DarkTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.8).delay(0.9), value: isAnimating)
            }
            
            // Demo flow
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    Image(systemName: "1.circle.fill")
                        .foregroundColor(DarkTheme.textPrimary)
                    Text(localizationManager.localizedString("onboarding.enhanced_setup.visual_step_1"))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(DarkTheme.textSecondary)
                }
                .opacity(isAnimating ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.6).delay(1.2), value: isAnimating)
                
                HStack(spacing: 12) {
                    Image(systemName: "2.circle.fill")
                        .foregroundColor(DarkTheme.textPrimary)
                    Text(localizationManager.localizedString("onboarding.enhanced_setup.visual_step_2"))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(DarkTheme.textSecondary)
                }
                .opacity(isAnimating ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.6).delay(1.4), value: isAnimating)
                
                HStack(spacing: 12) {
                    Image(systemName: "3.circle.fill")
                        .foregroundColor(DarkTheme.textPrimary)
                    Text(localizationManager.localizedString("onboarding.enhanced_setup.visual_step_3"))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(DarkTheme.textSecondary)
                }
                .opacity(isAnimating ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.6).delay(1.6), value: isAnimating)
            }
        }
        .onAppear {
            isAnimating = true
            pulseScale = 1.2
        }
    }
}

// MARK: - Setup Step Extension
extension EnhancedSetupView.SetupStep: RawRepresentable {
    typealias RawValue = Int
    
    init?(rawValue: Int) {
        switch rawValue {
        case 0: self = .keyboard
        case 1: self = .microphone
        case 2: self = .complete
        default: return nil
        }
    }
    
    var rawValue: Int {
        switch self {
        case .keyboard: return 0
        case .microphone: return 1
        case .complete: return 2
        }
    }
}


//#Preview {
//    EnhancedSetupView(viewModel: ProfessionalOnboardingViewModel())
//        .environmentObject(LocalizationManager.shared)
//}
