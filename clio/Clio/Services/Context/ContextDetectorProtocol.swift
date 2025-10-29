import Foundation
import os

/// Protocol that all context detector plugins must implement
protocol ContextDetectorProtocol {
    /// The type of context this detector handles
    var contextType: DetectedContextType { get }
    
    /// Priority for detection order (higher numbers run first)
    /// Email: 100, Code: 90, CasualChat: 10, etc.
    var priority: Int { get }
    
    /// Logger instance for consistent logging across detectors
    var logger: Logger { get }
    
    /// Detect context from window information and app context
    /// - Parameters:
    ///   - windowTitle: Current window title (optional)
    ///   - windowContent: Current window content (optional)
    ///   - appBundleId: Bundle ID of the current frontmost app (optional)
    /// - Returns: DetectedContext if this detector finds a match, nil otherwise
    func detectContext(windowTitle: String?, windowContent: String?, appBundleId: String?) -> DetectedContext?
    
    /// Get the appropriate prompt enhancement for this context type
    /// - Returns: Prompt enhancement string, or nil if no enhancement needed
    func getPromptEnhancement() -> String?
    
    /// Get the appropriate NER (Named Entity Recognition) prompt for this context type
    /// - Returns: NER prompt string, or nil if no specific NER enhancement needed
    func getNERPrompt() -> String?
    
    /// Validate if the given app bundle ID is appropriate for this context type
    /// - Parameter bundleId: App bundle identifier to validate
    /// - Returns: true if the app is valid for this context, false otherwise
    func isValidApp(_ bundleId: String) -> Bool
}

/// Base implementation providing common functionality for context detectors
class BaseContextDetector: ContextDetectorProtocol {
    let contextType: DetectedContextType
    let priority: Int
    let logger: Logger
    
    init(contextType: DetectedContextType, priority: Int) {
        self.contextType = contextType
        self.priority = priority
        self.logger = Logger(
            subsystem: "com.jetsonai.clio",
            category: "context.\(contextType.rawValue)"
        )
    }
    
    // Default implementations that subclasses can override
    func detectContext(windowTitle: String?, windowContent: String?, appBundleId: String?) -> DetectedContext? {
        // Subclasses must implement this
        fatalError("Subclasses must implement detectContext")
    }
    
    func getPromptEnhancement() -> String? {
        // Subclasses should override this
        return nil
    }
    
    func getNERPrompt() -> String? {
        // Subclasses should override this
        return nil
    }
    
    func isValidApp(_ bundleId: String) -> Bool {
        // Default implementation - subclasses should override
        return true
    }
    
    // MARK: - Helper Methods for Subclasses
    
    /// Helper method to check patterns against text with regex support
    /// - Parameters:
    ///   - text: Text to search in
    ///   - patterns: Array of regex patterns to match
    ///   - patternType: Type description for logging (e.g., "title", "content")
    /// - Returns: Array of matched pattern strings and count of matches
    func checkPatterns(in text: String, patterns: [String], patternType: String) -> (matches: [String], count: Int) {
        var matchedPatterns: [String] = []
        
        for pattern in patterns {
            if text.range(of: pattern, options: .regularExpression) != nil {
                matchedPatterns.append("\(patternType): \(pattern)")
            }
        }
        
        return (matchedPatterns, matchedPatterns.count)
    }
    
    /// Check if text contains any exclusion patterns that should prevent detection
    /// - Parameters:
    ///   - text: Text to check
    ///   - exclusionPatterns: Patterns that indicate this context should be excluded
    ///   - textType: Type of text being checked (for logging)
    /// - Returns: true if exclusion patterns found, false otherwise
    func hasExclusionPatterns(in text: String, exclusionPatterns: [String], textType: String) -> Bool {
        for exclusionPattern in exclusionPatterns {
            if text.range(of: exclusionPattern, options: .regularExpression) != nil {
                logger.notice("🚫 [DYNAMIC] \(self.contextType.displayName) exclusion detected in \(textType): excluding from detection")
                return true
            }
        }
        return false
    }
    
    /// Create a DetectedContext result
    /// - Parameters:
    ///   - confidence: Confidence level (0.0 to 1.0)
    ///   - matchedPatterns: Array of matched pattern descriptions
    ///   - source: Source of the detection (title, content, or both)
    /// - Returns: DetectedContext instance
    func createContext(confidence: Double, matchedPatterns: [String], source: DetectedContext.DetectionSource) -> DetectedContext {
        return DetectedContext(
            type: contextType,
            confidence: min(confidence, 1.0),
            matchedPatterns: matchedPatterns,
            source: source
        )
    }
}