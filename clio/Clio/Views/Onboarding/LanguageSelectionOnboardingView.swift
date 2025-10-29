import SwiftUI

struct LanguageSelectionOnboardingView: View {
    @ObservedObject var viewModel: ProfessionalOnboardingViewModel
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var selectedLanguages: Set<String> = []
    @State private var searchText = ""
    @State private var showLanguageDropdown = false
    @State private var animateElements = false
    
    private var filteredLanguages: [(code: String, name: String)] {
        let languages = SonioxLanguages.sortedLanguages.filter { $0.code != "auto" }
        if searchText.isEmpty {
            return languages
        }
        return languages.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.code.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        ZStack {
            // Full-page background image
            if let nsImage = loadOnboardingLangImage() {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .frame(minWidth: 1200, minHeight: 800)
                    .clipped()
            } else {
                Color.black
                    .ignoresSafeArea()
            }

            // Subtle gradient overlay for readability
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.5),
                    Color.black.opacity(0.2),
                    Color.black.opacity(0.4)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                OnboardingHeaderControls()

                // Centered content overlay
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(localizationManager.localizedString("onboarding.language.title"))
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(DarkTheme.textPrimary)
                            .opacity(animateElements ? 1 : 0)
                            .scaleEffect(animateElements ? 1 : 0.95)
                        Text(localizationManager.localizedString("onboarding.language.subtitle"))
                            .font(.system(size: 15))
                            .foregroundColor(DarkTheme.textSecondary)
                            .opacity(animateElements ? 1 : 0)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.top, 10)

                    // Language selection interface
                    VStack(spacing: 16) {
                        // Search bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(DarkTheme.textSecondary)
                                .font(.system(size: 16))

                            TextField(localizationManager.localizedString("onboarding.language.search_placeholder"), text: $searchText)
                                .textFieldStyle(.plain)
                                .font(.system(size: 16))
                                .foregroundColor(DarkTheme.textPrimary)
                                .onTapGesture { showLanguageDropdown = true }
                                .onChange(of: searchText) { newValue in
                                    showLanguageDropdown = !newValue.isEmpty
                                }
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(NSColor.controlBackgroundColor).opacity(0.3))
                        )

                        // Selected language chips
                        if !selectedLanguages.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(Array(selectedLanguages), id: \.self) { code in
                                        if let name = SonioxLanguages.all[code] {
                                            LanguageChip(code: code, name: name) {
                                                selectedLanguages.remove(code)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 4)
                            }
                        }

                        // Language dropdown
                        if showLanguageDropdown && !searchText.isEmpty {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 2) {
                                    ForEach(filteredLanguages.prefix(8), id: \.code) { language in
                                        LanguageRow(
                                            code: language.code,
                                            name: language.name,
                                            isSelected: selectedLanguages.contains(language.code),
                                            action: {
                                                if selectedLanguages.contains(language.code) {
                                                    selectedLanguages.remove(language.code)
                                                } else {
                                                    selectedLanguages.insert(language.code)
                                                }
                                            }
                                        )
                                    }
                                }
                            }
                            .frame(maxHeight: 200)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(DarkTheme.textPrimary.opacity(0.1), lineWidth: 1)
                                    )
                            )
                        }

                        // Continue + Back + Skip
                        HStack {
                            StyledBackButton { viewModel.previousScreen() }
                            StyledActionButton(
                                title: localizationManager.localizedString("general.continue"),
                                action: {
                                    saveLanguageSelection()
                                    viewModel.nextScreen()
                                },
                                isDisabled: false,
                                showArrow: true
                            )
                        }
                        .padding(.top, 28)

                        Text(localizationManager.localizedString("onboarding.skip"))
                            .font(.system(size: 14))
                            .foregroundColor(DarkTheme.textSecondary)
                            .onTapGesture {
                                saveLanguageSelection()
                                viewModel.nextScreen()
                            }
                            .frame(maxWidth: .infinity)
                    }
                    .opacity(animateElements ? 1 : 0)
                    .offset(y: animateElements ? 0 : 20)
                    .padding(.bottom, 60)
                }
                .offset(y: -12)
                .frame(maxWidth: 520)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(minWidth: 1200, minHeight: 800)
        .ignoresSafeArea()
        .onTapGesture {
            // Close dropdown when tapping outside
            if showLanguageDropdown {
                showLanguageDropdown = false
                searchText = ""
            }
        }
        .onAppear {
            loadExistingSelection()
            withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                animateElements = true
            }
        }
    }
    
    private func loadOnboardingLangImage() -> NSImage? {
        if let named = NSImage(named: "lang") { return named }
        let exts = ["png", "jpg", "jpeg"]
        for ext in exts {
            if let path = Bundle.main.path(forResource: "lang", ofType: ext),
               let img = NSImage(contentsOfFile: path) { return img }
        }
        return nil
    }
    
    
    private func loadExistingSelection() {
        // For onboarding, always start fresh with English as default
        // Remove any auto-detect preference and default to English
        selectedLanguages = ["en"]
        
        // Also check if there are existing selections that we should load
        if let data = UserDefaults.standard.data(forKey: "SelectedLanguages"),
           let decoded = try? JSONDecoder().decode(Set<String>.self, from: data),
           !decoded.isEmpty {
            // Remove auto-detect if it exists and ensure we have a valid selection
            var cleanedSelection = decoded
            cleanedSelection.remove("auto")
            if !cleanedSelection.isEmpty {
                selectedLanguages = cleanedSelection
            }
        }
    }
    
    private func saveLanguageSelection() {
        // Save selected languages or default to auto-detect if none selected
        let languagesToSave: Set<String> = selectedLanguages.isEmpty ? ["auto"] : selectedLanguages
        
        // Save to UserDefaults
        if let encoded = try? JSONEncoder().encode(languagesToSave) {
            UserDefaults.standard.set(encoded, forKey: "SelectedLanguages")
        }
        
        // Also update single language for backward compatibility
        if let firstLanguage = languagesToSave.first {
            UserDefaults.standard.set(firstLanguage, forKey: "SelectedLanguage")
        }
        
        // Post notification for language change
        NotificationCenter.default.post(name: .languageDidChange, object: nil)
    }
}


// MARK: - Language Chip
struct LanguageChip: View {
    let code: String
    let name: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 6) {
            Text(languageFlag(for: code))
                .font(.system(size: 14))
            Text(name)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(DarkTheme.textPrimary)
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(DarkTheme.textSecondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
        )
    }
    
    private func languageFlag(for code: String) -> String {
        switch code {
        case "en": return "🇺🇸"
        case "zh": return "🇨🇳"
        case "zh-Hant": return "🇹🇼"
        case "es": return "🇪🇸"
        case "fr": return "🇫🇷"
        case "de": return "🇩🇪"
        case "ja": return "🇯🇵"
        case "ko": return "🇰🇷"
        case "pt": return "🇵🇹"
        case "ru": return "🇷🇺"
        case "ar": return "🇸🇦"
        case "hi": return "🇮🇳"
        case "it": return "🇮🇹"
        case "nl": return "🇳🇱"
        case "pl": return "🇵🇱"
        case "tr": return "🇹🇷"
        case "vi": return "🇻🇳"
        case "id": return "🇮🇩"
        case "th": return "🇹🇭"
        case "sv": return "🇸🇪"
        case "da": return "🇩🇰"
        case "no": return "🇳🇴"
        case "fi": return "🇫🇮"
        case "el": return "🇬🇷"
        case "he": return "🇮🇱"
        case "cs": return "🇨🇿"
        case "hu": return "🇭🇺"
        case "ro": return "🇷🇴"
        case "uk": return "🇺🇦"
        case "bg": return "🇧🇬"
        case "hr": return "🇭🇷"
        case "sk": return "🇸🇰"
        case "sl": return "🇸🇮"
        case "et": return "🇪🇪"
        case "lv": return "🇱🇻"
        case "lt": return "🇱🇹"
        case "ca": return "🇦🇩"
        case "eu": return "🏴󠁥󠁳󠁰󠁶󠁿"  // Basque
        case "gl": return "🇪🇸"
        case "fa": return "🇮🇷"
        case "ur": return "🇵🇰"
        case "bn": return "🇧🇩"
        case "ta": return "🇱🇰"
        case "te": return "🇮🇳"
        case "ml": return "🇮🇳"
        case "kn": return "🇮🇳"
        case "mr": return "🇮🇳"
        case "gu": return "🇮🇳"
        case "pa": return "🇮🇳"
        case "ms": return "🇲🇾"
        case "tl": return "🇵🇭"
        case "sw": return "🇰🇪"
        case "am": return "🇪🇹"
        case "my": return "🇲🇲"
        case "km": return "🇰🇭"
        case "lo": return "🇱🇦"
        case "si": return "🇱🇰"
        case "ne": return "🇳🇵"
        case "mn": return "🇲🇳"
        case "kk": return "🇰🇿"
        case "az": return "🇦🇿"
        case "ka": return "🇬🇪"
        case "sq": return "🇦🇱"  // Albanian
        case "mk": return "🇲🇰"
        case "bs": return "🇧🇦"
        case "sr": return "🇷🇸"
        case "cy": return "🏴󠁧󠁢󠁷󠁬󠁳󠁿"  // Welsh
        case "is": return "🇮🇸"  // Icelandic
        case "mt": return "🇲🇹"  // Maltese
        case "be": return "🇧🇾"  // Belarusian
        case "auto": return "🌐"
        default: return "🌍"
        }
    }
}

// MARK: - Language Row
struct LanguageRow: View {
    let code: String
    let name: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(name)
                    .font(.system(size: 14))
                    .foregroundColor(DarkTheme.textPrimary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.accentColor)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
    }
}

// MARK: - Old Language Card Component (keeping for reference, can be removed)
struct OnboardingDictationCard: View {
    let code: String
    let name: String
    let isSelected: Bool
    let action: () -> Void
    
    private var languageFlag: String {
        // Map language codes to flag emojis
        switch code {
        case "en": return "🇺🇸"
        case "zh": return "🇨🇳"
        case "zh-Hant": return "🇹🇼"  // Taiwan flag for Traditional Chinese
        case "es": return "🇪🇸"
        case "fr": return "🇫🇷"
        case "de": return "🇩🇪"
        case "ja": return "🇯🇵"
        case "ko": return "🇰🇷"
        case "pt": return "🇵🇹"
        case "ru": return "🇷🇺"
        case "ar": return "🇸🇦"
        case "hi": return "🇮🇳"
        case "it": return "🇮🇹"
        case "nl": return "🇳🇱"
        case "pl": return "🇵🇱"
        case "tr": return "🇹🇷"
        case "vi": return "🇻🇳"
        case "id": return "🇮🇩"
        case "th": return "🇹🇭"
        case "sv": return "🇸🇪"
        case "da": return "🇩🇰"
        case "no": return "🇳🇴"
        case "fi": return "🇫🇮"
        case "el": return "🇬🇷"  // Greek
        case "he": return "🇮🇱"  // Hebrew
        case "cs": return "🇨🇿"  // Czech
        case "hu": return "🇭🇺"  // Hungarian
        case "ro": return "🇷🇴"  // Romanian
        case "uk": return "🇺🇦"  // Ukrainian
        case "bg": return "🇧🇬"  // Bulgarian
        case "hr": return "🇭🇷"  // Croatian
        case "sk": return "🇸🇰"  // Slovak
        case "sl": return "🇸🇮"  // Slovenian
        case "et": return "🇪🇪"  // Estonian
        case "lv": return "🇱🇻"  // Latvian
        case "lt": return "🇱🇹"  // Lithuanian
        case "ca": return "🇦🇩"  // Catalan (Andorra)
        case "eu": return "🇪🇸"  // Basque (Spain region)
        case "gl": return "🇪🇸"  // Galician (Spain region)
        case "fa": return "🇮🇷"  // Persian
        case "ur": return "🇵🇰"  // Urdu
        case "bn": return "🇧🇩"  // Bengali
        case "ta": return "🇱🇰"  // Tamil (Sri Lanka)
        case "te": return "🇮🇳"  // Telugu
        case "ml": return "🇮🇳"  // Malayalam
        case "kn": return "🇮🇳"  // Kannada
        case "mr": return "🇮🇳"  // Marathi
        case "gu": return "🇮🇳"  // Gujarati
        case "pa": return "🇮🇳"  // Punjabi
        case "ms": return "🇲🇾"  // Malay
        case "tl": return "🇵🇭"  // Filipino
        case "sw": return "🇰🇪"  // Swahili (Kenya)
        case "am": return "🇪🇹"  // Amharic
        case "my": return "🇲🇲"  // Myanmar
        case "km": return "🇰🇭"  // Khmer
        case "lo": return "🇱🇦"  // Lao
        case "si": return "🇱🇰"  // Sinhala
        case "ne": return "🇳🇵"  // Nepali
        case "mn": return "🇲🇳"  // Mongolian
        case "kk": return "🇰🇿"  // Kazakh
        case "az": return "🇦🇿"  // Azerbaijani
        case "ka": return "🇬🇪"  // Georgian
        case "sq": return "🇦🇱"  // Albanian
        case "mk": return "🇲🇰"  // Macedonian
        case "bs": return "🇧🇦"  // Bosnian
        case "sr": return "🇷🇸"  // Serbian
        case "cy": return "🏴󠁧󠁢󠁷󠁬󠁳󠁿"  // Welsh
        case "auto": return "🌐"
        default: return "🌍"
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // Flag or icon
                Text(languageFlag)
                    .font(.system(size: 28))
                
                // Language name
                Text(name)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(DarkTheme.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(minHeight: 32)
                
                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.green)
                } else {
                    Circle()
                        .stroke(DarkTheme.textSecondary.opacity(0.3), lineWidth: 1)
                        .frame(width: 18, height: 18)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 100)
            .padding(12)
            .background(
                ZStack {
                    // Main card background with glassmorphism effect
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? .ultraThinMaterial : .thinMaterial)
                    
                    // Selected state highlight
                    if isSelected {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(DarkTheme.textPrimary.opacity(0.3), lineWidth: 1)
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(DarkTheme.textSecondary.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// (Old two-column visual panel removed in favor of full-screen background)

#Preview {
    LanguageSelectionOnboardingView(viewModel: ProfessionalOnboardingViewModel())
        .environmentObject(LocalizationManager.shared)
        .frame(width: 1200, height: 800)
        .translucentBackground()
}
