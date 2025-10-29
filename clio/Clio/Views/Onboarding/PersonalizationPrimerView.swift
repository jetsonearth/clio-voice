import SwiftUI
import AVKit

// MARK: - Personalization Primer
struct PersonalizationPrimerView: View {
    @ObservedObject var viewModel: ProfessionalOnboardingViewModel
    @Binding var hasCompletedOnboarding: Bool
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var isButtonHovered = false
    @State private var isBackHovered = false
    
    var body: some View {
        ZStack {
            // Background matches the walkthrough
            VocabBackground()
                .ignoresSafeArea()
            
            // Subtle dark overlay for readability
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
            
            VStack(spacing: 24) {
                Spacer().frame(height: 240)
                
                Text(localizationManager.localizedString("onboarding.personalization.primer.title"))
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(DarkTheme.textPrimary)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.6), radius: 12, x: 0, y: 3)
                
                Text(localizationManager.localizedString("onboarding.personalization.primer.subtitle"))
                    .font(.system(size: 18))
                    .foregroundColor(DarkTheme.textPrimary.opacity(0.95))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .shadow(color: .black.opacity(0.6), radius: 8, x: 0, y: 2)
                    .frame(maxWidth: 900)
                
                Spacer()
                
                // Match other primers: primary button, then Back, then subtle Skip link
                VStack(spacing: 12) {
                    Button(action: { 
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            viewModel.nextScreen() 
                        }
                    }) {
                        Text(localizationManager.localizedString("onboarding.primer.continue"))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(DarkTheme.textPrimary)
                            .padding(.horizontal, isButtonHovered ? 28 : 24)
                            .padding(.vertical, isButtonHovered ? 11 : 10)
                            .background(
                                Capsule()
                                    .stroke(DarkTheme.textPrimary.opacity(isButtonHovered ? 1 : 0.8), lineWidth: isButtonHovered ? 2 : 1.5)
                                    .background(
                                        Capsule().fill(DarkTheme.textPrimary.opacity(isButtonHovered ? 0.15 : 0))
                                    )
                            )
                            .scaleEffect(isButtonHovered ? 1.06 : 1)
                            .shadow(color: .black.opacity(isButtonHovered ? 0.4 : 0.2), radius: isButtonHovered ? 10 : 6, x: 0, y: 3)
                    }
                    .buttonStyle(.plain)
                    .onHover { hovering in
                        withAnimation(.easeInOut(duration: 0.2)) { isButtonHovered = hovering }
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
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .stroke(DarkTheme.textPrimary.opacity(isBackHovered ? 0.5 : 0.3), lineWidth: 1)
                                .background(
                                    Capsule().fill(DarkTheme.textPrimary.opacity(isBackHovered ? 0.05 : 0))
                                )
                        )
                        .scaleEffect(isBackHovered ? 1.05 : 1)
                    }
                    .buttonStyle(.plain)
                    .contentShape(Capsule())
                    .onHover { hovering in
                        withAnimation(.easeInOut(duration: 0.15)) { isBackHovered = hovering }
                    }
                    
                    Button(action: { hasCompletedOnboarding = true }) {
                        Text(localizationManager.localizedString("onboarding.button.skip_for_now"))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(DarkTheme.textPrimary.opacity(0.85))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 160)
            }
            .padding(.horizontal, 80)
        }
        .frame(minWidth: 1200, minHeight: 800)
        .ignoresSafeArea()
    }
}

