import SwiftUI
import AppKit

/// Community-edition intro screen shown at the start of onboarding.
/// Replaces the old account-creation step so new users can jump straight into the product.
struct AuthOnboardingView: View {
    @ObservedObject var viewModel: ProfessionalOnboardingViewModel
    @State private var animateHeadline = false

    var body: some View {
        ZStack {
            backgroundLayer
            LinearGradient(
                colors: [
                    Color.black.opacity(0.55),
                    Color.black.opacity(0.2),
                    Color.black.opacity(0.45)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer(minLength: 80)

                VStack(spacing: 16) {
                    Text("Welcome to Clio Community Edition")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(DarkTheme.textPrimary)
                        .multilineTextAlignment(.center)
                        .shadow(color: .black.opacity(0.6), radius: 10, x: 0, y: 2)
                        .opacity(animateHeadline ? 1 : 0)
                        .scaleEffect(animateHeadline ? 1 : 0.9)

                    Text("The entire app is unlocked. Bring your own Groq and Soniox API keys in Settings and start transcribing immediately—no account, no checkout, no limitations.")
                        .font(.system(size: 18))
                        .multilineTextAlignment(.center)
                        .foregroundColor(DarkTheme.textSecondary)
                        .frame(maxWidth: 640)
                        .opacity(animateHeadline ? 1 : 0)
                        .offset(y: animateHeadline ? 0 : 16)
                }
                .padding(.horizontal, 40)

                featureGrid
                    .opacity(animateHeadline ? 1 : 0)
                    .offset(y: animateHeadline ? 0 : 24)

                Spacer()

                VStack(spacing: 16) {
                    Button(action: advance) {
                        HStack(spacing: 10) {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 18, weight: .semibold))
                            Text("Continue")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(.black)
                        .frame(width: 220, height: 54)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.2), radius: 15)
                        )
                    }
                    .buttonStyle(.plain)

                    Button(action: openRepository) {
                        Text("View Source on GitHub")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(DarkTheme.textPrimary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(DarkTheme.textPrimary.opacity(0.1))
                                    .overlay(
                                        Capsule()
                                            .stroke(DarkTheme.textPrimary.opacity(0.2), lineWidth: 1)
                                    )
                            )
                    }
                    .buttonStyle(.plain)
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
                animateHeadline = true
            }
        }
    }

    private var backgroundLayer: some View {
        Group {
            if let image = loadAuthBackground() {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            } else {
                LinearGradient(
                    colors: [Color.black, Color.gray.opacity(0.4)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }
        }
    }

    private var featureGrid: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                introCard(
                    icon: "bolt.fill",
                    title: "Instant Start",
                    detail: "Skip account creation—just complete onboarding and hit the microphone."
                )
                introCard(
                    icon: "key.fill",
                    title: "Bring Your Own Keys",
                    detail: "Store Groq and Soniox tokens locally via Settings → Cloud API Keys."
                )
            }
            HStack(spacing: 16) {
                introCard(
                    icon: "lock.shield",
                    title: "Local-First",
                    detail: "No telemetry, no remote auth. Your data stays on device unless you opt in."
                )
                introCard(
                    icon: "wand.and.stars",
                    title: "All Features Included",
                    detail: "AI enhancement, personalization, automations—everything ships enabled."
                )
            }
        }
        .frame(maxWidth: 720)
    }

    private func introCard(icon: String, title: String, detail: String) -> some View {
        GlassmorphismCard(padding: 20) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    Image(systemName: icon)
                        .foregroundColor(.accentColor)
                        .font(.system(size: 20, weight: .bold))
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(DarkTheme.textPrimary)
                }
                Text(detail)
                    .font(.system(size: 14))
                    .foregroundColor(DarkTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func advance() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
            viewModel.nextScreen()
        }
    }

    private func openRepository() {
        if let url = URL(string: "https://github.com/studio-kensense/clio") {
            NSWorkspace.shared.open(url)
        }
    }

    private func loadAuthBackground() -> NSImage? {
        if let named = NSImage(named: "auth") {
            return named
        }
        for ext in ["png", "jpg", "jpeg"] {
            if let path = Bundle.main.path(forResource: "auth", ofType: ext),
               let image = NSImage(contentsOfFile: path) {
                return image
            }
        }
        return nil
    }
}
