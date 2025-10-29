import Foundation

public final class DisfluencyCleaner {
    // Hard punctuation set; used as strong boundaries (includes CJK)
    private let hardPunct: Set<String> = [",", ".", "?", "!", "—", "-", "…", ":", ";", "，", "。", "？", "！", "、", "；", "："]
    private let softPunct: Set<String> = [",", "—", "-", ":", ";", "，", "、", "：", "；"]
    private let hyphenScalars: Set<Character> = ["-", "—", "–"]

    private struct SingleIndex {
        let caseInsensitive: Bool
        let rules: [String: FillerCatalog.SingleRule]
    }

    private struct PhraseIndex {
        let caseInsensitive: Bool
        let rules: [FillerCatalog.PhraseRule]
    }

    private let textSingleIndices: [SingleIndex]
    private let cjkSingleIndices: [SingleIndex]
    private let textPhraseIndices: [PhraseIndex]
    private let cjkPhraseIndices: [PhraseIndex]

    public init(catalog: FillerCatalog = .shared) {
        var textSingles: [SingleIndex] = []
        var cjkSingles: [SingleIndex] = []
        var textPhrases: [PhraseIndex] = []
        var cjkPhrases: [PhraseIndex] = []

        for locale in catalog.locales.values {
            let singleRules = locale.singles.reduce(into: [String: FillerCatalog.SingleRule]()) { dict, rule in
                let key = locale.caseInsensitive ? rule.normalized : rule.text
                dict[key] = rule
            }
            if !singleRules.isEmpty {
                let index = SingleIndex(caseInsensitive: locale.caseInsensitive, rules: singleRules)
                if locale.caseInsensitive {
                    textSingles.append(index)
                } else {
                    cjkSingles.append(index)
                }
            }

            if !locale.phrases.isEmpty {
                let index = PhraseIndex(caseInsensitive: locale.caseInsensitive, rules: locale.phrases)
                if locale.caseInsensitive {
                    textPhrases.append(index)
                } else {
                    cjkPhrases.append(index)
                }
            }
        }

        self.textSingleIndices = textSingles
        self.cjkSingleIndices = cjkSingles
        self.textPhraseIndices = textPhrases
        self.cjkPhraseIndices = cjkPhrases
    }

    // MARK: Public API

    /// Clean a sequence of tokens, preserving non-filler content and punctuation.
    /// - Parameters:
    ///   - tokens: input tokens (final tokens preferred)
    ///   - cfg: cleaner configuration controlling thresholds and mode
    /// - Returns: cleaned text joined with sensible spacing around punctuation
    public func clean(_ tokens: [SpeechToken], cfg: CleanerConfig = CleanerConfig()) -> String {
        guard !tokens.isEmpty else { return "" }

        let useTimestamps: Bool = {
            switch cfg.mode {
            case .auto: return tokens.contains { $0.startMs != nil && $0.endMs != nil }
            case .textOnly: return false
            case .timestamps: return tokens.contains { $0.startMs != nil && $0.endMs != nil }
            }
        }()

        let gapMs = useTimestamps ? adaptiveGapMs(tokens: tokens, cfg: cfg) : nil

        var output: [SpeechToken] = []
        var i = 0
        let dropLeadingSoftPunct = cfg.dropLeadingSoftPunctuation
        let dropTrailingSoftPunct = cfg.dropTrailingSoftPunctuation
        while i < tokens.count {
            // Stutter collapse (exact token repetition within window)
            if i > 0,
               tokens[i].text == tokens[i-1].text,
               within(tokens, i-1, i, <=, cfg.stutterWindowMs) {
                i += 1
                continue
            }

            // Phrase-level matches (multi-token fillers)
            if cfg.enableEnRules, let span = matchPhrase(tokens, i, indices: textPhraseIndices) {
                if shouldDropSpan(tokens, span, gapMs: gapMs, cfg: cfg) {
                    if dropLeadingSoftPunct, let last = output.last, isSoftPunct(last.text) { _ = output.popLast() }
                    let right = span.upperBound
                    if dropTrailingSoftPunct, right < tokens.count, isSoftPunct(tokens[right].text) {
                        i = right + 1
                    } else {
                        i = span.upperBound
                    }
                    continue
                }
            }

            if cfg.enableZhRules, let span = matchPhrase(tokens, i, indices: cjkPhraseIndices) {
                if shouldDropSpan(tokens, span, gapMs: gapMs, cfg: cfg) {
                    if dropLeadingSoftPunct, let last = output.last, isSoftPunct(last.text) { _ = output.popLast() }
                    let right = span.upperBound
                    if dropTrailingSoftPunct, right < tokens.count, isSoftPunct(tokens[right].text) {
                        i = right + 1
                    } else {
                        i = span.upperBound
                    }
                    continue
                }
            }

            // Single-token check
            if shouldDropSingle(tokens, i, gapMs: gapMs, cfg: cfg) {
                if dropLeadingSoftPunct, let last = output.last, isSoftPunct(last.text) { _ = output.popLast() }
                if dropTrailingSoftPunct, i + 1 < tokens.count, isSoftPunct(tokens[i+1].text) {
                    i += 2
                } else {
                    i += 1
                }
                continue
            }

            output.append(tokens[i])
            i += 1
        }

        return joinPretty(output.map { $0.text })
    }

    // MARK: Internal helpers

    private func matchPhrase(_ toks: [SpeechToken], _ index: Int, indices: [PhraseIndex]) -> Range<Int>? {
        guard !indices.isEmpty else { return nil }
        for entry in indices {
            for rule in entry.rules {
                if index + rule.tokens.count > toks.count { continue }
                var matches = true
                for offset in 0..<rule.tokens.count {
                    let tokenText = toks[index + offset].text
                    let comparison = entry.caseInsensitive ? tokenText.lowercased() : tokenText
                    let expected = entry.caseInsensitive ? rule.normalizedTokens[offset] : rule.tokens[offset]
                    if comparison != expected {
                        matches = false
                        break
                    }
                }
                if matches { return index..<(index + rule.tokens.count) }
            }
        }
        return nil
    }

    private func shouldDropSpan(_ toks: [SpeechToken], _ span: Range<Int>, gapMs: Int?, cfg: CleanerConfig) -> Bool {
        let left = span.lowerBound - 1
        let right = span.upperBound
        let leftBoundary = (left < 0) ||
            isPunct(toks, left) ||
            (gapMs != nil && pauseBetween(toks, left, span.lowerBound) >= gapMs!)
        let rightBoundary = (right >= toks.count) ||
            isPunct(toks, right) ||
            (gapMs != nil && pauseBetween(toks, span.upperBound - 1, right) >= gapMs!)
        // prefer comma/soft punct on at least one side for multi-word phrases
        let softBound = (left >= 0 && isSoftPunct(toks[left].text)) ||
                        (right < toks.count && isSoftPunct(toks[right].text))
        return leftBoundary && rightBoundary && softBound
    }

    private func shouldDropSingle(_ toks: [SpeechToken], _ i: Int, gapMs: Int?, cfg: CleanerConfig) -> Bool {
        if cfg.enableEnRules, let rule = lookupRule(text: toks[i].text, indices: textSingleIndices) {
            return evaluate(rule.dropMode, tokens: toks, index: i, gapMs: gapMs, cfg: cfg)
        }

        if cfg.enableZhRules, let rule = lookupRule(text: toks[i].text, indices: cjkSingleIndices) {
            return evaluate(rule.dropMode, tokens: toks, index: i, gapMs: gapMs, cfg: cfg)
        }
        return false
    }

    private func lookupRule(text: String, indices: [SingleIndex]) -> FillerCatalog.SingleRule? {
        for index in indices {
            let key = index.caseInsensitive ? text.lowercased() : text
            if let rule = index.rules[key] { return rule }
        }
        return nil
    }

    private func evaluate(_ mode: FillerCatalog.DropMode, tokens: [SpeechToken], index: Int, gapMs: Int?, cfg: CleanerConfig) -> Bool {
        switch mode {
        case .boundary:
            return startBounded(tokens, index, gapMs: gapMs) || bounded(tokens, index, gapMs: gapMs)
        case .bounded:
            return bounded(tokens, index, gapMs: gapMs)
        case .sentenceStart:
            return startBounded(tokens, index, gapMs: gapMs)
        }
    }

    // Boundary logic
    private func bounded(_ toks: [SpeechToken], _ i: Int, gapMs: Int?) -> Bool {
        leftBoundary(toks, i, gapMs: gapMs) && rightBoundary(toks, i, gapMs: gapMs)
    }
    private func startBounded(_ toks: [SpeechToken], _ i: Int, gapMs: Int?) -> Bool {
        isSentenceInitial(toks, i) && rightBoundary(toks, i, gapMs: gapMs)
    }
    private func isSentenceInitial(_ toks: [SpeechToken], _ i: Int) -> Bool {
        if i == 0 { return true }
        return isPunct(toks, i-1)
    }
    private func leftBoundary(_ toks: [SpeechToken], _ i: Int, gapMs: Int?) -> Bool {
        if i == 0 { return true }
        return isPunct(toks, i-1) || (gapMs != nil && pauseBetween(toks, i-1, i) >= gapMs!)
    }
    private func rightBoundary(_ toks: [SpeechToken], _ i: Int, gapMs: Int?) -> Bool {
        if i == toks.count - 1 { return true }
        return isPunct(toks, i+1) || (gapMs != nil && pauseBetween(toks, i, i+1) >= gapMs!)
    }

    private func within(_ toks: [SpeechToken], _ left: Int, _ right: Int, _ cmp: (Int, Int) -> Bool, _ ms: Int) -> Bool {
        guard left >= 0, right < toks.count,
              let le = toks[left].endMs, let rs = toks[right].startMs else { return false }
        return cmp(rs - le, ms)
    }

    private func pauseBetween(_ toks: [SpeechToken], _ left: Int, _ right: Int) -> Int {
        guard left >= 0, right < toks.count,
              let le = toks[left].endMs, let rs = toks[right].startMs else { return 0 }
        return rs - le
    }

    private func isPunct(_ toks: [SpeechToken], _ i: Int) -> Bool {
        guard i >= 0 && i < toks.count else { return false }
        return isHardPunct(toks[i].text)
    }
    private func isHardPunct(_ s: String) -> Bool {
        if hardPunct.contains(s) { return true }
        return !s.isEmpty && s.allSatisfy { hyphenScalars.contains($0) }
    }
    private func isSoftPunct(_ s: String) -> Bool {
        if softPunct.contains(s) { return true }
        return !s.isEmpty && s.allSatisfy { hyphenScalars.contains($0) }
    }

    private func joinPretty(_ words: [String]) -> String {
        var s = ""
        for w in words {
            if isHardPunct(w) {
                s.append(w)
            } else if s.isEmpty {
                s.append(w)
            } else {
                s.append(" "); s.append(w)
            }
        }
        // Normalize duplicated commas and misplaced spaces before punctuation
        while s.contains(",,") { s = s.replacingOccurrences(of: ",,", with: ",") }
        s = s.replacingOccurrences(of: " ,", with: ",")
        s = s.replacingOccurrences(of: ", .", with: ".")
        s = s.replacingOccurrences(of: ", !", with: "!")
        s = s.replacingOccurrences(of: ", ?", with: "?")
        s = s.replacingOccurrences(of: "，，", with: "，")
        s = s.replacingOccurrences(of: " ，", with: "，")
        if s.hasPrefix(",") { s.removeFirst() }
        if s.hasPrefix("，") { s.removeFirst() }
        return s.trimmingCharacters(in: .whitespaces)
    }

    // Adaptive pause based on speaking rate (tokens per second)
    private func adaptiveGapMs(tokens: [SpeechToken], cfg: CleanerConfig) -> Int {
        guard let first = tokens.first?.startMs, let last = tokens.last?.endMs, last > first else {
            return cfg.basePauseMs
        }
        let durSec = Double(last - first) / 1000.0
        if durSec <= 0 { return cfg.basePauseMs }
        let tps = Double(tokens.count) / durSec
        let proposed = Int(1000.0 / max(1.0, tps))
        return max(cfg.minPauseMs, min(cfg.maxPauseMs, proposed))
    }
}

