import SwiftUI

struct AddNewButton: View {
    let title: String
    let action: () -> Void
    var isEnabled: Bool = true
    var backgroundColor: Color = Color.accentColor
    var textColor: Color = .white
    var systemImage: String = "plus"
    var size: ButtonSize = .regular
    
    enum ButtonSize {
        case small
        case regular
        
        var fontSize: CGFloat {
            switch self {
            case .small: return 11
            case .regular: return 12
            }
        }
        
        var horizontalPadding: CGFloat {
            switch self {
            case .small: return 10
            case .regular: return 8
            }
        }
        
        var verticalPadding: CGFloat {
            switch self {
            case .small: return 6
            case .regular: return 4
            }
        }
        
        var iconSpacing: CGFloat {
            switch self {
            case .small: return 4
            case .regular: return 4
            }
        }
    }
    
    init(_ title: String = "Add new", action: @escaping () -> Void, isEnabled: Bool = true, backgroundColor: Color = Color.accentColor, textColor: Color = .white, systemImage: String = "plus", size: ButtonSize = .regular) {
        self.title = title
        self.action = action
        self.isEnabled = isEnabled
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.systemImage = systemImage
        self.size = size
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: size.iconSpacing) {
                if !systemImage.isEmpty {
                    Image(systemName: systemImage)
                        .font(.system(size: size.fontSize, weight: .medium))
                }
                Text(title)
                    .font(.system(size: size.fontSize, weight: .medium))
            }
            .foregroundColor(textColor)
            .padding(.horizontal, size.horizontalPadding)
            .padding(.vertical, size.verticalPadding)
            .background {
                Capsule()
                    .fill(backgroundColor)
            }
        }
        .buttonStyle(.borderless)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.6)
        .help(title)
    }
}

#Preview {
    HStack {
        AddNewButton("Add new") {
            print("Add new tapped")
        }
        
        AddNewButton("Add item") {
            print("Add item tapped")
        }
        
        AddNewButton("Add new", action: {
            print("Disabled")
        }, isEnabled: false)
    }
    .padding()
}