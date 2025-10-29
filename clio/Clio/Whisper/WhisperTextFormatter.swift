import Foundation
import NaturalLanguage

struct WhisperTextFormatter {
    static func format(_ text: String) -> String {
        // 1) Deterministic sentence→paragraph split using NL
        let options = TextSplitOptions(
            targetWordCountPerParagraph: 30,
            maxSignificantSentencesPerParagraph: 4,
            minWordsForSignificantSentence: 3,
            languageOverride: nil
        )
        let paragraphs = DeterministicTextSplitter.split(text, options: options)
        let splitText = paragraphs.joined(separator: "\n\n")

        // 2) Post-enhancement formatting: normalize numbers/units on Simplified first, then convert to Traditional if needed
        let formatted = PostEnhancementFormatter.apply(splitText)
        return formatted.trimmingCharacters(in: .whitespacesAndNewlines)
    }
} 
