import SwiftUI
import Cocoa

struct AppPermissionsSection: View {
    @EnvironmentObject private var contextService: ContextService
    @EnvironmentObject private var localizationManager: LocalizationManager
    @EnvironmentObject private var hotkeyManager: HotkeyManager
    @StateObject private var permissionManager = PermissionManager()
    
    // Computed properties for conditional permission logic
    private var isScreenRecordingRequired: Bool {
        contextService.useScreenCaptureContext
    }
    
    private var hasPermissionIssues: Bool {
        let corePermissionsRequired = !permissionManager.isAccessibilityEnabled || permissionManager.audioPermissionStatus != .authorized
        let screenRecordingRequired = isScreenRecordingRequired && !permissionManager.isScreenRecordingEnabled
        return corePermissionsRequired || screenRecordingRequired
    }
    
    private var permissionsSubtitle: String {
        if !hasPermissionIssues {
            return localizationManager.localizedString("settings.permissions.all_granted")
        } else {
            return localizationManager.localizedString("settings.permissions.subtitle")
        }
    }
    
    var body: some View {
        SettingsSection(
            icon: "shield.lefthalf.filled",
            title: localizationManager.localizedString("settings.permissions.title"),
            subtitle: permissionsSubtitle,
            showWarning: hasPermissionIssues
        ) {
            VStack(alignment: .leading, spacing: 16) {
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
                    
                    // Screen Recording Card - Only show when Deep Context is enabled
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
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .trailing).combined(with: .opacity)
                        ))
                    }
                }
                .animation(.smooth(duration: 0.3), value: isScreenRecordingRequired)
            }
        }
        .onAppear {
            permissionManager.setHotkeyManager(hotkeyManager)
        }
    }
}