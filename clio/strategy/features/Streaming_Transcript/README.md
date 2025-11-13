# Streaming Transcript MiniRecorder - Technical Implementation

## Performance Requirements

**Target Devices**: MacBook Air M1 (2020) and newer, Intel Mac (2019+)
**Performance Goals**:
- UI updates: 30fps maximum (vs 60fps system default to reduce load)  
- Memory overhead: <25MB additional during streaming
- CPU impact: <5% additional on M1 MacBook Air
- Animation latency: <16ms for expansion/collapse
- Battery impact: <5% additional drain

## Efficient Implementation Strategy

### 1. Optimized State Management

#### Minimal State Updates
```swift
// EFFICIENT: Throttled updates prevent excessive re-renders
class RecordingEngine: ObservableObject {
    @Published var streamingPartialText: String = ""
    @Published var streamingFinalText: String = ""
    
    private var lastUpdateTime: Date = Date()
    private let updateThrottle: TimeInterval = 0.033 // 30fps max
    
    private func setupStreamingTranscriptBinding() {
        sonioxStreamingService.$partialTranscript
            .throttle(for: .seconds(updateThrottle), scheduler: DispatchQueue.main, latest: true)
            .removeDuplicates() // Skip identical updates
            .receive(on: DispatchQueue.main)
            .assign(to: &$streamingPartialText)
    }
}
```

#### Smart Text Diffing
```swift
// EFFICIENT: Only update changed portions
struct TextUpdateDiff {
    let oldText: String
    let newText: String
    let changedRange: Range<String.Index>?
    
    static func calculateDiff(old: String, new: String) -> TextUpdateDiff {
        // Minimal diff calculation - only re-render changed parts
        let commonPrefix = old.commonPrefix(with: new)
        let changedRange = commonPrefix.endIndex..<new.endIndex
        
        return TextUpdateDiff(
            oldText: old,
            newText: new, 
            changedRange: changedRange.isEmpty ? nil : changedRange
        )
    }
}
```

### 2. Memory-Efficient Text Rendering

#### Text Virtualization for Long Transcripts
```swift
struct EfficientStreamingTranscriptView: View {
    @ObservedObject var recordingEngine: RecordingEngine
    @State private var displayText: String = ""
    @State private var maxDisplayLength: Int = 500 // Limit visible chars
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) { // Hide indicators to save GPU
                LazyVStack(alignment: .leading, spacing: 2) { // Lazy loading
                    // EFFICIENT: Only render visible text
                    Group {
                        if !recordingEngine.streamingFinalText.isEmpty {
                            Text(truncatedFinalText)
                                .foregroundColor(.white)
                                .font(.system(size: 13, weight: .regular)) // Smaller font for efficiency
                        }
                        
                        if !recordingEngine.streamingPartialText.isEmpty {
                            Text(recordingEngine.streamingPartialText)
                                .foregroundColor(.white)
                                .opacity(0.6)
                                .blur(radius: 0.3) // Reduced blur for performance
                        }
                    }
                    .textSelection(.disabled) // Disable selection to reduce overhead
                }
                .padding(12) // Reduced padding
                .id("transcript")
            }
            .clipped() // Prevent overdraw
            .onChange(of: recordingEngine.streamingPartialText) { _ in
                // EFFICIENT: Debounced scrolling
                scrollToBottomDebounced(proxy: proxy)
            }
        }
    }
    
    private var truncatedFinalText: String {
        // EFFICIENT: Only keep last 500 chars visible
        let text = recordingEngine.streamingFinalText
        return text.count > maxDisplayLength 
            ? String(text.suffix(maxDisplayLength))
            : text
    }
    
    private func scrollToBottomDebounced(proxy: ScrollViewReader) {
        // EFFICIENT: Debounce scroll updates to reduce animation load
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeOut(duration: 0.2)) { // Faster, simpler animation
                proxy.scrollTo("transcript", anchor: .bottom)
            }
        }
    }
}
```

### 3. Lightweight Animation System

#### Optimized Expansion Animation
```swift
struct EfficientMiniRecorderView: View {
    // EFFICIENT: Minimal state for animations
    @State private var isExpanded = false
    @State private var showContent = false
    
    // EFFICIENT: Pre-calculated sizes to avoid runtime calculations
    private let collapsedSize = CGSize(width: 40, height: 10)
    private let waveExpandedSize = CGSize(width: 95, height: 32)  
    private let transcriptExpandedSize = CGSize(width: 280, height: 100) // Smaller than spec for efficiency
    
    var body: some View {
        ZStack {
            // EFFICIENT: Single shape with conditional sizing
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(.clear)
                .background(efficientGlassmorphismBackground)
                .frame(
                    width: currentSize.width,
                    height: currentSize.height
                )
                .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.8), value: isExpanded) // Faster spring
                .overlay {
                    if showContent {
                        contentView
                            .opacity(isExpanded ? 1.0 : 0.0)
                            .animation(.easeInOut(duration: 0.2), value: isExpanded) // Simple fade
                    }
                }
        }
        .frame(width: transcriptExpandedSize.width, height: transcriptExpandedSize.height, alignment: .bottom)
        // EFFICIENT: Single container, bottom-aligned for upward expansion
    }
    
    private var currentSize: CGSize {
        if !isExpanded { return collapsedSize }
        return miniRecorderMode == .streamingTranscript ? transcriptExpandedSize : waveExpandedSize
    }
    
    private var cornerRadius: CGFloat {
        isExpanded ? 12 : 4 // Smaller radius for efficiency
    }
    
    // EFFICIENT: Simplified glassmorphism (fewer layers)
    private var efficientGlassmorphismBackground: some View {
        ZStack {
            // Single blur layer instead of multiple
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                .opacity(0.85)
            
            // Simple gradient overlay
            LinearGradient(
                colors: [Color.white.opacity(0.12), Color.white.opacity(0.04)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(Color.white.opacity(0.3), lineWidth: 0.5) // Thinner border
        )
    }
}
```

### 4. Efficient Settings Integration

#### Lightweight Settings Storage
```swift
// EFFICIENT: Simple enum for fast switching
@AppStorage("miniRecorderMode") private var miniRecorderModeRaw: String = "wave"

private var miniRecorderMode: MiniRecorderMode {
    get { MiniRecorderMode(rawValue: miniRecorderModeRaw) ?? .waveVisualizer }
    set { miniRecorderModeRaw = newValue.rawValue }
}

enum MiniRecorderMode: String, CaseIterable {
    case waveVisualizer = "wave"
    case streamingTranscript = "transcript"
}

// EFFICIENT: Settings UI with minimal overhead
struct MiniRecorderModeSection: View {
    @AppStorage("miniRecorderMode") private var mode: String = "wave"
    
    var body: some View {
        SettingsSection(
            icon: "rectangle.on.rectangle",
            title: "MiniRecorder Style"
        ) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Choose your preferred recorder interface.")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                
                Picker("Mode", selection: $mode) {
                    Text("Wave Visualizer").tag("wave")
                    Text("Streaming Transcript").tag("transcript")
                }
                .pickerStyle(.radioGroup)
            }
        }
    }
}
```

### 5. Resource Management

#### Memory Cleanup Strategy
```swift
class RecordingEngine: ObservableObject {
    private let maxTranscriptLength = 1000 // chars
    private var transcriptCleanupTimer: Timer?
    
    func startRecording() {
        // Clear old data
        streamingPartialText = ""
        streamingFinalText = ""
        
        // Start cleanup timer for long recordings
        transcriptCleanupTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { _ in
            self.cleanupLongTranscript()
        }
    }
    
    func stopRecording() {
        // EFFICIENT: Immediate cleanup
        transcriptCleanupTimer?.invalidate()
        transcriptCleanupTimer = nil
        
        // Clear streaming data after delay to allow final processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.streamingPartialText = ""
            // Keep final text briefly for user confirmation
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                self.streamingFinalText = ""
            }
        }
    }
    
    private func cleanupLongTranscript() {
        // EFFICIENT: Truncate old text to prevent memory growth
        if streamingFinalText.count > maxTranscriptLength {
            let keepLength = maxTranscriptLength / 2
            streamingFinalText = String(streamingFinalText.suffix(keepLength))
        }
    }
}
```

### 6. Performance Monitoring

#### Built-in Performance Tracking
```swift
struct PerformanceMonitor {
    private static var uiUpdateCount: Int = 0
    private static var lastResetTime: Date = Date()
    
    static func trackUIUpdate() {
        uiUpdateCount += 1
        
        // Log performance every 10 seconds
        let now = Date()
        if now.timeIntervalSince(lastResetTime) > 10.0 {
            let updatesPerSecond = Double(uiUpdateCount) / 10.0
            print("📊 [PERFORMANCE] UI updates: \(String(format: "%.1f", updatesPerSecond))/sec")
            
            if updatesPerSecond > 35 { // Warning if over 35fps
                print("⚠️ [PERFORMANCE] High UI update rate detected")
            }
            
            uiUpdateCount = 0
            lastResetTime = now
        }
    }
}

// Usage in StreamingTranscriptView
.onChange(of: recordingEngine.streamingPartialText) { _ in
    PerformanceMonitor.trackUIUpdate()
    // ... rest of update logic
}
```

## Implementation Checklist

### Phase 1: Efficient Core (Week 1)
- [ ] Throttled state updates (30fps max)
- [ ] Lightweight settings integration  
- [ ] Basic streaming transcript view with text virtualization
- [ ] Memory cleanup timers

### Phase 2: Optimized UI (Week 2)  
- [ ] Simplified glassmorphism background
- [ ] Bottom-anchored expansion with minimal animation
- [ ] Text diffing for partial updates
- [ ] Performance monitoring integration

### Phase 3: Polish & Testing (Week 3)
- [ ] Battery usage testing on MacBook Air M1
- [ ] Memory leak detection with long recordings
- [ ] Animation smoothness validation
- [ ] CPU usage profiling

## Performance Validation Criteria

### Automated Testing
```bash
# Performance test suite
./test_streaming_performance.sh
# - Records 5-minute transcript
# - Monitors CPU/Memory usage
# - Validates UI responsiveness  
# - Checks for memory leaks
```

### Success Metrics
- ✅ UI stays responsive during 10+ minute recordings
- ✅ Memory usage stays under 25MB additional
- ✅ CPU impact under 5% on M1 MacBook Air
- ✅ Animation frame rate maintains 30fps minimum
- ✅ No memory leaks after 100 recording cycles

## Rollback Plan

If performance issues arise:
1. **Disable text blur effects** (saves GPU processing)
2. **Increase update throttle** from 30fps to 15fps  
3. **Reduce transcript length** from 1000 to 500 chars
4. **Fall back to wave visualizer** for affected users
5. **Add performance setting** to let users choose update frequency

---

*This implementation prioritizes efficiency while maintaining the visual quality and user experience benefits of real-time transcript streaming.*