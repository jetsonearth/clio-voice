import SwiftUI

/// Minimal sign-in gate for users who have already completed onboarding.
/// Shows an authentication UI and returns to the main app once authenticated.
struct AuthGateView: View {
    @StateObject private var supabaseService = SupabaseServiceSDK.shared
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            // Full-page background image
            if let nsImage = loadAuthBackground() {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .frame(minWidth: 1200, minHeight: 800)
                    .clipped()
            } else {
                Color.black
                    .ignoresSafeArea()
            }
            
            // Gradient overlay for text readability
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.5),
                    Color.black.opacity(0.2),
                    Color.black.opacity(0.4)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer(minLength: 40)

                VStack(spacing: 24) {
                    // Banner
                    Image("clio-banner")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 80)
                        .frame(maxWidth: .infinity)

                    // Title/subtitle (match onboarding sizing)
                    VStack(spacing: 8) {
                        Text(localizationManager.localizedString("auth.signin.title"))
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(DarkTheme.textPrimary)
                            .shadow(color: .black.opacity(0.6), radius: 10, x: 0, y: 2)
                        Text(localizationManager.localizedString("auth.signin.subtitle"))
                            .font(.system(size: 16))
                            .foregroundColor(DarkTheme.textSecondary)
                            .shadow(color: .black.opacity(0.6), radius: 6, x: 0, y: 1)
                    }

                // Social sign-in (Google only for now)
                Button(action: { Task { await socialTapped(.google) } }) {
                    HStack(spacing: 12) {
                        Text("G")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(DarkTheme.textPrimary)
                            .frame(width: 24, height: 24)
                            .background(
                                Circle()
                                    .fill(.white)
                                    .overlay(
                                        Circle()
                                            .stroke(DarkTheme.textPrimary.opacity(0.1), lineWidth: 1)
                                    )
                            )

                        Text("Continue with Google")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(DarkTheme.textPrimary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Capsule()
                                    .stroke(DarkTheme.textPrimary.opacity(0.15), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(.plain)

                // OR divider
                HStack(spacing: 16) {
                    Rectangle().fill(DarkTheme.textSecondary.opacity(0.3)).frame(height: 1)
                    Text("OR")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(DarkTheme.textSecondary)
                        .padding(.horizontal, 8)
                    Rectangle().fill(DarkTheme.textSecondary.opacity(0.3)).frame(height: 1)
                }
                .frame(maxWidth: 400)

                // Email/password form
                VStack(spacing: 16) {
                    AuthTextField(
                        text: $email,
                        placeholder: localizationManager.localizedString("auth.placeholder.email"),
                        icon: "envelope.fill"
                    )
                    AuthTextField(
                        text: $password,
                        placeholder: localizationManager.localizedString("auth.placeholder.password"),
                        icon: "lock.fill",
                        isSecure: true
                    )

                    if let errorMessage = errorMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                                .font(.system(size: 14))
                            Text(errorMessage)
                                .font(.system(size: 13))
                                .foregroundColor(.red)
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(RoundedRectangle(cornerRadius: 10).fill(.red.opacity(0.08)))
                    }

                    StyledActionButton(
                        title: isLoading ? localizationManager.localizedString("auth.processing") : localizationManager.localizedString("auth.signin.button"),
                        action: handleEmailSignIn,
                        isDisabled: !isFormValid || isLoading,
                        showArrow: !isLoading
                    )
                    .frame(width: 200)
                }
                .frame(maxWidth: 400)
            }
            .padding(.horizontal, 32)

                Spacer(minLength: 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        // Reconfigure window chrome to allow content to extend fully underneath
        .background(WindowAccessor { window in
            WindowManager.shared.configureWindow(window)
        })
        .onAppear {
            if let creds = supabaseService.getSavedCredentials() {
                email = creds.email
                password = creds.password
            }
        }
    }
    
    private func loadAuthBackground() -> NSImage? {
        if let named = NSImage(named: "auth") { return named }
        let exts = ["png", "jpg", "jpeg"]
        for ext in exts {
            if let path = Bundle.main.path(forResource: "auth", ofType: ext),
               let img = NSImage(contentsOfFile: path) { return img }
        }
        return nil
    }

    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && isValidEmail(email)
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    private func handleEmailSignIn() {
        guard isFormValid else { return }
        isLoading = true
        errorMessage = nil
        Task {
            do {
                _ = try await supabaseService.signIn(email: email, password: password)
                await MainActor.run {
                    isLoading = false
                    supabaseService.saveCredentials(email: email, password: password)
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    if let authError = error as? AuthError {
                        errorMessage = authError.localizedDescription
                    } else {
                        errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }

    private func socialTapped(_ provider: SupabaseServiceSDK.OAuthProvider) async {
        isLoading = true
        errorMessage = nil
        do {
            try await supabaseService.signInWithOAuth(provider)
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
}
