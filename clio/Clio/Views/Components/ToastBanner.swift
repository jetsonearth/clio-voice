import SwiftUI
import AppKit

final class ToastBanner {
    static let shared = ToastBanner()
    private var panel: NSPanel?
    private var isVisible: Bool = false
    private var autoHideTask: Task<Void, Never>?
    private init() {}
    
    func show(title: String, subtitle: String? = nil, duration: TimeInterval = 3.0, systemIconName: String = "exclamationmark.triangle.fill") {
        DispatchQueue.main.async {
            self.hide()
            let screen = NSApp.keyWindow?.screen ?? NSScreen.main ?? NSScreen.screens.first!
            let frame = self.computeFrame(screen: screen)
            let panel = self.makePanel(frame: frame)
            let hosting = NSHostingController(rootView: ToastBannerView(title: title, subtitle: subtitle, systemIconName: systemIconName))
            panel.contentView = hosting.view
            self.panel = panel
            panel.alphaValue = 0
            panel.orderFrontRegardless()
            NSAnimationContext.runAnimationGroup { ctx in
                ctx.duration = 0.18
                panel.animator().alphaValue = 1
            }
            self.isVisible = true
            self.autoHideTask = Task { [weak self] in
                try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
                await MainActor.run { self?.hide() }
            }
        }
    }
    
    func hide() {
        guard isVisible, let panel = panel else { return }
        autoHideTask?.cancel(); autoHideTask = nil
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.18
            panel.animator().alphaValue = 0
        }, completionHandler: { [weak self] in
            self?.panel?.orderOut(nil)
            self?.panel = nil
            self?.isVisible = false
        })
    }
    
    private func computeFrame(screen: NSScreen) -> NSRect {
        let width: CGFloat = 360
        let height: CGFloat = 96
        let vf = screen.visibleFrame
        let x = vf.maxX - width - 16
        let y = vf.maxY - height - 24
        return NSRect(x: x, y: y, width: width, height: height)
    }
    
    private func makePanel(frame: NSRect) -> NSPanel {
        let panel = NSPanel(contentRect: frame, styleMask: [.nonactivatingPanel, .fullSizeContentView], backing: .buffered, defer: false)
        panel.isFloatingPanel = true
        panel.level = .statusBar
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.hidesOnDeactivate = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.standardWindowButton(.closeButton)?.isHidden = true
        panel.isMovable = false
        return panel
    }
}

private struct ToastBannerView: View {
    let title: String
    let subtitle: String?
    let systemIconName: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: systemIconName)
                .foregroundStyle(Color.yellow)
                .font(.system(size: 18, weight: .semibold))
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(3)
                if let subtitle = subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(3)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
        )
    }
}


