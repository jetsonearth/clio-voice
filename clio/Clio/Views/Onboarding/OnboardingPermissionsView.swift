import SwiftUI
import SwiftData
import AVFoundation
import AppKit
import KeyboardShortcuts

struct OnboardingPermission: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let type: PermissionType
    
    enum PermissionType {
        case microphone
        case accessibility
        case screenRecording
        case keyboardShortcut
        
        var systemName: String {
            switch self {
            case .microphone: return "mic"
            case .accessibility: return "accessibility"
            case .screenRecording: return "rectangle.inset.filled.and.person.filled"
            case .keyboardShortcut: return "keyboard"
            }
        }
    }
}

struct OnboardingPermissionsView: View {
    @Binding var hasCompletedOnboarding: Bool
    @EnvironmentObject private var hotkeyManager: HotkeyManager
    @EnvironmentObject private var localizationManager: LocalizationManager
    @ObservedObject private var audioDeviceManager = AudioDeviceManager.shared
    @State private var currentPermissionIndex = 0
    @State private var permissionStates: [Bool] = []
    @State private var showAnimation = false
    @State private var scale: CGFloat = 0.8
    @State private var opacity: CGFloat = 0
    @State private var showModelDownload = false
    
    private var permissions: [OnboardingPermission] {
        [
            OnboardingPermission(
                title: localizationManager.localizedString("onboarding.permissions.microphone.title"),
                description: localizationManager.localizedString("onboarding.permissions.microphone.description"),
                icon: "waveform",
                type: .microphone
            ),
            
            OnboardingPermission(
                title: localizationManager.localizedString("onboarding.permissions.accessibility.title"),
                description: localizationManager.localizedString("onboarding.permissions.accessibility.description"),
                icon: "accessibility",
                type: .accessibility
            ),
            OnboardingPermission(
                title: localizationManager.localizedString("onboarding.permissions.screen_recording.title"),
                description: localizationManager.localizedString("onboarding.permissions.screen_recording.description"),
                icon: "rectangle.inset.filled.and.person.filled",
                type: .screenRecording
            ),
            OnboardingPermission(
                title: localizationManager.localizedString("onboarding.permissions.keyboard_shortcut.title"),
                description: localizationManager.localizedString("onboarding.permissions.keyboard_shortcut.description"),
                icon: "keyboard",
                type: .keyboardShortcut
            )
        ]
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                ZStack {
                    // Reusable background
                    OnboardingBackgroundView()
                    
                    VStack(spacing: 40) {
                        // Progress indicator
                        HStack(spacing: 8) {
                            ForEach(0..<permissions.count, id: \.self) { index in
                                Circle()
                                    .fill(index <= currentPermissionIndex ? Color.accentColor : DarkTheme.textPrimary.opacity(0.1))
                                    .frame(width: 8, height: 8)
                                    .scaleEffect(index == currentPermissionIndex ? 1.2 : 1.0)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPermissionIndex)
                            }
                        }
                        .padding(.top, 40)
                        
                        // Current permission card
                        VStack(spacing: 30) {
                            // Permission icon
                            ZStack {
                                Circle()
                                    .fill(Color.accentColor.opacity(0.1))
                                    .frame(width: 100, height: 100)
                                
                                if permissionStates[currentPermissionIndex] {
                                    Image(systemName: "checkmark.seal.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(.accentColor)
                                        .transition(.scale.combined(with: .opacity))
                                } else {
                                    Image(systemName: permissions[currentPermissionIndex].icon)
                                        .font(.system(size: 40))
                                        .foregroundColor(.accentColor)
                                }
                            }
                            .scaleEffect(scale)
                            .opacity(opacity)
                            
                            // Permission text
                            VStack(spacing: 12) {
                                Text(permissions[currentPermissionIndex].title)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(DarkTheme.textPrimary)
                                
                                Text(permissions[currentPermissionIndex].description)
                                    .font(.body)
                                    .foregroundColor(DarkTheme.textPrimary.opacity(0.7))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            .scaleEffect(scale)
                            .opacity(opacity)
                            
                            // Audio device selection removed from onboarding
                            
                            // Keyboard shortcut recorder (only shown for keyboard shortcut step)
                            if permissions[currentPermissionIndex].type == .keyboardShortcut {
                                VStack(spacing: 16) {
                                    // Comment out the confusing number display
                                    // if hotkeyManager.isShortcutConfigured {
                                    //     if let shortcut = KeyboardShortcuts.getShortcut(for: .toggleMiniRecorder) {
                                    //         KeyboardShortcutView(shortcut: shortcut)
                                    //             .scaleEffect(1.2)
                                    //     }
                                    // }
                                    
                                    // Text("Choose your recording key:")
                                    //     .font(.headline)
                                    //     .foregroundColor(DarkTheme.textPrimary)
                                    
                                    // Text("Select the key you want to hold down to record")
                                    //     .font(.subheadline)
                                    //     .foregroundColor(DarkTheme.textPrimary.opacity(0.7))
                                    
                                    // Show all 7 keys in a grid layout
                                    VStack(spacing: 12) {
                                        // First row: Option keys and Control keys
                                        HStack(spacing: 12) {
                                            ForEach([HotkeyManager.PushToTalkKey.leftOption, .rightOption, .leftControl], id: \.self) { key in
                                                OnboardingKeyButton(
                                                    key: key,
                                                    isSelected: hotkeyManager.pushToTalkKey == key,
                                                    onTap: {
                                                        selectKey(key)
                                                    }
                                                )
                                            }
                                        }
                                        
                                        // Second row: Function, Command, and Shift keys  
                                        HStack(spacing: 12) {
                                            ForEach([HotkeyManager.PushToTalkKey.fn, .rightCommand, .rightShift], id: \.self) { key in
                                                OnboardingKeyButton(
                                                    key: key,
                                                    isSelected: hotkeyManager.pushToTalkKey == key,
                                                    onTap: {
                                                        selectKey(key)
                                                    }
                                                )
                                            }
                                        }
                                    }
                                    
                                    SkipButton(text: localizationManager.localizedString("onboarding.button.skip_for_now")) {
                                        moveToNext()
                                    }
                                }
                                .scaleEffect(scale)
                                .opacity(opacity)
                            }
                        }
                        .frame(maxWidth: 400)
                        .padding(.vertical, 40)
                        
                        // Action buttons
                        VStack(spacing: 16) {
                            Button(action: requestPermission) {
                                Text(getButtonTitle())
                                    .font(.headline)
                                    .foregroundColor(DarkTheme.textPrimary)
                                    .frame(width: 200, height: 50)
                                    .background(Color.accentColor)
                                    .cornerRadius(25)
                            }
                            .buttonStyle(ScaleButtonStyle())
                            
                            if !permissionStates[currentPermissionIndex] && 
                               permissions[currentPermissionIndex].type != .keyboardShortcut {
                                SkipButton(text: localizationManager.localizedString("onboarding.button.skip_for_now")) {
                                    moveToNext()
                                }
                            }
                        }
                        .opacity(opacity)
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            checkExistingPermissions()
            animateIn()
            // Ensure audio devices are loaded
            audioDeviceManager.loadAvailableDevices()
        }
    }
    
    private func animateIn() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            scale = 1
            opacity = 1
        }
    }
    
    private func resetAnimation() {
        scale = 0.8
        opacity = 0
        animateIn()
    }
    
    private func checkExistingPermissions() {
        // Check microphone permission
        permissionStates[0] = AVCaptureDevice.authorizationStatus(for: .audio) == .authorized
        
        // Check if device is selected
        permissionStates[1] = audioDeviceManager.selectedDeviceID != nil
        
        // Check accessibility permission
        permissionStates[2] = AXIsProcessTrusted()
        
        // Check screen recording permission
        permissionStates[3] = CGPreflightScreenCaptureAccess()
        
        // Check keyboard shortcut
        permissionStates[4] = hotkeyManager.isShortcutConfigured
    }
    
    private func requestPermission() {
        if permissionStates[currentPermissionIndex] {
            moveToNext()
            return
        }
        
        switch permissions[currentPermissionIndex].type {
        case .microphone:
            let status = AVCaptureDevice.authorizationStatus(for: .audio)
            
            if status == .denied || status == .restricted {
                // Permission was previously denied, open System Preferences
                openMicrophoneSettings()
            } else {
                // First time or undetermined, request permission
                AVCaptureDevice.requestAccess(for: .audio) { granted in
                    DispatchQueue.main.async {
                        permissionStates[currentPermissionIndex] = granted
                        if granted {
                            withAnimation {
                                showAnimation = true
                            }
                        } else {
                            // Permission denied, next click will open settings
                        }
                    }
                }
            }
            
        case .accessibility:
            let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
            AXIsProcessTrustedWithOptions(options)
            
            // Start checking for permission status
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                if AXIsProcessTrusted() {
                    timer.invalidate()
                    permissionStates[currentPermissionIndex] = true
                    withAnimation {
                        showAnimation = true
                    }
                }
            }
            
        case .screenRecording:
            // 1. If we already have permission - done
            if CGPreflightScreenCaptureAccess() {
                permissionStates[currentPermissionIndex] = true
                withAnimation {
                    showAnimation = true
                }
                return
            }
            
            // 2. Ask the system for access (shows Apple's prompt & adds app to list)
            let granted = CGRequestScreenCaptureAccess()
            
            if !granted {
                // 3. User pressed "Open System Settings" or "Deny"
                // Now when they go to settings, YOUR APP IS ALREADY IN THE LIST!
                let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture")!
                NSWorkspace.shared.open(url)
            }
            
            // 4. Start checking for permission status
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                if CGPreflightScreenCaptureAccess() {
                    timer.invalidate()
                    permissionStates[currentPermissionIndex] = true
                    withAnimation {
                        showAnimation = true
                    }
                }
            }
            
        case .keyboardShortcut:
            // The keyboard shortcut is handled by the KeyboardShortcuts.Recorder
            break
        }
    }
    
    private func moveToNext() {
        if currentPermissionIndex < permissions.count - 1 {
            withAnimation {
                currentPermissionIndex += 1
                resetAnimation()
            }
        } else {
            withAnimation {
                showModelDownload = true
            }
        }
    }
    
    private func getButtonTitle() -> String {
        switch permissions[currentPermissionIndex].type {
        case .microphone:
            let status = AVCaptureDevice.authorizationStatus(for: .audio)
            if permissionStates[currentPermissionIndex] {
                return localizationManager.localizedString("general.continue")
            } else if status == .denied || status == .restricted {
                return localizationManager.localizedString("onboarding.enhanced_permissions.open_settings")
            } else {
                return localizationManager.localizedString("onboarding.permissions.enable_access")
            }
        case .keyboardShortcut:
            return permissionStates[currentPermissionIndex] ? localizationManager.localizedString("general.continue") : localizationManager.localizedString("onboarding.permissions.set_shortcut")
        default:
            return permissionStates[currentPermissionIndex] ? localizationManager.localizedString("general.continue") : localizationManager.localizedString("onboarding.permissions.enable_access")
        }
    }
    
    private func openMicrophoneSettings() {
        // Open System Preferences to Security & Privacy > Privacy > Microphone
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone") {
            NSWorkspace.shared.open(url)
        }
        
        // Start a timer to check for permission changes
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            let newStatus = AVCaptureDevice.authorizationStatus(for: .audio)
            if newStatus == .authorized {
                timer.invalidate()
                DispatchQueue.main.async {
                    permissionStates[currentPermissionIndex] = true
                    withAnimation {
                        showAnimation = true
                    }
                }
            }
        }
    }
    
    private func selectKey(_ key: HotkeyManager.PushToTalkKey) {
        let shortcut = KeyboardShortcuts.Shortcut(
            KeyboardShortcuts.Key(rawValue: Int(key.keyCode)),
            modifiers: []
        )
        
        KeyboardShortcuts.setShortcut(shortcut, for: .toggleMiniRecorder)
        hotkeyManager.pushToTalkKey = key
        hotkeyManager.isPushToTalkEnabled = true
        hotkeyManager.updateShortcutStatus()
        
        withAnimation {
            permissionStates[currentPermissionIndex] = true
            showAnimation = true
        }
    }
}

struct OnboardingKeyButton: View {
    let key: HotkeyManager.PushToTalkKey
    let isSelected: Bool
    let onTap: () -> Void
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text(getKeySymbol(for: key))
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(isSelected ? .white : DarkTheme.textPrimary.opacity(0.8))
                    .frame(width: 50, height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isSelected ? Color.accentColor : DarkTheme.textPrimary.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.accentColor.opacity(0.8) : DarkTheme.textPrimary.opacity(0.2), lineWidth: 2)
                    )
                
                Text(getKeyText(for: key))
                    .font(.caption)
                    .foregroundColor(DarkTheme.textPrimary.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isSelected)
    }
    
    private func getKeySymbol(for key: HotkeyManager.PushToTalkKey) -> String {
        switch key {
        case .rightOption: return "⌥"
        case .leftOption: return "⌥"
        case .leftControl: return "⌃"
        case .rightControl: return "⌃"
        case .fn: return localizationManager.localizedString("onboarding.permissions.key_fn")
        case .rightCommand, .leftCommand: return "⌘"
        case .rightShift, .leftShift: return "⇧"
        }
    }
    
    private func getKeyText(for key: HotkeyManager.PushToTalkKey) -> String {
        switch key {
        case .rightOption: return localizationManager.localizedString("onboarding.permissions.key_right_option")
        case .leftOption: return localizationManager.localizedString("onboarding.permissions.key_left_option")
        case .leftControl: return localizationManager.localizedString("onboarding.permissions.key_left_control")
        case .rightControl: return localizationManager.localizedString("onboarding.permissions.key_right_control")
        case .fn: return localizationManager.localizedString("onboarding.permissions.key_function")
        case .rightCommand: return localizationManager.localizedString("onboarding.permissions.key_right_command")
        case .leftCommand: return localizationManager.localizedString("onboarding.permissions.key_left_command")
        case .rightShift: return localizationManager.localizedString("onboarding.permissions.key_right_shift")
        case .leftShift: return localizationManager.localizedString("onboarding.permissions.key_left_shift")
        }
    }
}
