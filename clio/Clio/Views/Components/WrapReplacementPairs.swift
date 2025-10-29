import SwiftUI

// Wraps pairs like "trigger -> expansion" into wrapping rows, similar to WrapTags
struct WrapReplacementPairs: View {
    let pairs: [(String, String)]
    private let spacing: CGFloat = 10

    var body: some View {
        GeometryReader { geo in
            self.generate(in: geo)
        }
        .frame(height: height)
    }

    @State private var totalHeight: CGFloat = .zero
    private var height: CGFloat { totalHeight }

    private func generate(in g: GeometryProxy) -> some View {
        var width: CGFloat = 0
        var height: CGFloat = 0

        return ZStack(alignment: .topLeading) {
            ForEach(Array(pairs.enumerated()), id: \.offset) { item in
                let pair = item.element
                ReplacementPairChip(left: pair.0, right: pair.1)
                    .padding(.trailing, spacing)
                    .padding(.bottom, spacing)
                    .alignmentGuide(.leading, computeValue: { d in
                        if abs(width - d.width) > g.size.width {
                            width = 0
                            height -= d.height + spacing
                        }
                        let result = width
                        width -= d.width + spacing
                        return result
                    })
                    .alignmentGuide(.top, computeValue: { _ in
                        let result = height
                        return result
                    })
            }
        }
        .background(heightReader($totalHeight))
    }

    private func heightReader(_ binding: Binding<CGFloat>) -> some View {
        GeometryReader { geo in
            Color.clear
                .preference(key: RPHeightKey.self, value: geo.size.height)
        }
        .onPreferenceChange(RPHeightKey.self) { binding.wrappedValue = $0 }
    }
}

private struct RPHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

struct ReplacementPairChip: View {
    let left: String
    let right: String

    var body: some View {
        HStack(spacing: 6) {
            Capsule()
                .fill(Color.primary.opacity(0.12))
                .overlay(Text(left)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(DarkTheme.textPrimary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6))
                .fixedSize()

            Image(systemName: "arrow.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(DarkTheme.textSecondary)

            Capsule()
                .fill(Color.primary.opacity(0.08))
                .overlay(Text(right)
                    .font(.system(size: 12))
                    .foregroundColor(DarkTheme.textSecondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6))
                .fixedSize()
        }
        .padding(.horizontal, 0)
    }
}

