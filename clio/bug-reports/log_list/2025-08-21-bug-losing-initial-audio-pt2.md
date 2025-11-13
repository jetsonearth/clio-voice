🎯 [STATE MACHINE] Event: keyDown in state: idle
🎯 [STATE MACHINE] Commands: ["showLightweightUI", "playSoundDelayed(Clio.SoundType.keyDown, delay: 0.06)", "schedulePromotion(delay: 0.3)", "scheduleMisTouchHide(delay: 0.4)", "updateUI(Clio.RecorderViewModel(isRecording: false, isHandsFreeLocked: false, isAttemptingToRecord: true, isVisualizerActive: true, sessionStateDescription: \"showing lightweight\", canTranscribe: true))"]
📱 Showing DynamicNotch recorder (MIT licensed)
🔍 [DYNAMIC NOTCH DEBUG] Showing notch...
🧊 [WARMUP] Skipping (recently run) context=recorderUIShown
🔍 [DYNAMIC NOTCH DEBUG] Using screen under mouse (preserving mouse-following)
🔍 [DYNAMIC NOTCH SIZE] Using built-in screen notch size: (185.0, 32.0)
🎯 [STATE MACHINE] Event: keyDown in state: lightweightShown(since: 2025-08-21 00:39:34 +0000)
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
🔄 [AUTH_REFRESH] Session still valid for 19 minutes
🎙️ [ASYNC TASK DEBUG] Starting async recording task...
🎙️ [ASYNC TASK DEBUG] Task thread: <_NSMainThread: 0x600003a78800>{number = 1, name = main}
🎙️ [ASYNC TASK DEBUG] Re-evaluating model for language settings...
🎙️ [ASYNC TASK DEBUG] Model type: soniox-realtime-streaming, isStreaming: true
🎙️ [SONIOX DEBUG] Starting Soniox streaming transcription...
🎙️ [SONIOX DEBUG] Calling wakeAudioSystemIfNeeded()...
🎙️ [SONIOX DEBUG] Calling sonioxStreamingService.startStreaming()...
📊 [SESSION] Starting recording session #8
t=29417818 sess=8Hv lvl=INFO cat=audio evt=session_backend backend=avcapture
t=29417818 sess=8Hv lvl=INFO cat=audio evt=compat_state enabled=true
🎤 Registering audio tap for Soniox
t=29417818 sess=8Hv lvl=INFO cat=audio evt=record_start service=Soniox
🔍 Performing audio system pre-flight checks
throwing -10877
throwing -10877
✅ Pre-flight checks passed
t=29417895 sess=8Hv lvl=INFO cat=audio evt=tap_install ok=true service=Soniox backend=avcapture
🎬 Starting unified audio capture
t=29417895 sess=8Hv lvl=INFO cat=audio evt=record_start reason=start_capture
t=29417895 sess=8Hv lvl=INFO cat=audio evt=device_pin_start desired_name="MacBook Pro Microphone" desired_uid_hash=3440565358075929298 prev_name="MacBook Pro Microphone" prev_uid_hash=3440565358075929298 desired_id=140 prev_id=140
❄️ Cold start detected - performing full initialization
❄️ Performing cold start initialization
⏭️ Skipping engine cold start (backend=AVCapture)
t=29417895 sess=8Hv lvl=INFO cat=audio evt=capture_backend_selected backend=avcapture
✅ Unified audio capture started
✅ Selected account account-bundle (connections: 1/10)
🎬 [CAPTURE DEBUG] Starting smart screen context capture
🔍 [CALLBACK DEBUG] onOCRCompleted callback exists: true
⏰ [CACHE] Cache is stale (age: 123.5s, ttl=120s)
🎬 Starting screen capture with verified permissions
🚀 Starting Clio streaming transcription
🎯 ScreenCapture detected frontmost app: Xcode (com.apple.dt.Xcode)
t=29417936 sess=8Hv lvl=INFO cat=transcript evt=session_start divider="────────── session start ──────────"
🎯 Found matching window: Clio — SonioxStreamingService.swift (Xcode) - layer:0, pid:661
🎯 ScreenCapture found window: Clio — SonioxStreamingService.swift (Xcode) - matches Context Preset detection
🎯 Found window: Clio — SonioxStreamingService.swift (Xcode)
🎯 ScreenCapture detected frontmost app: Xcode (com.apple.dt.Xcode)
🎯 Found matching window: Clio — SonioxStreamingService.swift (Xcode) - layer:0, pid:661
🎯 ScreenCapture found window: Clio — SonioxStreamingService.swift (Xcode) - matches Context Preset detection
🖼️ Attempting window-specific capture for: Clio — SonioxStreamingService.swift (ID: 3391)
⚡ [CACHE-HIT] Retrieved temp key in 2.1ms
✅ Successfully captured window: 3456.000000x2042.000000
🌐 [LANG DEBUG] Multi-language setting exists: true, Single language: en
🌐 [LANG DEBUG] Using multi-language selection (prioritized): zh, en
🌐 [OCR DEBUG] Selected languages from settings: en, zh
🌐 [OCR DEBUG] User selection mode - prioritizing non-English: zh-Hans, en-US
🌐 Using selected languages for OCR: zh-Hans, en-US
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
🚀 [WARM-REUSE] Reusing READY socket — sent START without reconnect (socketId=sock_-35443958918454888@attempt_13)
t=29417989 sess=8Hv lvl=INFO cat=stream evt=warm_reuse reused=true socket=sock_-35443958918454888@attempt_13
⏹️ Keepalive timer stopped
🔄 Keepalive timer started (interval: 15.000000s)
t=29417989 sess=8Hv lvl=INFO cat=audio evt=avcapture_start ok=true
t=29417989 sess=8Hv lvl=INFO cat=audio evt=first_buffer
🔍 [DYNAMIC NOTCH DEBUG] Showed notch in compact mode
👂 [LISTENER] Starting listener task for socketId=sock_-35443958918454888@attempt_13 attemptId=13
nw_read_request_report [C178] Receive failed with error "Socket is not connected"
nw_flow_service_reads [C178 129.146.176.251:443 failed parent-flow (satisfied (Path is satisfied), interface: utun4, ipv4, dns, uses wifi)] No output handler
nw_flow_add_write_request [C178 129.146.176.251:443 failed parent-flow (satisfied (Path is satisfied), interface: utun4, ipv4, dns, uses wifi)] cannot accept write requests
nw_write_request_report [C178] Send failed with error "Socket is not connected"
⚠️ WebSocket did close with code 1000 (sid=sock_-35443958918454888, attemptId=13)
✅ [AUDIO HEALTH] First audio data received - tap is functional
t=29417990 sess=8Hv lvl=WARN cat=stream evt=state state=closed code=1000
📤 Sending text frame seq=26836
❌ Failed to send frame seq=26836: The operation couldn’t be completed. Socket is not connected
t=29417990 sess=8Hv lvl=ERR cat=stream evt=error seq=26836 phase=send
🚑 Re-queueing failed packet seq=26836 requeue=true queue_len=2
❌ Send path reported failure: The operation couldn’t be completed. Socket is not connected
🏥 [AUDIO HEALTH] Health monitoring timer started
🎙️ [SONIOX DEBUG] Soniox streaming started successfully!
⏱️ [TIMING] mic_engaged @ 1755736775.431
❌ WebSocket receive error: The operation couldn’t be completed. Socket is not connected
🔄 Connection reset during recording - attempting recovery
🔄 [RECOVERY] Attempting mid-recording recovery
🔄 [RECOVERY] Attempting mid-recording recovery
🚑 [RECOVERY] Recovering from send failure: The operation couldn’t be completed. Socket is not connected
⚡ [WARM-REUSE] Skipping connect — socket already READY
pass
⏹️ Keepalive timer stopped
⏹️ Keepalive timer stopped
⏹️ Keepalive timer stopped
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
🔍 [DYNAMIC NOTCH DEBUG] Already visible, skipping show()
🔌 [WS] Disconnected (socketId=sock_-35443958918454888@attempt_13)
🔌 [WS] Disconnected (socketId=)
🔌 [WS] Disconnected (socketId=)
🌐 [CONNECT] New single-flight request from sendFailure
🌐 [CONNECT] Attempt #14 (loop 1/3) starting…
🌐 [PATH SNAPSHOT] status=unsatisfied iface=[] constrained=false expensive=false ipv4=false ipv6=false vpnLikely=false
⚡ [CACHE-HIT] Retrieved temp key in 0.0ms
⏱️ [TIMING] Temp key obtained in 0.1ms
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🔊 [SONIOX DEBUG] Full config: enable_endpoint_detection=true, model=stt-rt-preview-v2, language_hints=Optional(["en", "zh"])
🌐 [WS CONNECT] Using URL: wss://stt-rt.soniox.com/transcribe-websocket
🔗 [WS] Bound socket id=sock_5910722198444033252@attempt_14
t=29418269 sess=8Hv lvl=INFO cat=stream evt=ws_bind socket=sock_5910722198444033252@attempt_14
🔑 Successfully connected to Soniox using temp key (0ms key latency)
🔁 [CONNECT] Coalesced request from sendFailure onto in-flight attempt #14
🔁 [CONNECT] Coalesced request from sendFailure onto in-flight attempt #14
🌐 [PATH] Network path changed (status=satisfied) – triggering recovery
🌐 [PATH] Change detected but isConnecting=true — skipping recovery
🔍 Found 113 text observations
✅ Text extraction successful: 2531 chars, 2531 non-whitespace, 306 words from 113 observations
✅ Captured text successfully
✅ [CAPTURE DEBUG] Screen capture successful: 2617 characters
🎯 ScreenCapture detected frontmost app: Xcode (com.apple.dt.Xcode)
🎯 Found matching window: Clio — SonioxStreamingService.swift (Xcode) - layer:0, pid:661
🎯 ScreenCapture found window: Clio — SonioxStreamingService.swift (Xcode) - matches Context Preset detection
💾 [SMART-CACHE] Cached new context: com.apple.dt.Xcode|Clio — SonioxStreamingService.swift (2617 chars)
🎯 [CALLBACK DEBUG] Executing callback with fresh content (2617 chars)
🔥 [NER-TRIGGER] OCR completion callback triggered with fresh content
🔥 [NER-PREWARM] Triggering NER pre-warming with OCR text (2617 chars)
🔥 [PREWARM DEBUG] prewarmConnection() called - isEnhancementEnabled: true, isConfigured: true
🔥 [PREWARM DEBUG] connectionState: ready
🔥 [PREWARM DEBUG] Pre-warming AI connection (target: Gemini), environment: flyio
🛩️ [FLY.IO PREWARM] Starting Fly.io NER pre-warming (forced refresh)
🛩️ [FLY.IO-NER] sendFlyioWarmingRequest() called - starting NER processing (Gemini warmup)
🎬 [NER-PREWARM] Using raw OCR text for NER: 2617 characters
🛩️ [FLY.IO-NER] OCR text retrieved for NER processing: 2617 characters
🧠 [NER-DEFAULT] Using default NER prompt for general extraction
🤖 [FLY.IO-NER] Server-reported provider: gemini
📥 [NER-STORE] Stored NER entities: 252 chars - **Organizations:**
* Soniox

**Products:**
* Clio
* Xcode

**Projects:**
* wip/diagnostics-logging-2...
🛩️ [FLY.IO-NER] Pre-warming completed in 792ms - NER entities extracted
✅ [FLY.IO] NER refresh completed successfully
🔌 WebSocket did open (sid=sock_5910722198444033252, attemptId=14)
🌐 [CONNECT] Attempt #14 succeeded
📤 [START] Sent start/config text frame (attemptId=14, socketId=sock_5910722198444033252@attempt_14, start_text_sent=true)
t=29419774 sess=8Hv lvl=INFO cat=stream evt=start_sent attempt=14
🔌 [READY] attemptId=14 socketId=sock_5910722198444033252@attempt_14 start_text_sent=true
t=29419774 sess=8Hv lvl=INFO cat=stream evt=ready attempt=14 socket=sock_5910722198444033252@attempt_14
🔌 WebSocket ready after 1830ms - buffered 1.8s of audio
📦 Flushing 154 buffered packets (1.8s of audio, 57264 bytes)
📤 Sending text frame seq=26839
📤 Sent buffered packet 0/154 seq=2 size=360
📤 Sending text frame seq=26836
📤 Sending audio packet seq=26900 size=372
📤 Sent buffered packet 153/154 seq=155 size=372
📦 Flushing 4 additional packets that arrived during flush
✅ Buffer flush complete
⏹️ Keepalive timer stopped
🔄 Keepalive timer started (interval: 15.000000s)
👂 [LISTENER] Starting listener task for socketId=sock_5910722198444033252@attempt_14 attemptId=14
📤 Sending audio packet seq=27000 size=372
❌ Clio API Error: 400 - Control request invalid type.
nw_read_request_report [C179] Receive failed with error "Socket is not connected"
nw_flow_service_reads [C179 129.146.176.251:443 failed parent-flow (satisfied (Path is satisfied), interface: utun4, ipv4, dns, uses wifi)] No output handler
Connection 179: received failure notification
nw_flow_add_write_request [C179 129.146.176.251:443 failed parent-flow (satisfied (Path is satisfied), interface: utun4, ipv4, dns, uses wifi)] cannot accept write requests
❌ WebSocket receive error: The operation couldn’t be completed. Socket is not connected
⚠️ WebSocket did close with code 1000 (sid=sock_5910722198444033252, attemptId=14)
nw_write_request_report [C179] Send failed with error "Socket is not connected"
🔄 Connection reset during recording - attempting recovery
🔄 [RECOVERY] Attempting mid-recording recovery
⏹️ Keepalive timer stopped
t=29420220 sess=8Hv lvl=WARN cat=stream evt=state code=1000 state=closed
🔄 [RECOVERY] Attempting mid-recording recovery
🔌 [WS] Disconnected (socketId=sock_5910722198444033252@attempt_14)
⏹️ Keepalive timer stopped
🔌 [WS] Disconnected (socketId=)
🌐 [CONNECT] New single-flight request from sendFailure
🔁 [CONNECT] Coalesced request from sendFailure onto in-flight attempt #14
🌐 [CONNECT] Attempt #15 (loop 1/3) starting…
🌐 [PATH SNAPSHOT] status=unsatisfied iface=[] constrained=false expensive=false ipv4=false ipv6=false vpnLikely=false
⚡ [CACHE-HIT] Retrieved temp key in 0.2ms
⏱️ [TIMING] Temp key obtained in 0.4ms
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🔊 [SONIOX DEBUG] Full config: enable_endpoint_detection=true, model=stt-rt-preview-v2, language_hints=Optional(["zh", "en"])
🌐 [WS CONNECT] Using URL: wss://stt-rt.soniox.com/transcribe-websocket
🔗 [WS] Bound socket id=sock_2942095096553041958@attempt_15
t=29420543 sess=8Hv lvl=INFO cat=stream evt=ws_bind socket=sock_2942095096553041958@attempt_15
🔑 Successfully connected to Soniox using temp key (0ms key latency)
throwing -10877
throwing -10877
🔌 WebSocket did open (sid=sock_2942095096553041958, attemptId=15)
🌐 [CONNECT] Attempt #15 succeeded
📤 [START] Sent start/config text frame (attemptId=15, socketId=sock_2942095096553041958@attempt_15, start_text_sent=true)
t=29422071 sess=8Hv lvl=INFO cat=stream evt=start_sent attempt=15
🔌 [READY] attemptId=15 socketId=sock_2942095096553041958@attempt_15 start_text_sent=true
t=29422071 sess=8Hv lvl=INFO cat=stream evt=ready attempt=15 socket=sock_2942095096553041958@attempt_15
🔌 WebSocket ready after 4127ms - buffered 1.8s of audio
📦 Flushing 159 buffered packets (1.8s of audio, 59148 bytes)
📤 Sending text frame seq=27033
📤 Sent buffered packet 0/159 seq=195 size=372
📤 Sending audio packet seq=27100 size=372
📤 Sent buffered packet 158/159 seq=353 size=372
📦 Flushing 4 additional packets that arrived during flush
✅ Buffer flush complete
⏹️ Keepalive timer stopped
🔄 Keepalive timer started (interval: 15.000000s)
👂 [LISTENER] Starting listener task for socketId=sock_2942095096553041958@attempt_15 attemptId=15
📤 Sending audio packet seq=27200 size=372
📤 Sending audio packet seq=27300 size=372
📤 Sending audio packet seq=27400 size=372
📤 Sending audio packet seq=27500 size=372
throwing -10877
throwing -10877
📤 Sending audio packet seq=27600 size=372
📤 Sending audio packet seq=27700 size=372
📤 Sending audio packet seq=27800 size=372
📤 Sending audio packet seq=27900 size=372
throwing -10877
throwing -10877
📤 Sending audio packet seq=28000 size=372
t=29432317 sess=8Hv lvl=INFO cat=transcript evt=raw_final text="Hey, what's happening with mine?<end>"
📤 Sending audio packet seq=28100 size=372
📤 Sending audio packet seq=28200 size=372
📤 Sending audio packet seq=28300 size=372
🎯 [STATE MACHINE] Event: userCancelled in state: handsFreeLocked(since: 2025-08-21 00:39:35 +0000)
🎯 [STATE MACHINE] Cleared all cooldowns
🎯 [STATE MACHINE] Commands: ["cancelTimers", "clearCooldowns", "playSound(Clio.SoundType.cancel)", "markCancelled", "stopRecording", "hideUI", "updateUI(Clio.RecorderViewModel(isRecording: false, isHandsFreeLocked: false, isAttemptingToRecord: false, isVisualizerActive: false, sessionStateDescription: \"idle\", canTranscribe: true))"]
🎯 [STATE MACHINE] Event: userCancelled in state: idle
🔊 [SoundManager] Attempting to play esc sound (with fade)
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
t=29435191 sess=8Hv lvl=INFO cat=audio evt=record_stop
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key plugInPackage
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key CMIOType
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key numberOfDevices
t=29435199 sess=8Hv lvl=INFO cat=audio evt=avcapture_stop
✅ Unified audio capture stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
📉 Released connection for account account-bundle (connections: 0)
✅ [AUDIO HEALTH] First audio data received - tap is functional
💾 [COLD-START] Updated successful streaming timestamp
✅ Streaming stopped. Final transcript (32 chars, 17.3s, without audio file): "Hey, what's happening with mine?"
t=29435231 sess=8Hv lvl=INFO cat=transcript evt=final text="Hey, what's happening with mine?"
t=29435231 sess=8Hv lvl=INFO cat=transcript evt=session_end divider="────────── session end ──────────"
🔍 [DYNAMIC NOTCH DEBUG] Hidden notch



-----
but when i restarted my app, its fine...


🔑 TempKeyCache initialized
🔄 Background prefetch timer started
⏹️ System keepalive stopped
🔄 System keepalive started (interval: 15 minutes)
🎯 [GATE] State machine enabled for testing
🎹 HotkeyManager initializing at 2025-08-21 00:57:09 +0000
🎹 KeyboardShortcuts library available: toggleMiniRecorder
       LoudnessManager.mm:413   PlatformUtilities::CopyHardwareModelFullName() returns unknown value: Mac16,7, defaulting hw platform key
🔍 [SHORTCUT DEBUG] Library shortcut: F5 (effective: F5)
🔍 [SHORTCUT DEBUG] Custom shortcut: nil
🔍 [SHORTCUT DEBUG] Shortcut configured: true
🎛️ Setting up hands-free shortcut monitor for: Right ⌘
✅ Keyboard shortcut configured: F5
t=002331 sess=EAR lvl=INFO cat=sys evt=app_launch ver=1.44.0
🧭 [APP] ActivationPolicy=.regular (IsMenuBarOnly=false)
🧭 [APP] ActivationPolicy=.regular (IsMenuBarOnly=false)
t=002386 sess=EAR lvl=INFO cat=hotkey evt=open_config ready=false
🧪 Testing KeyboardShortcuts library...
🧪 Current shortcut from library: F5
🧪 Current shortcut available: F5
🧪 KeyboardShortcuts library test completed
🔧 [HOTKEY SETUP] Setting up shortcut handler at 2025-08-21 00:57:12 +0000
🧹 [HOTKEY SETUP] Cleared existing handlers
🔧 [HOTKEY SETUP] Attempting to activate KeyboardShortcuts system...
🔧 [HOTKEY SETUP] Forced library initialization
🔧 [HOTKEY SETUP] Library activation complete, ready for real handlers...
🎛️ Setting up hands-free shortcut monitor for: Right ⌘
t=002388 sess=EAR lvl=INFO cat=hotkey evt=register ok=true
🧭 [APP] applicationDidBecomeActive
🧭 [APP] ActivationPolicy=.regular (IsMenuBarOnly=false)
🧭 [APP] applicationDidBecomeActive
🧭 [APP] ActivationPolicy=.regular (IsMenuBarOnly=false)
🔐 [ENTITLEMENT] Using cached paid entitlement until 2025-08-30 15:20:52 +0000
🔄 [SYNC_STATE] syncTrialState called - currentTier: pro, isInTrial: false
🔄 [SYNC_STATE] Final state after syncTrialState - currentTier: pro, isInTrial: false
✅ LocalizationManager: Successfully loaded bundle for language: en
Loaded saved device ID: 140
Using saved device: MacBook Pro Microphone
Error: -checkForUpdatesInBackground called but .sessionInProgress == YES
🔥 [WARMUP] ensureReady() invoked context=appActivation
🔥 [SYSTEM-WARMUP] TempKeyCache warmup integration
🚀 [PREFETCH] Starting background temp key prefetch
✅ [MENUBAR] MenuBarView appeared
164867          HALC_ProxyIOContext.cpp:1622  HALC_ProxyIOContext::IOWorkLoop: skipping cycle due to overload
🔄 [AUTH_REFRESH] Manually triggering authentication refresh...
🔄 [AUTH_REFRESH] No session to refresh
🔄 [AUTH_REFRESH] Manually triggering authentication refresh...
🔄 [AUTH_REFRESH] No session to refresh
🎯 [WHISPER STATE] State machine connected, enabled: true
🔐 [ENTITLEMENT] Using cached paid entitlement until 2025-08-30 15:20:52 +0000
🔄 [SYNC_STATE] syncTrialState called - currentTier: pro, isInTrial: false
🔄 [SYNC_STATE] Final state after syncTrialState - currentTier: pro, isInTrial: false
🔐 [ENTITLEMENT] Using cached paid entitlement until 2025-08-30 15:20:52 +0000
🔄 [SYNC_STATE] syncTrialState called - currentTier: pro, isInTrial: false
🔄 [SYNC_STATE] Final state after syncTrialState - currentTier: pro, isInTrial: false
🔧 [HOTKEY SETUP] Setting up actual handlers...
✅ [HOTKEY SETUP] Real handlers configured (keyDown + keyUp)
🚀 [HOTKEY SETUP] Complete setup finished - handlers active
✅ F5→F16 remapper started (event tap)
✅ F5 override active via event tap (reason=postActivationAutoArm)
✅ F5→F16 remapper thread runloop started
🔍 [SHORTCUT DEBUG] Library shortcut: F5 (effective: F5)
🔍 [SHORTCUT DEBUG] Custom shortcut: nil
🔍 [SHORTCUT DEBUG] Shortcut configured: true
nw_connection_copy_connected_local_endpoint_block_invoke [C4] Client called nw_connection_copy_connected_local_endpoint on unconnected nw_connection
nw_connection_copy_connected_remote_endpoint_block_invoke [C4] Client called nw_connection_copy_connected_remote_endpoint on unconnected nw_connection
nw_connection_copy_protocol_metadata_internal_block_invoke [C4] Client called nw_connection_copy_protocol_metadata_internal on unconnected nw_connection
✅ [HOTKEY READY] effective=F5, F5Armed=true
Scheduling daily audio cleanup task
Cleanup run finished — removed: 0, failed: 0
✅ [AUTH] User authenticated: kentaro@resonantai.co.site
✅ [AUTH] User authenticated: kentaro@resonantai.co.site
✅ [AUTH] Restored session for: kentaro@resonantai.co.site
🔄 [SYNC_STATE] syncTrialState called - currentTier: pro, isInTrial: false
🔄 [SYNC_STATE] Final state after syncTrialState - currentTier: pro, isInTrial: false
🔄 [SYNC_STATE] syncTrialState called - currentTier: pro, isInTrial: false
🔄 [SYNC_STATE] Final state after syncTrialState - currentTier: pro, isInTrial: false
🌐 [ASR BREAKDOWN] Total: 2219ms | Client↔Proxy: 1352ms | Proxy↔Soniox: 867ms | Network: 867ms
💾 Cached temp key for languages: ["en", "zh"]
🗓️ [TTL-SCHEDULE] Scheduling temp key refresh for key=global in 3000s (expiresAt=2025-08-21 01:57:14 +0000)
✅ [HOTKEY READY] effective=F5, F5Armed=true
✅ [PREFETCH] Successfully prefetched temp key
🎯 [STATE MACHINE] Event: keyDown in state: idle
🎯 [STATE MACHINE] Commands: ["showLightweightUI", "playSoundDelayed(Clio.SoundType.keyDown, delay: 0.06)", "schedulePromotion(delay: 0.3)", "scheduleMisTouchHide(delay: 0.4)", "updateUI(Clio.RecorderViewModel(isRecording: false, isHandsFreeLocked: false, isAttemptingToRecord: true, isVisualizerActive: true, sessionStateDescription: \"showing lightweight\", canTranscribe: true))"]
📱 Showing DynamicNotch recorder (MIT licensed)
🔍 [DYNAMIC NOTCH DEBUG] Showing notch...
🧊 [WARMUP] Skipping (recently run) context=recorderUIShown
🔍 [DYNAMIC NOTCH DEBUG] Using screen under mouse (preserving mouse-following)
🔍 [DYNAMIC NOTCH SIZE] Using built-in screen notch size: (185.0, 32.0)
🎯 [STATE MACHINE] Event: keyDown in state: lightweightShown(since: 2025-08-21 00:57:15 +0000)
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
🎙️ [RECORD PERMISSION DEBUG] Thread: <_NSMainThread: 0x600001a801c0>{number = 1, name = main}
🎙️ [RECORD PERMISSION DEBUG] Time since app launch: 0.00s
🔄 [AUTH_REFRESH] Session expires in 2 minutes - refreshing...
🎙️ [ASYNC TASK DEBUG] Starting async recording task...
🎙️ [ASYNC TASK DEBUG] Task thread: <_NSMainThread: 0x600001a801c0>{number = 1, name = main}
🎙️ [ASYNC TASK DEBUG] Re-evaluating model for language settings...
🎙️ [ASYNC TASK DEBUG] Model type: soniox-realtime-streaming, isStreaming: true
🎙️ [SONIOX DEBUG] Starting Soniox streaming transcription...
🎙️ [SONIOX DEBUG] Calling wakeAudioSystemIfNeeded()...
🔊 Waking up audio system after 494s idle time
🎬 [CAPTURE DEBUG] Starting smart screen context capture
🔍 [CALLBACK DEBUG] onOCRCompleted callback exists: true
🔍 [CACHE] No cache available
🎬 Starting screen capture with verified permissions
🎯 ScreenCapture detected frontmost app: Clio (com.cliovoice.clio)
🎯 Found matching window:  (Clio) - layer:0, pid:49158
🎯 ScreenCapture found window:  (Clio) - matches Context Preset detection
🎯 Found window:  (Clio)
🎯 ScreenCapture detected frontmost app: Clio (com.cliovoice.clio)
🎯 Found matching window:  (Clio) - layer:0, pid:49158
🎯 ScreenCapture found window:  (Clio) - matches Context Preset detection
🖼️ Attempting window-specific capture for:  (ID: 26846)
✅ Successfully captured window: 2200.000000x1604.000000
🌐 [LANG DEBUG] Multi-language setting exists: true, Single language: en
🌐 [LANG DEBUG] Using multi-language selection (prioritized): zh, en
🌐 [OCR DEBUG] Selected languages from settings: en, zh
🌐 [OCR DEBUG] User selection mode - prioritizing non-English: zh-Hans, en-US
🌐 Using selected languages for OCR: zh-Hans, en-US
🎙️ [SONIOX DEBUG] Calling sonioxStreamingService.startStreaming()...
📊 [SESSION] Starting recording session #1
t=005856 sess=EAR lvl=INFO cat=audio evt=session_backend backend=avcapture
t=005856 sess=EAR lvl=INFO cat=audio evt=compat_state enabled=true
🎤 Registering audio tap for Soniox
t=005856 sess=EAR lvl=INFO cat=audio evt=record_start service=Soniox
🔍 Performing audio system pre-flight checks
CMIO_DAL_CMIOExtension_Device.mm:355:Device legacy uuid isn't present, using new style uuid instead
CMIO_DAL_CMIOExtension_Device.mm:355:Device legacy uuid isn't present, using new style uuid instead
nw_connection_copy_connected_local_endpoint_block_invoke [C8] Client called nw_connection_copy_connected_local_endpoint on unconnected nw_connection
nw_connection_copy_connected_remote_endpoint_block_invoke [C8] Client called nw_connection_copy_connected_remote_endpoint on unconnected nw_connection
nw_connection_copy_protocol_metadata_internal_block_invoke [C8] Client called nw_connection_copy_protocol_metadata_internal on unconnected nw_connection
cannot open file at line 49455 of [1b37c146ee]
os_unix.c:49455: (2) open(/private/var/db/DetachedSignatures) - No such file or directory
182283          HALC_ProxyIOContext.cpp:1622  HALC_ProxyIOContext::IOWorkLoop: skipping cycle due to overload
CMIO_DAL_CMIOExtension_Stream.mm:1863:GetPropertyData background replacement pixel buffer size invalid or not available
CMIOHardware.cpp:331:CMIOObjectGetPropertyData Error: 2003332927, failed
throwing -10877
throwing -10877
✅ Pre-flight checks passed
t=006261 sess=EAR lvl=INFO cat=audio evt=tap_install backend=avcapture service=Soniox ok=true
🎬 Starting unified audio capture
t=006261 sess=EAR lvl=INFO cat=audio evt=record_start reason=start_capture
t=006262 sess=EAR lvl=INFO cat=audio evt=device_pin_start prev_name="MacBook Pro Microphone" prev_id=140 prev_uid_hash=-4354896338347245519 desired_name="MacBook Pro Microphone" desired_uid_hash=-4354896338347245519 desired_id=140
❄️ Cold start detected - performing full initialization
❄️ Performing cold start initialization
⏭️ Skipping engine cold start (backend=AVCapture)
t=006262 sess=EAR lvl=INFO cat=audio evt=capture_backend_selected backend=avcapture
✅ Unified audio capture started
✅ Selected account account-bundle (connections: 1/10)
🔍 [DYNAMIC NOTCH DEBUG] Showed notch in compact mode
✅ [AUTH] Session refreshed
✅ [AUTH_REFRESH] Session refreshed successfully
Device list change detected
t=006267 sess=EAR lvl=INFO cat=audio evt=route_change reason=devices_changed
t=006267 sess=EAR lvl=INFO cat=audio evt=devices_scan
t=006272 sess=EAR lvl=INFO cat=audio evt=devices count=11
t=006272 sess=EAR lvl=INFO cat=audio evt=device ch=1 uid_hash=6962780729985092891 name="iPhone Microphone"
t=006272 sess=EAR lvl=INFO cat=audio evt=device ch=2 uid_hash=-4297415491686308552 name="BlackHole 2ch"
t=006272 sess=EAR lvl=INFO cat=audio evt=device name="MacBook Pro Microphone" uid_hash=-4354896338347245519 ch=1
t=006272 sess=EAR lvl=INFO cat=audio evt=device ch=1 uid_hash=4933752065475814007 name=CADefaultDeviceAggregate-49158-0
t=006272 sess=EAR lvl=INFO cat=audio evt=device name="Gemoo Speaker" uid_hash=-2163795484227914792 ch=2
t=006272 sess=EAR lvl=INFO cat=audio evt=device name="Microsoft Teams Audio" uid_hash=7242848057595788954 ch=2
t=006272 sess=EAR lvl=INFO cat=audio evt=device ch=2 uid_hash=8047412768166851095 name=PalabraMicrophone
t=006272 sess=EAR lvl=INFO cat=audio evt=device name=PalabraSpeaker uid_hash=6844119824085683755 ch=2
t=006272 sess=EAR lvl=INFO cat=audio evt=device uid_hash=3168051524172575669 name=ZoomAudioDevice ch=2
t=006275 sess=EAR lvl=INFO cat=audio evt=device name="Aggregate Device" uid_hash=4614445376558659932 ch=3
t=006275 sess=EAR lvl=INFO cat=audio evt=device ch=2 uid_hash=-8091051967861889921 name="Mixed Input"
182283          HALC_ProxyIOContext.cpp:1622  HALC_ProxyIOContext::IOWorkLoop: skipping cycle due to overload
🚀 Starting Clio streaming transcription
t=006296 sess=EAR lvl=INFO cat=transcript evt=session_start divider="────────── session start ──────────"
🔄 Handling audio device change
✅ Device change handling completed
🏥 [AUDIO HEALTH] Health monitoring timer started
🎙️ [SONIOX DEBUG] Soniox streaming started successfully!
⏱️ [TIMING] mic_engaged @ 1755737836.015
🆕 [COLD-START] First recording after app launch - applying background warm-up
🌐 [CONNECT] New single-flight request from start
pass
🌐 [CONNECT] Attempt #1 (loop 1/3) starting…
🔍 [DYNAMIC NOTCH DEBUG] Already visible, skipping show()
🔥 [COLD-START] Performing system warm-up with network stack pre-warming
⚡ [CACHE-HIT] Retrieved temp key in 1.1ms
⏱️ [TIMING] Temp key obtained in 1.2ms
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🔊 [SONIOX DEBUG] Full config: enable_endpoint_detection=true, model=stt-rt-preview-v2, language_hints=Optional(["zh", "en"])
🌐 [WS CONNECT] Using URL: wss://stt-rt.soniox.com/transcribe-websocket
🔗 [WS] Bound socket id=sock_7944739377785167833@attempt_1
t=006349 sess=EAR lvl=INFO cat=stream evt=ws_bind socket=sock_7944739377785167833@attempt_1
🔑 Successfully connected to Soniox using temp key (1ms key latency)
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
t=006389 sess=EAR lvl=INFO cat=audio evt=avcapture_start ok=true
t=006389 sess=EAR lvl=INFO cat=audio evt=first_buffer
✅ [AUDIO HEALTH] First audio data received - tap is functional
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
✅ Successfully updated user stats in Supabase
🔄 Stats synced successfully (FORCED)
📊 226814 words, 1750.7 minutes
✅ Successfully updated user stats in Supabase
🔄 Stats synced successfully (FORCED)
📊 226814 words, 1750.7 minutes
✅ [AUTH] User authenticated: kentaro@resonantai.co.site
✅ [AUTH] User authenticated: kentaro@resonantai.co.site
🔄 [SYNC_STATE] syncTrialState called - currentTier: pro, isInTrial: false
🔄 [SYNC_STATE] Final state after syncTrialState - currentTier: pro, isInTrial: false
🔍 Found 41 text observations
✅ Text extraction successful: 992 chars, 992 non-whitespace, 166 words from 41 observations
✅ Captured text successfully
🌐 [PATH] Network path changed (status=satisfied) – triggering recovery
🌐 [PATH] Change detected but isConnecting=true — skipping recovery
237067          HALC_ProxyIOContext.cpp:1622  HALC_ProxyIOContext::IOWorkLoop: skipping cycle due to overload
182283          HALC_ProxyIOContext.cpp:1622  HALC_ProxyIOContext::IOWorkLoop: skipping cycle due to overload
✅ [CAPTURE DEBUG] Screen capture successful: 1042 characters
🎯 ScreenCapture detected frontmost app: Clio (com.cliovoice.clio)
237067          HALC_ProxyIOContext.cpp:1622  HALC_ProxyIOContext::IOWorkLoop: skipping cycle due to overload
182283          HALC_ProxyIOContext.cpp:1622  HALC_ProxyIOContext::IOWorkLoop: skipping cycle due to overload
🎯 Found matching window:  (Clio) - layer:0, pid:49158
🎯 ScreenCapture found window:  (Clio) - matches Context Preset detection
💾 [SMART-CACHE] Cached new context: com.cliovoice.clio| (1042 chars)
🎯 [CALLBACK DEBUG] Executing callback with fresh content (1042 chars)
🔥 [NER-TRIGGER] OCR completion callback triggered with fresh content
🔥 [NER-PREWARM] Triggering NER pre-warming with OCR text (1042 chars)
🔥 [PREWARM DEBUG] prewarmConnection() called - isEnhancementEnabled: true, isConfigured: true
🔥 [PREWARM DEBUG] connectionState: cold
🔥 [PREWARM DEBUG] Pre-warming AI connection (target: Gemini), environment: flyio
🛩️ [FLY.IO PREWARM] Starting Fly.io NER pre-warming (forced refresh)
🛩️ [FLY.IO-NER] sendFlyioWarmingRequest() called - starting NER processing (Gemini warmup)
🎬 [NER-PREWARM] Using raw OCR text for NER: 1042 characters
🛩️ [FLY.IO-NER] OCR text retrieved for NER processing: 1042 characters
🧠 [NER-DEFAULT] Using default NER prompt for general extraction
✅ Successfully updated user stats in Supabase
🔄 Stats synced successfully (FORCED)
📊 226814 words, 1750.7 minutes
🔌 WebSocket did open (sid=sock_7944739377785167833, attemptId=1)
🌐 [CONNECT] Attempt #1 succeeded
⏱️ [TIMING] WebSocket connect task completed — will flush after READY
📤 [START] Sent start/config text frame (attemptId=1, socketId=sock_7944739377785167833@attempt_1, start_text_sent=true)
t=007843 sess=EAR lvl=INFO cat=stream evt=start_sent attempt=1
🔌 [READY] attemptId=1 socketId=sock_7944739377785167833@attempt_1 start_text_sent=true
t=007843 sess=EAR lvl=INFO cat=stream evt=ready socket=sock_7944739377785167833@attempt_1 attempt=1
🔌 WebSocket ready after 1546ms - buffered 1.5s of audio
📦 Flushing 128 buffered packets (1.5s of audio, 47036 bytes)
📤 Sent buffered packet 0/128 seq=0 size=360
🔥 [COLD-START] Pre-warming connection pool
📤 Sent buffered packet 127/128 seq=127 size=372
✅ Buffer flush complete
⏹️ Keepalive timer stopped
🔄 Keepalive timer started (interval: 15.000000s)
👂 [LISTENER] Starting listener task for socketId=sock_7944739377785167833@attempt_1 attemptId=1
t=007847 sess=EAR lvl=WARN cat=stream evt=backpressure queue=129
📤 Sending text frame seq=0
🤖 [FLY.IO-NER] Server-reported provider: gemini
📥 [NER-STORE] Stored NER entities: 179 chars - **Application:**
* Clio

**Project/File:**
* @SonioxStreamingService.swift

**Product/Feature:**
* w...
🛩️ [FLY.IO-NER] Pre-warming completed in 971ms - NER entities extracted
✅ [FLY.IO] NER refresh completed successfully
📤 Sending audio packet seq=100 size=372
📤 Sending audio packet seq=200 size=372
throwing -10877
throwing -10877
🔥 [SYSTEM-WARMUP] TempKeyCache warmup integration
🚀 [PREFETCH] Starting background temp key prefetch
📤 Sending audio packet seq=300 size=372
🌐 [ASR BREAKDOWN] Total: 945ms | Client↔Proxy: 97ms | Proxy↔Soniox: 848ms | Network: 848ms
🗑️ Evicted oldest temp key to maintain cache size limit
💾 Cached temp key for languages: ["zh", "en"]
🗓️ [TTL-SCHEDULE] Scheduling temp key refresh for key=global in 3000s (expiresAt=2025-08-21 01:57:20 +0000)
✅ [PREFETCH] Successfully prefetched temp key
🔥 [COLD-START] URLSession configured with extended timeouts
✅ [COLD-START] Warm-up complete with network stack optimization
t=010805 sess=EAR lvl=INFO cat=transcript evt=raw_final text="Hey, are we losing the first bit of audio still?<end>"
throwing -10877
throwing -10877
📤 Sending audio packet seq=400 size=372
📤 Sending audio packet seq=500 size=372
📤 Sending audio packet seq=600 size=372
t=013564 sess=EAR lvl=INFO cat=transcript evt=raw_final text=" So, fucking weird.<end>"
📤 Sending audio packet seq=700 size=372
🎯 [STATE MACHINE] Event: userCancelled in state: handsFreeLocked(since: 2025-08-21 00:57:15 +0000)
🎯 [STATE MACHINE] Cleared all cooldowns
🎯 [STATE MACHINE] Commands: ["cancelTimers", "clearCooldowns", "playSound(Clio.SoundType.cancel)", "markCancelled", "stopRecording", "hideUI", "updateUI(Clio.RecorderViewModel(isRecording: false, isHandsFreeLocked: false, isAttemptingToRecord: false, isVisualizerActive: false, sessionStateDescription: \"idle\", canTranscribe: true))"]
🎯 [STATE MACHINE] Event: userCancelled in state: idle
🎯 [STATE MACHINE] Cleared all cooldowns
🔊 [SoundManager] Attempting to play esc sound (with fade)
🎯 [STATE MACHINE] Commands: ["cancelTimers", "clearCooldowns", "hideUI", "playSound(Clio.SoundType.cancel)", "updateUI(Clio.RecorderViewModel(isRecording: false, isHandsFreeLocked: false, isAttemptingToRecord: false, isVisualizerActive: false, sessionStateDescription: \"idle\", canTranscribe: true))"]
🔍 [DYNAMIC NOTCH DEBUG] Hiding notch...
📱 Dismissing recorder
🛑 Stopping Clio streaming transcription
🏥 [AUDIO HEALTH] Health monitoring timer stopped
🧊 [WARMUP] Skipping warm-socket hold (rapid restart suppression)
🛑 Stopping unified audio capture
t=015005 sess=EAR lvl=INFO cat=audio evt=record_stop
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key plugInPackage
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key CMIOType
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key numberOfDevices
t=015015 sess=EAR lvl=INFO cat=audio evt=avcapture_stop
✅ Unified audio capture stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
📉 Released connection for account account-bundle (connections: 0)
💾 [COLD-START] Updated successful streaming timestamp
✅ Streaming stopped. Final transcript (67 chars, 8.7s, without audio file): "Hey, are we losing the first bit of audio still? So, fucking weird."
t=015021 sess=EAR lvl=INFO cat=transcript evt=final text="Hey, are we losing the first bit of audio still? So, fucking weird."
t=015021 sess=EAR lvl=INFO cat=transcript evt=session_end divider="────────── session end ──────────"
✅ [AUDIO HEALTH] First audio data received - tap is functional
🔍 [DYNAMIC NOTCH DEBUG] Hidden notch