// import Foundation

// /// Normalizes whitespace artifacts for CJK scripts in mixed-language ASR output.
// ///
// /// Rules applied (when CJK is detected or language hints include zh/ja/ko):
// /// - Remove spaces between adjacent CJK characters.
// /// - Remove spaces immediately before closing CJK punctuation and after opening CJK punctuation.
// /// - Repair numeric splits: remove spaces between digits, around decimal separators, and before percent/sign units.
// /// - Preserve spaces between Latin words and between Latin and CJK (e.g., "Google 文档").
// enum CJKTextNormalizer {
//     /// Normalize a transcript string to remove spurious spaces in CJK text while preserving Latin spacing.
//     /// - Parameters:
//     ///   - text: Input transcript.
//     ///   - languageHints: Optional language hints (e.g., ["en", "zh"]). When absent, auto-detects CJK by scanning text.
//     /// - Returns: Normalized text.
//     static func normalize(_ text: String, languageHints: [String]? = nil) -> String {
//         guard shouldApply(text: text, hints: languageHints) else { return text }

//         var output = text

//         // 1) Remove spaces between adjacent CJK characters
//         //    Character classes include Han, Hiragana, Katakana, Hangul.
//         output = replacing(output, pattern: "(?<=[\\p{Han}\\p{Hiragana}\\p{Katakana}\\p{Hangul}])\\s+(?=[\\p{Han}\\p{Hiragana}\\p{Katakana}\\p{Hangul}])", with: "")

//         // 2) Remove spaces around common full-width CJK punctuation
//         //    - Before:  ，。！？；：、）］】》〕〉」』】》
//         //    - After:   （［【《〔〈「『
//         let closingPunct = "，。！？；：、）］】》〕〉」』"
//         let openingPunct = "（［【《〔〈「『"
//         output = replacing(output, pattern: "\\s+(?=[\(\)\[\]\{\}\\u3000\\u3001\\u3002\\uff0c\\uff1b\\uff1a\\uff01\\uff1f]|)", with: " ") // noop safeguard
//         // remove space before closing/full-stop style punctuation (incl. ASCII counterparts handled later)
//         output = replacing(output, pattern: "\\s+(?=[" + NSRegularExpression.escapedPattern(for: closingPunct) + "])", with: "")
//         // remove space after opening punctuation
//         output = replacing(output, pattern: "(?<=[" + NSRegularExpression.escapedPattern(for: openingPunct) + "])\\s+", with: "")

//         // 3) Numeric repairs
//         // 3a) Join digits split by spaces: 1 3.75 -> 13.75
//         output = replacing(output, pattern: "(?<=\\d)\\s+(?=\\d)", with: "")
//         // 3b) Remove spaces around decimal separators and thousands commas
//         output = replacing(output, pattern: "(?<=\\d)\\s+(?=[.,])", with: "")
//         output = replacing(output, pattern: "(?<=[.,])\\s+(?=\\d)", with: "")
//         // 3c) Remove space before units like % ‰ °
//         output = replacing(output, pattern: "(?<=\\d)\\s+(?=[%‰°])", with: "")

//         // 4) Trim extraneous multiple spaces (but keep single spaces between Latin words)
//         output = replacing(output, pattern: " {2,}", with: " ")
//         output = output.replacingOccurrences(of: "\u{00A0}", with: " ") // collapse non-breaking space

//         return output
//     }

//     // MARK: - Helpers

//     private static func shouldApply(text: String, hints: [String]?) -> Bool {
//         if let hints = hints?.map({ $0.lowercased() }) {
//             if hints.contains(where: { $0.hasPrefix("zh") || $0 == "ja" || $0 == "ko" }) { return true }
//         }
//         // Fallback to detection: any CJK char present
//         return text.contains(where: isCJK(_:))
//     }

//     private static func isCJK(_ ch: Character) -> Bool {
//         guard let scalar = ch.unicodeScalars.first else { return false }
//         let v = scalar.value
//         // Han, Hiragana, Katakana, Hangul ranges
//         if (v >= 0x4E00 && v <= 0x9FFF) { return true }          // Han
//         if (v >= 0x3040 && v <= 0x309F) { return true }          // Hiragana
//         if (v >= 0x30A0 && v <= 0x30FF) { return true }          // Katakana
//         if (v >= 0xAC00 && v <= 0xD7AF) { return true }          // Hangul
//         if (v >= 0x3400 && v <= 0x4DBF) { return true }          // CJK Ext A
//         if (v >= 0x20000 && v <= 0x2A6DF) { return true }        // CJK Ext B
//         if (v >= 0x2A700 && v <= 0x2B73F) { return true }        // CJK Ext C
//         if (v >= 0x2B740 && v <= 0x2B81F) { return true }        // CJK Ext D
//         if (v >= 0x2B820 && v <= 0x2CEAF) { return true }        // CJK Ext E-F
//         return false
//     }

//     @inline(__always)
//     private static func replacing(_ s: String, pattern: String, with replacement: String) -> String {
//         return s.replacingOccurrences(of: pattern, with: replacement, options: [.regularExpression])
//     }
// }


