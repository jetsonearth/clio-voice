import Foundation

/// Context detector for code development and programming activities
class CodeContextDetector: BaseContextDetector {
    
    init() {
        super.init(contextType: .code, priority: 90) // High priority, but lower than email
    }
    
    // MARK: - Context Detection
    
    override func detectContext(windowTitle: String?, windowContent: String?, appBundleId: String?) -> DetectedContext? {
        logger.notice("💻 [CODE] Starting code context detection")
        
        var matchedPatterns: [String] = []
        var confidence: Double = 0.0
        let detectionSource: DetectedContext.DetectionSource = .windowTitle
        
        // Check window title patterns only - no content analysis
        var titleMatches = 0
        if let title = windowTitle {
            let titleResult = checkPatterns(in: title, patterns: CodePatterns.windowTitlePatterns, patternType: "title")
            matchedPatterns.append(contentsOf: titleResult.matches)
            titleMatches = titleResult.count
        }
        
        // Simple, deterministic confidence calculation
        confidence = min(Double(titleMatches) * CodePatterns.titleMatchWeight, 1.0)
        
        if confidence >= CodePatterns.minimumConfidence {
            logger.notice("💻 [CODE] Code context detected - Title matches: \(titleMatches), Confidence: \(confidence)")
            return createContext(confidence: confidence, matchedPatterns: matchedPatterns, source: detectionSource)
        }
        
        logger.debug("❌ [CODE] Code confidence too low: \(confidence) < \(CodePatterns.minimumConfidence)")
        return nil
    }
    
    // MARK: - App Validation
    
    override func isValidApp(_ bundleId: String) -> Bool {
        // Use case-insensitive comparison for robustness
        let isValid = CodePatterns.validCodeApps.contains { $0.lowercased() == bundleId.lowercased() }
        logger.debug("🔍 [CODE-VALIDATION] bundleId: '\(bundleId)' → valid: \(isValid)")
        return isValid
    }
    
    // MARK: - Prompt Enhancement
    
    override func getPromptEnhancement() -> String? {
        // Technical formatting rules are now integrated into the system prompt
        // Return nil to use the dedicated code system prompt instead
        return nil
    }
    
    // MARK: - NER Enhancement
    
    override func getNERPrompt() -> String? {
        return """
        You are Clio's NER assistant. Clio is a personalized voice dictation app that uses the user's on-screen context
        to improve speech recognition quality and the overall experience. You will be given OCR text captured from the
        user's active window.
        
        Your tasks:
        1) Produce a short paragraph for context_summary describing what the user is doing, what they are looking at,
           and the application/workspace in use. The summary should be concise but comprehensive.
        2) Extract ONLY meaningful technical entities and output STRICT JSON.

        Output format: return EXACTLY one minified JSON object with these exact keys (all present):
        {
          "context_summary": string[],
          "classes": string[],
          "components": string[],
          "function_names": string[],
          "files": string[],
          "frameworks": string[],
          "packages": string[],
          "variables": string[],
          "services": string[],
          "products": string[],
          "people": string[],
          "organizations": string[]
        }

        Rules:
        - JSON only. No markdown, no code fences, no prose outside the JSON. No trailing commas.
        - context_summary must be a short paragraph and should always be included.
        - Keys must match EXACTLY (snake_case). Only include keys that have values.
        - Values are unique, trimmed strings; preserve original casing (e.g., AIEnhancementService, URLSessionTaskDelegate).
        - Include app/service/product names when relevant (e.g., Xcode, Clio).
        - Exclude generic nouns, URLs, and broad topics.
        """.replacingOccurrences(of: "\n", with: " ")
    }
}
