import SwiftUI
import AppKit

/// Replaces the old "trial offer" step with a lightweight community-edition primer.
struct TrialOfferView: View {
    @ObservedObject var viewModel: ProfessionalOnboardingViewModel
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var animateHighlights = false

    var body: some View {
        ZStack {
            onboardingBackground("trial") // Reuse the existing asset if present
            LinearGradient(
                colors: [
                    Color.black.opacity(0.55),
                    Color.black.opacity(0.25),
                    Color.black.opacity(0.45)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {
                OnboardingHeaderControls()

                VStack(spacing: 16) {
                    Text("Everything Is Already Unlocked")
                        .font(.system(size: 38, weight: .bold))
                        .foregroundColor(DarkTheme.textPrimary)
                        .multilineTextAlignment(.center)
                        .shadow(color: .black.opacity(0.6), radius: 10, x: 0, y: 2)
                        .opacity(animateHighlights ? 1 : 0)
                        .scaleEffect(animateHighlights ? 1 : 0.92)

                    Text("Use this step to double-check the essentials—API keys, automation ideas, and where to tweak personalization—before diving into the hands-free walkthrough.")
                        .font(.system(size: 18))
                        .foregroundColor(DarkTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 640)
                        .opacity(animateHighlights ? 1 : 0)
                        .offset(y: animateHighlights ? 0 : 20)
                }
                .padding(.horizontal, 40)

                highlights
                    .opacity(animateHighlights ? 1 : 0)
                    .offset(y: animateHighlights ? 0 : 24)

                Spacer()

                HStack(spacing: 12) {
                    StyledBackButton {
                        viewModel.previousScreen()
                    }
                    StyledActionButton(
                        title: localizationManager.localizedString("general.continue"),
                        action: advance,
                        showArrow: true
                    )
                    .frame(width: 220)
                }
                .padding(.bottom, 60)
            }
            .padding(.horizontal, 32)
        }
        .ignoresSafeArea()
        .background(WindowAccessor { window in
            WindowManager.shared.configureWindow(window)
        })
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.85).delay(0.1)) {
                animateHighlights = true
            }
        }
    }

    private var highlights: some View {
        VStack(spacing: 18) {
            HighlightRow(
                icon: "key.fill",
                title: "Bring Your Own Keys",
                description: "Head to Settings → Cloud API Keys to paste your Groq and Soniox credentials. They’re stored locally in the Keychain."
            )
            HighlightRow(
                icon: "wand.and.stars",
                title: "Tune AI Enhancement",
                description: "Adjust editing strength and personalization prompts under Settings → Personalization before trying the hands-free demo."
            )
            HighlightRow(
                icon: "bolt.horizontal.button.fill",
                title: "Explore Automations",
                description: "Use snippets, replacements, and clipboard actions to ship transcripts directly into your workflow."
            )
        }
        .frame(maxWidth: 640)
    }

    private func advance() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
            viewModel.nextScreen()
        }
    }
}

private struct HighlightRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        GlassmorphismCard(padding: 20) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.accentColor.opacity(0.12))
                        .frame(width: 54, height: 54)
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.accentColor)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(DarkTheme.textPrimary)
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(DarkTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
            }
        }
    }
}

private func onboardingBackground(_ name: String) -> some View {
    Group {
        if let image = NSImage(named: name) {
            Image(nsImage: image)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        } else {
            Color.black.ignoresSafeArea()
        }
    }
}
