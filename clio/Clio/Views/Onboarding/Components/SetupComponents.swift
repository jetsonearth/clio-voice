import SwiftUI

// MARK: - Setup View
struct ProfessionalSetupView: View {
    @ObservedObject var viewModel: ProfessionalOnboardingViewModel
    @EnvironmentObject private var hotkeyManager: HotkeyManager
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var selectedKey: HotkeyManager.PushToTalkKey = .fn
    @State private var selectedModel: WhisperModelSize = .base
    
    enum SetupStep {
        case keyboard
        case microphone
        case model
        case complete
    }
    
    @State private var currentSetupStep: SetupStep = .keyboard
    
    var body: some View {
        VStack(spacing: 0) {
            // Back button
            HStack {
                Button(action: {
                    if currentSetupStep == .keyboard {
                        viewModel.previousScreen()
                    } else {
                        // Go to previous setup step
                        switch currentSetupStep {
                        case .microphone:
                            currentSetupStep = .keyboard
                        case .model:
                            currentSetupStep = .microphone
                        case .complete:
                            currentSetupStep = .model
                        default:
                            break
                        }
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14))
                        Text(localizationManager.localizedString("onboarding.setup.back"))
                            .font(.system(size: 14))
                    }
                    .foregroundColor(Color(white: 0.6))
                }
                Spacer()
            }
            .padding(.horizontal, 60)
            .padding(.top, 40)
            
            // Content
            Group {
                switch currentSetupStep {
                case .keyboard:
                    KeyboardSetupView(
                        selectedKey: $selectedKey,
                        onContinue: {
                            hotkeyManager.pushToTalkKey = selectedKey
                            currentSetupStep = .microphone
                        }
                    )
                case .microphone:
                    MicrophoneSetupView(
                        onContinue: {
                            currentSetupStep = .model
                        }
                    )
                case .model:
                    ModelSetupView(
                        selectedModel: $selectedModel,
                        onContinue: {
                            currentSetupStep = .complete
                        }
                    )
                case .complete:
                    SetupCompleteView(
                        onContinue: {
                            viewModel.nextScreen()
                        }
                    )
                }
            }
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentSetupStep)
        }
    }
}

// MARK: - Keyboard Setup View
struct KeyboardSetupView: View {
    @Binding var selectedKey: HotkeyManager.PushToTalkKey
    let onContinue: () -> Void
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        VStack(spacing: 60) {
            VStack(spacing: 20) {
                Text(localizationManager.localizedString("onboarding.setup.keyboard.title"))
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(DarkTheme.textPrimary)
                
                Text(localizationManager.localizedString("onboarding.setup.keyboard.description"))
                    .font(.system(size: 16))
                    .foregroundColor(Color(white: 0.6))
            }
            .multilineTextAlignment(.center)
            
            // Key selection
            VStack(spacing: 24) {
                HStack(spacing: 16) {
                    KeyOptionButton(
                        key: .fn,
                        isSelected: selectedKey == .fn,
                        isRecommended: true,
                        action: { selectedKey = .fn }
                    )
                    
                    KeyOptionButton(
                        key: .rightCommand,
                        isSelected: selectedKey == .rightCommand,
                        isRecommended: false,
                        action: { selectedKey = .rightCommand }
                    )
                    
                    KeyOptionButton(
                        key: .rightOption,
                        isSelected: selectedKey == .rightOption,
                        isRecommended: false,
                        action: { selectedKey = .rightOption }
                    )
                }
                
                HStack(spacing: 16) {
                    KeyOptionButton(
                        key: .leftControl,
                        isSelected: selectedKey == .leftControl,
                        isRecommended: false,
                        action: { selectedKey = .leftControl }
                    )
                    
                    KeyOptionButton(
                        key: .rightShift,
                        isSelected: selectedKey == .rightShift,
                        isRecommended: false,
                        action: { selectedKey = .rightShift }
                    )
                }
            }
            
            // Spacer()
            
            ProfessionalButton(
                title: localizationManager.localizedString("onboarding.setup.continue"),
                action: onContinue
            )
        }
        .padding(.horizontal, 120)
        .padding(.vertical, 60)
    }
}

// MARK: - Key Option Button
struct KeyOptionButton: View {
    let key: HotkeyManager.PushToTalkKey
    let isSelected: Bool
    let isRecommended: Bool
    let action: () -> Void
    
    private var keySymbol: String {
        switch key {
        case .rightOption, .leftOption: return "⌥"
        case .leftControl, .rightControl: return "⌃"
        case .fn: return "fn"
        case .rightCommand, .leftCommand: return "⌘"
        case .rightShift, .leftShift: return "⇧"
        }
    }
    
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    private var keyName: String {
        switch key {
        case .rightOption: return localizationManager.localizedString("onboarding.setup.keyboard.right_option")
        case .leftOption: return localizationManager.localizedString("onboarding.setup.keyboard.left_option")
        case .leftControl: return localizationManager.localizedString("onboarding.setup.keyboard.left_control")
        case .rightControl: return localizationManager.localizedString("onboarding.setup.keyboard.right_control")
        case .fn: return localizationManager.localizedString("onboarding.setup.keyboard.function")
        case .rightCommand: return localizationManager.localizedString("onboarding.setup.keyboard.right_command")
        case .leftCommand: return localizationManager.localizedString("onboarding.setup.keyboard.left_command")
        case .rightShift: return localizationManager.localizedString("onboarding.setup.keyboard.right_shift")
        case .leftShift: return localizationManager.localizedString("onboarding.setup.keyboard.left_shift")
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack(alignment: .topTrailing) {
                    // Key visual
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(isSelected ? Color(hex: "007AFF").opacity(0.15) : Color(hex: "1C1C1E"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(isSelected ? Color(hex: "007AFF") : Color(white: 0.15), lineWidth: 2)
                            )
                            .frame(width: 120, height: 80)
                        
                        Text(keySymbol)
                            .font(.system(size: 32, weight: .medium))
                            .foregroundColor(isSelected ? Color(hex: "007AFF") : .white)
                    }
                    
                    // Recommended badge
                    if isRecommended {
                        Text(localizationManager.localizedString("onboarding.setup.recommended"))
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color(hex: "007AFF"))
                            )
                            .offset(x: 8, y: -8)
                    }
                }
                
                Text(keyName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? Color(hex: "007AFF") : Color(white: 0.8))
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Microphone Setup View
struct MicrophoneSetupView: View {
    let onContinue: () -> Void
    @State private var audioLevel: Double = 0.0
    @State private var isListening = false
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var body: some View {
        VStack(spacing: 60) {
            VStack(spacing: 20) {
                Text(localizationManager.localizedString("onboarding.setup.microphone.title"))
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(DarkTheme.textPrimary)
                
                Text(localizationManager.localizedString("onboarding.setup.microphone.description"))
                    .font(.system(size: 16))
                    .foregroundColor(Color(white: 0.6))
            }
            .multilineTextAlignment(.center)
            
            // Audio level visualization
            VStack(spacing: 40) {
                ZStack {
                    Circle()
                        .stroke(Color(white: 0.2), lineWidth: 4)
                        .frame(width: 200, height: 200)
                    
                    Circle()
                        .fill(Color(hex: "007AFF").opacity(0.3))
                        .frame(width: 180 * (0.5 + audioLevel * 0.5), height: 180 * (0.5 + audioLevel * 0.5))
                        .animation(.easeInOut(duration: 0.1), value: audioLevel)
                    
                    Image(systemName: "mic.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Color(hex: "007AFF"))
                }
                
                Text(isListening ? localizationManager.localizedString("onboarding.setup.microphone.speak_now") : localizationManager.localizedString("onboarding.setup.microphone.tap_to_test"))
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(DarkTheme.textSecondary)
                
                Button(action: {
                    isListening.toggle()
                    // Simulate audio level for demo
                    if isListening {
                        simulateAudioLevel()
                    }
                }) {
                    Text(isListening ? localizationManager.localizedString("onboarding.setup.microphone.stop") : localizationManager.localizedString("onboarding.setup.microphone.test_microphone"))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(DarkTheme.textPrimary)
                        .frame(width: 160, height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(hex: "007AFF").opacity(0.8))
                        )
                }
                .buttonStyle(.plain)
            }
            
            // Spacer()
            
            ProfessionalButton(
                title: localizationManager.localizedString("onboarding.setup.continue"),
                action: onContinue
            )
        }
        .padding(.horizontal, 120)
        .padding(.vertical, 60)
    }
    
    private func simulateAudioLevel() {
        guard isListening else { return }
        
        audioLevel = Double.random(in: 0.0...1.0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            simulateAudioLevel()
        }
    }
}

// MARK: - Model Setup View
struct ModelSetupView: View {
    @Binding var selectedModel: WhisperModelSize
    let onContinue: () -> Void
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    private let models: [(WhisperModelSize, String, String, String)] = [
        (.tiny, "Tiny", "39 MB", "Fast, basic accuracy"),
        (.base, "Base", "74 MB", "Good balance of speed and accuracy"),
        (.small, "Small", "244 MB", "Better accuracy, slower"),
        (.medium, "Medium", "769 MB", "High accuracy"),
        (.large, "Large", "1550 MB", "Best accuracy, requires more resources")
    ]
    
    var body: some View {
        VStack(spacing: 40) {
            VStack(spacing: 20) {
                Text(localizationManager.localizedString("onboarding.setup.model.title"))
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(DarkTheme.textPrimary)
                
                Text(localizationManager.localizedString("onboarding.setup.model.description"))
                    .font(.system(size: 16))
                    .foregroundColor(Color(white: 0.6))
            }
            .multilineTextAlignment(.center)
            
            // Model selection
            VStack(spacing: 12) {
                ForEach(models, id: \.0) { model in
                    ModelOptionCard(
                        model: model.0,
                        title: model.1,
                        size: model.2,
                        description: model.3,
                        isSelected: selectedModel == model.0,
                        isRecommended: model.0 == .base,
                        action: { selectedModel = model.0 }
                    )
                }
            }
            
            // Spacer()
            
            ProfessionalButton(
                title: localizationManager.localizedString("onboarding.setup.model.download_continue"),
                action: onContinue
            )
        }
        .padding(.horizontal, 60)
        .padding(.vertical, 60)
    }
}

// MARK: - Model Option Card
struct ModelOptionCard: View {
    let model: WhisperModelSize
    let title: String
    let size: String
    let description: String
    let isSelected: Bool
    let isRecommended: Bool
    let action: () -> Void
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                // Selection indicator
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color(hex: "007AFF") : Color(white: 0.3), lineWidth: 2)
                        .frame(width: 20, height: 20)
                    
                    if isSelected {
                        Circle()
                            .fill(Color(hex: "007AFF"))
                            .frame(width: 12, height: 12)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(title)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(DarkTheme.textPrimary)
                        
                        Text(size)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(DarkTheme.textSecondary)
                        
                        if isRecommended {
                            Text(localizationManager.localizedString("onboarding.setup.recommended"))
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(Color(hex: "007AFF"))
                                )
                        }
                        
                        Spacer()
                    }
                    
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(DarkTheme.textSecondary)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "1C1C1E"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color(hex: "007AFF") : Color(white: 0.1), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Setup Complete View
struct SetupCompleteView: View {
    let onContinue: () -> Void
    @State private var isAnimating = false
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        VStack(spacing: 60) {
            Spacer()
            
            VStack(spacing: 40) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "007AFF").opacity(0.2))
                        .frame(width: 120, height: 120)
                        .scaleEffect(isAnimating ? 1.2 : 1.0)
                        .opacity(isAnimating ? 0.0 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 2.0)
                                .repeatForever(autoreverses: false),
                            value: isAnimating
                        )
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Color(hex: "007AFF"))
                        .scaleEffect(isAnimating ? 1.0 : 0.5)
                        .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.3), value: isAnimating)
                }
                
                VStack(spacing: 16) {
                    Text(localizationManager.localizedString("onboarding.setup.complete.title"))
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(DarkTheme.textPrimary)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.8).delay(0.6), value: isAnimating)
                    
                    Text(localizationManager.localizedString("onboarding.setup.complete.description"))
                        .font(.system(size: 18))
                        .foregroundColor(DarkTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.8).delay(0.8), value: isAnimating)
                }
            }
            
            // Spacer()
            
            ProfessionalButton(
                title: localizationManager.localizedString("onboarding.setup.complete.try_it_out"),
                action: onContinue
            )
            .opacity(isAnimating ? 1.0 : 0.0)
            .animation(.easeInOut(duration: 0.6).delay(1.0), value: isAnimating)
        }
        .padding(.horizontal, 120)
        .padding(.vertical, 60)
        .onAppear {
            isAnimating = true
        }
    }
}
