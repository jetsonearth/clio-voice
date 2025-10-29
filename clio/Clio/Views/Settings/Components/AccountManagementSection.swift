import SwiftUI

struct AccountManagementSection: View {
    @EnvironmentObject private var localizationManager: LocalizationManager
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    @AppStorage("hasCompletedAuthentication") private var hasCompletedAuthentication = true
    @StateObject private var supabaseService = SupabaseServiceSDK.shared
    
    var body: some View {
        SettingsSection(
            icon: "rectangle.portrait.and.arrow.right",
            title: localizationManager.localizedString("settings.sign_out.title"),
            subtitle: localizationManager.localizedString("settings.sign_out.subtitle")
        ) {
            VStack(alignment: .leading, spacing: 12) {
                Button(action: signOut) {
                    HStack(spacing: 8) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 14, weight: .medium))
                        Text(localizationManager.localizedString("settings.sign_out.button"))
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(DarkTheme.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(DarkTheme.textPrimary.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(DarkTheme.textPrimary.opacity(0.2), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private func signOut() {
        Task {
            do {
                // Sign out from Supabase
                try await supabaseService.signOut()
                print("✅ [AUTH] Successfully signed out from Supabase")
                
                // Reflect unauthenticated state but preserve onboarding completion
                hasCompletedAuthentication = false
                print("✅ [AUTH] Marked unauthenticated; onboarding preserved")
                
            } catch {
                print("❌ [AUTH] Sign out failed: \(error)")
                // Even if sign out fails, still mark unauthenticated locally
                hasCompletedAuthentication = false
                print("⚠️ [AUTH] Marked unauthenticated locally despite sign out error")
            }
        }
    }
}