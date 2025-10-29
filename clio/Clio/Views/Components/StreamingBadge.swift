import SwiftUI

/// A badge component that indicates streaming capability
struct StreamingBadge: View {
    let style: BadgeStyle
    
    enum BadgeStyle {
        case compact      // Just "STREAMING" text
        case withIcon     // Wave icon + "STREAMING"
        case iconOnly     // Just wave icon
    }
    
    init(style: BadgeStyle = .compact) {
        self.style = style
    }
    
    var body: some View {
        HStack(spacing: 4) {
            switch style {
            case .withIcon:
                Image(systemName: "waveform")
                    .font(.system(size: 10))
                    .foregroundColor(.blue)
            case .iconOnly:
                Image(systemName: "waveform")
                    .font(.system(size: 12))
                    .foregroundColor(.blue)
            case .compact:
                EmptyView()
            }
            
            if style != .iconOnly {
                Text("STREAMING")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, style == .iconOnly ? 6 : 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [Color.blue, Color.blue.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        )
        .shadow(color: Color.blue.opacity(0.3), radius: 2, x: 0, y: 1)
    }
}

// MARK: - View Extension

struct StreamingBadgeOverlay: ViewModifier {
    let showBadge: Bool
    let alignment: Alignment
    let style: StreamingBadge.BadgeStyle
    
    init(showBadge: Bool, alignment: Alignment = .topTrailing, style: StreamingBadge.BadgeStyle = .compact) {
        self.showBadge = showBadge
        self.alignment = alignment
        self.style = style
    }
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: alignment) {
                if showBadge {
                    StreamingBadge(style: style)
                        .offset(x: alignment == .topTrailing ? 8 : 0, y: alignment == .topTrailing ? -8 : 0)
                }
            }
    }
}

extension View {
    func streamingBadge(_ showBadge: Bool, alignment: Alignment = .topTrailing, style: StreamingBadge.BadgeStyle = .compact) -> some View {
        modifier(StreamingBadgeOverlay(showBadge: showBadge, alignment: alignment, style: style))
    }
}

#Preview {
    VStack(spacing: 20) {
        StreamingBadge(style: .compact)
        StreamingBadge(style: .withIcon)
        StreamingBadge(style: .iconOnly)
    }
    .padding()
}