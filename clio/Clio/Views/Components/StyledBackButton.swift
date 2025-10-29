import SwiftUI

// MARK: - Styled Back Button Component
struct StyledBackButton: View {
    let action: () -> Void
    @State private var isHovered = false
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(DarkTheme.textPrimary)
                Text(localizationManager.localizedString("general.back"))
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(DarkTheme.textPrimary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(DarkTheme.textPrimary.opacity(isHovered ? 0.4 : 0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isHovered ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
        .contentShape(Rectangle()) // Ensure full area is tappable
    }
}

#Preview {
    StyledBackButton {
        print("Back pressed")
    }
    .padding()
}
