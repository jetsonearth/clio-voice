import Foundation

/// Utility for post-processing raw ASR transcripts by removing filler words and collapsing simple false-starts (repeated short phrases).
struct TextCleaner {
    /// Removes filler words ("uh", "um", "you know", etc.) and repeated short phrases in the provided text.
    /// - Parameter input: Raw transcript.
    /// - Returns: Cleaned transcript.
    static func clean(_ input: String) -> String {
        var text = input

        // 1. Strip common English filler words / phrases.
        let fillerWords = [
            "uh", "uhh", "um", "umm", "you know", "like", "i mean", "so", "you see",
            "kind of", "sort of", "right", "actually", "basically", "well"
        ]
        for phrase in fillerWords {
            let pattern = "\\b" + NSRegularExpression.escapedPattern(for: phrase) + "\\b[,\\s]*"
            text = text.replacingOccurrences(
                of: pattern,
                with: "",
                options: [.regularExpression, .caseInsensitive]
            )
        }

        // 2. Collapse immediate repetitions of 1–3-word phrases (simple false-starts like "when I, when I").
        //    This regex captures a phrase of up to 3 words and removes subsequent immediate repeats.
        let repetitionPattern = "\\b(\\w+(?:\\s+\\w+){0,2})(?:,?\\s+\\1)+\\b"
        text = text.replacingOccurrences(
            of: repetitionPattern,
            with: "$1",
            options: [.regularExpression, .caseInsensitive]
        )

        // 3. Squash multiple spaces produced by removals.
        text = text.replacingOccurrences(
            of: "\\s{2,}",
            with: " ",
            options: .regularExpression
        )

        // 4. Trim spaces before punctuation (", . ? !").
        text = text.replacingOccurrences(
            of: "\\s+([.,?!])",
            with: "$1",
            options: .regularExpression
        )

        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
} 