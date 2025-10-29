import SwiftUI

struct DictationLanguageSettingsSection: View {
    @EnvironmentObject private var localizationManager: LocalizationManager
    @AppStorage("SelectedLanguages") private var selectedLanguagesData: Data = Data()
    @AppStorage("SelectedLanguage") private var selectedLanguage: String = "en"
    @State private var isHovered = false
    
    // Computed property for multiple language selection
    private var selectedLanguages: Set<String> {
        get {
            if let decoded = try? JSONDecoder().decode(Set<String>.self, from: selectedLanguagesData) {
                return decoded.isEmpty ? ["auto"] : decoded
            }
            return ["auto"]
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                selectedLanguagesData = encoded
            }
            
            // Update the primary language for backward compatibility
            if let firstLanguage = newValue.first {
                selectedLanguage = firstLanguage
                
                // Post notification for language change to sync with menu bar
                NotificationCenter.default.post(name: .languageDidChange, object: nil)
            }
        }
    }
    
    // List of dictation languages with native names
    private let dictationLanguages: [(code: String, name: String, nativeName: String)] = [
        ("auto", "Auto-Detect", "Auto-Detect"),
        ("en", "English", "English"),
        ("ar", "Arabic", "العربية"),
        ("be", "Belarusian", "Беларуская"),
        ("bg", "Bulgarian", "Български"),
        ("bn", "Bengali", "বাংলা"),
        ("ca", "Catalan", "Català"),
        ("zh", "Chinese", "中文"),
        // Pseudo option for Taiwanese users – maps to zh for ASR, enables Traditional post-processing
        ("zh-Hant", "Chinese (Traditional)", "繁體中文"),
        ("zh-tw", "Cantonese", "粵語"),
        ("hr", "Croatian", "Hrvatski"),
        ("cs", "Czech", "Čeština"),
        ("da", "Danish", "Dansk"),
        ("nl", "Dutch", "Nederlands"),
        ("et", "Estonian", "Eesti"),
        ("fi", "Finnish", "Suomi"),
        ("fr", "French", "Français"),
        ("de", "German", "Deutsch"),
        ("el", "Greek", "Ελληνικά"),
        ("he", "Hebrew", "עברית"),
        ("hi", "Hindi", "हिन्दी"),
        ("hu", "Hungarian", "Magyar"),
        ("is", "Icelandic", "Íslenska"),
        ("id", "Indonesian", "Bahasa Indonesia"),
        ("it", "Italian", "Italiano"),
        ("ja", "Japanese", "日本語"),
        ("ko", "Korean", "한국어"),
        ("lv", "Latvian", "Latviešu"),
        ("lt", "Lithuanian", "Lietuvių"),
        ("ms", "Malay", "Bahasa Melayu"),
        ("no", "Norwegian", "Norsk"),
        ("fa", "Persian", "فارسی"),
        ("pl", "Polish", "Polski"),
        ("pt", "Portuguese", "Português"),
        ("ro", "Romanian", "Română"),
        ("ru", "Russian", "Русский"),
        ("sk", "Slovak", "Slovenčina"),
        ("sl", "Slovenian", "Slovenščina"),
        ("es", "Spanish", "Español"),
        ("sv", "Swedish", "Svenska"),
        ("th", "Thai", "ไทย"),
        ("tr", "Turkish", "Türkçe"),
        ("uk", "Ukrainian", "Українська"),
        ("ur", "Urdu", "اردو"),
        ("vi", "Vietnamese", "Tiếng Việt")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "mic")
                    .font(.system(size: 20))
                    .foregroundColor(.accentColor)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(localizationManager.localizedString("settings.dictation_language"))
                            .font(.headline)
                            .foregroundColor(DarkTheme.textPrimary)
                        
                        HelpButton(message: localizationManager.localizedString("settings.dictation_language.tooltip"))
                    }
                    
                    Text(localizationManager.localizedString("settings.dictation_language.description"))
                        .font(.subheadline)
                        .foregroundColor(DarkTheme.textSecondary)
                }
                
                Spacer()
                
                Menu {
                    // Auto-Detect at the top
                    Button {
                        toggleLanguageSelection("auto")
                    } label: {
                        HStack {
                            Text("Auto-Detect - Auto-Detect")
                            Spacer()
                            if selectedLanguages.contains("auto") {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    
                    Divider()
                    
                    // All other languages (excluding auto)
                    ForEach(dictationLanguages.filter { $0.code != "auto" }, id: \.code) { language in
                        Button {
                            toggleLanguageSelection(language.code)
                        } label: {
                            HStack {
                                Text("\(language.name) - \(language.nativeName)")
                                Spacer()
                                if selectedLanguages.contains(language.code) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "mic")
                            .font(.system(size: 14))
                            .foregroundColor(DarkTheme.textSecondary)
                        
                        Text(selectedLanguagesText())
                            .font(.system(size: 13))
                            .foregroundColor(DarkTheme.textPrimary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12))
                            .foregroundColor(DarkTheme.textSecondary)
                            .rotationEffect(.degrees(isHovered ? 180 : 0))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(DarkTheme.surfaceBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(
                                        isHovered ? 
                                            Color.accentColor.opacity(0.5) : 
                                            DarkTheme.textSecondary.opacity(0.2), 
                                        lineWidth: 1
                                    )
                            )
                    )
                    .scaleEffect(isHovered ? 1.02 : 1.0)
                    .shadow(
                        color: isHovered ? Color.accentColor.opacity(0.1) : .clear,
                        radius: isHovered ? 8 : 0
                    )
                }
                .buttonStyle(.plain)
                .frame(width: 250)
                .onHover { hovering in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isHovered = hovering
                    }
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
    
    private func selectedLanguagesText() -> String {
        if selectedLanguages.contains("auto") {
            return localizationManager.localizedString("settings.dictation.auto_detect")
        } else if selectedLanguages.count == 1, let first = selectedLanguages.first {
            return dictationLanguages.first { $0.code == first }?.name ?? "Unknown"
        } else if selectedLanguages.count > 1 {
            return String(format: localizationManager.localizedString("settings.dictation.languages_count"), selectedLanguages.count)
        } else {
            return localizationManager.localizedString("settings.dictation.select_languages")
        }
    }
    
    private func toggleLanguageSelection(_ code: String) {
        var newSelection = selectedLanguages
        
        if code == "auto" {
            // If auto-detect is selected, clear all others
            newSelection = ["auto"]
        } else {
            // Remove auto-detect if a specific language is selected
            newSelection.remove("auto")
            
            if newSelection.contains(code) {
                newSelection.remove(code)
            } else {
                newSelection.insert(code)
            }
            
            // If no languages selected, default back to auto
            if newSelection.isEmpty {
                newSelection = ["auto"]
            }
        }
        
        // Update UserDefaults directly
        if let encoded = try? JSONEncoder().encode(newSelection) {
            selectedLanguagesData = encoded
        }
        
        // Update the primary language for backward compatibility
        if let firstLanguage = newSelection.first {
            selectedLanguage = firstLanguage
            
            // Post notification for language change to sync with menu bar
            NotificationCenter.default.post(name: .languageDidChange, object: nil)
        }
    }
}

struct DictationLanguageCard: View {
    let code: String
    let name: String
    let nativeName: String
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isHovered = false
    
    private var languageFlag: String {
        // Map language codes to flag emojis
        switch code {
        case "auto": return "🤖"
        case "en": return "🇺🇸"
        case "es": return "🇪🇸"
        case "fr": return "🇫🇷"
        case "de": return "🇩🇪"
        case "it": return "🇮🇹"
        case "pt": return "🇵🇹"
        case "ja": return "🇯🇵"
        case "ko": return "🇰🇷"
        case "zh": return "🇨🇳"
        case "zh-tw": return "🇭🇰"
        case "ru": return "🇷🇺"
        case "ar": return "🇸🇦"
        case "hi": return "🇮🇳"
        case "nl": return "🇳🇱"
        case "pl": return "🇵🇱"
        case "tr": return "🇹🇷"
        case "th": return "🇹🇭"
        case "vi": return "🇻🇳"
        case "no": return "🇳🇴"
        case "sv": return "🇸🇪"
        case "da": return "🇩🇰"
        case "fi": return "🇫🇮"
        case "he": return "🇮🇱"
        case "bg": return "🇧🇬"
        case "hr": return "🇭🇷"
        case "cs": return "🇨🇿"
        case "et": return "🇪🇪"
        case "lv": return "🇱🇻"
        case "lt": return "🇱🇹"
        case "sk": return "🇸🇰"
        case "sl": return "🇸🇮"
        case "ro": return "🇷🇴"
        case "hu": return "🇭🇺"
        case "el": return "🇬🇷"
        case "ca": return "🇪🇸"
        case "is": return "🇮🇸"
        case "id": return "🇮🇩"
        case "ms": return "🇲🇾"
        case "fa": return "🇮🇷"
        case "uk": return "🇺🇦"
        case "ur": return "🇵🇰"
        case "be": return "🇧🇾"
        case "bn": return "🇧🇩"
        default: return "🌐"
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(languageFlag)
                    .font(.system(size: 28))
                
                VStack(spacing: 2) {
                    Text("\(name) - \(nativeName)")
                        .font(.caption)
                        .fontWeight(isSelected ? .semibold : .regular)
                        .foregroundColor(isSelected ? DarkTheme.accent : DarkTheme.textPrimary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
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
                RoundedRectangle(cornerRadius: 8)
                    .fill(isHovered ? DarkTheme.accent.opacity(0.1) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                isSelected ? DarkTheme.accent : DarkTheme.textPrimary.opacity(0.2),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
}