import SwiftUI

#if canImport(SwiftfulLoadingIndicators)
import SwiftfulLoadingIndicators
#endif

/// Three-balls triangle loading indicator sized for the notch area.
/// Falls back to a simple pulsing three-dot indicator if the package isn't available.
struct ThreeBallsTriangleIfAvailable: View {
    var body: some View {
        #if canImport(SwiftfulLoadingIndicators)
        HStack(spacing: 0) {
            LoadingIndicator(animation: .threeBallsTriangle, color: .white, size: .small)
                .scaleEffect(0.64, anchor: .leading)
                .frame(width: 18, height: 8, alignment: .leading)
            Spacer(minLength: 0)
        }
        #else
        // Fallback: simple three pulsing dots to avoid build-time dependency
        HStack(spacing: 1.6) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(Color.white.opacity(0.9))
                    .frame(width: 1.4, height: 1.4)
                    .modifier(PulsingDelay(index: i))
            }
            Spacer(minLength: 0)
        }
        .frame(width: 18, height: 8, alignment: .leading)
        #endif
    }
}

private struct PulsingDelay: ViewModifier {
    let index: Int
    @State private var scale: CGFloat = 1.0
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onAppear {
                let base = 0.6
                withAnimation(.easeInOut(duration: 0.6).delay(Double(index) * 0.15).repeatForever(autoreverses: true)) {
                    scale = 1.3
                }
            }
    }
}

