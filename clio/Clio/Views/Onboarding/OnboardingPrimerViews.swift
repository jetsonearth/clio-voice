import SwiftUI
import AppKit

// MARK: - Mode Primer (generic)
struct ModePrimerView: View {
    let title: String
    let subtitle: String
    let imageName: String?
    let onContinue: () -> Void
    let onBack: () -> Void
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                OnboardingHeaderControls()
                Spacer()
            }
            
            VStack(spacing: 28) {
                Text(title)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(DarkTheme.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .allowsTightening(true)
                    .frame(maxWidth: 900)
                
                Text(subtitle)
                    .font(.system(size: 22))
                    .foregroundColor(DarkTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .lineLimit(2)
                    .minimumScaleFactor(0.9)
                    .allowsTightening(true)
                    .frame(maxWidth: 1000)
                
                // Placeholder image or rounded rectangle
                Group {
                    if let imageName = imageName, let nsImage = loadBundleImage(named: imageName) {
                        Image(nsImage: nsImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 720, maxHeight: 420)
                            .cornerRadius(12)
                    } else {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(DarkTheme.textPrimary.opacity(0.08))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(DarkTheme.textPrimary.opacity(0.2), lineWidth: 1)
                            )
                            .frame(width: 720, height: 420)
                    }
                }
                .padding(.top, 20)
                
                Button(action: onContinue) {
                    Text(localizationManager.localizedString("onboarding.primer.continue"))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 12)
                        .background(
                            Capsule().fill(Color.accentColor)
                        )
                }
                .buttonStyle(.plain)
                .padding(.top, 8)
                
                HStack(spacing: 12) {
                    StyledBackButton(action: onBack)
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 80)
        }
        .frame(minWidth: 1200, minHeight: 800)
    }
}

// MARK: - Specific Primers
struct PTTPrimerView: View {
    @ObservedObject var viewModel: ProfessionalOnboardingViewModel
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var isButtonHovered = false
    @State private var isBackHovered = false
    
    var body: some View {
        ZStack {
            // Full-page background image
            if let nsImage = loadBundleImage(named: "ptt") {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea() // Extends under the title bar
                    .frame(minWidth: 1200, minHeight: 800)
                    .clipped()
            } else {
                Color.black
                    .ignoresSafeArea()
            }
            
            // Very subtle dark overlay for better text readability
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.4),
                    Color.black.opacity(0.1),
                    Color.black.opacity(0.3)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Centered content overlay
            VStack(spacing: 24) {
                Spacer()
                    .frame(height: 240)
                
                Text(localizationManager.localizedString("onboarding.primer.ready_push_to_talk"))
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(DarkTheme.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .allowsTightening(true)
                    .frame(maxWidth: 900)
                    .shadow(color: .black.opacity(0.6), radius: 12, x: 0, y: 3)
                
                Text(localizationManager.localizedString("onboarding.primer.hold_key_instruction"))
                    .font(.system(size: 18))
                    .foregroundColor(DarkTheme.textPrimary.opacity(0.95))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .lineLimit(2)
                    .minimumScaleFactor(0.9)
                    .allowsTightening(true)
                    .frame(maxWidth: 1000)
                    .shadow(color: .black.opacity(0.6), radius: 8, x: 0, y: 2)
                
                Spacer()
                
                VStack(spacing: 12) {
                    Button(action: { 
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            viewModel.nextScreen() 
                        }
                    }) {
                        Text(localizationManager.localizedString("onboarding.primer.try_it_now"))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(DarkTheme.textPrimary)
                            .padding(.horizontal, isButtonHovered ? 28 : 24)
                            .padding(.vertical, isButtonHovered ? 11 : 10)
                            .background(
                                Capsule()
                                    .stroke(DarkTheme.textPrimary.opacity(isButtonHovered ? 1 : 0.8), lineWidth: isButtonHovered ? 2 : 1.5)
                                    .background(
                                        Capsule()
                                            .fill(DarkTheme.textPrimary.opacity(isButtonHovered ? 0.15 : 0))
                                    )
                            )
                            .scaleEffect(isButtonHovered ? 1.06 : 1)
                            .shadow(color: .black.opacity(isButtonHovered ? 0.4 : 0.2), radius: isButtonHovered ? 10 : 6, x: 0, y: 3)
                    }
                    .buttonStyle(.plain)
                    .onHover { hovering in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isButtonHovered = hovering
                        }
                    }
                    
                    Button(action: { 
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            viewModel.previousScreen() 
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 10, weight: .medium))
                            Text(localizationManager.localizedString("onboarding.primer.back"))
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(DarkTheme.textPrimary.opacity(0.7))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8) // Increased vertical padding for better hit area
                        .background(
                            Capsule()
                                .stroke(DarkTheme.textPrimary.opacity(isBackHovered ? 0.5 : 0.3), lineWidth: 1)
                                .background(
                                    Capsule()
                                        .fill(DarkTheme.textPrimary.opacity(isBackHovered ? 0.05 : 0))
                                )
                        )
                        .scaleEffect(isBackHovered ? 1.05 : 1)
                    }
                    .buttonStyle(.plain)
                    .contentShape(Capsule()) // Ensure full area is tappable
                    .onHover { hovering in
                        withAnimation(.easeInOut(duration: 0.15)) {
                            isBackHovered = hovering
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 80)
            .padding(.bottom, 100)
        }
        .frame(minWidth: 1200, minHeight: 800)
        .ignoresSafeArea() // Add this to ensure the entire ZStack ignores safe areas
    }
}

// MARK: - Local image loader accepting PNG/JPG
private func loadBundleImage(named: String) -> NSImage? {
    if let namedImg = NSImage(named: named) { return namedImg }
    let exts = ["png", "jpg", "jpeg"]
    for ext in exts {
        if let path = Bundle.main.path(forResource: named, ofType: ext),
           let img = NSImage(contentsOfFile: path) { return img }
    }
    return nil
}

struct HFPrimerView: View {
    @ObservedObject var viewModel: ProfessionalOnboardingViewModel
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var isButtonHovered = false
    @State private var isBackHovered = false
    
    var body: some View {
        ZStack {
            // Unified background (matches Try It pages)
            TryItBackgroundView(mode: .handsFree)
            
            // Very subtle dark overlay for better text readability
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.4),
                    Color.black.opacity(0.1),
                    Color.black.opacity(0.3)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Centered content overlay
            VStack(spacing: 24) {
                Spacer()
                    .frame(height: 240)
                
                Text(localizationManager.localizedString("onboarding.primer.next_hands_free"))
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(DarkTheme.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .allowsTightening(true)
                    .frame(maxWidth: 760)
                    .shadow(color: .black.opacity(0.6), radius: 12, x: 0, y: 3)
                
                Text(localizationManager.localizedString("onboarding.primer.double_tap_instruction"))
                    .font(.system(size: 18))
                    .foregroundColor(DarkTheme.textPrimary.opacity(0.95))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .lineLimit(2)
                    .minimumScaleFactor(0.9)
                    .allowsTightening(true)
                    .frame(maxWidth: 600)
                    .shadow(color: .black.opacity(0.6), radius: 8, x: 0, y: 2)
                
                Spacer()
                
                VStack(spacing: 12) {
                    Button(action: { 
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            viewModel.nextScreen() 
                        }
                    }) {
                        Text(localizationManager.localizedString("onboarding.primer.try_it_now"))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(DarkTheme.textPrimary)
                            .padding(.horizontal, isButtonHovered ? 28 : 24)
                            .padding(.vertical, isButtonHovered ? 11 : 10)
                            .background(
                                Capsule()
                                    .stroke(DarkTheme.textPrimary.opacity(isButtonHovered ? 1 : 0.8), lineWidth: isButtonHovered ? 2 : 1.5)
                                    .background(
                                        Capsule()
                                            .fill(DarkTheme.textPrimary.opacity(isButtonHovered ? 0.15 : 0))
                                    )
                            )
                            .scaleEffect(isButtonHovered ? 1.06 : 1)
                            .shadow(color: .black.opacity(isButtonHovered ? 0.4 : 0.2), radius: isButtonHovered ? 10 : 6, x: 0, y: 3)
                    }
                    .buttonStyle(.plain)
                    .onHover { hovering in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isButtonHovered = hovering
                        }
                    }
                    
                    Button(action: { viewModel.previousScreen() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 10, weight: .medium))
                            Text(localizationManager.localizedString("onboarding.primer.back"))
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(DarkTheme.textPrimary.opacity(0.7))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .stroke(DarkTheme.textPrimary.opacity(isBackHovered ? 0.5 : 0.3), lineWidth: 1)
                                .background(
                                    Capsule()
                                        .fill(DarkTheme.textPrimary.opacity(isBackHovered ? 0.05 : 0))
                                )
                        )
                        .scaleEffect(isBackHovered ? 1.05 : 1)
                    }
                    .buttonStyle(.plain)
                    .contentShape(Capsule()) // Ensure full area is tappable
                    .onHover { hovering in
                        withAnimation(.easeInOut(duration: 0.15)) {
                            isBackHovered = hovering
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 80)
            .padding(.bottom, 100)
        }
        .frame(minWidth: 1200, minHeight: 800)
        .ignoresSafeArea() // Add this to ensure the entire ZStack ignores safe areas
    }
}

struct CommandPrimerView: View {
    @ObservedObject var viewModel: ProfessionalOnboardingViewModel
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var isButtonHovered = false
    @State private var isBackHovered = false
    
    var body: some View {
        ZStack {
            // Unified background (matches Try It pages)
            TryItBackgroundView(mode: .command)
            
            // Content overlay (matches Try It pages exactly)
            VStack(spacing: 0) {
                OnboardingHeaderControls()
                
                // Centered content overlay
                VStack(spacing: 24) {
                    Spacer()
                        .frame(height: 240)
                
                Text(localizationManager.localizedString("onboarding.primer.next_command_mode"))
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(DarkTheme.textPrimary)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.6), radius: 12, x: 0, y: 3)
                
                Text(localizationManager.localizedString("onboarding.primer.select_text_instruction"))
                    .font(.system(size: 18))
                    .foregroundColor(DarkTheme.textPrimary.opacity(0.95))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .shadow(color: .black.opacity(0.6), radius: 8, x: 0, y: 2)
                
                Spacer()
                
                VStack(spacing: 12) {
                    Button(action: { 
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            viewModel.nextScreen() 
                        }
                    }) {
                        Text(localizationManager.localizedString("onboarding.primer.try_it_now"))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(DarkTheme.textPrimary)
                            .padding(.horizontal, isButtonHovered ? 28 : 24)
                            .padding(.vertical, isButtonHovered ? 11 : 10)
                            .background(
                                Capsule()
                                    .stroke(DarkTheme.textPrimary.opacity(isButtonHovered ? 1 : 0.8), lineWidth: isButtonHovered ? 2 : 1.5)
                                    .background(
                                        Capsule()
                                            .fill(DarkTheme.textPrimary.opacity(isButtonHovered ? 0.15 : 0))
                                    )
                            )
                            .scaleEffect(isButtonHovered ? 1.06 : 1)
                            .shadow(color: .black.opacity(isButtonHovered ? 0.4 : 0.2), radius: isButtonHovered ? 10 : 6, x: 0, y: 3)
                    }
                    .buttonStyle(.plain)
                    .onHover { hovering in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isButtonHovered = hovering
                        }
                    }
                    
                    Button(action: { viewModel.previousScreen() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 10, weight: .medium))
                            Text(localizationManager.localizedString("onboarding.primer.back"))
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(DarkTheme.textPrimary.opacity(0.7))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .stroke(DarkTheme.textPrimary.opacity(isBackHovered ? 0.5 : 0.3), lineWidth: 1)
                                .background(
                                    Capsule()
                                        .fill(DarkTheme.textPrimary.opacity(isBackHovered ? 0.05 : 0))
                                )
                        )
                        .scaleEffect(isBackHovered ? 1.05 : 1)
                    }
                    .buttonStyle(.plain)
                    .contentShape(Capsule()) // Ensure full area is tappable
                    .onHover { hovering in
                        withAnimation(.easeInOut(duration: 0.15)) {
                            isBackHovered = hovering
                        }
                    }
                }
                
                Spacer()
                }
            }
            .padding(.horizontal, 80)
            .padding(.bottom, 100)
        }
        .frame(minWidth: 1200, minHeight: 800)
        .ignoresSafeArea()
    }
}

// MARK: - Try It Screens (per-mode wrappers)
struct TryItPTTView: View {
    @ObservedObject var viewModel: ProfessionalOnboardingViewModel
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        ZStack {
            // Background that fills entire page
            TryItBackgroundView(mode: .pushToTalk)
            
            // Content overlay
            VStack(spacing: 0) {
                OnboardingHeaderControls()
                
                // Main content area that takes remaining space
                AquaStyleTryItContainer(
                    mode: .pushToTalk,
                    onPrimary: { 
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            viewModel.nextScreen() 
                        }
                    },
                    primaryTitle: localizationManager.localizedString("onboarding.tryit.next"),
                    onSecondary: { 
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            viewModel.previousScreen() 
                        }
                    },
                    secondaryIsBack: true
                )
            }
        }
        .ignoresSafeArea() // Ensure background extends under title bar
    }
}

struct TryItHFView: View {
    @ObservedObject var viewModel: ProfessionalOnboardingViewModel
    @EnvironmentObject private var localizationManager: LocalizationManager
    var body: some View {
        ZStack {
            // Background that fills entire page
            TryItBackgroundView(mode: .handsFree)
            
            // Content overlay
            VStack(spacing: 0) {
                OnboardingHeaderControls()
                
                // Main content area that takes remaining space
                AquaStyleTryItContainer(
                    mode: .handsFree,
                    onPrimary: { 
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            viewModel.nextScreen() 
                        }
                    },
                    primaryTitle: localizationManager.localizedString("onboarding.tryit.next"),
                    onSecondary: { 
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            viewModel.previousScreen() 
                        }
                    },
                    secondaryIsBack: true
                )
            }
        }
        .ignoresSafeArea() // Ensure background extends under title bar
    }
}

struct TryItCommandView: View {
    @ObservedObject var viewModel: ProfessionalOnboardingViewModel
    @Binding var hasCompletedOnboarding: Bool
    @EnvironmentObject private var hotkeyManager: HotkeyManager
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var isButtonHovered = false
    @State private var isBackHovered = false
    
    var body: some View {
        ZStack {
            // Background that fills entire page
            TryItBackgroundView(mode: .command)
            
            // Content overlay
            VStack(spacing: 0) {
                OnboardingHeaderControls()
                
                // Main content area that mirrors other Try It pages
                AquaStyleTryItContainer(
                    mode: .command,
                    onPrimary: { 
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            viewModel.nextScreen() 
                        }
                    },
                    primaryTitle: localizationManager.localizedString("onboarding.primer.continue"),
                    onSecondary: { 
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            viewModel.previousScreen() 
                        }
                    },
                    secondaryIsBack: true
                )
            }
        }
        .ignoresSafeArea()
    }
}
