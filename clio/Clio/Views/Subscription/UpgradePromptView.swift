import SwiftUI

struct UpgradePromptView: View {
    let feature: ProFeature?
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @ObservedObject private var licenseViewModel = LicenseViewModel.shared
    @EnvironmentObject private var localizationManager: LocalizationManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan: BillingPeriod = .monthly
    @State private var showingLicenseEntry = false
    
    enum BillingPeriod {
        case monthly
        case yearly
        
        var price: String {
            switch self {
            case .monthly: return "$5/month"
            case .yearly: return "$49/year"
            }
        }
        
        var savings: String? {
            switch self {
            case .monthly: return nil
            case .yearly: return "Save $11"
            }
        }
    }
    
    init(feature: ProFeature? = nil) {
        self.feature = feature
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerSection
            
            ScrollView {
                VStack(spacing: 24) {
                    // Trial status if applicable
                    if subscriptionManager.isInTrial {
                        trialStatusSection
                    }
                    
                    // Feature that triggered upgrade
                    if let feature = feature {
                        triggeredFeatureSection(feature)
                    }
                    
                    // Pricing plans
                    pricingSection
                    
                    // Feature comparison
                    featureComparisonSection
                    
                    // CTA buttons
                    ctaSection
                }
                .padding(32)
            }
        }
        .frame(width: 640, height: 640)
        .background(.ultraThinMaterial)
        .sheet(isPresented: $showingLicenseEntry) {
            LicenseView()
                .frame(width: 500, height: 400)
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(spacing: 24) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(localizationManager.localizedString("subscription.upgrade.title"))
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(DarkTheme.textPrimary)
                    
                    Text(localizationManager.localizedString("subscription.upgrade.subtitle"))
                        .font(.system(size: 18))
                        .foregroundColor(DarkTheme.textSecondary)
                }
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(DarkTheme.textSecondary)
                        .background(Circle().fill(Color.black.opacity(0.001)))
                }
                .buttonStyle(.plain)
            }
            
            Rectangle()
                .fill(DarkTheme.textSecondary.opacity(0.2))
                .frame(height: 1)
        }
        .padding(.horizontal, 40)
        .padding(.top, 32)
        .padding(.bottom, 20)
    }
    
    // MARK: - Trial Status
    
    private var trialStatusSection: some View {
        GlassmorphismCard(cornerRadius: 16, padding: 20) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.2))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "clock.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.orange)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(localizationManager.localizedString("subscription.trial.active"))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(DarkTheme.textPrimary)
                    
                    Text(String(format: localizationManager.localizedString("subscription.trial.days_remaining"), subscriptionManager.trialDaysRemaining))
                        .font(.system(size: 15))
                        .foregroundColor(DarkTheme.textSecondary)
                }
                
                Spacer()
                
                // Progress circle
                ZStack {
                    Circle()
                        .stroke(DarkTheme.textSecondary.opacity(0.3), lineWidth: 4)
                        .frame(width: 48, height: 48)
                    
                    Circle()
                        .trim(from: 0, to: 1 - Double(subscriptionManager.trialDaysRemaining) / Double(SubscriptionManager.TRIAL_DURATION_DAYS))
                        .stroke(.orange, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 48, height: 48)
                }
            }
        }
    }
    
    // MARK: - Triggered Feature
    
    private func triggeredFeatureSection(_ feature: ProFeature) -> some View {
        GlassmorphismCard(cornerRadius: 16, padding: 24) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.accentColor.opacity(0.2))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: feature.icon)
                        .font(.system(size: 28))
                        .foregroundColor(.accentColor)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(localizationManager.localizedString("subscription.feature.trying_to_use"))
                        .font(.system(size: 15))
                        .foregroundColor(DarkTheme.textSecondary)
                    
                    Text(feature.displayName)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(DarkTheme.textPrimary)
                }
                
                Spacer()
            }
        }
    }
    
    // MARK: - Pricing
    
    private var pricingSection: some View {
        VStack(spacing: 24) {
            // Billing toggle
            HStack(spacing: 4) {
                ForEach([BillingPeriod.monthly, BillingPeriod.yearly], id: \.self) { period in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedPlan = period
                        }
                    }) {
                        VStack(spacing: 6) {
                            Text(period == .monthly ? localizationManager.localizedString("subscription.billing.monthly") : localizationManager.localizedString("subscription.billing.yearly"))
                                .font(.system(size: 16, weight: .medium))
                            
                            if let savings = period.savings {
                                Text(localizationManager.localizedString("subscription.billing.save"))
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(DarkTheme.textPrimary)
                            } else {
                                Text(" ")
                                    .font(.system(size: 13))
                            }
                        }
                        .foregroundColor(selectedPlan == period ? DarkTheme.textPrimary : DarkTheme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedPlan == period ? Color.accentColor.opacity(0.15) : Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedPlan == period ? Color.accentColor : DarkTheme.textSecondary.opacity(0.3), lineWidth: 2)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            
            // Price display
            VStack(spacing: 8) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(selectedPlan == .monthly ? "$5" : "$49")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(DarkTheme.textPrimary)
                    
                    Text(selectedPlan == .monthly ? localizationManager.localizedString("subscription.billing.per_month") : localizationManager.localizedString("subscription.billing.per_year"))
                        .font(.system(size: 20))
                        .foregroundColor(DarkTheme.textSecondary)
                }
                
                if selectedPlan == .yearly {
                    Text(localizationManager.localizedString("subscription.billing.annual_savings"))
                        .font(.system(size: 14))
                        .foregroundColor(DarkTheme.textSecondary)
                }
            }
        }
    }
    
    // MARK: - Feature Comparison
    
    private var featureComparisonSection: some View {
        GlassmorphismCard(cornerRadius: 20, padding: 32) {
            VStack(alignment: .leading, spacing: 28) {
                Text(localizationManager.localizedString("subscription.features.title"))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(DarkTheme.textPrimary)
                
                VStack(spacing: 20) {
                    EnhancedFeatureRow(
                        icon: "cpu",
                        title: localizationManager.localizedString("subscription.feature.premium_models.title"),
                        description: localizationManager.localizedString("subscription.feature.premium_models.description")
                    )
                    
                    EnhancedFeatureRow(
                        icon: "sparkles",
                        title: localizationManager.localizedString("subscription.feature.ai_enhancement.title"),
                        description: localizationManager.localizedString("subscription.feature.ai_enhancement.description")
                    )
                    
                    EnhancedFeatureRow(
                        icon: "infinity",
                        title: localizationManager.localizedString("subscription.feature.unlimited.title"),
                        description: localizationManager.localizedString("subscription.feature.unlimited.description")
                    )
                    
                    EnhancedFeatureRow(
                        icon: "star.fill",
                        title: localizationManager.localizedString("subscription.feature.priority_support.title"),
                        description: localizationManager.localizedString("subscription.feature.priority_support.description")
                    )
                }
            }
        }
    }
    
    // MARK: - CTA
    
    private var ctaSection: some View {
        VStack(spacing: 20) {
            StyledActionButton(
                title: localizationManager.localizedString("subscription.cta.get_pro"),
                action: {
                    licenseViewModel.openPurchaseLink()
                },
                showArrow: true
            )
            
            Button(action: {
                showingLicenseEntry = true
            }) {
                Text(localizationManager.localizedString("subscription.cta.have_license"))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(DarkTheme.textSecondary)
            }
            .buttonStyle(.plain)
            
            if subscriptionManager.currentTier == .free && !subscriptionManager.isInTrial {
                Button(action: {
                    subscriptionManager.startDeviceTrial()
                    dismiss()
                }) {
                    Text(String(format: localizationManager.localizedString("subscription.cta.start_trial"), SubscriptionManager.trialDurationDisplayText))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Enhanced Feature Row

struct EnhancedFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(.accentColor)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(DarkTheme.textPrimary)
                
                Text(description)
                    .font(.system(size: 15))
                    .foregroundColor(DarkTheme.textSecondary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(DarkTheme.textPrimary)
        }
    }
}

// MARK: - Preview

#Preview {
    UpgradePromptView(feature: .aiEnhancement)
}