import SwiftUI

struct OnboardingTrialView: View {
    @Binding var hasCompletedOnboarding: Bool
    @ObservedObject private var subscriptionManager = SubscriptionManager.shared
    @ObservedObject private var deviceFingerprint = DeviceFingerprintService.shared
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var showingUpgrade = false
    @State private var animateFeatures = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                OnboardingBackgroundView()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 60))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.accentColor, Color.accentColor.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .scaleEffect(animateFeatures ? 1.1 : 1.0)
                            .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateFeatures)
                        
                        Text(localizationManager.localizedString("onboarding.trial.title"))
                            .font(.system(size: 42, weight: .bold))
                            .foregroundColor(DarkTheme.textPrimary)
                        
                        Text(String(format: localizationManager.localizedString("onboarding.trial.subtitle"), SubscriptionManager.trialDurationDisplayText))
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(DarkTheme.textPrimary.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal)
                    
                    // Feature highlights
                    VStack(spacing: 20) {
                        TrialFeatureRow(
                            icon: "cpu",
                            title: localizationManager.localizedString("onboarding.trial.feature_1_title"),
                            description: localizationManager.localizedString("onboarding.trial.feature_1_description"),
                            delay: 0.1
                        )
                        
                        TrialFeatureRow(
                            icon: "sparkles",
                            title: localizationManager.localizedString("onboarding.trial.feature_2_title"),
                            description: localizationManager.localizedString("onboarding.trial.feature_2_description"),
                            delay: 0.2
                        )
                        
                        TrialFeatureRow(
                            icon: "bolt.fill",
                            title: localizationManager.localizedString("onboarding.trial.feature_3_title"),
                            description: localizationManager.localizedString("onboarding.trial.feature_3_description"),
                            delay: 0.3
                        )
                    }
                    .frame(maxWidth: 500)
                    
                    Spacer()
                    
                    // Action buttons
                    VStack(spacing: 16) {
                        Button(action: startTrial) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text(String(format: localizationManager.localizedString("onboarding.trial.start_trial"), SubscriptionManager.trialDurationDisplayText))
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundColor(.black)
                            .frame(width: 280, height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 28)
                                    .fill(Color.white)
                                    .shadow(color: .white.opacity(0.3), radius: 20)
                            )
                        }
                        .buttonStyle(ScaleButtonStyle())
                        
                        // Button(action: {
                        //     showingUpgrade = true
                        // }) {
                        //     Text(localizationManager.localizedString("onboarding.trial.view_plans"))
                        //         .font(.system(size: 16, weight: .medium))
                        //         .foregroundColor(DarkTheme.textPrimary.opacity(0.8))
                        // }
                        // .buttonStyle(.plain)
                        
                        SkipButton(text: localizationManager.localizedString("onboarding.trial.continue_free")) {
                            hasCompletedOnboarding = true
                        }
                    }
                    .padding(.bottom, 50)
                }
            }
            .ignoresSafeArea()
        }
        .onAppear {
            animateFeatures = true
        }
        .sheet(isPresented: $showingUpgrade) {
            UpgradePromptView()
                .frame(width: 600, height: 700)
        }
    }
    
    private func startTrial() {
        subscriptionManager.startDeviceTrial()
        hasCompletedOnboarding = true
        
        // Show success feedback
        print("Pro Trial Started! You have \(SubscriptionManager.trialDurationDisplayText) to try all Pro features")
    }
}

struct TrialFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let delay: Double
    
    @State private var isVisible = false
    
    var body: some View {
        HStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.1))
                    .frame(width: 56, height: 56)
                
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(.accentColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(DarkTheme.textPrimary)
                
                Text(description)
                    .font(.system(size: 15))
                    .foregroundColor(DarkTheme.textPrimary.opacity(0.7))
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(.green)
                .opacity(0.8)
        }
        .padding(.horizontal, 30)
        .opacity(isVisible ? 1 : 0)
        .offset(x: isVisible ? 0 : -30)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay)) {
                isVisible = true
            }
        }
    }
}

// Add this view to your onboarding flow
// You can integrate this into your existing onboarding flow by showing this view
// after permissions are granted if the user hasn't used their trial yet
