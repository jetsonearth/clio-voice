import SwiftUI
import AppKit


/// DynamicNotchKit-based window manager that replaces NotchWindowManager
/// This provides the same functionality while using the MIT-licensed DynamicNotchKit
/// Only uses compact mode (elongated notch) - never shows expanded dropdown
class DynamicNotchWindowManager: ObservableObject {
    @Published var isVisible = false
    private let whisperState: WhisperState
    private let recorder: Recorder
    private var escapeGlobalMonitor: Any?
    private var escapeLocalMonitor: Any?
    
    // DynamicNotch instance - handles its own window management
    private var notch: DynamicNotch<ExpandedContent, CompactContent, CompactTrailingContent, CompactBottomContent>?
    private var targetScreen: NSScreen? // Lock to screen where mouse was when recording started
    
    init(whisperState: WhisperState, recorder: Recorder) {
        self.whisperState = whisperState
        self.recorder = recorder
    }
    
    @MainActor var window: NSWindow? {
        // Expose the underlying NSWindow so other components (e.g., confirmation sheets) can anchor to it
        return notch?.windowController?.window
    }
    
    deinit {
        removeEscapeMonitors()
    }
    
    @MainActor
    func show() async {
        if isVisible {
            // print("🔍 [DYNAMIC NOTCH DEBUG] Already visible, skipping show()")
            return
        }

        let metrics = TimingMetrics.shared
        metrics.markNotchShowCall()
        var showFields: [String: Any] = [:]
        if let mode = metrics.notchMode { showFields["mode"] = mode }
        if let intentTs = metrics.notchIntentTs, let showTs = metrics.notchShowCallTs, let delta = metrics.deltaMs(from: intentTs, to: showTs) {
            showFields["intent_to_show_call_ms"] = delta
        }
        StructuredLog.shared.log(cat: .ui, evt: "notch_show_call", lvl: .info, showFields)

        // print("🔍 [DYNAMIC NOTCH DEBUG] Showing notch...")
        DebugLogger.debug("perf:notch_show", category: .performance)
        
        // Clear any residual transcript state so new sessions start clean
        self.clearTranscriptState()
        
        // Create DynamicNotch if it doesn't exist - copy exact pattern from working test app
        if notch == nil {
            notch = DynamicNotch(style: .notch) {
                ExpandedContent(recorder: self.recorder, whisperState: self.whisperState)
            } compactLeading: {
                CompactContent(recorder: self.recorder, whisperState: self.whisperState)
            } compactTrailing: {
                CompactTrailingContent()
            } compactBottom: {
                CompactBottomContent(whisperState: self.whisperState)
            }
            // Apply keep-alive policy if configured
            notch?.keepAlive = RuntimeConfig.notchKeepAliveEnabled
        }
        
        self.isVisible = true
        // Keep system warm (no WebSocket preconnect during quick tap)
        // Run off the immediate main-actor path to avoid any chance of delaying first pixels.
        Task.detached {
            await MainActor.run { WarmupCoordinator.shared.ensureReady(.recorderUIShown) }
        }
        
        // Use mouse-following behavior (original logic) but apply built-in notch size
        if let screenWithMouse = self.screenUnderMouse() {
            self.targetScreen = screenWithMouse
            // print("🔍 [DYNAMIC NOTCH DEBUG] Using screen under mouse (preserving mouse-following)")
        } else {
            self.targetScreen = NSScreen.main ?? NSScreen.screens.first
            // print("🔍 [DYNAMIC NOTCH DEBUG] Fallback to main screen")
        }
        let screen = self.targetScreen
        
        // Apply user preference for bottom transcript under the Notch (default ON)
        let transcriptEnabled = (UserDefaults.standard.object(forKey: "NotchTranscriptEnabled") as? Bool) ?? true
        let finalDisableBottom = !transcriptEnabled
        notch?.disableCompactBottom = finalDisableBottom
        
        // Show in compact mode (elongated notch) on the chosen screen
        if let screen = screen, let notch = notch {
            // Remove UI debounce so animation begins at t=0 on key down
            await notch.compact(on: screen)
        } else if let notch = notch {
            await notch.compact()
        }

        let shownDeltas = metrics.markNotchShown()
        var shownFields: [String: Any] = [:]
        if let mode = metrics.notchMode { shownFields["mode"] = mode }
        if let intentMs = shownDeltas.intentToShowMs { shownFields["intent_to_shown_ms"] = intentMs }
        if let showMs = shownDeltas.showCallToShowMs { shownFields["show_call_to_shown_ms"] = showMs }
        StructuredLog.shared.log(cat: .ui, evt: "notch_shown", lvl: .info, shownFields)
        
        // Setup escape key monitoring
        self.setupEscapeMonitors()
        
        // print("🔍 [DYNAMIC NOTCH DEBUG] Showed notch in compact mode")
    }

    /// Pre-initialize the notch window (hidden) to remove first-show creation cost.
    @MainActor
    func prewarm() async {
        if notch == nil {
            notch = DynamicNotch(style: .notch) {
                ExpandedContent(recorder: self.recorder, whisperState: self.whisperState)
            } compactLeading: {
                CompactContent(recorder: self.recorder, whisperState: self.whisperState)
            } compactTrailing: {
                CompactTrailingContent()
            } compactBottom: {
                CompactBottomContent(whisperState: self.whisperState)
            }
            notch?.keepAlive = RuntimeConfig.notchKeepAliveEnabled
        }
        let screen = self.screenUnderMouse() ?? NSScreen.main ?? NSScreen.screens.first!
        await notch?.prewarm(on: screen)
    }

    // MARK: - Helpers

    private func screenUnderMouse() -> NSScreen? {
        let mouseLocation = NSEvent.mouseLocation
        for screen in NSScreen.screens {
            if NSMouseInRect(mouseLocation, screen.frame, false) {
                return screen
            }
        }
        return nil
    }
    
    @MainActor
    func hide(force: Bool = false) {
        guard isVisible else { return }
        
        // Do not hide while a recording session is active or starting/stopping unless forced
        if !force && (whisperState.isRecording || whisperState.isAttemptingToRecord || whisperState.isProcessing) {
            // print("🛑 [DYNAMIC NOTCH DEBUG] hide() ignored – session active or in transition")
            return
        }
        
        // print("🔍 [DYNAMIC NOTCH DEBUG] Hiding notch...")
        
        self.isVisible = false
        removeEscapeMonitors()
        
        // Hide the notch completely - exact same pattern as working test app
        notch?.hideDebounced()
        // print("🔍 [DYNAMIC NOTCH DEBUG] Hidden notch")
    }
    
    private func setupEscapeMonitors() {
        removeEscapeMonitors()
        
        // Global monitor to catch ESC even when app is not key (matches GPL version)
        escapeGlobalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self = self else { return }
            if event.keyCode == 53 { // ESC key
                Task { @MainActor in
                    if self.isVisible && self.whisperState.isRecording {
                        self.handleEscapeKey(event)
                    }
                }
            }
        }
        
        // Local monitor when app is foreground (matches GPL version)
        escapeLocalMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self = self else { return event }
            if event.keyCode == 53 && self.isVisible && self.whisperState.isRecording {
                self.handleEscapeKey(event)
                return nil // consume the event
            }
            return event
        }
    }
    
    private func handleEscapeKey(_ event: NSEvent) {
        guard event.keyCode == 53 else { return } // ESC key
        
        Task { @MainActor in
            if isVisible && whisperState.isRecording {
                // Cancel recording immediately
                whisperState.isProcessing = false
                whisperState.isVisualizerActive = false
                whisperState.isRecording = false
                whisperState.shouldCancelRecording = true
                whisperState.isAttemptingToRecord = false
                
                // Dismiss and cleanup using existing Clio logic
                await whisperState.dismissRecorder()
                
                // Play cancel sound after cleanup (matches GPL timing)
                SoundManager.shared.playEscSound()
            }
        }
    }
    
    @MainActor
    func applyBottomTranscriptPreference(_ enabled: Bool) {
        notch?.disableCompactBottom = !enabled
    }
    
    private func removeEscapeMonitors() {
        if let monitor = escapeGlobalMonitor { 
            NSEvent.removeMonitor(monitor)
            escapeGlobalMonitor = nil 
        }
        if let monitor = escapeLocalMonitor { 
            NSEvent.removeMonitor(monitor) 
            escapeLocalMonitor = nil 
        }
    }
    
    @MainActor
    func toggle() async {
        if isVisible {
            hide()
        } else {
            await show()
        }
    }
    
    // Passive renderer: show when session is non-idle; hide when idle
    @MainActor
    func render(sessionState: WhisperState.SessionState) async {
        switch sessionState {
        case .idle:
            hide(force: true)
        default:
            await show()
        }
    }
    
    // Ensure previous session text does not leak into a new recording UI session
    @MainActor private func clearTranscriptState() {
        // Clear WhisperState combined sources
        whisperState.streamingFinalText = ""
        whisperState.streamingPartialText = ""
        
        // Clear direct Soniox service buffers used by CompactBottomContent fallback
        whisperState.sonioxStreamingService.finalBuffer = ""
        whisperState.sonioxStreamingService.partialTranscript = ""
    }
}

/// ExpandedContent - Not used in our implementation (we only use compact mode)
/// Kept for compatibility but never shown
struct ExpandedContent: View {
    @ObservedObject var recorder: Recorder
    @ObservedObject var whisperState: WhisperState
    var body: some View {
        HStack(spacing: 8) {
            RecordingVisualizerView(
                recorder: recorder,
                whisperState: whisperState,
                isActive: whisperState.isVisualizerActive || whisperState.isRecording || whisperState.isProcessing
            )
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }
}

/// Left side of compact notch - shows recording status
struct CompactContent: View {
    @ObservedObject var recorder: Recorder
    @ObservedObject var whisperState: WhisperState
    var body: some View {
        // Match trailing side width and align to the leading edge so the visualizer hugs the left margin
        let leadingWidth: CGFloat = 66
        // Visualizer is fixed at 60pt wide; the remaining region is for the lock
        let lockRegionWidth: CGFloat = max(0, leadingWidth - 60)
        let lockPillWidth: CGFloat = 22 // make background oval (wider than height)
        let desiredGap: CGFloat = 0 // 0 = flush; positive = gap; negative = deeper overlap
        // Compute leftward overlap; clamp so we never overrun beyond the visualizer region
        let computedOverlap = -(max(0, lockPillWidth - desiredGap - lockRegionWidth))
        let maxSafeOverlap = -(lockPillWidth - lockRegionWidth) // fully flush; do not exceed
        let lockOffsetX: CGFloat = max(computedOverlap, maxSafeOverlap)
        
        HStack(spacing: 0) {
            RecordingVisualizerView(
                recorder: recorder,
                whisperState: whisperState,
                isActive: whisperState.isVisualizerActive || whisperState.isRecording || whisperState.isProcessing
            )
            
            // Right-side lock region sized to remaining width, lock overlaps into visualizer by a few points
            ZStack(alignment: .trailing) {
                if whisperState.isHandsFreeLocked && whisperState.isRecording {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: lockPillWidth, height: 14, alignment: .center)
                        .background(Color.white.opacity(0.15))
                        .clipShape(Capsule())
                        .offset(x: lockOffsetX)
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .frame(width: lockRegionWidth, height: 14, alignment: .trailing)
            .allowsHitTesting(false)
        }
        .frame(width: leadingWidth, height: 14, alignment: .leading)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }
}

/// Right side of compact notch - shows stop instruction
struct CompactTrailingContent: View {
    // Mirror the leading width so both sides feel balanced
    private let mirrorWidth: CGFloat = 66
    var body: some View {
        HStack(spacing: 6) {
            Spacer(minLength: 0)
            Circle()
                .fill(Color.white.opacity(0.15))
                .frame(width: 8, height: 8)
        }
        .frame(width: mirrorWidth, height: 14, alignment: .trailing)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }
}

/// Bottom row of compact notch - shows persistent streaming transcript with ethereal animations
struct CompactBottomContent: View {
    @ObservedObject var whisperState: WhisperState
    @State private var scrollOffset: CGFloat = 0
    @State private var textWidth: CGFloat = 0
    @State private var containerWidth: CGFloat = 0
    @State private var displayedText: String = ""
    @State private var animationOpacity: Double = 0.0
    @State private var previousTextLength: Int = 0
    @State private var shouldAnimateScroll: Bool = true
    
    // Combine final + partial text for persistence
    private var combinedText: String {
        let final = whisperState.streamingFinalText
        let partial = whisperState.streamingPartialText
        
        if !final.isEmpty && !partial.isEmpty {
            return joinFinalAndPartial(final: final, partial: partial)
        } else if !final.isEmpty {
            return final
        } else if !partial.isEmpty {
            return partial
        } else {
            // Fallback to direct Soniox streams
            let directFinal = whisperState.sonioxStreamingService.finalBuffer
            let directPartial = whisperState.sonioxStreamingService.partialTranscript
            
            if !directFinal.isEmpty && !directPartial.isEmpty {
                return joinFinalAndPartial(final: directFinal, partial: directPartial)
            } else if !directFinal.isEmpty {
                return directFinal
            } else {
                return directPartial
            }
        }
    }
    
    // Insert a boundary space only when truly needed.
    // Rules:
    // - If partial already begins with whitespace, do not add anything.
    // - If both sides are alphanumeric, add a single space (except for CJK boundaries).
    // - Otherwise, concatenate as-is.
    private func joinFinalAndPartial(final: String, partial: String) -> String {
        // Single-row compact display: rely on the ASR to provide correct spacing.
        // Do not synthesize a margin. Only collapse double spaces if both sides provide one.
        if final.isEmpty || partial.isEmpty { return final + partial }
        let finalEndsSpace = final.last?.isWhitespace == true
        let partialStartsSpace = partial.first?.isWhitespace == true
        if finalEndsSpace && partialStartsSpace {
            // Collapse duplicate boundary whitespace (keep the one from final).
            let trimmedPartial = String(partial.drop(while: { $0.isWhitespace }))
            return final + trimmedPartial
        }
        // Otherwise, just concatenate as-is (no extra space injected)
        return final + partial
    }
    
    private var isSessionActive: Bool {
        whisperState.isRecording || whisperState.isProcessing || whisperState.isAttemptingToRecord
    }
    
    private var isEnhancementPending: Bool {
        // Start shimmering immediately when recording stops and processing begins (no text dependency)
        (!whisperState.isRecording) && whisperState.isProcessing
    }
    
    var body: some View {
        if combinedText.isEmpty {
            // Show a tasteful listening indicator while waiting for first tokens
            ListeningPlaceholderView(isActive: isSessionActive)
                .frame(height: 16)
                .transition(.opacity)
        } else {
            GeometryReader { geometry in
                let availableWidth = geometry.size.width // No internal padding needed - handled by parent
                
                HStack(spacing: 0) {
                    Text(displayedText)
                        .font(.system(size: 11.5, weight: .medium))
                        .foregroundColor(.white)
                        .opacity(animationOpacity * 0.85) // Ethereal fade effect with softer opacity
                        .blur(radius: animationOpacity < 1 ? 4 : 0) // Soft blur fading away as it appears
                        .lineLimit(1)
                        .textSelection(.disabled)
                        .fixedSize() // Let text determine its natural size
                        // .shimmeringIfAvailable(active: isEnhancementPending)
                        .background(
                            // Invisible background to measure text width
                            GeometryReader { textGeometry in
                                Color.clear
                                    .onAppear {
                                        textWidth = textGeometry.size.width
                                        containerWidth = availableWidth
                                        updateScrollOffset()
                                    }
                                    .onChange(of: textGeometry.size.width) { newWidth in
                                        textWidth = newWidth
                                        updateScrollOffset()
                                    }
                                    .onChange(of: availableWidth) { newContainerWidth in
                                        containerWidth = newContainerWidth
                                        updateScrollOffset()
                                    }
                            }
                        )
                        .offset(x: scrollOffset)
                        .animation(shouldAnimateScroll ? .easeInOut(duration: 0.6) : nil, value: scrollOffset) // Smooth when desired; snap otherwise
                        .animation(.easeOut(duration: 1.0), value: animationOpacity) // Gentler ethereal fade animation
                    
                    Spacer(minLength: 0)
                }
            }
            .frame(height: 16) // Fixed height for text
            .clipped() // Hard clip any overflow beyond container
            .onChange(of: combinedText) { newText in
                handleTextChange(newText)
            }
            .onChange(of: whisperState.isProcessing) { _ in
                // During recording→processing transition, avoid lateral shifts by snapping
                shouldAnimateScroll = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    shouldAnimateScroll = true
                }
            }
            .onAppear {
                // Initialize with ethereal fade-in
                displayedText = combinedText
                animationOpacity = 0.0
                etherealFadeIn()
            }
        }
    }
    
    private func handleTextChange(_ newText: String) {
        let newLength = newText.count
        
        if newText.isEmpty {
            // Text cleared - ethereal fade out
            etherealFadeOut {
                displayedText = ""
            }
        } else if newLength > previousTextLength {
            // Text added/extended - update and fade in new content
            displayedText = newText
            etherealFadeIn()
            
            // Update scroll position smoothly
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                updateScrollOffset()
            }
        } else {
            // Text changed/replaced - brief ethereal transition
            displayedText = newText
            etherealFadeIn()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                updateScrollOffset()
            }
        }
        
        previousTextLength = newLength
    }
    
    private func etherealFadeIn() {
        withAnimation(.easeOut(duration: 1.0).delay(0.1)) {
            animationOpacity = 1.0
        }
    }
    
    private func etherealFadeOut(completion: @escaping () -> Void = {}) {
        withAnimation(.easeIn(duration: 0.4)) {
            animationOpacity = 0.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            completion()
        }
    }
    
    private func updateScrollOffset() {
        guard containerWidth > 0 && textWidth > 0 else { return }
        
        let target: CGFloat = (textWidth <= containerWidth) ? 0 : (containerWidth - textWidth)
        // If the target moves to the right (becomes less negative), snap without animation to avoid bounce.
        if target > scrollOffset {
            let wasAnimating = shouldAnimateScroll
            shouldAnimateScroll = false
            scrollOffset = target
            // Re-enable animation on next runloop turn to allow future leftward (extend) animations
            DispatchQueue.main.async {
                shouldAnimateScroll = wasAnimating || true
            }
        } else {
            // Leftward movement (more negative) feels natural to animate
            shouldAnimateScroll = true
            scrollOffset = target
        }
    }
}

// "Speak now..." text with gentle pulse shown while waiting for first streaming tokens
private struct ListeningPlaceholderView: View {
    let isActive: Bool
    @State private var dotCount: Int = 1
    
    var body: some View {
        HStack(spacing: 0) {
            Text("I'm listening, speak freely")
                .font(.system(size: 11.5, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
            
            Text(String(repeating: ".", count: dotCount))
                .font(.system(size: 11.5, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
                .frame(width: 20, alignment: .leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .onAppear { startDotAnimation() }
        .onDisappear { stopDotAnimation() }
    }
    
    private func startDotAnimation() {
        guard isActive else { return }
        
        Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { timer in
            guard isActive else {
                timer.invalidate()
                return
            }
            
            withAnimation(.easeInOut(duration: 0.2)) {
                dotCount = dotCount == 3 ? 1 : dotCount + 1
            }
        }
    }
    
    private func stopDotAnimation() {
        dotCount = 1
    }
}

// MARK: - Character utilities (duplicated minimal CJK check for boundary spacing)
private extension Character {
    var isCJK: Bool {
        guard let scalar = unicodeScalars.first else { return false }
        switch scalar.value {
        case 0x4E00...0x9FFF,      // CJK Unified Ideographs
             0x3400...0x4DBF,      // CJK Unified Ideographs Extension A
             0x20000...0x2A6DF,    // Extension B
             0x2A700...0x2B73F,    // Extension C
             0x2B740...0x2B81F,    // Extension D
             0x2B820...0x2CEAF,    // Extension E
             0x2CEB0...0x2EBEF,    // Extension F
             0x3040...0x309F,      // Hiragana
             0x30A0...0x30FF,      // Katakana
             0xAC00...0xD7AF:      // Hangul Syllables
            return true
        default:
            return false
        }
    }
}
