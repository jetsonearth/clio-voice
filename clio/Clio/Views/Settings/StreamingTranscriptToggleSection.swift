import SwiftUI

struct StreamingTranscriptToggleSection: View {
    @AppStorage("streamingTranscriptEnabled") private var streamingTranscriptEnabled: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "text.bubble")
                    .font(.system(size: 20))
                    .foregroundColor(.accentColor)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Streaming Transcript")
                        .font(.headline)
                        .foregroundColor(DarkTheme.textPrimary)
                    Text("Show real-time transcript text while recording")
                        .font(.subheadline)
                        .foregroundColor(DarkTheme.textSecondary)
                }
                
                Spacer()
                
                Toggle("", isOn: $streamingTranscriptEnabled)
                    .toggleStyle(SwitchToggleStyle(tint: DarkTheme.accent))
                    .scaleEffect(1.0)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(DarkTheme.textPrimary.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(DarkTheme.textPrimary.opacity(0.1), lineWidth: 1)
                )
        )
    }
}