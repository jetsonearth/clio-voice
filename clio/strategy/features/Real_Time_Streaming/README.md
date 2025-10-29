# Real-Time Streaming Text Input Implementation Plan

## Problem Analysis
Current Clio implementation waits for complete LLM response before pasting, while competitors like WhisperFlow provide real-time streaming text insertion with proper @mention handling for IDE integration.

### Current Issues
1. **Clipboard simulation**: Uses `CursorPaster.pasteAtCursor()` which copies to clipboard then simulates Cmd+V
2. **Batch processing**: Waits for complete LLM response (~880ms) before pasting anything
3. **No streaming**: Current Fly.io proxy uses `stream: false` in Groq requests
4. **@Mention limitations**: Pastes complete text blob instead of incremental @mention processing

### Desired Outcome
Achieve WhisperFlow-like experience with:
- **Real-time streaming text insertion** as tokens arrive from LLM
- **Smart @mention processing** with individual Enter key presses for IDE autocomplete
- **Direct text insertion** without clipboard pollution
- **Proper Cursor IDE integration** with file highlighting and linking

## Current Architecture Analysis

### Existing Data Flow
```
User speaks → ASR (400ms) → Wait for LLM (880ms) → CursorPaster.pasteAtCursor() → Cmd+V simulation
Total delay: 1280ms before any text appears
```

### Current Implementation Points
- **WhisperState.swift**: Calls `CursorPaster.pasteAtCursor(enhancedText)` after complete LLM response
- **CursorPaster.swift**: Manages clipboard state and simulates Cmd+V keypress
- **AIEnhancementService.swift**: Makes synchronous calls to Fly.io proxy, waits for complete response
- **clio-flyio-api/src/routes/llm.js**: Sets `stream: false` in Groq API requests

## Target Architecture

### Proposed Data Flow
```
User speaks → ASR (400ms) → First tokens (100ms) → Stream remaining tokens in real-time
                                                  ↓
                           Direct text insertion + @mention processing with Enter presses
```

### Performance Improvements
- **Current**: 1280ms total delay before any text appears
- **With streaming**: 500ms to first visible text (60% faster perceived time)
- **User experience**: Real-time feedback similar to ChatGPT/Claude interfaces

## Implementation Plan

### Phase 1: Enable Streaming in Fly.io Proxy
**Target file**: `clio-flyio-api/src/routes/llm.js`

#### Changes Required
1. **Enable streaming in Groq request**:
   ```javascript
   const requestBody = {
     model,
     messages: [...],
     temperature: 0.3,
     stream: true,  // Changed from false
     service_tier: 'flex'
   };
   ```

2. **Add Server-Sent Events (SSE) endpoint**:
   ```javascript
   // New endpoint: POST /api/llm/stream
   export async function llmStreamingProxy(req, res) {
     res.writeHead(200, {
       'Content-Type': 'text/event-stream',
       'Cache-Control': 'no-cache',
       'Connection': 'keep-alive'
     });
     
     // Stream Groq response as SSE events
     for await (const chunk of groqResponse.body) {
       const token = parseGroqStreamingChunk(chunk);
       if (token) {
         res.write(`data: ${JSON.stringify({token})}\n\n`);
       }
     }
   }
   ```

3. **Groq streaming response parsing**:
   ```javascript
   function parseGroqStreamingChunk(chunk) {
     // Parse Groq's streaming format:
     // data: {"choices":[{"delta":{"content":"token"}}]}
     // Return extracted content token
   }
   ```

### Phase 2: Create Direct Text Insertion Service
**New file**: `Clio/Clio/Managers/DirectTextInserter.swift`

#### Core Functionality
1. **Direct AXUIElement insertion** (replaces clipboard simulation):
   ```swift
   static func insertTextDirectly(_ text: String) -> Bool {
       guard AXIsProcessTrusted() else { return false }
       
       let systemWideElement = AXUIElementCreateSystemWide()
       var focusedElement: AXUIElement?
       
       AXUIElementCopyAttributeValue(systemWideElement, 
                                   kAXFocusedUIElementAttribute, 
                                   &focusedElement)
       
       if let element = focusedElement {
           AXUIElementSetAttributeValue(element, 
                                      kAXValueAttribute as CFString, 
                                      text as CFString)
           return true
       }
       return false
   }
   ```

2. **Incremental @mention processing**:
   ```swift
   static func insertWithFileTags(_ text: String) {
       let mentions = extractAtMentions(from: text)  // Find @ContextService.swift patterns
       let baseText = removeAtMentions(from: text)   // Remove @mentions from main text
       
       // Insert main text first
       insertTextDirectly(baseText)
       
       // Process each @mention individually
       for mention in mentions {
           Thread.sleep(forTimeInterval: 0.05)  // Small delay
           insertTextDirectly(mention)          // Type @ContextService.swift
           pressEnterKey()                      // Trigger Cursor's autocomplete
           Thread.sleep(forTimeInterval: 0.1)   // Wait for processing
       }
   }
   
   private static func pressEnterKey() {
       let source = CGEventSource(stateID: .hidSystemState)
       let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 0x24, keyDown: true)  // Enter key
       let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 0x24, keyDown: false)
       
       keyDown?.post(tap: .cghidEventTap)
       keyUp?.post(tap: .cghidEventTap)
   }
   ```

3. **@Mention detection patterns**:
   ```swift
   private static func extractAtMentions(from text: String) -> [String] {
       let pattern = #"@[A-Za-z0-9_.-]+\.[A-Za-z]{1,5}"#  // Matches @filename.ext
       let regex = try! NSRegularExpression(pattern: pattern)
       let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
       
       return matches.compactMap { match in
           String(text[Range(match.range, in: text)!])
       }
   }
   ```

### Phase 3: Add Streaming to AIEnhancementService
**Target file**: `Clio/Clio/Services/AI/AIEnhancementService.swift`

#### Streaming Integration
1. **New streaming method**:
   ```swift
   func enhanceWithStreaming(_ text: String) async throws -> AsyncThrowingStream<String, Error> {
       return AsyncThrowingStream { continuation in
           Task {
               do {
                   let url = URL(string: "\(APIConfig.flyioBaseURL)/api/llm/stream")!
                   let request = createStreamingRequest(url: url, text: text)
                   
                   let (asyncBytes, response) = try await URLSession.shared.bytes(for: request)
                   
                   for try await line in asyncBytes.lines {
                       if let token = parseSSELine(line) {
                           continuation.yield(token)
                       }
                   }
                   continuation.finish()
               } catch {
                   continuation.finish(throwing: error)
               }
           }
       }
   }
   ```

2. **SSE parsing for client**:
   ```swift
   private func parseSSELine(_ line: String) -> String? {
       guard line.hasPrefix("data: ") else { return nil }
       let jsonStr = String(line.dropFirst(6))
       guard jsonStr != "[DONE]" else { return nil }
       
       if let data = jsonStr.data(using: .utf8),
          let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
          let token = json["token"] as? String {
           return token
       }
       return nil
   }
   ```

### Phase 4: Integrate Real-Time Streaming in WhisperState
**Target file**: `Clio/Clio/Whisper/WhisperState.swift`

#### Replace Batch Processing
1. **Current implementation** (to be replaced):
   ```swift
   // OLD: Wait for complete response
   let enhancedText = try await enhancementService.enhance(transcript)
   CursorPaster.pasteAtCursor(enhancedText)
   ```

2. **New streaming implementation**:
   ```swift
   // NEW: Stream tokens as they arrive
   var streamBuffer = ""
   var pendingMentions: [String] = []
   
   for try await token in enhancementService.enhanceWithStreaming(transcript) {
       streamBuffer += token
       
       // Check for @mentions in the stream
       if token.contains("@") {
           let newMentions = DirectTextInserter.extractAtMentions(from: streamBuffer)
           for mention in newMentions where !pendingMentions.contains(mention) {
               pendingMentions.append(mention)
           }
       }
       
       // Insert token immediately (excluding @mentions)
       let cleanToken = DirectTextInserter.removeAtMentions(from: token)
       if !cleanToken.isEmpty {
           DirectTextInserter.insertTextDirectly(cleanToken)
       }
   }
   
   // Process @mentions after main text is complete
   for mention in pendingMentions {
       DirectTextInserter.insertTextDirectly(mention)
       DirectTextInserter.pressEnterKey()
       Thread.sleep(forTimeInterval: 0.1)
   }
   ```

### Phase 5: Smart Context Detection
**Enhancement for Cursor IDE integration**

#### Context-Aware @Mention Processing
1. **Detect Cursor IDE context**:
   ```swift
   private func isCursorIDEActive() -> Bool {
       let workspace = NSWorkspace.shared
       if let frontApp = workspace.frontmostApplication {
           return frontApp.bundleIdentifier?.contains("cursor") == true ||
                  frontApp.localizedName?.lowercased().contains("cursor") == true
       }
       return false
   }
   ```

2. **Smart file suggestion integration**:
   - Detect when user is in a coding context
   - Enhance @mention recognition for common file patterns
   - Add support for relative path @mentions (e.g., `@../Services/AIService.swift`)

## Technical Considerations

### Error Handling & Fallbacks
1. **Streaming failure recovery**:
   ```swift
   func enhanceWithStreamingFallback(_ text: String) async throws -> String {
       do {
           var result = ""
           for try await token in enhanceWithStreaming(text) {
               result += token
               DirectTextInserter.insertTextDirectly(token)
           }
           return result
       } catch {
           logger.notice("⚠️ Streaming failed, falling back to batch mode")
           return try await enhance(text)  // Fallback to existing batch method
       }
   }
   ```

2. **Connection reliability**:
   - Implement retry logic for dropped connections
   - Handle partial token reconstruction
   - Maintain session persistence for streaming connections

### Performance Monitoring
1. **Streaming latency metrics**:
   ```swift
   private func logStreamingMetrics(firstTokenTime: Double, totalTokens: Int, duration: Double) {
       logger.notice("📊 [STREAMING] First token: \(firstTokenTime)ms, Total tokens: \(totalTokens), Rate: \(totalTokens/duration) tokens/sec")
   }
   ```

2. **Compare streaming vs batch performance**:
   - Measure time to first visible character
   - Track total completion time
   - Monitor user satisfaction metrics

### User Experience Enhancements
1. **Visual feedback**:
   - Show streaming indicator during text generation
   - Highlight @mentions as they're being processed
   - Add progress indication for longer responses

2. **User preferences**:
   ```swift
   @AppStorage("enableStreamingMode") private var enableStreamingMode: Bool = true
   @AppStorage("streamingBufferDelay") private var streamingBufferDelay: Double = 0.05
   ```

## Migration Strategy

### Phase Implementation Order
1. **Phase 1**: Implement Fly.io streaming endpoint (backend only)
2. **Phase 2**: Create DirectTextInserter service (can coexist with existing)
3. **Phase 3**: Add streaming capability to AIEnhancementService
4. **Phase 4**: Replace WhisperState batch processing with streaming
5. **Phase 5**: Add Cursor IDE specific enhancements

### Backward Compatibility
- Keep existing `CursorPaster.pasteAtCursor()` as fallback option
- Add user setting to toggle between streaming and batch modes
- Maintain all existing AI provider integrations

### Testing Strategy
1. **Unit tests**: Test @mention extraction, SSE parsing, direct text insertion
2. **Integration tests**: Test streaming end-to-end with mock Groq responses
3. **Performance tests**: Compare streaming vs batch latency
4. **User testing**: Validate Cursor IDE integration and @mention autocomplete

## Success Metrics

### Performance Targets
- **Time to first visible text**: Reduce from 1280ms to <500ms (60% improvement)
- **@Mention processing accuracy**: 95%+ correct autocomplete triggers
- **Streaming reliability**: 99%+ successful stream completion rate

### User Experience Goals
- **Real-time feedback**: Users see text appearing as it's generated
- **Seamless IDE integration**: @mentions properly trigger Cursor's autocomplete
- **No clipboard pollution**: Direct text insertion preserves user workflow

## Future Enhancements

### Advanced Features
1. **Smart buffering**: Group tokens for smoother visual appearance
2. **Predictive @mention**: Suggest file completions based on context
3. **Multi-cursor support**: Handle multiple cursor positions in editors
4. **Undo/redo integration**: Proper integration with editor undo stacks

### Platform Expansion
- Support for other IDEs (VS Code, Xcode, IntelliJ)
- Browser-based editor integration (CodeSandbox, GitHub Codespaces)
- Terminal application support for command completion

## Conclusion

This implementation will transform Clio from a batch-processing transcription tool into a real-time streaming assistant that integrates seamlessly with modern development environments. The phased approach ensures backward compatibility while delivering immediate user experience improvements.

The key innovation is combining real-time streaming with intelligent @mention processing, creating a WhisperFlow-like experience that's specifically optimized for developer workflows and Cursor IDE integration.