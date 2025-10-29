import SwiftUI

struct LicensePageView: View {
    @ObservedObject private var subscriptionManager = SubscriptionManager.shared
    @ObservedObject private var userProfile = UserProfileService.shared
    @ObservedObject private var supabaseService = SupabaseServiceSDK.shared
    @EnvironmentObject private var localizationManager: LocalizationManager
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.fontScale) private var fontScale
    @AppStorage("emailSignatureEnabled") private var emailSignatureEnabled = false
    
    // Debug mode toggle (commented out for production)
    // @AppStorage("debugLicenseView") private var isDebugMode = false
    // @State private var debugLicenseState: SubscriptionTier = .free
    private var isDebugMode = false
    @State private var licenseKey = ""
    @State private var isActivating = false
    @State private var activationMessage: String?
    @State private var showingActivationError = false
    @State private var isOpeningPortal = false
    @State private var showingFeedback = false
    @State private var isAnnualLoading = false
    @State private var isMonthlyLoading = false
    
    // Local stats
    @State private var totalWords: Int = 0
    @State private var totalSessions: Int = 0
    
    // Polar checkout service
    @StateObject private var polarService = PolarCheckoutService()
    
    var currentTier: SubscriptionTier {
        subscriptionManager.currentTier
    }
    
    var isActuallyPro: Bool {
        #if DEBUG
        // In debug mode, respect developer overrides
        if UserDefaults.standard.bool(forKey: "DevModeBypassPolar") {
            return subscriptionManager.currentTier == .pro && !subscriptionManager.isInTrial
        }
        #endif
        
        // Trial users should NEVER see Pro UI, regardless of tier
        if subscriptionManager.isInTrial {
            return false
        }
        
        // Only show Pro section for actual paid subscribers
        if let session = supabaseService.currentSession {
            return session.user.subscriptionStatus == .active && session.user.subscriptionPlan != nil
        }
        // For non-Supabase users, check if Pro and not in trial
        return subscriptionManager.currentTier == .pro
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Enhanced Page Header Section
                modernPageHeader
                    .padding(.horizontal, 32)
                    .padding(.vertical, 32)
                
                // Main Content with improved spacing
                VStack(spacing: 28) {
                    // Main content area with modern design
                    if isActuallyPro {
                        proUserSection
                    } else {
                        modernFreeUserSection
                    }
                    
                    // Enhanced Footer with better styling
                    modernFooterSection
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
        .scrollContentBackground(.hidden)
        .scrollIndicators(.automatic, axes: .vertical)
        // Match other pages: let ContentView provide the glass background
        .background(Color.clear)
        .onAppear {
            loadUsageStats()
            Task { try? await SupabaseServiceSDK.shared.refreshSession() }
            
            // Listen for deep-link license activation
            NotificationCenter.default.addObserver(
                forName: .licenseActivatedViaDeepLink,
                object: nil,
                queue: .main
            ) { notification in
                if let licenseKey = notification.object as? String {
                    ToastBanner.shared.show(
                        title: "License Activated Successfully!",
                        subtitle: "License: \(licenseKey)",
                        duration: 5.0,
                        systemIconName: "checkmark.circle.fill"
                    )
                }
            }
        }
        .sheet(isPresented: $showingFeedback) {
            FeedbackView()
        }
    }
    
    // MARK: - Modern Page Header
    private var modernPageHeader: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
Text(localizationManager.localizedString("navigation.plan"))
                        .fontScaled(size: 30, weight: .bold)
                        .foregroundColor(DarkTheme.textPrimary)
                    
Text(localizationManager.localizedString("license.description"))
                        .fontScaled(size: 15)
                        .foregroundColor(DarkTheme.textSecondary)
                        .lineLimit(nil)
                }
                
                Spacer()
                
                // Status Badge - DISABLED for debugging
                // if isActuallyPro && !subscriptionManager.isInTrial {
                //     proStatusBadge
                // }
            }
            
            // Subtle divider
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            DarkTheme.border.opacity(0.3),
                            DarkTheme.border.opacity(0.1),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)
        }
    }
    
    // MARK: - Debug Toggle Section (commented out for production)
    // private var debugToggleSection: some View {
    //     VStack(spacing: 12) {
    //         Toggle("Debug Mode", isOn: $isDebugMode)
    //             .toggleStyle(SwitchToggleStyle(tint: DarkTheme.accent))
    //         
    //         if isDebugMode {
    //             Picker("License State", selection: $debugLicenseState) {
    //                 Text("Free").tag(SubscriptionTier.free)
    //                 Text("Pro").tag(SubscriptionTier.pro)
    //             }
    //             .pickerStyle(SegmentedPickerStyle())
    //             .frame(width: 200)
    //         }
    //     }
    //     .padding()
    //     .darkCardStyle()
    //     .overlay(
    //         Text("DEBUG")
    //             .font(.system(size: 10, weight: .bold))
    //             .foregroundColor(.red)
    //             .padding(.horizontal, 6)
    //             .padding(.vertical, 2)
    //             .background(Capsule().fill(.red.opacity(0.2)))
    //             .offset(x: -8, y: -8),
    //         alignment: .topTrailing
    //     )
    // }
    
    
    // MARK: - Pro User Section
    private var proUserSection: some View {
        VStack(spacing: 24) {
            // Subscription Status Card
            subscriptionStatusCard
            
            // Email Signature Pro Feature
            // emailSignatureFeatureCard
            
            // Credits Card
            creditsCard
        }
    }
    
    // MARK: - Modern Free User Section
    private var modernFreeUserSection: some View {
        VStack(spacing: 32) {
            // Word-based Trial Progress
            trialProgressCard
            
            // Modern Upgrade CTA - COMMENTED OUT
            // upgradeCard
            
            // Modern License Activation
            licenseActivationCard
            
            // Enhanced Feature Comparison
            modernFeatureComparisonCard
        }
    }
    
    // MARK: - Subscription Status Card
    private var subscriptionStatusCard: some View {
        SubscriptionStatusCardView(isOpeningPortal: $isOpeningPortal, licenseKey: $licenseKey)
            .environmentObject(localizationManager)
    }
    
    // MARK: - Credits Card
    private var creditsCard: some View {
        VStack(spacing: 14) {
            // Header with title and share button
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
Text(localizationManager.localizedString("license.credits.title"))
                        .fontScaled(size: 16, weight: .semibold)
                        .foregroundColor(DarkTheme.textPrimary)
                    
Text("$0")
                        .fontScaled(size: 22, weight: .bold)
                        .foregroundColor(DarkTheme.textPrimary)
                }
                
                Spacer()
                
                // Share Link Button - compact pill style
                Button(action: {
                    if let url = URL(string: "https://www.cliovoice.com/") {
                        NSWorkspace.shared.open(url)
                    }
                }) {
                    HStack(spacing: 6) {
Text(localizationManager.localizedString("license.credits.share_link"))
                            .fontScaled(size: 13, weight: .medium)
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 12 * fontScale, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(DarkTheme.accent)
                    )
                }
                .buttonStyle(.plain)
            }
            
            // Progress section - cleaner layout
            VStack(alignment: .leading, spacing: 10) {
                HStack {
Text(localizationManager.localizedString("license.credits.next_tier"))
                        .fontScaled(size: 15, weight: .medium)
                        .foregroundColor(DarkTheme.textPrimary)
                    Spacer()
Text("$0 / $120")
                        .fontScaled(size: 15, weight: .semibold)
                        .foregroundColor(DarkTheme.textPrimary)
                }
                
                // Enhanced Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(DarkTheme.textPrimary.opacity(0.08))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(DarkTheme.accent)
                            .frame(width: max(8, geometry.size.width * 0.0), height: 8) // 0% progress
                    }
                }
                .frame(height: 8)
                
Text(localizationManager.localizedString("license.credits.invite_description"))
                    .fontScaled(size: 13)
                    .foregroundColor(DarkTheme.textSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(DarkTheme.textPrimary.opacity(0.02))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    DarkTheme.textPrimary.opacity(0.08),
                                    DarkTheme.textPrimary.opacity(0.04)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }
    
    // MARK: - Word-Based Trial Progress Card
    private var trialProgressCard: some View {
        ModernTrialProgressCard(
            daysRemaining: subscriptionManager.trialDaysRemaining,
            totalDays: SubscriptionManager.TRIAL_DURATION_DAYS
        )
        .environmentObject(localizationManager)
    }
    
    // MARK: - Modern Upgrade CTA
    private var upgradeCard: some View {
        ModernUpgradeCTACard {
            Task {
                await polarService.openProCheckout(isYearly: false) // Default to monthly
            }
        }
        .environmentObject(localizationManager)
    }
    
    // MARK: - Modern License Activation Card
    private var licenseActivationCard: some View {
        ModernLicenseActivationCard(
            licenseKey: $licenseKey,
            isActivating: $isActivating,
            activationMessage: $activationMessage,
            showingActivationError: $showingActivationError,
            activationAction: activateLicense
        )
        .environmentObject(localizationManager)
    }
    
    // MARK: - Feature Comparison Card
    private var featureComparisonCard: some View {
        VStack(spacing: 20) {
Text(localizationManager.localizedString("subscription.features.title"))
                .fontScaled(size: 18, weight: .semibold)
                .foregroundColor(DarkTheme.textPrimary)
            
            VStack(spacing: 12) {
                featureRow(localizationManager.localizedString("feature.unlimited_transcriptions"), free: false, pro: true)
                featureRow(localizationManager.localizedString("feature.large_whisper_models"), free: false, pro: true)
                featureRow(localizationManager.localizedString("feature.ai_enhancement"), free: false, pro: true)
                featureRow(localizationManager.localizedString("feature.custom_prompts"), free: false, pro: true)
                featureRow(localizationManager.localizedString("feature.power_modes"), free: false, pro: true)
                featureRow(localizationManager.localizedString("feature.cloud_sync"), free: false, pro: true)
                featureRow(localizationManager.localizedString("feature.priority_support"), free: false, pro: true)
                featureRow(localizationManager.localizedString("feature.basic_transcription"), free: true, pro: true)
            }
        }
        .padding(20)
        .darkCardStyle()
    }
    
    // MARK: - Pro Features Grid
    private var proFeaturesGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            proFeatureItem(localizationManager.localizedString("feature.unlimited_usage.title"), localizationManager.localizedString("feature.unlimited_usage.description"))
            proFeatureItem(localizationManager.localizedString("feature.all_models.title"), localizationManager.localizedString("feature.all_models.description"))
            proFeatureItem(localizationManager.localizedString("feature.ai_enhancement.title"), localizationManager.localizedString("feature.ai_enhancement.description"))
            proFeatureItem(localizationManager.localizedString("feature.enhanced_modes.title"), localizationManager.localizedString("feature.enhanced_modes.description"))
            proFeatureItem(localizationManager.localizedString("feature.cloud_sync.title"), localizationManager.localizedString("feature.cloud_sync.description"))
            proFeatureItem(localizationManager.localizedString("feature.priority_support.title"), localizationManager.localizedString("feature.priority_support.description"))
        }
    }
    
    private func simpleStatItem(value: String, label: String) -> some View {
        VStack(spacing: 8) {
            Text(value)
                .fontScaled(size: 24, weight: .bold)
                .foregroundColor(DarkTheme.textPrimary)
            
            Text(label)
                .fontScaled(size: 14)
                .foregroundColor(DarkTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(DarkTheme.textPrimary.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(DarkTheme.textPrimary.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Footer Section
    private var footerSection: some View {
        HStack(spacing: 32) {
            footerLink(localizationManager.localizedString("footer.support"), icon: "envelope.fill") {
                EmailSupport.openSupportEmail()
            }
            
            footerLink(localizationManager.localizedString("footer.documentation"), icon: "book.fill") {
                if let url = URL(string: "https://www.cliovoice.com") {
                    NSWorkspace.shared.open(url)
                }
            }
            
            footerLink(localizationManager.localizedString("footer.privacy"), icon: "lock.fill") {
                if let url = URL(string: "https://www.cliovoice.com/privacy") {
                    NSWorkspace.shared.open(url)
                }
            }
        }
        .padding(.top, 24)
    }
    
    // MARK: - Helper Views
    private func featureRow(_ feature: String, free: Bool, pro: Bool) -> some View {
        HStack {
Text(feature)
                .fontScaled(size: 14)
                .foregroundColor(DarkTheme.textPrimary)
            
            Spacer()
            
            // Free tier
            Image(systemName: free ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(free ? DarkTheme.success.opacity(0.6) : DarkTheme.border)
                .font(.system(size: 16 * fontScale))
            
            // Pro tier
            Image(systemName: pro ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(pro ? DarkTheme.success : DarkTheme.border)
                .font(.system(size: 16 * fontScale))
        }
    }
    
    private func proFeatureItem(_ title: String, _ description: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Image(systemName: icon)
                //     .font(.system(size: 20))
                //     .foregroundColor(DarkTheme.accent)
                
Text(title)
                    .fontScaled(size: 16, weight: .semibold)
                    .foregroundColor(DarkTheme.textPrimary)
            }
            
Text(description)
                .fontScaled(size: 13)
                .foregroundColor(DarkTheme.textSecondary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.thinMaterial)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    private func statItem(_ label: String, value: String, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20 * fontScale))
                .foregroundColor(DarkTheme.accent)
            
            Text(value)
                .fontScaled(size: 24, weight: .bold)
                .foregroundColor(DarkTheme.textPrimary)
            
Text(label)
                .fontScaled(size: 12)
                .foregroundColor(DarkTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func footerLink(_ title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14 * fontScale))
Text(title)
                    .fontScaled(size: 14)
            }
            .foregroundColor(DarkTheme.textSecondary)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            if hovering {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
    }
    
    // MARK: - Helper Functions
    private func loadUsageStats() {
        Task {
            do {
                // Calculate local stats
                let stats = try await UserStatsService.shared.calculateLocalStats(modelContext: modelContext)
                
                await MainActor.run {
                    // Update local stats
                    totalWords = stats.totalWordsTranscribed
                    totalSessions = stats.totalSessions
                }
                
                // Sync stats if needed
                await UserStatsService.shared.syncStatsIfNeeded()
            } catch {
                print("Failed to load usage stats: \(error)")
            }
        }
    }
    
    private func activateLicense() {
        // Use the raw key but log a safe prefix; normalization happens in PolarService
        let keyPrefix = String(licenseKey.prefix(8))
        guard !licenseKey.isEmpty else { return }
        
        isActivating = true
        activationMessage = nil
        showingActivationError = false
        StructuredLog.shared.log(cat: .license, evt: "ui_activate_click", ["key_prefix": keyPrefix])
        
        Task {
            do {
                // REAL ACTIVATION: Use PolarService to validate and activate license  
                let polarLicenseService = PolarService.shared
                
                // Step 1: Get license plan information (monthly vs annual)
                let isAnnual = try await polarLicenseService.getLicensePlanInfo(licenseKey: licenseKey)
                StructuredLog.shared.log(cat: .license, evt: "plan_detected", ["annual": isAnnual])
                
                // Step 2: Check if license requires activation
                do {
                    let requiresActivation = try await polarLicenseService.checkLicenseRequiresActivation(licenseKey: licenseKey)
                    StructuredLog.shared.log(cat: .license, evt: "requires_activation", ["requires": requiresActivation])
                    if requiresActivation {
                        // Step 3: Try to activate the license
                        let activationResponse = try await polarLicenseService.activateLicenseKey(licenseKey)
                        StructuredLog.shared.log(cat: .license, evt: "activation_response", ["activation_id": activationResponse.activationId.prefix(8), "limit": activationResponse.activationsLimit])
                    } else {
                        // License doesn't require activation (unlimited devices)
                        StructuredLog.shared.log(cat: .license, evt: "activation_not_required")
                    }
                } catch {
                    // If activation fails due to "already activated", that's actually success!
                    StructuredLog.shared.log(cat: .license, evt: "activation_block_err", lvl: .err, ["error": String(describing: error)])
                    if let licenseError = error as? LicenseError, licenseError == .activationFailed {
                        throw error
                    } else {
                        throw error
                    }
                }
                
                // Step 4: Calculate subscription expiry for annual plans
                let subscriptionExpiresAt: Date? = isAnnual ? Calendar.current.date(byAdding: .year, value: 1, to: Date()) : nil
                
                // Step 5: Update subscription manager to refresh tier
                await subscriptionManager.updateSubscriptionState()
                
                // Step 6: Sync license status to Supabase with proper plan information
                if let _ = supabaseService.currentSession {
                    try await supabaseService.updateSubscriptionInfo(
                        status: "active",
                        plan: "pro",
                        expiresAt: subscriptionExpiresAt, // Annual: 1 year from now, Monthly: perpetual
                        trialEndsAt: nil
                    )
                    StructuredLog.shared.log(cat: .license, evt: "supabase_profile_updated", ["annual": isAnnual])
                }
                
                // Step 7: Store license key securely for future validation
                UserDefaults.standard.set(licenseKey, forKey: "polar_license_key")
                StructuredLog.shared.log(cat: .license, evt: "stored_license_key")
                
                // Success
                await MainActor.run {
                    activationMessage = localizationManager.localizedString("license.activation.success")
                    showingActivationError = false
                    isActivating = false
                    
                    // Clear the license key after success
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        licenseKey = ""
                        activationMessage = nil
                    }
                }
                
            } catch {
                StructuredLog.shared.log(cat: .license, evt: "ui_activation_failed", lvl: .err, ["error": String(describing: error)])
                
                // Check if this is an "already activated" or "limit reached" error - might mean activation succeeded but Supabase sync failed
                if let licenseError = error as? LicenseError, (licenseError == .activationFailed || licenseError == .activationLimitReached) {
                    // Try to check if license is actually valid (might be activated already)
                    do {
                        StructuredLog.shared.log(cat: .license, evt: "retry_validate_after_failed_activation")
                        let isAnnual = try await PolarService.shared.getLicensePlanInfo(licenseKey: licenseKey)
                        
                        // If we can get plan info, the license is valid
                        StructuredLog.shared.log(cat: .license, evt: "license_already_valid")
                        
                        // Update subscription manager and Supabase
                        await subscriptionManager.updateSubscriptionState()
                        
                        if let _ = supabaseService.currentSession {
                            let subscriptionExpiresAt: Date? = isAnnual ? Calendar.current.date(byAdding: .year, value: 1, to: Date()) : nil
                            
                            try await supabaseService.updateSubscriptionInfo(
                                status: "active",
                                plan: "pro", 
                                expiresAt: subscriptionExpiresAt,
                                trialEndsAt: nil
                            )
                            StructuredLog.shared.log(cat: .license, evt: "supabase_profile_updated_after_retry")
                        }
                        
                        UserDefaults.standard.set(licenseKey, forKey: "polar_license_key")
                        
                        await MainActor.run {
                            activationMessage = localizationManager.localizedString("license.activation.success")
                            showingActivationError = false
                            isActivating = false
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                licenseKey = ""
                                activationMessage = nil
                            }
                        }
                        return
                    } catch {
                        StructuredLog.shared.log(cat: .license, evt: "validation_retry_failed", lvl: .err, ["error": String(describing: error)])
                    }
                }
                
                await MainActor.run {
                    // Provide specific error messages based on error type
                    let errorMessage: String
                    if let licenseError = error as? LicenseError {
                        switch licenseError {
                        case .validationFailed:
                            errorMessage = "Invalid license key. Please check and try again."
                        case .activationFailed:
                            errorMessage = "License activation failed. This might be a network issue - try again."
                        case .activationLimitReached:
                            errorMessage = "This license is already activated on the maximum number of devices. If this is your device, try again - it might already be working."
                        case .activationNotRequired:
                            errorMessage = "License is already activated for unlimited devices."
                        case .serverError:
                            errorMessage = "Server error occurred during activation. Please try again later."
                        }
                    } else if error.localizedDescription.contains("connection was lost") {
                        errorMessage = "Network connection lost. License might be activated - try again."
                    } else {
                        errorMessage = "Activation failed: \(error.localizedDescription)"
                    }
                    
                    activationMessage = errorMessage
                    showingActivationError = true
                    isActivating = false
                }
            }
        }
    }
    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
    
    private func calculateTimeSaved() -> Int {
        let typingTime = Double(totalWords) / 40.0  // Average typing speed: 40 WPM
        let speakingTime = Double(totalWords) / 150.0  // Average speaking speed: 150 WPM
        return Int(typingTime - speakingTime)
    }
    
    // MARK: - Modern UI Components
    
    private var proStatusBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark.seal.fill")
                .foregroundColor(DarkTheme.success)
                .font(.system(size: 16 * fontScale))
            
            Text("PRO")
                .fontScaled(size: 14, weight: .bold)
                .foregroundColor(DarkTheme.success)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(DarkTheme.success.opacity(0.15))
                .overlay(
                    Capsule()
                        .stroke(DarkTheme.success.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private var trialStatusBadge: some View {
        let total = max(1, SubscriptionManager.TRIAL_DURATION_DAYS)
        let remaining = max(0, min(total, subscriptionManager.trialDaysRemaining))
        let progressPercentage = 1.0 - (Double(remaining) / Double(total))
        let isExpired = progressPercentage >= 1.0
        
        return HStack(spacing: 6) {
            Image(systemName: isExpired ? "clock.badge.exclamationmark" : "clock")
                .foregroundColor(isExpired ? DarkTheme.warning : DarkTheme.accent)
                .font(.system(size: 16 * fontScale))
            
            Text(isExpired ? "EXPIRED" : "TRIAL")
                .fontScaled(size: 14, weight: .bold)
                .foregroundColor(isExpired ? DarkTheme.warning : DarkTheme.accent)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill((isExpired ? DarkTheme.warning : DarkTheme.accent).opacity(0.15))
                .overlay(
                    Capsule()
                        .stroke((isExpired ? DarkTheme.warning : DarkTheme.accent).opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private var modernFeatureComparisonCard: some View {
        VStack(spacing: 24) {
            // Header with left-aligned text
            VStack(alignment: .leading, spacing: 8) {
                Text(localizationManager.localizedString("subscription.features.title"))
                    .fontScaled(size: 20, weight: .semibold)
                    .foregroundColor(DarkTheme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("See what you get with Clio Pro")
                    .fontScaled(size: 15)
                    .foregroundColor(DarkTheme.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Features Grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                modernFeatureCard("infinity", localizationManager.localizedString("feature.unlimited_usage.title"), localizationManager.localizedString("feature.unlimited_usage.description"))
                modernFeatureCard("cpu", localizationManager.localizedString("feature.all_models.title"), localizationManager.localizedString("feature.all_models.description"))
                modernFeatureCard("sparkles", localizationManager.localizedString("feature.ai_enhancement.title"), localizationManager.localizedString("feature.ai_enhancement.description"))
                modernFeatureCard("bolt.fill", localizationManager.localizedString("feature.enhanced_modes.title"), localizationManager.localizedString("feature.enhanced_modes.description"))
            }
            
            // Purchase Buttons - Full width, better spacing
            VStack(spacing: 12) {
                // Annual Plan (Recommended)
                Button(action: {
                    Task {
                        isAnnualLoading = true
                        await polarService.openProCheckout(isYearly: true)
                        isAnnualLoading = false
                    }
                }) {
                    ZStack {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 8) {
                                    Text(localizationManager.localizedString("subscription.billing.yearly"))
                                        .fontScaled(size: 16, weight: .semibold)
                                        .foregroundColor(.white)
                                    
                                    Text("Save $17")
                                        .fontScaled(size: 11, weight: .semibold)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(
                                            Capsule()
                                                .fill(.white.opacity(0.2))
                                        )
                                }
                                
                                Text("$79.99/year")
                                    .fontScaled(size: 14)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            
                            Spacer()
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14 * fontScale, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .opacity(isAnnualLoading ? 0.3 : 1.0)
                        
                        if isAnnualLoading {
                            ElegantLoadingOverlay(isLight: false)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [DarkTheme.accent, DarkTheme.accent.opacity(0.9)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: DarkTheme.accent.opacity(0.3), radius: 8, x: 0, y: 2)
                    )
                }
                .buttonStyle(.plain)
                .disabled(isAnnualLoading)
                
                // Monthly Plan
                Button(action: {
                    Task {
                        isMonthlyLoading = true
                        await polarService.openProCheckout(isYearly: false)
                        isMonthlyLoading = false
                    }
                }) {
                    ZStack {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(localizationManager.localizedString("subscription.billing.monthly"))
                                    .fontScaled(size: 16, weight: .semibold)
                                    .foregroundColor(DarkTheme.textPrimary)
                                
                                Text("$7.99/month")
                                    .fontScaled(size: 14)
                                    .foregroundColor(DarkTheme.textSecondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14 * fontScale, weight: .medium))
                                .foregroundColor(DarkTheme.textSecondary)
                        }
                        .opacity(isMonthlyLoading ? 0.3 : 1.0)
                        
                        if isMonthlyLoading {
                            ElegantLoadingOverlay(isLight: true)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(DarkTheme.textPrimary.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                DarkTheme.textPrimary.opacity(0.15),
                                                DarkTheme.textPrimary.opacity(0.08)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                    )
                }
                .buttonStyle(.plain)
                .disabled(isMonthlyLoading)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(DarkTheme.textPrimary.opacity(0.02))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    DarkTheme.textPrimary.opacity(0.08),
                                    DarkTheme.textPrimary.opacity(0.04)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }
    
    private func modernFeatureCard(_ icon: String, _ title: String, _ description: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .fontScaled(size: 14, weight: .semibold)
                    .foregroundColor(DarkTheme.textPrimary)
                    .lineLimit(1)
            }
            
            Text(description)
                .fontScaled(size: 12)
                .foregroundColor(DarkTheme.textSecondary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(DarkTheme.textPrimary.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(DarkTheme.border.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private var modernFooterSection: some View {
        VStack(spacing: 20) {
            // Divider
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.clear,
                            DarkTheme.border.opacity(0.3),
                            DarkTheme.border.opacity(0.1),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)
            
            // Footer Links
            HStack(spacing: 40) {
                modernFooterLink(localizationManager.localizedString("footer.support"), icon: "envelope.fill") {
                    showingFeedback = true
                }
                
                modernFooterLink(localizationManager.localizedString("footer.documentation"), icon: "book.fill") {
                    if let url = URL(string: "https://cliovoice.com") {
                        NSWorkspace.shared.open(url)
                    }
                }
                
                modernFooterLink(localizationManager.localizedString("footer.privacy"), icon: "lock.fill") {
                    if let url = URL(string: "https://cliovoice.com/privacy") {
                        NSWorkspace.shared.open(url)
                    }
                }
            }
        }
    }
    
    private func modernFooterLink(_ title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14 * fontScale, weight: .medium))
                Text(title)
                    .fontScaled(size: 14, weight: .medium)
            }
            .foregroundColor(DarkTheme.textSecondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.clear)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            if hovering {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
    }
    
    private var emailSignatureFeatureCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
            Image(systemName: "signature")
                .font(.system(size: 20 * fontScale))
                .foregroundColor(DarkTheme.accent)
                .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Professional Email Signatures")
                        .fontScaled(size: 17, weight: .semibold)
                        .foregroundColor(DarkTheme.textPrimary)
                    Text("Build your professional network effortlessly")
                        .fontScaled(size: 13)
                        .foregroundColor(DarkTheme.textSecondary)
                }
                
                Spacer()
            }
            
            Divider()
                .padding(.vertical, 4)
            
            VStack(alignment: .leading, spacing: 8) {
                Toggle("Add signature to emails", isOn: $emailSignatureEnabled)
                    .toggleStyle(.switch)
                
                if emailSignatureEnabled {
                    Text("Automatically adds a tasteful signature line to help recipients discover voice-to-text efficiency")
                        .fontScaled(size: 12)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(DarkTheme.textPrimary.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(DarkTheme.textPrimary.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
}

// MARK: - Extracted subscription status card to help the compiler
struct SubscriptionStatusCardView: View {
    @EnvironmentObject private var localizationManager: LocalizationManager
    @Environment(\.fontScale) private var fontScale
    @Binding var isOpeningPortal: Bool
    @Binding var licenseKey: String
    @ObservedObject private var supabaseService = SupabaseServiceSDK.shared

    var body: some View {
        VStack(spacing: 12) {
            // Dynamic status headline (split to avoid heavy type-checking)
            let user = supabaseService.currentUser
            let expiryDate = user?.subscriptionExpiresAt
            let isActive = (user?.subscriptionStatus == .active)
            let isCanceledButActive = isActive && (expiryDate != nil)

            if isCanceledButActive, let exp = expiryDate {
                // Flat expiry warning - no nested card
                VStack(alignment: .leading, spacing: 10) {
                    // Top row with badge and manage button
                    HStack {
                        Text(localizationManager.localizedString("license.status.expires_soon"))
                            .fontScaled(size: 12, weight: .semibold)
                            .foregroundColor(DarkTheme.accent)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Capsule()
                                    .fill(DarkTheme.accent.opacity(0.1))
                            )
                        
                        Spacer()
                        
                        Button(action: openPortal) {
                            HStack(spacing: 6) {
                                Text(localizationManager.localizedString("license.manage_account"))
                                    .fontScaled(size: 13, weight: .medium)
                                    .opacity(isOpeningPortal ? 0 : 1)
                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 12 * fontScale, weight: .medium))
                                    .opacity(isOpeningPortal ? 0 : 1)
                            }
                            .overlay(
                                Group {
                                    if isOpeningPortal {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.7)
                                    }
                                }
                            )
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(DarkTheme.accent)
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(isOpeningPortal)
                    }

                    // Days remaining + progress
                    let remaining = max(0, daysLeft(exp))
                    let total: Double = 30 // assume monthly cycle for visual scale
                    let percent = min(1.0, Double(remaining) / total)
                    HStack {
                        Text(localizationManager.localizedString("license.status.days_remaining"))
                            .fontScaled(size: 13, weight: .medium)
                            .foregroundColor(DarkTheme.textSecondary)
                        Spacer()
                        Text("\(remaining)")
                            .fontScaled(size: 16, weight: .semibold)
                            .foregroundColor(DarkTheme.textPrimary)
                    }
                    
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(DarkTheme.textPrimary.opacity(0.08))
                                .frame(height: 8)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(DarkTheme.accent)
                                .frame(width: max(8, geo.size.width * percent), height: 8)
                        }
                    }
                    .frame(height: 8)

                    Text("\(localizationManager.localizedString("license.status.access_until")) \(formatExpiry(exp))")
                        .fontScaled(size: 13)
                        .foregroundColor(DarkTheme.textSecondary)
                }
            } else {
                // Normal pro status - flat layout
                HStack {
                    HStack(spacing: 8) {
                        Text("PRO")
                            .fontScaled(size: 12, weight: .semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(DarkTheme.accent))
                        
                        Text("Thanks for being a Pro.")
                            .fontScaled(size: 14)
                            .foregroundColor(DarkTheme.textSecondary)
                    }

                    Spacer()

                    Button(action: openPortal) {
                        HStack(spacing: 6) {
                            Text("Manage")
                                .fontScaled(size: 13, weight: .medium)
                                .opacity(isOpeningPortal ? 0 : 1)
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 12 * fontScale, weight: .medium))
                                .opacity(isOpeningPortal ? 0 : 1)
                        }
                        .overlay(
                            Group {
                                if isOpeningPortal {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.7)
                                }
                            }
                        )
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(DarkTheme.accent)
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(isOpeningPortal)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(DarkTheme.textPrimary.opacity(0.02))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    DarkTheme.textPrimary.opacity(0.08),
                                    DarkTheme.textPrimary.opacity(0.04)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }

    @MainActor
    private func openPortal() {
        // Immediately reflect loading state on the main thread so the spinner shows
        isOpeningPortal = true
        Task { @MainActor in
            defer { isOpeningPortal = false }
            do {
                // Ensure we have the freshest profile (may have been updated by a prior portal open)
                try? await SupabaseServiceSDK.shared.refreshSession()
                let customerId = SupabaseServiceSDK.shared.currentUser?.polarCustomerId
                if let cid = customerId, !cid.isEmpty {
                    let sessionURL = try await PolarService.shared.createCustomerPortalSession(customerId: cid, returnUrl: "https://www.cliovoice.com")
                    NSWorkspace.shared.open(sessionURL)
                    return
                }

                // Fallback to license key paths. Normalize all historical keys.
                let key =
                    UserDefaults.standard.string(forKey: "polar_customer_portal_license_key") ??
                    UserDefaults.standard.string(forKey: "polar_license_key") ??
                    UserDefaults.standard.string(forKey: "PolarLicenseKey") ??
                    UserDefaults.standard.string(forKey: "IoLicense") ??
                    licenseKey

                let resolvedKey = key
                guard !resolvedKey.isEmpty else {
                    // Open public Polar portal where user authenticates by email per docs
                    if let url = URL(string: "https://polar.sh/studio-kensense/portal") { NSWorkspace.shared.open(url) }
                    return
                }

                // Persist under a canonical key for future use in this session
                UserDefaults.standard.set(resolvedKey, forKey: "polar_license_key")
                let sessionURL = try await PolarService.shared.createCustomerPortalSession(licenseKey: resolvedKey, returnUrl: "https://www.cliovoice.com")
                NSWorkspace.shared.open(sessionURL)

                // The proxy backfills polar_customer_id when using a license key. Refresh to capture it.
                try? await SupabaseServiceSDK.shared.refreshSession()
                SupabaseServiceSDK.shared.pollProfile(for: 30, interval: 3)
            } catch {
                // On failure, open public Polar portal instead of pricing
                if let url = URL(string: "https://polar.sh/studio-kensense/portal") { NSWorkspace.shared.open(url) }
            }
        }
    }

    // MARK: - Helpers
    private func formatExpiry(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f.string(from: date)
    }

    private func daysRemaining(_ to: Date) -> String {
        let start = Calendar.current.startOfDay(for: Date())
        let end = Calendar.current.startOfDay(for: to)
        let comps = Calendar.current.dateComponents([.day], from: start, to: end)
        let days = max(0, comps.day ?? 0)
        return days == 1 ? "1 day" : "\(days) days"
    }

    private func daysLeft(_ to: Date) -> Int {
        let start = Calendar.current.startOfDay(for: Date())
        let end = Calendar.current.startOfDay(for: to)
        let comps = Calendar.current.dateComponents([.day], from: start, to: end)
        return max(0, comps.day ?? 0)
    }
}

// MARK: - Elegant Loading Animation
struct ElegantLoadingOverlay: View {
    let isLight: Bool
    @State private var rotationAngle: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Elegant pulsing backdrop
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .scaleEffect(pulseScale)
                .animation(
                    .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                    value: pulseScale
                )
            
            // Elegant rotating rings
            ZStack {
                // Outer ring
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                isLight ? Color.blue.opacity(0.3) : Color.white.opacity(0.3),
                                isLight ? Color.blue.opacity(0.1) : Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 24, height: 24)
                    .rotationEffect(.degrees(rotationAngle))
                
                // Inner spinning dot
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                isLight ? Color.blue : Color.white,
                                isLight ? Color.blue.opacity(0.6) : Color.white.opacity(0.6)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 3, height: 3)
                    .offset(x: 10)
                    .rotationEffect(.degrees(rotationAngle * 1.8))
                
                // Center glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                isLight ? Color.blue.opacity(0.4) : Color.white.opacity(0.4),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 8
                        )
                    )
                    .frame(width: 16, height: 16)
                    .scaleEffect(pulseScale)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                pulseScale = 1.1
            }
        }
    }
}
