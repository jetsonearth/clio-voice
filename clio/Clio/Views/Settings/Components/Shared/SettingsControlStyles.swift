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
                .font(.system(size: 11, weight: .semibold))
            Text(text)
                .font(.system(size: 11, weight: .medium))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 0)
        .padding(.vertical, 0)
        .modifier(StatusPillModifier(color: foregroundColor))
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
        case .required: return DarkTheme.warning
        case .optional: return DarkTheme.textSecondary
        }
    }
}

private struct StatusPillModifier: ViewModifier {
    let color: Color
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(color)
            .padding(.vertical, 4)
            .padding(.horizontal, 10)
            .background(
                Capsule()
                    .fill(DarkTheme.surfaceBackground.opacity(0.6))
            )
    }
}

struct SettingsPillButtonStyle: ButtonStyle {
    enum Style {
        case primary
        case secondary
        case status
    }
    
    var style: Style = .primary
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(textColor(configuration: configuration))
            .padding(.vertical, style == .status ? 3 : 5)
            .padding(.horizontal, style == .status ? 10 : 12)
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
        case .status:
            return DarkTheme.textPrimary
        }
    }
    
    private func backgroundColor(configuration: Configuration) -> Color {
        switch style {
        case .primary:
            return Color.accentColor.opacity(configuration.isPressed ? 0.85 : 1.0)
        case .secondary:
            return DarkTheme.surfaceBackground.opacity(configuration.isPressed ? 0.9 : 1.0)
        case .status:
            return DarkTheme.surfaceBackground.opacity(configuration.isPressed ? 0.85 : 0.75)
        }
    }
    
    private func borderColor(configuration: Configuration) -> Color {
        switch style {
        case .primary:
            return Color.accentColor.opacity(0.6)
        case .secondary:
            return DarkTheme.border.opacity(0.9)
        case .status:
            return DarkTheme.border.opacity(0.6)
        }
    }
}
