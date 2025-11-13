import SwiftUI
import KeyboardShortcuts

// MARK: - Try It View
struct ProfessionalTryItView: View {
    @ObservedObject var viewModel: ProfessionalOnboardingViewModel
    @Binding var hasCompletedOnboarding: Bool
    @EnvironmentObject private var recordingEngine: RecordingEngine
    @EnvironmentObject private var hotkeyManager: HotkeyManager
    @EnvironmentObject private var localizationManager: LocalizationManager
    // Three pages: 0 = Push‑to‑talk, 1 = Hands‑free, 2 = Command
    @State private var currentStep = 0
    @State private var showTextEditor = true
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with controls
            OnboardingHeaderControls()
            
            // Content
            Group {
                if currentStep == 0 {
                    AquaStyleTryItContainer(mode: .pushToTalk,
                                             onPrimary: { currentStep = 1 },
                                             primaryTitle: localizationManager.localizedString("onboarding.tryit.next"),
                                             onSecondary: { 
                                                 withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                                     viewModel.previousScreen() 
                                                 }
                                             },
                                             secondaryIsBack: true)
                } else if currentStep == 1 {
                    AquaStyleTryItContainer(mode: .handsFree,
                                             onPrimary: { currentStep = 2 },
                                             primaryTitle: localizationManager.localizedString("onboarding.tryit.next"),
                                             onSecondary: { currentStep = 0 },
                                             secondaryIsBack: true)
                } else {
                    AquaStyleTryItContainer(mode: .command,
                                             onPrimary: { hasCompletedOnboarding = true },
                                             primaryTitle: localizationManager.localizedString("onboarding.tryit.complete_setup"),
                                             onSecondary: { currentStep = 1 },
                                             secondaryIsBack: true)
                }
            }
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentStep)
        }
    }
}

// MARK: - Enhanced Intro View
struct EnhancedIntroView: View {
    let onNext: () -> Void
    let onBack: () -> Void
    @State private var isAnimating = false
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    private let apps = [
        ("message.fill", "Slack", "Team Chat"),
        ("envelope.fill", "Email", "Communication"),
        ("doc.text.fill", "Notion", "Note Taking"),
        ("brain", "Cursor", "AI Coding"),
        ("sparkles", "ChatGPT", "AI Assistant")
    ]
    
    var body: some View {
        VStack(spacing: 80) {
            // Header section
            VStack(spacing: 24) {
                Text(localizationManager.localizedString("onboarding.intro.title"))
                    .font(.system(size: 42, weight: .bold))
                    .foregroundColor(DarkTheme.textPrimary)
                    .scaleEffect(isAnimating ? 1.0 : 0.8)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2), value: isAnimating)
                
                Text(localizationManager.localizedString("onboarding.intro.description"))
                    .font(.system(size: 18))
                    .foregroundColor(DarkTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .frame(maxWidth: 700)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.8).delay(0.5), value: isAnimating)
            }
            
            // App showcase - single row
            HStack(spacing: 24) {
                ForEach(Array(apps.enumerated()), id: \.offset) { index, app in
                    EnhancedAppCard(
                        icon: app.0,
                        title: app.1,
                        subtitle: app.2,
                        delay: Double(index) * 0.1 + 0.8
                    )
                }
            }
            
            
            // Two-column button layout
            HStack {
                StyledBackButton(action: onBack)
                                
                StyledActionButton(
                    title: localizationManager.localizedString("onboarding.intro.next"),
                    action: onNext
                )               
                // Button(action: onNext) {
                //     HStack(spacing: 8) {
                //         Text("Next")
                //             .font(.system(size: 16, weight: .semibold))
                //             .foregroundColor(DarkTheme.textPrimary)
                        
                //         Image(systemName: "arrow.right")
                //             .font(.system(size: 14, weight: .semibold))
                //             .foregroundColor(DarkTheme.textPrimary)
                //     }
                //     .frame(width: 120, height: 48)
                //     .background(
                //         ZStack {
                //             RoundedRectangle(cornerRadius: 12)
                //                 .fill(.thinMaterial)
                            
                //             RoundedRectangle(cornerRadius: 12)
                //                 .stroke(DarkTheme.textPrimary.opacity(0.2), lineWidth: 1)
                //         }
                //     )
                //     .shadow(
                //         color: DarkTheme.textPrimary.opacity(0.1),
                //         radius: 8,
                //         y: 2
                //     )
                // }
                // .buttonStyle(.plain)
            }
            .opacity(isAnimating ? 1.0 : 0.0)
            .animation(.easeInOut(duration: 0.6).delay(1.5), value: isAnimating)
        }
        .padding(.horizontal, 80)
        .padding(.vertical, 80)
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Enhanced App Card
struct EnhancedAppCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let delay: Double
    @State private var isVisible = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Icon container
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(DarkTheme.textPrimary.opacity(0.08))
                    .frame(width: 80, height: 80)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(DarkTheme.textPrimary.opacity(0.15), lineWidth: 1)
                    )
                
                Image(systemName: icon)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(DarkTheme.textPrimary)
            }
            
            // Text content
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(DarkTheme.textPrimary)
                
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(DarkTheme.textSecondary)
            }
        }
        .scaleEffect(isVisible ? 1.0 : 0.8)
        .opacity(isVisible ? 1.0 : 0.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(delay), value: isVisible)
        .onAppear {
            withAnimation {
                isVisible = true
            }
        }
    }
}

// MARK: - Enhanced Shortcut View
struct EnhancedShortcutView: View {
    @EnvironmentObject private var hotkeyManager: HotkeyManager
    @EnvironmentObject private var localizationManager: LocalizationManager
    let onNext: () -> Void
    let onBack: () -> Void
    @State private var isAnimating = false
    
    var body: some View {
        VStack {
            
            HStack(spacing: 80) {
                // Left side - Instructions
                VStack(alignment: .leading, spacing: 50) {
                VStack(alignment: .leading, spacing: 24) {
                    Text(localizationManager.localizedString("onboarding.shortcut.title"))
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(DarkTheme.textPrimary)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.8).delay(0.2), value: isAnimating)
                    
                    Text(String(format: localizationManager.localizedString("onboarding.shortcut.description"), displayHotkeyText))
                        .font(.system(size: 18))
                        .foregroundColor(DarkTheme.textSecondary)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.8).delay(0.4), value: isAnimating)
                }
                
                // Hotkey demonstration
                VStack(alignment: .leading, spacing: 20) {
                    Text(localizationManager.localizedString("onboarding.shortcut.hotkey_title"))
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(DarkTheme.textPrimary)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.6).delay(0.6), value: isAnimating)
                    
                    HStack(spacing: 16) {
                        // Key visualization
                        ZStack {
RoundedRectangle(cornerRadius: 12)
                                .fill(DarkTheme.textPrimary.opacity(0.1))
                                .frame(width: 72, height: 60)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(DarkTheme.textPrimary.opacity(0.3), lineWidth: 2)
                                )
                            
Text(tileKeySymbol)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(DarkTheme.textPrimary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                        }
                        
                        Text(localizationManager.localizedString("onboarding.shortcut.action_text"))
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(DarkTheme.textSecondary)
                    }
                    .scaleEffect(isAnimating ? 1.0 : 0.8)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.8), value: isAnimating)
                }
                }
                .frame(maxWidth: 450)
                
                // Right side - Enhanced visual demo
                EnhancedMockInterface()
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.8).delay(1.0), value: isAnimating)
            }
            
            Rectangle()
                .fill(Color.clear)
                .frame(height: 60)
            
            // Two-column button layout
            HStack {
                StyledBackButton(action: onBack)
                
                                
                StyledActionButton(
                    title: localizationManager.localizedString("onboarding.shortcut.try_it_out"),
                    action: onNext
                )
            }
            .opacity(isAnimating ? 1.0 : 0.0)
            .animation(.easeInOut(duration: 0.6).delay(1.2), value: isAnimating)
            .padding(.bottom, 80)
        }
        .padding(.horizontal, 60)
        .padding(.top, 80)
        .onAppear {
            isAnimating = true
        }
    }
    
private var displayHotkeyText: String {
        if let hf = hotkeyManager.handsFreeShortcut {
            return hf.description
        }
        return hotkeyManager.getCurrentShortcutDescription() ?? "⌘"
    }
    
private var keyName: String { displayHotkeyText }
    
    private var tileKeySymbol: String {
        // Prefer hands-free binding in onboarding demo; otherwise use dictation shortcut
        if let hf = hotkeyManager.handsFreeShortcut {
            if hf.keys.isEmpty {
                return glyphFrom(modifiers: hf.modifiers)
            } else {
                return tileSymbolFromDescription(hf.description)
            }
        }
        let desc = hotkeyManager.getCurrentShortcutDescription() ?? ""
        return tileSymbolFromDescription(desc)
    }
    
    private func glyphFrom(modifiers: UInt) -> String {
        let flags = NSEvent.ModifierFlags(rawValue: modifiers)
        if flags.contains(.command) { return "⌘" }
        if flags.contains(.option) { return "⌥" }
        if flags.contains(.control) { return "⌃" }
        if flags.contains(.shift) { return "⇧" }
        if flags.contains(.function) { return "fn" }
        return "⌘"
    }
    
    private func tileSymbolFromDescription(_ s: String) -> String {
        if s.lowercased().contains("fn") { return "fn" }
        if s.contains("⌘") { return "⌘" }
        if s.contains("⌥") { return "⌥" }
        if s.contains("⌃") { return "⌃" }
        if s.contains("⇧") { return "⇧" }
        if let range = s.range(of: "F\\d{1,2}", options: .regularExpression) {
            return String(s[range])
        }
        if let range = s.uppercased().range(of: "[A-Z]", options: .regularExpression) {
            return String(s[range])
        }
        return "⌘"
    }
}

// MARK: - Enhanced Mock Interface
struct EnhancedMockInterface: View {
    @State private var dictatedText = ""
    @State private var isListening = false
    @State private var currentWordIndex = 0
    @State private var isFormatting = false
    @State private var formattedText = ""
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    private let speechWords = ["Hi", "Sarah,", "", "I", "wanted", "to", "follow", "up", "on", "our", "discussion", "about", "the", "new", "project", "timeline.", "", "Could", "we", "schedule", "a", "meeting", "for", "next", "week", "to", "review", "the", "details?", "", "Thanks!"]
    
    private var finalFormattedEmail: String {
        """
Hi Sarah,

I wanted to follow up on our discussion about the new project timeline.

Could we schedule a meeting for next week to review the details?

Thanks!
"""
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Mock app header - Email
            HStack {
                HStack(spacing: 8) {
                    Circle()
                        .fill(.red)
                        .frame(width: 12, height: 12)
                    Circle()
                        .fill(.yellow)
                        .frame(width: 12, height: 12)
                    Circle()
                        .fill(.green)
                        .frame(width: 12, height: 12)
                }
                
                Spacer()
                
                // Text("Mail")
                //     .font(.system(size: 14, weight: .medium))
                //     .foregroundColor(DarkTheme.textSecondary)
                
                // Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(white: 0.08))
            
            // Email compose interface
            VStack(spacing: 12) {
                // Email header
                VStack(spacing: 8) {
                    HStack {
                        Text(localizationManager.localizedString("email.to_label"))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(DarkTheme.textSecondary)
                        Text(localizationManager.localizedString("email.sample_address"))
                            .font(.system(size: 13))
                            .foregroundColor(DarkTheme.textPrimary)
                        Spacer()
                    }
                    
                    HStack {
                        Text(localizationManager.localizedString("email.subject_label"))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(DarkTheme.textSecondary)
                        Text(localizationManager.localizedString("email.sample_subject"))
                            .font(.system(size: 13))
                            .foregroundColor(DarkTheme.textPrimary)
                        Spacer()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                
                Divider()
                    .background(DarkTheme.textSecondary.opacity(0.2))
                
                // Email body with voice dictation
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        // Microphone indicator
                        if isListening {
                            HStack(spacing: 6) {
                                Image(systemName: "mic.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.red)
                                
                                Text(localizationManager.localizedString("onboarding.demo.listening"))
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.red)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(4)
                        }
                        
                        Spacer()
                    }
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 4) {
                            if isFormatting {
                                // Show "Formatting..." indicator
                                HStack(spacing: 6) {
                                    ProgressView()
                                        .scaleEffect(0.7)
                                        .frame(width: 16, height: 16)
                                    Text(localizationManager.localizedString("onboarding.demo.ai_formatting"))
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(DarkTheme.textSecondary)
                                }
                                .padding(.vertical, 8)
                            }
                            
                            Text(formattedText.isEmpty ? dictatedText : formattedText)
                                .font(.system(size: 14))
                                .foregroundColor(DarkTheme.textPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                                .animation(.easeInOut(duration: 0.5), value: formattedText.isEmpty ? dictatedText : formattedText)
                            
                            // Blinking cursor
                            if isListening {
                                Rectangle()
                                    .fill(DarkTheme.textPrimary)
                                    .frame(width: 2, height: 16)
                                    .opacity(isListening ? 1.0 : 0.0)
                                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isListening)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxHeight: 120)
                }
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
            }
        }
        .background(Color(white: 0.03))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(DarkTheme.textPrimary.opacity(0.15), lineWidth: 1)
        )
        .frame(width: 400, height: 320)
        .onAppear {
            startVoiceDictationAnimation()
        }
    }
    
    private func startVoiceDictationAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isListening = true
            animateVoiceDictation()
        }
    }
    
    private func animateVoiceDictation() {
        guard currentWordIndex < speechWords.count else {
            isListening = false
            // Start formatting after dictation finishes
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                startFormatting()
            }
            return
        }
        
        let word = speechWords[currentWordIndex]
        
        // Handle pauses (empty strings)
        if word.isEmpty {
            currentWordIndex += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                animateVoiceDictation()
            }
            return
        }
        
        // Add word to dictated text
        if !dictatedText.isEmpty {
            dictatedText += " "
        }
        dictatedText += word
        currentWordIndex += 1
        
        // Realistic speech timing - shorter words faster, longer words/punctuation slower
        let delay: Double = {
            if word.contains(".") || word.contains("?") || word.contains("!") {
                return 0.7 // Pause after punctuation
            } else if word.count > 6 {
                return 0.4 // Longer words take more time
            } else {
                return 0.25 // Normal words
            }
        }()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            animateVoiceDictation()
        }
    }
    
    private func startFormatting() {
        isFormatting = true
        
        // Show formatting indicator for 1.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isFormatting = false
            // Replace with formatted email
            withAnimation(.easeInOut(duration: 0.8)) {
                formattedText = finalFormattedEmail
            }
        }
    }
}

// MARK: - Mock Message
struct MockMessage: View {
    let author: String
    let message: String
    let isCurrentUser: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if !isCurrentUser {
                Circle()
                    .fill(DarkTheme.textPrimary.opacity(0.2))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text(String(author.prefix(1)))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(DarkTheme.textPrimary)
                    )
            }
            
            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                if !isCurrentUser {
                    Text(author)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(DarkTheme.textPrimary)
                }
                
                Text(message)
                    .font(.system(size: 14))
                    .foregroundColor(DarkTheme.textPrimary.opacity(0.9))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isCurrentUser ? DarkTheme.textPrimary.opacity(0.15) : Color(white: 0.08))
                    )
            }
            
            if isCurrentUser {
                Spacer()
            }
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Aqua-style Try It Container (two modes: push-to-talk and hands-free)
struct AquaStyleTryItContainer: View {
    let mode: Mode
    let onPrimary: () -> Void
    let primaryTitle: String
    let onSecondary: () -> Void
    let secondaryIsBack: Bool
    @EnvironmentObject private var hotkeyManager: HotkeyManager
    @EnvironmentObject private var localizationManager: LocalizationManager
    @EnvironmentObject private var recordingEngine: RecordingEngine
    @State private var transcribedText = ""
    @State private var isAnimating = false
    @State private var showShortcutCapture = false
    @State private var showHandsFreeCapture = false
    @State private var showAssistantCapture = false
    @State private var hasSetShortcut = false
    @State private var isTryItActive = false
    @FocusState private var isTextEditorFocused: Bool

    // Only show final text (no streaming). We cache the latest final ASR during recording
    // and render it once recording ends.
    @State private var pendingFinalResult: String = ""
    @State private var wasRecording: Bool = false
    
    enum Mode { case pushToTalk, handsFree, command }
    
    @AppStorage("handsFreeShortcutDisplay") private var handsFreeShortcutDisplay: String = ""
    
    var body: some View {
        ZStack {
            // Background image based on mode
            TryItBackgroundView(mode: mode)
            
            // Foreground content
            VStack(spacing: 0) {
                // Top section: Instruction banner (opaque) + example text
                VStack(alignment: .leading, spacing: 16) {
                    // Instruction line aligned with editor width; improved layout for Command mode
                    HStack {
                        Spacer()
                        Group {
                            if mode == .command {
                                // Two-line layout: prefix + keys on first line, suffix on second line
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                                        Image(systemName: "mic.fill")
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(Color.accentColor)
                                        Text(instructionText)
                                            .foregroundColor(DarkTheme.textPrimary)
                                            .font(.system(size: 13, weight: .semibold))
                                        KeycapView(text: "Left ⌘")
                                        Text("+")
                                            .foregroundColor(DarkTheme.textPrimary)
                                            .font(.system(size: 13, weight: .semibold))
                                        KeycapView(text: "Left ⌃")
                                    }
                                    Text(instructionSuffix)
                                        .foregroundColor(DarkTheme.textPrimary)
                                        .font(.system(size: 13, weight: .semibold))
                                        .padding(.leading, 21) // Align with text after mic icon
                                }
                            } else {
                                HStack(spacing: 8) {
                                    Image(systemName: "mic.fill")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(Color.accentColor)
                                    Text(instructionText)
                                        .foregroundColor(DarkTheme.textPrimary)
                                        .font(.system(size: 13, weight: .semibold))
                                    KeycapView(text: keyGlyph)
                                    Text(instructionSuffix)
                                        .foregroundColor(DarkTheme.textPrimary)
                                        .font(.system(size: 13, weight: .semibold))
                                }
                            }
                        }
                        .frame(width: editorWidth, alignment: .leading)
                        Spacer()
                    }
                    
                    // Example text (hidden for command mode)
                    if mode != .command {
                        // Align with the editor: same centered width and same inner left padding (14)
                        HStack {
                            Spacer()
                            Text(exampleText)
                                .font(.system(size: 18, weight: .medium))
                                .italic()
                                .foregroundColor(DarkTheme.textPrimary)
                                .frame(width: editorWidth, alignment: .leading)
                                .padding(.leading, 14)
                                .overlay(
                                    Rectangle()
                                        .fill(DarkTheme.textPrimary.opacity(0.25))
                                        .frame(width: 2)
                                    , alignment: .leading
                                )
                            Spacer()
                        }
                    }
                    
                    // Input box (restore original lighter style, centered)
                    HStack {
                        Spacer()
                        GlassmorphismCard(cornerRadius: 12, padding: 0) {
                            TextEditor(text: $transcribedText)
                                .font(.system(size: 16))
                                .foregroundColor(DarkTheme.textPrimary)
                                .scrollContentBackground(.hidden)
                                .scrollIndicators(.hidden)
                                .scrollDisabled(true)
                                .background(Color.clear)
                                .padding(14)
                                .frame(height: 160)
                                .focused($isTextEditorFocused)
                        }
                        .frame(width: editorWidth)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(DarkTheme.textPrimary.opacity(0.18), lineWidth: 1)
                        )
                        Spacer()
                    }
                    
                    // Centered helper links (no instruction line here anymore)
                    HStack {
                        Spacer()
                        VStack(spacing: 10) {
                            HStack(spacing: 10) {
                                Text(localizationManager.localizedString("onboarding.tryit.want_to_change_keys"))
                                    .foregroundColor(DarkTheme.textPrimary)
                                Button(action: openCurrentHotkeyEditor) {
                                    Text(localizationManager.localizedString("onboarding.tryit.edit_hotkeys"))
                                        .font(.system(size: 12, weight: .semibold))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(
                                            Capsule()
                                                .fill(Color.accentColor)
                                        )
                                        .foregroundColor(.white)
                                }
                                .buttonStyle(.plain)
                            }
                            
                            // Command mode tips
                            if mode == .command {
                                Text(localizationManager.localizedString("onboarding.tryit.command_tips"))
                                    .font(.system(size: 12))
                                    .foregroundColor(DarkTheme.textPrimary.opacity(0.75))
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .frame(width: editorWidth)
                        Spacer()
                    }
                    .padding(.top, 12)
                }
                .padding(.top, topPadding)
                .frame(maxWidth: .infinity)
                .frame(width: contentWidth)
                
                // Fixed spacing instead of Spacer
                Spacer()
                    .frame(height: 40)
                
                // Bottom nav + skip
                VStack(spacing: 6) {
                    HStack(spacing: 8) {
                        if secondaryIsBack { StyledBackButton { onSecondary() } }
                        StyledActionButton(title: primaryTitle, action: onPrimary, isDisabled: false, showArrow: true)
                    }
                    
                    // Text-only skip that advances just like "Next"
                    SkipButton(text: localizationManager.localizedString("onboarding.button.skip_for_now")) {
                        onPrimary()
                    }
                }
                .padding(.bottom, 96)
            }
        }
        .onAppear {
            isAnimating = true
            hasSetShortcut = hotkeyManager.getCurrentShortcutDescription() != nil && hotkeyManager.getCurrentShortcutDescription() != "No shortcut set"
        }
        .sheet(isPresented: $showShortcutCapture) {
            ShortcutCaptureModal(
                onSave: { result in
                    // Same shortcut handling as KeyboardSetupContent
                    switch result {
                    case .shortcut(let shortcut):
                        KeyboardShortcuts.setShortcut(shortcut, for: .toggleMiniRecorder)
                        hotkeyManager.customShortcut = nil
                        hotkeyManager.isPushToTalkEnabled = false
                        
                    case .combination(let keys, let modifiers, let modifierKeyCodes):
                        let customShortcut = CustomShortcut(
                            keys: keys,
                            modifiers: modifiers.rawValue,
                            keyCode: nil,
                            modifierKeyCodes: modifierKeyCodes
                        )
                        KeyboardShortcuts.setShortcut(nil, for: .toggleMiniRecorder)
                        hotkeyManager.customShortcut = customShortcut
                        hotkeyManager.isPushToTalkEnabled = false
                        
                    case .modifierOnly(let keyCodes, let modifiers):
                        let customShortcut = CustomShortcut(
                            keys: [],
                            modifiers: modifiers.rawValue,
                            keyCode: keyCodes.first,
                            modifierKeyCodes: keyCodes
                        )
                        KeyboardShortcuts.setShortcut(nil, for: .toggleMiniRecorder)
                        hotkeyManager.customShortcut = customShortcut
                        hotkeyManager.isPushToTalkEnabled = false
                    }
                    hotkeyManager.updateShortcutStatus()
                    hasSetShortcut = true
                    showShortcutCapture = false
                },
                onCancel: { showShortcutCapture = false }
            )
        }
        .sheet(isPresented: $showHandsFreeCapture) {
            ShortcutCaptureModal(
                onSave: { result in
                    // Same hands-free handling as KeyboardSetupContent
                    switch result {
                    case .shortcut(let sc):
                        let keyCode = sc.key?.rawValue != nil ? UInt16(sc.key!.rawValue) : nil
                        let cs = CustomShortcut(keys: keyCode != nil ? [keyCode!] : [],
                                                modifiers: sc.modifiers.rawValue,
                                                keyCode: nil,
                                                modifierKeyCodes: nil)
                        hotkeyManager.handsFreeShortcut = cs
                        self.handsFreeShortcutDisplay = cs.description
                    case .combination(let keys, let modifiers, let modifierKeyCodes):
                        let cs = CustomShortcut(keys: keys,
                                                modifiers: modifiers.rawValue,
                                                keyCode: nil,
                                                modifierKeyCodes: modifierKeyCodes)
                        hotkeyManager.handsFreeShortcut = cs
                        self.handsFreeShortcutDisplay = cs.description
                    case .modifierOnly(let keyCodes, let modifiers):
                        let cs = CustomShortcut(keys: [],
                                                modifiers: modifiers.rawValue,
                                                keyCode: keyCodes.first,
                                                modifierKeyCodes: keyCodes)
                        hotkeyManager.handsFreeShortcut = cs
                        self.handsFreeShortcutDisplay = cs.description
                    }
                    showHandsFreeCapture = false
                },
                onCancel: { showHandsFreeCapture = false }
            )
        }
        .sheet(isPresented: $showAssistantCapture) {
            ShortcutCaptureModal(
                onSave: { result in
                    // Capture assistant (command mode) shortcut
                    switch result {
                    case .shortcut(let sc):
                        let keyCode = sc.key?.rawValue != nil ? UInt16(sc.key!.rawValue) : nil
                        let cs = CustomShortcut(keys: keyCode != nil ? [keyCode!] : [],
                                                modifiers: sc.modifiers.rawValue,
                                                keyCode: nil,
                                                modifierKeyCodes: nil)
                        hotkeyManager.assistantShortcut = cs
                    case .combination(let keys, let modifiers, let modifierKeyCodes):
                        let cs = CustomShortcut(keys: keys,
                                                modifiers: modifiers.rawValue,
                                                keyCode: nil,
                                                modifierKeyCodes: modifierKeyCodes)
                        hotkeyManager.assistantShortcut = cs
                    case .modifierOnly(let keyCodes, let modifiers):
                        let cs = CustomShortcut(keys: [],
                                                modifiers: modifiers.rawValue,
                                                keyCode: keyCodes.first,
                                                modifierKeyCodes: keyCodes)
                        hotkeyManager.assistantShortcut = cs
                    }
                    showAssistantCapture = false
                },
                onCancel: { showAssistantCapture = false }
            )
        }
        // Cache the latest Soniox finalized chunk, but don't show it until recording ends.
        .onReceive(recordingEngine.sonioxStreamingService.$finalBuffer) { text in
            guard isTryItActive else { return }
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                pendingFinalResult = trimmed
            }
        }
        .onReceive(recordingEngine.$isRecording) { isRecording in
            guard isTryItActive else { return }
            // Track start → clear any previous results and focus editor
            if isRecording {
                wasRecording = true
                pendingFinalResult = ""
                // Keep the caret focused in the demo editor, but DO NOT stream text
                isTextEditorFocused = true
            } else {
                // Recording just ended — prefer AI-enhanced text if available, else Soniox final fallback
                if wasRecording {
                    wasRecording = false
                    let enhanced = recordingEngine.lastOutputText.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !enhanced.isEmpty {
                        transcribedText = enhanced
                    } else {
                        let finalText = pendingFinalResult.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !finalText.isEmpty {
                            // Update the demo TextEditor directly; avoid system paste to prevent duplicates
                            transcribedText = finalText
                        }
                    }
                }
            }
        }
        // If enhancement completes slightly later, still prefer it and replace the fallback
        .onReceive(recordingEngine.$lastOutputText) { latest in
            guard isTryItActive else { return }
            let trimmed = latest.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                transcribedText = trimmed
            }
        }
        .onAppear {
            // Activate TryIt component when it appears
            isTryItActive = true
            // Suppress global paste while the Try It UI is frontmost
            recordingEngine.suppressSystemPaste = true
            // Clear any previous outputs
            recordingEngine.lastOutputText = ""
            // Set example text for command mode only
            if mode == .command {
                transcribedText = localizationManager.localizedString("onboarding.tryit.command_default_text")
                // If user has no assistant shortcut yet (first time seeing this mode), set default to Left ⌘ + Left ⌃
                if hotkeyManager.assistantShortcut == nil {
                    let flags = NSEvent.ModifierFlags.command.union(.control)
                    let combo = CustomShortcut(keys: [],
                                               modifiers: flags.rawValue,
                                               keyCode: nil,
                                               modifierKeyCodes: [55, 59])
                    hotkeyManager.assistantShortcut = combo
                }
            } else {
                transcribedText = ""
            }
        }
        .onDisappear {
            // Deactivate TryIt component when it disappears
            isTryItActive = false
            // Re-enable normal paste behavior for the rest of the app
            recordingEngine.suppressSystemPaste = false
        }
    }
    
    // MARK: - Helpers
    private var instructionText: String {
        switch mode {
        case .pushToTalk:
            return localizationManager.localizedString("onboarding.tryit.hold_down")
        case .handsFree:
            return localizationManager.localizedString("onboarding.tryit.press")
        case .command:
            return localizationManager.localizedString("onboarding.tryit.command_prefix")
        }
    }
    
    private var instructionSuffix: String {
        switch mode {
        case .pushToTalk:
            return localizationManager.localizedString("onboarding.tryit.and_begin_speaking")
        case .handsFree:
            return localizationManager.localizedString("onboarding.tryit.to_start_press_again")
        case .command:
            return localizationManager.localizedString("onboarding.tryit.command_instruction_suffix")
        }
    }
    
    private var exampleText: String {
        switch mode {
        case .pushToTalk:
            return "Clio is a new cognitive interface—where your voice becomes your instrument."
        case .handsFree:
            return "Clio is not voice-to-text. It's intention-to-output."
        case .command:
            return "" // Hidden in command mode
        }
    }
    
    private var editorWidth: CGFloat { mode == .command ? 700 : 620 }
    private var contentWidth: CGFloat { mode == .command ? 780 : 700 }
    private var topPadding: CGFloat { mode == .command ? 8 : 20 }
    
    private func openCurrentHotkeyEditor() {
        switch mode {
        case .pushToTalk: showShortcutCapture = true
        case .handsFree: showHandsFreeCapture = true
        case .command: showAssistantCapture = true
        }
    }
    
    private var currentShortcutDescription: String {
        return hotkeyManager.getCurrentShortcutDescription() ?? "No shortcut set"
    }
    
    private var keyGlyph: String {
        switch mode {
        case .pushToTalk:
            let d = hotkeyManager.getCurrentShortcutDescription() ?? "Right ⌥"
            return glyphFrom(description: d)
        case .handsFree:
            return glyphFrom(description: handsFreeDescription)
        case .command:
            return "Left ⌘ + Space"
        }
    }
    
    private func glyphFrom(description: String) -> String {
        // Handle our default shortcuts with proper side-specific display
        if description == "Right ⌥" || (description.contains("⌥") && description.contains("Right")) {
            return "Right ⌥"
        }
        if description == "Left ⌥" || (description.contains("⌥") && description.contains("Left")) {
            return "Right ⌥"  // Convert Left Option to Right Option for display
        }
        if description == "Right ⌘" || (description.contains("⌘") && description.contains("Right")) {
            return "Right ⌘"
        }
        if description == "Left ⌘ + Space" || (description.contains("⌘") && description.contains("Space") && description.contains("Left")) {
            return "Left ⌘ + Space"
        }
        
        // Original fallback logic
        if description.lowercased().contains("fn") { return "fn" }
        if let sym = ["⌘","⌥","⌃","⇧"].first(where: { description.contains($0) }) { return sym }
        if let range = description.range(of: "F\\d{1,2}", options: .regularExpression) {
            return String(description[range])
        }
        if let range = description.uppercased().range(of: "[A-Z]", options: .regularExpression) {
            return String(description[range])
        }
        return "⌘"
    }
    
    private var handsFreeDescription: String {
        // Prefer persisted display
        if !handsFreeShortcutDisplay.isEmpty { return handsFreeShortcutDisplay }
        // Otherwise reflect the actual configured shortcut from HotkeyManager, if present
        if let hf = hotkeyManager.handsFreeShortcut { return hf.description }
        // Safe fallback to avoid showing a letter from "Edit key"
        return "Right ⌘"
    }
    
    private var keyName: String {
        if let hf = hotkeyManager.handsFreeShortcut {
            return hf.description
        }
        return hotkeyManager.getCurrentShortcutDescription() ?? "⌘"
    }
}

// MARK: - Keycap View
struct KeycapView: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(DarkTheme.textPrimary)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(DarkTheme.textPrimary.opacity(0.2), lineWidth: 1)
                    )
            )
    }
}
struct ModePickerView: View {
    @Binding var mode: AquaStyleTryItContainer.Mode
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        Picker("", selection: $mode) {
            Text(localizationManager.localizedString("onboarding.tryit.push_to_talk")).tag(AquaStyleTryItContainer.Mode.pushToTalk)
            Text(localizationManager.localizedString("onboarding.tryit.hands_free")).tag(AquaStyleTryItContainer.Mode.handsFree)
        }
        .pickerStyle(.segmented)
        .frame(width: 260)
    }
}

// MARK: - Enhanced Instruction Step
struct EnhancedInstructionStep: View {
    let number: Int
    let text: String
    let delay: Double
    @State private var isVisible = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Step number
            ZStack {
                Circle()
                    .fill(DarkTheme.textPrimary.opacity(0.15))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Circle()
                            .stroke(DarkTheme.textPrimary.opacity(0.3), lineWidth: 1)
                    )
                
                Text("\(number)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(DarkTheme.textPrimary)
            }
            
            Text(text)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(DarkTheme.textPrimary.opacity(0.9))
        }
        .scaleEffect(isVisible ? 1.0 : 0.9)
        .opacity(isVisible ? 1.0 : 0.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay), value: isVisible)
        .onAppear {
            withAnimation {
                isVisible = true
            }
        }
    }
}

// MARK: - Enhanced Text Editor
struct EnhancedTextEditor: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool
    @State private var pulseScale: CGFloat = 1.0
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        VStack(spacing: 0) {
            // Mock app header
            HStack {
                HStack(spacing: 8) {
                    Circle()
                        .fill(.red)
                        .frame(width: 12, height: 12)
                    Circle()
                        .fill(.yellow)
                        .frame(width: 12, height: 12)
                    Circle()
                        .fill(.green)
                        .frame(width: 12, height: 12)
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(white: 0.08))
            
            // Text editing area
            ZStack {
                TextEditor(text: $text)
                    .font(.system(size: 18))
                    .focused($isFocused)
                    .scrollContentBackground(.hidden)
                    .scrollIndicators(.hidden)
                    .background(Color.clear)
                    .foregroundColor(DarkTheme.textPrimary)
                    .padding(20)
                
                // Placeholder when empty
                if text.isEmpty {
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(DarkTheme.textPrimary.opacity(0.1))
                                .frame(width: 60, height: 60)
                                .scaleEffect(pulseScale)
                                .animation(
                                    Animation.easeInOut(duration: 2.0)
                                        .repeatForever(autoreverses: true),
                                    value: pulseScale
                                )
                            
                            Image(systemName: "mic.fill")
                                .font(.system(size: 24))
                                .foregroundColor(DarkTheme.textPrimary.opacity(0.6))
                        }
                        
                        Text(localizationManager.localizedString("onboarding.tryit.placeholder"))
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(DarkTheme.textPrimary.opacity(0.5))
                    }
                    .allowsHitTesting(false)
                }
            }
            .background(Color(white: 0.03))
        }
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isFocused 
                        ? DarkTheme.textPrimary.opacity(0.3)
                        : DarkTheme.textPrimary.opacity(0.15),
                    lineWidth: 1
                )
        )
        .frame(width: 380, height: 520)
        .onAppear {
            pulseScale = 1.2
            isFocused = true
        }
    }
}

// MARK: - Right column visual-only panel for Try It
private struct TryItVisualPanel: View {
    @Binding var transcribedText: String
    var topInset: CGFloat = 80
    var bottomInset: CGFloat = 80
    @State private var animate = false
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .topLeading) {
                // Full-height, slightly darker than app background
                Rectangle()
                    .fill(Color.black.opacity(0.12))
                    .ignoresSafeArea()
                
                // Content column: explicit top and bottom insets
                VStack(spacing: 0) {
                    // TOP: instructional text bubble with independent top padding
                    HStack {
                        Text(localizationManager.localizedString("onboarding.tryit.click_field_instruction"))
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(DarkTheme.textPrimary)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .stroke(DarkTheme.textPrimary.opacity(0.12), lineWidth: 1)
                                    )
                            )
                        Spacer()
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, topInset)

                    Spacer(minLength: 0)

                    // BOTTOM: enhanced text editor with independent bottom padding
                    HStack {
                        Spacer()
                        EnhancedTextEditor(text: $transcribedText)
                            .transition(.scale.combined(with: .opacity))
                        Spacer()
                    }
                    .padding(.bottom, bottomInset)
                }
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .top)
            }
            .onAppear { animate = true }
        }
    }
}

// MARK: - Try It Background View
struct TryItBackgroundView: View {
    let mode: AquaStyleTryItContainer.Mode
    
    var body: some View {
        ZStack {
            switch mode {
            case .pushToTalk:
                BackgroundImageView(imageName: "ptt")
            case .handsFree:
                BackgroundImageView(imageName: "hf")
            case .command:
                CommandTryItBackgroundView()
            }
        }
        .ignoresSafeArea()
    }
}

// Reusable background so Primer and Try pages match exactly
private struct BackgroundImageView: View {
    let imageName: String
    var body: some View {
        Group {
            if let nsImage = loadBundleImage(named: imageName) {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .frame(minWidth: 1200, minHeight: 800)
                    .clipped()
            } else {
                Color.black
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Command Mode Background View
struct CommandTryItBackgroundView: View {
    var body: some View {
        ZStack {
            // Full-page background image for command mode
            if let nsImage = loadBundleImage(named: "command") {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .frame(minWidth: 1200, minHeight: 800)
                    .clipped()
            } else {
                Color.black
            }
            
            // Very subtle dark overlay for better text readability
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.4),
                    Color.black.opacity(0.1),
                    Color.black.opacity(0.3)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
    }
}

// MARK: - Local image loader accepting PNG/JPG
private func loadBundleImage(named: String) -> NSImage? {
    if let namedImg = NSImage(named: named) { return namedImg }
    let exts = ["png", "jpg", "jpeg"]
    for ext in exts {
        if let path = Bundle.main.path(forResource: named, ofType: ext),
           let img = NSImage(contentsOfFile: path) { return img }
    }
    return nil
}
