import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import AVFoundation

struct AudioTranscribeView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var recordingEngine: RecordingEngine
    @EnvironmentObject private var localizationManager: LocalizationManager
    @StateObject private var transcriptionManager = AudioTranscriptionManager.shared
    @State private var isDropTargeted = false
    @State private var selectedAudioURL: URL?
    @State private var isAudioFileSelected = false
    @State private var isEnhancementEnabled = false
    @State private var selectedPromptId: UUID?
    
    var body: some View {
        VStack(spacing: 0) {
            if transcriptionManager.isProcessing {
                processingView
            } else {
                dropZoneView
            }
            
            Divider()
                .padding(.vertical)
            
            // Show current transcription result
            if let transcription = transcriptionManager.currentTranscription {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(localizationManager.localizedString("audio_transcribe.transcription_result"))
                            .font(.headline)
                        
                        if let enhancedText = transcription.enhancedText {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(localizationManager.localizedString("audio_transcribe.enhanced"))
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    HStack(spacing: 8) {
                                        AnimatedCopyButton(textToCopy: enhancedText)
                                        AnimatedSaveButton(textToSave: enhancedText)
                                    }
                                }
                                Text(enhancedText)
                                    .textSelection(.enabled)
                            }
                            
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(localizationManager.localizedString("audio_transcribe.original"))
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    HStack(spacing: 8) {
                                        AnimatedCopyButton(textToCopy: transcription.text)
                                        AnimatedSaveButton(textToSave: transcription.text)
                                    }
                                }
                                Text(transcription.text)
                                    .textSelection(.enabled)
                            }
                        } else {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(localizationManager.localizedString("audio_transcribe.transcription"))
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    HStack(spacing: 8) {
                                        AnimatedCopyButton(textToCopy: transcription.text)
                                        AnimatedSaveButton(textToSave: transcription.text)
                                    }
                                }
                                Text(transcription.text)
                                    .textSelection(.enabled)
                            }
                        }
                        
                        HStack {
                            Text(String(format: localizationManager.localizedString("audio_transcribe.duration"), formatDuration(transcription.duration)))
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                    }
                    .padding()
                }
            }
        }
        .alert(localizationManager.localizedString("common.error"), isPresented: .constant(transcriptionManager.errorMessage != nil)) {
            Button(localizationManager.localizedString("common.ok"), role: .cancel) {
                transcriptionManager.errorMessage = nil
            }
        } message: {
            if let errorMessage = transcriptionManager.errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    private var dropZoneView: some View {
        VStack(spacing: 16) {
            if isAudioFileSelected {
                VStack(spacing: 16) {
                    Text(String(format: localizationManager.localizedString("audio_transcribe.audio_file_selected"), selectedAudioURL?.lastPathComponent ?? ""))
                        .font(.headline)
                    
                    // AI Enhancement Settings
                    if let enhancementService = recordingEngine.getEnhancementService() {
                        VStack(spacing: 16) {
                            // AI Enhancement and Prompt in the same row
                            HStack(spacing: 16) {
                                Toggle(localizationManager.localizedString("audio_transcribe.ai_enhancement"), isOn: $isEnhancementEnabled)
                                    .toggleStyle(.switch)
                                    .onChange(of: isEnhancementEnabled) { oldValue, newValue in
                                        enhancementService.isEnhancementEnabled = newValue
                                    }
                                
                                if isEnhancementEnabled {
                                    Divider()
                                        .frame(height: 20)
                                    
                                    // Prompt Selection
                                    HStack(spacing: 8) {
                                        Text(localizationManager.localizedString("audio_transcribe.prompt"))
                                            .font(.subheadline)
                                        
                                        Menu {
                                            ForEach(enhancementService.allPrompts) { prompt in
                                                Button {
                                                    enhancementService.setActivePrompt(prompt)
                                                    selectedPromptId = prompt.id
                                                } label: {
                                                    HStack {
                                                        Image(systemName: prompt.icon.rawValue)
                                                            .foregroundColor(.accentColor)
                                                        Text(prompt.title)
                                                        if selectedPromptId == prompt.id {
                                                            Spacer()
                                                            Image(systemName: "checkmark")
                                                        }
                                                    }
                                                }
                                            }
                                        } label: {
                                            HStack {
                                                Text(enhancementService.allPrompts.first(where: { $0.id == selectedPromptId })?.title ?? localizationManager.localizedString("audio_transcribe.select_prompt"))
                                                    .foregroundColor(.primary)
                                                Image(systemName: "chevron.down")
                                                    .font(.caption)
                                            }
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .fill(Color(.controlBackgroundColor))
                                            )
                                        }
                                        .fixedSize()
                                        .disabled(!isEnhancementEnabled)
                                    }
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.windowBackgroundColor).opacity(0.4))
                            )
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .onAppear {
                            // Initialize local state from enhancement service
                            isEnhancementEnabled = enhancementService.isEnhancementEnabled
                            selectedPromptId = enhancementService.selectedPromptId
                        }
                    }
                    
                    // Action Buttons in a row
                    HStack(spacing: 12) {
                        Button(localizationManager.localizedString("audio_transcribe.start_transcription")) {
                            if let url = selectedAudioURL {
                                transcriptionManager.startProcessing(
                                    url: url,
                                    modelContext: modelContext,
                                    recordingEngine: recordingEngine
                                )
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button(localizationManager.localizedString("audio_transcribe.choose_different_file")) {
                            selectedAudioURL = nil
                            isAudioFileSelected = false
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding()
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.windowBackgroundColor).opacity(0.4))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(
                                    style: StrokeStyle(
                                        lineWidth: 2,
                                        dash: [8]
                                    )
                                )
                                .foregroundColor(isDropTargeted ? Color.accentColor : .gray.opacity(0.5))
                        )
                    
                    VStack(spacing: 16) {
                        Image(systemName: "arrow.down.doc")
                            .font(.system(size: 32))
                            .foregroundColor(isDropTargeted ? Color.accentColor : .gray)
                        
                        Text(localizationManager.localizedString("audio_transcribe.drop_audio_file"))
                            .font(.headline)
                        
                        Text(localizationManager.localizedString("audio_transcribe.or"))
                            .foregroundColor(.secondary)
                        
                        Button(localizationManager.localizedString("audio_transcribe.choose_file")) {
                            selectFile()
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(32)
                }
                .frame(height: 200)
                .padding(.horizontal)
            }
            
            Text(localizationManager.localizedString("audio_transcribe.supported_formats"))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .onDrop(of: [.audio, .fileURL], isTargeted: $isDropTargeted) { providers in
            Task {
                await handleDroppedFile(providers)
            }
            return true
        }
    }
    
    private var processingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(0.8)
                .frame(width: 40, height: 40)
            Text(transcriptionManager.processingPhase.message)
                .font(.headline)
            Text(transcriptionManager.messageLog)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private func selectFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [
            .audio,
            .wav,
            .mp3,
            .mpeg4Audio,
            .aiff
        ]
        
        if panel.runModal() == .OK {
            if let url = panel.url {
                selectedAudioURL = url
                isAudioFileSelected = true
            }
        }
    }
    
    private func handleDroppedFile(_ providers: [NSItemProvider]) async {
        guard let provider = providers.first else { return }
        
        if provider.hasItemConformingToTypeIdentifier(UTType.audio.identifier) {
            try? await provider.loadItem(forTypeIdentifier: UTType.audio.identifier) { item, error in
                if let url = item as? URL {
                    Task { @MainActor in
                        selectedAudioURL = url
                        isAudioFileSelected = true
                    }
                }
            }
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
} 
