// import SwiftUI
// import AppKit

// class MiniRecorderPanel: NSPanel {
//     override var canBecomeKey: Bool { false }
//     override var canBecomeMain: Bool { false }
    
//     init(contentRect: NSRect) {
//         super.init(
//             contentRect: contentRect,
//             styleMask: [.nonactivatingPanel, .fullSizeContentView],
//             backing: .buffered,
//             defer: false
//         )
        
//         self.isFloatingPanel = true
//         self.level = .floating
//         self.backgroundColor = .clear
//         self.isOpaque = false
//         self.hasShadow = false
//         self.isMovableByWindowBackground = true
//         self.hidesOnDeactivate = false
//         self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
//         self.titlebarAppearsTransparent = true
//         self.titleVisibility = .hidden
        
//         self.standardWindowButton(.closeButton)?.isHidden = true
        
//         self.isMovable = true
//     }
    
//     static func calculateWindowMetrics() -> NSRect {
//         guard let screen = NSScreen.main else {
//             return NSRect(x: 0, y: 0, width: 200, height: 40)
//         }
        
//         let width: CGFloat = 140  // Further reduced width for more compact recorder
//         let height: CGFloat = 40  // Slightly reduced from 44
//         let padding: CGFloat = 40  // Increased from 24 to move higher from dock
        
//         let visibleFrame = screen.visibleFrame
        
//         let xPosition = visibleFrame.midX - (width / 2)
//         let yPosition = visibleFrame.minY + padding
        
//         return NSRect(
//             x: xPosition,
//             y: yPosition,
//             width: width,
//             height: height
//         )
//     }
    
//     func show() {
//         let metrics = MiniRecorderPanel.calculateWindowMetrics()
//         setFrame(metrics, display: true)
//         orderFrontRegardless()
//     }
    
//     func hide(completion: @escaping () -> Void) {
//         // Quick fade out after SwiftUI animation completes
//         NSAnimationContext.runAnimationGroup({ context in
//             context.duration = 0.1
//             animator().alphaValue = 0
//         }) {
//             completion()
//         }
//     }
// } 