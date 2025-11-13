import SwiftUI

struct SettingsSection<Content: View>: View {
    let icon: String?
    let title: String
    let subtitle: String
    let content: Content
    var showWarning: Bool = false
    var trailingButton: (() -> Void)? = nil
    var trailingButtonIcon: String? = nil
    var trailingButtonText: String = "Edit"
    var hideContent: Bool = false
    var badgeText: String? = nil
    
    init(icon: String? = nil, title: String, subtitle: String, showWarning: Bool = false, trailingButton: (() -> Void)? = nil, trailingButtonIcon: String? = nil, trailingButtonText: String = "Edit", hideContent: Bool = false, badgeText: String? = nil, @ViewBuilder content: () -> Content) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.showWarning = showWarning
        self.trailingButton = trailingButton
        self.trailingButtonIcon = trailingButtonIcon
        self.trailingButtonText = trailingButtonText
        self.hideContent = hideContent
        self.badgeText = badgeText
        self.content = content()
    }
    
    private var hasHeaderContent: Bool {
        !(title.isEmpty && subtitle.isEmpty && icon == nil)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if hasHeaderContent {
                HStack(spacing: icon == nil ? 0 : 12) {
                    if let icon {
                        Image(systemName: icon)
                            .font(.system(size: 20))
                            .foregroundColor(showWarning ? .orange : .accentColor)
                            .frame(width: 24, height: 24)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(DarkTheme.textPrimary)
                        Text(subtitle)
                            .font(.system(size: 12))
                            .foregroundColor(showWarning ? .orange : DarkTheme.textSecondary)
                    }
                    
                    if showWarning {
                        Spacer()
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .help("Permission required for Io to function properly")
                    }
                }
                
                Divider()
                    .padding(.vertical, 4)
            }
            
            content
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

// Add this extension for consistent description text styling
extension Text {
    func settingsDescription() -> some View {
        self
            .font(.caption)
            .foregroundColor(.secondary)
    }
}
