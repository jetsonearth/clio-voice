import SwiftUI

struct PageHeaderView: View {
    let title: String
    let subtitle: String
    var accessory: AnyView?
    
    init(title: String, subtitle: String, accessory: AnyView? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.accessory = accessory
    }
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .fontScaled(size: 30, weight: .bold)
                    .foregroundColor(DarkTheme.textPrimary)
                Text(subtitle)
                    .fontScaled(size: 16)
                    .foregroundColor(DarkTheme.textSecondary)
            }
            Spacer()
            accessory
        }
        .frame(maxWidth: .infinity)
    }
}

struct GlassCard<Content: View>: View {
    private let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(28)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(Color.white.opacity(0.03))
                    .overlay(
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .stroke(Color.white.opacity(0.05), lineWidth: 1)
                    )
            )
    }
}
