import Foundation

// Minimal, non-derivative prompt holder used only to satisfy existing references.
// This implementation intentionally avoids custom/dictionary prompting and
// does not maintain user-editable prompts. If you need language-specific
// behavior later, route it through your fixed `AIPrompts` utilities instead.

extension Notification.Name {
    static let languageDidChange = Notification.Name("languageDidChange")
    static let promptDidChange = Notification.Name("promptDidChange")
}

@MainActor
final class WhisperPrompt: ObservableObject {
    @Published var transcriptionPrompt: String = ""

    // Fixed, language-specific base prompts that gently bias output style.
    // Not user-configurable by design.
    private let languagePrompts: [String: String] = [
        // English
        "en": "Hello, how are you doing? Nice to meet you.",

        // Asian Languages
        "hi": "नमस्ते, कैसे हैं आप? आपसे मिलकर अच्छा लगा।",
        "bn": "নমস্কার, কেমন আছেন? আপনার সাথে দেখা হয়ে ভালো লাগলো।",
        "ja": "こんにちは、お元気ですか？お会いできて嬉しいです。",
        "ko": "안녕하세요, 잘 지내시나요? 만나서 반갑습니다.",
        "zh": "你好，最近好吗？见到你很高兴。",
        "th": "สวัสดีครับ/ค่ะ, สบายดีไหม? ยินดีที่ได้พบคุณ",
        "vi": "Xin chào, bạn khỏe không? Rất vui được gặp bạn.",
        // Whisper’s code for Cantonese is "yue"
        "yue": "你好，最近點呀？見到你好開心。",

        // European Languages
        "es": "¡Hola, ¿cómo estás? Encantado de conocerte.",
        "fr": "Bonjour, comment allez-vous? Ravi de vous rencontrer.",
        "de": "Hallo, wie geht es dir? Schön dich kennenzulernen.",
        "it": "Ciao, come stai? Piacere di conoscerti.",
        "pt": "Olá, como você está? Prazer em conhecê-lo.",
        "ru": "Здравствуйте, как ваши дела? Приятно познакомиться.",
        "pl": "Cześć, jak się masz? Miło cię poznać.",
        "nl": "Hallo, hoe gaat het? Aangenaam kennis te maken.",
        "tr": "Merhaba, nasılsın? Tanıştığımıza memnun oldum.",

        // Middle Eastern Languages
        "ar": "مرحباً، كيف حالك؟ سعيد بلقائك.",
        "fa": "سلام، حال شما چطور است؟ از آشنایی با شما خوشوقتم.",
        "he": "שלום, מה שלומך? נעים להכיר",

        // South Asian Languages
        "ta": "வணக்கம், எப்படி இருக்கிறீர்கள்? உங்களை சந்தித்ததில் மகிழ்ச்சி.",
        "te": "నమస్తారం, ఎలా ఉన్నారు? కలవడం చాలా సంతోషం.",
        "ml": "നമസ്കാരം, സുഖമാണോ? കണ്ടതിൽ സന്തോഷം.",
        "kn": "ನಮಸ್ಕಾರ, ಹೇಗಿದ್ದೀರಾ? ನಿಮ್ಮನ್ನು ಭೇಟಿಯಾಗಿ ಸಂತೋಷವಾಗಿದೆ.",
        "ur": "السلام علیکم، کیسے ہیں آپ؟ آپ سے مل کر خوشی ہوئی۔",

        // Default fallback
        "default": ""
    ]

    init() {
        // Initialize from current language selection, if present.
        updateTranscriptionPrompt()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLanguageChange),
            name: .languageDidChange,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func handleLanguageChange() {
        updateTranscriptionPrompt()
    }

    // MARK: Public surface kept for compatibility

    func updateDictionaryWords(_ words: [String]) {
        // No-op by design. Dictionary-based prompting is not supported.
    }

    func updateTranscriptionPrompt() {
        // Choose a fixed per-language hint; do not expose as a setting.
        let sel = (UserDefaults.standard.string(forKey: "SelectedLanguage") ?? "en").lowercased()
        let key = normalizeForPrompt(sel)
        transcriptionPrompt = languagePrompts[key] ?? languagePrompts["default"]!
        UserDefaults.standard.set(transcriptionPrompt, forKey: "TranscriptionPrompt")
        NotificationCenter.default.post(name: .promptDidChange, object: nil)
    }

    func getLanguagePrompt(for language: String) -> String {
        let key = normalizeForPrompt(language.lowercased())
        return languagePrompts[key] ?? languagePrompts["default"]!
    }

    func setCustomPrompt(_ prompt: String, for language: String) {
        // No-op. Custom prompts are not supported in this build.
        updateTranscriptionPrompt()
        objectWillChange.send()
    }

    func saveDictionaryItems(_ items: [DictionaryItem]) async {
        // No-op. Persisting dictionary items for prompting is not supported.
    }
}

// MARK: - Helpers
private extension WhisperPrompt {
    // Map app codes to whisper language keys for prompting.
    func normalizeForPrompt(_ code: String) -> String {
        // Handle Chinese variants
        if code.hasPrefix("zh-hant") || code == "zh-hk" || code == "zh-mo" { return "zh" }
        if code == "zh-cn" || code.hasPrefix("zh-hans") || code == "zh" { return "zh" }
        // Our UI uses "zh-tw" for Cantonese; Whisper’s language code is "yue"
        if code == "zh-tw" { return "yue" }
        // Pass-through when known
        if languagePrompts[code] != nil { return code }
        return "default"
    }
}
