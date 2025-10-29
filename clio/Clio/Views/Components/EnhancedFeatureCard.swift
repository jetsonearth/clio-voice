import SwiftUI

// MARK: - Enhanced Feature Card Component
struct EnhancedFeatureCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let delay: Double
    @State private var isVisible = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon container
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(DarkTheme.textPrimary.opacity(0.1))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(DarkTheme.textPrimary)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(DarkTheme.textPrimary)
                
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(DarkTheme.textSecondary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
            
            // Check mark
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(DarkTheme.textPrimary.opacity(0.8))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(white: 0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(DarkTheme.textPrimary.opacity(0.1), lineWidth: 1)
                )
        )
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

#Preview {
    VStack(spacing: 20) {
        EnhancedFeatureCard(
            icon: "command",
            title: "Hotkey Ready",
            subtitle: "Hold your key and speak to transcribe",
            delay: 0.1
        )
        
        EnhancedFeatureCard(
            icon: "waveform",
            title: "Audio Configured", 
            subtitle: "Your microphone is set up perfectly",
            delay: 0.2
        )
        
        EnhancedFeatureCard(
            icon: "brain.head.profile",
            title: "AI Model Active",
            subtitle: "Local transcription is ready to go",
            delay: 0.3
        )
    }
    .padding()
    .frame(width: 400)
}