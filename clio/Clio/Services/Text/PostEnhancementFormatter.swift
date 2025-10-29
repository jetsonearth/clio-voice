import Foundation

enum PostEnhancementFormatter {
    // Feature flag to control deterministic paragraph splitting
    // Default off as requested
    static var isParagraphSplitEnabled: Bool = false

    static func apply(_ text: String) -> String {
        // If splitting is disabled, skip directly to normalization
        guard isParagraphSplitEnabled else {
            return normalize(text)
        }

        // Deterministic paragraph split
        let options = TextSplitOptions(
            targetWordCountPerParagraph: 50,
            maxSignificantSentencesPerParagraph: 4,
            minWordsForSignificantSentence: 3,
            languageOverride: nil
        )
        let paragraphs = DeterministicTextSplitter.split(text, options: options)
        let splitText = paragraphs.joined(separator: "\n\n")

        return normalize(splitText)
    }

    private static func normalize(_ text: String) -> String { 
        // Keep dash normalization + product-name fixes + Han conversion
        let dashNormalized = text.replacingOccurrences(of: "—-", with: "-")
            .replacingOccurrences(of: "——", with: "-")
            .replacingOccurrences(of: "plus\\s+(\\d+(?:\\.\\d+)?%?)", with: "+$1", options: [.regularExpression, .caseInsensitive])
            .replacingOccurrences(of: "minus\\s+(\\d+(?:\\.\\d+)?%?)", with: "-$1", options: [.regularExpression, .caseInsensitive])
        let fixed = dashNormalized
            .replacingOccurrences(of: "Cloud Code", with: "Claude Code", options: [.caseInsensitive])
            .replacingOccurrences(of: "cursor", with: "Cursor", options: [.caseInsensitive])
            .replacingOccurrences(of: "gbt", with: "GPT", options: [.caseInsensitive])
        // Temporarily disable numeric/unit normalization to avoid unintended changes
        // Pass through only product-name fixes and Chinese script conversion
        var converted = ChineseScriptConverter.convertIfNeeded(fixed)

        let patterns: [(String, String)] = [
            // Trailing spaces after Chinese punctuation when next is CJK/opening symbol
            ("([。！？；：、，）】》」』])\\s+(?=[\\p{Han}（【《「『“])", "$1"),
            // Spaces before opening CJK brackets/quotes
            ("\\s+([（【《「『“])", "$1")
        ]
        for (pattern, template) in patterns {
            if let re = try? NSRegularExpression(pattern: pattern) {
                let range = NSRange(location: 0, length: converted.utf16.count)
                converted = re.stringByReplacingMatches(in: converted, options: [], range: range, withTemplate: template)
            }
        }

        return converted.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
}
