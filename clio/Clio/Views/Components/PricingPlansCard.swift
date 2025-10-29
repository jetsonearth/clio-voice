import SwiftUI

struct PricingPlansCard: View {
    @EnvironmentObject private var localizationManager: LocalizationManager
    @Environment(\.fontScale) private var fontScale
    @State private var isYearly = true // Default to annual for better savings
    @AppStorage("emailSignatureEnabled") private var emailSignatureEnabled = false
    
    let onPlanSelected: (String) -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // Simple Header
            VStack(spacing: 8) {
Text(localizationManager.localizedString("subscription.features.title"))
                    .fontScaled(size: 18, weight: .semibold)
                    .foregroundColor(DarkTheme.textPrimary)
                
Text("See what you get with Clio Pro")
                    .fontScaled(size: 14)
                    .foregroundColor(DarkTheme.textSecondary)
            }
            
            // Email Signature Pro Feature
            emailSignatureFeatureCard
            
            // Clean Pro Plan Card
            cleanProCard
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(DarkTheme.textPrimary.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(DarkTheme.textPrimary.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private var cleanProCard: some View {
        VStack(spacing: 20) {
            // Simple Pricing Toggle
            simplePricingToggle
            
            // Clean Price Display
            cleanPriceDisplay
            
            // Minimal Features List
            minimalFeaturesList
            
            // Simple CTA Button
            simpleCTAButton
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(DarkTheme.textPrimary.opacity(0.02))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(DarkTheme.textPrimary.opacity(0.08), lineWidth: 1)
                )
        )
    }
    
    private var simplePricingToggle: some View {
        HStack(spacing: 8) {
            // Monthly Button
            Button(action: { isYearly = false }) {
                VStack(spacing: 4) {
Text(localizationManager.localizedString("subscription.billing.monthly"))
                        .fontScaled(size: 14, weight: .medium)
                        .foregroundColor(isYearly ? DarkTheme.textSecondary : DarkTheme.textPrimary)
                    
Text("$7.99/mo")
                        .fontScaled(size: 12)
                        .foregroundColor(isYearly ? DarkTheme.textSecondary : DarkTheme.textPrimary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isYearly ? Color.clear : DarkTheme.textPrimary.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isYearly ? DarkTheme.textPrimary.opacity(0.1) : DarkTheme.accent.opacity(0.3), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(.plain)
            
            // Annual Button
            Button(action: { isYearly = true }) {
                VStack(spacing: 4) {
                    HStack(spacing: 6) {
Text(localizationManager.localizedString("subscription.billing.yearly"))
                            .fontScaled(size: 14, weight: .medium)
                        
                        if isYearly {
Text("Save $17")
                                .fontScaled(size: 10, weight: .medium)
                                .foregroundColor(DarkTheme.accent)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(DarkTheme.accent.opacity(0.1))
                                )
                        }
                    }
                    .foregroundColor(isYearly ? DarkTheme.textPrimary : DarkTheme.textSecondary)
                    
Text("$79.99/yr")
                        .fontScaled(size: 12)
                        .foregroundColor(isYearly ? DarkTheme.textPrimary : DarkTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isYearly ? DarkTheme.textPrimary.opacity(0.08) : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isYearly ? DarkTheme.accent.opacity(0.3) : DarkTheme.textPrimary.opacity(0.1), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    private var cleanPriceDisplay: some View {
        VStack(spacing: 4) {
            HStack(alignment: .bottom, spacing: 4) {
Text(isYearly ? "$79.99" : "$7.99")
                    .fontScaled(size: 28, weight: .semibold)
                    .foregroundColor(DarkTheme.textPrimary)
                
Text(isYearly ? "/year" : "/month")
                    .fontScaled(size: 14)
                    .foregroundColor(DarkTheme.textSecondary)
            }
            
            if isYearly {
Text("Just $6.67/month when billed annually")
                    .fontScaled(size: 12)
                    .foregroundColor(DarkTheme.accent)
            }
        }
    }
    
    private var minimalFeaturesList: some View {
        VStack(alignment: .leading, spacing: 12) {
            simpleFeatureRow(localizationManager.localizedString("subscription.feature.unlimited.title"))
            simpleFeatureRow(localizationManager.localizedString("subscription.feature.premium_models.title"))
            simpleFeatureRow(localizationManager.localizedString("subscription.feature.ai_enhancement.title"))
            simpleFeatureRow(localizationManager.localizedString("subscription.feature.priority_support.title"))
        }
    }
    
    private func simpleFeatureRow(_ title: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 14 * fontScale))
                .foregroundColor(DarkTheme.accent)
            
Text(title)
                .fontScaled(size: 14)
                .foregroundColor(DarkTheme.textPrimary)
            
            Spacer()
        }
    }
    
    private var simpleCTAButton: some View {
        Button(action: {
            onPlanSelected(isYearly ? "annual" : "monthly")
        }) {
Text(localizationManager.localizedString("subscription.cta.get_pro"))
                .fontScaled(size: 14, weight: .medium)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(DarkTheme.accent)
                )
        }
        .buttonStyle(.plain)
    }
    
    private var emailSignatureFeatureCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "signature")
                    .font(.system(size: 20 * fontScale))
                    .foregroundColor(.accentColor)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Professional Email Signatures")
                        .fontScaled(size: 17, weight: .semibold)
                        .foregroundColor(DarkTheme.textPrimary)
                    Text("Build your professional network effortlessly")
                        .fontScaled(size: 13)
                        .foregroundColor(DarkTheme.textSecondary)
                }
                
                Spacer()
            }
            
            Divider()
                .padding(.vertical, 4)
            
            VStack(alignment: .leading, spacing: 8) {
                Toggle("Add signature to emails", isOn: $emailSignatureEnabled)
                    .toggleStyle(.switch)
                
                if emailSignatureEnabled {
                    Text("Automatically adds a tasteful signature line to help recipients discover voice-to-text efficiency")
                        .fontScaled(size: 12)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(DarkTheme.textPrimary.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(DarkTheme.textPrimary.opacity(0.1), lineWidth: 1)
                )
        )
    }
}
