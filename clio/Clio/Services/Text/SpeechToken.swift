import Foundation

/// Lightweight token representation for text cleaning and analysis.
/// - For text-only mode, `startMs`/`endMs` may be nil.
/// - Punctuation is detected via `DisfluencyCleaner` punctuation set or simple fallback check.
public struct SpeechToken: Equatable {
    public let text: String
    public let startMs: Int?
    public let endMs: Int?
    public let language: String?

    public init(text: String, startMs: Int? = nil, endMs: Int? = nil, language: String? = nil) {
        self.text = text
        self.startMs = startMs
        self.endMs = endMs
        self.language = language
    }
}








