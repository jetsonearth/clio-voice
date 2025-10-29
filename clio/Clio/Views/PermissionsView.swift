import SwiftUI
import AVFoundation
import Cocoa
import KeyboardShortcuts

class PermissionManager: ObservableObject {
    @Published var audioPermissionStatus: AVAuthorizationStatus = .notDetermined
    @Published var isAccessibilityEnabled = false
    @Published var isScreenRecordingEnabled = false
    @Published var isKeyboardShortcutSet = false
    
    private weak var hotkeyManager: HotkeyManager?
    
    init(hotkeyManager: HotkeyManager? = nil) {
        self.hotkeyManager = hotkeyManager
        // Start observing system events that might indicate permission changes
        setupNotificationObservers()
        
        // Initial permission checks (delayed to avoid immediate microphone access)
        DispatchQueue.main.async {
            self.checkAllPermissions()
        }
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupNotificationObservers() {
        // Only observe when app becomes active, as this is a likely time for permissions to have changed
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: NSApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    @objc private func applicationDidBecomeActive() {
        checkAllPermissions()
    }
    
    func checkAllPermissions() {
        checkAccessibilityPermissions()
        checkScreenRecordingPermission()
        checkAudioPermissionStatus()
        checkKeyboardShortcut()
    }
    
    func checkAccessibilityPermissions() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false]
        let accessibilityEnabled = AXIsProcessTrustedWithOptions(options)
        DispatchQueue.main.async {
            self.isAccessibilityEnabled = accessibilityEnabled
        }
    }
    
    func checkScreenRecordingPermission() {
        DispatchQueue.main.async {
            self.isScreenRecordingEnabled = CGPreflightScreenCaptureAccess()
        }
    }
    
    func requestScreenRecordingPermission() {
        CGRequestScreenCaptureAccess()
    }
    
    func checkAudioPermissionStatus() {
        DispatchQueue.main.async {
            self.audioPermissionStatus = AVCaptureDevice.authorizationStatus(for: .audio)
        }
    }
    
    func requestAudioPermission() {
        AVCaptureDevice.requestAccess(for: .audio) { granted in
            DispatchQueue.main.async {
                self.audioPermissionStatus = granted ? .authorized : .denied
            }
        }
    }
    
    func checkKeyboardShortcut() {
        DispatchQueue.main.async {
            let libraryShortcut = KeyboardShortcuts.getShortcut(for: .toggleMiniRecorder) != nil
            let customShortcut = self.hotkeyManager?.customShortcut != nil
            self.isKeyboardShortcutSet = libraryShortcut || customShortcut
        }
    }
    
    func setHotkeyManager(_ hotkeyManager: HotkeyManager) {
        self.hotkeyManager = hotkeyManager
        checkKeyboardShortcut() // Recheck after setting the manager
    }
}

struct PermissionCard: View {
    let icon: String
    let title: String
    let description: String
    let isGranted: Bool
    let buttonTitle: String
    let buttonAction: () -> Void
    let checkPermission: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                // Icon with modern rectangular background
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.accentColor)
                    .frame(width: 32, height: 32)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.accentColor.opacity(0.1))
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(DarkTheme.textPrimary)
                    
                    Text(description)
                        .font(.system(size: 12))
                        .foregroundColor(DarkTheme.textSecondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                // Status indicator with color coding
                HStack(spacing: 6) {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 8, height: 8)
                    
                    Text(isGranted ? "Enabled" : "Required")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(statusColor)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isGranted ? Color.clear : statusColor.opacity(0.1))
                        .stroke(isGranted ? Color.clear : statusColor.opacity(0.3), lineWidth: 1)
                )
                .onTapGesture {
                    if !isGranted {
                        buttonAction()
                    }
                }
                .help(isGranted ? "" : "Click to open system settings")
                .scaleEffect(isGranted ? 1.0 : 1.0)
                .onHover { hovering in
                    if !isGranted {
                        // Visual feedback on hover for required permissions
                    }
                }
            }
            
            // Action button only for missing permissions
            if !isGranted {
                AddNewButton(buttonTitle, action: buttonAction)
                    .background(Color.clear)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(DarkTheme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(statusColor.opacity(isGranted ? 0.3 : 0.5), lineWidth: 1)
                )
        )
        .onTapGesture {
            checkPermission()
        }
    }
    
    private var statusColor: Color {
        isGranted ? DarkTheme.success : DarkTheme.warning
    }
}

struct PermissionsView: View {
    @StateObject private var permissionManager = PermissionManager()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                // Header
                VStack(spacing: 20) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.accentColor.opacity(0.1))
                            .frame(width: 70, height: 70)
                        
                        Image(systemName: "shield.lefthalf.filled")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(Color.accentColor)
                            .symbolRenderingMode(.hierarchical)
                    }
                    
                    VStack(spacing: 12) {
                        Text("App Permissions")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(DarkTheme.textPrimary)
                        
                        Text("Clio requires the following permissions to function properly")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(DarkTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.top, 20)
                
                // All permissions status summary
                if allPermissionsGranted {
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(DarkTheme.success)
                        
                        Text("All permissions are properly configured")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(DarkTheme.success)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(DarkTheme.success.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(DarkTheme.success.opacity(0.2), lineWidth: 1)
                            )
                    )
                }
                
                // Permission Cards
                VStack(spacing: 20) {
                    // Keyboard Shortcut Permission
                    PermissionCard(
                        icon: "keyboard",
                        title: "Keyboard Shortcut",
                        description: "Set up a keyboard shortcut to use Clio anywhere",
                        isGranted: permissionManager.isKeyboardShortcutSet,
                        buttonTitle: "Configure Shortcut",
                        buttonAction: {
                            NotificationCenter.default.post(
                                name: .navigateToDestination,
                                object: nil,
                                userInfo: ["destination": "Settings"]
                            )
                        },
                        checkPermission: { permissionManager.checkKeyboardShortcut() }
                    )
                    
                    // Audio Permission
                    PermissionCard(
                        icon: "mic",
                        title: "Microphone Access",
                        description: "Allow Clio to record your voice for transcription",
                        isGranted: permissionManager.audioPermissionStatus == .authorized,
                        buttonTitle: permissionManager.audioPermissionStatus == .notDetermined ? "Request Permission" : "Open System Settings",
                        buttonAction: {
                            if permissionManager.audioPermissionStatus == .notDetermined {
                                permissionManager.requestAudioPermission()
                            } else {
                                if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone") {
                                    NSWorkspace.shared.open(url)
                                }
                            }
                        },
                        checkPermission: { permissionManager.checkAudioPermissionStatus() }
                    )
                    
                    // Accessibility Permission
                    PermissionCard(
                        icon: "accessibility",
                        title: "Accessibility Access",
                        description: "Allow Clio to paste transcribed text directly at your cursor position",
                        isGranted: permissionManager.isAccessibilityEnabled,
                        buttonTitle: "Open System Settings",
                        buttonAction: {
                            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                                NSWorkspace.shared.open(url)
                            }
                        },
                        checkPermission: { permissionManager.checkAccessibilityPermissions() }
                    )
                    
                    // Screen Recording Permission
                    PermissionCard(
                        icon: "rectangle.on.rectangle",
                        title: "Screen Recording Access",
                        description: "Allow Clio to understand context from your screen for transcript enhancement",
                        isGranted: permissionManager.isScreenRecordingEnabled,
                        buttonTitle: "Request Permission",
                        buttonAction: {
                            permissionManager.requestScreenRecordingPermission()
                            // After requesting, open system preferences as fallback
                            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture") {
                                NSWorkspace.shared.open(url)
                            }
                        },
                        checkPermission: { permissionManager.checkScreenRecordingPermission() }
                    )
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DarkTheme.background)
        .onAppear {
            permissionManager.checkAllPermissions()
        }
    }
    
    private var allPermissionsGranted: Bool {
        permissionManager.isKeyboardShortcutSet &&
        permissionManager.audioPermissionStatus == .authorized &&
        permissionManager.isAccessibilityEnabled &&
        permissionManager.isScreenRecordingEnabled
    }
}

#Preview {
    PermissionsView()
}
