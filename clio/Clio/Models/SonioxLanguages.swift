import Foundation

enum SonioxLanguages {
    static let all: [String: String] = [
        "auto": "Auto-detect",
        "en": "English",
        "zh": "Chinese",
        "zh-Hant": "Chinese (Traditional)",
        "es": "Spanish", 
        "fr": "French",
        "de": "German",
        "ja": "Japanese",
        "ko": "Korean",
        "pt": "Portuguese",
        "ru": "Russian",
        "ar": "Arabic",
        "hi": "Hindi",
        "it": "Italian",
        "nl": "Dutch",
        "pl": "Polish",
        "tr": "Turkish",
        "vi": "Vietnamese",
        "id": "Indonesian",
        "th": "Thai",
        "sv": "Swedish",
        "da": "Danish",
        "no": "Norwegian",
        "fi": "Finnish",
        "el": "Greek",
        "he": "Hebrew",
        "cs": "Czech",
        "hu": "Hungarian",
        "ro": "Romanian",
        "uk": "Ukrainian",
        "bg": "Bulgarian",
        "hr": "Croatian",
        "sk": "Slovak",
        "sl": "Slovenian",
        "et": "Estonian",
        "lv": "Latvian",
        "lt": "Lithuanian",
        "ca": "Catalan",
        "eu": "Basque",
        "gl": "Galician",
        "fa": "Persian",
        "ur": "Urdu",
        "bn": "Bengali",
        "ta": "Tamil",
        "te": "Telugu",
        "ml": "Malayalam",
        "kn": "Kannada",
        "mr": "Marathi",
        "gu": "Gujarati",
        "pa": "Punjabi",
        "ms": "Malay",
        "tl": "Filipino",
        "sw": "Swahili",
        "am": "Amharic",
        "my": "Myanmar",
        "km": "Khmer",
        "lo": "Lao",
        "si": "Sinhala",
        "ne": "Nepali",
        "mn": "Mongolian",
        "kk": "Kazakh",
        "az": "Azerbaijani",
        "ka": "Georgian",
        "sq": "Albanian",
        "mk": "Macedonian",
        "bs": "Bosnian",
        "sr": "Serbian",
        "cy": "Welsh"
    ]
    
    static var sortedLanguages: [(code: String, name: String)] {
        return all.sorted { language1, language2 in
            // Auto-detect always comes first
            if language1.key == "auto" { return true }
            if language2.key == "auto" { return false }
            // Then sort alphabetically by display name
            return language1.value < language2.value
        }.map { (code: $0.key, name: $0.value) }
    }
    
    static func displayName(for languageCode: String) -> String {
        return all[languageCode] ?? languageCode.uppercased()
    }
    
    static func isValidLanguage(_ code: String) -> Bool {
        // Soniox does NOT accept zh-Hant as a hint; treat it as invalid for hint validation
        let lower = code.lowercased()
        if lower == "zh-hant" { return false }
        return all.keys.contains(code)
    }

    /// Returns comma-separated language hints from user selection, normalized
    static func defaultHintsJoined() -> String {
        // Pull multi-select from defaults, fallback to single
        if let data = UserDefaults.standard.data(forKey: "SelectedLanguages"),
           let set = try? JSONDecoder().decode(Set<String>.self, from: data) {
            // Keep only valid languages (except 'auto') and ensure 'en' is first if present
            var filtered: [String] = Array(set.filter { isValidLanguage($0) && $0.lowercased() != "auto" })
            if let enIndex = filtered.firstIndex(where: { $0.lowercased() == "en" }) {
                filtered.remove(at: enIndex)
                filtered.insert("en", at: 0)
            }
            return filtered.joined(separator: ",")
        }
        let single = UserDefaults.standard.string(forKey: "SelectedLanguage") ?? "en"
        if single.lowercased() == "auto" { return "en" }
        return isValidLanguage(single) ? single : "en"
    }
}