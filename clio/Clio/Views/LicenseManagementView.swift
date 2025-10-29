// import SwiftUI

// struct LicenseManagementView: View {
//     @ObservedObject private var licenseViewModel = LicenseViewModel.shared
//     @StateObject private var subscriptionManager = SubscriptionManager.shared
//     @StateObject private var userProfile = UserProfileService.shared
//     @Environment(\.modelContext) private var modelContext
    
//     @State private var transcriptionProgress: Double = 0.0
//     @State private var totalTranscriptionMinutes: Double = 0.0
//     @State private var maxTrialDays: Int = SubscriptionManager.TRIAL_DURATION_DAYS
    
//     let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.30"
    
//     var body: some View {
//         ScrollView {
//             VStack(spacing: 32) {
//                 // Header Section
//                 headerSection
                
//                 // Main Content
//                 if subscriptionManager.currentTier == .pro {
//                     proStatusSection
//                 } else {
//                     upgradeSection
//                 }
                
//                 // Trial Progress (for free users)
//                 if subscriptionManager.currentTier == .free {
//                     trialProgressSection
//                 }
                
//                 // License Activation Section
//                 if subscriptionManager.currentTier != .pro {
//                     licenseActivationSection
//                 }
//             }
//             .padding(32)
//         }
//         .frame(maxWidth: .infinity, maxHeight: .infinity)
//         .onAppear {
//             loadTranscriptionStats()
//         }
//     }
    
//     // MARK: - Header Section
//     private var headerSection: some View {
//         VStack(spacing: 24) {
//             // App Icon
//             ZStack {
//                 RoundedRectangle(cornerRadius: 24)
//                     .fill(.ultraThinMaterial)
//                     .frame(width: 96, height: 96)
//                     .overlay(
//                         RoundedRectangle(cornerRadius: 24)
//                             .stroke(DarkTheme.textPrimary.opacity(0.1), lineWidth: 1)
//                     )
                
//                 Image(systemName: "mic.fill")
//                     .font(.system(size: 40, weight: .medium))
//                     .foregroundColor(DarkTheme.accent)
//             }
            
//             VStack(spacing: 16) {
//                 HStack(spacing: 12) {
//                     Text(subscriptionManager.currentTier == .pro ? "Io Pro" : "Upgrade to Pro")
//                         .font(.system(size: 36, weight: .bold, design: .rounded))
//                         .foregroundColor(DarkTheme.textPrimary)
                    
//                     Text("v\(appVersion)")
//                         .font(.system(size: 16))
//                         .foregroundColor(DarkTheme.textSecondary)
//                         .padding(.top, 8)
//                 }
                
//                 Text(subscriptionManager.currentTier == .pro ? 
//                      "Thank you for supporting Io" :
//                      "Transform your voice into text with advanced features")
//                     .font(.system(size: 18))
//                     .foregroundColor(DarkTheme.textSecondary)
//                     .multilineTextAlignment(.center)
//             }
//         }
//     }
    
//     // MARK: - Pro Status Section
//     private var proStatusSection: some View {
//         VStack(spacing: 24) {
//             // Status Card
//             VStack(spacing: 20) {
//                 HStack {
//                     Image(systemName: "checkmark.circle.fill")
//                         .font(.system(size: 24, weight: .medium))
//                         .foregroundColor(.green)
                    
//                     Text("License Active")
//                         .font(.system(size: 20, weight: .semibold))
//                         .foregroundColor(DarkTheme.textPrimary)
                    
//                     Spacer()
                    
//                     Text("ACTIVE")
//                         .font(.system(size: 12, weight: .bold))
//                         .foregroundColor(.white)
//                         .padding(.horizontal, 8)
//                         .padding(.vertical, 4)
//                         .background(
//                             Capsule()
//                                 .fill(.green)
//                         )
//                 }
                
//                 Rectangle()
//                     .fill(DarkTheme.textPrimary.opacity(0.1))
//                     .frame(height: 1)
                
//                 Text("You have unlimited access to all Pro features on all your devices")
//                     .font(.system(size: 16))
//                     .foregroundColor(DarkTheme.textSecondary)
//                     .multilineTextAlignment(.center)
//             }
//             .padding(24)
//             .background(
//                 RoundedRectangle(cornerRadius: 16)
//                     .fill(.ultraThinMaterial)
//                     .overlay(
//                         RoundedRectangle(cornerRadius: 16)
//                             .stroke(DarkTheme.textPrimary.opacity(0.1), lineWidth: 1)
//                     )
//             )
            
//             // Support Links
//             supportLinksSection
            
//             // License Management
//             VStack(spacing: 20) {
//                 HStack {
//                     Text("License Management")
//                         .font(.system(size: 18, weight: .semibold))
//                         .foregroundColor(DarkTheme.textPrimary)
                    
//                     Spacer()
//                 }
                
//                 Button(action: {
//                     licenseViewModel.removeLicense()
//                 }) {
//                     HStack {
//                         Image(systemName: "xmark.circle.fill")
//                             .font(.system(size: 16))
//                         Text("Deactivate License")
//                             .font(.system(size: 16, weight: .medium))
//                     }
//                     .foregroundColor(.red)
//                     .frame(maxWidth: .infinity)
//                     .padding(.vertical, 12)
//                     .background(
//                         RoundedRectangle(cornerRadius: 12)
//                             .fill(.red.opacity(0.1))
//                             .overlay(
//                                 RoundedRectangle(cornerRadius: 12)
//                                     .stroke(.red.opacity(0.3), lineWidth: 1)
//                             )
//                     )
//                 }
//                 .buttonStyle(.plain)
//             }
//             .padding(24)
//             .background(
//                 RoundedRectangle(cornerRadius: 16)
//                     .fill(.ultraThinMaterial)
//                     .overlay(
//                         RoundedRectangle(cornerRadius: 16)
//                             .stroke(DarkTheme.textPrimary.opacity(0.1), lineWidth: 1)
//                     )
//             )
//         }
//     }
    
//     // MARK: - Upgrade Section
//     private var upgradeSection: some View {
//         VStack(spacing: 24) {
//             // Purchase Card
//             VStack(spacing: 24) {
//                 HStack {
//                     Image(systemName: "infinity.circle.fill")
//                         .font(.system(size: 20))
//                         .foregroundColor(DarkTheme.accent)
                    
//                     Text("Buy Once, Own Forever")
//                         .font(.system(size: 18, weight: .semibold))
//                         .foregroundColor(DarkTheme.textPrimary)
//                 }
//                 .padding(.horizontal, 16)
//                 .padding(.vertical, 8)
//                 .background(
//                     Capsule()
//                         .fill(DarkTheme.accent.opacity(0.1))
//                         .overlay(
//                             Capsule()
//                                 .stroke(DarkTheme.accent.opacity(0.3), lineWidth: 1)
//                         )
//                 )
                
//                 // Purchase Button
//                 Button(action: {
//                     if let url = URL(string: "https://tryio.com/buy") {
//                         NSWorkspace.shared.open(url)
//                     }
//                 }) {
//                     Text("Upgrade to Io Pro")
//                         .font(.system(size: 18, weight: .semibold))
//                         .foregroundColor(.white)
//                         .frame(maxWidth: .infinity)
//                         .padding(.vertical, 16)
//                         .background(
//                             RoundedRectangle(cornerRadius: 12)
//                                 .fill(DarkTheme.accent)
//                         )
//                 }
//                 .buttonStyle(.plain)
                
//                 // Features
//                 featuresGrid
//             }
//             .padding(24)
//             .background(
//                 RoundedRectangle(cornerRadius: 16)
//                     .fill(.ultraThinMaterial)
//                     .overlay(
//                         RoundedRectangle(cornerRadius: 16)
//                             .stroke(DarkTheme.textPrimary.opacity(0.1), lineWidth: 1)
//                     )
//             )
//         }
//     }
    
//     // MARK: - Trial Progress Section
//     private var trialProgressSection: some View {
//         VStack(spacing: 20) {
//             HStack {
//                 Text("Trial Progress")
//                     .font(.system(size: 18, weight: .semibold))
//                     .foregroundColor(DarkTheme.textPrimary)
                
//                 Spacer()
                
//                 Text("\(subscriptionManager.trialDaysRemaining) of \(maxTrialDays) days remaining")
//                     .font(.system(size: 14, weight: .medium))
//                     .foregroundColor(DarkTheme.textSecondary)
//             }
            
//             // Progress Bar
//             ZStack(alignment: .leading) {
//                 RoundedRectangle(cornerRadius: 6)
//                     .fill(DarkTheme.textPrimary.opacity(0.1))
//                     .frame(height: 12)
                
//                 RoundedRectangle(cornerRadius: 6)
//                     .fill(DarkTheme.accent)
//                     .frame(width: max(0, CGFloat(1.0 - Double(subscriptionManager.trialDaysRemaining) / Double(maxTrialDays)) * 300), height: 12)
//                     .animation(.easeInOut(duration: 0.3), value: subscriptionManager.trialDaysRemaining)
//             }
//             .frame(maxWidth: 300)
            
//             Text(subscriptionManager.trialDaysRemaining <= 0 ? 
//                  "Trial completed • Upgrade to continue" :
//                  "Enjoy \(subscriptionManager.trialDaysRemaining) days remaining")
//                 .font(.system(size: 14))
//                 .foregroundColor(subscriptionManager.trialDaysRemaining <= 0 ? .orange : DarkTheme.textSecondary)
//                 .multilineTextAlignment(.center)
//         }
//         .padding(24)
//         .background(
//             RoundedRectangle(cornerRadius: 16)
//                 .fill(.ultraThinMaterial)
//                 .overlay(
//                     RoundedRectangle(cornerRadius: 16)
//                         .stroke(DarkTheme.textPrimary.opacity(0.1), lineWidth: 1)
//                 )
//         )
//     }
    
//     // MARK: - License Activation Section
//     private var licenseActivationSection: some View {
//         VStack(spacing: 20) {
//             Text("Already have a license?")
//                 .font(.system(size: 18, weight: .semibold))
//                 .foregroundColor(DarkTheme.textPrimary)
            
//             HStack(spacing: 12) {
//                 TextField("ENTER YOUR LICENSE KEY", text: $licenseViewModel.licenseKey)
//                     .font(.system(size: 14, weight: .medium, design: .monospaced))
//                     .textCase(.uppercase)
//                     .foregroundColor(DarkTheme.textPrimary)
//                     .padding(.horizontal, 16)
//                     .padding(.vertical, 12)
//                     .background(
//                         RoundedRectangle(cornerRadius: 8)
//                             .fill(.ultraThinMaterial)
//                             .overlay(
//                                 RoundedRectangle(cornerRadius: 8)
//                                     .stroke(DarkTheme.textPrimary.opacity(0.2), lineWidth: 1)
//                             )
//                     )
                
//                 Button(action: {
//                     Task { await licenseViewModel.validateLicense() }
//                 }) {
//                     if licenseViewModel.isValidating {
//                         ProgressView()
//                             .controlSize(.small)
//                             .frame(width: 80)
//                     } else {
//                         Text("Activate")
//                             .font(.system(size: 14, weight: .semibold))
//                             .foregroundColor(.white)
//                             .frame(width: 80)
//                     }
//                 }
//                 .frame(height: 44)
//                 .background(
//                     RoundedRectangle(cornerRadius: 8)
//                         .fill(DarkTheme.accent)
//                 )
//                 .buttonStyle(.plain)
//                 .disabled(licenseViewModel.isValidating || licenseViewModel.licenseKey.isEmpty)
//             }
            
//             if let message = licenseViewModel.validationMessage {
//                 Text(message)
//                     .font(.system(size: 14))
//                     .foregroundColor(.red)
//                     .multilineTextAlignment(.center)
//             }
//         }
//         .padding(24)
//         .background(
//             RoundedRectangle(cornerRadius: 16)
//                 .fill(.ultraThinMaterial)
//                 .overlay(
//                     RoundedRectangle(cornerRadius: 16)
//                         .stroke(DarkTheme.textPrimary.opacity(0.1), lineWidth: 1)
//                 )
//         )
//     }
    
//     // MARK: - Support Links Section
//     private var supportLinksSection: some View {
//         HStack(spacing: 32) {
//             supportLinkItem(icon: "envelope.fill", title: "Support", color: DarkTheme.accent) {
//                 EmailSupport.openSupportEmail()
//             }
            
//             supportLinkItem(icon: "list.bullet.clipboard.fill", title: "Changelog", color: DarkTheme.accent) {
//                 if let url = URL(string: "https://github.com/Beingpax/Io/releases") {
//                     NSWorkspace.shared.open(url)
//                 }
//             }
            
//             supportLinkItem(icon: "map.fill", title: "Roadmap", color: DarkTheme.accent) {
//                 if let url = URL(string: "https://github.com/Beingpax/Io/issues") {
//                     NSWorkspace.shared.open(url)
//                 }
//             }
//         }
//     }
    
//     // MARK: - Features Grid
//     private var featuresGrid: some View {
//         HStack(spacing: 24) {
//             featureItem(icon: "bubble.left.and.bubble.right.fill", title: "Priority Support", color: DarkTheme.accent)
//             featureItem(icon: "infinity.circle.fill", title: "Lifetime Access", color: DarkTheme.accent)
//             featureItem(icon: "arrow.up.circle.fill", title: "Free Updates", color: DarkTheme.accent)
//             featureItem(icon: "macbook.and.iphone", title: "All Devices", color: DarkTheme.accent)
//         }
//     }
    
//     // MARK: - Helper Views
//     private func featureItem(icon: String, title: String, color: Color) -> some View {
//         VStack(spacing: 8) {
//             Image(systemName: icon)
//                 .font(.system(size: 20, weight: .medium))
//                 .foregroundColor(color)
            
//             Text(title)
//                 .font(.system(size: 13, weight: .medium))
//                 .foregroundColor(DarkTheme.textPrimary)
//                 .multilineTextAlignment(.center)
//         }
//     }
    
//     private func supportLinkItem(icon: String, title: String, color: Color, action: @escaping () -> Void) -> some View {
//         Button(action: action) {
//             HStack(spacing: 8) {
//                 Image(systemName: icon)
//                     .font(.system(size: 14, weight: .medium))
//                     .foregroundColor(color)
                
//                 Text(title)
//                     .font(.system(size: 14, weight: .medium))
//                     .foregroundColor(DarkTheme.textPrimary)
//             }
//         }
//         .buttonStyle(.plain)
//     }
    
//     // MARK: - Data Loading
//     private func loadTranscriptionStats() {
//         // Load transcription statistics from Core Data
//         // This would integrate with your existing transcription tracking
//         Task {
//             // Time-based trials don't need transcription usage tracking
//             // Trial progress is based on calendar time, not usage
//         }
//     }
// }

// #Preview {
//     LicenseManagementView()
//         .frame(width: 800, height: 1000)
//         .background(Color(hex: "0A0A0A"))
// }