import Foundation
import os

/// Registry that manages and coordinates all context detector plugins
/// Now uses the new ContextRuleEngine for configuration-driven detection
class ContextDetectorRegistry {
    private let logger = Logger(
        subsystem: "com.jetsonai.clio",
        category: "context.registry"
    )
    
    /// The new rule engine for context detection
    private let ruleEngine: ContextRuleEngine
    
    /// Legacy detectors (kept for backwards compatibility during transition)
    private var legacyDetectors: [ContextDetectorProtocol] = []
    
    /// Singleton instance
    static let shared = ContextDetectorRegistry()
    
    private init() {
        // Initialize the new rule engine
        self.ruleEngine = ContextRuleEngine.shared
        
        // Keep legacy detectors as fallback during transition
        registerDefaultDetectors()
    }
    
    // MARK: - Registration
    
    /// Register a legacy context detector plugin (for backwards compatibility)
    /// - Parameter detector: The detector to register
    func register(_ detector: ContextDetectorProtocol) {
        // Check if detector for this context type already exists
        if let existingIndex = legacyDetectors.firstIndex(where: { $0.contextType == detector.contextType }) {
            if !RuntimeConfig.shouldSilenceAllLogs { logger.warning("⚠️ [REGISTRY] Replacing existing legacy detector for \(detector.contextType.displayName)") }
            legacyDetectors[existingIndex] = detector
        } else {
            legacyDetectors.append(detector)
            // if !RuntimeConfig.shouldSilenceAllLogs { logger.notice("✅ [REGISTRY] Registered legacy detector for \(detector.contextType.displayName) with priority \(detector.priority)") }
        }
        
        // Sort detectors by priority (highest first)
        legacyDetectors.sort { $0.priority > $1.priority }
    }
    
    /// Register multiple detectors at once
    /// - Parameter detectors: Array of detectors to register
    func register(_ detectors: [ContextDetectorProtocol]) {
        detectors.forEach { register($0) }
    }
    
    /// Remove a detector for a specific context type
    /// - Parameter contextType: The context type to remove
    func unregister(_ contextType: DetectedContextType) {
        if let index = legacyDetectors.firstIndex(where: { $0.contextType == contextType }) {
            legacyDetectors.remove(at: index)
            if !RuntimeConfig.shouldSilenceAllLogs { logger.notice("🗑️ [REGISTRY] Unregistered legacy detector for \(contextType.displayName)") }
        }
    }
    
    // MARK: - Detection
    
    /// Detect context using the new rule engine with legacy fallback
    /// - Parameters:
    ///   - windowTitle: Current window title
    ///   - windowContent: Current window content
    ///   - appBundleId: Bundle ID of the current app
    ///   - processName: Process name of the current app (optional)
    ///   - activeURL: Active URL for browsers (optional)
    /// - Returns: Context detection result
    func detectContext(windowTitle: String?, windowContent: String?, appBundleId: String? = nil, processName: String? = nil, activeURL: String? = nil) -> DetectedContext {
        if RuntimeConfig.enableVerboseLogging {
            logger.notice("🔍 [REGISTRY] Starting context detection using new rule engine")
            logger.debug("🔍 [REGISTRY] Bundle ID: \(appBundleId ?? "nil")")
            logger.debug("🔍 [REGISTRY] Process name: \(processName ?? "nil")")
            logger.debug("🔍 [REGISTRY] URL: \(activeURL ?? "nil")")
            logger.debug("🔍 [REGISTRY] Window title: \(windowTitle ?? "nil")")
            logger.debug("🔍 [REGISTRY] Content length: \(windowContent?.count ?? 0) chars")
        }
        
        // 1. PRIMARY: Use the new rule engine
        let ruleEngineResult = ruleEngine.detectContext(
            windowTitle: windowTitle,
            windowContent: windowContent,
            appBundleId: appBundleId,
            processName: processName,
            activeURL: activeURL
        )
        
        // If rule engine found a context (not .none), return it
        if ruleEngineResult.type != .none {
            if RuntimeConfig.enableVerboseLogging {
                logger.notice("✅ [REGISTRY] Rule engine detected: \(ruleEngineResult.type.displayName) (confidence: \(ruleEngineResult.confidence))")
            }
            return ruleEngineResult
        }
        
        // 2. CONSERVATIVE FALLBACK: Only try legacy detectors for HIGH-confidence matches
        // When rule engine returns .none, we should primarily fallback to general mode
        if RuntimeConfig.enableVerboseLogging && !RuntimeConfig.shouldSilenceAllLogs { logger.debug("🔄 [REGISTRY] Rule engine returned .none, checking for high-confidence legacy matches only") }
        
        for detector in legacyDetectors {
            if RuntimeConfig.enableVerboseLogging && !RuntimeConfig.shouldSilenceAllLogs { logger.debug("🔄 [REGISTRY] Trying legacy \(detector.contextType.displayName) detector (priority: \(detector.priority))") }
            
            if let context = detector.detectContext(windowTitle: windowTitle, windowContent: windowContent, appBundleId: appBundleId) {
                // STRICT validation: only accept high-confidence matches or specialized apps
                if let bundleId = appBundleId {
                    // High confidence threshold for rule engine overrides
                    let highConfidenceThreshold = 0.8
                    
                    if context.confidence >= highConfidenceThreshold {
                        if !RuntimeConfig.shouldSilenceAllLogs { logger.notice("✅ [REGISTRY] Legacy detector found HIGH-CONFIDENCE match: \(context.type.displayName) context with confidence \(context.confidence) in app \(bundleId)") }
                        return context
                    } else {
                        if RuntimeConfig.enableVerboseLogging && !RuntimeConfig.shouldSilenceAllLogs { logger.notice("🚫 [REGISTRY] Legacy \(context.type.displayName) context rejected - rule engine returned .none and confidence not high enough (\(context.confidence) < \(highConfidenceThreshold))") }
                        continue
                    }
                } else {
                    // No app info - only accept very high confidence
                    if context.confidence >= 0.9 {
                        if !RuntimeConfig.shouldSilenceAllLogs { logger.notice("✅ [REGISTRY] Legacy detector found VERY-HIGH-CONFIDENCE match: \(context.type.displayName) context with confidence \(context.confidence) (no app validation)") }
                        return context
                    } else {
                        if RuntimeConfig.enableVerboseLogging && !RuntimeConfig.shouldSilenceAllLogs { logger.notice("🚫 [REGISTRY] Legacy \(context.type.displayName) context rejected - no app info and confidence not very high (\(context.confidence) < 0.9)") }
                        continue
                    }
                }
            }
        }
        
        // 3. PROPER FALLBACK: Return general context when rule engine says .none
        if !RuntimeConfig.shouldSilenceAllLogs { logger.notice("📝 [REGISTRY] Rule engine returned .none and no high-confidence legacy matches, returning general context") }
        return DetectedContext(type: .none, confidence: 1.0, matchedPatterns: ["fallback_general"], source: .windowTitle)
    }
    
    /// Legacy detection method for backwards compatibility
    func detectContextLegacy(windowTitle: String?, windowContent: String?, appBundleId: String? = nil) -> DetectedContext {
        return detectContext(windowTitle: windowTitle, windowContent: windowContent, appBundleId: appBundleId)
    }
    
    /// Get prompt enhancement for a detected context
    /// - Parameter context: The detected context
    /// - Returns: Prompt enhancement string, or nil if no enhancement needed
    func getPromptEnhancement(for context: DetectedContext) -> String? {
        // First try to get enhancement from legacy detectors
        if let detector = legacyDetectors.first(where: { $0.contextType == context.type }) {
            return detector.getPromptEnhancement()
        }
        
        // TODO: Add prompt enhancement support to rule engine configuration
        if RuntimeConfig.enableVerboseLogging && !RuntimeConfig.shouldSilenceAllLogs { logger.debug("⚠️ [REGISTRY] No prompt enhancement available for context type \(context.type.displayName)") }
        return nil
    }
    
    /// Get NER prompt for a detected context
    /// - Parameter context: The detected context
    /// - Returns: NER prompt string, or nil if no specific NER enhancement needed (uses default)
    func getNERPrompt(for context: DetectedContext) -> String? {
        // Only code context gets specialized NER prompt, all others use default
        if context.type == .code {
            if let detector = legacyDetectors.first(where: { $0.contextType == .code }) {
                return detector.getNERPrompt()
            }
        }
        
        // All non-code contexts use default NER (return nil)
        logger.debug("🔍 [REGISTRY] Using default NER for context type \(context.type.displayName)")
        return nil
    }
    
    // MARK: - Registry Information
    
    /// Get all registered context types (from rule engine + legacy detectors)
    /// - Returns: Array of registered context types
    func getRegisteredContextTypes() -> [DetectedContextType] {
        // TODO: Extract context types from rule engine configuration
        var types = legacyDetectors.map { $0.contextType }
        
        // Add known rule engine types
        types.append(contentsOf: [.email, .code, .social])
        
        return Array(Set(types)) // Remove duplicates
    }
    
    /// Get legacy detector for a specific context type
    /// - Parameter contextType: The context type to find
    /// - Returns: The detector for that type, or nil if not found
    func getLegacyDetector(for contextType: DetectedContextType) -> ContextDetectorProtocol? {
        return legacyDetectors.first { $0.contextType == contextType }
    }
    
    /// Get count of registered legacy detectors
    var legacyDetectorCount: Int {
        return legacyDetectors.count
    }
    
    // MARK: - Private Methods
    
    /// Register the default set of context detectors
    private func registerDefaultDetectors() {
        // logger.notice("🚀 [REGISTRY] Initializing default context detectors")
        
        // Register detectors in priority order (highest priority first)
        register(EmailContextDetector())        // Priority: 100
        register(CodeContextDetector())         // Priority: 90
        register(CasualChatContextDetector())   // Priority: 10
        
        logger.notice("📊 [REGISTRY] Initialization complete with \(self.legacyDetectors.count) legacy detectors")
    }
}