import Foundation

@MainActor
struct SonioxContextBuilder {
    private let contextService: ContextService?
    private let vocabularyManager: VocabularyManager
    private let maxTextLength = 6000
    private let maxTitleLength = 200
    
    init(contextService: ContextService?, vocabularyManager: VocabularyManager) {
        self.contextService = contextService
        self.vocabularyManager = vocabularyManager
    }
    
    func buildContext() -> SonioxContext? {
        let detectedContext = contextService?.getLatestDetectedContext()
        let vocabularyHints = contextService?.getVocabularyHints() ?? []
        let terms = vocabularyManager.buildTerms(detectedContext: detectedContext, vocabularyHints: vocabularyHints)
        
        var generalEntries: [SonioxContextGeneral] = []
        if let detected = detectedContext {
            generalEntries.append(SonioxContextGeneral(key: "domain", value: detected.type.displayName))
            let confidencePercent = Int((detected.confidence * 100).rounded())
            generalEntries.append(SonioxContextGeneral(key: "confidence_pct", value: "\(confidencePercent)"))
            generalEntries.append(SonioxContextGeneral(key: "detection_source", value: detected.source.displayName))
        }
        
        if let snapshot = contextService?.getWindowSnapshot() {
            if let bundle = snapshot.bundleID, !bundle.isEmpty {
                generalEntries.append(SonioxContextGeneral(key: "application", value: bundle))
            }
            if let title = snapshot.title, !title.isEmpty {
                generalEntries.append(SonioxContextGeneral(key: "window_title", value: truncated(title, limit: maxTitleLength)))
            }
        }
        
        let contextText = contextService?.getContextSummaryText(limit: maxTextLength)
        
        let context = SonioxContext(
            general: generalEntries.isEmpty ? nil : generalEntries,
            text: contextText,
            terms: terms.isEmpty ? nil : terms,
            translationTerms: nil
        )
        
        if context.general == nil && context.text == nil && context.terms == nil && context.translationTerms == nil {
            return nil
        }
        return context
    }
    
    private func truncated(_ value: String, limit: Int) -> String {
        guard value.count > limit else { return value }
        let index = value.index(value.startIndex, offsetBy: limit)
        return String(value[..<index])
    }
}
