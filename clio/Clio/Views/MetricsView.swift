import SwiftUI
import SwiftData
import Charts
import KeyboardShortcuts

struct MetricsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Transcription.timestamp) private var transcriptions: [Transcription]
    @EnvironmentObject private var whisperState: WhisperState
    @EnvironmentObject private var hotkeyManager: HotkeyManager
    @ObservedObject private var licenseViewModel = LicenseViewModel.shared
    @State private var hasLoadedData = false
    let skipSetupCheck: Bool
    
    init(skipSetupCheck: Bool = false) {
        self.skipSetupCheck = skipSetupCheck
    }
    
    var body: some View {
        VStack {
            // Trial Message
            if case .trial(let daysRemaining) = licenseViewModel.licenseState {
                TrialMessageView(
                    message: "You have \(daysRemaining) days left in your trial",
                    type: daysRemaining <= 2 ? .warning : .info
                )
                .padding()
            } else if case .trialExpired = licenseViewModel.licenseState {
                TrialMessageView(
                    message: "Your trial has expired. Upgrade to continue using Io",
                    type: .expired
                )
                .padding()
            }
            
            Group {
                if skipSetupCheck {
                    MetricsContent(transcriptions: Array(transcriptions))
                } else if isSetupComplete {
                    MetricsContent(transcriptions: Array(transcriptions))
                } else {
                    MetricsSetupView()
                }
            }
        }
        .background(Color(.controlBackgroundColor))
        .task {
            // Ensure the model context is ready
            hasLoadedData = true
        }
    }
    
    private var isSetupComplete: Bool {
        hasLoadedData &&
        whisperState.currentModel != nil &&
        KeyboardShortcuts.getShortcut(for: .toggleMiniRecorder) != nil &&
        AXIsProcessTrusted() &&
        CGPreflightScreenCaptureAccess()
    }
}
