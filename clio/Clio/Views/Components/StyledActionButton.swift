import SwiftUI

// MARK: - Styled Action Button Component
struct StyledActionButton: View {
    let title: String
    let action: () -> Void
    var isDisabled: Bool = false
    var showArrow: Bool = true
    var style: ButtonStyle = .primary
    
    @State private var isHovered = false
    
    enum ButtonStyle {
        case primary
        case secondary
        case destructive
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(isDisabled ? DarkTheme.textSecondary : DarkTheme.textPrimary)
                
                if showArrow && !isDisabled {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(DarkTheme.textPrimary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .contentShape(Rectangle()) // Make entire area clickable
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(backgroundMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(borderColor, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isHovered && !isDisabled ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isHovered)
        .disabled(isDisabled)
        .onHover { hovering in
            if !isDisabled {
                isHovered = hovering
            }
        }
    }
    
    private var backgroundMaterial: Material {
        switch style {
        case .primary:
            return .ultraThinMaterial
        case .secondary:
            return .ultraThinMaterial
        case .destructive:
            return .ultraThinMaterial
        }
    }
    
    private var borderColor: Color {
        if isDisabled {
            return DarkTheme.textPrimary.opacity(0.1)
        }
        
        switch style {
        case .primary:
            return DarkTheme.textPrimary.opacity(isHovered ? 0.4 : 0.2)
        case .secondary:
            return DarkTheme.textSecondary.opacity(isHovered ? 0.3 : 0.15)
        case .destructive:
            return Color.red.opacity(isHovered ? 0.6 : 0.3)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        StyledActionButton(title: "Continue", action: {})
        StyledActionButton(title: "Get Started", action: {})
        StyledActionButton(title: "Next", action: {})
        StyledActionButton(title: "Back", action: {}, showArrow: false)
        StyledActionButton(title: "Disabled", action: {}, isDisabled: true)
    }
    .padding()
}