import SwiftUI
import UniformTypeIdentifiers

struct AnimatedSaveButton: View {
    let textToSave: String
    @State private var isSaved: Bool = false
    @State private var isPulsing: Bool = false
    
    var body: some View {
        Button(action: { saveFile(as: .plainText, extension: "txt") }) {
            HStack(spacing: 6) {
                Image(systemName: isSaved ? "checkmark.circle.fill" : "square.and.arrow.down")
                    .foregroundColor(isSaved ? DarkTheme.success : DarkTheme.textPrimary)
                    .scaleEffect(isPulsing ? 1.06 : 1.0)
                Text(isSaved ? "Saved" : "Save")
                    .foregroundColor(DarkTheme.textPrimary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(DarkTheme.textPrimary.opacity(0.08))
            )
        }
        .buttonStyle(.plain)
        .onChange(of: isSaved) { _, newValue in
            guard newValue else { return }
            withAnimation(.easeInOut(duration: 0.18)) { isPulsing = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                withAnimation(.easeInOut(duration: 0.18)) { isPulsing = false }
            }
        }
    }
    
    private func saveFile(as contentType: UTType, extension fileExtension: String) {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [contentType]
        panel.nameFieldStringValue = "\(generateFileName()).\(fileExtension)"
        panel.title = "Save Transcription"
        
        if panel.runModal() == .OK {
            guard let url = panel.url else { return }
            
            do {
                let content = fileExtension == "md" ? formatAsMarkdown(textToSave) : textToSave
                try content.write(to: url, atomically: true, encoding: .utf8)
                withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) { isSaved = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                    withAnimation(.easeInOut(duration: 0.2)) { isSaved = false }
                }
            } catch {
                print("Failed to save file: \(error.localizedDescription)")
            }
        }
    }
    
    private func generateFileName() -> String {
        // Clean the text and split into words
        let cleanedText = textToSave
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\r", with: " ")
        
        let words = cleanedText.components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }
        
        // Take first 5-8 words (depending on length)
        let wordCount = min(words.count, words.count <= 3 ? words.count : (words.count <= 6 ? 6 : 8))
        let selectedWords = Array(words.prefix(wordCount))
        
        if selectedWords.isEmpty {
            return "transcription"
        }
        
        // Create filename by joining words and cleaning invalid characters
        let fileName = selectedWords.joined(separator: "-")
            .lowercased()
            .replacingOccurrences(of: "[^a-z0-9\\-]", with: "", options: .regularExpression)
            .replacingOccurrences(of: "--+", with: "-", options: .regularExpression)
            .trimmingCharacters(in: CharacterSet(charactersIn: "-"))
        
        // Ensure filename isn't empty and isn't too long
        let finalFileName = fileName.isEmpty ? "transcription" : String(fileName.prefix(50))
        
        return finalFileName
    }
    
    private func formatAsMarkdown(_ text: String) -> String {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short)
        return """
        # Transcription
        
        **Date:** \(timestamp)
        
        \(text)
        """
    }
}

struct AnimatedSaveButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            AnimatedSaveButton(textToSave: "Hello world this is a sample transcription text")
            Text("Save Button Preview")
                .padding()
        }
        .padding()
    }
} 