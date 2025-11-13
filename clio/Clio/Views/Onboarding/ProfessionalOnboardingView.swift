import SwiftUI
import SwiftData
import CoreAudio

// MARK: - Main Onboarding Container
struct ProfessionalOnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @StateObject private var viewModel = ProfessionalOnboardingViewModel()
    @EnvironmentObject private var hotkeyManager: HotkeyManager
    @EnvironmentObject private var whisperState: WhisperState
    @EnvironmentObject private var aiService: AIService
    @EnvironmentObject private var enhancementService: AIEnhancementService
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @EnvironmentObject private var modelAccessControl: ModelAccessControl
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        VStack(spacing: 0) {
                // Progress Header
                // ProgressHeader(currentStep: viewModel.currentStep)
                //     .padding(.top, 40)
                //     .padding(.horizontal, 60)
                
                // Content
                Group {
                    switch viewModel.currentScreen {
                    case .auth:
                        AuthOnboardingView(viewModel: viewModel)
                            .environmentObject(userViewModel)
                            .environmentObject(subscriptionManager)
                            .environmentObject(modelAccessControl)
                    case .languageSelection:
                        LanguageSelectionOnboardingView(viewModel: viewModel)
                            .environmentObject(localizationManager)
                    case .permissions:
                        EnhancedPermissionsView(viewModel: viewModel)
                    case .trial:
                        TrialOfferView(viewModel: viewModel)
                    case .primerPTT:
                        PTTPrimerView(viewModel: viewModel)
                    case .tryItPTT:
                        TryItPTTView(viewModel: viewModel)
                    case .primerHF:
                        HFPrimerView(viewModel: viewModel)
                    case .tryItHF:
                        TryItHFView(viewModel: viewModel)
                    case .primerCommand:
                        CommandPrimerView(viewModel: viewModel)
                    case .tryItCommand:
                        TryItCommandView(viewModel: viewModel, hasCompletedOnboarding: $hasCompletedOnboarding)
                    case .vocabPrimer:
                        PersonalizationPrimerView(viewModel: viewModel, hasCompletedOnboarding: $hasCompletedOnboarding)
                    case .vocabPlaceholder:
                        VocabPlaceholderView(viewModel: viewModel, hasCompletedOnboarding: $hasCompletedOnboarding)
                    case .setup:
                        EnhancedSetupView(viewModel: viewModel, hasCompletedOnboarding: $hasCompletedOnboarding)
                    case .tryIt:
                        ProfessionalTryItView(viewModel: viewModel, hasCompletedOnboarding: $hasCompletedOnboarding)
                    }
                }
                .transition(.opacity)
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: viewModel.currentScreen)
        }
        .frame(minWidth: 1200, idealWidth: 1400, minHeight: 800)
        .translucentBackground()
        // Ensure the hosting NSWindow hides the title bar while onboarding is shown
        .background(WindowAccessor { window in
            WindowManager.shared.configureWindow(window)
        })
        .onChange(of: hasCompletedOnboarding) { completed in
            if completed {
                // Clear persisted onboarding progress
                UserDefaults.standard.removeObject(forKey: "Onboarding.CurrentScreen")
                if UserDefaults.standard.bool(forKey: "ForceShowOnboarding") {
                    UserDefaults.standard.set(false, forKey: "ForceShowOnboarding")
                    print("🧪 [ONBOARDING] ForceShowOnboarding override cleared after completion")
                }
                WindowManager.shared.resetDefaultSizeForNextTransition()
            }
        }
    }
}

// MARK: - Progress Header
struct ProgressHeader: View {
    let currentStep: ProfessionalOnboardingViewModel.Step
    
    var body: some View {
        GlassmorphismBreadcrumb(
            steps: ProfessionalOnboardingViewModel.Step.allCases.map { $0.title },
            currentStep: currentStep.rawValue
        )
        .frame(maxWidth: .infinity, alignment: .center)
    }
}
