import SwiftUI
import AVFoundation
import AppKit

// MARK: - Enhanced Permissions View (Two-column, single-card stepper)
struct EnhancedPermissionsView: View {
    @ObservedObject var viewModel: ProfessionalOnboardingViewModel
    @StateObject private var permissionManager = PermissionManager()
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    // Step state
    @State private var currentStep: Step = .accessibility
    @State private var isRequesting = false
    @State private var showScreenRecordingDetails = false
    
    enum Step: Int, CaseIterable {
        case accessibility
        case microphone
        case screenRecording // optional
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Two-column layout
            HStack(spacing: 48) {
                // Left: header + single permission card + controls
                VStack(alignment: .leading, spacing: 20) {
                    // Header only on the left
                    VStack(alignment: .leading, spacing: 8) {
                        Text(localizationManager.localizedString("onboarding.enhanced_permissions.title"))
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(DarkTheme.textPrimary)
                        Text(localizationManager.localizedString("onboarding.enhanced_permissions.subtitle"))
                            .font(.system(size: 15))
                            .foregroundColor(DarkTheme.textSecondary)
                    }
                    .padding(.top, 80)
                    
                    // Card sits right under the header (not vertically centered)
                    PermissionStepCard(
                        step: currentStep,
                        isGranted: isCurrentGranted,
                        isRequesting: isRequesting,
                        primaryAction: { requestCurrentPermission() }
                    )

                    // Step-specific explanatory text below the card
                    Group {
                        switch currentStep {
                        case .accessibility:
                            GlassmorphismCard(cornerRadius: 12) {
                                Text(localizationManager.localizedString("onboarding.permissions.accessibility.long"))
                                    .font(.system(size: 15))
                                    .foregroundColor(DarkTheme.textPrimary.opacity(0.9))
                                    .lineSpacing(3)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(DarkTheme.textPrimary.opacity(0.12), lineWidth: 1)
                            )
                            .padding(.top, 12)
                        case .microphone:
                            GlassmorphismCard(cornerRadius: 12) {
                                Text(localizationManager.localizedString("onboarding.permissions.microphone.long"))
                                    .font(.system(size: 15))
                                    .foregroundColor(DarkTheme.textPrimary.opacity(0.9))
                                    .lineSpacing(3)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(DarkTheme.textPrimary.opacity(0.12), lineWidth: 1)
                            )
                            .padding(.top, 12)

                        case .screenRecording:
                            GlassmorphismCard(cornerRadius: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    // Make optionality explicit above the description
                                    HStack(spacing: 8) {
                                        Image(systemName: "info.circle")
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(.accentColor)
                                        Text(localizationManager.localizedString("onboarding.permissions.screen_recording.optional_notice"))
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(DarkTheme.textPrimary)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .fill(Color.accentColor.opacity(0.12))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                    .stroke(Color.accentColor.opacity(0.35), lineWidth: 1)
                                            )
                                    )
                                    .padding(.bottom, 4)

                                    // Short description by default
                                    Text(localizationManager.localizedString("onboarding.permissions.screen_recording.short"))
                                        .font(.system(size: 15))
                                        .foregroundColor(DarkTheme.textPrimary.opacity(0.9))
                                        .lineSpacing(3)
                                        .fixedSize(horizontal: false, vertical: true)

                                    // Expandable long description
                                    if showScreenRecordingDetails {
                                        Text(localizationManager.localizedString("onboarding.permissions.screen_recording.long"))
                                            .font(.system(size: 14))
                                            .foregroundColor(DarkTheme.textPrimary.opacity(0.9))
                                            .lineSpacing(3)
                                            .fixedSize(horizontal: false, vertical: true)
                                            .transition(.opacity)
                                            .padding(.top, 4)
                                    }

                                    Button(action: { withAnimation(.easeInOut(duration: 0.2)) { showScreenRecordingDetails.toggle() } }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: showScreenRecordingDetails ? "chevron.up" : "chevron.down")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(.accentColor)
                                            Text(showScreenRecordingDetails ? localizationManager.localizedString("general.show_less") : localizationManager.localizedString("privacy.learn_more"))
                                                .font(.system(size: 13, weight: .medium))
                                                .foregroundColor(.accentColor)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                    Button(action: {
                                        if let url = URL(string: "https://www.cliovoice.com/privacy") {
                                            NSWorkspace.shared.open(url)
                                        }
                                    }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "shield.checkerboard")
                                                .font(.system(size: 12))
                                                .foregroundColor(.accentColor)
                                            Text(localizationManager.localizedString("privacy.policy"))
                                                .font(.system(size: 13, weight: .medium))
                                                .foregroundColor(.accentColor)
                                            Image(systemName: "arrow.up.right")
                                                .font(.system(size: 10))
                                                .foregroundColor(.accentColor)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(DarkTheme.textPrimary.opacity(0.12), lineWidth: 1)
                            )
                            .padding(.top, 12)

                            // Prominent skip affordance for clarity
                            HStack {
                                SkipButton(text: localizationManager.localizedString("onboarding.button.skip_for_now")) {
                                    viewModel.nextScreen()
                                }
                                .padding(.leading, 2)
                                Spacer()
                            }
                            .padding(.top, 6)
                        }
                    }
                    
                    Spacer() // push buttons to bottom
                    
                    // Navigation controls shifted downward
                    HStack(spacing: 8) {
                        StyledBackButton { viewModel.previousScreen() }
                        
                        StyledActionButton(
                            title: localizationManager.localizedString("general.continue"),
                            action: advance,
                            isDisabled: continueDisabled,
                            showArrow: true
                        )
                    }
                    .padding(.bottom, 60)
                }
                .frame(maxWidth: 520)
                .padding(.leading, 60) // left padding only for the left column
                
                // Right: visual-only panel (full-height, slightly darker than background)
                VisualOnlyPanel(step: currentStep, topInset: 80, bottomInset: 80)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(.vertical, 0) // let right panel reach near top/bottom visually
            
        }
        .frame(minWidth: 1200, minHeight: 800)
        .onAppear {
            permissionManager.checkAllPermissions()
            Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { _ in
                permissionManager.checkAllPermissions()
            }
        }
    }
    
    // MARK: - Derived state
    private var continueDisabled: Bool {
        switch currentStep {
        case .accessibility:
            return !permissionManager.isAccessibilityEnabled
        case .microphone:
            return permissionManager.audioPermissionStatus != .authorized
        case .screenRecording:
            // Optional — allow continue regardless
            return false
        }
    }
    
    private var isCurrentGranted: Bool {
        switch currentStep {
        case .accessibility: return permissionManager.isAccessibilityEnabled
        case .microphone: return permissionManager.audioPermissionStatus == .authorized
        case .screenRecording: return permissionManager.isScreenRecordingEnabled
        }
    }
    
    // MARK: - Actions
    private func advance() {
        switch currentStep {
        case .accessibility:
            currentStep = .microphone
        case .microphone:
            currentStep = .screenRecording
        case .screenRecording:
            viewModel.nextScreen()
        }
    }
    
    
    
    private func requestCurrentPermission() {
        isRequesting = true
        switch currentStep {
        case .accessibility:
            let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
            NSWorkspace.shared.open(url)
        case .microphone:
            if permissionManager.audioPermissionStatus == .denied || permissionManager.audioPermissionStatus == .restricted {
                let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone")!
                NSWorkspace.shared.open(url)
            } else {
                AVCaptureDevice.requestAccess(for: .audio) { _ in
                    DispatchQueue.main.async { isRequesting = false }
                }
            }
        case .screenRecording:
            let granted = CGRequestScreenCaptureAccess()
            if !granted {
                let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture")!
                NSWorkspace.shared.open(url)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { isRequesting = false }
        }
    }
}

// MARK: - Left column single permission card
private struct PermissionStepCard: View {
    let step: EnhancedPermissionsView.Step
    let isGranted: Bool
    let isRequesting: Bool
    let primaryAction: () -> Void
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        GlassmorphismCard(cornerRadius: 16) {
            HStack(alignment: .center, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isGranted ? DarkTheme.textPrimary.opacity(0.15) : DarkTheme.textPrimary.opacity(0.08))
                        .frame(width: 50, height: 50)
                    Image(systemName: iconName)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(isGranted ? DarkTheme.textPrimary : DarkTheme.textPrimary.opacity(0.8))
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(DarkTheme.textPrimary)
                        if isOptional {
                            Text("Optional")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(DarkTheme.textPrimary.opacity(0.8))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(
                                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                                        .fill(DarkTheme.textPrimary.opacity(0.08))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                                .stroke(DarkTheme.textPrimary.opacity(0.15), lineWidth: 1)
                                        )
                                )
                        }
                    }
                    // Move details below card for all steps
                }
                
                Spacer()
                
                if !isGranted {
                    Button(action: primaryAction) {
                        HStack(spacing: 8) {
                            Text(buttonTitle)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(DarkTheme.textPrimary)
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 12))
                                .foregroundColor(DarkTheme.textPrimary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(DarkTheme.textPrimary.opacity(0.2), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                } else {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(DarkTheme.textPrimary)
                        Text(localizationManager.localizedString("onboarding.enhanced_permissions.granted"))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(DarkTheme.textPrimary.opacity(0.8))
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
    }
    
    private var iconName: String {
        switch step {
        case .accessibility: return isGranted ? "checkmark" : "text.cursor"
        case .microphone: return isGranted ? "checkmark" : "mic.fill"
        case .screenRecording: return isGranted ? "checkmark" : "desktopcomputer"
        }
    }
    
    private var title: String {
        switch step {
        case .accessibility: return localizationManager.localizedString("onboarding.enhanced_permissions.accessibility.title")
        case .microphone: return localizationManager.localizedString("onboarding.enhanced_permissions.microphone.title")
        case .screenRecording: return localizationManager.localizedString("onboarding.permissions.screen_recording.title")
        }
    }
    
    private var description: String {
        switch step {
        case .accessibility: return localizationManager.localizedString("onboarding.enhanced_permissions.accessibility.description")
        case .microphone: return localizationManager.localizedString("onboarding.enhanced_permissions.microphone.description")
        case .screenRecording: return localizationManager.localizedString("onboarding.permissions.screen_recording.short")
        }
    }

    private var isOptional: Bool {
        step == .screenRecording
    }

    private var buttonTitle: String {
        if isRequesting {
            return localizationManager.localizedString("onboarding.enhanced_permissions.open_settings")
        }
        if step == .screenRecording {
            return localizationManager.localizedString("onboarding.enhanced_permissions.grant_access") + " (Optional)"
        }
        return localizationManager.localizedString("onboarding.enhanced_permissions.grant_access")
    }
}

// MARK: - Right column visual-only panel
private struct VisualOnlyPanel: View {
    let step: EnhancedPermissionsView.Step
    var topInset: CGFloat = 108
    var bottomInset: CGFloat = 108
    @State private var animate = false
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .topLeading) {
                // Full-height, slightly darker than app background
                Rectangle()
                    .fill(Color.black.opacity(0.12))
                    .ignoresSafeArea()
                
                // Content column: explicit top and bottom insets
                VStack(spacing: 0) {
                    // TOP: text bubble with independent top padding
                    HStack {
                        Text(topText)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(DarkTheme.textPrimary)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .stroke(DarkTheme.textPrimary.opacity(0.12), lineWidth: 1)
                                    )
                            )
                        Spacer()
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, topInset)

                    Spacer(minLength: 0)

                    // BOTTOM: image container with independent bottom padding
                    HStack {
                        Spacer()
                        Group {
                            if let img = imageForStep() {
                                Image(nsImage: img)
                                    .resizable()
                                    .aspectRatio(3/4, contentMode: .fill)
                                    .frame(maxWidth: 400, maxHeight: 520)
                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .strokeBorder(DarkTheme.textPrimary.opacity(0.10), lineWidth: 0.8)
                                    )
                            } else {
                                // Fallback animated glyph if image missing
                                ZStack {
                                    Circle()
                                        .fill(DarkTheme.textPrimary.opacity(0.1))
                                        .frame(width: 220, height: 220)
                                        .scaleEffect(animate ? 1.05 : 0.95)
                                        .opacity(animate ? 0.85 : 0.65)
                                        .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: animate)
                                    Image(systemName: symbol)
                                        .font(.system(size: 96))
                                        .foregroundColor(DarkTheme.textPrimary)
                                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 6)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        Spacer()
                    }
                    .padding(.bottom, bottomInset)
                }
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .top)
            }
            .onAppear { animate = true }
        }
    }
    
    private var symbol: String {
        switch step {
        case .accessibility: return "text.cursor"
        case .microphone: return "mic.circle.fill"
        case .screenRecording: return "display"
        }
    }
    
    private var topText: String {
        switch step {
        case .microphone:
            return localizationManager.localizedString("onboarding.enhanced_permissions.panel.microphone")
        case .screenRecording:
            return localizationManager.localizedString("onboarding.enhanced_permissions.panel.screen_recording")
        case .accessibility:
            return localizationManager.localizedString("onboarding.enhanced_permissions.panel.accessibility")
        }
    }
    
    private func imageForStep() -> NSImage? {
        let name: String = {
            switch step {
            case .accessibility: return "access"
            case .microphone: return "mic"
            case .screenRecording: return "screen"
            }
        }()
        // 1) Try bundle/Assets
        if let path = Bundle.main.path(forResource: name, ofType: "jpeg", inDirectory: "Assets"),
           let img = NSImage(contentsOfFile: path) {
            return img
        }
        // 2) Try top-level bundle resources
        if let resURL = Bundle.main.resourceURL?.appendingPathComponent("\(name).jpeg"),
           let img = NSImage(contentsOf: resURL) {
            return img
        }
        // 3) Dev fallback: absolute project path (user provided)
        let devPath = "/Users/ZhaobangJetWu/clio-project/Clio/Clio/Assets/\(name).jpeg"
        if FileManager.default.fileExists(atPath: devPath),
           let img = NSImage(contentsOfFile: devPath) {
            return img
        }
        return nil
    }
}

#Preview {
    EnhancedPermissionsView(viewModel: ProfessionalOnboardingViewModel())
        .environmentObject(LocalizationManager.shared)
}
