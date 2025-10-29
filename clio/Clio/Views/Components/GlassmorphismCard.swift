import SwiftUI

// MARK: - Glassmorphism Card Background (from LicensePageView)
struct GlassmorphismCardBackground: ViewModifier {
    var cornerRadius: CGFloat = 12
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(DarkTheme.textPrimary.opacity(0.03))
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(DarkTheme.textPrimary.opacity(0.1), lineWidth: 1)
                    )
            )
    }
}

extension View {
    /// Apply the glassmorphism card style used in LicensePageView
    func glassmorphismCard(cornerRadius: CGFloat = 12) -> some View {
        modifier(GlassmorphismCardBackground(cornerRadius: cornerRadius))
    }
}