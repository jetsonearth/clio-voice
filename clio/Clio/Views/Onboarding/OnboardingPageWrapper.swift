import SwiftUI

// MARK: - Standardized Onboarding Page Wrapper
struct OnboardingPageWrapper<Content: View>: View {
    let content: () -> Content
    let showBackButton: Bool
    let showContinueButton: Bool
    let onBack: () -> Void
    let onContinue: () -> Void
    let isContinueDisabled: Bool
    let continueTitle: String
    
    init(
        showBackButton: Bool = true,
        showContinueButton: Bool = true,
        continueTitle: String = "Continue",
        isContinueDisabled: Bool = false,
        onBack: @escaping () -> Void = {},
        onContinue: @escaping () -> Void = {},
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.content = content
        self.showBackButton = showBackButton
        self.showContinueButton = showContinueButton
        self.onBack = onBack
        self.onContinue = onContinue
        self.isContinueDisabled = isContinueDisabled
        self.continueTitle = continueTitle
    }
    
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        VStack(spacing: 0) {
            // Main content area with consistent padding
            ScrollView {
                VStack(spacing: 24) {
                    content()
                }
                .padding(.horizontal, 80)  // Consistent horizontal padding
                .padding(.top, 60)        // Consistent top padding
                .padding(.bottom, 40)     // Space before buttons
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            // Navigation buttons with consistent placement
            HStack(spacing: 16) {
                if showBackButton {
                    Button(action: onBack) {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .medium))
                            Text(localizationManager.localizedString("general.back"))
                                .font(.system(size: 15, weight: .medium))
                        }
                        .foregroundColor(DarkTheme.textSecondary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.ultraThinMaterial)
                        )
                    }
                    .buttonStyle(.plain)
                }
                
                Spacer()
                
                if showContinueButton {
                    Button(action: onContinue) {
                        HStack(spacing: 8) {
                            Text(localizationManager.localizedString(continueTitle))
                                .font(.system(size: 15, weight: .medium))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(isContinueDisabled ? DarkTheme.textSecondary : DarkTheme.textPrimary)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(
                            Group {
                                if isContinueDisabled {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(.ultraThinMaterial)
                                } else {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.accentColor.opacity(0.8))
                                }
                            }
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(isContinueDisabled)
                }
            }
            .padding(.horizontal, 80)  // Match content padding
            .padding(.bottom, 60)      // Consistent bottom padding
        }
    }
}

// MARK: - Standard Onboarding Header
struct OnboardingHeader: View {
    let title: String
    let subtitle: String?
    let description: String?
    
    init(title: String, subtitle: String? = nil, description: String? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.description = description
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(DarkTheme.textPrimary)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.system(size: 18))
                    .foregroundColor(DarkTheme.textSecondary)
            }
            
            if let description = description {
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(DarkTheme.textSecondary.opacity(0.8))
                    .padding(.top, 4)
            }
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
    }
}