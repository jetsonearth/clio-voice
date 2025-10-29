import Foundation

/// Context detector for casual conversation and general communication
class CasualChatContextDetector: BaseContextDetector {
    
    init() {
        super.init(contextType: .social, priority: 10) // Lowest priority - fallback for general chat
    }
    
    // MARK: - Context Detection
    
    override func detectContext(windowTitle: String?, windowContent: String?, appBundleId: String?) -> DetectedContext? {
        logger.notice("💬 [CHAT] Starting casual chat context detection")
        
        var matchedPatterns: [String] = []
        var confidence: Double = 0.0
        var detectionSource: DetectedContext.DetectionSource = .windowTitle
        
        // Check window title patterns
        var titleMatches = 0
        if let title = windowTitle {
            let titleResult = checkPatterns(in: title, patterns: CasualChatPatterns.windowTitlePatterns, patternType: "title")
            matchedPatterns.append(contentsOf: titleResult.matches)
            titleMatches = titleResult.count
        }
        
        // Check content patterns
        var contentMatches = 0
        if let content = windowContent {
            let contentResult = checkPatterns(in: content, patterns: CasualChatPatterns.contentPatterns, patternType: "content")
            matchedPatterns.append(contentsOf: contentResult.matches)
            contentMatches = contentResult.count
        }
        
        // Calculate confidence
        let titleConfidence = min(Double(titleMatches) * CasualChatPatterns.titleMatchWeight, 1.0)
        let contentConfidence = min(Double(contentMatches) * CasualChatPatterns.contentMatchWeight, CasualChatPatterns.maxContentConfidence)
        confidence = titleConfidence + contentConfidence
        
        // Determine detection source
        if titleMatches > 0 && contentMatches > 0 {
            detectionSource = .both
        } else if contentMatches > 0 {
            detectionSource = .windowContent
        }
        
        // For casual chat, we use a very low threshold since this serves as a fallback
        // This helps provide some context enhancement even for general conversation
        if confidence >= CasualChatPatterns.minimumConfidence {
            logger.notice("💬 [CHAT] Casual chat context detected - Title matches: \(titleMatches), Content matches: \(contentMatches), Confidence: \(confidence)")
            return createContext(confidence: confidence, matchedPatterns: matchedPatterns, source: detectionSource)
        }
        
        logger.debug("❌ [CHAT] Chat confidence too low: \(confidence) < \(CasualChatPatterns.minimumConfidence)")
        return nil
    }
    
    // MARK: - App Validation
    
    override func isValidApp(_ bundleId: String) -> Bool {
        // Use case-insensitive comparison for robustness
        let isValid = CasualChatPatterns.validChatApps.contains { $0.lowercased() == bundleId.lowercased() }
        logger.debug("🔍 [CHAT-VALIDATION] bundleId: '\(bundleId)' → valid: \(isValid)")
        return isValid
    }
    
    // MARK: - Prompt Enhancement
    
    override func getPromptEnhancement() -> String? {
        return """
        ADDITIONAL CASUAL CONVERSATION FORMATTING:
        After cleaning the transcript, apply these casual communication enhancements:
        
        1. CONVERSATIONAL TONE:
           - Maintain natural, friendly conversational flow
           - Preserve casual expressions and colloquialisms when appropriate
           - Keep the speaker's personal style and voice
           - Ensure warmth and authenticity in the tone
        
        2. CASUAL STRUCTURE:
           - Use natural paragraph breaks for readability
           - Format as conversational rather than formal prose
           - Organize thoughts logically but keep it casual
           - Use bullet points sparingly, only when naturally mentioned
        
        3. SOCIAL CONTEXT AWARENESS:
           - Adapt formality level to the conversational context
           - Preserve personal anecdotes and casual references
           - Maintain appropriate level of informality
           - Keep social cues and conversational markers
        
        4. NATURAL SPEECH PATTERNS:
           - Clean up filler words but preserve natural flow
           - Maintain conversational rhythm and pacing
           - Keep contractions and casual language when appropriate
           - Preserve emotional context and enthusiasm
        
        5. CONTENT PRESERVATION:
           - Keep personal references and relationships intact
           - Preserve casual plans, suggestions, and ideas
           - Maintain the speaker's intended meaning and context
           - Don't over-formalize casual communication
        
        6. WHAT NOT TO DO:
           - Don't make it overly formal or business-like
           - Don't remove personality and casual expressions
           - Don't add formal structure not present in original
           - Don't change the conversational nature of the content
        
        Return naturally formatted casual communication that feels authentic and conversational.
        """
    }
}