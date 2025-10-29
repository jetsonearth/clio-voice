import SwiftUI

// MARK: - Key Selection Utility Functions
extension HotkeyManager.PushToTalkKey {
    var symbol: String {
        switch self {
        case .rightOption, .leftOption: return "⌥"
        case .leftControl, .rightControl: return "⌃"
        case .fn: return "fn"
        case .rightCommand, .leftCommand: return "⌘"
        case .rightShift, .leftShift: return "⇧"
        }
    }
    
    var shortDisplayName: String {
        switch self {
        case .rightOption: return "Right Option"
        case .leftOption: return "Left Option"
        case .leftControl, .rightControl: return "Control"
        case .fn: return "Function"
        case .rightCommand: return "Right Command"
        case .rightShift: return "Right Shift"
        case .leftCommand: return "Left Command"
        case .leftShift: return "Left Shift"
        }
    }
}

struct SimplifiedPushToTalkKeySelector: View {
    @Binding var selectedKey: HotkeyManager.PushToTalkKey
    let onKeySelected: (HotkeyManager.PushToTalkKey) -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(HotkeyManager.PushToTalkKey.allCases, id: \.self) { key in
                Button(action: {
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                        selectedKey = key
                        onKeySelected(key)
                    }
                }) {
                    SelectableKeyCapView(
                        text: key.symbol,
                        subtext: key.shortDisplayName,
                        isSelected: selectedKey == key
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct SelectableKeyCapView: View {
    let text: String
    let subtext: String
    let isSelected: Bool
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var keyColor: Color {
        if isSelected {
            return colorScheme == .dark ? Color.accentColor.opacity(0.3) : Color.accentColor.opacity(0.2)
        }
        return colorScheme == .dark ? Color(white: 0.2) : .white
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(text)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(DarkTheme.textPrimary)
                .frame(width: 44, height: 44)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(keyColor)
                        
                        // Highlight overlay
                        if isSelected {
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(Color.accentColor, lineWidth: 2)
                        }
                        
                        // Key surface highlight
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        DarkTheme.textPrimary.opacity(colorScheme == .dark ? 0.1 : 0.4),
                                        DarkTheme.textPrimary.opacity(0)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
                )
                .shadow(
                    color: Color.black.opacity(colorScheme == .dark ? 0.5 : 0.2),
                    radius: 2,
                    x: 0,
                    y: 1
                )
            
            Text(subtext)
                .font(.system(size: 11))
                .foregroundColor(DarkTheme.textPrimary)
        }
    }
}
