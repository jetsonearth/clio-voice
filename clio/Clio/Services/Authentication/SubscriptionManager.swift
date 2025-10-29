import Foundation
import Combine

enum SubscriptionTier: String, CaseIterable {
    case free = "free"
    case pro = "pro"
    case enterprise = "enterprise"
    
    var displayName: String {
        switch self {
        case .free: return "Free"
        case .pro: return "Pro"
        case .enterprise: return "Enterprise"
        }
    }
    
    var monthlyPrice: Double {
        switch self {
        case .free: return 0
        case .pro: return 7.99
        case .enterprise: return 29.99
        }
    }
    
    var yearlyPrice: Double {
        switch self {
        case .free: return 0
        case .pro: return 79.99  // ~17% annual discount
        case .enterprise: return 299.99
        }
    }
    
    // Map from Supabase subscription_plan values
    static func from(supabasePlan: String?) -> SubscriptionTier {
        switch supabasePlan?.lowercased() {
        case "pro": return .pro
        case "enterprise": return .enterprise
        default: return .free
        }
    }
}

struct SubscriptionFeatures {
    let tier: SubscriptionTier
    let trialDaysRemaining: Int
    let trialWordsUsed: Int
    
    // DEPRECATED: Usage-based trial (commented out)
    // let trialMinutesRemaining: Double
    
    // Model access
    var canUseBaseModels: Bool {
        true // Free for all tiers
    }
    
    var canUseLargeModels: Bool {
        tier != .free || isInTrial
    }
    
    var canUseCloudModels: Bool {
        tier != .free || isInTrial
    }
    
    // AI Enhancement
    var canUseAIEnhancement: Bool {
        tier != .free || isInTrial
    }
    
    var canUseCustomPrompts: Bool {
        tier != .free || isInTrial
    }
    
    var canUsePowerModes: Bool {
        tier != .free || isInTrial
    }
    
    // Trial status - TIME-BASED
    var isInTrial: Bool {
        trialDaysRemaining > 0
    }

    // Word-based properties (deprecated; kept to avoid wider refactors)
    private static let TRIAL_WORD_LIMIT = SubscriptionManager.TRIAL_WORD_LIMIT
    
    var trialWordLimit: Int {
        Self.TRIAL_WORD_LIMIT
    }
    
    var trialWordsRemaining: Int { // no longer used for gating
        max(0, Self.TRIAL_WORD_LIMIT - trialWordsUsed)
    }
    
    
    var trialProgressPercentage: Double {
        let used = Double(trialWordsUsed)
        let limit = Double(Self.TRIAL_WORD_LIMIT)
        return min(1.0, max(0.0, used / limit))
    }
    
    // Time-based trial properties
    var trialDurationDays: Int { SubscriptionManager.TRIAL_DURATION_DAYS }
    
    var monthlyTranscriptionMinutes: Int? {
        switch tier {
        case .free: 
            return isInTrial ? nil : 0 // Unlimited during trial, none after
        case .pro: return nil // Unlimited
        case .enterprise: return nil // Unlimited
        }
    }
    
    var monthlyEnhancementWords: Int? {
        switch tier {
        case .free: 
            return isInTrial ? nil : 0 // Unlimited during trial, none after
        case .pro: return nil // REMOVED: 100k word limit - Pro now has unlimited enhancement like Enterprise
        case .enterprise: return nil // Unlimited
        }
    }
    
    // Other features
    var canExportTranscripts: Bool {
        true // Available for all
    }
    
    var canSyncAcrossDevices: Bool {
        tier == .enterprise
    }
    
    var prioritySupport: Bool {
        tier != .free
    }
}

@MainActor
class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    // MARK: - Trial Configuration - EASY TO CHANGE!
    // Time-based trial in DAYS
    static let TRIAL_DURATION_DAYS: Int = 14  // 2-week trial period
    
    // WORD-BASED TRIAL (DEPRECATED): kept for backward compatibility/telemetry only
    static let TRIAL_WORD_LIMIT: Int = 4000
    
    // Helper for UI display
    static var trialDurationDisplayText: String {
        let days = TRIAL_DURATION_DAYS
        if days == 1 {
            return "1 day"
        } else {
            return "\(days) days"
        }
    }
    
    // DEPRECATED: Usage-based trial (commented out but kept for reference)
    // static let TRIAL_DURATION_MINUTES: Double = 30.0
    
    // MARK: - Published Properties
    @Published var currentTier: SubscriptionTier = .free
    @Published var isInTrial = false
    // TIME-BASED TRIAL: Track days remaining instead of minutes
    @Published var trialDaysRemaining: Int = TRIAL_DURATION_DAYS
    @Published private(set) var trialExpiresAt: Date?
    
    // WORD-BASED TRIAL: Track words used and remaining
    @Published private(set) var trialWordsUsed: Int = 0
    @Published private(set) var trialWordsRemaining: Int = TRIAL_WORD_LIMIT
    
    // DEPRECATED: Usage-based trial properties (commented out)
    // @Published private(set) var trialMinutesRemaining: Double = TRIAL_DURATION_MINUTES
    @Published private(set) var monthlyUsage = MonthlyUsage()
    @Published var features: SubscriptionFeatures
    
    // Computed properties for UI consistency
    var trialDaysUsed: Int {
        return Self.TRIAL_DURATION_DAYS - trialDaysRemaining
    }
    
    var maxTrialDays: Int {
        return Self.TRIAL_DURATION_DAYS
    }
    
    // DEPRECATED: Usage-based trial computed properties (commented out)
    // var trialMinutesUsed: Double {
    //     return trialDurationMinutes - trialMinutesRemaining
    // }
    // var maxTrialMinutes: Double {
    //     return trialDurationMinutes
    // }
    
    // MARK: - Services - Updated for Supabase
    private let supabaseService = SupabaseServiceSDK.shared
    private let userStatsService = UserStatsService.shared
    // Enable device fingerprinting for enhanced trial security
    private let deviceFingerprint = DeviceFingerprintService.shared
    // PHASE 2: Secure keychain storage for trial data
    private let keychainManager = KeychainManager.shared
    // REACTIVATED: Polar-based license system
    private let licenseViewModel = LicenseViewModel.shared
    // NEW: License sync service for Polar + Supabase integration
    private let licenseSyncService = LicenseSyncService.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Grace Period Tracking
    private var recordingStartTime: Date?
    private var recordingStartWordsRemaining: Int?
    
    // MARK: - Constants
    private let trialDurationDays: Int = SubscriptionManager.TRIAL_DURATION_DAYS
    
    // DEPRECATED: Usage-based trial duration (commented out)
    // private let trialDurationMinutes: Double = SubscriptionManager.TRIAL_DURATION_MINUTES
    private let userDefaults = UserDefaults.standard
    private let entitlementCacheKey = "EntitlementSnapshotExpiresAt"
    
    // MARK: - Timer Management 
    private var trialCheckTimer: Timer?
    
    // DEPRECATED: Usage-based sync management (commented out)
    // private var syncTimer: Timer?
    // private var hasPendingSync = false
    
    struct MonthlyUsage: Codable {
        var transcriptionMinutes: Double = 0
        var enhancementWords: Int = 0
        var trialWordsUsed: Int = 0  // Combined ASR + LLM words for trial tracking
        var lastResetDate: Date = Date()
        
        mutating func resetIfNeeded() {
            let calendar = Calendar.current
            let now = Date()
            
            if !calendar.isDate(now, equalTo: lastResetDate, toGranularity: .month) {
                transcriptionMinutes = 0
                enhancementWords = 0
                // Note: trialWordsUsed is NOT reset monthly - it's trial lifetime usage
                lastResetDate = now
            }
        }
    }
    
    private init() {
        // COMMENTED OUT: Polar-based initialization
        // self.licenseViewModel = LicenseViewModel()
        self.features = SubscriptionFeatures(tier: .free, trialDaysRemaining: Self.TRIAL_DURATION_DAYS, trialWordsUsed: 0)
        
        setupSubscriptions()
        loadSubscriptionState()
        startTrialCheckTimer()
    }
    
    // MARK: - Setup
    
    private func setupSubscriptions() {
        // Listen to both Supabase authentication AND license changes
        supabaseService.$currentSession
            .sink { [weak self] _ in
                Task { [weak self] in
                    await self?.updateSubscriptionState()
                }
            }
            .store(in: &cancellables)
        
        // REACTIVATED: License-based listener for Polar licenses
        NotificationCenter.default.publisher(for: .licenseStatusChanged)
            .sink { [weak self] _ in
                self?.updateSubscriptionState()
            }
            .store(in: &cancellables)
        
        // Check usage periodically and sync to cloud every 24 hours
        Timer.publish(every: 3600, on: .main, in: .common) // Every hour
            .autoconnect()
            .sink { [weak self] _ in
                self?.checkAndResetMonthlyUsage()
                Task { [weak self] in
                    await self?.userStatsService.syncStatsIfNeeded()
                }
            }
            .store(in: &cancellables)
        
        // Proactive authentication refresh every 30 minutes to prevent session expiry
        Timer.publish(every: 1800, on: .main, in: .common) // Every 30 minutes
            .autoconnect()
            .sink { [weak self] _ in
                Task { [weak self] in
                    await self?.refreshAuthenticationIfNeeded()
                }
            }
            .store(in: &cancellables)

        // Daily Polar → Supabase sync to reflect cancellations/renewals if a license is stored
        Timer.publish(every: 86400, on: .main, in: .common) // Every 24 hours
            .autoconnect()
            .sink { _ in
                let defaults = UserDefaults.standard
                let hasLicense = defaults.string(forKey: "PolarLicenseKey") != nil ||
                                 defaults.string(forKey: "polar_license_key") != nil ||
                                 defaults.string(forKey: "IoLicense") != nil
                if hasLicense {
                    Task { await LicenseSyncService.shared.validateAndSync() }
                }
            }
            .store(in: &cancellables)
    }
    
    private func loadSubscriptionState() {
        // PHASE 2: Perform integrity validation on app launch
        performTrialIntegrityValidation()
        
        // Check license state first
        updateSubscriptionState()
        
        // Load monthly usage
        if let usageData = userDefaults.data(forKey: "ClioMonthlyUsage"),
           let usage = try? JSONDecoder().decode(MonthlyUsage.self, from: usageData) {
            monthlyUsage = usage
            
            // Load trial words from local storage
            trialWordsUsed = monthlyUsage.trialWordsUsed
            trialWordsRemaining = max(0, Self.TRIAL_WORD_LIMIT - trialWordsUsed)
            print("📊 [STARTUP] Loaded trial words: \(trialWordsUsed)/\(Self.TRIAL_WORD_LIMIT), remaining: \(trialWordsRemaining)")
            
            checkAndResetMonthlyUsage()
        }
        
        // Check trial expiry
        checkTrialExpiry()
    }
    
    // PHASE 2: Comprehensive trial integrity validation on app launch
    private func performTrialIntegrityValidation() {
        // 1. Environment checks
        performEnvironmentSecurityChecks()
        
        // 2. Check if trial data exists in both Keychain and UserDefaults
        let hasKeychainData = keychainManager.hasTrialData()
        let hasUserDefaultsData = userDefaults.object(forKey: "TrialStartDate") != nil
        
        if hasKeychainData {
            // Validate Keychain data integrity
            if let trialDates = keychainManager.getTrialDates() {
                print("✅ Trial data integrity validation passed")
                
                // 3. Validate trial dates are reasonable
                if validateTrialDatesReasonable(startDate: trialDates.startDate, expiryDate: trialDates.expiryDate) {
                    print("✅ Trial dates validation passed")
                } else {
                    print("⚠️ Trial dates appear suspicious - possible tampering")
                    handleSuspiciousActivity(reason: "Invalid trial dates")
                }
                
                // Clean up old UserDefaults data if migration completed
                if hasUserDefaultsData {
                    userDefaults.removeObject(forKey: "TrialStartDate")
                    userDefaults.removeObject(forKey: "TrialExpiryDate")
                    print("✅ Cleaned up migrated UserDefaults trial data")
                }
            } else {
                print("ℹ️ Trial data integrity validation failed - clearing inconsistent data")
                // Don't treat this as suspicious activity - could be legitimate system changes
                keychainManager.clearTrialData()
            }
        } else if hasUserDefaultsData {
            print("🔄 Trial data found in UserDefaults - will migrate to Keychain on next access")
        }
    }
    
    // PHASE 2: Environment security checks
    private func performEnvironmentSecurityChecks() {
        #if DEBUG
        // print("🛠️ Debug mode - security checks relaxed")
        return
        #else
        
        // Check for debugger attachment (only log, don't treat as suspicious by default)
        if isDebuggerAttached() {
            print("ℹ️ Debugger detected during development")
        }
        
        // Check for suspicious app bundle modifications (only log, don't treat as suspicious by default)
        if !validateAppBundle() {
            print("ℹ️ App bundle validation check completed")
        }
        
        #endif
    }
    
    // PHASE 2: Validate trial dates are reasonable
    private func validateTrialDatesReasonable(startDate: Date, expiryDate: Date) -> Bool {
        let now = Date()
        let maxValidTrialDuration: TimeInterval = 365 * 24 * 60 * 60 // 1 year max
        let minValidTrialDuration: TimeInterval = 1 * 60 * 60 // 1 hour min
        
        // Check if start date is not too far in the past or future
        let timeSinceStart = now.timeIntervalSince(startDate)
        guard timeSinceStart >= -3600 && timeSinceStart <= maxValidTrialDuration else {
            return false
        }
        
        // Check if trial duration is reasonable
        let trialDuration = expiryDate.timeIntervalSince(startDate)
        guard trialDuration >= minValidTrialDuration && trialDuration <= maxValidTrialDuration else {
            return false
        }
        
        return true
    }
    
    // PHASE 2: Handle suspicious activity
    private func handleSuspiciousActivity(reason: String) {
        print("🚨 Suspicious activity detected: \(reason)")
        
        // Log the incident
        Task {
            await trackEvent(.suspiciousActivity(reason: reason))
        }
        
        // Reset trial state to be safe
        isInTrial = false
        trialDaysRemaining = 0
        trialExpiresAt = nil
        currentTier = .free
        features = SubscriptionFeatures(tier: .free, trialDaysRemaining: 0, trialWordsUsed: trialWordsUsed)
        
        // Could implement more severe measures here:
        // - Clear all trial data
        // - Require re-authentication
        // - Show warning to user
    }
    
    // PHASE 2: Check for debugger attachment
    private func isDebuggerAttached() -> Bool {
        var info = kinfo_proc()
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        var size = MemoryLayout.stride(ofValue: info)
        
        let result = sysctl(&mib, u_int(mib.count), &info, &size, nil, 0)
        if result != 0 {
            return false
        }
        
        return (info.kp_proc.p_flag & P_TRACED) != 0
    }
    
    // PHASE 2: Validate app bundle integrity
    private func validateAppBundle() -> Bool {
        guard let bundlePath = Bundle.main.bundlePath as NSString? else {
            return false
        }
        
        // Check if main executable exists and has reasonable size
        let executablePath = bundlePath.appendingPathComponent("Contents/MacOS/Clio")
        
        guard FileManager.default.fileExists(atPath: executablePath) else {
            return false
        }
        
        // Get file attributes
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: executablePath),
              let fileSize = attributes[.size] as? UInt64 else {
            return false
        }
        
        // Reasonable size check (between 1MB and 500MB)
        return fileSize > 1_000_000 && fileSize < 500_000_000
    }
    
    // MARK: - State Management
    
    /// Proactively refresh authentication session before critical subscription checks
    @MainActor private func refreshAuthenticationIfNeeded() async {
        guard let session = supabaseService.currentSession else {
            // print("🔄 [AUTH_REFRESH] No session to refresh")
            return
        }
        
        // Check if session is close to expiring (within 5 minutes)
        let expiresAt = session.expiresAt
        let timeUntilExpiry = expiresAt.timeIntervalSinceNow
        let shouldRefresh = timeUntilExpiry < 300 // 5 minutes
        
        if shouldRefresh {
            // print("🔄 [AUTH_REFRESH] Session expires in \(Int(timeUntilExpiry/60)) minutes - refreshing...")
            do {
                // Use the public refreshSession method which triggers auth state listener
                try await supabaseService.refreshSession()
                print("✅ [AUTH_REFRESH] Session refreshed successfully")
            } catch {
                print("⚠️ [AUTH_REFRESH] Failed to refresh session: \(error)")
            }
        } else {
            // print("🔄 [AUTH_REFRESH] Session still valid for \(Int(timeUntilExpiry/60)) minutes")
        }
    }
    
    @MainActor internal func updateSubscriptionState() {
        // print("🔍 [UPDATE_STATE] === updateSubscriptionState() called ===")
        // print("🔍 [UPDATE_STATE] Current state before update - currentTier: \(currentTier), isInTrial: \(isInTrial)")
        // print("🔍 [UPDATE_STATE] 1. Polar canUseApp: \(licenseViewModel.canUseApp)")
        // print("🔍 [UPDATE_STATE] 1b. Polar shouldUsePolarTrial: \(licenseViewModel.shouldUsePolarTrial)")
        // print("🔍 [UPDATE_STATE] 2. Supabase session: \(supabaseService.currentSession?.user.email ?? "nil")")
        
        // DEBUG: Show which tier system will be used
        if licenseViewModel.canUseApp {
            // print("🚨 [DEBUG] Will use TIER 1: Polar License System")
        } else if supabaseService.currentUser != nil {
            // print("🚨 [DEBUG] Will use TIER 2: Supabase Subscription System")
            // print("🚨 [DEBUG] Supabase user: \(supabaseService.currentUser?.email ?? "nil")")
            // print("🚨 [DEBUG] User subscription status: \(supabaseService.currentUser?.subscriptionStatus.rawValue ?? "nil")")
            // print("🚨 [DEBUG] User subscription plan: \(supabaseService.currentUser?.subscriptionPlan?.rawValue ?? "nil")")
        } else {
            // print("🚨 [DEBUG] Will use TIER 3: Local Trial System")
        }
        
        // If session is nil, check Polar first, then fall back to entitlement snapshot/local trial system  
        if supabaseService.currentSession == nil {
            DebugLogger.debug("No Supabase session available - checking Polar and local trial system", category: .subscription)
            // Don't call server-validated trial without a session - fall through to Polar/local logic instead
        }
        
        // INTEGRATED AUTHENTICATION: Polar + Supabase tiered validation system
        // print("🔍 [SUBSCRIPTION] === INTEGRATED AUTHENTICATION SYSTEM ===")
        
        // TIER 1: Polar License Validation (Highest Priority - Paying Customers)
        // print("🚨 [CRITICAL DEBUG] [TIER 1] Checking Polar license status...")
        // print("🚨 [CRITICAL DEBUG] License State: \(licenseViewModel.licenseState)")
        // print("🚨 [CRITICAL DEBUG] Can Use App: \(licenseViewModel.canUseApp)")
        // print("🚨 [CRITICAL DEBUG] Should Use Polar Trial: \(licenseViewModel.shouldUsePolarTrial)")
        
        // CRITICAL FIX: Only use Polar license/trial if shouldUsePolarTrial is true
        // This prevents the default .trial(daysRemaining: 7) from overriding Supabase Pro subscriptions
        if licenseViewModel.canUseApp || licenseViewModel.shouldUsePolarTrial {
            switch licenseViewModel.licenseState {
            case .licensed:
                // If we don't have a Supabase session, align with Polar's state to respect trial timing
                if supabaseService.currentSession == nil,
                   let polarEnd = userDefaults.object(forKey: "PolarTrialEndsAt") as? Date,
                   polarEnd > Date() {
                    let remaining = max(0, Int(ceil(polarEnd.timeIntervalSince(Date()) / (24*60*60))))
                    currentTier = .pro
                    isInTrial = true
                    trialDaysRemaining = remaining
                    features = SubscriptionFeatures(tier: currentTier, trialDaysRemaining: trialDaysRemaining, trialWordsUsed: trialWordsUsed)
                    syncTrialState()
                    return
                } else {
                    currentTier = .pro
                    isInTrial = false
                    trialDaysRemaining = 0
                    features = SubscriptionFeatures(tier: currentTier, trialDaysRemaining: trialDaysRemaining, trialWordsUsed: trialWordsUsed)
                    syncTrialState()
                }
                
                // Sync Polar state to Supabase for consistency
                Task {
                    await licenseSyncService.validateAndSync()
                }
                return
                
            case .trial(let daysRemaining):
                // print("🚨 [CRITICAL DEBUG] POLAR TRIAL DETECTED - EARLY RETURN!")
                // print("🚨 [CRITICAL DEBUG] Days remaining: \(daysRemaining)")
                // Use Polar trial if available
                currentTier = .pro  // Polar trial gives Pro features
                isInTrial = true
                trialDaysRemaining = daysRemaining
                features = SubscriptionFeatures(tier: currentTier, trialDaysRemaining: trialDaysRemaining, trialWordsUsed: trialWordsUsed)
                syncTrialState()
                // print("✅ [SUBSCRIPTION] [TIER 1] Using Polar trial - \(daysRemaining) days remaining")
                
                // Sync Polar state to Supabase for consistency
                Task {
                    await licenseSyncService.validateAndSync()
                }
                return
        
            case .trialExpired:
                // print("🚨 [CRITICAL DEBUG] POLAR TRIAL EXPIRED - CONTINUING TO TIER 2!")
                // Continue to Tier 2: Supabase validation
                break
            } // End of switch licenseViewModel.licenseState
        } else {
            // print("🚨 [CRITICAL DEBUG] SKIPPING POLAR TIER 1 - shouldUsePolarTrial is false")
            // print("🚨 [CRITICAL DEBUG] This allows Supabase Pro subscription to be checked!")
        } // End of Tier 1: Polar validation
        
        // TIER 2: Supabase Subscription Validation (Account-based subscriptions)  
        // print("🚨 [CRITICAL DEBUG] About to check Tier 2 condition...")
        // print("🚨 [CRITICAL DEBUG] supabaseService.currentSession: \(supabaseService.currentSession != nil ? "NOT NIL" : "NIL")")
        // print("🚨 [CRITICAL DEBUG] supabaseService.currentUser: \(supabaseService.currentUser != nil ? "NOT NIL" : "NIL")")
        
        if let session = supabaseService.currentSession {
            // print("🚨 [CRITICAL] ENTERED TIER 2 LOGIC!")
            // print("🔍 [SUBSCRIPTION] [TIER 2] Checking Supabase subscription...")
            let user = session.user
            // print("🔍 [SUBSCRIPTION] User email: \(user.email ?? "nil")")
            // print("🔍 [SUBSCRIPTION] Raw subscription status: '\(user.subscriptionStatus.rawValue)'")
            // print("🔍 [SUBSCRIPTION] Raw subscription plan: '\(user.subscriptionPlan?.rawValue ?? "nil")'")
            // print("🔍 [SUBSCRIPTION] Status == .active: \(user.subscriptionStatus == .active)")
            // print("🔍 [SUBSCRIPTION] Plan != nil: \(user.subscriptionPlan != nil)")
            // print("🔍 [SUBSCRIPTION] Trial ends at: \(user.trialEndsAt?.description ?? "nil")")
            // print("🔍 [SUBSCRIPTION] Subscription expires at: \(user.subscriptionExpiresAt?.description ?? "nil")")
            
            // Get subscription tier from Supabase user profile
            // print("🚨 [DEBUG] Checking subscription condition:")
            // print("🚨 [DEBUG] user.subscriptionStatus == .active: \(user.subscriptionStatus == .active)")
            // print("🚨 [DEBUG] user.subscriptionPlan != nil: \(user.subscriptionPlan != nil)")
            // print("🚨 [DEBUG] Combined condition: \(user.subscriptionStatus == .active && user.subscriptionPlan != nil)")
            // print("🚨 [CRITICAL] ABOUT TO CHECK THE MAIN SUBSCRIPTION CONDITION!")
            
            // CRITICAL DEBUG: Let's see why this condition might be failing
            // print("🚨 [CRITICAL DEBUG] Checking subscription condition:")
            // print("🚨 [CRITICAL DEBUG] user.subscriptionStatus: \(user.subscriptionStatus)")
            // print("🚨 [CRITICAL DEBUG] user.subscriptionStatus.rawValue: '\(user.subscriptionStatus.rawValue)'")
            // print("🚨 [CRITICAL DEBUG] user.subscriptionStatus == .active: \(user.subscriptionStatus == .active)")
            // print("🚨 [CRITICAL DEBUG] user.subscriptionPlan: \(String(describing: user.subscriptionPlan))")
            // print("🚨 [CRITICAL DEBUG] user.subscriptionPlan != nil: \(user.subscriptionPlan != nil)")
            // print("🚨 [CRITICAL DEBUG] Combined condition result: \(user.subscriptionStatus == .active && user.subscriptionPlan != nil)")
            
            // Prefer expires_at as source of truth: active until end date
            if let exp = user.subscriptionExpiresAt, exp > Date(), let plan = user.subscriptionPlan {
                let newTier = SubscriptionTier.from(supabasePlan: plan.rawValue)
                currentTier = newTier
                isInTrial = false
                trialDaysRemaining = 0
                features = SubscriptionFeatures(tier: currentTier, trialDaysRemaining: trialDaysRemaining, trialWordsUsed: trialWordsUsed)
                // Cache entitlement snapshot for offline stability
                userDefaults.set(exp, forKey: entitlementCacheKey)
                // print("✅ [SUBSCRIPTION] [TIER 2] Using Supabase Pro by expiry - pro tier until \(exp)")
                syncTrialState()
                return
            } else if user.subscriptionStatus == .active && user.subscriptionPlan != nil {
                // print("🎉 [CRITICAL] CONDITION PASSED! Pro user detected!")
                let newTier = SubscriptionTier.from(supabasePlan: user.subscriptionPlan?.rawValue)
                // print("🔍 [SUBSCRIPTION] Supabase Pro user detected!")
                // print("🔍 [SUBSCRIPTION] Plan '\(user.subscriptionPlan?.rawValue ?? "nil")' → Tier: \(newTier)")
                
                currentTier = newTier
                isInTrial = false
                trialDaysRemaining = 0
                features = SubscriptionFeatures(tier: currentTier, trialDaysRemaining: trialDaysRemaining, trialWordsUsed: trialWordsUsed)
                // Cache entitlement snapshot if expires_at is available
                if let exp = user.subscriptionExpiresAt { userDefaults.set(exp, forKey: entitlementCacheKey) }
                
                // print("🚨 [DEBUG] SETTING isInTrial = false for active Pro subscription")
                syncTrialState()
                
                // print("✅ [SUBSCRIPTION] [TIER 2] Using Supabase Pro subscription - \(currentTier) tier")
                // print("🔍 [SUBSCRIPTION] Final state: currentTier=\(currentTier), isInTrial=\(isInTrial)")
                return
            } else if user.subscriptionStatus == .trial {
                // print("🚨 [CRITICAL DEBUG] CONDITION FAILED - User has trial status")
                // print("🚨 [CRITICAL DEBUG] This is why user shows as trial despite being Pro!")
                // print("🔍 [SUBSCRIPTION] Following trial path")
                // Check if trial is still valid (time-based only)
                if let trialEnd = user.trialEndsAt, trialEnd > Date() {
                    currentTier = .pro
                    isInTrial = true
                    let remainingTime = trialEnd.timeIntervalSince(Date())
                    trialDaysRemaining = max(0, Int(ceil(remainingTime / (24 * 60 * 60))))
                } else {
                    // Trial expired by time
                    currentTier = .free
                    isInTrial = false
                    trialDaysRemaining = 0
                    // print("🔍 [SUBSCRIPTION] Trial expired by time - setting to free")
                }
            } else {
                // Free tier or no subscription - check local trial
                // print("🚨 [CRITICAL DEBUG] FALLBACK ELSE HIT!")
                // print("🚨 [SUBSCRIPTION] Fallback hit! Status: \(user.subscriptionStatus), Plan: \(user.subscriptionPlan?.rawValue ?? "nil")")
                // print("🚨 [SUBSCRIPTION] User email: \(user.email ?? "nil")")
                // print("🚨 [SUBSCRIPTION] This should NOT happen for authenticated pro users!")
                // print("🚨 [CRITICAL DEBUG] Raw subscription status value: '\(user.subscriptionStatus.rawValue)'")
                // print("🚨 [CRITICAL DEBUG] Raw subscription plan value: '\(user.subscriptionPlan?.rawValue ?? "NONE")'")
                // print("🚨 [CRITICAL DEBUG] Status enum comparison: \(user.subscriptionStatus == SubscriptionStatus.active)")
                updateTrialState()
                return
            }
            
            features = SubscriptionFeatures(tier: currentTier, trialDaysRemaining: trialDaysRemaining, trialWordsUsed: trialWordsUsed)
            syncTrialState()
            return
        }
        
        // TIER 2.5: Entitlement snapshot fallback when offline/no session
        if supabaseService.currentSession == nil,
           let snapExp = userDefaults.object(forKey: entitlementCacheKey) as? Date,
           snapExp > Date() {
            print("🔐 [ENTITLEMENT] Using cached paid entitlement until \(snapExp)")
            currentTier = .pro
            isInTrial = false
            trialDaysRemaining = 0
            features = SubscriptionFeatures(tier: currentTier, trialDaysRemaining: trialDaysRemaining, trialWordsUsed: trialWordsUsed)
            syncTrialState()
            return
        }

        // TIER 3: Local Trial System (Fallback when neither Polar nor Supabase available)
        // print("🔍 [SUBSCRIPTION] [TIER 3] Using local trial system fallback...")
        updateTrialState()
        
        // COMMENTED OUT: Old license-based logic
        // switch licenseViewModel.licenseState {
        // case .licensed:
        //     currentTier = .pro
        //     isInTrial = false
        // case .trial(let daysRemaining):
        //     currentTier = .pro
        //     isInTrial = false
        // case .trialExpired:
        //     updateTrialState()
        //     if !isInTrial {
        //         currentTier = .free
        //     }
        // }
    }
    
    /// Updates trial state using server-side validation
    private func updateServerValidatedTrialState() async {
        // If user is signed in with a valid Supabase session, skip server-side device trial logic
        guard supabaseService.currentSession == nil else {
            return
        }
        
        let validationResult = await ServerTrialValidator.shared.validateTrialStatus()
        
        await MainActor.run {
            if validationResult.isValid {
                // print("✅ [SUBSCRIPTION] Server-validated trial is active")
                isInTrial = true
                currentTier = .pro
                trialDaysRemaining = validationResult.daysRemaining
                trialExpiresAt = validationResult.expiryDate
            } else {
                // print("❌ [SUBSCRIPTION] Server-validated trial expired or invalid: \(validationResult.reason)")
                isInTrial = false
                currentTier = .free
                trialDaysRemaining = 0
                trialExpiresAt = nil
            }
            
            features = SubscriptionFeatures(tier: currentTier, trialDaysRemaining: trialDaysRemaining, trialWordsUsed: trialWordsUsed)
            
            // Sync @Published isInTrial with word-based trial status
            syncTrialState()
            
            objectWillChange.send()
        }
    }
    
    /// Synchronizes @Published isInTrial with the word-based trial status
    private func syncTrialState() {
        print("🔄 [SYNC_STATE] syncTrialState called - currentTier: \(currentTier), isInTrial: \(isInTrial)")
        
        // Enforce entitlement invariants first
        enforceEntitlementInvariants()
        
        // For free tier users, ensure word-based trial reflects state after invariants
        if currentTier == .free {
            let wasInTrial = isInTrial
            isInTrial = trialWordsRemaining > 0
            print("🔄 [SYNC_STATE] Free tier user - changed isInTrial from \(wasInTrial) to \(isInTrial) (words remaining: \(trialWordsRemaining))")
        }
        // For paid tiers, isInTrial should remain as set by subscription logic above
        
        // NEW: Sync local trial word count with Supabase if user is authenticated
        if let session = supabaseService.currentSession {
            Task {
                await syncTrialWordsFromSupabase()
            }
        }
        
        print("🔄 [SYNC_STATE] Final state after syncTrialState - currentTier: \(currentTier), isInTrial: \(isInTrial)")
    }

    /// Enforce invariant: paid entitlements must never be marked as trial
    private func enforceEntitlementInvariants() {
        let hasPaid = hasActivePaidEntitlement()
        if hasPaid && isInTrial {
            print("🔒 [INVARIANT] Paid entitlement detected → forcing isInTrial = false")
            isInTrial = false
        }
    }

    /// Returns true if user has a paid entitlement (Polar license OR Supabase active subscription)
    private func hasActivePaidEntitlement() -> Bool {
        // Polar license
        if case .licensed = licenseViewModel.licenseState { return true }
        // Supabase active subscription
        if let session = supabaseService.currentSession, session.user.subscriptionStatus == .active { return true }
        return false
    }
    
    /// Sync trial word count from Supabase to local storage
    private func syncTrialWordsFromSupabase() async {
        guard let session = supabaseService.currentSession else { return }
        
        // Get the remote trial words used from Supabase
        if let remoteWordsUsed = session.user.trialWordsUsed {
            let localWordsUsed = trialWordsUsed
            
            if remoteWordsUsed != localWordsUsed {
                print("🔄 [SYNC] Trial word count mismatch - Local: \(localWordsUsed), Remote: \(remoteWordsUsed)")
                
                // Use the higher value to prevent losing progress
                let correctWordsUsed = max(localWordsUsed, remoteWordsUsed)
                print("🔄 [SYNC] Using higher value: \(correctWordsUsed)")
                
                // Update both local and remote to the correct value
                monthlyUsage.trialWordsUsed = correctWordsUsed
                trialWordsUsed = correctWordsUsed
                trialWordsRemaining = max(0, Self.TRIAL_WORD_LIMIT - trialWordsUsed)
                saveMonthlyUsage()
                
                // Sync the correct value back to Supabase if it was lower
                if remoteWordsUsed < correctWordsUsed {
                    print("🔄 [SYNC] Updating Supabase with correct value: \(correctWordsUsed)")
                    let currentCorrectWordsUsed = correctWordsUsed  // Capture value
                    Task.detached(priority: .background) { [weak self] in
                        await self?.syncTrialWordsToSupabase(trialWordsUsed: currentCorrectWordsUsed, retryCount: 0)
                    }
                }
                
                // Update features to reflect synced trial status
                if let session = supabaseService.currentSession, session.user.subscriptionStatus == .active {
                    // Pro users with active subscriptions - must be non-trial
                    print("🔍 [SYNC] Active Pro subscription detected - forcing isInTrial = false during sync")
                    isInTrial = false
                } else if let session = supabaseService.currentSession, session.user.subscriptionStatus == .trial {
                    // Keep isInTrial as set by Supabase authentication (don't override)
                    print("🔍 [SYNC] Preserving Supabase trial status during sync: isInTrial = \(isInTrial)")
                } else {
                    // For local/legacy trials, use word-based logic
                    isInTrial = currentTier == .free && trialWordsRemaining > 0
                }
                features = SubscriptionFeatures(tier: currentTier, trialDaysRemaining: trialDaysRemaining, trialWordsUsed: trialWordsUsed)
                
                print("✅ [SYNC] Trial words synced: \(trialWordsUsed)/\(Self.TRIAL_WORD_LIMIT), remaining: \(trialWordsRemaining)")
            } else {
                print("ℹ️ [SYNC] Trial word counts already synced: \(trialWordsUsed)")
            }
        }
    }
    
    // DEPRECATED: Old usage-based updateTrialState method (commented out)
    // private func updateTrialStateOld() {
    //     // UPDATED: Use local trial for users not signed in
    //     let trialMinutesUsed = userDefaults.double(forKey: "TrialMinutesUsed")
    //     let remainingMinutes = max(0, trialDurationMinutes - trialMinutesUsed)
    //     
    //     if remainingMinutes > 0 {
    //         isInTrial = true
    //         trialMinutesRemaining = remainingMinutes
    //         currentTier = .pro // Give Pro features during trial
    //     } else {
    //         isInTrial = false
    //         trialMinutesRemaining = 0
    //         currentTier = .free
    //     }
    //     
    //     features = SubscriptionFeatures(tier: currentTier, trialMinutesRemaining: trialMinutesRemaining)
    // }
        
        // COMMENTED OUT: Old device fingerprint-based logic
        // let remainingMinutes = deviceFingerprint.getRemainingTrialMinutes()
        // if remainingMinutes > 0 && !licenseViewModel.canUseApp {
        //     isInTrial = true
        //     trialMinutesRemaining = remainingMinutes
        //     currentTier = .pro
        // } else {
        //     isInTrial = false
        //     trialMinutesRemaining = 0
        //     if licenseViewModel.licenseState == .trialExpired {
        //         currentTier = .free
        //     }
        // }
    
    // DEPRECATED: Usage-based trial from Supabase (commented out)
    // private func updateTrialMinutesFromSupabase(user: User) {
    //     // Calculate remaining minutes based on trial_minutes_used in Supabase
    //     let usedMinutes = user.trialMinutesUsed ?? 0
    //     trialMinutesRemaining = max(0, trialDurationMinutes - usedMinutes)
    // }
    
    // PHASE 2: Secure trial state update with integrity validation
    private func updateTrialState() {
        // Try Keychain first (secure), then fall back to UserDefaults (migration support)
        var startDate: Date?
        var expiryDate: Date?
        
        if let keychainDates = keychainManager.getTrialDates() {
            // Keychain data available and validated
            startDate = keychainDates.startDate
            expiryDate = keychainDates.expiryDate
        } else if let userDefaultsStartDate = userDefaults.object(forKey: "TrialStartDate") as? Date,
                  let userDefaultsExpiryDate = userDefaults.object(forKey: "TrialExpiryDate") as? Date {
            // Migrate from UserDefaults to Keychain
            startDate = userDefaultsStartDate
            expiryDate = userDefaultsExpiryDate
            
            // Store in Keychain for future use
            if keychainManager.setTrialDates(startDate: userDefaultsStartDate, expiryDate: userDefaultsExpiryDate) {
                // Clear UserDefaults after successful migration
                userDefaults.removeObject(forKey: "TrialStartDate")
                userDefaults.removeObject(forKey: "TrialExpiryDate")
                print("✅ Migrated trial data from UserDefaults to Keychain")
            }
        } else {
            // No trial data found
            isInTrial = false
            trialDaysRemaining = 0
            self.trialExpiresAt = nil
            return
        }
        
        guard let validStartDate = startDate, let validExpiryDate = expiryDate else {
            isInTrial = false
            trialDaysRemaining = 0
            self.trialExpiresAt = nil
            return
        }
        
        let now = Date()
        self.trialExpiresAt = validExpiryDate
        
        if now >= validExpiryDate {
            // Trial expired
            isInTrial = false
            trialDaysRemaining = 0
            currentTier = .free
        } else {
            // Trial active - calculate remaining days
            let remainingTime = validExpiryDate.timeIntervalSince(now)
            let remainingDays = max(0, Int(ceil(remainingTime / (24 * 60 * 60))))
            
            isInTrial = true
            trialDaysRemaining = remainingDays
            currentTier = .pro // Give Pro features during trial
        }
        
        // Update features
        features = SubscriptionFeatures(tier: currentTier, trialDaysRemaining: trialDaysRemaining, trialWordsUsed: trialWordsUsed)
        syncTrialState()
    }
    
    // NEW: Force immediate sync (call on sign-in, sign-out, or after significant usage)
    func forceSyncUsageToSupabase() {
        Task {
            await userStatsService.forceSyncStats()
        }
    }
    
    // MARK: - Trial Management
    
    // PHASE 2: Secure trial start with Keychain storage
    func startTrial() {
        // Check if trial already used (check both Keychain and UserDefaults for migration)
        guard !keychainManager.hasTrialData() && userDefaults.object(forKey: "TrialStartDate") == nil else { 
            return 
        }
        
        // Initialize time-based trial
        let startDate = Date()
        let expiryDate = Calendar.current.date(byAdding: .day, value: trialDurationDays, to: startDate) ?? startDate
        
        // Store securely in Keychain with integrity checking
        if !keychainManager.setTrialDates(startDate: startDate, expiryDate: expiryDate) {
            print("⚠️ Failed to store trial data in Keychain - falling back to UserDefaults")
            userDefaults.set(startDate, forKey: "TrialStartDate")
            userDefaults.set(expiryDate, forKey: "TrialExpiryDate")
        }
        
        self.trialExpiresAt = expiryDate
        updateTrialState()
        
        // Track trial start
        Task {
            await trackEvent(.trialStarted)
        }
    }
    
    // DEPRECATED: Usage-based trial start (commented out)
    // func startTrialOld() {
    //     // Check if trial already used
    //     guard userDefaults.double(forKey: "TrialMinutesUsed") == 0 else { return }
    //     
    //     // Initialize trial
    //     userDefaults.set(0.0, forKey: "TrialMinutesUsed")
    //     updateTrialState()
    //     
    //     // Track trial start
    //     Task {
    //         await trackEvent(.trialStarted)
    //     }
    // }
    
    // UPDATED: Device trial method for UI compatibility
    func startDeviceTrial() {
        startTrial()
    }
    
    // PHASE 2: Clear trial data (for testing or support purposes)
    #if DEBUG
    func clearTrialData() -> Bool {
        let keychainSuccess = keychainManager.clearTrialData()
        
        // Also clear UserDefaults for complete cleanup
        userDefaults.removeObject(forKey: "TrialStartDate")
        userDefaults.removeObject(forKey: "TrialExpiryDate")
        
        // Reset trial state
        isInTrial = false
        trialDaysRemaining = Self.TRIAL_DURATION_DAYS
        trialExpiresAt = nil
        currentTier = .free
        features = SubscriptionFeatures(tier: .free, trialDaysRemaining: Self.TRIAL_DURATION_DAYS, trialWordsUsed: trialWordsUsed)
        
        print("🛠️ [DEBUG] Trial data cleared for testing")
        
        return keychainSuccess
    }
    #endif
    
    // COMMENTED OUT: Old device-based trial
    // func startDeviceTrial() {
    //     guard !deviceFingerprint.hasUsedTrial() else { return }
    //     deviceFingerprint.startTrial()
    //     updateTrialState()
    //     Task {
    //         await trackEvent(.trialStarted)
    //     }
    // }
    
    // DEPRECATED: Usage-based trial tracking (commented out)
    // func useTrialMinutes(_ minutes: Double) {
    //     guard isInTrial else { return }
    //     
    //     // Update local trial usage (primary, always reliable)
    //     let currentUsage = userDefaults.double(forKey: "TrialMinutesUsed")
    //     let newUsage = currentUsage + minutes
    //     userDefaults.set(newUsage, forKey: "TrialMinutesUsed")
    //     
    //     // Queue Supabase sync for later (don't block transcription)
    //     if let session = supabaseService.currentSession {
    //         queueSupabaseSync()
    //     }
    //     
    //     updateTrialState()
    //     
    //     if trialMinutesRemaining <= 0 {
    //         // Trial exhausted
    //         Task {
    //             await trackEvent(.trialExhausted)
    //         }
    //     }
    // }
    
    // PHASE 2: Secure trial expiry check with integrity validation
    func checkTrialExpiry() {
        // Try Keychain first, then UserDefaults for migration support
        var expiryDate: Date?
        
        if let keychainDates = keychainManager.getTrialDates() {
            expiryDate = keychainDates.expiryDate
        } else if let userDefaultsExpiryDate = userDefaults.object(forKey: "TrialExpiryDate") as? Date {
            expiryDate = userDefaultsExpiryDate
        } else {
            return // No trial data
        }
        
        guard let validExpiryDate = expiryDate else { return }
        
        self.trialExpiresAt = validExpiryDate
        
        if Date() >= validExpiryDate {
            // Trial expired
            isInTrial = false
            trialDaysRemaining = 0
            
            Task {
                await trackEvent(.trialExhausted)
            }
        } else {
            updateTrialState()
        }
    }
    
    // MARK: - Timer Management
    
    private func startTrialCheckTimer() {
        // Check trial expiry every hour
        trialCheckTimer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { [weak self] _ in
            self?.checkTrialExpiry()
        }
    }
    
    deinit {
        trialCheckTimer?.invalidate()
    }
    
    // DEPRECATED: Usage-based sync management (commented out for time-based trials)
    // MARK: - Batched Sync Management
    // 
    // private func queueSupabaseSync() {
    //     // Mark that we have pending changes
    //     hasPendingSync = true
    //     
    //     // Cancel existing timer if running
    //     syncTimer?.invalidate()
    //     
    //     // Start new timer to batch updates (sync after 3 seconds of inactivity)
    //     syncTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
    //         Task { [weak self] in
    //             await self?.performBatchedSync()
    //         }
    //     }
    // }
    // 
    // private func performBatchedSync() async {
    //     guard hasPendingSync else { return }
    //     
    //     do {
    //         // Get current local usage
    //         let totalUsage = userDefaults.double(forKey: "TrialMinutesUsed")
    //         
    //         // Sync to Supabase (graceful failure)  
    //         await userStatsService.syncTrialUsage(totalMinutes: totalUsage)
    //         
    //         // Clear pending flag on success
    //         await MainActor.run {
    //             hasPendingSync = false
    //         }
    //         
    //         print("✅ Successfully synced trial usage to Supabase: \(totalUsage) minutes")
    //     } catch {
    //         // Fail gracefully - don't block local functionality
    //         print("⚠️ Failed to sync trial usage to Supabase (continuing locally): \(error.localizedDescription)")
    //         
    //         // Don't clear pending flag - will retry later
    //     }
    // }
    
    // Force immediate sync (call on app backgrounding/foregrounding)
    func forceBatchedSync() {
        // syncTimer?.invalidate() // DEPRECATED: property commented out for time-based trials
        Task {
            // await performBatchedSync() // DEPRECATED: method commented out for time-based trials
        }
    }
    
    // DEPRECATED: Old per-transcription sync
    private func updateTrialUsageInSupabase(additionalMinutes: Double) async {
        await userStatsService.updateTrialUsage(additionalMinutes: additionalMinutes)
    }
    
    // MARK: - Usage Tracking
    
    func trackTranscription(durationSeconds: Double) {
        let minutes = durationSeconds / 60.0
        
        // Update monthly usage
        monthlyUsage.transcriptionMinutes += minutes
        saveMonthlyUsage()
        
        // Check if exceeded limits
        if let limit = features.monthlyTranscriptionMinutes,
           monthlyUsage.transcriptionMinutes > Double(limit) {
            // Notify user about limit
            NotificationCenter.default.post(
                name: .subscriptionLimitExceeded,
                object: nil,
                userInfo: ["type": "transcription"]
            )
        }
    }
    
    func trackASRWords(wordCount: Int) {
        // ASR words are NOT counted toward trial - only enhanced text counts
        // This prevents double-counting and excludes filler words from trial usage
        
        // Could track monthly ASR words if needed in the future
        // monthlyUsage.asrWords += wordCount
        // saveMonthlyUsage()
    }
    
    func trackEnhancement(wordCount: Int) {
        monthlyUsage.enhancementWords += wordCount
        saveMonthlyUsage()
        // Time-based trial: no word-limit gating
        print("📊 [ENHANCEMENT] Tracked \(wordCount) words (time-based trial mode)")

        // Check if exceeded limits
        if let limit = features.monthlyEnhancementWords,
           monthlyUsage.enhancementWords > limit {
            // Notify user about limit
            NotificationCenter.default.post(
                name: .subscriptionLimitExceeded,
                object: nil,
                userInfo: ["type": "enhancement"]
            )
        }
    }
    
    private func trackTrialWords(_ wordCount: Int) {
        // Deprecated for gating; retain telemetry only
        monthlyUsage.trialWordsUsed += wordCount
        trialWordsUsed = monthlyUsage.trialWordsUsed
        trialWordsRemaining = max(0, Self.TRIAL_WORD_LIMIT - trialWordsUsed)
        saveMonthlyUsage()
        features = SubscriptionFeatures(tier: currentTier, trialDaysRemaining: trialDaysRemaining, trialWordsUsed: trialWordsUsed)
    }
    
    private func saveMonthlyUsage() {
        if let data = try? JSONEncoder().encode(monthlyUsage) {
            userDefaults.set(data, forKey: "ClioMonthlyUsage")
        }
    }
    
    private func checkAndResetMonthlyUsage() {
        monthlyUsage.resetIfNeeded()
        saveMonthlyUsage()
    }
    
    /// Sync trial words to Supabase with retry logic (background task)
    private func syncTrialWordsToSupabase(trialWordsUsed: Int, retryCount: Int) async {
        let maxRetries = 2
        let baseDelay: TimeInterval = 1.0
        
        do {
            if supabaseService.currentSession != nil {
                try await userStatsService.updateUserStats(trialWordsUsed: trialWordsUsed)
                print("✅ [TRIAL] Synced to Supabase: \(trialWordsUsed) words")
            } else {
                print("ℹ️ [TRIAL] No Supabase session - trial tracked locally only")
            }
        } catch {
            print("⚠️ [TRIAL] Supabase sync failed (attempt \(retryCount + 1)/\(maxRetries + 1)): \(error)")
            
            // Retry with exponential backoff if we haven't exhausted retries
            if retryCount < maxRetries {
                let delay = baseDelay * pow(2.0, Double(retryCount))
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                await syncTrialWordsToSupabase(trialWordsUsed: trialWordsUsed, retryCount: retryCount + 1)
            } else {
                print("❌ [TRIAL] Failed to sync trial words after \(maxRetries + 1) attempts - continuing with local tracking")
            }
        }
    }
    
    // MARK: - Recording Session Management
    
    /// Check if a new recording session can start based on trial limits
    /// This should be called BEFORE recording begins (on hotkey press)
    func canStartNewRecording() -> Bool {
        // Proactively refresh authentication for background operations
        Task {
            await refreshAuthenticationIfNeeded()
        }
        
        // Pro users always allowed
        if currentTier != .free {
            return true
        }
        
        // Free users: allow during active time-based trial (Supabase or local)
        if isTrialActive() { return true }
        
        print("🚨 [TRIAL] Cannot start recording - trial expired")
        return false
    }
    
    /// Start tracking a new recording session for grace period
    func startRecordingSession() {
        recordingStartTime = Date()
        recordingStartWordsRemaining = trialWordsRemaining
        print("📝 [GRACE] Recording session started with \(trialWordsRemaining) words remaining")
    }
    
    /// End the current recording session
    func endRecordingSession() {
        recordingStartTime = nil
        recordingStartWordsRemaining = nil
        print("📝 [GRACE] Recording session ended")
    }
    
    /// Check if user is in grace period (started recording when they had words remaining)
    private func isInGracePeriod() -> Bool {
        guard let startTime = recordingStartTime,
              let startWordsRemaining = recordingStartWordsRemaining else {
            return false
        }
        
        // Grace period: Allow completion if recording started with words remaining
        let hadWordsAtStart = startWordsRemaining > 0
        let withinReasonableTime = Date().timeIntervalSince(startTime) < 300 // 5 minute max session
        
        let inGracePeriod = hadWordsAtStart && withinReasonableTime
        if inGracePeriod {
            print("✅ [GRACE] In grace period - recording started with \(startWordsRemaining) words remaining")
        }
        
        return inGracePeriod
    }
    
    /// Check if AI enhancement should be allowed (includes grace period logic)
    func canUseAIEnhancementNow() -> Bool {
        // Proactively refresh authentication for background operations
        Task {
            await refreshAuthenticationIfNeeded()
        }
        
        // Pro users always allowed
        if currentTier != .free {
            return true
        }
        
        // Check base feature access
        if !features.canUseAIEnhancement {
            return false
        }
        
        return isTrialActive() || isInGracePeriod()
    }
    
    // MARK: - Feature Access
    
    /// Check if AI enhancement is allowed based on subscription tier and trial limits
    func canUseAIEnhancement() -> Bool {
        // Proactively refresh authentication for background operations
        Task {
            await refreshAuthenticationIfNeeded()
        }
        
        // Pro users have unlimited access
        if currentTier != .free {
            print("✅ [FEATURE] AI Enhancement allowed - Pro user")
            return true
        }
        
        // Free users allowed while trial is active (time-based)
        let allowed = isTrialActive()
        if allowed {
            print("✅ [FEATURE] AI Enhancement allowed - active time-based trial")
        } else {
            print("🚨 [FEATURE] AI Enhancement blocked - trial expired")
        }
        return allowed
    }

    // Helper: trial active via Supabase or local time-based trial
    private func isTrialActive() -> Bool {
        if let session = supabaseService.currentSession,
           session.user.subscriptionStatus == .trial,
           let end = session.user.trialEndsAt, end > Date() {
            return true
        }
        return isInTrial && trialDaysRemaining > 0
    }
    
    func canAccessFeature(_ feature: ProFeature) -> Bool {
        switch feature {
        case .largeModels:
            return features.canUseLargeModels
        case .cloudModels:
            return features.canUseCloudModels
        case .aiEnhancement:
            return features.canUseAIEnhancement
        case .customPrompts:
            return features.canUseCustomPrompts
        
        case .unlimitedTranscription:
            return features.monthlyTranscriptionMinutes == nil
        case .unlimitedEnhancement:
            return features.monthlyEnhancementWords == nil
        case .prioritySupport:
            return features.prioritySupport
        case .syncAcrossDevices:
            return features.canSyncAcrossDevices
        }
    }
    
    func getRemainingUsage(for feature: ProFeature) -> UsageInfo? {
        switch feature {
        case .unlimitedTranscription:
            if let limit = features.monthlyTranscriptionMinutes {
                let remaining = Double(limit) - monthlyUsage.transcriptionMinutes
                return UsageInfo(
                    used: monthlyUsage.transcriptionMinutes,
                    limit: Double(limit),
                    remaining: max(0, remaining),
                    unit: "minutes"
                )
            }
        case .unlimitedEnhancement:
            if let limit = features.monthlyEnhancementWords {
                let remaining = limit - monthlyUsage.enhancementWords
                return UsageInfo(
                    used: Double(monthlyUsage.enhancementWords),
                    limit: Double(limit),
                    remaining: Double(max(0, remaining)),
                    unit: "words"
                )
            }
        default:
            break
        }
        return nil
    }
    
    // MARK: - Analytics
    
    enum AnalyticsEvent {
        case trialStarted
        case trialExhausted
        case featureAttempted(ProFeature)
        case limitExceeded(String)
        case upgradePrompted(from: String)
        case suspiciousActivity(reason: String)
    }
    
    private func trackEvent(_ event: AnalyticsEvent) async {
        // Track with Supabase when implemented
        print("[Analytics] Event: \(event)")
    }
    
    
    // MARK: - License Management
    
    /// Access to license management for UI components
    var licenseManager: LicenseViewModel {
        return licenseViewModel
    }
    
    /// Check if user has an active license (Polar or Supabase)
    var hasActiveLicense: Bool {
        // Check Polar license first
        if case .licensed = licenseViewModel.licenseState {
            return true
        }
        
        // Check Supabase subscription
        if let session = supabaseService.currentSession {
            return session.user.subscriptionStatus == .active
        }
        
        return false
    }
    
    // MARK: - Debug & Testing
    
    /// Force refresh authentication session (for debugging or manual refresh)
    func forceRefreshAuthentication() async {
        // print("🔄 [AUTH_REFRESH] Manually triggering authentication refresh...")
        await refreshAuthenticationIfNeeded()
    }
    
    #if DEBUG
    /// Manual trigger for subscription state update (for debugging)
    func forceUpdateSubscriptionState() {
        print("🛠️ [DEBUG] Manually triggering subscription state update...")
        updateSubscriptionState()
    }
    
    /// Print current subscription state (for debugging)
    func printCurrentState() {
        print("🛠️ [DEBUG] === Current Subscription State ===")
        print("🛠️ [DEBUG] currentTier: \(currentTier)")
        print("🛠️ [DEBUG] isInTrial: \(isInTrial)")
        print("🛠️ [DEBUG] trialDaysRemaining: \(trialDaysRemaining)")
        print("🛠️ [DEBUG] trialWordsUsed: \(trialWordsUsed)")
        print("🛠️ [DEBUG] trialWordsRemaining: \(trialWordsRemaining)")
        print("🛠️ [DEBUG] hasActiveLicense: \(hasActiveLicense)")
        
        if let session = supabaseService.currentSession {
            let user = session.user
            print("🛠️ [DEBUG] Supabase User:")
            print("🛠️ [DEBUG]   - email: \(user.email)")
            print("🛠️ [DEBUG]   - subscription_status: \(user.subscriptionStatus.rawValue)")
            print("🛠️ [DEBUG]   - subscription_plan: \(user.subscriptionPlan?.rawValue ?? "nil")")
            print("🛠️ [DEBUG]   - subscription_expires_at: \(user.subscriptionExpiresAt?.description ?? "nil")")
            print("🛠️ [DEBUG]   - trial_ends_at: \(user.trialEndsAt?.description ?? "nil")")
        } else {
            print("🛠️ [DEBUG] No Supabase session")
        }
        
        print("🛠️ [DEBUG] Polar License State: \(licenseViewModel.licenseState)")
        print("🛠️ [DEBUG] ================================")
    }
    #endif
    
    // MARK: - Upgrade Flow
    
    func promptUpgrade(from context: String) {
        Task {
            await trackEvent(.upgradePrompted(from: context))
        }
        
        NotificationCenter.default.post(
            name: .showUpgradePrompt,
            object: nil,
            userInfo: ["context": context]
        )
    }
}

// MARK: - Supporting Types

enum ProFeature: String, CaseIterable {
    case largeModels = "large_models"
    case cloudModels = "cloud_models"
    case aiEnhancement = "ai_enhancement"
    case customPrompts = "custom_prompts"
    case unlimitedTranscription = "unlimited_transcription"
    case unlimitedEnhancement = "unlimited_enhancement"
    case prioritySupport = "priority_support"
    case syncAcrossDevices = "sync_across_devices"
    
    var displayName: String {
        switch self {
        case .largeModels: return "Large Whisper Models"
        case .cloudModels: return "Cloud AI Models"
        case .aiEnhancement: return "AI Text Enhancement"
        case .customPrompts: return "Custom AI Prompts"
        case .unlimitedTranscription: return "Unlimited Transcription"
        case .unlimitedEnhancement: return "Unlimited AI Enhancement"
        case .prioritySupport: return "Priority Support"
        case .syncAcrossDevices: return "Multi-Device Sync"
        }
    }
    
    var icon: String {
        switch self {
        case .largeModels: return "cpu"
        case .cloudModels: return "cloud"
        case .aiEnhancement: return "sparkles"
        case .customPrompts: return "text.quote"
        case .unlimitedTranscription: return "mic.fill"
        case .unlimitedEnhancement: return "infinity"
        case .prioritySupport: return "star.fill"
        case .syncAcrossDevices: return "arrow.triangle.2.circlepath"
        }
    }
}

struct UsageInfo {
    let used: Double
    let limit: Double
    let remaining: Double
    let unit: String
    
    var percentageUsed: Double {
        guard limit > 0 else { return 0 }
        return (used / limit) * 100
    }
    
    var isNearLimit: Bool {
        percentageUsed >= 80
    }
    
    var isAtLimit: Bool {
        remaining <= 0
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let subscriptionLimitExceeded = Notification.Name("subscriptionLimitExceeded")
    static let showUpgradePrompt = Notification.Name("showUpgradePrompt")
    static let subscriptionStateChanged = Notification.Name("subscriptionStateChanged")
    static let showRecordingFailedDialog = Notification.Name("showRecordingFailedDialog")
}
