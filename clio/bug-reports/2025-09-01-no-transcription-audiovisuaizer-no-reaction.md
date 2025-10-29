Failure (2 transcripts)

📱 Showing DynamicNotch recorder (MIT licensed)
🎤 Registering audio tap for SonioxPreview
t=3277905 sess=06U lvl=INFO cat=audio evt=record_start service=SonioxPreview
🔍 Performing audio system pre-flight checks
throwing -10877
throwing -10877
✅ Pre-flight checks passed
t=3277991 sess=06U lvl=INFO cat=audio evt=tap_install ok=true backend=avcapture service=SonioxPreview
t=3277991 sess=06U lvl=INFO cat=audio evt=record_start reason=start_capture
t=3277992 sess=06U lvl=INFO cat=audio evt=device_pin_start prev_uid_hash=-3940942547441473505 prev_id=177 desired_name=PalabraSpeaker desired_id=177 prev_name=PalabraSpeaker desired_uid_hash=-3940942547441473505
❄️ Cold start detected - performing full initialization
❄️ Performing cold start initialization
⏭️ Skipping engine cold start (backend=AVCapture)
🔥 [WARMUP] ensureReady() invoked context=recorderUIShown
🔥 [SYSTEM-WARMUP] TempKeyCache warmup integration
🚀 [PREFETCH] Starting background temp key prefetch
t=3278021 sess=06U lvl=INFO cat=audio evt=capture_backend_selected backend=avcapture
✅ Unified audio capture started
GenerativeModelsAvailability.Parameters: Initialized with invalid language code: zh-CN. Expected to receive two-letter ISO 639 code. e.g. 'zh' or 'en'. Falling back to: zh
AFIsDeviceGreymatterEligible Missing entitlements for os_eligibility lookup
t=3278061 sess=06U lvl=INFO cat=audio evt=avcapture_start ok=true
🎤 [toggleRecord] Starting recording, current model: soniox-realtime-streaming
🧊 [WARMUP] Skipping (recently run) context=hotkeyDown
🎙️ Starting recording sequence...
📝 [GRACE] Recording session started with 0 words remaining
🔧 [NER-SETUP] Setting up callback - contextService exists: true
✅ [NER-SETUP] OCR completion callback configured for NER pre-warming - callback exists: true
📊 [SESSION] Starting recording session #12
🧪 [A/B] warm_socket=yes
🎤 Registering audio tap for Soniox
t=3278141 sess=06U lvl=INFO cat=audio evt=record_start service=Soniox
🔍 Performing audio system pre-flight checks
throwing -10877
throwing -10877
✅ Pre-flight checks passed
t=3278197 sess=06U lvl=INFO cat=audio evt=tap_install service=Soniox ok=true backend=avcapture
⚡ Audio capture already active
🔌 Unregistering audio tap for SonioxPreview
⚠️ No tap registered for SonioxPreview
✅ Selected account account-bundle (connections: 1/10)
🧠 [TEN-VAD] Initialized (threshold=0.5, hop=256)
🚀 Starting Clio streaming transcription
🎬 Starting screen capture with verified permissions
🎯 Clio — codex-aarch64-apple-darwin ◂ node /opt/homebrew/bin/codex — 99×37
🌐 Using selected languages for OCR: zh-Hans, en-US
🏥 [AUDIO HEALTH] Health monitoring timer started
⏱️ [TIMING] mic_engaged @ 1756706042.852
t=3278259 sess=06U lvl=INFO cat=stream evt=first_audio_buffer_captured ms=27
🌐 [CONNECT] New single-flight request from start
pass
t=3278260 sess=06U lvl=WARN cat=audio evt=silence_detected threshold_db=-50 device_uid_hash=-3940942547441473505 device_id=177 duration_s=3 device_name=PalabraSpeaker
✅ [AUDIO HEALTH] First audio data received - tap is functional
🌐 [CONNECT] Attempt #20 (loop 1/3) starting…
t=3278265 sess=06U lvl=INFO cat=stream evt=temp_key_fetch_start
⚡ [CACHE-HIT] Retrieved temp key in 0.1ms
t=3278265 sess=06U lvl=INFO cat=stream evt=temp_key_fetch source=cached expires_in_s=-1 latency_ms=0
🌐 [WS CONNECT] Using URL: wss://stt-rt.soniox.com/transcribe-websocket
🔗 [WS] Bound socket id=sock_1456830508807327516@attempt_20
t=3278284 sess=06U lvl=INFO cat=stream evt=ws_bind target_ip=resolving... via_proxy=false path=/transcribe-websocket socket=sock_1456830508807327516@attempt_20 attempt=20 target_host=stt-rt.soniox.com
🔑 Successfully connected to Soniox using temp key (20ms key latency)
t=3278285 sess=06U lvl=INFO cat=stream evt=ws_bind_resolved target_host=stt-rt.soniox.com socket=sock_1456830508807327516@attempt_20 target_ip=129.146.176.251 via_proxy=false attempt=20 path=/transcribe-websocket
🌐 [ASR TEMPKEY] client_total=336ms | client↔proxy=80ms | server↔soniox=256ms | server_net=255ms
🗑️ Evicted oldest temp key to maintain cache size limit
💾 Cached temp key for languages: ["en", "zh"]
🗓️ [TTL-SCHEDULE] Scheduling temp key refresh for key=global in 3000s (expiresAt=2025-09-01 06:54:02 +0000)
✅ [PREFETCH] Successfully prefetched temp key
🎤 [WARMUP] Pre-warming audio system...
✅ [PREWARM] Device enumeration completed
✅ [PREWARM] Audio system pre-warming completed successfully
✅ [WARMUP] Audio system pre-warmed successfully
🔍 Found 44 text observations
✅ Text extraction successful: 1381 chars, 1381 non-whitespace, 181 words from 44 observations
✅ Captured text successfully
✅ [CAPTURE DEBUG] Screen capture successful: 1507 characters
💾 [SMART-CACHE] Cached new context: com.apple.Terminal|Clio — codex-aarch64-apple-darwin ◂ node /opt/homebrew/bin/codex — 99×37 (1507 chars)
🎯 [CALLBACK DEBUG] Executing callback with fresh content (1507 chars)
🔥 [PREWARM DEBUG] Pre-warming AI connection (target: Gemini), environment: flyio
🔥 [NER-TRIGGER] OCR completion callback triggered with fresh content
🎦 [NER-PREWARM] Using raw OCR text for NER: 1507 characters
🎯 [RULE-ENGINE] Detected: Code Review
💻 [NER-DETECT] Detected code context for NER (source=\(latest.source.displayName), conf=\(String(format: "%.2f", latest.confidence)))
🧠 [NER-CODE] Using code NER prompt (\(codeNER.count) chars)
🧠 [NER-CODE-FULL] Code NER System Prompt: \(codeNER)
t=3279778 sess=06U lvl=INFO cat=stream evt=ws_handshake_metrics reused=false protocol=http/1.1 total_ms=1511 socket=sock_1456830508807327516@attempt_20 connect_ms=1110 proxy=false tls_ms=1109 dns_ms=0 attempt=20
🔌 WebSocket did open (sid=sock_1456830508807327516, attemptId=20)
🌐 [CONNECT] Attempt #20 succeeded
📤 [START] Sent start/config text frame (attemptId=20, socketId=sock_1456830508807327516@attempt_20, start_text_sent=true)
🔌 [READY] attemptId=20 socketId=sock_1456830508807327516@attempt_20 start_text_sent=true
🔌 WebSocket ready after 1548ms - buffered 1.7s of audio
📦 Flushing 159 buffered packets (1.7s of audio, 54378 bytes)
⏱️ [TIMING] WebSocket connect task completed — will flush after READY
📤 Sent buffered packet 0/159 seq=0 size=342
📤 Sent buffered packet 158/159 seq=158 size=342
📦 Flushing 1 additional packets that arrived during flush
✅ Buffer flush complete
⏹️ Keepalive timer stopped
🔄 Keepalive timer started (interval: 15.000000s)
👂 [LISTENER] Starting listener task for socketId=sock_1456830508807327516@attempt_20 attemptId=20
📤 Sending text frame seq=25572
t=3279798 sess=06U lvl=INFO cat=stream evt=first_audio_sent ms=1565 seq=160
🤖 [FLY.IO-NER] Server-reported provider: gemini
📥 [NER-STORE] Stored NER entities: 718 chars - FULL TEXT: ```json
{
  "context_summary": "The user is working within the Terminal application, specifically on a Node.js process related to 'codex'. They are reviewing code changes in a file named PostEnhancementFormatter.swift, which appears to be part of the Clio application. The changes involve text normalization, including handling of dashes and potentially Chinese characters, and the implementation of a feature flag to control paragraph splitting logic.",
  "classes": [
    "PostEnhancementFormatter"
  ],
  "files": [
    "./Clio/Clio/Services/Text/PostEnhancementFormatter.swift"
  ],
  "function_names": [
    "normalize"
  ],
  "variables": [
    "isParagraphSplitEnabled"
  ],
  "products": [
    "Clio"
  ]
}
```
✅ [FLY.IO] NER refresh completed successfully
throwing -10877
throwing -10877
throwing -10877
throwing -10877
throwing -10877
throwing -10877
💓 Sent keepalive (active)
throwing -10877
throwing -10877
🧊 [WARMUP] Skipping (recently run) context=reachabilityChange
throwing -10877
throwing -10877
throwing -10877
throwing -10877
💓 Sent keepalive (active)
🔊 [SoundManager] Attempting to play esc sound (with fade)
📱 Dismissing recorder
🛑 Stopping Clio streaming transcription
🏥 [AUDIO HEALTH] Health monitoring timer stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
🛑 Stopping unified audio capture
t=3310867 sess=06U lvl=INFO cat=audio evt=record_stop
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key plugInPackage
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key CMIOType
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key numberOfDevices
t=3310894 sess=06U lvl=INFO cat=audio evt=avcapture_stop
✅ Unified audio capture stopped
⚡ Audio capture already stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
📉 Released connection for account account-bundle (connections: 0)
💾 [COLD-START] Updated successful streaming timestamp
💾 [COLD-START] Updated successful streaming timestamp
✅ Streaming stopped. Final transcript (0 chars, 32.7s, without audio file): ""
🌡️ [WARM] warm_socket=yes
t=3310924 sess=06U lvl=INFO cat=transcript evt=final text=
t=3310924 sess=06U lvl=INFO cat=transcript evt=session_end divider="────────── session end ──────────"
⏹️ Keepalive timer stopped
🔌 [WS] Closed (code 1001) during standby/shutdown (sid=sock_1456830508807327516, attemptId=20)
t=3310926 sess=06U lvl=INFO cat=stream evt=state state=closed code=1001
⏹️ Send cancelled — pausing queue (seq=28645, queue_len=1)
🔌 [WS] Disconnected (socketId=sock_1456830508807327516@attempt_20)
🌐 [CONNECT] New single-flight request from warmHold
🌐 [CONNECT] Attempt #21 (loop 1/2) starting…
t=3310977 sess=06U lvl=INFO cat=stream evt=temp_key_fetch_start
⚡ [CACHE-HIT] Retrieved temp key in 29.2ms
t=3311006 sess=06U lvl=INFO cat=stream evt=temp_key_fetch source=cached latency_ms=29 expires_in_s=-1
🌐 [WS CONNECT] Using URL: wss://stt-rt.soniox.com/transcribe-websocket
🔗 [WS] Bound socket id=sock_-8314635571227182550@attempt_21
t=3311007 sess=06U lvl=INFO cat=stream evt=ws_bind via_proxy=false socket=sock_-8314635571227182550@attempt_21 target_host=stt-rt.soniox.com attempt=21 target_ip=resolving... path=/transcribe-websocket
🔑 Successfully connected to Soniox using temp key (30ms key latency)
t=3311008 sess=06U lvl=INFO cat=stream evt=ws_bind_resolved socket=sock_-8314635571227182550@attempt_21 target_ip=129.146.176.251 via_proxy=false path=/transcribe-websocket attempt=21 target_host=stt-rt.soniox.com
t=3312442 sess=06U lvl=INFO cat=stream evt=ws_handshake_metrics attempt=21 total_ms=1435 socket=sock_-8314635571227182550@attempt_21 connect_ms=1034 proxy=false dns_ms=1 tls_ms=1033 reused=false protocol=http/1.1
🔌 WebSocket did open (sid=sock_-8314635571227182550, attemptId=21)
📤 [START] Sent start/config on standby socket (eager mode)
🌐 [CONNECT] Attempt #21 succeeded
📤 Sending text frame seq=28646
🧊 [STANDBY] Connected standby socket — keepalive every 10.0s, TTL=60s (attempt=21, socket=sock_-8314635571227182550@attempt_21)
🔌 [READY] attemptId=21 socketId=sock_-8314635571227182550@attempt_21 start_text_sent=true
🧊 [STANDBY] WebSocket ready in 1469ms (handshake)
👂 [LISTENER] Standby listener task for socketId=sock_-8314635571227182550@attempt_21 attemptId=21
📱 Showing DynamicNotch recorder (MIT licensed)
🎤 Registering audio tap for SonioxPreview
t=3329920 sess=06U lvl=INFO cat=audio evt=record_start service=SonioxPreview
🔍 Performing audio system pre-flight checks
throwing -10877
throwing -10877
✅ Pre-flight checks passed
t=3330004 sess=06U lvl=INFO cat=audio evt=tap_install service=SonioxPreview ok=true backend=avcapture
t=3330004 sess=06U lvl=INFO cat=audio evt=record_start reason=start_capture
t=3330005 sess=06U lvl=INFO cat=audio evt=device_pin_start desired_uid_hash=-3940942547441473505 prev_uid_hash=-3940942547441473505 prev_name=PalabraSpeaker desired_id=177 prev_id=177 desired_name=PalabraSpeaker
t=3330007 sess=06U lvl=INFO cat=audio evt=capture_backend_selected backend=avcapture
✅ Unified audio capture started
🔥 [WARMUP] ensureReady() invoked context=recorderUIShown
🔥 [SYSTEM-WARMUP] TempKeyCache warmup integration
🚀 [PREFETCH] Starting background temp key prefetch
t=3330040 sess=06U lvl=INFO cat=audio evt=avcapture_start ok=true
🎤 [toggleRecord] Starting recording, current model: soniox-realtime-streaming
🧊 [WARMUP] Skipping (recently run) context=hotkeyDown
🎙️ Starting recording sequence...
📝 [GRACE] Recording session started with 0 words remaining
🔧 [NER-SETUP] Setting up callback - contextService exists: true
✅ [NER-SETUP] OCR completion callback configured for NER pre-warming - callback exists: true
📊 [SESSION] Starting recording session #13
🧪 [A/B] warm_socket=yes
🧊➡️🔥 [STANDBY->ACTIVE] Consuming standby socket for new utterance
⏭️ [STANDBY->ACTIVE] START already sent on standby (eager) — skipping re-send
✅ [STANDBY->ACTIVE] Probe keepalive OK — proceeding to resume queue
⏹️ Keepalive timer stopped
🔄 Keepalive timer started (interval: 15.000000s)
🧪 [PROMO] snapshot attempt=21 socket=sock_-8314635571227182550@attempt_21 start_sent=true ws_ready=true standby=false purpose=active cap_sr=16000 cap_ch=1 prebuf=9 last_fp=m=stt-rt-preview-v2|sr=16000|ch=1|h=en,zh|ctx=6003518689133571000
t=3330162 sess=06U lvl=INFO cat=stream evt=temp_key_fetch_start
🎬 Starting screen capture with verified permissions
⚡ [CACHE-HIT] Retrieved temp key in 0.4ms
t=3330162 sess=06U lvl=INFO cat=stream evt=temp_key_fetch source=cached expires_in_s=-1 latency_ms=0
🧪 [PROMO] config_fp current=m=stt-rt-preview-v2|sr=16000|ch=1|h=en,zh|ctx=6003518689133571000 last=m=stt-rt-preview-v2|sr=16000|ch=1|h=en,zh|ctx=6003518689133571000
🎤 Registering audio tap for Soniox
t=3330163 sess=06U lvl=INFO cat=audio evt=record_start service=Soniox
🔍 Performing audio system pre-flight checks
🎯 Clio — PostEnhancementFormatter.swift
🌐 Using selected languages for OCR: zh-Hans, en-US
throwing -10877
throwing -10877
✅ Pre-flight checks passed
t=3330225 sess=06U lvl=INFO cat=audio evt=tap_install ok=true service=Soniox backend=avcapture
⚡ Audio capture already active
🔌 Unregistering audio tap for SonioxPreview
⚠️ No tap registered for SonioxPreview
✅ Selected account account-bundle (connections: 1/10)
🧠 [TEN-VAD] Initialized (threshold=0.5, hop=256)
🚀 Starting Clio streaming transcription
🏥 [AUDIO HEALTH] Health monitoring timer started
⏱️ [TIMING] mic_engaged @ 1756706094.882
⏱️ [TIMING] WebSocket connect task completed — will flush after READY
pass
t=3330315 sess=06U lvl=INFO cat=stream evt=first_audio_buffer_captured ms=29
🧪 [PROMO] first_audio seq=0 bytes=342 approx_db=-60.0
✅ [AUDIO HEALTH] First audio data received - tap is functional
t=3330316 sess=06U lvl=INFO cat=stream evt=first_audio_sent seq=1 ms=30
🌐 [ASR TEMPKEY] client_total=331ms | client↔proxy=72ms | server↔soniox=259ms | server_net=259ms
🗑️ Evicted oldest temp key to maintain cache size limit
💾 Cached temp key for languages: ["en", "zh"]
🗓️ [TTL-SCHEDULE] Scheduling temp key refresh for key=global in 3000s (expiresAt=2025-09-01 06:54:54 +0000)
✅ [PREFETCH] Successfully prefetched temp key
🎤 [WARMUP] Pre-warming audio system...
✅ [PREWARM] Device enumeration completed
✅ [PREWARM] Audio system pre-warming completed successfully
✅ [WARMUP] Audio system pre-warmed successfully
🧪 [PROMO] audio_bytes bytes=10260
throwing -10877
throwing -10877
🌐 [PATH] Initial path baseline set — no action
🔍 Found 125 text observations
✅ Text extraction successful: 2801 chars, 2801 non-whitespace, 295 words from 125 observations
✅ Captured text successfully
✅ [CAPTURE DEBUG] Screen capture successful: 2889 characters
💾 [SMART-CACHE] Cached new context: com.apple.dt.Xcode|Clio — PostEnhancementFormatter.swift (2889 chars)
🎯 [CALLBACK DEBUG] Executing callback with fresh content (2889 chars)
🔥 [PREWARM DEBUG] Pre-warming AI connection (target: Gemini), environment: flyio
🔥 [NER-TRIGGER] OCR completion callback triggered with fresh content
🎦 [NER-PREWARM] Using raw OCR text for NER: 2889 characters
🎯 [RULE-ENGINE] Detected: Code Review
💻 [NER-DETECT] Detected code context for NER (source=\(latest.source.displayName), conf=\(String(format: "%.2f", latest.confidence)))
🧠 [NER-CODE] Using code NER prompt (\(codeNER.count) chars)
🧠 [NER-CODE-FULL] Code NER System Prompt: \(codeNER)
🧪 [PROMO] audio_bytes bytes=30096
🤖 [FLY.IO-NER] Server-reported provider: gemini
📥 [NER-STORE] Stored NER entities: 2154 chars - FULL TEXT: ```json
{
  "context_summary": "The user is working within the Xcode application, specifically on a Swift file named 'PostEnhancementFormatter.swift' for the Clio project. They are likely reviewing or editing code related to text processing and enhancement, as indicated by the file name and the surrounding code snippets and logs.",
  "classes": [
    "PostEnhancementFormatter",
    "TextSplitOptions",
    "StateMachine",
    "SubscriptionManager",
    "WebSocketSendActor",
    "AIPrompts",
    "HotkeyManager",
    "AlEnhancementService",
    "UserProfileService",
    "UserStatsService",
    "WordReplacementService",
    "ContextService",
    "DynamicContextDetector",
    "LocalEntityExtractor",
    "PromptDetectionService",
    "PromptMigrationService",
    "ConnectionHealthMonitor",
    "KoyebKeepAlive",
    "KoyebRequestManager",
    "KoyebSessionManager",
    "RailwayKeepAlive",
    "TokenManager",
    "ChineseScriptConverter",
    "CleanerConfig",
    "DeterministicTextSplitter",
    "DisfluencyCleaner",
    "SmartDictionaryService",
    "SpeechToken",
    "OnboardingAudioManager",
    "PolarCheckoutService"
  ],
  "components": [
    "ViewModels",
    "Views",
    "Assets",
    "Frameworks",
    "Package Dependencies",
    "AppAuth",
    "AppCheck",
    "Filter"
  ],
  "function_names": [
    "apply"
  ],
  "files": [
    "PostEnhancementFormatter.swift",
    "Clio.code-workspace",
    "Clio-Bridging-Header.h"
  ],
  "frameworks": [
    "Foundation"
  ],
  "packages": [
    "AppAuth 2.0.0",
    "AppCheck 11.2.0"
  ],
  "variables": [
    "isParagraphSplitEnabled"
  ],
  "services": [
    "ContextService",
    "PromptDetectionService",
    "PromptMigrationService",
    "UserProfileService",
    "UserStatsService",
    "WordReplacementService",
    "ConnectionHealthMonitor",
    "KoyebKeepAlive",
    "KoyebRequestManager",
    "KoyebSessionManager",
    "RailwayKeepAlive",
    "TokenManager",
    "ChineseScriptConverter",
    "SmartDictionaryService",
    "OnboardingAudioManager",
    "PolarCheckoutService",
    "AlEnhancementService"
  ],
  "products": [
    "Clio"
  ],
  "organizations": [],
  "people": []
}
```
✅ [FLY.IO] NER refresh completed successfully
🔊 [SoundManager] Attempting to play esc sound (with fade)
📱 Dismissing recorder
🛑 Stopping Clio streaming transcription
🏥 [AUDIO HEALTH] Health monitoring timer stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
🛑 Stopping unified audio capture
t=3334569 sess=06U lvl=INFO cat=audio evt=record_stop
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key plugInPackage
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key CMIOType
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key numberOfDevices
t=3334596 sess=06U lvl=INFO cat=audio evt=avcapture_stop
✅ Unified audio capture stopped
⚡ Audio capture already stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
📉 Released connection for account account-bundle (connections: 0)
💾 [COLD-START] Updated successful streaming timestamp
💾 [COLD-START] Updated successful streaming timestamp
🧪 [PROMO] no_tokens_before_stop bytes_sent=137484 queue_depth=0
✅ Streaming stopped. Final transcript (0 chars, 4.3s, without audio file): ""
t=3334631 sess=06U lvl=INFO cat=transcript evt=final text=
t=3334632 sess=06U lvl=INFO cat=transcript evt=session_end divider="────────── session end ──────────"
🌡️ [WARM] warm_socket=yes
⏹️ Keepalive timer stopped
🔌 [WS] Closed (code 1001) during standby/shutdown (sid=sock_-8314635571227182550, attemptId=21)
t=3334657 sess=06U lvl=INFO cat=stream evt=state state=closed code=1001
🔌 [WS] Disconnected (socketId=sock_-8314635571227182550@attempt_21)
🌐 [CONNECT] New single-flight request from warmHold
🌐 [CONNECT] Attempt #22 (loop 1/2) starting…
t=3334754 sess=06U lvl=INFO cat=stream evt=temp_key_fetch_start
⚡ [CACHE-HIT] Retrieved temp key in 0.2ms
t=3334755 sess=06U lvl=INFO cat=stream evt=temp_key_fetch latency_ms=0 source=cached expires_in_s=-1
🌐 [WS CONNECT] Using URL: wss://stt-rt.soniox.com/transcribe-websocket
🔗 [WS] Bound socket id=sock_-3773762161063972650@attempt_22
t=3334755 sess=06U lvl=INFO cat=stream evt=ws_bind via_proxy=false socket=sock_-3773762161063972650@attempt_22 path=/transcribe-websocket target_host=stt-rt.soniox.com target_ip=resolving... attempt=22
🔑 Successfully connected to Soniox using temp key (1ms key latency)
t=3334756 sess=06U lvl=INFO cat=stream evt=ws_bind_resolved target_ip=129.146.176.251 socket=sock_-3773762161063972650@attempt_22 attempt=22 via_proxy=false target_host=stt-rt.soniox.com path=/transcribe-websocket
t=3336081 sess=06U lvl=INFO cat=stream evt=ws_handshake_metrics reused=false attempt=22 total_ms=1324 proxy=false protocol=http/1.1 tls_ms=1004 socket=sock_-3773762161063972650@attempt_22 dns_ms=1 connect_ms=1006
🔌 WebSocket did open (sid=sock_-3773762161063972650, attemptId=22)
📤 [START] Sent start/config on standby socket (eager mode)
📤 Sending text frame seq=29049
🌐 [CONNECT] Attempt #22 succeeded
🧊 [STANDBY] Connected standby socket — keepalive every 10.0s, TTL=60s (attempt=22, socket=sock_-3773762161063972650@attempt_22)
🔌 [READY] attemptId=22 socketId=sock_-3773762161063972650@attempt_22 start_text_sent=true
🧊 [STANDBY] WebSocket ready in 1347ms (handshake)
📦 Flushing 18 buffered packets (0.2s of audio, 6156 bytes)
📤 Sent buffered packet 0/18 seq=402 size=342
📤 Sent buffered packet 17/18 seq=419 size=342
✅ Buffer flush complete
👂 [LISTENER] Standby listener task for socketId=sock_-3773762161063972650@attempt_22 attemptId=22



📱 Showing DynamicNotch recorder (MIT licensed)
🎤 Registering audio tap for SonioxPreview
t=005608 sess=SgB lvl=INFO cat=audio evt=record_start service=SonioxPreview
🔍 Performing audio system pre-flight checks
throwing -10877
throwing -10877
✅ Pre-flight checks passed
t=005699 sess=SgB lvl=INFO cat=audio evt=tap_install ok=true service=SonioxPreview backend=avcapture
t=005699 sess=SgB lvl=INFO cat=audio evt=record_start reason=start_capture
t=005700 sess=SgB lvl=INFO cat=audio evt=device_pin_start desired_id=177 prev_id=177 prev_uid_hash=3065854669433934240 desired_uid_hash=3065854669433934240 prev_name=PalabraSpeaker desired_name=PalabraSpeaker
❄️ Cold start detected - performing full initialization
🧊 [WARMUP] Skipping (recently run) context=recorderUIShown
❄️ Performing cold start initialization
⏭️ Skipping engine cold start (backend=AVCapture)
t=005759 sess=SgB lvl=INFO cat=audio evt=capture_backend_selected backend=avcapture
✅ Unified audio capture started
249091          HALC_ProxyIOContext.cpp:1622  HALC_ProxyIOContext::IOWorkLoop: skipping cycle due to overload
249091          HALC_ProxyIOContext.cpp:1622  HALC_ProxyIOContext::IOWorkLoop: skipping cycle due to overload
throwing -10877
throwing -10877
t=005928 sess=SgB lvl=INFO cat=audio evt=avcapture_start ok=true
🎤 [toggleRecord] Starting recording, current model: soniox-realtime-streaming
🧊 [WARMUP] Skipping (recently run) context=hotkeyDown
🎙️ Starting recording sequence...
📝 [GRACE] Recording session started with 0 words remaining
🔧 [NER-SETUP] Setting up callback - contextService exists: true
✅ [NER-SETUP] OCR completion callback configured for NER pre-warming - callback exists: true
📊 [SESSION] Starting recording session #1
🧪 [A/B] warm_socket=yes
🎤 Registering audio tap for Soniox
t=006012 sess=SgB lvl=INFO cat=audio evt=record_start service=Soniox
🔍 Performing audio system pre-flight checks
throwing -10877
throwing -10877
✅ Pre-flight checks passed
t=006070 sess=SgB lvl=INFO cat=audio evt=tap_install ok=true service=Soniox backend=avcapture
⚡ Audio capture already active
🔌 Unregistering audio tap for SonioxPreview
⚠️ No tap registered for SonioxPreview
✅ Selected account account-bundle (connections: 1/10)
🧠 [TEN-VAD] Initialized (threshold=0.5, hop=256)
🚀 Starting Clio streaming transcription
🎬 Starting screen capture with verified permissions
🎯 Clio — PostEnhancementFormatter.swift
🌐 Using selected languages for OCR: zh-Hans, en-US
🏥 [AUDIO HEALTH] Health monitoring timer started
⏱️ [TIMING] mic_engaged @ 1756706422.517
t=006129 sess=SgB lvl=INFO cat=stream evt=first_audio_buffer_captured ms=33
🆕 [COLD-START] First recording after app launch - applying background warm-up
🌐 [CONNECT] New single-flight request from start
pass
✅ [AUDIO HEALTH] First audio data received - tap is functional
🌐 [CONNECT] Attempt #1 (loop 1/3) starting…
t=006186 sess=SgB lvl=INFO cat=stream evt=temp_key_fetch_start
⚡ [CACHE-HIT] Retrieved temp key in 0.7ms
t=006186 sess=SgB lvl=INFO cat=stream evt=temp_key_fetch expires_in_s=-1 source=cached latency_ms=0
🌐 [WS CONNECT] Using URL: wss://stt-rt.soniox.com/transcribe-websocket
🔗 [WS] Bound socket id=sock_-7924840357464292526@attempt_1
t=006187 sess=SgB lvl=INFO cat=stream evt=ws_bind attempt=1 via_proxy=false target_ip=resolving... path=/transcribe-websocket target_host=stt-rt.soniox.com socket=sock_-7924840357464292526@attempt_1
t=006188 sess=SgB lvl=INFO cat=stream evt=ws_bind_resolved socket=sock_-7924840357464292526@attempt_1 attempt=1 target_ip=129.146.176.251 via_proxy=false path=/transcribe-websocket target_host=stt-rt.soniox.com
🔑 Successfully connected to Soniox using temp key (3ms key latency)
🔍 Found 130 text observations
✅ Text extraction successful: 2610 chars, 2610 non-whitespace, 287 words from 130 observations
✅ Captured text successfully
✅ [CAPTURE DEBUG] Screen capture successful: 2698 characters
💾 [SMART-CACHE] Cached new context: com.apple.dt.Xcode|Clio — PostEnhancementFormatter.swift (2698 chars)
🎯 [CALLBACK DEBUG] Executing callback with fresh content (2698 chars)
🔥 [PREWARM DEBUG] Pre-warming AI connection (target: Gemini), environment: flyio
🔥 [NER-TRIGGER] OCR completion callback triggered with fresh content
🎦 [NER-PREWARM] Using raw OCR text for NER: 2698 characters
🎯 [RULE-ENGINE] Detected: Code Review
💻 [NER-DETECT] Detected code context for NER (source=\(latest.source.displayName), conf=\(String(format: "%.2f", latest.confidence)))
🧠 [NER-CODE] Using code NER prompt (\(codeNER.count) chars)
🧠 [NER-CODE-FULL] Code NER System Prompt: \(codeNER)
🔥 [COLD-START] Pre-warming connection pool
t=007617 sess=SgB lvl=INFO cat=stream evt=ws_handshake_metrics dns_ms=0 socket=sock_-7924840357464292526@attempt_1 connect_ms=1118 total_ms=1429 protocol=http/1.1 attempt=1 reused=false proxy=false tls_ms=1115
🔌 WebSocket did open (sid=sock_-7924840357464292526, attemptId=1)
🌐 [CONNECT] Attempt #1 succeeded
⏱️ [TIMING] WebSocket connect task completed — will flush after READY
📤 [START] Sent start/config text frame (attemptId=1, socketId=sock_-7924840357464292526@attempt_1, start_text_sent=true)
🔌 [READY] attemptId=1 socketId=sock_-7924840357464292526@attempt_1 start_text_sent=true
🔌 WebSocket ready after 1523ms - buffered 1.8s of audio
📦 Flushing 165 buffered packets (1.8s of audio, 56430 bytes)
📤 Sent buffered packet 0/165 seq=0 size=342
📤 Sent buffered packet 164/165 seq=164 size=342
✅ Buffer flush complete
⏹️ Keepalive timer stopped
🔄 Keepalive timer started (interval: 15.000000s)
👂 [LISTENER] Starting listener task for socketId=sock_-7924840357464292526@attempt_1 attemptId=1
📤 Sending text frame seq=0
t=007624 sess=SgB lvl=INFO cat=stream evt=first_audio_sent ms=1528 seq=165
⏭️ [SYSTEM-WARMUP] Skipping audio warmup (backend=AVCapture)
🔥 [SYSTEM-WARMUP] Warming up network connections
✅ [SYSTEM-WARMUP] JWT token pre-fetched
🔥 [SYSTEM-WARMUP] TempKeyCache warmup integration
🚀 [PREFETCH] Starting background temp key prefetch
🤖 [FLY.IO-NER] Server-reported provider: gemini
📥 [NER-STORE] Stored NER entities: 2068 chars - FULL TEXT: ```json
{
  "context_summary": "The user is working within the Xcode application, specifically on a Swift file named PostEnhancementFormatter.swift. This file appears to be part of the Clio project, which focuses on speech dictation and enhancement. The user is likely reviewing or modifying code related to text processing, formatting, and potentially integrating with various services like context detection, prompt handling, and network communication.",
  "classes": [
    "PostEnhancementFormatter",
    "TextSplitOptions",
    "ContextService",
    "DynamicContextDetector",
    "LocalEntityExtractor",
    "PromptDetectionService",
    "PromptMigrationService",
    "UserProfileService",
    "UserStatsService",
    "WordReplacementService",
    "ConnectionHealthMonitor",
    "KoyebKeepAlive",
    "KoyebRequestManager",
    "KoyebSessionManager",
    "RailwayKeepAlive",
    "TokenManager",
    "ChineseScriptConverter",
    "CleanerConfig",
    "DeterministicTextSplitter",
    "DisfluencyCleaner",
    "SmartDictionaryService",
    "SpeechToken",
    "OnboardingAudioManager",
    "PolarCheckoutService",
    "StateMachine",
    "Utils",
    "ViewModels",
    "Whisper",
    "Assets",
    "WebSocketSendActor",
    "SubscriptionManager",
    "HotkeyManager",
    "AIEnhancementService",
    "AIPrompts"
  ],
  "function_names": [
    "apply",
    "normalize"
  ],
  "files": [
    "PostEnhancementFormatter.swift",
    "Clio.code-workspace",
    "Clio-Bridging-Header.h",
    "HALC_ProxyIOContext.cpp"
  ],
  "frameworks": [
    "Foundation"
  ],
  "packages": [
    "AppAuth",
    "AppCheck"
  ],
  "variables": [
    "isParagraphSplitEnabled",
    "targetWordCountPerParagraph"
  ],
  "services": [
    "ContextService",
    "PromptDetectionService",
    "PromptMigrationService",
    "UserProfileService",
    "UserStatsService",
    "WordReplacementService",
    "SmartDictionaryService",
    "OnboardingAudioManager",
    "PolarCheckoutService",
    "AIEnhancementService"
  ],
  "products": [
    "Clio"
  ],
  "organizations": [
    "Soniox"
  ]
}
```
✅ [FLY.IO] NER refresh completed successfully
t=009141 sess=SgB lvl=WARN cat=audio evt=silence_detected threshold_db=-50 device_uid_hash=3065854669433934240 device_name=PalabraSpeaker duration_s=3 device_id=177
🌐 [ASR TEMPKEY] client_total=330ms | client↔proxy=74ms | server↔soniox=255ms | server_net=255ms
🗑️ Evicted oldest temp key to maintain cache size limit
💾 Cached temp key for languages: ["zh", "en"]
🗓️ [TTL-SCHEDULE] Scheduling temp key refresh for key=global in 3000s (expiresAt=2025-09-01 07:00:25 +0000)
✅ [PREFETCH] Successfully prefetched temp key
🔥 [COLD-START] URLSession configured with extended timeouts
✅ [COLD-START] Warm-up complete with network stack optimization
throwing -10877
throwing -10877
throwing -10877
throwing -10877
throwing -10877
throwing -10877
💓 Sent keepalive (active)
🔊 [SoundManager] Attempting to play esc sound (with fade)
📱 Dismissing recorder
🛑 Stopping Clio streaming transcription
🏥 [AUDIO HEALTH] Health monitoring timer stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
🛑 Stopping unified audio capture
t=023079 sess=SgB lvl=INFO cat=audio evt=record_stop
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key plugInPackage
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key CMIOType
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key numberOfDevices
t=023107 sess=SgB lvl=INFO cat=audio evt=avcapture_stop
✅ Unified audio capture stopped
⚡ Audio capture already stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
📉 Released connection for account account-bundle (connections: 0)
💾 [COLD-START] Updated successful streaming timestamp
💾 [COLD-START] Updated successful streaming timestamp
✅ Streaming stopped. Final transcript (0 chars, 17.0s, without audio file): ""
🌡️ [WARM] warm_socket=yes
t=023135 sess=SgB lvl=INFO cat=transcript evt=final text=
t=023135 sess=SgB lvl=INFO cat=transcript evt=session_end divider="────────── session end ──────────"
⏹️ Keepalive timer stopped
🔌 [WS] Closed (code 1001) during standby/shutdown (sid=sock_-7924840357464292526, attemptId=1)
t=023165 sess=SgB lvl=INFO cat=stream evt=state code=1001 state=closed
🔌 [WS] Disconnected (socketId=sock_-7924840357464292526@attempt_1)
🌐 [CONNECT] New single-flight request from warmHold
🌐 [CONNECT] Attempt #2 (loop 1/2) starting…
t=023267 sess=SgB lvl=INFO cat=stream evt=temp_key_fetch_start
⚡ [CACHE-HIT] Retrieved temp key in 29.3ms
t=023296 sess=SgB lvl=INFO cat=stream evt=temp_key_fetch source=cached latency_ms=29 expires_in_s=-1
🌐 [WS CONNECT] Using URL: wss://stt-rt.soniox.com/transcribe-websocket
🔗 [WS] Bound socket id=sock_-2664310520223002029@attempt_2
t=023297 sess=SgB lvl=INFO cat=stream evt=ws_bind target_host=stt-rt.soniox.com socket=sock_-2664310520223002029@attempt_2 via_proxy=false path=/transcribe-websocket attempt=2 target_ip=resolving...
🔑 Successfully connected to Soniox using temp key (30ms key latency)
t=023298 sess=SgB lvl=INFO cat=stream evt=ws_bind_resolved target_ip=129.146.176.251 target_host=stt-rt.soniox.com via_proxy=false path=/transcribe-websocket socket=sock_-2664310520223002029@attempt_2 attempt=2
t=024650 sess=SgB lvl=INFO cat=stream evt=ws_handshake_metrics connect_ms=1054 total_ms=1352 protocol=http/1.1 reused=false attempt=2 proxy=false socket=sock_-2664310520223002029@attempt_2 tls_ms=1052 dns_ms=0
🔌 WebSocket did open (sid=sock_-2664310520223002029, attemptId=2)
📤 [START] Sent start/config on standby socket (eager mode)
🌐 [CONNECT] Attempt #2 succeeded
📤 Sending text frame seq=1616
🧊 [STANDBY] Connected standby socket — keepalive every 10.0s, TTL=60s (attempt=2, socket=sock_-2664310520223002029@attempt_2)
🔌 [READY] attemptId=2 socketId=sock_-2664310520223002029@attempt_2 start_text_sent=true
🧊 [STANDBY] WebSocket ready in 1386ms (handshake)
👂 [LISTENER] Standby listener task for socketId=sock_-2664310520223002029@attempt_2 attemptId=2