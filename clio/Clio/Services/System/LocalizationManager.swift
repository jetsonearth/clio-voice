//
//  LocalizationManager.swift
//  Clio
//
//  Created on 2025-01-04.
//

import SwiftUI
import Foundation

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var currentLanguage: String {
        didSet {
            UserDefaults.standard.set(currentLanguage, forKey: "selectedLanguage")
            updateBundle()
        }
    }
    
    private(set) var bundle: Bundle = .main
    
    // Supported languages with their native names
    static let supportedLanguages: [(code: String, name: String, nativeName: String)] = [
        ("en", "English", "English"),
        ("es", "Spanish", "Español"),
        ("fr", "French", "Français"),
        ("de", "German", "Deutsch"),
        ("it", "Italian", "Italiano"),
        ("ja", "Japanese", "日本語"),
        ("ko", "Korean", "한국어"),
        ("zh-Hans", "Chinese (Simplified)", "简体中文"),
        ("zh-Hant", "Chinese (Traditional)", "繁體中文"),
        ("ru", "Russian", "Русский")
    ]
    
    private init() {
        // Load saved language preference or use system language
        let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage")
        let systemLanguage = Locale.current.language.languageCode?.identifier ?? "en"
        
        // Check if saved or system language is supported
        let supportedCodes = Self.supportedLanguages.map { $0.code }
        if let saved = savedLanguage, supportedCodes.contains(saved) {
            self.currentLanguage = saved
        } else if supportedCodes.contains(systemLanguage) {
            self.currentLanguage = systemLanguage
        } else {
            self.currentLanguage = "en"
        }
        
        updateBundle()
    }
    
    private func updateBundle() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if let path = Bundle.main.path(forResource: self.currentLanguage, ofType: "lproj"),
               let languageBundle = Bundle(path: path) {
                self.bundle = languageBundle
                print("✅ LocalizationManager: Successfully loaded bundle for language: \(self.currentLanguage)")
            } else {
                self.bundle = .main
                print("⚠️ LocalizationManager: Failed to load bundle for language: \(self.currentLanguage), using main bundle")
            }
            
            // Trigger UI update
            self.objectWillChange.send()
        }
    }
    
    func setLanguage(_ languageCode: String) {
        guard Self.supportedLanguages.contains(where: { $0.code == languageCode }) else { return }
        DispatchQueue.main.async { [weak self] in
            self?.currentLanguage = languageCode
            // Force UI update by sending objectWillChange
            self?.objectWillChange.send()
        }
    }
    
    // Helper function to get localized string
    func localizedString(_ key: String, comment: String = "") -> String {
        // First try the selected language bundle
        let localizedString = bundle.localizedString(forKey: key, value: nil, table: nil)
        
        // If not found, try the main bundle
        if localizedString == key {
            let mainBundleString = Bundle.main.localizedString(forKey: key, value: nil, table: nil)
            print("⚠️ LocalizationManager: Missing translation for key '\(key)' in language '\(currentLanguage)'")
            // If still not found, return the key itself as fallback
            return mainBundleString != key ? mainBundleString : key
        }
        
        return localizedString
    }
    
    // Get current language display name
    var currentLanguageDisplayName: String {
        Self.supportedLanguages.first(where: { $0.code == currentLanguage })?.nativeName ?? "English"
    }
    
    // Check if current language is RTL
    var isRTL: Bool {
        return Locale.Language(identifier: currentLanguage).characterDirection == .rightToLeft
    }
}

// SwiftUI View Extension for easy localization
extension View {
    func localized() -> some View {
        self
            .environment(\.locale, Locale(identifier: LocalizationManager.shared.currentLanguage))
            .environment(\.layoutDirection, LocalizationManager.shared.isRTL ? .rightToLeft : .leftToRight)
    }
}

// Helper for SwiftUI localization
extension String {
    var localizationKey: LocalizedStringKey {
        return LocalizedStringKey(self)
    }
}