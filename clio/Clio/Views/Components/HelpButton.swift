import SwiftUI

struct HelpButton: View {
    let message: String
    @State private var isShowingTip: Bool = false
    
    var body: some View {
        Button(action: { isShowingTip.toggle() }) {
            Image(systemName: "info.circle")
                .font(.system(size: 12))
                .foregroundColor(DarkTheme.textSecondary)
        }
        .buttonStyle(.plain)
        .popover(isPresented: $isShowingTip) {
            VStack(alignment: .leading, spacing: 8) {
                Text(message)
                    .frame(width: 300)
                    .font(.system(size: 13))
                    .foregroundColor(.primary)
            }
            .padding()
        }
    }
}

#Preview {
    HelpButton(message: "This is a help message explaining the feature in detail.")
        .padding()
}