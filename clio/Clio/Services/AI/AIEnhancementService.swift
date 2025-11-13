import Foundation
import os
import SwiftData
import AppKit
import SwiftUI
import Combine

enum EnhancementPrompt {
    case transcriptionEnhancement
    case aiAssistant
}

struct EnhancementResult {
    let enhancedText: String
    let llmLatencyMs: Double
    let provider: String
    let model: String
}

enum ConnectionState {
    case cold
    case warming
    case ready
    case error
}

@MainActor
class AIEnhancementService: NSObject, ObservableObject, @preconcurrency URLSessionTaskDelegate {
    // Feature flag: allow opting in/out of streaming LLM responses
    @AppStorage("enableStreamingMode") private var useStreamingLLM: Bool = true
    // Shared persistent session for Railway/Groq connection reuse
    nonisolated(unsafe) static var sharedPersistentSession: URLSession?
    private let logger = Logger(
        subsystem: "com.jetsonai.clio",
        category: "aienhancement"
    )
    
    private let modelAccessControl = ModelAccessControl.shared
    private let subscriptionManager = SubscriptionManager.shared
    
    // Connection pre-warming state
    @Published private var connectionState: ConnectionState = .cold
    private var warmSession: URLSession?
    // Railway keep-alive handled by dedicated service
    private var isPrewarmingEnabled = false
    
    // NER results from pre-warming
    private var nerEntities: String?

    // Connection pooling for Groq sessions to optimize reuse and reduce connection overhead
    // NOTE: UNUSED for Fly.io environment - we use URLSession.shared instead
    // private lazy var groqConnectionPool: GroqConnectionPool = GroqConnectionPool(delegate: self)
    
    // Cached session for Groq to avoid creating a fresh connection every request while still
    // HTTP/3 enabled. We create it lazily the first time it's needed and reuse it afterwards.
    private var groqURLSession: URLSession?

    // Per-request correlation IDs → metrics map (debug only, not retained long-term)
    private var pendingMetrics: [String: URLSessionTaskMetrics] = [:]
    
    @Published var isEnhancementEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnhancementEnabled, forKey: "isAIEnhancementEnabled")
            if isEnhancementEnabled && selectedPromptId == nil {
                selectedPromptId = customPrompts.first?.id
            }
        }
    }

    // Editing strength (Light vs Full). UI persists to UserDefaults; we mirror it here.
    @Published var editingStrength: AIEditingStrength = {
        let raw = UserDefaults.standard.string(forKey: "ai.editingStrength") ?? AIEditingStrength.full.rawValue
        return AIEditingStrength(rawValue: raw) ?? .full
    }() {
        didSet {
            UserDefaults.standard.set(editingStrength.rawValue, forKey: "ai.editingStrength")
        }
    }
    
    @Published var useEnhancementTabSettings: Bool {
        didSet {
            UserDefaults.standard.set(useEnhancementTabSettings, forKey: "useEnhancementTabSettings")
        }
    }
    
    @Published var customPrompts: [CustomPrompt] {
        didSet {
            if let encoded = try? JSONEncoder().encode(customPrompts) {
                UserDefaults.standard.set(encoded, forKey: "customPrompts")
            }
        }
    }
    
    @Published var selectedPromptId: UUID? {
        didSet {
            UserDefaults.standard.set(selectedPromptId?.uuidString, forKey: "selectedPromptId")
        }
    }
    
    // LLM Configuration System
    @Published var llmConfiguration: Int {
        didSet {
            UserDefaults.standard.set(llmConfiguration, forKey: "llmConfiguration")
        }
    }
    
    @Published var groqModel: String {
        didSet {
            UserDefaults.standard.set(groqModel, forKey: "groqModel")
        }
    }
    
    // Dynamic context-based prompt enhancement
    @Published var currentDetectedContext: DetectedContextType?
    private var dynamicPromptEnhancement: String?
    private var dynamicNERPrompt: String?
    
    var activePrompt: CustomPrompt? {
        allPrompts.first { $0.id == selectedPromptId }
    }
    
    var selectedPrompt: CustomPrompt? {
        activePrompt
    }
    
    var allPrompts: [CustomPrompt] {
        // Fixed-prompt build: no predefined/custom selection exposed
        return []
    }
    
    private let aiService: AIService
    private let contextService: ContextService
    private let baseTimeout: TimeInterval = 10   // Let the proxy own TTFT/fallback; do not preempt on client
    private let rateLimitInterval: TimeInterval = 0.0  // Removed rate limiting
    private var lastRequestTime: Date?
    private let modelContext: ModelContext
    
    init(aiService: AIService = AIService(), contextService: ContextService, modelContext: ModelContext) {
        // --- Phase 1: assign stored properties that don't require self ---
        self.aiService = aiService
        self.contextService = contextService
        self.modelContext = modelContext

        // Provide temporary default values to @Published vars (will be overwritten)
        self.isEnhancementEnabled = false
        self.useEnhancementTabSettings = false
        self.customPrompts = []
        self.selectedPromptId = nil
        self.llmConfiguration = 2 // Default to Config 2 (Groq-first)
        self.groqModel = "qwen" // Default to Qwen 3 32B

        // Call NSObject initialiser before using self in any computed properties / methods
        super.init()

        // --- Phase 2: finish initialisation ---
        let defaults = UserDefaults.standard

        // Enable AI Enhancement by default for all users (always on)
        defaults.set(true, forKey: "isAIEnhancementEnabled")
        self.isEnhancementEnabled = true

        if defaults.object(forKey: "useEnhancementTabSettings") == nil {
            defaults.set(true, forKey: "useEnhancementTabSettings")
        }
        self.useEnhancementTabSettings = defaults.bool(forKey: "useEnhancementTabSettings")

        // Load prompts via migration service
        self.customPrompts = PromptMigrationService.migratePromptsIfNeeded()

        if let savedPromptId = defaults.string(forKey: "selectedPromptId") {
            self.selectedPromptId = UUID(uuidString: savedPromptId)
        }

        if self.isEnhancementEnabled && (self.selectedPromptId == nil || !self.allPrompts.contains(where: { $0.id == self.selectedPromptId })) {
            self.selectedPromptId = self.allPrompts.first?.id
        }
        
        // Load LLM configuration settings - Force Config 2 (Groq primary) as new default
        defaults.set(2, forKey: "llmConfiguration") // Force Config 2 (Groq primary)
        self.llmConfiguration = 2 // Force Config 2
        
        if defaults.object(forKey: "groqModel") == nil {
            defaults.set("qwen", forKey: "groqModel") // Default to Qwen
        } else if defaults.string(forKey: "groqModel") == "maverick" {
            // Migrate old default to Qwen for consistency across devices
            defaults.set("qwen", forKey: "groqModel")
        }
        self.groqModel = defaults.string(forKey: "groqModel") ?? "qwen"

        // API key notification observer removed - proxy handles all authentication

        // Fixed-prompt build: no predefined/custom selection

        // Observe UI changes for editing strength
        NotificationCenter.default.addObserver(forName: Notification.Name("AIEditingStrengthChanged"), object: nil, queue: .main) { [weak self] _ in
            guard let self else { return }
            let raw = UserDefaults.standard.string(forKey: "ai.editingStrength") ?? AIEditingStrength.full.rawValue
            self.editingStrength = AIEditingStrength(rawValue: raw) ?? .full
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        // Clean up connection resources synchronously since we can't use async in deinit
        isPrewarmingEnabled = false
        if APIConfig.environment == .railway {
            RailwayKeepAlive.shared.stop()
        }
        warmSession?.invalidateAndCancel()
        warmSession = nil
        
        // Clean up persistent session
        persistentSession?.invalidateAndCancel()
        persistentSession = nil
        
        // Note: connectionState will be cleaned up automatically when object is deallocated
    }
    
// API key change handling removed - proxy handles all authentication
    
    // MARK: - Public: Transform selected text according to an instruction (Command Mode)
    func transformSelectedText(selected: String, instruction: String) async throws -> String {
        // Decide prompt style based on latest detected context (aligns with dictation behavior)
        let latest = contextService.getLatestDetectedContext()
        let isCodeContext = (latest?.type == .code)
        
        // Pull NER/context data (uses pre-warmed entities when available)
        let contextData = await getNERContextData()
        
        // Build system + user messages
        let systemMessage: String
        let userMessage: String
        if isCodeContext {
            // Code-aware transform
            systemMessage = """
            You are a code transformation engine. Apply the user's instruction to the provided code selection.
            - Return ONLY the transformed code with no commentary or fences.
            - Preserve semantics; format idiomatically for the detected language when reformatting.
            - If the instruction asks to add comments, include only the requested comments inline.
            """.replacingOccurrences(of: "\n", with: " ")
            userMessage = """
            Context:
            \(contextData)
            Instruction: \(instruction)
            Selection (code):
            <selection>
            \(selected)
            </selection>
            """
        } else {
            systemMessage = """
            You are a text transformation engine. Apply the user instruction to the provided selection and return ONLY the transformed text. Do not include explanations, headers, or code fences. Preserve formatting when appropriate. If the instruction asks to translate, translate faithfully. If it asks to reformat, produce the formatted text. Output plain text only.
            """.replacingOccurrences(of: "\n", with: " ")
            userMessage = """
            Context:
            \(contextData)
            Instruction: \(instruction)
            Selection:
            <selection>
            \(selected)
            </selection>
            """
        }
        let session = getURLSession()
        do {
            let result = try await makeProxyRequest(systemMessage: systemMessage, userMessage: userMessage, urlSession: session)
            // Do not run PostEnhancementFormatter here to avoid unintended normalization
            return result
        } catch {
            logger.notice("⚠️ [FALLBACK] Groq failed in transform: \(error.localizedDescription)")
            let shouldFallback = shouldFallbackToGemini(error: error)
            if shouldFallback {
                logger.notice("🤖 [FALLBACK] Attempting Gemini fallback (transform)...")
                do {
                    let fallbackResult = try await makeGeminiRequest(systemMessage: systemMessage, userMessage: userMessage, urlSession: getURLSession())
                    return fallbackResult // keep exact output; no PostEnhancementFormatter for transform
                } catch {
                    logger.notice("❌ [FALLBACK] Gemini fallback also failed: \(error.localizedDescription)")
                    throw error
                }
            } else {
                throw error
            }
        }
    }
    
    func getAIService() -> AIService? {
        return aiService
    }
    
    var isConfigured: Bool {
        // AI Enhancement uses proxy server - always configured
        return true
    }
    
    // MARK: - Connection Pre-warming
    
    /// Pre-warm the AI connection when recording starts
    func prewarmConnection() {
        // logger.notice("🔥 [PREWARM DEBUG] prewarmConnection() called - isEnhancementEnabled: \(self.isEnhancementEnabled), isConfigured: \(self.isConfigured)")
        
        guard isEnhancementEnabled && isConfigured else {
            logger.notice("🔥 Pre-warming skipped: enhancement disabled or not configured")
            return
        }
        
        // logger.notice("🔥 [PREWARM DEBUG] connectionState: \(String(describing: self.connectionState))")
        
        // Always re-run NER on Fly.io, even if the connection is already warm
        // For other environments, keep the original guard to avoid redundant work
        if APIConfig.environment != .flyio {
            guard connectionState == .cold else {
                logger.notice("🔥 Pre-warming skipped: connection already warm")
                return
            }
        }
        
        isPrewarmingEnabled = true
        connectionState = .warming
        
        if APIConfig.environment == .flyio {
            logger.notice("🔥 [PREWARM DEBUG] Pre-warming AI connection (target: Gemini), environment: \(String(describing: APIConfig.environment))")
        } else {
            logger.notice("🔥 [PREWARM DEBUG] Pre-warming AI connection for \(self.aiService.selectedProvider.rawValue), environment: \(String(describing: APIConfig.environment))")
        }
        
        // For Railway, just mark as ready - connection will be established on first actual request
        if APIConfig.environment == .railway {
            connectionState = .ready
            RailwayKeepAlive.shared.start() // Use reliable background scheduler for keep-alive
            logger.notice("🚂 [RAILWAY] Pre-warming completed - persistent session ready for use (keep-alive enabled)")
            return
        }
        
        if APIConfig.environment == .flyio {
            // logger.notice("🛩️ [FLY.IO PREWARM] Starting Fly.io NER pre-warming (forced refresh)")
            // Mark as ready immediately to avoid blocking; NER runs asynchronously and updates stored entities
            connectionState = .ready
            Task {
                do {
                    try await sendFlyioWarmingRequest()
                    logger.notice("✅ [FLY.IO] NER refresh completed successfully")
                } catch {
                    logger.notice("⚠️ [FLY.IO] NER refresh failed: \(error.localizedDescription)")
                }
            }
            return
        }
        
        if APIConfig.environment == .cloudflare {
            // Use Cloudflare Workers warmup (routes to Gemini with full NER when text provided)
            connectionState = .ready
            Task {
                do {
                    try await sendCloudflareWarmingRequest()
                    logger.notice("✅ [CFW] NER warmup completed successfully")
                } catch {
                    logger.notice("⚠️ [CFW] NER warmup failed: \(error.localizedDescription)")
                }
            }
            return
        }
        
        Task {
            do {
                try await establishWarmConnection()
                await MainActor.run {
                    self.connectionState = .ready
                    if APIConfig.environment == .railway {
                        RailwayKeepAlive.shared.start()
                    }
                    // No keep-alive for other environments
                }
                logger.notice("✅ Connection pre-warming completed successfully")
            } catch {
                await MainActor.run {
                    self.connectionState = .error
                }
                logger.error("❌ Connection pre-warming failed: \(error.localizedDescription)")
            }
        }
    }

    /// Minimal keep-alive warmup that does NOT depend on OCR or NER.
    /// Used when Offline Mode is enabled so the LLM endpoint stays warm
    /// for enhancement requests that may follow.
    func prewarmKeepAlivePing() {
        // Bypass the enhancement-enabled guard on purpose: we want the socket warm
        // even if the enhancement feature is toggled off in UI while offline.
        if APIConfig.environment == .flyio {
            // Mark ready immediately and fire-and-forget a tiny warmup request
            connectionState = .ready
            Task {
                do {
                    try await sendFlyioQuickWarmRequest()
                } catch {
                    logger.notice("⚠️ [FLY.IO] Quick warmup failed: \(error.localizedDescription)")
                }
            }
            return
        }

        // For other environments, reuse the generic establish path to prime the session
        connectionState = .warming
        Task {
            do {
                try await establishWarmConnection()
                await MainActor.run { self.connectionState = .ready }
                logger.notice("✅ [LLM-WARMUP] Keep-alive warmup completed")
            } catch {
                await MainActor.run { self.connectionState = .error }
                logger.notice("⚠️ [LLM-WARMUP] Keep-alive warmup failed: \(error.localizedDescription)")
            }
        }
    }
    
    /// Clean up warm connection when recording ends
    func cleanupConnection() {
        // For Railway we keep the session & keep-alive timer running so the socket stays warm
        if APIConfig.environment == .railway {
            logger.notice("🚂 [RAILWAY] Keeping persistent session + keep-alive timer alive between recordings")
            // Leave isPrewarmingEnabled true and DO NOT cancel the timer or session
        } else if APIConfig.environment == .flyio {
            // No cleanup needed for Fly.io
        } else {
            isPrewarmingEnabled = false
            // No keep-alive to stop for other environments
            warmSession?.invalidateAndCancel()
            warmSession = nil
            
            // Clean up connection pool for direct API
            // NOTE: UNUSED for Fly.io environment
            // groqConnectionPool.invalidateAllSessions()
            
            // If the cached Groq session was the one we just invalidated, drop the reference so that
            // the next call will create a fresh (valid) one instead of re-using an invalidated session.
            if groqURLSession != nil {
                groqURLSession = nil
            }
        }
        
        connectionState = .cold
        logger.notice("🧹 Connection cleanup completed (session resources released)")
    }
    
    private func establishWarmConnection() async throws {
        // Create a dedicated session for pre-warming
        if aiService.selectedProvider == .groq || APIConfig.environment == .railway {
            // Reuse (or lazily create) our cached session so the warm-up connection persists.
            warmSession = getGroqSession()
        } else {
            var config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = 10
            config.timeoutIntervalForResource = 30
            
            // Enable HTTP/3 (QUIC) support with TLS 1.3 for optimal performance
            if #available(macOS 12.0, iOS 15.0, *) {
                config.tlsMaximumSupportedProtocolVersion = .TLSv13
                // Let URLSession automatically negotiate HTTP/3 when available
            }
            
            warmSession = URLSession(configuration: config)
        }
        
        // Send a minimal warming request based on provider
        try await sendWarmingRequest()
    }
    
    private func sendWarmingRequest() async throws {
//        // For Railway, send HEAD request first to establish HTTP/2 connection
//        if APIConfig.environment == .railway {
//            try await sendRailwayWarmingRequest()
//            return
//        }
        
        // For Koyeb, send LLM keep-alive request to warm the connection
        if APIConfig.environment == .koyeb {
            try await sendKoyebWarmingRequest()
            return
        }
    }
    
    /// Koyeb-specific pre-warming with LLM keep-alive endpoint to establish HTTP/2 connection
    private func sendKoyebWarmingRequest() async throws {
        let keepAliveURL = URL(string: APIConfig.llmKeepAliveURL)!
        
        var request = URLRequest(url: keepAliveURL)
        request.httpMethod = "POST"
        request.timeoutInterval = 5
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Koyeb-PreWarm/1.0", forHTTPHeaderField: "User-Agent")
        request.httpBody = "{}".data(using: .utf8)
        
        // Use default session for pre-warming to enable connection pooling
        var ephemeralConfig = URLSessionConfiguration.default
        
        // Enable HTTP/3 (QUIC) support for optimal edge performance
        if #available(macOS 12.0, iOS 15.0, *) {
            ephemeralConfig.tlsMaximumSupportedProtocolVersion = .TLSv13
        }
        
        let session = URLSession(configuration: ephemeralConfig)
        
        do {
            let startTime = CFAbsoluteTimeGetCurrent()
            let (data, response) = try await session.data(for: request)
            let responseTime = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
            
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 200 {
                // Parse response to see if connection was reused during warming
                if let responseData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let connectionReused = responseData["connectionReused"] as? Bool {
                    let status = connectionReused ? "🔄 REUSED" : "🆕 NEW"
                    logger.notice("🚀 [KOYEB-WARMUP] LLM keep-alive warming successful (\(status)) in \(String(format: "%.1f", responseTime))ms")
                } else {
                    logger.notice("🚀 [KOYEB-WARMUP] LLM keep-alive warming successful in \(String(format: "%.1f", responseTime))ms")
                }
            } else {
                logger.warning("⚠️ [KOYEB-WARMUP] LLM keep-alive warming failed with status \((response as? HTTPURLResponse)?.statusCode ?? 0)")
            }
        } catch {
            logger.error("❌ [KOYEB-WARMUP] LLM keep-alive warming error: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Fly.io-specific pre-warming with NER processing for OCR context
    private func sendFlyioWarmingRequest() async throws {
        // logger.notice("🛩️ [FLY.IO-NER] sendFlyioWarmingRequest() called - starting NER processing (Gemini warmup)")
        
        // Use Gemini proxy endpoint for NER warmup (server already supports this route)
        let warmupURL = URL(string: "\(APIConfig.apiBaseURL)/llm/gemini")!
        var request = URLRequest(url: warmupURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 15
        
        // Get OCR text from context service for NER processing
        let ocrText = await getOCRTextForNER()
        // logger.notice("🛩️ [FLY.IO-NER] OCR text retrieved for NER processing: \(ocrText.count) characters")
        
        // NER system prompt selection
        // Priority:
        // 1) If current window is detected as code, use specialized code NER prompt from registry
        // 2) Otherwise, use any previously-set dynamic NER prompt
        // 3) Fallback to the default strict JSON NER prompt
        let nerSystemPrompt: String
        if let latest = contextService.getLatestDetectedContext(), latest.type == .code,
           let codeNER = ContextDetectorRegistry.shared.getNERPrompt(for: latest) {
            logger.notice("💻 [NER-DETECT] Detected code context for NER (source=\\(latest.source.displayName), conf=\\(String(format: \"%.2f\", latest.confidence)))")
            nerSystemPrompt = codeNER
            logger.notice("🧠 [NER-CODE] Using code NER prompt (\\(codeNER.count) chars)")
            logger.notice("🧠 [NER-CODE-FULL] Code NER System Prompt: \\(codeNER)")
        } else if let dynamicNERPrompt = getDynamicNERPrompt() {
            nerSystemPrompt = dynamicNERPrompt
            logger.notice("🧠 [NER-DYNAMIC] Using dynamic NER prompt for technical extraction (\\(dynamicNERPrompt.count) chars)")
            logger.notice("🧠 [NER-DYNAMIC-FULL] Dynamic NER System Prompt: \\(dynamicNERPrompt)")
        } else {
            nerSystemPrompt = """
            You are Clio's NER assistant. Clio is a personalized voice dictation app that uses the user's on-screen context
            to improve speech recognition quality and the overall experience. You will be given OCR text captured from the
            user's active window.
            
            Your tasks:
            1) Produce a short paragraph for context_summary describing what the user is doing, what they are looking at,
               and the application/workspace in use. The summary should be concise but comprehensive.
            2) Extract ONLY the following technical categories and output STRICT JSON.

            Output format: return EXACTLY one minified JSON object with these exact keys (all present):
            {
              "context_summary": string[],
              "product": string[],
              "people": string[],
              "organizations": string[],
              "location": string[]
            }

            Rules:
            - context_summary must be a concise paragraph and should always be included.
            - JSON only. No markdown, no code fences, no prose outside the JSON. No trailing commas.
            - Keys must match EXACTLY (snake_case). Only include keys that have values.
            - Values are unique, trimmed strings.
            - Exclude generic nouns, URLs, and broad topics.
            """.replacingOccurrences(of: "\n", with: " ")

            logger.notice("🧠 [NER-DEFAULT] Using strict JSON NER prompt (enhanced schema)")
            if RuntimeConfig.logNERFullInputs {
                logger.notice("🧠 [NER-DEFAULT-FULL] Default NER System Prompt: \(nerSystemPrompt)")
            }
        }
        
        let requestBody: [String: Any] = [
            // provider not required when calling dedicated Gemini route
            "text": ocrText,
            "model": "gemini-2.5-flash-lite",
            "systemPrompt": nerSystemPrompt
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let session = getURLSession()
        let startTime = CFAbsoluteTimeGetCurrent()
        let (data, response) = try await session.data(for: request)
        let responseTime = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw EnhancementError.networkError
        }
        
        if httpResponse.statusCode == 200 {
            if let responseData = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                if let provider = responseData["provider"] as? String {
                    logger.notice("🤖 [FLY.IO-NER] Server-reported provider: \(provider)")
                }
                if let enhancedText = responseData["enhancedText"] as? String, !enhancedText.isEmpty {
                    await MainActor.run {
                        self.nerEntities = enhancedText
                        logger.notice("📥 [NER-STORE] Stored NER entities: \(enhancedText.count) chars - FULL TEXT: \(enhancedText)")
                    }
                    // logger.notice("🛩️ [FLY.IO-NER] Pre-warming completed in \(String(format: "%.0f", responseTime))ms - NER entities extracted")
                } else {
                    logger.notice("🛩️ [FLY.IO] Connection pre-warmed in \(String(format: "%.0f", responseTime))ms")
                }
            } else {
                logger.notice("🛩️ [FLY.IO] Connection pre-warmed in \(String(format: "%.0f", responseTime))ms")
            }
        } else if httpResponse.statusCode == 204 {
            logger.notice("🛩️ [FLY.IO] Warmup accepted (204) in \(String(format: "%.0f", responseTime))ms")
        } else {
            logger.warning("⚠️ [FLY.IO] Pre-warming got status \(httpResponse.statusCode)")
            throw EnhancementError.networkError
        }
    }

    /// Fly.io minimal warmup that sends a tiny payload to keep the endpoint hot.
    private func sendFlyioQuickWarmRequest() async throws {
        let warmupURL = URL(string: "\(APIConfig.apiBaseURL)/llm/gemini")!
        var request = URLRequest(url: warmupURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 8
        let body: [String: Any] = [
            "text": "hello",
            "model": "gemini-2.5-flash-lite",
            "systemPrompt": "warmup"
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let session = getURLSession()
        let start = CFAbsoluteTimeGetCurrent()
        let (_, response) = try await session.data(for: request)
        let rt = (CFAbsoluteTimeGetCurrent() - start) * 1000
        if let http = response as? HTTPURLResponse, http.statusCode == 200 {
            logger.notice("✅ [FLY.IO] Quick LLM warmup succeeded in \(String(format: "%.0f", rt))ms")
        } else {
            logger.notice("⚠️ [FLY.IO] Quick LLM warmup returned status \((response as? HTTPURLResponse)?.statusCode ?? -1)")
        }
    }
    
    /// Get raw OCR text directly for NER processing, with fallback to minimal text
    private func getOCRTextForNER() async -> String {
        // Get raw OCR text directly via ContextService method
        let rawOCRText = await MainActor.run {
            contextService.getRawScreenCaptureText()
        }
        
        // If we have meaningful OCR text, use it
        if !rawOCRText.isEmpty {
            logger.notice("🎦 [NER-PREWARM] Using raw OCR text for NER: \(rawOCRText.count) characters")
            if RuntimeConfig.logNERFullInputs {
                logger.notice("🎦 [NER-INPUT-FULL] Full OCR Text Being Sent to NER: \(rawOCRText)")
            }
            return rawOCRText
        }
        
        // Fallback to minimal text for connection warming only
        logger.notice("🎬 [NER-PREWARM] No OCR available, using minimal text for connection warming")
        return "test"
    }
    
    private func waitForRateLimit() async throws {
        if let lastRequest = lastRequestTime {
            let timeSinceLastRequest = Date().timeIntervalSince(lastRequest)
            if timeSinceLastRequest < rateLimitInterval {
                try await Task.sleep(nanoseconds: UInt64((rateLimitInterval - timeSinceLastRequest) * 1_000_000_000))
            }
        }
        lastRequestTime = Date()
    }

    /// Returns optimized persistent URLSession for connection reuse
    private var persistentSession: URLSession?
    
    /// Returns the cached URLSession, creating environment-optimized version
    private func getGroqSession() -> URLSession {
        // For Koyeb, always use the centralized session manager with detailed timing
        if APIConfig.environment == .koyeb {
            // Set this service as delegate to capture URLSessionTaskDelegate metrics
            KoyebSessionManager.shared.setTaskDelegate(self)
            let session = KoyebSessionManager.shared.session
            KoyebSessionManager.shared.logSessionIdentity(context: "AIEnhancementService.getGroqSession")
            logger.notice("🚀 [KOYEB] Using centralized session for connection reuse with detailed timing")
            return session
        }
        
        // For Railway, use persistent connections optimized for HTTP/2
        if APIConfig.environment == .railway {
            if let session = persistentSession {
                AIEnhancementService.sharedPersistentSession = session
                return session
            }
            
            var config = URLSessionConfiguration.default  // Changed from ephemeral
            
            // Force HTTP/2 instead of HTTP/3 (QUIC) to avoid connection instability
            if #available(macOS 12.0, iOS 15.0, *) {
                config.tlsMaximumSupportedProtocolVersion = .TLSv13
            }
            
            // HTTP/3 optimization for Railway edge connections
            config.httpMaximumConnectionsPerHost = 6  // HTTP/3 can handle more concurrent streams
            config.httpShouldUsePipelining = false  // Let HTTP/3 or HTTP/2 handle multiplexing
            config.httpShouldSetCookies = true
            
            // Connection persistence settings
            config.timeoutIntervalForRequest = 60  // Per-request timeout (under Railway's 6.9min limit)  
            config.timeoutIntervalForResource = 120  // 2 minutes - matches Railway edge proxy limits
            config.waitsForConnectivity = true
            config.allowsCellularAccess = true
            
            // Optimize for persistent connections
            config.requestCachePolicy = .reloadIgnoringLocalCacheData
            // config.urlCache = nil  // ← FIXED: Removed to enable connection caching and reuse
            
            // Multipath TCP for better performance (iOS only)
            #if os(iOS)
            config.multipathServiceType = .interactive
            #endif
            
            let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
            persistentSession = session
            AIEnhancementService.sharedPersistentSession = session
            
            logger.notice("🚂 [RAILWAY] Created persistent HTTP/2 session for connection reuse")
            return session
        }
        
        // For direct Groq API, use the original configuration
        if let s = groqURLSession { return s }

        var config = URLSessionConfiguration.default  // Changed from ephemeral to enable connection pooling
        if #available(macOS 12.0, iOS 15.0, *) {
            config.tlsMaximumSupportedProtocolVersion = .TLSv13  // Changed from TLSv12 to TLSv13 for HTTP/2
        }

        // Enable pipelining for faster reuse & set delegate for metrics collection
        config.httpShouldUsePipelining = true

        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        groqURLSession = session
        return session
    }

    // MARK: - URLSessionTaskDelegate for detailed timing

    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        guard let requestId = task.originalRequest?.value(forHTTPHeaderField: "X-Request-Id") else { return }
        pendingMetrics[requestId] = metrics
        
        // Record metrics for HTTP protocol performance analysis
        let endpoint = task.originalRequest?.url?.path ?? "unknown"
        if let httpMetric = HTTPProtocolMetrics.shared.createMetric(from: metrics, requestId: requestId, endpoint: endpoint) {
            HTTPProtocolMetrics.shared.recordMetric(httpMetric)
        }
        
        // Log session identity for Koyeb connections
        if APIConfig.environment == .koyeb {
            KoyebSessionManager.shared.logSessionIdentity(context: "URLSessionTaskDelegate.didFinishCollecting for \(requestId)")
        }
        
        // Debug: Check if we have any transaction metrics at all
        logger.notice("🔍 [METRICS DEBUG] Total transactions: \(metrics.transactionMetrics.count)")
        if metrics.transactionMetrics.isEmpty {
            logger.warning("⚠️ [METRICS DEBUG] No transaction metrics available!")
            return
        }

        if let transaction = metrics.transactionMetrics.first {
            let reused = transaction.isReusedConnection
            let dns = durationMs(from: transaction.domainLookupStartDate, to: transaction.domainLookupEndDate)
            let tcp = durationMs(from: transaction.connectStartDate, to: transaction.connectEndDate)
            let tls = durationMs(from: transaction.secureConnectionStartDate, to: transaction.secureConnectionEndDate)
            let ttfb = durationMs(from: transaction.requestStartDate, to: transaction.responseStartDate)
            let download = durationMs(from: transaction.responseStartDate, to: transaction.responseEndDate)
            let total = dns + tcp + tls + ttfb + download

            // Railway-specific logging with connection reuse analysis
            if APIConfig.environment == .railway {
                logger.notice("🚂 [RAILWAY METRICS] id:\(requestId)")
                logger.notice("🚂   Connection Reused: \(reused)")
                logger.notice("🚂   DNS Lookup: \(dns)ms")
                logger.notice("🚂   TCP Connect: \(tcp)ms") 
                logger.notice("🚂   TLS Handshake: \(tls)ms")
                logger.notice("🚂   Time to First Byte: \(ttfb)ms")
                logger.notice("🚂   Download Time: \(download)ms")
            } else if APIConfig.environment == .koyeb {
                // Calculate handshake overhead and meaningful metrics
                let handshakeTime = max(0, dns) + max(0, tcp) + max(0, tls)
                let meaningfulTotal = (ttfb > 0 ? ttfb : 0) + (download > 0 ? download : 0) + (reused ? 0 : handshakeTime)
                let networkProtocol = transaction.networkProtocolName ?? "unknown"
                
                // Clean, concise logging with key metrics - use actual protocol in prefix
                let protocolPrefix = networkProtocol.uppercased()
                if reused {
                    logger.notice("🚀 [\(protocolPrefix)] \(meaningfulTotal)ms total (TTFB: \(ttfb)ms, reused: ✅) | Protocol: \(networkProtocol) | Handshake saved: ~\(handshakeTime > 0 ? handshakeTime : 200)ms")
                } else {
                    logger.notice("🚀 [\(protocolPrefix)] \(meaningfulTotal)ms total (TTFB: \(ttfb)ms, reused: ❌) | Protocol: \(networkProtocol) | Handshake cost: \(handshakeTime)ms")
                }
                
                // Show detailed timestamps for debugging
                logDetailedTimestamps(transaction, requestId: requestId)
            } else {
                logger.notice("📊 [DETAILED NETWORK METRICS] id:\(requestId)")
                logger.notice("📊   Connection Reused: \(reused)")
                logger.notice("📊   DNS Lookup: \(dns)ms")
                logger.notice("📊   TCP Connect: \(tcp)ms") 
                logger.notice("📊   TLS Handshake: \(tls)ms")
                logger.notice("📊   Time to First Byte: \(ttfb)ms")
                logger.notice("📊   Download Time: \(download)ms")
                logger.notice("📊   Total Network Time: \(total)ms")
            }
            
            // Brief analysis
            logger.notice("🔍 [NETWORK] \(total)ms total, \(APIConfig.environment.displayName) environment")
        }
    }

    // Helper to safely compute durations in milliseconds
    private func durationMs(from start: Date?, to end: Date?) -> Int {
        guard let s = start, let e = end else { return -1 }
        return Int(e.timeIntervalSince(s) * 1000)
    }
    
    // Helper to get meaningful duration for display (shows "N/A" for reused connections)
    private func displayDuration(ms: Int, isReused: Bool, label: String) -> String {
        if ms == -1 && isReused {
            return "N/A (reused)"
        } else if ms == -1 {
            return "N/A"
        } else {
            return "\(ms)ms"
        }
    }
    
    // Helper to show detailed timestamp info for debugging
    private func logDetailedTimestamps(_ transaction: URLSessionTaskTransactionMetrics, requestId: String) {
        // Only log key timestamps for debugging if needed
        if transaction.requestStartDate != nil && transaction.responseStartDate != nil {
            logger.notice("🔍 [\(requestId)] Request: \(transaction.requestStartDate!.timeIntervalSince1970) → Response: \(transaction.responseStartDate!.timeIntervalSince1970)")
        }
    }

    // MARK: - Networking helper
    private func getURLSession() -> URLSession {
        // For Koyeb, use centralized session for connection reuse
        if APIConfig.environment == .koyeb {
            return getGroqSession()  // Returns centralized Koyeb session
        }
        
        // For Railway, use persistent session to enable connection reuse
        if APIConfig.environment == .railway {
            return getGroqSession()  // Returns Railway-optimized persistent session
        }
        
        // For Fly.io or Cloudflare proxy, use a shared tuned session to maximize connection reuse
        if APIConfig.environment == .flyio || APIConfig.environment == .cloudflare {
            return ProxySessionManager.shared.session
        }
        
        // For Groq direct API, use connection pool
        // NOTE: UNUSED for Fly.io environment - this code path is never reached
        // if aiService.selectedProvider == .groq {
        //     return groqConnectionPool.getWarmSession()
        // }
        return URLSession.shared
    }
    
    /// Return a URLSession to the connection pool after use
    private func returnURLSession(_ session: URLSession) {
        // For Koyeb, keep centralized session alive (don't return to pool)
        if APIConfig.environment == .koyeb {
            // Don't return Koyeb session - it's managed centrally
            logger.notice("🚀 [KOYEB] Keeping centralized session alive for connection reuse")
            return
        }
        
        // For Railway, keep persistent session alive (don't return to pool)
        if APIConfig.environment == .railway {
            // Don't return Railway session - keep it persistent for connection reuse
            logger.notice("🛜 [PROXY] Keeping persistent session alive for connection reuse")
            return
        }
        
        // For direct Groq API, use connection pool
        // NOTE: UNUSED for Fly.io environment - this code path is never reached
        // if aiService.selectedProvider == .groq {
        //     groqConnectionPool.returnSession(session)
        // }
        // For non-Groq providers, we use URLSession.shared which doesn't need cleanup
    }
    
    private func getSystemMessage(for mode: EnhancementPrompt) -> String {
        logger.notice("🚨 [PROMPT-DEBUG] getSystemMessage called with mode: \(mode == .aiAssistant ? "aiAssistant" : "transcriptionEnhancement")")
        
        if mode == .aiAssistant {
            // For AI assistant mode, use the legacy assistant system prompt
            logger.notice("🚨 [PROMPT-DEBUG] RETURNING ASSISTANT MODE PROMPT")
            return AIPrompts.assistantMode
        }
        
        // For transcription enhancement, choose based on user editing strength
        let modeLabel = (editingStrength == .light) ? "LIGHT" : "FULL"
        logger.notice("🚨 [PROMPT-DEBUG] RETURNING TRANSCRIPTION PROMPT (\(modeLabel))")
        switch editingStrength {
        case .light:
            return AIPrompts.lightEditingPrompt()
        case .full:
            return AIPrompts.fullEditingPrompt()
        }
    }
    
    private func getUserMessage(text: String, mode: EnhancementPrompt) async -> String {
        // Get mode-specific task instructions
        let taskInstructions = getTaskInstructions(for: mode)
        
        // Get dictionary terms
        let dictionaryTerms = getDictionaryTerms()
        
        // Get context data - prefer NER entities from pre-warming, with wait if needed
        let contextData = await getNERContextData()
        
        // DEBUG: Log context data to verify it's being captured
        if contextData == "No context available" {
            logger.notice("⚠️ [CONTEXT DEBUG] Context data is EMPTY - no screen context captured")
        } else {
            // logger.notice("✅ [CONTEXT DEBUG] Context data has \(contextData.count) characters")
            // logger.debug("📄 [CONTEXT DEBUG] Context content: \(contextData)")
        }
        
        // Use leaner template for generic transcription enhancement to save tokens
        // IMPORTANT: userPromptTemplateNoDictionary has two placeholders: CONTEXT then TRANSCRIPT.
        // Pass arguments in the correct order and do NOT include taskInstructions here.
        return String(format: AIPrompts.userPromptTemplateNoDictionary, contextData, text)
    }
    
    /// Get stored NER entities from pre-warming (public accessor for ContextService)
    @MainActor
    func getStoredNEREntities() -> String? {
        // logger.notice("🔍 [NER-ACCESS] ContextService requesting stored NER entities - available: \(self.nerEntities != nil)")
        
        if let entities = nerEntities, !entities.isEmpty {
            // logger.notice("✅ [NER-ACCESS] Returning NER entities to ContextService (\(entities.count) chars)")
            return entities
        }
        
        // logger.notice("❌ [NER-ACCESS] No NER entities available for ContextService")
        return nil
    }
    
    /// Get context data prioritizing NER entities from pre-warming, with brief wait if needed
    @MainActor
    private func getNERContextData() async -> String {
        // DEBUG: Log current state
        // logger.notice("🔍 [NER-DEBUG] getNERContextData called - nerEntities exists: \(self.nerEntities != nil), connectionState: \(String(describing: self.connectionState))")
        
        // If NER pre-warming is still in progress, wait for it to complete (no timeout needed - ASR is much longer)
        if connectionState == .warming {
            // logger.notice("⏱️ [NER-WAIT] Pre-warming in progress, waiting for completion...")
            
            let startWait = CFAbsoluteTimeGetCurrent()
            while connectionState == .warming {
                try? await Task.sleep(nanoseconds: 50_000_000) // 50ms check interval
            }
            let waitTime = (CFAbsoluteTimeGetCurrent() - startWait) * 1000
            // logger.notice("✅ [NER-WAIT] Pre-warming completed after \(String(format: "%.1f", waitTime))ms")
        }
        
        // First try to use NER entities from pre-warming
        if let nerEntities = nerEntities, !nerEntities.isEmpty {
            // logger.notice("✅ [NER-CONTEXT] Using NER entities from pre-warming (\(nerEntities.count) chars)")
            // logger.notice("🔍 [NER-CONTENT] NER entities preview: \(String(nerEntities.prefix(200)))...")
            // Clear NER entities after successful use to avoid stale data
            self.nerEntities = nil
            
            // Attempt to parse and format the NER JSON into a compact, per-line context string
            if let formatted = Self.formatNERContextForPrompt(fromJSON: nerEntities, perLine: true) {
                return formatted
            }
            
            // Fallback: return raw JSON if parsing fails
            return "NER Context Entities:\n\(nerEntities)"
        } else {
            if let entities = self.nerEntities {
                logger.notice("❌ [NER-DEBUG] NER entities exist but empty: \(entities.isEmpty)")
            } else {
                logger.notice("❌ [NER-DEBUG] NER entities is nil")
            }
        }
        
        // No fallback to raw OCR - use no context when NER fails/empty
        logger.notice("🚫 [NO-FALLBACK] NER not available, using no context (clean transcript only)")
        return "No context available"
    }
    
    /// Extract the first valid JSON object from a string (handles code fences and concatenated JSON)
    private static func firstJSONObjectString(in text: String) -> String? {
        // Strip common code fences that may appear despite instructions
        var s = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.hasPrefix("```") {
            // Remove leading fence
            if let range = s.range(of: "\n") {
                s = String(s[range.upperBound...])
            }
        }
        if s.hasSuffix("```") {
            if let range = s.range(of: "```", options: .backwards) {
                s = String(s[..<range.lowerBound])
            }
        }
        
        // Find the first balanced JSON object
        var depth = 0
        var started = false
        var startIndex: String.Index?
        for (i, ch) in s.enumerated() {
            let idx = s.index(s.startIndex, offsetBy: i)
            if ch == "{" {
                if !started {
                    started = true
                    startIndex = idx
                }
                depth += 1
            } else if ch == "}" {
                if started {
                    depth -= 1
                    if depth == 0, let start = startIndex {
                        return String(s[start...idx])
                    }
                }
            }
        }
        return nil
    }
    
    /// Format NER JSON into a compact prompt-ready context string
    private static func formatNERContextForPrompt(fromJSON jsonString: String, perLine: Bool = true) -> String? {
        // Extract the first valid JSON object (handles code fences and concatenated payloads)
        guard let jsonObjectString = firstJSONObjectString(in: jsonString),
              let data = jsonObjectString.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }

        // Helper: tolerant extractor supporting array-or-string values and multiple alias keys
        func values(for keys: [String]) -> [String] {
            for k in keys {
                // Array form
                if let list = obj[k] as? [Any] {
                    let v = list.compactMap { ($0 as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) }
                                .filter { !$0.isEmpty }
                    if !v.isEmpty { return v }
                }
                // String form
                if let s = obj[k] as? String {
                    let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmed.isEmpty { return [trimmed] }
                }
            }
            return []
        }

        // Canonical categories with common aliases (to match your current NER prompts)
        let summary       = values(for: ["context_summary", "context summary"]) // string or string[]
        let classes       = values(for: ["classes"]) 
        let components    = values(for: ["components"]) 
        let functionNames = values(for: ["function_names", "function names"]) 
        let files         = values(for: ["files", "filenames"]) 
        let frameworks    = values(for: ["frameworks"]) 
        let packages      = values(for: ["packages", "libs", "libraries"]) 
        let variables     = values(for: ["variables", "vars"]) 
        let services      = values(for: ["services"]) 
        // Important: accept singular/plural and spaced variants from prompts
        let products      = values(for: ["products", "product", "product_names", "product names"]) 
        let people        = values(for: ["people", "persons"]) 
        let organizations = values(for: ["organizations", "orgs"]) 
        let locations     = values(for: ["locations", "location"]) 
        // Intentionally ignore generic entity lists (too vague) such as
        // "entities", "entity", "meaningful entities", or "meaningful_entities".
        // We do not extract or render them in the context block.
        let entities: [String] = []

        var lines: [String] = []
        if !summary.isEmpty {
            // Join array-of-sentences into one paragraph
            lines.append("Context Summary: " + summary.joined(separator: " "))
        }

        lines.append("Key Entities:")

        func section(_ title: String, _ items: [String], prefixFileWithAt: Bool = false) {
            guard !items.isEmpty else { return }
            // Category header on its own line (no bullet), followed by indented items
            lines.append("  \(title):")
            for item in items {
                if prefixFileWithAt {
                    lines.append("    - @\(item)")
                } else {
                    lines.append("    - \(item)")
                }
            }
        }
        section("Classes", classes)
        section("Components", components)
        section("Functions", functionNames)
        section("Files", files, prefixFileWithAt: true)
        section("Frameworks", frameworks)
        section("Packages", packages)
        section("Variables", variables)
        section("Services", services)
        section("Products", products)
        section("People", people)
        section("Organizations", organizations)
        section("Locations", locations)
        // Omit generic entity sections from the context information

        let result = lines.joined(separator: "\n")
        return result.isEmpty ? nil : result
    }
    
    private func getDictionaryTerms() -> String {
        guard let data = UserDefaults.standard.data(forKey: "CustomDictionaryItems") else {
            return "No custom terms"
        }
        
        guard let savedItems = try? JSONDecoder().decode([DictionaryItem].self, from: data) else {
            return "No custom terms"
        }
        
        let enabledWords = savedItems.filter { $0.isEnabled }.map { $0.word }
        
        if enabledWords.isEmpty {
            return "No custom terms"
        }
        
        return enabledWords.joined(separator: ", ")
    }
    
    private func getTaskInstructions(for mode: EnhancementPrompt) -> String {
        if mode == .aiAssistant {
            return "Provide a helpful response to the user's query:"
        }
        
        // For transcription enhancement mode
        // If selectedPromptId is nil, it means "Default Configuration" - use default prompt from PromptTemplates
        if selectedPromptId == nil {
            if let defaultTemplate = PromptTemplates.all.first(where: { $0.title == "Default" }) {
                return defaultTemplate.promptText
            }
            // Fall through to global editing strength baseline
            switch editingStrength {
            case .light: return AIPrompts.lightEditingPrompt()
            case .full:  return AIPrompts.fullEditingPrompt()
            }
        }
        
        guard let activePrompt = activePrompt else {
            return "Clean this transcript while maintaining natural tone."
        }
        
        // Assistant predefined id not used; rely on mode
        
        return activePrompt.promptText
    }
    
    private func makeRequest(text: String, mode: EnhancementPrompt, retryCount: Int = 0) async throws -> String {
        let stepTimer = CFAbsoluteTimeGetCurrent()
        
        guard isConfigured else {
            logger.error("AI Enhancement: API not configured")
            throw EnhancementError.notConfigured
        }
        
        guard !text.isEmpty else {
            logger.error("AI Enhancement: Empty text received")
            throw EnhancementError.emptyText
        }
        
        let systemMessage = getSystemMessage(for: mode)
        let userMessage = await getUserMessage(text: text, mode: mode)
        print("🔍 [DEBUG] Message generation: \(Int((CFAbsoluteTimeGetCurrent() - stepTimer) * 1000))ms")
        
        if RuntimeConfig.logFullPrompt {
            logger.notice("🛰️ Sending to AI provider: \(self.aiService.selectedProvider.rawValue, privacy: .public)")
            logger.notice("🧠 [PROMPT FULL] System Message (\(systemMessage.count) chars): \(systemMessage, privacy: .public)")
            logger.notice("🧠 [PROMPT FULL] User Message (\(userMessage.count) chars): \(userMessage, privacy: .public)")
        } else if RuntimeConfig.enableVerboseLogging {
            logger.notice("🛰️ Sending to AI provider: \(self.aiService.selectedProvider.rawValue, privacy: .public)")
            logger.debug("System Message: \(RuntimeConfig.truncate(systemMessage), privacy: .public)")
            logger.debug("User Message: \(RuntimeConfig.truncate(userMessage), privacy: .public)")
        } else {
            logger.notice("🛰️ Sending to AI provider: \(self.aiService.selectedProvider.rawValue, privacy: .public)")
        }
        
        // Always use Railway proxy - no direct API fallback
        
        // Use Clio Online proxy instead of direct API calls
        let urlSession = getURLSession()
        
        do {
            // Send to LLM proxy (server owns TTFT + fallback policy)
            logger.notice("🌐 Sending request to LLM proxy (provider auto-selected by server)...")
            let result = try await makeProxyRequest(systemMessage: systemMessage, userMessage: userMessage, urlSession: urlSession)
            let final = PostEnhancementFormatter.apply(result)
            
            // Return session to pool after successful use
            returnURLSession(urlSession)
            
            logger.notice("✅ Enhancement request via proxy succeeded")
            return final
        } catch {
            logger.notice("⚠️ [FALLBACK] Groq failed: \(error.localizedDescription)")
            
            // Check if this is a fallback-worthy error
            let shouldFallback = shouldFallbackToGemini(error: error)
            
            // GPT o3's fix: Check for SSL corruption errors and invalidate session for next request
            if let nsError = error as? NSError,
               nsError.domain == NSURLErrorDomain,
               nsError.code == NSURLErrorSecureConnectionFailed || nsError.code == -1200 {
                logger.notice("🔧 [SSL-RECOVERY] Detected SSL corruption (\(nsError.code)), invalidating session for next request")
                
                // For Koyeb, invalidate centralized session
                if APIConfig.environment == .koyeb {
                    KoyebSessionManager.shared.invalidateSession()
                } else {
                    // Invalidate the corrupted session to force fresh connection next time
                    persistentSession?.invalidateAndCancel()
                    persistentSession = nil
                }
            }
            
            // Return session to pool even on error
            returnURLSession(urlSession)
            
            // Try Gemini fallback if appropriate
            if shouldFallback {
                logger.notice("🤖 [FALLBACK] Attempting Gemini fallback...")
                do {
                    let fallbackResult = try await makeGeminiRequest(systemMessage: systemMessage, userMessage: userMessage, urlSession: getURLSession())
                    logger.notice("✅ [FALLBACK] Gemini succeeded")
                    return PostEnhancementFormatter.apply(fallbackResult)
                } catch {
                    logger.notice("❌ [FALLBACK] Gemini also failed: \(error.localizedDescription)")
                    throw error
                }
            } else {
                // Not a fallback-worthy error, just throw it
                throw error
            }
        }
    }
    
    /// Make request through Clio Online proxy (routes to appropriate endpoint based on config)
    private func makeProxyRequest(systemMessage: String, userMessage: String, urlSession: URLSession) async throws -> String {
        let overallStartTime = CFAbsoluteTimeGetCurrent()
        
        // Skip rate limiting for proxy requests (handled server-side)
        
        // Prepare request - Route to correct endpoint based on configuration
        let requestPrepStartTime = CFAbsoluteTimeGetCurrent()
        
        // Route to appropriate endpoint based on configuration
        let endpointURL: String
        var requestBody: [String: Any] = [
            "text": userMessage,
            "systemPrompt": systemMessage
        ]
        // Respect streaming flag; when disabled, request JSON response
        if useStreamingLLM {
            requestBody["stream"] = true
        }
        
        if self.llmConfiguration == 1 {
            // Config 1: Gemini primary - use dedicated Gemini endpoint
            endpointURL = APIConfig.geminiProxyURL
            requestBody["model"] = "gemini-2.5-flash"  // Use regular flash for enhancement
            logger.notice("🎯 [CONFIG-DEBUG] Config 1: Routing to Gemini endpoint (\(APIConfig.geminiProxyURL))")
        } else {
            // Config 2: Groq primary - use Groq proxy endpoint  
            endpointURL = APIConfig.llmProxyURL
            requestBody["groqModel"] = self.groqModel
            logger.notice("🎯 [CONFIG-DEBUG] Config 2: Routing to Groq endpoint (\(APIConfig.llmProxyURL)) with model: \(self.groqModel)")
        }
        
        // Force non-stream JSON on servers that support the toggle (CFW implemented; Fly may ignore)
        let finalEndpointURL: String = {
            guard useStreamingLLM == false else { return endpointURL }
            let sep = endpointURL.contains("?") ? "&" : "?"
            return endpointURL + "\(sep)stream=0"
        }()

        let proxyURL = URL(string: finalEndpointURL)!
        var request = URLRequest(url: proxyURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if useStreamingLLM {
            request.addValue("text/event-stream", forHTTPHeaderField: "Accept")
        }
        request.timeoutInterval = baseTimeout
        
        let correlationId = UUID().uuidString
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        request.addValue(correlationId, forHTTPHeaderField: "X-Request-Id")
        let requestPrepTime = CFAbsoluteTimeGetCurrent() - requestPrepStartTime
        logger.notice("📝 [TIMING] Request preparation: \(String(format: "%.1f", requestPrepTime * 1000))ms")

        // Step 3: Network request
        logger.notice("🌐 [DEBUG] Sending request to proxy...")
        let networkStartTime = CFAbsoluteTimeGetCurrent()
        
        // Handle SSE streaming response
        let (data, response) = try await urlSession.data(for: request)
        let networkTime = CFAbsoluteTimeGetCurrent() - networkStartTime
        logger.notice("🌐 [DEBUG] Proxy response received in \(Int(networkTime * 1000))ms")
        
        // Step 4: Response processing
        let responseProcessStartTime = CFAbsoluteTimeGetCurrent()
        
        guard let httpResponse = response as? HTTPURLResponse else {
            logger.error("❌ [ERROR] Response is not HTTPURLResponse")
            throw EnhancementError.invalidResponse
        }
        
        // logger.notice("📊 [DEBUG] HTTP Status: \(httpResponse.statusCode)")
        // logger.notice("📋 [DEBUG] Response Headers: \(httpResponse.allHeaderFields)")
        
        // Check for fallback scenarios BEFORE processing 200 responses
        switch httpResponse.statusCode {
        case 498: // Groq Flex capacity exceeded (fail-fast)
            logger.notice("🔄 [FALLBACK] Flex capacity exceeded (498) - routing to Gemini immediately")
            throw EnhancementError.serverError // This will trigger fallback
        case 408: // Request timeout from server (proxy abort / network stall)
            logger.notice("🔄 [FALLBACK] Server timeout detected (408) - flex tier overloaded or network stall")
            throw EnhancementError.serverError // This will trigger fallback
        case 429: // Rate limit exceeded  
            logger.notice("🔄 [FALLBACK] Rate limit detected (429)")
            throw EnhancementError.rateLimitExceeded // This will trigger fallback
        case 502, 503, 504: // Bad gateway, service unavailable, gateway timeout
            logger.notice("🔄 [FALLBACK] Service unavailable (\(httpResponse.statusCode))")
            throw EnhancementError.serverError // This will trigger fallback
        default:
            break
        }

        var result: String
        switch httpResponse.statusCode {
        case 200:
            // Check if this is an SSE stream or regular JSON
            if let contentType = httpResponse.value(forHTTPHeaderField: "content-type"),
               contentType.contains("text/event-stream") {
                // Log streaming headers for visibility
                let headerKeys = [
                    "X-Route", "X-TTFT-Threshold-MS", "X-Provider-Initial", "X-Stream-Mode",
                    "X-Content-Cleaned", "X-Conn-Reuse-Threshold", "X-Request-Id"
                ]
                var headerLog: [String: String] = [:]
                for key in headerKeys {
                    if let v = httpResponse.value(forHTTPHeaderField: key) {
                        headerLog[key] = v
                    }
                }
                if !headerLog.isEmpty {
                    logger.notice("🛰️ [SSE-HEADERS] \(headerLog.map { "\($0.key): \($0.value)" }.joined(separator: " | "))")
                }
                // Parse SSE stream
                result = try parseSSEStream(data: data)
            } else {
                // Legacy JSON response (fallback)
                let responseData = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                
                // Provider-aware logging
                let provider = (responseData?["provider"] as? String) ?? "unknown"
                logger.notice("🔎 [LLM] Provider reported by server: \(provider)")
                
                // Extract accurate timing only for Groq
                if provider.lowercased() == "groq", let timing = responseData?["timing"] as? [String: Any] {
                    let clientTotal = Int(networkTime * 1000)
                    let groqActual = timing["groq_actual"] as? Int ?? 0
                    let networkOverhead = timing["network_overhead"] as? Int ?? 0
                    let proxyTotal = timing["proxy_total"] as? Int ?? 0
                    
                    // Extract standard Groq usage timing (matches dashboard)
                    var groqDashboardLatency: Int?
                    var groqTTFT: Int?
                    
                    if let usage = responseData?["usage"] as? [String: Any] {
                        // Convert from seconds to ms - this matches Groq dashboard
                        if let totalTime = usage["total_time"] as? Double {
                            groqDashboardLatency = Int(totalTime * 1000)
                        }
                        
                        // Calculate TTFT from prompt_time + queue_time  
                        let promptTime = (usage["prompt_time"] as? Double ?? 0) * 1000
                        let queueTime = (usage["queue_time"] as? Double ?? 0) * 1000
                        groqTTFT = Int(promptTime + queueTime)
                    }
                    
                    // Show comprehensive breakdown with dashboard-accurate metrics
                    var logMessage = "📊 [TIMING] Client→Proxy: \(clientTotal)ms | Proxy total: \(proxyTotal)ms"
                    
                    if let dashboardLatency = groqDashboardLatency {
                        logMessage += " | Groq dashboard: \(dashboardLatency)ms"
                        if let ttft = groqTTFT, ttft > 0 {
                            logMessage += " (TTFT: \(ttft)ms)"
                        }
                    }
                    
                    logMessage += " | Groq measured: \(groqActual)ms | Network: \(networkOverhead)ms"
                    
                    logger.notice("\(logMessage)")
                }
                
                if let enhancedText = responseData?["enhancedText"] as? String {
                    logger.notice("✅ [DEBUG] Found enhancedText field")
                    
                    // Extract and log server-side network diagnostics
                    if let networkDiagnostics = responseData?["network_diagnostics"] as? [String: Any] {
                        logServerNetworkDiagnostics(networkDiagnostics)
                        
                        // Also log the client-server timing correlation when Groq
                        if provider.lowercased() == "groq",
                           let totals = networkDiagnostics["totals"] as? [String: Any],
                           let serverTotal = totals["end_to_end"] as? Int,
                           let groqActual = totals["groq_processing"] as? Int {
                            let clientTotalMs = (CFAbsoluteTimeGetCurrent() - overallStartTime) * 1000
                            logTimingBreakdown(clientLLMMs: clientTotalMs, serverTotal: serverTotal, groqActual: groqActual)
                        }
                    } else {
                        logger.notice("🌐 [SERVER DIAGNOSTICS] No network diagnostics received from server")
                    }
                    
                    // Strip framework tags to avoid empty "<TRANSCRIPT></TRANSCRIPT>" surfacing to users
                    let cleaned = Self.stripPromptTags(enhancedText)
                    if cleaned.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        logger.notice("⚠️ [JSON] enhancedText empty after cleaning — treating as failure")
                        throw EnhancementError.enhancementFailed
                    }
                    result = cleaned
                } else if let text = responseData?["text"] as? String {
                    logger.notice("✅ [DEBUG] Found text field (legacy format)")
                    let cleanedLegacy = Self.stripPromptTags(text)
                    if cleanedLegacy.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        logger.notice("⚠️ [JSON] legacy text empty after cleaning — treating as failure")
                        throw EnhancementError.enhancementFailed
                    }
                    result = cleanedLegacy
                } else {
                    logger.error("❌ [ERROR] No valid text field found in response")
                    throw EnhancementError.invalidResponse
                }
            }
        case 401:
            throw EnhancementError.authenticationError
        case 429:
            throw EnhancementError.rateLimitExceeded
        case 500...599:
            throw EnhancementError.serverError
        default:
            throw EnhancementError.invalidResponse
        }
        
        // Step 5: Final timing breakdown
        let responseProcessTime = CFAbsoluteTimeGetCurrent() - responseProcessStartTime
        let overallTime = CFAbsoluteTimeGetCurrent() - overallStartTime
        
        // logger.notice("📊 [COMPLETE TIMING BREAKDOWN]")
        // logger.notice("📊   Request Prep: \(String(format: "%.1f", requestPrepTime * 1000))ms") 
        // logger.notice("📊   Network (Client→Proxy): \(String(format: "%.1f", networkTime * 1000))ms")
        // logger.notice("📊   Response Process: \(String(format: "%.1f", responseProcessTime * 1000))ms")
        // logger.notice("📊   Total Client Time: \(String(format: "%.1f", overallTime * 1000))ms")
        
        // Extract detailed network metrics from URLSessionTaskDelegate
        if let metrics = pendingMetrics[correlationId],
           let transaction = metrics.transactionMetrics.first {
            let reused = transaction.isReusedConnection
            let dns = durationMs(from: transaction.domainLookupStartDate, to: transaction.domainLookupEndDate)
            let tcp = durationMs(from: transaction.connectStartDate, to: transaction.connectEndDate)
            let tls = durationMs(from: transaction.secureConnectionStartDate, to: transaction.secureConnectionEndDate)
            let ttfb = durationMs(from: transaction.requestStartDate, to: transaction.responseStartDate)
            let download = durationMs(from: transaction.responseStartDate, to: transaction.responseEndDate)
            
            logger.notice("🔧 [DETAILED NETWORK BREAKDOWN]")
            logger.notice("🔧   Connection Reused: \(reused ? "✅ YES" : "❌ NO")")
            if !reused {
                logger.notice("🔧   DNS Lookup: \(dns >= 0 ? "\(dns)ms" : "N/A")")
                logger.notice("🔧   TCP Connect: \(tcp >= 0 ? "\(tcp)ms" : "N/A")")
                logger.notice("🔧   TLS Handshake: \(tls >= 0 ? "\(tls)ms" : "N/A")")
            }
            logger.notice("🔧   Time to First Byte: \(ttfb >= 0 ? "\(ttfb)ms" : "N/A")")
            logger.notice("🔧   Download Time: \(download >= 0 ? "\(download)ms" : "N/A")")
            logger.notice("🔧   Protocol: \(transaction.networkProtocolName ?? "unknown")")
            
            // Clean up metrics
            pendingMetrics.removeValue(forKey: correlationId)
        }
        
        
        // Extract server-side timing from response if available
        if let responseDict = result as? [String: Any],
           let timing = responseDict["timing"] as? [String: Any],
           let serverTotal = timing["total"] as? Int,
           let groqTime = timing["groq"] as? Int {
            let proxyOverhead = serverTotal - groqTime
            logger.notice("🌐 [SERVER-SIDE BREAKDOWN]")
            logger.notice("🌐   Proxy Processing: \(proxyOverhead)ms")
            logger.notice("🌐   Groq API Call: \(groqTime)ms")
            logger.notice("🌐   Total Server Time: \(serverTotal)ms")
            
            // Calculate where time is spent
            let clientNetwork = (networkTime * 1000) - Double(serverTotal)
            logger.notice("🔍 [LATENCY ANALYSIS]")
            logger.notice("🔍   Pure Network Latency: \(String(format: "%.1f", clientNetwork))ms (TCP+TLS+RTT)")
            logger.notice("🔍   Server Processing: \(serverTotal)ms (Proxy+Groq)")
            logger.notice("🔍   Client Overhead: \(String(format: "%.1f", (requestPrepTime + responseProcessTime) * 1000))ms")
        }
        
        logger.notice("🔍 [CONNECTION HEALTH]")
        if let responseDict = result as? [String: Any],
           let connection = responseDict["connection"] as? [String: Any] {
            if let reused = connection["reused"] as? Bool {
                logger.notice("🔍   Connection Reused: \(reused ? "✅ Yes" : "❌ No")")
            }
            if let reuseRate = connection["reuseRate"] as? String {
                logger.notice("🔍   Overall Reuse Rate: \(reuseRate)")
            }
        }
        
        return result
    }
    
    /// Cloudflare Workers warm-up with NER (Gemini) using /api/llm/warmup
    private func sendCloudflareWarmingRequest() async throws {
        // Build POST to CFW warmup endpoint; if we include text + systemPrompt, server computes NER via Gemini
        let warmupURL = URL(string: "\(APIConfig.apiBaseURL)/llm/warmup")!
        var request = URLRequest(url: warmupURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 15
        
        // Get OCR text for NER processing (same as Fly path)
        let ocrText = await getOCRTextForNER()
        
        // Use the same strict JSON NER prompt used in Fly warmup
        let nerSystemPrompt = """
        You are Clio's NER assistant. You will be given OCR text captured from the user's active window.
        Output EXACTLY one minified JSON object with keys: context_summary, product names, people, organizations, location.
        JSON only. No surrounding prose. No trailing commas. Omit empty keys.
        """.replacingOccurrences(of: "\n", with: " ")
        
        let requestBody: [String: Any] = [
            "provider": "gemini",
            "text": ocrText,
            "model": "gemini-2.5-flash-lite",
            "systemPrompt": nerSystemPrompt
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let session = getURLSession()
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw EnhancementError.networkError
        }
        
        if httpResponse.statusCode == 200 {
            if let responseData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let enhancedText = responseData["enhancedText"] as? String, !enhancedText.isEmpty {
                await MainActor.run {
                    self.nerEntities = enhancedText
                    logger.notice("📥 [NER-STORE] (CFW) Stored NER entities: \(enhancedText.count) chars")
                }
            } else {
                logger.notice("🧊 [CFW-WARMUP] Warmed without NER payload (no enhancedText)")
            }
        } else if httpResponse.statusCode == 204 {
            logger.notice("🧊 [CFW-WARMUP] Accepted (204) — minimal warmup sent")
        } else {
            logger.warning("⚠️ [CFW-WARMUP] Warmup got status \(httpResponse.statusCode)")
            throw EnhancementError.networkError
        }
    }
    
    /// Determine if we should fallback to Gemini based on the Groq error
    private func shouldFallbackToGemini(error: Error) -> Bool {
        // Check for HTTP errors first
        if let nsError = error as? NSError {
            // URL loading errors
            if nsError.domain == NSURLErrorDomain {
                switch nsError.code {
                case NSURLErrorTimedOut,
                     NSURLErrorCannotConnectToHost,
                     NSURLErrorNetworkConnectionLost,
                     NSURLErrorNotConnectedToInternet:
                    logger.notice("🔄 [FALLBACK] Network error detected: \(nsError.code)")
                    return true
                default:
                    break
                }
            }
            
            // HTTP status code errors
            if nsError.domain == "HTTPError" {
                switch nsError.code {
                case 498: // Groq Flex capacity exceeded
                    logger.notice("🔄 [FALLBACK] Groq flex capacity exceeded (498)")
                    return true
                case 408: // Request timeout (proxy abort / stall)
                    logger.notice("🔄 [FALLBACK] Groq flex timeout detected")
                    return true
                case 429: // Rate limit
                    logger.notice("🔄 [FALLBACK] Groq rate limit detected")
                    return true
                case 503, 502, 504: // Service unavailable, bad gateway, gateway timeout
                    logger.notice("🔄 [FALLBACK] Groq service unavailable")
                    return true
                default:
                    break
                }
            }
        }
        
        // Check for enhancement service errors
        if let enhancementError = error as? EnhancementError {
            switch enhancementError {
            case .rateLimitExceeded, .serverError, .networkError,
                 .invalidResponse, .enhancementFailed:
                logger.notice("🔄 [FALLBACK] Enhancement error detected: \(enhancementError)")
                return true
            default:
                break
            }
        }
        
        logger.notice("❌ [FALLBACK] Error not suitable for fallback: \(error)")
        return false
    }

    /// Remove framework prompt tags from any model output to avoid rendering tags when model echos prompt
    private static func stripPromptTags(_ s: String) -> String {
        if s.isEmpty { return s }
        var out = s
        let patterns = [
            "(?i)</?TRANSCRIPT>",
            "(?i)</?CONTEXT_INFORMATION>",
            "(?i)</?DICTIONARY_TERMS>"
        ]
        for p in patterns {
            out = out.replacingOccurrences(of: p, with: "", options: .regularExpression)
        }
        // Also strip <CLEANED> tags using literal replacement (no regex)
        out = out.replacingOccurrences(of: "<CLEANED>", with: "")
        out = out.replacingOccurrences(of: "</CLEANED>", with: "")
        return out.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Make request to Gemini API through Fly.io proxy
    private func makeGeminiRequest(systemMessage: String, userMessage: String, urlSession: URLSession) async throws -> String {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Prepare Gemini request
        let geminiURL = URL(string: "\(APIConfig.apiBaseURL)/llm/gemini")!
        var request = URLRequest(url: geminiURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 10 // Gemini timeout (longer than Groq)
        
        let requestBody: [String: Any] = [
            "text": userMessage,
            "model": "gemini-2.5-flash-lite",
            "systemPrompt": systemMessage
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        // Make request
        let (data, response) = try await urlSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw EnhancementError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            logger.error("❌ [GEMINI] HTTP error: \(httpResponse.statusCode)")
            if httpResponse.statusCode == 429 {
                throw EnhancementError.rateLimitExceeded
            } else if httpResponse.statusCode >= 500 {
                throw EnhancementError.serverError
            } else {
                throw EnhancementError.invalidResponse
            }
        }
        
        // Parse response
        guard let responseData = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let enhancedText = responseData["enhancedText"] as? String else {
            throw EnhancementError.invalidResponse
        }
        
        let duration = CFAbsoluteTimeGetCurrent() - startTime
        logger.notice("🤖 [GEMINI] Request completed in \(String(format: "%.1f", duration * 1000))ms")
        
        // Log that we used fallback
        if let diagnostics = responseData["network_diagnostics"] as? [String: Any] {
            logger.notice("🤖 [GEMINI] Used fallback provider successfully")
        }
        
        return Self.stripPromptTags(enhancedText)
    }
    
    /// Log clean network breakdown from server diagnostics
    private func logServerNetworkDiagnostics(_ diagnostics: [String: Any]) {
        // Extract essential timing data
        guard let totals = diagnostics["totals"] as? [String: Any] else { return }
        
        let groqProcessing = totals["groq_processing"] as? Int ?? 0
        
        // Extract TTFT from groq_details
        var ttft = 0
        if let groqDetails = diagnostics["groq_details"] as? [String: Any] {
            ttft = groqDetails["ttft"] as? Int ?? 0
        }
        
        // Only show actual Groq processing time (user requested: "i only want groq: 404ms, that one thing")
        logger.notice("🌐 [LLM] Groq: \(groqProcessing)ms | TTFT: \(ttft)ms")
    }
    
    /// Log network segment breakdown
    private func logTimingBreakdown(clientLLMMs: Double, serverTotal: Int, groqActual: Int) {
        // Calculate client to proxy time: total LLM time minus actual Groq processing
        // User calculation: "client <-> proxy is 1302 - 404 = 900 ish ms"
        let clientToProxyMs = Int(clientLLMMs) - groqActual
        
        logger.notice("🌐   Client↔Proxy: \(clientToProxyMs)ms")
    }
    
    /// Parse SSE stream data from Groq response
    private func parseSSEStream(data: Data) throws -> String {
        guard let streamString = String(data: data, encoding: .utf8) else {
            logger.error("❌ [SSE] Could not decode stream as UTF-8")
            throw EnhancementError.invalidResponse
        }
        
        var enhancedText = ""
        var currentEvent: String? = nil
        let lines = streamString.components(separatedBy: .newlines)
        
        for line in lines {
            if line.hasPrefix("event: ") {
                currentEvent = String(line.dropFirst(7)).trimmingCharacters(in: .whitespaces)
                continue
            }
            if line.hasPrefix("data: ") {
                let dataContent = String(line.dropFirst(6))
                if dataContent == "[DONE]" { break }
                
                // Try to parse JSON payloads
                if let data = dataContent.data(using: .utf8),
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if let evt = currentEvent {
                        switch evt {
                        case "route":
                            let route = (json["route"] as? String) ?? "?"
                            let planned = (json["planned_provider"] as? String) ?? "?"
                            let thr = (json["ttft_threshold_ms"] as? Int) ?? -1
                            logger.notice("📡 [SSE] route=\(route) planned=\(planned) ttft_threshold=\(thr)ms")
                        case "ttft":
                            if let ttft = json["ttft_ms"] as? Int {
                                logger.notice("⏱️ [SSE] TTFT=\(ttft)ms")
                            }
                        case "token":
                            if let delta = json["delta"] as? String, !delta.isEmpty {
                                enhancedText += delta
                            }
                        case "fallback":
                            let reason = (json["reason"] as? String) ?? "unknown"
                            let thr = (json["threshold_ms"] as? Int) ?? -1
                            let elapsed = (json["elapsed_ms"] as? Int) ?? -1
                            logger.notice("🔄 [SSE] Fallback triggered reason=\(reason) threshold=\(thr)ms elapsed=\(elapsed)ms")
                        case "complete":
                            let provider = (json["provider"] as? String) ?? "?"
                            let ptime = (json["provider_time_ms"] as? Int) ?? -1
                            if let content = json["content"] as? String, !content.isEmpty {
                                // Backfill if we didn't collect via tokens
                                if enhancedText.isEmpty { enhancedText = content }
                            }
                            logger.notice("✅ [SSE] complete provider=\(provider) provider_time=\(ptime)ms chars=\(enhancedText.count)")
                        case "error":
                            if let msg = json["error"] as? String {
                                logger.error("❌ [SSE] error event: \(msg)")
                            }
                        default:
                            break
                        }
                    } else {
                        // OpenAI-compatible stream chunk or default message types
                        if let choices = json["choices"] as? [[String: Any]],
                           let firstChoice = choices.first,
                           let delta = firstChoice["delta"] as? [String: Any],
                           let content = delta["content"] as? String {
                            enhancedText += content
                        } else if let type = json["type"] as? String {
                            switch type {
                            case "token":
                                if let delta = json["delta"] as? String { enhancedText += delta }
                            case "ttft":
                                if let ttft = json["ttft_ms"] as? Int { logger.notice("⏱️ [SSE] TTFT=\(ttft)ms") }
                            case "complete":
                                if let content = json["content"] as? String, !content.isEmpty, enhancedText.isEmpty { enhancedText = content }
                            case "error":
                                if let msg = json["error"] as? String { logger.error("❌ [SSE] error message: \(msg)") }
                            default:
                                break
                            }
                        }
                    }
                } else {
                    // Plain text data fallback (rare). Only accumulate when no explicit event.
                    if currentEvent == nil && !dataContent.isEmpty {
                        enhancedText += dataContent
                    }
                }
                // Reset event after processing a data frame
                currentEvent = nil
            }
        }
        
        logger.notice("✅ [SSE] Parsed streaming response: \(enhancedText.count) characters")
        let trimmed = enhancedText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        // Strip framework wrapper tags like <CLEANED>...</CLEANED> before downstream formatting
        let cleaned = Self.stripPromptTags(trimmed)
        if cleaned.isEmpty {
            throw EnhancementError.enhancementFailed
        }
        return cleaned
    }
    
    // Direct API requests removed - all requests go through proxy only
    
    /// Provides access to the shared Groq session for connection reuse across services  
    func getSharedGroqSession() -> URLSession {
        return getGroqSession()
    }
    
    func enhance(_ text: String) async throws -> String {
        logger.notice("🚀 Starting AI enhancement for text (\(text.count) characters)")
        
        // Check subscription access for AI enhancement
        do {
            try modelAccessControl.validateFeatureAccess(.aiEnhancement)
        } catch {
            logger.error("❌ AI Enhancement access denied: \(error.localizedDescription)")
            
            // Show upgrade prompt
            subscriptionManager.promptUpgrade(from: "ai_enhancement")
            throw error
        }
        
        // DISABLED: Check usage limits for AI enhancement (Pro now has unlimited access)
        // do {
        //     try modelAccessControl.validateUsageLimit(for: .unlimitedEnhancement)
        // } catch {
        //     logger.error("❌ AI Enhancement usage limit exceeded: \(error.localizedDescription)")
        //     
        //     // Show upgrade prompt
        //     subscriptionManager.promptUpgrade(from: "ai_enhancement_usage")
        //     throw error
        // }
        
        let enhancementPrompt: EnhancementPrompt = .transcriptionEnhancement
        
        // Single attempt with fallback - no retries
        do {
            let result = try await makeRequest(text: text, mode: enhancementPrompt, retryCount: 0)
            logger.notice("✅ AI enhancement completed successfully (\(result.count) characters)")
            return result
        } catch {
            logger.notice("⚠️ Both Groq and Gemini failed, returning formatted ASR transcript: \(error.localizedDescription)")
            // Ensure deterministic formatting (paragraph split + zh Hans → Hant) on fallback
            return PostEnhancementFormatter.apply(text)
        }
    }
    
    /// Enhanced version with a custom prompt string for PowerMode
    func enhanceWithCustomPrompt(_ text: String, promptText: String) async throws -> String {
        logger.notice("🚀 Starting AI enhancement with custom prompt for text (\(text.count) characters)")
        
        // Check subscription access for AI enhancement
        do {
            try modelAccessControl.validateFeatureAccess(.aiEnhancement)
        } catch {
            logger.error("❌ AI Enhancement access denied: \(error.localizedDescription)")
            subscriptionManager.promptUpgrade(from: "ai_enhancement")
            throw error
        }
        
        // DISABLED: Check usage limits for AI enhancement (Pro now has unlimited access)
        // do {
        //     try modelAccessControl.validateUsageLimit(for: .unlimitedEnhancement)
        // } catch {
        //     logger.error("❌ AI Enhancement usage limit exceeded: \(error.localizedDescription)")
        //     subscriptionManager.promptUpgrade(from: "ai_enhancement")
        //     throw error
        // }
        
        // Create system and user messages for this enhancement
        let customSystemMessage = getSystemMessageForCustomPrompt(promptText)
        let customUserMessage = getUserMessageForCustomPrompt(promptText, text: text)
        
        // Single attempt with fallback - no retries
        do {
            let result = try await makeRequestWithCustomPrompt(systemMessage: customSystemMessage, userMessage: customUserMessage, retryCount: 0)
            logger.notice("✅ AI enhancement with custom prompt completed successfully (\(result.count) characters)")
            return result
        } catch {
            logger.notice("⚠️ Both Groq and Gemini failed, returning formatted ASR transcript: \(error.localizedDescription)")
            // Ensure deterministic formatting (paragraph split + zh Hans → Hant) on fallback
            return PostEnhancementFormatter.apply(text)
        }
    }
    
    /// Dynamic enhancement with context-aware layered prompting
    func enhanceWithDynamicContext(_ text: String, windowTitle: String?, windowContent: String?) async throws -> String {
        logger.notice("🎯 Starting dynamic context-aware AI enhancement for text (\(text.count) characters)")
        
        // Respect user Style Presets first (no restart required)
        let activeBundleId = NSWorkspace.shared.frontmostApplication?.bundleIdentifier
        
        // Extract current URL if we're in a browser
        var activeHost: String?
        if let bundleId = activeBundleId,
           let browserType = BrowserType.fromBundleIdentifier(bundleId) {
            do {
                let url = try await BrowserURLService.shared.getCurrentURL(from: browserType)
                if let urlComponents = URLComponents(string: url),
                   let host = urlComponents.host {
                    activeHost = host
                    logger.debug("🌐 [PRESET] Extracted host for style preset: \(host)")
                }
            } catch {
                logger.debug("⚠️ [PRESET] Failed to extract URL from \(browserType.displayName): \(error.localizedDescription)")
            }
        }
        
        if let preset = await StylePresetStore.shared.activePreset(bundleId: activeBundleId, activeHost: activeHost) {
            logger.notice("🎯 [PRESET] Applying user style preset for bundleId=\(activeBundleId ?? "nil") in dynamic path")
            let systemMessage: String = getSystemMessage(for: .transcriptionEnhancement)
            let userMessage = getUserMessageForCustomPrompt(preset.prompt, text: text)
            return try await makeRequestWithCustomPrompt(systemMessage: systemMessage, userMessage: userMessage)
        }
        
        // Check subscription access for AI enhancement
        do {
            try modelAccessControl.validateFeatureAccess(.aiEnhancement)
        } catch {
            logger.error("❌ AI Enhancement access denied: \(error.localizedDescription)")
            subscriptionManager.promptUpgrade(from: "ai_enhancement")
            throw error
        }
        
        // DISABLED: Check usage limits for AI enhancement (Pro now has unlimited access)
        // do {
        //     try modelAccessControl.validateUsageLimit(for: .unlimitedEnhancement)
        // } catch {
        //     logger.error("❌ AI Enhancement usage limit exceeded: \(error.localizedDescription)")
        //     subscriptionManager.promptUpgrade(from: "ai_enhancement")
        //     throw error
        // }
        
        // Step 1: Detect context using dynamic detector
        let detector = DynamicContextDetector()
        let detectedContext = await detector.detectContext(windowTitle: windowTitle, windowContent: windowContent)
        
        // Enhanced debugging logging for detection accuracy analysis
        logger.notice("🎯 [DYNAMIC] Context detected: \(detectedContext.type.displayName) (confidence: \(String(format: "%.2f", detectedContext.confidence)))")
        logger.debug("🔍 [DYNAMIC] Window title: '\(windowTitle ?? "nil")'")
        // logger.debug("🔍 [DYNAMIC] Content length: \(windowContent?.count ?? 0) chars")
        logger.debug("🔍 [DYNAMIC] Detection source: \(detectedContext.source.displayName)")
        if !detectedContext.matchedPatterns.isEmpty {
            logger.debug("🔍 [DYNAMIC] Matched patterns: \(detectedContext.matchedPatterns.prefix(5).joined(separator: ", "))")
        }
        
        // Step 2: Apply layered prompting based on context
        var finalResult: String
        
        if detectedContext.type == .none {
            // No specific context detected, use standard enhancement
            logger.notice("📝 [DYNAMIC] Using standard enhancement (no specific context)")
            finalResult = try await enhance(text)
        } else if detectedContext.type == .code {
            // Code context: use dedicated code system prompt
            logger.notice("💻 [DYNAMIC] Using streamlined code system prompt for \(detectedContext.type.displayName) context")
            finalResult = try await enhanceWithCodePrompt(text)
            logger.notice("✅ [DYNAMIC] Code context enhancement completed (\(finalResult.count) characters)")
        } else {
            // Other contexts: try context-specific enhancement, fallback to standard
            logger.notice("🎨 [DYNAMIC] Applying direct \(detectedContext.type.displayName) context enhancement")
            
            if let contextEnhancement = detector.getPromptEnhancement(for: detectedContext) {
                logger.notice("🎨 [DYNAMIC] Using \(detectedContext.type.displayName) context enhancement")
                logger.debug("🎨 [DYNAMIC] Context enhancement prompt: '\(contextEnhancement.prefix(150))...'")
                finalResult = try await enhanceWithCustomPrompt(text, promptText: contextEnhancement)
                logger.notice("✅ [DYNAMIC] Context enhancement completed (\(finalResult.count) characters)")
                logger.debug("🔍 [DYNAMIC] Final enhanced text: '\(finalResult.prefix(100))...'")
            } else {
                logger.notice("⚠️ [DYNAMIC] No context enhancement available for \(detectedContext.type.displayName), using standard")
                finalResult = try await enhance(text)
            }
        }
        
        logger.notice("✅ [DYNAMIC] Dynamic context-aware enhancement completed successfully")
        return finalResult
    }
    
    /// Dynamic enhancement with context-aware layered prompting and performance tracking
    func enhanceWithDynamicContextTracking(_ text: String, windowTitle: String?, windowContent: String?, usePrewarmedContext: Bool = false) async throws -> EnhancementResult {
logger.notice("🎯 Starting dynamic context-aware AI enhancement with tracking for text (\(text.count) characters)")
        
        let startTime = CFAbsoluteTimeGetCurrent()
        // Mark LLM start for E2E timing
        TimingMetrics.shared.llmStartTs = Date()
        let enhancedText: String
        
        // SMART OPTIMIZATION: Use pre-warmed context if available to skip redundant detection
        if usePrewarmedContext && nerEntities != nil && !nerEntities!.isEmpty {
            logger.notice("⚡ [FAST-PATH] Using pre-warmed context - skipping redundant detection")
            enhancedText = try await enhanceWithPrewarmedNERContext(text)
        } else {
            logger.notice("🔄 [LEGACY-PATH] Running full context detection")
            enhancedText = try await enhanceWithDynamicContext(text, windowTitle: windowTitle, windowContent: windowContent)
        }
        
let totalLatencyMs = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
        // Mark LLM end for E2E timing
        TimingMetrics.shared.llmEndTs = Date()
        
        // Also emit structured log for LLM final text here to guarantee visibility
        StructuredLog.shared.log(cat: .transcript, evt: "llm_final", lvl: .info, ["text": enhancedText])
        
        // Return tracking result with the same format as existing methods
        return EnhancementResult(
            enhancedText: enhancedText,
            llmLatencyMs: totalLatencyMs,
            provider: aiService.selectedProvider.rawValue,
            model: usePrewarmedContext ? "prewarmed-context-enhanced" : "dynamic-context-enhanced"
        )
    }
    
    /// Fast path enhancement using pre-warmed NER context
    private func enhanceWithPrewarmedNERContext(_ text: String) async throws -> String {
        logger.notice("⚡ [PREWARMED] Using pre-warmed NER context fast-path")
        
        // First: check user Style Presets by active app/website
        let activeBundleId = NSWorkspace.shared.frontmostApplication?.bundleIdentifier
        
        // Extract current URL if we're in a browser
        var activeHost: String?
        if let bundleId = activeBundleId,
           let browserType = BrowserType.fromBundleIdentifier(bundleId) {
            do {
                let url = try await BrowserURLService.shared.getCurrentURL(from: browserType)
                if let urlComponents = URLComponents(string: url),
                   let host = urlComponents.host {
                    activeHost = host
                    logger.debug("🌐 [PRESET] Extracted host for style preset: \(host)")
                }
            } catch {
                logger.debug("⚠️ [PRESET] Failed to extract URL from \(browserType.displayName): \(error.localizedDescription)")
            }
        }
        
        if let preset = await StylePresetStore.shared.activePreset(bundleId: activeBundleId, activeHost: activeHost) {
            logger.notice("🎯 [PRESET] Applying user style preset for bundleId=\(activeBundleId ?? "nil")")
            let systemMessage: String = getSystemMessage(for: .transcriptionEnhancement)
            let userMessage = getUserMessageForCustomPrompt(preset.prompt, text: text)
            if RuntimeConfig.logFullPrompt {
                logger.notice("🧩 [PRESET-SYSTEM FULL] System: '\(systemMessage)'")
                logger.notice("🧩 [PRESET-USER FULL] User: '\(userMessage)'")
            } else {
                logger.debug("🧩 [PRESET-SYSTEM] System: '\(systemMessage)'")
                logger.debug("🧩 [PRESET-USER] User: '\(userMessage)'")
            }
            return try await makeRequestWithCustomPrompt(systemMessage: systemMessage, userMessage: userMessage)
        }
        
        // Decide prompt based on latest detected context (from cached screen content + window title)
        let latestContext = contextService.getLatestDetectedContext()
        let isCodeContext = (latestContext?.type == .code)
        
        let systemMessage: String
        let userMessage: String
        if isCodeContext {
            logger.notice("💻 [PREWARMED] Detected code context → using knob-selected system prompt")
            systemMessage = getSystemMessage(for: .transcriptionEnhancement)
            userMessage = await getCodeUserMessage(text)
            logger.debug("💻 [PREWARMED-SYSTEM] Code system prompt: '\(systemMessage)'")
            logger.debug("💻 [PREWARMED-USER] Code user prompt: '\(userMessage)'")
        } else {
            logger.notice("📝 [PREWARMED] Non-code or unknown context → using enhanced system prompt")
            logger.notice("🚨 [PROMPT-DEBUG] About to call getSystemMessage(for: .transcriptionEnhancement)")
            systemMessage = getSystemMessage(for: .transcriptionEnhancement)
            logger.notice("🚨 [PROMPT-DEBUG] About to call getUserMessage(text:, mode: .transcriptionEnhancement)")
            userMessage = await getUserMessage(text: text, mode: .transcriptionEnhancement)
            if RuntimeConfig.logFullPrompt {
                logger.notice("📝 [PREWARMED-SYSTEM FULL] Enhanced system prompt: '\(systemMessage)'")
                logger.notice("📝 [PREWARMED-USER FULL] Enhanced user prompt: '\(userMessage)'")
            } else {
                logger.debug("📝 [PREWARMED-SYSTEM] Enhanced system prompt: '\(String(systemMessage))'")
                logger.debug("📝 [PREWARMED-USER] Enhanced user prompt: '\(String(userMessage))'")
            }
        }
        
        return try await makeRequestWithCustomPrompt(systemMessage: systemMessage, userMessage: userMessage)
    }
    
    private func getSystemMessageForCustomPrompt(_ promptText: String) -> String {
        // For custom/preset prompts, use baseline selected by global editing strength
        switch editingStrength {
        case .light: return AIPrompts.lightEditingPrompt()
        case .full:  return AIPrompts.fullEditingPrompt()
        }
    }
    
    /// Code-specific enhancement using streamlined prompts
    private func enhanceWithCodePrompt(_ text: String) async throws -> String {
        let systemMessage = getSystemMessage(for: .transcriptionEnhancement)
        let userMessage = await getCodeUserMessage(text)
        
        logger.notice("💻 Sending to AI provider with streamlined code prompt")
        if RuntimeConfig.logFullPrompt {
            logger.notice("💻 [CODE-SYSTEM FULL] Code system prompt: '\(systemMessage)'")
            logger.notice("💻 [CODE-USER FULL] Code user prompt: '\(userMessage)'")
        } else {
            logger.debug("💻 [CODE-SYSTEM] Code system prompt: '\(systemMessage.prefix(150))...'")
            logger.debug("💻 [CODE-USER] Code user prompt: '\(userMessage.prefix(150))...'")
        }
        
        return try await makeRequestWithCustomPrompt(systemMessage: systemMessage, userMessage: userMessage)
    }
    
    /// Generate user message for code context with streamlined instructions
    @MainActor
    private func getCodeUserMessage(_ text: String) async -> String {
        // Get dictionary terms
        let dictionaryTerms = getDictionaryTerms()
        
        // Get context data - prefer NER entities from pre-warming
        let contextData = await getNERContextData()
        
        // Format user message with streamlined code template
        // In fallback (no preset-provided snippet), inject the default visible code rules as the snippet
        let tpl = AIPrompts.getCodeUserPromptTemplate()
        let snippet = AIPrompts.getCodeVisiblePresetDefault()
        return String(format: tpl, snippet, dictionaryTerms, contextData, text)
    }
    
    private func getUserMessageForCustomPrompt(_ promptText: String, text: String) -> String {
        // Get dictionary terms
        let dictionaryTerms = getDictionaryTerms()
        
        // Get context data
        let contextData = contextService.getContextData()
        
        // If in a code context (frontmost app is a code tool), use the code template
        let bid = NSWorkspace.shared.frontmostApplication?.bundleIdentifier?.lowercased() ?? ""
        let codeBIDs: Set<String> = [
            "com.microsoft.vscode", "com.microsoft.vscode.insiders",
            "com.todesktop.230313mzl4w4u92", // Cursor
            "dev.warp.warp", "com.apple.terminal",
            "com.codeium.windsurf"
        ]
        if codeBIDs.contains(bid) {
            let tpl = AIPrompts.getCodeUserPromptTemplate()
            return String(format: tpl, promptText, dictionaryTerms, contextData, text)
        }
        
        // Otherwise use the generic template (baseline rules live in system prompt)
        return String(format: AIPrompts.userPromptTemplate, promptText, dictionaryTerms, contextData, text)
    }
    
    private func makeRequestWithCustomPrompt(systemMessage: String, userMessage: String, retryCount: Int = 0) async throws -> String {
        // Use proxy-only approach - no direct API calls allowed
        guard isConfigured else {
            logger.error("AI Enhancement: API not configured")
            throw EnhancementError.notConfigured
        }
        
        if RuntimeConfig.logFullPrompt {
            logger.notice("🛰️ Sending to AI provider via proxy: \(self.aiService.selectedProvider.rawValue, privacy: .public)")
            logger.notice("🧠 [PROMPT FULL] System Message (\(systemMessage.count) chars): \(systemMessage, privacy: .public)")
            logger.notice("🧠 [PROMPT FULL] User Message (\(userMessage.count) chars): \(userMessage, privacy: .public)")
        } else if RuntimeConfig.enableVerboseLogging {
            logger.debug("System Message: \(RuntimeConfig.truncate(systemMessage), privacy: .public)")
            logger.debug("User Message: \(RuntimeConfig.truncate(userMessage), privacy: .public)")
        } else {
            logger.notice("🛰️ Sending to AI provider via proxy: \(self.aiService.selectedProvider.rawValue, privacy: .public)")
        }
        
        // Always use proxy - no direct API fallback
        let urlSession = getURLSession()
        
        do {
            // Try Groq first with proxy
            logger.notice("🌐 Sending custom-prompt request to LLM proxy (provider auto-selected by server)...")
            let result = try await makeProxyRequest(systemMessage: systemMessage, userMessage: userMessage, urlSession: urlSession)
            let final = PostEnhancementFormatter.apply(result)
            
            // Return session to pool after successful use
            returnURLSession(urlSession)
            
            logger.notice("✅ Custom-prompt enhancement via proxy succeeded")
            return final
        } catch {
            logger.notice("⚠️ [CUSTOM-PROMPT] Groq via proxy failed: \(error.localizedDescription)")
            
            // Check if this is a fallback-worthy error
            let shouldFallback = shouldFallbackToGemini(error: error)
            
            // Return session to pool even on error
            returnURLSession(urlSession)
            
            // Try Gemini fallback if appropriate
            if shouldFallback {
                logger.notice("🤖 [CUSTOM-PROMPT] Attempting Gemini fallback...")
                do {
                    let fallbackResult = try await makeGeminiRequest(systemMessage: systemMessage, userMessage: userMessage, urlSession: getURLSession())
                    logger.notice("✅ [CUSTOM-PROMPT] Gemini fallback succeeded")
                    return PostEnhancementFormatter.apply(fallbackResult)
                } catch {
                    logger.notice("❌ [CUSTOM-PROMPT] Gemini fallback also failed: \(error.localizedDescription)")
                    throw error
                }
            } else {
                // Not a fallback-worthy error, just throw it
                throw error
            }
        }
    }
    
    func captureScreenContext() async {
        await contextService.captureScreenContext()
    }
    
    /// Captures screen context at the end of recording for intelligent context detection
    func captureEndContext() async {
        await contextService.captureEndContext()
    }
    
    func addPrompt(title: String, promptText: String, icon: PromptIcon = .documentFill, description: String? = nil, triggerWords: [String] = []) {
        let newPrompt = CustomPrompt(title: title, promptText: promptText, icon: icon, description: description, isPredefined: false, triggerWords: triggerWords)
        customPrompts.append(newPrompt)
        if customPrompts.count == 1 {
            selectedPromptId = newPrompt.id
        }
    }
    
    func updatePrompt(_ prompt: CustomPrompt) {
        if let index = customPrompts.firstIndex(where: { $0.id == prompt.id }) {
            customPrompts[index] = prompt
        }
    }
    
    func deletePrompt(_ prompt: CustomPrompt) {
        customPrompts.removeAll { $0.id == prompt.id }
        if selectedPromptId == prompt.id {
            selectedPromptId = allPrompts.first?.id
        }
    }
    
    func setActivePrompt(_ prompt: CustomPrompt) {
        selectedPromptId = prompt.id
    }
    
    /// Sets the dynamic prompt enhancement based on detected context
    func setDynamicPromptEnhancement(_ promptEnhancement: String?) {
        dynamicPromptEnhancement = promptEnhancement
        logger.debug("🎯 Set dynamic prompt enhancement: \(promptEnhancement?.count ?? 0) chars")
    }
    
    /// Sets the dynamic NER prompt based on detected context
    func setDynamicNERPrompt(_ nerPrompt: String?) {
        dynamicNERPrompt = nerPrompt
        logger.debug("🧠 Set dynamic NER prompt: \(nerPrompt?.count ?? 0) chars")
    }
    
    /// Gets the current dynamic NER prompt for the detected context
    func getDynamicNERPrompt() -> String? {
        return dynamicNERPrompt
    }
    
    /// PowerMode prompt mapping removed; no-op retained for compatibility
    func setPromptForPowerMode(_ promptId: String?) { selectedPromptId = nil }
    
    // Retry methods removed - now using single attempt with raw transcript fallback
    
    private func initializePredefinedPrompts() {
        // No-op in fixed-prompt build
    }
}

enum EnhancementError: Error {
    case notConfigured
    case emptyText
    case invalidResponse
    case enhancementFailed
    case authenticationFailed
    case authenticationError
    case rateLimitExceeded
    case serverError
    case apiError
    case networkError
    case maxRetriesExceeded
}
