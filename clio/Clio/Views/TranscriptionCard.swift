import SwiftUI
import SwiftData
import AVFoundation

// MARK: - Code Highlighted Text Component
struct CodeHighlightedText: View {
    let text: String
    
    // Cache the attributed string to avoid expensive regex recalculation
    @State private var cachedAttributedString: AttributedString?
    @State private var lastProcessedText: String = ""
    
    // Shared regex for better performance
    private static let codeRegex: NSRegularExpression? = {
        try? NSRegularExpression(pattern: "`([^`]+)`")
    }()
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        Text(getAttributedString())
            .lineSpacing(6)
    }
    
    private func getAttributedString() -> AttributedString {
        // Return cached result if text hasn't changed
        if text == lastProcessedText, let cached = cachedAttributedString {
            return cached
        }
        
        // Create new attributed string and cache it
        let result = createAttributedString()
        cachedAttributedString = result
        lastProcessedText = text
        return result
    }
    
    private func createAttributedString() -> AttributedString {
        var attributedString = AttributedString()
        
        guard let regex = Self.codeRegex else {
            var fallback = AttributedString(text)
            fallback.font = .system(size: 12, weight: .regular, design: .default)
            fallback.foregroundColor = Color(DarkTheme.textPrimary)
            return fallback
        }
        
        let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
        var lastEnd = text.startIndex
        
        // If no matches, return regular text
        if matches.isEmpty {
            var result = AttributedString(text)
            result.font = .system(size: 12.5, weight: .regular, design: .default)
            result.foregroundColor = Color(DarkTheme.textPrimary)
            return result
        }
        
        for match in matches {
            // Add text before the code block
            let beforeStart = lastEnd
            let beforeEnd = text.index(text.startIndex, offsetBy: match.range.location)
            
            if beforeStart < beforeEnd {
                let beforeText = String(text[beforeStart..<beforeEnd])
                var beforeAttributed = AttributedString(beforeText)
                beforeAttributed.font = .system(size: 12.5, weight: .regular, design: .default)
                beforeAttributed.foregroundColor = Color(DarkTheme.textPrimary)
                attributedString += beforeAttributed
            }
            
            // Add the code content (without backticks)
            if let codeRange = Range(match.range(at: 1), in: text) {
                let codeText = String(text[codeRange])
                var codeAttributed = AttributedString(codeText)
                codeAttributed.font = .system(size: 12, weight: .medium, design: .monospaced)
                codeAttributed.foregroundColor = Color(DarkTheme.accent)
                codeAttributed.backgroundColor = Color(DarkTheme.accent.opacity(0.15))
                attributedString += codeAttributed
            }
            
            lastEnd = text.index(text.startIndex, offsetBy: match.range.location + match.range.length)
        }
        
        // Add remaining text after the last match
        if lastEnd < text.endIndex {
            let remainingText = String(text[lastEnd...])
            var remainingAttributed = AttributedString(remainingText)
                remainingAttributed.font = .system(size: 12.5, weight: .regular, design: .default)
            remainingAttributed.foregroundColor = Color(DarkTheme.textPrimary)
            attributedString += remainingAttributed
        }
        
        return attributedString
    }
}

struct TranscriptionCard: View {
    let transcription: Transcription
    let onDelete: () -> Void
    let onReTranscribe: () -> Void
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var audioPlayerManager: AudioPlayerManager? = nil
    @State private var isCopied = false
    
    // Helper function to play audio in-app
    private func playAudio(url: URL) {
        if audioPlayerManager == nil {
            audioPlayerManager = AudioPlayerManager()
        }
        guard let manager = audioPlayerManager else { return }
        if manager.isPlaying {
            manager.pause()
        } else {
            manager.loadAudio(from: url)
            manager.play()
        }
    }
    
    // Helper function to copy text with visual feedback
    private func copyText() {
        let textToCopy = transcription.enhancedText ?? transcription.text
        let _ = ClipboardManager.copyToClipboard(textToCopy)
        withAnimation {
            isCopied = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                isCopied = false
            }
        }
    }
    
    // Inline action buttons
    private var inlineActionButtons: some View {
        HStack(spacing: 6) {
            // Play audio button (only if audio file exists)
            if let urlString = transcription.audioFileURL,
               let url = URL(string: urlString),
               FileManager.default.fileExists(atPath: url.path) {
                Button(action: {
                    playAudio(url: url)
                }) {
                    Image(systemName: audioPlayerManager?.isPlaying == true ? "pause.circle" : "play.circle")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(DarkTheme.textSecondary)
                        .contentTransition(.symbolEffect(.replace.downUp))
                }
                .buttonStyle(.plain)
                .help("Play Audio")
            }
            
            // Copy button
            Button(action: {
                copyText()
            }) {
                Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isCopied ? .green : DarkTheme.textSecondary)
                    .scaleEffect(isCopied ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isCopied)
            }
            .buttonStyle(.plain)
            .help(localizationManager.localizedString("transcription.copy"))
            
            // Show in folder button (only if audio file exists)
            if let urlString = transcription.audioFileURL,
               let url = URL(string: urlString),
               FileManager.default.fileExists(atPath: url.path) {
                Button(action: {
                    NSWorkspace.shared.activateFileViewerSelecting([url])
                }) {
                    Image(systemName: "folder")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(DarkTheme.textSecondary)
                }
                .buttonStyle(.plain)
                .help("Show in Folder")
            }
            
            // Re-transcribe button
            Button(action: {
                onReTranscribe()
            }) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(DarkTheme.textSecondary)
            }
            .buttonStyle(.plain)
            .help("Re-transcribe")
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
                // Timeline-style header with inline actions
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        // Only show time in 12-hour format
                        Text(transcription.timestamp, formatter: timeFormatter)
                            .font(.system(size: 14, weight: .medium, design: .default))
                            .foregroundColor(DarkTheme.textSecondary)
                        
                        Spacer()
                        
                        // Metrics and Actions in a compact layout
                        HStack(spacing: 8) {
                            // Duration badge
                            Text(formatDuration(transcription.duration))
                                .font(.system(size: 11, weight: .medium, design: .monospaced))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(
                                    Capsule()
                                        .fill(DarkTheme.accent.opacity(0.15))
                                )
                                .foregroundColor(DarkTheme.accent)
                            
                            // Total Latency badge (if available)
                            // let totalLatency = (transcription.processingLatencyMs ?? 0) + (transcription.llmLatencyMs ?? 0)
                            // if totalLatency > 0 {
                            //     Text("\(String(format: "%.0f", totalLatency))ms")
                            //         .font(.system(size: 11, weight: .medium, design: .monospaced))
                            //         .padding(.horizontal, 8)
                            //         .padding(.vertical, 3)
                            //         .background(
                            //             Capsule()
                            //                 .fill(DarkTheme.accent.opacity(0.15))
                            //         )
                            //         .foregroundColor(DarkTheme.accent)
                            //         .help(String(format: localizationManager.localizedString("transcription.total_latency_help"), String(format: "%.0f", totalLatency)))
                            // }
                            
                            // Action buttons
                            inlineActionButtons
                        }
                    }
                }
                
                // Main content section - always visible
                VStack(alignment: .leading, spacing: 13) {
                    // Show enhanced text if available, otherwise show original
                    CodeHighlightedText(transcription.enhancedText ?? transcription.text)
                }
            }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(NSColor.windowBackgroundColor).opacity(0.85))
        )
        // Light outline only – much cheaper than multi-stroke & blur
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.06), lineWidth: 0.5)
        )
        .onTapGesture {
            copyText()
        }
        .scaleEffect(isCopied ? 1.02 : 1.0)
        .drawingGroup()
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isCopied)
        .contextMenu {
            if let enhancedText = transcription.enhancedText {
                Button {
                    let _ = ClipboardManager.copyToClipboard(enhancedText)
                } label: {
                    Label(localizationManager.localizedString("transcription.copy_enhanced"), systemImage: "doc.on.doc")
                }
            }
            
            Button {
                let _ = ClipboardManager.copyToClipboard(transcription.text)
            } label: {
                Label(localizationManager.localizedString("transcription.copy_original"), systemImage: "doc.on.doc")
            }
            
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label(localizationManager.localizedString("general.delete"), systemImage: "trash")
            }
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"  // Force 12-hour format with AM/PM
        formatter.locale = Locale(identifier: "en_US")  // Use US locale for consistent 12-hour format
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter
    }
}

//// MARK: - Preview
//#Preview("Code Highlighting") {
//    VStack(spacing: 20) {
//        CodeHighlightedText("Here's some regular text with `const data = await groqResponse.json()` and more text.")
//        
//        CodeHighlightedText("Multiple code snippets: `await response.json()` and `fetch('/api/data')` in the same line.")
//        
//        CodeHighlightedText("This is a paragraph with some `inline code` that should be highlighted with a background color and monospace font.")
//        
//        CodeHighlightedText("No code snippets here, just regular text to ensure it displays normally.")
//    }
//    .padding()
//    .background(DarkTheme.background)
//}
