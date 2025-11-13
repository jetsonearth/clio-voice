I think for this transcription, before I finish the transcription and AI enhancement, it shuts off the dynamic notch recorder. For some reason, it's like a premature collapse of the recorder. Most likely it's a UI change, so this is breaking. See if you can see the problem. 

client log:
📱 Showing DynamicNotch recorder (MIT licensed)
🔍 [DYNAMIC NOTCH DEBUG] Already visible, skipping show()
🛑 [GATE] Abort mis-touch hide: recording started or hands-free locked
🔍 [DYNAMIC NOTCH DEBUG] Showed notch in compact mode
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
🎙️ [RECORD PERMISSION DEBUG] Thread: <_NSMainThread: 0x600002db0200>{number = 1, name = main}
🎙️ [RECORD PERMISSION DEBUG] Time since app launch: 0.00s
🔄 [AUTH_REFRESH] Session still valid for 43 minutes
🎙️ [ASYNC TASK DEBUG] Starting async recording task...
🎙️ [ASYNC TASK DEBUG] Task thread: <_NSMainThread: 0x600002db0200>{number = 1, name = main}
🎙️ [ASYNC TASK DEBUG] Re-evaluating model for language settings...
🎙️ [ASYNC TASK DEBUG] Model type: soniox-realtime-streaming, isStreaming: true
🎙️ [SONIOX DEBUG] Starting Soniox streaming transcription...
🎙️ [SONIOX DEBUG] Calling wakeAudioSystemIfNeeded()...
🎙️ [SONIOX DEBUG] Calling sonioxStreamingService.startStreaming()...
📊 [SESSION] Starting recording session #10
✅ Selected account account-bundle (connections: 1/10)
🎬 [CAPTURE DEBUG] Starting smart screen context capture
🔍 [CALLBACK DEBUG] onOCRCompleted callback exists: true
🎯 ScreenCapture detected frontmost app: Cursor (com.todesktop.230313mzl4w4u92)
🎯 Found matching window: 2025-08-17-possible-omission-of-final-sentence.md — clio-project (Workspace) (Cursor) - layer:0, pid:652
🎯 ScreenCapture found window: 2025-08-17-possible-omission-of-final-sentence.md — clio-project (Workspace) (Cursor) - matches Context Preset detection
🔄 [CACHE] Context changed - invalidating cache
🔄 [CACHE]   Old: com.apple.Terminal|Clio — ioreg ◂ claude GIT_PS1_SHOWDIRTYSTATE=1 — 80×24
🔄 [CACHE]   New: com.todesktop.230313mzl4w4u92|2025-08-17-possible-omission-of-final-sentence.md — clio-project (Workspace)
🔄 [CACHE]   BundleID Match: false
🔄 [CACHE]   Title Match: false
🔄 [CACHE]   Content Hash: Old=91b65455... New=91b65455...
🎬 Starting screen capture with verified permissions
🚀 Starting Clio streaming transcription
🎯 ScreenCapture detected frontmost app: Cursor (com.todesktop.230313mzl4w4u92)
🔊 Setting up audio engine...
🎯 Found matching window: 2025-08-17-possible-omission-of-final-sentence.md — clio-project (Workspace) (Cursor) - layer:0, pid:652
🎯 ScreenCapture found window: 2025-08-17-possible-omission-of-final-sentence.md — clio-project (Workspace) (Cursor) - matches Context Preset detection
🎯 Found window: 2025-08-17-possible-omission-of-final-sentence.md — clio-project (Workspace) (Cursor)
🎯 ScreenCapture detected frontmost app: Cursor (com.todesktop.230313mzl4w4u92)
🎯 Found matching window: 2025-08-17-possible-omission-of-final-sentence.md — clio-project (Workspace) (Cursor) - layer:0, pid:652
🎯 ScreenCapture found window: 2025-08-17-possible-omission-of-final-sentence.md — clio-project (Workspace) (Cursor) - matches Context Preset detection
🖼️ Attempting window-specific capture for: 2025-08-17-possible-omission-of-final-sentence.md — clio-project (Workspace) (ID: 113)
✅ Successfully captured window: 1920.000000x1055.000000
🌐 [LANG DEBUG] Multi-language setting exists: true, Single language: en
🌐 [LANG DEBUG] Using multi-language selection (prioritized): zh, en
🌐 [OCR DEBUG] Selected languages from settings: en, zh
🌐 [OCR DEBUG] User selection mode - prioritizing non-English: zh-Hans, en-US
🌐 Using selected languages for OCR: zh-Hans, en-US
throwing -10877
throwing -10877
🧹 [TAP CLEANUP] Removing any existing taps before installation
✅ [TAP CLEANUP] Successfully removed existing tap
🎧 [AUDIO INPUT] Using device id=146 name=MacBook Pro Microphone
🎤 Detected hardware format: 48000.000000Hz, 1 channels
🎯 [TAP INSTALL] Installing new audio tap with format: 48000.000000Hz
✅ [TAP INSTALL] Audio tap installed successfully
✅ Audio engine configured successfully
⏱️ [TIMING] Audio engine setup completed
⏱️ [TIMING] Audio capture started - buffering until WebSocket ready
🏥 [AUDIO HEALTH] Health monitoring timer started
🎙️ [SONIOX DEBUG] Soniox streaming started successfully!
⏱️ [TIMING] mic_engaged @ 1755414060.922
⏱️ [TIMING] WebSocket connect task completed — will flush after READY
pass
✅ [AUDIO HEALTH] First audio data received - tap is functional
nw_flow_add_write_request [C33 129.146.176.251:443 failed parent-flow (satisfied (Path is satisfied), interface: utun4, ipv4, dns, uses wifi)] cannot accept write requests
nw_write_request_report [C33] Send failed with error "Socket is not connected"
nw_flow_add_write_request [C33 129.146.176.251:443 failed parent-flow (satisfied (Path is satisfied), interface: utun4, ipv4, dns, uses wifi)] cannot accept write requests
nw_write_request_report [C33] Send failed with error "Socket is not connected"
Task <2FE81A4C-C9B5-42FD-A7AF-BE7255F5257A>.<8> finished with error [57] Error Domain=NSPOSIXErrorDomain Code=57 "Socket is not connected" UserInfo={NSDescription=Socket is not connected, _NSURLErrorRelatedURLSessionTaskErrorKey=(
    "LocalWebSocketTask <2FE81A4C-C9B5-42FD-A7AF-BE7255F5257A>.<8>"
), _NSURLErrorFailingURLSessionTaskErrorKey=LocalWebSocketTask <2FE81A4C-C9B5-42FD-A7AF-BE7255F5257A>.<8>}
❌ Failed to send frame seq=2282: The operation couldn’t be completed. Socket is not connected
🚑 Re-queueing failed packet seq=2282 requeue=true queue_len=1
❌ Send path reported failure: The operation couldn’t be completed. Socket is not connected
🚑 [RECOVERY] Recovering from send failure: The operation couldn’t be completed. Socket is not connected
⏹️ Keepalive timer stopped
🔌 [WS] Disconnected (socketId=sock_-307567423835364114@attempt_9)
🌐 [CONNECT] New single-flight request from sendFailure
🌐 [CONNECT] Attempt #10 (loop 1/3) starting…
⚡ [CACHE-HIT] Retrieved temp key in 0.1ms
⏱️ [TIMING] Temp key obtained in 0.1ms
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🔊 [SONIOX DEBUG] Full config: enable_endpoint_detection=true, model=stt-rt-preview-v2, language_hints=Optional(["zh", "en"])
🌐 [WS CONNECT] Using URL: wss://stt-rt.soniox.com/transcribe-websocket
🔗 [WS] Bound socket id=sock_8018202227708215026@attempt_10
🔑 Successfully connected to Soniox using temp key (0ms key latency)
🌐 [ASR BREAKDOWN] Total: 1051ms | Client↔Proxy: 80ms | Proxy↔Soniox: 971ms | Network: 971ms
🗑️ Evicted oldest temp key to maintain cache size limit
💾 Cached temp key for languages: ["en", "zh"]
🗓️ [TTL-SCHEDULE] Scheduling temp key refresh for key=global in 3000s (expiresAt=2025-08-17 08:01:01 +0000)
✅ [PREFETCH] Successfully prefetched temp key
🌐 [PATH] Network path changed (status=satisfied) – triggering recovery
🌐 [PATH] Change detected but isConnecting=true — skipping recovery
🔍 Found 115 text observations
✅ Text extraction successful: 3825 chars, 3825 non-whitespace, 453 words from 115 observations
✅ Captured text successfully
✅ [CAPTURE DEBUG] Screen capture successful: 3953 characters
🎯 ScreenCapture detected frontmost app: Cursor (com.todesktop.230313mzl4w4u92)
🎯 Found matching window: 2025-08-17-possible-omission-of-final-sentence.md — clio-project (Workspace) (Cursor) - layer:0, pid:652
🎯 ScreenCapture found window: 2025-08-17-possible-omission-of-final-sentence.md — clio-project (Workspace) (Cursor) - matches Context Preset detection
💾 [SMART-CACHE] Cached new context: com.todesktop.230313mzl4w4u92|2025-08-17-possible-omission-of-final-sentence.md — clio-project (Workspace) (3953 chars)
🎯 [CALLBACK DEBUG] Executing callback with fresh content (3953 chars)
🔥 [NER-TRIGGER] OCR completion callback triggered with fresh content
🔥 [NER-PREWARM] Triggering NER pre-warming with OCR text (3953 chars)
🔥 [PREWARM DEBUG] prewarmConnection() called - isEnhancementEnabled: true, isConfigured: true
🔥 [PREWARM DEBUG] connectionState: cold
🔥 [PREWARM DEBUG] Pre-warming AI connection (target: Gemini), environment: flyio
🛩️ [FLY.IO PREWARM] Starting Fly.io NER pre-warming (forced refresh)
🛩️ [FLY.IO-NER] sendFlyioWarmingRequest() called - starting NER processing (Gemini warmup)
🎬 [NER-PREWARM] Using raw OCR text for NER: 3953 characters
🛩️ [FLY.IO-NER] OCR text retrieved for NER processing: 3953 characters
🧠 [NER-DEFAULT] Using default NER prompt for general extraction
🔌 WebSocket did open (sid=sock_8018202227708215026, attemptId=10)
🌐 [CONNECT] Attempt #10 succeeded
📤 [START] Sent start/config text frame (attemptId=10, socketId=sock_8018202227708215026@attempt_10, start_text_sent=true)
🔌 [READY] attemptId=10 socketId=sock_8018202227708215026@attempt_10 start_text_sent=true
🔌 WebSocket ready after 1864ms - buffered 1.6s of audio
📦 Flushing 16 buffered packets (1.6s of audio, 51200 bytes)
📤 Sent buffered packet 0/16 seq=1 size=3200
📤 Sending text frame seq=2283
📤 Sent buffered packet 15/16 seq=16 size=3200
✅ Buffer flush complete
⏹️ Keepalive timer stopped
🔄 Keepalive timer started (interval: 15.000000s)
👂 [LISTENER] Starting listener task for socketId=sock_8018202227708215026@attempt_10 attemptId=10
📤 Sending audio packet seq=2300 size=3200
🤖 [FLY.IO-NER] Server-reported provider: gemini
📥 [NER-STORE] Stored NER entities: 133 chars - **People**
* ZhaobangJetwu

**Organizations**
* clio-project
* Clio
* NSA

**Products**
* Cursor
* g...
🛩️ [FLY.IO-NER] Pre-warming completed in 910ms - NER entities extracted
✅ [FLY.IO] NER refresh completed successfully
🎹 Custom modifier DOWN → dictationKeyDown: Right ⌘
🔒 [GATE] Hands-free active; keyDown → stop
🎹 Custom modifier UP   → dictationKeyUp: Right ⌘
🔍 [DYNAMIC NOTCH DEBUG] Hiding notch...
👆 [GATE] Mis-touch: auto-hide with no finalize
🎤 [UI] handleToggleMiniRecorder called
🎤 [UI] toggleNotchRecorder called isRecording=true
🛑 Stopping recording
🛑 Stopping Clio streaming transcription
🏥 [AUDIO HEALTH] Health monitoring timer stopped
✅ [TAP CLEANUP] Successfully removed tap during stop
✅ [AUDIO HEALTH] First audio data received - tap is functional
✅ [DRAIN] Queue drained before finalize
🔍 [DYNAMIC NOTCH DEBUG] Hidden notch
📤 Sent end-of-stream signal
📤 Sent manual finalize command
🕐 Using finalization timeout: 2000ms (connection took 9290ms)
🏁 Received <fin> token - finalization complete
✅ Received <fin> token after 460ms
⏹️ Keepalive timer stopped
🧊 [WARMUP] Skipping warm-socket hold (rapid restart suppression)
📉 Released connection for account account-bundle (connections: 0)
💾 [COLD-START] Updated successful streaming timestamp
✅ Streaming stopped. Final transcript (109 chars, 9.8s, with audio file): "I think the lessons might be getting omitted by the transcription tool, so we should, uh, uh, look into this."
✅ Streaming transcription completed successfully, length: 109 characters
⏱️ [TIMING] Subscription tracking: 0.2ms
⏱️ [TIMING] ASR word tracking: 0.0ms
🧠 Performing intelligent end-context detection for streaming
⏱️ [CONTEXT DETAIL] Cache check: 0.0ms
⚡ [SMART-OPTIMIZATION] Using smart cached screen context (3953 chars) - skipping new capture
⏱️ [STREAMING CONTEXT TIMING] Screen capture + context detection: 0.0ms
🎯 Starting dynamic context-aware AI enhancement with tracking for text (109 characters)
⚡ [FAST-PATH] Using pre-warmed context - skipping redundant detection
⚡ [PREWARMED] Using pre-warmed NER context for Code Review enhancement
🌐 [LANG DEBUG] Multi-language setting exists: true, Single language: en
🌐 [LANG DEBUG] Using multi-language selection (prioritized): zh, en
🔍 [NER-DEBUG] getNERContextData called - nerEntities exists: true, connectionState: ready
✅ [NER-CONTEXT] Using NER entities from pre-warming (133 chars)
🔍 [NER-CONTENT] NER entities preview: **People**
* ZhaobangJetwu

**Organizations**
* clio-project
* Clio
* NSA

**Products**
* Cursor
* gemma

**Projects**
* clio-project...
💻 Sending to AI provider with pre-warmed code context
💻 [PREWARMED-SYSTEM] Code system prompt: 'You are an expert at enhancing the text provided within <TRANSCRIPT> tags according to the following guidelines for developers. The information in <CO...'
💻 [PREWARMED-USER] Code user prompt: '
<DICTIONARY_TERMS>
Groq, Clio
</DICTIONARY_TERMS>

<CONTEXT_INFORMATION>
NER Context Entities:
**People**
* ZhaobangJetwu

**Organizations**
* clio-p...'
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
    Input: “connection persistence test py"
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
**People**
* ZhaobangJetwu

**Organizations**
* clio-project
* Clio
* NSA

**Products**
* Cursor
* gemma

**Projects**
* clio-project
</CONTEXT_INFORMATION>

DICTIONARY USAGE:
Fix ASR errors using <DICTIONARY_TERMS>: phonetic matches, partial matches, common errors (e.g., "clod code" → "Claude Code")

CONTEXT USAGE:
<CONTEXT_INFORMATION> provides technical terms for accuracy. Prioritize context spellings over transcript. Clean transcript only - don't respond to it.

Process the following transcript:

<TRANSCRIPT>
I think the lessons might be getting omitted by the transcription tool, so we should, uh, uh, look into this.
</TRANSCRIPT>
🌐 [CUSTOM-PROMPT] Attempting Groq via proxy...
🔑 [DEBUG] Getting JWT token...
🔑 [DEBUG] JWT token obtained in 0ms
📝 [TIMING] Request preparation: 0.1ms
🌐 [DEBUG] Sending request to proxy...
🌐 [DEBUG] Proxy response received in 449ms
📊 [DEBUG] HTTP Status: 200
📋 [DEBUG] Response Headers: [AnyHashable("Content-Encoding"): br, AnyHashable("fly-request-id"): 01K2VDA1H79MNHH1KGR6SZ984H-sin, AnyHashable("Etag"): W/"5c1-FkE9oxlYmiGI66cONGDIYS8P4Ug", AnyHashable("Server"): Fly/ac563edfc (2025-08-15), AnyHashable("Via"): 2 fly.io, AnyHashable("access-control-allow-credentials"): true, AnyHashable("Content-Type"): application/json; charset=utf-8, AnyHashable("x-powered-by"): Express, AnyHashable("Vary"): Origin, AnyHashable("Date"): Sun, 17 Aug 2025 07:01:11 GMT]
✅ [DEBUG] Found enhancedText field
🌐 [LLM] Groq: 248ms | TTFT: 230ms
🌐   Client↔Proxy: 202ms
🔍 [CONNECTION HEALTH]
🌐 [LANG DEBUG] Multi-language setting exists: true, Single language: en
🌐 [LANG DEBUG] Using multi-language selection (prioritized): zh, en
✅ [CUSTOM-PROMPT] Groq via proxy succeeded
📊 [DETAILED STREAMING TIMING] Streaming: 795.6ms | Context: 0.0ms | LLM: 466.7ms | Tracked Overhead: 0.0ms | Unaccounted: 0.6ms | Total: 1262.9ms
🔍 [OVERHEAD BREAKDOWN] Prompt: 0.0ms | ASR Track: 0.0ms | Window Info: 0.0ms | Word Track: 0.0ms | Database: 0.0ms
🔊 [SoundManager] Attempting to play stop sound
🔊 [SoundManager] NSSound stop sound result: true
🔍 [PASTE DEBUG] AXIsProcessTrusted: true, shouldCancelRecording: false, text length: 98
🔍 [PASTE DEBUG] Calling CursorPaster.pasteAtCursor() after 0.05s delay
📱 Dismissing recorder
📊 [ENHANCEMENT] Tracking 17 words - currentTier: pro, trialWordsRemaining: 2552
🧹 Connection cleanup completed (session resources released)
📝 [GRACE] Recording session ended
🔍 [PASTE DEBUG] About to execute CursorPaster.pasteAtCursor()
🔍 [PASTE DEBUG] CursorPaster.pasteAtCursor() called with text length: 98
🔍 [PASTE DEBUG] AXIsProcessTrusted() returned true, proceeding
🔍 [PASTE DEBUG] UseDirectTextInsertion setting: false
🔍 [PASTE DEBUG] Direct insertion disabled, using clipboard paste
⌨️ Using CGEvent-based Command+V
🔍 [PASTE DEBUG] CursorPaster.pasteAtCursor() completed
✅ Streaming transcription processing completed
⏳ [POST-FIN] Ignoring late 408 timeout after finalize/shutdown
Connection 34: received failure notification



evidence 2:
📱 Showing DynamicNotch recorder (MIT licensed)
🔍 [DYNAMIC NOTCH DEBUG] Showing notch...
🧬 [DYNAMIC NOTCH DEBUG] uiGeneration advanced to 9
🔍 [DYNAMIC NOTCH DEBUG] Using screen under mouse (preserving mouse-following)
🔍 [DYNAMIC NOTCH SIZE] Using built-in screen notch size: (185.0, 32.0)
📱 [GATE] Full UI shown (heavy work deferred until promotion)
🔥 [WARMUP] ensureReady() invoked context=recorderUIShown
🔥 [SYSTEM-WARMUP] TempKeyCache warmup integration
🚀 [PREFETCH] Starting background temp key prefetch
📱 Showing DynamicNotch recorder (MIT licensed)
🔍 [DYNAMIC NOTCH DEBUG] Already visible, skipping show()
📱 [GATE] Full UI shown (heavy work deferred until promotion)
🎤 [UI] handleToggleMiniRecorder called
🔐 [GATE] Promoted to hands-free via double-tap within window
🎤 [UI] toggleNotchRecorder called isRecording=false
📱 Showing DynamicNotch recorder (MIT licensed)
🔍 [DYNAMIC NOTCH DEBUG] Already visible, skipping show()
⛔️ [GATE] Ignoring keyUp during promotion cooldown
🛑 [GATE] Abort mis-touch hide: recording started or hands-free locked
🔍 [DYNAMIC NOTCH DEBUG] Showed notch in compact mode
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
🎙️ [RECORD PERMISSION DEBUG] Thread: <_NSMainThread: 0x6000018f4080>{number = 1, name = main}
🎙️ [RECORD PERMISSION DEBUG] Time since app launch: 0.00s
🔄 [AUTH_REFRESH] Session still valid for 15 minutes
🎙️ [ASYNC TASK DEBUG] Starting async recording task...
🎙️ [ASYNC TASK DEBUG] Task thread: <_NSMainThread: 0x6000018f4080>{number = 1, name = main}
🎙️ [ASYNC TASK DEBUG] Re-evaluating model for language settings...
🎙️ [ASYNC TASK DEBUG] Model type: soniox-realtime-streaming, isStreaming: true
🎙️ [SONIOX DEBUG] Starting Soniox streaming transcription...
🎙️ [SONIOX DEBUG] Calling wakeAudioSystemIfNeeded()...
🎙️ [SONIOX DEBUG] Calling sonioxStreamingService.startStreaming()...
📊 [SESSION] Starting recording session #7
✅ Selected account account-bundle (connections: 1/10)
🎬 [CAPTURE DEBUG] Starting smart screen context capture
🔍 [CALLBACK DEBUG] onOCRCompleted callback exists: true
🎯 ScreenCapture detected frontmost app: Xcode (com.apple.dt.Xcode)
🎯 Found matching window: Clio — HotkeyManager.swift (Xcode) - layer:0, pid:623
🎯 ScreenCapture found window: Clio — HotkeyManager.swift (Xcode) - matches Context Preset detection
🔄 [CACHE] Context changed - invalidating cache
🔄 [CACHE]   Old: com.todesktop.230313mzl4w4u92|2025-08-17-ptt-losing-initial-audio.md — clio-project (Workspace) — Untracked
🔄 [CACHE]   New: com.apple.dt.Xcode|Clio — HotkeyManager.swift
🔄 [CACHE]   BundleID Match: false
🔄 [CACHE]   Title Match: false
🔄 [CACHE]   Content Hash: Old=aa3b0a0b... New=aa3b0a0b...
🚀 Starting Clio streaming transcription
🎬 Starting screen capture with verified permissions
🎯 ScreenCapture detected frontmost app: Xcode (com.apple.dt.Xcode)
🔊 Setting up audio engine...
🎯 Found matching window: Clio — HotkeyManager.swift (Xcode) - layer:0, pid:623
🎯 ScreenCapture found window: Clio — HotkeyManager.swift (Xcode) - matches Context Preset detection
🎯 Found window: Clio — HotkeyManager.swift (Xcode)
🎯 ScreenCapture detected frontmost app: Xcode (com.apple.dt.Xcode)
🎯 Found matching window: Clio — HotkeyManager.swift (Xcode) - layer:0, pid:623
🎯 ScreenCapture found window: Clio — HotkeyManager.swift (Xcode) - matches Context Preset detection
🖼️ Attempting window-specific capture for: Clio — HotkeyManager.swift (ID: 14557)
✅ Successfully captured window: 3456.000000x2038.000000
🌐 [LANG DEBUG] Multi-language setting exists: true, Single language: en
🌐 [LANG DEBUG] Using multi-language selection (prioritized): zh, en
🌐 [OCR DEBUG] Selected languages from settings: en, zh
🌐 [OCR DEBUG] User selection mode - prioritizing non-English: zh-Hans, en-US
🌐 Using selected languages for OCR: zh-Hans, en-US
throwing -10877
throwing -10877
🧹 [TAP CLEANUP] Removing any existing taps before installation
✅ [TAP CLEANUP] Successfully removed existing tap
🎧 [AUDIO INPUT] Using device id=146 name=MacBook Pro Microphone
🎤 Detected hardware format: 48000.000000Hz, 1 channels
🎯 [TAP INSTALL] Installing new audio tap with format: 48000.000000Hz
✅ [TAP INSTALL] Audio tap installed successfully
✅ Audio engine configured successfully
⏱️ [TIMING] Audio engine setup completed
⏱️ [TIMING] Audio capture started - buffering until WebSocket ready
🏥 [AUDIO HEALTH] Health monitoring timer started
🎙️ [SONIOX DEBUG] Soniox streaming started successfully!
⏱️ [TIMING] mic_engaged @ 1755415737.639
⏱️ [TIMING] WebSocket connect task completed — will flush after READY
pass
✅ [AUDIO HEALTH] First audio data received - tap is functional
❌ Clio API Error: 408 - Request timeout.
nw_read_request_report [C16] Receive failed with error "Socket is not connected"
nw_flow_service_reads [C16 129.146.176.251:443 failed parent-flow (satisfied (Path is satisfied), interface: utun4, ipv4, dns, uses wifi)] No output handler
Connection 16: received failure notification
⚠️ WebSocket did close with code 1000 (sid=sock_9189748557949886315, attemptId=6)
nw_flow_add_write_request [C16 129.146.176.251:443 failed parent-flow (satisfied (Path is satisfied), interface: utun4, ipv4, dns, uses wifi)] cannot accept write requests
nw_write_request_report [C16] Send failed with error "Socket is not connected"
🔄 [RECOVERY] Attempting mid-recording recovery
⏹️ Keepalive timer stopped
🔌 [WS] Disconnected (socketId=sock_9189748557949886315@attempt_6)
🌐 [ASR BREAKDOWN] Total: 1010ms | Client↔Proxy: 81ms | Proxy↔Soniox: 929ms | Network: 929ms
🗑️ Evicted oldest temp key to maintain cache size limit
💾 Cached temp key for languages: ["zh", "en"]
🗓️ [TTL-SCHEDULE] Scheduling temp key refresh for key=global in 3000s (expiresAt=2025-08-17 08:28:57 +0000)
✅ [PREFETCH] Successfully prefetched temp key
🌐 [CONNECT] New single-flight request from sendFailure
🌐 [CONNECT] Attempt #7 (loop 1/3) starting…
⚡ [CACHE-HIT] Retrieved temp key in 0.0ms
⏱️ [TIMING] Temp key obtained in 0.1ms
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🔊 [SONIOX DEBUG] Full config: enable_endpoint_detection=true, model=stt-rt-preview-v2, language_hints=Optional(["zh", "en"])
🌐 [WS CONNECT] Using URL: wss://stt-rt.soniox.com/transcribe-websocket
🔗 [WS] Bound socket id=sock_-5776876304279523681@attempt_7
🔑 Successfully connected to Soniox using temp key (0ms key latency)
🌐 [PATH] Network path changed (status=satisfied) – triggering recovery
🌐 [PATH] Change detected but isConnecting=true — skipping recovery
🔍 Found 124 text observations
✅ Text extraction successful: 2311 chars, 2311 non-whitespace, 301 words from 124 observations
✅ Captured text successfully
✅ [CAPTURE DEBUG] Screen capture successful: 2388 characters
🎯 ScreenCapture detected frontmost app: Xcode (com.apple.dt.Xcode)
🎯 Found matching window: Clio — HotkeyManager.swift (Xcode) - layer:0, pid:623
🎯 ScreenCapture found window: Clio — HotkeyManager.swift (Xcode) - matches Context Preset detection
💾 [SMART-CACHE] Cached new context: com.apple.dt.Xcode|Clio — HotkeyManager.swift (2388 chars)
🎯 [CALLBACK DEBUG] Executing callback with fresh content (2388 chars)
🔥 [NER-TRIGGER] OCR completion callback triggered with fresh content
🔥 [NER-PREWARM] Triggering NER pre-warming with OCR text (2388 chars)
🔥 [PREWARM DEBUG] prewarmConnection() called - isEnhancementEnabled: true, isConfigured: true
🔥 [PREWARM DEBUG] connectionState: cold
🔥 [PREWARM DEBUG] Pre-warming AI connection (target: Gemini), environment: flyio
🛩️ [FLY.IO PREWARM] Starting Fly.io NER pre-warming (forced refresh)
🛩️ [FLY.IO-NER] sendFlyioWarmingRequest() called - starting NER processing (Gemini warmup)
🎬 [NER-PREWARM] Using raw OCR text for NER: 2388 characters
🛩️ [FLY.IO-NER] OCR text retrieved for NER processing: 2388 characters
🧠 [NER-DEFAULT] Using default NER prompt for general extraction
🤖 [FLY.IO-NER] Server-reported provider: gemini
📥 [NER-STORE] Stored NER entities: 292 chars - - **Clio** (Organization/Product)
- **Xcode** (Application)
- **HotkeyManager** (Project/Class)
- **...
🛩️ [FLY.IO-NER] Pre-warming completed in 865ms - NER entities extracted
✅ [FLY.IO] NER refresh completed successfully
🔌 WebSocket did open (sid=sock_-5776876304279523681, attemptId=7)
📤 [START] Sent start/config text frame (attemptId=7, socketId=sock_-5776876304279523681@attempt_7, start_text_sent=true)
🔌 [READY] attemptId=7 socketId=sock_-5776876304279523681@attempt_7 start_text_sent=true
🔌 WebSocket ready after 2085ms - buffered 1.7s of audio
📦 Flushing 17 buffered packets (1.7s of audio, 54400 bytes)
🌐 [CONNECT] Attempt #7 succeeded
📤 Sent buffered packet 0/17 seq=1 size=3200
📤 Sending text frame seq=516
📤 Sent buffered packet 16/17 seq=17 size=3200
✅ Buffer flush complete
⏹️ Keepalive timer stopped
🔄 Keepalive timer started (interval: 15.000000s)
👂 [LISTENER] Starting listener task for socketId=sock_-5776876304279523681@attempt_7 attemptId=7
🔒 [GATE] Hands-free active; keyDown → stop
🎤 [UI] handleToggleMiniRecorder called
🔍 [DYNAMIC NOTCH DEBUG] Hiding notch...
👆 [GATE] Mis-touch: auto-hide with no finalize
🎤 [UI] toggleNotchRecorder called isRecording=true
🛑 Stopping recording
🛑 Stopping Clio streaming transcription
🏥 [AUDIO HEALTH] Health monitoring timer stopped
✅ [TAP CLEANUP] Successfully removed tap during stop
✅ [AUDIO HEALTH] First audio data received - tap is functional
📤 Sending audio packet seq=600 size=3200
✅ [DRAIN] Queue drained before finalize
📤 Sent end-of-stream signal
📤 Sent manual finalize command
🕐 Using finalization timeout: 2000ms (connection took 9075ms)
🔍 [DYNAMIC NOTCH DEBUG] Hidden notch
🏁 Received <fin> token - finalization complete
✅ Received <fin> token after 370ms
⏹️ Keepalive timer stopped
🧊 [WARMUP] Skipping warm-socket hold (rapid restart suppression)
📉 Released connection for account account-bundle (connections: 0)
💾 [COLD-START] Updated successful streaming timestamp
✅ Streaming stopped. Final transcript (66 chars, 9.4s, with audio file): "I feel like I'm still losing a bit of audio at the very beginning."
✅ Streaming transcription completed successfully, length: 66 characters
⏱️ [TIMING] Subscription tracking: 0.5ms
⏱️ [TIMING] ASR word tracking: 0.0ms
🧠 Performing intelligent end-context detection for streaming
⏱️ [CONTEXT DETAIL] Cache check: 0.0ms
⚡ [SMART-OPTIMIZATION] Using smart cached screen context (2388 chars) - skipping new capture
⏱️ [STREAMING CONTEXT TIMING] Screen capture + context detection: 0.1ms
🎯 Starting dynamic context-aware AI enhancement with tracking for text (66 characters)
⚡ [FAST-PATH] Using pre-warmed context - skipping redundant detection
⚡ [PREWARMED] Using pre-warmed NER context for Code Review enhancement
🌐 [LANG DEBUG] Multi-language setting exists: true, Single language: en
🌐 [LANG DEBUG] Using multi-language selection (prioritized): zh, en
🔍 [NER-DEBUG] getNERContextData called - nerEntities exists: true, connectionState: ready
✅ [NER-CONTEXT] Using NER entities from pre-warming (292 chars)
🔍 [NER-CONTENT] NER entities preview: - **Clio** (Organization/Product)
- **Xcode** (Application)
- **HotkeyManager** (Project/Class)
- **HIDKeyRemapper** (Class)
- **F5ToF16Remapper** (Class)
- **LaunchAgentInstaller** (Class)
- **Keyboa...
💻 Sending to AI provider with pre-warmed code context
💻 [PREWARMED-SYSTEM] Code system prompt: 'You are an expert at enhancing the text provided within <TRANSCRIPT> tags according to the following guidelines for developers. The information in <CO...'
💻 [PREWARMED-USER] Code user prompt: '
<DICTIONARY_TERMS>
Groq, Clio
</DICTIONARY_TERMS>

<CONTEXT_INFORMATION>
NER Context Entities:
- **Clio** (Organization/Product)
- **Xcode** (Applica...'
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
    Input: “connection persistence test py"
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
- **Clio** (Organization/Product)
- **Xcode** (Application)
- **HotkeyManager** (Project/Class)
- **HIDKeyRemapper** (Class)
- **F5ToF16Remapper** (Class)
- **LaunchAgentInstaller** (Class)
- **KeyboardShortcuts** (Library/Framework)
- **ContextService** (Class)
- **RecordingEngine+UI** (Class)
</CONTEXT_INFORMATION>

DICTIONARY USAGE:
Fix ASR errors using <DICTIONARY_TERMS>: phonetic matches, partial matches, common errors (e.g., "clod code" → "Claude Code")

CONTEXT USAGE:
<CONTEXT_INFORMATION> provides technical terms for accuracy. Prioritize context spellings over transcript. Clean transcript only - don't respond to it.

Process the following transcript:

<TRANSCRIPT>
I feel like I'm still losing a bit of audio at the very beginning.
</TRANSCRIPT>
🌐 [CUSTOM-PROMPT] Attempting Groq via proxy...
🔑 [DEBUG] Getting JWT token...
🔑 [DEBUG] JWT token obtained in 0ms
📝 [TIMING] Request preparation: 0.2ms
🌐 [DEBUG] Sending request to proxy...
🌐 [DEBUG] Proxy response received in 467ms
📊 [DEBUG] HTTP Status: 200
📋 [DEBUG] Response Headers: [AnyHashable("x-powered-by"): Express, AnyHashable("fly-request-id"): 01K2VEX6HKXHB7HTC5ZNR466G2-sin, AnyHashable("access-control-allow-credentials"): true, AnyHashable("Etag"): W/"59e-NGzOnlNZ53RGQsZmwmCZObev0sA", AnyHashable("Content-Encoding"): br, AnyHashable("Content-Type"): application/json; charset=utf-8, AnyHashable("Via"): 2 fly.io, AnyHashable("Server"): Fly/ac563edfc (2025-08-15), AnyHashable("Vary"): Origin, AnyHashable("Date"): Sun, 17 Aug 2025 07:29:07 GMT]
✅ [DEBUG] Found enhancedText field
🌐 [LLM] Groq: 212ms | TTFT: 202ms
🌐   Client↔Proxy: 256ms
🔍 [CONNECTION HEALTH]
🌐 [LANG DEBUG] Multi-language setting exists: true, Single language: en
🌐 [LANG DEBUG] Using multi-language selection (prioritized): zh, en
✅ [CUSTOM-PROMPT] Groq via proxy succeeded
📊 [DETAILED STREAMING TIMING] Streaming: 718.7ms | Context: 0.1ms | LLM: 479.6ms | Tracked Overhead: 0.0ms | Unaccounted: 1.2ms | Total: 1199.6ms
🔍 [OVERHEAD BREAKDOWN] Prompt: 0.0ms | ASR Track: 0.0ms | Window Info: 0.0ms | Word Track: 0.0ms | Database: 0.0ms
🔊 [SoundManager] Attempting to play stop sound
🔊 [SoundManager] NSSound stop sound result: true
🔍 [PASTE DEBUG] AXIsProcessTrusted: true, shouldCancelRecording: false, text length: 67
🔍 [PASTE DEBUG] Calling CursorPaster.pasteAtCursor() after 0.05s delay
📱 Dismissing recorder
📊 [ENHANCEMENT] Tracking 15 words - currentTier: pro, trialWordsRemaining: 2552
🧹 Connection cleanup completed (session resources released)
📝 [GRACE] Recording session ended
🔍 [PASTE DEBUG] About to execute CursorPaster.pasteAtCursor()
🔍 [PASTE DEBUG] CursorPaster.pasteAtCursor() called with text length: 67
🔍 [PASTE DEBUG] AXIsProcessTrusted() returned true, proceeding
🔍 [PASTE DEBUG] UseDirectTextInsertion setting: false
🔍 [PASTE DEBUG] Direct insertion disabled, using clipboard paste
⌨️ Using CGEvent-based Command+V
🔍 [PASTE DEBUG] CursorPaster.pasteAtCursor() completed
✅ Streaming transcription processing completed