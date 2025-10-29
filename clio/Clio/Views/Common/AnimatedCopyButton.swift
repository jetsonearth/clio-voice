import SwiftUI

struct AnimatedCopyButton: View {
    let textToCopy: String
    @State private var isCopied: Bool = false
    @State private var isPulsing: Bool = false

    var body: some View {
        Button(action: handleCopy) {
            HStack(spacing: 6) {
                Image(systemName: isCopied ? "checkmark.circle.fill" : "doc.on.doc")
                    .foregroundColor(isCopied ? DarkTheme.success : DarkTheme.textPrimary)
                    .scaleEffect(isPulsing ? 1.06 : 1.0)
                Text(isCopied ? "Copied" : "Copy")
                    .foregroundColor(DarkTheme.textPrimary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(DarkTheme.textPrimary.opacity(0.08))
            )
        }
        .buttonStyle(.plain)
        .onChange(of: isCopied) { _, newValue in
            guard newValue else { return }
            withAnimation(.easeInOut(duration: 0.18)) { isPulsing = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                withAnimation(.easeInOut(duration: 0.18)) { isPulsing = false }
            }
        }
    }

    private func handleCopy() {
        _ = ClipboardManager.copyToClipboard(textToCopy)
        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) { isCopied = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeInOut(duration: 0.2)) { isCopied = false }
        }
    }
}