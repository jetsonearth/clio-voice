import Foundation

/// Service responsible for syncing license state between Polar and Supabase
/// Implements the full Polar + Supabase Integration Architecture
@MainActor
class LicenseSyncService: ObservableObject {
    
    // Import SubscriptionDetails from PolarService
    typealias SubscriptionDetails = PolarService.SubscriptionDetails
    static let shared = LicenseSyncService()
    
    // MARK: - Published Properties
    @Published private(set) var lastSyncDate: Date?
    @Published private(set) var isSyncing = false
    @Published private(set) var lastSyncError: Error?
    
    // MARK: - Dependencies  
    private let supabaseService = SupabaseServiceSDK.shared
    private let polarService = PolarService.shared
    
    private init() {
        // print("🔄 [SYNC] LicenseSyncService initialized - Full Integration")
    }
    
    /// Main sync method - validates with Polar and updates Supabase
    func validateAndSync() async {
        print("🔄 [SYNC] Starting full Polar → Supabase sync")
        
        guard !isSyncing else { 
            print("ℹ️ [SYNC] Already syncing, skipping")
            return 
        }
        
        // Check if we have a stored license key to sync (support both legacy and canonical keys)
        let defaults = UserDefaults.standard
        let licenseKey = defaults.string(forKey: "PolarLicenseKey") ??
                         defaults.string(forKey: "polar_license_key") ??
                         defaults.string(forKey: "IoLicense")
        if let licenseKey = licenseKey, !licenseKey.isEmpty {
            await syncPolarToSupabase(licenseKey: licenseKey)
        } else {
            print("ℹ️ [SYNC] No stored license key found - skipping Polar sync")
            lastSyncDate = Date()
        }
    }
    
    /// Sync specific license key from Polar to Supabase
    func syncPolarToSupabase(licenseKey: String) async {
        print("🔄 [SYNC] Syncing license \(String(licenseKey.prefix(8)))... to Supabase")
        
        guard !isSyncing else { 
            print("ℹ️ [SYNC] Already syncing, skipping")
            return 
        }
        
        isSyncing = true
        lastSyncError = nil
        
        defer { 
            isSyncing = false 
        }
        
        do {
            // Step 1: Get subscription details from Polar
            print("📡 [SYNC] Fetching subscription details from Polar...")
            guard let subscriptionDetails = try await polarService.getSubscriptionDetails(licenseKey: licenseKey) else {
                print("⚠️ [SYNC] No subscription found in Polar for this license")
                lastSyncDate = Date()
                return
            }
            
            // Step 2: Verify user is authenticated with Supabase
            guard let session = supabaseService.currentSession else {
                print("⚠️ [SYNC] No Supabase session - cannot sync subscription details")
                throw SyncError.noSupabaseSession
            }
            
            // Step 3: Update Supabase with subscription details
            print("💾 [SYNC] Updating Supabase with subscription details...")
            try await updateSupabaseSubscription(
                userId: session.user.id,
                subscriptionDetails: subscriptionDetails
            )
            
            lastSyncDate = Date()
            print("✅ [SYNC] Successfully synced Polar subscription to Supabase")
            
            // Trigger subscription manager to refresh state
            NotificationCenter.default.post(name: .licenseStatusChanged, object: nil)
            
        } catch {
            print("❌ [SYNC] Failed to sync license: \(error.localizedDescription)")
            lastSyncError = error
            
            // Handle specific error types
            if let syncError = error as? SyncError {
                switch syncError {
                case .noSupabaseSession:
                    print("ℹ️ [SYNC] No Supabase session - this is expected for license-only users")
                case .polarFetchFailed:
                    print("⚠️ [SYNC] Polar API failed - license validation may still work locally")
                case .supabaseUpdateFailed:
                    print("⚠️ [SYNC] Supabase update failed - app will continue with existing data")
                case .invalidSubscriptionData:
                    print("⚠️ [SYNC] Invalid data from Polar - skipping sync")
                }
            } else {
                // Network or other errors
                print("⚠️ [SYNC] Network or other error during sync - app will continue normally")
                print("⚠️ [SYNC] Error details: \(error)")
            }
        }
    }
    
    /// Update Supabase user profile and subscriptions table with details from Polar
    private func updateSupabaseSubscription(userId: String, subscriptionDetails: SubscriptionDetails) async throws {
        print("📅 [SYNC] Updating Supabase with subscription details")
        
        // Step 1: Update user_profiles table using existing method
        // Map Polar status to user profile fields. If the subscription is in a trial
        // period, set `subscription_status = trial` and populate `trial_ends_at`.
        let statusLower = subscriptionDetails.status.lowercased()
        let isTrial = statusLower.contains("trial") || statusLower.contains("trialing")
        let trialEnds = isTrial ? subscriptionDetails.expirationDate : nil
        let subExpires = isTrial ? nil : subscriptionDetails.expirationDate
        try await supabaseService.updateSubscriptionInfo(
            status: isTrial ? "trial" : "active",
            plan: "pro",
            expiresAt: subExpires,
            trialEndsAt: trialEnds
        )
        
        // Step 2: Update or create record in subscriptions table
        try await syncToSubscriptionsTable(userId: userId, subscriptionDetails: subscriptionDetails)
        
        if let expirationDate = subscriptionDetails.expirationDate {
            print("📅 [SYNC] Set subscription_expires_at: \(expirationDate)")
        } else {
            print("⚠️ [SYNC] No expiration date found in Polar subscription")
        }
        
        print("✅ [SYNC] Updated both user_profiles and subscriptions tables")
    }
    
    /// Sync subscription data to the subscriptions table
    private func syncToSubscriptionsTable(userId: String, subscriptionDetails: SubscriptionDetails) async throws {
        print("📊 [SYNC] Syncing to subscriptions table")
        
        // Prepare subscription data
        let currentPeriodStart: Date = {
            guard let startString = subscriptionDetails.current_period_start else {
                return Date().addingTimeInterval(-365*24*60*60) // 1 year ago fallback
            }
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            return formatter.date(from: startString) ?? Date().addingTimeInterval(-365*24*60*60)
        }()
        
        let currentPeriodEnd = subscriptionDetails.expirationDate ?? Date().addingTimeInterval(365*24*60*60) // 1 year ahead fallback
        
        // Try to update existing record first
        let existingRecords = try await checkExistingSubscription(userId: userId)
        
        if existingRecords.isEmpty {
            // Create new subscription record
            try await createSubscriptionRecord(
                userId: userId,
                subscriptionDetails: subscriptionDetails,
                currentPeriodStart: currentPeriodStart,
                currentPeriodEnd: currentPeriodEnd
            )
        } else {
            // Update existing subscription record
            try await updateSubscriptionRecord(
                userId: userId,
                subscriptionDetails: subscriptionDetails,
                currentPeriodStart: currentPeriodStart,
                currentPeriodEnd: currentPeriodEnd
            )
        }
        
        print("✅ [SYNC] Successfully synced to subscriptions table")
    }
    
    /// Check if user already has a subscription record
    private func checkExistingSubscription(userId: String) async throws -> [[String: Any]] {
        // Use raw HTTP request to Supabase since we need custom query logic
        guard let url = URL(string: "\(supabaseService.apiURL)/rest/v1/subscriptions?user_id=eq.\(userId)&select=id,polar_subscription_id") else {
            throw SyncError.invalidSubscriptionData
        }
        
        var request = URLRequest(url: url)
        request.addValue("Bearer \(supabaseService.apiKey)", forHTTPHeaderField: "apikey")
        request.addValue("Bearer \(supabaseService.currentSession?.accessToken ?? "")", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        
        if let array = json as? [[String: Any]] {
            return array
        } else {
            return []
        }
    }
    
    /// Create new subscription record in subscriptions table
    private func createSubscriptionRecord(
        userId: String,
        subscriptionDetails: SubscriptionDetails,
        currentPeriodStart: Date,
        currentPeriodEnd: Date
    ) async throws {
        print("➕ [SYNC] Creating new subscription record")
        
        let subscriptionData: [String: Any] = [
            "user_id": userId,
            "polar_subscription_id": subscriptionDetails.id,
            "status": "active",
            "current_period_start": ISO8601DateFormatter().string(from: currentPeriodStart),
            "current_period_end": ISO8601DateFormatter().string(from: currentPeriodEnd),
            "cancel_at_period_end": false
        ]
        
        // Use raw HTTP request to create subscription
        guard let url = URL(string: "\(supabaseService.apiURL)/rest/v1/subscriptions") else {
            throw SyncError.supabaseUpdateFailed
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(supabaseService.apiKey)", forHTTPHeaderField: "apikey")
        request.addValue("Bearer \(supabaseService.currentSession?.accessToken ?? "")", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("return=minimal", forHTTPHeaderField: "Prefer")
        
        request.httpBody = try JSONSerialization.data(withJSONObject: subscriptionData, options: [])
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
            throw SyncError.supabaseUpdateFailed
        }
        
        print("✅ [SYNC] Created new subscription record")
    }
    
    /// Update existing subscription record in subscriptions table
    private func updateSubscriptionRecord(
        userId: String,
        subscriptionDetails: SubscriptionDetails,
        currentPeriodStart: Date,
        currentPeriodEnd: Date
    ) async throws {
        print("📝 [SYNC] Updating existing subscription record")
        
        var updateData: [String: Any] = [
            "polar_subscription_id": subscriptionDetails.id,
            "status": "active",
            "current_period_start": ISO8601DateFormatter().string(from: currentPeriodStart),
            "current_period_end": ISO8601DateFormatter().string(from: currentPeriodEnd),
            "updated_at": ISO8601DateFormatter().string(from: Date())
        ]

        // If Polar status is not active but the period end is in the future, treat as cancel_at_period_end
        let now = Date()
        let isCanceledAtPeriodEnd = (subscriptionDetails.status.lowercased() != "active") && currentPeriodEnd > now
        if isCanceledAtPeriodEnd {
            updateData["cancel_at_period_end"] = true
        }
        
        // Use raw HTTP request to update subscription
        guard let url = URL(string: "\(supabaseService.apiURL)/rest/v1/subscriptions?user_id=eq.\(userId)") else {
            throw SyncError.supabaseUpdateFailed
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("Bearer \(supabaseService.apiKey)", forHTTPHeaderField: "apikey")
        request.addValue("Bearer \(supabaseService.currentSession?.accessToken ?? "")", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("return=minimal", forHTTPHeaderField: "Prefer")
        
        request.httpBody = try JSONSerialization.data(withJSONObject: updateData, options: [])
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 204 else {
            throw SyncError.supabaseUpdateFailed
        }
        
        print("✅ [SYNC] Updated existing subscription record")
    }
    
    
    // TODO: Future methods for background sync and advanced validation will go here
    
    /// Store license key for future validation
    func storeLicenseKey(_ licenseKey: String) {
        print("🔄 [SYNC] Storing license key for future validation")
        UserDefaults.standard.set(licenseKey, forKey: "PolarLicenseKey")
    }
    
    /// Clear stored license (for logout/reset)
    func clearStoredLicense() {
        print("🔄 [SYNC] Clearing stored license")
        UserDefaults.standard.removeObject(forKey: "PolarLicenseKey")
    }
}

// MARK: - Supporting Types

enum SyncError: Error, LocalizedError {
    case noSupabaseSession
    case polarFetchFailed
    case supabaseUpdateFailed
    case invalidSubscriptionData
    
    var errorDescription: String? {
        switch self {
        case .noSupabaseSession:
            return "No Supabase session available for sync"
        case .polarFetchFailed:
            return "Failed to fetch subscription details from Polar"
        case .supabaseUpdateFailed:
            return "Failed to update subscription in Supabase"
        case .invalidSubscriptionData:
            return "Invalid subscription data received from Polar"
        }
    }
}
