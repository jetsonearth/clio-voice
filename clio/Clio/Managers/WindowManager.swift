import SwiftUI
import AppKit

class WindowManager {
    static let shared = WindowManager()
    // Keep a strong reference to the window delegate to avoid dangling pointer crashes
    private var mainWindowDelegate: WindowStateDelegate?
    // Track the app's primary window explicitly - strong reference to prevent deallocation
    var mainWindow: NSWindow?
    
    // Prevent concurrent window creation attempts
    private var isCreatingWindow = false
    private let windowCreationQueue = DispatchQueue(label: "com.cliovoice.windowCreation", qos: .userInitiated)
    
    // One-per-launch guard to avoid fighting the user
    private var didApplyDefaultSizeThisLaunch = false
    
    private init() {}
    
    func configureWindow(_ window: NSWindow) {
        print("🪟 [WINDOW] Configuring window: \(window.title)")
        
        // CRITICAL: Prevent duplicate windows at the earliest possible point
        if self.mainWindow != nil && self.mainWindow !== window {
            print("⚠️ [WINDOW] BLOCKING duplicate window creation! Existing: \(self.mainWindow?.title ?? "nil"), Blocking: \(window.title)")
            // AGGRESSIVE: Close the duplicate window immediately
            DispatchQueue.main.async {
                window.close()
            }
            return
        }
        
        // CRITICAL: Check if this exact window is already configured
        if window.identifier?.rawValue == "MainAppWindow" && self.mainWindow === window {
            print("🪟 [WINDOW] Window already fully configured, skipping: \(window.title)")
            return
        }
        
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        // Remove the thin separator line between titlebar and content
        if #available(macOS 13.0, *) {
            window.titlebarSeparatorStyle = .none
        }
        window.styleMask.insert(.fullSizeContentView)
        window.backgroundColor = .windowBackgroundColor
        window.isReleasedWhenClosed = false
        window.title = "Clio"

        // Debug window chrome state
        #if DEBUG
        let hasToolbar = window.toolbar != nil
        let showsBaseline = window.toolbar?.showsBaselineSeparator ?? false
        if #available(macOS 13.0, *) {
            print("🔧 [WINDOW CFG] transparent=\(window.titlebarAppearsTransparent) hiddenTitle=\(window.titleVisibility == .hidden) fullSize=\(window.styleMask.contains(.fullSizeContentView)) sep=\(String(describing: window.titlebarSeparatorStyle)) toolbar=\(hasToolbar) baseline=\(showsBaseline)")
        } else {
            print("🔧 [WINDOW CFG] transparent=\(window.titlebarAppearsTransparent) hiddenTitle=\(window.titleVisibility == .hidden) fullSize=\(window.styleMask.contains(.fullSizeContentView)) toolbar=\(hasToolbar) baseline=\(showsBaseline)")
        }
        #endif
        
        // Add additional window configuration for better state management
        window.collectionBehavior = [.fullScreenPrimary]
        
        // Ensure proper window level and ordering
        window.level = .normal
        window.orderFrontRegardless()

        // Mark and retain reference to main app window for reliable focusing later
        window.identifier = NSUserInterfaceItemIdentifier("MainAppWindow")
        
        // Set main window reference on first configuration
        if self.mainWindow == nil {
            self.mainWindow = window
            print("🪟 [WINDOW] Set main window reference: \(window.title)")
        } else {
            print("🪟 [WINDOW] Same window already configured: \(window.title)")
        }
        
        // Log initial size for verification
        let frame = window.frame
        let contentSize = window.contentRect(forFrameRect: frame).size
        print("📐 [WINDOW CFG] initial frame=\(Int(frame.width))x\(Int(frame.height)) content=\(Int(contentSize.width))x\(Int(contentSize.height))")
    }
    
    func createMainWindow(contentView: NSView) -> NSWindow {
        // Use a standard size that fits well on most displays
        let defaultSize = NSSize(width: 1000, height: 700)
        
        // Get the main screen frame to help with centering
let screenFrame = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1000, height: 600)
        
        // Create window with centered position
        let xPosition = (screenFrame.width - defaultSize.width) / 2 + screenFrame.minX
        let yPosition = (screenFrame.height - defaultSize.height) / 2 + screenFrame.minY
        
        let window = NSWindow(
            contentRect: NSRect(x: xPosition, y: yPosition, width: defaultSize.width, height: defaultSize.height),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        configureWindow(window)
        window.contentView = contentView
        
        // Set up window delegate to handle window state changes
        let delegate = WindowStateDelegate()
        window.delegate = delegate
        // Retain strongly to match NSWindow's weak delegate
        self.mainWindowDelegate = delegate
        
        return window
    }

    /// Ensure main window exists and bring it to the foreground
    func ensureAndActivateMainWindow() {
        print("🪟 [WINDOW] ensureAndActivateMainWindow called")
        
        // Check if we're already in the process of creating a window
        windowCreationQueue.sync {
            if isCreatingWindow {
                print("🪟 [WINDOW] Window creation already in progress, waiting...")
                return
            }
            isCreatingWindow = true
        }
        
        defer {
            windowCreationQueue.sync {
                isCreatingWindow = false
            }
        }
        
        let window = ensureMainWindow()
        
        #if DEBUG
        assert(mainWindow != nil, "Main window should exist after ensureMainWindow()")
        #endif
        
        activateWindow(window)
    }
    
    /// Guarantee main window exists, creating if necessary
    @discardableResult
    private func ensureMainWindow() -> NSWindow {
        print("🪟 [WINDOW] ensureMainWindow called - checking existing windows...")
        
        if let existingWindow = mainWindow, existingWindow.isVisible || !existingWindow.isVisible {
            print("🪟 [WINDOW] Using tracked main window: \(existingWindow.title)")
            return existingWindow
        }
        
        // Look for existing main window by identifier
        if let existingWindow = NSApp.windows.first(where: { $0.identifier?.rawValue == "MainAppWindow" }) {
            mainWindow = existingWindow
            print("🪟 [WINDOW] Found existing main window by ID: \(existingWindow.title)")
            return existingWindow
        }
        
        // Look for any window that looks like our main window
        let candidateWindows = NSApp.windows.filter { window in
            return window.title == "Clio" || window.titleVisibility == .hidden
        }
        
        if let candidate = candidateWindows.first {
            mainWindow = candidate
            candidate.identifier = NSUserInterfaceItemIdentifier("MainAppWindow")
            print("🪟 [WINDOW] Found candidate main window: \(candidate.title)")
            return candidate
        }
        
        // Count all windows for debugging
        let allWindows = NSApp.windows
        print("🪟 [WINDOW] Total windows: \(allWindows.count)")
        for (index, window) in allWindows.enumerated() {
            print("   Window \(index): '\(window.title)' ID:\(window.identifier?.rawValue ?? "nil") visible:\(window.isVisible)")
        }
        
        // If no window exists, we have a problem - the app should have created the main window
        // This should not happen in normal flow, but let's handle it gracefully
        print("⚠️ [WINDOW] No main window found - this indicates an app lifecycle issue")
        
        // Return the first available window as fallback
        if let fallbackWindow = NSApp.windows.first {
            mainWindow = fallbackWindow
            fallbackWindow.identifier = NSUserInterfaceItemIdentifier("MainAppWindow")
            print("🪟 [WINDOW] Using fallback window: \(fallbackWindow.title)")
            return fallbackWindow
        }
        
        // This should never happen, but create a minimal window as last resort
        fatalError("No windows available and cannot create new window without environment objects")
    }
    
    /// Activate and focus the given window
    private func activateWindow(_ window: NSWindow) {
        print("🪟 [WINDOW] Activating window: \(window.title)")
        
        // Make absolutely sure the application is visible and allowed to front
        NSApp.unhide(nil)
        NSApplication.shared.activate(ignoringOtherApps: true)

        if window.isMiniaturized {
            window.deminiaturize(nil)
        }
        
        // Make the window visible first
        window.orderFrontRegardless()
        
        // Set window level to ensure it appears above other windows
        let originalLevel = window.level
        window.level = .floating
        
        // Only attempt to make key on a window that can become key
        if window.canBecomeKey {
            window.makeKeyAndOrderFront(nil)
        }
        
        // Reset to original level after a brief moment
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            window.level = originalLevel
        }
    }
    
    /// Apply the default preferred content size once per app launch, if the window is currently larger.
    /// This ensures the app opens smaller on first show while respecting user resizes afterwards.
    func applyDefaultMainWindowSizeIfNeeded(width: CGFloat = 1000, height: CGFloat = 700) {
        guard !didApplyDefaultSizeThisLaunch, let window = mainWindow else { return }
        let frameBefore = window.frame
        let currentContentSize = window.contentRect(forFrameRect: frameBefore).size
        let target = NSSize(width: width, height: height)
        print("📐 [WINDOW SIZE] before apply frame=\(Int(frameBefore.width))x\(Int(frameBefore.height)) content=\(Int(currentContentSize.width))x\(Int(currentContentSize.height)) target=\(Int(target.width))x\(Int(target.height))")

        // Only shrink if currently larger than target; never force grow (note: width may increase if height is shrunk)
        if currentContentSize.width > target.width + 1 || currentContentSize.height > target.height + 1 {
            // Temporarily clamp content size to survive SwiftUI's initial re-measure
            let prevMin = window.contentMinSize
            let prevMax = window.contentMaxSize
            window.contentMinSize = target
            window.contentMaxSize = target
            print("📐 [WINDOW SIZE] temporarily clamped min/max to \(Int(target.width))x\(Int(target.height))")

            window.setContentSize(target)
            window.center()
            let frameAfter = window.frame
            let newContentSize = window.contentRect(forFrameRect: frameAfter).size
            print("📐 [WINDOW SIZE] applied frame=\(Int(frameAfter.width))x\(Int(frameAfter.height)) content=\(Int(newContentSize.width))x\(Int(newContentSize.height))")

            // Relax the clamp after the first layout pass settles
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let restoredMin = WindowManager.adjustedMinSize(previous: prevMin, target: target)
                let restoredMax = WindowManager.adjustedMaxSize(previous: prevMax, target: target)
                window.contentMinSize = restoredMin
                window.contentMaxSize = restoredMax
                // Run one more resize now that onboarding/update views are gone
                window.setContentSize(target)
                window.center()
                let minW = restoredMin.width.isFinite ? String(Int(restoredMin.width)) : "inf"
                let minH = restoredMin.height.isFinite ? String(Int(restoredMin.height)) : "inf"
                let maxW = restoredMax.width.isFinite ? String(Int(restoredMax.width)) : "inf"
                let maxH = restoredMax.height.isFinite ? String(Int(restoredMax.height)) : "inf"
                print("📐 [WINDOW SIZE] released clamp; restored min=\(minW)x\(minH) max=\(maxW)x\(maxH)")
            }
        } else {
            print("📐 [WINDOW SIZE] no change (<= target)")
        }
        didApplyDefaultSizeThisLaunch = true
    }

    /// Allow the default-size helper to run again during the current launch.
    /// Useful when a large temporary flow (onboarding/update) completes and we need
    /// to re-apply the compact main window size once the main content becomes active.
    func resetDefaultSizeForNextTransition() {
        didApplyDefaultSizeThisLaunch = false
    }

    private static func adjustedMinSize(previous: NSSize, target: NSSize) -> NSSize {
        var newSize = previous
        if previous.width.isFinite && previous.width > target.width {
            newSize.width = target.width
        }
        if previous.height.isFinite && previous.height > target.height {
            newSize.height = target.height
        }
        return newSize
    }

    private static func adjustedMaxSize(previous: NSSize, target: NSSize) -> NSSize {
        var newSize = previous
        if previous.width.isFinite && previous.width < target.width {
            newSize.width = target.width
        }
        if previous.height.isFinite && previous.height < target.height {
            newSize.height = target.height
        }
        return newSize
    }
}

// Add window delegate to handle window state changes
class WindowStateDelegate: NSObject, NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        guard let window = notification.object as? NSWindow else { return }
        // Clear main window reference if this is the main window being closed
        if window.identifier?.rawValue == "MainAppWindow" {
            WindowManager.shared.mainWindow = nil
        }
        // Ensure window is properly hidden when closed
        window.orderOut(nil)
    }
    
    func windowDidBecomeKey(_ notification: Notification) {
        // Ensure window is properly activated
        guard let window = notification.object as? NSWindow else { return }
        NSApp.activate(ignoringOtherApps: true)
        
        // Re-apply separator suppression; SwiftUI/AppKit may reset it
        if #available(macOS 13.0, *) {
            window.titlebarSeparatorStyle = .none
            #if DEBUG
            print("📐 [BECAME KEY] Reapplied titlebarSeparatorStyle=.none -> now=\(String(describing: window.titlebarSeparatorStyle))")
            #endif
        }
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden

        // Log for debugging menu bar activation issues
        print("🪟 [WINDOW] Window became key: \(window.title)")
    }
}
