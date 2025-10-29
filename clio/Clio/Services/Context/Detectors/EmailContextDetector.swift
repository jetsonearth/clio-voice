import Foundation

/// Context detector for email composition and email-related activities
class EmailContextDetector: BaseContextDetector {
    
    init() {
        super.init(contextType: .email, priority: 100) // Highest priority
    }
    
    // MARK: - Context Detection
    
    override func detectContext(windowTitle: String?, windowContent: String?, appBundleId: String?) -> DetectedContext? {
        logger.notice("📧 [EMAIL] Starting email context detection")
        
        var matchedPatterns: [String] = []
        var confidence: Double = 0.0
        var detectionSource: DetectedContext.DetectionSource = .windowTitle
        
        // FIRST: Check for development/debugging exclusions
        if let title = windowTitle {
            if hasExclusionPatterns(in: title, exclusionPatterns: EmailPatterns.exclusionPatterns, textType: "title") {
                return nil
            }
        }
        
        if let content = windowContent {
            if hasExclusionPatterns(in: content, exclusionPatterns: EmailPatterns.exclusionPatterns, textType: "content") {
                return nil
            }
        }
        
        // Check window title patterns
        var titleMatches = 0
        if let title = windowTitle {
            let titleResult = checkPatterns(in: title, patterns: EmailPatterns.windowTitlePatterns, patternType: "title")
            matchedPatterns.append(contentsOf: titleResult.matches)
            titleMatches = titleResult.count
        }
        
        // Check content patterns
        var contentMatches = 0
        if let content = windowContent {
            let contentResult = checkPatterns(in: content, patterns: EmailPatterns.contentPatterns, patternType: "content")
            matchedPatterns.append(contentsOf: contentResult.matches)
            contentMatches = contentResult.count
        }
        
        // Calculate confidence with higher emphasis on title matches
        let titleConfidence = min(Double(titleMatches) * EmailPatterns.titleMatchWeight, 1.0)
        let contentConfidence = min(Double(contentMatches) * EmailPatterns.contentMatchWeight, EmailPatterns.maxContentConfidence)
        confidence = titleConfidence + contentConfidence
        
        // Determine detection source
        if titleMatches > 0 && contentMatches > 0 {
            detectionSource = .both
        } else if contentMatches > 0 {
            detectionSource = .windowContent
        }
        
        // Additional validation: require at least one title match for high confidence
        if titleMatches == 0 && confidence < EmailPatterns.minimumTitleConfidenceThreshold {
            logger.debug("❌ [EMAIL] No title matches and confidence not high enough: \(confidence)")
            return nil
        }
        
        if confidence >= EmailPatterns.minimumConfidence {
            logger.notice("📧 [EMAIL] Email detected - Title matches: \(titleMatches), Content matches: \(contentMatches), Confidence: \(confidence)")
            return createContext(confidence: confidence, matchedPatterns: matchedPatterns, source: detectionSource)
        }
        
        logger.debug("❌ [EMAIL] Email confidence too low: \(confidence) < \(EmailPatterns.minimumConfidence)")
        return nil
    }
    
    // MARK: - App Validation
    
    override func isValidApp(_ bundleId: String) -> Bool {
        // Use case-insensitive comparison for robustness
        let isValid = EmailPatterns.validEmailApps.contains { $0.lowercased() == bundleId.lowercased() }
        logger.debug("🔍 [EMAIL-VALIDATION] bundleId: '\(bundleId)' → valid: \(isValid)")
        return isValid
    }
    
    // MARK: - Prompt Enhancement
    
    override func getPromptEnhancement() -> String? {
        return """
        EMAIL FORMATTING INSTRUCTIONS:
        Format the transcript as a proper email with line breaks. Follow this structure:
        
        EXAMPLE:
        Input: "Hi Sarah, hope you're doing well, can we schedule a meeting for next week, thanks Michael"
        Output:
        Hi Sarah,
        
        Hope you're doing well. Can we schedule a meeting for next week?
        
        Thanks,
        Michael
        
        FORMATTING RULES:
        - Put greeting on its own line with comma (preserve exact greeting word used)
        - Add empty line after greeting
        - Format body content in clear paragraphs  
        - Add empty line before closing
        - Put closing and name on separate lines
        - NEVER change the greeting/closing words used (Hi/Hey/Dear/Thanks/Best/etc.)
        - NEVER add content not in the original transcript
        
        Return only the formatted email body with original content preserved.
        """
    }
}