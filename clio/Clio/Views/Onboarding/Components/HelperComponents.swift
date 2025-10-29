import SwiftUI

// MARK: - Professional Button
struct ProfessionalButton: View {
    let title: String
    let action: () -> Void
    let disabled: Bool
    let isLoading: Bool
    
    init(title: String, action: @escaping () -> Void, disabled: Bool = false, isLoading: Bool = false) {
        self.title = title
        self.action = action
        self.disabled = disabled
        self.isLoading = isLoading
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(0.8)
                        .frame(width: 16, height: 16)
                } else {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                }
            }
            .foregroundColor(DarkTheme.textPrimary)
            .frame(width: 160, height: 44)
            .background(
                ZStack {
                    if disabled {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.thinMaterial)
                    } else {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.accentColor.opacity(0.8))
                        
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        DarkTheme.textPrimary.opacity(0.3),
                                        DarkTheme.textPrimary.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
                }
            )
        }
        .disabled(disabled || isLoading)
        .buttonStyle(.plain)
    }
}

// MARK: - Mock Desktop Environment
struct MockDesktopEnvironment: View {
    var body: some View {
        ZStack {
            // Desktop background
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "1A1A1A"),
                            Color(hex: "0F0F0F")
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // Chat window
            MockChatInterface()
                .offset(x: -50, y: -50)
        }
        .frame(width: 700, height: 500)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(white: 0.15), lineWidth: 2)
        )
        .shadow(
            color: .black.opacity(0.4),
            radius: 30,
            y: 15
        )
        .overlay(
            // macOS window controls
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
                Spacer()
            }
            .padding(16),
            alignment: .topLeading
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "2C2C2E"))
                .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
        )
    }
}

struct MockChatInterface: View {
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "message.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: "007AFF"))
                
                Text("Slack")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(DarkTheme.textPrimary)
                
                Spacer()
            }
            .padding(20)
            .background(Color(hex: "1C1C1E"))
            
            // Messages
            VStack(alignment: .leading, spacing: 16) {
                ChatMessage(
                    name: "Tobias",
                    message: "Hey Jetson, is Flow working for you?",
                    isUser: false
                )
                
                // Input field
                HStack {
                    Text("Hold down on the fn key and start speaking...")
                        .font(.system(size: 14))
                        .foregroundColor(Color(white: 0.4))
                    
                    Spacer()
                    
                    Image(systemName: "paperplane")
                        .font(.system(size: 16))
                        .foregroundColor(Color(white: 0.4))
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: "2C2C2E"))
                )
            }
            .padding(20)
            
            Spacer()
            
            // Dock
            HStack(spacing: 12) {
                ForEach(["Finder", "Slack", "Gmail", "notion", "ChatGPT"], id: \.self) { appName in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "2C2C2E"))
                        .frame(width: 48, height: 48)
                        .overlay(
                            Image(systemName: iconForApp(appName))
                                .font(.system(size: 24))
                                .foregroundColor(DarkTheme.textPrimary)
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color(hex: "1C1C1E").opacity(0.9))
            )
            .padding(.bottom, 20)
        }
        .frame(width: 600, height: 500)
        .background(Color(hex: "141414"))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(white: 0.1), lineWidth: 1)
        )
    }
    
    private func iconForApp(_ appName: String) -> String {
        switch appName {
        case "Finder": return "folder"
        case "Slack": return "message.fill"
        case "Gmail": return "envelope.fill"
        case "notion": return "doc.text.fill"
        case "ChatGPT": return "bubble.left.and.bubble.right.fill"
        default: return "app"
        }
    }
}

struct ChatMessage: View {
    let name: String
    let message: String
    let isUser: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if !isUser {
                Circle()
                    .fill(Color(hex: "007AFF"))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text(String(name.prefix(1)))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                if !isUser {
                    Text(name)
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
                            .fill(Color(hex: "2C2C2E"))
                    )
            }
            
            if isUser {
                Spacer()
            }
        }
    }
}

// MARK: - Whisper Model Size
enum WhisperModelSize: String {
    case tiny = "tiny"
    case base = "base"
    case small = "small"
    case medium = "medium"
    case large = "large"
}

// MARK: - View Model
class ProfessionalOnboardingViewModel: ObservableObject {
    enum Step: Int, CaseIterable {
        case auth
        case welcomeSource
        case languageSelection
        case permissions
        case trial
        case setup
        case tryIt
        
        var title: String {
            switch self {
            case .auth: return "ACCOUNT"
            case .welcomeSource: return "WELCOME"
            case .languageSelection: return "LANGUAGES"
            case .permissions: return "PERMISSIONS" 
            case .trial: return "TRIAL"
            case .setup: return "SET UP"
            case .tryIt: return "TRY IT"
            }
        }
    }
    
    enum Screen: String {
        case auth
        case welcomeSource
        case languageSelection
        case permissions
        case trial
        // New primer and try-it screens for each mode
        case primerPTT
        case tryItPTT
        case primerHF
        case tryItHF
        case primerCommand
        case tryItCommand
        // Personalization primer and walkthrough
        case vocabPrimer
        case vocabPlaceholder
        case setup
        case tryIt // legacy
    }
    
    private let storageKey = "Onboarding.CurrentScreen"
    
    @Published var currentScreen: Screen = .auth {
        didSet {
            UserDefaults.standard.set(currentScreen.rawValue, forKey: storageKey)
        }
    }
    
    init() {
        if let raw = UserDefaults.standard.string(forKey: storageKey),
           let restored = Screen(rawValue: raw) {
            // Migrate deprecated onboarding screens (PTT/Command removed for now)
            switch restored {
            case .welcomeSource:
                currentScreen = .languageSelection
            case .primerPTT, .tryItPTT:
                currentScreen = .primerHF
            case .primerCommand, .tryItCommand:
                currentScreen = .vocabPrimer
            default:
                currentScreen = restored
            }
        }
    }
    
    var currentStep: Step {
        switch currentScreen {
        case .auth: return .auth
        case .welcomeSource: return .welcomeSource
        case .languageSelection: return .languageSelection
        case .permissions: return .permissions
        case .trial, .primerPTT, .tryItPTT, .primerHF, .tryItHF, .primerCommand, .tryItCommand, .vocabPrimer, .vocabPlaceholder: return .trial
        case .setup: return .setup
        case .tryIt: return .tryIt
        }
    }
    
    func nextScreen() {
        switch currentScreen {
        case .auth:
            // Skip Welcome Source; go straight to language selection
            currentScreen = .languageSelection
        case .welcomeSource:
            currentScreen = .languageSelection
        case .languageSelection:
            currentScreen = .permissions
        case .permissions:
            currentScreen = .trial
        case .trial:
            // Skip PTT; go straight to Hands‑Free primer
            currentScreen = .primerHF
        case .primerPTT:
            // Deprecated in current flow: fall through to Hands‑Free
            currentScreen = .primerHF
        case .tryItPTT:
            // Deprecated in current flow: continue with Hands‑Free
            currentScreen = .primerHF
        case .primerHF:
            currentScreen = .tryItHF
        case .tryItHF:
            // Skip Command; proceed to personalization
            currentScreen = .vocabPrimer
        case .primerCommand:
            // Deprecated in current flow: proceed to personalization
            currentScreen = .vocabPrimer
        case .tryItCommand:
            // Deprecated in current flow: proceed to personalization
            currentScreen = .vocabPrimer
        case .vocabPrimer:
            currentScreen = .vocabPlaceholder
        case .vocabPlaceholder:
            currentScreen = .setup // continue to setup/finish
        case .setup:
            currentScreen = .tryIt
        case .tryIt:
            break
        }
    }
    
    func previousScreen() {
        switch currentScreen {
        case .auth:
            break
        case .welcomeSource:
            currentScreen = .auth
        case .languageSelection:
            // With Welcome Source removed, go back to auth
            currentScreen = .auth
        case .permissions:
            currentScreen = .languageSelection
        case .trial:
            currentScreen = .permissions
        case .primerPTT:
            currentScreen = .trial
        case .tryItPTT:
            currentScreen = .primerPTT
        case .primerHF:
            // Since PTT is skipped, go back to trial
            currentScreen = .trial
        case .tryItHF:
            currentScreen = .primerHF
        case .primerCommand:
            // Command is skipped; treat as end of HF section
            currentScreen = .tryItHF
        case .tryItCommand:
            // Command is skipped; go back to HF try‑it
            currentScreen = .tryItHF
        case .vocabPrimer:
            // With Command skipped, return to HF try‑it
            currentScreen = .tryItHF
        case .vocabPlaceholder:
            currentScreen = .vocabPrimer
        case .setup:
            currentScreen = .vocabPlaceholder
        case .tryIt:
            currentScreen = .trial
        }
    }
}
