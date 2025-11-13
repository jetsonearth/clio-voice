import SwiftUI
import Cocoa
import KeyboardShortcuts
import LaunchAtLogin
import AVFoundation
// Additional imports for Settings components

// Helper struct for audio device dropdown
struct AudioDeviceOption: Hashable {
    let id: UInt32
    let uid: String
    let name: String
}

struct SettingsView: View {
    @EnvironmentObject private var updaterViewModel: UpdaterViewModel
    // MenuBarManager removed
    @EnvironmentObject private var hotkeyManager: HotkeyManager
    @EnvironmentObject private var aiService: AIService
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var localizationManager: LocalizationManager
    @EnvironmentObject private var enhancementService: AIEnhancementService
    @EnvironmentObject private var contextService: ContextService
    @EnvironmentObject private var recordingEngine: RecordingEngine
    @StateObject private var deviceManager = AudioDeviceManager.shared
    @State private var showResetOnboardingAlert = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("emailSignatureEnabled") private var emailSignatureEnabled = false
    
    
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Page Header Section
                pageHeader
                    .padding(.horizontal, 40)
                    .padding(.vertical, 40)
                
                // Main Content
                VStack(spacing: 32) {

                    // Audio Cleanup Section
//                    AudioInputSection()
                    
                    // Keyboard Shortcuts Section
                    KeyboardShortcutsSection()
                    
                    // Combined Language Settings Section
                    CombinedLanguageSettingsSection()
                    
                    // Context Options Section
                    ContextOptionsSection()
                    
                    // System Settings Section (grouped rows)
                    SystemSettingsSection()

                    // Community profile lives at the bottom so it appears after permissions
                    CommunityProfileSection()
                    
                    // AI Enhancement Section with Toggle Header (commented out for menubar integration)
                    // AIEnhancementSectionWithToggle()
                    
                    // Privacy Section (commented out for proxy architecture)
                    // PrivacySection()
                
                // Updates Section
                // SettingsSection(
                //     icon: "arrow.triangle.2.circlepath",
                //     title: "Updates",
                //     subtitle: "Keep Io up to date"
                // ) {
                //     VStack(alignment: .leading, spacing: 8) {
                //         Text("Io automatically checks for updates on launch and every other day.")
                //             .settingsDescription()
                //             .foregroundColor(DarkTheme.textSecondary)
                        
                //         AddNewButton("Check for Updates Now") {
                //             updaterViewModel.checkForUpdates()
                //         }
                //     }
                // }
                
                // App Appearance Section
                // SettingsSection(
                //     icon: "dock.rectangle",
                //     title: "App Appearance",
                //     subtitle: "Dock and Menu Bar options"
                // ) {
                //     VStack(alignment: .leading, spacing: 8) {
                //         Text("Choose how Io appears in your system.")
                //             .settingsDescription()
                        
                //         Toggle("Hide Dock Icon (Menu Bar Only)", isOn: $menuBarManager.isMenuBarOnly)
                //             .toggleStyle(.switch)
                //     }
                // }
                
                // Recorder Preference Section
                // SettingsSection(
                //     icon: "rectangle.on.rectangle",
                //     title: "Recorder Style",
                //     subtitle: "Choose your preferred recorder interface"
                // ) {
                //     VStack(alignment: .leading, spacing: 8) {
                //         Text("Select how you want the recorder to appear on your screen.")
                //             .settingsDescription()
                        
                //         Picker("Recorder Style", selection: $recordingEngine.recorderType) {
                //             Text("Notch Recorder").tag("notch")
                //             Text("Mini Recorder").tag("mini")
                //         }
                //         .pickerStyle(.radioGroup)
                //         .padding(.vertical, 4)
                //     }
                // }
                
                // Streaming Transcript Toggle Section
//                StreamingTranscriptToggleSection()
                
                // Recorder Style Toggle Section - Commented out (notch is now default)
                // RecorderStyleToggleSection()
                
                // Audio Cleanup Section with Toggle (moved into SystemSettingsSection)
                // AudioCleanupSectionWithToggle()
                
                // Compatibility Mode is internal-only and hidden from client builds
                // CompatibilityModeSectionWithToggle()
                
                // App Permissions Section (now shown inside SystemSettingsSection)
                // AppPermissionsSection()
                
                // Reset Onboarding Section (commented out as requested)
                /*
                SettingsSection(
                    icon: "arrow.counterclockwise",
                    title: localizationManager.localizedString("settings.reset_onboarding.title"),
                    subtitle: localizationManager.localizedString("settings.reset_onboarding.subtitle")
                ) {
                    VStack(alignment: .leading, spacing: 12) {
                        Button(action: { showResetOnboardingAlert = true }) {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.system(size: 14, weight: .medium))
                                Text(localizationManager.localizedString("settings.reset_onboarding.button"))
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(DarkTheme.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(DarkTheme.textPrimary.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(DarkTheme.textPrimary.opacity(0.2), lineWidth: 1)
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                */
                .alert("Reset Onboarding", isPresented: $showResetOnboardingAlert) {
                    Button(localizationManager.localizedString("general.cancel"), role: .cancel) { }
                    Button(localizationManager.localizedString("settings.reset_onboarding.confirm"), role: .destructive) {
                        resetOnboarding()
                    }
                } message: {
                    Text(localizationManager.localizedString("settings.reset_onboarding.message"))
                }
                
                // Account & Sign Out Section (now integrated into System Settings)
                // AccountManagementSection()
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
        // .alert("Reset Onboarding", isPresented: $showResetOnboardingAlert) {
        //     Button("Cancel", role: .cancel) { }
        //     Button("Reset", role: .destructive) {
        //         hasCompletedOnboarding = false
        //     }
        // } message: {
        //     Text("Are you sure you want to reset the onboarding? You'll see the introduction screens again the next time you launch the app.")
        // }
    }
    
//    private func openAPIKeyManagement() {
//        let window = NSWindow(
//            contentRect: NSRect(x: 0, y: 0, width: 600, height: 400),
//            styleMask: [.titled, .closable, .resizable],
//            backing: .buffered,
//            defer: false
//        )
//        window.title = "API Key Management"
//        window.center()
//        window.isReleasedWhenClosed = false
//        
//        let hostingView = NSHostingView(
//            rootView: APIKeyManagementView()
//                .environmentObject(aiService)
//                .frame(minWidth: 600, minHeight: 400)
//                .padding()
//        )
//        
//        window.contentView = hostingView
//        window.makeKeyAndOrderFront(nil)
//    }
//    
//    private func getPushToTalkDescription() -> String {
//        switch hotkeyManager.pushToTalkKey {
//        case .rightOption:
//            return "Using Right Option (⌥) key to quickly start recording. Release to stop."
//        case .leftOption:
//            return "Using Left Option (⌥) key to quickly start recording. Release to stop."
//        case .leftControl:
//            return "Using Left Control (⌃) key to quickly start recording. Release to stop."
//        case .rightControl:
//            return "Using Right Control (⌃) key to quickly start recording. Release to stop."
//        case .fn:
//            return "Using Function (Fn) key to quickly start recording. Release to stop."
//        case .rightCommand:
//            return "Using Right Command (⌘) key to quickly start recording. Release to stop."
//        case .rightShift:
//            return "Using Right Shift (⇧) key to quickly start recording. Release to stop."
//        case .leftCommand:
//            return "Using Left Command (⌘) key to quickly start recording. Release to stop."
//        case .leftShift:
//            return "Using Left Shift (⇧) key to quickly start recording. Release to stop."
//        }
//    }
    
    // MARK: - Page Header
    private var pageHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
Text(localizationManager.localizedString("settings.title"))
                        .fontScaled(size: 30, weight: .bold)
                        .foregroundColor(DarkTheme.textPrimary)
                    
Text(localizationManager.localizedString("settings.description"))
                        .fontScaled(size: 16)
                        .foregroundColor(DarkTheme.textSecondary)
                }
                
                Spacer()
            }
        }
    }
    
    
    private func resetOnboarding() {
        hasCompletedOnboarding = false
        print("✅ [ONBOARDING] Reset onboarding flag")
        print("🔄 [ONBOARDING] App will show onboarding flow on next restart")
    }
    
}

struct AudioCleanupSectionWithToggle: View {
    @AppStorage("IsAudioCleanupEnabled") private var isAudioCleanupEnabled = true
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "trash.circle")
                    .font(.system(size: 20))
                    .foregroundColor(.accentColor)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(localizationManager.localizedString("settings.audio_cleanup.title"))
                        .font(.headline)
                        .foregroundColor(DarkTheme.textPrimary)
                    Text(localizationManager.localizedString("settings.audio_cleanup.description"))
                        .font(.subheadline)
                        .foregroundColor(DarkTheme.textSecondary)
                }
                
                Spacer()
                
                // Only toggle (no status badge)
                Toggle("", isOn: $isAudioCleanupEnabled)
                    .toggleStyle(SwitchToggleStyle(tint: DarkTheme.accent))
                    .scaleEffect(1.0)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(DarkTheme.textPrimary.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(DarkTheme.textPrimary.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// Extension removed - using the one in Components/Shared/SettingsSection.swift

struct CompatibilityModeSectionWithToggle: View {
    @AppStorage("CompatibilityModeEnabled") private var compatEnabled = false
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.shield")
                    .font(.system(size: 20))
                    .foregroundColor(.accentColor)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Compatibility Mode")
                        .font(.headline)
                        .foregroundColor(DarkTheme.textPrimary)
                    Text("Pins macOS input device and uses aggressive recovery. Enable only if the default capture is unstable.")
                        .font(.subheadline)
                        .foregroundColor(DarkTheme.textSecondary)
                }
                
                Spacer()
                
                Toggle("", isOn: $compatEnabled)
                    .toggleStyle(SwitchToggleStyle(tint: DarkTheme.accent))
                    .scaleEffect(1.0)
                    .onChange(of: compatEnabled) { _, newValue in
                        let state = newValue ? "on" : "off"
                        StructuredLog.shared.log(cat: .audio, evt: "compat_mode_toggle", lvl: .info, ["enabled": newValue])
                        if newValue {
                            ToastBanner.shared.show(title: "Compatibility Mode enabled", subtitle: "Clio will pin the input device for stability")
                        } else {
                            ToastBanner.shared.show(title: "Compatibility Mode disabled", subtitle: "Clio will use non-intrusive VoiceInk-style capture")
                        }
                    }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(DarkTheme.textPrimary.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(DarkTheme.textPrimary.opacity(0.1), lineWidth: 1)
                )
        )
    }
}


struct CustomKeyboardRecorder: View {
    @Binding var isRecording: Bool
    let onShortcutRecorded: (KeyboardShortcuts.Shortcut?) -> Void
    
    @State private var currentKeys: Set<UInt16> = []
    @State private var currentModifiers: NSEvent.ModifierFlags = []
    @State private var eventMonitor: Any?
    
    var body: some View {
        Button(action: {
            if isRecording {
                stopRecording()
            } else {
                startRecording()
            }
        }) {
            HStack {
                Image(systemName: isRecording ? "record.circle.fill" : "keyboard")
                    .foregroundColor(isRecording ? .red : .primary)
                Text(isRecording ? "Recording... (Press Esc to cancel)" : "Custom Recorder")
            }
        }
        .buttonStyle(.bordered)
        .onDisappear {
            stopRecording()
        }
    }
    
    private func startRecording() {
        print("🎯 Starting custom keyboard recording...")
        isRecording = true
        currentKeys.removeAll()
        currentModifiers = []
        
        // Monitor key events
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .keyUp, .flagsChanged]) { event in
            handleKeyEvent(event)
            return nil // Consume the event
        }
    }
    
    private func stopRecording() {
        print("🎯 Stopping custom keyboard recording...")
        isRecording = false
        
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
        
        currentKeys.removeAll()
        currentModifiers = []
    }
    
    private func handleKeyEvent(_ event: NSEvent) {
        print("🎯 Key event: type=\(event.type.rawValue), keyCode=\(event.keyCode), modifiers=\(event.modifierFlags)")
        
        switch event.type {
        case .keyDown:
            // Escape cancels recording
            if event.keyCode == 53 { // Escape key
                print("🎯 Escape pressed, cancelling recording")
                stopRecording()
                return
            }
            
            // Record the key combination
            let modifiers = event.modifierFlags.intersection([.command, .option, .shift, .control])
            
            // Create the key directly (KeyboardShortcuts.Key doesn't return optional)
            let key = KeyboardShortcuts.Key(rawValue: Int(event.keyCode))
            let shortcut = KeyboardShortcuts.Shortcut(key, modifiers: modifiers)
            print("🎯 Recorded shortcut: \(shortcut)")
            
            stopRecording()
            onShortcutRecorded(shortcut)
            
        case .flagsChanged:
            currentModifiers = event.modifierFlags.intersection([.command, .option, .shift, .control])
            print("🎯 Modifiers changed: \(currentModifiers)")
            
        default:
            break
        }
    }
}

struct PermissionRow: View {
    let icon: String
    let title: String
    let description: String
    let isGranted: Bool
    let buttonTitle: String
    let buttonAction: () -> Void
    let checkPermission: () -> Void
    @State private var isRefreshing = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon with status
            ZStack {
                Circle()
                    .fill(isGranted ? DarkTheme.accent.opacity(0.15) : Color.orange.opacity(0.15))
                    .frame(width: 32, height: 32)
                
                Image(systemName: isGranted ? "\(icon).fill" : icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isGranted ? DarkTheme.accent : .orange)
                    .symbolRenderingMode(.hierarchical)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isRefreshing = true
                    }
                    checkPermission()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isRefreshing = false
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(isRefreshing ? 360 : 0))
                }
                .buttonStyle(.plain)
                
                if isGranted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(DarkTheme.accent)
                } else {
                    Button(buttonTitle) {
                        buttonAction()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct AudioInputModeCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    @State private var hoverState = false
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                // Icon section
                ZStack {
                    Circle()
                        .fill(
                            isSelected ? color.opacity(0.15) : Color.secondary.opacity(0.1)
                        )
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(isSelected ? color : .secondary)
                        .symbolRenderingMode(.hierarchical)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                // Selection indicator
                HStack {
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(color)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            }
            .padding(12)
            .frame(height: 100)
            .frame(maxWidth: .infinity)
            .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(DarkTheme.textPrimary.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(DarkTheme.textPrimary.opacity(0.1), lineWidth: 1)
                )
        )
            .scaleEffect(hoverState ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: hoverState)
            .animation(.easeInOut(duration: 0.3), value: isSelected)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            hoverState = hovering
        }
    }
}

struct SimplePermissionRow: View {
    let icon: String
    let title: String
    let isGranted: Bool
    let buttonAction: () -> Void
    let checkPermission: () -> Void
    @State private var isRefreshing = false
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
                .frame(width: 20)
            
            // Title
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.primary)
            
            Spacer()
            
            // Status and actions
            HStack(spacing: 8) {
                // Status indicator
                HStack(spacing: 6) {
                    Circle()
                        .fill(isGranted ? DarkTheme.accent : .orange)
                        .frame(width: 6, height: 6)
                    
                    Text(isGranted ? localizationManager.localizedString("settings.status.enabled") : localizationManager.localizedString("settings.status.disabled"))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(isGranted ? DarkTheme.accent : .orange)
                }
                
                // Refresh button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isRefreshing = true
                    }
                    checkPermission()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isRefreshing = false
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(isRefreshing ? 360 : 0))
                }
                .buttonStyle(.plain)
                .help("Refresh permission status")
                
                // Enable button (only if not granted)
                if !isGranted {
                    Button(localizationManager.localizedString("settings.permissions.grant")) {
                        buttonAction()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// struct AudioCleanupSettingsView: View {
//     var body: some View {
//         VStack(alignment: .leading, spacing: 12) {
//             Text("Automatically clean up audio recordings to save disk space.")
//                 .settingsDescription()
            
//             // Add actual audio cleanup settings here
//             Toggle("Delete recordings after transcription", isOn: .constant(false))
//                 .toggleStyle(.switch)
            
//             Button("Clean Up Now") {
//                 // Implement cleanup functionality
//             }
//             .buttonStyle(.bordered)
//             .controlSize(.large)
//         }
//     }
// }

/// Reusable dark card component for settings rows
struct DarkSettingsCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.12, green: 0.12, blue: 0.13)) // Slightly lighter dark background
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.06), lineWidth: 1)
                    )
            )
    }
}

struct BeautifulPermissionCard: View {
    let icon: String
    let title: String
    let description: String
    let isGranted: Bool
    let buttonAction: () -> Void
    let checkPermission: () -> Void
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        DarkSettingsCard {
            HStack(spacing: 16) {
                // Icon with status indicator
                ZStack {
                    Circle()
                        .fill(statusColor.opacity(0.15))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(statusColor)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(title)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Status badge
                        HStack(spacing: 6) {
                            Circle()
                                .fill(statusColor)
                                .frame(width: 8, height: 8)
                            
                            Text(isGranted ? localizationManager.localizedString("settings.status.enabled") : localizationManager.localizedString("settings.status.disabled"))
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(statusColor)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(statusColor.opacity(0.15))
                        )
                    }
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.leading)
                }
                
                // Action button (only show if not granted)
                if !isGranted {
                    Button(action: buttonAction) {
                        HStack(spacing: 6) {
                            Image(systemName: "gear")
                                .font(.caption)
                            Text(localizationManager.localizedString("settings.permissions.grant"))
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(statusColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .stroke(statusColor, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .help("Open System Preferences to grant permission")
                }
            }
        }
        .onAppear {
            checkPermission()
        }
    }
    
    private var statusColor: Color {
        isGranted ? DarkTheme.accent : DarkTheme.warning
    }
}

// struct AIEnhancementSectionWithToggle: View {
//     @EnvironmentObject private var enhancementService: AIEnhancementService
//     @EnvironmentObject private var aiService: AIService
//     @EnvironmentObject private var localizationManager: LocalizationManager
    
//     var body: some View {
//         VStack(alignment: .leading, spacing: 12) {
//             HStack(spacing: 12) {
//                 Image(systemName: "wand.and.stars")
//                     .font(.system(size: 20))
//                     .foregroundColor(.accentColor)
//                     .frame(width: 24, height: 24)
                
//                 VStack(alignment: .leading, spacing: 2) {
//                     Text(localizationManager.localizedString("settings.ai_enhancement"))
//                         .font(.headline)
//                         .foregroundColor(DarkTheme.textPrimary)
//                     Text(localizationManager.localizedString("settings.ai_enhancement.description"))
//                         .font(.subheadline)
//                         .foregroundColor(DarkTheme.textSecondary)
//                 }
                
//                 Spacer()
                
//                 // Toggle only (simplified - no status badge needed)
//                 Toggle("", isOn: $enhancementService.isEnhancementEnabled)
//                     .toggleStyle(SwitchToggleStyle(tint: DarkTheme.accent))
//                     .scaleEffect(1.0)
//             }
            
//             // Configuration section removed for simplicity
//             // Users can access advanced settings through the separate Enhancement Prompts page
//         }
//         .padding(16)
//         .frame(maxWidth: .infinity, alignment: .leading)
//         .background(
//             RoundedRectangle(cornerRadius: 12)
//                 .fill(DarkTheme.textPrimary.opacity(0.03))
//                 .overlay(
//                     RoundedRectangle(cornerRadius: 12)
//                         .stroke(DarkTheme.textPrimary.opacity(0.1), lineWidth: 1)
//                 )
//         )
//         .animation(.easeInOut(duration: 0.3), value: enhancementService.isEnhancementEnabled)
//     }
// }

// struct AIEnhancementConfigurationView: View {
//     @EnvironmentObject private var enhancementService: AIEnhancementService
//     @EnvironmentObject private var aiService: AIService
//     @EnvironmentObject private var localizationManager: LocalizationManager
//     @State private var hasLocalModel = false
//     @State private var isDownloading = false
//     @State private var downloadProgress: String = ""
//     @State private var useLocalAI = true
    
//     private var isLocalProvider: Bool {
//         false // Only Groq is supported now, which is not local
//     }
    
//     var body: some View {
//         VStack(spacing: 16) {
//             // Local vs Cloud Toggle Section
//             VStack(alignment: .leading, spacing: 12) {
//                 Text(localizationManager.localizedString("settings.ai_model_type.title"))
//                     .font(.subheadline)
//                     .fontWeight(.semibold)
//                     .foregroundColor(DarkTheme.textPrimary)
                
//                 HStack(spacing: 16) {
//                     // Local AI Option
//                     Button(action: {
//                         withAnimation(.easeInOut(duration: 0.3)) {
//                             useLocalAI = true
//                             // No local providers available with Groq-only setup
//                         }
//                     }) {
//                         HStack(spacing: 12) {
//                             ZStack {
//                                 Circle()
//                                     .fill(useLocalAI ? DarkTheme.accent.opacity(0.15) : DarkTheme.textTertiary.opacity(0.1))
//                                     .frame(width: 40, height: 40)
                                
//                                 Image(systemName: "cpu")
//                                     .font(.system(size: 18, weight: .medium))
//                                     .foregroundColor(useLocalAI ? DarkTheme.accent : DarkTheme.textTertiary)
//                             }
                            
//                             VStack(alignment: .leading, spacing: 2) {
//                                 Text(localizationManager.localizedString("settings.ai_model_type.local"))
//                                     .font(.system(size: 14, weight: .semibold))
//                                     .foregroundColor(useLocalAI ? DarkTheme.textPrimary : DarkTheme.textTertiary)
                                
//                                 Text(localizationManager.localizedString("settings.ai_model_type.local_description"))
//                                     .font(.caption)
//                                     .foregroundColor(useLocalAI ? DarkTheme.textSecondary : DarkTheme.textTertiary)
//                             }
                            
//                             Spacer()
                            
//                             if useLocalAI {
//                                 Image(systemName: "checkmark.circle.fill")
//                                     .foregroundColor(DarkTheme.accent)
//                                     .font(.system(size: 16))
//                             }
//                         }
//                         .padding()
//                         .contentShape(Rectangle())
//                     }
//                     .buttonStyle(.plain)
//                     .background(
//                         RoundedRectangle(cornerRadius: 12)
//                             .fill(useLocalAI ? DarkTheme.accent.opacity(0.08) : Color.clear)
//                             .overlay(
//                                 RoundedRectangle(cornerRadius: 12)
//                                     .stroke(useLocalAI ? DarkTheme.accent.opacity(0.3) : DarkTheme.textTertiary.opacity(0.2), lineWidth: 1)
//                             )
//                     )
                    
//                     // Cloud AI Option
//                     Button(action: {
//                         withAnimation(.easeInOut(duration: 0.3)) {
//                             useLocalAI = false
//                             // Switch to a cloud provider if currently local
//                             if isLocalProvider {
//                                 aiService.selectedProvider = .groq
//                             }
//                         }
//                     }) {
//                         HStack(spacing: 12) {
//                             ZStack {
//                                 Circle()
//                                     .fill(!useLocalAI ? DarkTheme.accent.opacity(0.15) : DarkTheme.textTertiary.opacity(0.1))
//                                     .frame(width: 40, height: 40)
                                
//                                 Image(systemName: "cloud")
//                                     .font(.system(size: 18, weight: .medium))
//                                     .foregroundColor(!useLocalAI ? DarkTheme.accent : DarkTheme.textTertiary)
//                             }
                            
//                             VStack(alignment: .leading, spacing: 2) {
//                                 Text(localizationManager.localizedString("settings.ai_model_type.cloud"))
//                                     .font(.system(size: 14, weight: .semibold))
//                                     .foregroundColor(!useLocalAI ? DarkTheme.textPrimary : DarkTheme.textTertiary)
                                
//                                 Text(localizationManager.localizedString("settings.ai_model_type.cloud_description"))
//                                     .font(.caption)
//                                     .foregroundColor(!useLocalAI ? DarkTheme.textSecondary : DarkTheme.textTertiary)
//                             }
                            
//                             Spacer()
                            
//                             if !useLocalAI {
//                                 Image(systemName: "checkmark.circle.fill")
//                                     .foregroundColor(DarkTheme.accent)
//                                     .font(.system(size: 16))
//                             }
//                         }
//                         .padding()
//                         .contentShape(Rectangle())
//                     }
//                     .buttonStyle(.plain)
//                     .background(
//                         RoundedRectangle(cornerRadius: 12)
//                             .fill(!useLocalAI ? DarkTheme.accent.opacity(0.08) : Color.clear)
//                             .overlay(
//                                 RoundedRectangle(cornerRadius: 12)
//                                     .stroke(!useLocalAI ? DarkTheme.accent.opacity(0.3) : DarkTheme.textTertiary.opacity(0.2), lineWidth: 1)
//                             )
//                     )
//                 }
//             }
            
//             Divider()
            
//             // Proxy Configuration Status
//             VStack(alignment: .leading, spacing: 12) {
//                 Text("AI Enhancement")
//                     .font(.subheadline)
//                     .fontWeight(.semibold)
//                     .foregroundColor(DarkTheme.textPrimary)
                
//                 HStack(spacing: 8) {
//                     Circle()
//                         .fill(DarkTheme.success)
//                         .frame(width: 8, height: 8)
                    
//                     Text("Connected via Clio Online proxy")
//                         .font(.caption)
//                         .foregroundColor(DarkTheme.success)
                    
//                     Spacer()
//                 }
//                 .padding(.top, 4)
//             }
//             .padding()
//             .background(DarkTheme.cardBackground.opacity(0.3))
//             .cornerRadius(8)
            
//             // Removed inline Context Options block (moved to dedicated ContextOptionsSection)
//         }
//         .padding()
//         .background(DarkTheme.cardBackground.opacity(0.5))
//         .cornerRadius(8)
//         .onAppear {
//             useLocalAI = isLocalProvider
//             checkForLocalModel()
//         }
//         .onChange(of: aiService.selectedProvider) { oldValue, newValue in
//             useLocalAI = isLocalProvider
//         }
//     }
    
//     private func checkForLocalModel() {
//         Task {
//             // Check if we have any downloaded Ollama models
//             let hasOllamaModels = await checkOllamaModels()
//             await MainActor.run {
//                 hasLocalModel = hasOllamaModels
//             }
//         }
//     }
    
//     private func checkOllamaModels() async -> Bool {
//         // Run the blocking operation on a background queue to prevent UI freezing
//         return await withCheckedContinuation { continuation in
//             Task.detached {
//                 do {
//                     let process = Process()
//                     process.executableURL = URL(fileURLWithPath: "/usr/local/bin/ollama")
//                     process.arguments = ["list"]
                    
//                     let pipe = Pipe()
//                     process.standardOutput = pipe
                    
//                     try process.run()
//                     process.waitUntilExit()
                    
//                     let data = pipe.fileHandleForReading.readDataToEndOfFile()
//                     let output = String(data: data, encoding: .utf8) ?? ""
                    
//                     // Check if we have qwen models
//                     let hasModels = output.contains("qwen2.5") || output.contains("qwen3")
//                     continuation.resume(returning: hasModels)
//                 } catch {
//                     print("Error checking Ollama models: \(error)")
//                     continuation.resume(returning: false)
//                 }
//             }
//         }
//     }
    
//     private func downloadModel() {
//         Task.detached {
//             await MainActor.run {
//                 isDownloading = true
//                 downloadProgress = "Starting download..."
//             }
            
//             do {
//                 let process = Process()
//                 process.executableURL = URL(fileURLWithPath: "/usr/local/bin/ollama")
//                 process.arguments = ["pull", "qwen2.5:3b"]
                
//                 let pipe = Pipe()
//                 process.standardOutput = pipe
//                 process.standardError = pipe
                
//                 try process.run()
                
//                 // Monitor progress
//                 Task {
//                     while process.isRunning {
//                         let data = pipe.fileHandleForReading.availableData
//                         if !data.isEmpty {
//                             let output = String(data: data, encoding: .utf8) ?? ""
//                             await MainActor.run {
//                                 downloadProgress = output.trimmingCharacters(in: .whitespacesAndNewlines)
//                             }
//                         }
//                         try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
//                     }
//                 }
                
//                 process.waitUntilExit()
                
//                 await MainActor.run {
//                     isDownloading = false
//                     if process.terminationStatus == 0 {
//                         downloadProgress = "Download completed!"
//                         hasLocalModel = true
//                     } else {
//                         downloadProgress = "Download failed"
//                     }
//                 }
                
//                 // Clear progress message after delay
//                 try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
//                 await MainActor.run {
//                     downloadProgress = ""
//                 }
                
//             } catch {
//                 await MainActor.run {
//                     isDownloading = false
//                     downloadProgress = "Error: \(error.localizedDescription)"
//                 }
//             }
//         }
//     }
    
//     private func openModelsFolder() {
//         let modelsPath = FileManager.default.homeDirectoryForCurrentUser
//             .appendingPathComponent("Library/Application Support/WhisperKit/Models")
        
//         NSWorkspace.shared.open(modelsPath)
//     }
// }

// struct SubscriptionStatusSection: View {
//     @StateObject private var subscriptionManager = SubscriptionManager.shared
//     @StateObject private var userStatsService = UserStatsService.shared
//     @EnvironmentObject private var localizationManager: LocalizationManager
    
//     // Consistent plan display name logic with LicensePageView
//     private var planDisplayName: String {
//         if subscriptionManager.isInTrial {
//             return "Free Trial"
//         } else if subscriptionManager.currentTier == .pro {
//             return "Clio Pro" 
//         } else {
//             return "Free"
//         }
//     }
    
//     var body: some View {
//         SettingsSection(
//             icon: (subscriptionManager.currentTier == .pro && !subscriptionManager.isInTrial) ? "crown.fill" : "person.circle",
//             title: "Subscription Status",
//             subtitle: subscriptionStatusSubtitle
//         ) {
//             VStack(alignment: .leading, spacing: 16) {
//                 // Current plan card
//                 HStack(spacing: 16) {
//                     // Plan badge
//                     VStack(alignment: .leading, spacing: 8) {
//                         HStack(spacing: 8) {
//                             // Show crown only for actual Pro subscribers (not trial users)
//                             if subscriptionManager.currentTier == .pro && !subscriptionManager.isInTrial {
//                                 Image(systemName: "crown.fill")
//                                     .font(.system(size: 16))
//                                     .foregroundColor(.yellow)
//                             }
                            
//                             Text(planDisplayName)
//                                 .font(.headline)
//                                 .fontWeight(.bold)
//                                 .foregroundColor(DarkTheme.textPrimary)
//                         }
                        
//                         Text(subscriptionStatusDescription)
//                             .font(.subheadline)
//                             .foregroundColor(DarkTheme.textSecondary)
//                     }
                    
//                     Spacer()
                    
//                     // Action button
//                     if subscriptionManager.currentTier != .pro {
//                         AddNewButton("Upgrade", action: {
//                             subscriptionManager.promptUpgrade(from: "settings")
//                         }, backgroundColor: DarkTheme.accent, systemImage: "arrow.up.circle")
//                     } else {
//                         HStack(spacing: 6) {
//                             Circle()
//                                 .fill(.green)
//                                 .frame(width: 8, height: 8)
                            
//                             Text(localizationManager.localizedString("settings.subscription.active"))
//                                 .font(.caption)
//                                 .fontWeight(.medium)
//                                 .foregroundColor(.green)
//                         }
//                         .padding(.horizontal, 12)
//                         .padding(.vertical, 6)
//                         .background(
//                             Capsule()
//                                 .fill(.green.opacity(0.15))
//                         )
//                     }
//                 }
                
//                 // Trial progress (if in trial)
//                 if subscriptionManager.isInTrial {
//                     Divider()
//                         .opacity(0.3)
                    
//                     VStack(alignment: .leading, spacing: 12) {
//                         HStack {
//                             Text(localizationManager.localizedString("settings.subscription.trial_usage"))
//                                 .font(.subheadline)
//                                 .fontWeight(.semibold)
//                                 .foregroundColor(DarkTheme.textPrimary)
                            
//                             Spacer()
                            
//                             Text("\(subscriptionManager.trialDaysRemaining) of \(SubscriptionManager.TRIAL_DURATION_DAYS) days left")
//                                 .font(.caption)
//                                 .foregroundColor(DarkTheme.textSecondary)
//                         }
                        
//                         // Progress bar
//                         ZStack(alignment: .leading) {
//                             RoundedRectangle(cornerRadius: 4)
//                                 .fill(DarkTheme.textPrimary.opacity(0.1))
//                                 .frame(height: 8)
                            
//                             RoundedRectangle(cornerRadius: 4)
//                                 .fill(trialProgressColor)
//                                 .frame(width: max(0, trialProgress * 300), height: 8)
//                                 .animation(.easeInOut(duration: 0.3), value: trialProgress)
//                         }
//                         .frame(maxWidth: 300)
                        
//                         Text(trialStatusText)
//                             .font(.caption)
//                             .foregroundColor(trialProgress > 0.8 ? .orange : DarkTheme.textSecondary)
//                     }
//                 }
                
//                 // Feature access indicators
//                 if subscriptionManager.currentTier != .pro {
//                     Divider()
//                         .opacity(0.3)
                    
//                     VStack(alignment: .leading, spacing: 8) {
//                         Text(localizationManager.localizedString("settings.subscription.premium_features"))
//                             .font(.subheadline)
//                             .fontWeight(.semibold)
//                             .foregroundColor(DarkTheme.textPrimary)
                        
//                         LazyVGrid(columns: [
//                             GridItem(.flexible()),
//                             GridItem(.flexible())
//                         ], spacing: 12) {
//                             FeatureStatusCard(
//                                 icon: "infinity",
//                                 title: "Unlimited Transcriptions",
//                                 isAvailable: false
//                             )
                            
//                             FeatureStatusCard(
//                                 icon: "wand.and.stars",
//                                 title: "AI Enhancement",
//                                 isAvailable: subscriptionManager.isInTrial
//                             )
                            
//                             FeatureStatusCard(
//                                 icon: "cpu",
//                                 title: "Large Models",
//                                 isAvailable: false
//                             )
                            
//                             FeatureStatusCard(
//                                 icon: "headphones",
//                                 title: "Priority Support",
//                                 isAvailable: false
//                             )
//                         }
//                     }
//                 }
//             }
//         }
//     }
    
//     private var subscriptionStatusSubtitle: String {
//         if subscriptionManager.currentTier == .pro {
//             return "You have full access to all features"
//         } else if subscriptionManager.isInTrial {
//             return "Trial active with limited usage"
//         } else {
//             return "Free plan with basic features"
//         }
//     }
    
//     private var subscriptionStatusDescription: String {
//         if subscriptionManager.currentTier == .pro {
//             return "All features unlocked"
//         } else if subscriptionManager.isInTrial {
//             return "Trial expires when usage limit is reached"
//         } else {
//             return "Upgrade to unlock all features"
//         }
//     }
    
//     private var trialProgress: Double {
//         let totalDays = Double(SubscriptionManager.TRIAL_DURATION_DAYS)
//         let remainingDays = Double(subscriptionManager.trialDaysRemaining)
//         return max(0, min(1.0, (totalDays - remainingDays) / totalDays))
//     }
    
//     private var trialProgressColor: Color {
//         if trialProgress < 0.5 {
//             return DarkTheme.accent
//         } else if trialProgress < 0.8 {
//             return .yellow
//         } else {
//             return .orange
//         }
//     }
    
//     private var trialStatusText: String {
//         let remainingDays = subscriptionManager.trialDaysRemaining
//         if remainingDays <= 0 {
//             return "Trial period expired"
//         } else if remainingDays == 1 {
//             return "⚠️ Last day of trial"
//         } else {
//             return "\(remainingDays) days remaining"
//         }
//     }
// }


// MARK: - Feature Status Card Component
struct FeatureStatusCard: View {
    let icon: String
    let title: String
    let isAvailable: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isAvailable ? icon : "lock.fill")
                .font(.system(size: 14))
                .foregroundColor(isAvailable ? DarkTheme.accent : DarkTheme.textTertiary)
                .frame(width: 16)
            
            Text(title)
                .font(.caption)
                .foregroundColor(isAvailable ? DarkTheme.textPrimary : DarkTheme.textTertiary)
                .lineLimit(1)
            
            Spacer()
            
            if isAvailable {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.green)
            } else {
                ProBadge(style: .compact)
                    .scaleEffect(0.8)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isAvailable ? DarkTheme.accent.opacity(0.1) : DarkTheme.textTertiary.opacity(0.05))
        )
    }
}


 
