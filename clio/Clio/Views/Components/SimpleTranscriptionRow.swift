import SwiftUI
import SwiftData
import AVFoundation

struct SimpleTranscriptionRow: View {
    let transcription: Transcription
    let onDelete: () -> Void
    let onReTranscribe: () -> Void
    var isRetranscribing: Bool = false
    
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var isHovered = false
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlayingAudio = false
    @State private var isExpanded = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Content with variable height
            VStack(alignment: .leading, spacing: 6) {
                // Top row with timestamp badge, duration badge, and actions
                HStack {
                    // Time of recording badge - subtle and transparent
                    Text(formatTime(transcription.timestamp))
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(Color.secondary.opacity(0.15))
                        )
                    
                    // Audio duration badge - subtle and transparent
                    Text(formatDuration(transcription.duration))
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(Color.accentColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(Color.accentColor.opacity(0.15))
                        )
                    
                    // Mode badge (Dictation / Command)
                    Text(transcription.isCommand ? "Command" : "Dictation")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(transcription.isCommand ? .orange : .secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill((transcription.isCommand ? Color.orange : Color.secondary).opacity(0.15))
                        )
                    
                    Spacer()
                    
                    // Actions (only visible on hover)
                    if isHovered {
                        HStack(spacing: 8) {
                            // Audio play button
                            if let audioURL = transcription.audioFileURL, !audioURL.isEmpty {
                                Button(action: {
                                    toggleAudioPlayback(audioURLString: audioURL)
                                }) {
                                    Image(systemName: isPlayingAudio ? "pause.circle" : "play.circle")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(DarkTheme.textSecondary)
                                }
                                .buttonStyle(.plain)
                                .help(isPlayingAudio ? "Pause Audio" : "Play Audio")
                            }
                            
                            // Folder button to show audio file location
                            Button(action: {
                                showAudioFileLocation()
                            }) {
                                Image(systemName: "folder")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(DarkTheme.textSecondary)
                            }
                            .buttonStyle(.plain)
                            .help("Show audio file location")
                            
                            // Copy button
                            Button(action: {
                                let text = transcription.enhancedText?.isEmpty == false ? transcription.enhancedText! : transcription.text
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString(text, forType: .string)
                            }) {
                                Image(systemName: "doc.on.doc")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(DarkTheme.textSecondary)
                            }
                            .buttonStyle(.plain)
                            .help("Copy")
                            
                            // Re-transcribe button
                            Button(action: onReTranscribe) {
                                Group {
                                    if isRetranscribing {
                                        ProgressView()
                                            .controlSize(.mini)
                                            .frame(width: 12, height: 12)
                                    } else {
                                        Image(systemName: "arrow.clockwise")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(DarkTheme.textSecondary)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                            .disabled(isRetranscribing)
                            .help("Re-transcribe")
                            
                            // Delete button
                            Button(action: onDelete) {
                                Image(systemName: "trash")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.red.opacity(0.8))
                            }
                            .buttonStyle(.plain)
                            .help("Delete")
                        }
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                    }
                }
                
                // Full transcript text or command output
                VStack(alignment: .leading, spacing: 8) {
                    Text(displayText)
                        .font(.system(size: 12.5, weight: .regular, design: .default))
                        .foregroundColor(DarkTheme.textPrimary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    if isExpanded, !transcription.text.isEmpty, transcription.enhancedText != nil {
                        Divider()
                        HStack {
                            Text("Original")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        Text(transcription.text)
                            .font(.system(size: 12.5, weight: .regular))
                            .foregroundColor(DarkTheme.textPrimary)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isHovered ? Color.white.opacity(0.02) : Color.clear)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            // Only expand when there's an enhanced version to compare against
            if transcription.enhancedText != nil {
                withAnimation(.easeInOut(duration: 0.15)) { isExpanded.toggle() }
            }
        }
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
        .onDisappear {
            audioPlayer?.stop()
            audioPlayer = nil
            isPlayingAudio = false
        }
        .contextMenu {
            Button(action: {
                // Copy to clipboard
                if let text = transcription.enhancedText?.isEmpty == false ? transcription.enhancedText : transcription.text {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(text, forType: .string)
                }
            }) {
                Label("Copy", systemImage: "doc.on.doc")
            }
            
            Divider()
            
            Button(action: onReTranscribe) {
                Label("Re-transcribe", systemImage: "arrow.clockwise")
            }
            
            Button(action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        
        if minutes > 0 {
            return String(format: "%d:%02d", minutes, seconds)
        } else {
            return String(format: "%ds", seconds)
        }
    }
    
    // Determine what to display for this row
    private var displayText: String {
        if transcription.isCommand {
            return transcription.commandOutput?.isEmpty == false ? transcription.commandOutput! : transcription.text
        } else {
            return transcription.enhancedText?.isEmpty == false ? transcription.enhancedText! : transcription.text
        }
    }
    
    private func showAudioFileLocation() {
        // Try to highlight the specific audio file if it exists
        if let audioURLString = transcription.audioFileURL,
           let audioURL = URL(string: audioURLString),
           FileManager.default.fileExists(atPath: audioURL.path) {
            // Highlight the specific file in Finder
            NSWorkspace.shared.activateFileViewerSelecting([audioURL])
        } else {
            // Fallback: open the recordings directory
            let recordingsDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("com.jetsonai.clio")
                .appendingPathComponent("Recordings")
            NSWorkspace.shared.open(recordingsDirectory)
        }
    }
    
    private func toggleAudioPlayback(audioURLString: String) {
        guard let audioURL = URL(string: audioURLString) else { return }
        
        if isPlayingAudio {
            // Stop current playback
            audioPlayer?.stop()
            audioPlayer = nil
            isPlayingAudio = false
        } else {
            // Start playback
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
                audioPlayer?.play()
                isPlayingAudio = true
                
                // Auto-stop when finished
                DispatchQueue.global(qos: .background).async {
                    while self.audioPlayer?.isPlaying == true {
                        Thread.sleep(forTimeInterval: 0.1)
                    }
                    DispatchQueue.main.async {
                        self.isPlayingAudio = false
                        self.audioPlayer = nil
                    }
                }
            } catch {
                print("Failed to play audio: \(error)")
            }
        }
    }
}