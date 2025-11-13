# Streaming Transcript MiniRecorder

## Problem Statement

**User Pain Point**: "I was speaking for 3 minutes, pressed transcribe, and nothing happened..."

Users experience anxiety during long recordings with only wave visualizer feedback. They can't confirm their speech is being captured, leading to broken creative flow when unsure if the system is working. This transitions users from optimal "Flow State" (路径 1) back to analytical "Problem-Solving Mode" (路径 2), disrupting creative momentum.

**Impact**: Lost user confidence, interrupted creative sessions, potential data loss anxiety.

## Solution Overview

Add alternative MiniRecorder UI mode that displays real-time ASR transcript streaming, similar to Aqua Voice interface. Provides immediate visual confirmation that speech is being captured and transcribed.

## User Experience Flow

### Current Flow (Wave Visualizer Mode)
1. Hotkey pressed → Small oval badge expands to rectangle (95x32)
2. User speaks → Wave animation visualizes audio activity
3. Hotkey pressed → Collapse to thin progress bar during LLM processing
4. Complete → Shrink back to oval badge, paste text

### New Flow (Streaming Transcript Mode)  
1. Hotkey pressed → Small oval badge expands **upward** to larger rectangle (300x120)
2. User speaks → Real-time transcript appears with visual hierarchy:
   - **Final text**: Full opacity, crisp (confirmed words)
   - **Partial text**: 60% opacity + subtle blur (interim words) 
   - **Smooth transitions**: Text clarifies when partial → final
3. Hotkey pressed → Collapse down to current progress bar 
4. Complete → Shrink back to oval badge, paste enhanced text

### Key UX Principles
- **Bottom-anchored expansion**: Badge bottom edge stays fixed, expands upward
- **Progressive clarification**: Text literally becomes clearer as it's confirmed
- **Immediate feedback**: Users see words appearing within 200ms of speaking
- **Graceful overflow**: ScrollView handles long transcripts smoothly

## Visual Design Specifications

### Typography & Layout
- **Font**: SF Pro Text, 14pt (optimized for readability)
- **Line height**: 1.4x for comfortable reading
- **Margins**: 16px from all edges of glassmorphism card
- **Text alignment**: Left-aligned, natural reading flow

### Glassmorphism Card
- **Collapsed**: 40w × 10h oval badge
- **Expanded**: 300w × 120h rounded rectangle (16px corners)
- **Material**: Same blur/gradient system as current mini recorder
- **Border**: Consistent with existing dark theme outline

### Text Visual Hierarchy  
```swift
// Final confirmed text
.foregroundColor(.white)
.opacity(1.0)

// Partial interim text  
.foregroundColor(.white)
.opacity(0.6)
.blur(radius: 0.5)

// Transition animation
.animation(.easeInOut(duration: 0.3), value: isTextFinal)
```

### Scroll Behavior
- **Auto-scroll**: Latest text always visible
- **Smooth scrolling**: 60fps with scroll indicators
- **Content padding**: Text doesn't touch edges

## Technical Implementation

### Architecture Changes

#### RecordingEngine Extensions
```swift
// New published properties for real-time display
@Published var streamingPartialText: String = ""
@Published var streamingFinalText: String = ""

private func setupStreamingTranscriptBinding() {
    sonioxStreamingService.$partialTranscript
        .receive(on: DispatchQueue.main)
        .assign(to: &$streamingPartialText)
        
    sonioxStreamingService.$finalBuffer
        .receive(on: DispatchQueue.main)
        .assign(to: &$streamingFinalText)
}
```

#### Settings Integration
```swift
@AppStorage("miniRecorderMode") private var miniRecorderMode: MiniRecorderMode = .waveVisualizer

enum MiniRecorderMode: String, CaseIterable {
    case waveVisualizer = "wave"
    case streamingTranscript = "transcript"
    
    var displayName: String {
        switch self {
        case .waveVisualizer: return "Wave Visualizer"
        case .streamingTranscript: return "Streaming Transcript"
        }
    }
}
```

### Component Architecture

#### StreamingTranscriptView
```swift
struct StreamingTranscriptView: View {
    @ObservedObject var recordingEngine: RecordingEngine
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 4) {
                    // Final confirmed text
                    if !recordingEngine.streamingFinalText.isEmpty {
                        Text(recordingEngine.streamingFinalText)
                            .foregroundColor(.white)
                            .opacity(1.0)
                    }
                    
                    // Partial interim text with blur effect
                    if !recordingEngine.streamingPartialText.isEmpty {
                        Text(recordingEngine.streamingPartialText)
                            .foregroundColor(.white)
                            .opacity(0.6)
                            .blur(radius: 0.5)
                    }
                }
                .padding(16)
                .id("transcript")
            }
            .onChange(of: recordingEngine.streamingPartialText) { _ in
                withAnimation(.easeInOut(duration: 0.2)) {
                    proxy.scrollTo("transcript", anchor: .bottom)
                }
            }
        }
    }
}
```

#### MiniRecorderView Updates
```swift
// Conditional sizing based on mode
private func getExpandedSize() -> CGSize {
    switch miniRecorderMode {
    case .waveVisualizer:
        return CGSize(width: 95, height: 32)
    case .streamingTranscript:  
        return CGSize(width: 300, height: 120)
    }
}

// Conditional content rendering
.overlay {
    if showContent {
        Group {
            if recordingEngine.isProcessing {
                TranscribingProgressBar(progress: $recordingEngine.transcriptionProgress)
            } else if miniRecorderMode == .streamingTranscript {
                StreamingTranscriptView(recordingEngine: recordingEngine)
            } else {
                // Wave visualizer (existing)
                AudioVisualizer(...)
            }
        }
    }
}
```

### Animation System

#### Bottom-Anchored Expansion
```swift
// Container positioning for upward expansion
.frame(
    width: expandedSize.width,
    height: expandedSize.height,
    alignment: .bottom  // Key: anchors expansion from bottom
)

// Smooth spring animation
.animation(.spring(response: 0.4, dampingFraction: 0.7), value: isExpanded)
```

#### Text Clarification Animation
```swift
// Progressive text clarity as words are confirmed
.onChange(of: recordingEngine.streamingFinalText) { oldValue, newValue in
    // Find newly confirmed words
    let newWords = extractNewWords(old: oldValue, new: newValue)
    
    // Animate each word from blur → clear
    newWords.forEach { word in
        withAnimation(.easeInOut(duration: 0.3)) {
            updateWordClarityState(word)
        }
    }
}
```

## Data Flow Architecture

### Streaming Pipeline
```
User Speech → Soniox WebSocket → Interim Results → partialTranscript
                              → Final Results → finalBuffer
                              ↓
SonioxStreamingService → RecordingEngine Binding → StreamingTranscriptView
                      ↓
Real-time UI Updates (60fps) → Progressive Text Clarification
```

### State Transitions
1. **Recording Start**: 
   - `isRecording = true` → Badge expands upward
   - Streaming transcript begins updating
   
2. **Active Recording**:
   - `partialTranscript` updates → Blurred text appears
   - `finalBuffer` updates → Text clarifies and solidifies
   
3. **Recording Stop**:
   - `isProcessing = true` → Collapse to progress bar  
   - Streaming stops, LLM enhancement begins
   
4. **Processing Complete**:
   - Enhanced text pasted → Badge returns to small oval

## Performance Considerations

### Optimization Strategies
- **Text Diffing**: Only re-render changed portions of transcript
- **Scroll Optimization**: Virtual scrolling for very long transcripts
- **Animation Throttling**: Limit text updates to 30fps max
- **Memory Management**: Clear old transcript data after processing

### Resource Monitoring
- Track UI update frequency during streaming
- Monitor memory usage for long transcripts (>5 minutes)
- Ensure smooth 60fps animation during expansion/collapse

## Success Metrics

### User Experience  
- **Confidence Indicator**: Reduced "did it work?" support requests
- **Flow State Maintenance**: Users continue speaking without interruption
- **Accuracy Perception**: Real-time feedback increases confidence in final result

### Technical Performance
- **Response Time**: Text appears within 200ms of speech
- **Animation Smoothness**: Maintain 60fps during all transitions  
- **Memory Efficiency**: <50MB additional usage during streaming
- **Battery Impact**: <10% additional drain during transcript mode

## Implementation Timeline

### Week 1: Core Infrastructure
- ✅ RecordingEngine streaming properties & binding
- Settings integration with mode selection toggle
- Basic StreamingTranscriptView component

### Week 2: Visual Polish
- Aqua Voice-style text treatment (blur/clarity effects)
- Bottom-anchored expansion animation
- Scroll behavior and overflow handling

### Week 3: Integration & Testing
- MiniRecorderView conditional mode rendering
- Performance optimization and testing
- User experience validation

## Risk Mitigation

### Technical Risks
- **Performance**: Continuous UI updates could impact battery/CPU
  - *Mitigation*: Throttle updates, optimize rendering pipeline
  
- **Memory Usage**: Long transcripts accumulating in memory
  - *Mitigation*: Implement transcript cleanup, virtual scrolling

### UX Risks  
- **Information Overload**: Too much text might be distracting
  - *Mitigation*: Elegant typography, proper spacing, smooth animations
  
- **Mode Discovery**: Users might not find the new mode
  - *Mitigation*: Prominent settings placement, onboarding hint

## Future Enhancements

### Advanced Features
- **Word-level highlighting**: Show confidence scores via opacity
- **Smart truncation**: Fade out older text to focus on recent words
- **Gesture controls**: Swipe to scroll through transcript history
- **Export transcript**: Save streaming transcript as separate file

### Accessibility
- **Voice Over support**: Proper accessibility labels for transcript text
- **High contrast mode**: Enhanced visibility options
- **Text size scaling**: Respect system text size preferences

---

*This feature positions Clio as a premium transcription tool that respects users' creative flow while providing the technical confidence they need for professional work.*