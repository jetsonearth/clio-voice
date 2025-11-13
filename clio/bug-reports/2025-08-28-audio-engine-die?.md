
✅ Streaming transcription completed successfully, length: 27 characters
✅ Streaming stopped. Final transcript (27 chars, 8.5s, with audio file): "我准备测试一个新的版本, 它会去到哪个中间的那个空格。"
🌡️ [WARM] warm_socket=yes
⏱️ [TIMING] Subscription tracking: 0.6ms
t=080070 sess=tam lvl=INFO cat=transcript evt=final text="我准备测试一个新的版本, 它会去到哪个中间的那个空格。"
⏱️ [TIMING] ASR word tracking: 0.0ms
🧠 Performing intelligent end-context detection for streaming
⏱️ [CONTEXT DETAIL] Cache check: 0.0ms
⚡ [SMART-OPTIMIZATION] Using smart cached screen context (979 chars) - skipping new capture
⏱️ [STREAMING CONTEXT TIMING] Screen capture + context detection: 0.1ms
t=080073 sess=tam lvl=INFO cat=transcript evt=session_end divider="────────── session end ──────────"
🔊 [SoundManager] Attempting to play stop sound
🔊 [SoundManager] NSSound stop sound result: true
🧹 Connection cleanup completed (session resources released)
📝 [GRACE] Recording session ended
📱 Dismissing recorder
⏹️ Keepalive timer stopped
⚠️ WebSocket did close with code 1001 (sid=sock_-7369324225094977507, attemptId=4)
t=080183 sess=tam lvl=WARN cat=stream evt=state code=1001 state=closed
✅ Streaming transcription processing completed
t=080225 sess=tam lvl=INFO cat=transcript evt=insert_attempt target=WeChat text="我准备测试一个新的版本, 它会去到哪个中间的那个空格。 " chars=28
🔍 [PASTE DEBUG] AXIsProcessTrusted() returned true, proceeding
🔍 [PASTE DEBUG] UseDirectTextInsertion setting: false
🔍 [PASTE DEBUG] Direct insertion disabled, using clipboard paste
⌨️ Using CGEvent-based Command+V
t=080226 sess=tam lvl=INFO cat=transcript evt=insert_result ok=true
📊 [POST-RELEASE E2E] 821ms (finalize=623ms | paste=0ms) | warm_socket=no
🔌 [WS] Disconnected (socketId=sock_-7369324225094977507@attempt_4)
🌐 [CONNECT] New single-flight request from warmHold
🌐 [CONNECT] Attempt #5 (loop 1/2) starting…
t=080478 sess=tam lvl=INFO cat=stream evt=temp_key_fetch_start
⚡ [CACHE-HIT] Retrieved temp key in 0.1ms
t=080479 sess=tam lvl=INFO cat=stream evt=temp_key_fetch latency_ms=0 expires_in_s=-1 source=cached
🌐 [WS CONNECT] Using URL: wss://stt-rt.soniox.com/transcribe-websocket
🔗 [WS] Bound socket id=sock_-4857443974369053993@attempt_5
t=080479 sess=tam lvl=INFO cat=stream evt=ws_bind socket=sock_-4857443974369053993@attempt_5 attempt=5 path=/transcribe-websocket target_host=stt-rt.soniox.com target_ip=resolving... via_proxy=false
🔑 Successfully connected to Soniox using temp key (4ms key latency)
t=080484 sess=tam lvl=INFO cat=stream evt=ws_bind_resolved socket=sock_-4857443974369053993@attempt_5 attempt=5 path=/transcribe-websocket target_host=stt-rt.soniox.com target_ip=129.146.176.251 via_proxy=false
t=081922 sess=tam lvl=INFO cat=stream evt=ws_handshake_metrics socket=sock_-4857443974369053993@attempt_5 dns_ms=1 connect_ms=1111 tls_ms=1110 total_ms=1441 proxy=false reused=false protocol=http/1.1 attempt=5
🔌 WebSocket did open (sid=sock_-4857443974369053993, attemptId=5)
📤 [START] Sent start/config on standby socket (eager mode)
📤 Sending text frame seq=2258
🌐 [CONNECT] Attempt #5 succeeded
🧊 [STANDBY] Connected standby socket — keepalive every 10.0s, TTL=60s (attempt=5, socket=sock_-4857443974369053993@attempt_5)
🔌 [READY] attemptId=5 socketId=sock_-4857443974369053993@attempt_5 start_text_sent=true
🧊 [STANDBY] WebSocket ready in 1446ms (handshake)
👂 [LISTENER] Standby listener task for socketId=sock_-4857443974369053993@attempt_5 attemptId=5
💤 [STANDBY] keepalive_tick
t=091926 sess=tam lvl=INFO cat=stream evt=standby_keepalive_tick
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
📊 [SESSION] Starting recording session #5
🧪 [A/B] warm_socket=yes
🧊➡️🔥 [STANDBY->ACTIVE] Consuming standby socket for new utterance
⏭️ [STANDBY->ACTIVE] START already sent on standby (eager) — skipping re-send
♻️ [SMART-CACHE] Using cached context: 979 characters
🔥 [NER-CACHE] Triggering NER callback with cached content (979 chars)
✅ [NER-CACHE] NER callback triggered with cached content
✅ [STANDBY->ACTIVE] Probe keepalive OK — proceeding to resume queue
⏹️ Keepalive timer stopped
🔄 Keepalive timer started (interval: 15.000000s)
🧪 [PROMO] snapshot attempt=5 socket=sock_-4857443974369053993@attempt_5 start_sent=true ws_ready=true standby=false purpose=active cap_sr=16000 cap_ch=1 prebuf=0 last_fp=m=stt-rt-preview-v2|sr=16000|ch=1|h=en,zh|ctx=7250312277565852139
t=101393 sess=tam lvl=INFO cat=stream evt=temp_key_fetch_start
🔥 [PREWARM DEBUG] Pre-warming AI connection (target: Gemini), environment: flyio
⚡ [CACHE-HIT] Retrieved temp key in 0.7ms
t=101394 sess=tam lvl=INFO cat=stream evt=temp_key_fetch latency_ms=0 expires_in_s=-1 source=cached
🧪 [PROMO] config_fp current=m=stt-rt-preview-v2|sr=16000|ch=1|h=en,zh|ctx=7250312277565852139 last=m=stt-rt-preview-v2|sr=16000|ch=1|h=en,zh|ctx=7250312277565852139
🎤 Registering audio tap for Soniox
t=101401 sess=tam lvl=INFO cat=audio evt=record_start service=Soniox
🔍 Performing audio system pre-flight checks
throwing -10877
throwing -10877
✅ Pre-flight checks passed
t=101482 sess=tam lvl=INFO cat=audio evt=tap_install service=Soniox ok=true backend=avcapture
t=101482 sess=tam lvl=INFO cat=audio evt=record_start reason=start_capture
t=101482 sess=tam lvl=INFO cat=audio evt=device_pin_start prev_id=181 desired_id=181 prev_name="MacBook Pro Microphone" prev_uid_hash=406926317792165891 desired_name="MacBook Pro Microphone" desired_uid_hash=406926317792165891
t=101482 sess=tam lvl=INFO cat=audio evt=capture_backend_selected backend=avcapture
✅ Unified audio capture started
✅ Selected account account-bundle (connections: 1/10)
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
🎦 [NER-PREWARM] Using raw OCR text for NER: 979 characters
🎦 [NER-INPUT-FULL] Full OCR Text Being Sent to NER: Active Window: Weixin
Application: WeChat
Window Content:
Q
Search
YC
难的是把这个用户体验打磨好
十
00:56
YC
具体的用户体验设计我还没有想好，比如说我在，如果说我的，比如我的
西班牙语并不是很好，但我有一个西班牙语的朋友，然后我想跟他用西班
牙语对话，或者可能就是外貌场景的时候，很多中国人他们可以去使用一
个第二语言，第三语言能接触到更多的客户。
Alvin 之友［Al+］学习交流群
00:30
［4］Cruise： ［Link］ PH Notify 下线了？别慌….
BFA的AI大脑
Yesterday 23:46
［2］小文：我的搭档晓丹的作品！一个温情小.
叫我有做外贸的朋友，他们有的时候要用英文，但很多人思考的时候更使
用native language 在思考嘛。那比如说我可以对着我的voice agent
说出中文，然后我想要什么，我想要表达什么，它如果能自然地变成英文
发出去。
Voice Agent开发者2R...
lip：听了一下，印象比较深刻是，
K
Yesterday 23:38
11labs的tran...
Yesterday 23:26
哦对，这个在我的feature list里面。
方便的话明天白天可以聊一下
其实很简单，做出来。
dontbesilent 聊赚钱的群
Yesterday 23:13
yanliang： 咱们群里有小红书号商么，求推...
嗯嗯 功能不难
RTE Meetup：全球化拓..
傅丰元：［Chat History］
Yesterday 22:47
换个prompt就好了，你可以设置一个新的快捷键之类的。
难的是把这个用户体验打磨好
AI语音客服 | RTE Dev ...
傅丰元：［Chat History］
Yesterday 22:47
8~
二
Voice Agent 开发者
R...
傅丰元 RTE 开发者社区：［Chat History］
Yesterday 22:47
0830华侨城活动临时群
“狮子先生•谢训“邀请"Ben"加入了群聊
Yesterday 22:29
Official Accounts
Yesterday 22:12
丁香医生：从息肉到癌症！5 种常见息肉，真正…
🎯 [RULE-ENGINE] Cache hit for com.tencent.xinWeChat|||Weixin
📧 [EMAIL] Starting email context detection
❌ [EMAIL] No title matches and confidence not high enough: 0.000000
💻 [CODE] Starting code context detection
❌ [CODE] Code confidence too low: 0.000000 < 0.300000
💬 [CHAT] Starting casual chat context detection
❌ [CHAT] Chat confidence too low: 0.040000 < 0.100000
📝 [REGISTRY] Rule engine returned .none and no high-confidence legacy matches, returning general context
🧠 [NER-DEFAULT] Using strict JSON NER prompt (default)
🧠 [NER-DEFAULT-FULL] Default NER System Prompt: You are an expert Named Entity Recognition (NER) system. Extract ONLY meaningful entities from the input and output STRICT JSON suitable for downstream prompting.  Return EXACTLY one minified JSON object with these keys (all present): {   "people": string[],   "organizations": string[],   "products": string[],   "projects": string[],   "apps": string[],   "services": string[],   "places": string[], }  Rules: - JSON only. No markdown, no prose, no explanations. - Values are unique, trimmed strings, 1–6 words, preserve original casing. - Exclude generic nouns, URLs, and broad topics. - If a category has no items, use an empty array. - Use the same language as the detected entities.
🧠 [TEN-VAD] Initialized (threshold=0.5, hop=256)
🚀 Starting Clio streaming transcription
t=101720 sess=tam lvl=INFO cat=audio evt=avcapture_start ok=true
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
t=101727 sess=tam lvl=INFO cat=stream evt=first_audio_buffer_captured ms=0
🏥 [AUDIO HEALTH] Health monitoring timer started
⏱️ [TIMING] mic_engaged @ 1756313898.289
⏱️ [TIMING] WebSocket connect task completed — will flush after READY
pass
🧪 [PROMO] first_audio seq=0 bytes=360 approx_db=-52.6
✅ [AUDIO HEALTH] First audio data received - tap is functional
t=101753 sess=tam lvl=INFO cat=stream evt=first_audio_sent seq=0 ms=27
🧪 [PROMO] audio_bytes bytes=10032
🌐 [ASR TEMPKEY] client_total=878ms | client↔proxy=86ms | server↔soniox=791ms | server_net=790ms
🗑️ Evicted oldest temp key to maintain cache size limit
💾 Cached temp key for languages: ["en", "zh"]
🗓️ [TTL-SCHEDULE] Scheduling temp key refresh for key=global in 3000s (expiresAt=2025-08-27 17:58:18 +0000)
✅ [PREFETCH] Successfully prefetched temp key
🎤 [WARMUP] Pre-warming audio system...
✅ [PREWARM] Device enumeration completed
✅ [PREWARM] Audio system pre-warming completed successfully
✅ [WARMUP] Audio system pre-warmed successfully
🌐 [PATH] Initial path baseline set — no action
🗣️ [TEN-VAD] Speech start detected
🧪 [PROMO] audio_bytes bytes=30120
🤖 [FLY.IO-NER] Server-reported provider: gemini
📥 [NER-STORE] Stored NER entities: 327 chars - FULL TEXT: ```json
{
  "people": [
    "Alvin",
    "傅丰元",
    "狮子先生•谢训",
    "Ben"
  ],
  "organizations": [
    "Weixin",
    "RTE Dev",
    "RTE Developer Community",
    "丁香医生"
  ],
  "products": [
    "WeChat"
  ],
  "projects": [
    "PH Notify"
  ],
  "apps": [],
  "services": [
    "AI语音客服"
  ],
  "places": [
    "西班牙"
  ]
}
```
✅ [FLY.IO] NER refresh completed successfully
throwing -10877
throwing -10877
t=103980 sess=tam lvl=INFO cat=stream evt=first_partial ms=2254
t=103981 sess=tam lvl=INFO cat=stream evt=ttft_hotkey ms=2254
t=103981 sess=tam lvl=INFO cat=stream evt=ttft ms=1589
🧪 [PROMO] first_token ms=2587 tokens_in_msg=1
🛑 Stopping recording
🛑 Stopping Clio streaming transcription
🏥 [AUDIO HEALTH] Health monitoring timer stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
🛑 Stopping unified audio capture
t=104717 sess=tam lvl=INFO cat=audio evt=record_stop
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key plugInPackage
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key CMIOType
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key numberOfDevices
t=104726 sess=tam lvl=INFO cat=audio evt=avcapture_stop
✅ Unified audio capture stopped
📤 Sent end-of-stream signal
📤 Sent manual finalize command
🕐 Using finalization timeout: 1000ms (connection took 3214ms)
ℹ️ [OPTIMISTIC] Not skipping: end=false pending=0 ms_since_last=133 tail=100 silence_ok=true tokens_quiet_ok=false partial_empty=false uncond=false
t=105281 sess=tam lvl=INFO cat=stream evt=first_final ms=3555
t=105282 sess=tam lvl=INFO cat=transcript evt=raw_final text=我现在马上要更新了。<end>
🏁 Received <fin> token - finalization complete
✅ Received <fin> token after 495ms
⚡ Audio capture already stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
📉 Released connection for account account-bundle (connections: 0)
💾 [COLD-START] Updated successful streaming timestamp
💾 [COLD-START] Updated successful streaming timestamp
✅ Streaming stopped. Final transcript (10 chars, 3.7s, with audio file): "我现在马上要更新了。"
✅ Streaming transcription completed successfully, length: 10 characters
🌡️ [WARM] warm_socket=yes
⏱️ [TIMING] Subscription tracking: 0.4ms
⏱️ [TIMING] ASR word tracking: 0.0ms
🧠 Performing intelligent end-context detection for streaming
⏱️ [CONTEXT DETAIL] Cache check: 0.0ms
⚡ [SMART-OPTIMIZATION] Using smart cached screen context (979 chars) - skipping new capture
⏱️ [STREAMING CONTEXT TIMING] Screen capture + context detection: 0.0ms
t=105438 sess=tam lvl=INFO cat=transcript evt=final text=我现在马上要更新了。
t=105438 sess=tam lvl=INFO cat=transcript evt=session_end divider="────────── session end ──────────"
🔊 [SoundManager] Attempting to play stop sound
🔊 [SoundManager] NSSound stop sound result: true
🧹 Connection cleanup completed (session resources released)
📝 [GRACE] Recording session ended
📱 Dismissing recorder
⏹️ Keepalive timer stopped
⚠️ WebSocket did close with code 1001 (sid=sock_-4857443974369053993, attemptId=5)
t=105489 sess=tam lvl=WARN cat=stream evt=state code=1001 state=closed
✅ Streaming transcription processing completed
🔌 [WS] Disconnected (socketId=sock_-4857443974369053993@attempt_5)
t=105547 sess=tam lvl=INFO cat=transcript evt=insert_attempt chars=11 target=WeChat text="我现在马上要更新了。 "
🔍 [PASTE DEBUG] AXIsProcessTrusted() returned true, proceeding
🔍 [PASTE DEBUG] UseDirectTextInsertion setting: false
🔍 [PASTE DEBUG] Direct insertion disabled, using clipboard paste
⌨️ Using CGEvent-based Command+V
t=105547 sess=tam lvl=INFO cat=transcript evt=insert_result ok=true
📊 [POST-RELEASE E2E] 855ms (finalize=676ms | paste=0ms) | warm_socket=no
🌐 [CONNECT] New single-flight request from warmHold
🌐 [CONNECT] Attempt #6 (loop 1/2) starting…
t=105745 sess=tam lvl=INFO cat=stream evt=temp_key_fetch_start
⚡ [CACHE-HIT] Retrieved temp key in 0.2ms
t=105745 sess=tam lvl=INFO cat=stream evt=temp_key_fetch expires_in_s=-1 latency_ms=0 source=cached
🌐 [WS CONNECT] Using URL: wss://stt-rt.soniox.com/transcribe-websocket
🔗 [WS] Bound socket id=sock_1281444412104287250@attempt_6
t=105745 sess=tam lvl=INFO cat=stream evt=ws_bind via_proxy=false target_ip=resolving... attempt=6 target_host=stt-rt.soniox.com path=/transcribe-websocket socket=sock_1281444412104287250@attempt_6
🔑 Successfully connected to Soniox using temp key (1ms key latency)
t=105747 sess=tam lvl=INFO cat=stream evt=ws_bind_resolved target_ip=129.146.176.251 via_proxy=false socket=sock_1281444412104287250@attempt_6 path=/transcribe-websocket attempt=6 target_host=stt-rt.soniox.com
t=107304 sess=tam lvl=INFO cat=stream evt=ws_handshake_metrics socket=sock_1281444412104287250@attempt_6 connect_ms=1238 dns_ms=1 proxy=false protocol=http/1.1 reused=false attempt=6 total_ms=1556 tls_ms=1236
🔌 WebSocket did open (sid=sock_1281444412104287250, attemptId=6)
📤 [START] Sent start/config on standby socket (eager mode)
📤 Sending text frame seq=2517
🌐 [CONNECT] Attempt #6 succeeded
🧊 [STANDBY] Connected standby socket — keepalive every 10.0s, TTL=60s (attempt=6, socket=sock_1281444412104287250@attempt_6)
🔌 [READY] attemptId=6 socketId=sock_1281444412104287250@attempt_6 start_text_sent=true
🧊 [STANDBY] WebSocket ready in 1599ms (handshake)
👂 [LISTENER] Standby listener task for socketId=sock_1281444412104287250@attempt_6 attemptId=6
💤 [STANDBY] keepalive_tick
t=117314 sess=tam lvl=INFO cat=stream evt=standby_keepalive_tick
💤 [STANDBY] keepalive_tick
t=127315 sess=tam lvl=INFO cat=stream evt=standby_keepalive_tick
💤 [STANDBY] keepalive_tick
t=137313 sess=tam lvl=INFO cat=stream evt=standby_keepalive_tick
💤 [STANDBY] keepalive_tick
t=147316 sess=tam lvl=INFO cat=stream evt=standby_keepalive_tick
💤 [STANDBY] keepalive_tick
t=157315 sess=tam lvl=INFO cat=stream evt=standby_keepalive_tick
⏱️ [STANDBY] TTL reached (60s) — closing standby socket
⏹️ Keepalive timer stopped
💤 [STANDBY] keepalive_tick
⚠️ WebSocket did close with code 1001 (sid=sock_1281444412104287250, attemptId=6)
t=167316 sess=tam lvl=INFO cat=stream evt=standby_keepalive_tick
🔌 [WS] Disconnected (socketId=sock_1281444412104287250@attempt_6)
t=167318 sess=tam lvl=WARN cat=stream evt=state code=1001 state=closed
❌ WebSocket receive error: The operation couldn’t be completed. Socket is not connected
nw_read_request_report [C2] Receive failed with error "Operation timed out"
nw_read_request_report [C2] Receive failed with error "Operation timed out"
nw_read_request_report [C2] Receive failed with error "Operation timed out"
nw_endpoint_flow_fillout_data_transfer_snapshot copy_info() returned NULL
nw_read_request_report [C5] Receive failed with error "Operation timed out"
nw_read_request_report [C5] Receive failed with error "Operation timed out"
nw_read_request_report [C5] Receive failed with error "Operation timed out"
nw_endpoint_flow_fillout_data_transfer_snapshot copy_info() returned NULL
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
📊 [SESSION] Starting recording session #6
🧪 [A/B] warm_socket=yes
🎤 Registering audio tap for Soniox
t=193086 sess=tam lvl=INFO cat=audio evt=record_start service=Soniox
🔍 Performing audio system pre-flight checks
throwing -10877
throwing -10877
✅ Pre-flight checks passed
t=193168 sess=tam lvl=INFO cat=audio evt=tap_install ok=true backend=avcapture service=Soniox
t=193168 sess=tam lvl=INFO cat=audio evt=record_start reason=start_capture
t=193168 sess=tam lvl=INFO cat=audio evt=device_pin_start prev_id=181 desired_uid_hash=406926317792165891 prev_uid_hash=406926317792165891 prev_name="MacBook Pro Microphone" desired_id=181 desired_name="MacBook Pro Microphone"
❄️ Cold start detected - performing full initialization
❄️ Performing cold start initialization
⏭️ Skipping engine cold start (backend=AVCapture)
🎬 Starting screen capture with verified permissions
t=193203 sess=tam lvl=INFO cat=audio evt=capture_backend_selected backend=avcapture
✅ Unified audio capture started
✅ Selected account account-bundle (connections: 1/10)
🧠 [TEN-VAD] Initialized (threshold=0.5, hop=256)
🚀 Starting Clio streaming transcription
🎯 RecordingEngine.swift — clio-project (Workspace)
🌐 Using selected languages for OCR: zh-Hans, en-US
🏥 [AUDIO HEALTH] Health monitoring timer started
⏱️ [TIMING] mic_engaged @ 1756313990.517
🌐 [CONNECT] New single-flight request from start
pass
🌐 [CONNECT] Attempt #7 (loop 1/3) starting…
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
t=193395 sess=tam lvl=INFO cat=stream evt=temp_key_fetch_start
t=193395 sess=tam lvl=INFO cat=audio evt=avcapture_start ok=true
t=193395 sess=tam lvl=INFO cat=stream evt=first_audio_buffer_captured ms=146
⚡ [CACHE-HIT] Retrieved temp key in 1.4ms
t=193396 sess=tam lvl=INFO cat=stream evt=temp_key_fetch expires_in_s=-1 source=cached latency_ms=1
🌐 [WS CONNECT] Using URL: wss://stt-rt.soniox.com/transcribe-websocket
t=193397 sess=tam lvl=WARN cat=audio evt=silence_detected device_id=181 threshold_db=-50 device_name="MacBook Pro Microphone" device_uid_hash=406926317792165891 duration_s=3
✅ [AUDIO HEALTH] First audio data received - tap is functional
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
🔗 [WS] Bound socket id=sock_-8884088925980639199@attempt_7
t=193428 sess=tam lvl=INFO cat=stream evt=ws_bind target_ip=resolving... attempt=7 socket=sock_-8884088925980639199@attempt_7 via_proxy=false target_host=stt-rt.soniox.com path=/transcribe-websocket
🔑 Successfully connected to Soniox using temp key (33ms key latency)
t=193429 sess=tam lvl=INFO cat=stream evt=ws_bind_resolved attempt=7 target_host=stt-rt.soniox.com target_ip=129.146.176.251 path=/transcribe-websocket via_proxy=false socket=sock_-8884088925980639199@attempt_7
throwing -10877
throwing -10877
🗣️ [TEN-VAD] Speech start detected
🌐 [ASR TEMPKEY] client_total=914ms | client↔proxy=93ms | server↔soniox=821ms | server_net=821ms
🗑️ Evicted oldest temp key to maintain cache size limit
💾 Cached temp key for languages: ["en", "zh"]
🗓️ [TTL-SCHEDULE] Scheduling temp key refresh for key=global in 3000s (expiresAt=2025-08-27 17:59:51 +0000)
✅ [PREFETCH] Successfully prefetched temp key
🎤 [WARMUP] Pre-warming audio system...
✅ [PREWARM] Device enumeration completed
✅ [PREWARM] Audio system pre-warming completed successfully
✅ [WARMUP] Audio system pre-warmed successfully
🔍 Found 180 text observations
✅ Text extraction successful: 3417 chars, 3417 non-whitespace, 382 words from 180 observations
✅ Captured text successfully
✅ [CAPTURE DEBUG] Screen capture successful: 3514 characters
💾 [SMART-CACHE] Cached new context: com.todesktop.230313mzl4w4u92|RecordingEngine.swift — clio-project (Workspace) (3514 chars)
🎯 [CALLBACK DEBUG] Executing callback with fresh content (3514 chars)
🔥 [PREWARM DEBUG] Pre-warming AI connection (target: Gemini), environment: flyio
🔥 [NER-TRIGGER] OCR completion callback triggered with fresh content
🎦 [NER-PREWARM] Using raw OCR text for NER: 3514 characters
🎦 [NER-INPUT-FULL] Full OCR Text Being Sent to NER: Active Window: RecordingEngine.swift — clio-project (Workspace)
Application: Cursor
Window Content:
•
8o
⑦
v clio-project
v Clio
< Clio
> Assets
> Assets.xcassets
>Config
> Core
> Localization
> Managers
> Models
> Preview Content
> Resources
> Services
> StateMachine
> Utils
> ViewModels
> Views
~ Whisper
y LibWhisper.swift
PredefinedModelsShim.swift
StreamingTextCache.swift
TranscriptionEngine.swift
TranscriptionManager.swift
y WhisperPrompt.swift
> RecordingEngine.swift
RecordingEngine+ModelManager.swift
4 RecordingEngine+Ul.swift
4 RecordingEngineErrorShim.swift
以 WhisperTextFormatter.swift
y WhisperVAD.swift
Clio-Bridging-Header.h
｛｝ Clio.code-workspace
>Clio.xcodeproj
> ClioTests
> ClioUITests
> docs
>friday-tutorial
>Image
〉 NOTEPADS
OUTLINE
RecordingEngine.swift — clio-project （Workspace）
D
Investigating warn
Evaluate
染
ement.md
f mcp.json
Js polar.js
clio-project >Clio >Clio >Whisper〉
> RecordingEngine.swift
#endif
y PolarService.swift
LicensePageView.swift
RecordingEngine.swift M
980
1559
1668
1670
> ner
Aa山.*11of20
个
=×
private func handleStreamingTranscriptionComple
if let enhancementService = enhancementService，
enhancementservice. 1sConfigured.！..........
'OI
｝ else｛
contextCaptureLatencyMs = 0.0
logger.notice（"e
［STREAMING CONTEXT TIMING］ End context
disabled for performance - using pal
© 1Tab
Probably going to make changes to the
ConnectionResilientStreamingService' file and
the 'SonioxStreamingService'.And then we'||
take a look at the temp key cache.
1684
1685
1686
1687
1688
1689
1690
1691
1692
1693
// Simple heuristic: skip enhancement for very short utterances （applies to Soniox streaming onl
Let shouldSkipEnhancement: Bool = ｛
Let wc = TextUtils.countWords （in: originalText）
let
dur
= actualDuration
return wc < 20 || dur < 11
1694
｝（）
1695
1696
1697
1698
1699
1700
1701
1702
1703
shouldCancelRecording ｛ await dismissRecorder（）；enhancementService？.cleanupConnection（）；ret
if shouldSkipEnhancement ｛
// Persist raw ASR without enhancement
Let newTranscription = Transcription（
text: originalText，
duration: actuatDuration，
audioFileURL: audioFileURL，
processingLatencyMs: streamingLatencyMs
1704
1705
1706
1707
1708
1709
1710
modelContext. insert （newTranscription）
try? modelContext.save（）
text = originalText
｝ else if let enhancementService = enhancementService，
enhancementService.isE
Review next file 〉
Led，
enhancementService.isC.
1711
dn
Problems
Output
Debug Console
Terminal
Ports
bash-Clio 十
（use "git
restore <file>..." to discard changes in working directory）
modified：
Clio/Services/AL/sonLoXstreamLnobervLce.SwuTu
modified：
Clio/Services/AI/TranscriptionBuffer.swift
modified：
Clio/Views/Recorder/DynamicNotchWindowManager.swift
modified：
Clio/Whisper/RecordingEngine.swift
no changes added to commit （use "git add" and/or "'git commit -a"）
（base）
ZhaobangJetwu（feature/ensure-synchronous-root-rendering-with-placehoLder-content-for-windowgroup-dock-menu-restore-20
250823-160006
Clio
•$g1t
add.
ZhaobangJetwu （feature/ensure-synchronous-root-rendering-with-placeholder-content-for-windowgroup-dock-menu-restore-20_
250823-160006
Clio
o＄git
commit -m
∞ 8I、
gpt-5$2
• Send to Background
Past Chats ~
Fix app initialization issue on launch
Evaluate clipboard method for race conditions
Investigating warm reuse socket failures
View AIl
1h
1h
2h
∞ Agents
Clio feature/ensure-synchronous-root-rendering-with-placeholder-content-for-windowgroup-dock-menu-restore-2025082C
K to generate a commana
⑧1A94
9 Not Committed Yet （Staged）
Screen Reader Optimized
Ln 1693, Col 39
Spaces: 4
C
🎯 [RULE-ENGINE] Detected: Code Review
💻 [NER-DETECT] Detected code context for NER (source=\(latest.source.displayName), conf=\(String(format: "%.2f", latest.confidence)))
🧠 [NER-CODE] Using code NER prompt (\(codeNER.count) chars)
🧠 [NER-CODE-FULL] Code NER System Prompt: \(codeNER)
t=194795 sess=tam lvl=INFO cat=stream evt=ws_handshake_metrics proxy=false tls_ms=1082 dns_ms=0 protocol=http/1.1 socket=sock_-8884088925980639199@attempt_7 attempt=7 connect_ms=1082 reused=false total_ms=1398
🔌 WebSocket did open (sid=sock_-8884088925980639199, attemptId=7)
🌐 [CONNECT] Attempt #7 succeeded
📤 [START] Sent start/config text frame (attemptId=7, socketId=sock_-8884088925980639199@attempt_7, start_text_sent=true)
🔌 [READY] attemptId=7 socketId=sock_-8884088925980639199@attempt_7 start_text_sent=true
🔌 WebSocket ready after 1548ms - buffered 1.5s of audio
📦 Flushing 132 buffered packets (1.5s of audio, 49080 bytes)
⏱️ [TIMING] WebSocket connect task completed — will flush after READY
📤 Sent buffered packet 0/132 seq=0 size=372
📤 Sent buffered packet 131/132 seq=131 size=372
✅ Buffer flush complete
⏱️ [SPEECH-WATCHDOG] Arming watchdog: deadline=2.000000s attempt=7
🧪 [PROMO] speech_watchdog_arm attempt=7 speaking=true bytes_threshold=10000 gates isStreaming=true ws_ready=true start_sent=true hasTokens=false
⏹️ Keepalive timer stopped
🔄 Keepalive timer started (interval: 15.000000s)
👂 [LISTENER] Starting listener task for socketId=sock_-8884088925980639199@attempt_7 attemptId=7
📤 Sending text frame seq=2518
t=194798 sess=tam lvl=INFO cat=stream evt=first_audio_sent seq=132 ms=1550
t=196015 sess=tam lvl=INFO cat=stream evt=first_partial ms=2767
t=196015 sess=tam lvl=INFO cat=stream evt=ttft_hotkey ms=2767
t=196015 sess=tam lvl=INFO cat=stream evt=ttft ms=2308
🛑 [SPEECH-WATCHDOG] Cancelled
🤖 [FLY.IO-NER] Server-reported provider: gemini
📥 [NER-STORE] Stored NER entities: 1051 chars - FULL TEXT: {"classes": ["RecordingEngine", "Transcription", "DynamicNotchWindowManager"], "components": [], "function names": ["handleStreamingTranscriptionComple", "shouldSkipEnhancement"], "files": ["RecordingEngine.swift", "LibWhisper.swift", "PredefinedModelsShim.swift", "StreamingTextCache.swift", "TranscriptionEngine.swift", "TranscriptionManager.swift", "WhisperPrompt.swift", "RecordingEngine+ModelManager.swift", "RecordingEngine+Ul.swift", "RecordingEngineErrorShim.swift", "WhisperTextFormatter.swift", "WhisperVAD.swift", "Clio-Bridging-Header.h", "PolarService.swift", "LicensePageView.swift", "mcp.json", "polar.js"], "frameworks": [], "packages": [], "variables": ["enhancementService", "contextCaptureLatencyMs", "originalText", "actualDuration", "streamingLatencyMs", "modelContext", "newTranscription", "audioFileURL", "wc", "dur", "shouldCancelRecording", "shouldSkipEnhancement", "text"], "services": ["PolarService", "ConnectionResilientStreamingService", "SonioxStreamingService"], "products": ["Clio"], "people": ["ZhaobangJetwu"], "organizations": []}
✅ [FLY.IO] NER refresh completed successfully
🛑 Stopping recording
🛑 Stopping Clio streaming transcription
🏥 [AUDIO HEALTH] Health monitoring timer stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
🛑 Stopping unified audio capture
t=196458 sess=tam lvl=INFO cat=audio evt=record_stop
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key plugInPackage
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key CMIOType
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key numberOfDevices
t=196467 sess=tam lvl=INFO cat=audio evt=avcapture_stop
✅ Unified audio capture stopped
🧺 [DRAIN] Starting drain-before-finalize queued=9
✅ [DRAIN] Queue drained before finalize
📤 Sent end-of-stream signal
📤 Sent manual finalize command
🕐 Using finalization timeout: 1000ms (connection took 3582ms)
ℹ️ [OPTIMISTIC] Not skipping: end=false pending=0 ms_since_last=278 tail=100 silence_ok=true tokens_quiet_ok=false partial_empty=false uncond=false
t=196878 sess=tam lvl=INFO cat=stream evt=first_final ms=3630
t=196878 sess=tam lvl=INFO cat=transcript evt=raw_final text="Stable release for Clio.<end>"
🏁 Received <fin> token - finalization complete
✅ Received <fin> token after 424ms
⚡ Audio capture already stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
📉 Released connection for account account-bundle (connections: 0)
💾 [COLD-START] Updated successful streaming timestamp
💾 [COLD-START] Updated successful streaming timestamp
✅ Streaming transcription completed successfully, length: 24 characters
✅ Streaming stopped. Final transcript (24 chars, 4.0s, with audio file): "Stable release for Clio."
🌡️ [WARM] warm_socket=yes
⏱️ [TIMING] Subscription tracking: 0.5ms
t=197257 sess=tam lvl=INFO cat=transcript evt=final text="Stable release for Clio."
t=197258 sess=tam lvl=INFO cat=transcript evt=session_end divider="────────── session end ──────────"
⏱️ [TIMING] ASR word tracking: 0.0ms
🧠 Performing intelligent end-context detection for streaming
⏱️ [CONTEXT DETAIL] Cache check: 0.0ms
⚡ [SMART-OPTIMIZATION] Using smart cached screen context (3514 chars) - skipping new capture
⏱️ [STREAMING CONTEXT TIMING] Screen capture + context detection: 0.1ms
🔊 [SoundManager] Attempting to play stop sound
🔊 [SoundManager] NSSound stop sound result: true
🧹 Connection cleanup completed (session resources released)
📝 [GRACE] Recording session ended
📱 Dismissing recorder
⏹️ Keepalive timer stopped
⚠️ WebSocket did close with code 1001 (sid=sock_-8884088925980639199, attemptId=7)
t=197338 sess=tam lvl=WARN cat=stream evt=state state=closed code=1001
✅ Streaming transcription processing completed
t=197405 sess=tam lvl=INFO cat=transcript evt=insert_attempt target=Cursor chars=25 text="Stable release for Clio. "
🔍 [PASTE DEBUG] AXIsProcessTrusted() returned true, proceeding
🔍 [PASTE DEBUG] UseDirectTextInsertion setting: false
🔍 [PASTE DEBUG] Direct insertion disabled, using clipboard paste
⌨️ Using CGEvent-based Command+V
t=197408 sess=tam lvl=INFO cat=transcript evt=insert_result ok=true
📊 [POST-RELEASE E2E] 979ms (finalize=823ms | paste=0ms) | warm_socket=no
🔌 [WS] Disconnected (socketId=sock_-8884088925980639199@attempt_7)
🌐 [CONNECT] New single-flight request from warmHold
🌐 [CONNECT] Attempt #8 (loop 1/2) starting…
t=197626 sess=tam lvl=INFO cat=stream evt=temp_key_fetch_start
⚡ [CACHE-HIT] Retrieved temp key in 0.1ms
t=197626 sess=tam lvl=INFO cat=stream evt=temp_key_fetch source=cached latency_ms=0 expires_in_s=-1
🌐 [WS CONNECT] Using URL: wss://stt-rt.soniox.com/transcribe-websocket
🔗 [WS] Bound socket id=sock_-7021932807674281362@attempt_8
t=197627 sess=tam lvl=INFO cat=stream evt=ws_bind path=/transcribe-websocket target_host=stt-rt.soniox.com via_proxy=false attempt=8 target_ip=resolving... socket=sock_-7021932807674281362@attempt_8
🔑 Successfully connected to Soniox using temp key (1ms key latency)
t=197630 sess=tam lvl=INFO cat=stream evt=ws_bind_resolved target_host=stt-rt.soniox.com path=/transcribe-websocket via_proxy=false target_ip=129.146.176.251 socket=sock_-7021932807674281362@attempt_8 attempt=8
t=199038 sess=tam lvl=INFO cat=stream evt=ws_handshake_metrics proxy=false dns_ms=0 tls_ms=1088 reused=false socket=sock_-7021932807674281362@attempt_8 protocol=http/1.1 total_ms=1410 connect_ms=1090 attempt=8
🔌 WebSocket did open (sid=sock_-7021932807674281362, attemptId=8)
📤 [START] Sent start/config on standby socket (eager mode)
📤 Sending text frame seq=2795
🌐 [CONNECT] Attempt #8 succeeded
🧊 [STANDBY] Connected standby socket — keepalive every 10.0s, TTL=60s (attempt=8, socket=sock_-7021932807674281362@attempt_8)
🔌 [READY] attemptId=8 socketId=sock_-7021932807674281362@attempt_8 start_text_sent=true
🧊 [STANDBY] WebSocket ready in 1414ms (handshake)
👂 [LISTENER] Standby listener task for socketId=sock_-7021932807674281362@attempt_8 attemptId=8
💤 [STANDBY] keepalive_tick
t=209047 sess=tam lvl=INFO cat=stream evt=standby_keepalive_tick
💤 [STANDBY] keepalive_tick
t=219042 sess=tam lvl=INFO cat=stream evt=standby_keepalive_tick
💤 [STANDBY] keepalive_tick
t=229042 sess=tam lvl=INFO cat=stream evt=standby_keepalive_tick
💤 [STANDBY] keepalive_tick
t=239042 sess=tam lvl=INFO cat=stream evt=standby_keepalive_tick
💤 [STANDBY] keepalive_tick
t=249042 sess=tam lvl=INFO cat=stream evt=standby_keepalive_tick
⏱️ [STANDBY] TTL reached (60s) — closing standby socket
⏹️ Keepalive timer stopped
💤 [STANDBY] keepalive_tick
t=259043 sess=tam lvl=INFO cat=stream evt=standby_keepalive_tick
🔌 [WS] Disconnected (socketId=sock_-7021932807674281362@attempt_8)
⚠️ WebSocket did close with code 1001 (sid=sock_-7021932807674281362, attemptId=8)
t=259044 sess=tam lvl=WARN cat=stream evt=state code=1001 state=closed
❌ WebSocket receive error: The operation couldn’t be completed. Socket is not connected
🔥 [WARMUP] ensureReady() invoked context=reachabilityChange
🔥 [SYSTEM-WARMUP] TempKeyCache warmup integration
🚀 [PREFETCH] Starting background temp key prefetch
🌐 [ASR TEMPKEY] client_total=350ms | client↔proxy=91ms | server↔soniox=259ms | server_net=259ms
🗑️ Evicted oldest temp key to maintain cache size limit
💾 Cached temp key for languages: ["en", "zh"]
🗓️ [TTL-SCHEDULE] Scheduling temp key refresh for key=global in 3000s (expiresAt=2025-08-27 18:01:37 +0000)
✅ [PREFETCH] Successfully prefetched temp key
🎤 [WARMUP] Pre-warming audio system...
✅ [PREWARM] Device enumeration completed
✅ [PREWARM] AVCaptureSession pre-configured
✅ [PREWARM] Audio system pre-warming completed successfully
✅ [WARMUP] Audio system pre-warmed successfully
Unable to load .strings file: CFBundle 0x600001520000 </Users/ZhaobangJetWu/Library/Developer/Xcode/DerivedData/Clio-fnialateruaamwckdkitrckmjkkh/Build/Products/Debug/Clio.app> (executable, loaded) / Localizable: Error Domain=NSOSStatusErrorDomain Code=-10 "kCFURLUnknownError / dsMacsBugInstalled: "
📱 Showing DynamicNotch recorder (MIT licensed)
Unable to load .strings file: CFBundle 0x600001520000 </Users/ZhaobangJetWu/Library/Developer/Xcode/DerivedData/Clio-fnialateruaamwckdkitrckmjkkh/Build/Products/Debug/Clio.app> (executable, loaded) / Localizable: Error Domain=NSOSStatusErrorDomain Code=-10 "kCFURLUnknownError / dsMacsBugInstalled: "
🔥 [WARMUP] ensureReady() invoked context=recorderUIShown
🔥 [SYSTEM-WARMUP] TempKeyCache warmup integration
🚀 [PREFETCH] Starting background temp key prefetch
Unable to load .strings file: CFBundle 0x600001520000 </Users/ZhaobangJetWu/Library/Developer/Xcode/DerivedData/Clio-fnialateruaamwckdkitrckmjkkh/Build/Products/Debug/Clio.app> (executable, loaded) / Localizable: Error Domain=NSOSStatusErrorDomain Code=-10 "kCFURLUnknownError / dsMacsBugInstalled: "
Unable to load .strings file: CFBundle 0x600001520000 </Users/ZhaobangJetWu/Library/Developer/Xcode/DerivedData/Clio-fnialateruaamwckdkitrckmjkkh/Build/Products/Debug/Clio.app> (executable, loaded) / Localizable: Error Domain=NSOSStatusErrorDomain Code=-10 "kCFURLUnknownError / dsMacsBugInstalled: "
187715          HALC_ProxyIOContext.cpp:1622  HALC_ProxyIOContext::IOWorkLoop: skipping cycle due to overload
Unable to load .strings file: CFBundle 0x600001520000 </Users/ZhaobangJetWu/Library/Developer/Xcode/DerivedData/Clio-fnialateruaamwckdkitrckmjkkh/Build/Products/Debug/Clio.app> (executable, loaded) / Localizable: Error Domain=NSOSStatusErrorDomain Code=-10 "kCFURLUnknownError / dsMacsBugInstalled: "
🎤 [toggleRecord] Starting recording, current model: soniox-realtime-streaming
🧊 [WARMUP] Skipping (recently run) context=hotkeyDown
🎙️ Starting recording sequence...
📝 [GRACE] Recording session started with 2552 words remaining
🔧 [NER-SETUP] Setting up callback - contextService exists: true
✅ [NER-SETUP] OCR completion callback configured for NER pre-warming - callback exists: true
Unable to load .strings file: CFBundle 0x600001520000 </Users/ZhaobangJetWu/Library/Developer/Xcode/DerivedData/Clio-fnialateruaamwckdkitrckmjkkh/Build/Products/Debug/Clio.app> (executable, loaded) / Localizable: Error Domain=NSOSStatusErrorDomain Code=-10 "kCFURLUnknownError / dsMacsBugInstalled: "
📊 [SESSION] Starting recording session #7
🧪 [A/B] warm_socket=yes
🎤 Registering audio tap for Soniox
t=365163 sess=tam lvl=INFO cat=audio evt=record_start service=Soniox
🔍 Performing audio system pre-flight checks
throwing -10877
throwing -10877
      HALC_ShellObject.mm:615    HALC_ShellObject::SetPropertyData: call to the proxy failed, Error: 1852797029 (nope)
      HALC_ShellObject.mm:615    HALC_ShellObject::SetPropertyData: call to the proxy failed, Error: 1852797029 (nope)
✅ Pre-flight checks passed
t=365230 sess=tam lvl=INFO cat=audio evt=tap_install backend=avcapture ok=true service=Soniox
t=365230 sess=tam lvl=INFO cat=audio evt=record_start reason=start_capture
t=365230 sess=tam lvl=INFO cat=audio evt=device_pin_start prev_uid_hash=406926317792165891 prev_name="MacBook Pro Microphone" prev_id=181 desired_id=181 desired_name="MacBook Pro Microphone" desired_uid_hash=406926317792165891
❄️ Cold start detected - performing full initialization
Unable to load .strings file: CFBundle 0x600001520000 </Users/ZhaobangJetWu/Library/Developer/Xcode/DerivedData/Clio-fnialateruaamwckdkitrckmjkkh/Build/Products/Debug/Clio.app> (executable, loaded) / Localizable: Error Domain=NSOSStatusErrorDomain Code=-10 "kCFURLUnknownError / dsMacsBugInstalled: "
❄️ Performing cold start initialization
⏭️ Skipping engine cold start (backend=AVCapture)
🎬 Starting screen capture with verified permissions
t=365258 sess=tam lvl=INFO cat=audio evt=capture_backend_selected backend=avcapture
✅ Unified audio capture started
✅ Selected account account-bundle (connections: 1/10)
🧠 [TEN-VAD] Initialized (threshold=0.5, hop=256)
🚀 Starting Clio streaming transcription
🎯 Notifications | LinkedIn
🌐 Browser detected, using content-optimized capture settings
Unable to load .strings file: CFBundle 0x600001520000 </Users/ZhaobangJetWu/Library/Developer/Xcode/DerivedData/Clio-fnialateruaamwckdkitrckmjkkh/Build/Products/Debug/Clio.app> (executable, loaded) / Localizable: Error Domain=NSOSStatusErrorDomain Code=-10 "kCFURLUnknownError / dsMacsBugInstalled: "
🏥 [AUDIO HEALTH] Health monitoring timer started
⏱️ [TIMING] mic_engaged @ 1756314162.570
🌐 [CONNECT] New single-flight request from start
pass
Unable to load .strings file: CFBundle 0x600001520000 </Users/ZhaobangJetWu/Library/Developer/Xcode/DerivedData/Clio-fnialateruaamwckdkitrckmjkkh/Build/Products/Debug/Clio.app> (executable, loaded) / Localizable: Error Domain=NSOSStatusErrorDomain Code=-10 "kCFURLUnknownError / dsMacsBugInstalled: "
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
🌐 [CONNECT] Attempt #9 (loop 1/3) starting…
t=365327 sess=tam lvl=INFO cat=audio evt=avcapture_start ok=true
t=365327 sess=tam lvl=INFO cat=stream evt=first_audio_buffer_captured ms=29
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
t=365361 sess=tam lvl=INFO cat=stream evt=temp_key_fetch_start
✅ [AUDIO HEALTH] First audio data received - tap is functional
⚡ [CACHE-HIT] Retrieved temp key in 0.4ms
t=365362 sess=tam lvl=INFO cat=stream evt=temp_key_fetch latency_ms=0 expires_in_s=-1 source=cached
🌐 [WS CONNECT] Using URL: wss://stt-rt.soniox.com/transcribe-websocket
🔗 [WS] Bound socket id=sock_-5790295106748096174@attempt_9
t=365367 sess=tam lvl=INFO cat=stream evt=ws_bind target_ip=resolving... attempt=9 target_host=stt-rt.soniox.com via_proxy=false path=/transcribe-websocket socket=sock_-5790295106748096174@attempt_9
🔑 Successfully connected to Soniox using temp key (6ms key latency)
t=365368 sess=tam lvl=INFO cat=stream evt=ws_bind_resolved via_proxy=false socket=sock_-5790295106748096174@attempt_9 target_ip=129.146.176.251 attempt=9 path=/transcribe-websocket target_host=stt-rt.soniox.com
🌐 [ASR TEMPKEY] client_total=833ms | client↔proxy=83ms | server↔soniox=750ms | server_net=750ms
🗑️ Evicted oldest temp key to maintain cache size limit
💾 Cached temp key for languages: ["en", "zh"]
🗓️ [TTL-SCHEDULE] Scheduling temp key refresh for key=global in 3000s (expiresAt=2025-08-27 18:02:43 +0000)
✅ [PREFETCH] Successfully prefetched temp key
🎤 [WARMUP] Pre-warming audio system...
✅ [PREWARM] Device enumeration completed
✅ [PREWARM] Audio system pre-warming completed successfully
✅ [WARMUP] Audio system pre-warmed successfully
t=366771 sess=tam lvl=INFO cat=stream evt=ws_handshake_metrics tls_ms=1093 attempt=9 reused=false dns_ms=1 total_ms=1402 socket=sock_-5790295106748096174@attempt_9 protocol=http/1.1 connect_ms=1095 proxy=false
🔌 WebSocket did open (sid=sock_-5790295106748096174, attemptId=9)
🌐 [CONNECT] Attempt #9 succeeded
📤 [START] Sent start/config text frame (attemptId=9, socketId=sock_-5790295106748096174@attempt_9, start_text_sent=true)
🔌 [READY] attemptId=9 socketId=sock_-5790295106748096174@attempt_9 start_text_sent=true
🔌 WebSocket ready after 1474ms - buffered 1.5s of audio
📦 Flushing 126 buffered packets (1.5s of audio, 46848 bytes)
⏱️ [TIMING] WebSocket connect task completed — will flush after READY
📤 Sent buffered packet 0/126 seq=0 size=372
📤 Sent buffered packet 125/126 seq=125 size=372
📦 Flushing 1 additional packets that arrived during flush
✅ Buffer flush complete
⏹️ Keepalive timer stopped
🔄 Keepalive timer started (interval: 15.000000s)
👂 [LISTENER] Starting listener task for socketId=sock_-5790295106748096174@attempt_9 attemptId=9
📤 Sending text frame seq=2796
t=366787 sess=tam lvl=INFO cat=stream evt=first_audio_sent ms=1489 seq=127
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
🛑 Stopping recording
Unable to load .strings file: CFBundle 0x600001520000 </Users/ZhaobangJetWu/Library/Developer/Xcode/DerivedData/Clio-fnialateruaamwckdkitrckmjkkh/Build/Products/Debug/Clio.app> (executable, loaded) / Localizable: Error Domain=NSOSStatusErrorDomain Code=-10 "kCFURLUnknownError / dsMacsBugInstalled: "
🛑 Stopping Clio streaming transcription
Unable to load .strings file: CFBundle 0x600001520000 </Users/ZhaobangJetWu/Library/Developer/Xcode/DerivedData/Clio-fnialateruaamwckdkitrckmjkkh/Build/Products/Debug/Clio.app> (executable, loaded) / Localizable: Error Domain=NSOSStatusErrorDomain Code=-10 "kCFURLUnknownError / dsMacsBugInstalled: "
🏥 [AUDIO HEALTH] Health monitoring timer stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
🛑 Stopping unified audio capture
t=390492 sess=tam lvl=INFO cat=audio evt=record_stop
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key plugInPackage
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key CMIOType
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key numberOfDevices
t=390503 sess=tam lvl=INFO cat=audio evt=avcapture_stop
✅ Unified audio capture stopped
Unable to load .strings file: CFBundle 0x600001520000 </Users/ZhaobangJetWu/Library/Developer/Xcode/DerivedData/Clio-fnialateruaamwckdkitrckmjkkh/Build/Products/Debug/Clio.app> (executable, loaded) / Localizable: Error Domain=NSOSStatusErrorDomain Code=-10 "kCFURLUnknownError / dsMacsBugInstalled: "
📤 Sent end-of-stream signal
📤 Sent manual finalize command
🕐 Using finalization timeout: 1000ms (connection took 25329ms)
ℹ️ [OPTIMISTIC] Not skipping: end=false pending=0 ms_since_last=86 tail=100 silence_ok=true tokens_quiet_ok=true partial_empty=true uncond=false
🏁 Received <fin> token - finalization complete
✅ Received <fin> token after 367ms
⚡ Audio capture already stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
📉 Released connection for account account-bundle (connections: 0)
💾 [COLD-START] Updated successful streaming timestamp
💾 [COLD-START] Updated successful streaming timestamp
⚠️ No text received from streaming transcription
📱 Dismissing recorder
✅ Streaming stopped. Final transcript (0 chars, 25.7s, with audio file): ""
🌡️ [WARM] warm_socket=yes
t=390998 sess=tam lvl=INFO cat=transcript evt=final text=
t=391000 sess=tam lvl=INFO cat=transcript evt=session_end divider="────────── session end ──────────"
Unable to load .strings file: CFBundle 0x600001520000 </Users/ZhaobangJetWu/Library/Developer/Xcode/DerivedData/Clio-fnialateruaamwckdkitrckmjkkh/Build/Products/Debug/Clio.app> (executable, loaded) / Localizable: Error Domain=NSOSStatusErrorDomain Code=-10 "kCFURLUnknownError / dsMacsBugInstalled: "
🧹 Connection cleanup completed (session resources released)
⏹️ Keepalive timer stopped
⚠️ WebSocket did close with code 1001 (sid=sock_-5790295106748096174, attemptId=9)
t=391032 sess=tam lvl=WARN cat=stream evt=state state=closed code=1001
Unable to load .strings file: CFBundle 0x600001520000 </Users/ZhaobangJetWu/Library/Developer/Xcode/DerivedData/Clio-fnialateruaamwckdkitrckmjkkh/Build/Products/Debug/Clio.app> (executable, loaded) / Localizable: Error Domain=NSOSStatusErrorDomain Code=-10 "kCFURLUnknownError / dsMacsBugInstalled: "
🔌 [WS] Disconnected (socketId=sock_-5790295106748096174@attempt_9)
Unable to load .strings file: CFBundle 0x600001520000 </Users/ZhaobangJetWu/Library/Developer/Xcode/DerivedData/Clio-fnialateruaamwckdkitrckmjkkh/Build/Products/Debug/Clio.app> (executable, loaded) / Localizable: Error Domain=NSOSStatusErrorDomain Code=-10 "kCFURLUnknownError / dsMacsBugInstalled: "
Unable to load .strings file: CFBundle 0x600001520000 </Users/ZhaobangJetWu/Library/Developer/Xcode/DerivedData/Clio-fnialateruaamwckdkitrckmjkkh/Build/Products/Debug/Clio.app> (executable, loaded) / Localizable: Error Domain=NSOSStatusErrorDomain Code=-10 "kCFURLUnknownError / dsMacsBugInstalled: "
Unable to load .strings file: CFBundle 0x600001520000 </Users/ZhaobangJetWu/Library/Developer/Xcode/DerivedData/Clio-fnialateruaamwckdkitrckmjkkh/Build/Products/Debug/Clio.app> (executable, loaded) / Localizable: Error Domain=NSOSStatusErrorDomain Code=-10 "kCFURLUnknownError / dsMacsBugInstalled: "
🌐 [CONNECT] New single-flight request from warmHold
🌐 [CONNECT] Attempt #10 (loop 1/2) starting…
t=391188 sess=tam lvl=INFO cat=stream evt=temp_key_fetch_start
⚡ [CACHE-HIT] Retrieved temp key in 35.8ms
t=391225 sess=tam lvl=INFO cat=stream evt=temp_key_fetch expires_in_s=-1 source=cached latency_ms=35
🌐 [WS CONNECT] Using URL: wss://stt-rt.soniox.com/transcribe-websocket
🔗 [WS] Bound socket id=sock_-7066010273632960221@attempt_10
t=391225 sess=tam lvl=INFO cat=stream evt=ws_bind attempt=10 target_host=stt-rt.soniox.com socket=sock_-7066010273632960221@attempt_10 via_proxy=false path=/transcribe-websocket target_ip=resolving...
🔑 Successfully connected to Soniox using temp key (37ms key latency)
t=391227 sess=tam lvl=INFO cat=stream evt=ws_bind_resolved attempt=10 target_ip=129.146.176.251 via_proxy=false socket=sock_-7066010273632960221@attempt_10 target_host=stt-rt.soniox.com path=/transcribe-websocket
t=392613 sess=tam lvl=INFO cat=stream evt=ws_handshake_metrics proxy=false protocol=http/1.1 dns_ms=0 connect_ms=1072 tls_ms=1070 reused=false socket=sock_-7066010273632960221@attempt_10 total_ms=1387 attempt=10
🔌 WebSocket did open (sid=sock_-7066010273632960221, attemptId=10)
🌐 [CONNECT] Attempt #10 succeeded
📤 [START] Sent start/config on standby socket (eager mode)
📤 Sending text frame seq=4967
🧊 [STANDBY] Connected standby socket — keepalive every 10.0s, TTL=60s (attempt=10, socket=sock_-7066010273632960221@attempt_10)
🔌 [READY] attemptId=10 socketId=sock_-7066010273632960221@attempt_10 start_text_sent=true
🧊 [STANDBY] WebSocket ready in 1426ms (handshake)
👂 [LISTENER] Standby listener task for socketId=sock_-7066010273632960221@attempt_10 attemptId=10
Unable to load .strings file: CFBundle 0x600001520000 </Users/ZhaobangJetWu/Library/Developer/Xcode/DerivedData/Clio-fnialateruaamwckdkitrckmjkkh/Build/Products/Debug/Clio.app> (executable, loaded) / Localizable: Error Domain=NSOSStatusErrorDomain Code=-10 "kCFURLUnknownError / dsMacsBugInstalled: "
📱 Showing DynamicNotch recorder (MIT licensed)
🧊 [WARMUP] Skipping (recently run) context=recorderUIShown
Unable to load .strings file: CFBundle 0x600001520000 </Users/ZhaobangJetWu/Library/Developer/Xcode/DerivedData/Clio-fnialateruaamwckdkitrckmjkkh/Build/Products/Debug/Clio.app> (executable, loaded) / Localizable: Error Domain=NSOSStatusErrorDomain Code=-10 "kCFURLUnknownError / dsMacsBugInstalled: "
Unable to load .strings file: CFBundle 0x600001520000 </Users/ZhaobangJetWu/Library/Developer/Xcode/DerivedData/Clio-fnialateruaamwckdkitrckmjkkh/Build/Products/Debug/Clio.app> (executable, loaded) / Localizable: Error Domain=NSOSStatusErrorDomain Code=-10 "kCFURLUnknownError / dsMacsBugInstalled: "
Unable to load .strings file: CFBundle 0x600001520000 </Users/ZhaobangJetWu/Library/Developer/Xcode/DerivedData/Clio-fnialateruaamwckdkitrckmjkkh/Build/Products/Debug/Clio.app> (executable, loaded) / Localizable: Error Domain=NSOSStatusErrorDomain Code=-10 "kCFURLUnknownError / dsMacsBugInstalled: "
🎤 [toggleRecord] Starting recording, current model: soniox-realtime-streaming
🧊 [WARMUP] Skipping (recently run) context=hotkeyDown
🎙️ Starting recording sequence...
📝 [GRACE] Recording session started with 2552 words remaining
🔧 [NER-SETUP] Setting up callback - contextService exists: true
✅ [NER-SETUP] OCR completion callback configured for NER pre-warming - callback exists: true
Unable to load .strings file: CFBundle 0x600001520000 </Users/ZhaobangJetWu/Library/Developer/Xcode/DerivedData/Clio-fnialateruaamwckdkitrckmjkkh/Build/Products/Debug/Clio.app> (executable, loaded) / Localizable: Error Domain=NSOSStatusErrorDomain Code=-10 "kCFURLUnknownError / dsMacsBugInstalled: "
📊 [SESSION] Starting recording session #8
🧪 [A/B] warm_socket=yes
🧊➡️🔥 [STANDBY->ACTIVE] Consuming standby socket for new utterance
⏭️ [STANDBY->ACTIVE] START already sent on standby (eager) — skipping re-send
Unable to load .strings file: CFBundle 0x600001520000 </Users/ZhaobangJetWu/Library/Developer/Xcode/DerivedData/Clio-fnialateruaamwckdkitrckmjkkh/Build/Products/Debug/Clio.app> (executable, loaded) / Localizable: Error Domain=NSOSStatusErrorDomain Code=-10 "kCFURLUnknownError / dsMacsBugInstalled: "
✅ [STANDBY->ACTIVE] Probe keepalive OK — proceeding to resume queue
⏹️ Keepalive timer stopped
🔄 Keepalive timer started (interval: 15.000000s)
🧪 [PROMO] snapshot attempt=10 socket=sock_-7066010273632960221@attempt_10 start_sent=true ws_ready=true standby=false purpose=active cap_sr=16000 cap_ch=1 prebuf=0 last_fp=m=stt-rt-preview-v2|sr=16000|ch=1|h=en,zh|ctx=7250312277565852139
t=393123 sess=tam lvl=INFO cat=stream evt=temp_key_fetch_start
⚠️ Screen capture already in progress, skipping
⚡ [CACHE-HIT] Retrieved temp key in 0.2ms
t=393123 sess=tam lvl=INFO cat=stream evt=temp_key_fetch expires_in_s=-1 latency_ms=0 source=cached
🧪 [PROMO] config_fp current=m=stt-rt-preview-v2|sr=16000|ch=1|h=en,zh|ctx=7250312277565852139 last=m=stt-rt-preview-v2|sr=16000|ch=1|h=en,zh|ctx=7250312277565852139
🎤 Registering audio tap for Soniox
t=393124 sess=tam lvl=INFO cat=audio evt=record_start service=Soniox
🔍 Performing audio system pre-flight checks
throwing -10877
throwing -10877
✅ Pre-flight checks passed
t=393182 sess=tam lvl=INFO cat=audio evt=tap_install ok=true service=Soniox backend=avcapture
t=393182 sess=tam lvl=INFO cat=audio evt=record_start reason=start_capture
t=393182 sess=tam lvl=INFO cat=audio evt=device_pin_start prev_uid_hash=406926317792165891 prev_id=181 desired_name="MacBook Pro Microphone" prev_name="MacBook Pro Microphone" desired_id=181 desired_uid_hash=406926317792165891
t=393182 sess=tam lvl=INFO cat=audio evt=capture_backend_selected backend=avcapture
✅ Unified audio capture started
✅ Selected account account-bundle (connections: 1/10)
Unable to load .strings file: CFBundle 0x600001520000 </Users/ZhaobangJetWu/Library/Developer/Xcode/DerivedData/Clio-fnialateruaamwckdkitrckmjkkh/Build/Products/Debug/Clio.app> (executable, loaded) / Localizable: Error Domain=NSOSStatusErrorDomain Code=-10 "kCFURLUnknownError / dsMacsBugInstalled: "
⏸️ [CAPTURE DEBUG] Screen capture skipped - already in progress, will reuse results
🧠 [TEN-VAD] Initialized (threshold=0.5, hop=256)
🚀 Starting Clio streaming transcription
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
🏥 [AUDIO HEALTH] Health monitoring timer started
⏱️ [TIMING] mic_engaged @ 1756314190.518
t=393246 sess=tam lvl=INFO cat=audio evt=avcapture_start ok=true
t=393246 sess=tam lvl=INFO cat=stream evt=first_audio_buffer_captured ms=33
⏱️ [TIMING] WebSocket connect task completed — will flush after READY
pass
🧪 [PROMO] first_audio seq=0 bytes=372 approx_db=-60.0
✅ [AUDIO HEALTH] First audio data received - tap is functional
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
Unable to load .strings file: CFBundle 0x600001520000 </Users/ZhaobangJetWu/Library/Developer/Xcode/DerivedData/Clio-fnialateruaamwckdkitrckmjkkh/Build/Products/Debug/Clio.app> (executable, loaded) / Localizable: Error Domain=NSOSStatusErrorDomain Code=-10 "kCFURLUnknownError / dsMacsBugInstalled: "
t=393272 sess=tam lvl=INFO cat=stream evt=first_audio_sent ms=60 seq=0
throwing -10877
throwing -10877
🧪 [PROMO] audio_bytes bytes=10020
🌐 [PATH] Initial path baseline set — no action
🧪 [PROMO] audio_bytes bytes=30108
 [ERROR] SLSWindowListCreateImageProxying:156 unable to complete request due to timeout: 83FE1736-C5C4-4B74-B8E2-786C4B67770F
🌐 Using selected languages for OCR: zh-Hans, en-US
🔍 Found 147 text observations
✅ Text extraction successful: 3311 chars, 3311 non-whitespace, 594 words from 147 observations
✅ Captured text successfully
✅ [CAPTURE DEBUG] Screen capture successful: 3394 characters
💾 [SMART-CACHE] Cached new context: com.apple.dt.Xcode|Clio — SonioxStreamingService.swift (3394 chars)
🎯 [CALLBACK DEBUG] Executing callback with fresh content (3394 chars)
🔥 [PREWARM DEBUG] Pre-warming AI connection (target: Gemini), environment: flyio
🔥 [NER-TRIGGER] OCR completion callback triggered with fresh content
🎦 [NER-PREWARM] Using raw OCR text for NER: 3394 characters
🎦 [NER-INPUT-FULL] Full OCR Text Being Sent to NER: Active Window: Notifications | LinkedIn
Application: Google Chrome
Window Content:
•〇〇
X fron
X Hon|
14 NCR
4 Wee
X Jeff
◎ Fror
X The
×
GRE
S
Tim
Voic
Sigr
The
个
G
linkedin.com/notifications/？filter=all
品一口 Training
口 工作 L Life L MBA
口 GSB
口 交易
參 Old Tibet Photogr..
S How To Repurpose..
Search
Jetson Wu
Bullding In voice Al Resonate （A
User Research） + Clio （Al Voice..
Singapore
A stealth Startup
Manage your
notifications
View settings
《 The Ultimate Guid..
All
Home
My Network
Jobs
My posts
Mentions
Ayushi Sinha posted: We made 20 extra corduroy hats. Who
wants one? In honor of the US Open, our team just dropped a
small batch of hats for the real MVPs of medicine. These aren't..
Isabella Teague reposted Quirk Creative's post: Meal kits are
dead. Long live dinner. This week marks a big, bold leap for Blue
Apron, saying goodbye to subscriptions and hello to freed
New from Tony Robbins in The One Thing: Tony Robbins |
Question That Transformed My Life （and Can Transform Yo
Marissa Ramirez de Chanlatte posted: Looking forward tc
hearing from several startups shaping the next generation
computing technologies at Strata's virtual pitch event！
（19）
API
Doc
The
4 Men
ntra
X Men
Q
ENe EP Trading School...
FewMoreDays
Home - Qullamagg..
R Readwise
Get 50% Off Sales
Messaqind
Notifications
For Business~
口
引
Error：
口 All Bookmarks
Karolis Kazlauskas posted: This will help you a lot！
Mina Zarabian, PhD reposted Alejandra Enriquez Garcia'
SixRing is growing, and we're looking for a Research Chem
◎ join our team and contribute to our mission to transform..
Steven Lee reposted Benjamin Cichy's post: /'m hiring for
Director level roles on my team - this one will lead the tear
implementing the critical flight and simulation software for
Shen Sean Chen, your new connection, posted: Thanks N
and Tailwind for making mobile web app adaptation smoot
easy. Q We're building AutoManus.io, an AI Agent Sales Le
MIT Sloan School of Management Admissions and other：
follow created 6 events this week. View all events.
网
Todd Medema
Post grad | worked at a gravity energy startup at Idealab
（a tech incubator in Pasadena） and we had a portfolio
company that was acquired by Nextracker. How do u like
it there？
Todd Medema ⑦ • 5:38 PM
Amazing! Yeah I don't think we have a way of shipping
physical copies to China ©
What brought you back to China？
Oh neat-Ireally like it. The people here are both
mission-driven, and very kind. A rare combination
Jetson Wu （He/Him）• 5:39 PM
Iodd: Amazing: Yeah I dont think we have a way ot shipping physical
copies to China ©
It's home - I was studying in the US + working！
Todd Medema ⑦. 5:39 PM
Jetson: It's home - I was studying in the US + working！
Ahl That makes sensp
Write a message...
1D53
Messaging
C
Goodwill Painting
Q Search messages
Focused
Other
Todd Medema
Todd: Ah! That makes sense
Aug 23
Ariya Chittasy
Ariya: Hey Jetson, sorry but
any word on this？
Aug 23
Sherwin Ng
Aug 23
Sherwin: We should defo find
a time to chat, how does a...
Xiaojin （Alan） Wang
C InMail Join the 2025
Next Star Global Startup..
Aug 15
Javier （Jia Wei） Ng
Javler （Jla wel: very helprul，
thanks Jetson
Aug 15
Serge, Deepak, Philip.. Aug 15
DDPn2K• 一 I Wor A TAw
customer interviews put..
Raynard Lao
You: sharing some context
Aug 14
Deepak, Philip, and you
Aug 8
Deepak: Nope
Deepak Goel
Deepak sent a post
Aug 7
Gloria Pu
Gloria：感谢回复，
方便问下您可
以加微信汤佣吗？仅店想要能
Aug 4
-
🎯 [RULE-ENGINE] Detected: Code Review
💻 [NER-DETECT] Detected code context for NER (source=\(latest.source.displayName), conf=\(String(format: "%.2f", latest.confidence)))
🧠 [NER-CODE] Using code NER prompt (\(codeNER.count) chars)
🧠 [NER-CODE-FULL] Code NER System Prompt: \(codeNER)
throwing -10877
throwing -10877
🤖 [FLY.IO-NER] Server-reported provider: gemini
📥 [NER-STORE] Stored NER entities: 725 chars - FULL TEXT: ```json
{
  "classes": [],
  "components": [],
  "function names": [],
  "files": [],
  "frameworks": ["Tailwind"],
  "packages": [],
  "variables": [],
  "services": [],
  "products": ["Blue Apron", "AutoManus.io"],
  "people": ["Jetson Wu", "Ayushi Sinha", "Isabella Teague", "Tony Robbins", "Marissa Ramirez de Chanlatte", "Karolis Kazlauskas", "Mina Zarabian", "Alejandra Enriquez Garcia", "Steven Lee", "Benjamin Cichy", "Shen Sean Chen", "Todd Medema", "Ariya Chittasy", "Sherwin Ng", "Xiaojin （Alan） Wang", "Javier （Jia Wei） Ng", "Deepak", "Philip", "Raynard Lao", "Deepak Goel", "Gloria Pu"],
  "organizations": ["LinkedIn", "Google Chrome", "MIT Sloan School of Management", "SixRing", "Idealab", "Nextracker"]
}
```
✅ [FLY.IO] NER refresh completed successfully
🛑 Stopping recording
Unable to load .strings file: CFBundle 0x600001520000 </Users/ZhaobangJetWu/Library/Developer/Xcode/DerivedData/Clio-fnialateruaamwckdkitrckmjkkh/Build/Products/Debug/Clio.app> (executable, loaded) / Localizable: Error Domain=NSOSStatusErrorDomain Code=-10 "kCFURLUnknownError / dsMacsBugInstalled: "
🛑 Stopping Clio streaming transcription
Unable to load .strings file: CFBundle 0x600001520000 </Users/ZhaobangJetWu/Library/Developer/Xcode/DerivedData/Clio-fnialateruaamwckdkitrckmjkkh/Build/Products/Debug/Clio.app> (executable, loaded) / Localizable: Error Domain=NSOSStatusErrorDomain Code=-10 "kCFURLUnknownError / dsMacsBugInstalled: "
🏥 [AUDIO HEALTH] Health monitoring timer stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
🛑 Stopping unified audio capture
t=399915 sess=tam lvl=INFO cat=audio evt=record_stop
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key plugInPackage
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key CMIOType
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key numberOfDevices
t=399924 sess=tam lvl=INFO cat=audio evt=avcapture_stop
✅ Unified audio capture stopped
Unable to load .strings file: CFBundle 0x600001520000 </Users/ZhaobangJetWu/Library/Developer/Xcode/DerivedData/Clio-fnialateruaamwckdkitrckmjkkh/Build/Products/Debug/Clio.app> (executable, loaded) / Localizable: Error Domain=NSOSStatusErrorDomain Code=-10 "kCFURLUnknownError / dsMacsBugInstalled: "
📤 Sent end-of-stream signal
📤 Sent manual finalize command
🕐 Using finalization timeout: 1000ms (connection took 6839ms)
ℹ️ [OPTIMISTIC] Not skipping: end=false pending=0 ms_since_last=80 tail=100 silence_ok=true tokens_quiet_ok=true partial_empty=true uncond=false
🧪 [PROMO] first_token ms=7308 tokens_in_msg=1
🏁 Received <fin> token - finalization complete
✅ Received <fin> token after 420ms
⚡ Audio capture already stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
📉 Released connection for account account-bundle (connections: 0)
💾 [COLD-START] Updated successful streaming timestamp
💾 [COLD-START] Updated successful streaming timestamp
🧪 [PROMO] no_tokens_before_stop bytes_sent=214620 queue_depth=0
⚠️ No text received from streaming transcription
📱 Dismissing recorder
✅ Streaming stopped. Final transcript (0 chars, 7.3s, with audio file): ""
🌡️ [WARM] warm_socket=yes
t=400473 sess=tam lvl=INFO cat=transcript evt=final text=
t=400473 sess=tam lvl=INFO cat=transcript evt=session_end divider="────────── session end ──────────"
Unable to load .strings file: CFBundle 0x600001520000 </Users/ZhaobangJetWu/Library/Developer/Xcode/DerivedData/Clio-fnialateruaamwckdkitrckmjkkh/Build/Products/Debug/Clio.app> (executable, loaded) / Localizable: Error Domain=NSOSStatusErrorDomain Code=-10 "kCFURLUnknownError / dsMacsBugInstalled: "
🧹 Connection cleanup completed (session resources released)
⏹️ Keepalive timer stopped
⚠️ WebSocket did close with code 1001 (sid=sock_-7066010273632960221, attemptId=10)
t=400570 sess=tam lvl=WARN cat=stream evt=state state=closed code=1001
Unable to load .strings file: CFBundle 0x600001520000 </Users/ZhaobangJetWu/Library/Developer/Xcode/DerivedData/Clio-fnialateruaamwckdkitrckmjkkh/Build/Products/Debug/Clio.app> (executable, loaded) / Localizable: Error Domain=NSOSStatusErrorDomain Code=-10 "kCFURLUnknownError / dsMacsBugInstalled: "
🔌 [WS] Disconnected (socketId=sock_-7066010273632960221@attempt_10)
Unable to load .strings file: CFBundle 0x600001520000 </Users/ZhaobangJetWu/Library/Developer/Xcode/DerivedData/Clio-fnialateruaamwckdkitrckmjkkh/Build/Products/Debug/Clio.app> (executable, loaded) / Localizable: Error Domain=NSOSStatusErrorDomain Code=-10 "kCFURLUnknownError / dsMacsBugInstalled: "
Unable to load .strings file: CFBundle 0x600001520000 </Users/ZhaobangJetWu/Library/Developer/Xcode/DerivedData/Clio-fnialateruaamwckdkitrckmjkkh/Build/Products/Debug/Clio.app> (executable, loaded) / Localizable: Error Domain=NSOSStatusErrorDomain Code=-10 "kCFURLUnknownError / dsMacsBugInstalled: "
Unable to load .strings file: CFBundle 0x600001520000 </Users/ZhaobangJetWu/Library/Developer/Xcode/DerivedData/Clio-fnialateruaamwckdkitrckmjkkh/Build/Products/Debug/Clio.app> (executable, loaded) / Localizable: Error Domain=NSOSStatusErrorDomain Code=-10 "kCFURLUnknownError / dsMacsBugInstalled: "
🌐 [CONNECT] New single-flight request from warmHold
🌐 [CONNECT] Attempt #11 (loop 1/2) starting…
t=400699 sess=tam lvl=INFO cat=stream evt=temp_key_fetch_start
⚡ [CACHE-HIT] Retrieved temp key in 0.3ms
t=400700 sess=tam lvl=INFO cat=stream evt=temp_key_fetch source=cached expires_in_s=-1 latency_ms=0
🌐 [WS CONNECT] Using URL: wss://stt-rt.soniox.com/transcribe-websocket
🔗 [WS] Bound socket id=sock_-2439524045345732887@attempt_11
t=400701 sess=tam lvl=INFO cat=stream evt=ws_bind socket=sock_-2439524045345732887@attempt_11 attempt=11 target_ip=resolving... target_host=stt-rt.soniox.com via_proxy=false path=/transcribe-websocket
🔑 Successfully connected to Soniox using temp key (1ms key latency)
t=400702 sess=tam lvl=INFO cat=stream evt=ws_bind_resolved target_ip=129.146.176.251 via_proxy=false attempt=11 target_host=stt-rt.soniox.com path=/transcribe-websocket socket=sock_-2439524045345732887@attempt_11
t=401985 sess=tam lvl=INFO cat=stream evt=ws_handshake_metrics dns_ms=0 connect_ms=978 proxy=false tls_ms=976 reused=false protocol=http/1.1 socket=sock_-2439524045345732887@attempt_11 attempt=11 total_ms=1283
🔌 WebSocket did open (sid=sock_-2439524045345732887, attemptId=11)
📤 [START] Sent start/config on standby socket (eager mode)
📤 Sending text frame seq=5545
🌐 [CONNECT] Attempt #11 succeeded
🧊 [STANDBY] Connected standby socket — keepalive every 10.0s, TTL=60s (attempt=11, socket=sock_-2439524045345732887@attempt_11)
🔌 [READY] attemptId=11 socketId=sock_-2439524045345732887@attempt_11 start_text_sent=true
🧊 [STANDBY] WebSocket ready in 1287ms (handshake)
👂 [LISTENER] Standby listener task for socketId=sock_-2439524045345732887@attempt_11 attemptId=11
💤 [STANDBY] keepalive_tick
t=411989 sess=tam lvl=INFO cat=stream evt=standby_keepalive_tick
💤 [STANDBY] keepalive_tick
t=421989 sess=tam lvl=INFO cat=stream evt=standby_keepalive_tick
💤 [STANDBY] keepalive_tick
t=431987 sess=tam lvl=INFO cat=stream evt=standby_keepalive_tick
💤 [STANDBY] keepalive_tick
t=441988 sess=tam lvl=INFO cat=stream evt=standby_keepalive_tick