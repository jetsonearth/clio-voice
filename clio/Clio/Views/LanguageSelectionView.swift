import SwiftUI

// Define a display mode for flexible usage
enum LanguageDisplayMode {
    case full // For settings page with descriptions
    case menuItem // For menu bar with compact layout
}

struct LanguageSelectionView: View {
    @ObservedObject var recordingEngine: RecordingEngine
    @AppStorage("SelectedLanguage") private var selectedLanguage: String = "en"
    @AppStorage("SelectedLanguages") private var selectedLanguagesData: Data = Data()
    // Add display mode parameter with full as the default
    var displayMode: LanguageDisplayMode = .full
    @ObservedObject var whisperPrompt: WhisperPrompt
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    // Computed property for multiple language selection
    private var selectedLanguages: Set<String> {
        get {
            if let decoded = try? JSONDecoder().decode(Set<String>.self, from: selectedLanguagesData) {
                return decoded.isEmpty ? ["en"] : decoded
            }
            return ["en"]
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                selectedLanguagesData = encoded
            }
        }
    }

    private func updateLanguage(_ language: String) {
        // Update UI state - the UserDefaults updating is now automatic with @AppStorage
        selectedLanguage = language

        // Force the prompt to update for the new language
        whisperPrompt.updateTranscriptionPrompt()

        // Post notification for language change
        NotificationCenter.default.post(name: .languageDidChange, object: nil)
    }
    
    // Function to check if current model is multilingual
    private func isMultilingualModel() -> Bool {
        guard let currentModel = recordingEngine.currentModel,
               let predefinedModel = PredefinedModels.models.first(where: { $0.name == currentModel.name }) else {
            return false
        }
        return predefinedModel.isMultilingualModel
    }

    // Function to get current model's supported languages
    private func getCurrentModelLanguages() -> [String: String] {
        guard let currentModel = recordingEngine.currentModel,
              let predefinedModel = PredefinedModels.models.first(where: {
                  $0.name == currentModel.name
              })
        else {
            return ["en": "English"] // Default to English if no model found
        }
        return predefinedModel.supportedLanguages
    }

    // Get the display name of the current language
    private func currentLanguageDisplayName() -> String {
        return getCurrentModelLanguages()[selectedLanguage] ?? "Unknown"
    }

    var body: some View {
        switch displayMode {
        case .full:
            fullView
        case .menuItem:
            menuItemView
        }
    }

    // The original full view layout for settings page
    private var fullView: some View {
        VStack(alignment: .leading, spacing: 16) {
            languageSelectionSection
            
            // Add prompt customization view below language selection
//            PromptCustomizationView(whisperPrompt: whisperPrompt)
        }
    }
    
    private var languageSelectionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(localizationManager.localizedString("language.transcription.title"))
                .font(.headline)

            if let currentModel = recordingEngine.currentModel,
               let predefinedModel = PredefinedModels.models.first(where: {
                   $0.name == currentModel.name
               })
            {
                if isMultilingualModel() {
                    VStack(alignment: .leading, spacing: 8) {
                        Picker("Select Language", selection: $selectedLanguage) {
                            ForEach(
                                predefinedModel.supportedLanguages.sorted(by: {
                                    if $0.key == "auto" { return true }
                                    if $1.key == "auto" { return false }
                                    return $0.value < $1.value
                                }), id: \.key
                            ) { key, value in
                                Text(value).tag(key)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .onChange(of: selectedLanguage) { oldValue, newValue in
                            updateLanguage(newValue)
                        }

                        Text(String(format: localizationManager.localizedString("language.current_model"), predefinedModel.displayName))
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(localizationManager.localizedString("language.multilingual.description"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                } else {
                    // For English-only models, force set language to English
                    VStack(alignment: .leading, spacing: 8) {
                        Text(localizationManager.localizedString("language.english_only"))
                            .font(.subheadline)
                            .foregroundColor(.primary)

                        Text(String(format: localizationManager.localizedString("language.current_model"), predefinedModel.displayName))
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(localizationManager.localizedString("language.english_only.description"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    .onAppear {
                        // Ensure English is set when viewing English-only model
                        updateLanguage("en")
                    }
                }
            } else {
                Text(localizationManager.localizedString("language.no_model"))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(10)
    }

    // New compact view for menu bar with multiple language selection
    private var menuItemView: some View {
        Menu {
            ForEach(SonioxLanguages.sortedLanguages, id: \.code) { language in
                Button {
                    toggleLanguageSelection(language.code)
                } label: {
                    HStack {
                        Text(language.name)
                        Spacer()
                        if selectedLanguages.contains(language.code) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            
            Divider()
            
            Button("Clear All") {
                if let encoded = try? JSONEncoder().encode(Set(["en"])) {
                    selectedLanguagesData = encoded
                }
            }
        } label: {
            Text(LocalizationManager.shared.localizedString("menu.select_dictation_language"))
        }
    }
    
    private func toggleLanguageSelection(_ languageCode: String) {
        var newSelection = selectedLanguages
        
        if languageCode == "auto" {
            // If auto is selected, clear other selections and set only auto
            newSelection = ["auto"]
        } else {
            // Remove auto if another language is selected
            newSelection.remove("auto")
            
            if newSelection.contains(languageCode) {
                newSelection.remove(languageCode)
                // Ensure at least one language is selected
                if newSelection.isEmpty {
                    newSelection.insert("en")
                }
            } else {
                newSelection.insert(languageCode)
                // If user selects Traditional Chinese, also ensure base Chinese is present for ASR
                if languageCode.lowercased() == "zh-hant" {
                    newSelection.insert("zh")
                }
            }
        }
        
        if let encoded = try? JSONEncoder().encode(newSelection) {
            selectedLanguagesData = encoded
        }
        
        // Update the primary language for backward compatibility
        if let firstLanguage = newSelection.first {
            updateLanguage(firstLanguage)
        }
    }
}
