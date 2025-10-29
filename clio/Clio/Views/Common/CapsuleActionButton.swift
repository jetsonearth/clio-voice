import SwiftUI

/// A pill-shaped button with an icon and a title that follows the DarkTheme palette.
struct CapsuleActionButton: View {
    let title: String
    let systemImage: String
    var backgroundColor: Color = Color.accentColor
    var action: () -> Void
    
    @State private var isPressed: Bool = false
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(DarkTheme.textPrimary)
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(DarkTheme.textPrimary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(backgroundColor.opacity(isPressed ? 0.8 : 1.0))
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.97 : 1)
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isPressed)
        .pressAction { pressing in
            isPressed = pressing
        }
    }
}

// MARK: - Press action helper
private extension View {
    /// Adds a press gesture that exposes a boolean indicating the pressed state.
    func pressAction(onChanged: @escaping (Bool) -> Void) -> some View {
        modifier(PressActionModifier(onChanged: onChanged))
    }
}

private struct PressActionModifier: ViewModifier {
    var onChanged: (Bool) -> Void
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in onChanged(true) }
                    .onEnded { _ in onChanged(false) }
            )
    }
}

#if DEBUG
struct CapsuleActionButton_Previews: PreviewProvider {
    static var previews: some View {
        CapsuleActionButton(title: "Add new", systemImage: "plus", action: {})
            .padding()
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
    }
}
#endif 