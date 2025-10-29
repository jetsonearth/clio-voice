import Foundation

/// Data-driven filler catalog enabling locale-specific disfluency rules.
/// The catalog loads definitions from `FillerCatalog.json` (with sensible fallbacks)
/// so filler lists can be expanded without touching the cleaner logic.
public final class FillerCatalog {
    public static let shared = FillerCatalog()

    public struct LocaleRuleSet {
        public let locale: String
        public let caseInsensitive: Bool
        public let singles: [SingleRule]
        public let phrases: [PhraseRule]
    }

    public struct SingleRule {
        public let text: String
        public let normalized: String
        public let dropMode: DropMode
        public let sentenceCase: Bool
        public let tidyFallback: Bool
    }

    public struct PhraseRule {
        public let tokens: [String]
        public let normalizedTokens: [String]
        public let sentenceCase: Bool
    }

    public enum DropMode: String, Decodable {
        case boundary
        case bounded
        case sentenceStart
    }

    private(set) var locales: [String: LocaleRuleSet] = [:]

    private init() {
        let definition = Self.loadDefinition()
        locales = Self.buildLocales(from: definition)
    }

    func localeRules(_ id: String) -> LocaleRuleSet? {
        locales[id]
    }

    func singleRules(locales ids: [String]) -> [SingleRule] {
        ids.compactMap { localeRules($0) }.flatMap { $0.singles }
    }

    func phraseRules(locales ids: [String]) -> [PhraseRule] {
        ids.compactMap { localeRules($0) }.flatMap { $0.phrases }
    }

    func tidyTokens(for locale: String) -> [String] {
        localeRules(locale)?.singles.filter { $0.tidyFallback }.map { $0.text } ?? []
    }

    func sentenceCaseSingles(for locale: String) -> [SingleRule] {
        localeRules(locale)?.singles.filter { $0.sentenceCase } ?? []
    }

    func sentenceCasePhrases(for locale: String) -> [PhraseRule] {
        localeRules(locale)?.phrases.filter { $0.sentenceCase } ?? []
    }

    // MARK: - Loading

    private struct Definition: Decodable {
        let locales: [LocaleDefinition]
    }

    private struct LocaleDefinition: Decodable {
        let id: String
        let caseInsensitive: Bool?
        let singles: [SingleDefinition]
        let phrases: [PhraseDefinition]?
    }

    private struct SingleDefinition: Decodable {
        let text: String
        let dropMode: DropMode?
        let sentenceCase: Bool?
        let tidy: Bool?
    }

    private struct PhraseDefinition: Decodable {
        let tokens: [String]
        let sentenceCase: Bool?
    }

    private static func loadDefinition() -> Definition {
        let decoder = JSONDecoder()
        if let data = loadCatalogData(), let definition = try? decoder.decode(Definition.self, from: data) {
            return definition
        }
        let fallbackData = Data(Self.fallbackJSON.utf8)
        return (try? decoder.decode(Definition.self, from: fallbackData)) ?? Definition(locales: [])
    }

    private static func loadCatalogData() -> Data? {
        let bundles: [Bundle] = [Bundle.main, BundleToken.bundle]
        for bundle in bundles {
            if let url = bundle.url(forResource: "FillerCatalog", withExtension: "json"),
               let data = try? Data(contentsOf: url) {
                return data
            }
        }
        return nil
    }

    private static func buildLocales(from definition: Definition) -> [String: LocaleRuleSet] {
        var result: [String: LocaleRuleSet] = [:]
        for locale in definition.locales {
            let caseInsensitive = locale.caseInsensitive ?? false
            let singles = locale.singles.map { definition -> SingleRule in
                let normalized = caseInsensitive ? definition.text.lowercased() : definition.text
                return SingleRule(
                    text: definition.text,
                    normalized: normalized,
                    dropMode: definition.dropMode ?? .boundary,
                    sentenceCase: definition.sentenceCase ?? true,
                    tidyFallback: definition.tidy ?? false
                )
            }
            let phrases = (locale.phrases ?? []).map { phrase -> PhraseRule in
                let normalizedTokens = caseInsensitive ? phrase.tokens.map { $0.lowercased() } : phrase.tokens
                return PhraseRule(tokens: phrase.tokens,
                                   normalizedTokens: normalizedTokens,
                                   sentenceCase: phrase.sentenceCase ?? true)
            }
            result[locale.id] = LocaleRuleSet(locale: locale.id,
                                              caseInsensitive: caseInsensitive,
                                              singles: singles,
                                              phrases: phrases)
        }
        return result
    }

    private static let fallbackJSON: String = {
        return """
        {
          "locales": [
            {
              "id": "en",
              "caseInsensitive": true,
              "singles": [
                { "text": "um", "tidy": true },
                { "text": "uh", "tidy": true },
                { "text": "umm", "tidy": true },
                { "text": "uhh", "tidy": true },
                { "text": "erm", "tidy": true },
                { "text": "er", "tidy": true },
                { "text": "hmm", "tidy": true },
                { "text": "mm", "tidy": true },
                { "text": "well" },
                { "text": "so" },
                { "text": "like", "dropMode": "bounded" },
                { "text": "okay" },
                { "text": "ok" },
                { "text": "basically" },
                { "text": "literally" }
              ],
              "phrases": [
                { "tokens": ["you", "know"] },
                { "tokens": ["i", "mean"] },
                { "tokens": ["kind", "of"] },
                { "tokens": ["sort", "of"] }
              ]
            },
            {
              "id": "zh",
              "caseInsensitive": false,
              "singles": [
                { "text": "嗯", "tidy": true, "sentenceCase": false },
                { "text": "呃", "tidy": true, "sentenceCase": false },
                { "text": "额", "tidy": true, "sentenceCase": false },
                { "text": "啊", "tidy": true, "sentenceCase": false },
                { "text": "那个", "sentenceCase": false },
                { "text": "这个", "sentenceCase": false },
                { "text": "那個", "sentenceCase": false },
                { "text": "這個", "sentenceCase": false },
                { "text": "就是", "sentenceCase": false },
                { "text": "然后", "dropMode": "sentenceStart", "sentenceCase": false },
                { "text": "嘛", "sentenceCase": false }
              ]
            },
            {
              "id": "es",
              "caseInsensitive": true,
              "singles": [
                { "text": "eh", "tidy": true },
                { "text": "em", "tidy": true },
                { "text": "mmm", "tidy": true },
                { "text": "este", "dropMode": "sentenceStart" }
              ],
              "phrases": [
                { "tokens": ["o", "sea"] }
              ]
            },
            {
              "id": "fr",
              "caseInsensitive": true,
              "singles": [
                { "text": "euh", "tidy": true },
                { "text": "heu", "tidy": true }
              ]
            },
            {
              "id": "de",
              "caseInsensitive": true,
              "singles": [
                { "text": "äh", "tidy": true },
                { "text": "ähm", "tidy": true },
                { "text": "hm", "tidy": true, "dropMode": "bounded" }
              ]
            },
            {
              "id": "ja",
              "caseInsensitive": false,
              "singles": [
                { "text": "えっと", "tidy": true, "sentenceCase": false },
                { "text": "ええと", "tidy": true, "sentenceCase": false },
                { "text": "うーん", "tidy": true, "sentenceCase": false },
                { "text": "んー", "tidy": true, "sentenceCase": false }
              ]
            },
            {
              "id": "ko",
              "caseInsensitive": false,
              "singles": [
                { "text": "음", "tidy": true, "sentenceCase": false },
                { "text": "음...", "tidy": true, "sentenceCase": false },
                { "text": "음..", "tidy": true, "sentenceCase": false }
              ]
            }
          ]
        }
        """
    }()
}

private final class BundleToken {}

private extension BundleToken {
    static var bundle: Bundle {
        Bundle(for: BundleToken.self)
    }
}
