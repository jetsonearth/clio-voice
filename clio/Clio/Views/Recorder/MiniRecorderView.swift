import SwiftUI

struct MiniRecorderView: View {
    @ObservedObject var whisperState: WhisperState
    @ObservedObject var recorder: Recorder
    @ObservedObject var audioLevel: AudioLevelPublisher
    @EnvironmentObject var windowManager: MiniWindowManager
    // PowerMode removed
    @State private var isShowing = false
    @State private var hasInitialized = false
    @State private var isExpanded = false
    @State private var showContent = false // controls visualizer visibility after expansion
    @State private var animationScale: CGFloat = 1.0
    
    // Helper to update expansion/content states based on recording & processing flags
    private func refreshVisualState() {
        let wasExpanded = isExpanded
        let shouldExpand = whisperState.isRecording || whisperState.isProcessing || whisperState.isAttemptingToRecord
        
        // Animation is now handled directly in onChange - just update state
        isExpanded = shouldExpand
        
        // Removed bounce animation to prevent laggy expansion conflicts

        if shouldExpand {
            // Just set the state - let the main .animation modifiers handle it
            showContent = true
        } else {
            showContent = false
        }
    }
    
    private func animateRecordingStart() {
        // No animation - just set the scale immediately
        animationScale = 1.0
    }
    
    private func animateRecordingStop() {
        // Ending: spring bounce effect
        withAnimation(.spring(response: 0.22, dampingFraction: 0.8, blendDuration: 0)) {
            animationScale = 1.0
        }
    }
    
    private func animateBounce() {
        // Disabled to prevent startup animation conflicts
        animationScale = 1.0
    }
    
    private func getHeight() -> CGFloat {
        if !isExpanded {
            return 10 // Collapsed state - slightly taller
        } else if whisperState.isProcessing {
            return 10 // Thin bar for transcribing - slightly taller
        } else if whisperState.isStreamingTranscriptEnabled {
            return 160 // 24px top + 112px content (6 lines) + 24px bottom = 160px total
        } else {
            return 32 // Full height for wave visualizer recording
        }
    }
    
    private func getWidth() -> CGFloat {
        if !isExpanded {
            return 40 // Collapsed state
        } else if whisperState.isStreamingTranscriptEnabled && !whisperState.isProcessing {
            return 320 // Wider for streaming transcript with elegant padding
        } else {
            return 95 // Standard width for wave visualizer
        }
    }
    
    var body: some View {
        // Wrap in a fixed-size container with bottom alignment for upward expansion
        ZStack(alignment: .bottom) {
            // Glassmorphism oval that expands from center
            RoundedRectangle(cornerRadius: isExpanded ? 16 : 4)
                .fill(.clear)
                .background(
                    ZStack {
                        // Glassmorphism background with blur
                        VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                            .opacity(0.8)
                        
                        // Subtle tinted overlay for depth
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.15),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        
                        // Additional blur layer for stronger glass effect
                        VisualEffectView(material: .menu, blendingMode: .withinWindow)
                            .opacity(0.3)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: isExpanded ? 16 : 4))
                )
                .overlay {
                    // Subtle dark theme outline border
                    RoundedRectangle(cornerRadius: isExpanded ? 16 : 4)
                        .strokeBorder(DarkTheme.textPrimary.opacity(0.6), lineWidth: 1.0)
                }
                // MARK: - Alternative Glass Border Effects (commented for future use)
                /*
                .overlay {
                    // Option 1: White glass border outline
                    RoundedRectangle(cornerRadius: isExpanded ? 16 : 4)
                        .strokeBorder(Color.white.opacity(0.2), lineWidth: 1.0)
                }
                */
                /*
                .overlay {
                    // Option 2: Gradient glass border effect
                    RoundedRectangle(cornerRadius: isExpanded ? 16 : 4)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.1),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.0
                        )
                }
                */
                .frame(
                    width: getWidth(),
                    height: getHeight()
                )
                .scaleEffect(animationScale)
                // Lighter animations to avoid jank on continuous updates
                .animation(.interactiveSpring(response: 0.28, dampingFraction: 0.85), value: isExpanded)
                .animation(.interactiveSpring(response: 0.28, dampingFraction: 0.85), value: whisperState.isProcessing)
                .overlay {
                    // Content only shows when expanded
                    if showContent {
                        Group {
                            if whisperState.isProcessing {
                                // Show progress bar for transcribing state
                                TranscribingProgressBar(progress: $whisperState.transcriptionProgress)
                            } else if whisperState.isRecording {
                                // Conditional content based on streaming transcript setting
                                if whisperState.isStreamingTranscriptEnabled {
                                    // Show streaming transcript view
                                    StreamingTranscriptView(whisperState: whisperState)
                                } else {
                                    // Show audio visualizer for recording state
                                    HStack(spacing: 0) {
                                        AudioVisualizer(
                                            audioMeter: audioLevel.level,
                                            color: .white,
                                            isActive: whisperState.isRecording
                                        )
                                        .frame(maxWidth: .infinity)
                                        .padding(.horizontal, 4)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                        .opacity(isExpanded ? 1.0 : 0.0)
                        // Simple content fade synchronized with shape
                        .animation(.easeInOut(duration: 0.18), value: isExpanded)
                    }
                }
        }
        .frame(
            width: whisperState.isStreamingTranscriptEnabled ? 320 : 95,
            height: whisperState.isStreamingTranscriptEnabled ? 160 : 32,
            alignment: .bottom  // Bottom-anchored expansion - key for upward growth!
        )
        .task {
            // Always show the oval when app runs
            if !hasInitialized {
                hasInitialized = true
                isShowing = true  // Always visible, no animation needed
            }
            refreshVisualState()
        }
        .onChange(of: whisperState.isAttemptingToRecord) { oldValue, newValue in
            // INSTANT expansion - zero lag response
            if newValue && !oldValue {
                // Reset progress at the very start of recording to ensure clean state
                whisperState.transcriptionProgress = 0.0
                animateRecordingStart()
                // Set states immediately - no refreshVisualState conflicts
                isExpanded = true
                showContent = true
            } else if !newValue && oldValue {
                // If attempt was cancelled and not actually recording/processing, collapse
                if !whisperState.isRecording && !whisperState.isProcessing {
                    isExpanded = false
                    showContent = false
                }
            }
            // DON'T call refreshVisualState() - it causes competing state changes
        }
        .onChange(of: whisperState.isRecording) { oldValue, newValue in
            if !newValue && oldValue {
                animateRecordingStop()
            }
            refreshVisualState()
        }
        .onChange(of: whisperState.isProcessing) { oldValue, newValue in
            // Reset progress to 0 when transcription starts
            if newValue && !oldValue {
                whisperState.transcriptionProgress = 0.0
            }
            // Removed animateBounce() to prevent startup animation conflicts
            refreshVisualState()
        }
    }
}


