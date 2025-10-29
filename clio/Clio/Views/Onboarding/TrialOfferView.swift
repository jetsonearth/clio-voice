import SwiftUI

// MARK: - Trial Offer View
struct TrialOfferView: View {
    @ObservedObject var viewModel: ProfessionalOnboardingViewModel
    @ObservedObject private var subscriptionManager = SubscriptionManager.shared
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var animateElements = false
    @State private var showUpgrade = false
    
    var body: some View {
        ZStack {
            // Full-page background image for trial page
            if let nsImage = loadTrialBackground() {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .frame(minWidth: 1200, minHeight: 800)
                    .clipped()
            } else {
                Color.black
                    .ignoresSafeArea()
            }

            // Subtle gradient overlay for text readability
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.5),
                    Color.black.opacity(0.2),
                    Color.black.opacity(0.4)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header with controls
                OnboardingHeaderControls()
                
                // Main content
                VStack(spacing: 40) {
                // Title section
                VStack(spacing: 16) {
                    HStack {
                        // Image(systemName: "sparkles")
                        //     .font(.system(size: 32))
                        //     .foregroundColor(.accentColor)
                        //     .opacity(animateElements ? 1 : 0)
                        //     .scaleEffect(animateElements ? 1 : 0.5)
                        
                        Text(localizationManager.localizedString("onboarding.trial.title"))
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(DarkTheme.textPrimary)
                            .opacity(animateElements ? 1 : 0)
                            .scaleEffect(animateElements ? 1 : 0.8)
                    }
                    
                    Text(localizationManager.localizedString("onboarding.trial.subtitle"))
                        .font(.system(size: 18))
                        .foregroundColor(DarkTheme.textSecondary)
                        .opacity(animateElements ? 1 : 0)
                        .multilineTextAlignment(.center)
                }
.padding(.top, 44)
                
                // Feature cards in 3x2 grid layout
                VStack(spacing: 16) {
                    // Row 1
                    HStack(spacing: 16) {
                        TrialFeatureCard(
                            icon: "bolt.fill",
                            title: localizationManager.localizedString("onboarding.trial.feature.lightning_fast.title"),
                            description: localizationManager.localizedString("onboarding.trial.feature.lightning_fast.description"),
                            delay: 0.1
                        )
                        
                        TrialFeatureCard(
                            icon: "globe",
                            title: localizationManager.localizedString("onboarding.trial.feature.world_leading.title"),
                            description: localizationManager.localizedString("onboarding.trial.feature.world_leading.description"),
                            delay: 0.2
                        )
                    }
                    
                    // Row 2
                    HStack(spacing: 16) {
                        TrialFeatureCard(
                            icon: "translate",
                            title: localizationManager.localizedString("onboarding.trial.feature.realtime_translation.title"),
                            description: localizationManager.localizedString("onboarding.trial.feature.realtime_translation.description"),
                            delay: 0.3
                        )
                        
                        TrialFeatureCard(
                            icon: "wand.and.stars",
                            title: localizationManager.localizedString("onboarding.trial.feature.messy_to_polished.title"),
                            description: localizationManager.localizedString("onboarding.trial.feature.messy_to_polished.description"),
                            delay: 0.4
                        )
                    }
                    
                    // Row 3
                    HStack(spacing: 16) {
                        TrialFeatureCard(
                            icon: "laptopcomputer",
                            title: localizationManager.localizedString("onboarding.trial.feature.speed_up_writing.title"),
                            description: localizationManager.localizedString("onboarding.trial.feature.speed_up_writing.description"),
                            delay: 0.5
                        )
                        
                        TrialFeatureCard(
                            icon: "lock.shield.fill",
                            title: localizationManager.localizedString("onboarding.trial.feature.privacy_first.title"),
                            description: localizationManager.localizedString("onboarding.trial.feature.privacy_first.description"),
                            delay: 0.6
                        )
                    }
                }
                .frame(maxWidth: 600)
                .opacity(animateElements ? 1 : 0)
                .offset(y: animateElements ? 0 : 30)
                
                // Spacer()
                
                // Action buttons
                VStack(spacing: 16) {
                    // Back and Start trial buttons
                    HStack(spacing: 8) {
                        StyledBackButton {
                            viewModel.previousScreen()
                        }
                        
                        StyledActionButton(
                            title: localizationManager.localizedString("onboarding.trial.start_trial"),
                            action: {
                                subscriptionManager.startDeviceTrial()
                                viewModel.nextScreen()
                            },
                            isDisabled: false,
                            showArrow: true
                        )
                    }
                    .opacity(animateElements ? 1 : 0)
                    .offset(y: animateElements ? 0 : 20)
                    
                    // View plans button
                    // Text(localizationManager.localizedString("onboarding.trial.view_plans"))
                    //     .font(.system(size: 14))
                    //     .foregroundColor(DarkTheme.textSecondary)
                    //     .onTapGesture {
                    //         showUpgrade = true
                    //     }
                    //     .opacity(animateElements ? 1 : 0)
                }
                .padding(.bottom, 80)
            }
        }
        }
        .ignoresSafeArea() // Ensure the entire trial page extends under the title bar with no gap
        .onAppear {
            startAnimations()
        }
        .sheet(isPresented: $showUpgrade) {
            UpgradePromptView()
                .frame(width: 600, height: 700)
        }
    }
    
    private func loadTrialBackground() -> NSImage? {
        if let named = NSImage(named: "trial") { return named }
        let exts = ["png", "jpg", "jpeg"]
        for ext in exts {
            if let path = Bundle.main.path(forResource: "trial", ofType: ext),
               let img = NSImage(contentsOfFile: path) { return img }
        }
        return nil
    }
    
    private func startAnimations() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2)) {
            animateElements = true
        }
    }
}

// MARK: - Trial Feature Card

struct TrialFeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let delay: Double
    
    @State private var isVisible = false
    
    var body: some View {
        GlassmorphismCard(padding: 16) {
            VStack(spacing: 12) {
                // Top row: Icon + Title
                HStack(spacing: 12) {
                    // Icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(DarkTheme.textPrimary.opacity(0.1))
                            .frame(width: 32, height: 32)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(DarkTheme.textPrimary.opacity(0.2), lineWidth: 1)
                            )
                        
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(DarkTheme.textPrimary)
                    }
                    
                    // Title
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(DarkTheme.textPrimary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Bottom row: Description
                Text(description)
                    .font(.system(size: 13))
                    .foregroundColor(DarkTheme.textSecondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 34) // Reset to original height
            }
        }
        .frame(width: 380, height: 110) // Further increased width for all cards
        .opacity(isVisible ? 1 : 0)
        .offset(x: isVisible ? 0 : -30)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay)) {
                isVisible = true
            }
        }
    }
}
