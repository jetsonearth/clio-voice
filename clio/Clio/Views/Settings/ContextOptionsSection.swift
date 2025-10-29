import SwiftUI

// Stand-alone "Context Options" settings section that groups clipboard and screen context toggles in their own card, matching the rest of the settings UI.
struct ContextOptionsSection: View {
    @EnvironmentObject private var contextService: ContextService
    @EnvironmentObject private var localizationManager: LocalizationManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "brain")
                    .font(.system(size: 20))
                    .foregroundColor(.accentColor)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(localizationManager.localizedString("settings.deep_context.title"))
                            .font(.headline)
                            .foregroundColor(DarkTheme.textPrimary)
                        
                        HelpButton(message: localizationManager.localizedString("settings.deep_context.tooltip"))
                    }
                    Text(localizationManager.localizedString("settings.deep_context.subtitle"))
                        .font(.subheadline)
                        .foregroundColor(DarkTheme.textSecondary)
                }
                
                Spacer()
                
                Toggle("", isOn: $contextService.useScreenCaptureContext)
                    .toggleStyle(SwitchToggleStyle(tint: DarkTheme.accent))
                    .scaleEffect(1.0)
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