import SwiftUI
import AppKit

class MiniRecorderPanel: NSPanel {
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
    
    init(contentRect: NSRect) {
        super.init(
            contentRect: contentRect,
            styleMask: [.nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        self.isFloatingPanel = true
        self.level = .floating
        self.backgroundColor = .clear
        self.isOpaque = false
        self.hasShadow = false // Explicitly no window shadow
        self.isMovableByWindowBackground = true
        self.hidesOnDeactivate = false
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
        self.titlebarAppearsTransparent = true
        self.titleVisibility = .hidden
        
        self.standardWindowButton(.closeButton)?.isHidden = true
        self.isMovable = true
    }
    
    static func calculateWindowMetrics(for screen: NSScreen? = nil, streamingTranscriptEnabled: Bool = false) -> NSRect {
        let targetScreen = screen ?? NSScreen.main ?? NSScreen.screens.first!

        // Dynamic sizing based on mode - bounded text container approach
        let width: CGFloat = streamingTranscriptEnabled ? 320 : 95
        let height: CGFloat = streamingTranscriptEnabled ? 160 : 32  // 24px top + 112px content + 24px bottom
        let padding: CGFloat = 25  // Distance from bottom dock

        let visibleFrame = targetScreen.visibleFrame

        let xPosition = visibleFrame.midX - (width / 2)
        let yPosition = visibleFrame.minY + padding

        return NSRect(
            x: xPosition,
            y: yPosition,
            width: width,
            height: height
        )
    }
    
    func show(on screen: NSScreen? = nil, streamingTranscriptEnabled: Bool = false) {
        let metrics = MiniRecorderPanel.calculateWindowMetrics(for: screen, streamingTranscriptEnabled: streamingTranscriptEnabled)
        setFrame(metrics, display: true)
        orderFrontRegardless()
    }
    
    func hide(completion: @escaping () -> Void) {
        // Quick fade out after SwiftUI animation completes
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.1
            animator().alphaValue = 0
        }) {
            completion()
        }
    }
} 
