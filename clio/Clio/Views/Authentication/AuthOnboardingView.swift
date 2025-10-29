import SwiftUI

// MARK: - Authentication Onboarding View
struct AuthOnboardingView: View {
    @ObservedObject var viewModel: ProfessionalOnboardingViewModel
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @StateObject private var userProfile = UserProfileService.shared
    @StateObject private var supabaseService = SupabaseServiceSDK.shared
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var authMode: AuthMode = .signIn
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var fullName = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showOptionalAuth = false
    @State private var animateElements = false
    @State private var showEmailVerification = false
    @State private var emailConfirmationTimer: Timer?
    @State private var showPasswordResetSuccess = false
    @State private var passwordResetMessage = ""
    @State private var showLanguageSelection = false
    
    enum AuthMode {
        case signIn
        case signUp
        
        func title(using localizationManager: LocalizationManager) -> String {
            switch self {
            case .signIn: return localizationManager.localizedString("auth.signin.title")
            case .signUp: return localizationManager.localizedString("auth.signup.title")
            }
        }
        
        func subtitle(using localizationManager: LocalizationManager) -> String {
            switch self {
            case .signIn: return localizationManager.localizedString("auth.signin.subtitle")
            case .signUp: return localizationManager.localizedString("auth.signup.subtitle")
            }
        }
        
        func buttonTitle(using localizationManager: LocalizationManager) -> String {
            switch self {
            case .signIn: return localizationManager.localizedString("auth.signin.button")
            case .signUp: return localizationManager.localizedString("auth.signup.button")
            }
        }
        
        func switchPrompt(using localizationManager: LocalizationManager) -> String {
            switch self {
            case .signIn: return localizationManager.localizedString("auth.signin.switch_prompt")
            case .signUp: return localizationManager.localizedString("auth.signup.switch_prompt")
            }
        }
        
        func switchAction(using localizationManager: LocalizationManager) -> String {
            switch self {
            case .signIn: return localizationManager.localizedString("auth.signin.switch_action")
            case .signUp: return localizationManager.localizedString("auth.signup.switch_action")
            }
        }
    }
    
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
            
            // Top-right language toggle overlay
            VStack {
                HStack {
                    Spacer()
                    Button(action: { showLanguageSelection = true }) {
                        HStack(spacing: 6) {
                            Image(systemName: "globe")
                                .font(.system(size: 14))
                                .foregroundColor(DarkTheme.textPrimary)
                            Text(localizationManager.currentLanguageDisplayName)
                                .font(.system(size: 12))
                                .foregroundColor(DarkTheme.textPrimary)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(DarkTheme.textPrimary.opacity(0.1), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                Spacer()
            }
            
            // Main content
            VStack(spacing: 32) {
                Spacer(minLength: 60)
                
                // Title section
                VStack(spacing: 12) {
                    Text(authMode == .signIn ? localizationManager.localizedString("auth.signin.title") : localizationManager.localizedString("auth.signup.title"))
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(DarkTheme.textPrimary)
                        .shadow(color: .black.opacity(0.6), radius: 10, x: 0, y: 2)
                        .opacity(animateElements ? 1 : 0)
                        .scaleEffect(animateElements ? 1 : 0.8)
                    
                    Text(authMode == .signIn ? localizationManager.localizedString("auth.signin.subtitle") : localizationManager.localizedString("auth.signup.subtitle"))
                        .font(.system(size: 16))
                        .foregroundColor(DarkTheme.textSecondary)
                        .shadow(color: .black.opacity(0.6), radius: 6, x: 0, y: 1)
                        .opacity(animateElements ? 1 : 0)
                }
                .multilineTextAlignment(.center)
                
                // Auth form
                VStack(spacing: 24) {
                    // Mode toggle at top
                    authModeToggle
                        .opacity(animateElements ? 1 : 0)
                        .offset(y: animateElements ? 0 : 20)
                    
                    // Social sign-in
                    socialSignInSection
                    
                    // OR divider
                    orDivider
                    
                    // Form fields
                    VStack(spacing: 20) {
                        if authMode == .signUp {
                            AuthTextField(
                                text: $fullName,
                                placeholder: localizationManager.localizedString("auth.placeholder.fullname"),
                                icon: "person.fill"
                            )
                            .opacity(animateElements ? 1 : 0)
                            .offset(y: animateElements ? 0 : 20)
                        }
                        
                        AuthTextField(
                            text: $email,
                            placeholder: localizationManager.localizedString("auth.placeholder.email"),
                            icon: "envelope.fill"
                        )
                        .opacity(animateElements ? 1 : 0)
                        .offset(y: animateElements ? 0 : 20)
                        
                        AuthTextField(
                            text: $password,
                            placeholder: localizationManager.localizedString("auth.placeholder.password"),
                            icon: "lock.fill",
                            isSecure: true
                        )
                        .opacity(animateElements ? 1 : 0)
                        .offset(y: animateElements ? 0 : 20)
                        
                        if authMode == .signUp {
                            AuthTextField(
                                text: $confirmPassword,
                                placeholder: localizationManager.localizedString("auth.placeholder.confirm_password"),
                                icon: "lock.fill",
                                isSecure: true
                            )
                            .opacity(animateElements ? 1 : 0)
                            .offset(y: animateElements ? 0 : 20)
                            
                            if !password.isEmpty && !confirmPassword.isEmpty && password != confirmPassword {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.orange)
                                        .font(.system(size: 14))
                                    Text(localizationManager.localizedString("auth.error.passwords_mismatch"))
                                        .font(.system(size: 14))
                                        .foregroundColor(.orange)
                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        
                    }
                    .frame(maxWidth: 400)
                    
                    // Error message
                    if let errorMessage = errorMessage {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                                .font(.system(size: 14))
                            Text(errorMessage)
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.red.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(.red.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .frame(maxWidth: 400)
                        .transition(.scale.combined(with: .opacity))
                    }
                    
                    // Success message for password reset
                    if showPasswordResetSuccess {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 14))
                            Text(passwordResetMessage)
                                .font(.system(size: 14))
                                .foregroundColor(.green)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.green.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(.green.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .frame(maxWidth: 400)
                        .transition(.scale.combined(with: .opacity))
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showPasswordResetSuccess)
                    }
                    
                    // Submit button
                    submitButton
                        .opacity(animateElements ? 1 : 0)
                        .offset(y: animateElements ? 0 : 20)
                    
                    // Forgot password (only for sign-in)
                    if authMode == .signIn {
                        Button(localizationManager.localizedString("auth.forgot_password")) {
                            handleForgotPassword()
                        }
                        .font(.system(size: 14))
                        .foregroundColor(DarkTheme.textSecondary)
                        .buttonStyle(.plain)
                        .opacity(animateElements ? 1 : 0)
                    }
                }
                
                Spacer()
            }
        }
        .ignoresSafeArea()
        .onAppear {
            startAnimations()
            checkEmailConfirmation()
            loadSavedCredentials()
        }
        .onDisappear {
            emailConfirmationTimer?.invalidate()
        }
        .sheet(isPresented: $showLanguageSelection) {
            AuthLanguagePickerView()
                .environmentObject(localizationManager)
        }
        .sheet(isPresented: $showEmailVerification) {
            EmailConfirmationView(
                email: email,
                onResendEmail: resendVerificationEmail,
                onConfirmed: handleEmailConfirmed
            )
        }
        .onChange(of: supabaseService.isAuthenticated) { isAuthed in
            if isAuthed {
                // Advance onboarding when OAuth/email sign-in completes
                viewModel.nextScreen()
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
    
    // MARK: - Auth Mode Toggle
    
    private var authModeToggle: some View {
        HStack(spacing: 0) {
            // Sign In Button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    authMode = .signIn
                    clearForm()
                }
            }) {
                Text(localizationManager.localizedString("auth.signin.button"))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(authMode == .signIn ? DarkTheme.textPrimary : DarkTheme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .contentShape(Rectangle()) // Make entire area clickable
                    .background(
                        Group {
                            if authMode == .signIn {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(DarkTheme.textPrimary.opacity(0.3), lineWidth: 1)
                                    )
                            } else {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.clear)
                            }
                        }
                    )
            }
            .buttonStyle(.plain)
            
            // Sign Up Button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    authMode = .signUp
                    clearForm()
                }
            }) {
                Text(localizationManager.localizedString("auth.signup.button"))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(authMode == .signUp ? DarkTheme.textPrimary : DarkTheme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .contentShape(Rectangle()) // Make entire area clickable
                    .background(
                        Group {
                            if authMode == .signUp {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(DarkTheme.textPrimary.opacity(0.3), lineWidth: 1)
                                    )
                            } else {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.clear)
                            }
                        }
                    )
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: 300)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(DarkTheme.textPrimary.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Social Sign-In Section
    private var socialSignInSection: some View {
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
        .opacity(animateElements ? 1 : 0)
        .offset(y: animateElements ? 0 : 20)
        
        // Commented out other social providers for now
        /*
        HStack(spacing: 16) {
            socialIconButton(systemImage: "apple.logo", color: DarkTheme.textPrimary) { await socialTapped(.apple) }
            socialIconButton(systemImage: "chevron.left.forwardslash.chevron.right", color: DarkTheme.textPrimary) { await socialTapped(.github) }
            socialIconButton(icon: "𝕏", color: DarkTheme.textPrimary) { await socialTapped(.twitter) }
        }
        */
    }
    
    // MARK: - OR Divider
    private var orDivider: some View {
        HStack(spacing: 16) {
            Rectangle()
                .fill(DarkTheme.textSecondary.opacity(0.3))
                .frame(height: 1)
            
            Text("OR")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(DarkTheme.textSecondary)
                .padding(.horizontal, 8)
            
            Rectangle()
                .fill(DarkTheme.textSecondary.opacity(0.3))
                .frame(height: 1)
        }
        .frame(maxWidth: 400)
        .opacity(animateElements ? 1 : 0)
        .offset(y: animateElements ? 0 : 20)
    }
    
    // Commented out for now - keeping just Google
    /*
    private func socialIconButton(icon: String = "", systemImage: String? = nil, color: Color, action: @escaping () async -> Void) -> some View {
        Button(action: { Task { await action() } }) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Circle()
                            .stroke(DarkTheme.textPrimary.opacity(0.1), lineWidth: 1)
                    )
                
                if let systemImage = systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(color)
                } else {
                    Text(icon)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(color)
                }
            }
        }
        .buttonStyle(.plain)
    }
    */
    
    private func socialTapped(_ provider: SupabaseServiceSDK.OAuthProvider) async {
        isLoading = true
        errorMessage = nil
        do {
            try await supabaseService.signInWithOAuth(provider)
            // The flow continues in external session; upon return, authState listener updates UI
            // For sign-up vs sign-in, Supabase treats both the same; we can unify here
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
    
    // MARK: - Submit Button
    
    private var submitButton: some View {
        StyledActionButton(
            title: isLoading ? localizationManager.localizedString("auth.processing") : authMode.buttonTitle(using: localizationManager),
            action: handleSubmit,
            isDisabled: !isFormValid || isLoading,
            showArrow: !isLoading
        )
        .frame(width: 200)
    }
    
    // MARK: - Form Validation
    
    private var isFormValid: Bool {
        switch authMode {
        case .signIn:
            return !email.isEmpty && !password.isEmpty && isValidEmail(email)
        case .signUp:
            return !email.isEmpty && 
                   !password.isEmpty && 
                   !confirmPassword.isEmpty &&
                   !fullName.isEmpty &&
                   password == confirmPassword && 
                   password.count >= 6 &&
                   isValidEmail(email)
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    // MARK: - Actions
    
    private func handleSubmit() {
        guard isFormValid else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // Real Supabase authentication
                if authMode == .signUp {
                    let credentials = RegisterCredentials(
                        email: email,
                        password: password,
                        fullName: fullName.isEmpty ? nil : fullName
                    )
                    
                    _ = try await supabaseService.signUp(credentials: credentials)
                    
                    await MainActor.run {
                        isLoading = false
                        
                        // Store credentials for later auto sign-in after confirmation
                        UserDefaults.standard.set(email, forKey: "PendingSignUpEmail")
                        UserDefaults.standard.set(password, forKey: "PendingSignUpPassword")
                        UserDefaults.standard.set(fullName, forKey: "PendingSignUpFullName")
                        
                        // Show email verification screen
                        showEmailVerification = true
                        
                        // Start checking for email confirmation
                        startEmailConfirmationCheck()
                    }
                } else {
                    let credentials = AuthCredentials(email: email, password: password)
                    let user = try await supabaseService.signIn(credentials: credentials)
                    
                    await MainActor.run {
                        isLoading = false
                        
                        // Always save credentials (remember by default)
                        supabaseService.saveCredentials(email: email, password: password)
                        
                        // Update local profile service with real user data
                        let displayName = user.fullName ?? email.components(separatedBy: "@").first?.capitalized ?? "User"
                        userProfile.signIn(name: displayName, email: user.email)
                        
                        // Move to next step on success
                        viewModel.nextScreen()
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    print("❌ Authentication error: \(error)")
                    
                    // Check if this is a network timeout during sign-up
                    if authMode == .signUp && error.localizedDescription.contains("network connection") {
                        // For sign-up network errors, still proceed to email verification
                        // The user might have been created on the server despite the timeout
                        print("🔄 Network timeout during sign-up, proceeding to email verification anyway")
                        
                        // Store credentials for later auto sign-in after confirmation
                        UserDefaults.standard.set(email, forKey: "PendingSignUpEmail")
                        UserDefaults.standard.set(password, forKey: "PendingSignUpPassword")
                        UserDefaults.standard.set(fullName, forKey: "PendingSignUpFullName")
                        
                        // Show email verification screen
                        showEmailVerification = true
                        
                        // Start checking for email confirmation
                        startEmailConfirmationCheck()
                        return
                    }
                    
                    if let authError = error as? AuthError {
                        errorMessage = authError.localizedDescription
                    } else {
                        errorMessage = "Authentication failed: \(error.localizedDescription)"
                    }
                }
            }
        }
    }
    
    private func clearForm() {
        email = ""
        password = ""
        confirmPassword = ""
        fullName = ""
        errorMessage = nil
    }
    
    private func startAnimations() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.1)) {
            animateElements = true
        }
    }
    
    private func checkEmailConfirmation() {
        // Check if user just returned from email confirmation
        if let pendingEmail = UserDefaults.standard.string(forKey: "PendingSignUpEmail"),
           let pendingPassword = UserDefaults.standard.string(forKey: "PendingSignUpPassword") {
            
            // Try to sign in automatically after email confirmation
            Task {
                do {
                    let credentials = AuthCredentials(email: pendingEmail, password: pendingPassword)
                    let user = try await supabaseService.signIn(credentials: credentials)
                    
                    await MainActor.run {
                        // Clear pending credentials
                        UserDefaults.standard.removeObject(forKey: "PendingSignUpEmail")
                        UserDefaults.standard.removeObject(forKey: "PendingSignUpPassword")
                        
                        let displayName = user.fullName ?? pendingEmail.components(separatedBy: "@").first?.capitalized ?? "User"
                        userProfile.signIn(name: displayName, email: user.email)
                        
                        // Proceed to welcome screen for source selection
                        fullName = UserDefaults.standard.string(forKey: "PendingSignUpFullName") ?? ""
                        UserDefaults.standard.removeObject(forKey: "PendingSignUpFullName")
                        
                        // Move to next screen (welcome source)
                        viewModel.nextScreen()
                    }
                } catch {
                    // If auto sign-in fails, user hasn't confirmed yet
                    print("Auto sign-in failed, user likely hasn't confirmed email yet")
                }
            }
        }
    }
    
    private func resendVerificationEmail() {
        // Resend verification email
        Task {
            do {
                try await supabaseService.sendPasswordResetEmail(email: email)
            } catch {
                print("Failed to resend verification email: \(error)")
            }
        }
    }
    
    private func handleEmailConfirmed() {
        print("🔘 User clicked 'I've verified my email'")
        
        // Stop the timer when user manually confirms
        emailConfirmationTimer?.invalidate()
        emailConfirmationTimer = nil
        
        // Try to sign in with pending credentials
        Task {
            print("🔍 Checking email confirmation status manually...")
            await checkEmailConfirmationStatus()
        }
    }
    
    
    private func loadSavedCredentials() {
        if let savedCredentials = supabaseService.getSavedCredentials() {
            email = savedCredentials.email
            password = savedCredentials.password
        }
    }
    
    private func startEmailConfirmationCheck() {
        emailConfirmationTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            Task {
                await checkEmailConfirmationStatus()
            }
        }
    }
    
    private func checkEmailConfirmationStatus() async {
        // Try to sign in with pending credentials to check if email is confirmed
        guard let pendingEmail = UserDefaults.standard.string(forKey: "PendingSignUpEmail"),
              let pendingPassword = UserDefaults.standard.string(forKey: "PendingSignUpPassword") else {
            print("❌ No pending credentials found")
            return
        }
        
        print("🔍 Trying to sign in with: \(pendingEmail)")
        
        do {
            let credentials = AuthCredentials(email: pendingEmail, password: pendingPassword)
            let user = try await supabaseService.signIn(credentials: credentials)
            
            print("✅ Email confirmed! User signed in successfully")
            print("👤 User details: \(user.email), subscription: \(user.subscriptionStatus)")
            
            await MainActor.run {
                // Email confirmed! Stop the timer and proceed
                emailConfirmationTimer?.invalidate()
                emailConfirmationTimer = nil
                
                // Clear pending credentials
                UserDefaults.standard.removeObject(forKey: "PendingSignUpEmail")
                UserDefaults.standard.removeObject(forKey: "PendingSignUpPassword")
                
                let displayName = user.fullName ?? pendingEmail.components(separatedBy: "@").first?.capitalized ?? "User"
                userProfile.signIn(name: displayName, email: user.email)
                
                // Close email verification and proceed to welcome screen
                showEmailVerification = false
                fullName = UserDefaults.standard.string(forKey: "PendingSignUpFullName") ?? ""
                UserDefaults.standard.removeObject(forKey: "PendingSignUpFullName")
                
                // Update user profile service with the user's name
                userProfile.signIn(name: displayName, email: user.email)
                
                // Move to next screen (welcome source)
                viewModel.nextScreen()
            }
        } catch {
            // Handle specific email confirmation error
            if let authError = error as? AuthError {
                switch authError {
                case .emailNotConfirmed:
                    print("📧 Email not confirmed yet - user needs to click verification link")
                case .invalidCredentials:
                    print("❌ Invalid credentials - possible wrong email/password")
                default:
                    print("❌ Auth error: \(authError.localizedDescription)")
                }
            } else {
                print("❌ Other error: \(error)")
                print("❌ Error type: \(type(of: error))")
            }
        }
    }
    
    // MARK: - Forgot Password
    
    private func handleForgotPassword() {
        guard !email.isEmpty && isValidEmail(email) else {
            errorMessage = localizationManager.localizedString("auth.error.invalid_email")
            showPasswordResetSuccess = false
            return
        }
        
        Task {
            do {
                try await supabaseService.sendPasswordResetEmail(email: email)
                
                await MainActor.run {
                    errorMessage = nil
                    passwordResetMessage = String(format: localizationManager.localizedString("auth.password_reset_sent"), email)
                    
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        showPasswordResetSuccess = true
                    }
                    
                    print("✅ Password reset email sent to \(email)")
                    
                    // Hide success message after 5 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        withAnimation(.easeOut(duration: 0.5)) {
                            showPasswordResetSuccess = false
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    showPasswordResetSuccess = false
                    if let authError = error as? AuthError {
                        errorMessage = authError.localizedDescription
                    } else {
                        errorMessage = localizationManager.localizedString("auth.error.password_reset_failed")
                    }
                }
            }
        }
    }
}

// MARK: - Custom Text Field

struct AuthTextField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String
    var isSecure: Bool = false
    
    @FocusState private var isFocused: Bool
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isFocused ? .accentColor : DarkTheme.textSecondary)
                .frame(width: 20)
            
            // Text field
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .font(.system(size: 16))
            .textFieldStyle(.plain)
            .focused($isFocused)
            .foregroundColor(DarkTheme.textPrimary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isFocused ? .accentColor : DarkTheme.textPrimary.opacity(isHovered ? 0.3 : 0.15), 
                            lineWidth: isFocused ? 2 : 1
                        )
                )
        )
        .onHover { hovering in
            isHovered = hovering
        }
        .animation(.easeInOut(duration: 0.15), value: isFocused)
        .animation(.easeInOut(duration: 0.15), value: isHovered)
    }
}

// MARK: - Language Picker Sheet

struct AuthLanguagePickerView: View {
    @EnvironmentObject private var localizationManager: LocalizationManager
    @Environment(\.dismiss) private var dismiss
    
    // UI state
    @State private var searchText: String = ""
    @State private var hoveredCode: String? = nil
    
    // 4-column grid for better balance
    private let columns = [
        GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())
    ]
    
    // Hide these only in onboarding picker
    private let hiddenCodes: Set<String> = ["pt", "nl", "ar", "pl"]
    
    // Filtered languages with search and hidden codes
    private var displayLanguages: [(code: String, name: String, nativeName: String)] {
        let base = LocalizationManager.supportedLanguages
            .filter { !hiddenCodes.contains($0.code) }
        guard !searchText.isEmpty else { return base }
        return base.filter { lang in
            lang.name.localizedCaseInsensitiveContains(searchText) ||
            lang.nativeName.localizedCaseInsensitiveContains(searchText) ||
            lang.code.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 6) {
                Text("App Language")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(DarkTheme.textPrimary)
                Text("Changes apply instantly")
                    .font(.system(size: 13))
                    .foregroundColor(DarkTheme.textSecondary)
            }
            .padding(.top, 8)
            
            // Search
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(DarkTheme.textSecondary)
                TextField("Search languages", text: $searchText)
                    .textFieldStyle(.plain)
                    .foregroundColor(DarkTheme.textPrimary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(DarkTheme.textPrimary.opacity(0.12), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 16)
            
            // Grid
            ScrollView {
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(displayLanguages, id: \.code) { lang in
                        OnboardingLanguageCard(
                            code: lang.code,
                            name: lang.name,
                            nativeName: lang.nativeName,
                            isSelected: localizationManager.currentLanguage == lang.code
                        ) {
                            NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .default)
                            localizationManager.setLanguage(lang.code)
                            dismiss()
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
            }
        }
        .padding()
        .frame(width: 620, height: 560)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(DarkTheme.textPrimary.opacity(0.02))
        )
    }
}

// Reuse existing LanguageCard from Settings by making it public, but for now, replicate minimal version
private struct OnboardingLanguageCard: View {
    let code: String
    let name: String
    let nativeName: String
    let isSelected: Bool
    let action: () -> Void
    @State private var isHovered = false

    private var languageFlag: String {
        switch code {
        case "en": return "🇺🇸"
        case "es": return "🇪🇸"
        case "fr": return "🇫🇷"
        case "de": return "🇩🇪"
        case "it": return "🇮🇹"
        case "ja": return "🇯🇵"
        case "ko": return "🇰🇷"
        case "zh-Hans": return "🇨🇳"
        case "zh-Hant": return "🇹🇼"
        case "ru": return "🇷🇺"
        case "hi": return "🇮🇳"
        default: return "🌐"
        }
    }

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 10) {
                    // Flag
                    Text(languageFlag)
                        .font(.system(size: 32))
                        .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
                        .scaleEffect(isHovered ? 1.06 : 1.0)
                        .animation(.easeInOut(duration: 0.15), value: isHovered)

                    // Names
                    VStack(spacing: 2) {
                        Text(nativeName)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(isSelected ? .accentColor : DarkTheme.textPrimary)
                        Text(name)
                            .font(.system(size: 12))
                            .foregroundColor(DarkTheme.textSecondary)
                    }
                    .multilineTextAlignment(.center)
                }
                .frame(width: 128, height: 110)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(
                                    isSelected ? Color.accentColor.opacity(0.65) : DarkTheme.textPrimary.opacity(isHovered ? 0.25 : 0.12),
                                    lineWidth: isSelected ? 2 : 1
                                )
                        )
                        .shadow(color: .black.opacity(isHovered ? 0.25 : 0.18), radius: isHovered ? 12 : 8, y: 6)
                )

                // Checkmark badge
                if isSelected {
                    Image(systemName: "checkmark.seal.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color.accentColor, Color.white)
                        .font(.system(size: 18, weight: .semibold))
                        .padding(6)
                        .background(
                            Circle().fill(DarkTheme.cardBackground.opacity(0.6))
                        )
                        .offset(x: -6, y: 6)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .scaleEffect(isHovered ? 1.02 : 1.0)
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}

#Preview {
    AuthOnboardingView(viewModel: ProfessionalOnboardingViewModel())
        .frame(width: 1200, height: 800)
        .background(.black)
}
