import SwiftUI

// Reusable background with a simple material fill and adaptive stroke/shadow.
// Internal implementation is intentionally minimal and non-derivative.
struct CardBackground: View {
    var isSelected: Bool
    var cornerRadius: CGFloat = 16
    var useAccentGradientWhenSelected: Bool = false

    var body: some View {
        let resolvedCornerRadius = cornerRadius
        let strokeColor: Color = isSelected
            ? Color.accentColor.opacity(0.35)
            : Color.primary.opacity(0.15)
        let shadowOpacity: Double = isSelected ? 0.18 : 0.10
        let shadowRadius: CGFloat = isSelected ? 12 : 8
        let shadowYOffset: CGFloat = isSelected ? 6 : 3

        RoundedRectangle(cornerRadius: resolvedCornerRadius, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: resolvedCornerRadius, style: .continuous)
                    .stroke(strokeColor, lineWidth: isSelected ? 1.5 : 1)
            )
            .shadow(
                color: Color.black.opacity(shadowOpacity),
                radius: shadowRadius,
                x: 0,
                y: shadowYOffset
            )
    }
}