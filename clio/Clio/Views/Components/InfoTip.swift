import SwiftUI

// Simple info tip with popover; implementation is intentionally minimal.
struct InfoTip: View {
    var title: String
    var message: String
    var learnMoreLink: URL?
    var learnMoreText: String = "Learn More"
    var iconName: String = "info.circle"
    var width: CGFloat = 300

    @State private var isShowingTip: Bool = false

    var body: some View {
        Button(action: { isShowingTip.toggle() }) {
            Image(systemName: iconName)
                .imageScale(.medium)
                .foregroundColor(.secondary)
                .padding(4)
        }
        .buttonStyle(.plain)
        .popover(isPresented: $isShowingTip) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title).font(.headline)
                Text(message).frame(width: width)
                if let url = learnMoreLink {
                    Button(learnMoreText) { NSWorkspace.shared.open(url) }
                        .foregroundColor(.accentColor)
                }
            }
            .padding()
        }
    }
}

extension InfoTip {
    init(title: String, message: String) {
        self.title = title
        self.message = message
        self.learnMoreLink = nil
    }

    init(title: String, message: String, learnMoreURL: String) {
        self.title = title
        self.message = message
        self.learnMoreLink = URL(string: learnMoreURL)
    }
}
