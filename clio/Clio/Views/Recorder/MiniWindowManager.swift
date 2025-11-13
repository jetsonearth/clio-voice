import SwiftUI
import AppKit

class MiniWindowManager: ObservableObject {
    @Published var isVisible = false
    private var windowController: NSWindowController?
    private var miniPanel: MiniRecorderPanel?
    private let recordingEngine: RecordingEngine
    private let recorder: Recorder
    
    var window: NSWindow? {
        return miniPanel
    }
    
    init(recordingEngine: RecordingEngine, recorder: Recorder) {
        self.recordingEngine = recordingEngine
        self.recorder = recorder
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleHideNotification),
            name: NSNotification.Name("HideMiniRecorder"),
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func handleHideNotification() {
        hide()
    }
    
    func show() {
        if isVisible { return }

        // Prefer front-most application's screen, then mouse location, then key window, then main.
        let activeScreen = screenForFrontmostApplication()
            ?? {
                let mouseLocation = NSEvent.mouseLocation
                return NSScreen.screens.first(where: { $0.frame.contains(mouseLocation) })
            }()
            ?? NSApp.keyWindow?.screen
            ?? NSScreen.main
            ?? NSScreen.screens[0]

        Task { @MainActor in
            initializeWindow(screen: activeScreen)
            self.isVisible = true
            miniPanel?.show(on: activeScreen, streamingTranscriptEnabled: recordingEngine.isStreamingTranscriptEnabled)
        }
    }
    
    func showAlwaysOn() {
        // Show the always-on small oval without triggering RecordingEngine visibility logic
        // This prevents the race condition in toggleMiniRecorder
        
        let activeScreen = screenForFrontmostApplication()
            ?? {
                let mouseLocation = NSEvent.mouseLocation
                return NSScreen.screens.first(where: { $0.frame.contains(mouseLocation) })
            }()
            ?? NSApp.keyWindow?.screen
            ?? NSScreen.main
            ?? NSScreen.screens[0]

        Task { @MainActor in
            initializeWindow(screen: activeScreen)
            // Set isVisible so the window manager knows it exists, but this doesn't trigger
            // RecordingEngine.isMiniRecorderVisible because we call this before that flag is set
            self.isVisible = true
            miniPanel?.show(on: activeScreen, streamingTranscriptEnabled: recordingEngine.isStreamingTranscriptEnabled)
        }
    }
    
    func hide() {
        guard isVisible else { return }
        
        self.isVisible = false
        
        // Delay window hiding to allow SwiftUI animation to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
            self?.miniPanel?.hide { [weak self] in
                guard let self = self else { return }
                self.deinitializeWindow()
            }
        }
    }
    
    @MainActor
    private func initializeWindow(screen: NSScreen) {
        deinitializeWindow()
        
        let metrics = MiniRecorderPanel.calculateWindowMetrics(for: screen, streamingTranscriptEnabled: recordingEngine.isStreamingTranscriptEnabled)
        let panel = MiniRecorderPanel(contentRect: metrics)
        
        let miniRecorderView = MiniRecorderView(
            recordingEngine: recordingEngine,
            recorder: recorder,
            audioLevel: recordingEngine.audioLevel
        )
            .environmentObject(self)
        
        let hostingController = NSHostingController(rootView: miniRecorderView)
        panel.contentView = hostingController.view
        
        self.miniPanel = panel
        self.windowController = NSWindowController(window: panel)
        
        panel.orderFrontRegardless()
    }
    
    private func deinitializeWindow() {
        windowController?.close()
        windowController = nil
        miniPanel = nil
    }
    
    func toggle() {
        if isVisible {
            hide()
        } else {
            show()
        }
    }
    
    @MainActor
    func applyMode(streamingTranscriptEnabled: Bool) {
        guard let panel = miniPanel else { return }
        let screen = panel.screen
            ?? screenForFrontmostApplication()
            ?? NSScreen.main
            ?? NSScreen.screens.first!
        let rect = MiniRecorderPanel.calculateWindowMetrics(
            for: screen,
            streamingTranscriptEnabled: streamingTranscriptEnabled
        )
        panel.setFrame(rect, display: true)
        panel.orderFrontRegardless()
    }
    
    @MainActor
    func reposition(to screen: NSScreen) {
        guard let panel = miniPanel else { return }
        let metrics = MiniRecorderPanel.calculateWindowMetrics(
            for: screen,
            streamingTranscriptEnabled: recordingEngine.isStreamingTranscriptEnabled
        )
        panel.setFrame(metrics, display: true)
    }
    
    @MainActor
    func updatePosition() {
        let screen = screenForFrontmostApplication()
            ?? {
                let mouseLocation = NSEvent.mouseLocation
                return NSScreen.screens.first(where: { $0.frame.contains(mouseLocation) })
            }()
            ?? NSApp.keyWindow?.screen
            ?? NSScreen.main
        reposition(to: screen!)
    }
    
    /// Attempt to detect the NSScreen that contains the front-most application’s key window
    private func screenForFrontmostApplication() -> NSScreen? {
        guard let frontApp = NSWorkspace.shared.frontmostApplication else { return nil }
        let pid = frontApp.processIdentifier

        // Query window list for windows belonging to frontmost app
        let options: CGWindowListOption = [.optionOnScreenOnly, .excludeDesktopElements]
        if let windowInfos = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] {
            for info in windowInfos {
                if let ownerPID = info[kCGWindowOwnerPID as String] as? pid_t, ownerPID == pid,
                   let boundsDict = info[kCGWindowBounds as String] as? NSDictionary,
                   let bounds = CGRect(dictionaryRepresentation: boundsDict) {
                    // Find NSScreen whose frame contains window centre
                    let center = CGPoint(x: bounds.midX, y: bounds.midY)
                    if let match = NSScreen.screens.first(where: { $0.frame.contains(center) }) {
                        return match
                    }
                }
            }
        }
        return nil
    }
} 