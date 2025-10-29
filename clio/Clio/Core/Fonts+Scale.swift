import SwiftUI

// Environment key to propagate a typography scale across the app
private struct FontScaleKey: EnvironmentKey {
    static let defaultValue: Double = 1.0
}

extension EnvironmentValues {
    var fontScale: Double {
        get { self[FontScaleKey.self] }
        set { self[FontScaleKey.self] = newValue }
    }
}

// View modifier to apply a scaled system font based on the current fontScale
private struct ScaledFont: ViewModifier {
    @Environment(\.fontScale) private var fontScale
    let size: CGFloat
    let weight: Font.Weight
    let design: Font.Design

    func body(content: Content) -> some View {
        content.font(.system(size: size * fontScale, weight: weight, design: design))
    }
}

extension View {
    func fontScaled(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) -> some View {
        modifier(ScaledFont(size: size, weight: weight, design: design))
    }
}
