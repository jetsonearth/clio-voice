import Foundation
import os
#if canImport(Yams)
import Yams
#endif

/// Data structures for YAML configuration parsing
struct ContextDetectionConfig: Codable {
    let contexts: [String: ContextRuleSet]
    let detectionConfig: DetectionGlobalConfig
    let userOverrides: [String: AnyCodable]?
    
    private enum CodingKeys: String, CodingKey {
        case contexts
        case detectionConfig = "detection_config"
        case userOverrides = "user_overrides"
    }
}

struct ContextRuleSet: Codable {
    let displayName: String
    let priority: Int
    let confidenceBoost: Double
    let applications: [ApplicationRule]?
    let browserRules: BrowserRules?
    let windowTitlePatterns: [PatternRule]?
    let contentPatterns: [PatternRule]?
    
    private enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case priority
        case confidenceBoost = "confidence_boost"
        case applications
        case browserRules = "browser_rules"
        case windowTitlePatterns = "window_title_patterns"
        case contentPatterns = "content_patterns"
    }
}

struct ApplicationRule: Codable {
    let bundleId: String?
    let bundleIdPattern: String?
    let processNames: [String]?
    let priority: Int
    let confidence: Double?
    
    private enum CodingKeys: String, CodingKey {
        case bundleId = "bundle_id"
        case bundleIdPattern = "bundle_id_pattern"
        case processNames = "process_names"
        case priority
        case confidence
    }
    
    /// Check if this rule matches the given bundle ID and process name
    func matches(bundleId: String?, processName: String?) -> (matches: Bool, confidence: Double) {
        let baseConfidence = confidence ?? 1.0
        
        // 1. Exact bundle ID match (highest priority)
        if let ruleBundleId = self.bundleId, let appBundleId = bundleId {
            if appBundleId.lowercased() == ruleBundleId.lowercased() {
                return (true, baseConfidence)
            }
        }
        
        // 2. Pattern-based bundle ID match
        if let pattern = self.bundleIdPattern, let appBundleId = bundleId {
            if matchesRegexPattern(appBundleId, pattern: pattern) {
                return (true, baseConfidence * 0.9) // Slightly lower confidence for pattern matches
            }
        }
        
        // 3. Process name match (fallback)
        if let ruleProcessNames = self.processNames, let appProcessName = processName {
            if ruleProcessNames.contains(where: { $0.lowercased() == appProcessName.lowercased() }) {
                return (true, baseConfidence * 0.8) // Lower confidence for process name matches
            }
        }
        
        return (false, 0.0)
    }
    
    private func matchesRegexPattern(_ text: String, pattern: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let range = NSRange(location: 0, length: text.utf16.count)
            return regex.firstMatch(in: text, options: [], range: range) != nil
        } catch {
            return false
        }
    }
}

struct BrowserRules: Codable {
    let validBrowsers: [String]
    let urlPatterns: [PatternRule]
    
    private enum CodingKeys: String, CodingKey {
        case validBrowsers = "valid_browsers"
        case urlPatterns = "url_patterns"
    }
}

struct PatternRule: Codable {
    let pattern: String
    let confidence: Double
}

struct DetectionGlobalConfig: Codable {
    let minimumConfidence: Double
    let bundleIdOverrideThreshold: Double
    let urlConfidenceBoost: Double
    let maxPatternsPerType: Int
    let cacheDurationSeconds: Int
    
    private enum CodingKeys: String, CodingKey {
        case minimumConfidence = "minimum_confidence"
        case bundleIdOverrideThreshold = "bundle_id_override_threshold"
        case urlConfidenceBoost = "url_confidence_boost"
        case maxPatternsPerType = "max_patterns_per_type"
        case cacheDurationSeconds = "cache_duration_seconds"
    }
}

// Helper for unknown YAML values
struct AnyCodable: Codable {
    let value: Any
    
    init<T>(_ value: T?) {
        self.value = value ?? ()
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            value = ()
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let string = try? container.decode(String.self) {
            value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map { $0.value }
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            value = dictionary.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Unknown type"))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        if let value = value as? Bool {
            try container.encode(value)
        } else if let value = value as? Int {
            try container.encode(value)
        } else if let value = value as? Double {
            try container.encode(value)
        } else if let value = value as? String {
            try container.encode(value)
        } else if let value = value as? [Any] {
            try container.encode(value.map(AnyCodable.init))
        } else if let value = value as? [String: Any] {
            try container.encode(value.mapValues(AnyCodable.init))
        } else {
            try container.encodeNil()
        }
    }
}

/// Cache entry for detection results
struct ContextDetectionCacheEntry {
    let result: DetectedContext
    let timestamp: Date
    let isExpired: Bool
    
    init(result: DetectedContext, cacheDuration: TimeInterval) {
        self.result = result
        self.timestamp = Date()
        self.isExpired = Date().timeIntervalSince(timestamp) > cacheDuration
    }
}

/// High-performance, configuration-driven context detection engine
class ContextRuleEngine {
    private let logger = Logger(
        subsystem: "com.jetsonai.clio",
        category: "context.rule-engine"
    )
    
    private var config: ContextDetectionConfig?
    private var cache: [String: ContextDetectionCacheEntry] = [:]
    private let cacheQueue = DispatchQueue(label: "context.cache", attributes: .concurrent)
    
    /// Singleton instance
    static let shared = ContextRuleEngine()
    
    private init() {
        loadConfiguration()
    }
    
    // MARK: - Configuration Loading
    
    /// Load configuration from bundle.
    /// Prefers JSON (ContextDetectionRules.json); if absent, attempts YAML via Yams when available;
    /// finally falls back to internal test JSON if neither is available or parsing fails.
    private func loadConfiguration() {
        // 1) Try JSON configuration first
        if let jsonPath = Bundle.main.path(forResource: "ContextDetectionRules", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: jsonPath))
                self.config = try JSONDecoder().decode(ContextDetectionConfig.self, from: data)
                return
            } catch {
                logger.error("❌ [RULE-ENGINE] Failed to load ContextDetectionRules.json: \(error.localizedDescription)")
            }
        }

        // 2) Try YAML if JSON is not available
        if let yamlPath = Bundle.main.path(forResource: "ContextDetectionRules", ofType: "yaml") {
            do {
                let yamlString = try String(contentsOfFile: yamlPath, encoding: .utf8)
                #if canImport(Yams)
                let decoder = YAMLDecoder()
                self.config = try decoder.decode(ContextDetectionConfig.self, from: yamlString)
                return
                #else
                logger.error("❌ [RULE-ENGINE] Found ContextDetectionRules.yaml but YAML parser not available. Add Yams via Swift Package Manager or provide ContextDetectionRules.json.")
                #endif
            } catch {
                logger.error("❌ [RULE-ENGINE] Failed to read ContextDetectionRules.yaml: \(error.localizedDescription)")
            }
        } else {
            logger.error("❌ [RULE-ENGINE] No ContextDetectionRules.json or .yaml found in bundle")
        }

        // 3) Fallback: use internal test configuration to avoid crash
        do {
            // Reuse existing converter that returns a test JSON blob
            let jsonData = try convertYAMLToJSON("")
            self.config = try JSONDecoder().decode(ContextDetectionConfig.self, from: jsonData)
        } catch {
            logger.error("❌ [RULE-ENGINE] Failed to load fallback configuration: \(error.localizedDescription)")
        }
    }
    
    /// Simple YAML to JSON converter for our specific format
    /// Note: This is a simplified implementation. For full YAML support, consider using Yams library
    private func convertYAMLToJSON(_ yamlString: String) throws -> Data {
        // For now, we'll implement a basic converter that handles our specific YAML structure
        // This is a simplified approach - in production, use a proper YAML parser like Yams
        
        var jsonString = yamlString
        
        // Convert YAML boolean values
        jsonString = jsonString.replacingOccurrences(of: ": true", with: ": true")
        jsonString = jsonString.replacingOccurrences(of: ": false", with: ": false")
        
        // Handle YAML list format conversion (basic)
        let lines = jsonString.components(separatedBy: .newlines)
        var jsonLines: [String] = []
        var indentLevel = 0
        var inList = false
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            // Skip empty lines and comments
            if trimmedLine.isEmpty || trimmedLine.hasPrefix("#") {
                continue
            }
            
            // Detect list items
            if trimmedLine.hasPrefix("- ") {
                if !inList {
                    // Start of new list
                    jsonLines.append(String(repeating: " ", count: indentLevel) + "[")
                    inList = true
                }
                
                // Convert list item
                let itemContent = String(trimmedLine.dropFirst(2))
                if itemContent.contains(":") {
                    jsonLines.append(String(repeating: " ", count: indentLevel + 2) + "{")
                    jsonLines.append(String(repeating: " ", count: indentLevel + 4) + "\"\(itemContent)\"")
                    jsonLines.append(String(repeating: " ", count: indentLevel + 2) + "},")
                } else {
                    jsonLines.append(String(repeating: " ", count: indentLevel + 2) + "\"\(itemContent)\",")
                }
            } else {
                // End list if we were in one
                if inList {
                    // Remove trailing comma from last item
                    if let lastIndex = jsonLines.lastIndex(where: { $0.contains(",") }) {
                        jsonLines[lastIndex] = jsonLines[lastIndex].replacingOccurrences(of: ",", with: "")
                    }
                    jsonLines.append(String(repeating: " ", count: indentLevel) + "],")
                    inList = false
                }
                
                // Regular key-value pair
                if line.contains(":") {
                    let components = line.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: false)
                    if components.count == 2 {
                        let key = components[0].trimmingCharacters(in: .whitespaces)
                        let value = components[1].trimmingCharacters(in: .whitespaces)
                        
                        let jsonKey = "\"\(key)\""
                        let jsonValue: String
                        
                        if value.isEmpty {
                            jsonValue = "{"
                            jsonLines.append(String(repeating: " ", count: indentLevel) + "\(jsonKey): \(jsonValue)")
                            indentLevel += 2
                            continue
                        } else if let doubleValue = Double(value) {
                            jsonValue = "\(doubleValue)"
                        } else if value == "true" || value == "false" {
                            jsonValue = value
                        } else {
                            jsonValue = "\"\(value)\""
                        }
                        
                        jsonLines.append(String(repeating: " ", count: indentLevel) + "\(jsonKey): \(jsonValue),")
                    }
                }
            }
        }
        
        // Close any remaining structures
        if inList {
            if let lastIndex = jsonLines.lastIndex(where: { $0.contains(",") }) {
                jsonLines[lastIndex] = jsonLines[lastIndex].replacingOccurrences(of: ",", with: "")
            }
            jsonLines.append(String(repeating: " ", count: indentLevel) + "]")
        }
        
        // Remove trailing commas and close JSON object
        let _ = "{\n" + jsonLines.joined(separator: "\n") + "\n}"
        
        // For now, let's use a hardcoded JSON structure for testing
        // TODO: Implement proper YAML parsing
        let testJSON = """
        {
            "contexts": {
                "email": {
                    "display_name": "Email",
                    "priority": 100,
                    "confidence_boost": 0.5,
                    "applications": [
                        {"bundle_id": "com.apple.Mail", "priority": 100},
                        {"bundle_id": "com.microsoft.Outlook", "priority": 100}
                    ],
                    "browser_rules": {
                        "valid_browsers": ["com.google.Chrome", "com.apple.Safari", "com.mozilla.firefox", "com.microsoft.edgemac"],
                        "url_patterns": [
                            {"pattern": "mail\\\\.google\\\\.com", "confidence": 0.9},
                            {"pattern": "outlook\\\\.live\\\\.com", "confidence": 0.9},
                            {"pattern": "outlook\\\\.office\\\\.com", "confidence": 0.9},
                            {"pattern": "mail\\\\.yahoo\\\\.com", "confidence": 0.9},
                            {"pattern": "mail\\\\.protonmail\\\\.com", "confidence": 0.9},
                            {"pattern": "fastmail\\\\.com", "confidence": 0.9}
                        ]
                    },
                    "window_title_patterns": [
                        {"pattern": ".*Gmail.*", "confidence": 0.8}
                    ]
                },
                "code": {
                    "display_name": "Code",
                    "priority": 90,
                    "confidence_boost": 0.4,
                    "applications": [
                        {"bundle_id": "com.apple.Terminal", "priority": 95},
                        {"bundle_id": "com.microsoft.VSCode", "priority": 100},
                        {"bundle_id_pattern": "com\\\\.todesktop\\\\..*", "process_names": ["Cursor"], "priority": 100, "confidence": 0.9},
                        {"bundle_id": "com.github.atom", "priority": 90},
                        {"bundle_id": "com.sublimetext.4", "priority": 90},
                        {"bundle_id": "com.jetbrains.intellij", "priority": 90},
                        {"bundle_id": "com.jetbrains.pycharm", "priority": 90},
                        {"bundle_id": "com.jetbrains.webstorm", "priority": 90},
                        {"bundle_id": "com.apple.dt.Xcode", "priority": 95},
                        {"bundle_id": "com.panic.Nova", "priority": 90},
                        {"bundle_id": "com.coteditor.CotEditor", "priority": 80},
                        {"bundle_id": "com.bear-writer.BearMarkdown", "priority": 80},
                        {"bundle_id_pattern": ".*windsurf.*", "process_names": ["Windsurf"], "priority": 95, "confidence": 0.9},
                        {"bundle_id_pattern": ".*sourcegraph.*", "process_names": ["Sourcegraph"], "priority": 90, "confidence": 0.9}
                    ],
                    "browser_rules": {
                        "valid_browsers": ["com.google.Chrome", "com.apple.Safari", "com.mozilla.firefox"],
                        "url_patterns": [
                            {"pattern": "github\\\\.com", "confidence": 0.9},
                            {"pattern": "replit\\\\.com", "confidence": 0.9},
                            {"pattern": "v0\\\\.dev", "confidence": 0.9},
                            {"pattern": "stackblitz\\\\.com", "confidence": 0.9},
                            {"pattern": "codesandbox\\\\.io", "confidence": 0.9},
                            {"pattern": "bolt\\\\.new", "confidence": 0.9},
                            {"pattern": "same\\\\.dev", "confidence": 0.9},
                            {"pattern": "devin\\\\.ai", "confidence": 0.9},
                            {"pattern": "orchids\\\\.app", "confidence": 0.9},
                            {"pattern": "sourcegraph\\\\.com", "confidence": 0.9},
                            {"pattern": "windsurf\\\\.com", "confidence": 0.9},
                            {"pattern": "cursor\\\\.sh", "confidence": 0.9},
                            {"pattern": "lovable\\\\.dev", "confidence": 0.9}
                        ]
                    },
                    "window_title_patterns": [
                        {"pattern": ".*Terminal.*", "confidence": 0.8},
                        {"pattern": ".*\\\\.py.*", "confidence": 0.7},
                        {"pattern": ".*\\\\.js.*", "confidence": 0.7},
                        {"pattern": ".*\\\\.ts.*", "confidence": 0.7},
                        {"pattern": ".*\\\\.tsx.*", "confidence": 0.8},
                        {"pattern": ".*\\\\.jsx.*", "confidence": 0.7},
                        {"pattern": ".*\\\\.swift.*", "confidence": 0.7},
                        {"pattern": ".*\\\\.java.*", "confidence": 0.7},
                        {"pattern": ".*\\\\.cpp.*", "confidence": 0.7},
                        {"pattern": ".*\\\\.c.*", "confidence": 0.7},
                        {"pattern": ".*Bolt\\\\.new.*", "confidence": 0.9},
                        {"pattern": ".*GitHub.*", "confidence": 0.8},
                        {"pattern": ".*Devin.*", "confidence": 0.9},
                        {"pattern": ".*Orchids.*", "confidence": 0.9},
                        {"pattern": ".*Sourcegraph.*", "confidence": 0.9},
                        {"pattern": ".*Windsurf.*", "confidence": 0.9},
                        {"pattern": ".*Cursor.*", "confidence": 0.9},
                        {"pattern": ".*Lovable.*", "confidence": 0.9},
                        {"pattern": ".*Same\\\\.dev.*", "confidence": 0.9},
                        {"pattern": ".*Replit.*", "confidence": 0.9},
                        {"pattern": ".*CodeSandbox.*", "confidence": 0.9},
                        {"pattern": ".*StackBlitz.*", "confidence": 0.9}
                    ]
                }
            },
            "detection_config": {
                "minimum_confidence": 0.3,
                "bundle_id_override_threshold": 0.8,
                "url_confidence_boost": 0.3,
                "max_patterns_per_type": 50,
                "cache_duration_seconds": 5
            }
        }
        """
        
        return testJSON.data(using: .utf8)!
    }
    
    // MARK: - Context Detection
    
    /// Detect context using hierarchical rule matching
    func detectContext(windowTitle: String?, windowContent: String?, appBundleId: String?, processName: String? = nil, activeURL: String? = nil) -> DetectedContext {
        
        guard let config = config else {
            logger.error("❌ [RULE-ENGINE] Configuration not loaded")
            return createFallbackContext()
        }
        
        let cacheKey = generateCacheKey(windowTitle: windowTitle, appBundleId: appBundleId, processName: processName, activeURL: activeURL)
        
        // Check cache first
        if let cachedEntry = getCachedResult(for: cacheKey), !cachedEntry.isExpired {
            logger.debug("🎯 [RULE-ENGINE] Cache hit for \(cacheKey)")
            return cachedEntry.result
        }
        
        if RuntimeConfig.enableVerboseLogging {
            logger.notice("🔍 [RULE-ENGINE] Starting hierarchical context detection")
            logger.debug("🔍 [RULE-ENGINE] Bundle ID: \(appBundleId ?? "nil")")
            logger.debug("🔍 [RULE-ENGINE] Process name: \(processName ?? "nil")")
            logger.debug("🔍 [RULE-ENGINE] URL: \(activeURL ?? "nil")")
            logger.debug("🔍 [RULE-ENGINE] Window title: \(windowTitle ?? "nil")")
        }
        
        var bestMatch: DetectedContext?
        var highestConfidence: Double = 0.0
        
        // Iterate through contexts in priority order
        let sortedContexts = config.contexts.sorted { $0.value.priority > $1.value.priority }
        
        for (contextKey, contextRule) in sortedContexts {
            let contextType = DetectedContextType.fromString(contextKey)
            var totalConfidence: Double = 0.0
            var matchedPatterns: [String] = []
            var detectionSource: DetectedContext.DetectionSource = .windowTitle
            
            if RuntimeConfig.enableVerboseLogging {
                logger.debug("🔄 [RULE-ENGINE] Evaluating \(contextRule.displayName) context...")
            }
            
            // 1. HIGHEST PRIORITY: Multi-tiered Application Matching
            if let applications = contextRule.applications {
                for appRule in applications {
                    let (matches, ruleConfidence) = appRule.matches(bundleId: appBundleId, processName: processName)
                    
                    if matches {
                        let adjustedConfidence = ruleConfidence * config.detectionConfig.bundleIdOverrideThreshold
                        totalConfidence = max(totalConfidence, adjustedConfidence)
                        
                        // Log the type of match for debugging
                        if let bundleId = appBundleId, let ruleBundleId = appRule.bundleId, 
                           bundleId.lowercased() == ruleBundleId.lowercased() {
                            matchedPatterns.append("bundle_id:\(ruleBundleId)")
                            if RuntimeConfig.enableVerboseLogging {
                                logger.notice("✅ [RULE-ENGINE] Exact Bundle ID match: \(bundleId) → \(contextRule.displayName)")
                            }
                        } else if let bundleId = appBundleId, let pattern = appRule.bundleIdPattern {
                            matchedPatterns.append("bundle_pattern:\(pattern)")
                            if RuntimeConfig.enableVerboseLogging {
                                logger.notice("✅ [RULE-ENGINE] Bundle ID pattern match: \(bundleId) matches \(pattern) → \(contextRule.displayName)")
                            }
                        } else if let processName = processName {
                            matchedPatterns.append("process_name:\(processName)")
                            if RuntimeConfig.enableVerboseLogging {
                                logger.notice("✅ [RULE-ENGINE] Process name match: \(processName) → \(contextRule.displayName)")
                            }
                        }
                        
                        detectionSource = .both
                        break
                    }
                }
            }
            
            // 2. SECOND PRIORITY: URL matching (for browsers)
            if let url = activeURL, let browserRules = contextRule.browserRules {
                if let bundleId = appBundleId, browserRules.validBrowsers.contains(bundleId) {
                    for urlPattern in browserRules.urlPatterns.prefix(config.detectionConfig.maxPatternsPerType) {
                        if matchesPattern(url, pattern: urlPattern.pattern) {
                            let urlConfidence = urlPattern.confidence + config.detectionConfig.urlConfidenceBoost
                            totalConfidence = max(totalConfidence, urlConfidence)
                            matchedPatterns.append("url:\(urlPattern.pattern)")
                            detectionSource = detectionSource == .both ? .both : .both
                            
                            if RuntimeConfig.enableVerboseLogging {
                                logger.notice("✅ [RULE-ENGINE] URL match: \(url) → \(contextRule.displayName)")
                            }
                            break
                        }
                    }
                }
            }
            
            // 3. THIRD PRIORITY: Window title matching
            if let title = windowTitle, let titlePatterns = contextRule.windowTitlePatterns {
                for titlePattern in titlePatterns.prefix(config.detectionConfig.maxPatternsPerType) {
                    if matchesPattern(title, pattern: titlePattern.pattern) {
                        totalConfidence = max(totalConfidence, titlePattern.confidence)
                        matchedPatterns.append("title:\(titlePattern.pattern)")
                        if detectionSource != .both {
                            detectionSource = detectionSource == .windowContent ? .both : .windowTitle
                        }
                        
                        if RuntimeConfig.enableVerboseLogging {
                            logger.debug("✅ [RULE-ENGINE] Title match: \(title) → \(contextRule.displayName)")
                        }
                        break
                    }
                }
            }
            
            // Apply confidence boost only if there are actual matches
            if !matchedPatterns.isEmpty {
                totalConfidence += contextRule.confidenceBoost
                if RuntimeConfig.enableVerboseLogging {
                    logger.debug("🚀 [RULE-ENGINE] Applied confidence boost of \(contextRule.confidenceBoost) for \(contextRule.displayName) with matches: \(matchedPatterns)")
                }
            }
            
            // Check if this is the best match so far
            // For email context, require actual pattern matches (no confidence from just being a valid browser)
            let requiresPatternMatch = (contextType == .email)
            let hasValidMatch = !requiresPatternMatch || !matchedPatterns.isEmpty
            
            if hasValidMatch && totalConfidence >= config.detectionConfig.minimumConfidence && totalConfidence > highestConfidence {
                highestConfidence = totalConfidence
                bestMatch = DetectedContext(
                    type: contextType,
                    confidence: min(1.0, totalConfidence), // Cap at 1.0
                    matchedPatterns: matchedPatterns,
                    source: detectionSource
                )
                
                if RuntimeConfig.enableVerboseLogging {
                    logger.notice("🎯 [RULE-ENGINE] New best match: \(contextRule.displayName) (confidence: \(totalConfidence))")
                }
                
                // Early exit if we have a very high confidence match
                if totalConfidence >= 0.9 {
                    if RuntimeConfig.enableVerboseLogging {
                        logger.notice("🚀 [RULE-ENGINE] High confidence match found, stopping search")
                    }
                    break
                }
            }
        }
        
        let finalResult = bestMatch ?? createFallbackContext()
        
        // Cache the result
        cacheResult(finalResult, for: cacheKey)
        
        logger.notice("🎯 [RULE-ENGINE] Detected: \(finalResult.type.displayName)")
        
        return finalResult
    }
    
    // MARK: - Helper Methods
    
    private func createFallbackContext() -> DetectedContext {
        return DetectedContext(
            type: .none,
            confidence: 1.0,
            matchedPatterns: [],
            source: .windowTitle
        )
    }
    
    private func matchesPattern(_ text: String, pattern: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let range = NSRange(location: 0, length: text.utf16.count)
            return regex.firstMatch(in: text, options: [], range: range) != nil
        } catch {
            logger.error("❌ [RULE-ENGINE] Invalid regex pattern: \(pattern) - \(error.localizedDescription)")
            return false
        }
    }
    
    private func generateCacheKey(windowTitle: String?, appBundleId: String?, processName: String?, activeURL: String?) -> String {
        return "\(appBundleId ?? "")|\(processName ?? "")|\(activeURL ?? "")|\(windowTitle ?? "")"
    }
    
    private func getCachedResult(for key: String) -> ContextDetectionCacheEntry? {
        return cacheQueue.sync {
            return cache[key]
        }
    }
    
    private func cacheResult(_ result: DetectedContext, for key: String) {
        guard let config = config else { return }
        
        let cacheEntry = ContextDetectionCacheEntry(
            result: result,
            cacheDuration: TimeInterval(config.detectionConfig.cacheDurationSeconds)
        )
        
        cacheQueue.async(flags: .barrier) {
            self.cache[key] = cacheEntry
            
            // Clean up expired entries periodically
            if self.cache.count > 100 {
                self.cache = self.cache.filter { !$0.value.isExpired }
            }
        }
    }
}

// MARK: - DetectedContextType Extension

extension DetectedContextType {
    static func fromString(_ string: String) -> DetectedContextType {
        switch string.lowercased() {
        case "email":
            return .email
        case "code":
            return .code
        case "social_media":
            return .social
        default:
            return .none
        }
    }
}

