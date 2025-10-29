import Foundation
import AppKit
import os

/// Context types that can be dynamically detected
enum DetectedContextType: String, CaseIterable {
    case email = "email"
    case meeting = "meeting"
    case document = "document"
    case code = "code"
    case social = "social"
    case none = "none"
    
    var displayName: String {
        switch self {
        case .email: return "Email"
        case .meeting: return "Meeting"
        case .document: return "Document"
        case .code: return "Code Review"
        case .social: return "Social Media"
        case .none: return "General"
        }
    }
}

/// Result of dynamic context detection
struct DetectedContext {
    let type: DetectedContextType
    let confidence: Double // 0.0 to 1.0
    let matchedPatterns: [String]
    let source: DetectionSource
    
    enum DetectionSource {
        case windowTitle
        case windowContent
        case both
        
        var displayName: String {
            switch self {
            case .windowTitle: return "window title"
            case .windowContent: return "window content"
            case .both: return "title + content"
            }
        }
    }
}

/// Dynamic context detection service that analyzes window titles and content
/// to automatically determine the appropriate prompt enhancement
/// 
/// This service now uses a plugin-based architecture with ContextDetectorRegistry
/// to manage different context detector plugins (email, code, casual chat, etc.)
class DynamicContextDetector: ObservableObject {
    private let logger = Logger(
        subsystem: "com.jetsonai.clio",
        category: "dynamic.context"
    )
    
    /// Registry that manages all context detector plugins
    private let registry = ContextDetectorRegistry.shared
    
    /// Browser URL service for extracting URLs from browsers
    private let browserURLService = BrowserURLService.shared
    
    // MARK: - Public API
    
    /// Main detection method that analyzes window info and content
    /// Uses the registry to coordinate detection across all registered plugins
    func detectContext(windowTitle: String?, windowContent: String?) async -> DetectedContext {
        logger.notice("🔍 [DYNAMIC] Starting plugin-based context detection")
        logger.debug("🔍 [DYNAMIC] Window title: \(windowTitle ?? "nil")")
        logger.debug("🔍 [DYNAMIC] Content length: \(windowContent?.count ?? 0) chars")
        
        // Get current app bundle ID for context validation
        var appBundleId: String?
        if let frontmostApp = NSWorkspace.shared.frontmostApplication,
           let bundleId = frontmostApp.bundleIdentifier {
            appBundleId = bundleId
            logger.debug("🔍 [DYNAMIC] Current app: \(bundleId)")
        }
        
        // Extract URL if current app is a browser
        var activeURL: String?
        if let bundleId = appBundleId,
           let browserType = BrowserType.fromBundleIdentifier(bundleId) {
            logger.debug("🌐 [DYNAMIC] Detected browser: \(browserType.displayName), attempting URL extraction")
            
            do {
                let url = try await browserURLService.getCurrentURL(from: browserType)
                logger.notice("🔗 [DYNAMIC] Successfully extracted URL: \(url)")
                activeURL = url
            } catch {
                logger.debug("⚠️ [DYNAMIC] Failed to extract URL from \(browserType.displayName): \(error.localizedDescription)")
            }
        }
        
        // Use the registry to detect context across all registered plugins
        let detectedContext = registry.detectContext(
            windowTitle: windowTitle,
            windowContent: windowContent,
            appBundleId: appBundleId,
            activeURL: activeURL
        )
        
        logger.notice("✅ [DYNAMIC] Final context: \(detectedContext.type.displayName) with confidence \(detectedContext.confidence)")
        if let url = activeURL {
            logger.notice("🔗 [DYNAMIC] Used URL for context: \(url)")
        }
        return detectedContext
    }
    
    /// Get the appropriate prompt enhancement for detected context
    /// Delegates to the registry to find the appropriate detector plugin
    func getPromptEnhancement(for context: DetectedContext) -> String? {
        return registry.getPromptEnhancement(for: context)
    }
    
    /// Get the appropriate NER prompt for detected context
    /// Delegates to the registry to find the appropriate detector plugin
    func getNERPrompt(for context: DetectedContext) -> String? {
        return registry.getNERPrompt(for: context)
    }
    
    // MARK: - Registry Information
    
    /// Get information about registered detectors (for debugging/monitoring)
    func getRegisteredDetectors() -> [DetectedContextType] {
        return registry.getRegisteredContextTypes()
    }
    
    /// Get count of registered detectors
    var registeredDetectorCount: Int {
        return registry.legacyDetectorCount
    }
}