Problems I'm seeing in this log: one is losing connections halfway. And the other one is not capturing the first bit of audio. Um, like, I thought we buffer everything and then we--so before WebSocket's ready, I tho ught we buffer everything, and when it connects, we send everything to it. Is it--are we not doing this anymore? What's happening?

🔄 Handling audio device change
✅ Device change handling completed
🔍 [DYNAMIC NOTCH SIZE] Using built-in screen notch size: (185.0, 32.0)
🔍 [DYNAMIC NOTCH SIZE] Using built-in screen notch size: (185.0, 32.0)
🔍 [DYNAMIC NOTCH SIZE] Using built-in screen notch size: (185.0, 32.0)
🔥 [WARMUP] ensureReady() invoked context=reachabilityChange
🔥 [SYSTEM-WARMUP] TempKeyCache warmup integration
🚀 [PREFETCH] Starting background temp key prefetch
🌐 [ASR BREAKDOWN] Total: 1562ms | Client↔Proxy: 722ms | Proxy↔Soniox: 840ms | Network: 839ms
🗑️ Evicted oldest temp key to maintain cache size limit
💾 Cached temp key for languages: ["en", "zh"]
🗓️ [TTL-SCHEDULE] Scheduling temp key refresh for key=global in 3000s (expiresAt=2025-08-21 01:24:21 +0000)
✅ [PREFETCH] Successfully prefetched temp key
🔄 [AUTH_REFRESH] Session still valid for 30 minutes
🔄 [SYNC_STATE] syncTrialState called - currentTier: pro, isInTrial: true
🔒 [INVARIANT] Paid entitlement detected → forcing isInTrial = false
🔄 [SYNC_STATE] Final state after syncTrialState - currentTier: pro, isInTrial: false
🔥 [SYSTEM-WARMUP] Skipping warmup - recent warmup detected
🔥 [WARMUP] ensureReady() invoked context=reachabilityChange
🔥 [SYSTEM-WARMUP] TempKeyCache warmup integration
🚀 [PREFETCH] Starting background temp key prefetch
🌐 [ASR BREAKDOWN] Total: 1698ms | Client↔Proxy: 759ms | Proxy↔Soniox: 939ms | Network: 938ms
🗑️ Evicted oldest temp key to maintain cache size limit
💾 Cached temp key for languages: ["en", "zh"]
🗓️ [TTL-SCHEDULE] Scheduling temp key refresh for key=global in 3000s (expiresAt=2025-08-21 01:29:21 +0000)
✅ [PREFETCH] Successfully prefetched temp key
🎯 [STATE MACHINE] Event: keyDown in state: idle
🎯 [STATE MACHINE] Commands: ["showLightweightUI", "playSoundDelayed(Clio.SoundType.keyDown, delay: 0.06)", "schedulePromotion(delay: 0.3)", "scheduleMisTouchHide(delay: 0.4)", "updateUI(Clio.RecorderViewModel(isRecording: false, isHandsFreeLocked: false, isAttemptingToRecord: true, isVisualizerActive: true, sessionStateDescription: \"showing lightweight\", canTranscribe: true))"]
📱 Showing DynamicNotch recorder (MIT licensed)
🔍 [DYNAMIC NOTCH DEBUG] Showing notch...
🔍 [DYNAMIC NOTCH DEBUG] Using screen under mouse (preserving mouse-following)
🔍 [DYNAMIC NOTCH SIZE] Using built-in screen notch size: (185.0, 32.0)
🔥 [WARMUP] ensureReady() invoked context=recorderUIShown
🔥 [SYSTEM-WARMUP] TempKeyCache warmup integration
🚀 [PREFETCH] Starting background temp key prefetch
🎯 [STATE MACHINE] Event: keyDown in state: lightweightShown(since: 2025-08-21 00:31:07 +0000)
🎯 [STATE MACHINE] Commands: ["cancelTimers", "startRecording(mode: Clio.RecorderMode.handsFreeLocked)", "playSound(Clio.SoundType.lock)", "updateUI(Clio.RecorderViewModel(isRecording: true, isHandsFreeLocked: true, isAttemptingToRecord: false, isVisualizerActive: true, sessionStateDescription: \"recording hands-free\", canTranscribe: true))"]
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
🎙️ [RECORD PERMISSION DEBUG] Thread: <_NSMainThread: 0x600003a78800>{number = 1, name = main}
🎙️ [RECORD PERMISSION DEBUG] Time since app launch: 0.00s
🔄 Background token refresh completed
🔄 Background token refresh completed
🔄 [AUTH_REFRESH] Session still valid for 28 minutes
🎙️ [ASYNC TASK DEBUG] Starting async recording task...
🎙️ [ASYNC TASK DEBUG] Task thread: <_NSMainThread: 0x600003a78800>{number = 1, name = main}
🎙️ [ASYNC TASK DEBUG] Re-evaluating model for language settings...
🎙️ [ASYNC TASK DEBUG] Model type: soniox-realtime-streaming, isStreaming: true
🎙️ [SONIOX DEBUG] Starting Soniox streaming transcription...
🎙️ [SONIOX DEBUG] Calling wakeAudioSystemIfNeeded()...
🔊 Waking up audio system after 28764s idle time
🎬 [CAPTURE DEBUG] Starting smart screen context capture
🔍 [CALLBACK DEBUG] onOCRCompleted callback exists: true
⏰ [CACHE] Cache is stale (age: 28781.8s, ttl=120s)
🎬 Starting screen capture with verified permissions
🎯 ScreenCapture detected frontmost app: Warp (dev.warp.Warp-Stable)
🎯 Found matching window: ~/clio-project/Clio (Warp) - layer:0, pid:642
🎯 ScreenCapture found window: ~/clio-project/Clio (Warp) - matches Context Preset detection
🎯 Found window: ~/clio-project/Clio (Warp)
🎯 ScreenCapture detected frontmost app: Warp (dev.warp.Warp-Stable)
🎯 Found matching window: ~/clio-project/Clio (Warp) - layer:0, pid:642
🎯 ScreenCapture found window: ~/clio-project/Clio (Warp) - matches Context Preset detection
🖼️ Attempting window-specific capture for: ~/clio-project/Clio (ID: 61)
✅ Successfully captured window: 3840.000000x2110.000000
🌐 [LANG DEBUG] Multi-language setting exists: true, Single language: en
🌐 [LANG DEBUG] Using multi-language selection (prioritized): zh, en
🌐 [OCR DEBUG] Selected languages from settings: en, zh
🌐 [OCR DEBUG] User selection mode - prioritizing non-English: zh-Hans, en-US
🌐 Using selected languages for OCR: zh-Hans, en-US
🎙️ [SONIOX DEBUG] Calling sonioxStreamingService.startStreaming()...
📊 [SESSION] Starting recording session #4
t=28910741 sess=8Hv lvl=INFO cat=audio evt=session_backend backend=avcapture
t=28910741 sess=8Hv lvl=INFO cat=audio evt=compat_state enabled=true
🎤 Registering audio tap for Soniox
t=28910742 sess=8Hv lvl=INFO cat=audio evt=record_start service=Soniox
🔍 Performing audio system pre-flight checks
throwing -10877
throwing -10877
✅ Pre-flight checks passed
t=28910841 sess=8Hv lvl=INFO cat=audio evt=tap_install backend=avcapture ok=true service=Soniox
🎬 Starting unified audio capture
t=28910842 sess=8Hv lvl=INFO cat=audio evt=record_start reason=start_capture
t=28910842 sess=8Hv lvl=INFO cat=audio evt=device_pin_start desired_uid_hash=3440565358075929298 prev_name="MacBook Pro Microphone" prev_id=140 desired_name="MacBook Pro Microphone" prev_uid_hash=3440565358075929298 desired_id=140
❄️ Cold start detected - performing full initialization
❄️ Performing cold start initialization
⏭️ Skipping engine cold start (backend=AVCapture)
t=28910842 sess=8Hv lvl=INFO cat=audio evt=capture_backend_selected backend=avcapture
✅ Unified audio capture started
✅ Selected account account-bundle (connections: 1/10)
🔍 [DYNAMIC NOTCH DEBUG] Showed notch in compact mode
🚀 Starting Clio streaming transcription
t=28910848 sess=8Hv lvl=INFO cat=transcript evt=session_start divider="────────── session start ──────────"
⚡ [CACHE-HIT] Retrieved temp key in 4.5ms
🚀 [WARM-REUSE] Reusing READY socket — sent START without reconnect (socketId=sock_-5032499713381520610@attempt_4)
t=28910865 sess=8Hv lvl=INFO cat=stream evt=warm_reuse socket=sock_-5032499713381520610@attempt_4 reused=true
⏹️ Keepalive timer stopped
🔄 Keepalive timer started (interval: 15.000000s)
👂 [LISTENER] Starting listener task for socketId=sock_-5032499713381520610@attempt_4 attemptId=4
nw_read_request_report [C16] Receive failed with error "Socket is not connected"
nw_flow_service_reads [C16 129.146.176.251:443 failed parent-flow (satisfied (Path is satisfied), interface: utun4, ipv4, dns, uses wifi)] No output handler
🏥 [AUDIO HEALTH] Health monitoring timer started
🎙️ [SONIOX DEBUG] Soniox streaming started successfully!
⏱️ [TIMING] mic_engaged @ 1755736268.296
❌ WebSocket receive error: The operation couldn’t be completed. Socket is not connected
🔄 Connection reset during recording - attempting recovery
🔄 [RECOVERY] Attempting mid-recording recovery
⚡ [WARM-REUSE] Skipping connect — socket already READY
pass
⏹️ Keepalive timer stopped
🔍 [DYNAMIC NOTCH DEBUG] Already visible, skipping show()
🔌 [WS] Disconnected (socketId=sock_-5032499713381520610@attempt_4)
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
t=28910942 sess=8Hv lvl=INFO cat=audio evt=avcapture_start ok=true
t=28910943 sess=8Hv lvl=INFO cat=audio evt=first_buffer
✅ [AUDIO HEALTH] First audio data received - tap is functional
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
throwing -10877
throwing -10877
🌐 [CONNECT] New single-flight request from sendFailure
🌐 [CONNECT] Attempt #5 (loop 1/3) starting…
🌐 [PATH SNAPSHOT] status=unsatisfied iface=[] constrained=false expensive=false ipv4=false ipv6=false vpnLikely=false
⚡ [CACHE-HIT] Retrieved temp key in 0.3ms
⏱️ [TIMING] Temp key obtained in 0.4ms
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🔊 [SONIOX DEBUG] Full config: enable_endpoint_detection=true, model=stt-rt-preview-v2, language_hints=Optional(["zh", "en"])
🌐 [WS CONNECT] Using URL: wss://stt-rt.soniox.com/transcribe-websocket
🔗 [WS] Bound socket id=sock_-6043523738306579213@attempt_5
t=28911215 sess=8Hv lvl=INFO cat=stream evt=ws_bind socket=sock_-6043523738306579213@attempt_5
🔑 Successfully connected to Soniox using temp key (0ms key latency)
🌐 [ASR BREAKDOWN] Total: 908ms | Client↔Proxy: 83ms | Proxy↔Soniox: 825ms | Network: 825ms
🗑️ Evicted oldest temp key to maintain cache size limit
💾 Cached temp key for languages: ["en", "zh"]
🗓️ [TTL-SCHEDULE] Scheduling temp key refresh for key=global in 3000s (expiresAt=2025-08-21 01:31:08 +0000)
✅ [PREFETCH] Successfully prefetched temp key
🌐 [PATH] Network path changed (status=satisfied) – triggering recovery
🌐 [PATH] Change detected but isConnecting=true — skipping recovery
🔍 Found 62 text observations
✅ Text extraction successful: 2682 chars, 2682 non-whitespace, 323 words from 62 observations
✅ Captured text successfully
✅ [CAPTURE DEBUG] Screen capture successful: 2751 characters
🎯 ScreenCapture detected frontmost app: Warp (dev.warp.Warp-Stable)
🎯 Found matching window: ~/clio-project/Clio (Warp) - layer:0, pid:642
🎯 ScreenCapture found window: ~/clio-project/Clio (Warp) - matches Context Preset detection
💾 [SMART-CACHE] Cached new context: dev.warp.Warp-Stable|~/clio-project/Clio (2751 chars)
🎯 [CALLBACK DEBUG] Executing callback with fresh content (2751 chars)
🔥 [NER-TRIGGER] OCR completion callback triggered with fresh content
🔥 [NER-PREWARM] Triggering NER pre-warming with OCR text (2751 chars)
🔥 [PREWARM DEBUG] prewarmConnection() called - isEnhancementEnabled: true, isConfigured: true
🔥 [PREWARM DEBUG] connectionState: cold
🔥 [PREWARM DEBUG] Pre-warming AI connection (target: Gemini), environment: flyio
🛩️ [FLY.IO PREWARM] Starting Fly.io NER pre-warming (forced refresh)
🛩️ [FLY.IO-NER] sendFlyioWarmingRequest() called - starting NER processing (Gemini warmup)
🎬 [NER-PREWARM] Using raw OCR text for NER: 2751 characters
🛩️ [FLY.IO-NER] OCR text retrieved for NER processing: 2751 characters
🧠 [NER-DEFAULT] Using default NER prompt for general extraction
🔌 WebSocket did open (sid=sock_-6043523738306579213, attemptId=5)
🌐 [CONNECT] Attempt #5 succeeded
📤 [START] Sent start/config text frame (attemptId=5, socketId=sock_-6043523738306579213@attempt_5, start_text_sent=true)
t=28912654 sess=8Hv lvl=INFO cat=stream evt=start_sent attempt=5
🔌 [READY] attemptId=5 socketId=sock_-6043523738306579213@attempt_5 start_text_sent=true
t=28912654 sess=8Hv lvl=INFO cat=stream evt=ready socket=sock_-6043523738306579213@attempt_5 attempt=5
🔌 WebSocket ready after 1798ms - buffered 1.7s of audio
📦 Flushing 149 buffered packets (1.7s of audio, 55404 bytes)
📤 Sending text frame seq=7345
📤 Sending text frame seq=7344
📤 Sent buffered packet 0/149 seq=0 size=372
📤 Sending audio packet seq=7400 size=372
📤 Sent buffered packet 148/149 seq=148 size=372
📦 Flushing 4 additional packets that arrived during flush
✅ Buffer flush complete
⏹️ Keepalive timer stopped
🔄 Keepalive timer started (interval: 15.000000s)
👂 [LISTENER] Starting listener task for socketId=sock_-6043523738306579213@attempt_5 attemptId=5
📤 Sending audio packet seq=7500 size=372
🤖 [FLY.IO-NER] Server-reported provider: gemini
📥 [NER-STORE] Stored NER entities: 242 chars - *   **Clio** (Project)
*   **SonioxStreamingService** (Class/Service)
*   **SonioxConnectionManager*...
🛩️ [FLY.IO-NER] Pre-warming completed in 1047ms - NER entities extracted
✅ [FLY.IO] NER refresh completed successfully
❌ Clio API Error: 400 - Control request invalid type.
nw_read_request_report [C169] Receive failed with error "Socket is not connected"
nw_flow_service_reads [C169 129.146.176.251:443 failed parent-flow (satisfied (Path is satisfied), interface: utun4, ipv4, dns, uses wifi)] No output handler
nw_flow_add_write_request [C169 129.146.176.251:443 failed parent-flow (satisfied (Path is satisfied), interface: utun4, ipv4, dns, uses wifi)] cannot accept write requests
nw_write_request_report [C169] Send failed with error "Socket is not connected"
Connection 169: received failure notification
⚠️ WebSocket did close with code 1000 (sid=sock_-6043523738306579213, attemptId=5)
nw_flow_add_write_request [C169 129.146.176.251:443 failed parent-flow (satisfied (Path is satisfied), interface: utun4, ipv4, dns, uses wifi)] cannot accept write requests
❌ WebSocket receive error: The operation couldn’t be completed. Socket is not connected
nw_write_request_report [C169] Send failed with error "Socket is not connected"
🔄 Connection reset during recording - attempting recovery
🔄 [RECOVERY] Attempting mid-recording recovery
t=28913092 sess=8Hv lvl=WARN cat=stream evt=state code=1000 state=closed
⏹️ Keepalive timer stopped
❌ Failed to send frame seq=7532: The operation couldn’t be completed. Socket is not connected
t=28913093 sess=8Hv lvl=ERR cat=stream evt=error phase=send seq=7532
🚑 Re-queueing failed packet seq=7532 requeue=true queue_len=1
❌ Send path reported failure: The operation couldn’t be completed. Socket is not connected
🔄 [RECOVERY] Attempting mid-recording recovery
🔌 [WS] Disconnected (socketId=sock_-6043523738306579213@attempt_5)
🚑 [RECOVERY] Recovering from send failure: The operation couldn’t be completed. Socket is not connected
⏹️ Keepalive timer stopped
⏹️ Keepalive timer stopped
🔌 [WS] Disconnected (socketId=)
🔌 [WS] Disconnected (socketId=)
🌐 [CONNECT] New single-flight request from sendFailure
🌐 [CONNECT] Attempt #6 (loop 1/3) starting…
🌐 [PATH SNAPSHOT] status=unsatisfied iface=[] constrained=false expensive=false ipv4=false ipv6=false vpnLikely=false
⚡ [CACHE-HIT] Retrieved temp key in 0.1ms
⏱️ [TIMING] Temp key obtained in 0.4ms
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🔊 [SONIOX DEBUG] Full config: enable_endpoint_detection=true, model=stt-rt-preview-v2, language_hints=Optional(["zh", "en"])
🌐 [WS CONNECT] Using URL: wss://stt-rt.soniox.com/transcribe-websocket
🔗 [WS] Bound socket id=sock_-4194057072685975005@attempt_6
t=28913329 sess=8Hv lvl=INFO cat=stream evt=ws_bind socket=sock_-4194057072685975005@attempt_6
🔑 Successfully connected to Soniox using temp key (0ms key latency)
🔁 [CONNECT] Coalesced request from sendFailure onto in-flight attempt #6
🔁 [CONNECT] Coalesced request from sendFailure onto in-flight attempt #6
🔌 WebSocket did open (sid=sock_-4194057072685975005, attemptId=6)
🌐 [CONNECT] Attempt #6 succeeded
📤 [START] Sent start/config text frame (attemptId=6, socketId=sock_-4194057072685975005@attempt_6, start_text_sent=true)
t=28914803 sess=8Hv lvl=INFO cat=stream evt=start_sent attempt=6
🔌 [READY] attemptId=6 socketId=sock_-4194057072685975005@attempt_6 start_text_sent=true
t=28914804 sess=8Hv lvl=INFO cat=stream evt=ready socket=sock_-4194057072685975005@attempt_6 attempt=6
🔌 WebSocket ready after 3948ms - buffered 1.7s of audio
📦 Flushing 147 buffered packets (1.7s of audio, 54684 bytes)
📤 Sending text frame seq=7533
📤 Sent buffered packet 0/147 seq=187 size=372
📤 Sending audio packet seq=7600 size=372
📤 Sent buffered packet 146/147 seq=333 size=372
📦 Flushing 5 additional packets that arrived during flush
✅ Buffer flush complete
⏹️ Keepalive timer stopped
🔄 Keepalive timer started (interval: 15.000000s)
👂 [LISTENER] Starting listener task for socketId=sock_-4194057072685975005@attempt_6 attemptId=6
📤 Sending audio packet seq=7700 size=372
throwing -10877
throwing -10877
📤 Sending audio packet seq=7800 size=372
📤 Sending audio packet seq=7900 size=372
t=28918128 sess=8Hv lvl=INFO cat=transcript evt=raw_final text="Warmup probe writer and the transcription buffer, right?<end>"
📤 Sending audio packet seq=8000 size=372
📤 Sending audio packet seq=8100 size=372
📤 Sending audio packet seq=8200 size=372
throwing -10877
throwing -10877
📤 Sending audio packet seq=8300 size=372
📤 Sending audio packet seq=8400 size=372
📤 Sending audio packet seq=8500 size=372
📤 Sending audio packet seq=8600 size=372
throwing -10877
throwing -10877
📤 Sending audio packet seq=8700 size=372
📤 Sending audio packet seq=8800 size=372
📤 Sending audio packet seq=8900 size=372
💓 Sent keepalive message
📤 Sending audio packet seq=9000 size=372
throwing -10877
throwing -10877
📤 Sending audio packet seq=9100 size=372
📤 Sending audio packet seq=9200 size=372
📤 Sending audio packet seq=9300 size=372
📤 Sending audio packet seq=9400 size=372
throwing -10877
throwing -10877
📤 Sending audio packet seq=9500 size=372
📤 Sending audio packet seq=9600 size=372
throwing -10877
Connection 170: received failure notification
nw_flow_add_write_request [C170 129.146.176.251:443 failed parent-flow (satisfied (Path is satisfied), interface: utun4, ipv4, dns, uses wifi)] cannot accept write requests
throwing -10877
nw_write_request_report [C170] Send failed with error "Socket is not connected"
❌ Failed to send frame seq=9600: The operation couldn’t be completed. Socket is not connected
nw_flow_add_write_request [C170 129.146.176.251:443 failed parent-flow (satisfied (Path is satisfied), interface: utun4, ipv4, dns, uses wifi)] cannot accept write requests
nw_write_request_report [C170] Send failed with error "Socket is not connected"
t=28960485 sess=8Hv lvl=ERR cat=stream evt=error phase=send seq=9600
🚑 Re-queueing failed packet seq=9600 requeue=true queue_len=329
❌ Send path reported failure: The operation couldn’t be completed. Socket is not connected
Task <38848B13-A2DD-4D3E-AB6F-7071933D63B2>.<5> finished with error [57] Error Domain=NSPOSIXErrorDomain Code=57 "Socket is not connected" UserInfo={NSDescription=Socket is not connected, _NSURLErrorRelatedURLSessionTaskErrorKey=(
    "LocalWebSocketTask <38848B13-A2DD-4D3E-AB6F-7071933D63B2>.<5>"
), _NSURLErrorFailingURLSessionTaskErrorKey=LocalWebSocketTask <38848B13-A2DD-4D3E-AB6F-7071933D63B2>.<5>}
⏳ [POST-FIN] Ignoring late 408 timeout after finalize/shutdown
🚑 [RECOVERY] Recovering from send failure: The operation couldn’t be completed. Socket is not connected
❌ WebSocket receive error: The operation couldn’t be completed. Socket is not connected
🔄 Connection reset during recording - attempting recovery
🔄 [RECOVERY] Attempting mid-recording recovery
⏹️ Keepalive timer stopped
⏹️ Keepalive timer stopped
🔌 [WS] Disconnected (socketId=sock_-4194057072685975005@attempt_6)
🔌 [WS] Disconnected (socketId=)
throwing -10877
throwing -10877
throwing -10877
throwing -10877
🌐 [CONNECT] New single-flight request from sendFailure
🌐 [CONNECT] Attempt #7 (loop 1/3) starting…
🌐 [PATH SNAPSHOT] status=unsatisfied iface=[] constrained=false expensive=false ipv4=false ipv6=false vpnLikely=false
⚡ [CACHE-HIT] Retrieved temp key in 0.0ms
⏱️ [TIMING] Temp key obtained in 0.1ms
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🔊 [SONIOX DEBUG] Full config: enable_endpoint_detection=true, model=stt-rt-preview-v2, language_hints=Optional(["zh", "en"])
🌐 [WS CONNECT] Using URL: wss://stt-rt.soniox.com/transcribe-websocket
🔗 [WS] Bound socket id=sock_4703576088802985178@attempt_7
t=28961004 sess=8Hv lvl=INFO cat=stream evt=ws_bind socket=sock_4703576088802985178@attempt_7
🔑 Successfully connected to Soniox using temp key (0ms key latency)
🔁 [CONNECT] Coalesced request from sendFailure onto in-flight attempt #7
🔌 WebSocket did open (sid=sock_4703576088802985178, attemptId=7)
🌐 [CONNECT] Attempt #7 succeeded
📤 [START] Sent start/config text frame (attemptId=7, socketId=sock_4703576088802985178@attempt_7, start_text_sent=true)
t=28962475 sess=8Hv lvl=INFO cat=stream evt=start_sent attempt=7
🔌 [READY] attemptId=7 socketId=sock_4703576088802985178@attempt_7 start_text_sent=true
t=28962475 sess=8Hv lvl=INFO cat=stream evt=ready socket=sock_4703576088802985178@attempt_7 attempt=7
🔌 WebSocket ready after 51620ms - buffered 2.0s of audio
⚠️ ABNORMAL DELAY: WebSocket took 51.6s to connect!
⚠️ This may indicate VPN instability or network issues.
📦 Flushing 171 buffered packets (2.0s of audio, 63612 bytes)
t=28962476 sess=8Hv lvl=WARN cat=stream evt=backpressure queue=2018
📤 Sending text frame seq=11616
📤 Sent buffered packet 0/171 seq=4269 size=372
📤 Sending audio packet seq=9600 size=372
📤 Sent buffered packet 170/171 seq=4439 size=372
📦 Flushing 3 additional packets that arrived during flush
✅ Buffer flush complete
⏹️ Keepalive timer stopped
🔄 Keepalive timer started (interval: 15.000000s)
👂 [LISTENER] Starting listener task for socketId=sock_4703576088802985178@attempt_7 attemptId=7
📤 Sending audio packet seq=9700 size=372
📤 Sending audio packet seq=9800 size=372
📤 Sending audio packet seq=9900 size=372
📤 Sending audio packet seq=10000 size=372
📤 Sending audio packet seq=10100 size=372
throwing -10877
throwing -10877
📤 Sending audio packet seq=10200 size=372
📤 Sending audio packet seq=10300 size=372
📤 Sending audio packet seq=10400 size=372
📤 Sending audio packet seq=10500 size=372
📤 Sending audio packet seq=10600 size=372
📤 Sending audio packet seq=10700 size=372
📤 Sending audio packet seq=10800 size=372
📤 Sending audio packet seq=10900 size=372
throwing -10877
throwing -10877
📤 Sending audio packet seq=11000 size=372
📤 Sending audio packet seq=11100 size=372
📤 Sending audio packet seq=11200 size=372
📤 Sending audio packet seq=11300 size=372
📤 Sending audio packet seq=11400 size=372
📤 Sending audio packet seq=11500 size=372
📤 Sending audio packet seq=11600 size=372
📤 Sending audio packet seq=11700 size=372
throwing -10877
throwing -10877
📤 Sending audio packet seq=11800 size=372
📤 Sending audio packet seq=11900 size=372
📤 Sending audio packet seq=12000 size=372
💓 Sent keepalive message
📤 Sending audio packet seq=12100 size=372
📤 Sending audio packet seq=12200 size=372
📤 Sending audio packet seq=12300 size=372
📤 Sending audio packet seq=12400 size=372
📤 Sending audio packet seq=12500 size=372
throwing -10877
throwing -10877
📤 Sending audio packet seq=12600 size=372
📤 Sending audio packet seq=12700 size=372
📤 Sending audio packet seq=12800 size=372
📤 Sending audio packet seq=12900 size=372
📤 Sending audio packet seq=13000 size=372
📤 Sending audio packet seq=13100 size=372
📤 Sending audio packet seq=13200 size=372
📤 Sending audio packet seq=13300 size=372
throwing -10877
throwing -10877
📤 Sending audio packet seq=13400 size=372
📤 Sending audio packet seq=13500 size=372
📤 Sending audio packet seq=13600 size=372
📤 Sending audio packet seq=13700 size=372
📤 Sending audio packet seq=13800 size=372
📤 Sending audio packet seq=13900 size=372
📤 Sending audio packet seq=14000 size=372
📤 Sending audio packet seq=14100 size=372
throwing -10877
throwing -10877
📤 Sending audio packet seq=14200 size=372
t=28991160 sess=8Hv lvl=INFO cat=transcript evt=raw_final text=U
📤 Sending audio packet seq=14300 size=372
💓 Sent keepalive message
t=28992685 sess=8Hv lvl=INFO cat=transcript evt=raw_final text="m, because you already"
📤 Sending audio packet seq=14400 size=372
t=28993472 sess=8Hv lvl=INFO cat=transcript evt=raw_final text=" separated it from Soniox, so--<end>"
📤 Sending audio packet seq=14500 size=372
t=28994218 sess=8Hv lvl=INFO cat=transcript evt=raw_final text=" Okay.<end>"
📤 Sending audio packet seq=14600 size=372
throwing -10877
throwing -10877
📤 Sending audio packet seq=14700 size=372
📤 Sending audio packet seq=14800 size=372
📤 Sending audio packet seq=14900 size=372
📤 Sending audio packet seq=15000 size=372
throwing -10877
throwing -10877
📤 Sending audio packet seq=15100 size=372
📤 Sending audio packet seq=15200 size=372
📤 Sending audio packet seq=15300 size=372
📤 Sending audio packet seq=15400 size=372







=29024170 sess=8Hv lvl=INFO cat=stream evt=warm_reuse socket=sock_4703576088802985178@attempt_7 reused=true
⏹️ Keepalive timer stopped
🔄 Keepalive timer started (interval: 15.000000s)
🔍 [DYNAMIC NOTCH DEBUG] Showed notch in compact mode
👂 [LISTENER] Starting listener task for socketId=sock_4703576088802985178@attempt_7 attemptId=7
🏥 [AUDIO HEALTH] Health monitoring timer started
🎙️ [SONIOX DEBUG] Soniox streaming started successfully!
⏱️ [TIMING] mic_engaged @ 1755736381.599
⚡ [WARM-REUSE] Skipping connect — socket already READY
pass
🔍 [DYNAMIC NOTCH DEBUG] Already visible, skipping show()
❌ Clio API Error: 400 - Control request invalid type.
Connection 171: received failure notification
nw_read_request_report [C171] Receive failed with error "Socket is not connected"
nw_flow_service_reads [C171 129.146.176.251:443 failed parent-flow (satisfied (Path is satisfied), interface: utun4, ipv4, dns, uses wifi)] No output handler
nw_flow_add_write_request [C171 129.146.176.251:443 failed parent-flow (satisfied (Path is satisfied), interface: utun4, ipv4, dns, uses wifi)] cannot accept write requests
❌ WebSocket receive error: The operation couldn’t be completed. Socket is not connected
nw_write_request_report [C171] Send failed with error "Socket is not connected"
🔄 Connection reset during recording - attempting recovery
🔄 [RECOVERY] Attempting mid-recording recovery
⚠️ WebSocket did close with code 1000 (sid=sock_4703576088802985178, attemptId=7)
t=29024518 sess=8Hv lvl=WARN cat=stream evt=state code=1000 state=closed
⏹️ Keepalive timer stopped
🔄 [RECOVERY] Attempting mid-recording recovery
🔌 [WS] Disconnected (socketId=sock_4703576088802985178@attempt_7)
⏹️ Keepalive timer stopped
🔌 [WS] Disconnected (socketId=)
🌐 [PATH] Network path changed (status=satisfied) – triggering recovery
⏹️ Keepalive timer stopped
🔌 [WS] Disconnected (socketId=)
🌐 [ASR BREAKDOWN] Total: 865ms | Client↔Proxy: 100ms | Proxy↔Soniox: 765ms | Network: 765ms
🗑️ Evicted oldest temp key to maintain cache size limit
💾 Cached temp key for languages: ["en", "zh"]
🗓️ [TTL-SCHEDULE] Scheduling temp key refresh for key=global in 3000s (expiresAt=2025-08-21 01:33:02 +0000)
✅ [PREFETCH] Successfully prefetched temp key
🌐 [CONNECT] New single-flight request from pathChange
🔁 [CONNECT] Coalesced request from sendFailure onto in-flight attempt #7
🔁 [CONNECT] Coalesced request from sendFailure onto in-flight attempt #7
🌐 [CONNECT] Attempt #8 (loop 1/3) starting…
🌐 [PATH SNAPSHOT] status=unsatisfied iface=[] constrained=false expensive=false ipv4=false ipv6=false vpnLikely=false
⚡ [CACHE-HIT] Retrieved temp key in 0.2ms
⏱️ [TIMING] Temp key obtained in 0.4ms
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🔊 [SONIOX DEBUG] Full config: enable_endpoint_detection=true, model=stt-rt-preview-v2, language_hints=Optional(["zh", "en"])
🌐 [WS CONNECT] Using URL: wss://stt-rt.soniox.com/transcribe-websocket
🔗 [WS] Bound socket id=sock_3191619355140558152@attempt_8
t=29024849 sess=8Hv lvl=INFO cat=stream evt=ws_bind socket=sock_3191619355140558152@attempt_8
🔑 Successfully connected to Soniox using temp key (0ms key latency)
🤖 [FLY.IO-NER] Server-reported provider: gemini
📥 [NER-STORE] Stored NER entities: 316 chars - *   **Clio**: Organization
*   **Warp**: Application
*   **URLSessionWebSocketDelegate**: Protocol
*...
🛩️ [FLY.IO-NER] Pre-warming completed in 1064ms - NER entities extracted
✅ [FLY.IO] NER refresh completed successfully
🎯 [STATE MACHINE] Event: userCancelled in state: handsFreeLocked(since: 2025-08-21 00:33:01 +0000)
🎯 [STATE MACHINE] Cleared all cooldowns
🎯 [STATE MACHINE] Commands: ["cancelTimers", "clearCooldowns", "playSound(Clio.SoundType.cancel)", "markCancelled", "stopRecording", "hideUI", "updateUI(Clio.RecorderViewModel(isRecording: false, isHandsFreeLocked: false, isAttemptingToRecord: false, isVisualizerActive: false, sessionStateDescription: \"idle\", canTranscribe: true))"]
🔊 [SoundManager] Attempting to play esc sound (with fade)
🎯 [STATE MACHINE] Event: userCancelled in state: idle
🎯 [STATE MACHINE] Cleared all cooldowns
🎯 [STATE MACHINE] Commands: ["cancelTimers", "clearCooldowns", "hideUI", "playSound(Clio.SoundType.cancel)", "updateUI(Clio.RecorderViewModel(isRecording: false, isHandsFreeLocked: false, isAttemptingToRecord: false, isVisualizerActive: false, sessionStateDescription: \"idle\", canTranscribe: true))"]
🎯 [STATE MACHINE] Event: userCancelled in state: idle
🎯 [STATE MACHINE] Cleared all cooldowns
🎯 [STATE MACHINE] Commands: ["cancelTimers", "clearCooldowns", "hideUI", "playSound(Clio.SoundType.cancel)", "updateUI(Clio.RecorderViewModel(isRecording: false, isHandsFreeLocked: false, isAttemptingToRecord: false, isVisualizerActive: false, sessionStateDescription: \"idle\", canTranscribe: true))"]
🎯 [STATE MACHINE] Event: userCancelled in state: idle
🎯 [STATE MACHINE] Cleared all cooldowns
🎯 [STATE MACHINE] Commands: ["cancelTimers", "clearCooldowns", "hideUI", "playSound(Clio.SoundType.cancel)", "updateUI(Clio.RecorderViewModel(isRecording: false, isHandsFreeLocked: false, isAttemptingToRecord: false, isVisualizerActive: false, sessionStateDescription: \"idle\", canTranscribe: true))"]
🎯 [STATE MACHINE] Event: userCancelled in state: idle
🎯 [STATE MACHINE] Cleared all cooldowns
🎯 [STATE MACHINE] Commands: ["cancelTimers", "clearCooldowns", "hideUI", "playSound(Clio.SoundType.cancel)", "updateUI(Clio.RecorderViewModel(isRecording: false, isHandsFreeLocked: false, isAttemptingToRecord: false, isVisualizerActive: false, sessionStateDescription: \"idle\", canTranscribe: true))"]
🎯 [STATE MACHINE] Event: userCancelled in state: idle
🎯 [STATE MACHINE] Cleared all cooldowns
🎯 [STATE MACHINE] Commands: ["cancelTimers", "clearCooldowns", "hideUI", "playSound(Clio.SoundType.cancel)", "updateUI(Clio.RecorderViewModel(isRecording: false, isHandsFreeLocked: false, isAttemptingToRecord: false, isVisualizerActive: false, sessionStateDescription: \"idle\", canTranscribe: true))"]
🎯 [STATE MACHINE] Event: userCancelled in state: idle
🎯 [STATE MACHINE] Cleared all cooldowns
🎯 [STATE MACHINE] Commands: ["cancelTimers", "clearCooldowns", "hideUI", "playSound(Clio.SoundType.cancel)", "updateUI(Clio.RecorderViewModel(isRecording: false, isHandsFreeLocked: false, isAttemptingToRecord: false, isVisualizerActive: false, sessionStateDescription: \"idle\", canTranscribe: true))"]
🎯 [STATE MACHINE] Event: userCancelled in state: idle
🎯 [STATE MACHINE] Cleared all cooldowns
🎯 [STATE MACHINE] Commands: ["cancelTimers", "clearCooldowns", "hideUI", "playSound(Clio.SoundType.cancel)", "updateUI(Clio.RecorderViewModel(isRecording: false, isHandsFreeLocked: false, isAttemptingToRecord: false, isVisualizerActive: false, sessionStateDescription: \"idle\", canTranscribe: true))"]
🎯 [STATE MACHINE] Event: userCancelled in state: idle
🎯 [STATE MACHINE] Cleared all cooldowns
🎯 [STATE MACHINE] Commands: ["cancelTimers", "clearCooldowns", "hideUI", "playSound(Clio.SoundType.cancel)", "updateUI(Clio.RecorderViewModel(isRecording: false, isHandsFreeLocked: false, isAttemptingToRecord: false, isVisualizerActive: false, sessionStateDescription: \"idle\", canTranscribe: true))"]
🎯 [STATE MACHINE] Event: userCancelled in state: idle
🎯 [STATE MACHINE] Cleared all cooldowns
🎯 [STATE MACHINE] Commands: ["cancelTimers", "clearCooldowns", "hideUI", "playSound(Clio.SoundType.cancel)", "updateUI(Clio.RecorderViewModel(isRecording: false, isHandsFreeLocked: false, isAttemptingToRecord: false, isVisualizerActive: false, sessionStateDescription: \"idle\", canTranscribe: true))"]
🔍 [DYNAMIC NOTCH DEBUG] Hiding notch...
📱 Dismissing recorder
🛑 Stopping Clio streaming transcription
🏥 [AUDIO HEALTH] Health monitoring timer stopped
🛑 Stopping unified audio capture
t=29025535 sess=8Hv lvl=INFO cat=audio evt=record_stop
t=29025544 sess=8Hv lvl=INFO cat=audio evt=avcapture_stop
✅ Unified audio capture stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
📉 Released connection for account account-bundle (connections: 0)
💾 [COLD-START] Updated successful streaming timestamp
✅ Streaming stopped. Final transcript (0 chars, 1.4s, without audio file): ""
t=29025546 sess=8Hv lvl=INFO cat=transcript evt=final text=
t=29025546 sess=8Hv lvl=INFO cat=transcript evt=session_end divider="────────── session end ──────────"
✅ [AUDIO HEALTH] First audio data received - tap is functional
🔍 [DYNAMIC NOTCH DEBUG] Hidden notch
🔌 WebSocket did open (sid=sock_3191619355140558152, attemptId=8)
ℹ️ didOpen received after stop – ignoring and canceling socket
⚠️ WebSocket did close with code 1001 (sid=sock_3191619355140558152, attemptId=8)
t=29026333 sess=8Hv lvl=WARN cat=stream evt=state code=1001 state=closed
🌐 [CONNECT] Attempt #8 failed: URL session not configured
⚠️ WebSocket connect failed (attempt 1). Retrying in 250ms…
🌐 [CONNECT] Attempt #9 (loop 2/3) starting…
🌐 [PATH SNAPSHOT] status=unsatisfied iface=[] constrained=false expensive=false ipv4=false ipv6=false vpnLikely=false
⚡ [CACHE-HIT] Retrieved temp key in 0.1ms
⏱️ [TIMING] Temp key obtained in 0.3ms
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🔊 [SONIOX DEBUG] Full config: enable_endpoint_detection=true, model=stt-rt-preview-v2, language_hints=Optional(["en", "zh"])
🌐 [WS CONNECT] Using URL: wss://stt-rt.soniox.com/transcribe-websocket
🔗 [WS] Bound socket id=sock_4740081041871777277@attempt_9
t=29026605 sess=8Hv lvl=INFO cat=stream evt=ws_bind socket=sock_4740081041871777277@attempt_9
🔑 Successfully connected to Soniox using temp key (0ms key latency)
⏳ [CONNECT-TIMEOUT] Readiness not signaled within 8s — aborting connect (attempt=8)
⏹️ Keepalive timer stopped
🔌 [WS] Disconnected (socketId=sock_4740081041871777277@attempt_9)
🌐 [CONNECT] Attempt #9 failed: URL session not configured
⚠️ WebSocket connect failed (attempt 2). Retrying in 500ms…
🌐 [CONNECT] Attempt #10 (loop 3/3) starting…
🌐 [PATH SNAPSHOT] status=unsatisfied iface=[] constrained=false expensive=false ipv4=false ipv6=false vpnLikely=false
⚡ [CACHE-HIT] Retrieved temp key in 0.1ms
⏱️ [TIMING] Temp key obtained in 0.4ms
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🔊 [SONIOX DEBUG] Full config: enable_endpoint_detection=true, model=stt-rt-preview-v2, language_hints=Optional(["zh", "en"])
🌐 [WS CONNECT] Using URL: wss://stt-rt.soniox.com/transcribe-websocket
🔗 [WS] Bound socket id=sock_3400575228684575635@attempt_10
t=29027134 sess=8Hv lvl=INFO cat=stream evt=ws_bind socket=sock_3400575228684575635@attempt_10
🔑 Successfully connected to Soniox using temp key (0ms key latency)
🔌 WebSocket did open (sid=sock_3400575228684575635, attemptId=10)
ℹ️ didOpen received after stop – ignoring and canceling socket
⚠️ WebSocket did close with code 1001 (sid=sock_3400575228684575635, attemptId=10)
t=29028661 sess=8Hv lvl=WARN cat=stream evt=state state=closed code=1001
🌐 [CONNECT] Attempt #10 failed: URL session not configured
❌ WebSocket connection failed after 3 attempts: URL session not configured
❌ Recovery connect failed: URL session not configured
❌ Path-change recovery failed: URL session not configured
❌ Recovery connect failed: URL session not configured