✅ [NER-SETUP] OCR completion callback configured for NER pre-warming - callback exists: true
🎙️ [RECORD PERMISSION DEBUG] Permission granted: true
🎙️ [RECORD PERMISSION DEBUG] Thread: <_NSMainThread: 0x600002e84040>{number = 1, name = main}
🎙️ [RECORD PERMISSION DEBUG] Time since app launch: 0.00s
🔄 [AUTH_REFRESH] Session still valid for 58 minutes
🎙️ [ASYNC TASK DEBUG] Starting async recording task...
🎙️ [ASYNC TASK DEBUG] Task thread: <_NSMainThread: 0x600002e84040>{number = 1, name = main}
🎙️ [ASYNC TASK DEBUG] Re-evaluating model for language settings...
🎙️ [ASYNC TASK DEBUG] Model type: soniox-realtime-streaming, isStreaming: true
🎙️ [SONIOX DEBUG] Starting Soniox streaming transcription...
🎙️ [SONIOX DEBUG] Calling wakeAudioSystemIfNeeded()...
🎙️ [SONIOX DEBUG] Calling sonioxStreamingService.startStreaming()...
📊 [SESSION] Starting recording session #9
✅ Selected account account-bundle (connections: 1/10)
🎬 [CAPTURE DEBUG] Starting smart screen context capture
🔍 [CALLBACK DEBUG] onOCRCompleted callback exists: true
🎯 ScreenCapture detected frontmost app: Warp (dev.warp.Warp-Stable)
🎯 Found matching window: ~/clio-project/Clio (Warp) - layer:0, pid:656
🎯 ScreenCapture found window: ~/clio-project/Clio (Warp) - matches PowerMode detection
🔄 [CACHE] Context changed - invalidating cache
🔄 [CACHE]   Old: com.apple.dt.Xcode|Clio — TempKeyCache.swift
🔄 [CACHE]   New: dev.warp.Warp-Stable|~/clio-project/Clio
🔄 [CACHE]   BundleID Match: false
🔄 [CACHE]   Title Match: false
🔄 [CACHE]   Content Hash: Old=cf35f4b2... New=cf35f4b2...
🎬 Starting screen capture with verified permissions
🚀 Starting Clio streaming transcription
🎯 ScreenCapture detected frontmost app: Warp (dev.warp.Warp-Stable)
🎯 Found matching window: ~/clio-project/Clio (Warp) - layer:0, pid:656
🎯 ScreenCapture found window: ~/clio-project/Clio (Warp) - matches PowerMode detection
🎯 Found window: ~/clio-project/Clio (Warp)
🎯 ScreenCapture detected frontmost app: Warp (dev.warp.Warp-Stable)
🎯 Found matching window: ~/clio-project/Clio (Warp) - layer:0, pid:656
🎯 ScreenCapture found window: ~/clio-project/Clio (Warp) - matches PowerMode detection
🖼️ Attempting window-specific capture for: ~/clio-project/Clio (ID: 2201)
🔊 Setting up audio engine...
✅ Successfully captured window: 3840.000000x2110.000000
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
⏱️ [TIMING] mic_engaged @ 1755327592.630
⏱️ [TIMING] WebSocket connection established - flushing buffered audio
pass
🔍 [DYNAMIC NOTCH DEBUG] Showed notch in compact mode
✅ [AUDIO HEALTH] First audio data received - tap is functional
🌐 [PATH] Network path changed (status=satisfied) – triggering recovery
⏹️ Keepalive timer stopped
🔌 [WS] Disconnected (socketId=sock_-5399504320679147753@attempt_33)
⚠️ WebSocket did close with code 1001 (sid=sock_-5399504320679147753, attemptId=33)
🔄 [RECOVERY] Attempting mid-recording recovery
⏹️ Keepalive timer stopped
🔌 [WS] Disconnected (socketId=)
🌐 [CONNECT] Attempt #34 (loop 1/3) starting…
⚡ [CACHE-HIT] Retrieved temp key in 0.1ms
⏱️ [TIMING] Temp key obtained in 0.1ms
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🔊 [SONIOX DEBUG] Full config: enable_endpoint_detection=true, model=stt-rt-preview-v2, language_hints=Optional(["zh", "en"])
🌐 [WS CONNECT] Using URL: wss://stt-rt.soniox.com/transcribe-websocket
🔗 [WS] Bound socket id=sock_-5640287119461833844@attempt_34
🔑 Successfully connected to Soniox using temp key (0ms key latency)
🌐 [CONNECT] New single-flight request from sendFailure
🌐 [CONNECT] Attempt #35 (loop 1/3) starting…
🌐 [CONNECT] Attempt #35 failed: URL session not configured
⚠️ WebSocket connect failed (attempt 1). Retrying in 500ms…
⚡ [CACHE-HIT] Retrieved temp key in 0.0ms
⏱️ [TIMING] Temp key obtained in 0.1ms
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🔊 [SONIOX DEBUG] Full config: enable_endpoint_detection=true, model=stt-rt-preview-v2, language_hints=Optional(["en", "zh"])
🌐 [WS CONNECT] Using URL: wss://stt-rt.soniox.com/transcribe-websocket
🔗 [WS] Bound socket id=sock_-6978804373839925711@attempt_35
🔑 Successfully connected to Soniox using temp key (0ms key latency)
⏳ [CONNECT-TIMEOUT] Readiness not signaled within 12s — aborting connect (attempt=34)
⏹️ Keepalive timer stopped
🔌 [WS] Disconnected (socketId=sock_-6978804373839925711@attempt_35)
🌐 [CONNECT] Attempt #35 failed: URL session not configured
⚠️ WebSocket connect failed (attempt 1). Retrying in 500ms…
🔍 Found 67 text observations
✅ Text extraction successful: 3083 chars, 3083 non-whitespace, 399 words from 67 observations
✅ Captured text successfully
✅ [CAPTURE DEBUG] Screen capture successful: 3152 characters
🎯 ScreenCapture detected frontmost app: Warp (dev.warp.Warp-Stable)
🎯 Found matching window: ~/clio-project/Clio (Warp) - layer:0, pid:656
🎯 ScreenCapture found window: ~/clio-project/Clio (Warp) - matches PowerMode detection
💾 [SMART-CACHE] Cached new context: dev.warp.Warp-Stable|~/clio-project/Clio (3152 chars)
🎯 [CALLBACK DEBUG] Executing callback with fresh content (3152 chars)
🔥 [NER-TRIGGER] OCR completion callback triggered with fresh content
🔥 [NER-PREWARM] Triggering NER pre-warming with OCR text (3152 chars)
🔥 [PREWARM DEBUG] prewarmConnection() called - isEnhancementEnabled: true, isConfigured: true
🔥 [PREWARM DEBUG] connectionState: cold
🔥 [PREWARM DEBUG] Pre-warming AI connection (target: Gemini), environment: flyio
🛩️ [FLY.IO PREWARM] Starting Fly.io NER pre-warming (forced refresh)
🛩️ [FLY.IO-NER] sendFlyioWarmingRequest() called - starting NER processing (Gemini warmup)
🎬 [NER-PREWARM] Using raw OCR text for NER: 3152 characters
🛩️ [FLY.IO-NER] OCR text retrieved for NER processing: 3152 characters
🧠 [NER-DEFAULT] Using default NER prompt for general extraction
🌐 [CONNECT] Attempt #36 (loop 2/3) starting…
⚡ [CACHE-HIT] Retrieved temp key in 0.2ms
⏱️ [TIMING] Temp key obtained in 0.6ms
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🔊 [SONIOX DEBUG] Full config: enable_endpoint_detection=true, model=stt-rt-preview-v2, language_hints=Optional(["en", "zh"])
🌐 [WS CONNECT] Using URL: wss://stt-rt.soniox.com/transcribe-websocket
🔗 [WS] Bound socket id=sock_-13187194349602552@attempt_36
🔑 Successfully connected to Soniox using temp key (1ms key latency)
🌐 [CONNECT] Attempt #37 (loop 2/3) starting…
🌐 [CONNECT] Attempt #37 failed: URL session not configured
⚠️ WebSocket connect failed (attempt 2). Retrying in 1000ms…
⚡ [CACHE-HIT] Retrieved temp key in 0.2ms
⏱️ [TIMING] Temp key obtained in 0.5ms
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🔊 [SONIOX DEBUG] Full config: enable_endpoint_detection=true, model=stt-rt-preview-v2, language_hints=Optional(["en", "zh"])
🌐 [WS CONNECT] Using URL: wss://stt-rt.soniox.com/transcribe-websocket
🔗 [WS] Bound socket id=sock_7113200048990540914@attempt_37
🔑 Successfully connected to Soniox using temp key (0ms key latency)
⏳ [CONNECT-TIMEOUT] Readiness not signaled within 12s — aborting connect (attempt=36)
⏹️ Keepalive timer stopped
🔌 [WS] Disconnected (socketId=sock_7113200048990540914@attempt_37)
🌐 [CONNECT] Attempt #37 failed: URL session not configured
⚠️ WebSocket connect failed (attempt 2). Retrying in 1000ms…
🤖 [FLY.IO-NER] Server-reported provider: gemini
📥 [NER-STORE] Stored NER entities: 116 chars - **People:**
* Agent

**Organizations:**
* Peak XV

**Products:**
* Clio
* Warp
* GPT-5

**Projects:*...
🛩️ [FLY.IO-NER] Pre-warming completed in 965ms - NER entities extracted
✅ [FLY.IO] NER refresh completed successfully
🔌 WebSocket did open (sid=sock_-5640287119461833844, attemptId=37)
ℹ️ didOpen for stale socket – ignoring and canceling stale task
⚠️ WebSocket did close with code 1001 (sid=sock_-5640287119461833844, attemptId=37)
🔄 [RECOVERY] Attempting mid-recording recovery
⏹️ Keepalive timer stopped
🔌 [WS] Disconnected (socketId=)
🌐 [CONNECT] Attempt #38 (loop 3/3) starting…
⚡ [CACHE-HIT] Retrieved temp key in 0.2ms
⏱️ [TIMING] Temp key obtained in 0.5ms
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🔊 [SONIOX DEBUG] Full config: enable_endpoint_detection=true, model=stt-rt-preview-v2, language_hints=Optional(["zh", "en"])
🌐 [WS CONNECT] Using URL: wss://stt-rt.soniox.com/transcribe-websocket
🔗 [WS] Bound socket id=sock_-4968803089378212867@attempt_38
🔑 Successfully connected to Soniox using temp key (1ms key latency)
🔁 [CONNECT] Coalesced request from sendFailure onto in-flight attempt #38
🌐 [CONNECT] Attempt #39 (loop 3/3) starting…
🌐 [CONNECT] Attempt #39 failed: URL session not configured
❌ WebSocket connection failed after 3 attempts: URL session not configured
❌ Path-change recovery failed: URL session not configured
🛑 Stopping Clio streaming transcription
🏥 [AUDIO HEALTH] Health monitoring timer stopped
⏳ WebSocket not ready yet - waiting up to 10 seconds to avoid losing audio
⚡ [CACHE-HIT] Retrieved temp key in 0.2ms
⏱️ [TIMING] Temp key obtained in 0.5ms
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🔊 [SONIOX DEBUG] Full config: enable_endpoint_detection=true, model=stt-rt-preview-v2, language_hints=Optional(["zh", "en"])
🌐 [WS CONNECT] Using URL: wss://stt-rt.soniox.com/transcribe-websocket
🔗 [WS] Bound socket id=sock_7962686050539553937@attempt_39
🔑 Successfully connected to Soniox using temp key (1ms key latency)
⏳ [CONNECT-TIMEOUT] Readiness not signaled within 12s — aborting connect (attempt=38)
⏹️ Keepalive timer stopped
🔌 [WS] Disconnected (socketId=sock_7962686050539553937@attempt_39)
🌐 [CONNECT] Attempt #39 failed: URL session not configured
❌ WebSocket connection failed after 3 attempts: URL session not configured
❌ Recovery connect failed: URL session not configured
❌ Recovery connect failed: URL session not configured
🔌 WebSocket did open (sid=sock_-13187194349602552, attemptId=39)
ℹ️ didOpen for stale socket – ignoring and canceling stale task
⚠️ WebSocket did close with code 1001 (sid=sock_-13187194349602552, attemptId=39)
🔄 [RECOVERY] Attempting mid-recording recovery
⏹️ Keepalive timer stopped
🔌 [WS] Disconnected (socketId=)
🌐 [CONNECT] New single-flight request from sendFailure
🌐 [CONNECT] Attempt #40 (loop 1/3) starting…
⚡ [CACHE-HIT] Retrieved temp key in 0.2ms
⏱️ [TIMING] Temp key obtained in 0.5ms
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🔊 [SONIOX DEBUG] Full config: enable_endpoint_detection=true, model=stt-rt-preview-v2, language_hints=Optional(["zh", "en"])
🌐 [WS CONNECT] Using URL: wss://stt-rt.soniox.com/transcribe-websocket
🔗 [WS] Bound socket id=sock_-5162069232765121207@attempt_40
🔑 Successfully connected to Soniox using temp key (1ms key latency)
🔌 WebSocket did open (sid=sock_-4968803089378212867, attemptId=40)
ℹ️ didOpen for stale socket – ignoring and canceling stale task
⚠️ WebSocket did close with code 1001 (sid=sock_-4968803089378212867, attemptId=40)
🔄 [RECOVERY] Attempting mid-recording recovery
⏹️ Keepalive timer stopped
🌐 [CONNECT] Attempt #40 failed: URL session not configured
⚠️ WebSocket connect failed (attempt 1). Retrying in 500ms…
🔌 [WS] Disconnected (socketId=sock_-5162069232765121207@attempt_40)
🔁 [CONNECT] Coalesced request from sendFailure onto in-flight attempt #40
🌐 [CONNECT] Attempt #41 (loop 2/3) starting…
⚡ [CACHE-HIT] Retrieved temp key in 0.1ms
⏱️ [TIMING] Temp key obtained in 0.3ms
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🔊 [SONIOX DEBUG] Full config: enable_endpoint_detection=true, model=stt-rt-preview-v2, language_hints=Optional(["en", "zh"])
🌐 [WS CONNECT] Using URL: wss://stt-rt.soniox.com/transcribe-websocket
🔗 [WS] Bound socket id=sock_-4516082040875666018@attempt_41
🔑 Successfully connected to Soniox using temp key (0ms key latency)
📦 Buffer growing: 50 packets (160000 bytes)
🔌 WebSocket did open (sid=sock_-4516082040875666018, attemptId=41)
🌐 [CONNECT] Attempt #41 succeeded
📤 [START] Sent start/config text frame (attemptId=41, socketId=sock_-4516082040875666018@attempt_41, start_text_sent=true)
🔌 [READY] attemptId=41 socketId=sock_-4516082040875666018@attempt_41 start_text_sent=true
🔌 WebSocket ready after 5776ms - buffered 5.1s of audio
🌐 SLOW CONNECTION: 5.8s (possibly VPN-related)
📦 Flushing 51 buffered packets (5.1s of audio, 163200 bytes)
📤 Sent buffered packet 0/51 seq=5 size=3200
📤 Sending text frame seq=0
📤 Sent buffered packet 50/51 seq=55 size=3200
✅ Buffer flush complete
⏹️ Keepalive timer stopped
🔄 Keepalive timer started (interval: 15.000000s)
👂 [LISTENER] Starting listener task for socketId=sock_-4516082040875666018@attempt_41 attemptId=41
✅ WebSocket became ready after 3341ms - proceeding with finalization
✅ [TAP CLEANUP] Successfully removed tap during stop
📤 Sent end-of-stream signal
📤 Sent manual finalize command
🕐 Using finalization timeout: 2000ms (connection took 5944ms)
🏁 Received <fin> token - finalization complete
✅ Received <fin> token after 870ms
⏹️ Keepalive timer stopped
📉 Released connection for account account-bundle (connections: 0)
💾 [COLD-START] Updated successful streaming timestamp
✅ Streaming stopped. Final transcript (35 chars, 6.8s, with audio file): "Stagnant robust retry or something?"