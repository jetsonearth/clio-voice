import SwiftUI
import AppKit

struct MenuBarView: View {
    @EnvironmentObject var recordingEngine: RecordingEngine
    @EnvironmentObject private var localizationManager: LocalizationManager
    @EnvironmentObject private var enhancementService: AIEnhancementService
    @State private var showFeedbackWindow = false

    private var appVersionString: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        return version
    }
    
    var body: some View {
        VStack(spacing: 4) {
            // Settings (activates app and routes)
            Button(localizationManager.localizedString("general.settings")) {
                NotificationCenter.default.post(name: .navigateToDestination, object: nil, userInfo: ["destination": "Settings"])
            }
            
            // AI Enhancement Toggle (commented out - moved to separate enhancement prompts page)
            /*
            Button(action: {
                enhancementService.isEnhancementEnabled.toggle()
            }) {
                HStack {
                    Image(systemName: enhancementService.isEnhancementEnabled ? "checkmark.square" : "square")
                        .foregroundColor(enhancementService.isEnhancementEnabled ? .blue : .primary)
                    Text(localizationManager.localizedString("settings.ai_enhancement"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .buttonStyle(.plain)
            
            Divider()
            */
            
            // Audio & Language Configuration Group
            LanguageSelectionView(
                recordingEngine: recordingEngine, 
                displayMode: .menuItem, 
                whisperPrompt: recordingEngine.whisperPrompt
            )
            
            MicrophoneSelectionView()
            
            Divider()
            
            // Dictionary
            Button(localizationManager.localizedString("menu.add_word_to_dictionary")) {
                NotificationCenter.default.post(name: .navigateToDestination, object: nil, userInfo: ["destination": "Dictionary"])
            }

            Divider()

            // Version
            Text("\(localizationManager.localizedString("menu.version")): \(appVersionString)")
                .foregroundColor(.secondary)

            // Share Feedback (in-app modal)
            Button(localizationManager.localizedString("menu.share_feedback")) {
                NotificationCenter.default.post(name: .showFeedbackModal, object: nil)
            }
            
            Divider()
            
            // Quit
            Button(localizationManager.localizedString("menu.quit")) {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding(.vertical, 4)
        .onAppear { print("✅ [MENUBAR] MenuBarView appeared") }
        .onDisappear { print("🚫 [MENUBAR] MenuBarView disappeared") }
    }
}
