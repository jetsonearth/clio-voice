import SwiftUI

struct LanguageSettingsSection: View {
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    private var supportedLanguages: [(code: String, name: String, nativeName: String)] {
        return LocalizationManager.supportedLanguages
    }
    
    private var currentLanguageOption: String? {
        return supportedLanguages.first { $0.code == localizationManager.currentLanguage }
            .map { "\($0.code)|\($0.name)|\($0.nativeName)" }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "globe")
                    .font(.system(size: 20))
                    .foregroundColor(.accentColor)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(localizationManager.localizedString("settings.app_language"))
                            .font(.headline)
                            .foregroundColor(DarkTheme.textPrimary)
                        
                        HelpButton(message: localizationManager.localizedString("settings.app_language.tooltip"))
                    }
                    
                    Text(localizationManager.localizedString("settings.app_language.description"))
                        .font(.subheadline)
                        .foregroundColor(DarkTheme.textSecondary)
                }
                
                Spacer()
                
                StyledDropdown(
                    icon: "globe",
                    options: supportedLanguages.map { "\($0.code)|\($0.name)|\($0.nativeName)" },
                    selectedOption: supportedLanguages.first { $0.code == localizationManager.currentLanguage }
                        .map { "\($0.code)|\($0.name)|\($0.nativeName)" },
                    defaultText: "Select Language",
                    optionDisplayText: { option in
                        let parts = option.split(separator: "|")
                        if parts.count == 3 {
                            let englishName = String(parts[1])
                            let nativeName = String(parts[2])
                            return "\(englishName) - \(nativeName)"
                        }
                        return option
                    }
                ) { selection in
                    if let selection = selection {
                        let parts = selection.split(separator: "|")
                        if parts.count >= 2 {
                            let languageCode = String(parts[0])
                            localizationManager.setLanguage(languageCode)
                        }
                    }
                }
                .frame(minWidth: 250, maxWidth: 280, alignment: .trailing)
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

struct LanguageCard: View {
    let code: String
    let name: String
    let nativeName: String
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isHovered = false
    
    private var languageFlag: String {
        // Map language codes to flag emojis
        switch code {
        case "en": return "🇺🇸"
        case "es": return "🇪🇸"
        case "fr": return "🇫🇷"
        case "de": return "🇩🇪"
        case "it": return "🇮🇹"
        case "pt": return "🇵🇹"
        case "ja": return "🇯🇵"
        case "ko": return "🇰🇷"
        case "zh-Hans": return "🇨🇳"
        case "zh-Hant": return "🇹🇼"
        case "ru": return "🇷🇺"
        case "ar": return "🇸🇦"
        case "hi": return "🇮🇳"
        case "nl": return "🇳🇱"
        case "pl": return "🇵🇱"
        default: return "🌐"
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(languageFlag)
                    .font(.system(size: 28))
                
                VStack(spacing: 2) {
                    Text(nativeName)
                        .font(.caption)
                        .fontWeight(isSelected ? .semibold : .regular)
                        .foregroundColor(isSelected ? DarkTheme.accent : DarkTheme.textPrimary)
                    
                    Text(name)
                        .font(.caption2)
                        .foregroundColor(DarkTheme.textSecondary)
                }
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(DarkTheme.accent)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        isSelected ? DarkTheme.accent.opacity(0.15) :
                        (isHovered ? DarkTheme.textTertiary.opacity(0.1) : Color.clear)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? DarkTheme.accent.opacity(0.4) :
                                (isHovered ? DarkTheme.textTertiary.opacity(0.2) : Color.clear),
                                lineWidth: 1
                            )
                    )
            )
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isHovered)
            .animation(.easeInOut(duration: 0.3), value: isSelected)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}
