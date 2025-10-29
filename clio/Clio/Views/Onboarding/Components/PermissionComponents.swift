import SwiftUI
import AVFoundation

// MARK: - Professional Permissions View
struct ProfessionalPermissionsView: View {
    @ObservedObject var viewModel: ProfessionalOnboardingViewModel
    @StateObject private var permissionManager = PermissionManager()
    @State private var showMicrophoneDialog = false
    @State private var showAccessibilityDialog = false
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with back button
            HStack {
                StyledBackButton {
                    // Go back to authentication
                }
                Spacer()
            }
            .padding(.horizontal, 60)
            .padding(.top, 40)
            
            // Main content
            HStack(spacing: 80) {
                // Left side - Permission setup
                VStack(alignment: .leading, spacing: 40) {
                    // Title section
                    VStack(alignment: .leading, spacing: 16) {
                        Text(localizationManager.localizedString("onboarding.permissions.title"))
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(DarkTheme.textPrimary)
                        
                        Text(localizationManager.localizedString("onboarding.permissions.description"))
                            .font(.system(size: 18))
                            .foregroundColor(DarkTheme.textSecondary)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    // Permission cards
                    VStack(spacing: 20) {
                        EnhancedPermissionCard(
                            icon: "text.cursor",
                            title: localizationManager.localizedString("onboarding.permissions.accessibility_title"),
                            subtitle: localizationManager.localizedString("onboarding.permissions.accessibility_subtitle"),
                            isGranted: permissionManager.isAccessibilityEnabled,
                            delay: 0.1,
                            action: {
                                showAccessibilityDialog = true
                            }
                        )
                        
                        EnhancedPermissionCard(
                            icon: "waveform",
                            title: localizationManager.localizedString("onboarding.permissions.microphone_title"), 
                            subtitle: localizationManager.localizedString("onboarding.permissions.microphone_subtitle"),
                            isGranted: permissionManager.audioPermissionStatus == .authorized,
                            delay: 0.2,
                            action: {
                                if permissionManager.audioPermissionStatus != .authorized {
                                    permissionManager.requestAudioPermission()
                                    showMicrophoneDialog = true
                                }
                            }
                        )

                        // Optional Screen Recording card (collapsible details + policy link)
                        GlassmorphismCard(cornerRadius: 16) {
                            ScreenRecordingPermissionRow(
                                isGranted: permissionManager.isScreenRecordingEnabled,
                                requestAction: {
                                    if !permissionManager.isScreenRecordingEnabled {
                                        let granted = CGRequestScreenCaptureAccess()
                                        if !granted {
                                            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture")!)
                                        }
                                    }
                                }
                            )
                        }
                    }
                    
                    Spacer()
                    
                    // Continue button
                    StyledActionButton(
                        title: localizationManager.localizedString("onboarding.permissions.continue"),
                        action: {
                            viewModel.nextScreen()
                        },
                        isDisabled: !canContinue
                    )
                    .padding(.bottom, 60)
                }
                .frame(maxWidth: 500)
                
                // Right side - Visual preview
                PermissionsVisualColumn(
                    showMicrophoneDialog: showMicrophoneDialog,
                    showAccessibilityDialog: showAccessibilityDialog
                )
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 60)
            .padding(.vertical, 40)
            .frame(maxHeight: .infinity)
        }
        .onAppear {
            permissionManager.checkAllPermissions()
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                permissionManager.checkAllPermissions()
            }
        }
    }
    
    private var canContinue: Bool {
        permissionManager.audioPermissionStatus == .authorized &&
        permissionManager.isAccessibilityEnabled
    }
}

// MARK: - Enhanced Permission Card
struct EnhancedPermissionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let isGranted: Bool
    let delay: Double
    let action: () -> Void
    @State private var isVisible = false
    @State private var isHovered = false
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        Button(action: isGranted ? {} : action) {
            HStack(spacing: 20) {
                // Icon container
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isGranted ? DarkTheme.textPrimary.opacity(0.15) : DarkTheme.textPrimary.opacity(0.08))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(isGranted ? DarkTheme.textPrimary : DarkTheme.textPrimary.opacity(0.7))
                }
                
                // Content
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 12) {
                        Text(title)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(DarkTheme.textPrimary)
                        
                        Spacer()
                        
                        // Status indicator
                        if isGranted {
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(DarkTheme.textPrimary)
                                Text(localizationManager.localizedString("onboarding.permissions.granted"))
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(DarkTheme.textPrimary.opacity(0.8))
                            }
                        } else {
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.circle")
                                    .font(.system(size: 16))
                                    .foregroundColor(DarkTheme.textPrimary.opacity(0.6))
                                Text(localizationManager.localizedString("onboarding.permissions.required"))
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(DarkTheme.textPrimary.opacity(0.6))
                            }
                        }
                    }
                    
                    Text(subtitle)
                        .font(.system(size: 15))
                        .foregroundColor(DarkTheme.textSecondary)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                    
                    if !isGranted {
                        HStack(spacing: 8) {
                            Text(localizationManager.localizedString("onboarding.permissions.tap_to_grant"))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(DarkTheme.textPrimary.opacity(0.8))
                            
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 12))
                                .foregroundColor(DarkTheme.textPrimary.opacity(0.8))
                        }
                        .padding(.top, 4)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(white: 0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isGranted 
                                    ? DarkTheme.textPrimary.opacity(0.2)
                                    : (isHovered ? DarkTheme.textPrimary.opacity(0.15) : DarkTheme.textPrimary.opacity(0.08)),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(isGranted)
        .scaleEffect(isVisible ? 1.0 : 0.95)
        .opacity(isVisible ? 1.0 : 0.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay), value: isVisible)
        .scaleEffect(isHovered && !isGranted ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover { hovering in
            if !isGranted {
                isHovered = hovering
            }
        }
        .onAppear {
            withAnimation {
                isVisible = true
            }
        }
    }
}

// MARK: - Permissions Visual Column
struct PermissionsVisualColumn: View {
    let showMicrophoneDialog: Bool
    let showAccessibilityDialog: Bool
    @State private var isAnimating = false
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        VStack {
            Spacer()
            
            GlassmorphismCard(cornerRadius: 20, padding: 40) {
                VStack(spacing: 32) {
                    // Main visual
                    ZStack {
                        // Background glow
                        Circle()
                            .fill(DarkTheme.textPrimary.opacity(0.1))
                            .frame(width: 120, height: 120)
                            .scaleEffect(isAnimating ? 1.2 : 1.0)
                            .opacity(isAnimating ? 0.3 : 0.8)
                            .animation(
                                Animation.easeInOut(duration: 2.0)
                                    .repeatForever(autoreverses: true),
                                value: isAnimating
                            )
                        
                        // Main circle
                        Circle()
                            .fill(DarkTheme.textPrimary.opacity(0.15))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Circle()
                                    .stroke(DarkTheme.textPrimary.opacity(0.3), lineWidth: 2)
                            )
                        
                        // Central icon
                        Image(systemName: "shield.checkered")
                            .font(.system(size: 32))
                            .foregroundColor(DarkTheme.textPrimary)
                    }
                    
                    VStack(spacing: 16) {
                        Text(localizationManager.localizedString("onboarding.permissions.privacy_title"))
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(DarkTheme.textPrimary)
                        
                        Text(localizationManager.localizedString("onboarding.permissions.privacy_description"))
                            .font(.system(size: 16))
                            .foregroundColor(DarkTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                    
                    // Feature highlights
                    VStack(spacing: 16) {
                        PermissionFeatureRow(
                            icon: "lock.shield",
                            text: localizationManager.localizedString("onboarding.permissions.feature_local"),
                            delay: 0.3
                        )
                        
                        PermissionFeatureRow(
                            icon: "eye.slash",
                            text: localizationManager.localizedString("onboarding.permissions.feature_no_data"),
                            delay: 0.5
                        )
                        
                        PermissionFeatureRow(
                            icon: "hand.raised",
                            text: localizationManager.localizedString("onboarding.permissions.feature_control"),
                            delay: 0.7
                        )
                    }
                }
                .frame(width: 350, height: 400)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Permission Feature Row
struct PermissionFeatureRow: View {
    let icon: String
    let text: String
    let delay: Double
    @State private var isVisible = false
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(DarkTheme.textPrimary)
                .frame(width: 20)
            
            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(DarkTheme.textSecondary)
            
            Spacer()
        }
        .opacity(isVisible ? 1.0 : 0.0)
        .animation(.easeInOut(duration: 0.6).delay(delay), value: isVisible)
        .onAppear {
            withAnimation {
                isVisible = true
            }
        }
    }
}

// MARK: - Screen Recording Row for simple onboarding
struct ScreenRecordingPermissionRow: View {
    let isGranted: Bool
    let requestAction: () -> Void
    @State private var expanded: Bool = false
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isGranted ? DarkTheme.textPrimary.opacity(0.15) : DarkTheme.textPrimary.opacity(0.08))
                        .frame(width: 48, height: 48)
                    Image(systemName: isGranted ? "checkmark" : "desktopcomputer")
                        .foregroundColor(DarkTheme.textPrimary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(localizationManager.localizedString("onboarding.permissions.screen_recording.title"))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(DarkTheme.textPrimary)
                    Text(localizationManager.localizedString("onboarding.permissions.screen_recording.short"))
                        .font(.system(size: 14))
                        .foregroundColor(DarkTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                if !isGranted {
                    Button(localizationManager.localizedString("onboarding.enhanced_permissions.grant_access")) {
                        requestAction()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            
            DisclosureGroup(isExpanded: $expanded) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(localizationManager.localizedString("onboarding.permissions.screen_recording.long"))
                        .font(.system(size: 13))
                        .foregroundColor(DarkTheme.textSecondary)
                    Link(localizationManager.localizedString("privacy.policy"), destination: URL(string: "https://www.cliovoice.com/privacy")!)
                        .font(.system(size: 13, weight: .medium))
                }
                .padding(.top, 6)
            } label: {
                HStack(spacing: 6) {
                    Text(expanded ? localizationManager.localizedString("privacy.hide_details") : localizationManager.localizedString("privacy.learn_more"))
                        .font(.system(size: 12, weight: .medium))
                    Image(systemName: expanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12))
                }
                .foregroundColor(DarkTheme.textPrimary.opacity(0.9))
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation { expanded.toggle() }
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }
}
