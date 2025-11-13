import SwiftUI
import AppKit

class CancelConfirmationWindow: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
    
    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 180, height: 100),
            styleMask: [.nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        self.isFloatingPanel = true
        self.level = .statusBar + 10 // Above the mini recorder
        self.backgroundColor = .clear
        self.isOpaque = false
        self.contentView?.wantsLayer = true
        self.contentView?.layer?.backgroundColor = NSColor.clear.cgColor
        self.alphaValue = 1.0
        self.hasShadow = true
        self.isMovableByWindowBackground = false
        self.hidesOnDeactivate = false
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle]
        
        self.appearance = NSAppearance(named: .darkAqua)
        self.styleMask.remove(.titled)
        self.titlebarAppearsTransparent = true
        self.titleVisibility = .hidden
        
        self.standardWindowButton(.closeButton)?.isHidden = true
        self.standardWindowButton(.miniaturizeButton)?.isHidden = true
        self.standardWindowButton(.zoomButton)?.isHidden = true
        
        self.ignoresMouseEvents = false
        self.isMovable = false
    }
    
    func showNear(miniRecorder: NSRect) {
        // Ensure we have a valid anchor frame before doing any work
        guard !miniRecorder.isNull && !miniRecorder.isEmpty else {
            // Nothing sensible to anchor to – just abort the presentation
            return
        }

        guard let screen = NSScreen.main else { return }

        // Position the confirmation window above the mini recorder
        let windowWidth: CGFloat = 180
        let windowHeight: CGFloat = 100
        let padding: CGFloat = 8

        let xPosition = miniRecorder.midX - (windowWidth / 2)
        let yPosition = miniRecorder.maxY + padding

        var proposedFrame = NSRect(
            x: xPosition,
            y: yPosition,
            width: windowWidth,
            height: windowHeight
        )

        // Clamp the proposed frame so that it does not fall outside the screen.
        // Using visibleFrame keeps us clear of the Dock / menu bar when possible.
        let bounds = screen.visibleFrame

        // Horizontal clamping
        if proposedFrame.minX < bounds.minX {
            proposedFrame.origin.x = bounds.minX + 10
        } else if proposedFrame.maxX > bounds.maxX {
            proposedFrame.origin.x = bounds.maxX - windowWidth - 10
        }

        // Vertical clamping
        if proposedFrame.maxY > bounds.maxY {
            proposedFrame.origin.y = bounds.maxY - windowHeight - 10
        } else if proposedFrame.minY < bounds.minY {
            proposedFrame.origin.y = bounds.minY + 10
        }

        // As a last resort, bail if the frame is still invalid (should never happen)
        guard proposedFrame.origin.x.isFinite && proposedFrame.origin.y.isFinite else { return }

        setFrame(proposedFrame, display: true)
        orderFrontRegardless()
    }
    
    func hide() {
        orderOut(nil)
    }
}

class CancelConfirmationWindowManager: ObservableObject {
    private var window: CancelConfirmationWindow?
    private var recordingEngine: RecordingEngine
    
    init(recordingEngine: RecordingEngine) {
        self.recordingEngine = recordingEngine
    }
    
    func show(near miniRecorderFrame: NSRect) {
        // Skip if the frame we receive is invalid – avoids downstream crashes
        guard !miniRecorderFrame.isNull && !miniRecorderFrame.isEmpty else { return }

        if window == nil {
            window = CancelConfirmationWindow()
            
            let contentView = CancelConfirmationView(
                onNo: { [weak self] in
                    Task { @MainActor in
                        self?.recordingEngine.showCancelConfirmation = false
                        self?.hide()
                    }
                },
                onYes: { [weak self] in
                    Task { @MainActor in
                        // Hide UI elements immediately - no async needed for instant response
                        self?.recordingEngine.showCancelConfirmation = false
                        self?.hide()
                        
                        // Sound will be played after mic fully stops in dismiss flow
                        
                        // Set immediate UI-only states for instant mini recorder shrinking
                        self?.recordingEngine.isProcessing = false
                        self?.recordingEngine.isVisualizerActive = false
                        self?.recordingEngine.isRecording = false  // For immediate UI shrinking - cleanup uses shouldCancelRecording flag
                        
                        // Run heavy async operations in background without blocking UI
                        self?.recordingEngine.shouldCancelRecording = true
                        self?.recordingEngine.isAttemptingToRecord = false  // Reset attempt flag on cancel
                        Task { await self?.recordingEngine.dismissRecorder() }
                        // Play cancel sound shortly after to keep UX snappy while avoiding pops
                        try? await Task.sleep(nanoseconds: 120_000_000)
                        SoundManager.shared.playEscSound()
                    }
                }
            )
            
            let hostingController = NSHostingController(rootView: contentView)
            hostingController.view.wantsLayer = true
            hostingController.view.layer?.backgroundColor = NSColor.clear.cgColor
            window?.contentViewController = hostingController
        }
        
        window?.showNear(miniRecorder: miniRecorderFrame)
    }
    
    func hide() {
        window?.hide()
        window = nil
    }
}

struct CancelConfirmationView: View {
    let onNo: () -> Void
    let onYes: () -> Void
    @StateObject private var localizationManager = LocalizationManager.shared
    
    var body: some View {
        VStack(spacing: 14) {
            Text(localizationManager.localizedString("recording.stop.confirmation", comment: "Stop recording confirmation"))
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 8) {
                Button(action: onNo) {
                    Text(localizationManager.localizedString("general.no", comment: "No"))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 30)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.white.opacity(0.12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                                )
                        )
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
                
                Button(action: onYes) {
                    Text(localizationManager.localizedString("general.yes", comment: "Yes"))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 30)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.red.opacity(0.9),
                                            Color.red.opacity(0.7)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.red.opacity(0.3), lineWidth: 0.5)
                                )
                        )
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.98),
                            Color.black.opacity(0.92)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.15),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: .black.opacity(0.5), radius: 16, x: 0, y: 6)
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}