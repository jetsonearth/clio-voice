import SwiftUI
import Cocoa
import LaunchAtLogin
import AVFoundation

struct SystemSettingsSection: View {
    // Audio Cleanup
    @AppStorage("IsAudioCleanupEnabled") private var isAudioCleanupEnabled = true
    // Launch at Login default-on guard
    @AppStorage("_LaunchAtLoginDefaulted") private var launchDefaulted = false
    @State private var launchAtLoginEnabled: Bool = LaunchAtLogin.isEnabled
    // Hide Dock icon (menu-bar-only) toggle
    @AppStorage("IsMenuBarOnly") private var isMenuBarOnly: Bool = false
    // Notch transcript toggle (default ON)
    @AppStorage("NotchTranscriptEnabled") private var notchTranscriptEnabled: Bool = true
    // Recorder style toggle (default to Notch)
    @AppStorage("RecorderStyleIsNotch") private var recorderStyleIsNotch: Bool = true

    // Permissions
    @EnvironmentObject private var contextService: ContextService
    @EnvironmentObject private var localizationManager: LocalizationManager
    @EnvironmentObject private var hotkeyManager: HotkeyManager
    @EnvironmentObject private var recordingEngine: RecordingEngine
    @StateObject private var permissionManager = PermissionManager()

    // Sign out

    private var isScreenRecordingRequired: Bool { contextService.useScreenCaptureContext }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            Text(localizationManager.localizedString("settings.system_settings.header"))
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(DarkTheme.textSecondary.opacity(0.8))
                .textCase(.uppercase)
                .tracking(0.5)

            // Grouped card
            VStack(spacing: 0) {
                // Audio Cleanup row
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

                    Toggle("", isOn: $isAudioCleanupEnabled)
                        .toggleStyle(SwitchToggleStyle(tint: DarkTheme.accent))
                        .scaleEffect(1.0)
                }
                .padding(16)

                // Divider
                Rectangle().fill(DarkTheme.textSecondary.opacity(0.2)).frame(height: 1).padding(.horizontal, 16)

                // Launch at Login row
                HStack(spacing: 12) {
                    Image(systemName: "power")
                        .font(.system(size: 20))
                        .foregroundColor(.accentColor)
                        .frame(width: 24, height: 24)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(localizationManager.localizedString("settings.launch_at_login"))
                            .font(.headline)
                            .foregroundColor(DarkTheme.textPrimary)
                        Text(localizationManager.localizedString("settings.launch_at_login.subtitle"))
                            .font(.subheadline)
                            .foregroundColor(DarkTheme.textSecondary)
                    }

                    Spacer()

                    Toggle("", isOn: $launchAtLoginEnabled)
                        .toggleStyle(SwitchToggleStyle(tint: DarkTheme.accent))
                        .onChange(of: launchAtLoginEnabled) { _, newValue in
                            LaunchAtLogin.isEnabled = newValue
                        }
                }
                .padding(16)

                // Divider
                Rectangle().fill(DarkTheme.textSecondary.opacity(0.2)).frame(height: 1).padding(.horizontal, 16)

                // Hide Dock Icon (Menu-bar only) row
                HStack(spacing: 12) {
                    Image(systemName: "dock.rectangle")
                        .font(.system(size: 20))
                        .foregroundColor(.accentColor)
                        .frame(width: 24, height: 24)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(localizationManager.localizedString("settings.hide_dock_icon.title"))
                            .font(.headline)
                            .foregroundColor(DarkTheme.textPrimary)
                        Text(localizationManager.localizedString("settings.hide_dock_icon.description"))
                            .font(.subheadline)
                            .foregroundColor(DarkTheme.textSecondary)
                    }

                    Spacer()

                    Toggle("", isOn: $isMenuBarOnly)
                        .toggleStyle(SwitchToggleStyle(tint: DarkTheme.accent))
                        .onChange(of: isMenuBarOnly) { _, newValue in
                            UserDefaults.standard.set(newValue, forKey: "IsMenuBarOnly")
                            if newValue {
                                NSApp.setActivationPolicy(.accessory)
                            } else {
                                NSApp.setActivationPolicy(.regular)
                                NSApp.unhide(nil)
                            }
                        }
                }
                .padding(16)

                // Divider
                Rectangle().fill(DarkTheme.textSecondary.opacity(0.2)).frame(height: 1).padding(.horizontal, 16)

                // Recorder Style row - COMMENTED OUT
                /*
                HStack(spacing: 12) {
                    Image(systemName: "rectangle.on.rectangle")
                        .font(.system(size: 20))
                        .foregroundColor(.accentColor)
                        .frame(width: 24, height: 24)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Recorder Style")
                            .font(.headline)
                            .foregroundColor(DarkTheme.textPrimary)
                        Text("Use the notch recorder. Off uses the mini recorder.")
                            .font(.subheadline)
                            .foregroundColor(DarkTheme.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()

                    Toggle("", isOn: $recorderStyleIsNotch)
                        .toggleStyle(SwitchToggleStyle(tint: DarkTheme.accent))
                        .onChange(of: recorderStyleIsNotch) { _, newValue in
                            recordingEngine.recorderType = newValue ? "notch" : "mini"
                            if newValue {
                                recordingEngine.miniWindowManager?.hide()
                            } else {
                                recordingEngine.notchWindowManager?.hide()
                            }
                        }
                }
                .padding(16)
                .onAppear {
                    // Sync recordingEngine with persisted preference on load
                    recordingEngine.recorderType = recorderStyleIsNotch ? "notch" : "mini"
                }
                */

                // Divider
                Rectangle().fill(DarkTheme.textSecondary.opacity(0.2)).frame(height: 1).padding(.horizontal, 16)

                // Streaming transcript under Notch row
                HStack(spacing: 12) {
                    Image(systemName: "captions.bubble")
                        .font(.system(size: 20))
                        .foregroundColor(.accentColor)
                        .frame(width: 24, height: 24)

VStack(alignment: .leading, spacing: 4) {
                        Text(localizationManager.localizedString("settings.notch_transcript.title"))
                            .font(.headline)
                            .foregroundColor(DarkTheme.textPrimary)
                        Text(localizationManager.localizedString("settings.notch_transcript.description"))
                            .font(.subheadline)
                            .foregroundColor(DarkTheme.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()

                    Toggle("", isOn: $notchTranscriptEnabled)
                        .toggleStyle(SwitchToggleStyle(tint: DarkTheme.accent))
                        .onChange(of: notchTranscriptEnabled) { _, newValue in
                            // Update active notch UI immediately if present
                            recordingEngine.notchWindowManager?.applyBottomTranscriptPreference(newValue)
                        }
                }
                .padding(16)

                // Divider
                Rectangle().fill(DarkTheme.textSecondary.opacity(0.2)).frame(height: 1).padding(.horizontal, 16)

                // App Permissions sub-section inside the group
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        Image(systemName: "shield.lefthalf.filled")
                            .font(.system(size: 20))
                            .foregroundColor(.accentColor)
                            .frame(width: 24, height: 24)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(localizationManager.localizedString("settings.permissions.title"))
                                .font(.headline)
                                .foregroundColor(DarkTheme.textPrimary)
                            Text(appPermissionsSubtitle)
                                .font(.subheadline)
                                .foregroundColor(DarkTheme.textSecondary)
                        }

                        Spacer()
                    }

                    // Cards
                    HStack(spacing: 16) {
                        CompactPermissionCard(
                            icon: "keyboard",
                            title: localizationManager.localizedString("settings.permission.keyboard_shortcut"),
                            isGranted: permissionManager.isKeyboardShortcutSet,
                            buttonAction: { },
                            checkPermission: { permissionManager.checkKeyboardShortcut() }
                        )
                        CompactPermissionCard(
                            icon: "mic.fill",
                            title: localizationManager.localizedString("settings.permission.microphone"),
                            isGranted: permissionManager.audioPermissionStatus == .authorized,
                            buttonAction: { permissionManager.requestAudioPermission() },
                            checkPermission: { permissionManager.checkAudioPermissionStatus() }
                        )
                        CompactPermissionCard(
                            icon: "accessibility",
                            title: localizationManager.localizedString("settings.permission.accessibility"),
                            isGranted: permissionManager.isAccessibilityEnabled,
                            buttonAction: {
                                let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
                                NSWorkspace.shared.open(url)
                            },
                            checkPermission: { permissionManager.checkAccessibilityPermissions() }
                        )
                        if isScreenRecordingRequired {
                            CompactPermissionCard(
                                icon: "desktopcomputer",
                                title: localizationManager.localizedString("settings.permission.screen_recording"),
                                isGranted: permissionManager.isScreenRecordingEnabled,
                                buttonAction: {
                                    let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture")!
                                    NSWorkspace.shared.open(url)
                                },
                                checkPermission: { permissionManager.checkScreenRecordingPermission() }
                            )
                            .transition(.opacity)
                        }
                    }
                    .animation(.smooth(duration: 0.3), value: isScreenRecordingRequired)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 4)
                }
                .padding(16)

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
        .onAppear {
            permissionManager.setHotkeyManager(hotkeyManager)
            // Default Launch at Login to ON once
            if !launchDefaulted {
                LaunchAtLogin.isEnabled = true
                launchAtLoginEnabled = true
                launchDefaulted = true
            } else {
                launchAtLoginEnabled = LaunchAtLogin.isEnabled
            }
        }
    }

    private var appPermissionsSubtitle: String {
        if permissionManager.isAccessibilityEnabled &&
            permissionManager.audioPermissionStatus == .authorized &&
            (!isScreenRecordingRequired || permissionManager.isScreenRecordingEnabled) {
            return localizationManager.localizedString("settings.permissions.all_granted")
        }
        return localizationManager.localizedString("settings.permissions.subtitle")
    }
}
