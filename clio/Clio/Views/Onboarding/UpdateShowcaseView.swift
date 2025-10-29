import SwiftUI
import AppKit

// MARK: - Update Intro Primer (full-bleed image, no Back)
struct UpdateIntroPrimerView: View {
    let onContinue: () -> Void
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var isButtonHovered = false

    var body: some View {
        ZStack {
            // Full-bleed background using update image (png/jpg)
            if let nsImage = loadUpdateImage() {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            } else {
                Color.black.ignoresSafeArea()
            }

            // Subtle overlay for readability
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.45),
                    Color.black.opacity(0.15),
                    Color.black.opacity(0.35)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer().frame(height: 240)

                Text(localizationManager.localizedString("updates.primer.title"))
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(DarkTheme.textPrimary)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.6), radius: 12, x: 0, y: 3)

                Text(localizationManager.localizedString("updates.primer.subtitle"))
                    .font(.system(size: 18))
                    .foregroundColor(DarkTheme.textPrimary.opacity(0.95))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .shadow(color: .black.opacity(0.6), radius: 8, x: 0, y: 2)
                    .frame(maxWidth: 900)

                Spacer()

                // Single primary CTA (no Back on this page)
                Button(action: onContinue) {
                    Text(localizationManager.localizedString("updates.primer.primary"))
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
                .padding(.bottom, 275)
            }
            .padding(.horizontal, 80)
        }
        .frame(minWidth: 1200, minHeight: 800)
        .ignoresSafeArea()
    }
}

private func loadUpdateImage() -> NSImage? {
    if let named = NSImage(named: "update") { return named }
    let exts = ["png", "jpg", "jpeg"]
    for ext in exts {
        if let path = Bundle.main.path(forResource: "update", ofType: ext),
           let img = NSImage(contentsOfFile: path) {
            return img
        }
    }
    return nil
}

// MARK: - Update Showcase Wrapper
struct UpdateShowcaseView: View {
    @Binding var didFinish: Bool
    @StateObject private var viewModel = ProfessionalOnboardingViewModel()

    enum Stage {
        case intro
        case flow // use viewModel screens
    }

    @State private var stage: Stage = .intro

    var body: some View {
        Group {
            switch stage {
            case .intro:
                UpdateIntroPrimerView(onContinue: {
                    viewModel.currentScreen = .primerCommand
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        stage = .flow
                    }
                })
            case .flow:
                Group {
                    switch viewModel.currentScreen {
                    case .primerCommand:
                        CommandPrimerView(viewModel: viewModel)
                    case .tryItCommand:
                        TryItCommandView(viewModel: viewModel, hasCompletedOnboarding: $didFinish)
                    case .vocabPrimer:
                        PersonalizationPrimerView(viewModel: viewModel, hasCompletedOnboarding: $didFinish)
                    case .vocabPlaceholder:
                        VocabPlaceholderView(viewModel: viewModel, hasCompletedOnboarding: $didFinish)
                    default:
                        // If user navigates elsewhere, bring them back to the start of the flow
                        CommandPrimerView(viewModel: viewModel)
                    }
                }
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: viewModel.currentScreen)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            // If user has completed the update walkthrough before, auto-finish so it never shows again.
            if UserDefaults.standard.bool(forKey: "UpdateShowcase.HasCompleted") {
                didFinish = true
            }
        }
        .onChange(of: didFinish) { completed in
            if completed {
                UserDefaults.standard.set(true, forKey: "UpdateShowcase.HasCompleted")
            }
        }
    }
}
