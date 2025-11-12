import Foundation

/// Lightweight wrapper that applies `DisfluencyCleaner` to plain text output from ASR engines.
/// This is optimized for small transcripts where we do not have token timestamps.
enum RawDisfluencySanitizer {
    private static let cleaner = DisfluencyCleaner()
    private static let catalog = FillerCatalog.shared
    private static let apostrophes: Set<Character> = ["'", "’"]
    private static let hyphenFamily: Set<Character> = ["-", "—", "–"]
    private static let punctuationCharacters: Set<Character> = {
        var chars: Set<Character> = [
            ",", ".", "?", "!", ":", ";", "…", "，", "。", "？", "！", "、", "；", "：",
            "(", ")", "[", "]", "{", "}", "\"", "“", "”", "‘", "’", "《", "》", "〈", "〉",
            "「", "」", "『", "』", "~", "•"
        ]
        chars.formUnion(hyphenFamily)
        return chars
    }()
    private struct SentenceCaseRule {
        let singles: Set<String>
        let phrases: [[String]]
        let caseInsensitive: Bool
    }
    private static let sentenceCaseRules: [SentenceCaseRule] = {
        catalog.locales.values.compactMap { locale in
            let singles = locale.singles.filter { $0.sentenceCase }.map { locale.caseInsensitive ? $0.normalized : $0.text }
            let phrases = locale.phrases.filter { $0.sentenceCase }.map { locale.caseInsensitive ? $0.normalizedTokens : $0.tokens }
            if singles.isEmpty && phrases.isEmpty { return nil }
            return SentenceCaseRule(singles: Set(singles), phrases: phrases, caseInsensitive: locale.caseInsensitive)
        }
    }()
    private static let tidyPatterns: [String] = {
        catalog.locales.values.compactMap { locale -> String? in
            guard let core = buildTidyPattern(for: locale) else { return nil }
            return "(^|[\\s,.;:—–-…，。？！、；：])" + core + "(?:[-—–]{1,2})?(?=[\\s,.;:—–-…，。？！、；：]|$)"
        }
    }()
    private static let sentenceTerminators: Set<String> = [".", "?", "!", "。", "？", "！"]
    private static let sentenceTerminatorCharacters: Set<Character> = [".", "?", "!", "。", "？", "！"]
    private static let sentencePrefixSkippables: Set<String> = [
        "\"", "'", "“", "”", "‘", "’", "(", ")", "[", "]", "{", "}", "《", "》", "〈", "〉", "-", "—", "–", ","
    ]

    static func clean(_ input: String) -> String {
        guard !input.isEmpty else { return input }

        let normalized = input.replacingOccurrences(of: "\r\n", with: "\n")
        let segments = normalized.split(separator: "\n", omittingEmptySubsequences: false)
        let cleanedSegments = segments.map { segment -> String in
            let line = String(segment)
            guard !line.isEmpty else { return "" }
            let tokens = tokenize(line)
            guard !tokens.isEmpty else { return "" }

            var cfg = CleanerConfig()
            cfg.mode = .textOnly
            cfg.dropLeadingSoftPunctuation = false
            let cleaned = cleaner.clean(tokens, cfg: cfg)
            let tidied = tidy(cleaned)
            if containsSentenceBoundaryFiller(tokens) {
                return applySentenceCase(original: line, cleaned: tidied)
            } else {
                return restoreOriginalLeadingCaseIfNeeded(original: line, cleaned: tidied)
            }
        }
        return cleanedSegments.joined(separator: "\n")
    }

    private static func tokenize(_ input: String) -> [SpeechToken] {
        if input.isEmpty { return [] }
        let characters = Array(input)
        var tokens: [SpeechToken] = []
        var buffer = ""
        var bufferKind: SegmentKind?

        var index = 0
        while index < characters.count {
            let ch = characters[index]
            if ch.isWhitespace {
                flushBuffer(&buffer, kind: &bufferKind, into: &tokens)
                index += 1
                continue
            }

            if punctuationCharacters.contains(ch) {
                flushBuffer(&buffer, kind: &bufferKind, into: &tokens)
                if hyphenFamily.contains(ch) {
                    let (segment, nextIndex) = readWhile(characters, from: index) { hyphenFamily.contains($0) }
                    tokens.append(SpeechToken(text: segment))
                    index = nextIndex
                } else if ch == "…" {
                    let (segment, nextIndex) = readWhile(characters, from: index) { $0 == "…" || $0 == "." }
                    tokens.append(SpeechToken(text: segment))
                    index = nextIndex
                } else {
                    tokens.append(SpeechToken(text: String(ch)))
                    index += 1
                }
                continue
            }

            if isCJK(ch) {
                if bufferKind == .cjk {
                    buffer.append(ch)
                } else {
                    flushBuffer(&buffer, kind: &bufferKind, into: &tokens)
                    buffer = String(ch)
                    bufferKind = .cjk
                }
                index += 1
                continue
            }

            if ch.isLetter || ch.isNumber || apostrophes.contains(ch) {
                if bufferKind == .latin {
                    buffer.append(ch)
                } else {
                    flushBuffer(&buffer, kind: &bufferKind, into: &tokens)
                    buffer = String(ch)
                    bufferKind = .latin
                }
                index += 1
                continue
            }

            flushBuffer(&buffer, kind: &bufferKind, into: &tokens)
            tokens.append(SpeechToken(text: String(ch)))
            index += 1
        }

        flushBuffer(&buffer, kind: &bufferKind, into: &tokens)
        return tokens
    }

    private static func tidy(_ text: String) -> String {
        guard !text.isEmpty else { return text }
        var result = text
        for pattern in tidyPatterns {
            result = result.replacingOccurrences(of: pattern, with: "$1", options: .regularExpression)
        }
        result = result.replacingOccurrences(of: "\\s{2,}", with: " ", options: .regularExpression)
        result = result.replacingOccurrences(of: " ([,.;:?!])", with: "$1", options: .regularExpression)
        result = result.replacingOccurrences(of: " ([，。？！、；：])", with: "$1", options: .regularExpression)
        result = result.replacingOccurrences(of: "([，。？！、；：])\\s+(?=[\\p{Han}])", with: "$1", options: .regularExpression)
        result = result.replacingOccurrences(of: "([，。？！、；：])\\s+(?=[\\p{Latin}])", with: "$1", options: .regularExpression)
        result = removeDanglingDashes(result)
        result = result.replacingOccurrences(of: "(,|，){2,}", with: "$1", options: .regularExpression)
        result = result.replacingOccurrences(of: "([?!]){2,}", with: "$1", options: .regularExpression)
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func applySentenceCase(original: String, cleaned: String) -> String {
        guard !cleaned.isEmpty else { return cleaned }

        var characters = Array(cleaned)
        var shouldCapitalize = true
        let softPrefixCharacters: Set<Character> = ["\"", "'", "“", "”", "‘", "’", "(", "[", "{", "〈", "《"]

        for index in characters.indices {
            let ch = characters[index]
            if shouldCapitalize {
                if ch.isLetter {
                    if ch.isLowercase {
                        characters[index] = Character(String(ch).uppercased())
                    }
                    shouldCapitalize = false
                } else if ch.isNumber {
                    shouldCapitalize = false
                } else if ch.isWhitespace || softPrefixCharacters.contains(ch) {
                    // keep looking for the first letter to capitalize
                } else {
                    shouldCapitalize = false
                }
            } else if sentenceTerminatorCharacters.contains(ch) || ch.isNewline {
                shouldCapitalize = true
            }
        }

        var result = String(characters)
        result = result.trimmingCharacters(in: .whitespacesAndNewlines)

        // If the original line intentionally began with lowercase, restore it.
        let trimmedOriginal = original.trimmingCharacters(in: .whitespacesAndNewlines)
        if let originalFirst = trimmedOriginal.first, originalFirst.isLetter, originalFirst.isLowercase,
           let letterIndex = result.firstIndex(where: { $0.isLetter }) {
            let lowerReplacement = String(result[letterIndex]).lowercased()
            result.replaceSubrange(letterIndex...letterIndex, with: lowerReplacement)
        }

        return result
    }

    private static func restoreOriginalLeadingCaseIfNeeded(original: String, cleaned: String) -> String {
        guard !cleaned.isEmpty else { return cleaned }
        let trimmedOriginal = original.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let originalFirst = trimmedOriginal.first else { return cleaned }
        guard let letterIndex = cleaned.firstIndex(where: { $0.isLetter }) else { return cleaned }

        var result = cleaned
        result = result.trimmingCharacters(in: .whitespacesAndNewlines)

        if originalFirst.isLowercase, let idx = result.firstIndex(where: { $0.isLetter }) {
            let lowerReplacement = String(result[idx]).lowercased()
            result.replaceSubrange(idx...idx, with: lowerReplacement)
        }
        return result
    }

    private static func removeDanglingDashes(_ text: String) -> String {
        var s = text
        let nbsp = "\u{00A0}"
        s = s.replacingOccurrences(of: "(^|[\\s,.，。？！、；：])[-—–]{1,2}(?=[\\s,.，。？！、；：])", with: "$1", options: .regularExpression)
        s = s.replacingOccurrences(of: "(^|[\\s,.，。？！、；：])[-—–]{1,2}(?=[A-Za-z0-9\\p{Han}])", with: "$1", options: .regularExpression)
        let trailingDashPattern = "^[—–-]{1,2}(?=[" + nbsp + "\\s]|$)"
        s = s.replacingOccurrences(of: trailingDashPattern, with: "", options: .regularExpression)
        s = s.replacingOccurrences(of: "^[—–-]{1,2}(?=\\w)", with: "", options: .regularExpression)
        return s
    }

    private static func containsSentenceBoundaryFiller(_ tokens: [SpeechToken]) -> Bool {
        guard !sentenceCaseRules.isEmpty else { return false }
        var index = 0
        var atSentenceStart = true
        while index < tokens.count {
            let raw = tokens[index].text
            let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty {
                index += 1
                continue
            }

            if sentenceTerminators.contains(trimmed) || trimmed == "\n" {
                atSentenceStart = true
                index += 1
                continue
            }

            if isSkippablePrefixToken(trimmed) {
                index += 1
                continue
            }

            if atSentenceStart {
                for rule in sentenceCaseRules {
                    let normalized = rule.caseInsensitive ? trimmed.lowercased() : trimmed
                    if rule.singles.contains(normalized) { return true }
                    if matchesSentenceCasePhrase(tokens: tokens, start: index, rule: rule) { return true }
                }
                atSentenceStart = false
            } else {
                atSentenceStart = false
            }

            index += 1
        }
        return false
    }

    private static func matchesSentenceCasePhrase(tokens: [SpeechToken], start: Int, rule: SentenceCaseRule) -> Bool {
        guard !rule.phrases.isEmpty else { return false }
        for phrase in rule.phrases {
            if start + phrase.count > tokens.count { continue }
            var matched = true
            for offset in 0..<phrase.count {
                let tokenText = tokens[start + offset].text
                let comparison = rule.caseInsensitive ? tokenText.lowercased() : tokenText
                if comparison != phrase[offset] {
                    matched = false
                    break
                }
            }
            if matched { return true }
        }
        return false
    }

    private static func isSkippablePrefixToken(_ text: String) -> Bool {
        if sentencePrefixSkippables.contains(text) { return true }
        if text.allSatisfy({ hyphenFamily.contains($0) }) { return true }
        return false
    }

    private static func buildTidyPattern(for locale: FillerCatalog.LocaleRuleSet) -> String? {
        let tokens = locale.singles.filter { $0.tidyFallback }
        guard !tokens.isEmpty else { return nil }
        let escaped = tokens.map { token -> String in
            let value = locale.caseInsensitive ? token.normalized : token.text
            return NSRegularExpression.escapedPattern(for: value)
        }
        let union = escaped.joined(separator: "|")
        guard !union.isEmpty else { return nil }
        if locale.caseInsensitive {
            return "(?i:(?:" + union + "))"
        } else {
            return "(?:" + union + ")"
        }
    }

    private static func flushBuffer(_ buffer: inout String, kind: inout SegmentKind?, into tokens: inout [SpeechToken]) {
        guard !buffer.isEmpty else { return }
        tokens.append(SpeechToken(text: buffer))
        buffer.removeAll(keepingCapacity: true)
        kind = nil
    }

    private static func readWhile(_ characters: [Character], from index: Int, predicate: (Character) -> Bool) -> (String, Int) {
        var i = index
        var buffer = ""
        while i < characters.count, predicate(characters[i]) {
            buffer.append(characters[i])
            i += 1
        }
        return (buffer, i)
    }

    private static func isCJK(_ char: Character) -> Bool {
        guard let scalar = char.unicodeScalars.first else { return false }
        let value = scalar.value
        return (0x04E00...0x09FFF).contains(value) ||
               (0x03400...0x04DBF).contains(value) ||
               (0x20000...0x2A6DF).contains(value) ||
               (0x2A700...0x2B73F).contains(value) ||
               (0x2B740...0x2B81F).contains(value) ||
               (0x2B820...0x2CEAF).contains(value) ||
               (0x0F900...0x0FAFF).contains(value) ||
               (0x2F800...0x2FA1F).contains(value)
    }

    private enum SegmentKind {
        case latin
        case cjk
    }
}
