import SwiftUI

// MARK: - Compact Trial Progress Component
struct ModernTrialProgressCard: View {
    // Time-based trial UI (14 days by default)
    let daysRemaining: Int
    let totalDays: Int
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    private var progressPercentage: Double {
        guard totalDays > 0 else { return 1.0 }
        let used = max(0, min(totalDays, totalDays - daysRemaining))
        return Double(used) / Double(totalDays)
    }
    private var isNearLimit: Bool { progressPercentage > 0.8 }
    private var isAtLimit: Bool { progressPercentage >= 1.0 }
    
    var body: some View {
        VStack(spacing: 12) {
            // Compact header with progress
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    // Remove "Free" label; show neutral title
Text("Trial")
                        .fontScaled(size: 16, weight: .semibold)
                        .foregroundColor(DarkTheme.textPrimary)
                    // "X of Y days remaining"
Text(String(format: localizationManager.localizedString("trial.days_remaining_detail"), daysRemaining, totalDays))
                        .fontScaled(size: 13)
                        .foregroundColor(DarkTheme.textSecondary)
                }
                
                Spacer()
                
                // Compact stats
                HStack(spacing: 12) {
                    VStack(alignment: .trailing, spacing: 1) {
Text("\(daysRemaining)")
                            .fontScaled(size: 18, weight: .bold)
                            .foregroundColor(DarkTheme.textPrimary)
Text(localizationManager.localizedString("subscription.trial.days_remaining"))
                            .fontScaled(size: 11)
                            .foregroundColor(DarkTheme.textSecondary)
                    }
                    
Text("/")
                        .fontScaled(size: 14)
                        .foregroundColor(DarkTheme.textTertiary)
                    
                    VStack(alignment: .leading, spacing: 1) {
Text("\(totalDays)")
                            .fontScaled(size: 18, weight: .bold)
                            .foregroundColor(progressTextColor)
Text("days")
                            .fontScaled(size: 11)
                            .foregroundColor(DarkTheme.textSecondary)
                    }
                }
            }
            
            // Compact progress bar
            compactProgressBar
            
            // Status message (if needed)
            if isAtLimit || isNearLimit {
                compactStatusMessage
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(DarkTheme.textPrimary.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(DarkTheme.textPrimary.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    
    
    private var progressGradient: LinearGradient {
        if isAtLimit {
            return LinearGradient(
                colors: [DarkTheme.error, DarkTheme.error.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else if isNearLimit {
            return LinearGradient(
                colors: [DarkTheme.warning, DarkTheme.warning.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [DarkTheme.accent, DarkTheme.accent.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private var progressTextColor: Color {
        if isAtLimit {
            return DarkTheme.error
        } else if isNearLimit {
            return DarkTheme.warning
        } else {
            return DarkTheme.accent
        }
    }
    
    
    // MARK: - Compact Progress Bar
    private var compactProgressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background Track
                RoundedRectangle(cornerRadius: 3)
                    .fill(DarkTheme.border.opacity(0.2))
                    .frame(height: 6)
                
                // Progress Fill
                RoundedRectangle(cornerRadius: 3)
                    .fill(progressGradient)
                    .frame(
                        width: CGFloat(progressPercentage) * geometry.size.width,
                        height: 6
                    )
                    .animation(.easeInOut(duration: 0.6), value: progressPercentage)
            }
        }
        .frame(height: 6)
    }
    
    
    // MARK: - Compact Status Message
    private var compactStatusMessage: some View {
        HStack(spacing: 6) {
            Image(systemName: isAtLimit ? "exclamationmark.triangle.fill" : "clock.fill")
                .foregroundColor(isAtLimit ? DarkTheme.error : DarkTheme.warning)
                .font(.system(size: 12))
            
Text(isAtLimit ? localizationManager.localizedString("trial.expired.title") :
                 String(format: localizationManager.localizedString("trial.days_remaining_detail"), daysRemaining, totalDays))
                .fontScaled(size: 12, weight: .medium)
                .foregroundColor(isAtLimit ? DarkTheme.error : DarkTheme.warning)
                
                Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill((isAtLimit ? DarkTheme.error : DarkTheme.warning).opacity(0.1))
        )
    }
    
    
    // MARK: - Helper Functions
    private func formatNumber(_ number: Int) -> String { String(number) }
}

// MARK: - Compact Upgrade CTA
struct ModernUpgradeCTACard: View {
    let action: () -> Void
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Compact icon and text
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(DarkTheme.accent.opacity(0.15))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(DarkTheme.accent)
                }
                
                VStack(alignment: .leading, spacing: 2) {
Text(localizationManager.localizedString("upgrade.primary.title"))
                        .fontScaled(size: 16, weight: .semibold)
                        .foregroundColor(DarkTheme.textPrimary)
                    
Text(localizationManager.localizedString("upgrade.primary.subtitle"))
                        .fontScaled(size: 13)
                        .foregroundColor(DarkTheme.textSecondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Compact CTA button
            Button(action: action) {
                HStack(spacing: 6) {
Text(localizationManager.localizedString("upgrade.cta.primary"))
                        .fontScaled(size: 14, weight: .semibold)
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(DarkTheme.textPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [DarkTheme.accent, DarkTheme.accent.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(DarkTheme.textPrimary.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(DarkTheme.textPrimary.opacity(0.1), lineWidth: 1)
                )
        )
        .scaleEffect(isHovered ? 1.01 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
    
    
    
    
    
    
}

// MARK: - Compact License Activation
struct ModernLicenseActivationCard: View {
    @Binding var licenseKey: String
    @Binding var isActivating: Bool
    @Binding var activationMessage: String?
    @Binding var showingActivationError: Bool
    let activationAction: () -> Void
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        VStack(spacing: 12) {
            // Compact header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
Text(localizationManager.localizedString("license.activation.title"))
                        .fontScaled(size: 16, weight: .semibold)
                        .foregroundColor(DarkTheme.textPrimary)
                    
Text(localizationManager.localizedString("license.activation.subtitle"))
                        .fontScaled(size: 13)
                        .foregroundColor(DarkTheme.textSecondary)
                }
                Spacer()
            }
            
            // Compact input row
            HStack(spacing: 10) {
                modernTextField
                activationButton
            }
            
            // Activation Message
            if let message = activationMessage {
Text(message)
                    .fontScaled(size: 12, weight: .medium)
                    .foregroundColor(showingActivationError ? DarkTheme.error : DarkTheme.success)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .transition(.opacity)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(DarkTheme.textPrimary.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(DarkTheme.textPrimary.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Compact Text Field
    private var modernTextField: some View {
        HStack(spacing: 10) {
            Image(systemName: "key.fill")
                .foregroundColor(DarkTheme.textTertiary)
                .font(.system(size: 14))
            
            TextField(
                localizationManager.localizedString("license.key.placeholder"),
                text: $licenseKey
            )
            .textFieldStyle(.plain)
            .foregroundColor(DarkTheme.textPrimary)
            .font(.system(size: 14, weight: .medium, design: .monospaced))
            .textCase(.uppercase)
        }
        .padding(.horizontal, 12)
        .frame(height: 36)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(DarkTheme.surfaceBackground.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            licenseKey.isEmpty ? DarkTheme.border.opacity(0.3) : DarkTheme.accent.opacity(0.4),
                            lineWidth: 1
                        )
                )
        )
    }
    
    // MARK: - Compact Activation Button
    private var activationButton: some View {
        Button(action: activationAction) {
            HStack(spacing: 4) {
                if isActivating {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
Text(localizationManager.localizedString("license.activation.cta"))
                        .fontScaled(size: 13, weight: .semibold)
                }
            }
            .foregroundColor(DarkTheme.textPrimary)
            .padding(.horizontal, 16)
            .frame(height: 36)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        licenseKey.isEmpty ? 
                        DarkTheme.border.opacity(0.3) :
                        DarkTheme.accent
                    )
            )
            .disabled(licenseKey.isEmpty || isActivating)
        }
        .buttonStyle(.plain)
    }
    
}

#Preview("Trial Progress Card") {
    ModernTrialProgressCard(
        daysRemaining: 10,
        totalDays: 14
    )
    .frame(width: 400)
    .background(DarkTheme.background)
    .environmentObject(LocalizationManager.shared)
}

#Preview("Upgrade CTA Card") {
    ModernUpgradeCTACard {
        print("Upgrade tapped")
    }
    .frame(width: 400)
    .background(DarkTheme.background)
    .environmentObject(LocalizationManager.shared)
}

#Preview("License Activation Card") {
    ModernLicenseActivationCard(
        licenseKey: .constant(""),
        isActivating: .constant(false),
        activationMessage: .constant(nil),
        showingActivationError: .constant(false),
        activationAction: {}
    )
    .frame(width: 400)
    .background(DarkTheme.background)
    .environmentObject(LocalizationManager.shared)
}
