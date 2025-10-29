import SwiftUI

struct PresetPromptCard: View {
    let icon: String
    let title: String
    let description: String
    let promptText: String
    let isSelected: Bool
    let onSelect: () -> Void
    
    @State private var isExpanded = false
    @State private var isHovered = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Main card content
            HStack(spacing: 16) {
                // Icon
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : DarkTheme.textSecondary)
                    .frame(width: 24, height: 24)
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(isSelected ? .white : DarkTheme.textPrimary)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : DarkTheme.textSecondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Selection indicator and expand button
                HStack(spacing: 12) {
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                            .font(.title3)
                    }
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isExpanded.toggle()
                        }
                    }) {
                        Image(systemName: "chevron.down")
                            .foregroundColor(isSelected ? .white.opacity(0.8) : DarkTheme.textSecondary)
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                            .animation(.easeInOut(duration: 0.3), value: isExpanded)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.accentColor : DarkTheme.surfaceBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? 
                                    Color.accentColor : 
                                    (isHovered ? DarkTheme.textSecondary.opacity(0.3) : DarkTheme.textSecondary.opacity(0.1)),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isHovered)
            .onTapGesture {
                onSelect()
            }
            .onHover { hovering in
                isHovered = hovering
            }
            
            // Expandable prompt text section
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "doc.text")
                            .foregroundColor(DarkTheme.textSecondary)
                        Text("Prompt Text")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(DarkTheme.textPrimary)
                        Spacer()
                    }
                    
                    ScrollView {
                        Text(promptText)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(DarkTheme.textSecondary)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxHeight: 200)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(DarkTheme.cardBackground)
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(DarkTheme.surfaceBackground)
                        .clipShape(
                            .rect(
                                topLeadingRadius: 0,
                                bottomLeadingRadius: 12,
                                bottomTrailingRadius: 12,
                                topTrailingRadius: 0
                            )
                        )
                )
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .top)),
                    removal: .opacity.combined(with: .move(edge: .top))
                ))
            }
        }
    }
}

// MARK: - Preview
// #Preview {
//     VStack(spacing: 16) {
//         PresetPromptCard(
//             icon: "envelope.fill",
//             title: "Email",
//             description: "Convert to professional email format",
//             promptText: "You are an AI assistant tasked with repurposing a raw voice transcript into a professional email...",
//             isSelected: true,
//             onSelect: {}
//         )
        
//         PresetPromptCard(
//             icon: "person.2.fill",
//             title: "Meeting Notes",
//             description: "Structure into meeting notes with action items",
//             promptText: "You are an AI assistant tasked with processing a voice-dictated transcript from a meeting...",
//             isSelected: false,
//             onSelect: {}
//         )
//     }
//     .padding()
//     .background(DarkTheme.cardBackground)
// }