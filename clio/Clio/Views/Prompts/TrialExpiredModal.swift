import SwiftUI
import AppKit

// MARK: - Consolidated Trial Expired Modal
class TrialExpiredModal: ObservableObject {
    static let shared = TrialExpiredModal()
    
    @Published private(set) var isVisible = false
    private var windowController: NSWindowController?
    private var panel: NSPanel?
    
    private init() {}
    
    func show(whisperState: WhisperState?) {
        guard !isVisible else { return }
        isVisible = true
        
        let screen = NSApp.keyWindow?.screen ?? NSScreen.main ?? NSScreen.screens[0]
        initializeWindow(screen: screen, whisperState: whisperState)
        showWithAnimation()
    }
    
    private func initializeWindow(screen: NSScreen, whisperState: WhisperState?) {
        deinitializeWindow()
        
        let rect = calculateWindowMetrics()
        let panel = createPanel(contentRect: rect)
        
        let contentView = TrialExpiredPromptView(
            onUseFlash: { [weak self, weak whisperState] in
                guard let self = self else { return }
                if let state = whisperState {
                    Task { await self.handleUseFlash(state: state) }
                } else {
                    self.hide()
                }
            },
            onUpgrade: { [weak self] in
                Task { @MainActor in
                    if let url = URL(string: "https://www.cliovoice.com/pricing") {
                        NSWorkspace.shared.open(url)
                    }
                    SubscriptionManager.shared.promptUpgrade(from: "trial_expired_prompt")
                    self?.hide()
                }
            },
            onNeverRemind: { [weak self] in
                UserDefaults.standard.set(true, forKey: "TrialExpiredNeverRemind")
                self?.hide()
            },
            onClose: { [weak self] in
                self?.hide()
            }
        )
        .environmentObject(self)
        .environmentObject(LocalizationManager.shared)
        
        let hosting = NSHostingController(rootView: contentView)
        panel.contentView = hosting.view
        
        self.panel = panel
        self.windowController = NSWindowController(window: panel)
    }
    
    private func createPanel(contentRect: NSRect) -> NSPanel {
        let panel = TrialExpiredPanel(contentRect: contentRect,
                                     styleMask: [.nonactivatingPanel, .fullSizeContentView],
                                     backing: .buffered,
                                     defer: false)
        
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = false
        panel.isMovableByWindowBackground = true
        panel.hidesOnDeactivate = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.titlebarAppearsTransparent = true
        panel.titleVisibility = .hidden
        panel.standardWindowButton(.closeButton)?.isHidden = true
        panel.isMovable = true
        
        return panel
    }
    
    private func calculateWindowMetrics() -> NSRect {
        guard let screen = NSScreen.main else {
            return NSRect(x: 0, y: 0, width: 360, height: 180)
        }
        
        let width: CGFloat = 360
        let height: CGFloat = 200
        let visibleFrame = screen.visibleFrame
        
        let xPosition = visibleFrame.midX - (width / 2)
        let yPosition = visibleFrame.midY - (height / 2)
        
        return NSRect(x: xPosition, y: yPosition, width: width, height: height)
    }
    
    private func showWithAnimation() {
        guard let panel = panel else { return }
        
        let metrics = calculateWindowMetrics()
        panel.setFrame(metrics, display: true)
        panel.orderFrontRegardless()
        panel.alphaValue = 0
        
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.25
            panel.animator().alphaValue = 1
        }
    }
    
    @MainActor
    private func handleUseFlash(state: WhisperState) async {
        if let flashModel = state.availableModels.first(where: { $0.name == "ggml-small" }) {
            self.hide()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                Task { await state.toggleRecord() }
            }
        } else {
            let proceed = await withCheckedContinuation { cont in
                let alert = NSAlert()
                alert.messageText = LocalizationManager.shared.localizedString("download_flash.title")
                alert.informativeText = LocalizationManager.shared.localizedString("download_flash.description")
                alert.alertStyle = .informational
                alert.addButton(withTitle: LocalizationManager.shared.localizedString("common.download"))
                alert.addButton(withTitle: LocalizationManager.shared.localizedString("common.cancel"))
                let resp = alert.runModal()
                cont.resume(returning: resp == .alertFirstButtonReturn)
            }
            
            guard proceed else { return }
            // Download logic would go here
        }
    }
    
    func hide() {
        guard isVisible else { return }
        isVisible = false
        
        guard let panel = panel else { return }
        
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.2
            panel.animator().alphaValue = 0
        }, completionHandler: { [weak self] in
            self?.deinitializeWindow()
        })
    }
    
    private func deinitializeWindow() {
        windowController?.close()
        windowController = nil
        panel = nil
    }
}

// MARK: - SwiftUI View
private struct TrialExpiredPromptView: View {
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var onUseFlash: () -> Void
    var onUpgrade: () -> Void
    var onNeverRemind: () -> Void
    var onClose: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Close button in top-right corner
            HStack {
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(DarkTheme.textSecondary)
                        .frame(width: 24, height: 24)
                        .background(
                            Circle()
                                .fill(DarkTheme.textPrimary.opacity(0.1))
                        )
                }
                .buttonStyle(.plain)
                .help("Close")
            }
            .padding(.top, -8)
            
            Text(localizationManager.localizedString("trial_expired.title"))
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(DarkTheme.textPrimary)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
            
            Text(localizationManager.localizedString("trial_expired.description"))
                .font(.system(size: 14))
                .multilineTextAlignment(.center)
                .foregroundColor(DarkTheme.textSecondary)
                .frame(maxWidth: 280)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
            
            VStack(spacing: 12) {
                AddNewButton(localizationManager.localizedString("trial_expired.upgrade"),
                             action: onUpgrade,
                             backgroundColor: DarkTheme.accent,
                             textColor: DarkTheme.textPrimary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(24)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(radius: 10)
    }
}

// MARK: - Custom NSPanel Subclass
private class TrialExpiredPanel: NSPanel {
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}