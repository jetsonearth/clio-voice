import SwiftUI

struct AppIconView: View {
    var size: CGFloat
    var cornerRadius: CGFloat
    
    var body: some View {
        Group {
            if let appIcon = NSImage(named: NSImage.applicationIconName) {
                Image(nsImage: appIcon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size, height: size)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(.linearGradient(
                                colors: [
                                    DarkTheme.textPrimary.opacity(0.5),
                                    DarkTheme.textPrimary.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 10, y: 5)
            }
        }
    }
} 