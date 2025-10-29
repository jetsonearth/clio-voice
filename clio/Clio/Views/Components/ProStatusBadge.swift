import SwiftUI

struct ProStatusBadge: View {
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(DarkTheme.accent)
                .frame(width: 8, height: 8)
            
            Text("Clio Pro")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(DarkTheme.accent)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(DarkTheme.accent.opacity(0.1))
        )
    }
}

#Preview {
    ProStatusBadge()
        .preferredColorScheme(.dark)
}