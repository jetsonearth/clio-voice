import SwiftUI

/// A badge component that indicates Pro subscription requirement
struct ProBadge: View {
    let style: BadgeStyle
    
    enum BadgeStyle {
        case compact      // Just "PRO" text
        case withIcon     // Crown icon + "PRO"
        case withLock     // Lock icon + "PRO"
    }
    
    init(style: BadgeStyle = .compact) {
        self.style = style
    }
    
    var body: some View {
        HStack(spacing: 4) {
            switch style {
            case .withIcon:
                Image(systemName: "crown.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.yellow)
            case .withLock:
                Image(systemName: "lock.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            case .compact:
                EmptyView()
            }
            
            Text("PRO")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.96, green: 0.65, blue: 0.14), // Gold
                            Color(red: 0.94, green: 0.78, blue: 0.31)  // Light gold
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
    }
}

/// A more subtle Pro indicator for inline use
struct ProIndicator: View {
    let isLocked: Bool
    
    init(isLocked: Bool = false) {
        self.isLocked = isLocked
    }
    
    var body: some View {
        if isLocked {
            Image(systemName: "lock.fill")
                .font(.system(size: 12))
                .foregroundColor(.secondary.opacity(0.8))
        } else {
            Image(systemName: "crown.fill")
                .font(.system(size: 12))
                .foregroundColor(.yellow.opacity(0.8))
        }
    }
}

/// View modifier to add a Pro badge overlay
struct ProBadgeOverlay: ViewModifier {
    let showBadge: Bool
    let alignment: Alignment
    let style: ProBadge.BadgeStyle
    
    init(showBadge: Bool, alignment: Alignment = .topTrailing, style: ProBadge.BadgeStyle = .compact) {
        self.showBadge = showBadge
        self.alignment = alignment
        self.style = style
    }
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: alignment) {
                if showBadge {
                    ProBadge(style: style)
                        .padding(8)
                }
            }
    }
}

extension View {
    /// Adds a Pro badge overlay to the view
    func proBadge(_ showBadge: Bool, alignment: Alignment = .topTrailing, style: ProBadge.BadgeStyle = .compact) -> some View {
        modifier(ProBadgeOverlay(showBadge: showBadge, alignment: alignment, style: style))
    }
}

// MARK: - Preview

#Preview("Pro Badges") {
    VStack(spacing: 20) {
        HStack(spacing: 20) {
            ProBadge(style: .compact)
            ProBadge(style: .withIcon)
            ProBadge(style: .withLock)
        }
        
        HStack(spacing: 20) {
            ProIndicator(isLocked: false)
            ProIndicator(isLocked: true)
        }
        
        // Example usage in a card
        VStack {
            Text("Large v3 Turbo Model")
                .font(.headline)
        }
        .frame(width: 200, height: 100)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
        .proBadge(true, style: .withIcon)
    }
    .padding(40)
    .background(Color.black)
}