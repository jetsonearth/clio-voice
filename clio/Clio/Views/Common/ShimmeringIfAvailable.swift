import SwiftUI

#if canImport(Shimmer)
import Shimmer
#endif

public extension View {
    @ViewBuilder
    func shimmeringIfAvailable(active: Bool,
                               bandSize: CGFloat = 0.30) -> some View {
        #if canImport(Shimmer)
        // Balanced shimmer - visible on long text, lighter performance impact
        self.shimmering(
            active: active,
            animation: .linear(duration: 1.2).repeatForever(autoreverses: false),
            gradient: Gradient(colors: [
                .clear,
                Color.white.opacity(0.05),
                Color.white.opacity(0.5),
                Color.white.opacity(0.05),
                .clear
            ]),
            bandSize: bandSize * 0.7, // Narrower band for subtler effect
            mode: .overlay()
        )
        #else
        self
        #endif
    }
}

