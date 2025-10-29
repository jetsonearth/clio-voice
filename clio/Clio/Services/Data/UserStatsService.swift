import Foundation
import SwiftData
import Combine

// MARK: - User Statistics Service
@MainActor
class UserStatsService: ObservableObject {
    static let shared = UserStatsService()
    
    // MARK: - Published Properties
    @Published private(set) var isLoading = false
    @Published private(set) var lastSyncDate: Date?
    @Published private(set) var pendingSyncCount = 0
    
    // MARK: - Services
    private let supabaseService = SupabaseServiceSDK.shared
    private let userDefaults = UserDefaults.standard
    private var cancellables = Set<AnyCancellable>()
    
    // Custom URLSession for stats updates with optimized reliability settings
    private lazy var statsURLSession: URLSession = makeStatsSession()

    private func makeStatsSession() -> URLSession {
        let config = URLSessionConfiguration.default
        // More generous timeouts following Supabase best practices
        config.timeoutIntervalForRequest = 30.0   // 30 second request timeout
        config.timeoutIntervalForResource = 60.0  // 60 second resource timeout
        config.waitsForConnectivity = true        // Wait for network recovery
        // Connection behavior tuned for stability on flaky networks
        config.httpMaximumConnectionsPerHost = 1  // prefer a single, stable connection
        config.allowsConstrainedNetworkAccess = true
        config.allowsExpensiveNetworkAccess = true
        config.requestCachePolicy = .useProtocolCachePolicy
        return URLSession(configuration: config)
    }

    private func rebuildStatsSession() {
        // Invalidate old session and create a fresh one to recover from -1005 or stale QUIC
        statsURLSession.invalidateAndCancel()
        statsURLSession = makeStatsSession()
    }
    
    // MARK: - Constants
    private let syncIntervalHours: TimeInterval = 24
    private let lastSyncKey = "UserStatsLastSyncDate"
    private let pendingSyncKey = "UserStatsPendingSyncCount"
    
    private init() {
        loadSyncState()
        setupListeners()
    }
    
    // MARK: - Setup
    
    private func setupListeners() {
        // Listen for authentication changes
        supabaseService.$currentSession
            .dropFirst() // Skip initial value
            .sink { [weak self] session in
                if session != nil {
                    // User signed in or switched - force sync immediately\n                    print(\"🔄 User session changed - forcing stats sync\")
                    Task { [weak self] in
                        await self?.forceSyncStats()
                    }
                } else {
                    // User signed out - clear sync state\n                    print(\"🚪 User signed out - clearing sync state\")
                    self?.clearSyncState()
                }
            }
            .store(in: &cancellables)
    }
    
    private func loadSyncState() {
        lastSyncDate = userDefaults.object(forKey: lastSyncKey) as? Date
        pendingSyncCount = userDefaults.integer(forKey: pendingSyncKey)
    }
    
    private func clearSyncState() {
        lastSyncDate = nil
        pendingSyncCount = 0
        userDefaults.removeObject(forKey: lastSyncKey)
        userDefaults.removeObject(forKey: pendingSyncKey)
    }
    
    // MARK: - Public Methods
    
    /// Check if stats should be synced (every 24 hours)
    func shouldSyncStats() -> Bool {
        guard supabaseService.currentSession != nil else { return false }
        
        guard let lastSync = lastSyncDate else { return true }
        let hoursSinceLastSync = Date().timeIntervalSince(lastSync) / 3600
        return hoursSinceLastSync >= syncIntervalHours
    }
    
    /// Sync stats if needed (called periodically)
    func syncStatsIfNeeded() async {
        if shouldSyncStats() {
            await syncStats(forced: false)
        }
    }
    
    /// Force immediate sync (called on sign-in, significant usage)
    func forceSyncStats() async {
        await syncStats(forced: true)
    }
    
    /// Calculate current local stats from SwiftData
    func calculateLocalStats(modelContext: ModelContext) async throws -> LocalUsageStats {
        return try await withCheckedThrowingContinuation { continuation in
            Task { @MainActor in
                do {
                    // Fetch all transcriptions
                    let descriptor = FetchDescriptor<Transcription>(
                        sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
                    )
                    let transcriptions = try modelContext.fetch(descriptor)
                    
                    var totalWords = 0
                    var totalSpeakingMinutes: Double = 0
                    var totalTimeSavedMinutes: Double = 0
                    let totalSessions = transcriptions.count
                    
                    for transcription in transcriptions {
                        let wordCount = TextUtils.countWords(in: transcription.text)
                        totalWords += wordCount
                        
                        // Calculate speaking time
                        let speakingTimeMinutes: Double
                        if transcription.duration > 0 {
                            speakingTimeMinutes = transcription.duration / 60.0
                        } else {
                            // Estimate at 150 WPM
                            speakingTimeMinutes = Double(wordCount) / 150.0
                        }
                        totalSpeakingMinutes += speakingTimeMinutes
                        
                        // Calculate time saved (typing time - speaking time)
                        let typingTimeMinutes = Double(wordCount) / 40.0 // 40 WPM typing
                        let timeSaved = max(0, typingTimeMinutes - speakingTimeMinutes)
                        totalTimeSavedMinutes += timeSaved
                    }
                    
                    // Calculate average WPM
                    let averageWpm = totalSpeakingMinutes > 0 ? Double(totalWords) / totalSpeakingMinutes : 0
                    
                    let stats = LocalUsageStats(
                        totalWordsTranscribed: totalWords,
                        totalSpeakingMinutes: totalSpeakingMinutes,
                        totalSessions: totalSessions,
                        totalTimeSavedMinutes: totalTimeSavedMinutes,
                        averageWpm: averageWpm,
                        lastActivityAt: transcriptions.first?.timestamp ?? Date()
                    )
                    
                    continuation.resume(returning: stats)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /// Update trial usage in Supabase (non-blocking, runs on background queue)
    func updateTrialUsage(additionalMinutes: Double) async {
        guard let session = supabaseService.currentSession else { return }
        
        // Run on background task to avoid blocking transcription pipeline
        Task.detached(priority: .background) { [weak self] in
            await self?.performTrialUsageUpdate(additionalMinutes: additionalMinutes, retryCount: 0)
        }
    }
    
    /// Perform trial usage update with retry logic on background queue
    private func performTrialUsageUpdate(additionalMinutes: Double, retryCount: Int) async {
        let maxRetries = 3
        let baseDelay: TimeInterval = 1.0

        guard let session = supabaseService.currentSession else { return }

        do {
            let currentUsage = session.user.trialMinutesUsed ?? 0
            let newUsage = currentUsage + additionalMinutes

            try await updateUserStats(trialMinutesUsed: newUsage)
            print("✅ Updated trial usage: +\(additionalMinutes) minutes (total: \(newUsage))")
        } catch {
            print("❌ Failed to update trial usage (attempt \(retryCount + 1)/\(maxRetries + 1)): \(error)")

            // Decide if retryable and compute delay using same policy as full sync
            let shouldRetry = shouldRetryError(error, attempt: retryCount + 1, maxAttempts: maxRetries + 1)
            if shouldRetry && retryCount < maxRetries {
                // Rebuild session proactively on network losses to avoid reusing a bad transport
                if let urlError = error as? URLError, urlError.code == .networkConnectionLost {
                    rebuildStatsSession()
                }
                let delay = calculateRetryDelay(baseDelay: baseDelay, attempt: retryCount, error: error)
                print("🔄 Retrying trial usage update in \(String(format: "%.1f", delay))s...")
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                await performTrialUsageUpdate(additionalMinutes: additionalMinutes, retryCount: retryCount + 1)
            } else {
                let reason = shouldRetry ? "max retries exceeded" : "error not retryable"
                print("❌ Failed to update trial usage after \(retryCount + 1) attempts (\(reason))")
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// Main sync method
    private func syncStats(forced: Bool) async {
        guard let session = supabaseService.currentSession else {
            print("⚠️ No session available for stats sync")
            return
        }
        
        guard let modelContext = getCurrentModelContext() else {
            print("❌ No model context available for stats calculation")
            return
        }
        
        isLoading = true
        
        do {
            // Calculate current local stats
            let localStats = try await calculateLocalStats(modelContext: modelContext)
            
            // Sync to Supabase
            try await updateUserStats(from: localStats)
            
            // Update sync state
            lastSyncDate = Date()
            pendingSyncCount = 0
            userDefaults.set(lastSyncDate, forKey: lastSyncKey)
            userDefaults.set(0, forKey: pendingSyncKey)
            
            print("🔄 Stats synced successfully (\(forced ? "FORCED" : "SCHEDULED"))")
            print("📊 \(localStats.totalWordsTranscribed) words, \(String(format: "%.1f", localStats.totalSpeakingMinutes)) minutes")
            
        } catch {
            print("❌ Failed to sync stats: \(error)")
            
            // Increment pending sync count for retry later
            pendingSyncCount += 1
            userDefaults.set(pendingSyncCount, forKey: pendingSyncKey)
        }
        
        isLoading = false
    }
    
    /// Update user stats in Supabase
    private func updateUserStats(from localStats: LocalUsageStats) async throws {
        try await updateUserStats(
            totalWordsTranscribed: localStats.totalWordsTranscribed,
            totalSpeakingMinutes: localStats.totalSpeakingMinutes,
            totalSessions: localStats.totalSessions,
            totalTimeSavedMinutes: localStats.totalTimeSavedMinutes,
            averageWpm: localStats.averageWpm,
            lastActivityAt: localStats.lastActivityAt
        )
    }
    
    /// Update specific user stats fields in Supabase
    internal func updateUserStats(
        totalWordsTranscribed: Int? = nil,
        totalSpeakingMinutes: Double? = nil,
        totalSessions: Int? = nil,
        totalTimeSavedMinutes: Double? = nil,
        averageWpm: Double? = nil,
        lastActivityAt: Date? = nil,
        trialWordsUsed: Int? = nil,
        trialMinutesUsed: Double? = nil
    ) async throws {
        guard let session = supabaseService.currentSession else {
            throw UserStatsError.noSession
        }
        
        // Build update object
        var updateData: [String: Any] = [
            "updated_at": ISO8601DateFormatter().string(from: Date())
        ]
        
        if let totalWordsTranscribed = totalWordsTranscribed {
            updateData["total_words_transcribed"] = totalWordsTranscribed
        }
        if let totalSpeakingMinutes = totalSpeakingMinutes {
            updateData["total_speaking_minutes"] = totalSpeakingMinutes
        }
        if let totalSessions = totalSessions {
            updateData["total_sessions"] = totalSessions
        }
        if let totalTimeSavedMinutes = totalTimeSavedMinutes {
            updateData["total_time_saved_minutes"] = totalTimeSavedMinutes
        }
        if let averageWpm = averageWpm {
            updateData["average_wpm"] = averageWpm
        }
        if let lastActivityAt = lastActivityAt {
            updateData["last_activity_at"] = ISO8601DateFormatter().string(from: lastActivityAt)
        }
        if let trialWordsUsed = trialWordsUsed {
            updateData["trial_words_used"] = trialWordsUsed
        }
        if let trialMinutesUsed = trialMinutesUsed {
            updateData["trial_minutes_used"] = trialMinutesUsed
        }
        
        // Make API request using UPSERT for better reliability
        let url = URL(string: "\(supabaseService.apiURL)/rest/v1/user_profiles?id=eq.\(session.user.id)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(session.accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue(supabaseService.apiKey, forHTTPHeaderField: "apikey")
        request.setValue("return=minimal", forHTTPHeaderField: "Prefer")
        // Note: PATCH is correct here since we're updating an existing user profile
        
        request.httpBody = try JSONSerialization.data(withJSONObject: updateData)
        
        // Use custom URLSession with optimized reliability settings
        let (_, httpResponse): (Data, URLResponse)
        do {
            let result = try await statsURLSession.data(for: request)
            httpResponse = result.1
        } catch {
            // Convert URLErrors to specific UserStatsError types and rebuild session on -1005
            if let urlError = error as? URLError {
                switch urlError.code {
                case .networkConnectionLost, .notConnectedToInternet:
                    rebuildStatsSession()
                    throw UserStatsError.networkError
                case .timedOut:
                    throw UserStatsError.networkError
                default:
                    throw UserStatsError.updateFailed
                }
            }
            throw error
        }
        
        guard let response = httpResponse as? HTTPURLResponse else {
            throw UserStatsError.updateFailed
        }
        
        if !(200...299 ~= response.statusCode) {
            print("❌ Supabase stats update failed with status \(response.statusCode)")
            
            // Throw specific errors for different status codes (following Supabase best practices)
            switch response.statusCode {
            case 401:
                throw UserStatsError.authenticationFailed
            case 403:
                throw UserStatsError.permissionDenied
            case 429:
                throw UserStatsError.rateLimited
            case 500...599:
                throw UserStatsError.serverError
            default:
                throw UserStatsError.updateFailed
            }
        }
        
        print("✅ Successfully updated user stats in Supabase")
    }
    
    /// Get current model context (this would be injected in real implementation)
    private func getCurrentModelContext() -> ModelContext? {
        // Access the shared model context from the app
        // This needs to be set from the main app when it initializes
        return UserStatsService.sharedModelContext
    }
    
    // MARK: - Trial Usage Sync
    
    /// Sync trial usage to Supabase (graceful failure) - runs on background queue
    func syncTrialUsage(totalMinutes: Double) async {
        // Run on background queue to avoid blocking transcription pipeline
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await self.performTrialUsageSync(totalMinutes: totalMinutes, retryCount: 0)
            }
        }
    }
    
    /// Perform trial usage sync with enhanced retry logic following Supabase best practices
    private func performTrialUsageSync(totalMinutes: Double, retryCount: Int) async {
        let maxRetries = 3  // Increased from 2 to 3 for better reliability
        let baseDelay: TimeInterval = 1.0
        
        do {
            try await updateUserStats(trialMinutesUsed: totalMinutes)
            print("✅ Trial usage synced successfully: \(totalMinutes) minutes")
        } catch {
            print("⚠️ Failed to sync trial usage (attempt \(retryCount + 1)/\(maxRetries + 1)): \(error)")
            
            // Determine if error is retryable based on Supabase best practices
            let shouldRetry = shouldRetryError(error, attempt: retryCount + 1, maxAttempts: maxRetries + 1)
            
            if shouldRetry && retryCount < maxRetries {
                // Enhanced exponential backoff with jitter
                let delay = calculateRetryDelay(baseDelay: baseDelay, attempt: retryCount, error: error)
                print("🔄 Retrying in \(String(format: "%.1f", delay))s...")
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                await performTrialUsageSync(totalMinutes: totalMinutes, retryCount: retryCount + 1)
            } else {
                let reason = shouldRetry ? "max retries exceeded" : "error not retryable"
                print("❌ Failed to sync trial usage after \(retryCount + 1) attempts (\(reason))")
            }
        }
    }
    
    /// Determine if an error should be retried based on Supabase recommendations
    private func shouldRetryError(_ error: Error, attempt: Int, maxAttempts: Int) -> Bool {
        // Don't retry if we've exceeded max attempts
        guard attempt < maxAttempts else { return false }
        
        // Handle specific Supabase error types
        if let statsError = error as? UserStatsError {
            switch statsError {
            case .authenticationFailed:
                return false  // Don't retry auth failures
            case .permissionDenied:
                return false  // Don't retry permission errors
            case .rateLimited:
                return true   // Retry rate limits with longer delay
            case .serverError:
                return true   // Retry server errors
            case .networkError:
                return true   // Retry network errors
            default:
                return attempt <= 1  // Retry other errors once
            }
        }
        
        // Handle URLError network issues (following Supabase docs)
        if let urlError = error as? URLError {
            switch urlError.code {
            case .networkConnectionLost, .notConnectedToInternet, .timedOut:
                return true   // Retry network issues
            case .badServerResponse:
                return attempt <= 1  // Retry bad responses once
            default:
                return false
            }
        }
        
        // Default: retry once for unknown errors
        return attempt <= 1
    }
    
    /// Calculate retry delay with exponential backoff and jitter
    private func calculateRetryDelay(baseDelay: TimeInterval, attempt: Int, error: Error) -> TimeInterval {
        // Base exponential backoff
        var delay = baseDelay * pow(2.0, Double(attempt))
        
        // Special handling for rate limiting (longer delays)
        if let statsError = error as? UserStatsError, statsError == .rateLimited {
            delay = max(delay, 10.0)  // Minimum 10s for rate limits
        }
        
        // Add jitter to prevent thundering herd (±25%)
        let jitter = Double.random(in: 0.75...1.25)
        delay *= jitter
        
        // Cap maximum delay at 30s
        return min(delay, 30.0)
    }
    
    // Static property to hold the model context
    static var sharedModelContext: ModelContext?
}

// MARK: - Supporting Types

struct LocalUsageStats {
    let totalWordsTranscribed: Int
    let totalSpeakingMinutes: Double
    let totalSessions: Int
    let totalTimeSavedMinutes: Double
    let averageWpm: Double
    let lastActivityAt: Date
}

enum UserStatsError: Error, LocalizedError, Equatable {
    case noSession
    case updateFailed
    case calculationFailed
    case authenticationFailed
    case permissionDenied
    case rateLimited
    case serverError
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .noSession:
            return "No active user session"
        case .updateFailed:
            return "Failed to update user statistics"
        case .calculationFailed:
            return "Failed to calculate local statistics"
        case .authenticationFailed:
            return "Authentication failed - user needs to re-login"
        case .permissionDenied:
            return "Permission denied - insufficient privileges"
        case .rateLimited:
            return "Rate limited - too many requests"
        case .serverError:
            return "Server error - Supabase service unavailable"
        case .networkError:
            return "Network error - connection lost"
        }
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let userStatsUpdated = Notification.Name("userStatsUpdated")
    static let userStatsSyncFailed = Notification.Name("userStatsSyncFailed")
}
