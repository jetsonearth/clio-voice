Very huge issue - warm up socket is not listening and transcribing 

Problem description:

2 out of 6/7 transcripts, i see that the standby wss has been successfully created following the connection end of transcript_t, but then sometimes it gets promoted, but sometimes it doesn't. or maybe it did get promoted, but audio is not going in reliably and getting transcript out.

Previously, I don't do this pre-connect. Every time user press hotkey, it's a 2-3s sometimes more delay in getting the first bit of streaming transcript, due to cold connection and handshake latency. sometimes, connection can take up to 8s... and that's why i do this. i offload the latency as much as possible to idle time so UX can be greatly improved.

the way i combat this is by assuming users will continue using the wss service after each transcript, at least within a short amount of time, thereby we spin up a standby socket right after the previous transcript ends, and keep it alive for 60s (timer for 60s, and keep sending keep alive). 

then, whenever within that 60s user presses hotkey again, we promote this socket (we should have already sent START config already, that's how we are able to send keepalive
evidenced by these folks right here:
💤 [STANDBY] keepalive_tick
t=6287250 sess=G79 lvl=INFO cat=stream evt=standby_keepalive_tick
💤 [STANDBY] keepalive_tick
t=6297248 sess=G79 lvl=INFO cat=stream evt=standby_keepalive_tick

otherwise it's not possible to send kepe alive to a wss that has not received START config, you also cannot send START config twice, in that case i will get Clio API 400 error (i got this many many times) )

since soniox max lifetime for a wss is 60 minutes and i am only keeping the warm socket up for 60s, i don't understand this behavior is so unpredictable.

see client log below.

📱 Showing DynamicNotch recorder (MIT licensed)
🧊 [WARMUP] Skipping (recently run) context=recorderUIShown
🎤 [toggleRecord] Starting recording, current model: soniox-realtime-streaming
🧊 [WARMUP] Skipping (recently run) context=hotkeyDown
🎙️ Starting recording sequence...
📝 [GRACE] Recording session started with 2552 words remaining
🔧 [NER-SETUP] Setting up callback - contextService exists: true
✅ [NER-SETUP] OCR completion callback configured for NER pre-warming - callback exists: true
📊 [SESSION] Starting recording session #12
🧪 [A/B] warm_socket=yes
🧊➡️🔥 [STANDBY->ACTIVE] Consuming standby socket for new utterance
⏭️ [STANDBY->ACTIVE] START already sent on standby (eager) — skipping re-send
✅ [STANDBY->ACTIVE] Probe keepalive OK — proceeding to resume queue
⏹️ Keepalive timer stopped
🔄 Keepalive timer started (interval: 15.000000s)
🎤 Registering audio tap for Soniox
🎬 Starting screen capture with verified permissions
t=6015163 sess=G79 lvl=INFO cat=audio evt=record_start service=Soniox
🔍 Performing audio system pre-flight checks
🎯 Clio — SonioxStreamingService.swift
🌐 Using selected languages for OCR: zh-Hans, en-US
throwing -10877
throwing -10877
✅ Pre-flight checks passed
t=6015268 sess=G79 lvl=INFO cat=audio evt=tap_install backend=avcapture ok=true service=Soniox
t=6015268 sess=G79 lvl=INFO cat=audio evt=record_start reason=start_capture
t=6015268 sess=G79 lvl=INFO cat=audio evt=device_pin_start prev_name="MacBook Pro Microphone" prev_id=198 prev_uid_hash=-1464455807919438517 desired_id=198 desired_name="MacBook Pro Microphone" desired_uid_hash=-1464455807919438517
❄️ Cold start detected - performing full initialization
❄️ Performing cold start initialization
⏭️ Skipping engine cold start (backend=AVCapture)
t=6015312 sess=G79 lvl=INFO cat=audio evt=capture_backend_selected backend=avcapture
✅ Unified audio capture started
✅ Selected account account-bundle (connections: 1/10)
🧠 [TEN-VAD] Initialized (threshold=0.5, hop=256)
🚀 Starting Clio streaming transcription
🏥 [AUDIO HEALTH] Health monitoring timer started
⏱️ [TIMING] mic_engaged @ 1756217842.611
⏱️ [TIMING] WebSocket connect task completed — will flush after READY
pass
t=6015365 sess=G79 lvl=INFO cat=audio evt=avcapture_start ok=true
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
t=6015376 sess=G79 lvl=INFO cat=stream evt=first_audio_buffer_captured ms=62
✅ [AUDIO HEALTH] First audio data received - tap is functional
t=6015377 sess=G79 lvl=INFO cat=stream evt=first_audio_sent seq=0 ms=63
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
🔍 Found 70 text observations
✅ Text extraction successful: 1192 chars, 1192 non-whitespace, 130 words from 70 observations
✅ Captured text successfully
✅ [CAPTURE DEBUG] Screen capture successful: 1278 characters
💾 [SMART-CACHE] Cached new context: com.apple.dt.Xcode|Clio — SonioxStreamingService.swift (1278 chars)
🎯 [CALLBACK DEBUG] Executing callback with fresh content (1278 chars)
🔥 [PREWARM DEBUG] Pre-warming AI connection (target: Gemini), environment: flyio
🔥 [NER-TRIGGER] OCR completion callback triggered with fresh content
🌐 [PATH] Initial path baseline set — no action
🎬 [NER-PREWARM] Using raw OCR text for NER: 1278 characters
🧠 [NER-DEFAULT] Using default NER prompt for general extraction
throwing -10877
throwing -10877
🤖 [FLY.IO-NER] Server-reported provider: gemini
📥 [NER-STORE] Stored NER entities: 1888 chars - This is a screenshot of Xcode, the integrated development environment for Apple platforms. It shows ...
✅ [FLY.IO] NER refresh completed successfully
t=6018518 sess=G79 lvl=INFO cat=stream evt=first_partial ms=3204
t=6018518 sess=G79 lvl=INFO cat=stream evt=ttft_hotkey ms=3204
t=6018518 sess=G79 lvl=INFO cat=stream evt=ttft ms=57701
throwing -10877
throwing -10877
t=6025005 sess=G79 lvl=INFO cat=stream evt=first_final ms=9691
t=6025005 sess=G79 lvl=INFO cat=transcript evt=raw_final text="You know your business"
t=6026290 sess=G79 lvl=INFO cat=transcript evt=raw_final text=" better than anyone, right?"
throwing -10877
throwing -10877
t=6027630 sess=G79 lvl=INFO cat=transcript evt=raw_final text=" So why not build an app"
t=6028974 sess=G79 lvl=INFO cat=transcript evt=raw_final text=" to run it with basically"
🛑 Stopping recording
🛑 Stopping Clio streaming transcription
🏥 [AUDIO HEALTH] Health monitoring timer stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
🛑 Stopping unified audio capture
t=6029751 sess=G79 lvl=INFO cat=audio evt=record_stop
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key plugInPackage
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key CMIOType
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key numberOfDevices
t=6029759 sess=G79 lvl=INFO cat=audio evt=avcapture_stop
✅ Unified audio capture stopped
📤 Sent end-of-stream signal
📤 Sent manual finalize command
🕐 Using finalization timeout: 400ms (connection took 14566ms)
ℹ️ [OPTIMISTIC] Not skipping: end=false pending=0 ms_since_last=88 tail=100 silence_ok=false tokens_quiet_ok=true partial_empty=false uncond=false
💓 Sent keepalive (active)
t=6030177 sess=G79 lvl=INFO cat=transcript evt=raw_final text=" four? This finance app solves your business headaches.<end>"
🏁 Received <fin> token - finalization complete
✅ Received <fin> token after 398ms
⚡ Audio capture already stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
📉 Released connection for account account-bundle (connections: 0)
💾 [COLD-START] Updated successful streaming timestamp
💾 [COLD-START] Updated successful streaming timestamp
✅ Streaming stopped. Final transcript (153 chars, 15.0s, with audio file): "You know your business better than anyone, right? So why not build an app to run it with basically four? This finance app solves your business headaches."
t=6030281 sess=G79 lvl=INFO cat=transcript evt=final text="You know your business better than anyone, right? So why not build an app to run it with basically four? This finance app solves your business headaches."
t=6030281 sess=G79 lvl=INFO cat=transcript evt=session_end divider="────────── session end ──────────"
🌡️ [WARM] warm_socket=yes
⏹️ Keepalive timer stopped
⚠️ WebSocket did close with code 1001 (sid=sock_1296880848252463035, attemptId=15)
t=6030281 sess=G79 lvl=WARN cat=stream evt=state state=closed code=1001
🔌 [WS] Disconnected (socketId=sock_1296880848252463035@attempt_15)
✅ Streaming transcription completed successfully, length: 153 characters
⏱️ [TIMING] Subscription tracking: 0.9ms
⏱️ [TIMING] ASR word tracking: 0.0ms
🧠 Performing intelligent end-context detection for streaming
⏱️ [CONTEXT DETAIL] Cache check: 0.0ms
⚡ [SMART-OPTIMIZATION] Using smart cached screen context (1278 chars) - skipping new capture
⏱️ [STREAMING CONTEXT TIMING] Screen capture + context detection: 0.1ms
🎯 Starting dynamic context-aware AI enhancement with tracking for text (153 characters)
⚡ [FAST-PATH] Using pre-warmed context - skipping redundant detection
⚡ [PREWARMED] Using pre-warmed NER context fast-path
🎯 [RULE-ENGINE] Cache hit for com.apple.dt.Xcode|||Clio — SonioxStreamingService.swift
💻 [PREWARMED] Detected code context → using code system prompt
💻 [PREWARMED-SYSTEM] Code system prompt: 'You are an expert at enhancing the text provided within <TRANSCRIPT> tags according to the following guidelines for developers. The information in <CO...'
💻 [PREWARMED-USER] Code user prompt: '
<DICTIONARY_TERMS>
Claude Code, Groq, Clio
</DICTIONARY_TERMS>

<CONTEXT_INFORMATION>
NER Context Entities:
This is a screenshot of Xcode, the integr...'
🛰️ Sending to AI provider via proxy: GROQ
🌐 Sending custom-prompt request to LLM proxy (provider auto-selected by server)...
🔑 [DEBUG] Getting JWT token...
🔑 [DEBUG] JWT token obtained in 0ms
🎯 [CONFIG-DEBUG] Config 2: Routing to Groq endpoint (https://fly.cliovoice.com/api/llm/proxy) with model: qwen
📝 [TIMING] Request preparation: 0.3ms
🌐 [DEBUG] Sending request to proxy...
🌐 [CONNECT] New single-flight request from warmHold
🌐 [CONNECT] Attempt #16 (loop 1/2) starting…
t=6030406 sess=G79 lvl=INFO cat=stream evt=temp_key_fetch_start
⚡ [CACHE-HIT] Retrieved temp key in 0.1ms
t=6030406 sess=G79 lvl=INFO cat=stream evt=temp_key_fetch latency_ms=0 source=cached expires_in_s=-1
🌐 [WS CONNECT] Using URL: wss://stt-rt.soniox.com/transcribe-websocket
🔗 [WS] Bound socket id=sock_283069642706383108@attempt_16
t=6030407 sess=G79 lvl=INFO cat=stream evt=ws_bind target_host=stt-rt.soniox.com via_proxy=false target_ip=resolving... path=/transcribe-websocket socket=sock_283069642706383108@attempt_16 attempt=16
🔑 Successfully connected to Soniox using temp key (1ms key latency)
t=6030408 sess=G79 lvl=INFO cat=stream evt=ws_bind_resolved attempt=16 socket=sock_283069642706383108@attempt_16 target_host=stt-rt.soniox.com target_ip=129.146.176.251 via_proxy=false path=/transcribe-websocket
t=6031590 sess=G79 lvl=INFO cat=stream evt=ws_handshake_metrics proxy=false reused=false socket=sock_283069642706383108@attempt_16 tls_ms=917 total_ms=1182 attempt=16 protocol=http/1.1 connect_ms=922 dns_ms=0
🔌 WebSocket did open (sid=sock_283069642706383108, attemptId=16)
🌐 [CONNECT] Attempt #16 succeeded
📤 [START] Sent start/config on standby socket (eager mode)
t=6031640 sess=G79 lvl=INFO cat=stream evt=start_config ctx=standby_eager summary=["model": "stt-rt-preview-v2", "sr": 16000, "langs": 2, "json_hash": "74c88fa4ee9a34f7", "ctx_len": 36, "valid": true, "audio_format": "pcm_s16le", "ch": 1] attempt=16 socket=sock_283069642706383108@attempt_16
📤 Sending text frame seq=38463
🧊 [STANDBY] Connected standby socket — keepalive every 10.0s, TTL=60s
🔌 [READY] attemptId=16 socketId=sock_283069642706383108@attempt_16 start_text_sent=true
🧊 [STANDBY] WebSocket ready in 1234ms (handshake)
👂 [LISTENER] Standby listener task for socketId=sock_283069642706383108@attempt_16 attemptId=16
🌐 [DEBUG] Proxy response received in 1643ms
✅ [SSE] Parsed streaming response: 135 characters
🔍 [CONNECTION HEALTH]
✅ Custom-prompt enhancement via proxy succeeded
t=6031970 sess=G79 lvl=INFO cat=transcript evt=llm_final text="You know your business better than anyone. Why not build an app to run it with four? This finance app solves your business headaches."
📊 [DETAILED STREAMING TIMING] Streaming: 566.5ms | Context: 0.1ms | LLM: 1685.2ms | Tracked Overhead: 0.0ms | Unaccounted: 2.2ms | Total: 2254.1ms
🔊 [SoundManager] Attempting to play stop sound
🔊 [SoundManager] NSSound stop sound result: true
🧹 Connection cleanup completed (session resources released)
📝 [GRACE] Recording session ended
📱 Dismissing recorder
📊 [ENHANCEMENT] Tracking 24 words - currentTier: pro, trialWordsRemaining: 2552
✅ Streaming transcription processing completed
t=6032082 sess=G79 lvl=INFO cat=transcript evt=insert_attempt chars=134 text="You know your business better than anyone. Why not build an app to run it with four? This finance app solves your business headaches. " target=Xcode
🔍 [PASTE DEBUG] AXIsProcessTrusted() returned true, proceeding
🔍 [PASTE DEBUG] UseDirectTextInsertion setting: false
🔍 [PASTE DEBUG] Direct insertion disabled, using clipboard paste
⌨️ Using CGEvent-based Command+V
t=6032082 sess=G79 lvl=INFO cat=transcript evt=insert_result ok=true
📊 [POST-RELEASE E2E] 2366ms (finalize=510ms | llm=1685ms | paste=0ms) | warm_socket=no
💤 [STANDBY] keepalive_tick
t=6041642 sess=G79 lvl=INFO cat=stream evt=standby_keepalive_tick
📱 Showing DynamicNotch recorder (MIT licensed)
🔥 [WARMUP] ensureReady() invoked context=recorderUIShown
🔥 [SYSTEM-WARMUP] TempKeyCache warmup integration
🚀 [PREFETCH] Starting background temp key prefetch
🎤 [toggleRecord] Starting recording, current model: soniox-realtime-streaming
🧊 [WARMUP] Skipping (recently run) context=hotkeyDown
🎙️ Starting recording sequence...
📝 [GRACE] Recording session started with 2552 words remaining
🔧 [NER-SETUP] Setting up callback - contextService exists: true
✅ [NER-SETUP] OCR completion callback configured for NER pre-warming - callback exists: true
📊 [SESSION] Starting recording session #13
🧪 [A/B] warm_socket=yes
🧊➡️🔥 [STANDBY->ACTIVE] Consuming standby socket for new utterance
⏭️ [STANDBY->ACTIVE] START already sent on standby (eager) — skipping re-send
♻️ [SMART-CACHE] Using cached context: 1278 characters
🔥 [NER-CACHE] Triggering NER callback with cached content (1278 chars)
✅ [NER-CACHE] NER callback triggered with cached content
✅ [STANDBY->ACTIVE] Probe keepalive OK — proceeding to resume queue
⏹️ Keepalive timer stopped
🔄 Keepalive timer started (interval: 15.000000s)
🔥 [PREWARM DEBUG] Pre-warming AI connection (target: Gemini), environment: flyio
🎤 Registering audio tap for Soniox
t=6045204 sess=G79 lvl=INFO cat=audio evt=record_start service=Soniox
🔍 Performing audio system pre-flight checks
throwing -10877
throwing -10877
✅ Pre-flight checks passed
t=6045288 sess=G79 lvl=INFO cat=audio evt=tap_install backend=avcapture service=Soniox ok=true
t=6045288 sess=G79 lvl=INFO cat=audio evt=record_start reason=start_capture
t=6045288 sess=G79 lvl=INFO cat=audio evt=device_pin_start prev_id=198 desired_id=198 desired_uid_hash=-1464455807919438517 desired_name="MacBook Pro Microphone" prev_name="MacBook Pro Microphone" prev_uid_hash=-1464455807919438517
t=6045289 sess=G79 lvl=INFO cat=audio evt=capture_backend_selected backend=avcapture
✅ Unified audio capture started
✅ Selected account account-bundle (connections: 1/10)
🧠 [TEN-VAD] Initialized (threshold=0.5, hop=256)
🚀 Starting Clio streaming transcription
🎬 [NER-PREWARM] Using raw OCR text for NER: 1278 characters
🧠 [NER-DEFAULT] Using default NER prompt for general extraction
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
t=6045384 sess=G79 lvl=INFO cat=audio evt=avcapture_start ok=true
t=6045394 sess=G79 lvl=INFO cat=stream evt=first_audio_buffer_captured ms=9
✅ [AUDIO HEALTH] First audio data received - tap is functional
🏥 [AUDIO HEALTH] Health monitoring timer started
⏱️ [TIMING] mic_engaged @ 1756217872.691
t=6045395 sess=G79 lvl=INFO cat=stream evt=first_audio_sent ms=10 seq=1
⏱️ [TIMING] WebSocket connect task completed — will flush after READY
pass
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
🌐 [ASR BREAKDOWN] Total: 472ms | Client↔Proxy: 216ms | Proxy↔Soniox: 255ms | Network: 254ms
🗑️ Evicted oldest temp key to maintain cache size limit
💾 Cached temp key for languages: ["en", "zh"]
🗓️ [TTL-SCHEDULE] Scheduling temp key refresh for key=global in 3000s (expiresAt=2025-08-26 15:17:52 +0000)
✅ [PREFETCH] Successfully prefetched temp key
🎤 [WARMUP] Pre-warming audio system...
✅ [PREWARM] Device enumeration completed
✅ [PREWARM] Audio system pre-warming completed successfully
✅ [WARMUP] Audio system pre-warmed successfully
🗣️ [TEN-VAD] Speech start detected
🌐 [PATH] Initial path baseline set — no action
throwing -10877
throwing -10877
🤖 [FLY.IO-NER] Server-reported provider: gemini
📥 [NER-STORE] Stored NER entities: 2072 chars - This is a screenshot from Xcode, showing the `SonioxStreamingService.swift` file in the "Clio" appli...
✅ [FLY.IO] NER refresh completed successfully
t=6048081 sess=G79 lvl=INFO cat=stream evt=first_partial ms=2697
t=6048082 sess=G79 lvl=INFO cat=stream evt=ttft_hotkey ms=2697
t=6048082 sess=G79 lvl=INFO cat=stream evt=ttft ms=2548
t=6051023 sess=G79 lvl=INFO cat=stream evt=first_final ms=5639
t=6051023 sess=G79 lvl=INFO cat=transcript evt=raw_final text="Tracking in"
throwing -10877
throwing -10877
t=6052328 sess=G79 lvl=INFO cat=transcript evt=raw_final text="voices, managing client"
t=6053934 sess=G79 lvl=INFO cat=transcript evt=raw_final text="s, keeping payments in che"
t=6054961 sess=G79 lvl=INFO cat=transcript evt=raw_final text="ck, all in one"
t=6055823 sess=G79 lvl=INFO cat=transcript evt=raw_final text=" place. Good. Phase 24, and write your prompt. What your...<end>"
🛑 Stopping recording
🛑 Stopping Clio streaming transcription
🏥 [AUDIO HEALTH] Health monitoring timer stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
🛑 Stopping unified audio capture
t=6056504 sess=G79 lvl=INFO cat=audio evt=record_stop
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key plugInPackage
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key CMIOType
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key numberOfDevices
t=6056512 sess=G79 lvl=INFO cat=audio evt=avcapture_stop
✅ Unified audio capture stopped
🗣️ [TEN-VAD] Speech start detected
📤 Sent end-of-stream signal
📤 Sent manual finalize command
🕐 Using finalization timeout: 400ms (connection took 11260ms)
⏳ [OPTIMISTIC] Waiting remaining tail before skip (remaining=10ms, ms_since_last=90, tail=100)
⚡ [OPTIMISTIC] Skipping wait-for-<fin> path=end tail=100ms pending=0 ms_since_last=90
🔬 [OPTIMISTIC] tokens_after_skip=0 window_ms=500
⚡ Audio capture already stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
📉 Released connection for account account-bundle (connections: 0)
💾 [COLD-START] Updated successful streaming timestamp
💾 [COLD-START] Updated successful streaming timestamp
✅ Streaming stopped. Final transcript (135 chars, 11.3s, with audio file): "Tracking invoices, managing client s, keeping payments in che ck, all in one place. Good. Phase 24, and write your prompt. What your..."
t=6056657 sess=G79 lvl=INFO cat=transcript evt=final text="Tracking invoices, managing client s, keeping payments in che ck, all in one place. Good. Phase 24, and write your prompt. What your..."
t=6056657 sess=G79 lvl=INFO cat=transcript evt=session_end divider="────────── session end ──────────"
🌡️ [WARM] warm_socket=yes
⏹️ Keepalive timer stopped
🔌 [WS] Disconnected (socketId=sock_283069642706383108@attempt_16)
⚠️ WebSocket did close with code 1001 (sid=sock_283069642706383108, attemptId=16)
t=6056657 sess=G79 lvl=WARN cat=stream evt=state state=closed code=1001
✅ Streaming transcription completed successfully, length: 135 characters
⏱️ [TIMING] Subscription tracking: 0.4ms
⏱️ [TIMING] ASR word tracking: 0.0ms
🧠 Performing intelligent end-context detection for streaming
⏱️ [CONTEXT DETAIL] Cache check: 0.0ms
⚡ [SMART-OPTIMIZATION] Using smart cached screen context (1278 chars) - skipping new capture
⏱️ [STREAMING CONTEXT TIMING] Screen capture + context detection: 0.0ms
🎯 Starting dynamic context-aware AI enhancement with tracking for text (135 characters)
⚡ [FAST-PATH] Using pre-warmed context - skipping redundant detection
⚡ [PREWARMED] Using pre-warmed NER context fast-path
🎯 [RULE-ENGINE] Cache hit for com.apple.dt.Xcode|||Clio — SonioxStreamingService.swift
💻 [PREWARMED] Detected code context → using code system prompt
💻 [PREWARMED-SYSTEM] Code system prompt: 'You are an expert at enhancing the text provided within <TRANSCRIPT> tags according to the following guidelines for developers. The information in <CO...'
💻 [PREWARMED-USER] Code user prompt: '
<DICTIONARY_TERMS>
Claude Code, Groq, Clio
</DICTIONARY_TERMS>

<CONTEXT_INFORMATION>
NER Context Entities:
This is a screenshot from Xcode, showing ...'
🛰️ Sending to AI provider via proxy: GROQ
🌐 Sending custom-prompt request to LLM proxy (provider auto-selected by server)...
🔑 [DEBUG] Getting JWT token...
🔑 [DEBUG] JWT token obtained in 0ms
🎯 [CONFIG-DEBUG] Config 2: Routing to Groq endpoint (https://fly.cliovoice.com/api/llm/proxy) with model: qwen
📝 [TIMING] Request preparation: 0.1ms
🌐 [DEBUG] Sending request to proxy...
🌐 [CONNECT] New single-flight request from warmHold
🌐 [CONNECT] Attempt #17 (loop 1/2) starting…
t=6056729 sess=G79 lvl=INFO cat=stream evt=temp_key_fetch_start
⚡ [CACHE-HIT] Retrieved temp key in 0.1ms
t=6056729 sess=G79 lvl=INFO cat=stream evt=temp_key_fetch latency_ms=0 source=cached expires_in_s=-1
🌐 [WS CONNECT] Using URL: wss://stt-rt.soniox.com/transcribe-websocket
🔗 [WS] Bound socket id=sock_1362276900109741648@attempt_17
t=6056730 sess=G79 lvl=INFO cat=stream evt=ws_bind attempt=17 target_host=stt-rt.soniox.com via_proxy=false path=/transcribe-websocket socket=sock_1362276900109741648@attempt_17 target_ip=resolving...
🔑 Successfully connected to Soniox using temp key (1ms key latency)
t=6056731 sess=G79 lvl=INFO cat=stream evt=ws_bind_resolved path=/transcribe-websocket target_host=stt-rt.soniox.com target_ip=129.146.176.251 attempt=17 socket=sock_1362276900109741648@attempt_17 via_proxy=false
🌐 [DEBUG] Proxy response received in 1195ms
✅ [SSE] Parsed streaming response: 116 characters
🔍 [CONNECTION HEALTH]
t=6057865 sess=G79 lvl=INFO cat=stream evt=ws_handshake_metrics tls_ms=876 socket=sock_1362276900109741648@attempt_17 connect_ms=883 proxy=false reused=false protocol=http/1.1 attempt=17 total_ms=1134 dns_ms=0
🔌 WebSocket did open (sid=sock_1362276900109741648, attemptId=17)
✅ Custom-prompt enhancement via proxy succeeded
t=6057873 sess=G79 lvl=INFO cat=transcript evt=llm_final text="Tracking invoices, managing clients, keeping payments in check, all in one place. Phase 24, and write your prompt."
📊 [DETAILED STREAMING TIMING] Streaming: 186.3ms | Context: 0.0ms | LLM: 1214.9ms | Tracked Overhead: 0.0ms | Unaccounted: 1.3ms | Total: 1402.5ms
🔊 [SoundManager] Attempting to play stop sound
🔊 [SoundManager] NSSound stop sound result: true
🧹 Connection cleanup completed (session resources released)
📝 [GRACE] Recording session ended
📱 Dismissing recorder
📊 [ENHANCEMENT] Tracking 18 words - currentTier: pro, trialWordsRemaining: 2552
✅ Streaming transcription processing completed
t=6058008 sess=G79 lvl=INFO cat=transcript evt=insert_attempt target=Xcode chars=115 text="Tracking invoices, managing clients, keeping payments in check, all in one place. Phase 24, and write your prompt. "
🔍 [PASTE DEBUG] AXIsProcessTrusted() returned true, proceeding
🔍 [PASTE DEBUG] UseDirectTextInsertion setting: false
🔍 [PASTE DEBUG] Direct insertion disabled, using clipboard paste
⌨️ Using CGEvent-based Command+V
t=6058009 sess=G79 lvl=INFO cat=transcript evt=insert_result ok=true
📊 [POST-RELEASE E2E] 1537ms (finalize=184ms | llm=1214ms | paste=0ms) | warm_socket=no
🌐 [CONNECT] Attempt #17 succeeded
📤 [START] Sent start/config on standby socket (eager mode)
t=6058042 sess=G79 lvl=INFO cat=stream evt=start_config ctx=standby_eager attempt=17 socket=sock_1362276900109741648@attempt_17 summary=["audio_format": "pcm_s16le", "ch": 1, "langs": 2, "model": "stt-rt-preview-v2", "ctx_len": 36, "sr": 16000, "json_hash": "647d4d9a98bd6de5", "valid": true]
📤 Sending text frame seq=39426
🧊 [STANDBY] Connected standby socket — keepalive every 10.0s, TTL=60s
🔌 [READY] attemptId=17 socketId=sock_1362276900109741648@attempt_17 start_text_sent=true
🧊 [STANDBY] WebSocket ready in 1347ms (handshake)
👂 [LISTENER] Standby listener task for socketId=sock_1362276900109741648@attempt_17 attemptId=17
🧭 [APP] applicationDidBecomeActive
🧭 [APP] ActivationPolicy=.regular (IsMenuBarOnly=false)
🔄 [SYNC_STATE] syncTrialState called - currentTier: pro, isInTrial: false
🔄 [SYNC_STATE] Final state after syncTrialState - currentTier: pro, isInTrial: false
💤 [STANDBY] keepalive_tick
t=6068080 sess=G79 lvl=INFO cat=stream evt=standby_keepalive_tick
📱 Showing DynamicNotch recorder (MIT licensed)
🧊 [WARMUP] Skipping (recently run) context=recorderUIShown
🎤 [toggleRecord] Starting recording, current model: soniox-realtime-streaming
🧊 [WARMUP] Skipping (recently run) context=hotkeyDown
🎙️ Starting recording sequence...
📝 [GRACE] Recording session started with 2552 words remaining
🔧 [NER-SETUP] Setting up callback - contextService exists: true
✅ [NER-SETUP] OCR completion callback configured for NER pre-warming - callback exists: true
📊 [SESSION] Starting recording session #14
🧪 [A/B] warm_socket=yes
🧊➡️🔥 [STANDBY->ACTIVE] Consuming standby socket for new utterance
⏭️ [STANDBY->ACTIVE] START already sent on standby (eager) — skipping re-send
✅ [STANDBY->ACTIVE] Probe keepalive OK — proceeding to resume queue
⏹️ Keepalive timer stopped
🔄 Keepalive timer started (interval: 15.000000s)
🎤 Registering audio tap for Soniox
🎬 Starting screen capture with verified permissions
t=6070470 sess=G79 lvl=INFO cat=audio evt=record_start service=Soniox
🔍 Performing audio system pre-flight checks
🎯 (16) A Yale Student Raised $3.1M in 2 Weeks for an AI Social App | Series, Nathaneo Johnson - YouTube
🌐 Browser detected, using content-optimized capture settings
throwing -10877
🌐 Using selected languages for OCR: zh-Hans, en-US
🌐 Browser detected - using optimized OCR settings for webpage content
throwing -10877
✅ Pre-flight checks passed
t=6070588 sess=G79 lvl=INFO cat=audio evt=tap_install backend=avcapture ok=true service=Soniox
t=6070589 sess=G79 lvl=INFO cat=audio evt=record_start reason=start_capture
t=6070589 sess=G79 lvl=INFO cat=audio evt=device_pin_start desired_id=198 prev_name="MacBook Pro Microphone" desired_uid_hash=-1464455807919438517 desired_name="MacBook Pro Microphone" prev_id=198 prev_uid_hash=-1464455807919438517
t=6070589 sess=G79 lvl=INFO cat=audio evt=capture_backend_selected backend=avcapture
✅ Unified audio capture started
✅ Selected account account-bundle (connections: 1/10)
🧠 [TEN-VAD] Initialized (threshold=0.5, hop=256)
🚀 Starting Clio streaming transcription
🏥 [AUDIO HEALTH] Health monitoring timer started
⏱️ [TIMING] mic_engaged @ 1756217897.928
⏱️ [TIMING] WebSocket connect task completed — will flush after READY
pass
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
t=6070680 sess=G79 lvl=INFO cat=audio evt=avcapture_start ok=true
t=6070681 sess=G79 lvl=INFO cat=stream evt=first_audio_buffer_captured ms=50
✅ [AUDIO HEALTH] First audio data received - tap is functional
t=6070682 sess=G79 lvl=INFO cat=stream evt=first_audio_sent ms=52 seq=1
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
🔍 Found 53 text observations
✅ Text extraction successful: 638 chars, 638 non-whitespace, 124 words from 53 observations
✅ Captured text successfully
✅ [CAPTURE DEBUG] Screen capture successful: 798 characters
💾 [SMART-CACHE] Cached new context: com.google.Chrome|(16) A Yale Student Raised $3.1M in 2 Weeks for an AI Social App | Series, Nathaneo Johnson - YouTube (798 chars)
🎯 [CALLBACK DEBUG] Executing callback with fresh content (798 chars)
🔥 [PREWARM DEBUG] Pre-warming AI connection (target: Gemini), environment: flyio
🔥 [NER-TRIGGER] OCR completion callback triggered with fresh content
🎬 [NER-PREWARM] Using raw OCR text for NER: 798 characters
🧠 [NER-DEFAULT] Using default NER prompt for general extraction
🌐 [PATH] Initial path baseline set — no action
throwing -10877
throwing -10877
🤖 [FLY.IO-NER] Server-reported provider: gemini
📥 [NER-STORE] Stored NER entities: 2110 chars - This looks like a screenshot of a YouTube video about a Yale student raising money for an AI social ...
✅ [FLY.IO] NER refresh completed successfully
throwing -10877
throwing -10877
throwing -10877
throwing -10877
t=6084986 sess=G79 lvl=INFO cat=stream evt=first_partial ms=14356
t=6084986 sess=G79 lvl=INFO cat=stream evt=ttft_hotkey ms=14356
t=6084986 sess=G79 lvl=INFO cat=stream evt=ttft ms=28473
💓 Sent keepalive (active)
throwing -10877
throwing -10877
t=6088207 sess=G79 lvl=INFO cat=stream evt=first_final ms=17577
t=6088207 sess=G79 lvl=INFO cat=transcript evt=raw_final text="This is going to be a really dangerous story, and I actually"
t=6089523 sess=G79 lvl=INFO cat=transcript evt=raw_final text=" started when Sean and my"
t=6090890 sess=G79 lvl=INFO cat=transcript evt=raw_final text=" co-founder and I started a"
🛑 Stopping recording
🛑 Stopping Clio streaming transcription
🏥 [AUDIO HEALTH] Health monitoring timer stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
🛑 Stopping unified audio capture
t=6091024 sess=G79 lvl=INFO cat=audio evt=record_stop
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key plugInPackage
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key CMIOType
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key numberOfDevices
t=6091033 sess=G79 lvl=INFO cat=audio evt=avcapture_stop
✅ Unified audio capture stopped
🗣️ [TEN-VAD] Speech start detected
📤 Sent end-of-stream signal
📤 Sent manual finalize command
🕐 Using finalization timeout: 400ms (connection took 20527ms)
ℹ️ [OPTIMISTIC] Not skipping: end=false pending=0 ms_since_last=94 tail=100 silence_ok=false tokens_quiet_ok=false partial_empty=false uncond=false
t=6091452 sess=G79 lvl=INFO cat=transcript evt=raw_final text=" podcast about professional media at Yale. This is interviewing founder.<end>"
🏁 Received <fin> token - finalization complete
✅ Received <fin> token after 405ms
⚡ Audio capture already stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
📉 Released connection for account account-bundle (connections: 0)
💾 [COLD-START] Updated successful streaming timestamp
💾 [COLD-START] Updated successful streaming timestamp
✅ Streaming stopped. Final transcript (184 chars, 20.9s, with audio file): "This is going to be a really dangerous story, and I actually started when Sean and my co-founder and I started a podcast about professional media at Yale. This is interviewing founder."
t=6091582 sess=G79 lvl=INFO cat=transcript evt=final text="This is going to be a really dangerous story, and I actually started when Sean and my co-founder and I started a podcast about professional media at Yale. This is interviewing founder."
t=6091582 sess=G79 lvl=INFO cat=transcript evt=session_end divider="────────── session end ──────────"
🌡️ [WARM] warm_socket=yes
⏹️ Keepalive timer stopped
⚠️ WebSocket did close with code 1001 (sid=sock_1362276900109741648, attemptId=17)
🔌 [WS] Disconnected (socketId=sock_1362276900109741648@attempt_17)
t=6091583 sess=G79 lvl=WARN cat=stream evt=state code=1001 state=closed
✅ Streaming transcription completed successfully, length: 184 characters
⏱️ [TIMING] Subscription tracking: 0.4ms
⏱️ [TIMING] ASR word tracking: 0.0ms
🧠 Performing intelligent end-context detection for streaming
⏱️ [CONTEXT DETAIL] Cache check: 0.0ms
⚡ [SMART-OPTIMIZATION] Using smart cached screen context (798 chars) - skipping new capture
⏱️ [STREAMING CONTEXT TIMING] Screen capture + context detection: 0.0ms
🎯 Starting dynamic context-aware AI enhancement with tracking for text (184 characters)
⚡ [FAST-PATH] Using pre-warmed context - skipping redundant detection
⚡ [PREWARMED] Using pre-warmed NER context fast-path
🎯 [RULE-ENGINE] Cache hit for com.apple.dt.Xcode|||Clio — SonioxStreamingService.swift
💻 [PREWARMED] Detected code context → using code system prompt
💻 [PREWARMED-SYSTEM] Code system prompt: 'You are an expert at enhancing the text provided within <TRANSCRIPT> tags according to the following guidelines for developers. The information in <CO...'
💻 [PREWARMED-USER] Code user prompt: '
<DICTIONARY_TERMS>
Claude Code, Groq, Clio
</DICTIONARY_TERMS>

<CONTEXT_INFORMATION>
NER Context Entities:
This looks like a screenshot of a YouTube...'
🛰️ Sending to AI provider via proxy: GROQ
🌐 Sending custom-prompt request to LLM proxy (provider auto-selected by server)...
🔑 [DEBUG] Getting JWT token...
🔑 [DEBUG] JWT token obtained in 0ms
🎯 [CONFIG-DEBUG] Config 2: Routing to Groq endpoint (https://fly.cliovoice.com/api/llm/proxy) with model: qwen
📝 [TIMING] Request preparation: 0.2ms
🌐 [DEBUG] Sending request to proxy...
🌐 [CONNECT] New single-flight request from warmHold
🌐 [CONNECT] Attempt #18 (loop 1/2) starting…
t=6091672 sess=G79 lvl=INFO cat=stream evt=temp_key_fetch_start
⚡ [CACHE-HIT] Retrieved temp key in 0.1ms
t=6091673 sess=G79 lvl=INFO cat=stream evt=temp_key_fetch latency_ms=0 source=cached expires_in_s=-1
🌐 [WS CONNECT] Using URL: wss://stt-rt.soniox.com/transcribe-websocket
🔗 [WS] Bound socket id=sock_-7003565710894523804@attempt_18
t=6091673 sess=G79 lvl=INFO cat=stream evt=ws_bind target_ip=resolving... socket=sock_-7003565710894523804@attempt_18 via_proxy=false attempt=18 path=/transcribe-websocket target_host=stt-rt.soniox.com
🔑 Successfully connected to Soniox using temp key (1ms key latency)
t=6091674 sess=G79 lvl=INFO cat=stream evt=ws_bind_resolved path=/transcribe-websocket attempt=18 target_host=stt-rt.soniox.com via_proxy=false socket=sock_-7003565710894523804@attempt_18 target_ip=129.146.176.251
🌐 [DEBUG] Proxy response received in 923ms
✅ [SSE] Parsed streaming response: 182 characters
🔍 [CONNECTION HEALTH]
✅ Custom-prompt enhancement via proxy succeeded
t=6092532 sess=G79 lvl=INFO cat=transcript evt=llm_final text="This is going to be a really dangerous story. I actually started when Sean and my co-founder and I started a podcast about professional media at Yale. This is interviewing founder."
📊 [DETAILED STREAMING TIMING] Streaming: 586.9ms | Context: 0.0ms | LLM: 948.0ms | Tracked Overhead: 0.0ms | Unaccounted: 1.5ms | Total: 1536.5ms
🔊 [SoundManager] Attempting to play stop sound
🔊 [SoundManager] NSSound stop sound result: true
🧹 Connection cleanup completed (session resources released)
📝 [GRACE] Recording session ended
📱 Dismissing recorder
📊 [ENHANCEMENT] Tracking 32 words - currentTier: pro, trialWordsRemaining: 2552
✅ Streaming transcription processing completed
t=6092645 sess=G79 lvl=INFO cat=transcript evt=insert_attempt chars=181 text="This is going to be a really dangerous story. I actually started when Sean and my co-founder and I started a podcast about professional media at Yale. This is interviewing founder. " target=Xcode
🔍 [PASTE DEBUG] AXIsProcessTrusted() returned true, proceeding
🔍 [PASTE DEBUG] UseDirectTextInsertion setting: false
🔍 [PASTE DEBUG] Direct insertion disabled, using clipboard paste
⌨️ Using CGEvent-based Command+V
t=6092646 sess=G79 lvl=INFO cat=transcript evt=insert_result ok=true
📊 [POST-RELEASE E2E] 1649ms (finalize=514ms | llm=948ms | paste=0ms) | warm_socket=no
t=6092864 sess=G79 lvl=INFO cat=stream evt=ws_handshake_metrics proxy=false total_ms=1190 reused=false socket=sock_-7003565710894523804@attempt_18 attempt=18 dns_ms=1 tls_ms=884 protocol=http/1.1 connect_ms=886
🔌 WebSocket did open (sid=sock_-7003565710894523804, attemptId=18)
🌐 [CONNECT] Attempt #18 succeeded
📤 [START] Sent start/config on standby socket (eager mode)
t=6092865 sess=G79 lvl=INFO cat=stream evt=start_config summary=["audio_format": "pcm_s16le", "json_hash": "647d4d9a98bd6de5", "valid": true, "ch": 1, "langs": 2, "sr": 16000, "model": "stt-rt-preview-v2", "ctx_len": 36] ctx=standby_eager attempt=18 socket=sock_-7003565710894523804@attempt_18
📤 Sending text frame seq=41182
🧊 [STANDBY] Connected standby socket — keepalive every 10.0s, TTL=60s
🔌 [READY] attemptId=18 socketId=sock_-7003565710894523804@attempt_18 start_text_sent=true
🧊 [STANDBY] WebSocket ready in 1193ms (handshake)
👂 [LISTENER] Standby listener task for socketId=sock_-7003565710894523804@attempt_18 attemptId=18
🧭 [APP] applicationShouldHandleReopen called - hasVisibleWindows: true
🧭 [APP] ActivationPolicy=.regular (IsMenuBarOnly=false)
🧭 [APP] applicationDidBecomeActive
🧭 [APP] ActivationPolicy=.regular (IsMenuBarOnly=false)
🪟 [DOCK] Found existing window, activating it
🔄 [SYNC_STATE] syncTrialState called - currentTier: pro, isInTrial: false
🔄 [SYNC_STATE] Final state after syncTrialState - currentTier: pro, isInTrial: false
Cancelling audio cleanup scheduling
💤 [STANDBY] keepalive_tick
t=6102866 sess=G79 lvl=INFO cat=stream evt=standby_keepalive_tick
📱 Showing DynamicNotch recorder (MIT licensed)
🔥 [WARMUP] ensureReady() invoked context=recorderUIShown
🔥 [SYSTEM-WARMUP] TempKeyCache warmup integration
🚀 [PREFETCH] Starting background temp key prefetch
🎤 [toggleRecord] Starting recording, current model: soniox-realtime-streaming
🧊 [WARMUP] Skipping (recently run) context=hotkeyDown
🎙️ Starting recording sequence...
📝 [GRACE] Recording session started with 2552 words remaining
🔧 [NER-SETUP] Setting up callback - contextService exists: true
✅ [NER-SETUP] OCR completion callback configured for NER pre-warming - callback exists: true
📊 [SESSION] Starting recording session #15
🧪 [A/B] warm_socket=yes
🧊➡️🔥 [STANDBY->ACTIVE] Consuming standby socket for new utterance
⏭️ [STANDBY->ACTIVE] START already sent on standby (eager) — skipping re-send
✅ [STANDBY->ACTIVE] Probe keepalive OK — proceeding to resume queue
⏹️ Keepalive timer stopped
🔄 Keepalive timer started (interval: 15.000000s)
🎤 Registering audio tap for Soniox
🎬 Starting screen capture with verified permissions
t=6110848 sess=G79 lvl=INFO cat=audio evt=record_start service=Soniox
🔍 Performing audio system pre-flight checks
🎯 Clio — SonioxStreamingService.swift
🌐 Using selected languages for OCR: zh-Hans, en-US
throwing -10877
throwing -10877
✅ Pre-flight checks passed
t=6110955 sess=G79 lvl=INFO cat=audio evt=tap_install service=Soniox ok=true backend=avcapture
t=6110955 sess=G79 lvl=INFO cat=audio evt=record_start reason=start_capture
t=6110955 sess=G79 lvl=INFO cat=audio evt=device_pin_start desired_name="MacBook Pro Microphone" prev_id=198 prev_uid_hash=-1464455807919438517 prev_name="MacBook Pro Microphone" desired_id=198 desired_uid_hash=-1464455807919438517
t=6110956 sess=G79 lvl=INFO cat=audio evt=capture_backend_selected backend=avcapture
✅ Unified audio capture started
✅ Selected account account-bundle (connections: 1/10)
🧠 [TEN-VAD] Initialized (threshold=0.5, hop=256)
🚀 Starting Clio streaming transcription
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
t=6111023 sess=G79 lvl=INFO cat=audio evt=avcapture_start ok=true
t=6111025 sess=G79 lvl=INFO cat=stream evt=first_audio_buffer_captured ms=36
🏥 [AUDIO HEALTH] Health monitoring timer started
⏱️ [TIMING] mic_engaged @ 1756217938.322
⏱️ [TIMING] WebSocket connect task completed — will flush after READY
pass
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
✅ [AUDIO HEALTH] First audio data received - tap is functional
t=6111050 sess=G79 lvl=INFO cat=stream evt=first_audio_sent ms=62 seq=1
throwing -10877
throwing -10877
🌐 [PATH] Initial path baseline set — no action
🔍 Found 82 text observations
✅ Text extraction successful: 1886 chars, 1886 non-whitespace, 202 words from 82 observations
✅ Captured text successfully
✅ [CAPTURE DEBUG] Screen capture successful: 1972 characters
💾 [SMART-CACHE] Cached new context: com.google.Chrome|(16) A Yale Student Raised $3.1M in 2 Weeks for an AI Social App | Series, Nathaneo Johnson - YouTube (1972 chars)
🎯 [CALLBACK DEBUG] Executing callback with fresh content (1972 chars)
🔥 [PREWARM DEBUG] Pre-warming AI connection (target: Gemini), environment: flyio
🔥 [NER-TRIGGER] OCR completion callback triggered with fresh content
🎬 [NER-PREWARM] Using raw OCR text for NER: 1972 characters
🧠 [NER-DEFAULT] Using default NER prompt for general extraction
🌐 [ASR BREAKDOWN] Total: 1272ms | Client↔Proxy: 209ms | Proxy↔Soniox: 1063ms | Network: 1063ms
🗑️ Evicted oldest temp key to maintain cache size limit
💾 Cached temp key for languages: ["zh", "en"]
🗓️ [TTL-SCHEDULE] Scheduling temp key refresh for key=global in 3000s (expiresAt=2025-08-26 15:18:59 +0000)
✅ [PREFETCH] Successfully prefetched temp key
🎤 [WARMUP] Pre-warming audio system...
✅ [PREWARM] Device enumeration completed
✅ [PREWARM] Audio system pre-warming completed successfully
✅ [WARMUP] Audio system pre-warmed successfully
t=6113353 sess=G79 lvl=INFO cat=stream evt=first_partial ms=2364
t=6113353 sess=G79 lvl=INFO cat=stream evt=ttft_hotkey ms=2364
t=6113353 sess=G79 lvl=INFO cat=stream evt=ttft ms=22319
🤖 [FLY.IO-NER] Server-reported provider: gemini
📥 [NER-STORE] Stored NER entities: 4723 chars - This looks like a snippet of code from a Swift application called "Clio" that interacts with a strea...
✅ [FLY.IO] NER refresh completed successfully
throwing -10877
throwing -10877
throwing -10877
throwing -10877
💓 Sent keepalive (active)
throwing -10877
throwing -10877
throwing -10877
throwing -10877
throwing -10877
throwing -10877
💓 Sent keepalive (active)
throwing -10877
throwing -10877
throwing -10877
throwing -10877
throwing -10877
throwing -10877
💓 Sent keepalive (active)
throwing -10877
throwing -10877
throwing -10877
throwing -10877
throwing -10877
throwing -10877
💓 Sent keepalive (active)
🛑 Stopping recording
🛑 Stopping Clio streaming transcription
🏥 [AUDIO HEALTH] Health monitoring timer stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
🛑 Stopping unified audio capture
t=6171143 sess=G79 lvl=INFO cat=audio evt=record_stop
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key plugInPackage
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key CMIOType
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key numberOfDevices
t=6171153 sess=G79 lvl=INFO cat=audio evt=avcapture_stop
✅ Unified audio capture stopped
📤 Sent end-of-stream signal
📤 Sent manual finalize command
🕐 Using finalization timeout: 400ms (connection took 60290ms)
ℹ️ [OPTIMISTIC] Not skipping: end=false pending=0 ms_since_last=117 tail=100 silence_ok=false tokens_quiet_ok=true partial_empty=true uncond=false
⚠️ Timed out waiting for <fin> token after 418ms — merging partial transcript
⚡ Audio capture already stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
📉 Released connection for account account-bundle (connections: 0)
💾 [COLD-START] Updated successful streaming timestamp
💾 [COLD-START] Updated successful streaming timestamp
✅ Streaming stopped. Final transcript (0 chars, 60.7s, with audio file): ""
t=6171706 sess=G79 lvl=INFO cat=transcript evt=final text=
t=6171706 sess=G79 lvl=INFO cat=transcript evt=session_end divider="────────── session end ──────────"
🌡️ [WARM] warm_socket=yes
⏹️ Keepalive timer stopped
🔌 [WS] Disconnected (socketId=sock_-7003565710894523804@attempt_18)
⚠️ WebSocket did close with code 1001 (sid=sock_-7003565710894523804, attemptId=18)
⚠️ No text received from streaming transcription
📱 Dismissing recorder
t=6171707 sess=G79 lvl=WARN cat=stream evt=state state=closed code=1001
🌐 [CONNECT] New single-flight request from warmHold
🧹 Connection cleanup completed (session resources released)
🌐 [CONNECT] Attempt #19 (loop 1/2) starting…
t=6171812 sess=G79 lvl=INFO cat=stream evt=temp_key_fetch_start
⚡ [CACHE-HIT] Retrieved temp key in 3.7ms
t=6171816 sess=G79 lvl=INFO cat=stream evt=temp_key_fetch expires_in_s=-1 latency_ms=3 source=cached
🌐 [WS CONNECT] Using URL: wss://stt-rt.soniox.com/transcribe-websocket
🔗 [WS] Bound socket id=sock_2533067161244131825@attempt_19
t=6171817 sess=G79 lvl=INFO cat=stream evt=ws_bind target_ip=resolving... path=/transcribe-websocket socket=sock_2533067161244131825@attempt_19 target_host=stt-rt.soniox.com attempt=19 via_proxy=false
🔑 Successfully connected to Soniox using temp key (5ms key latency)
t=6172011 sess=G79 lvl=INFO cat=stream evt=ws_bind_resolved target_ip=129.146.176.251 attempt=19 path=/transcribe-websocket socket=sock_2533067161244131825@attempt_19 via_proxy=false target_host=stt-rt.soniox.com
t=6174204 sess=G79 lvl=INFO cat=stream evt=ws_handshake_metrics tls_ms=2071 socket=sock_2533067161244131825@attempt_19 dns_ms=54 connect_ms=2075 total_ms=2385 proxy=false reused=false attempt=19 protocol=http/1.1
🔌 WebSocket did open (sid=sock_2533067161244131825, attemptId=19)
🌐 [CONNECT] Attempt #19 succeeded
📤 [START] Sent start/config on standby socket (eager mode)
t=6174205 sess=G79 lvl=INFO cat=stream evt=start_config summary=["ch": 1, "valid": true, "audio_format": "pcm_s16le", "ctx_len": 36, "json_hash": "74c88fa4ee9a34f7", "model": "stt-rt-preview-v2", "langs": 2, "sr": 16000] ctx=standby_eager attempt=19 socket=sock_2533067161244131825@attempt_19
📤 Sending text frame seq=46362
🧊 [STANDBY] Connected standby socket — keepalive every 10.0s, TTL=60s
🔌 [READY] attemptId=19 socketId=sock_2533067161244131825@attempt_19 start_text_sent=true
🧊 [STANDBY] WebSocket ready in 2416ms (handshake)
👂 [LISTENER] Standby listener task for socketId=sock_2533067161244131825@attempt_19 attemptId=19
📱 Showing DynamicNotch recorder (MIT licensed)
🔥 [WARMUP] ensureReady() invoked context=recorderUIShown
🔥 [SYSTEM-WARMUP] TempKeyCache warmup integration
🚀 [PREFETCH] Starting background temp key prefetch
🎤 [toggleRecord] Starting recording, current model: soniox-realtime-streaming
🧊 [WARMUP] Skipping (recently run) context=hotkeyDown
🎙️ Starting recording sequence...
📝 [GRACE] Recording session started with 2552 words remaining
🔧 [NER-SETUP] Setting up callback - contextService exists: true
✅ [NER-SETUP] OCR completion callback configured for NER pre-warming - callback exists: true
📊 [SESSION] Starting recording session #16
🧪 [A/B] warm_socket=yes
🧊➡️🔥 [STANDBY->ACTIVE] Consuming standby socket for new utterance
⏭️ [STANDBY->ACTIVE] START already sent on standby (eager) — skipping re-send
♻️ [SMART-CACHE] Using cached context: 1972 characters
🔥 [NER-CACHE] Triggering NER callback with cached content (1972 chars)
✅ [NER-CACHE] NER callback triggered with cached content
✅ [STANDBY->ACTIVE] Probe keepalive OK — proceeding to resume queue
⏹️ Keepalive timer stopped
🔄 Keepalive timer started (interval: 15.000000s)
🔥 [PREWARM DEBUG] Pre-warming AI connection (target: Gemini), environment: flyio
🎤 Registering audio tap for Soniox
t=6181536 sess=G79 lvl=INFO cat=audio evt=record_start service=Soniox
🔍 Performing audio system pre-flight checks
throwing -10877
throwing -10877
✅ Pre-flight checks passed
t=6181620 sess=G79 lvl=INFO cat=audio evt=tap_install ok=true service=Soniox backend=avcapture
t=6181620 sess=G79 lvl=INFO cat=audio evt=record_start reason=start_capture
t=6181620 sess=G79 lvl=INFO cat=audio evt=device_pin_start prev_id=198 prev_uid_hash=-1464455807919438517 desired_id=198 desired_name="MacBook Pro Microphone" prev_name="MacBook Pro Microphone" desired_uid_hash=-1464455807919438517
t=6181620 sess=G79 lvl=INFO cat=audio evt=capture_backend_selected backend=avcapture
✅ Unified audio capture started
✅ Selected account account-bundle (connections: 1/10)
🧠 [TEN-VAD] Initialized (threshold=0.5, hop=256)
🚀 Starting Clio streaming transcription
🎬 [NER-PREWARM] Using raw OCR text for NER: 1972 characters
🧠 [NER-DEFAULT] Using default NER prompt for general extraction
🏥 [AUDIO HEALTH] Health monitoring timer started
⏱️ [TIMING] mic_engaged @ 1756218008.957
⏱️ [TIMING] WebSocket connect task completed — will flush after READY
pass
throwing -10877
throwing -10877
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
t=6181740 sess=G79 lvl=INFO cat=audio evt=avcapture_start ok=true
t=6181741 sess=G79 lvl=INFO cat=stream evt=first_audio_buffer_captured ms=86
✅ [AUDIO HEALTH] First audio data received - tap is functional
t=6181741 sess=G79 lvl=INFO cat=stream evt=first_audio_sent seq=1 ms=87
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
🌐 [ASR BREAKDOWN] Total: 477ms | Client↔Proxy: 215ms | Proxy↔Soniox: 262ms | Network: 262ms
🗑️ Evicted oldest temp key to maintain cache size limit
💾 Cached temp key for languages: ["zh", "en"]
🗓️ [TTL-SCHEDULE] Scheduling temp key refresh for key=global in 3000s (expiresAt=2025-08-26 15:20:09 +0000)
✅ [PREFETCH] Successfully prefetched temp key
🎤 [WARMUP] Pre-warming audio system...
✅ [PREWARM] Device enumeration completed
✅ [PREWARM] Audio system pre-warming completed successfully
✅ [WARMUP] Audio system pre-warmed successfully
🗣️ [TEN-VAD] Speech start detected
🌐 [PATH] Initial path baseline set — no action
🤖 [FLY.IO-NER] Server-reported provider: gemini
📥 [NER-STORE] Stored NER entities: 1803 chars - The user is viewing the Xcode IDE.

Here's a breakdown of what the image shows:

*   **Application:*...
✅ [FLY.IO] NER refresh completed successfully
t=6184734 sess=G79 lvl=INFO cat=stream evt=first_partial ms=3080
t=6184734 sess=G79 lvl=INFO cat=stream evt=ttft_hotkey ms=3080
t=6184734 sess=G79 lvl=INFO cat=stream evt=ttft ms=2866
throwing -10877
throwing -10877
t=6187367 sess=G79 lvl=INFO cat=stream evt=first_final ms=5713
t=6187368 sess=G79 lvl=INFO cat=transcript evt=raw_final text=Profess
t=6188680 sess=G79 lvl=INFO cat=transcript evt=raw_final text="ional reasons, whether that"
t=6190072 sess=G79 lvl=INFO cat=transcript evt=raw_final text=" is a reason for capital"
t=6191312 sess=G79 lvl=INFO cat=transcript evt=raw_final text=" or that the j"
throwing -10877
throwing -10877
t=6192607 sess=G79 lvl=INFO cat=transcript evt=raw_final text="ob I imagine is"
🛑 Stopping recording
🛑 Stopping Clio streaming transcription
🏥 [AUDIO HEALTH] Health monitoring timer stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
🛑 Stopping unified audio capture
t=6193192 sess=G79 lvl=INFO cat=audio evt=record_stop
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key plugInPackage
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key CMIOType
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key numberOfDevices
t=6193203 sess=G79 lvl=INFO cat=audio evt=avcapture_stop
✅ Unified audio capture stopped
🗣️ [TEN-VAD] Speech start detected
📤 Sent end-of-stream signal
📤 Sent manual finalize command
🕐 Using finalization timeout: 400ms (connection took 11689ms)
ℹ️ [OPTIMISTIC] Not skipping: end=false pending=0 ms_since_last=93 tail=100 silence_ok=false tokens_quiet_ok=false partial_empty=false uncond=false
t=6193688 sess=G79 lvl=INFO cat=transcript evt=raw_final text=" to be a diabetes patient. There's definitely five.<end>"
🏁 Received <fin> token - finalization complete
✅ Received <fin> token after 395ms
⚡ Audio capture already stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
📉 Released connection for account account-bundle (connections: 0)
💾 [COLD-START] Updated successful streaming timestamp
💾 [COLD-START] Updated successful streaming timestamp
✅ Streaming stopped. Final transcript (139 chars, 12.1s, with audio file): "Professional reasons, whether that is a reason for capital or that the j ob I imagine is to be a diabetes patient. There's definitely five."
t=6193790 sess=G79 lvl=INFO cat=transcript evt=final text="Professional reasons, whether that is a reason for capital or that the j ob I imagine is to be a diabetes patient. There's definitely five."
t=6193790 sess=G79 lvl=INFO cat=transcript evt=session_end divider="────────── session end ──────────"
🌡️ [WARM] warm_socket=yes
⏹️ Keepalive timer stopped
🔌 [WS] Disconnected (socketId=sock_2533067161244131825@attempt_19)
⚠️ WebSocket did close with code 1001 (sid=sock_2533067161244131825, attemptId=19)
t=6193791 sess=G79 lvl=WARN cat=stream evt=state state=closed code=1001
✅ Streaming transcription completed successfully, length: 139 characters
⏱️ [TIMING] Subscription tracking: 0.3ms
⏱️ [TIMING] ASR word tracking: 0.0ms
🧠 Performing intelligent end-context detection for streaming
⏱️ [CONTEXT DETAIL] Cache check: 0.0ms
⚡ [SMART-OPTIMIZATION] Using smart cached screen context (1972 chars) - skipping new capture
⏱️ [STREAMING CONTEXT TIMING] Screen capture + context detection: 0.0ms
🎯 Starting dynamic context-aware AI enhancement with tracking for text (139 characters)
⚡ [FAST-PATH] Using pre-warmed context - skipping redundant detection
⚡ [PREWARMED] Using pre-warmed NER context fast-path
🎯 [RULE-ENGINE] Detected: General
📧 [EMAIL] Starting email context detection
🚫 [DYNAMIC] Email exclusion detected in content: excluding from detection
💻 [CODE] Starting code context detection
❌ [CODE] Code confidence too low: 0.000000 < 0.300000
💬 [CHAT] Starting casual chat context detection
💬 [CHAT] Casual chat context detected - Title matches: 1, Content matches: 4, Confidence: 0.280000
📝 [REGISTRY] Rule engine returned .none and no high-confidence legacy matches, returning general context
📝 [PREWARMED] Non-code or unknown context → using enhanced system prompt
🚨 [PROMPT-DEBUG] About to call getSystemMessage(for: .transcriptionEnhancement)
🚨 [PROMPT-DEBUG] getSystemMessage called with mode: transcriptionEnhancement
🚨 [PROMPT-DEBUG] RETURNING TRANSCRIPTION ENHANCEMENT PROMPT
🚨 [PROMPT-DEBUG] About to call getUserMessage(text:, mode: .transcriptionEnhancement)
📝 [PREWARMED-SYSTEM] Enhanced system prompt: 'You are an expert in enhancing the text provided within <TRANSCRIPT> tags according to the following guidelines: The information in <CONTEXT_INFORMATI...'
📝 [PREWARMED-USER] Enhanced user prompt: '<CONTEXT_INFORMATION>
NER Context Entities:
The user is viewing the Xcode IDE.

Here's a breakdown of what the image shows:

*   **Application:** Xcod...'
🛰️ Sending to AI provider via proxy: GROQ
🌐 Sending custom-prompt request to LLM proxy (provider auto-selected by server)...
🔑 [DEBUG] Getting JWT token...
🔑 [DEBUG] JWT token obtained in 0ms
🎯 [CONFIG-DEBUG] Config 2: Routing to Groq endpoint (https://fly.cliovoice.com/api/llm/proxy) with model: qwen
📝 [TIMING] Request preparation: 0.3ms
🌐 [DEBUG] Sending request to proxy...
🌐 [CONNECT] New single-flight request from warmHold
🌐 [CONNECT] Attempt #20 (loop 1/2) starting…
t=6194078 sess=G79 lvl=INFO cat=stream evt=temp_key_fetch_start
⚡ [CACHE-HIT] Retrieved temp key in 0.1ms
t=6194078 sess=G79 lvl=INFO cat=stream evt=temp_key_fetch expires_in_s=-1 latency_ms=0 source=cached
🌐 [WS CONNECT] Using URL: wss://stt-rt.soniox.com/transcribe-websocket
🔗 [WS] Bound socket id=sock_-6904204766172543671@attempt_20
t=6194079 sess=G79 lvl=INFO cat=stream evt=ws_bind socket=sock_-6904204766172543671@attempt_20 target_ip=resolving... path=/transcribe-websocket target_host=stt-rt.soniox.com via_proxy=false attempt=20
🔑 Successfully connected to Soniox using temp key (1ms key latency)
t=6194080 sess=G79 lvl=INFO cat=stream evt=ws_bind_resolved attempt=20 target_host=stt-rt.soniox.com target_ip=129.146.176.251 socket=sock_-6904204766172543671@attempt_20 via_proxy=false path=/transcribe-websocket
🌐 [DEBUG] Proxy response received in 853ms
✅ [SSE] Parsed streaming response: 135 characters
🔍 [CONNECTION HEALTH]
✅ Custom-prompt enhancement via proxy succeeded
t=6194839 sess=G79 lvl=INFO cat=transcript evt=llm_final text="Professional reasons, whether that is a reason for capital or the job I imagine is to be a diabetes patient. There's definitely five."
📊 [DETAILED STREAMING TIMING] Streaming: 623.6ms | Context: 0.0ms | LLM: 1047.1ms | Tracked Overhead: 0.0ms | Unaccounted: 0.9ms | Total: 1671.7ms
🔊 [SoundManager] Attempting to play stop sound
🔊 [SoundManager] NSSound stop sound result: true
🧹 Connection cleanup completed (session resources released)
📝 [GRACE] Recording session ended
📱 Dismissing recorder
📊 [ENHANCEMENT] Tracking 24 words - currentTier: pro, trialWordsRemaining: 2552
✅ Streaming transcription processing completed
t=6194939 sess=G79 lvl=INFO cat=transcript evt=insert_attempt chars=134 target=Xcode text="Professional reasons, whether that is a reason for capital or the job I imagine is to be a diabetes patient. There's definitely five. "
🔍 [PASTE DEBUG] AXIsProcessTrusted() returned true, proceeding
🔍 [PASTE DEBUG] UseDirectTextInsertion setting: false
🔍 [PASTE DEBUG] Direct insertion disabled, using clipboard paste
⌨️ Using CGEvent-based Command+V
t=6194960 sess=G79 lvl=INFO cat=transcript evt=insert_result ok=true
📊 [POST-RELEASE E2E] 1791ms (finalize=521ms | llm=1047ms | paste=0ms) | warm_socket=no
t=6195115 sess=G79 lvl=INFO cat=stream evt=ws_handshake_metrics attempt=20 socket=sock_-6904204766172543671@attempt_20 reused=false protocol=http/1.1 total_ms=1036 dns_ms=1 proxy=false tls_ms=773 connect_ms=784
🔌 WebSocket did open (sid=sock_-6904204766172543671, attemptId=20)
🌐 [CONNECT] Attempt #20 succeeded
📤 [START] Sent start/config on standby socket (eager mode)
t=6195115 sess=G79 lvl=INFO cat=stream evt=start_config summary=["model": "stt-rt-preview-v2", "sr": 16000, "ch": 1, "langs": 2, "valid": true, "audio_format": "pcm_s16le", "ctx_len": 36, "json_hash": "647d4d9a98bd6de5"] ctx=standby_eager attempt=20 socket=sock_-6904204766172543671@attempt_20
📤 Sending text frame seq=47355
🧊 [STANDBY] Connected standby socket — keepalive every 10.0s, TTL=60s
🔌 [READY] attemptId=20 socketId=sock_-6904204766172543671@attempt_20 start_text_sent=true
🧊 [STANDBY] WebSocket ready in 1038ms (handshake)
👂 [LISTENER] Standby listener task for socketId=sock_-6904204766172543671@attempt_20 attemptId=20
💤 [STANDBY] keepalive_tick
t=6205118 sess=G79 lvl=INFO cat=stream evt=standby_keepalive_tick
📱 Showing DynamicNotch recorder (MIT licensed)
🧊 [WARMUP] Skipping (recently run) context=recorderUIShown
🎤 [toggleRecord] Starting recording, current model: soniox-realtime-streaming
🧊 [WARMUP] Skipping (recently run) context=hotkeyDown
🎙️ Starting recording sequence...
📝 [GRACE] Recording session started with 2552 words remaining
🔧 [NER-SETUP] Setting up callback - contextService exists: true
✅ [NER-SETUP] OCR completion callback configured for NER pre-warming - callback exists: true
📊 [SESSION] Starting recording session #17
🧪 [A/B] warm_socket=yes
🧊➡️🔥 [STANDBY->ACTIVE] Consuming standby socket for new utterance
⏭️ [STANDBY->ACTIVE] START already sent on standby (eager) — skipping re-send
✅ [STANDBY->ACTIVE] Probe keepalive OK — proceeding to resume queue
⏹️ Keepalive timer stopped
🔄 Keepalive timer started (interval: 15.000000s)
🎬 Starting screen capture with verified permissions
🎤 Registering audio tap for Soniox
t=6206280 sess=G79 lvl=INFO cat=audio evt=record_start service=Soniox
🔍 Performing audio system pre-flight checks
🎯 Clio — SonioxStreamingService.swift
throwing -10877
throwing -10877
🌐 Using selected languages for OCR: zh-Hans, en-US
✅ Pre-flight checks passed
t=6206366 sess=G79 lvl=INFO cat=audio evt=tap_install service=Soniox backend=avcapture ok=true
t=6206366 sess=G79 lvl=INFO cat=audio evt=record_start reason=start_capture
t=6206367 sess=G79 lvl=INFO cat=audio evt=device_pin_start desired_id=198 desired_uid_hash=-1464455807919438517 desired_name="MacBook Pro Microphone" prev_uid_hash=-1464455807919438517 prev_id=198 prev_name="MacBook Pro Microphone"
t=6206367 sess=G79 lvl=INFO cat=audio evt=capture_backend_selected backend=avcapture
✅ Unified audio capture started
✅ Selected account account-bundle (connections: 1/10)
🧠 [TEN-VAD] Initialized (threshold=0.5, hop=256)
🚀 Starting Clio streaming transcription
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
t=6206425 sess=G79 lvl=INFO cat=audio evt=avcapture_start ok=true
t=6206425 sess=G79 lvl=INFO cat=stream evt=first_audio_buffer_captured ms=30
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
🏥 [AUDIO HEALTH] Health monitoring timer started
⏱️ [TIMING] mic_engaged @ 1756218033.752
⏱️ [TIMING] WebSocket connect task completed — will flush after READY
pass
✅ [AUDIO HEALTH] First audio data received - tap is functional
t=6206460 sess=G79 lvl=INFO cat=stream evt=first_audio_sent seq=1 ms=64
throwing -10877
throwing -10877
🌐 [PATH] Initial path baseline set — no action
🔍 Found 84 text observations
✅ Text extraction successful: 1905 chars, 1905 non-whitespace, 205 words from 84 observations
✅ Captured text successfully
✅ [CAPTURE DEBUG] Screen capture successful: 1991 characters
💾 [SMART-CACHE] Cached new context: com.google.Chrome|(16) A Yale Student Raised $3.1M in 2 Weeks for an AI Social App | Series, Nathaneo Johnson - YouTube (1991 chars)
🎯 [CALLBACK DEBUG] Executing callback with fresh content (1991 chars)
🔥 [PREWARM DEBUG] Pre-warming AI connection (target: Gemini), environment: flyio
🔥 [NER-TRIGGER] OCR completion callback triggered with fresh content
🎬 [NER-PREWARM] Using raw OCR text for NER: 1991 characters
🧠 [NER-DEFAULT] Using default NER prompt for general extraction
t=6210174 sess=G79 lvl=INFO cat=stream evt=first_partial ms=3778
t=6210174 sess=G79 lvl=INFO cat=stream evt=ttft_hotkey ms=3778
t=6210174 sess=G79 lvl=INFO cat=stream evt=ttft ms=16925
throwing -10877
throwing -10877
🤖 [FLY.IO-NER] Server-reported provider: gemini
📥 [NER-STORE] Stored NER entities: 4571 chars - This is a capture of a software development environment, specifically Xcode, showing a Swift file na...
✅ [FLY.IO] NER refresh completed successfully
throwing -10877
throwing -10877
💓 Sent keepalive (active)
throwing -10877
throwing -10877
throwing -10877
throwing -10877
throwing -10877
throwing -10877
🔊 [SoundManager] Attempting to play esc sound (with fade)
📱 Dismissing recorder
🛑 Stopping Clio streaming transcription
🏥 [AUDIO HEALTH] Health monitoring timer stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
🛑 Stopping unified audio capture
t=6236093 sess=G79 lvl=INFO cat=audio evt=record_stop
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key plugInPackage
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key CMIOType
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key numberOfDevices
t=6236103 sess=G79 lvl=INFO cat=audio evt=avcapture_stop
✅ Unified audio capture stopped
⚡ Audio capture already stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
📉 Released connection for account account-bundle (connections: 0)
💾 [COLD-START] Updated successful streaming timestamp
💾 [COLD-START] Updated successful streaming timestamp
✅ Streaming stopped. Final transcript (0 chars, 29.7s, without audio file): ""
t=6236128 sess=G79 lvl=INFO cat=transcript evt=final text=
t=6236128 sess=G79 lvl=INFO cat=transcript evt=session_end divider="────────── session end ──────────"
🌡️ [WARM] warm_socket=yes
⏹️ Keepalive timer stopped
⚠️ WebSocket did close with code 1001 (sid=sock_-6904204766172543671, attemptId=20)
t=6236128 sess=G79 lvl=WARN cat=stream evt=state state=closed code=1001
🗣️ [TEN-VAD] Speech start detected
🔌 [WS] Disconnected (socketId=sock_-6904204766172543671@attempt_20)
🌐 [CONNECT] New single-flight request from warmHold
🌐 [CONNECT] Attempt #21 (loop 1/2) starting…
t=6236185 sess=G79 lvl=INFO cat=stream evt=temp_key_fetch_start
⚡ [CACHE-HIT] Retrieved temp key in 1.6ms
t=6236187 sess=G79 lvl=INFO cat=stream evt=temp_key_fetch source=cached latency_ms=1 expires_in_s=-1
🌐 [WS CONNECT] Using URL: wss://stt-rt.soniox.com/transcribe-websocket
🔗 [WS] Bound socket id=sock_1987707318871578398@attempt_21
t=6236191 sess=G79 lvl=INFO cat=stream evt=ws_bind target_ip=resolving... target_host=stt-rt.soniox.com socket=sock_1987707318871578398@attempt_21 attempt=21 via_proxy=false path=/transcribe-websocket
🔑 Successfully connected to Soniox using temp key (6ms key latency)
t=6236192 sess=G79 lvl=INFO cat=stream evt=ws_bind_resolved target_ip=129.146.176.251 via_proxy=false attempt=21 target_host=stt-rt.soniox.com socket=sock_1987707318871578398@attempt_21 path=/transcribe-websocket
t=6237246 sess=G79 lvl=INFO cat=stream evt=ws_handshake_metrics proxy=false reused=false socket=sock_1987707318871578398@attempt_21 protocol=http/1.1 connect_ms=791 tls_ms=786 attempt=21 dns_ms=0 total_ms=1058
🔌 WebSocket did open (sid=sock_1987707318871578398, attemptId=21)
🌐 [CONNECT] Attempt #21 succeeded
📤 [START] Sent start/config on standby socket (eager mode)
t=6237247 sess=G79 lvl=INFO cat=stream evt=start_config socket=sock_1987707318871578398@attempt_21 ctx=standby_eager summary=["valid": true, "model": "stt-rt-preview-v2", "ch": 1, "json_hash": "74c88fa4ee9a34f7", "langs": 2, "ctx_len": 36, "sr": 16000, "audio_format": "pcm_s16le"] attempt=21
🧊 [STANDBY] Connected standby socket — keepalive every 10.0s, TTL=60s
📤 Sending text frame seq=49910
🔌 [READY] attemptId=21 socketId=sock_1987707318871578398@attempt_21 start_text_sent=true
🧊 [STANDBY] WebSocket ready in 1086ms (handshake)
📦 Flushing 2 buffered packets (0.0s of audio, 744 bytes)
📤 Sent buffered packet 0/2 seq=2554 size=372
📤 Sent buffered packet 1/2 seq=2555 size=372
✅ Buffer flush complete
👂 [LISTENER] Standby listener task for socketId=sock_1987707318871578398@attempt_21 attemptId=21