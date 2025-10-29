import SwiftUI

struct EmailConfirmationView: View {
    let email: String
    let onResendEmail: () -> Void
    let onConfirmed: () -> Void
    
    @State private var animateElements = false
    @State private var isResending = false
    @State private var resendCooldown = 0
    @State private var resendTimer: Timer?
    
    var body: some View {
        VStack(spacing: 0) {
            // Main content
            VStack(spacing: 50) {
                // Email icon and title
                VStack(spacing: 32) {
                    // Email verification icon
                    Image(systemName: "envelope.circle.fill")
                        .font(.system(size: 100))
                        .foregroundColor(.accentColor)
                    .opacity(animateElements ? 1 : 0)
                    .scaleEffect(animateElements ? 1 : 0.5)
                    
                    // Title and subtitle
                    VStack(spacing: 16) {
                        Text("Check your email")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(DarkTheme.textPrimary)
                            .opacity(animateElements ? 1 : 0)
                        
                        VStack(spacing: 8) {
                            Text("We sent a confirmation link to")
                                .font(.system(size: 18))
                                .foregroundColor(DarkTheme.textSecondary)
                            
                            Text(email)
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.accentColor)
                        }
                        .opacity(animateElements ? 1 : 0)
                    }
                    .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                // Instructions and actions
                VStack(spacing: 32) {
                    // Instructions
                    VStack(spacing: 12) {
                        Text("Click the link in your email to verify your account.")
                            .font(.system(size: 16))
                            .foregroundColor(DarkTheme.textSecondary)
                            .multilineTextAlignment(.center)
                        
                        Text("Once verified, you'll be automatically signed in.")
                            .font(.system(size: 14))
                            .foregroundColor(DarkTheme.textSecondary.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .opacity(animateElements ? 1 : 0)
                    .offset(y: animateElements ? 0 : 20)
                    
                    // Action buttons
                    VStack(spacing: 20) {
                        // Resend email button using StyledActionButton
                        StyledActionButton(
                            title: resendButtonText,
                            action: handleResendEmail,
                            isDisabled: isResending || resendCooldown > 0,
                            showArrow: false
                        )
                        .frame(width: 240)
                        
                        // Manual check button using StyledActionButton
                        StyledActionButton(
                            title: "I've verified my email",
                            action: {
                                print("🔘 User manually triggered email verification check")
                                onConfirmed()
                            },
                            isDisabled: false,
                            showArrow: false
                        )
                        .frame(width: 240)
                    }
                    .opacity(animateElements ? 1 : 0)
                    .offset(y: animateElements ? 0 : 20)
                }
                
                // Help text
                VStack(spacing: 6) {
                    Text("Didn't receive the email?")
                        .font(.system(size: 14))
                        .foregroundColor(DarkTheme.textSecondary.opacity(0.7))
                    
                    Text("Check your spam folder or try resending")
                        .font(.system(size: 13))
                        .foregroundColor(DarkTheme.textSecondary.opacity(0.5))
                }
                .multilineTextAlignment(.center)
                .padding(.bottom, 40)
                .opacity(animateElements ? 1 : 0)
            }
            .padding(.horizontal, 60)
            .padding(.vertical, 40)
        }
        .frame(minWidth: 600, minHeight: 500)
        .onAppear {
            startAnimations()
        }
        .onDisappear {
            resendTimer?.invalidate()
        }
    }
    
    private var resendButtonText: String {
        if isResending {
            return "Sending..."
        } else if resendCooldown > 0 {
            return "Resend in \(resendCooldown)s"
        } else {
            return "Resend email"
        }
    }
    
    private func handleResendEmail() {
        guard !isResending && resendCooldown == 0 else { return }
        
        isResending = true
        onResendEmail()
        
        // Simulate sending delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isResending = false
            startResendCooldown()
        }
    }
    
    private func startResendCooldown() {
        resendCooldown = 30
        resendTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            resendCooldown -= 1
            if resendCooldown <= 0 {
                timer.invalidate()
                resendTimer = nil
            }
        }
    }
    
    private func startAnimations() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.1)) {
            animateElements = true
        }
    }
}

#Preview {
    EmailConfirmationView(
        email: "user@example.com",
        onResendEmail: { print("Resend email") },
        onConfirmed: { print("Email confirmed") }
    )
    .frame(width: 1200, height: 800)
    .background(.black)
}