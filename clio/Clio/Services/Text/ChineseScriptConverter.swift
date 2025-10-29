import Foundation
import os
#if canImport(OpenCC)
import OpenCC
#endif

enum ChineseScriptConverter {
    private static let logger = Logger(subsystem: "com.jetsonai.clio", category: "OpenCC")
    #if canImport(OpenCC)
    private static var cachedTWConverter: ChineseConverter?
    private static var cachedHKConverter: ChineseConverter?
    #endif

    /// Convert Simplified Chinese to Traditional when user's selected languages include Traditional variants.
    /// English and other non-Han characters are unaffected by OpenCC.
    static func convertIfNeeded(_ text: String) -> String {
        // Determine if Traditional output is desired
        let selected = MultilingualPrompts.getSelectedLanguages().map { $0.lowercased() }
        let needsTraditional = selected.contains("zh-hant") || selected.contains("zh-tw") || selected.contains("zh-hk")
        guard needsTraditional else {
            return text
        }

        #if canImport(OpenCC)
        do {
            Self.logger.notice("[OpenCC] available. selected=\(selected)")
            // Prefer Hong Kong standard if explicitly selected; otherwise default to Taiwan standard + idioms
            if selected.contains("zh-hk") {
                if let converter = cachedHKConverter {
                    Self.logger.notice("[OpenCC] using cached HK converter")
                    return converter.convert(text)
                } else {
                    let converter = try ChineseConverter(options: [.traditionalize, .hkStandard])
                    cachedHKConverter = converter
                    Self.logger.notice("[OpenCC] initialized HK converter")
                    return converter.convert(text)
                }
            } else {
                if let converter = cachedTWConverter {
                    Self.logger.notice("[OpenCC] using cached TW converter")
                    return converter.convert(text)
                } else {
                    let converter = try ChineseConverter(options: [.traditionalize, .twStandard, .twIdiom])
                    cachedTWConverter = converter
                    Self.logger.notice("[OpenCC] initialized TW converter (.twStandard + .twIdiom)")
                    return converter.convert(text)
                }
            }
        } catch {
            Self.logger.error("[OpenCC] init/convert error: \(String(describing: error))")
            return text
        }
        #else
        Self.logger.notice("[OpenCC] not available at build time – conversion skipped")
        return text
        #endif
    }
}


