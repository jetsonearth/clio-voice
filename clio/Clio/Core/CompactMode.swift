import SwiftUI

extension DynamicTypeSize {
    func oneStepSmaller() -> DynamicTypeSize {
        let order: [DynamicTypeSize] = [
            .xSmall, .small, .medium, .large, .xLarge, .xxLarge, .xxxLarge,
            .accessibility1, .accessibility2, .accessibility3, .accessibility4, .accessibility5
        ]
        if let i = order.firstIndex(of: self), i > 0 { return order[i - 1] }
        return self
    }
}

private struct CompactEnvironment: ViewModifier {
    let compact: Bool
    @Environment(\.dynamicTypeSize) private var currentSize

    func body(content: Content) -> some View {
        if compact {
            content
                .environment(\.dynamicTypeSize, currentSize.oneStepSmaller())
.environment(\.fontScale, 0.88) // slightly smaller to fit tighter cards
                .controlSize(.small)
        } else {
            content
                .environment(\.fontScale, 1.0)
                .controlSize(.regular)
        }
    }
}

extension View {
    func compactMode(_ enabled: Bool) -> some View {
        modifier(CompactEnvironment(compact: enabled))
    }
}
