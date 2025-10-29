import Foundation
import AppKit

@MainActor
class LicenseViewModel: ObservableObject {
    // MARK: - Singleton
    static let shared = LicenseViewModel()
    
    enum LicenseState: Equatable {
        case trial(daysRemaining: Int)
        case trialExpired
        case licensed
    }
    
    @Published private(set) var licenseState: LicenseState = .trial(daysRemaining: SubscriptionManager.TRIAL_DURATION_DAYS)  // Sync with main trial system
    @Published var licenseKey: String = ""
    @Published var isValidating = false
    @Published var validationMessage: String?
    @Published private(set) var activationsLimit: Int = 0
    
    private let trialPeriodDays = SubscriptionManager.TRIAL_DURATION_DAYS  // Use consistent 14-day trial
    private let polarService = PolarService.shared
    private let licenseSyncService = LicenseSyncService.shared
    private let userDefaults = UserDefaults.standard
    
    private init() {
        loadLicenseState()
    }
    
    func startTrial() {
        // Only set trial start date if it hasn't been set before
        if userDefaults.trialStartDate == nil {
            userDefaults.trialStartDate = Date()
            licenseState = .trial(daysRemaining: SubscriptionManager.TRIAL_DURATION_DAYS)
            NotificationCenter.default.post(name: .licenseStatusChanged, object: nil)
        }
    }
    
    private func loadLicenseState() {
        // Check for existing license key
        if let licenseKey = userDefaults.licenseKey {
            self.licenseKey = licenseKey
            
            // If we have a license key, trust that it's licensed
            // Skip server validation on startup
            if userDefaults.activationId != nil || !userDefaults.bool(forKey: "IoLicenseRequiresActivation") {
                licenseState = .licensed
                return
            }
        }
        
        // Check if this is first launch
        let hasLaunchedBefore = userDefaults.bool(forKey: "IoHasLaunchedBefore")
        if !hasLaunchedBefore {
            // First launch - start trial automatically
            userDefaults.set(true, forKey: "IoHasLaunchedBefore")
            startTrial()
            return
        }
        
        // Only check trial if not licensed and not first launch
        if let trialStartDate = userDefaults.trialStartDate {
            let daysSinceTrialStart = Calendar.current.dateComponents([.day], from: trialStartDate, to: Date()).day ?? 0
            
            if daysSinceTrialStart >= SubscriptionManager.TRIAL_DURATION_DAYS {
                licenseState = .trialExpired
            } else {
                licenseState = .trial(daysRemaining: SubscriptionManager.TRIAL_DURATION_DAYS - daysSinceTrialStart)
            }
        } else {
            // No trial has been started yet - start it now
            startTrial()
        }
    }
    
    var canUseApp: Bool {
        switch licenseState {
        case .licensed:
            return true
        case .trial, .trialExpired:
            return false  // Let Supabase account trial take priority over local trial
        }
    }
    
    // Disable Polar trial system when user is authenticated with Supabase
    var shouldUsePolarTrial: Bool {
        // If user has Supabase session, don't use Polar trial
        return SupabaseServiceSDK.shared.currentSession == nil && licenseState != .licensed
    }
    
    func openPurchaseLink() {
        if let url = URL(string: "https://www.cliovoice.com/pricing") {
            NSWorkspace.shared.open(url)
        }
    }
    
    func validateLicense() async {
        guard !licenseKey.isEmpty else {
            validationMessage = "Please enter a license key"
            return
        }
        
        isValidating = true
        
        do {
            // First, check if the license requires activation (this also validates it)
            let requiresActivation = try await polarService.checkLicenseRequiresActivation(licenseKey: licenseKey)
            
            // Store the license key since it's valid
            userDefaults.licenseKey = licenseKey
            
            // Store license key for sync service
            licenseSyncService.storeLicenseKey(licenseKey)
            
            // Handle based on whether activation is required
            if requiresActivation {
                // If we already have an activation ID, validate with it
                if let activationId = userDefaults.activationId {
                    let isValid = try await polarService.validateLicenseKeyWithActivation(licenseKey, activationId: activationId)
                    if isValid {
                        // Existing activation is valid
                        licenseState = .licensed
                        validationMessage = "License activated successfully!"
                        
                        // CRITICAL: Clear any trial data to prevent conflicts
                        print("🔧 [LICENSE] Clearing trial data after license activation")
                        
                        NotificationCenter.default.post(name: .licenseStatusChanged, object: nil)
                        
                        // FORCE immediate subscription manager update
                        print("🔧 [LICENSE] Forcing SubscriptionManager update")
                        isValidating = false
                        return
                    }
                }
                
                // Need to create a new activation
                let (activationId, limit) = try await polarService.activateLicenseKey(licenseKey)
                
                // Store activation details
                userDefaults.activationId = activationId
                userDefaults.set(true, forKey: "IoLicenseRequiresActivation")
                self.activationsLimit = limit
                
            } else {
                // This license doesn't require activation (unlimited devices)
                userDefaults.activationId = nil
                userDefaults.set(false, forKey: "IoLicenseRequiresActivation")
                self.activationsLimit = 0 // Unlimited devices - no activation limit
            }
            
            // Update the license state
            licenseState = .licensed
            validationMessage = "License activated successfully!"
            
            // CRITICAL: Clear any trial data to prevent conflicts
            print("🔧 [LICENSE] Clearing trial data after license activation")
            
            NotificationCenter.default.post(name: .licenseStatusChanged, object: nil)
            
            // SYNC: Sync license details from Polar to Supabase
            print("🔄 [LICENSE] Triggering Polar → Supabase sync after successful activation")
            Task.detached { [weak self, licenseKey] in
                await self?.licenseSyncService.syncPolarToSupabase(licenseKey: licenseKey)
            }
            
            // FORCE immediate subscription manager update
            print("🔧 [LICENSE] Forcing SubscriptionManager update")
            
        } catch LicenseError.activationLimitReached {
            validationMessage = "This license has reached its maximum number of activations."
        } catch LicenseError.activationNotRequired {
            // This is actually a success case for unlimited licenses
            userDefaults.licenseKey = licenseKey
            userDefaults.activationId = nil
            userDefaults.set(false, forKey: "IoLicenseRequiresActivation")
            self.activationsLimit = 0
            
            licenseState = .licensed
            validationMessage = "License activated successfully!"
            
            // CRITICAL: Clear any trial data to prevent conflicts
            print("🔧 [LICENSE] Clearing trial data after license activation (unlimited)")
            
            // SYNC: Sync license details from Polar to Supabase
            print("🔄 [LICENSE] Triggering Polar → Supabase sync after unlimited license activation")
            Task.detached { [weak self, licenseKey] in
                await self?.licenseSyncService.syncPolarToSupabase(licenseKey: licenseKey)
            }
            
            NotificationCenter.default.post(name: .licenseStatusChanged, object: nil)
        } catch {
            validationMessage = "Error validating license: \(error.localizedDescription)"
        }
        
        isValidating = false
    }
    
    func removeLicense() {
        // Remove both license key and trial data
        userDefaults.licenseKey = nil
        userDefaults.activationId = nil
        userDefaults.set(false, forKey: "IoLicenseRequiresActivation")
        userDefaults.trialStartDate = nil
        userDefaults.set(false, forKey: "IoHasLaunchedBefore")  // Allow trial to restart
        
        licenseState = .trial(daysRemaining: trialPeriodDays)  // Reset to trial state
        licenseKey = ""
        validationMessage = nil
        NotificationCenter.default.post(name: .licenseStatusChanged, object: nil)
        loadLicenseState()
    }
}

extension Notification.Name {
    static let licenseStatusChanged = Notification.Name("licenseStatusChanged")
}

// Add UserDefaults extensions for storing activation ID
extension UserDefaults {
    var activationId: String? {
        get { string(forKey: "IoActivationId") }
        set { set(newValue, forKey: "IoActivationId") }
    }
}
