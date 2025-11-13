# TIER‑1 BUG: Mid‑stream WebSocket becomes "Socket is not connected" and session dead‑ends (no recovery)

## Summary
- Severity: 🔴 CRITICAL
- Components: `SonioxStreamingService.swift` (send path + recovery), `WebSocketSendActor.swift`, network path monitoring
- Impact: After a transient network/path change, the WS task is invalidated and all subsequent sends fail with "Socket is not connected". The app keeps skipping packets and never self‑recovers; later recordings also fail until restart.

## Evidence (user logs – 2025‑08‑15)
```
nw_flow_add_write_request [...] cannot accept write requests
nw_write_request_report [C9] Send failed with error "Socket is not connected"
Task <...> finished with error [57] NSPOSIXErrorDomain Code=57 "Socket is not connected"
❌ Failed to send frame seq=288: The operation couldn't be completed. Socket is not connected
⚠️ Skipping failed packet seq=288, continuing with remaining 0 packets
... (repeated for many seq)
```
Context around failure shows earlier normal runs, then this session enters a permanent error state despite NER success and audio health OK.

## Root‑cause hypothesis
- URLSessionWebSocketTask was invalidated (VPN/utun path switch or transient TCP reset). Our send path continues writing without triggering service‑level recovery.
- `WebSocketSendActor` logs and skips failed frames but does not notify `SonioxStreamingService` to reconnect; there is no backoff/circuit breaker.
- No `NWPathMonitor` to proactively reconnect on interface/path changes while streaming.

## Scope to inspect
- `WebSocketSendActor`
  - Add send‑failure callback/delegate to service
  - Pause queue and await reconnection instead of blind skipping
- `SonioxStreamingService`
  - On send‑failure callback: mark `webSocketReady = false`, stop keepalive, `disconnectWebSocket()`, then `connectWebSocketWithRetry()`; call `sendActor.setSocket(newSocket)` and resume
  - Add bounded retry + circuit breaker → surface user‑visible error if recovery fails
  - Add `NWPathMonitor` to trigger proactive reconnect on path change (throttled)
  - Ensure warm‑socket hold task is cancelled when streaming starts and never closes socket mid‑recording

## Acceptance criteria (QA)
- During streaming, if WS send returns error, service reconnects within ≤3s and live packets resume; no app restart needed
- No infinite packet skipping; queue pauses during recovery
- If N (e.g., 3) recoveries fail or >10s without a socket, recording stops with a clear UI error message
- Subsequent recordings work without restarting the app

## Reproduction
1. Start streaming on a network with VPN or interface changes
2. Force a brief path switch (toggle VPN or Wi‑Fi off/on)
3. Observe send failures with "Socket is not connected"; verify recovery occurs automatically and session continues or fails fast with error

## Fix direction
- Add `WebSocketSendActorDelegate` (actor‑safe closure) to notify service on send failure
- Implement `recoverFromSendFailure()` in service: stop keepalive → disconnect → retry connect → rebind actor → resume
- Add `NWPathMonitor` to trigger `recoverFromPathChange()` while streaming (debounced)
- Add circuit breaker + user‑visible error when recovery cannot succeed

## Test plan
- Path change mid‑stream: auto‑reconnect within ≤3s; no packet storm; no UI dead‑end
- VPN toggle mid‑stream: service recovers or fails fast with error dialog
- Warm socket hold regression: no unintended close while `isStreaming == true`

## Status update — 2025-08-16
- Status: 🟢 RESOLVED — pending soak (72h)
- Changes landed:
  - Send-path failure callback from WebSocketSendActor to service; pause queue during recovery
  - Mid-recording recovery: disconnect → reconnect with bounded retries → rebind actor → resume queue
  - Network path monitor with cooldown to trigger proactive reconnect on interface/path change
  - Hardened connect lifecycle: defer start/config text until didOpen; readiness timeout guarded per-attempt; dedupe late opens
- Verification so far:
  - Manual tests: VPN toggles and brief Wi‑Fi drops auto‑recover; no permanent "Socket is not connected" loops observed
  - Subsequent recordings succeed without app restart
- Remaining risks:
  - Extended outages still stop session as designed; user‑facing error shown
  - Need soak period across diverse networks

## Raw client log (multiple transcripts, after successful run, this error just happened randomly, right now no UI display or notice of users)
🎹 Custom modifier shortcut triggered: Right ⌘
🎤 [UI] handleToggleMiniRecorder called
🎤 [UI] toggleNotchRecorder called isRecording=false
🔊 [SoundManager] Attempting to play start sound @ 1755270634.434
🔊 [SoundManager] NSSound start sound result: true
⏱️ [TIMING] start_sound_played @ 1755270634.488
📱 Showing DynamicNotch recorder (MIT licensed)
🔍 [DYNAMIC NOTCH DEBUG] Showing notch...
🧊 [WARMUP] Skipping (recently run) context=recorderUIShown
🔍 [DYNAMIC NOTCH DEBUG] Using screen under mouse (preserving mouse-following)
🔍 [DYNAMIC NOTCH SIZE] Using built-in screen notch size: (185.0, 32.0)
⚡ [CACHE-HIT] Retrieved temp key in 10.0ms
⏱️ [TIMING] Temp key obtained in 10.2ms
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🔊 [SONIOX DEBUG] Full config: enable_endpoint_detection=true, model=stt-rt-preview-v2, language_hints=Optional(["zh", "en"])
🎙️ [TOGGLERECORD DEBUG] ===============================================
🎙️ [TOGGLERECORD DEBUG] Starting recording attempt
🎙️ [TOGGLERECORD DEBUG] Current model: soniox-realtime-streaming
🎙️ [TOGGLERECORD DEBUG] canTranscribe: true
🎤 [toggleRecord] Starting recording, current model: soniox-realtime-streaming
🎙️ [TOGGLERECORD DEBUG] Checking subscription limits...
🎙️ [TOGGLERECORD DEBUG] ✅ Subscription check passed
🎙️ [TOGGLERECORD DEBUG] Checking model access permissions...
🎙️ [TOGGLERECORD DEBUG] ✅ Model access check passed
🎙️ [TOGGLERECORD DEBUG] ✅ All checks passed - starting recording sequence
🧊 [WARMUP] Skipping (recently run) context=hotkeyDown
🎙️ Starting recording sequence...
🎙️ [TOGGLERECORD DEBUG] Starting recording session tracking...
📝 [GRACE] Recording session started with 2552 words remaining
🎙️ [TOGGLERECORD DEBUG] ===============================================
🔧 [NER-SETUP] Setting up callback - contextService exists: true
✅ [NER-SETUP] OCR completion callback configured for NER pre-warming - callback exists: true
🎙️ [RECORD PERMISSION DEBUG] Permission granted: true
🎙️ [RECORD PERMISSION DEBUG] Thread: <_NSMainThread: 0x600002264000>{number = 1, name = main}
🎙️ [RECORD PERMISSION DEBUG] Time since app launch: 0.00s
🔄 [AUTH_REFRESH] Session still valid for 35 minutes
🎙️ [ASYNC TASK DEBUG] Starting async recording task...
🎙️ [ASYNC TASK DEBUG] Task thread: <_NSMainThread: 0x600002264000>{number = 1, name = main}
🎙️ [ASYNC TASK DEBUG] Re-evaluating model for language settings...
🎙️ [ASYNC TASK DEBUG] Model type: soniox-realtime-streaming, isStreaming: true
🎙️ [SONIOX DEBUG] Starting Soniox streaming transcription...
🎙️ [SONIOX DEBUG] Calling wakeAudioSystemIfNeeded()...
🔊 Waking up audio system after 444s idle time
🎬 [CAPTURE DEBUG] Starting smart screen context capture
🔍 [CALLBACK DEBUG] onOCRCompleted callback exists: true
🔍 [CACHE] No cache available
🎬 Starting screen capture with verified permissions
🎯 ScreenCapture detected frontmost app: Cursor (com.todesktop.230313mzl4w4u92)
🎯 Found matching window: SonioxStreamingService.swift — clio-project (Workspace) — Modified (Cursor) - layer:0, pid:652
🎯 ScreenCapture found window: SonioxStreamingService.swift — clio-project (Workspace) — Modified (Cursor) - matches Context Preset detection
🎯 Found window: SonioxStreamingService.swift — clio-project (Workspace) — Modified (Cursor)
🎯 ScreenCapture detected frontmost app: Cursor (com.todesktop.230313mzl4w4u92)
🎯 Found matching window: SonioxStreamingService.swift — clio-project (Workspace) — Modified (Cursor) - layer:0, pid:652
🎯 ScreenCapture found window: SonioxStreamingService.swift — clio-project (Workspace) — Modified (Cursor) - matches Context Preset detection
🖼️ Attempting window-specific capture for: SonioxStreamingService.swift — clio-project (Workspace) — Modified (ID: 113)
✅ Successfully captured window: 3840.000000x2110.000000
🌐 [LANG DEBUG] Multi-language setting exists: true, Single language: en
🌐 [LANG DEBUG] Using multi-language selection (prioritized): zh, en
🌐 [OCR DEBUG] Selected languages from settings: zh, en
🌐 [OCR DEBUG] User selection mode - prioritizing non-English: zh-Hans, en-US
🌐 Using selected languages for OCR: zh-Hans, en-US
🎙️ [SONIOX DEBUG] Calling sonioxStreamingService.startStreaming()...
📊 [SESSION] Starting recording session #1
✅ Selected account account-bundle (connections: 1/10)
🚀 Starting Clio streaming transcription
🔊 Setting up audio engine...
throwing -10877
throwing -10877
🧹 [TAP CLEANUP] Removing any existing taps before installation
✅ [TAP CLEANUP] Successfully removed existing tap
🎧 [AUDIO INPUT] Using device id=104 name=MacBook Pro Microphone
🎤 Detected hardware format: 48000.000000Hz, 1 channels
🎯 [TAP INSTALL] Installing new audio tap with format: 48000.000000Hz
✅ [TAP INSTALL] Audio tap installed successfully
✅ Audio engine configured successfully
⏱️ [TIMING] Audio engine setup completed
⏱️ [TIMING] Audio capture started - buffering until WebSocket ready
Device list change detected
🏥 [AUDIO HEALTH] Health monitoring timer started
🎙️ [SONIOX DEBUG] Soniox streaming started successfully!
⏱️ [TIMING] mic_engaged @ 1755270635.036
🔄 Handling audio device change
✅ Device change handling completed
🆕 [COLD-START] First recording after app launch - applying background warm-up
pass
🔥 [COLD-START] Performing system warm-up with network stack pre-warming
🔥 [COLD-START] Pre-warming DNS resolution
✅ [AUDIO HEALTH] First audio data received - tap is functional
🔍 [DYNAMIC NOTCH DEBUG] Showed notch in compact mode
🔁 [DEVICE] Device/default changed – refreshing capture path
⏸️ [CAPTURE RECOVERY] Skipping capture restart while connecting
🔌 WebSocket did open
🔌 WebSocket ready after 1326ms - buffered 1.2s of audio
📦 Flushing 12 buffered packets (1.2s of audio, 38400 bytes)
📤 Sending audio packet seq=0 size=3200
🔑 Successfully connected to Soniox using temp key (10ms key latency)
📤 Sent buffered packet 0/12 seq=0 size=3200
📤 Sent buffered packet 11/12 seq=11 size=3200
✅ Buffer flush complete
⏹️ Keepalive timer stopped
🔄 Keepalive timer started (interval: 15.000000s)
⏱️ [TIMING] WebSocket connection established - flushing buffered audio
🔍 Found 155 text observations
✅ Text extraction successful: 3999 chars, 3999 non-whitespace, 583 words from 155 observations
✅ Captured text successfully
✅ [CAPTURE DEBUG] Screen capture successful: 4117 characters
🎯 ScreenCapture detected frontmost app: Cursor (com.todesktop.230313mzl4w4u92)
🎯 Found matching window: SonioxStreamingService.swift — clio-project (Workspace) — Modified (Cursor) - layer:0, pid:652
🎯 ScreenCapture found window: SonioxStreamingService.swift — clio-project (Workspace) — Modified (Cursor) - matches Context Preset detection
💾 [SMART-CACHE] Cached new context: com.todesktop.230313mzl4w4u92|SonioxStreamingService.swift — clio-project (Workspace) — Modified (4117 chars)
🎯 [CALLBACK DEBUG] Executing callback with fresh content (4117 chars)
🔥 [NER-TRIGGER] OCR completion callback triggered with fresh content
🔥 [NER-PREWARM] Triggering NER pre-warming with OCR text (4117 chars)
🔥 [PREWARM DEBUG] prewarmConnection() called - isEnhancementEnabled: true, isConfigured: true
🔥 [PREWARM DEBUG] connectionState: cold
🔥 [PREWARM DEBUG] Pre-warming AI connection for GROQ, environment: flyio
🛩️ [FLY.IO PREWARM] Starting Fly.io NER pre-warming (forced refresh)
🛩️ [FLY.IO-NER] sendFlyioWarmingRequest() called - starting NER processing
🎬 [NER-PREWARM] Using raw OCR text for NER: 4117 characters
🛩️ [FLY.IO-NER] OCR text retrieved for NER processing: 4117 characters
🧠 [NER-DEFAULT] Using default NER prompt for general extraction
🔥 [COLD-START] Pre-warming connection pool
📥 [NER-STORE] Stored NER entities: 448 chars - Here are the extracted entities:

**People**

* Zhaobanwgalum

**Organizations**

* Cursor
* Fly.io
...
🛩️ [FLY.IO-NER] Pre-warming completed in 633ms - NER entities extracted: Here are the extracted entities:

**People**

* Zhaobanwgalum

**Organizations**

* Cursor
* Fly.io
...
✅ [FLY.IO] NER refresh completed successfully
🔥 [COLD-START] Warming up audio system
throwing -10877
throwing -10877
🔥 [COLD-START] Audio engine started for warm-up
🔥 [COLD-START] Audio engine warm-up completed
🔥 [COLD-START] Pre-warming authenticated connections with temp key caching
🔥 [COLD-START] JWT token pre-fetched
🔥 [SYSTEM-WARMUP] TempKeyCache warmup integration
🚀 [PREFETCH] Starting background temp key prefetch
🌐 [ASR BREAKDOWN] Total: 846ms | Client↔Proxy: 93ms | Proxy↔Soniox: 753ms | Network: 753ms
💾 Cached temp key for languages: ["en", "zh"]
✅ [PREFETCH] Successfully prefetched temp key
🔥 [COLD-START] Temp key cache warmed up
🔥 [COLD-START] Reinitializing URLSession with optimized timeouts
🔥 [COLD-START] URLSession configured with extended timeouts
✅ [COLD-START] Warm-up complete with network stack optimization
📤 Sending audio packet seq=100 size=3200
💓 Sent keepalive message
📤 Sending audio packet seq=200 size=3200
📤 Sending audio packet seq=300 size=3200
💓 Sent keepalive message
📤 Sending audio packet seq=400 size=3200
💓 Sent keepalive message
📤 Sending audio packet seq=500 size=3200
📤 Sending audio packet seq=600 size=3200
💓 Sent keepalive message
📤 Sending audio packet seq=700 size=3200
💓 Sent keepalive message
📤 Sending audio packet seq=800 size=3200
📤 Sending audio packet seq=900 size=3200
💓 Sent keepalive message
📤 Sending audio packet seq=1000 size=3200
💓 Sent keepalive message
🎹 Custom modifier shortcut triggered: Right ⌘
🎤 [UI] handleToggleMiniRecorder called
🎤 [UI] toggleNotchRecorder called isRecording=true
🛑 Stopping recording
🛑 Stopping Clio streaming transcription
🏥 [AUDIO HEALTH] Health monitoring timer stopped
✅ [TAP CLEANUP] Successfully removed tap during stop
📤 Sent end-of-stream signal
📤 Sent manual finalize command
🕐 Using finalization timeout: 2000ms (connection took 108477ms)
🏁 Received <fin> token - finalization complete
✅ Received <fin> token after 371ms
⏹️ Keepalive timer stopped
📉 Released connection for account account-bundle (connections: 0)
💾 [COLD-START] Updated successful streaming timestamp
✅ Streaming stopped. Final transcript (1204 chars, 108.8s, with audio file): "So, I would... The 765 mill iseconds, can that be shrunk down even further? Um, I'm not sure why we need the 765 mill iseconds. I don't get that, because user is the one making connection with Soniox. Using the temporary key, not through the proxy. So, if we main tain the socket... We're not fetching key every time, right? So, we're... You can  just store the key using Redis or something else. Redis is fine, right? At client side, so user can fetch through the client and cli ent's warm. User don't need to request Soniox to get the key. So then when you have the key, you can just reuse the connections to connect with Soniox so that should be really fast. So, I don't get the 750 milliseconds. Let's sign out. Um, I'm really worried about this new issue that we fig ure. Please draft a new document, uh, with all the... You can write down the full log that I gave you. And with a lot of inform ation and context, because I'm going to have another agent take take a look at it. And Just wondering if we can even squish down the latency, but maybe that would be hard. So, y es, this new issue. And then, ple ase go ahead and, u h, check off all the bug  reports that are related to what we implement."
✅ Streaming transcription completed successfully, length: 1204 characters
⏱️ [TIMING] Subscription tracking: 6.6ms
⏱️ [TIMING] ASR word tracking: 0.2ms
🧠 Performing intelligent end-context detection for streaming
⏱️ [CONTEXT DETAIL] Cache check: 0.0ms
⚡ [SMART-OPTIMIZATION] Using smart cached screen context (4117 chars) - skipping new capture
⏱️ [STREAMING CONTEXT TIMING] Screen capture + context detection: 0.1ms
🎯 Starting dynamic context-aware AI enhancement with tracking for text (1204 characters)
⚡ [FAST-PATH] Using pre-warmed context - skipping redundant detection
⚡ [PREWARMED] Using pre-warmed NER context for Code Review enhancement
🌐 [LANG DEBUG] Multi-language setting exists: true, Single language: en
🌐 [LANG DEBUG] Using multi-language selection (prioritized): zh, en
🔍 [NER-DEBUG] getNERContextData called - nerEntities exists: true, connectionState: ready
✅ [NER-CONTEXT] Using NER entities from pre-warming (448 chars)
🔍 [NER-CONTENT] NER entities preview: Here are the extracted entities:

**People**

* Zhaobanwgalum

**Organizations**

* Cursor
* Fly.io
* Soniox
* Groq

**Projects**

* Clio
* Clio-backend-fly
* Clio-project

**Products**

* Cursor
* Cl...
💻 Sending to AI provider with pre-warmed code context
💻 [PREWARMED-SYSTEM] Code system prompt: 'You are an expert at enhancing the text provided within <TRANSCRIPT> tags according to the following guidelines for developers. The information in <CO...'
💻 [PREWARMED-USER] Code user prompt: '
<DICTIONARY_TERMS>
Groq, Clio
</DICTIONARY_TERMS>

<CONTEXT_INFORMATION>
NER Context Entities:
Here are the extracted entities:

**People**

* Zhaoba...'
🛰️ Sending to AI provider via proxy: GROQ
System Message: You are an expert at enhancing the text provided within <TRANSCRIPT> tags according to the following guidelines for developers. The information in <CONTEXT_INFORMATION> section is ONLY for reference.

### INSTRUCTIONS:
1. Aggressively remove all filler words, guess words, stutters and repetitions in all languages, such as: um, uh, like, you know, so, well, I mean, kind of, sort of, basically, literally, right, alright, 嗯, 呃, 啊, 那个, 就是, 然后, 怎么说, 就是说, 那什么, 额, 呢, 吧, 哎
2. Remove any ASR endpoint tokens like "<end>".
3. Preserve the speaker's intent, meaning, tone, and style.

5. Do not add information; do not answer questions in <TRANSCRIPT>.
6. Disfluency cleanup (MANDATORY):
    - False starts and self‑corrections: If a phrase is revised (e.g., "we need it Monday… actually Wednesday"), keep ONLY the corrected version. Remove the abandoned fragment and connectors (e.g., "actually", "no", "wait", "sorry", "let me rephrase", "I mean"; 中文如「其实」「不对」「等等」「我意思是」)。
    - Stutters and repetitions: Remove duplicated words/phrases (e.g., "I I think", "we should we should", "我们 我们"), including cross‑clause duplicates from ASR.
    Examples:
    Input: "We need to finish by Monday... oh wait... actually no... by Wednesday" 
    Output: "We need to finish by Wednesday."

    Input: "I think we should, we should call the client — no wait, email the client first."
    Output: "I think we should email the client first."

    Input: "嗯 我觉得 uh 我们可以先试试。"
    Output: "我觉得我们可以先试试。"

Verification pass (MANDATORY): Before returning, re‑scan and fix: (1) remaining false starts/corrections, (2) duplicated words/phrases, (3) leftover fillers, and (4) paragraphs outside the 2–4 sentence target when a semantic split is available.
7. Format list items correctly without adding new content. When input text contains a sequence, restructure as a numbered list (1. 2. 3.).
    Examples: 
    Input: "i need to do three things first buy groceries second call mom and third finish the report"
    Output: I need to do three things:
        1. Buy groceries
        2. Call mom
        3. Finish the report
8. PRESERVE ALL LANGUAGES EXACTLY AS SPOKEN
    - NEVER translate between languages - keep Chinese as Chinese, English as English
    - When speaker mixes languages in one sentence, keep the mix exactly
    - Code-switching is intentional - preserve it completely
    - Example: "我想改 Soniox streaming service 到 Swift" → "我想改 @SonioxStreamingService.swift"
9. TECHNICAL FORMATTING FOR CODE ELEMENTS: Use backticks only for non-file items
    - Functions: `getData()`
    - Variables: `userId`
    - Classes when not files: `UserService` class
10. FILE MATCHING FROM CONTEXT:
    - Match partial names to full files: "llama" → @LlamaService.swift
    - "registry" → @ContextDetectorRegistry.swift
    
11. AUTOMATIC FILENAME PATTERN RECOGNITION:
    - When words are followed by file extensions (.py, .swift, .js, .md, .json, .txt, .sql, etc.), treat as filename
    - Convert spaces between words to underscores for filenames
    - Apply lowercase conversion for most filenames (unless context suggests CamelCase)
    
    Examples:
    Input: "connection persistence test py"
    Output: "@connection_persistence_test.py"
    
    Input: "User service manager swift"
    Output: "@UserServiceManager.swift" 
    
12. SMART FILE EXTENSION HANDLING:
    - Map spoken extensions to symbols: "dot py/js/swift/json/md/sql/txt" → ".py/.js/.swift/.json/.md/.sql/.txt"
    - Handle both explicit mentions and implied extensions from context
    
13. MULTI-WORD FILENAME CONVERSION:
    - Detect multi-word phrases that could be filenames from context
    - Convert spaces to underscores for Python-style files
    - Convert spaces to CamelCase for Swift/Java-style files when appropriate
    - Use context clues and existing files to determine naming convention
    
    Examples:
    Input: "check the context detector registry file"
    Output: "Check the @ContextDetectorRegistry.swift file"
    
    Input: "look at connection test file"
    Output: "Look at @connection_test.py file" (based on context showing .py files)

OUTPUT: Natural, cleaned text with @ for files, backticks for code elements, ALL languages preserved.

User Message: 
<DICTIONARY_TERMS>
Groq, Clio
</DICTIONARY_TERMS>

<CONTEXT_INFORMATION>
NER Context Entities:
Here are the extracted entities:

**People**

* Zhaobanwgalum

**Organizations**

* Cursor
* Fly.io
* Soniox
* Groq

**Projects**

* Clio
* Clio-backend-fly
* Clio-project

**Products**

* Cursor
* Clio
* SonioxStreamingService
* Whisper
* LibWhisper
* TranscriptionEngine

**Services**

* SonioxStreamingService
* PolarCheckoutService
* WebSocketSendActor
* WarmupCoordinator
* TempKeyCache

**Tools**

* VS Code 

**Other**

* Swift 
* ASR 
* LLM
</CONTEXT_INFORMATION>

DICTIONARY USAGE:
Fix ASR errors using <DICTIONARY_TERMS>: phonetic matches, partial matches, common errors (e.g., "clod code" → "Claude Code")

CONTEXT USAGE:
<CONTEXT_INFORMATION> provides technical terms for accuracy. Prioritize context spellings over transcript. Clean transcript only - don't respond to it.

Process the following transcript:

<TRANSCRIPT>
So, I would... The 765 mill iseconds, can that be shrunk down even further? Um, I'm not sure why we need the 765 mill iseconds. I don't get that, because user is the one making connection with Soniox. Using the temporary key, not through the proxy. So, if we main tain the socket... We're not fetching key every time, right? So, we're... You can  just store the key using Redis or something else. Redis is fine, right? At client side, so user can fetch through the client and cli ent's warm. User don't need to request Soniox to get the key. So then when you have the key, you can just reuse the connections to connect with Soniox so that should be really fast. So, I don't get the 750 milliseconds. Let's sign out. Um, I'm really worried about this new issue that we fig ure. Please draft a new document, uh, with all the... You can write down the full log that I gave you. And with a lot of inform ation and context, because I'm going to have another agent take take a look at it. And Just wondering if we can even squish down the latency, but maybe that would be hard. So, y es, this new issue. And then, ple ase go ahead and, u h, check off all the bug  reports that are related to what we implement.
</TRANSCRIPT>
🌐 [CUSTOM-PROMPT] Attempting Groq via proxy...
🔑 [DEBUG] Getting JWT token...
🔑 [DEBUG] JWT token obtained in 0ms
📝 [TIMING] Request preparation: 0.3ms
🌐 [DEBUG] Sending request to proxy...
🌐 [DEBUG] Proxy response received in 1117ms
📊 [DEBUG] HTTP Status: 200
📋 [DEBUG] Response Headers: [AnyHashable("x-powered-by"): Express, AnyHashable("Content-Encoding"): br, AnyHashable("Etag"): W/"9c5-tWmSRkMCx+8gFL+pZht2jW51IqU", AnyHashable("Date"): Fri, 15 Aug 2025 15:12:24 GMT, AnyHashable("Server"): Fly/90dd1273b (2025-08-14), AnyHashable("fly-request-id"): 01K2Q4M1VQE7Z9FEN2B6FVWAVK-sin, AnyHashable("Content-Type"): application/json; charset=utf-8, AnyHashable("Via"): 2 fly.io, AnyHashable("access-control-allow-credentials"): true, AnyHashable("Vary"): Origin]
✅ [DEBUG] Found enhancedText field
🌐 [LLM] Groq: 868ms | TTFT: 277ms
🌐   Client↔Proxy: 253ms
🔍 [CONNECTION HEALTH]
🌐 [LANG DEBUG] Multi-language setting exists: true, Single language: en
🌐 [LANG DEBUG] Using multi-language selection (prioritized): zh, en
✅ [CUSTOM-PROMPT] Groq via proxy succeeded
📊 [DETAILED STREAMING TIMING] Streaming: 532.9ms | Context: 0.1ms | LLM: 1144.9ms | Tracked Overhead: 0.2ms | Unaccounted: 7.4ms | Total: 1685.6ms
🔍 [OVERHEAD BREAKDOWN] Prompt: 0.0ms | ASR Track: 0.2ms | Window Info: 0.0ms | Word Track: 0.0ms | Database: 0.0ms
🔊 [SoundManager] Attempting to play stop sound
🔊 [SoundManager] NSSound stop sound result: true
🔍 [PASTE DEBUG] AXIsProcessTrusted: true, shouldCancelRecording: false, text length: 1118
🔍 [PASTE DEBUG] Calling CursorPaster.pasteAtCursor() after 0.05s delay
📱 Dismissing recorder
🔍 [DYNAMIC NOTCH DEBUG] Hiding notch...
🧹 Connection cleanup completed (session resources released)
📝 [GRACE] Recording session ended
📊 [ENHANCEMENT] Tracking 218 words - currentTier: pro, trialWordsRemaining: 2552
🔍 [PASTE DEBUG] About to execute CursorPaster.pasteAtCursor()
🔍 [PASTE DEBUG] CursorPaster.pasteAtCursor() called with text length: 1118
🔍 [PASTE DEBUG] AXIsProcessTrusted() returned true, proceeding
🔍 [PASTE DEBUG] UseDirectTextInsertion setting: false
🔍 [PASTE DEBUG] Direct insertion disabled, using clipboard paste
246347          HALC_ProxyIOContext.cpp:1622  HALC_ProxyIOContext::IOWorkLoop: skipping cycle due to overload
⌨️ Using CGEvent-based Command+V
🔍 [PASTE DEBUG] CursorPaster.pasteAtCursor() completed
🔍 [DYNAMIC NOTCH DEBUG] Hidden notch
✅ Streaming transcription processing completed
Task <AD4EEA1C-9AD1-4570-BA64-A0D84176F5CC>.<1> finished with error [-1001] Error Domain=NSURLErrorDomain Code=-1001 "The request timed out." UserInfo={_kCFStreamErrorCodeKey=-2103, _NSURLErrorFailingURLSessionTaskErrorKey=LocalWebSocketTask <AD4EEA1C-9AD1-4570-BA64-A0D84176F5CC>.<1>, _NSURLErrorRelatedURLSessionTaskErrorKey=(
    "LocalWebSocketTask <AD4EEA1C-9AD1-4570-BA64-A0D84176F5CC>.<1>"
), NSLocalizedDescription=The request timed out., NSErrorFailingURLStringKey=https://stt-rt.soniox.com/transcribe-websocket, NSErrorFailingURLKey=https://stt-rt.soniox.com/transcribe-websocket, _kCFStreamErrorDomainKey=4}
Connection 8: received failure notification
❌ Clio API Error: 408 - Request timeout.
⏹️ Keepalive timer stopped
nw_read_request_report [C2] Receive failed with error "Operation timed out"
nw_read_request_report [C2] Receive failed with error "Operation timed out"
nw_read_request_report [C2] Receive failed with error "Operation timed out"
nw_endpoint_flow_fillout_data_transfer_snapshot copy_info() returned NULL
nw_read_request_report [C6] Receive failed with error "Operation timed out"
nw_read_request_report [C6] Receive failed with error "Operation timed out"
nw_read_request_report [C6] Receive failed with error "Operation timed out"
nw_endpoint_flow_fillout_data_transfer_snapshot copy_info() returned NULL
🎹 Custom modifier shortcut triggered: Right ⌘
🎤 [UI] handleToggleMiniRecorder called
🎤 [UI] toggleNotchRecorder called isRecording=false
🔊 [SoundManager] Attempting to play start sound @ 1755270820.037
🔊 [SoundManager] NSSound start sound result: true
⏱️ [TIMING] start_sound_played @ 1755270820.098
📱 Showing DynamicNotch recorder (MIT licensed)
🔍 [DYNAMIC NOTCH DEBUG] Showing notch...
🔍 [DYNAMIC NOTCH DEBUG] Using screen under mouse (preserving mouse-following)
🔍 [DYNAMIC NOTCH SIZE] Using built-in screen notch size: (185.0, 32.0)
🔥 [WARMUP] ensureReady() invoked context=recorderUIShown
🔥 [SYSTEM-WARMUP] TempKeyCache warmup integration
🚀 [PREFETCH] Starting background temp key prefetch
⚡ [CACHE-HIT] Retrieved temp key in 7.3ms
⏱️ [TIMING] Temp key obtained in 7.4ms
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🔊 [SONIOX DEBUG] Full config: enable_endpoint_detection=true, model=stt-rt-preview-v2, language_hints=Optional(["en", "zh"])
cannot open file at line 49455 of [1b37c146ee]
os_unix.c:49455: (2) open(/private/var/db/DetachedSignatures) - No such file or directory
158219          HALC_ProxyIOContext.cpp:1622  HALC_ProxyIOContext::IOWorkLoop: skipping cycle due to overload
🔄 Background token refresh completed
🔄 Background token refresh completed
🎙️ [TOGGLERECORD DEBUG] ===============================================
🎙️ [TOGGLERECORD DEBUG] Starting recording attempt
🎙️ [TOGGLERECORD DEBUG] Current model: soniox-realtime-streaming
🎙️ [TOGGLERECORD DEBUG] canTranscribe: true
🎤 [toggleRecord] Starting recording, current model: soniox-realtime-streaming
🎙️ [TOGGLERECORD DEBUG] Checking subscription limits...
🎙️ [TOGGLERECORD DEBUG] ✅ Subscription check passed
🎙️ [TOGGLERECORD DEBUG] Checking model access permissions...
🎙️ [TOGGLERECORD DEBUG] ✅ Model access check passed
🎙️ [TOGGLERECORD DEBUG] ✅ All checks passed - starting recording sequence
🧊 [WARMUP] Skipping (recently run) context=hotkeyDown
🎙️ Starting recording sequence...
🎙️ [TOGGLERECORD DEBUG] Starting recording session tracking...
📝 [GRACE] Recording session started with 2552 words remaining
🎙️ [TOGGLERECORD DEBUG] ===============================================
🔧 [NER-SETUP] Setting up callback - contextService exists: true
✅ [NER-SETUP] OCR completion callback configured for NER pre-warming - callback exists: true
🎙️ [RECORD PERMISSION DEBUG] Permission granted: true
🎙️ [RECORD PERMISSION DEBUG] Thread: <_NSMainThread: 0x600002264000>{number = 1, name = main}
🎙️ [RECORD PERMISSION DEBUG] Time since app launch: 0.00s
🔄 [AUTH_REFRESH] Session still valid for 32 minutes
🎙️ [ASYNC TASK DEBUG] Starting async recording task...
🎙️ [ASYNC TASK DEBUG] Task thread: <_NSMainThread: 0x600002264000>{number = 1, name = main}
🎙️ [ASYNC TASK DEBUG] Re-evaluating model for language settings...
🎙️ [ASYNC TASK DEBUG] Model type: soniox-realtime-streaming, isStreaming: true
🎙️ [SONIOX DEBUG] Starting Soniox streaming transcription...
🎙️ [SONIOX DEBUG] Calling wakeAudioSystemIfNeeded()...
🎙️ [SONIOX DEBUG] Calling sonioxStreamingService.startStreaming()...
📊 [SESSION] Starting recording session #2
✅ Selected account account-bundle (connections: 1/10)
🎬 [CAPTURE DEBUG] Starting smart screen context capture
🔍 [CALLBACK DEBUG] onOCRCompleted callback exists: true
⏰ [CACHE] Cache is stale (age: 184.2s, ttl=120s)
🎬 Starting screen capture with verified permissions
🚀 Starting Clio streaming transcription
🎯 ScreenCapture detected frontmost app: Warp (dev.warp.Warp-Stable)
🔊 Setting up audio engine...
🎯 Found matching window: ~/clio-project (Warp) - layer:0, pid:656
🎯 ScreenCapture found window: ~/clio-project (Warp) - matches Context Preset detection
🎯 Found window: ~/clio-project (Warp)
🎯 ScreenCapture detected frontmost app: Warp (dev.warp.Warp-Stable)
🎯 Found matching window: ~/clio-project (Warp) - layer:0, pid:656
🎯 ScreenCapture found window: ~/clio-project (Warp) - matches Context Preset detection
🖼️ Attempting window-specific capture for: ~/clio-project (ID: 2201)
✅ Successfully captured window: 3516.000000x1948.000000
🌐 [LANG DEBUG] Multi-language setting exists: true, Single language: en
🌐 [LANG DEBUG] Using multi-language selection (prioritized): zh, en
🌐 [OCR DEBUG] Selected languages from settings: zh, en
🌐 [OCR DEBUG] User selection mode - prioritizing non-English: zh-Hans, en-US
🌐 Using selected languages for OCR: zh-Hans, en-US
throwing -10877
throwing -10877
🧹 [TAP CLEANUP] Removing any existing taps before installation
✅ [TAP CLEANUP] Successfully removed existing tap
🎧 [AUDIO INPUT] Using device id=104 name=MacBook Pro Microphone
🎤 Detected hardware format: 48000.000000Hz, 1 channels
🎯 [TAP INSTALL] Installing new audio tap with format: 48000.000000Hz
✅ [TAP INSTALL] Audio tap installed successfully
✅ Audio engine configured successfully
⏱️ [TIMING] Audio engine setup completed
⏱️ [TIMING] Audio capture started - buffering until WebSocket ready
🏥 [AUDIO HEALTH] Health monitoring timer started
🎙️ [SONIOX DEBUG] Soniox streaming started successfully!
⏱️ [TIMING] mic_engaged @ 1755270820.588
pass
🔍 [DYNAMIC NOTCH DEBUG] Showed notch in compact mode
✅ [AUDIO HEALTH] First audio data received - tap is functional
🌐 [ASR BREAKDOWN] Total: 1117ms | Client↔Proxy: 85ms | Proxy↔Soniox: 1031ms | Network: 1031ms
💾 Cached temp key for languages: ["en", "zh"]
✅ [PREFETCH] Successfully prefetched temp key
🔍 Found 72 text observations
✅ Text extraction successful: 2767 chars, 2767 non-whitespace, 400 words from 72 observations
✅ Captured text successfully
✅ [CAPTURE DEBUG] Screen capture successful: 2831 characters
🎯 ScreenCapture detected frontmost app: Warp (dev.warp.Warp-Stable)
🎯 Found matching window: ~/clio-project (Warp) - layer:0, pid:656
🎯 ScreenCapture found window: ~/clio-project (Warp) - matches Context Preset detection
💾 [SMART-CACHE] Cached new context: dev.warp.Warp-Stable|~/clio-project (2831 chars)
🎯 [CALLBACK DEBUG] Executing callback with fresh content (2831 chars)
🔥 [NER-TRIGGER] OCR completion callback triggered with fresh content
🔥 [NER-PREWARM] Triggering NER pre-warming with OCR text (2831 chars)
🔥 [PREWARM DEBUG] prewarmConnection() called - isEnhancementEnabled: true, isConfigured: true
🔥 [PREWARM DEBUG] connectionState: cold
🔥 [PREWARM DEBUG] Pre-warming AI connection for GROQ, environment: flyio
🛩️ [FLY.IO PREWARM] Starting Fly.io NER pre-warming (forced refresh)
🛩️ [FLY.IO-NER] sendFlyioWarmingRequest() called - starting NER processing
🎬 [NER-PREWARM] Using raw OCR text for NER: 2831 characters
🛩️ [FLY.IO-NER] OCR text retrieved for NER processing: 2831 characters
🧠 [NER-DEFAULT] Using default NER prompt for general extraction
🔌 WebSocket did open
🔌 WebSocket ready after 1164ms - buffered 1.0s of audio
📦 Flushing 10 buffered packets (1.0s of audio, 32000 bytes)
📤 Sending audio packet seq=0 size=3200
🔑 Successfully connected to Soniox using temp key (7ms key latency)
📤 Sent buffered packet 0/10 seq=1082 size=3200
📤 Sent buffered packet 9/10 seq=1091 size=3200
✅ Buffer flush complete
⏹️ Keepalive timer stopped
🔄 Keepalive timer started (interval: 15.000000s)
⏱️ [TIMING] WebSocket connection established - flushing buffered audio
📥 [NER-STORE] Stored NER entities: 508 chars - Here is the list of extracted entities:

**People/Organizations:**

* Peak XV
* Warp

**Products/Pro...
🛩️ [FLY.IO-NER] Pre-warming completed in 656ms - NER entities extracted: Here is the list of extracted entities:

**People/Organizations:**

* Peak XV
* Warp

**Products/Pro...
✅ [FLY.IO] NER refresh completed successfully
📱 Dismissing recorder
🛑 Stopping Clio streaming transcription
🏥 [AUDIO HEALTH] Health monitoring timer stopped
✅ [TAP CLEANUP] Successfully removed tap during stop
⏹️ Keepalive timer stopped
📉 Released connection for account account-bundle (connections: 0)
💾 [COLD-START] Updated successful streaming timestamp
✅ Streaming stopped. Final transcript (53 chars, 7.7s, without audio file): "Labdien, feel free to draft as many docs as possible."
🔍 [DYNAMIC NOTCH DEBUG] Hiding notch...
🔊 [SoundManager] Attempting to play esc sound (with fade)
✅ [AUDIO HEALTH] First audio data received - tap is functional
🔍 [DYNAMIC NOTCH DEBUG] Hidden notch
🎹 Custom modifier shortcut triggered: Right ⌘
🎤 [UI] handleToggleMiniRecorder called
🎤 [UI] toggleNotchRecorder called isRecording=false
🔊 [SoundManager] Attempting to play start sound @ 1755270829.330
🔊 [SoundManager] NSSound start sound result: true
⏱️ [TIMING] start_sound_played @ 1755270829.349
📱 Showing DynamicNotch recorder (MIT licensed)
🔍 [DYNAMIC NOTCH DEBUG] Showing notch...
🧊 [WARMUP] Skipping (recently run) context=recorderUIShown
🔍 [DYNAMIC NOTCH DEBUG] Using screen under mouse (preserving mouse-following)
🔍 [DYNAMIC NOTCH SIZE] Using built-in screen notch size: (185.0, 32.0)
🎙️ [TOGGLERECORD DEBUG] ===============================================
🎙️ [TOGGLERECORD DEBUG] Starting recording attempt
🎙️ [TOGGLERECORD DEBUG] Current model: soniox-realtime-streaming
🎙️ [TOGGLERECORD DEBUG] canTranscribe: true
🎤 [toggleRecord] Starting recording, current model: soniox-realtime-streaming
🎙️ [TOGGLERECORD DEBUG] Checking subscription limits...
🎙️ [TOGGLERECORD DEBUG] ✅ Subscription check passed
🎙️ [TOGGLERECORD DEBUG] Checking model access permissions...
🎙️ [TOGGLERECORD DEBUG] ✅ Model access check passed
🎙️ [TOGGLERECORD DEBUG] ✅ All checks passed - starting recording sequence
🧊 [WARMUP] Skipping (recently run) context=hotkeyDown
🎙️ Starting recording sequence...
🎙️ [TOGGLERECORD DEBUG] Starting recording session tracking...
📝 [GRACE] Recording session started with 2552 words remaining
🎙️ [TOGGLERECORD DEBUG] ===============================================
🔧 [NER-SETUP] Setting up callback - contextService exists: true
✅ [NER-SETUP] OCR completion callback configured for NER pre-warming - callback exists: true
🎙️ [RECORD PERMISSION DEBUG] Permission granted: true
🎙️ [RECORD PERMISSION DEBUG] Thread: <_NSMainThread: 0x600002264000>{number = 1, name = main}
🎙️ [RECORD PERMISSION DEBUG] Time since app launch: 0.00s
🔄 [AUTH_REFRESH] Session still valid for 32 minutes
🎙️ [ASYNC TASK DEBUG] Starting async recording task...
🎙️ [ASYNC TASK DEBUG] Task thread: <_NSMainThread: 0x600002264000>{number = 1, name = main}
🎙️ [ASYNC TASK DEBUG] Re-evaluating model for language settings...
🎙️ [ASYNC TASK DEBUG] Model type: soniox-realtime-streaming, isStreaming: true
🎙️ [SONIOX DEBUG] Starting Soniox streaming transcription...
🎙️ [SONIOX DEBUG] Calling wakeAudioSystemIfNeeded()...
🎙️ [SONIOX DEBUG] Calling sonioxStreamingService.startStreaming()...
📊 [SESSION] Starting recording session #3
✅ Selected account account-bundle (connections: 1/10)
🎬 [CAPTURE DEBUG] Starting smart screen context capture
🔍 [CALLBACK DEBUG] onOCRCompleted callback exists: true
🎯 ScreenCapture detected frontmost app: Warp (dev.warp.Warp-Stable)
🎯 Found matching window: ~/clio-project (Warp) - layer:0, pid:656
🎯 ScreenCapture found window: ~/clio-project (Warp) - matches Context Preset detection
✅ [CACHE] Context unchanged - reusing cache (2831 chars)
♻️ [SMART-CACHE] Using cached context: 2831 characters
🔥 [NER-CACHE] Triggering NER callback with cached content (2831 chars)
✅ [NER-CACHE] NER callback triggered with cached content
🚀 Starting Clio streaming transcription
🔥 [NER-PREWARM] Triggering NER pre-warming with OCR text (2831 chars)
🔥 [PREWARM DEBUG] prewarmConnection() called - isEnhancementEnabled: true, isConfigured: true
🔥 [PREWARM DEBUG] connectionState: ready
🔥 [PREWARM DEBUG] Pre-warming AI connection for GROQ, environment: flyio
🛩️ [FLY.IO PREWARM] Starting Fly.io NER pre-warming (forced refresh)
🔊 Setting up audio engine...
throwing -10877
throwing -10877
🧹 [TAP CLEANUP] Removing any existing taps before installation
✅ [TAP CLEANUP] Successfully removed existing tap
🎧 [AUDIO INPUT] Using device id=104 name=MacBook Pro Microphone
🎤 Detected hardware format: 48000.000000Hz, 1 channels
🎯 [TAP INSTALL] Installing new audio tap with format: 48000.000000Hz
✅ [TAP INSTALL] Audio tap installed successfully
✅ Audio engine configured successfully
⏱️ [TIMING] Audio engine setup completed
⏱️ [TIMING] Audio capture started - buffering until WebSocket ready
🛩️ [FLY.IO-NER] sendFlyioWarmingRequest() called - starting NER processing
🎬 [NER-PREWARM] Using raw OCR text for NER: 2831 characters
🛩️ [FLY.IO-NER] OCR text retrieved for NER processing: 2831 characters
🧠 [NER-DEFAULT] Using default NER prompt for general extraction
🏥 [AUDIO HEALTH] Health monitoring timer started
🎙️ [SONIOX DEBUG] Soniox streaming started successfully!
⏱️ [TIMING] mic_engaged @ 1755270829.903
⏱️ [TIMING] WebSocket connection established - flushing buffered audio
pass
🔍 [DYNAMIC NOTCH DEBUG] Showed notch in compact mode
✅ [AUDIO HEALTH] First audio data received - tap is functional
📥 [NER-STORE] Stored NER entities: 418 chars - Here is the list of extracted entities:

**People/Organizations:**

* Peak XV
* Warp

**Projects:**
...
🛩️ [FLY.IO-NER] Pre-warming completed in 577ms - NER entities extracted: Here is the list of extracted entities:

**People/Organizations:**

* Peak XV
* Warp

**Projects:**
...
✅ [FLY.IO] NER refresh completed successfully
📤 Sending audio packet seq=100 size=3200
💓 Sent keepalive message
🎹 Custom modifier shortcut triggered: Right ⌘
🎤 [UI] handleToggleMiniRecorder called
🎤 [UI] toggleNotchRecorder called isRecording=true
🛑 Stopping recording
🛑 Stopping Clio streaming transcription
🏥 [AUDIO HEALTH] Health monitoring timer stopped
✅ [TAP CLEANUP] Successfully removed tap during stop
📤 Sent end-of-stream signal
✅ [AUDIO HEALTH] First audio data received - tap is functional
📤 Sent manual finalize command
🕐 Using finalization timeout: 2000ms (connection took 11595ms)
⚠️ Timed out waiting for <fin> token after 2089ms — merging partial transcript
⏹️ Keepalive timer stopped
📉 Released connection for account account-bundle (connections: 0)
💾 [COLD-START] Updated successful streaming timestamp
✅ Streaming stopped. Final transcript (0 chars, 13.7s, with audio file): ""
⚠️ No text received from streaming transcription
📱 Dismissing recorder
🔍 [DYNAMIC NOTCH DEBUG] Hiding notch...
🧹 Connection cleanup completed (session resources released)
🔍 [DYNAMIC NOTCH DEBUG] Hidden notch
--
log 2
.....
Let me know if you'd like me to help with anything else!
</CONTEXT_INFORMATION>

DICTIONARY USAGE:
Fix ASR errors using <DICTIONARY_TERMS>: phonetic matches, partial matches, common errors (e.g., "clod code" → "Claude Code")

CONTEXT USAGE:
<CONTEXT_INFORMATION> provides technical terms for accuracy. Prioritize context spellings over transcript. Clean transcript only - don't respond to it.

Process the following transcript:

<TRANSCRIPT>
I pretty much is about like one hundred uh, nine hundred to twelve hundred millisecond s about this range for my end-to-end latency. Not sure if I can push it fur ther, but what do you think of our you know, after our changes, what do you think?
</TRANSCRIPT>
🌐 [CUSTOM-PROMPT] Attempting Groq via proxy...
🔑 [DEBUG] Getting JWT token...
🔑 [DEBUG] JWT token obtained in 0ms
📝 [TIMING] Request preparation: 0.2ms
🌐 [DEBUG] Sending request to proxy...
🌐 [DEBUG] Proxy response received in 576ms
📊 [DEBUG] HTTP Status: 200
📋 [DEBUG] Response Headers: [AnyHashable("fly-request-id"): 01K2Q40T2V4D6RCKR0GNBD6YG1-sin, AnyHashable("Content-Type"): application/json; charset=utf-8, AnyHashable("Content-Encoding"): br, AnyHashable("Vary"): Origin, AnyHashable("x-powered-by"): Express, AnyHashable("Server"): Fly/90dd1273b (2025-08-14), AnyHashable("Etag"): W/"5fe-YIoyPIFkl5wfIAM1Cu9qdoUtYxE", AnyHashable("Via"): 2 fly.io, AnyHashable("Date"): Fri, 15 Aug 2025 15:01:53 GMT, AnyHashable("access-control-allow-credentials"): true]
✅ [DEBUG] Found enhancedText field
🌐 [LLM] Groq: 348ms | TTFT: 293ms
🌐   Client↔Proxy: 229ms
🔍 [CONNECTION HEALTH]
🌐 [LANG DEBUG] Multi-language setting exists: true, Single language: en
🌐 [LANG DEBUG] Using multi-language selection (prioritized): zh, en
✅ [CUSTOM-PROMPT] Groq via proxy succeeded
📊 [DETAILED STREAMING TIMING] Streaming: 493.3ms | Context: 0.0ms | LLM: 595.2ms | Tracked Overhead: 0.1ms | Unaccounted: 1.0ms | Total: 1089.6ms
🔍 [OVERHEAD BREAKDOWN] Prompt: 0.0ms | ASR Track: 0.1ms | Window Info: 0.0ms | Word Track: 0.0ms | Database: 0.0ms
🔊 [SoundManager] Attempting to play stop sound
🔊 [SoundManager] NSSound stop sound result: true
🔍 [PASTE DEBUG] AXIsProcessTrusted: true, shouldCancelRecording: false, text length: 159
🔍 [PASTE DEBUG] Calling CursorPaster.pasteAtCursor() after 0.05s delay
📱 Dismissing recorder
🔍 [DYNAMIC NOTCH DEBUG] Hiding notch...
🧹 Connection cleanup completed (session resources released)
📝 [GRACE] Recording session ended
📊 [ENHANCEMENT] Tracking 30 words - currentTier: pro, trialWordsRemaining: 2552
🔍 [PASTE DEBUG] About to execute CursorPaster.pasteAtCursor()
🔍 [PASTE DEBUG] CursorPaster.pasteAtCursor() called with text length: 159
🔍 [PASTE DEBUG] AXIsProcessTrusted() returned true, proceeding
🔍 [PASTE DEBUG] UseDirectTextInsertion setting: false
🔍 [PASTE DEBUG] Direct insertion disabled, using clipboard paste
⌨️ Using CGEvent-based Command+V
🔍 [PASTE DEBUG] CursorPaster.pasteAtCursor() completed
🔍 [DYNAMIC NOTCH DEBUG] Hidden notch
✅ Streaming transcription processing completed
🔥 [WARMUP] ensureReady() invoked context=appActivation
🔥 [SYSTEM-WARMUP] TempKeyCache warmup integration
🚀 [PREFETCH] Starting background temp key prefetch
ViewBridge to RemoteViewService Terminated: Error Domain=com.apple.ViewBridge Code=18 "(null)" UserInfo={com.apple.ViewBridge.error.hint=this process disconnected remote view controller -- benign unless unexpected, com.apple.ViewBridge.error.description=NSViewBridgeErrorCanceled}
🔄 [AUTH_REFRESH] Manually triggering authentication refresh...
🔄 [AUTH_REFRESH] Session still valid for 43 minutes
🔍 [UPDATE_STATE] === updateSubscriptionState() called ===
🔍 [UPDATE_STATE] Current state before update - currentTier: pro, isInTrial: false
🔍 [UPDATE_STATE] 1. Polar canUseApp: false
🔍 [UPDATE_STATE] 1b. Polar shouldUsePolarTrial: false
🔍 [UPDATE_STATE] 2. Supabase session: kentaro@resonantai.co.site
🚨 [DEBUG] Will use TIER 2: Supabase Subscription System
🚨 [DEBUG] Supabase user: kentaro@resonantai.co.site
🚨 [DEBUG] User subscription status: active
🚨 [DEBUG] User subscription plan: pro
🚨 [CRITICAL DEBUG] [TIER 1] Checking Polar license status...
🚨 [CRITICAL DEBUG] License State: trialExpired
🚨 [CRITICAL DEBUG] Can Use App: false
🚨 [CRITICAL DEBUG] Should Use Polar Trial: false
🚨 [CRITICAL DEBUG] SKIPPING POLAR TIER 1 - shouldUsePolarTrial is false
🚨 [CRITICAL DEBUG] This allows Supabase Pro subscription to be checked!
🚨 [CRITICAL DEBUG] About to check Tier 2 condition...
🚨 [CRITICAL DEBUG] supabaseService.currentSession: NOT NIL
🚨 [CRITICAL DEBUG] supabaseService.currentUser: NOT NIL
🚨 [CRITICAL] ENTERED TIER 2 LOGIC!
🔍 [SUBSCRIPTION] [TIER 2] Checking Supabase subscription...
🔍 [SUBSCRIPTION] User email: kentaro@resonantai.co.site
🔍 [SUBSCRIPTION] Raw subscription status: 'active'
🔍 [SUBSCRIPTION] Raw subscription plan: 'pro'
🔍 [SUBSCRIPTION] Status == .active: true
🔍 [SUBSCRIPTION] Plan != nil: true
🔍 [SUBSCRIPTION] Trial ends at: 2025-07-29 13:36:32 +0000
🔍 [SUBSCRIPTION] Subscription expires at: 2025-08-30 15:20:52 +0000
🚨 [DEBUG] Checking subscription condition:
🚨 [DEBUG] user.subscriptionStatus == .active: true
🚨 [DEBUG] user.subscriptionPlan != nil: true
🚨 [DEBUG] Combined condition: true
🚨 [CRITICAL] ABOUT TO CHECK THE MAIN SUBSCRIPTION CONDITION!
🚨 [CRITICAL DEBUG] Checking subscription condition:
🚨 [CRITICAL DEBUG] user.subscriptionStatus: active
🚨 [CRITICAL DEBUG] user.subscriptionStatus.rawValue: 'active'
🚨 [CRITICAL DEBUG] user.subscriptionStatus == .active: true
🚨 [CRITICAL DEBUG] user.subscriptionPlan: Optional(Clio.SubscriptionPlan.pro)
🚨 [CRITICAL DEBUG] user.subscriptionPlan != nil: true
🚨 [CRITICAL DEBUG] Combined condition result: true
✅ [SUBSCRIPTION] [TIER 2] Using Supabase Pro by expiry - pro tier until 2025-08-30 15:20:52 +0000
🔄 [SYNC_STATE] syncTrialState called - currentTier: pro, isInTrial: false
🔄 [SYNC_STATE] Final state after syncTrialState - currentTier: pro, isInTrial: false
🌐 [ASR BREAKDOWN] Total: 844ms | Client↔Proxy: 78ms | Proxy↔Soniox: 765ms | Network: 765ms
💾 Cached temp key for languages: ["zh", "en"]
✅ [PREFETCH] Successfully prefetched temp key
❌ Clio API Error: 408 - Request timeout.
Connection 9: received failure notification

this second recording has got some issues, and now we are on a real fucking issue 

see the log, this is going to deserve another tier fucking 1 bug. 

 [RECORD PERMISSION DEBUG] Time since app launch: 0.00s
🔄 [AUTH_REFRESH] Session still valid for 43 minutes
🎙️ [ASYNC TASK DEBUG] Starting async recording task...
🎙️ [ASYNC TASK DEBUG] Task thread: <_NSMainThread: 0x6000025e8140>{number = 1, name = main}
🎙️ [ASYNC TASK DEBUG] Re-evaluating model for language settings...
🎙️ [ASYNC TASK DEBUG] Model type: soniox-realtime-streaming, isStreaming: true
🎙️ [SONIOX DEBUG] Starting Soniox streaming transcription...
🎙️ [SONIOX DEBUG] Calling wakeAudioSystemIfNeeded()...
🎙️ [SONIOX DEBUG] Calling sonioxStreamingService.startStreaming()...
📊 [SESSION] Starting recording session #3
✅ Selected account account-bundle (connections: 1/10)
🎬 [CAPTURE DEBUG] Starting smart screen context capture
🔍 [CALLBACK DEBUG] onOCRCompleted callback exists: true
🎯 ScreenCapture detected frontmost app: Cursor (com.todesktop.230313mzl4w4u92)
🎯 Found matching window: SonioxStreamingService.swift — clio-project (Workspace) — Modified (Cursor) - layer:0, pid:652
🎯 ScreenCapture found window: SonioxStreamingService.swift — clio-project (Workspace) — Modified (Cursor) - matches Context Preset detection
✅ [CACHE] Context unchanged - reusing cache (4831 chars)
♻️ [SMART-CACHE] Using cached context: 4831 characters
🔥 [NER-CACHE] Triggering NER callback with cached content (4831 chars)
✅ [NER-CACHE] NER callback triggered with cached content
🚀 Starting Clio streaming transcription
🔥 [NER-PREWARM] Triggering NER pre-warming with OCR text (4831 chars)
🔥 [PREWARM DEBUG] prewarmConnection() called - isEnhancementEnabled: true, isConfigured: true
🔥 [PREWARM DEBUG] connectionState: cold
🔥 [PREWARM DEBUG] Pre-warming AI connection for GROQ, environment: flyio
🛩️ [FLY.IO PREWARM] Starting Fly.io NER pre-warming (forced refresh)
🔊 Setting up audio engine...
throwing -10877
throwing -10877
🧹 [TAP CLEANUP] Removing any existing taps before installation
✅ [TAP CLEANUP] Successfully removed existing tap
🎧 [AUDIO INPUT] Using device id=104 name=MacBook Pro Microphone
🎤 Detected hardware format: 48000.000000Hz, 1 channels
🎯 [TAP INSTALL] Installing new audio tap with format: 48000.000000Hz
✅ [TAP INSTALL] Audio tap installed successfully
✅ Audio engine configured successfully
⏱️ [TIMING] Audio engine setup completed
⏱️ [TIMING] Audio capture started - buffering until WebSocket ready
🛩️ [FLY.IO-NER] sendFlyioWarmingRequest() called - starting NER processing
🔍 [DYNAMIC NOTCH DEBUG] Showed notch in compact mode
🎬 [NER-PREWARM] Using raw OCR text for NER: 4831 characters
🛩️ [FLY.IO-NER] OCR text retrieved for NER processing: 4831 characters
🧠 [NER-DEFAULT] Using default NER prompt for general extraction
🏥 [AUDIO HEALTH] Health monitoring timer started
🎙️ [SONIOX DEBUG] Soniox streaming started successfully!
⏱️ [TIMING] mic_engaged @ 1755270144.382
⏱️ [TIMING] WebSocket connection established - flushing buffered audio
pass
✅ [AUDIO HEALTH] First audio data received - tap is functional
nw_flow_add_write_request [C9 129.146.176.251:443 failed parent-flow (satisfied (Path is satisfied), interface: utun4, ipv4, dns, uses wifi)] cannot accept write requests
nw_write_request_report [C9] Send failed with error "Socket is not connected"
nw_flow_add_write_request [C9 129.146.176.251:443 failed parent-flow (satisfied (Path is satisfied), interface: utun4, ipv4, dns, uses wifi)] cannot accept write requests
nw_write_request_report [C9] Send failed with error "Socket is not connected"
Task <66961AFA-1412-44CF-8DE7-33C448D51E90>.<1> finished with error [57] Error Domain=NSPOSIXErrorDomain Code=57 "Socket is not connected" UserInfo={NSDescription=Socket is not connected, _NSURLErrorRelatedURLSessionTaskErrorKey=(
    "LocalWebSocketTask <66961AFA-1412-44CF-8DE7-33C448D51E90>.<1>"
), _NSURLErrorFailingURLSessionTaskErrorKey=LocalWebSocketTask <66961AFA-1412-44CF-8DE7-33C448D51E90>.<1>}
❌ Failed to send frame seq=288: The operation couldn't be completed. Socket is not connected
⚠️ Skipping failed packet seq=288, continuing with remaining 0 packets
❌ Failed to send frame seq=289: The operation couldn't be completed. Socket is not connected
⚠️ Skipping failed packet seq=289, continuing with remaining 0 packets
❌ Failed to send frame seq=290: The operation couldn't be completed. Socket is not connected
⚠️ Skipping failed packet seq=290, continuing with remaining 0 packets
❌ Failed to send frame seq=291: The operation couldn't be completed. Socket is not connected
⚠️ Skipping failed packet seq=291, continuing with remaining 0 packets
❌ Failed to send frame seq=292: The operation couldn't be completed. Socket is not connected
⚠️ Skipping failed packet seq=292, continuing with remaining 0 packets
❌ Failed to send frame seq=293: The operation couldn't be completed. Socket is not connected
⚠️ Skipping failed packet seq=293, continuing with remaining 0 packets
❌ Failed to send frame seq=294: The operation couldn't be completed. Socket is not connected
⚠️ Skipping failed packet seq=294, continuing with remaining 0 packets
❌ Failed to send frame seq=295: The operation couldn't be completed. Socket is not connected
⚠️ Skipping failed packet seq=295, continuing with remaining 0 packets
❌ Failed to send frame seq=296: The operation couldn't be completed. Socket is not connected
⚠️ Skipping failed packet seq=296, continuing with remaining 0 packets
📥 [NER-STORE] Stored NER entities: 724 chars - Here are the extracted entities:

**Organizations:**
- Soniox
- Clio
- Vercel
- Fly.io

**Projects:*...
🛩️ [FLY.IO-NER] Pre-warming completed in 857ms - NER entities extracted: Here are the extracted entities:

**Organizations:**
- Soniox
- Clio
- Vercel
- Fly.io

**Projects:*...
✅ [FLY.IO] NER refresh completed successfully
❌ Failed to send frame seq=297: The operation couldn't be completed. Socket is not connected
⚠️ Skipping failed packet seq=297, continuing with remaining 0 packets
❌ Failed to send frame seq=298: The operation couldn't be completed. Socket is not connected
⚠️ Skipping failed packet seq=298, continuing with remaining 0 packets
❌ Failed to send frame seq=299: The operation couldn't be completed. Socket is not connected
⚠️ Skipping failed packet seq=299, continuing with remaining 0 packets
📤 Sending audio packet seq=300 size=3200
❌ Failed to send frame seq=300: The operation couldn't be completed. Socket is not connected
⚠️ Skipping failed packet seq=300, continuing with remaining 0 packets
❌ Failed to send frame seq=301: The operation couldn't be completed. Socket is not connected
⚠️ Skipping failed packet seq=301, continuing with remaining 0 packets
❌ Failed to send frame seq=302: The operation couldn't be completed. Socket is not connected
⚠️ Skipping failed packet seq=302, continuing with remaining 0 packets
❌ Failed to send frame seq=303: The operation couldn't be completed. Socket is not connected
⚠️ Skipping failed packet seq=303, continuing with remaining 0 packets
❌ Failed to send frame seq=304: The operation couldn't be completed. Socket is not connected
⚠️ Skipping failed packet seq=304, continuing with remaining 0 packets
❌ Failed to send frame seq=305: The operation couldn't be completed. Socket is not connected
⚠️ Skipping failed packet seq=305, continuing with remaining 0 packets
❌ Failed to send frame seq=306: The operation couldn't be completed. Socket is not connected
⚠️ Skipping failed packet seq=306, continuing with remaining 0 packets
❌ Failed to send frame seq=307: The operation couldn't be completed. Socket is not connected
⚠️ Skipping failed packet seq=307, continuing with remaining 0 packets
❌ Failed to send frame seq=308: The operation couldn't be completed. Socket is not connected
⚠️ Skipping failed packet seq=308, continuing with remaining 0 packets
❌ Failed to send frame seq=309: The operation couldn't be completed. Socket is not connected
⚠️ Skipping failed packet seq=309, continuing with remaining 0 packets
❌ Failed to send frame seq=310: The operation couldn't be completed. Socket is not connected
⚠️ Skipping failed packet seq=310, continuing with remaining 0 packets
❌ Failed to send frame seq=311: The operation couldn't be completed. Socket is not connected
⚠️ Skipping failed packet seq=311, continuing with remaining 0 packets
❌ Failed to send frame seq=312: The operation couldn't be completed. Socket is not connected
⚠️ Skipping failed packet seq=312, continuing with remaining 0 packets
❌ Failed to send frame seq=313: The operation couldn't be completed. Socket is not connected
⚠️ Skipping failed packet seq=313, continuing with remaining 0 packets
❌ Failed to send frame seq=314: The operation couldn't be completed. Socket is not connected
⚠️ Skipping failed packet seq=314, continuing with remaining 0 packets
❌ Failed to send frame seq=315: The operation couldn't be completed. Socket is not connected
⚠️ Skipping failed packet seq=315, continuing with remaining 0 packets
❌ Failed to send frame seq=316: The operation couldn't be completed. Socket is not connected
⚠️ Skipping failed packet seq=316, continuing with remaining 0 packets
❌ Failed to send frame seq=317: The operation couldn't be completed. Socket is not connected
⚠️ Skipping failed packet seq=317, continuing with remaining 0 packets
❌ Failed to send frame seq=318: The operation couldn't be completed. Socket is not connected
⚠️ Skipping failed packet seq=318, continuing with remaining 0 packets
❌ Failed to send frame seq=319: The operation couldn't be completed. Socket is not connected
⚠️ Skipping failed packet seq=319, continuing with remaining 0 packets
❌ Failed to send frame seq=320: The operation couldn't be completed. Socket is not connected
⚠️ Skipping failed packet seq=320, continuing with remaining 0 packets
❌ Failed to send frame seq=321: The operation couldn't be completed. Socket is not connected
⚠️ Skipping failed packet seq=321, co


---
Status: ❌ OPEN | Owner: Audio/Networking


====
08-16 update 

🔄 [SYNC] LicenseSyncService initialized - Full Integration
🛠️ Debug mode - security checks relaxed
🔍 [UPDATE_STATE] === updateSubscriptionState() called ===
🔍 [UPDATE_STATE] Current state before update - currentTier: free, isInTrial: false
🔍 [UPDATE_STATE] 1. Polar canUseApp: false
🔍 [UPDATE_STATE] 1b. Polar shouldUsePolarTrial: true
🔍 [UPDATE_STATE] 2. Supabase session: nil
🚨 [DEBUG] Will use TIER 3: Local Trial System
🚨 [CRITICAL DEBUG] [TIER 1] Checking Polar license status...
🚨 [CRITICAL DEBUG] License State: trialExpired
🚨 [CRITICAL DEBUG] Can Use App: false
🚨 [CRITICAL DEBUG] Should Use Polar Trial: true
🚨 [CRITICAL DEBUG] POLAR TRIAL EXPIRED - CONTINUING TO TIER 2!
🚨 [CRITICAL DEBUG] About to check Tier 2 condition...
🚨 [CRITICAL DEBUG] supabaseService.currentSession: NIL
🚨 [CRITICAL DEBUG] supabaseService.currentUser: NIL
🔐 [ENTITLEMENT] Using cached paid entitlement until 2025-08-30 15:20:52 +0000
🔄 [SYNC_STATE] syncTrialState called - currentTier: pro, isInTrial: false
🔄 [SYNC_STATE] Final state after syncTrialState - currentTier: pro, isInTrial: false
📊 [STARTUP] Loaded trial words: 1448/4000, remaining: 2552
AudioCleanup ready
🔄 Found legacy data, starting migration...
   From: /Users/ZhaobangJetWu/Library/Application Support/com.jetsonai.clio
   To: /Users/ZhaobangJetWu/Library/Application Support/com.jetsonai.clio
   ⏭️ Skipping .DS_Store (already exists)
   ⏭️ Skipping Recordings (already exists)
   ⏭️ Skipping default.store (already exists)
   ⏭️ Skipping default.store-wal (already exists)
   ⏭️ Skipping default.store-shm (already exists)
   ⏭️ Skipping WhisperModels (already exists)
🎉 Migration completed successfully!
   Files migrated: 0
   Total size: Zero KB
📝 Legacy data preserved for safety
   You can manually delete it after verifying migration worked correctly
💾 SwiftData storage location: /Users/ZhaobangJetWu/Library/Application Support/com.jetsonai.clio/default.store
✅ [RULE-ENGINE] Successfully loaded configuration with 2 contexts
🚀 [REGISTRY] Initializing default context detectors
✅ [REGISTRY] Registered legacy detector for Email with priority 100
✅ [REGISTRY] Registered legacy detector for Code Review with priority 90
✅ [REGISTRY] Registered legacy detector for Social Media with priority 10
📊 [REGISTRY] Initialization complete with 3 legacy detectors
AddInstanceForFactory: No factory registered for id <CFUUID 0x600003a72ec0> F8BB1C28-BAE8-11D6-9C31-00039315CD46
      HALC_ShellObject.mm:615    HALC_ShellObject::SetPropertyData: call to the proxy failed, Error: 1852797029 (nope)
      HALC_ShellObject.mm:615    HALC_ShellObject::SetPropertyData: call to the proxy failed, Error: 1852797029 (nope)
      HALC_ShellObject.mm:615    HALC_ShellObject::SetPropertyData: call to the proxy failed, Error: 1852797029 (nope)
Failed to get fallback device
Successfully added device change listener
Successfully added default input change listener
🔑 TempKeyCache initialized
🔄 Background prefetch timer started
⏹️ System keepalive stopped
🔄 System keepalive started (interval: 15 minutes)
🎹 HotkeyManager initializing at 2025-08-16 01:00:21 +0000
🎹 KeyboardShortcuts library available: toggleMiniRecorder
       LoudnessManager.mm:413   PlatformUtilities::CopyHardwareModelFullName() returns unknown value: Mac16,7, defaulting hw platform key
Scheduling daily audio cleanup task
🔍 [SHORTCUT DEBUG] Library shortcut: nil
🔍 [SHORTCUT DEBUG] Custom shortcut: Right ⌘
🔍 [SHORTCUT DEBUG] Shortcut configured: true
🎹 Setting up custom shortcut monitor for: Right ⌘
✅ Keyboard shortcut configured: Right ⌘
🧪 Testing KeyboardShortcuts library...
🧪 Current shortcut from library: none
🧪 Current shortcut available: none
🧪 KeyboardShortcuts library test completed
🔧 [HOTKEY SETUP] Setting up shortcut handler at 2025-08-16 01:00:24 +0000
🧹 [HOTKEY SETUP] Cleared existing handlers
🔧 [HOTKEY SETUP] Attempting to activate KeyboardShortcuts system...
🔧 [HOTKEY SETUP] Forced library initialization
🔧 [HOTKEY SETUP] Library activation complete, ready for real handlers...
🧊 [WARMUP] Skipping (recently run) context=appActivation
🧊 [WARMUP] Skipping (recently run) context=appActivation
🔍 [UPDATE_STATE] === updateSubscriptionState() called ===
🔍 [UPDATE_STATE] Current state before update - currentTier: pro, isInTrial: false
🔍 [UPDATE_STATE] 1. Polar canUseApp: false
🔍 [UPDATE_STATE] 1b. Polar shouldUsePolarTrial: true
🔍 [UPDATE_STATE] 2. Supabase session: nil
🚨 [DEBUG] Will use TIER 3: Local Trial System
🚨 [CRITICAL DEBUG] [TIER 1] Checking Polar license status...
🚨 [CRITICAL DEBUG] License State: trialExpired
🚨 [CRITICAL DEBUG] Can Use App: false
🚨 [CRITICAL DEBUG] Should Use Polar Trial: true
🚨 [CRITICAL DEBUG] POLAR TRIAL EXPIRED - CONTINUING TO TIER 2!
🚨 [CRITICAL DEBUG] About to check Tier 2 condition...
🚨 [CRITICAL DEBUG] supabaseService.currentSession: NIL
🚨 [CRITICAL DEBUG] supabaseService.currentUser: NIL
🔐 [ENTITLEMENT] Using cached paid entitlement until 2025-08-30 15:20:52 +0000
🔄 [SYNC_STATE] syncTrialState called - currentTier: pro, isInTrial: false
🔄 [SYNC_STATE] Final state after syncTrialState - currentTier: pro, isInTrial: false
✅ LocalizationManager: Successfully loaded bundle for language: en
Loaded saved device ID: 104
Using saved device: MacBook Pro Microphone
Error: -checkForUpdatesInBackground called but .sessionInProgress == YES
Cleanup run finished — removed: 0, failed: 0
🔥 [WARMUP] ensureReady() invoked context=appLaunch
🔥 [SYSTEM-WARMUP] TempKeyCache warmup integration
🚀 [PREFETCH] Starting background temp key prefetch
163083          HALC_ProxyIOContext.cpp:1622  HALC_ProxyIOContext::IOWorkLoop: skipping cycle due to overload
🔄 [AUTH_REFRESH] Manually triggering authentication refresh...
🔄 [AUTH_REFRESH] No session to refresh
🔄 [AUTH_REFRESH] Manually triggering authentication refresh...
🔄 [AUTH_REFRESH] No session to refresh
🔧 [HOTKEY SETUP] Setting up actual handlers...
✅ [HOTKEY SETUP] Real handlers configured
🚀 [HOTKEY SETUP] Complete setup finished - handlers active
🔍 [UPDATE_STATE] === updateSubscriptionState() called ===
🔍 [UPDATE_STATE] Current state before update - currentTier: pro, isInTrial: false
🔍 [UPDATE_STATE] 1. Polar canUseApp: false
🔍 [UPDATE_STATE] 1b. Polar shouldUsePolarTrial: true
🔍 [UPDATE_STATE] 2. Supabase session: nil
🚨 [DEBUG] Will use TIER 3: Local Trial System
🚨 [CRITICAL DEBUG] [TIER 1] Checking Polar license status...
🚨 [CRITICAL DEBUG] License State: trialExpired
🚨 [CRITICAL DEBUG] Can Use App: false
🚨 [CRITICAL DEBUG] Should Use Polar Trial: true
🚨 [CRITICAL DEBUG] POLAR TRIAL EXPIRED - CONTINUING TO TIER 2!
🚨 [CRITICAL DEBUG] About to check Tier 2 condition...
🚨 [CRITICAL DEBUG] supabaseService.currentSession: NIL
🚨 [CRITICAL DEBUG] supabaseService.currentUser: NIL
🔐 [ENTITLEMENT] Using cached paid entitlement until 2025-08-30 15:20:52 +0000
🔄 [SYNC_STATE] syncTrialState called - currentTier: pro, isInTrial: false
🔄 [SYNC_STATE] Final state after syncTrialState - currentTier: pro, isInTrial: false
🔍 [UPDATE_STATE] === updateSubscriptionState() called ===
🔍 [UPDATE_STATE] Current state before update - currentTier: pro, isInTrial: false
🔍 [UPDATE_STATE] 1. Polar canUseApp: false
🔍 [UPDATE_STATE] 1b. Polar shouldUsePolarTrial: true
🔍 [UPDATE_STATE] 2. Supabase session: nil
🚨 [DEBUG] Will use TIER 3: Local Trial System
🚨 [CRITICAL DEBUG] [TIER 1] Checking Polar license status...
🚨 [CRITICAL DEBUG] License State: trialExpired
🚨 [CRITICAL DEBUG] Can Use App: false
🚨 [CRITICAL DEBUG] Should Use Polar Trial: true
🚨 [CRITICAL DEBUG] POLAR TRIAL EXPIRED - CONTINUING TO TIER 2!
🚨 [CRITICAL DEBUG] About to check Tier 2 condition...
🚨 [CRITICAL DEBUG] supabaseService.currentSession: NIL
🚨 [CRITICAL DEBUG] supabaseService.currentUser: NIL
🔐 [ENTITLEMENT] Using cached paid entitlement until 2025-08-30 15:20:52 +0000
🔄 [SYNC_STATE] syncTrialState called - currentTier: pro, isInTrial: false
🔄 [SYNC_STATE] Final state after syncTrialState - currentTier: pro, isInTrial: false
🎹 Custom modifier shortcut triggered: Right ⌘
🎤 [UI] handleToggleMiniRecorder called
🎤 [UI] toggleNotchRecorder called isRecording=false
🔊 [SoundManager] Attempting to play start sound @ 1755306025.945
🔊 [SoundManager] NSSound start sound result: true
⏱️ [TIMING] start_sound_played @ 1755306025.955
📱 Showing DynamicNotch recorder (MIT licensed)
🔍 [DYNAMIC NOTCH DEBUG] Showing notch...
🧊 [WARMUP] Skipping (recently run) context=recorderUIShown
🔍 [DYNAMIC NOTCH DEBUG] Using screen under mouse (preserving mouse-following)
🔍 [DYNAMIC NOTCH SIZE] Using built-in screen notch size: (185.0, 32.0)
🔍 [CACHE-MISS] Fetching fresh temp key...
Unable to open mach-O at path: /AppleInternal/Library/BuildRoots/4~B5FIugA1pgyNPFl0-ZGG8fewoBL0-6a_xWhpzsk/Library/Caches/com.apple.xbs/Binaries/RenderBox/install/TempContent/Root/System/Library/PrivateFrameworks/RenderBox.framework/Versions/A/Resources/default.metallib  Error:2
nw_connection_copy_connected_local_endpoint_block_invoke [C3] Client called nw_connection_copy_connected_local_endpoint on unconnected nw_connection
nw_connection_copy_connected_remote_endpoint_block_invoke [C3] Client called nw_connection_copy_connected_remote_endpoint on unconnected nw_connection
nw_connection_copy_protocol_metadata_internal_block_invoke [C3] Client called nw_connection_copy_protocol_metadata_internal on unconnected nw_connection
nw_connection_copy_connected_local_endpoint_block_invoke [C4] Client called nw_connection_copy_connected_local_endpoint on unconnected nw_connection
nw_connection_copy_connected_remote_endpoint_block_invoke [C4] Client called nw_connection_copy_connected_remote_endpoint on unconnected nw_connection
nw_connection_copy_protocol_metadata_internal_block_invoke [C4] Client called nw_connection_copy_protocol_metadata_internal on unconnected nw_connection
🎙️ [TOGGLERECORD DEBUG] ===============================================
🎙️ [TOGGLERECORD DEBUG] Starting recording attempt
🎙️ [TOGGLERECORD DEBUG] Current model: soniox-realtime-streaming
🎙️ [TOGGLERECORD DEBUG] canTranscribe: true
🎤 [toggleRecord] Starting recording, current model: soniox-realtime-streaming
🎙️ [TOGGLERECORD DEBUG] Checking subscription limits...
🎙️ [TOGGLERECORD DEBUG] ✅ Subscription check passed
🎙️ [TOGGLERECORD DEBUG] Checking model access permissions...
🎙️ [TOGGLERECORD DEBUG] ✅ Model access check passed
🎙️ [TOGGLERECORD DEBUG] ✅ All checks passed - starting recording sequence
🧊 [WARMUP] Skipping (recently run) context=hotkeyDown
🎙️ Starting recording sequence...
🎙️ [TOGGLERECORD DEBUG] Starting recording session tracking...
📝 [GRACE] Recording session started with 2552 words remaining
🎙️ [TOGGLERECORD DEBUG] ===============================================
🔧 [NER-SETUP] Setting up callback - contextService exists: true
✅ [NER-SETUP] OCR completion callback configured for NER pre-warming - callback exists: true
🎙️ [RECORD PERMISSION DEBUG] Permission granted: true
🎙️ [RECORD PERMISSION DEBUG] Thread: <_NSMainThread: 0x600002f48040>{number = 1, name = main}
🎙️ [RECORD PERMISSION DEBUG] Time since app launch: 0.00s
🔄 [AUTH_REFRESH] No session to refresh
🎙️ [ASYNC TASK DEBUG] Starting async recording task...
🎙️ [ASYNC TASK DEBUG] Task thread: <_NSMainThread: 0x600002f48040>{number = 1, name = main}
🎙️ [ASYNC TASK DEBUG] Re-evaluating model for language settings...
🎙️ [ASYNC TASK DEBUG] Model type: soniox-realtime-streaming, isStreaming: true
🎙️ [SONIOX DEBUG] Starting Soniox streaming transcription...
🎙️ [SONIOX DEBUG] Calling wakeAudioSystemIfNeeded()...
🎙️ [SONIOX DEBUG] Calling sonioxStreamingService.startStreaming()...
📊 [SESSION] Starting recording session #1
✅ Selected account account-bundle (connections: 1/10)
🎬 [CAPTURE DEBUG] Starting smart screen context capture
🔍 [CALLBACK DEBUG] onOCRCompleted callback exists: true
🔍 [CACHE] No cache available
🚀 Starting Clio streaming transcription
🎬 Starting screen capture with verified permissions
🎯 ScreenCapture detected frontmost app: Clio (com.cliovoice.clio)
🎯 Found matching window:  (Clio) - layer:0, pid:92191
🎯 ScreenCapture found window:  (Clio) - matches Context Preset detection
🎯 Found window:  (Clio)
🎯 ScreenCapture detected frontmost app: Clio (com.cliovoice.clio)
🎯 Found matching window:  (Clio) - layer:0, pid:92191
🎯 ScreenCapture found window:  (Clio) - matches Context Preset detection
🖼️ Attempting window-specific capture for:  (ID: 5011)
✅ Successfully captured window: 2200.000000x1556.000000
🌐 [LANG DEBUG] Multi-language setting exists: true, Single language: en
🌐 [LANG DEBUG] Using multi-language selection (prioritized): zh, en
🌐 [OCR DEBUG] Selected languages from settings: en, zh
🌐 [OCR DEBUG] User selection mode - prioritizing non-English: zh-Hans, en-US
🌐 Using selected languages for OCR: zh-Hans, en-US
🔊 Setting up audio engine...
throwing -10877
throwing -10877
🧹 [TAP CLEANUP] Removing any existing taps before installation
✅ [TAP CLEANUP] Successfully removed existing tap
🎧 [AUDIO INPUT] Using device id=104 name=MacBook Pro Microphone
🎤 Detected hardware format: 48000.000000Hz, 1 channels
🎯 [TAP INSTALL] Installing new audio tap with format: 48000.000000Hz
✅ [TAP INSTALL] Audio tap installed successfully
✅ Audio engine configured successfully
⏱️ [TIMING] Audio engine setup completed
⏱️ [TIMING] Audio capture started - buffering until WebSocket ready
Device list change detected
🔍 [DYNAMIC NOTCH DEBUG] Showed notch in compact mode
🏥 [AUDIO HEALTH] Health monitoring timer started
🎙️ [SONIOX DEBUG] Soniox streaming started successfully!
⏱️ [TIMING] mic_engaged @ 1755306026.465
🔄 Handling audio device change
✅ Device change handling completed
🆕 [COLD-START] First recording after app launch - applying background warm-up
pass
🔥 [COLD-START] Performing system warm-up with network stack pre-warming
🔥 [COLD-START] Pre-warming DNS resolution
Connection 6: received failure notification
Connection 6: failed to connect 12:8, reason -1
Connection 6: encountered error(12:8)
Task <F6029B99-4379-4F4A-9665-85D72F845D35>.<5> HTTP load failed, 0/0 bytes (error code: -1003 [12:8])
Task <F6029B99-4379-4F4A-9665-85D72F845D35>.<5> finished with error [-1003] Error Domain=NSURLErrorDomain Code=-1003 "A server with the specified hostname could not be found." UserInfo={_kCFStreamErrorCodeKey=8, NSUnderlyingError=0x6000035f4e70 {Error Domain=kCFErrorDomainCFNetwork Code=-1003 "(null)" UserInfo={_kCFStreamErrorDomainKey=12, _kCFStreamErrorCodeKey=8, _NSURLErrorNWResolutionReportKey=Resolved 0 endpoints in 0ms using unknown from cache, _NSURLErrorNWPathKey=satisfied (Path is satisfied), interface: utun4, ipv4, dns, uses wifi}}, _NSURLErrorFailingURLSessionTaskErrorKey=LocalDataTask <F6029B99-4379-4F4A-9665-85D72F845D35>.<5>, _NSURLErrorRelatedURLSessionTaskErrorKey=(
    "LocalDataTask <F6029B99-4379-4F4A-9665-85D72F845D35>.<5>"
), NSLocalizedDescription=A server with the specified hostname could not be found., NSErrorFailingURLStringKey=https://stt-rt.soniox.com/, NSErrorFailingURLKey=https://stt-rt.soniox.com/, _kCFStreamErrorDomainKey=12}
⚠️ [COLD-START] DNS warmup failed for stt-rt.soniox.com: A server with the specified hostname could not be found.
✅ [AUDIO HEALTH] First audio data received - tap is functional
🔍 [USER] Raw trial_ends_at from Supabase: '2025-07-29T13:36:32Z'
🔍 [USER] Parsed trial_ends_at: 2025-07-29 13:36:32 +0000
🔍 [USER] Parsed subscription_status: 'active' → active
🔍 [USER] Parsed subscription_plan: 'pro' → pro
✅ [AUTH] Restored session for: kentaro@resonantai.co.site
🔍 [USER] Raw trial_ends_at from Supabase: '2025-07-29T13:36:32Z'
🔍 [USER] Parsed trial_ends_at: 2025-07-29 13:36:32 +0000
🔍 [USER] Parsed subscription_status: 'active' → active
🔍 [USER] Parsed subscription_plan: 'pro' → pro
✅ [AUTH] User authenticated: kentaro@resonantai.co.site
✅ [AUTH] User authenticated: kentaro@resonantai.co.site
🔍 [UPDATE_STATE] === updateSubscriptionState() called ===
🔍 [UPDATE_STATE] Current state before update - currentTier: pro, isInTrial: false
🔍 [UPDATE_STATE] 1. Polar canUseApp: false
🔍 [UPDATE_STATE] 1b. Polar shouldUsePolarTrial: false
🔍 [UPDATE_STATE] 2. Supabase session: kentaro@resonantai.co.site
🚨 [DEBUG] Will use TIER 2: Supabase Subscription System
🚨 [DEBUG] Supabase user: kentaro@resonantai.co.site
🚨 [DEBUG] User subscription status: active
🚨 [DEBUG] User subscription plan: pro
🚨 [CRITICAL DEBUG] [TIER 1] Checking Polar license status...
🚨 [CRITICAL DEBUG] License State: trialExpired
🚨 [CRITICAL DEBUG] Can Use App: false
🚨 [CRITICAL DEBUG] Should Use Polar Trial: false
🚨 [CRITICAL DEBUG] SKIPPING POLAR TIER 1 - shouldUsePolarTrial is false
🚨 [CRITICAL DEBUG] This allows Supabase Pro subscription to be checked!
🚨 [CRITICAL DEBUG] About to check Tier 2 condition...
🚨 [CRITICAL DEBUG] supabaseService.currentSession: NOT NIL
🚨 [CRITICAL DEBUG] supabaseService.currentUser: NOT NIL
🚨 [CRITICAL] ENTERED TIER 2 LOGIC!
🔍 [SUBSCRIPTION] [TIER 2] Checking Supabase subscription...
🔍 [SUBSCRIPTION] User email: kentaro@resonantai.co.site
🔍 [SUBSCRIPTION] Raw subscription status: 'active'
🔍 [SUBSCRIPTION] Raw subscription plan: 'pro'
🔍 [SUBSCRIPTION] Status == .active: true
🔍 [SUBSCRIPTION] Plan != nil: true
🔍 [SUBSCRIPTION] Trial ends at: 2025-07-29 13:36:32 +0000
🔍 [SUBSCRIPTION] Subscription expires at: 2025-08-30 15:20:52 +0000
🚨 [DEBUG] Checking subscription condition:
🚨 [DEBUG] user.subscriptionStatus == .active: true
🚨 [DEBUG] user.subscriptionPlan != nil: true
🚨 [DEBUG] Combined condition: true
🚨 [CRITICAL] ABOUT TO CHECK THE MAIN SUBSCRIPTION CONDITION!
🚨 [CRITICAL DEBUG] Checking subscription condition:
🚨 [CRITICAL DEBUG] user.subscriptionStatus: active
🚨 [CRITICAL DEBUG] user.subscriptionStatus.rawValue: 'active'
🚨 [CRITICAL DEBUG] user.subscriptionStatus == .active: true
🚨 [CRITICAL DEBUG] user.subscriptionPlan: Optional(Clio.SubscriptionPlan.pro)
🚨 [CRITICAL DEBUG] user.subscriptionPlan != nil: true
🚨 [CRITICAL DEBUG] Combined condition result: true
✅ [SUBSCRIPTION] [TIER 2] Using Supabase Pro by expiry - pro tier until 2025-08-30 15:20:52 +0000
🔄 [SYNC_STATE] syncTrialState called - currentTier: pro, isInTrial: false
🔄 [SYNC_STATE] Final state after syncTrialState - currentTier: pro, isInTrial: false
🔍 [UPDATE_STATE] === updateSubscriptionState() called ===
🔍 [UPDATE_STATE] Current state before update - currentTier: pro, isInTrial: false
🔍 [UPDATE_STATE] 1. Polar canUseApp: false
🔍 [UPDATE_STATE] 1b. Polar shouldUsePolarTrial: false
🔍 [UPDATE_STATE] 2. Supabase session: kentaro@resonantai.co.site
🚨 [DEBUG] Will use TIER 2: Supabase Subscription System
🚨 [DEBUG] Supabase user: kentaro@resonantai.co.site
🚨 [DEBUG] User subscription status: active
🚨 [DEBUG] User subscription plan: pro
🚨 [CRITICAL DEBUG] [TIER 1] Checking Polar license status...
🚨 [CRITICAL DEBUG] License State: trialExpired
🚨 [CRITICAL DEBUG] Can Use App: false
🚨 [CRITICAL DEBUG] Should Use Polar Trial: false
🚨 [CRITICAL DEBUG] SKIPPING POLAR TIER 1 - shouldUsePolarTrial is false
🚨 [CRITICAL DEBUG] This allows Supabase Pro subscription to be checked!
🚨 [CRITICAL DEBUG] About to check Tier 2 condition...
🚨 [CRITICAL DEBUG] supabaseService.currentSession: NOT NIL
🚨 [CRITICAL DEBUG] supabaseService.currentUser: NOT NIL
🚨 [CRITICAL] ENTERED TIER 2 LOGIC!
🔍 [SUBSCRIPTION] [TIER 2] Checking Supabase subscription...
🔍 [SUBSCRIPTION] User email: kentaro@resonantai.co.site
🔍 [SUBSCRIPTION] Raw subscription status: 'active'
🔍 [SUBSCRIPTION] Raw subscription plan: 'pro'
🔍 [SUBSCRIPTION] Status == .active: true
🔍 [SUBSCRIPTION] Plan != nil: true
🔍 [SUBSCRIPTION] Trial ends at: 2025-07-29 13:36:32 +0000
🔍 [SUBSCRIPTION] Subscription expires at: 2025-08-30 15:20:52 +0000
🚨 [DEBUG] Checking subscription condition:
🚨 [DEBUG] user.subscriptionStatus == .active: true
🚨 [DEBUG] user.subscriptionPlan != nil: true
🚨 [DEBUG] Combined condition: true
🚨 [CRITICAL] ABOUT TO CHECK THE MAIN SUBSCRIPTION CONDITION!
🚨 [CRITICAL DEBUG] Checking subscription condition:
🚨 [CRITICAL DEBUG] user.subscriptionStatus: active
🚨 [CRITICAL DEBUG] user.subscriptionStatus.rawValue: 'active'
🚨 [CRITICAL DEBUG] user.subscriptionStatus == .active: true
🚨 [CRITICAL DEBUG] user.subscriptionPlan: Optional(Clio.SubscriptionPlan.pro)
🚨 [CRITICAL DEBUG] user.subscriptionPlan != nil: true
🚨 [CRITICAL DEBUG] Combined condition result: true
✅ [SUBSCRIPTION] [TIER 2] Using Supabase Pro by expiry - pro tier until 2025-08-30 15:20:52 +0000
🔄 [SYNC_STATE] syncTrialState called - currentTier: pro, isInTrial: false
🔄 [SYNC_STATE] Final state after syncTrialState - currentTier: pro, isInTrial: false
🔍 Found 38 text observations
✅ Text extraction successful: 840 chars, 840 non-whitespace, 143 words from 38 observations
🌐 [ASR BREAKDOWN] Total: 2165ms | Client↔Proxy: 1305ms | Proxy↔Soniox: 860ms | Network: 854ms
💾 Cached temp key for languages: ["zh", "en"]
🗓️ [TTL-SCHEDULE] Scheduling temp key refresh for key=global in 3000s (expiresAt=2025-08-16 02:00:27 +0000)
⚠️ WebSocket connect failed (attempt 1). Retrying in 500ms…
🌐 [PATH] Network path changed (status=satisfied) – triggering recovery
✅ Captured text successfully
✅ [PREFETCH] Successfully prefetched temp key
⏹️ Keepalive timer stopped
✅ [CAPTURE DEBUG] Screen capture successful: 890 characters
🎯 ScreenCapture detected frontmost app: Clio (com.cliovoice.clio)
🎯 Found matching window:  (Clio) - layer:0, pid:92191
🎯 ScreenCapture found window:  (Clio) - matches Context Preset detection
💾 [SMART-CACHE] Cached new context: com.cliovoice.clio| (890 chars)
🎯 [CALLBACK DEBUG] Executing callback with fresh content (890 chars)
🔥 [NER-TRIGGER] OCR completion callback triggered with fresh content
🔥 [NER-PREWARM] Triggering NER pre-warming with OCR text (890 chars)
🔥 [PREWARM DEBUG] prewarmConnection() called - isEnhancementEnabled: true, isConfigured: true
🔥 [PREWARM DEBUG] connectionState: cold
🔥 [PREWARM DEBUG] Pre-warming AI connection for GROQ, environment: flyio
🛩️ [FLY.IO PREWARM] Starting Fly.io NER pre-warming (forced refresh)
⚡ [CACHE-HIT] Retrieved temp key in 3.1ms
⏱️ [TIMING] Temp key obtained in 3.1ms
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🔊 [SONIOX DEBUG] Full config: enable_endpoint_detection=true, model=stt-rt-preview-v2, language_hints=Optional(["en", "zh"])
Connection 10: received failure notification
Connection 10: failed to connect 12:8, reason -1
Connection 10: encountered error(12:8)
Task <C3C13B57-4BF7-4E44-A2CD-A29B5A0FB68B>.<1> HTTP load failed, 0/0 bytes (error code: -1003 [12:8])
Task <C3C13B57-4BF7-4E44-A2CD-A29B5A0FB68B>.<1> finished with error [-1003] Error Domain=NSURLErrorDomain Code=-1003 "A server with the specified hostname could not be found." UserInfo={NSErrorFailingURLStringKey=https://stt-rt.soniox.com/transcribe-websocket, NSErrorFailingURLKey=https://stt-rt.soniox.com/transcribe-websocket, _NSURLErrorRelatedURLSessionTaskErrorKey=(
    "LocalWebSocketTask <C3C13B57-4BF7-4E44-A2CD-A29B5A0FB68B>.<1>"
), _NSURLErrorFailingURLSessionTaskErrorKey=LocalWebSocketTask <C3C13B57-4BF7-4E44-A2CD-A29B5A0FB68B>.<1>, NSLocalizedDescription=A server with the specified hostname could not be found.}
🛩️ [FLY.IO-NER] sendFlyioWarmingRequest() called - starting NER processing
🔥 [COLD-START] Pre-warming connection pool
🎬 [NER-PREWARM] Using raw OCR text for NER: 890 characters
🛩️ [FLY.IO-NER] OCR text retrieved for NER processing: 890 characters
🧠 [NER-DEFAULT] Using default NER prompt for general extraction
⚠️ WebSocket connect failed (attempt 1). Retrying in 500ms…
🔁 [DEVICE] Device/default changed – refreshing capture path
🔄 [CAPTURE RECOVERY] Restarting audio capture without closing WebSocket
Connection 11: received failure notification
Connection 11: failed to connect 12:8, reason -1
Connection 11: encountered error(12:8)
Task <AABC95C8-EAA4-4E0E-886A-7052DEDEA1BB>.<1> HTTP load failed, 0/0 bytes (error code: -1003 [12:8])
Task <AABC95C8-EAA4-4E0E-886A-7052DEDEA1BB>.<1> finished with error [-1003] Error Domain=NSURLErrorDomain Code=-1003 "A server with the specified hostname could not be found." UserInfo={_kCFStreamErrorCodeKey=8, NSUnderlyingError=0x6000034a72d0 {Error Domain=kCFErrorDomainCFNetwork Code=-1003 "(null)" UserInfo={_kCFStreamErrorDomainKey=12, _kCFStreamErrorCodeKey=8, _NSURLErrorNWResolutionReportKey=Resolved 0 endpoints in 0ms using unknown from cache, _NSURLErrorNWPathKey=satisfied (Path is satisfied), interface: utun4, ipv4, dns, uses wifi}}, _NSURLErrorFailingURLSessionTaskErrorKey=LocalDataTask <AABC95C8-EAA4-4E0E-886A-7052DEDEA1BB>.<1>, _NSURLErrorRelatedURLSessionTaskErrorKey=(
    "LocalDataTask <AABC95C8-EAA4-4E0E-886A-7052DEDEA1BB>.<1>"
), NSLocalizedDescription=A server with the specified hostname could not be found., NSErrorFailingURLStringKey=https://stt-rt.soniox.com/, NSErrorFailingURLKey=https://stt-rt.soniox.com/, _kCFStreamErrorDomainKey=12}
⚠️ [COLD-START] Connection warmup attempt for https://stt-rt.soniox.com: A server with the specified hostname could not be found.
163083          HALC_ProxyIOContext.cpp:1622  HALC_ProxyIOContext::IOWorkLoop: skipping cycle due to overload
🔁 [CAPTURE RECOVERY] Attempt 1 to restart capture
🔊 Setting up audio engine...
throwing -10877
throwing -10877
🧹 [TAP CLEANUP] Removing any existing taps before installation
✅ [TAP CLEANUP] Successfully removed existing tap
🎧 [AUDIO INPUT] Using device id=104 name=MacBook Pro Microphone
🎤 Detected hardware format: 48000.000000Hz, 1 channels
🎯 [TAP INSTALL] Installing new audio tap with format: 48000.000000Hz
✅ [TAP INSTALL] Audio tap installed successfully
✅ Audio engine configured successfully
⚡ [CACHE-HIT] Retrieved temp key in 70.6ms
⏱️ [TIMING] Temp key obtained in 71.4ms
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🔊 [SONIOX DEBUG] Full config: enable_endpoint_detection=true, model=stt-rt-preview-v2, language_hints=Optional(["zh", "en"])
Connection 14: received failure notification
Connection 14: failed to connect 12:8, reason -1
Connection 14: encountered error(12:8)
Task <E050C71F-5EC2-4D29-825B-BA691FA659D1>.<2> HTTP load failed, 0/0 bytes (error code: -1003 [12:8])
Task <E050C71F-5EC2-4D29-825B-BA691FA659D1>.<2> finished with error [-1003] Error Domain=NSURLErrorDomain Code=-1003 "A server with the specified hostname could not be found." UserInfo={NSErrorFailingURLStringKey=https://stt-rt.soniox.com/transcribe-websocket, NSErrorFailingURLKey=https://stt-rt.soniox.com/transcribe-websocket, _NSURLErrorRelatedURLSessionTaskErrorKey=(
    "LocalWebSocketTask <E050C71F-5EC2-4D29-825B-BA691FA659D1>.<2>"
), _NSURLErrorFailingURLSessionTaskErrorKey=LocalWebSocketTask <E050C71F-5EC2-4D29-825B-BA691FA659D1>.<2>, NSLocalizedDescription=A server with the specified hostname could not be found.}
✅ [CAPTURE RECOVERY] Audio capture restarted successfully on attempt 1
🌐 [RECOVERY] WebSocket not ready during capture restart – initiating connection
⚠️ WebSocket connect failed (attempt 1). Retrying in 500ms…
⚡ [CACHE-HIT] Retrieved temp key in 0.1ms
⏱️ [TIMING] Temp key obtained in 0.2ms
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🔊 [SONIOX DEBUG] Full config: enable_endpoint_detection=true, model=stt-rt-preview-v2, language_hints=Optional(["en", "zh"])
Connection 15: received failure notification
Connection 15: failed to connect 12:8, reason -1
Connection 15: encountered error(12:8)
Task <FBEBD1AD-CE3B-41C5-8D33-D4C9A6658D67>.<3> HTTP load failed, 0/0 bytes (error code: -1003 [12:8])
Task <FBEBD1AD-CE3B-41C5-8D33-D4C9A6658D67>.<3> finished with error [-1003] Error Domain=NSURLErrorDomain Code=-1003 "A server with the specified hostname could not be found." UserInfo={NSErrorFailingURLStringKey=https://stt-rt.soniox.com/transcribe-websocket, NSErrorFailingURLKey=https://stt-rt.soniox.com/transcribe-websocket, _NSURLErrorRelatedURLSessionTaskErrorKey=(
    "LocalWebSocketTask <FBEBD1AD-CE3B-41C5-8D33-D4C9A6658D67>.<3>"
), _NSURLErrorFailingURLSessionTaskErrorKey=LocalWebSocketTask <FBEBD1AD-CE3B-41C5-8D33-D4C9A6658D67>.<3>, NSLocalizedDescription=A server with the specified hostname could not be found.}
⚠️ WebSocket connect failed (attempt 1). Retrying in 500ms…
✅ [AUDIO HEALTH] First audio data received - tap is functional
⚡ [CACHE-HIT] Retrieved temp key in 0.0ms
⏱️ [TIMING] Temp key obtained in 0.2ms
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🔊 [SONIOX DEBUG] Full config: enable_endpoint_detection=true, model=stt-rt-preview-v2, language_hints=Optional(["en", "zh"])
Connection 16: received failure notification
Connection 16: failed to connect 12:8, reason -1
Connection 16: encountered error(12:8)
Task <5C5FB119-5213-412F-A5F2-14A1BD4731EC>.<4> HTTP load failed, 0/0 bytes (error code: -1003 [12:8])
Task <5C5FB119-5213-412F-A5F2-14A1BD4731EC>.<4> finished with error [-1003] Error Domain=NSURLErrorDomain Code=-1003 "A server with the specified hostname could not be found." UserInfo={NSErrorFailingURLStringKey=https://stt-rt.soniox.com/transcribe-websocket, NSErrorFailingURLKey=https://stt-rt.soniox.com/transcribe-websocket, _NSURLErrorRelatedURLSessionTaskErrorKey=(
    "LocalWebSocketTask <5C5FB119-5213-412F-A5F2-14A1BD4731EC>.<4>"
), _NSURLErrorFailingURLSessionTaskErrorKey=LocalWebSocketTask <5C5FB119-5213-412F-A5F2-14A1BD4731EC>.<4>, NSLocalizedDescription=A server with the specified hostname could not be found.}
❌ WebSocket connection failed after 2 attempts: A server with the specified hostname could not be found.
⚠️ Preconnect failed (non-fatal): A server with the specified hostname could not be found.
nw_connection_copy_connected_local_endpoint_block_invoke [C13] Client called nw_connection_copy_connected_local_endpoint on unconnected nw_connection
nw_connection_copy_connected_remote_endpoint_block_invoke [C13] Client called nw_connection_copy_connected_remote_endpoint on unconnected nw_connection
nw_connection_copy_protocol_metadata_internal_block_invoke [C13] Client called nw_connection_copy_protocol_metadata_internal on unconnected nw_connection
quic_conn_process_inbound [C8.1.1.1:2] [-01502a25b4a5505e1253ec25aea55b92e84859ed] unable to parse packet
⚡ [CACHE-HIT] Retrieved temp key in 0.0ms
⏱️ [TIMING] Temp key obtained in 0.2ms
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🔊 [SONIOX DEBUG] Full config: enable_endpoint_detection=true, model=stt-rt-preview-v2, language_hints=Optional(["zh", "en"])
Connection 17: received failure notification
Connection 17: failed to connect 12:8, reason -1
Connection 17: encountered error(12:8)
Task <4C68C753-1DDA-488A-A43C-DB9572335BDF>.<5> HTTP load failed, 0/0 bytes (error code: -1003 [12:8])
Task <4C68C753-1DDA-488A-A43C-DB9572335BDF>.<5> finished with error [-1003] Error Domain=NSURLErrorDomain Code=-1003 "A server with the specified hostname could not be found." UserInfo={NSErrorFailingURLStringKey=https://stt-rt.soniox.com/transcribe-websocket, NSErrorFailingURLKey=https://stt-rt.soniox.com/transcribe-websocket, _NSURLErrorRelatedURLSessionTaskErrorKey=(
    "LocalWebSocketTask <4C68C753-1DDA-488A-A43C-DB9572335BDF>.<5>"
), _NSURLErrorFailingURLSessionTaskErrorKey=LocalWebSocketTask <4C68C753-1DDA-488A-A43C-DB9572335BDF>.<5>, NSLocalizedDescription=A server with the specified hostname could not be found.}
⚠️ WebSocket connect failed (attempt 2). Retrying in 1000ms…
quic_conn_process_inbound [C8.1.1.1:2] [-01502a25b4a5505e1253ec25aea55b92e84859ed] unable to parse packet
quic_conn_process_inbound [C8.1.1.1:2] [-01502a25b4a5505e1253ec25aea55b92e84859ed] unable to parse packet
quic_conn_process_inbound [C8.1.1.1:2] [-01502a25b4a5505e1253ec25aea55b92e84859ed] unable to parse packet
🔥 [COLD-START] Warming up audio system
throwing -10877
throwing -10877
🔥 [COLD-START] Audio engine started for warm-up
✅ Successfully updated user stats in Supabase
🔄 Stats synced successfully (FORCED)
📊 196160 words, 1491.2 minutes
✅ Successfully updated user stats in Supabase
🔄 Stats synced successfully (FORCED)
📊 196160 words, 1491.2 minutes
🔥 [COLD-START] Audio engine warm-up completed
🔥 [COLD-START] Pre-warming authenticated connections with temp key caching
🔥 [COLD-START] JWT token pre-fetched
🔥 [SYSTEM-WARMUP] TempKeyCache warmup integration
🚀 [PREFETCH] Starting background temp key prefetch
⚡ [CACHE-HIT] Retrieved temp key in 0.1ms
⏱️ [TIMING] Temp key obtained in 0.4ms
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🔊 [SONIOX DEBUG] Full config: enable_endpoint_detection=true, model=stt-rt-preview-v2, language_hints=Optional(["en", "zh"])
Connection 18: received failure notification
Connection 18: failed to connect 12:8, reason -1
Connection 18: encountered error(12:8)
Task <4A64BA7F-BC0C-417B-9D0F-DA39815590F1>.<6> HTTP load failed, 0/0 bytes (error code: -1003 [12:8])
Task <4A64BA7F-BC0C-417B-9D0F-DA39815590F1>.<6> finished with error [-1003] Error Domain=NSURLErrorDomain Code=-1003 "A server with the specified hostname could not be found." UserInfo={NSErrorFailingURLStringKey=https://stt-rt.soniox.com/transcribe-websocket, NSErrorFailingURLKey=https://stt-rt.soniox.com/transcribe-websocket, _NSURLErrorRelatedURLSessionTaskErrorKey=(
    "LocalWebSocketTask <4A64BA7F-BC0C-417B-9D0F-DA39815590F1>.<6>"
), _NSURLErrorFailingURLSessionTaskErrorKey=LocalWebSocketTask <4A64BA7F-BC0C-417B-9D0F-DA39815590F1>.<6>, NSLocalizedDescription=A server with the specified hostname could not be found.}
⚠️ WebSocket connect failed (attempt 2). Retrying in 1000ms…
⚡ [CACHE-HIT] Retrieved temp key in 0.2ms
⏱️ [TIMING] Temp key obtained in 0.5ms
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🔊 [SONIOX DEBUG] Full config: enable_endpoint_detection=true, model=stt-rt-preview-v2, language_hints=Optional(["en", "zh"])
Connection 19: received failure notification
Connection 19: failed to connect 12:8, reason -1
Connection 19: encountered error(12:8)
Task <A9FC404A-B35B-495F-88B2-788AED4A04DF>.<7> HTTP load failed, 0/0 bytes (error code: -1003 [12:8])
Task <A9FC404A-B35B-495F-88B2-788AED4A04DF>.<7> finished with error [-1003] Error Domain=NSURLErrorDomain Code=-1003 "A server with the specified hostname could not be found." UserInfo={NSErrorFailingURLStringKey=https://stt-rt.soniox.com/transcribe-websocket, NSErrorFailingURLKey=https://stt-rt.soniox.com/transcribe-websocket, _NSURLErrorRelatedURLSessionTaskErrorKey=(
    "LocalWebSocketTask <A9FC404A-B35B-495F-88B2-788AED4A04DF>.<7>"
), _NSURLErrorFailingURLSessionTaskErrorKey=LocalWebSocketTask <A9FC404A-B35B-495F-88B2-788AED4A04DF>.<7>, NSLocalizedDescription=A server with the specified hostname could not be found.}
⚠️ WebSocket connect failed (attempt 2). Retrying in 1000ms…
📥 [NER-STORE] Stored NER entities: 212 chars - Here are the extracted entities:

* **People**: 
	+ Kentaro
* **Organizations**: 
	+ Clio
* **Produc...
🛩️ [FLY.IO-NER] Pre-warming completed in 1219ms - NER entities extracted: Here are the extracted entities:

* **People**: 
	+ Kentaro
* **Organizations**: 
	+ Clio
* **Produc...
✅ [FLY.IO] NER refresh completed successfully
⚡ [CACHE-HIT] Retrieved temp key in 2.7ms
⏱️ [TIMING] Temp key obtained in 2.9ms
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🔊 [SONIOX DEBUG] Full config: enable_endpoint_detection=true, model=stt-rt-preview-v2, language_hints=Optional(["zh", "en"])
Connection 20: received failure notification
Connection 20: failed to connect 12:8, reason -1
Connection 20: encountered error(12:8)
Task <76A32B2B-4089-4B02-A6A1-7132D72E0DD8>.<8> HTTP load failed, 0/0 bytes (error code: -1003 [12:8])
Task <76A32B2B-4089-4B02-A6A1-7132D72E0DD8>.<8> finished with error [-1003] Error Domain=NSURLErrorDomain Code=-1003 "A server with the specified hostname could not be found." UserInfo={NSErrorFailingURLStringKey=https://stt-rt.soniox.com/transcribe-websocket, NSErrorFailingURLKey=https://stt-rt.soniox.com/transcribe-websocket, _NSURLErrorRelatedURLSessionTaskErrorKey=(
    "LocalWebSocketTask <76A32B2B-4089-4B02-A6A1-7132D72E0DD8>.<8>"
), _NSURLErrorFailingURLSessionTaskErrorKey=LocalWebSocketTask <76A32B2B-4089-4B02-A6A1-7132D72E0DD8>.<8>, NSLocalizedDescription=A server with the specified hostname could not be found.}
❌ WebSocket connection failed after 3 attempts: A server with the specified hostname could not be found.
❌ WebSocket connection failed: A server with the specified hostname could not be found.
🛑 Stopping Clio streaming transcription
🏥 [AUDIO HEALTH] Health monitoring timer stopped
⏳ WebSocket not ready yet - waiting up to 10 seconds to avoid losing audio
⚡ [CACHE-HIT] Retrieved temp key in 0.1ms
⏱️ [TIMING] Temp key obtained in 0.3ms
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🔊 [SONIOX DEBUG] Full config: enable_endpoint_detection=true, model=stt-rt-preview-v2, language_hints=Optional(["en", "zh"])
nw_path_necp_check_for_updates Failed to copy updated result (22)
Connection 21: received failure notification
Connection 21: failed to connect 12:8, reason -1
Connection 21: encountered error(12:8)
Task <0316BFD7-3994-48DF-AD27-A20AFFDAA66E>.<9> HTTP load failed, 0/0 bytes (error code: -1003 [12:8])
Task <0316BFD7-3994-48DF-AD27-A20AFFDAA66E>.<9> finished with error [-1003] Error Domain=NSURLErrorDomain Code=-1003 "A server with the specified hostname could not be found." UserInfo={NSErrorFailingURLStringKey=https://stt-rt.soniox.com/transcribe-websocket, NSErrorFailingURLKey=https://stt-rt.soniox.com/transcribe-websocket, _NSURLErrorRelatedURLSessionTaskErrorKey=(
    "LocalWebSocketTask <0316BFD7-3994-48DF-AD27-A20AFFDAA66E>.<9>"
), _NSURLErrorFailingURLSessionTaskErrorKey=LocalWebSocketTask <0316BFD7-3994-48DF-AD27-A20AFFDAA66E>.<9>, NSLocalizedDescription=A server with the specified hostname could not be found.}
❌ WebSocket connection failed after 3 attempts: A server with the specified hostname could not be found.
❌ Path-change recovery failed: A server with the specified hostname could not be found.
🛑 Stopping Clio streaming transcription
🏥 [AUDIO HEALTH] Health monitoring timer stopped
⏳ WebSocket not ready yet - waiting up to 10 seconds to avoid losing audio
⚡ [CACHE-HIT] Retrieved temp key in 3.7ms
⏱️ [TIMING] Temp key obtained in 4.1ms
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🔊 [SONIOX DEBUG] Full config: enable_endpoint_detection=true, model=stt-rt-preview-v2, language_hints=Optional(["zh", "en"])
Connection 22: received failure notification
Connection 22: failed to connect 12:8, reason -1
Connection 22: encountered error(12:8)
Task <036B04E7-379A-4F02-84A2-260DAABAE70F>.<10> HTTP load failed, 0/0 bytes (error code: -1003 [12:8])
Task <036B04E7-379A-4F02-84A2-260DAABAE70F>.<10> finished with error [-1003] Error Domain=NSURLErrorDomain Code=-1003 "A server with the specified hostname could not be found." UserInfo={NSErrorFailingURLStringKey=https://stt-rt.soniox.com/transcribe-websocket, NSErrorFailingURLKey=https://stt-rt.soniox.com/transcribe-websocket, _NSURLErrorRelatedURLSessionTaskErrorKey=(
    "LocalWebSocketTask <036B04E7-379A-4F02-84A2-260DAABAE70F>.<10>"
), _NSURLErrorFailingURLSessionTaskErrorKey=LocalWebSocketTask <036B04E7-379A-4F02-84A2-260DAABAE70F>.<10>, NSLocalizedDescription=A server with the specified hostname could not be found.}
❌ WebSocket connection failed after 3 attempts: A server with the specified hostname could not be found.
❌ WebSocket connection failed during recovery: A server with the specified hostname could not be found.
🛑 Stopping Clio streaming transcription
🏥 [AUDIO HEALTH] Health monitoring timer stopped
⏳ WebSocket not ready yet - waiting up to 10 seconds to avoid losing audio
📱 Dismissing recorder
🛑 Stopping Clio streaming transcription
🏥 [AUDIO HEALTH] Health monitoring timer stopped
✅ [TAP CLEANUP] Successfully removed tap during stop
⏹️ Keepalive timer stopped
📉 Released connection for account account-bundle (connections: 0)
💾 [COLD-START] Updated successful streaming timestamp
✅ Streaming stopped. Final transcript (0 chars, 4.5s, without audio file): ""
🔍 [DYNAMIC NOTCH DEBUG] Hiding notch...
🔊 [SoundManager] Attempting to play esc sound (with fade)
🔍 [DYNAMIC NOTCH DEBUG] Hidden notch
⚠️ WebSocket still not ready after 10480ms - proceeding anyway
❌ Failed to send finalization: A server with the specified hostname could not be found.
⏹️ Keepalive timer stopped
💾 [COLD-START] Updated successful streaming timestamp
✅ Streaming stopped. Final transcript (0 chars, 13.0s, with audio file): ""
⚡ [CACHE-HIT] Retrieved temp key in 0.3ms
⏱️ [TIMING] Temp key obtained in 0.5ms
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🔊 [SONIOX DEBUG] Full config: enable_endpoint_detection=true, model=stt-rt-preview-v2, language_hints=Optional(["zh", "en"])
Connection 23: received failure notification
Connection 23: failed to connect 12:8, reason -1
Connection 23: encountered error(12:8)
Task <0FCE2678-D108-40F5-A421-3547855C2E7D>.<11> HTTP load failed, 0/0 bytes (error code: -1003 [12:8])
Task <0FCE2678-D108-40F5-A421-3547855C2E7D>.<11> finished with error [-1003] Error Domain=NSURLErrorDomain Code=-1003 "A server with the specified hostname could not be found." UserInfo={NSErrorFailingURLStringKey=https://stt-rt.soniox.com/transcribe-websocket, NSErrorFailingURLKey=https://stt-rt.soniox.com/transcribe-websocket, _NSURLErrorRelatedURLSessionTaskErrorKey=(
    "LocalWebSocketTask <0FCE2678-D108-40F5-A421-3547855C2E7D>.<11>"
), _NSURLErrorFailingURLSessionTaskErrorKey=LocalWebSocketTask <0FCE2678-D108-40F5-A421-3547855C2E7D>.<11>, NSLocalizedDescription=A server with the specified hostname could not be found.}
⚠️ WebSocket connect failed (attempt 1). Retrying in 500ms…
⚠️ WebSocket still not ready after 10475ms - proceeding anyway
❌ Failed to send finalization: A server with the specified hostname could not be found.
⏹️ Keepalive timer stopped
💾 [COLD-START] Updated successful streaming timestamp
✅ Streaming stopped. Final transcript (0 chars, 13.4s, with audio file): ""
⚡ [CACHE-HIT] Retrieved temp key in 0.2ms
⏱️ [TIMING] Temp key obtained in 0.4ms
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🔊 [SONIOX DEBUG] Full config: enable_endpoint_detection=true, model=stt-rt-preview-v2, language_hints=Optional(["en", "zh"])
Connection 24: received failure notification
Connection 24: failed to connect 12:8, reason -1
Connection 24: encountered error(12:8)
Task <D7CC5678-FF23-46A4-A73D-F3630F01E589>.<12> HTTP load failed, 0/0 bytes (error code: -1003 [12:8])
⚠️ WebSocket connect failed (attempt 1). Retrying in 500ms…
Task <D7CC5678-FF23-46A4-A73D-F3630F01E589>.<12> finished with error [-1003] Error Domain=NSURLErrorDomain Code=-1003 "A server with the specified hostname could not be found." UserInfo={NSErrorFailingURLStringKey=https://stt-rt.soniox.com/transcribe-websocket, NSErrorFailingURLKey=https://stt-rt.soniox.com/transcribe-websocket, _NSURLErrorRelatedURLSessionTaskErrorKey=(
    "LocalWebSocketTask <D7CC5678-FF23-46A4-A73D-F3630F01E589>.<12>"
), _NSURLErrorFailingURLSessionTaskErrorKey=LocalWebSocketTask <D7CC5678-FF23-46A4-A73D-F3630F01E589>.<12>, NSLocalizedDescription=A server with the specified hostname could not be found.}
⚡ [CACHE-HIT] Retrieved temp key in 0.1ms
⏱️ [TIMING] Temp key obtained in 0.2ms
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🔊 [SONIOX DEBUG] Full config: enable_endpoint_detection=true, model=stt-rt-preview-v2, language_hints=Optional(["en", "zh"])
Connection 25: received failure notification
Connection 25: failed to connect 12:8, reason -1
Connection 25: encountered error(12:8)
Task <A81EB6D8-B40B-43F1-B163-CB578314ED5B>.<13> HTTP load failed, 0/0 bytes (error code: -1003 [12:8])
❌ WebSocket connection failed after 2 attempts: A server with the specified hostname could not be found.
Task <A81EB6D8-B40B-43F1-B163-CB578314ED5B>.<13> finished with error [-1003] Error Domain=NSURLErrorDomain Code=-1003 "A server with the specified hostname could not be found." UserInfo={NSErrorFailingURLStringKey=https://stt-rt.soniox.com/transcribe-websocket, NSErrorFailingURLKey=https://stt-rt.soniox.com/transcribe-websocket, _NSURLErrorRelatedURLSessionTaskErrorKey=(
    "LocalWebSocketTask <A81EB6D8-B40B-43F1-B163-CB578314ED5B>.<13>"
), _NSURLErrorFailingURLSessionTaskErrorKey=LocalWebSocketTask <A81EB6D8-B40B-43F1-B163-CB578314ED5B>.<13>, NSLocalizedDescription=A server with the specified hostname could not be found.}
⚠️ Preconnect failed (non-fatal): A server with the specified hostname could not be found.
⚠️ WebSocket still not ready after 10512ms - proceeding anyway
❌ Failed to send finalization: A server with the specified hostname could not be found.
⏹️ Keepalive timer stopped
💾 [COLD-START] Updated successful streaming timestamp
✅ Streaming stopped. Final transcript (0 chars, 13.5s, with audio file): ""
⚡ [CACHE-HIT] Retrieved temp key in 0.2ms
⏱️ [TIMING] Temp key obtained in 0.3ms
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🔊 [SONIOX DEBUG] Full config: enable_endpoint_detection=true, model=stt-rt-preview-v2, language_hints=Optional(["zh", "en"])
Connection 26: received failure notification
Connection 26: failed to connect 12:8, reason -1
Connection 26: encountered error(12:8)
Task <6C126CDE-DDFF-4061-8E0E-10456E02B75F>.<14> HTTP load failed, 0/0 bytes (error code: -1003 [12:8])
⚡ [CACHE-HIT] Retrieved temp key in 0.1ms
⏱️ [TIMING] Temp key obtained in 22.5ms
Task <6C126CDE-DDFF-4061-8E0E-10456E02B75F>.<14> finished with error [-1003] Error Domain=NSURLErrorDomain Code=-1003 "A server with the specified hostname could not be found." UserInfo={NSErrorFailingURLStringKey=https://stt-rt.soniox.com/transcribe-websocket, NSErrorFailingURLKey=https://stt-rt.soniox.com/transcribe-websocket, _NSURLErrorRelatedURLSessionTaskErrorKey=(
    "LocalWebSocketTask <6C126CDE-DDFF-4061-8E0E-10456E02B75F>.<14>"
), _NSURLErrorFailingURLSessionTaskErrorKey=LocalWebSocketTask <6C126CDE-DDFF-4061-8E0E-10456E02B75F>.<14>, NSLocalizedDescription=A server with the specified hostname could not be found.}
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🔊 [SONIOX DEBUG] Full config: enable_endpoint_detection=true, model=stt-rt-preview-v2, language_hints=Optional(["zh", "en"])
⚠️ WebSocket connect failed (attempt 1). Retrying in 500ms…
Connection 27: received failure notification
Connection 27: failed to connect 12:8, reason -1
Connection 27: encountered error(12:8)
Task <FA1918E3-FAD8-44FC-8AE2-88405103A7EA>.<15> HTTP load failed, 0/0 bytes (error code: -1003 [12:8])
Task <FA1918E3-FAD8-44FC-8AE2-88405103A7EA>.<15> finished with error [-1003] Error Domain=NSURLErrorDomain Code=-1003 "A server with the specified hostname could not be found." UserInfo={NSErrorFailingURLStringKey=https://stt-rt.soniox.com/transcribe-websocket, NSErrorFailingURLKey=https://stt-rt.soniox.com/transcribe-websocket, _NSURLErrorRelatedURLSessionTaskErrorKey=(
    "LocalWebSocketTask <FA1918E3-FAD8-44FC-8AE2-88405103A7EA>.<15>"
), _NSURLErrorFailingURLSessionTaskErrorKey=LocalWebSocketTask <FA1918E3-FAD8-44FC-8AE2-88405103A7EA>.<15>, NSLocalizedDescription=A server with the specified hostname could not be found.}
❌ WebSocket connection failed after 2 attempts: A server with the specified hostname could not be found.
⚠️ Preconnect failed (non-fatal): A server with the specified hostname could not be found.
⚡ [CACHE-HIT] Retrieved temp key in 0.1ms
⏱️ [TIMING] Temp key obtained in 0.2ms
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🔊 [SONIOX DEBUG] Full config: enable_endpoint_detection=true, model=stt-rt-preview-v2, language_hints=Optional(["en", "zh"])
Connection 28: received failure notification
Connection 28: failed to connect 12:8, reason -1
Connection 28: encountered error(12:8)
Task <74C1B5EA-2313-4186-A2BB-BE02032590B7>.<16> HTTP load failed, 0/0 bytes (error code: -1003 [12:8])
Task <74C1B5EA-2313-4186-A2BB-BE02032590B7>.<16> finished with error [-1003] Error Domain=NSURLErrorDomain Code=-1003 "A server with the specified hostname could not be found." UserInfo={NSErrorFailingURLStringKey=https://stt-rt.soniox.com/transcribe-websocket, NSErrorFailingURLKey=https://stt-rt.soniox.com/transcribe-websocket, _NSURLErrorRelatedURLSessionTaskErrorKey=(
    "LocalWebSocketTask <74C1B5EA-2313-4186-A2BB-BE02032590B7>.<16>"
), _NSURLErrorFailingURLSessionTaskErrorKey=LocalWebSocketTask <74C1B5EA-2313-4186-A2BB-BE02032590B7>.<16>, NSLocalizedDescription=A server with the specified hostname could not be found.}
❌ WebSocket connection failed after 2 attempts: A server with the specified hostname could not be found.
⚠️ Preconnect failed (non-fatal): A server with the specified hostname could not be found.
🌐 [ASR BREAKDOWN] Total: 12589ms | Client↔Proxy: 12261ms | Proxy↔Soniox: 327ms | Network: 321ms
🗑️ Evicted oldest temp key to maintain cache size limit
💾 Cached temp key for languages: ["zh", "en"]
🗓️ [TTL-SCHEDULE] Scheduling temp key refresh for key=global in 3000s (expiresAt=2025-08-16 02:00:40 +0000)
✅ [PREFETCH] Successfully prefetched temp key
🔥 [COLD-START] Temp key cache warmed up
🔥 [COLD-START] Reinitializing URLSession with optimized timeouts
🔥 [COLD-START] URLSession configured with extended timeouts
✅ [COLD-START] Warm-up complete with network stack optimization
⏹️ Keepalive timer stopped
Device list change detected
🔄 Handling audio device change
✅ Device change handling completed
nw_read_request_report [C8] Receive failed with error "Operation timed out"
nw_read_request_report [C8] Receive failed with error "Operation timed out"
nw_read_request_report [C8] Receive failed with error "Operation timed out"
nw_endpoint_flow_fillout_data_transfer_snapshot copy_info() returned NULL
🔥 [WARMUP] ensureReady() invoked context=reachabilityChange
🔥 [SYSTEM-WARMUP] TempKeyCache warmup integration
🚀 [PREFETCH] Starting background temp key prefetch
cannot open file at line 49455 of [1b37c146ee]
os_unix.c:49455: (2) open(/private/var/db/DetachedSignatures) - No such file or directory
🔄 Background token refresh completed
⚠️ [PREFETCH] Failed to prefetch temp key: Failed to fetch temp key: HTTP 502
⚠️ Background token refresh failed: Clio.TokenError.authenticationFailed(502)

🔄 [SYNC] LicenseSyncService initialized - Full Integration
🛠️ Debug mode - security checks relaxed
🔍 [UPDATE_STATE] === updateSubscriptionState() called ===
🔍 [UPDATE_STATE] Current state before update - currentTier: free, isInTrial: false
🔍 [UPDATE_STATE] 1. Polar canUseApp: false
🔍 [UPDATE_STATE] 1b. Polar shouldUsePolarTrial: true
🔍 [UPDATE_STATE] 2. Supabase session: nil
🚨 [DEBUG] Will use TIER 3: Local Trial System
🚨 [CRITICAL DEBUG] [TIER 1] Checking Polar license status...
🚨 [CRITICAL DEBUG] License State: trialExpired
🚨 [CRITICAL DEBUG] Can Use App: false
🚨 [CRITICAL DEBUG] Should Use Polar Trial: true
🚨 [CRITICAL DEBUG] POLAR TRIAL EXPIRED - CONTINUING TO TIER 2!
🚨 [CRITICAL DEBUG] About to check Tier 2 condition...
🚨 [CRITICAL DEBUG] supabaseService.currentSession: NIL
🚨 [CRITICAL DEBUG] supabaseService.currentUser: NIL
🔐 [ENTITLEMENT] Using cached paid entitlement until 2025-08-30 15:20:52 +0000
🔄 [SYNC_STATE] syncTrialState called - currentTier: pro, isInTrial: false
🔄 [SYNC_STATE] Final state after syncTrialState - currentTier: pro, isInTrial: false
📊 [STARTUP] Loaded trial words: 1448/4000, remaining: 2552
AudioCleanup ready
🔄 Found legacy data, starting migration...
   From: /Users/ZhaobangJetWu/Library/Application Support/com.jetsonai.clio
   To: /Users/ZhaobangJetWu/Library/Application Support/com.jetsonai.clio
   ⏭️ Skipping .DS_Store (already exists)
   ⏭️ Skipping Recordings (already exists)
   ⏭️ Skipping default.store (already exists)
   ⏭️ Skipping default.store-wal (already exists)
   ⏭️ Skipping default.store-shm (already exists)
   ⏭️ Skipping WhisperModels (already exists)
🎉 Migration completed successfully!
   Files migrated: 0
   Total size: Zero KB
📝 Legacy data preserved for safety
   You can manually delete it after verifying migration worked correctly
💾 SwiftData storage location: /Users/ZhaobangJetWu/Library/Application Support/com.jetsonai.clio/default.store
✅ [RULE-ENGINE] Successfully loaded configuration with 2 contexts
🚀 [REGISTRY] Initializing default context detectors
✅ [REGISTRY] Registered legacy detector for Email with priority 100
✅ [REGISTRY] Registered legacy detector for Code Review with priority 90
✅ [REGISTRY] Registered legacy detector for Social Media with priority 10
📊 [REGISTRY] Initialization complete with 3 legacy detectors
AddInstanceForFactory: No factory registered for id <CFUUID 0x600003ddc280> F8BB1C28-BAE8-11D6-9C31-00039315CD46
      HALC_ShellObject.mm:615    HALC_ShellObject::SetPropertyData: call to the proxy failed, Error: 1852797029 (nope)
      HALC_ShellObject.mm:615    HALC_ShellObject::SetPropertyData: call to the proxy failed, Error: 1852797029 (nope)
      HALC_ShellObject.mm:615    HALC_ShellObject::SetPropertyData: call to the proxy failed, Error: 1852797029 (nope)
Failed to get fallback device
Successfully added device change listener
Successfully added default input change listener
🔑 TempKeyCache initialized
🔄 Background prefetch timer started
⏹️ System keepalive stopped
🔄 System keepalive started (interval: 15 minutes)
🎹 HotkeyManager initializing at 2025-08-16 01:11:46 +0000
🎹 KeyboardShortcuts library available: toggleMiniRecorder
       LoudnessManager.mm:413   PlatformUtilities::CopyHardwareModelFullName() returns unknown value: Mac16,7, defaulting hw platform key
Scheduling daily audio cleanup task
🔍 [SHORTCUT DEBUG] Library shortcut: nil
🔍 [SHORTCUT DEBUG] Custom shortcut: Right ⌘
🔍 [SHORTCUT DEBUG] Shortcut configured: true
🎹 Setting up custom shortcut monitor for: Right ⌘
✅ Keyboard shortcut configured: Right ⌘
🧪 Testing KeyboardShortcuts library...
🧪 Current shortcut from library: none
🧪 Current shortcut available: none
🧪 KeyboardShortcuts library test completed
🔧 [HOTKEY SETUP] Setting up shortcut handler at 2025-08-16 01:11:46 +0000
🧹 [HOTKEY SETUP] Cleared existing handlers
🔧 [HOTKEY SETUP] Attempting to activate KeyboardShortcuts system...
🔧 [HOTKEY SETUP] Forced library initialization
🔧 [HOTKEY SETUP] Library activation complete, ready for real handlers...
🧊 [WARMUP] Skipping (recently run) context=appActivation
🔍 [UPDATE_STATE] === updateSubscriptionState() called ===
🔍 [UPDATE_STATE] Current state before update - currentTier: pro, isInTrial: false
🔍 [UPDATE_STATE] 1. Polar canUseApp: false
🔍 [UPDATE_STATE] 1b. Polar shouldUsePolarTrial: true
🔍 [UPDATE_STATE] 2. Supabase session: nil
🚨 [DEBUG] Will use TIER 3: Local Trial System
🚨 [CRITICAL DEBUG] [TIER 1] Checking Polar license status...
🚨 [CRITICAL DEBUG] License State: trialExpired
🚨 [CRITICAL DEBUG] Can Use App: false
🚨 [CRITICAL DEBUG] Should Use Polar Trial: true
🚨 [CRITICAL DEBUG] POLAR TRIAL EXPIRED - CONTINUING TO TIER 2!
🚨 [CRITICAL DEBUG] About to check Tier 2 condition...
🚨 [CRITICAL DEBUG] supabaseService.currentSession: NIL
🚨 [CRITICAL DEBUG] supabaseService.currentUser: NIL
🔐 [ENTITLEMENT] Using cached paid entitlement until 2025-08-30 15:20:52 +0000
🔄 [SYNC_STATE] syncTrialState called - currentTier: pro, isInTrial: false
🔄 [SYNC_STATE] Final state after syncTrialState - currentTier: pro, isInTrial: false
✅ LocalizationManager: Successfully loaded bundle for language: en
Loaded saved device ID: 104
Using saved device: MacBook Pro Microphone
Cleanup run finished — removed: 0, failed: 0
🔥 [WARMUP] ensureReady() invoked context=appLaunch
🔥 [SYSTEM-WARMUP] TempKeyCache warmup integration
🚀 [PREFETCH] Starting background temp key prefetch
164615          HALC_ProxyIOContext.cpp:1622  HALC_ProxyIOContext::IOWorkLoop: skipping cycle due to overload
164615          HALC_ProxyIOContext.cpp:1630  HALC_ProxyIOContext::IOWorkLoop: context 2711 received an out of order message (got 41 want: 1)
🔄 [AUTH_REFRESH] Manually triggering authentication refresh...
🔄 [AUTH_REFRESH] No session to refresh
🔧 [HOTKEY SETUP] Setting up actual handlers...
✅ [HOTKEY SETUP] Real handlers configured
🚀 [HOTKEY SETUP] Complete setup finished - handlers active
🔍 [UPDATE_STATE] === updateSubscriptionState() called ===
🔍 [UPDATE_STATE] Current state before update - currentTier: pro, isInTrial: false
🔍 [UPDATE_STATE] 1. Polar canUseApp: false
🔍 [UPDATE_STATE] 1b. Polar shouldUsePolarTrial: true
🔍 [UPDATE_STATE] 2. Supabase session: nil
🚨 [DEBUG] Will use TIER 3: Local Trial System
🚨 [CRITICAL DEBUG] [TIER 1] Checking Polar license status...
🚨 [CRITICAL DEBUG] License State: trialExpired
🚨 [CRITICAL DEBUG] Can Use App: false
🚨 [CRITICAL DEBUG] Should Use Polar Trial: true
🚨 [CRITICAL DEBUG] POLAR TRIAL EXPIRED - CONTINUING TO TIER 2!
🚨 [CRITICAL DEBUG] About to check Tier 2 condition...
🚨 [CRITICAL DEBUG] supabaseService.currentSession: NIL
🚨 [CRITICAL DEBUG] supabaseService.currentUser: NIL
🔐 [ENTITLEMENT] Using cached paid entitlement until 2025-08-30 15:20:52 +0000
🔄 [SYNC_STATE] syncTrialState called - currentTier: pro, isInTrial: false
🔄 [SYNC_STATE] Final state after syncTrialState - currentTier: pro, isInTrial: false
nw_connection_copy_connected_local_endpoint_block_invoke [C4] Client called nw_connection_copy_connected_local_endpoint on unconnected nw_connection
nw_connection_copy_connected_remote_endpoint_block_invoke [C4] Client called nw_connection_copy_connected_remote_endpoint on unconnected nw_connection
nw_connection_copy_protocol_metadata_internal_block_invoke [C4] Client called nw_connection_copy_protocol_metadata_internal on unconnected nw_connection
Error: -checkForUpdatesInBackground called but .sessionInProgress == YES
🔍 [USER] Raw trial_ends_at from Supabase: '2025-07-29T13:36:32Z'
🔍 [USER] Parsed trial_ends_at: 2025-07-29 13:36:32 +0000
🔍 [USER] Parsed subscription_status: 'active' → active
🔍 [USER] Parsed subscription_plan: 'pro' → pro
✅ [AUTH] User authenticated: kentaro@resonantai.co.site
✅ [AUTH] User authenticated: kentaro@resonantai.co.site
🔍 [USER] Raw trial_ends_at from Supabase: '2025-07-29T13:36:32Z'
🔍 [USER] Parsed trial_ends_at: 2025-07-29 13:36:32 +0000
🔍 [USER] Parsed subscription_status: 'active' → active
🔍 [USER] Parsed subscription_plan: 'pro' → pro
✅ [AUTH] Restored session for: kentaro@resonantai.co.site
🔍 [UPDATE_STATE] === updateSubscriptionState() called ===
🔍 [UPDATE_STATE] Current state before update - currentTier: pro, isInTrial: false
🔍 [UPDATE_STATE] 1. Polar canUseApp: false
🔍 [UPDATE_STATE] 1b. Polar shouldUsePolarTrial: false
🔍 [UPDATE_STATE] 2. Supabase session: kentaro@resonantai.co.site
🚨 [DEBUG] Will use TIER 2: Supabase Subscription System
🚨 [DEBUG] Supabase user: kentaro@resonantai.co.site
🚨 [DEBUG] User subscription status: active
🚨 [DEBUG] User subscription plan: pro
🚨 [CRITICAL DEBUG] [TIER 1] Checking Polar license status...
🚨 [CRITICAL DEBUG] License State: trialExpired
🚨 [CRITICAL DEBUG] Can Use App: false
🚨 [CRITICAL DEBUG] Should Use Polar Trial: false
🚨 [CRITICAL DEBUG] SKIPPING POLAR TIER 1 - shouldUsePolarTrial is false
🚨 [CRITICAL DEBUG] This allows Supabase Pro subscription to be checked!
🚨 [CRITICAL DEBUG] About to check Tier 2 condition...
🚨 [CRITICAL DEBUG] supabaseService.currentSession: NOT NIL
🚨 [CRITICAL DEBUG] supabaseService.currentUser: NOT NIL
🚨 [CRITICAL] ENTERED TIER 2 LOGIC!
🔍 [SUBSCRIPTION] [TIER 2] Checking Supabase subscription...
🔍 [SUBSCRIPTION] User email: kentaro@resonantai.co.site
🔍 [SUBSCRIPTION] Raw subscription status: 'active'
🔍 [SUBSCRIPTION] Raw subscription plan: 'pro'
🔍 [SUBSCRIPTION] Status == .active: true
🔍 [SUBSCRIPTION] Plan != nil: true
🔍 [SUBSCRIPTION] Trial ends at: 2025-07-29 13:36:32 +0000
🔍 [SUBSCRIPTION] Subscription expires at: 2025-08-30 15:20:52 +0000
🚨 [DEBUG] Checking subscription condition:
🚨 [DEBUG] user.subscriptionStatus == .active: true
🚨 [DEBUG] user.subscriptionPlan != nil: true
🚨 [DEBUG] Combined condition: true
🚨 [CRITICAL] ABOUT TO CHECK THE MAIN SUBSCRIPTION CONDITION!
🚨 [CRITICAL DEBUG] Checking subscription condition:
🚨 [CRITICAL DEBUG] user.subscriptionStatus: active
🚨 [CRITICAL DEBUG] user.subscriptionStatus.rawValue: 'active'
🚨 [CRITICAL DEBUG] user.subscriptionStatus == .active: true
🚨 [CRITICAL DEBUG] user.subscriptionPlan: Optional(Clio.SubscriptionPlan.pro)
🚨 [CRITICAL DEBUG] user.subscriptionPlan != nil: true
🚨 [CRITICAL DEBUG] Combined condition result: true
✅ [SUBSCRIPTION] [TIER 2] Using Supabase Pro by expiry - pro tier until 2025-08-30 15:20:52 +0000
🔄 [SYNC_STATE] syncTrialState called - currentTier: pro, isInTrial: false
🔄 [SYNC_STATE] Final state after syncTrialState - currentTier: pro, isInTrial: false
🔍 [UPDATE_STATE] === updateSubscriptionState() called ===
🔍 [UPDATE_STATE] Current state before update - currentTier: pro, isInTrial: false
🔍 [UPDATE_STATE] 1. Polar canUseApp: false
🔍 [UPDATE_STATE] 1b. Polar shouldUsePolarTrial: false
🔍 [UPDATE_STATE] 2. Supabase session: kentaro@resonantai.co.site
🚨 [DEBUG] Will use TIER 2: Supabase Subscription System
🚨 [DEBUG] Supabase user: kentaro@resonantai.co.site
🚨 [DEBUG] User subscription status: active
🚨 [DEBUG] User subscription plan: pro
🚨 [CRITICAL DEBUG] [TIER 1] Checking Polar license status...
🚨 [CRITICAL DEBUG] License State: trialExpired
🚨 [CRITICAL DEBUG] Can Use App: false
🚨 [CRITICAL DEBUG] Should Use Polar Trial: false
🚨 [CRITICAL DEBUG] SKIPPING POLAR TIER 1 - shouldUsePolarTrial is false
🚨 [CRITICAL DEBUG] This allows Supabase Pro subscription to be checked!
🚨 [CRITICAL DEBUG] About to check Tier 2 condition...
🚨 [CRITICAL DEBUG] supabaseService.currentSession: NOT NIL
🚨 [CRITICAL DEBUG] supabaseService.currentUser: NOT NIL
🚨 [CRITICAL] ENTERED TIER 2 LOGIC!
🔍 [SUBSCRIPTION] [TIER 2] Checking Supabase subscription...
🔍 [SUBSCRIPTION] User email: kentaro@resonantai.co.site
🔍 [SUBSCRIPTION] Raw subscription status: 'active'
🔍 [SUBSCRIPTION] Raw subscription plan: 'pro'
🔍 [SUBSCRIPTION] Status == .active: true
🔍 [SUBSCRIPTION] Plan != nil: true
🔍 [SUBSCRIPTION] Trial ends at: 2025-07-29 13:36:32 +0000
🔍 [SUBSCRIPTION] Subscription expires at: 2025-08-30 15:20:52 +0000
🚨 [DEBUG] Checking subscription condition:
🚨 [DEBUG] user.subscriptionStatus == .active: true
🚨 [DEBUG] user.subscriptionPlan != nil: true
🚨 [DEBUG] Combined condition: true
🚨 [CRITICAL] ABOUT TO CHECK THE MAIN SUBSCRIPTION CONDITION!
🚨 [CRITICAL DEBUG] Checking subscription condition:
🚨 [CRITICAL DEBUG] user.subscriptionStatus: active
🚨 [CRITICAL DEBUG] user.subscriptionStatus.rawValue: 'active'
🚨 [CRITICAL DEBUG] user.subscriptionStatus == .active: true
🚨 [CRITICAL DEBUG] user.subscriptionPlan: Optional(Clio.SubscriptionPlan.pro)
🚨 [CRITICAL DEBUG] user.subscriptionPlan != nil: true
🚨 [CRITICAL DEBUG] Combined condition result: true
✅ [SUBSCRIPTION] [TIER 2] Using Supabase Pro by expiry - pro tier until 2025-08-30 15:20:52 +0000
🔄 [SYNC_STATE] syncTrialState called - currentTier: pro, isInTrial: false
🔄 [SYNC_STATE] Final state after syncTrialState - currentTier: pro, isInTrial: false
164615          HALC_ProxyIOContext.cpp:1622  HALC_ProxyIOContext::IOWorkLoop: skipping cycle due to overload
164615          HALC_ProxyIOContext.cpp:1630  HALC_ProxyIOContext::IOWorkLoop: context 2711 received an out of order message (got 220 want: 1)
🎹 Custom modifier shortcut triggered: Right ⌘
🎤 [UI] handleToggleMiniRecorder called
🎤 [UI] toggleNotchRecorder called isRecording=false
🔊 [SoundManager] Attempting to play start sound @ 1755306709.622
🔊 [SoundManager] NSSound start sound result: true
⏱️ [TIMING] start_sound_played @ 1755306709.636
📱 Showing DynamicNotch recorder (MIT licensed)
🔍 [DYNAMIC NOTCH DEBUG] Showing notch...
🧊 [WARMUP] Skipping (recently run) context=recorderUIShown
🔍 [DYNAMIC NOTCH DEBUG] Using screen under mouse (preserving mouse-following)
🔍 [DYNAMIC NOTCH SIZE] Using built-in screen notch size: (185.0, 32.0)
🔍 [CACHE-MISS] Fetching fresh temp key...
Unable to open mach-O at path: /AppleInternal/Library/BuildRoots/4~B5FIugA1pgyNPFl0-ZGG8fewoBL0-6a_xWhpzsk/Library/Caches/com.apple.xbs/Binaries/RenderBox/install/TempContent/Root/System/Library/PrivateFrameworks/RenderBox.framework/Versions/A/Resources/default.metallib  Error:2
nw_connection_copy_connected_local_endpoint_block_invoke [C8] Client called nw_connection_copy_connected_local_endpoint on unconnected nw_connection
nw_connection_copy_connected_remote_endpoint_block_invoke [C8] Client called nw_connection_copy_connected_remote_endpoint on unconnected nw_connection
nw_connection_copy_protocol_metadata_internal_block_invoke [C8] Client called nw_connection_copy_protocol_metadata_internal on unconnected nw_connection
🎙️ [TOGGLERECORD DEBUG] ===============================================
🎙️ [TOGGLERECORD DEBUG] Starting recording attempt
🎙️ [TOGGLERECORD DEBUG] Current model: soniox-realtime-streaming
🎙️ [TOGGLERECORD DEBUG] canTranscribe: true
🎤 [toggleRecord] Starting recording, current model: soniox-realtime-streaming
🎙️ [TOGGLERECORD DEBUG] Checking subscription limits...
🎙️ [TOGGLERECORD DEBUG] ✅ Subscription check passed
🎙️ [TOGGLERECORD DEBUG] Checking model access permissions...
🎙️ [TOGGLERECORD DEBUG] ✅ Model access check passed
🎙️ [TOGGLERECORD DEBUG] ✅ All checks passed - starting recording sequence
🧊 [WARMUP] Skipping (recently run) context=hotkeyDown
🎙️ Starting recording sequence...
🎙️ [TOGGLERECORD DEBUG] Starting recording session tracking...
📝 [GRACE] Recording session started with 2552 words remaining
🎙️ [TOGGLERECORD DEBUG] ===============================================
🔧 [NER-SETUP] Setting up callback - contextService exists: true
✅ [NER-SETUP] OCR completion callback configured for NER pre-warming - callback exists: true
🎙️ [RECORD PERMISSION DEBUG] Permission granted: true
🎙️ [RECORD PERMISSION DEBUG] Thread: <_NSMainThread: 0x6000028e0080>{number = 1, name = main}
🎙️ [RECORD PERMISSION DEBUG] Time since app launch: 0.00s
🔄 [AUTH_REFRESH] Session still valid for 29 minutes
🎙️ [ASYNC TASK DEBUG] Starting async recording task...
🎙️ [ASYNC TASK DEBUG] Task thread: <_NSMainThread: 0x6000028e0080>{number = 1, name = main}
🎙️ [ASYNC TASK DEBUG] Re-evaluating model for language settings...
🎙️ [ASYNC TASK DEBUG] Model type: soniox-realtime-streaming, isStreaming: true
🎙️ [SONIOX DEBUG] Starting Soniox streaming transcription...
🎙️ [SONIOX DEBUG] Calling wakeAudioSystemIfNeeded()...
🔊 Waking up audio system after 683s idle time
✅ Successfully updated user stats in Supabase
🔄 Stats synced successfully (FORCED)
📊 196160 words, 1491.2 minutes
✅ Successfully updated user stats in Supabase
🔄 Stats synced successfully (FORCED)
📊 196160 words, 1491.2 minutes
🎬 [CAPTURE DEBUG] Starting smart screen context capture
🔍 [CALLBACK DEBUG] onOCRCompleted callback exists: true
🔍 [CACHE] No cache available
🎬 Starting screen capture with verified permissions
🎯 ScreenCapture detected frontmost app: Xcode (com.apple.dt.Xcode)
🎯 Found matching window: Clio — SonioxStreamingService.swift (Xcode) - layer:0, pid:623
🎯 ScreenCapture found window: Clio — SonioxStreamingService.swift (Xcode) - matches Context Preset detection
🎯 Found window: Clio — SonioxStreamingService.swift (Xcode)
🎯 ScreenCapture detected frontmost app: Xcode (com.apple.dt.Xcode)
🎯 Found matching window: Clio — SonioxStreamingService.swift (Xcode) - layer:0, pid:623
🎯 ScreenCapture found window: Clio — SonioxStreamingService.swift (Xcode) - matches Context Preset detection
🖼️ Attempting window-specific capture for: Clio — SonioxStreamingService.swift (ID: 268)
✅ Successfully captured window: 3456.000000x2038.000000
🌐 [LANG DEBUG] Multi-language setting exists: true, Single language: en
🌐 [LANG DEBUG] Using multi-language selection (prioritized): zh, en
🌐 [OCR DEBUG] Selected languages from settings: zh, en
🌐 [OCR DEBUG] User selection mode - prioritizing non-English: zh-Hans, en-US
🌐 Using selected languages for OCR: zh-Hans, en-US
🎙️ [SONIOX DEBUG] Calling sonioxStreamingService.startStreaming()...
📊 [SESSION] Starting recording session #1
✅ Selected account account-bundle (connections: 1/10)
🚀 Starting Clio streaming transcription
🔊 Setting up audio engine...
throwing -10877
throwing -10877
🧹 [TAP CLEANUP] Removing any existing taps before installation
✅ [TAP CLEANUP] Successfully removed existing tap
🎧 [AUDIO INPUT] Using device id=104 name=MacBook Pro Microphone
🎤 Detected hardware format: 48000.000000Hz, 1 channels
🎯 [TAP INSTALL] Installing new audio tap with format: 48000.000000Hz
✅ [TAP INSTALL] Audio tap installed successfully
✅ Audio engine configured successfully
⏱️ [TIMING] Audio engine setup completed
⏱️ [TIMING] Audio capture started - buffering until WebSocket ready
Device list change detected
🔍 [DYNAMIC NOTCH DEBUG] Showed notch in compact mode
🏥 [AUDIO HEALTH] Health monitoring timer started
🎙️ [SONIOX DEBUG] Soniox streaming started successfully!
⏱️ [TIMING] mic_engaged @ 1755306710.205
🔄 Handling audio device change
✅ Device change handling completed
🆕 [COLD-START] First recording after app launch - applying background warm-up
pass
🔥 [COLD-START] Performing system warm-up with network stack pre-warming
🔥 [COLD-START] Pre-warming DNS resolution
✅ [AUDIO HEALTH] First audio data received - tap is functional
🌐 [ASR BREAKDOWN] Total: 700ms | Client↔Proxy: 353ms | Proxy↔Soniox: 346ms | Network: 340ms
💾 Cached temp key for languages: ["en", "zh"]
🗓️ [TTL-SCHEDULE] Scheduling temp key refresh for key=global in 3000s (expiresAt=2025-08-16 02:11:50 +0000)
🔑 [FRESH-KEY] Fetched and cached temp key in 713ms
⏱️ [TIMING] Temp key obtained in 712.7ms
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🔊 [SONIOX DEBUG] Full config: enable_endpoint_detection=true, model=stt-rt-preview-v2, language_hints=Optional(["en", "zh"])
🔁 [DEVICE] Device/default changed – refreshing capture path
⏸️ [CAPTURE RECOVERY] Skipping capture restart while connecting
🌐 [PATH] Network path changed (status=satisfied) – triggering recovery
⏹️ Keepalive timer stopped
⚠️ WebSocket connect failed (attempt 1). Retrying in 500ms…
⚡ [CACHE-HIT] Retrieved temp key in 0.0ms
⏱️ [TIMING] Temp key obtained in 0.2ms
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🔊 [SONIOX DEBUG] Full config: enable_endpoint_detection=true, model=stt-rt-preview-v2, language_hints=Optional(["zh", "en"])
🔍 Found 106 text observations
✅ Text extraction successful: 2195 chars, 2195 non-whitespace, 239 words from 106 observations
✅ Captured text successfully
✅ [CAPTURE DEBUG] Screen capture successful: 2281 characters
🎯 ScreenCapture detected frontmost app: Xcode (com.apple.dt.Xcode)
🎯 Found matching window: Clio — SonioxStreamingService.swift (Xcode) - layer:0, pid:623
🎯 ScreenCapture found window: Clio — SonioxStreamingService.swift (Xcode) - matches Context Preset detection
💾 [SMART-CACHE] Cached new context: com.apple.dt.Xcode|Clio — SonioxStreamingService.swift (2281 chars)
🎯 [CALLBACK DEBUG] Executing callback with fresh content (2281 chars)
🔥 [NER-TRIGGER] OCR completion callback triggered with fresh content
🔥 [NER-PREWARM] Triggering NER pre-warming with OCR text (2281 chars)
🔥 [PREWARM DEBUG] prewarmConnection() called - isEnhancementEnabled: true, isConfigured: true
🔥 [PREWARM DEBUG] connectionState: cold
🔥 [PREWARM DEBUG] Pre-warming AI connection for GROQ, environment: flyio
🛩️ [FLY.IO PREWARM] Starting Fly.io NER pre-warming (forced refresh)
🛩️ [FLY.IO-NER] sendFlyioWarmingRequest() called - starting NER processing
🎬 [NER-PREWARM] Using raw OCR text for NER: 2281 characters
🛩️ [FLY.IO-NER] OCR text retrieved for NER processing: 2281 characters
🧠 [NER-DEFAULT] Using default NER prompt for general extraction
🌐 [ASR BREAKDOWN] Total: 3919ms | Client↔Proxy: 2916ms | Proxy↔Soniox: 1003ms | Network: 1001ms
🗑️ Evicted oldest temp key to maintain cache size limit
💾 Cached temp key for languages: ["en", "zh"]
🗓️ [TTL-SCHEDULE] Scheduling temp key refresh for key=global in 3000s (expiresAt=2025-08-16 02:11:51 +0000)
✅ [PREFETCH] Successfully prefetched temp key
🔥 [COLD-START] Pre-warming connection pool
🔌 WebSocket did open
🔌 WebSocket ready after 1765ms - buffered 1.6s of audio
📦 Flushing 16 buffered packets (1.6s of audio, 51200 bytes)
📤 Sending audio packet seq=0 size=3200
🔑 Successfully connected to Soniox using temp key (0ms key latency)
📤 Sent buffered packet 0/16 seq=0 size=3200
⚡ [CACHE-HIT] Retrieved temp key in 0.1ms
⏱️ [TIMING] Temp key obtained in 0.5ms
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🔊 [SONIOX DEBUG] Full config: enable_endpoint_detection=true, model=stt-rt-preview-v2, language_hints=Optional(["en", "zh"])
🔥 [COLD-START] Warming up audio system
throwing -10877
throwing -10877
🔥 [COLD-START] Audio engine started for warm-up
🔥 [COLD-START] Audio engine warm-up completed
🔥 [COLD-START] Pre-warming authenticated connections with temp key caching
🔥 [COLD-START] JWT token pre-fetched
🔥 [SYSTEM-WARMUP] TempKeyCache warmup integration
🚀 [PREFETCH] Starting background temp key prefetch
🔌 WebSocket did open
🔌 WebSocket ready after 2968ms - buffered 1.2s of audio
📦 Flushing 12 buffered packets (1.2s of audio, 38400 bytes)
📤 Sent buffered packet 0/12 seq=15 size=3200
📤 Sent buffered packet 11/12 seq=26 size=3200
✅ Buffer flush complete
⏹️ Keepalive timer stopped
🔄 Keepalive timer started (interval: 15.000000s)
⏱️ [TIMING] WebSocket connection established - flushing buffered audio
🔑 Successfully connected to Soniox using temp key (0ms key latency)
📤 Sent buffered packet 15/16 seq=27 size=3200
✅ Buffer flush complete
⏹️ Keepalive timer stopped
🔄 Keepalive timer started (interval: 15.000000s)
❌ Clio API Error: 400 - Start request must be a text message.
nw_read_request_report [C15] Receive failed with error "Socket is not connected"
nw_flow_service_reads [C15 129.146.176.251:443 failed parent-flow (satisfied (Path is satisfied), interface: utun4, ipv4, dns, uses wifi)] No output handler
Connection 15: received failure notification
⚠️ WebSocket did close with code 1000
nw_flow_add_write_request [C15 129.146.176.251:443 failed parent-flow (satisfied (Path is satisfied), interface: utun4, ipv4, dns, uses wifi)] cannot accept write requests
nw_write_request_report [C15] Send failed with error "Socket is not connected"
❌ WebSocket receive error: The operation couldn’t be completed. Socket is not connected
🔄 Connection reset during recording - attempting recovery
🔄 [RECOVERY] Attempting mid-recording recovery
❌ WebSocket receive error: The operation couldn’t be completed. Socket is not connected
🔄 Connection reset during recording - attempting recovery
🔄 [RECOVERY] Attempting mid-recording recovery
🔄 [RECOVERY] Attempting mid-recording recovery
⏹️ Keepalive timer stopped
⏹️ Keepalive timer stopped
⏹️ Keepalive timer stopped
⚡ [CACHE-HIT] Retrieved temp key in 0.2ms
⏱️ [TIMING] Temp key obtained in 0.6ms
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🔊 [SONIOX DEBUG] Full config: enable_endpoint_detection=true, model=stt-rt-preview-v2, language_hints=Optional(["en", "zh"])
🔌 WebSocket did open
🔌 WebSocket ready after 4649ms - buffered 1.4s of audio
📦 Flushing 14 buffered packets (1.4s of audio, 44800 bytes)
📤 Sending audio packet seq=0 size=3200
🔑 Successfully connected to Soniox using temp key (1ms key latency)
📤 Sent buffered packet 0/14 seq=31 size=3200
📤 Sent buffered packet 13/14 seq=44 size=3200
✅ Buffer flush complete
⏹️ Keepalive timer stopped
🔄 Keepalive timer started (interval: 15.000000s)
📱 Dismissing recorder
🛑 Stopping Clio streaming transcription
🏥 [AUDIO HEALTH] Health monitoring timer stopped
✅ [TAP CLEANUP] Successfully removed tap during stop
⏹️ Keepalive timer stopped
📉 Released connection for account account-bundle (connections: 0)
💾 [COLD-START] Updated successful streaming timestamp
✅ Streaming stopped. Final transcript (0 chars, 5.0s, without audio file): ""
🔍 [DYNAMIC NOTCH DEBUG] Hiding notch...
🔊 [SoundManager] Attempting to play esc sound (with fade)
📥 [NER-STORE] Stored NER entities: 300 chars - Here are the extracted entities:

* **Organizations**: 
	+ Soniox
	+ Apple
* **Product Names**: 
	+ ...
🛩️ [FLY.IO-NER] Pre-warming completed in 4340ms - NER entities extracted: Here are the extracted entities:

* **Organizations**: 
	+ Soniox
	+ Apple
* **Product Names**: 
	+ ...
✅ [FLY.IO] NER refresh completed successfully
🔍 [DYNAMIC NOTCH DEBUG] Hidden notch
⚠️ [PREFETCH] Failed to prefetch temp key: Failed to fetch temp key: HTTP 502
🔥 [COLD-START] Temp key cache warmed up
🔥 [COLD-START] Reinitializing URLSession with optimized timeouts
🔥 [COLD-START] URLSession configured with extended timeouts
✅ [COLD-START] Warm-up complete with network stack optimization
⏹️ Keepalive timer stopped
⚠️ WebSocket did close with code 1001
tcp_output [C16.1.1:3] flags=[R.] seq=303693155, ack=840450730, win=2048 state=CLOSED rcv_nxt=840450730, snd_una=303693101