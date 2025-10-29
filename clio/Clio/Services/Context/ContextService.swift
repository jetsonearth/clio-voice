import Foundation
import os
import AppKit
import SwiftUI
import Combine
import NaturalLanguage
import CryptoKit

// MARK: - Smart Context Fingerprinting

struct ContextFingerprint {
    let windowTitle: String
    let bundleID: String
    let contentHash: String
    let timestamp: Date
    
    init(windowTitle: String, bundleID: String, content: String) {
        self.windowTitle = windowTitle
        self.bundleID = bundleID
        self.contentHash = Self.hashContent(content)
        self.timestamp = Date()
    }
    
    /// Check if the fingerprint is stale (older than maxAge seconds)
    func isStale(maxAge: TimeInterval = 30) -> Bool {
        Date().timeIntervalSince(timestamp) > maxAge
    }
    
    /// Check if this fingerprint matches another (same app + window + content)
    func matches(_ other: ContextFingerprint) -> Bool {
        // Must have same bundle ID (same app)
        guard self.bundleID == other.bundleID else { return false }
        // Policy: default strict match on title + content
        return self.windowTitle == other.windowTitle && self.contentHash == other.contentHash
    }
    
    /// Create a hash of the first 500 characters for content comparison
    private static func hashContent(_ content: String) -> String {
        let sample = String(content.prefix(500))
        let data = sample.data(using: .utf8) ?? Data()
        let digest = SHA256.hash(data: data)
        return digest.compactMap { String(format: "%02x", $0) }.joined()
    }
}

@MainActor
class ContextService: ObservableObject {
    private static weak var sharedInstance: ContextService?
    static var shared: ContextService? { sharedInstance }
    
    private let logger = Logger(
        subsystem: "com.jetsonai.clio",
        category: "context"
    )
    
    // Cache policy
    private let cacheTTLSeconds: TimeInterval = 120 // extend beyond typical recording length
    private let reuseStaleCacheAtEnd: Bool = true   // prefer reuse at end-of-recording to avoid OCR latency
    
    // Callback for triggering NER pre-warming when OCR completes
    var onOCRCompleted: ((String) -> Void)?
    
    // Reference to AIEnhancementService to access stored NER entities
    weak var aiEnhancementService: AIEnhancementService?
    
    @Published var useClipboardContext: Bool {
        didSet {
            UserDefaults.standard.set(useClipboardContext, forKey: "useClipboardContext")
        }
    }
    
    @Published var useScreenCaptureContext: Bool {
        didSet {
            UserDefaults.standard.set(useScreenCaptureContext, forKey: "useScreenCaptureContext")
        }
    }
    
    private let screenCaptureService: ScreenCaptureService
    private let entityExtractor = LocalEntityExtractor()
    private let dynamicContextDetector = DynamicContextDetector()
    
    // Store latest extracted entities for reuse
    private var lastExtractedEntities: ExtractedEntities?
    
    // Smart context caching with fingerprinting
    private var contextCache: (fingerprint: ContextFingerprint, content: String)?
    
    init() {
        self.useClipboardContext = UserDefaults.standard.bool(forKey: "useClipboardContext")
        self.useScreenCaptureContext = UserDefaults.standard.bool(forKey: "useScreenCaptureContext")
        self.screenCaptureService = ScreenCaptureService()
        
        if ContextService.sharedInstance == nil {
            ContextService.sharedInstance = self
        }
    }
    
    // MARK: - Smart Cache Validation
    
    /// Check if we should reuse cached context based on current screen state
    private func shouldReuseCache() -> (shouldReuse: Bool, cachedContent: String?) {
        guard let cache = contextCache else {
            if RuntimeConfig.enableVerboseLogging {
                logger.notice("🔍 [CACHE] No cache available")
            }
            return (false, nil)
        }
        
        // Check if cache is stale (30 second timeout)
        if cache.fingerprint.isStale(maxAge: cacheTTLSeconds) {
            if RuntimeConfig.enableVerboseLogging {
                logger.notice("⏰ [CACHE] Cache is stale (age: \(String(format: "%.1f", Date().timeIntervalSince(cache.fingerprint.timestamp)))s, ttl=\(Int(self.cacheTTLSeconds))s)")
            }
            contextCache = nil
            return (false, nil)
        }
        
        // Get current window state for comparison
        let (currentTitle, _) = screenCaptureService.getCurrentWindowInfo()
        let currentBundleID = NSWorkspace.shared.frontmostApplication?.bundleIdentifier ?? "unknown"
        
        // Create fingerprint for current state (using cached content for hash comparison)
        let currentFingerprint = ContextFingerprint(
            windowTitle: currentTitle ?? "unknown",
            bundleID: currentBundleID,
            content: cache.content // Use cached content temporarily for comparison
        )
        
        // Check if current context matches cached context
        let matches = cache.fingerprint.matches(currentFingerprint)
        
        if matches {
            if RuntimeConfig.enableVerboseLogging {
                logger.notice("✅ [CACHE] Context unchanged - reusing cache (\(cache.content.count) chars)")
            }
            return (true, cache.content)
        } else {
            if RuntimeConfig.enableVerboseLogging {
                logger.notice("🔄 [CACHE] Context changed - invalidating cache")
                logger.notice("🔄 [CACHE]   Old: \(cache.fingerprint.bundleID)|\(cache.fingerprint.windowTitle)")
                logger.notice("🔄 [CACHE]   New: \(currentBundleID)|\(currentTitle ?? "unknown")")
                logger.notice("🔄 [CACHE]   BundleID Match: \(cache.fingerprint.bundleID == currentBundleID)")
                logger.notice("🔄 [CACHE]   Title Match: \(cache.fingerprint.windowTitle == (currentTitle ?? "unknown"))")
                logger.notice("🔄 [CACHE]   Content Hash: Old=\(cache.fingerprint.contentHash.prefix(8))... New=\(currentFingerprint.contentHash.prefix(8))...")
            }
            contextCache = nil
            return (false, nil)
        }
    }
    
    // MARK: - Context Gathering
    
    func captureScreenContext() async {
        guard useScreenCaptureContext else { 
            logger.notice("⚠️ [CAPTURE DEBUG] Screen capture context is DISABLED - skipping capture")
            return 
        }
        
        // logger.notice("🎬 [CAPTURE DEBUG] Starting smart screen context capture")
        // logger.notice("🔍 [CALLBACK DEBUG] onOCRCompleted callback exists: \(self.onOCRCompleted != nil)")
        
        // Check smart cache first
        let cacheResult = shouldReuseCache()
        if cacheResult.shouldReuse, let cachedContent = cacheResult.cachedContent {
            logger.notice("♻️ [SMART-CACHE] Using cached context: \(cachedContent.count) characters")
            
            // CRITICAL FIX: Always trigger NER callback even with cached content
            if let callback = onOCRCompleted {
                logger.notice("🔥 [NER-CACHE] Triggering NER callback with cached content (\(cachedContent.count) chars)")
                callback(cachedContent)
                logger.notice("✅ [NER-CACHE] NER callback triggered with cached content")
            } else {
                logger.notice("❌ [NER-CACHE] onOCRCompleted callback is NIL")
            }
            return
        }
        
        // Perform fresh screen capture in background to avoid blocking main thread
        Task.detached(priority: .userInitiated) { [weak self] in
            guard let self = self else { return }
            
            if let capturedText = await self.screenCaptureService.captureAndExtractText() {
                await MainActor.run {
                    self.logger.notice("✅ [CAPTURE DEBUG] Screen capture successful: \(capturedText.count) characters")
                }
                
                // Create fingerprint for current context
                let (windowTitle, _) = await self.screenCaptureService.getCurrentWindowInfo()
                let bundleID = await MainActor.run {
                    NSWorkspace.shared.frontmostApplication?.bundleIdentifier ?? "unknown"
                }
                
                let fingerprint = ContextFingerprint(
                    windowTitle: windowTitle ?? "unknown",
                    bundleID: bundleID,
                    content: capturedText
                )
                
                // Store in smart cache
                await MainActor.run {
                    self.contextCache = (fingerprint: fingerprint, content: capturedText)
                    self.logger.notice("💾 [SMART-CACHE] Cached new context: \(bundleID)|\(windowTitle ?? "unknown") (\(capturedText.count) chars)")
                }
                
                // Always trigger NER pre-warming with fresh OCR text (in background)
                let callback = await MainActor.run { self.onOCRCompleted }
                if let callback = callback {
                    await MainActor.run {
                        self.logger.notice("🎯 [CALLBACK DEBUG] Executing callback with fresh content (\(capturedText.count) chars)")
                    }
                    callback(capturedText)
                    await MainActor.run {
                        self.logger.notice("🔥 [NER-TRIGGER] OCR completion callback triggered with fresh content")
                    }
                } else {
                    await MainActor.run {
                        self.logger.notice("❌ [CALLBACK DEBUG] onOCRCompleted callback is NIL - cannot trigger NER pre-warming")
                    }
                }
            } else {
                // Check if capture was blocked due to existing capture in progress
                let isCapturing = await self.screenCaptureService.isCapturing
                await MainActor.run {
                    if isCapturing {
                        self.logger.notice("⏸️ [CAPTURE DEBUG] Screen capture skipped - already in progress, will reuse results")
                    } else {
                        self.logger.notice("❌ [CAPTURE DEBUG] Screen capture failed - no text captured")
                    }
                    self.contextCache = nil
                }
            }
        }
    }
    
    func captureEndContext() async {
        let contextServiceStart = Date()
        guard useScreenCaptureContext else { return }
        
        // Use smart cached context if available (parallel optimization)
        let cacheCheckStart = Date()
        if let cache = contextCache, !cache.fingerprint.isStale(maxAge: cacheTTLSeconds) {
            let cacheCheckTime = Date().timeIntervalSince(cacheCheckStart) * 1000
            print("⏱️ [CONTEXT DETAIL] Cache check: \(String(format: "%.1f", cacheCheckTime))ms")
            logger.notice("⚡ [SMART-OPTIMIZATION] Using smart cached screen context (\(cache.content.count) chars) - skipping new capture")
            
            // Context remains in cache for potential reuse
            // DISABLED: Entity extraction too slow
            // let entities = entityExtractor.extractEntities(from: cache.content)
            // await MainActor.run {
            //     self.lastExtractedEntities = entities
            //     self.objectWillChange.send()
            // }
            return
        }
        // Optional reuse of stale cache at end-of-recording to avoid OCR latency
        if reuseStaleCacheAtEnd, let cache = contextCache {
            let age = Date().timeIntervalSince(cache.fingerprint.timestamp)
            // Reuse only when app and title both still match (policy-driven, no app hardcoding)
            let (currentTitle, _) = screenCaptureService.getCurrentWindowInfo()
            let currentBundleID = NSWorkspace.shared.frontmostApplication?.bundleIdentifier ?? "unknown"
            let isSameApp = cache.fingerprint.bundleID == currentBundleID
            let isSameTitle = cache.fingerprint.windowTitle == (currentTitle ?? "unknown")
            if isSameApp && isSameTitle {
                logger.notice("⚠️ [SMART-OPTIMIZATION] Reusing STALE cached screen context at end-of-recording (age: \(String(format: "%.1f", age))s, ttl=\(Int(self.cacheTTLSeconds))s)")
                logger.notice("⚠️ [SMART-OPTIMIZATION]   App match: \(isSameApp), Title match: \(isSameTitle)")
                return
            }
        }
        let cacheCheckTime = Date().timeIntervalSince(cacheCheckStart) * 1000
        print("⏱️ [CONTEXT DETAIL] Cache check (miss): \(String(format: "%.1f", cacheCheckTime))ms")
        
        // Policy: NEVER run OCR/NER at end-of-recording. Only snapshot window metadata.
        logger.notice("⚠️ [FALLBACK] No pre-captured context available at end-of-recording; skipping OCR/NER by policy")
        let windowInfoStart = Date()
        let (windowTitleSnapshot, _) = screenCaptureService.getCurrentWindowInfo()
        let windowInfoTime = Date().timeIntervalSince(windowInfoStart) * 1000
        print("⏱️ [CONTEXT DETAIL] Window detection: \(String(format: "%.1f", windowInfoTime))ms")
        if let title = windowTitleSnapshot {
            logger.notice("📝 [END-CONTEXT] Window snapshot: \(title)")
        }
        
        let totalContextServiceTime = Date().timeIntervalSince(contextServiceStart) * 1000
        print("⏱️ [CONTEXT DETAIL] Total ContextService: \(String(format: "%.1f", totalContextServiceTime))ms")
    }
    
    // MARK: - Context Retrieval
    
    func getClipboardContext() -> String {
        guard useClipboardContext,
              let clipboardText = NSPasteboard.general.string(forType: .string),
              !clipboardText.isEmpty else {
            return ""
        }
        return "\n\nAvailable Clipboard Context: \(clipboardText)"
    }
    
    func getScreenCaptureContext() -> String {
        guard useScreenCaptureContext else { return "" }
        
        // Use smart cached context if available
        if let cache = contextCache, !cache.fingerprint.isStale(maxAge: cacheTTLSeconds) {
            return "\n\nActive Window Context: \(cache.content)"
        }
        
        // Fallback to screen capture service (legacy compatibility)
        if let capturedText = screenCaptureService.lastCapturedText, !capturedText.isEmpty {
            return "\n\nActive Window Context: \(capturedText)"
        }
        
        return ""
    }
    
    /// Get raw OCR text directly (for NER processing)
    func getRawScreenCaptureText() -> String {
        // Use smart cached context if available
        if let cache = contextCache, !cache.fingerprint.isStale(maxAge: cacheTTLSeconds) {
            return cache.content
        }
        
        // Fallback to screen capture service (legacy compatibility)
        return screenCaptureService.lastCapturedText ?? ""
    }
    
    func getFullContextSection() -> String {
        let clipboardContext = getClipboardContext()
        let screenCaptureContext = getScreenCaptureContext()
        
        guard !clipboardContext.isEmpty || !screenCaptureContext.isEmpty else {
            return ""
        }
        
        // DEPRECATED: Legacy method - use getContextData() for new system/user prompt structure
        let contextInstructions = """
        <CONTEXT_USAGE_INSTRUCTIONS>
        Your task is to work ONLY with the content within the <TRANSCRIPT> tags.
        
        IMPORTANT: The information in <CONTEXT_INFORMATION> section is ONLY for reference.
        - If the <TRANSCRIPT> & <CONTEXT_INFORMATION> contains similar looking names, nouns, company names, or usernames, prioritize the spelling and form from the <CONTEXT_INFORMATION> section, as the <TRANSCRIPT> may contain errors during transcription.
        - Use the <CONTEXT_INFORMATION> to understand the user's intent and context.
        </CONTEXT_USAGE_INSTRUCTIONS>
        """
        return "\n\n\(contextInstructions)\n\n<CONTEXT_INFORMATION>\(clipboardContext)\(screenCaptureContext)\n</CONTEXT_INFORMATION>"
    }
    
    // MARK: - Enhanced Context with NER
    
    /// Get enhanced context with entity extraction for better AI prompts
    func getEnhancedContextSection() -> String {
        let clipboardContext = getClipboardContext()
        let enhancedScreenContext = getEnhancedScreenContext()
        
        // DEBUG: Log what we're getting from each context source
        // logger.debug("🔍 [CONTEXT DEBUG] Clipboard context: \(clipboardContext.isEmpty ? "EMPTY" : "\(clipboardContext.count) chars")")
        // logger.debug("🔍 [CONTEXT DEBUG] Enhanced screen context: \(enhancedScreenContext.isEmpty ? "EMPTY" : "\(enhancedScreenContext.count) chars")")
        
        guard !clipboardContext.isEmpty || !enhancedScreenContext.isEmpty else {
            // logger.notice("⚠️ [CONTEXT DEBUG] Both clipboard and screen context are EMPTY - returning empty context")
            return ""
        }
        
        // DEPRECATED: Legacy contextInstructions constant no longer exists
        // Use getContextData() for the new system/user prompt structure
        let contextInstructions = """
        <CONTEXT_USAGE_INSTRUCTIONS>
        Your task is to work ONLY with the content within the <TRANSCRIPT> tags.
        
        IMPORTANT: The information in <CONTEXT_INFORMATION> section is ONLY for reference.
        - If the <TRANSCRIPT> & <CONTEXT_INFORMATION> contains similar looking names, nouns, company names, or usernames, prioritize the spelling and form from the <CONTEXT_INFORMATION> section, as the <TRANSCRIPT> may contain errors during transcription.
        - Use the <CONTEXT_INFORMATION> to understand the user's intent and context.
        </CONTEXT_USAGE_INSTRUCTIONS>
        """
        let fullContext = "\n\n\(contextInstructions)\n\n<CONTEXT_INFORMATION>\(clipboardContext)\(enhancedScreenContext)\n</CONTEXT_INFORMATION>"
            if RuntimeConfig.enableVerboseLogging {
                logger.notice("✅ [CONTEXT DEBUG] Built enhanced context section with chars=\(fullContext.count)")
            }
        
        return fullContext
    }
    
    /// Get context data only (no instructions) for new prompt structure
    func getContextData() -> String {
        let clipboardContext = getClipboardContext()
        let enhancedScreenContext = getEnhancedScreenContext()
        
        // DEBUG: Log what we're getting from each context source
        // logger.debug("🔍 [CONTEXT DEBUG] Clipboard context: \(clipboardContext.isEmpty ? "EMPTY" : "\(clipboardContext.count) chars")")
        // logger.debug("🔍 [CONTEXT DEBUG] Enhanced screen context: \(enhancedScreenContext.isEmpty ? "EMPTY" : "\(enhancedScreenContext.count) chars")")
        
        if clipboardContext.isEmpty && enhancedScreenContext.isEmpty {
            return "No context available"
        }
        
        let contextData = "\(clipboardContext)\(enhancedScreenContext)"
        // logger.notice("✅ [CONTEXT DEBUG] Built context data with \(contextData.count) characters")
        
        return contextData
    }
    
    /// Get screen context enhanced with extracted entities
    func getEnhancedScreenContext() -> String {
        // DEBUG: Check each condition that could cause empty context
        // logger.debug("🔍 [SCREEN DEBUG] useScreenCaptureContext: \(self.useScreenCaptureContext)")
        // logger.debug("🔍 [SCREEN DEBUG] Smart cache available: \(self.contextCache != nil)")
        // logger.debug("🔍 [SCREEN DEBUG] Cache is stale: \(self.contextCache?.fingerprint.isStale() ?? true)")
        
        guard useScreenCaptureContext else {
            // logger.notice("⚠️ [SCREEN DEBUG] Screen capture context is DISABLED in settings")
            return ""
        }
        
        // Try smart cache first
        if let cache = contextCache, !cache.fingerprint.isStale() {
            if RuntimeConfig.enableVerboseLogging {
                logger.notice("✅ [SCREEN DEBUG] Using smart cached context: \(cache.content.count) characters")
            }
            let capturedText = cache.content
            
            // Continue with existing NER entity logic...
            // PRIORITY 1: Try to use NER entities from AIEnhancementService pre-warming
            if let aiService = aiEnhancementService,
               let storedEntities = aiService.getStoredNEREntities(),
               !storedEntities.isEmpty {
                if RuntimeConfig.enableVerboseLogging {
                    logger.notice("✅ [NER-CONTEXT] Using stored NER entities from AIEnhancementService (\(storedEntities.count) chars)")
                    logger.notice("🔍 [NER-PREVIEW] Entities: \(RuntimeConfig.truncate(storedEntities))")
                }
                return "\n\nActive Window Context: \(storedEntities)"
            }
            
            // PRIORITY 2: Fallback to cached OCR text if no NER entities available
            if RuntimeConfig.enableVerboseLogging {
                logger.notice("⚠️ [FALLBACK-CONTEXT] No NER entities available, using cached OCR text (\(capturedText.count) chars)")
            }
            return "\n\nActive Window Context: \(capturedText)"
        }
        
        // Fallback to legacy screen capture service
        guard let capturedText = screenCaptureService.lastCapturedText else {
            // logger.notice("⚠️ [SCREEN DEBUG] No context available (neither cache nor legacy capture)")
            return ""
        }
        
        guard !capturedText.isEmpty else {
            // logger.notice("⚠️ [SCREEN DEBUG] Legacy captured text is EMPTY")
            return ""
        }
        
            if RuntimeConfig.enableVerboseLogging {
                logger.notice("✅ [SCREEN DEBUG] Have captured text: \(capturedText.count) characters")
            }
        
        // PRIORITY 1: Try to use NER entities from AIEnhancementService pre-warming
        if let aiService = aiEnhancementService,
           let storedEntities = aiService.getStoredNEREntities(),
           !storedEntities.isEmpty {
            if RuntimeConfig.enableVerboseLogging {
                logger.notice("✅ [NER-CONTEXT] Using stored NER entities from AIEnhancementService (\(storedEntities.count) chars)")
                logger.notice("🔍 [NER-PREVIEW] Entities: \(RuntimeConfig.truncate(storedEntities))")
            }
            return "\n\nActive Window Context: \(storedEntities)"
        }
        
        // PRIORITY 2: Fallback to raw OCR text if no NER entities available
        if RuntimeConfig.enableVerboseLogging {
            logger.notice("⚠️ [FALLBACK-CONTEXT] No NER entities available, using raw OCR text (\(capturedText.count) chars)")
        }
        return "\n\nActive Window Context: \(capturedText)"
    }
    
    /// Get vocabulary hints from extracted entities for ASR improvement
    func getVocabularyHints() -> [String] {
        guard let entities = lastExtractedEntities else {
            return []
        }
        
        return entityExtractor.buildVocabularyHints(from: entities)
    }
    
    /// Get the latest extracted entities (for debugging/monitoring)
    func getLastExtractedEntities() -> ExtractedEntities? {
        return lastExtractedEntities
    }
    
    // MARK: - Direct Context Appending (for use without AI enhancement)
    
    func appendContextToTranscription(_ transcription: String) -> String {
        let clipboardContext = getClipboardContext()
        let screenCaptureContext = getScreenCaptureContext()
        
        guard !clipboardContext.isEmpty || !screenCaptureContext.isEmpty else {
            return transcription
        }
        
        var contextText = ""
        if !clipboardContext.isEmpty {
            contextText += "\n\n📋 Clipboard:\(clipboardContext)"
        }
        if !screenCaptureContext.isEmpty {
            contextText += "\n\n📱 Screen Context:\(screenCaptureContext)"
        }
        
        return transcription + contextText
    }

    // MARK: - Detected Context Accessor (for services like Soniox)

    /// Returns the latest detected context based on cached OCR text and current window title
    /// without triggering a fresh screen capture. If no cached content exists, falls back to
    /// the last captured text from `ScreenCaptureService`. Returns nil when no data available.
    func getLatestDetectedContext() -> DetectedContext? {
        let content: String? = {
            if let cache = contextCache, !cache.fingerprint.isStale(maxAge: cacheTTLSeconds) {
                return cache.content
            }
            let last = screenCaptureService.lastCapturedText
            return (last?.isEmpty == false) ? last : nil
        }()

        guard let windowContent = content else { return nil }
        let (windowTitle, _) = screenCaptureService.getCurrentWindowInfo()
        let appBundleId = NSWorkspace.shared.frontmostApplication?.bundleIdentifier
        // Use registry directly (synchronous) to avoid requiring async/await here
        let detected = ContextDetectorRegistry.shared.detectContext(
            windowTitle: windowTitle,
            windowContent: windowContent,
            appBundleId: appBundleId,
            processName: nil,
            activeURL: nil
        )
        return detected
    }

    // MARK: - Window Snapshot Helpers
    
    @MainActor
    func getWindowSnapshot() -> (bundleID: String?, title: String?) {
        let bundleID = NSWorkspace.shared.frontmostApplication?.bundleIdentifier
        let (title, _) = screenCaptureService.getCurrentWindowInfo()
        return (bundleID: bundleID, title: title)
    }
    
    func getContextSummaryText(limit: Int = 4000) -> String? {
        let enhanced = getEnhancedScreenContext()
        var candidate = sanitizeContextText(enhanced)
        
        if candidate == nil || candidate?.isEmpty == true {
            candidate = sanitizeContextText(getRawScreenCaptureText())
        }
        
        guard var text = candidate?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else {
            return nil
        }
        
        if text.count > limit {
            let idx = text.index(text.startIndex, offsetBy: limit)
            text = String(text[..<idx])
        }
        return text
    }
    
    private func sanitizeContextText(_ text: String?) -> String? {
        guard var raw = text, !raw.isEmpty else { return nil }
        raw = raw.replacingOccurrences(of: "\0", with: "")
        
        if let range = raw.range(of: "Active Window Context:") {
            raw = String(raw[range.upperBound...])
        }
        if let range = raw.range(of: "Available Clipboard Context:") {
            raw.removeSubrange(range.lowerBound..<raw.endIndex)
        }
        
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
