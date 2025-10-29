import SwiftUI

// MARK: - Standard Card Style (matches License page cards)
struct StandardCardBackground: ViewModifier {
    var cornerRadius: CGFloat = 16
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(DarkTheme.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(DarkTheme.border, lineWidth: 1)
                    )
            )
    }
}

extension View {
    /// Apply the standard card style used across the app (same as License page)
    func standardCardStyle(cornerRadius: CGFloat = 16) -> some View {
        modifier(StandardCardBackground(cornerRadius: cornerRadius))
    }
} 