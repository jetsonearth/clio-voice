import SwiftUI
import SwiftData
import KeyboardShortcuts

struct OnboardingTutorialView: View {
    @Binding var hasCompletedOnboarding: Bool
    @EnvironmentObject private var hotkeyManager: HotkeyManager
    @EnvironmentObject private var whisperState: WhisperState
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var scale: CGFloat = 0.8
    @State private var opacity: CGFloat = 0
    @State private var transcribedText: String = ""
    @State private var isTextFieldFocused: Bool = false
    @State private var showingShortcutHint: Bool = true
    @FocusState private var isFocused: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Reusable background
                OnboardingBackgroundView()
                
                HStack(spacing: 0) {
                    // Left side - Tutorial instructions
                    VStack(alignment: .leading, spacing: 40) {
                        // Title and description
                        VStack(alignment: .leading, spacing: 16) {
                            Text(localizationManager.localizedString("onboarding.tutorial.title"))
                                .font(.system(size: 44, weight: .bold))
                                .foregroundColor(DarkTheme.textPrimary)
                            
                            Text(localizationManager.localizedString("onboarding.tutorial.subtitle"))
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(DarkTheme.textPrimary.opacity(0.7))
                                .lineSpacing(4)
                        }
                        
                        // Keyboard shortcut display
                        VStack(alignment: .leading, spacing: 20) {
                            Text(localizationManager.localizedString("onboarding.tutorial.your_shortcut"))
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundColor(DarkTheme.textPrimary)
                            
                            if let shortcut = KeyboardShortcuts.getShortcut(for: .toggleMiniRecorder) {
                                KeyboardShortcutView(shortcut: shortcut)
                                    .scaleEffect(1.2)
                            }
                        }
                        
                        // Instructions
                        VStack(alignment: .leading, spacing: 24) {
                            ForEach(1...4, id: \.self) { step in
                                instructionStep(number: step, text: getInstructionText(for: step))
                            }
                        }
                        
                        Spacer()
                        
                        // Continue button
                        Button(action: {
                            hasCompletedOnboarding = true
                        }) {
                            Text(localizationManager.localizedString("onboarding.tutorial.complete_setup"))
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(DarkTheme.textPrimary)
                                .frame(width: 200, height: 50)
                                .background(Color.accentColor)
                                .cornerRadius(25)
                        }
                        .buttonStyle(ScaleButtonStyle())
                        .opacity(transcribedText.isEmpty ? 0.5 : 1)
                        .disabled(transcribedText.isEmpty)
                        
                        SkipButton(text: localizationManager.localizedString("onboarding.button.skip_for_now")) {
                            hasCompletedOnboarding = true
                        }
                    }
                    .padding(60)
                    .frame(width: geometry.size.width * 0.5)
                    
                    // Right side - Interactive area
                    VStack {
                        // Magical text editor area
                        ZStack {
                            // Glowing background
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.black.opacity(0.4))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(DarkTheme.textPrimary.opacity(0.1), lineWidth: 1)
                                )
                                .overlay(
                                    // Subtle gradient overlay
                                    LinearGradient(
                                        colors: [
                                            Color.accentColor.opacity(0.05),
                                            Color.black.opacity(0.1)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: Color.accentColor.opacity(0.1), radius: 15, x: 0, y: 0)
                            
                            // Text editor with custom styling
                            TextEditor(text: $transcribedText)
                                .font(.system(size: 32, weight: .bold))
                                .focused($isFocused)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                                .foregroundColor(DarkTheme.textPrimary)
                                .padding(20)
                            
                            // Placeholder text with magical appearance
                            if transcribedText.isEmpty {
                                VStack(spacing: 16) {
                                    Image(systemName: "wand.and.stars")
                                        .font(.system(size: 36))
                                        .foregroundColor(DarkTheme.textPrimary.opacity(0.3))
                                    
                                    Text(localizationManager.localizedString("onboarding.tutorial.placeholder"))
                                        .font(.system(size: 28, weight: .semibold))
                                        .foregroundColor(DarkTheme.textPrimary.opacity(0.5))
                                        .multilineTextAlignment(.center)
                                }
                                .padding()
                                .allowsHitTesting(false)
                            }
                            
                            // Subtle animated border
                            RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            Color.accentColor.opacity(isFocused ? 0.4 : 0.1),
                                            Color.accentColor.opacity(isFocused ? 0.2 : 0.05)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                                .animation(.easeInOut(duration: 0.3), value: isFocused)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .padding(60)
                    .frame(width: geometry.size.width * 0.5)
                }
            }
        }
        .onAppear {
            animateIn()
            isFocused = true
        }
    }
    
    private func getInstructionText(for step: Int) -> String {
        switch step {
        case 1: return localizationManager.localizedString("onboarding.tutorial.step_1")
        case 2: return localizationManager.localizedString("onboarding.tutorial.step_2")
        case 3: return localizationManager.localizedString("onboarding.tutorial.step_3")
        case 4: return localizationManager.localizedString("onboarding.tutorial.step_4")
        default: return ""
        }
    }
    
    private func instructionStep(number: Int, text: String) -> some View {
        HStack(spacing: 20) {
            Text("\(number)")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(DarkTheme.textPrimary)
                .frame(width: 40, height: 40)
                .background(Circle().fill(Color.accentColor.opacity(0.2)))
                .overlay(
                    Circle()
                        .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
                )
            
            Text(text)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(DarkTheme.textPrimary.opacity(0.9))
                .lineSpacing(4)
        }
    }
    
    private func animateIn() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            scale = 1
            opacity = 1
        }
    }
}

#Preview {
    // Simple preview without heavy dependencies
    OnboardingTutorialView(hasCompletedOnboarding: .constant(false))
        .environmentObject(LocalizationManager.shared)
        .environmentObject({
            let context = try! ModelContainer(for: Transcription.self).mainContext
            let whisperState = WhisperState(modelContext: context, enhancementService: nil)
            return HotkeyManager(whisperState: whisperState)
        }())
        .environmentObject({
            let context = try! ModelContainer(for: Transcription.self).mainContext
            return WhisperState(modelContext: context, enhancementService: nil)
        }())
} 