import SwiftUI

struct WelcomeSourceView: View {
    let userName: String
    let onComplete: () -> Void
    let onBack: () -> Void
    
    @EnvironmentObject private var localizationManager: LocalizationManager
    @StateObject private var supabaseService = SupabaseServiceSDK.shared
    @State private var selectedSource: ReferralSource?
    @State private var animateElements = false
    @State private var isSaving = false
    
    enum ReferralSource: String, CaseIterable {
        case twitter = "Twitter/X"
        case youtube = "YouTube"
        case reddit = "Reddit"
        case productHunt = "Product Hunt"
        case friend = "Friend/Colleague"
        case search = "Google Search"
        case blog = "Blog/Article"
        case coldOutreach = "From Jetson"
        case other = "Other"
        
        var icon: String {
            switch self {
            case .twitter: return "at"
            case .youtube: return "play.rectangle.fill"
            case .reddit: return "bubble.left.and.bubble.right.fill"
            case .productHunt: return "flame.fill"
            case .friend: return "person.2.fill"
            case .search: return "magnifyingglass"
            case .blog: return "doc.text.fill"
            case .coldOutreach: return "person.badge.plus.fill"
            case .other: return "ellipsis"
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Full-page background image to match auth views
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

            // Subtle readability gradient
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
                // Header with controls
                OnboardingHeaderControls()

                // Main content
                VStack(spacing: 40) {
                // Welcome message
                VStack(spacing: 16) {
                    Text(String(format: localizationManager.localizedString("onboarding.welcome.title"), userName))
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(DarkTheme.textPrimary)
                        .opacity(animateElements ? 1 : 0)
                        .scaleEffect(animateElements ? 1 : 0.8)
                    
                    Text(localizationManager.localizedString("onboarding.welcome.subtitle"))
                        .font(.system(size: 18))
                        .foregroundColor(DarkTheme.textSecondary)
                        .opacity(animateElements ? 1 : 0)
                }
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.top, 40)
                
                // Source selection
                VStack(spacing: 20) {
                    // Text("Help us understand how you found Io")
                    //     .font(.system(size: 14))
                    //     .foregroundColor(DarkTheme.textSecondary.opacity(0.8))
                    //     .opacity(animateElements ? 1 : 0)
                    
                    // Source grid
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        ForEach(ReferralSource.allCases, id: \.rawValue) { source in
                            SourceButton(
                                source: source,
                                isSelected: selectedSource == source,
                                action: { selectedSource = source }
                            )
                        }
                    }
                    .frame(maxWidth: 480)
                    .opacity(animateElements ? 1 : 0)
                    .offset(y: animateElements ? 0 : 20)
                }
                .frame(maxWidth: .infinity)
                
                // Continue and back buttons with skip option
                VStack(spacing: 16) {
                    // Back and Continue buttons
                    HStack(spacing: 8) {
                        StyledBackButton {
                            onBack()
                        }
                        
                        StyledActionButton(
                            title: isSaving ? "Saving..." : localizationManager.localizedString("general.continue"),
                            action: handleContinue,
                            isDisabled: selectedSource == nil || isSaving,
                            showArrow: !isSaving
                        )
                    }
                    
                    // Skip option as plain text
                    Text(localizationManager.localizedString("onboarding.skip"))
                        .font(.system(size: 14))
                        .foregroundColor(DarkTheme.textSecondary)
                        .onTapGesture {
                            onComplete()
                        }
                        .frame(maxWidth: .infinity)
                }
                .opacity(animateElements ? 1 : 0)
                .offset(y: animateElements ? 0 : 20)
                
                    Spacer()
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            startAnimations()
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
    
    private func handleContinue() {
        guard let source = selectedSource else { return }
        
        isSaving = true
        
        Task {
            do {
                // Save the welcome source to Supabase
                try await supabaseService.updateWelcomeSource(source.rawValue)
                print("✅ User heard about us from: \(source.rawValue)")
                
                await MainActor.run {
                    isSaving = false
                    onComplete()
                }
            } catch {
                print("❌ Failed to save welcome source: \(error)")
                // Still continue even if saving fails
                await MainActor.run {
                    isSaving = false
                    onComplete()
                }
            }
        }
    }
    
    private func startAnimations() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.1)) {
            animateElements = true
        }
    }
}

struct SourceButton: View {
    let source: WelcomeSourceView.ReferralSource
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Icon
                Image(systemName: source.icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(isSelected ? .accentColor : DarkTheme.textSecondary)
                    .frame(width: 32, height: 32)
                
                // Label
                Text(source.rawValue)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? DarkTheme.textPrimary : DarkTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(height: 100)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? .accentColor : DarkTheme.textPrimary.opacity(isHovered ? 0.3 : 0.15),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
        .animation(.easeInOut(duration: 0.15), value: isSelected)
        .animation(.easeInOut(duration: 0.15), value: isHovered)
    }
}

#Preview {
    ZStack {
        // Background to match app
        Color(hex: "0A0A0A")
            .ignoresSafeArea()
        
        WelcomeSourceView(
            userName: "Kentaro",
            onComplete: { print("Welcome completed") },
            onBack: { print("Back pressed") }
        )
    }
    .frame(width: 1400, height: 900)
}
