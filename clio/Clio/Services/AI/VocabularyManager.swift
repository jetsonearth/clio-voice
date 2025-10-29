import Foundation
import os.log

/// Manages vocabulary context and dictionary functionality for speech recognition
/// Provides technical terms, custom user words, and contextual vocabulary for improved ASR accuracy
class VocabularyManager {
    private let logger = Logger(subsystem: "com.cliovoice.clio", category: "VocabularyManager")
    
    /// Generate complete dictionary context for Soniox ASR
    /// Combines standard terms, technical terms (when in code context), and custom user words
    @MainActor
    func getDictionaryContext() -> String? {
        let detectedContext = ContextService.shared?.getLatestDetectedContext()
        let vocabularyHints = ContextService.shared?.getVocabularyHints() ?? []
        let terms = buildTerms(detectedContext: detectedContext, vocabularyHints: vocabularyHints)
        guard !terms.isEmpty else { return nil }
        return terms.joined(separator: ", ")
    }
    
    func buildTerms(detectedContext: DetectedContext?, vocabularyHints: [String]) -> [String] {
        var results: [String] = []
        var seen = Set<String>()
        
        func append(_ term: String) {
            let trimmed = term.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return }
            let key = trimmed.lowercased()
            guard !seen.contains(key) else { return }
            seen.insert(key)
            results.append(trimmed)
        }
        
        append("Claude Code")
        
        if detectedContext?.type == .code {
            getCodeModeTechnicalTerms().forEach { append($0) }
        }
        
        getCustomDictionaryWords().forEach { append($0) }
        vocabularyHints.forEach { append($0) }
        detectedContext?.matchedPatterns.forEach { append($0) }
        
        let limited = results.prefix(64)
        return Array(limited)
    }
    
    /// Technical terms commonly mispronounced in code contexts
    /// Called only when code context is detected via ContextService
    private func getCodeModeTechnicalTerms() -> [String] {
        // Technical terms that are commonly mispronounced in code contexts
        // This function is now called only when code context is detected via ContextService
        return [
            "npm", 
            "RL", 
            "JSON",
            "async",
            "Vue",
            "git commit",
            "npm run dev",
            "GPT-4o",
            "Claude 4",
            "o3",
            "Ultrathink",
            "uv",
            "Qwen",
            "Tauri"
        ]
    }
    
    /// Retrieve custom dictionary words from user settings
    /// Returns only enabled words from UserDefaults storage
    func getCustomDictionaryWords() -> [String] {
        let saveKey = "CustomDictionaryItems"
        guard let data = UserDefaults.standard.data(forKey: saveKey) else { return [] }
        
        do {
            // Decode as array of dictionaries to avoid struct dependency
            guard let savedItems = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
                return []
            }
            
            let enabledWords = savedItems.compactMap { item -> String? in
                guard let word = item["word"] as? String,
                      let isEnabled = item["isEnabled"] as? Bool,
                      isEnabled else { return nil }
                return word
            }
            
            return enabledWords
        } catch {
            logger.error("Failed to decode custom dictionary items: \(error)")
            return []
        }
    }
}
