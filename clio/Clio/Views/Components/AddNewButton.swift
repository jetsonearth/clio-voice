import SwiftUI

struct AddNewButton: View {
    let title: String
    let action: () -> Void
    var isEnabled: Bool = true
    var backgroundColor: Color = Color.accentColor
    var textColor: Color = .white
    var systemImage: String = "plus"
    
    init(_ title: String = "Add new", action: @escaping () -> Void, isEnabled: Bool = true, backgroundColor: Color = Color.accentColor, textColor: Color = .white, systemImage: String = "plus") {
        self.title = title
        self.action = action
        self.isEnabled = isEnabled
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.systemImage = systemImage
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if !systemImage.isEmpty {
                    Image(systemName: systemImage)
                        .font(.system(size: 12, weight: .medium))
                }
                Text(title)
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundColor(textColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
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