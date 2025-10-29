import SwiftUI

struct StreamingTranscriptView: View {
    @ObservedObject var whisperState: WhisperState
    @State private var maxDisplayLength: Int = 500 // Limit visible chars for efficiency
    // Subtle dreamy micro-animations (render-only, no layout changes)
    @State private var overlayOpacity: Double = 0.92
    @State private var crispScale: CGFloat = 1.0
    
    // Remove multi-layer rendering; use a single node bound to the atomic attributed stream
    
    var isEnhancementPending: Bool {
        // Start shimmering immediately when recording stops and processing begins (no text dependency)
        (!whisperState.isRecording) && whisperState.isProcessing
    }
    
    var body: some View {
        // Bounded text container - text lives strictly within these margins
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 24) // Fixed top margin
            
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        TimelineView(.animation) { _ in
                            // Soft two-layer rendering that remains atomic: crisp final under a hazy partial overlay
                            ZStack(alignment: .topLeading) {
                                // Finalized text (crisp)
                                Text(whisperState.streamingTextCache.snapshot.crisp)
                                    .font(.system(size: 12, weight: .semibold, design: .default))
                                    .scaleEffect(crispScale)
                                // Partial overlay with gentle blur/haze
                                Text(whisperState.streamingTextCache.snapshot.overlay)
                                    .font(.system(size: 12, weight: .semibold, design: .default))
                                    .blur(radius: 1.8)
                                    .opacity(overlayOpacity)
                            }
                            .compositingGroup()
                            .drawingGroup(opaque: false, colorMode: .linear)
                            .lineSpacing(6)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                            .textSelection(.disabled)
                            .layoutPriority(1)
                        }

                        // Bottom sentinel for reliable scrolling
                        Color.clear.frame(height: 1).id("bottom")
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                }
                .transaction { t in t.animation = nil } // hard-disable implicit animations inside
                // Avoid clipping to prevent bottom cut-off
                .onChange(of: whisperState.streamingAttributed) { _ in
                    // Non-animated jump to bottom, debounced slightly to batch updates
                    scrollToBottomDebounced(proxy: proxy)
                }
                // Dreamy micro-animations: run only on promotions (atomic, cheap transforms)
                .onChange(of: whisperState.streamingPromotionCounter) { _ in
                    // Start slightly shrunken and a touch dimmer, then ease out
                    crispScale = 0.995
                    overlayOpacity = 0.86
                    withAnimation(.easeOut(duration: 0.18)) {
                        crispScale = 1.0
                        overlayOpacity = 0.92
                    }
                }
            }
            
            Spacer()
                .frame(height: 24) // Fixed bottom margin
        }
    }
    
    
    private func scrollToBottomDebounced(proxy: ScrollViewProxy) {
        // Debounce slighty and jump without animation to avoid extra frame paints
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
            proxy.scrollTo("bottom", anchor: .bottom)
        }
    }
}
