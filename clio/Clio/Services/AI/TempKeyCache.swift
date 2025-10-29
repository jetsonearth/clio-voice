import Foundation
import os
import AppKit // For NSApplication notifications

/// Thread-safe cache for Soniox temporary API keys to eliminate 200-500ms connection latency
/// Integrates with existing SonioxStreamingService architecture and system warmup cycles
@MainActor
final class TempKeyCache: ObservableObject {
    static let shared = TempKeyCache()
    
    // MARK: - Published State for Monitoring
    @Published var cacheHitRate: Double = 0.0
    @Published var totalRequests: Int = 0
    @Published var cacheHits: Int = 0
    @Published var cacheMisses: Int = 0
    @Published var keysInCache: Int = 0
    
    // MARK: - Configuration
    private let maxCacheSize: Int = 1 // Single global key; language hints applied at connect time
    private let keyExpirationBuffer: TimeInterval = 60 // 1-min safety buffer (keys last 1 hour)
    private let prefetchThreshold: TimeInterval = 600 // Start prefetch when 10 min remaining
    
    // MARK: - Internal State
    private var cache: [String: CachedTempKey] = [:]
    private let cacheQueue = DispatchQueue(label: "com.cliovoice.clio.tempkey-cache", attributes: .concurrent)
    private let logger = Logger(subsystem: "com.cliovoice.clio", category: "TempKeyCache")
    
    // MARK: - Dependencies
    private let tokenManager = TokenManager.shared
    
    // MARK: - Background Prefetch Management
    private var prefetchTimer: Timer?
    private var isPrefetching = false
    private var inFlightPrefetchKeys: Set<String> = []
    private var scheduledRefreshTimers: [String: Timer] = [:]
    private var lastPrefetchAttempt: Date?
    private let prefetchInterval: TimeInterval = 600 // 10 minutes between TTL-driven prefetch attempts
    
    private init() {
        logger.notice("🔑 TempKeyCache initialized")
        
        // Start background prefetch timer aligned with system warmup
        startBackgroundPrefetch()
        
        // Listen for app lifecycle to cleanup
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppTermination),
            name: NSApplication.willTerminateNotification,
            object: nil
        )
    }
    
    deinit {
        // Ensure we call the main-actor isolated method on the main actor context
        Task { @MainActor in
            stopBackgroundPrefetch()
        }
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Public API
    
    /// Get cached temp key or fetch fresh one, with performance timing
    func getCachedTempKey(languages: [String]) async throws -> TemporaryKeyInfo {
        let startTime = Date()
        totalRequests += 1
        StreamingDiagnostics.logTempKeyFetchStart()
        
        // Try cache first (fast path)
        if let cachedKey = await getCachedKeyIfValid(languages: languages) {
            cacheHits += 1
            updateCacheHitRate()
            
            let cacheLatency = Date().timeIntervalSince(startTime) * 1000
        if !RuntimeConfig.shouldSilenceAllLogs { logger.notice("⚡ [CACHE-HIT] Retrieved temp key in \(String(format: "%.1f", cacheLatency))ms") }
            
            // Structured log: temp key fetch (cached)
            if let expiresAtDate = parseExpirationDate(from: cachedKey.keyInfo.expiresAt) {
                let expiresIn = Int(expiresAtDate.timeIntervalSince(Date()))
                StructuredLog.shared.log(cat: .stream, evt: "temp_key_fetch", lvl: .info, [
                    "source": "cached",
                    "latency_ms": Int(cacheLatency),
                    "expires_in_s": expiresIn
                ])
            } else {
                StructuredLog.shared.log(cat: .stream, evt: "temp_key_fetch", lvl: .info, [
                    "source": "cached",
                    "latency_ms": Int(cacheLatency),
                    "expires_in_s": -1
                ])
            }
            
            // Trigger background prefetch if key is expiring soon
            triggerPrefetchIfNeeded(cachedKey: cachedKey, languages: languages)
            
            return cachedKey.keyInfo
        }
        
        // Cache miss - fetch fresh key (slow path)
        cacheMisses += 1
        updateCacheHitRate()
        
        logger.notice("🔍 [CACHE-MISS] Fetching fresh temp key...")
        let freshKey = try await fetchFreshTempKey(languages: languages)
        
        // Cache the fresh key
        await cacheTempKey(freshKey, languages: languages)
        
        let totalLatency = Date().timeIntervalSince(startTime) * 1000
        logger.notice("🔑 [FRESH-KEY] Fetched and cached temp key in \(String(format: "%.0f", totalLatency))ms")
        
        // Structured log: temp key fetch (fresh)
        if let expiresAtDate = parseExpirationDate(from: freshKey.expiresAt) {
            let expiresIn = Int(expiresAtDate.timeIntervalSince(Date()))
            StructuredLog.shared.log(cat: .stream, evt: "temp_key_fetch", lvl: .info, [
                "source": "fresh",
                "latency_ms": Int(totalLatency),
                "expires_in_s": expiresIn
            ])
        } else {
            StructuredLog.shared.log(cat: .stream, evt: "temp_key_fetch", lvl: .info, [
                "source": "fresh",
                "latency_ms": Int(totalLatency),
                "expires_in_s": -1
            ])
        }
        
        return freshKey
    }
    
    /// Trigger immediate prefetch for given languages (used by system warmup)
    func prefetchTempKey(languages: [String]) async {
        let cacheKey = generateCacheKey(languages: languages)
        if inFlightPrefetchKeys.contains(cacheKey) {
            if RuntimeConfig.enableVerboseLogging && !RuntimeConfig.shouldSilenceAllLogs { logger.debug("🔄 [PREFETCH] Already prefetching for key=\(cacheKey), skipping") }
            return
        }
        inFlightPrefetchKeys.insert(cacheKey)
        defer { inFlightPrefetchKeys.remove(cacheKey) }
        
        if !RuntimeConfig.shouldSilenceAllLogs { logger.notice("🚀 [PREFETCH] Starting background temp key prefetch") }
        
        do {
            let freshKey = try await fetchFreshTempKey(languages: languages)
            await cacheTempKey(freshKey, languages: languages)
        if !RuntimeConfig.shouldSilenceAllLogs { logger.notice("✅ [PREFETCH] Successfully prefetched temp key") }
            // Schedule precise TTL-based refresh for this languages set
            if let expiresAtDate = parseExpirationDate(from: freshKey.expiresAt) {
                scheduleOneShotRefresh(for: cacheKey, languages: languages, expiresAt: expiresAtDate)
            }
        } catch {
        if !RuntimeConfig.shouldSilenceAllLogs { logger.warning("⚠️ [PREFETCH] Failed to prefetch temp key: \(error.localizedDescription)") }
        }
    }
    
    /// Ensure a temp key exists with sufficient TTL; prefetch if needed (debounced).
    func ensurePrefetchedIfNeeded() async {
        let languages = getSonioxLanguageHints()
        // If we already have a valid key with enough runway, do nothing
        if let cached = await getCachedKeyIfValid(languages: languages) {
            let remaining = cached.expiresAt.timeIntervalSince(Date())
            if remaining > max(prefetchThreshold, keyExpirationBuffer + 60) {
                return
            }
        }
        // Debounce repeated attempts
        if let last = lastPrefetchAttempt, Date().timeIntervalSince(last) < prefetchInterval {
            return
        }
        await prefetchTempKey(languages: languages)
        lastPrefetchAttempt = Date()
    }
    
    /// Clear cache and reset metrics (for testing/debugging)
    func clearCache() async {
        await cacheQueue.sync(flags: .barrier) {
            cache.removeAll()
            keysInCache = 0
            logger.notice("🧹 Cache cleared")
        }
    }
    
    // MARK: - Integration with System Warmup
    
    /// Hook for SonioxStreamingService.performSystemWarmup()
    func integrateWithSystemWarmup() async {
        logger.debug("🔥 [SYSTEM-WARMUP] TempKeyCache warmup integration")
        
        // TTL-aware: only prefetch if needed
        await ensurePrefetchedIfNeeded()
    }
    
    // MARK: - Private Implementation
    
    private func getCachedKeyIfValid(languages: [String]) async -> CachedTempKey? {
        return await withCheckedContinuation { continuation in
            cacheQueue.async {
                let cacheKey = self.generateCacheKey(languages: languages)
                
                guard let cachedKey = self.cache[cacheKey] else {
                    continuation.resume(returning: nil)
                    return
                }
                
                // Check if key is still valid (with safety buffer)
                let now = Date()
                let effectiveExpiration = cachedKey.expiresAt.addingTimeInterval(-self.keyExpirationBuffer)
                
                if now < effectiveExpiration {
                    continuation.resume(returning: cachedKey)
                } else {
                    // Remove expired key
                    self.cache.removeValue(forKey: cacheKey)
                    Task { @MainActor in
                        self.keysInCache = self.cache.count
                    }
                    self.logger.debug("🗑️ Removed expired temp key from cache")
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
    private func cacheTempKey(_ keyInfo: TemporaryKeyInfo, languages: [String]) async {
        await withCheckedContinuation { continuation in
            cacheQueue.async(flags: .barrier) {
                let cacheKey = self.generateCacheKey(languages: languages)
                
                // Parse expiration from keyInfo
                let expirationDate = self.parseExpirationDate(from: keyInfo.expiresAt) ?? Date().addingTimeInterval(3600)
                
                let cachedKey = CachedTempKey(
                    keyInfo: keyInfo,
                    languages: languages,
                    cachedAt: Date(),
                    expiresAt: expirationDate
                )
                
                // Enforce cache size limit
                if self.cache.count >= self.maxCacheSize {
                    // Remove oldest cached key
                    if let oldestKey = self.cache.min(by: { $0.value.cachedAt < $1.value.cachedAt }) {
                        self.cache.removeValue(forKey: oldestKey.key)
                        self.logger.debug("🗑️ Evicted oldest temp key to maintain cache size limit")
                    }
                }
                
                self.cache[cacheKey] = cachedKey
                
                Task { @MainActor in
                    self.keysInCache = self.cache.count
                }
                
                self.logger.debug("💾 Cached temp key for languages: \(languages)")
                // Schedule a one-shot refresh at expiresAt − 10 minutes
                self.scheduleOneShotRefresh(for: cacheKey, languages: languages, expiresAt: expirationDate)
                continuation.resume()
            }
        }
    }
    
    private func fetchFreshTempKey(languages: [String]) async throws -> TemporaryKeyInfo {
        let startTime = Date()
        
        // Use existing requestTemporaryApiKey logic from SonioxStreamingService
        let jwtToken = try await tokenManager.getValidToken()
        
        let url = URL(string: APIConfig.asrTempKeyURL)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")
        
        let requestBody: [String: Any] = [
            "languages": languages,
            "duration": 3600  // 1 hour temp key lifetime
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await ProxySessionManager.shared.session.data(for: request)
        let totalTime = Date().timeIntervalSince(startTime) * 1000 // Convert to milliseconds
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw TempKeyCacheError.fetchFailed(statusCode: (response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let tempApiKey = json["temporaryApiKey"] as? String,
              let expiresAt = json["expiresAt"] as? String,
              let websocketUrl = json["websocketUrl"] as? String,
              let configDict = json["config"] as? [String: Any] else {
            throw TempKeyCacheError.invalidResponse
        }
        
        // Log ASR latency breakdown if timing data is available
        if let timingData = json["timing"] as? [String: Any] {
            let proxyTotal = timingData["proxy_total"] as? Int ?? 0
            let sonioxActual = timingData["soniox_actual"] as? Int ?? 0
            let networkOverhead = timingData["network_overhead"] as? Int ?? 0
            // Client↔Proxy here refers to the HTTP call from app → proxy ONLY for temp-key fetch
            // This does NOT reflect the live ASR streaming path (which is client → Soniox WebSocket)
            let clientToProxyMs = max(0, Int(totalTime) - proxyTotal)
            logger.notice("🌐 [ASR TEMPKEY] client_total=\(Int(totalTime))ms | client↔proxy=\(clientToProxyMs)ms | server↔soniox=\(sonioxActual)ms | server_net=\(networkOverhead)ms")
        } else {
            logger.notice("⏱️ [ASR TEMPKEY] client_total=\(Int(totalTime))ms (no server breakdown available)")
        }
        
        // Parse the config (similar to SonioxStreamingService.requestTemporaryApiKey)
        let configLanguageHints = (configDict["language_hints"] as? [String]) ?? languages
        
        let config = SonioxConfig(
            api_key: tempApiKey,
            model: "stt-rt-v3",
            audio_format: "pcm_s16le",
            sample_rate: 16000, // Default, will be updated when used
            num_channels: 1,    // Default, will be updated when used
            language_hints: configLanguageHints,
            enable_non_final_tokens: true,
            enable_endpoint_detection: true, // Default, will be set to true when used
            // max_non_final_tokens_duration_ms: 6000, // Deprecated by Soniox as of Sept 1st 2024
            context: nil // Will be set when used
        )
        
        return TemporaryKeyInfo(
            apiKey: tempApiKey,
            expiresAt: expiresAt,
            websocketUrl: websocketUrl,
            config: config
        )
    }
    
    private func triggerPrefetchIfNeeded(cachedKey: CachedTempKey, languages: [String]) {
        let timeUntilExpiration = cachedKey.expiresAt.timeIntervalSince(Date())
        
        if timeUntilExpiration <= prefetchThreshold && !isPrefetching {
            // Check if we haven't prefetched recently
            if let lastAttempt = lastPrefetchAttempt,
               Date().timeIntervalSince(lastAttempt) < prefetchInterval {
                return
            }
            
            logger.notice("🔄 [PREFETCH] Key expiring in \(String(format: "%.0f", timeUntilExpiration))s, triggering background prefetch")
            
            Task {
                await prefetchTempKey(languages: languages)
            }
            
            lastPrefetchAttempt = Date()
        }
    }
    
    // MARK: - Background Prefetch Timer
    
    private func startBackgroundPrefetch() {
        stopBackgroundPrefetch()
        
        // Align with system warmup interval (15 minutes)
        prefetchTimer = Timer.scheduledTimer(withTimeInterval: 15 * 60, repeats: true) { [weak self] _ in
            Task { [weak self] in
                await self?.periodicPrefetch()
            }
        }
        
        logger.debug("🔄 Background prefetch timer started")
    }
    
    private func stopBackgroundPrefetch() {
        prefetchTimer?.invalidate()
        prefetchTimer = nil
    }
    
    private func periodicPrefetch() async {
        // Only prefetch if cache is empty or has expiring keys
        let shouldPrefetch = await withCheckedContinuation { continuation in
            cacheQueue.async {
                let hasExpiringKeys = self.cache.values.contains { cachedKey in
                    let timeUntilExpiration = cachedKey.expiresAt.timeIntervalSince(Date())
                    return timeUntilExpiration <= self.prefetchThreshold
                }
                
                let shouldPrefetch = self.cache.isEmpty || hasExpiringKeys
                continuation.resume(returning: shouldPrefetch)
            }
        }
        
        if shouldPrefetch {
            let languages = getSonioxLanguageHints()
            await prefetchTempKey(languages: languages)
        }
    }
    
    // MARK: - Utility Methods
    
    private func generateCacheKey(languages: [String]) -> String {
        // Temp key is not language-bound; we maintain a single global entry.
        return "global"
    }
    
    private func parseExpirationDate(from expiresAtString: String) -> Date? {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = f.date(from: expiresAtString) { return d }
        let f2 = ISO8601DateFormatter()
        f2.formatOptions = [.withInternetDateTime]
        return f2.date(from: expiresAtString)
    }
    
    private func scheduleOneShotRefresh(for cacheKey: String, languages: [String], expiresAt: Date) {
        // Cancel any existing timer for this key
        if let timer = scheduledRefreshTimers[cacheKey] {
            timer.invalidate()
            scheduledRefreshTimers[cacheKey] = nil
        }
        
        // Schedule at expiresAt − 10 minutes
        let refreshLeadTime: TimeInterval = 10 * 60
        var fireDate = expiresAt.addingTimeInterval(-refreshLeadTime)
        // If already within the lead window, schedule soon (5s) to refresh proactively
        let minimumLead: TimeInterval = 5
        if fireDate <= Date().addingTimeInterval(minimumLead) {
            fireDate = Date().addingTimeInterval(minimumLead)
        }
        
        let interval = max(1.0, fireDate.timeIntervalSinceNow)
        if !RuntimeConfig.shouldSilenceAllLogs {
            logger.notice("🗓️ [TTL-SCHEDULE] Scheduling temp key refresh for key=\(cacheKey) in \(String(format: "%.0f", interval))s (expiresAt=\(expiresAt))")
        }
        
        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            guard let self else { return }
            Task { [weak self] in
                guard let self else { return }
                // Always prefetch the single global key
                await self.prefetchTempKey(languages: self.getSonioxLanguageHints())
            }
        }
        scheduledRefreshTimers[cacheKey] = timer
    }
    
    private func getSonioxLanguageHints() -> [String] {
        // Mirror the logic from SonioxStreamingService
        guard let selectedLanguagesData = UserDefaults.standard.data(forKey: "SelectedLanguages") else {
            let selectedLanguage = UserDefaults.standard.string(forKey: "SelectedLanguage") ?? "en"
            return [selectedLanguage == "auto" ? "en" : selectedLanguage]
        }
        
        do {
            let selectedLanguages = try JSONDecoder().decode(Set<String>.self, from: selectedLanguagesData)
            // Map Traditional Chinese pseudo option(s) to base Chinese for Soniox and EXCLUDE the pseudo code itself
            var normalized: Set<String> = []
            for code in selectedLanguages {
                let lower = code.lowercased()
                if lower == "zh-hant" || lower == "zh-tw" {
                    normalized.insert("zh")
                    continue // do NOT include the pseudo code
                }
                normalized.insert(code)
            }
            // Final filter: exclude zh-Hant explicitly to avoid leaking into Soniox hints
            let validLanguages = normalized.filter { SonioxLanguages.isValidLanguage($0) && $0.lowercased() != "zh-hant" }
            
            if validLanguages.contains("auto") {
                return ["en"]
            }
            
            // Ensure zh-Hant cannot slip through
            let sanitized = validLanguages.filter { $0.lowercased() != "zh-hant" }
            return sanitized.isEmpty ? ["en"] : Array(sanitized)
        } catch {
            let selectedLanguage = UserDefaults.standard.string(forKey: "SelectedLanguage") ?? "en"
            return [selectedLanguage == "auto" ? "en" : selectedLanguage]
        }
    }
    
    private func updateCacheHitRate() {
        cacheHitRate = totalRequests > 0 ? Double(cacheHits) / Double(totalRequests) : 0.0
    }
    
    @objc private func handleAppTermination() {
        stopBackgroundPrefetch()
    }
}

// MARK: - Supporting Data Models

/// Cached temporary key with metadata
private struct CachedTempKey {
    let keyInfo: TemporaryKeyInfo
    let languages: [String]
    let cachedAt: Date
    let expiresAt: Date
}

/// Enhanced TemporaryKeyInfo to match SonioxStreamingService structure
struct TemporaryKeyInfo {
    let apiKey: String
    let expiresAt: String
    let websocketUrl: String
    let config: SonioxConfig
}

// MARK: - Errors

enum TempKeyCacheError: LocalizedError {
    case fetchFailed(statusCode: Int)
    case invalidResponse
    case cacheCorrupted
    
    var errorDescription: String? {
        switch self {
        case .fetchFailed(let statusCode):
            return "Failed to fetch temp key: HTTP \(statusCode)"
        case .invalidResponse:
            return "Invalid response from temp key API"
        case .cacheCorrupted:
            return "Temp key cache is corrupted"
        }
    }
}

// MARK: - Performance Monitoring Extension

extension TempKeyCache {
    /// Get cache performance metrics for debugging
    func getCacheMetrics() -> [String: Any] {
        return [
            "totalRequests": totalRequests,
            "cacheHits": cacheHits,
            "cacheMisses": cacheMisses,
            "hitRate": String(format: "%.1f%%", cacheHitRate * 100),
            "keysInCache": keysInCache,
            "maxCacheSize": maxCacheSize
        ]
    }
    
    /// Log current cache status for debugging
    func logCacheStatus() {
        let metrics = getCacheMetrics()
        logger.notice("📊 [CACHE-METRICS] \(metrics)")
    }
}
