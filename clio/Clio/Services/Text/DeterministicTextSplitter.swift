import Foundation
import NaturalLanguage

struct TextSplitOptions {
    var targetWordCountPerParagraph: Int = 50
    var maxSignificantSentencesPerParagraph: Int = 4
    var minWordsForSignificantSentence: Int = 4
    var languageOverride: String? = nil
}

enum DeterministicTextSplitter {
    static func split(_ text: String, options: TextSplitOptions = TextSplitOptions()) -> [String] {
        let normalized = text
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\t", with: " ")
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { return [] }

        // Language detection or override
        let language: NLLanguage = {
            if let override = options.languageOverride { return NLLanguage(rawValue: override) }
            return NLLanguageRecognizer.dominantLanguage(for: normalized) ?? .english
        }()

        // Sentence segmentation via NLTokenizer
        let sentenceTokenizer = NLTokenizer(unit: .sentence)
        sentenceTokenizer.string = normalized
        sentenceTokenizer.setLanguage(language)

        var sentences: [String] = []
        sentenceTokenizer.enumerateTokens(in: normalized.startIndex..<normalized.endIndex) { range, _ in
            let s = String(normalized[range]).trimmingCharacters(in: .whitespacesAndNewlines)
            if !s.isEmpty { sentences.append(s) }
            return true
        }
        guard !sentences.isEmpty else { return [] }

        var results: [String] = []
        var index = 0
        while index < sentences.count {
            var group: [String] = []
            var currentWordCount = 0
            var significantCount = 0

            while index < sentences.count, currentWordCount < options.targetWordCountPerParagraph {
                let s = sentences[index]
                let w = countWords(in: s, language: language)
                group.append(s)
                currentWordCount += w
                if w >= options.minWordsForSignificantSentence { significantCount += 1 }
                index += 1
            }

            // Never drop content. If we exceed the maxSignificantSentencesPerParagraph,
            // split the current group into multiple paragraphs, each honoring the limit.
            if significantCount > options.maxSignificantSentencesPerParagraph {
                var currentParagraph: [String] = []
                var currentSignificant = 0
                for s in group {
                    let isSignificant = countWords(in: s, language: language) >= options.minWordsForSignificantSentence
                    if isSignificant && currentSignificant >= options.maxSignificantSentencesPerParagraph {
                        // Flush the paragraph and start a new one
                        if !currentParagraph.isEmpty {
                            results.append(currentParagraph.joined(separator: " "))
                            currentParagraph.removeAll(keepingCapacity: true)
                            currentSignificant = 0
                        }
                    }
                    currentParagraph.append(s)
                    if isSignificant { currentSignificant += 1 }
                }
                if !currentParagraph.isEmpty {
                    results.append(currentParagraph.joined(separator: " "))
                }
            } else {
                results.append(group.joined(separator: " "))
            }
        }

        return results.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    }

    private static func countWords(in sentence: String, language: NLLanguage) -> Int {
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = sentence
        tokenizer.setLanguage(language)
        var count = 0
        tokenizer.enumerateTokens(in: sentence.startIndex..<sentence.endIndex) { _, _ in
            count += 1
            return true
        }
        return count
    }
}



