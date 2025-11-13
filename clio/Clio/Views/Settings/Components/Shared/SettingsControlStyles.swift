import SwiftUI

struct ConfigurationStatusBadge: View {
    enum Status {
        case ready
        case required
        case optional
    }
    
    let status: Status
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
            Text(text)
                .font(.system(size: 12, weight: .medium))
        }
        .foregroundColor(foregroundColor)
        .padding(.horizontal, 12)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(backgroundColor)
        )
    }
    
    private var icon: String {
        switch status {
        case .ready: return "checkmark.circle.fill"
        case .required: return "exclamationmark.triangle.fill"
        case .optional: return "info.circle.fill"
        }
    }
    
    private var foregroundColor: Color {
        switch status {
        case .ready: return DarkTheme.textPrimary
        case .required: return DarkTheme.textPrimary
        case .optional: return DarkTheme.textSecondary
        }
    }
    
    private var backgroundColor: Color {
        DarkTheme.surfaceBackground.opacity(0.7)
    }
}

struct SettingsPillButtonStyle: ButtonStyle {
    enum Style {
        case primary
        case secondary
    }
    
    var style: Style = .primary
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(textColor(configuration: configuration))
            .padding(.vertical, 6)
            .padding(.horizontal, 14)
            .background(
                Capsule()
                    .fill(backgroundColor(configuration: configuration))
                    .overlay(
                        Capsule()
                            .stroke(borderColor(configuration: configuration), lineWidth: 1)
                    )
            )
            .opacity(configuration.isPressed ? 0.85 : 1.0)
    }
    
    private func textColor(configuration: Configuration) -> Color {
        switch style {
        case .primary:
            return .white
        case .secondary:
            return DarkTheme.textPrimary
        }
    }
    
    private func backgroundColor(configuration: Configuration) -> Color {
        switch style {
        case .primary:
            return Color.accentColor.opacity(configuration.isPressed ? 0.85 : 1.0)
        case .secondary:
            return DarkTheme.surfaceBackground.opacity(configuration.isPressed ? 0.9 : 1.0)
        }
    }
    
    private func borderColor(configuration: Configuration) -> Color {
        switch style {
        case .primary:
            return Color.accentColor.opacity(0.6)
        case .secondary:
            return DarkTheme.border.opacity(0.9)
        }
    }
}
