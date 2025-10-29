import SwiftUI

// MARK: - Dark Theme Color Palette
struct DarkTheme {
    static let background = Color(hex: "0A0A0A")
    static let cardBackground = Color(hex: "141414")
    static let surfaceBackground = Color(hex: "1A1A1A")
    static let border = Color(hex: "2A2A2A")
    static let textPrimary = Color(hex: "D5C9B4")
    static let textSecondary = Color(hex: "958E7B")
    static let textTertiary = Color(white: 0.4)
    static let accent = Color.accentColor
    static let success = Color(hex: "34C759")
    static let warning = Color(hex: "FF9500")
    static let error = Color(hex: "FF3B30")
}

// MARK: - Light Theme Color Palette  
struct LightTheme {
    static let background = Color(hex: "FFFFFF")
    static let cardBackground = Color(hex: "F8F9FA")
    static let surfaceBackground = Color(hex: "F1F3F4")
    static let border = Color(hex: "E1E3E4")
    static let textPrimary = Color(hex: "1D1D1F")
    static let textSecondary = Color(hex: "6E6E73")
    static let textTertiary = Color(hex: "8E8E93")
    static let accent = Color.accentColor
    static let success = Color(hex: "34C759")
    static let warning = Color(hex: "FF9500")
    static let error = Color(hex: "FF3B30")
}

// MARK: - Current Theme (auto-detects system preference)
struct CurrentTheme {
    @Environment(\.colorScheme) private var colorScheme
    
    var isDark: Bool {
        colorScheme == .dark
    }
    
    var background: Color { isDark ? DarkTheme.background : LightTheme.background }
    var cardBackground: Color { isDark ? DarkTheme.cardBackground : LightTheme.cardBackground }
    var surfaceBackground: Color { isDark ? DarkTheme.surfaceBackground : LightTheme.surfaceBackground }
    var border: Color { isDark ? DarkTheme.border : LightTheme.border }
    var textPrimary: Color { isDark ? DarkTheme.textPrimary : LightTheme.textPrimary }
    var textSecondary: Color { isDark ? DarkTheme.textSecondary : LightTheme.textSecondary }
    var textTertiary: Color { isDark ? DarkTheme.textTertiary : LightTheme.textTertiary }
    var accent: Color { isDark ? DarkTheme.accent : LightTheme.accent }
    var success: Color { isDark ? DarkTheme.success : LightTheme.success }
    var warning: Color { isDark ? DarkTheme.warning : LightTheme.warning }
    var error: Color { isDark ? DarkTheme.error : LightTheme.error }
}

// MARK: - Dark Theme Components
struct DarkCardBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(DarkTheme.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(DarkTheme.border, lineWidth: 1)
                    )
            )
    }
}

struct DarkButton: View {
    let title: String
    let action: () -> Void
    var style: ButtonStyle = .primary
    var isLoading: Bool = false
    var disabled: Bool = false
    
    enum ButtonStyle {
        case primary, secondary, text
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(0.8)
                        .frame(width: 16, height: 16)
                } else {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(backgroundView)
            .cornerRadius(12)
        }
        .disabled(disabled || isLoading)
        .opacity(disabled ? 0.6 : 1)
    }
    
    private var textColor: Color {
        switch style {
        case .primary:
            return .white
        case .secondary:
            return DarkTheme.textPrimary
        case .text:
            return DarkTheme.accent
        }
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .primary:
            LinearGradient(
                colors: [DarkTheme.accent, DarkTheme.accent.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .secondary:
            RoundedRectangle(cornerRadius: 12)
                .fill(DarkTheme.surfaceBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(DarkTheme.border, lineWidth: 1)
                )
        case .text:
            Color.clear
        }
    }
}

struct DarkTextField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var icon: String? = nil
    
    var body: some View {
        HStack(spacing: 12) {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(DarkTheme.textTertiary)
                    .frame(width: 20)
            }
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .textFieldStyle(.plain)
                    .foregroundColor(DarkTheme.textPrimary)
            } else {
                TextField(placeholder, text: $text)
                    .textFieldStyle(.plain)
                    .foregroundColor(DarkTheme.textPrimary)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 50)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(DarkTheme.surfaceBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(DarkTheme.border, lineWidth: 1)
                )
        )
    }
}

struct DarkProgressIndicator: View {
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { index in
                Circle()
                    .fill(index <= currentStep ? DarkTheme.accent : DarkTheme.border)
                    .frame(width: 8, height: 8)
                    .animation(.spring(response: 0.3), value: currentStep)
            }
        }
    }
}

// MARK: - View Extensions
extension View {
    func darkCardStyle() -> some View {
        modifier(DarkCardBackground())
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
}