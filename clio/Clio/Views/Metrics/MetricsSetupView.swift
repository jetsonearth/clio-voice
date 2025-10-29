import SwiftUI
import KeyboardShortcuts

struct MetricsSetupView: View {
    @EnvironmentObject private var whisperState: WhisperState
    @State private var isAccessibilityEnabled = AXIsProcessTrusted()
    @State private var isScreenRecordingEnabled = CGPreflightScreenCaptureAccess()
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: geometry.size.height * 0.05) {
                    // Header
                    VStack(spacing: geometry.size.height * 0.02) {
                        AppIconView(size: min(90, geometry.size.width * 0.15), cornerRadius: 22)
                        
                        VStack(spacing: geometry.size.height * 0.01) {
                            Text("Welcome to Io")
                                .font(.system(size: min(32, geometry.size.width * 0.05), weight: .bold))
                                .multilineTextAlignment(.center)
                            
                            Text("Complete the setup to get started")
                                .font(.system(size: min(16, geometry.size.width * 0.025)))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.top, geometry.size.height * 0.03)
                    
                    // Setup Steps
                    VStack(spacing: geometry.size.height * 0.02) {
                        ForEach(0..<4) { index in
                            setupStep(for: index, geometry: geometry)
                        }
                    }
                    .padding(.horizontal, geometry.size.width * 0.03)
                    
                    Spacer(minLength: geometry.size.height * 0.02)
                    
                    // Action Button
                    actionButton
                        .frame(maxWidth: min(600, geometry.size.width * 0.8))
                    
                    // Help Text
                    helpText
                        .padding(.bottom, geometry.size.height * 0.03)
                }
                .padding(.horizontal, geometry.size.width * 0.05)
                .frame(minHeight: geometry.size.height)
                .background {
                    Color(.controlBackgroundColor)
                }
            }
        }
        .frame(minWidth: 500, minHeight: 400)
    }
    
    private func setupStep(for index: Int, geometry: GeometryProxy) -> some View {
        let isCompleted: Bool
        let icon: String
        let title: String
        let description: String
        
        switch index {
        case 0:
            isCompleted = KeyboardShortcuts.getShortcut(for: .toggleMiniRecorder) != nil
            icon = "command"
            title = "Set Keyboard Shortcut"
            description = "Set up a keyboard shortcut to use Io anywhere"
        case 1:
            isCompleted = isAccessibilityEnabled
            icon = "hand.raised"
            title = "Enable Accessibility"
            description = "Allow Io to paste transcribed text directly at your cursor position"
        case 2:
            isCompleted = isScreenRecordingEnabled
            icon = "video"
            title = "Enable Screen Recording"
            description = "Allow Io to understand context from your screen for transcript  Enhancement"
        default:
            isCompleted = whisperState.currentModel != nil
            icon = "arrow.down"
            title = "Download Model"
            description = "Choose and download an AI model"
        }
        
        return HStack(spacing: geometry.size.width * 0.03) {
            // Status Icon
            ZStack {
                Circle()
                    .fill(isCompleted ?
                          Color(nsColor: .controlAccentColor).opacity(0.15) :
                          Color(nsColor: .systemRed).opacity(0.15))
                    .frame(width: min(44, geometry.size.width * 0.08), height: min(44, geometry.size.width * 0.08))
                
                Image(systemName: "\(icon).circle")
                    .font(.system(size: min(24, geometry.size.width * 0.04), weight: .medium))
                    .foregroundColor(isCompleted ? Color(nsColor: .controlAccentColor) : Color(nsColor: .systemRed))
                    .symbolRenderingMode(.hierarchical)
            }
            
            // Text
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: min(16, geometry.size.width * 0.025), weight: .semibold))
                Text(description)
                    .font(.system(size: min(14, geometry.size.width * 0.022)))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Status indicator
            if isCompleted {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: min(26, geometry.size.width * 0.045), weight: .semibold))
                    .foregroundColor(Color.green.opacity(0.95))
                    .symbolRenderingMode(.hierarchical)
            } else {
                Circle()
                    .stroke(Color(nsColor: .systemRed), lineWidth: 2)
                    .frame(width: min(24, geometry.size.width * 0.04), height: min(24, geometry.size.width * 0.04))
            }
        }
        .padding(.horizontal, geometry.size.width * 0.03)
        .padding(.vertical, geometry.size.height * 0.02)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.windowBackgroundColor))
                .shadow(
                    color: Color.black.opacity(0.05),
                    radius: 8,
                    x: 0,
                    y: 4
                )
        )
    }
    
    private var actionButton: some View {
        Button(action: {
            if isShortcutAndAccessibilityGranted {
                openModelManagement()
            } else {
                // Handle different permission requests based on which one is missing
                if KeyboardShortcuts.getShortcut(for: .toggleMiniRecorder) == nil {
                    openSettings()
                } else if !AXIsProcessTrusted() {
                    if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                        NSWorkspace.shared.open(url)
                    }
                } else if !CGPreflightScreenCaptureAccess() {
                    CGRequestScreenCaptureAccess()
                    // After requesting, open system preferences as fallback
                    if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture") {
                        NSWorkspace.shared.open(url)
                    }
                }
            }
        }) {
            HStack(spacing: 8) {
                Text(isShortcutAndAccessibilityGranted ? "Download Model" : getActionButtonTitle())
                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .semibold))
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                LinearGradient(
                    colors: [
                        Color(nsColor: .controlAccentColor),
                        Color(nsColor: .controlAccentColor).opacity(0.8)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(DarkTheme.textPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
        .shadow(
            color: Color(nsColor: .controlAccentColor).opacity(0.3),
            radius: 10,
            y: 5
        )
    }
    
    private func getActionButtonTitle() -> String {
        if KeyboardShortcuts.getShortcut(for: .toggleMiniRecorder) == nil {
            return "Configure Shortcut"
        } else if !AXIsProcessTrusted() {
            return "Enable Accessibility"
        } else if !CGPreflightScreenCaptureAccess() {
            return "Enable Screen Recording"
        }
        return "Open Settings"
    }
    
    private var helpText: some View {
        Text("Need help? Check the Help menu for support options")
            .font(.system(size: 13))
            .foregroundColor(.secondary)
    }
    
    private var isShortcutAndAccessibilityGranted: Bool {
        KeyboardShortcuts.getShortcut(for: .toggleMiniRecorder) != nil && 
        AXIsProcessTrusted() && 
        CGPreflightScreenCaptureAccess()
    }
    
    private func openSettings() {
        NotificationCenter.default.post(
            name: .navigateToDestination,
            object: nil,
            userInfo: ["destination": "Settings"]
        )
    }
    
    private func openModelManagement() {
        NotificationCenter.default.post(
            name: .navigateToDestination,
            object: nil,
            userInfo: ["destination": "AI Models"]
        )
    }
}

