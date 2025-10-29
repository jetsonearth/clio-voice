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
🔊 Waking up audio system after 4516s idle time
⏰ [CACHE] Cache is stale (age: 4581.2s, ttl=120s)
🎬 Starting screen capture with verified permissions
🎯 (17) A Yale Student Raised $3.1M in 2 Weeks for an AI Social App | Series, Nathaneo Johnson - YouTube
🌐 Browser detected, using content-optimized capture settings
🌐 [LANG DEBUG] Multi-language setting exists: true, Single language: en
🌐 [LANG DEBUG] Using multi-language selection (prioritized): zh, en
🌐 Using selected languages for OCR: zh-Hans, en-US
🌐 Browser detected - using optimized OCR settings for webpage content
📊 [SESSION] Starting recording session #6
🧪 [A/B] warm_socket=yes
🎤 Registering audio tap for Soniox
t=2952134 sess=9Hn lvl=INFO cat=audio evt=record_start service=Soniox
🔍 Performing audio system pre-flight checks
throwing -10877
throwing -10877
✅ Pre-flight checks passed
t=2952243 sess=9Hn lvl=INFO cat=audio evt=tap_install ok=true backend=avcapture service=Soniox
t=2952244 sess=9Hn lvl=INFO cat=audio evt=record_start reason=start_capture
t=2952245 sess=9Hn lvl=INFO cat=audio evt=device_pin_start desired_name="MacBook Pro Microphone" desired_uid_hash=4285059772673450742 prev_name="MacBook Pro Microphone" prev_id=181 prev_uid_hash=4285059772673450742 desired_id=181
❄️ Cold start detected - performing full initialization
❄️ Performing cold start initialization
⏭️ Skipping engine cold start (backend=AVCapture)
t=2952246 sess=9Hn lvl=INFO cat=audio evt=capture_backend_selected backend=avcapture
✅ Unified audio capture started
✅ Selected account account-bundle (connections: 1/10)
🧠 [TEN-VAD] Initialized (threshold=0.5, hop=256)
🚀 Starting Clio streaming transcription
🏥 [AUDIO HEALTH] Health monitoring timer started
⏱️ [TIMING] mic_engaged @ 1756225988.255
🌐 [CONNECT] New single-flight request from start
pass
🌐 [CONNECT] Attempt #7 (loop 1/3) starting…
t=2952288 sess=9Hn lvl=INFO cat=stream evt=temp_key_fetch_start
⚡ [CACHE-HIT] Retrieved temp key in 0.1ms
t=2952289 sess=9Hn lvl=INFO cat=stream evt=temp_key_fetch source=cached expires_in_s=-1 latency_ms=0
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🌐 [WS CONNECT] Using URL: wss://stt-rt.soniox.com/transcribe-websocket
🔗 [WS] Bound socket id=sock_3372325045645707305@attempt_7
t=2952291 sess=9Hn lvl=INFO cat=stream evt=ws_bind target_host=stt-rt.soniox.com target_ip=resolving... socket=sock_3372325045645707305@attempt_7 path=/transcribe-websocket attempt=7 via_proxy=false
🔑 Successfully connected to Soniox using temp key (3ms key latency)
t=2952301 sess=9Hn lvl=INFO cat=audio evt=avcapture_start ok=true
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
t=2952310 sess=9Hn lvl=INFO cat=stream evt=first_audio_buffer_captured ms=54
t=2952311 sess=9Hn lvl=INFO cat=audio evt=level peak_db=-60 avg_db=-60
✅ [AUDIO HEALTH] First audio data received - tap is functional
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
t=2952797 sess=9Hn lvl=INFO cat=stream evt=ws_bind_resolved via_proxy=false target_ip=129.146.176.251 socket=sock_3372325045645707305@attempt_7 attempt=7 path=/transcribe-websocket target_host=stt-rt.soniox.com
🔍 Found 93 text observations
✅ Text extraction successful: 1394 chars, 1394 non-whitespace, 237 words from 93 observations
✅ Captured text successfully
✅ [CAPTURE DEBUG] Screen capture successful: 1554 characters
💾 [SMART-CACHE] Cached new context: com.google.Chrome|(17) A Yale Student Raised $3.1M in 2 Weeks for an AI Social App | Series, Nathaneo Johnson - YouTube (1554 chars)
🎯 [CALLBACK DEBUG] Executing callback with fresh content (1554 chars)
🔥 [PREWARM DEBUG] Pre-warming AI connection (target: Gemini), environment: flyio
🔥 [NER-TRIGGER] OCR completion callback triggered with fresh content
🎬 [NER-PREWARM] Using raw OCR text for NER: 1554 characters
🧠 [NER-DEFAULT] Using default NER prompt for general extraction
🌐 [ASR BREAKDOWN] Total: 1587ms | Client↔Proxy: 683ms | Proxy↔Soniox: 900ms | Network: 900ms
🗑️ Evicted oldest temp key to maintain cache size limit
💾 Cached temp key for languages: ["zh", "en"]
🗓️ [TTL-SCHEDULE] Scheduling temp key refresh for key=global in 3000s (expiresAt=2025-08-26 17:33:09 +0000)
✅ [PREFETCH] Successfully prefetched temp key
🎤 [WARMUP] Pre-warming audio system...
✅ [PREWARM] Device enumeration completed
✅ [PREWARM] Audio system pre-warming completed successfully
✅ [WARMUP] Audio system pre-warmed successfully
t=2953951 sess=9Hn lvl=INFO cat=stream evt=ws_handshake_metrics dns_ms=504 connect_ms=881 attempt=7 total_ms=1657 proxy=false protocol=http/1.1 tls_ms=879 reused=false socket=sock_3372325045645707305@attempt_7
🔌 WebSocket did open (sid=sock_3372325045645707305, attemptId=7)
🌐 [CONNECT] Attempt #7 succeeded
⏱️ [TIMING] WebSocket connect task completed — will flush after READY
📤 [START] Sent start/config text frame (attemptId=7, socketId=sock_3372325045645707305@attempt_7, start_text_sent=true)
t=2953955 sess=9Hn lvl=INFO cat=stream evt=start_config socket=sock_3372325045645707305@attempt_7 attempt=7 summary=["ch": 1, "json_hash": "647d4d9a98bd6de5", "sr": 16000, "valid": true, "langs": 2, "ctx_len": 36, "audio_format": "pcm_s16le", "model": "stt-rt-preview-v2"] ctx=active
🧾 [START-CONFIG] ctx=active sum=["ch": 1, "json_hash": "647d4d9a98bd6de5", "sr": 16000, "valid": true, "langs": 2, "ctx_len": 36, "audio_format": "pcm_s16le", "model": "stt-rt-preview-v2"]
🔌 [READY] attemptId=7 socketId=sock_3372325045645707305@attempt_7 start_text_sent=true
🔌 WebSocket ready after 1699ms - buffered 1.6s of audio
📦 Flushing 142 buffered packets (1.6s of audio, 52800 bytes)
📤 Sent buffered packet 0/142 seq=0 size=360
📤 Sent buffered packet 141/142 seq=141 size=372
📦 Flushing 1 additional packets that arrived during flush
✅ Buffer flush complete
⏱️ [SPEECH-WATCHDOG] Arming watchdog: deadline=2.000000s attempt=7
🧪 [PROMO] speech_watchdog_arm attempt=7 speaking=true bytes_threshold=10000 gates isStreaming=true ws_ready=true start_sent=true hasTokens=false
⏹️ Keepalive timer stopped
🔄 Keepalive timer started (interval: 15.000000s)
👂 [LISTENER] Starting listener task for socketId=sock_3372325045645707305@attempt_7 attemptId=7
📤 Sending text frame seq=3655
t=2953970 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=143 bytes=372 ready=true flushing=false
t=2953970 sess=9Hn lvl=INFO cat=stream evt=first_audio_sent seq=143 ms=1713
t=2953982 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=144 bytes=372
t=2953993 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=145 bytes=372
t=2954005 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=146 flushing=false ready=true has_socket=true
t=2954016 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=147 has_socket=true bytes=372 ready=true flushing=false
t=2954036 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=148 bytes=372
t=2954039 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=149 bytes=372
t=2954051 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false ready=true seq=150 has_socket=true
t=2954063 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=151 ready=true has_socket=true
t=2954076 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=152 flushing=false has_socket=true ready=true bytes=372
t=2954086 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=153 flushing=false has_socket=true ready=true bytes=372
t=2954098 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=154 flushing=false has_socket=true ready=true bytes=372
t=2954109 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=155
throwing -10877
throwing -10877
t=2954201 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=156
t=2954201 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=157
t=2954201 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=158
🛑 [TEN-VAD] Speech end detected
t=2954201 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=159
t=2954201 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=160
t=2954201 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=161
t=2954201 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=162
t=2954202 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=163 bytes=372
t=2954214 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=164 bytes=372 ready=true flushing=false
t=2954225 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=165 has_socket=true ready=true
t=2954237 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true seq=166 flushing=false bytes=372
t=2954248 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=167 bytes=372 ready=true flushing=false
t=2954260 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=168 has_socket=true bytes=372 ready=true flushing=false
t=2954272 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=169 has_socket=true flushing=false ready=true
t=2954284 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=170 has_socket=true ready=true
t=2954295 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 seq=171 flushing=false
t=2954306 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=172
t=2954318 sess=9Hn lvl=INFO cat=audio evt=level avg_db=-27 peak_db=-27
t=2954318 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=173 has_socket=true bytes=372 ready=true flushing=false
t=2954330 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=174 ready=true has_socket=true
t=2954341 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true has_socket=true bytes=372 seq=175
t=2954353 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=176 flushing=false has_socket=true ready=true bytes=372
t=2954365 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=177 flushing=false has_socket=true ready=true bytes=372
t=2954377 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=178 has_socket=true bytes=372 ready=true flushing=false
t=2954388 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 seq=179 flushing=false ready=true
t=2954400 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=180
t=2954411 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=181 has_socket=true bytes=372 ready=true flushing=false
t=2954423 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=182 flushing=false has_socket=true ready=true bytes=372
t=2954434 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=183
t=2954446 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=184 bytes=372 flushing=false has_socket=true ready=true
t=2954458 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=185 flushing=false has_socket=true ready=true bytes=372
t=2954469 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=186 bytes=372 flushing=false has_socket=true ready=true
t=2954481 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=187
t=2954493 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=188 has_socket=true bytes=372 ready=true flushing=false
t=2954504 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=189
t=2954516 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=190 bytes=372
t=2954527 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=191
t=2954539 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=192 bytes=372
t=2954550 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=193 bytes=372 ready=true
t=2954567 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=194
t=2954574 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=195 ready=true has_socket=true flushing=false bytes=372
t=2954585 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=196
t=2954597 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=197 has_socket=true bytes=372 ready=true flushing=false
t=2954609 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=198 has_socket=true bytes=372 ready=true flushing=false
t=2954621 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=199 has_socket=true bytes=372 ready=true flushing=false
t=2954632 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=200 has_socket=true bytes=372 ready=true flushing=false
t=2954643 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=201 has_socket=true bytes=372 ready=true flushing=false
t=2954655 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=202 bytes=372
t=2954667 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=203 has_socket=true bytes=372 ready=true flushing=false
t=2954679 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=204 has_socket=true ready=true flushing=false
t=2954690 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=205 has_socket=true bytes=372 ready=true flushing=false
t=2954702 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=206 flushing=false has_socket=true
t=2954713 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=207 flushing=false has_socket=true ready=true bytes=372
🛑 [TEN-VAD] Speech end detected
t=2954725 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=208 bytes=372
t=2954737 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=209 has_socket=true bytes=372 ready=true flushing=false
t=2954748 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=210 has_socket=true flushing=false ready=true bytes=372
t=2954759 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=211 has_socket=true ready=true flushing=false
t=2954772 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=212
t=2954784 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=213 has_socket=true flushing=false bytes=372 ready=true
t=2954794 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=214
t=2954806 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=215 bytes=372
t=2954818 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=216 flushing=false has_socket=true ready=true bytes=372
t=2954829 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=217 flushing=false has_socket=true ready=true bytes=372
t=2954841 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=218 flushing=false has_socket=true ready=true bytes=372
t=2954852 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=219
t=2954864 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=220 flushing=false has_socket=true ready=true bytes=372
t=2954876 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=221 bytes=372
t=2954887 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 ready=true flushing=false seq=222
t=2954899 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=223 has_socket=true ready=true flushing=false
t=2954911 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=224 has_socket=true ready=true flushing=false
t=2954922 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=225 flushing=false has_socket=true ready=true bytes=372
t=2954934 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=226 has_socket=true flushing=false
t=2954945 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=227 flushing=false has_socket=true ready=true bytes=372
t=2954957 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=228 has_socket=true ready=true flushing=false bytes=372
t=2954968 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=229 has_socket=true ready=true flushing=false bytes=372
t=2954980 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=230 bytes=372
t=2954992 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true ready=true seq=231
t=2955003 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=232 flushing=false has_socket=true ready=true bytes=372
t=2955015 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=233 bytes=372
t=2955027 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true ready=true seq=234
t=2955038 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 seq=235 flushing=false ready=true
t=2955051 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true ready=true seq=236
t=2955061 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=237 flushing=false ready=true has_socket=true
t=2955073 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=238 bytes=372
t=2955085 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=239 flushing=false has_socket=true ready=true bytes=372
t=2955096 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=240 ready=true flushing=false has_socket=true bytes=372
t=2955108 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=241 bytes=372
t=2955114 sess=9Hn lvl=INFO cat=stream evt=first_partial ms=2858
t=2955114 sess=9Hn lvl=INFO cat=stream evt=ttft_hotkey ms=2858
t=2955114 sess=9Hn lvl=INFO cat=stream evt=ttft ms=4511938
🛑 [SPEECH-WATCHDOG] Cancelled
t=2955120 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=242 bytes=372
t=2955177 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 seq=243 ready=true flushing=false
t=2955177 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 seq=244 ready=true flushing=false
t=2955177 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 seq=245 ready=true flushing=false
t=2955177 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 seq=246 flushing=false
t=2955178 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 seq=247 flushing=false
t=2955220 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false has_socket=true seq=248
t=2955220 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false has_socket=true seq=249
t=2955220 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false has_socket=true seq=250
t=2955224 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=251
t=2955235 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=252 flushing=false has_socket=true bytes=372 ready=true
🤖 [FLY.IO-NER] Server-reported provider: gemini
📥 [NER-STORE] Stored NER entities: 1790 chars - I've analyzed the provided information, and I can see that the user is currently viewing a YouTube v...
✅ [FLY.IO] NER refresh completed successfully
t=2955247 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=253 has_socket=true ready=true flushing=false
t=2955259 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=254 has_socket=true ready=true flushing=false
t=2955270 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 has_socket=true seq=255
t=2955282 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true has_socket=true seq=256
t=2955293 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false seq=257 ready=true
t=2955332 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=258 has_socket=true bytes=372
t=2955332 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=259
t=2955332 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=260
t=2955340 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=261 bytes=372
t=2955351 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=262 ready=true has_socket=true bytes=372 flushing=false
t=2955363 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=263 ready=true has_socket=true flushing=false bytes=372
t=2955375 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true ready=true bytes=372 seq=264
t=2955386 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=265 has_socket=true ready=true
t=2955398 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=266 has_socket=true ready=true bytes=372
t=2955410 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=267 bytes=372
t=2955421 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=268 flushing=false has_socket=true bytes=372 ready=true
t=2955433 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true ready=true bytes=372 seq=269
t=2955476 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=270 has_socket=true ready=true flushing=false
t=2955476 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=271 has_socket=true ready=true flushing=false
t=2955477 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=272 has_socket=true ready=true flushing=false
t=2955479 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 ready=true seq=273
t=2955491 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true has_socket=true seq=274
t=2955502 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 ready=true seq=275
t=2955536 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=276 has_socket=true flushing=false ready=true
t=2955536 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=277 has_socket=true flushing=false ready=true
t=2955537 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true seq=278 bytes=372
t=2955549 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=279 bytes=372
t=2955560 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 ready=true seq=280
t=2955572 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=281 bytes=372
t=2955584 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=282 bytes=372
t=2955595 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 ready=true seq=283
t=2955607 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=284 ready=true has_socket=true
t=2955649 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=285 has_socket=true ready=true bytes=372 flushing=false
t=2955649 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=286 has_socket=true ready=true bytes=372 flushing=false
t=2955649 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=287 has_socket=true ready=true bytes=372 flushing=false
t=2955653 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=288 has_socket=true ready=true flushing=false
t=2955665 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=289 has_socket=true ready=true flushing=false
t=2955676 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=290 ready=true bytes=372 flushing=false has_socket=true
t=2955688 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=291 ready=true has_socket=true
t=2955700 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true bytes=372 seq=292 ready=true
t=2955711 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=293 has_socket=true ready=true flushing=false
t=2955723 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=294 bytes=372 ready=true flushing=false
t=2955734 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=295 has_socket=true ready=true flushing=false
t=2955746 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=296
t=2955758 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=297 ready=true bytes=372 flushing=false has_socket=true
t=2955770 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=298 bytes=372 ready=true flushing=false
t=2955781 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=299 has_socket=true ready=true flushing=false
t=2955793 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=300 bytes=372 ready=true flushing=false
t=2955804 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=301 ready=true bytes=372 flushing=false has_socket=true
t=2955816 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=302 bytes=372 ready=true flushing=false
t=2955828 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=303 ready=true flushing=false bytes=372
t=2955839 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=304 bytes=372 ready=true
t=2955851 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=305 ready=true flushing=false bytes=372
t=2955906 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 ready=true seq=306
t=2955907 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 ready=true seq=307
t=2955907 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 ready=true seq=308
t=2955907 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 ready=true seq=309
t=2955909 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=310 has_socket=true ready=true bytes=372 flushing=false
t=2955920 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=311 has_socket=true flushing=false
t=2955956 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=312 flushing=false ready=true has_socket=true bytes=372
t=2955956 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=313
t=2955956 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=314
t=2955967 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 seq=315 flushing=false ready=true
t=2956000 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=316 flushing=false has_socket=true bytes=372 ready=true
t=2956000 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=317 flushing=false has_socket=true bytes=372 ready=true
t=2956002 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=318 has_socket=true ready=true
t=2956029 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=319 bytes=372 ready=true flushing=false
t=2956029 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=320 bytes=372 ready=true flushing=false
t=2956036 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=321 ready=true has_socket=true bytes=372 flushing=false
t=2956048 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=322 ready=true bytes=372 flushing=false has_socket=true
t=2956060 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=323
t=2956071 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=324 has_socket=true ready=true
t=2956083 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=325 ready=true bytes=372 flushing=false has_socket=true
t=2956094 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=326 has_socket=true flushing=false bytes=372
t=2956106 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=327 flushing=false ready=true has_socket=true bytes=372
t=2956118 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=328 has_socket=true flushing=false bytes=372
t=2956129 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=329 has_socket=true flushing=false bytes=372
t=2956141 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=330 bytes=372 ready=true flushing=false
t=2956153 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true has_socket=true bytes=372 seq=331
t=2956164 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=332 flushing=false bytes=372 has_socket=true ready=true
t=2956176 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=333 ready=true bytes=372 flushing=false has_socket=true
t=2956187 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 seq=334 has_socket=true
t=2956199 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=335 has_socket=true flushing=false bytes=372
t=2956211 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false seq=336 has_socket=true
t=2956223 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=337 has_socket=true bytes=372 ready=true
t=2956234 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=338 ready=true flushing=false bytes=372
t=2956246 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=339 flushing=false has_socket=true ready=true bytes=372
t=2956258 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=340 has_socket=true ready=true flushing=false
t=2956269 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=341 has_socket=true ready=true flushing=false
t=2956281 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=342 bytes=372 flushing=false has_socket=true ready=true
t=2956292 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=343 bytes=372 flushing=false has_socket=true ready=true
t=2956304 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=344 bytes=372
t=2956315 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=345 has_socket=true ready=true flushing=false
t=2956327 sess=9Hn lvl=INFO cat=audio evt=level avg_db=-28 peak_db=-28
t=2956327 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=346 ready=true flushing=false bytes=372
t=2956402 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=347 ready=true has_socket=true
t=2956402 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=348 ready=true has_socket=true
t=2956402 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=349 ready=true has_socket=true
t=2956402 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=350 ready=true has_socket=true
t=2956402 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=351 ready=true has_socket=true
t=2956402 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=352 ready=true has_socket=true
t=2956408 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=353 has_socket=true ready=true bytes=372
t=2956420 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=354 bytes=372 ready=true flushing=false
t=2956431 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=355 bytes=372 ready=true flushing=false
t=2956443 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=356 flushing=false bytes=372 has_socket=true
t=2956454 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=357 bytes=372 ready=true flushing=false
t=2956506 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=358 has_socket=true ready=true bytes=372
t=2956506 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=359 has_socket=true ready=true bytes=372
t=2956506 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=360 has_socket=true ready=true bytes=372
t=2956506 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=361 has_socket=true ready=true bytes=372
t=2956512 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=362 has_socket=true bytes=372 ready=true flushing=false
t=2956524 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=363 bytes=372 ready=true flushing=false
t=2956536 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=364 bytes=372 ready=true flushing=false
t=2956547 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=365 bytes=372 ready=true flushing=false
t=2956559 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=366 has_socket=true ready=true flushing=false
t=2956570 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=367
t=2956582 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=368
t=2956594 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=369 bytes=372 ready=true flushing=false
t=2956605 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=370 bytes=372 ready=true flushing=false
t=2956617 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false has_socket=true seq=371
t=2956632 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=372
t=2956641 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=373
t=2956652 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=374
t=2956664 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=375
t=2956677 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=376 ready=true bytes=372
t=2956687 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=377
t=2956699 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=378 has_socket=true ready=true flushing=false
t=2956711 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=379
t=2956722 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=380
t=2956735 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=381
t=2956745 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=382 has_socket=true ready=true flushing=false bytes=372
t=2956757 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=383 ready=true bytes=372
t=2956769 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=384 has_socket=true ready=true flushing=false
t=2956781 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=385
t=2956792 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=386
t=2956804 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=387
t=2956816 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=388 bytes=372
t=2956827 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=389 bytes=372
t=2956838 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=390 bytes=372 flushing=false has_socket=true ready=true
t=2956850 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=391 ready=true flushing=false bytes=372
t=2956862 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=392 ready=true flushing=false bytes=372
t=2956874 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=393
t=2956885 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=394
t=2956896 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=395 has_socket=true bytes=372 ready=true
t=2956908 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=396 bytes=372
t=2956976 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 flushing=false seq=397
t=2956976 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 flushing=false seq=398
t=2956976 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 flushing=false seq=399
t=2956976 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 flushing=false seq=400
t=2956976 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 flushing=false seq=401
t=2956977 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=402 ready=true bytes=372
t=2956988 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=403 ready=true bytes=372 flushing=false has_socket=true
t=2957000 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false seq=404 ready=true
t=2957012 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=405 has_socket=true ready=true
t=2957024 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=406 bytes=372 ready=true flushing=false
t=2957035 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=407
t=2957047 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 seq=408 flushing=false ready=true
t=2957058 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=409 has_socket=true bytes=372 ready=true flushing=false
t=2957070 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=410 flushing=false has_socket=true ready=true
t=2957082 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=411 has_socket=true ready=true flushing=false
t=2957094 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=412 flushing=false has_socket=true ready=true
t=2957105 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=413 ready=true flushing=false has_socket=true
t=2957117 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=414 bytes=372
t=2957129 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=415 bytes=372
t=2957140 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=416 bytes=372 flushing=false
t=2957153 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=417 flushing=false has_socket=true ready=true
t=2957163 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=418 bytes=372 flushing=false
t=2957176 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=419 has_socket=true bytes=372 ready=true
t=2957256 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=420 bytes=372
t=2957256 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=421 bytes=372
t=2957256 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=422 bytes=372
t=2957256 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=423 bytes=372
t=2957256 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=424 bytes=372
t=2957256 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=425 bytes=372
t=2957256 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=426 bytes=372
t=2957267 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=427 bytes=372
t=2957279 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=428 ready=true has_socket=true bytes=372 flushing=false
t=2957291 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=429 bytes=372
t=2957302 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=430 bytes=372 ready=true flushing=false
t=2957314 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=431 ready=true bytes=372
t=2957325 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=432 has_socket=true bytes=372 ready=true flushing=false
t=2957337 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=433 ready=true has_socket=true bytes=372 flushing=false
t=2957348 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=434 ready=true bytes=372
t=2957360 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=435 bytes=372
t=2957372 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=436 has_socket=true ready=true
🛑 [TEN-VAD] Speech end detected
t=2957384 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=437 flushing=false bytes=372 ready=true
t=2957447 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=438 flushing=false bytes=372 ready=true has_socket=true
t=2957447 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=439 flushing=false bytes=372 ready=true has_socket=true
t=2957447 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=440 flushing=false bytes=372 ready=true has_socket=true
t=2957447 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=441 flushing=false bytes=372 ready=true has_socket=true
t=2957447 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=442 flushing=false bytes=372 ready=true has_socket=true
t=2957453 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=443 ready=true has_socket=true bytes=372 flushing=false
t=2957464 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=444 ready=true has_socket=true flushing=false bytes=372
🛑 [TEN-VAD] Speech end detected
t=2957476 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=445 has_socket=true ready=true flushing=false
t=2957488 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=446 has_socket=true ready=true flushing=false
t=2957499 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=447 has_socket=true bytes=372 ready=true flushing=false
t=2957511 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=448 bytes=372 flushing=false
t=2957523 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 seq=449 ready=true flushing=false
t=2957534 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=450 bytes=372 flushing=false
t=2957546 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=451 has_socket=true ready=true
t=2957602 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=452 bytes=372
t=2957602 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=453 bytes=372
t=2957602 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=454 bytes=372
t=2957602 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=455 bytes=372
t=2957604 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=456 has_socket=true ready=true bytes=372
t=2957615 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=457 ready=true bytes=372 flushing=false
t=2957627 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=458 has_socket=true ready=true flushing=false
t=2957639 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=459 bytes=372 flushing=false ready=true
t=2957650 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=460 has_socket=true bytes=372 ready=true flushing=false
t=2957662 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=461
t=2957674 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=462 has_socket=true ready=true flushing=false
t=2957685 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=463 has_socket=true ready=true flushing=false
t=2957697 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=464 ready=true
t=2957709 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=465 ready=true
t=2957720 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=466 ready=true
t=2957732 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=467 has_socket=true flushing=false bytes=372 ready=true
t=2957743 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=468 bytes=372
t=2957755 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=469 has_socket=true bytes=372 ready=true
t=2957767 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=470 ready=true flushing=false bytes=372
t=2957779 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=471 bytes=372
t=2957791 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=472 has_socket=true bytes=372 ready=true
t=2957802 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=473 ready=true
t=2957814 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=474 ready=true
t=2957825 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=475 ready=true flushing=false bytes=372
t=2957837 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=476 bytes=372
t=2957848 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=477 ready=true flushing=false bytes=372
t=2957860 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=478 has_socket=true flushing=false bytes=372 ready=true
t=2957872 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=479 bytes=372
t=2957885 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=480 bytes=372
t=2957895 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=481 has_socket=true bytes=372 ready=true
t=2957906 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=482 bytes=372
t=2957918 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=483 ready=true
t=2957986 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=484 has_socket=true ready=true flushing=false bytes=372
t=2957986 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=485 has_socket=true ready=true flushing=false bytes=372
t=2957986 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=486 has_socket=true ready=true flushing=false bytes=372
t=2957986 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=487 has_socket=true ready=true flushing=false bytes=372
t=2957986 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=488 has_socket=true ready=true flushing=false bytes=372
t=2957987 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true ready=true bytes=372 seq=489
t=2957999 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=490 has_socket=true ready=true flushing=false
t=2958010 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=491 bytes=372
t=2958022 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=492
t=2958023 sess=9Hn lvl=INFO cat=stream evt=first_final ms=5766
t=2958023 sess=9Hn lvl=INFO cat=transcript evt=raw_final text="I can be solved through"
t=2958033 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=493
t=2958068 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=494 ready=true has_socket=true
t=2958068 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=495 ready=true has_socket=true
t=2958068 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=496 ready=true has_socket=true
t=2958080 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=497 flushing=false ready=true has_socket=true
t=2958091 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=498 bytes=372 has_socket=true
t=2958103 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=499 bytes=372 ready=true flushing=false
t=2958115 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=500 bytes=372
t=2958126 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=501 bytes=372
t=2958138 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=502 bytes=372 ready=true flushing=false
t=2958149 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=503 bytes=372 ready=true flushing=false
t=2958161 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=504 bytes=372
t=2958173 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=505 has_socket=true ready=true
t=2958184 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=506 has_socket=true ready=true flushing=false
t=2958196 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=507 ready=true bytes=372
t=2958208 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=508 ready=true flushing=false bytes=372
t=2958220 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=509 has_socket=true ready=true flushing=false
t=2958231 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=510 bytes=372
t=2958243 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=511 bytes=372 flushing=false
t=2958255 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=512 ready=true flushing=false bytes=372
t=2958267 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=513 bytes=372
t=2958277 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=514 bytes=372 flushing=false has_socket=true ready=true
t=2958290 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=515 ready=true flushing=false bytes=372
t=2958301 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=516 bytes=372
t=2958313 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=517 bytes=372
t=2958324 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=518 bytes=372
t=2958336 sess=9Hn lvl=INFO cat=audio evt=level avg_db=-41 peak_db=-41
t=2958336 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=519 has_socket=true ready=true flushing=false
t=2958347 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=520 bytes=372 flushing=false has_socket=true ready=true
t=2958359 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=521 bytes=372 flushing=false
t=2958370 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=522 bytes=372 flushing=false
t=2958382 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=523 bytes=372 flushing=false
t=2958395 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=524 has_socket=true bytes=372 ready=true
t=2958405 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=525 has_socket=true bytes=372 ready=true
t=2958417 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=526 bytes=372
t=2958428 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=527 bytes=372 flushing=false
t=2958441 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true ready=true bytes=372 seq=528
t=2958452 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=529 has_socket=true ready=true flushing=false
t=2958464 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=530 bytes=372 flushing=false has_socket=true ready=true
t=2958477 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=531 bytes=372
t=2958487 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=532 bytes=372 flushing=false
t=2958499 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=533 has_socket=true flushing=false ready=true bytes=372
t=2958510 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=534 has_socket=true ready=true flushing=false
t=2958521 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=535 ready=true bytes=372
t=2958533 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=536 has_socket=true bytes=372 ready=true
t=2958545 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=537 has_socket=true ready=true flushing=false
t=2958556 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=538 ready=true bytes=372
t=2958568 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=539 bytes=372 flushing=false
t=2958580 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=540 ready=true flushing=false bytes=372
t=2958591 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=541 bytes=372 flushing=false
t=2958603 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=542 bytes=372 flushing=false
t=2958615 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=543 bytes=372 flushing=false
t=2958626 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=544 bytes=372 flushing=false
t=2958678 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=545 ready=true bytes=372 flushing=false
t=2958678 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=546 ready=true bytes=372 flushing=false
t=2958678 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=547 ready=true bytes=372 flushing=false
t=2958678 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=548 ready=true bytes=372 flushing=false
t=2958684 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false seq=549 bytes=372
t=2958695 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=550 has_socket=true ready=true bytes=372 flushing=false
t=2958707 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=551 bytes=372 ready=true flushing=false
t=2958719 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true has_socket=true seq=552
t=2958730 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=553 bytes=372 ready=true flushing=false
t=2958784 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=554 has_socket=true ready=true flushing=false
t=2958784 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=555 has_socket=true ready=true flushing=false
t=2958784 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=556 has_socket=true ready=true flushing=false
t=2958784 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=557 has_socket=true ready=true flushing=false
t=2958788 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=558 has_socket=true bytes=372
t=2958800 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=559 has_socket=true ready=true flushing=false
t=2958811 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=560 has_socket=true ready=true flushing=false
t=2958823 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=561 bytes=372 ready=true flushing=false
t=2958835 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=562 flushing=false ready=true has_socket=true bytes=372
t=2958846 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=563 has_socket=true ready=true flushing=false
t=2958858 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=564
t=2958870 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=565 ready=true bytes=372 flushing=false has_socket=true
t=2958881 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=566 has_socket=true flushing=false bytes=372 ready=true
t=2958893 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=567 ready=true bytes=372 flushing=false has_socket=true
t=2958905 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=568 bytes=372
t=2958916 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=569 flushing=false has_socket=true ready=true bytes=372
t=2958928 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=570 flushing=false has_socket=true ready=true bytes=372
t=2958940 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=571 bytes=372
t=2958951 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=572 ready=true bytes=372
t=2958963 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=573 bytes=372
t=2958974 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=574 bytes=372 flushing=false ready=true
t=2958986 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=575 has_socket=true bytes=372 ready=true
t=2958998 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true ready=true bytes=372 seq=576
t=2959010 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=577 flushing=false has_socket=true ready=true bytes=372
t=2959022 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=578 has_socket=true ready=true flushing=false
t=2959033 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=579 flushing=false has_socket=true ready=true bytes=372
t=2959044 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=580 has_socket=true ready=true flushing=false
t=2959056 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=581 bytes=372
t=2959068 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=582 flushing=false has_socket=true ready=true bytes=372
t=2959079 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=583 ready=true bytes=372
t=2959091 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=584 bytes=372
t=2959103 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=585 bytes=372
t=2959114 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=586 flushing=false has_socket=true ready=true bytes=372
throwing -10877
throwing -10877
t=2959217 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=587 has_socket=true flushing=false bytes=372
t=2959217 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=588 has_socket=true flushing=false bytes=372
t=2959217 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=589 has_socket=true flushing=false bytes=372
t=2959217 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=590 has_socket=true flushing=false bytes=372
t=2959217 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=591 has_socket=true flushing=false bytes=372
t=2959217 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=592 has_socket=true flushing=false bytes=372
t=2959217 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=593 ready=true flushing=false has_socket=true
t=2959217 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=594 ready=true flushing=false has_socket=true
t=2959218 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=595 ready=true flushing=false has_socket=true
t=2959247 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=596 bytes=372 ready=true flushing=false
t=2959247 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=597 bytes=372 ready=true flushing=false
t=2959271 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=598 bytes=372
t=2959271 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=599 bytes=372
t=2959275 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=600 has_socket=true ready=true
t=2959287 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true has_socket=true flushing=false seq=601
t=2959299 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=602 has_socket=true ready=true
t=2959310 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=603 has_socket=true ready=true
t=2959322 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=604 bytes=372
🛑 [TEN-VAD] Speech end detected
t=2959334 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=605 has_socket=true flushing=false bytes=372 ready=true
t=2959345 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=606 has_socket=true flushing=false bytes=372 ready=true
t=2959356 sess=9Hn lvl=INFO cat=transcript evt=raw_final text=", essentially using"
t=2959357 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=607 flushing=false bytes=372 ready=true has_socket=true
t=2959391 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=608 has_socket=true ready=true
t=2959391 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=609 has_socket=true ready=true
t=2959392 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=610 has_socket=true ready=true bytes=372
t=2959403 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=611 has_socket=true ready=true bytes=372
t=2959415 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=612 bytes=372 ready=true flushing=false
t=2959426 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 ready=true seq=613
t=2959438 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=614 ready=true has_socket=true flushing=false bytes=372
t=2959450 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=615
t=2959461 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=616 has_socket=true ready=true bytes=372
t=2959473 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=617 has_socket=true ready=true bytes=372
t=2959485 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=618
🛑 [TEN-VAD] Speech end detected
t=2959496 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=619 has_socket=true ready=true flushing=false
t=2959508 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 ready=true seq=620
t=2959520 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 seq=621 ready=true flushing=false
t=2959531 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true has_socket=true bytes=372 seq=622
t=2959573 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=623 bytes=372 ready=true flushing=false
t=2959573 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=624 bytes=372 ready=true flushing=false
t=2959573 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=625 bytes=372 ready=true flushing=false
t=2959577 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=626
t=2959589 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=627 ready=true has_socket=true flushing=false bytes=372
t=2959601 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=628 ready=true has_socket=true flushing=false bytes=372
t=2959612 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=629 has_socket=true ready=true bytes=372
🛑 [TEN-VAD] Speech end detected
t=2959624 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=630 ready=true has_socket=true flushing=false bytes=372
t=2959636 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=631
t=2959647 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=632
t=2959659 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=633
t=2959670 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=634 bytes=372 ready=true flushing=false
t=2959682 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=635 ready=true bytes=372
t=2959694 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=636 has_socket=true ready=true flushing=false
t=2959743 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=637 has_socket=true flushing=false ready=true bytes=372
t=2959743 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=638 has_socket=true flushing=false ready=true bytes=372
t=2959743 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=639 has_socket=true flushing=false ready=true bytes=372
t=2959744 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=640 has_socket=true flushing=false ready=true bytes=372
t=2959752 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=641 has_socket=true ready=true flushing=false
t=2959763 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=642 has_socket=true ready=true flushing=false
t=2959775 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=643 ready=true bytes=372
t=2959787 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=644 has_socket=true ready=true flushing=false
t=2959798 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 ready=true seq=645
t=2959810 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=646 has_socket=true ready=true
t=2959821 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=647 ready=true bytes=372
t=2959833 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 ready=true seq=648
t=2959892 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=649 has_socket=true ready=true bytes=372
t=2959892 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=650 has_socket=true ready=true bytes=372
t=2959892 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=651 has_socket=true ready=true bytes=372
t=2959892 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=652 has_socket=true ready=true bytes=372
t=2959892 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=653 has_socket=true ready=true bytes=372
t=2959902 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=654 bytes=372 ready=true flushing=false
t=2959914 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=655 bytes=372 has_socket=true
t=2959953 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=656
t=2959953 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=657
t=2959953 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=658
t=2959960 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=659 flushing=false has_socket=true ready=true bytes=372
t=2959972 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=660 has_socket=true flushing=false
t=2959984 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=661 has_socket=true ready=true flushing=false bytes=372
t=2959996 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=662
t=2960007 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=663 bytes=372
t=2960019 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=664 flushing=false has_socket=true ready=true bytes=372
t=2960031 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=665 ready=true flushing=false bytes=372
t=2960042 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=666 bytes=372
🛑 Stopping recording
🛑 Stopping Clio streaming transcription
🏥 [AUDIO HEALTH] Health monitoring timer stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
🛑 Stopping unified audio capture
t=2960105 sess=9Hn lvl=INFO cat=audio evt=record_stop
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key plugInPackage
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key CMIOType
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key numberOfDevices
t=2960115 sess=9Hn lvl=INFO cat=audio evt=avcapture_stop
✅ Unified audio capture stopped
t=2960115 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=667 has_socket=true flushing=false bytes=372 ready=true
t=2960115 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=668 has_socket=true flushing=false bytes=372 ready=true
t=2960144 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true has_socket=true seq=669 bytes=372
t=2960144 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true has_socket=true seq=670 bytes=372
t=2960144 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true has_socket=true seq=671 bytes=372
📤 Sent end-of-stream signal
📤 Sent manual finalize command
🕐 Using finalization timeout: 400ms (connection took 7985ms)
ℹ️ [OPTIMISTIC] Not skipping: end=false pending=0 ms_since_last=94 tail=100 silence_ok=false tokens_quiet_ok=true partial_empty=false uncond=false
t=2960324 sess=9Hn lvl=INFO cat=transcript evt=raw_final text=" agentic matchmaking to make those connections more accessible.<end>"
🏁 Received <fin> token - finalization complete
✅ Received <fin> token after 350ms
⏹️ Keepalive timer stopped
⚡ Audio capture already stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
📉 Released connection for account account-bundle (connections: 0)
💾 [COLD-START] Updated successful streaming timestamp
💾 [COLD-START] Updated successful streaming timestamp
✅ Streaming stopped. Final transcript (105 chars, 8.3s, with audio file): "I can be solved through, essentially using agentic matchmaking to make those connections more accessible."
t=2960597 sess=9Hn lvl=INFO cat=transcript evt=final text="I can be solved through, essentially using agentic matchmaking to make those connections more accessible."
t=2960597 sess=9Hn lvl=INFO cat=transcript evt=session_end divider="────────── session end ──────────"
🌡️ [WARM] warm_socket=yes
⏹️ Keepalive timer stopped
🔌 [WS] Disconnected (socketId=sock_3372325045645707305@attempt_7)
⚠️ WebSocket did close with code 1001 (sid=sock_3372325045645707305, attemptId=7)
t=2960598 sess=9Hn lvl=WARN cat=stream evt=state code=1001 state=closed
✅ Streaming transcription completed successfully, length: 105 characters
⏱️ [TIMING] Subscription tracking: 1.0ms
⏱️ [TIMING] ASR word tracking: 0.0ms
🧠 Performing intelligent end-context detection for streaming
⏱️ [CONTEXT DETAIL] Cache check: 0.0ms
⚡ [SMART-OPTIMIZATION] Using smart cached screen context (1554 chars) - skipping new capture
⏱️ [STREAMING CONTEXT TIMING] Screen capture + context detection: 0.1ms
🎯 Starting dynamic context-aware AI enhancement with tracking for text (105 characters)
⚡ [FAST-PATH] Using pre-warmed context - skipping redundant detection
⚡ [PREWARMED] Using pre-warmed NER context fast-path
🔍 [REGISTRY] Starting context detection using new rule engine
🔍 [REGISTRY] Bundle ID: com.google.Chrome
🔍 [REGISTRY] Process name: nil
🔍 [REGISTRY] URL: nil
🔍 [REGISTRY] Window title: (17) A Yale Student Raised $3.1M in 2 Weeks for an AI Social App | Series, Nathaneo Johnson - YouTube
🔍 [REGISTRY] Content length: 1554 chars
🔍 [RULE-ENGINE] Starting hierarchical context detection
🔍 [RULE-ENGINE] Bundle ID: com.google.Chrome
🔍 [RULE-ENGINE] Process name: nil
🔍 [RULE-ENGINE] URL: nil
🔍 [RULE-ENGINE] Window title: (17) A Yale Student Raised $3.1M in 2 Weeks for an AI Social App | Series, Nathaneo Johnson - YouTube
🔄 [RULE-ENGINE] Evaluating Email context...
🔄 [RULE-ENGINE] Evaluating Code context...
🎯 [RULE-ENGINE] Detected: General
🔄 [REGISTRY] Rule engine returned .none, checking for high-confidence legacy matches only
🔄 [REGISTRY] Trying legacy Email detector (priority: 100)
📧 [EMAIL] Starting email context detection
🚫 [DYNAMIC] Email exclusion detected in content: excluding from detection
🔄 [REGISTRY] Trying legacy Code Review detector (priority: 90)
💻 [CODE] Starting code context detection
❌ [CODE] Code confidence too low: 0.000000 < 0.300000
🔄 [REGISTRY] Trying legacy Social Media detector (priority: 10)
💬 [CHAT] Starting casual chat context detection
💬 [CHAT] Casual chat context detected - Title matches: 1, Content matches: 4, Confidence: 0.280000
🚫 [REGISTRY] Legacy Social Media context rejected - rule engine returned .none and confidence not high enough (0.280000 < 0.800000)
📝 [REGISTRY] Rule engine returned .none and no high-confidence legacy matches, returning general context
📝 [PREWARMED] Non-code or unknown context → using enhanced system prompt
🚨 [PROMPT-DEBUG] About to call getSystemMessage(for: .transcriptionEnhancement)
🚨 [PROMPT-DEBUG] getSystemMessage called with mode: transcriptionEnhancement
🚨 [PROMPT-DEBUG] RETURNING TRANSCRIPTION ENHANCEMENT PROMPT
🌐 [LANG DEBUG] Multi-language setting exists: true, Single language: en
🌐 [LANG DEBUG] Using multi-language selection (prioritized): zh, en
🚨 [PROMPT-DEBUG] About to call getUserMessage(text:, mode: .transcriptionEnhancement)
🌐 [LANG DEBUG] Multi-language setting exists: true, Single language: en
🌐 [LANG DEBUG] Using multi-language selection (prioritized): zh, en
🌐 [LANG DEBUG] Multi-language setting exists: true, Single language: en
🌐 [LANG DEBUG] Using multi-language selection (prioritized): zh, en
📝 [PREWARMED-SYSTEM] Enhanced system prompt: 'You are an expert in enhancing the text provided within <TRANSCRIPT> tags according to the following guidelines: The information in <CONTEXT_INFORMATI...'
📝 [PREWARMED-USER] Enhanced user prompt: '<CONTEXT_INFORMATION>
NER Context Entities:
I've analyzed the provided information, and I can see that the user is currently viewing a YouTube video i...'
System Message: You are an expert in enhancing the text provided within <TRANSCRIPT> tags according to the following guidelines: The information in <CONTEXT_INFORMATION> section is ONLY for reference.

### INSTRUCTIO…
User Message: <CONTEXT_INFORMATION>
NER Context Entities:
I've analyzed the provided information, and I can see that the user is currently viewing a YouTube video in Google Chrome. The video is titled "A Yale Stude…
🌐 Sending custom-prompt request to LLM proxy (provider auto-selected by server)...
🔑 [DEBUG] Getting JWT token...
🔑 [DEBUG] JWT token obtained in 0ms
🎯 [CONFIG-DEBUG] Config 2: Routing to Groq endpoint (https://fly.cliovoice.com/api/llm/proxy) with model: qwen
📝 [TIMING] Request preparation: 0.1ms
🌐 [DEBUG] Sending request to proxy...
🌐 [CONNECT] New single-flight request from warmHold
🌐 [CONNECT] Attempt #8 (loop 1/2) starting…
t=2960796 sess=9Hn lvl=INFO cat=stream evt=temp_key_fetch_start
⚡ [CACHE-HIT] Retrieved temp key in 0.1ms
t=2960796 sess=9Hn lvl=INFO cat=stream evt=temp_key_fetch expires_in_s=-1 latency_ms=0 source=cached
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🌐 [WS CONNECT] Using URL: wss://stt-rt.soniox.com/transcribe-websocket
🔗 [WS] Bound socket id=sock_-5270740219771717577@attempt_8
t=2960797 sess=9Hn lvl=INFO cat=stream evt=ws_bind via_proxy=false path=/transcribe-websocket attempt=8 socket=sock_-5270740219771717577@attempt_8 target_host=stt-rt.soniox.com target_ip=resolving...
🔑 Successfully connected to Soniox using temp key (1ms key latency)
t=2960798 sess=9Hn lvl=INFO cat=stream evt=ws_bind_resolved path=/transcribe-websocket target_host=stt-rt.soniox.com target_ip=129.146.176.251 socket=sock_-5270740219771717577@attempt_8 attempt=8 via_proxy=false
🌐 [DEBUG] Proxy response received in 609ms
✅ [SSE] Parsed streaming response: 106 characters
🔍 [CONNECTION HEALTH]
🌐 [LANG DEBUG] Multi-language setting exists: true, Single language: en
🌐 [LANG DEBUG] Using multi-language selection (prioritized): zh, en
✅ Custom-prompt enhancement via proxy succeeded
t=2961361 sess=9Hn lvl=INFO cat=transcript evt=llm_final text="I can be solved through essentially using agentic matchmaking to make those connections more accessible."
📊 [DETAILED STREAMING TIMING] Streaming: 523.5ms | Context: 0.1ms | LLM: 758.6ms | Tracked Overhead: 0.0ms | Unaccounted: 4.0ms | Total: 1286.2ms
🔊 [SoundManager] Attempting to play stop sound
🔊 [SoundManager] NSSound stop sound result: true
🧹 Connection cleanup completed (session resources released)
📝 [GRACE] Recording session ended
📱 Dismissing recorder
📊 [ENHANCEMENT] Tracking 15 words - currentTier: pro, trialWordsRemaining: 2552
✅ Streaming transcription processing completed
t=2961482 sess=9Hn lvl=INFO cat=transcript evt=insert_attempt target="Google Chrome" chars=105 text="I can be solved through essentially using agentic matchmaking to make those connections more accessible. "
🔍 [PASTE DEBUG] AXIsProcessTrusted() returned true, proceeding
🔍 [PASTE DEBUG] UseDirectTextInsertion setting: false
🔍 [PASTE DEBUG] Direct insertion disabled, using clipboard paste
⌨️ Using CGEvent-based Command+V
t=2961484 sess=9Hn lvl=INFO cat=transcript evt=insert_result ok=true
📊 [POST-RELEASE E2E] 1408ms (finalize=510ms | llm=758ms | paste=0ms) | warm_socket=no
t=2961958 sess=9Hn lvl=INFO cat=stream evt=ws_handshake_metrics reused=false protocol=http/1.1 connect_ms=888 tls_ms=879 socket=sock_-5270740219771717577@attempt_8 dns_ms=0 attempt=8 total_ms=1160 proxy=false
🔌 WebSocket did open (sid=sock_-5270740219771717577, attemptId=8)
🌐 [CONNECT] Attempt #8 succeeded
📤 [START] Sent start/config on standby socket (eager mode)
t=2961960 sess=9Hn lvl=INFO cat=stream evt=start_config ctx=standby_eager attempt=8 socket=sock_-5270740219771717577@attempt_8 summary=["sr": 16000, "ctx_len": 36, "json_hash": "647d4d9a98bd6de5", "valid": true, "model": "stt-rt-preview-v2", "audio_format": "pcm_s16le", "langs": 2, "ch": 1]
🧾 [START-CONFIG] ctx=standby_eager sum=["sr": 16000, "ctx_len": 36, "json_hash": "647d4d9a98bd6de5", "valid": true, "model": "stt-rt-preview-v2", "audio_format": "pcm_s16le", "langs": 2, "ch": 1]
🧊 [STANDBY] Connected standby socket — keepalive every 10.0s, TTL=60s
📤 Sending text frame seq=4328
🔌 [READY] attemptId=8 socketId=sock_-5270740219771717577@attempt_8 start_text_sent=true
🧊 [STANDBY] WebSocket ready in 1170ms (handshake)
👂 [LISTENER] Standby listener task for socketId=sock_-5270740219771717577@attempt_8 attemptId=8
📱 Showing DynamicNotch recorder (MIT licensed)
🧊 [WARMUP] Skipping (recently run) context=recorderUIShown
🎤 [toggleRecord] Starting recording, current model: soniox-realtime-streaming
🧊 [WARMUP] Skipping (recently run) context=hotkeyDown
🎙️ Starting recording sequence...
📝 [GRACE] Recording session started with 2552 words remaining
🔧 [NER-SETUP] Setting up callback - contextService exists: true
✅ [NER-SETUP] OCR completion callback configured for NER pre-warming - callback exists: true
📊 [SESSION] Starting recording session #7
🧪 [A/B] warm_socket=yes
🧊➡️🔥 [STANDBY->ACTIVE] Consuming standby socket for new utterance
⏭️ [STANDBY->ACTIVE] START already sent on standby (eager) — skipping re-send
✅ [CACHE] Context unchanged - reusing cache (1554 chars)
♻️ [SMART-CACHE] Using cached context: 1554 characters
🔥 [NER-CACHE] Triggering NER callback with cached content (1554 chars)
✅ [NER-CACHE] NER callback triggered with cached content
✅ [STANDBY->ACTIVE] Probe keepalive OK — proceeding to resume queue
⏹️ Keepalive timer stopped
🔄 Keepalive timer started (interval: 15.000000s)
🧪 [PROMO] snapshot attempt=8 socket=sock_-5270740219771717577@attempt_8 start_sent=true ws_ready=true standby=false purpose=active cap_sr=16000 cap_ch=1 prebuf=0 last_fp=m=stt-rt-preview-v2|sr=16000|ch=1|h=en,zh|ctx=889740762234866296
t=2965004 sess=9Hn lvl=INFO cat=stream evt=temp_key_fetch_start
🔥 [PREWARM DEBUG] Pre-warming AI connection (target: Gemini), environment: flyio
⚡ [CACHE-HIT] Retrieved temp key in 0.4ms
t=2965005 sess=9Hn lvl=INFO cat=stream evt=temp_key_fetch expires_in_s=-1 source=cached latency_ms=0
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🧪 [PROMO] config_fp current=m=stt-rt-preview-v2|sr=16000|ch=1|h=en,zh|ctx=889740762234866296 last=m=stt-rt-preview-v2|sr=16000|ch=1|h=en,zh|ctx=889740762234866296
🎤 Registering audio tap for Soniox
t=2965011 sess=9Hn lvl=INFO cat=audio evt=record_start service=Soniox
🔍 Performing audio system pre-flight checks
throwing -10877
throwing -10877
✅ Pre-flight checks passed
t=2965089 sess=9Hn lvl=INFO cat=audio evt=tap_install service=Soniox ok=true backend=avcapture
t=2965089 sess=9Hn lvl=INFO cat=audio evt=record_start reason=start_capture
t=2965090 sess=9Hn lvl=INFO cat=audio evt=device_pin_start prev_id=181 prev_uid_hash=4285059772673450742 prev_name="MacBook Pro Microphone" desired_id=181 desired_name="MacBook Pro Microphone" desired_uid_hash=4285059772673450742
t=2965090 sess=9Hn lvl=INFO cat=audio evt=capture_backend_selected backend=avcapture
✅ Unified audio capture started
✅ Selected account account-bundle (connections: 1/10)
🎬 [NER-PREWARM] Using raw OCR text for NER: 1554 characters
🧠 [NER-DEFAULT] Using default NER prompt for general extraction
🧠 [TEN-VAD] Initialized (threshold=0.5, hop=256)
🚀 Starting Clio streaming transcription
🏥 [AUDIO HEALTH] Health monitoring timer started
⏱️ [TIMING] mic_engaged @ 1756226001.121
⏱️ [TIMING] WebSocket connect task completed — will flush after READY
pass
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
t=2965184 sess=9Hn lvl=INFO cat=audio evt=avcapture_start ok=true
t=2965184 sess=9Hn lvl=INFO cat=stream evt=first_audio_buffer_captured ms=61
🧪 [PROMO] first_audio seq=0 bytes=372 approx_db=-60.0
t=2965185 sess=9Hn lvl=INFO cat=audio evt=level avg_db=-60 peak_db=-60
✅ [AUDIO HEALTH] First audio data received - tap is functional
t=2965185 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false has_socket=true seq=0
t=2965185 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=1 flushing=false bytes=372 ready=true has_socket=true
t=2965185 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=2 flushing=false bytes=372 ready=true has_socket=true
t=2965185 sess=9Hn lvl=INFO cat=stream evt=first_audio_sent ms=62 seq=1
t=2965186 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=3 ready=true flushing=false bytes=360
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
t=2965193 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=4 has_socket=true ready=true bytes=360 flushing=false
t=2965204 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false seq=5 bytes=372
t=2965216 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=6 bytes=372 ready=true flushing=false
t=2965227 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=7 bytes=372 ready=true flushing=false
t=2965239 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=8 flushing=false has_socket=true
t=2965250 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=9 flushing=false has_socket=true
t=2965262 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=10 has_socket=true flushing=false
t=2965274 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=11 bytes=372 ready=true flushing=false
t=2965285 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=12 has_socket=true flushing=false
t=2965297 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=13 bytes=372 ready=true flushing=false
t=2965309 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=14 flushing=false has_socket=true
t=2965320 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=15 bytes=372 ready=true flushing=false
t=2965332 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=16 bytes=372 flushing=false has_socket=true ready=true
t=2965344 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=17 bytes=372
t=2965356 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=18 has_socket=true ready=true bytes=372 flushing=false
t=2965367 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=19 ready=true bytes=372
t=2965379 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=20 ready=true has_socket=true
t=2965390 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=21 ready=true has_socket=true
t=2965402 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=22 has_socket=true bytes=372 ready=true
t=2965415 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true has_socket=true seq=23
t=2965425 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=24 has_socket=true bytes=372 ready=true
t=2965437 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=25 bytes=372
t=2965449 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=26 bytes=372 flushing=false has_socket=true ready=true
🧪 [PROMO] audio_bytes bytes=10020
t=2965460 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=27 has_socket=true flushing=false bytes=372 ready=true
t=2965473 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=28 bytes=372 flushing=false has_socket=true ready=true
t=2965484 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=29 ready=true has_socket=true
t=2965495 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=30 bytes=372
t=2965507 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=31 bytes=372 flushing=false ready=true
t=2965518 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true has_socket=true seq=32
t=2965532 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=33 has_socket=true ready=true flushing=false
t=2965541 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=34 ready=true bytes=372
t=2965553 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=35 has_socket=true bytes=372 ready=true
t=2965565 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=36 bytes=372 flushing=false has_socket=true ready=true
t=2965576 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=37 ready=true has_socket=true
t=2965589 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=38 bytes=372 flushing=false has_socket=true ready=true
t=2965599 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=39 has_socket=true bytes=372 ready=true
t=2965611 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=40 bytes=372 flushing=false has_socket=true ready=true
t=2965623 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=41 ready=true has_socket=true flushing=false bytes=372
🌐 [PATH] Initial path baseline set — no action
t=2965634 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=42 ready=true has_socket=true
t=2965647 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=43 has_socket=true ready=true flushing=false bytes=372
t=2965657 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=44 has_socket=true ready=true bytes=372 flushing=false
t=2965669 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=45 ready=true bytes=372
🗣️ [TEN-VAD] Speech start detected
t=2965681 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=46
🛑 [TEN-VAD] Speech end detected
t=2965692 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=47 ready=true has_socket=true
t=2965705 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=48 ready=true has_socket=true flushing=false bytes=372
t=2965716 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=49 ready=true has_socket=true
t=2965727 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=50 bytes=372
t=2965740 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=51 ready=true has_socket=true flushing=false bytes=372
t=2965750 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=52 has_socket=true bytes=372 ready=true
t=2965765 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=53 bytes=372 ready=true
t=2965774 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=54 has_socket=true ready=true
t=2965785 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=55 has_socket=true ready=true bytes=372 flushing=false
t=2965798 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=56
t=2965808 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=57 ready=true bytes=372
t=2965820 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=58 ready=true bytes=372
t=2965832 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=59 bytes=372
t=2965843 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=60 bytes=372
t=2965856 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=61
t=2965867 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=62 ready=true bytes=372
t=2965878 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=63 has_socket=true ready=true flushing=false
t=2965889 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=64 has_socket=true ready=true flushing=false bytes=372
t=2965901 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=65 bytes=372
t=2965914 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=66 has_socket=true ready=true flushing=false bytes=372
t=2965924 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=67 has_socket=true ready=true flushing=false
t=2965936 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=68 bytes=372
t=2965948 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=69 has_socket=true ready=true flushing=false bytes=372
t=2965959 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=70 ready=true has_socket=true
t=2965973 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=71 ready=true has_socket=true
t=2965983 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=72 ready=true bytes=372
t=2965994 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=73 has_socket=true ready=true flushing=false
t=2966007 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=74 has_socket=true flushing=false
t=2966017 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=75 bytes=372
t=2966031 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=76 has_socket=true ready=true flushing=false
t=2966041 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=77 ready=true bytes=372
t=2966052 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=78 bytes=372
t=2966065 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true has_socket=true seq=79 flushing=false
t=2966075 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=80 ready=true has_socket=true
🧪 [PROMO] audio_bytes bytes=30108
t=2966086 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=81
t=2966099 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=82 has_socket=true bytes=372 ready=true
t=2966110 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=83 ready=true has_socket=true flushing=false
t=2966124 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=84
t=2966134 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=85
t=2966145 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=86 bytes=372 flushing=false has_socket=true ready=true
t=2966156 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=87 bytes=372 ready=true
t=2966168 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=88 has_socket=true ready=true bytes=372 flushing=false
t=2966181 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=89 ready=true bytes=372
t=2966191 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=90 ready=true has_socket=true flushing=false bytes=372
t=2966203 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=91 ready=true has_socket=true
t=2966215 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true seq=92 bytes=372 has_socket=true
t=2966226 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=93 ready=true has_socket=true flushing=false bytes=372
t=2966240 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=94 ready=true has_socket=true flushing=false bytes=372
t=2966250 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=95 flushing=false ready=true
t=2966261 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=96 ready=true bytes=372
t=2966273 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=97 bytes=372 flushing=false has_socket=true ready=true
t=2966284 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true bytes=372 ready=true seq=98
t=2966297 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=99 has_socket=true ready=true flushing=false
t=2966307 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=100 has_socket=true flushing=false
t=2966319 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=101 has_socket=true ready=true flushing=false bytes=372
t=2966331 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=102 ready=true has_socket=true bytes=372
t=2966342 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=103 ready=true has_socket=true
t=2966354 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true seq=104 bytes=372 has_socket=true
t=2966366 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=105 ready=true has_socket=true bytes=372
t=2966377 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=106 has_socket=true flushing=false bytes=372 ready=true
t=2966390 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=107 ready=true has_socket=true flushing=false bytes=372
t=2966401 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=108 bytes=372
t=2966412 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=109 flushing=false has_socket=true ready=true bytes=372
t=2966423 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=110 bytes=372
t=2966435 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=111 has_socket=true flushing=false bytes=372 ready=true
t=2966448 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=112 ready=true flushing=false has_socket=true bytes=372
t=2966458 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true has_socket=true flushing=false seq=113
t=2966470 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=114 has_socket=true bytes=372 ready=true
t=2966482 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=115 has_socket=true ready=true bytes=372 flushing=false
t=2966493 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=116 bytes=372
t=2966505 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=117 ready=true has_socket=true flushing=false bytes=372
t=2966516 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=118 bytes=372 flushing=false has_socket=true ready=true
t=2966528 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=119 bytes=372
t=2966539 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=120 bytes=372
t=2966551 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=121 ready=true bytes=372
t=2966565 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=122 has_socket=true ready=true bytes=372 flushing=false
t=2966574 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=123 has_socket=true bytes=372 ready=true
t=2966586 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=124 ready=true bytes=372
t=2966599 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=125 ready=true bytes=372
t=2966609 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=126 has_socket=true ready=true flushing=false
t=2966622 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=127 bytes=372 flushing=false has_socket=true ready=true
t=2966633 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=128 bytes=372
t=2966644 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=129 bytes=372
t=2966657 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 seq=130 flushing=false
t=2966667 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=131 has_socket=true bytes=372 ready=true
t=2966681 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=132 has_socket=true ready=true
t=2966691 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=133 flushing=false ready=true has_socket=true bytes=372
🤖 [FLY.IO-NER] Server-reported provider: gemini
📥 [NER-STORE] Stored NER entities: 886 chars - The user has provided a screenshot of their active Chrome window, which is displaying a YouTube vide...
✅ [FLY.IO] NER refresh completed successfully
t=2966702 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=134 bytes=372 flushing=false has_socket=true ready=true
t=2966715 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=135 bytes=372 flushing=false
t=2966726 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=136 bytes=372 flushing=false has_socket=true ready=true
t=2966737 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=137 bytes=372
t=2966748 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 seq=138 ready=true
t=2966760 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=139 ready=true bytes=372
t=2966773 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=140 has_socket=true bytes=372 ready=true
t=2966783 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 seq=141 flushing=false
t=2966795 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 seq=142 flushing=false
t=2966807 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=143 bytes=372
t=2966818 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=144 bytes=372
t=2966830 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=145 bytes=372
t=2966841 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=146 bytes=372
t=2966853 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=147 ready=true bytes=372
t=2966865 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true has_socket=true seq=148
t=2966877 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=149 bytes=372
t=2966888 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=150 bytes=372 flushing=false has_socket=true ready=true
t=2966893 sess=9Hn lvl=INFO cat=stream evt=first_partial ms=1770
t=2966893 sess=9Hn lvl=INFO cat=stream evt=ttft_hotkey ms=1770
t=2966893 sess=9Hn lvl=INFO cat=stream evt=ttft ms=1223
🧪 [PROMO] first_token ms=1889 tokens_in_msg=1
t=2966957 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 ready=true seq=151 flushing=false
t=2966957 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 ready=true seq=152 flushing=false
t=2966957 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 ready=true seq=153 flushing=false
t=2966957 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 ready=true seq=154 flushing=false
t=2966957 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 ready=true seq=155 flushing=false
t=2966958 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true seq=156 bytes=372
t=2966969 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=157 flushing=false has_socket=true
t=2966980 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=158 flushing=false has_socket=true bytes=372 ready=true
t=2966992 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true has_socket=true seq=159 flushing=false
t=2967028 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 seq=160 has_socket=true
t=2967028 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 seq=161 has_socket=true
t=2967028 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 seq=162 has_socket=true
t=2967038 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true bytes=372 ready=true seq=163
t=2967050 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=164
t=2967062 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=165 bytes=372 ready=true flushing=false
t=2967073 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=166
t=2967085 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=167
t=2967096 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=168
t=2967108 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=169
t=2967120 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=170 bytes=372 ready=true flushing=false
t=2967132 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=171 bytes=372 has_socket=true ready=true flushing=false
t=2967175 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=172 has_socket=true ready=true
t=2967175 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=173 has_socket=true ready=true
t=2967175 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=174 bytes=372 ready=true flushing=false
t=2967178 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=175 bytes=372 ready=true flushing=false
t=2967189 sess=9Hn lvl=INFO cat=audio evt=level peak_db=-32 avg_db=-32
t=2967189 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=176 ready=true flushing=false
t=2967201 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=177
t=2967213 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=178 bytes=372 ready=true flushing=false
t=2967224 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=179 ready=true flushing=false
t=2967236 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true seq=180 has_socket=true bytes=372
t=2967248 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=181 bytes=372 ready=true flushing=false
t=2967259 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=182 has_socket=true
t=2967271 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=183 ready=true flushing=false
t=2967282 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=184 bytes=372
t=2967294 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=185 ready=true bytes=372
t=2967306 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=186 bytes=372
t=2967360 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true bytes=372 ready=true seq=187
t=2967360 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true bytes=372 ready=true seq=188
t=2967360 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true bytes=372 ready=true seq=189
t=2967360 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true bytes=372 ready=true seq=190
t=2967363 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=191 bytes=372 ready=true flushing=false
t=2967376 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=192 flushing=false has_socket=true
t=2967387 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=193 bytes=372 flushing=false has_socket=true ready=true
t=2967430 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=194 has_socket=true ready=true bytes=372 flushing=false
t=2967430 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=195 has_socket=true ready=true bytes=372 flushing=false
t=2967430 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=196 has_socket=true ready=true bytes=372 flushing=false
t=2967433 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=197 ready=true has_socket=true bytes=372
t=2967445 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=198 bytes=372 ready=true flushing=false
t=2967456 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=199 bytes=372 has_socket=true ready=true flushing=false
t=2967468 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=200 bytes=372 ready=true flushing=false
t=2967480 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=201 flushing=false bytes=372 has_socket=true ready=true
t=2967491 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=202 bytes=372 has_socket=true ready=true flushing=false
t=2967503 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=203 ready=true flushing=false
t=2967515 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=204 ready=true flushing=false
t=2967555 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=205 bytes=372 ready=true flushing=false
t=2967555 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=206 bytes=372 ready=true flushing=false
t=2967555 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=207 bytes=372 ready=true flushing=false
t=2967561 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=208 bytes=372 ready=true flushing=false
t=2967573 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=209 bytes=372 ready=true flushing=false
t=2967584 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false seq=210 has_socket=true
t=2967596 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=211 flushing=false has_socket=true
t=2967607 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=212
t=2967619 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true has_socket=true seq=213
t=2967631 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true has_socket=true seq=214
t=2967642 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=215 has_socket=true ready=true bytes=372
t=2967654 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=216 has_socket=true ready=true flushing=false bytes=372
t=2967666 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=217 bytes=372
t=2967677 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=218 has_socket=true ready=true flushing=false
t=2967689 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=219 ready=true bytes=372
t=2967700 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=220 ready=true has_socket=true
t=2967712 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=221 has_socket=true bytes=372 ready=true
t=2967724 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=222 has_socket=true ready=true flushing=false
t=2967735 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=223 ready=true flushing=false bytes=372 has_socket=true
t=2967747 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=224 ready=true has_socket=true
t=2967797 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false seq=225 bytes=372
t=2967797 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false seq=226 bytes=372
t=2967797 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false seq=227 bytes=372
t=2967797 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false seq=228 bytes=372
t=2967805 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=229
t=2967817 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=230 flushing=false has_socket=true
t=2967828 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=231 ready=true bytes=372
t=2967840 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=232 flushing=false has_socket=true
t=2967851 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=233 has_socket=true
t=2967863 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=234 bytes=372 ready=true has_socket=true flushing=false
t=2967918 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=235 ready=true flushing=false bytes=372 has_socket=true
t=2967918 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=236 ready=true flushing=false bytes=372 has_socket=true
t=2967918 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=237 ready=true flushing=false bytes=372 has_socket=true
t=2967918 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=238 ready=true flushing=false bytes=372 has_socket=true
t=2967921 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=239
t=2967933 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true seq=240 has_socket=true bytes=372
t=2967944 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=241 bytes=372 ready=true flushing=false
t=2967956 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=242 has_socket=true ready=true flushing=false bytes=372
t=2967967 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=243 bytes=372 ready=true flushing=false
t=2968005 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=244 flushing=false has_socket=true bytes=372 ready=true
t=2968005 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=245 flushing=false has_socket=true bytes=372 ready=true
t=2968005 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=246 flushing=false has_socket=true bytes=372 ready=true
t=2968014 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=247 has_socket=true ready=true
t=2968025 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=248 bytes=372 ready=true flushing=false
t=2968037 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=249 flushing=false ready=true bytes=372
t=2968049 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=250 bytes=372 ready=true flushing=false
t=2968060 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=251 bytes=372 ready=true flushing=false
t=2968072 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=252 has_socket=true ready=true
t=2968083 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=253 bytes=372 ready=true flushing=false
t=2968095 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=254 ready=true flushing=false bytes=372 has_socket=true
t=2968107 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=255 flushing=false has_socket=true bytes=372 ready=true
t=2968149 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true seq=256 has_socket=true bytes=372
t=2968149 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true seq=257 has_socket=true bytes=372
t=2968149 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=258 ready=true flushing=false has_socket=true bytes=372
t=2968153 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=259 ready=true flushing=false bytes=372 has_socket=true
t=2968165 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=260 bytes=372 ready=true flushing=false
t=2968176 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true seq=261 has_socket=true bytes=372
t=2968188 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=262 ready=true has_socket=true
t=2968199 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=263 bytes=372
t=2968211 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=264 ready=true has_socket=true
t=2968223 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=265 bytes=372
t=2968234 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=266 bytes=372
t=2968246 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=267
t=2968258 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=268 ready=true bytes=372
t=2968269 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=269 has_socket=true bytes=372 ready=true
t=2968281 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=270 ready=true bytes=372
t=2968293 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 flushing=false seq=271
t=2968304 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=272 ready=true bytes=372
t=2968316 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=273 has_socket=true ready=true bytes=372 flushing=false
t=2968328 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=274 ready=true flushing=false bytes=372 has_socket=true
t=2968339 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=275 has_socket=true bytes=372 ready=true
t=2968350 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=276 ready=true flushing=false bytes=372 has_socket=true
t=2968362 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=277 ready=true flushing=false bytes=372 has_socket=true
t=2968374 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 flushing=false seq=278
t=2968385 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=279 bytes=372
t=2968397 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=280 bytes=372
t=2968409 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true has_socket=true seq=281
t=2968421 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=282 has_socket=true bytes=372 ready=true
t=2968433 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=283 ready=true bytes=372
t=2968443 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=284 has_socket=true ready=true flushing=false
t=2968456 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 flushing=false seq=285
t=2968467 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 flushing=false seq=286
t=2968517 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=287 bytes=372 ready=true flushing=false
t=2968517 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=288 bytes=372 ready=true flushing=false
t=2968517 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=289 bytes=372 ready=true flushing=false
t=2968517 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=290 bytes=372 ready=true flushing=false
t=2968524 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=291 flushing=false has_socket=true
t=2968536 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=292
t=2968548 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=293 flushing=false has_socket=true
t=2968559 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=294 has_socket=true ready=true
t=2968600 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=295 ready=true bytes=372
t=2968600 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=296 ready=true bytes=372
t=2968600 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=297 ready=true bytes=372
t=2968606 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=298 bytes=372 has_socket=true ready=true flushing=false
t=2968617 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=299 has_socket=true flushing=false bytes=372
t=2968629 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=300
t=2968641 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=301 ready=true has_socket=true flushing=false
t=2968652 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=302 has_socket=true flushing=false
t=2968664 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=303
t=2968676 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=304 has_socket=true
t=2968687 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true bytes=372 ready=true seq=305
t=2968699 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=306 ready=true has_socket=true
t=2968710 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true has_socket=true seq=307
t=2968722 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=308 has_socket=true ready=true flushing=false
t=2968734 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=309 bytes=372
t=2968745 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=310 bytes=372
t=2968757 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=311
t=2968769 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=312 has_socket=true ready=true flushing=false
t=2968780 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=313 bytes=372
t=2968792 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=314
t=2968804 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=315 bytes=372
t=2968816 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=316 flushing=false ready=true bytes=372 has_socket=true
t=2968827 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=317 has_socket=true ready=true bytes=372 flushing=false
t=2968838 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=318 flushing=false ready=true bytes=372 has_socket=true
t=2968850 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=319 has_socket=true ready=true flushing=false
t=2968861 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=320 ready=true has_socket=true
t=2968920 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false ready=true seq=321 has_socket=true
t=2968920 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false ready=true seq=322 has_socket=true
t=2968920 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false ready=true seq=323 has_socket=true
t=2968920 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false ready=true seq=324 has_socket=true
t=2968920 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false ready=true seq=325 has_socket=true
t=2968931 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=326 flushing=false bytes=372 ready=true
t=2968943 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=327 flushing=false bytes=372 ready=true
t=2968954 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=328 flushing=false has_socket=true bytes=372
t=2968966 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=329 has_socket=true
t=2968977 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=330
t=2968989 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=331 has_socket=true
t=2969000 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true seq=332 flushing=false
t=2969013 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=333 ready=true flushing=false has_socket=true bytes=372
t=2969025 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=334 has_socket=true bytes=372 ready=true
t=2969036 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=335 has_socket=true ready=true flushing=false bytes=372
t=2969048 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=336 has_socket=true ready=true flushing=false bytes=372
t=2969059 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=337 has_socket=true ready=true flushing=false bytes=372
t=2969071 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false ready=true seq=338
t=2969082 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=339 ready=true flushing=false has_socket=true bytes=372
t=2969094 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 seq=340 flushing=false
t=2969105 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=341 has_socket=true ready=true flushing=false
t=2969117 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=342
throwing -10877
throwing -10877
t=2969209 sess=9Hn lvl=INFO cat=audio evt=level peak_db=-35 avg_db=-35
t=2969209 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=343 ready=true
...
t=2971137 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=516 has_socket=true
🛑 [TEN-VAD] Speech end detected
t=2971149 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=517 ready=true has_socket=true
t=2971160 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=518 bytes=372
t=2971172 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=519 bytes=372
t=2971183 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=520 has_socket=true bytes=372 ready=true
t=2971195 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=521 flushing=false has_socket=true bytes=372 ready=true
🛑 [TEN-VAD] Speech end detected
t=2971207 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=522 bytes=372
t=2971218 sess=9Hn lvl=INFO cat=audio evt=level avg_db=-50 peak_db=-50
t=2971218 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=523 ready=true bytes=372
t=2971268 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=524 bytes=372 ready=true flushing=false
t=2971268 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=525 bytes=372 ready=true flushing=false
t=2971268 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=526 bytes=372 ready=true flushing=false
t=2971268 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=527 bytes=372 ready=true flushing=false
t=2971276 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=528 ready=true flushing=false bytes=372 has_socket=true
t=2971288 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=529 ready=true flushing=false bytes=372 has_socket=true
t=2971299 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=530
t=2971311 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=531 has_socket=true ready=true
t=2971323 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true has_socket=true seq=532
t=2971334 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=533
t=2971346 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=534
t=2971358 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=535
t=2971370 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=536 has_socket=true
t=2971380 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=537 has_socket=true
t=2971392 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=538 bytes=372 ready=true flushing=false
t=2971404 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=539 has_socket=true
🛑 Stopping recording
🛑 Stopping Clio streaming transcription
🏥 [AUDIO HEALTH] Health monitoring timer stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
🛑 Stopping unified audio capture
t=2971509 sess=9Hn lvl=INFO cat=audio evt=record_stop
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key plugInPackage
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key CMIOType
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key numberOfDevices
t=2971518 sess=9Hn lvl=INFO cat=audio evt=avcapture_stop
✅ Unified audio capture stopped
t=2971521 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=540 bytes=372 ready=true flushing=false
t=2971521 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=541 bytes=372 ready=true flushing=false
t=2971521 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=542 bytes=372 ready=true flushing=false
t=2971521 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=543 bytes=372 ready=true flushing=false
t=2971521 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=544 bytes=372 ready=true flushing=false
t=2971550 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true seq=545 bytes=372
t=2971550 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true seq=546 bytes=372
t=2971550 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true seq=547 bytes=372
t=2971550 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true seq=548 bytes=372
📤 Sent end-of-stream signal
📤 Sent manual finalize command
🕐 Using finalization timeout: 400ms (connection took 6522ms)
ℹ️ [OPTIMISTIC] Not skipping: end=false pending=0 ms_since_last=90 tail=100 silence_ok=false tokens_quiet_ok=false partial_empty=false uncond=false
t=2971954 sess=9Hn lvl=INFO cat=transcript evt=raw_final text=" experimenting with AI, "
t=2972021 sess=9Hn lvl=INFO cat=transcript evt=raw_final text="right? I come from a CS background and was able to.<end>"
🏁 Received <fin> token - finalization complete
⏹️ Keepalive timer stopped
⚡ Audio capture already stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
📉 Released connection for account account-bundle (connections: 0)
💾 [COLD-START] Updated successful streaming timestamp
💾 [COLD-START] Updated successful streaming timestamp
✅ Streaming stopped. Final transcript (106 chars, 7.0s, with audio file): "So what happened is we ended up experimenting with AI, right? I come from a CS background and was able to."
t=2972096 sess=9Hn lvl=INFO cat=transcript evt=final text="So what happened is we ended up experimenting with AI, right? I come from a CS background and was able to."
t=2972096 sess=9Hn lvl=INFO cat=transcript evt=session_end divider="────────── session end ──────────"
🌡️ [WARM] warm_socket=yes
⏹️ Keepalive timer stopped
⚠️ WebSocket did close with code 1001 (sid=sock_-5270740219771717577, attemptId=8)
🔌 [WS] Disconnected (socketId=sock_-5270740219771717577@attempt_8)
t=2972096 sess=9Hn lvl=WARN cat=stream evt=state state=closed code=1001
✅ Streaming transcription completed successfully, length: 106 characters
⏱️ [TIMING] Subscription tracking: 0.3ms
⏱️ [TIMING] ASR word tracking: 0.0ms
🧠 Performing intelligent end-context detection for streaming
⏱️ [CONTEXT DETAIL] Cache check: 0.0ms
⚡ [SMART-OPTIMIZATION] Using smart cached screen context (1554 chars) - skipping new capture
⏱️ [STREAMING CONTEXT TIMING] Screen capture + context detection: 0.0ms
🎯 Starting dynamic context-aware AI enhancement with tracking for text (106 characters)
⚡ [FAST-PATH] Using pre-warmed context - skipping redundant detection
⚡ [PREWARMED] Using pre-warmed NER context fast-path
🔍 [REGISTRY] Starting context detection using new rule engine
🔍 [REGISTRY] Bundle ID: com.google.Chrome
🔍 [REGISTRY] Process name: nil
🔍 [REGISTRY] URL: nil
🔍 [REGISTRY] Window title: (17) A Yale Student Raised $3.1M in 2 Weeks for an AI Social App | Series, Nathaneo Johnson - YouTube
🔍 [REGISTRY] Content length: 1554 chars
🎯 [RULE-ENGINE] Cache hit for com.google.Chrome|||(17) A Yale Student Raised $3.1M in 2 Weeks for an AI Social App | Series, Nathaneo Johnson - YouTube
🔄 [REGISTRY] Rule engine returned .none, checking for high-confidence legacy matches only
🔄 [REGISTRY] Trying legacy Email detector (priority: 100)
📧 [EMAIL] Starting email context detection
🚫 [DYNAMIC] Email exclusion detected in content: excluding from detection
🔄 [REGISTRY] Trying legacy Code Review detector (priority: 90)
💻 [CODE] Starting code context detection
❌ [CODE] Code confidence too low: 0.000000 < 0.300000
🔄 [REGISTRY] Trying legacy Social Media detector (priority: 10)
💬 [CHAT] Starting casual chat context detection
💬 [CHAT] Casual chat context detected - Title matches: 1, Content matches: 4, Confidence: 0.280000
🚫 [REGISTRY] Legacy Social Media context rejected - rule engine returned .none and confidence not high enough (0.280000 < 0.800000)
📝 [REGISTRY] Rule engine returned .none and no high-confidence legacy matches, returning general context
📝 [PREWARMED] Non-code or unknown context → using enhanced system prompt
🚨 [PROMPT-DEBUG] About to call getSystemMessage(for: .transcriptionEnhancement)
🚨 [PROMPT-DEBUG] getSystemMessage called with mode: transcriptionEnhancement
🚨 [PROMPT-DEBUG] RETURNING TRANSCRIPTION ENHANCEMENT PROMPT
🌐 [LANG DEBUG] Multi-language setting exists: true, Single language: en
🌐 [LANG DEBUG] Using multi-language selection (prioritized): zh, en
🚨 [PROMPT-DEBUG] About to call getUserMessage(text:, mode: .transcriptionEnhancement)
🌐 [LANG DEBUG] Multi-language setting exists: true, Single language: en
🌐 [LANG DEBUG] Using multi-language selection (prioritized): zh, en
🌐 [LANG DEBUG] Multi-language setting exists: true, Single language: en
🌐 [LANG DEBUG] Using multi-language selection (prioritized): zh, en
📝 [PREWARMED-SYSTEM] Enhanced system prompt: 'You are an expert in enhancing the text provided within <TRANSCRIPT> tags according to the following guidelines: The information in <CONTEXT_INFORMATI...'
📝 [PREWARMED-USER] Enhanced user prompt: '<CONTEXT_INFORMATION>
NER Context Entities:
The user has provided a screenshot of their active Chrome window, which is displaying a YouTube video titl...'
System Message: You are an expert in enhancing the text provided within <TRANSCRIPT> tags according to the following guidelines: The information in <CONTEXT_INFORMATION> section is ONLY for reference.

### INSTRUCTIO…
User Message: <CONTEXT_INFORMATION>
NER Context Entities:
The user has provided a screenshot of their active Chrome window, which is displaying a YouTube video titled "A Yale Student Raised $3.1M in 2 Weeks for an …
🌐 Sending custom-prompt request to LLM proxy (provider auto-selected by server)...
🔑 [DEBUG] Getting JWT token...
🔑 [DEBUG] JWT token obtained in 0ms
🎯 [CONFIG-DEBUG] Config 2: Routing to Groq endpoint (https://fly.cliovoice.com/api/llm/proxy) with model: qwen
📝 [TIMING] Request preparation: 0.1ms
🌐 [DEBUG] Sending request to proxy...
🌐 [CONNECT] New single-flight request from warmHold
🌐 [CONNECT] Attempt #9 (loop 1/2) starting…
t=2972238 sess=9Hn lvl=INFO cat=stream evt=temp_key_fetch_start
⚡ [CACHE-HIT] Retrieved temp key in 0.1ms
t=2972239 sess=9Hn lvl=INFO cat=stream evt=temp_key_fetch source=cached latency_ms=0 expires_in_s=-1
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🌐 [WS CONNECT] Using URL: wss://stt-rt.soniox.com/transcribe-websocket
🔗 [WS] Bound socket id=sock_-5131603304247269425@attempt_9
t=2972239 sess=9Hn lvl=INFO cat=stream evt=ws_bind socket=sock_-5131603304247269425@attempt_9 attempt=9 via_proxy=false target_host=stt-rt.soniox.com path=/transcribe-websocket target_ip=resolving...
🔑 Successfully connected to Soniox using temp key (1ms key latency)
t=2972240 sess=9Hn lvl=INFO cat=stream evt=ws_bind_resolved target_ip=129.146.176.251 target_host=stt-rt.soniox.com via_proxy=false path=/transcribe-websocket attempt=9 socket=sock_-5131603304247269425@attempt_9
🌐 [DEBUG] Proxy response received in 517ms
✅ [SSE] Parsed streaming response: 98 characters
🔍 [CONNECTION HEALTH]
🌐 [LANG DEBUG] Multi-language setting exists: true, Single language: en
🌐 [LANG DEBUG] Using multi-language selection (prioritized): zh, en
✅ Custom-prompt enhancement via proxy succeeded
t=2972704 sess=9Hn lvl=INFO cat=transcript evt=llm_final text="What happened is we ended up experimenting with AI. I come from a CS background and was able to."
📊 [DETAILED STREAMING TIMING] Streaming: 624.5ms | Context: 0.0ms | LLM: 607.0ms | Tracked Overhead: 0.0ms | Unaccounted: 0.9ms | Total: 1232.4ms
🔊 [SoundManager] Attempting to play stop sound
🔊 [SoundManager] NSSound stop sound result: true
🧹 Connection cleanup completed (session resources released)
📝 [GRACE] Recording session ended
📱 Dismissing recorder
📊 [ENHANCEMENT] Tracking 19 words - currentTier: pro, trialWordsRemaining: 2552
✅ Streaming transcription processing completed
t=2972809 sess=9Hn lvl=INFO cat=transcript evt=insert_attempt target="Google Chrome" chars=97 text="What happened is we ended up experimenting with AI. I come from a CS background and was able to. "
🔍 [PASTE DEBUG] AXIsProcessTrusted() returned true, proceeding
🔍 [PASTE DEBUG] UseDirectTextInsertion setting: false
🔍 [PASTE DEBUG] Direct insertion disabled, using clipboard paste
⌨️ Using CGEvent-based Command+V
t=2972810 sess=9Hn lvl=INFO cat=transcript evt=insert_result ok=true
📊 [POST-RELEASE E2E] 1338ms (finalize=550ms | llm=606ms | paste=0ms) | warm_socket=no
t=2973373 sess=9Hn lvl=INFO cat=stream evt=ws_handshake_metrics reused=false protocol=http/1.1 connect_ms=853 tls_ms=848 socket=sock_-5131603304247269425@attempt_9 dns_ms=1 attempt=9 total_ms=1132 proxy=false
🔌 WebSocket did open (sid=sock_-5131603304247269425, attemptId=9)
🌐 [CONNECT] Attempt #9 succeeded
📤 [START] Sent start/config on standby socket (eager mode)
t=2973373 sess=9Hn lvl=INFO cat=stream evt=start_config socket=sock_-5131603304247269425@attempt_9 attempt=9 summary=["valid": true, "sr": 16000, "audio_format": "pcm_s16le", "ctx_len": 36, "model": "stt-rt-preview-v2", "json_hash": "74c88fa4ee9a34f7", "langs": 2, "ch": 1] ctx=standby_eager
🧾 [START-CONFIG] ctx=standby_eager sum=["valid": true, "sr": 16000, "audio_format": "pcm_s16le", "ctx_len": 36, "model": "stt-rt-preview-v2", "json_hash": "74c88fa4ee9a34f7", "langs": 2, "ch": 1]
📤 Sending text frame seq=4878
🧊 [STANDBY] Connected standby socket — keepalive every 10.0s, TTL=60s
🔌 [READY] attemptId=9 socketId=sock_-5131603304247269425@attempt_9 start_text_sent=true
🧊 [STANDBY] WebSocket ready in 1136ms (handshake)
👂 [LISTENER] Standby listener task for socketId=sock_-5131603304247269425@attempt_9 attemptId=9
📱 Showing DynamicNotch recorder (MIT licensed)
🧊 [WARMUP] Skipping (recently run) context=recorderUIShown
🎤 [toggleRecord] Starting recording, current model: soniox-realtime-streaming
🧊 [WARMUP] Skipping (recently run) context=hotkeyDown
🎙️ Starting recording sequence...
📝 [GRACE] Recording session started with 2552 words remaining
🔧 [NER-SETUP] Setting up callback - contextService exists: true
✅ [NER-SETUP] OCR completion callback configured for NER pre-warming - callback exists: true
📊 [SESSION] Starting recording session #8
🧪 [A/B] warm_socket=yes
🧊➡️🔥 [STANDBY->ACTIVE] Consuming standby socket for new utterance
⏭️ [STANDBY->ACTIVE] START already sent on standby (eager) — skipping re-send
✅ [CACHE] Context unchanged - reusing cache (1554 chars)
♻️ [SMART-CACHE] Using cached context: 1554 characters
🔥 [NER-CACHE] Triggering NER callback with cached content (1554 chars)
✅ [NER-CACHE] NER callback triggered with cached content
✅ [STANDBY->ACTIVE] Probe keepalive OK — proceeding to resume queue
⏹️ Keepalive timer stopped
🔄 Keepalive timer started (interval: 15.000000s)
🧪 [PROMO] snapshot attempt=9 socket=sock_-5131603304247269425@attempt_9 start_sent=true ws_ready=true standby=false purpose=active cap_sr=16000 cap_ch=1 prebuf=0 last_fp=m=stt-rt-preview-v2|sr=16000|ch=1|h=en,zh|ctx=889740762234866296
t=2976197 sess=9Hn lvl=INFO cat=stream evt=temp_key_fetch_start
🔥 [PREWARM DEBUG] Pre-warming AI connection (target: Gemini), environment: flyio
⚡ [CACHE-HIT] Retrieved temp key in 0.2ms
t=2976197 sess=9Hn lvl=INFO cat=stream evt=temp_key_fetch latency_ms=0 source=cached expires_in_s=-1
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🧪 [PROMO] config_fp current=m=stt-rt-preview-v2|sr=16000|ch=1|h=en,zh|ctx=889740762234866296 last=m=stt-rt-preview-v2|sr=16000|ch=1|h=en,zh|ctx=889740762234866296
🎤 Registering audio tap for Soniox
t=2976214 sess=9Hn lvl=INFO cat=audio evt=record_start service=Soniox
🔍 Performing audio system pre-flight checks
throwing -10877
throwing -10877
✅ Pre-flight checks passed
t=2976290 sess=9Hn lvl=INFO cat=audio evt=tap_install service=Soniox backend=avcapture ok=true
t=2976291 sess=9Hn lvl=INFO cat=audio evt=record_start reason=start_capture
t=2976291 sess=9Hn lvl=INFO cat=audio evt=device_pin_start desired_name="MacBook Pro Microphone" prev_id=181 prev_name="MacBook Pro Microphone" prev_uid_hash=4285059772673450742 desired_id=181 desired_uid_hash=4285059772673450742
t=2976291 sess=9Hn lvl=INFO cat=audio evt=capture_backend_selected backend=avcapture
✅ Unified audio capture started
✅ Selected account account-bundle (connections: 1/10)
🎬 [NER-PREWARM] Using raw OCR text for NER: 1554 characters
🧠 [NER-DEFAULT] Using default NER prompt for general extraction
🧠 [TEN-VAD] Initialized (threshold=0.5, hop=256)
🚀 Starting Clio streaming transcription
🏥 [AUDIO HEALTH] Health monitoring timer started
⏱️ [TIMING] mic_engaged @ 1756226012.321
⏱️ [TIMING] WebSocket connect task completed — will flush after READY
pass
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
t=2976390 sess=9Hn lvl=INFO cat=audio evt=avcapture_start ok=true
t=2976390 sess=9Hn lvl=INFO cat=stream evt=first_audio_buffer_captured ms=66
🧪 [PROMO] first_audio seq=0 bytes=372 approx_db=-60.0
t=2976391 sess=9Hn lvl=INFO cat=audio evt=level peak_db=-60 avg_db=-60
t=2976392 sess=9Hn lvl=WARN cat=audio evt=silence_detected device_name="MacBook Pro Microphone" device_uid_hash=4285059772673450742 threshold_db=-50 duration_s=3 device_id=181
✅ [AUDIO HEALTH] First audio data received - tap is functional
t=2976392 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=0 bytes=372 has_socket=true
t=2976392 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=1 has_socket=true ready=true flushing=false
t=2976392 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=2 has_socket=true ready=true flushing=false
t=2976392 sess=9Hn lvl=INFO cat=stream evt=first_audio_sent ms=68 seq=1
t=2976392 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=3 has_socket=true flushing=false bytes=360
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
t=2976393 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=4 has_socket=true ready=true bytes=360 flushing=false
t=2976405 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true ready=true bytes=372 seq=5
t=2976416 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true seq=6 has_socket=true bytes=372
t=2976428 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true bytes=372 seq=7 ready=true
t=2976439 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=8 has_socket=true ready=true
t=2976451 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=9 has_socket=true ready=true flushing=false bytes=372
t=2976462 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=10 has_socket=true ready=true flushing=false
t=2976474 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true has_socket=true flushing=false seq=11
t=2976486 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true bytes=372 seq=12 ready=true
t=2976498 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=13 bytes=372 flushing=false has_socket=true ready=true
t=2976509 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 seq=14 flushing=false
t=2976521 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=15
t=2976532 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 seq=16 flushing=false
t=2976544 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 seq=17 flushing=false
t=2976556 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 seq=18 flushing=false
t=2976567 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true has_socket=true seq=19
t=2976579 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=20 has_socket=true bytes=372 ready=true
t=2976591 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=21 ready=true bytes=372
t=2976602 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=22 has_socket=true ready=true bytes=372 flushing=false
t=2976615 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=23 ready=true bytes=372
t=2976625 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=24 has_socket=true ready=true flushing=false
t=2976637 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=25 bytes=372
t=2976649 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 flushing=false seq=26
🧪 [PROMO] audio_bytes bytes=10020
t=2976660 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 seq=27 flushing=false
t=2976673 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=28 bytes=372
t=2976683 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=29 has_socket=true ready=true flushing=false
t=2976695 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 seq=30 flushing=false
t=2976707 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=31 ready=true has_socket=true
t=2976719 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=32 bytes=372
t=2976732 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=33 ready=true has_socket=true bytes=372 flushing=false
t=2976742 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true has_socket=true seq=34
t=2976754 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 seq=35 flushing=false
t=2976765 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=36 bytes=372
t=2976777 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=37 has_socket=true ready=true flushing=false
t=2976789 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 flushing=false seq=38
t=2976799 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=39 ready=true bytes=372
t=2976811 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=40 bytes=372
t=2976823 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=41
🗣️ [TEN-VAD] Speech start detected
🌐 [PATH] Initial path baseline set — no action
t=2976835 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=42 ready=true bytes=372
🛑 [TEN-VAD] Speech end detected
t=2976847 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=43 bytes=372 ready=true
t=2976857 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=44 ready=true flushing=false bytes=372
t=2976869 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=45 ready=true bytes=372
t=2976882 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 seq=46 flushing=false
t=2976892 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 flushing=false seq=47
t=2976905 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=48 ready=true flushing=false bytes=372 has_socket=true
t=2976916 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=49 bytes=372
t=2976927 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=50 ready=true bytes=372
t=2976940 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=51 ready=true bytes=372
t=2976950 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 flushing=false seq=52
t=2976962 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=53 has_socket=true ready=true flushing=false
t=2976974 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=54 ready=true flushing=false
t=2976985 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 seq=55 flushing=false
t=2976998 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 flushing=false seq=56
t=2977009 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=57 has_socket=true ready=true flushing=false
t=2977020 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 flushing=false seq=58
t=2977032 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=59 bytes=372 flushing=false has_socket=true
t=2977043 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=60 has_socket=true ready=true bytes=372 flushing=false
t=2977056 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=61 has_socket=true ready=true flushing=false
t=2977067 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=62 ready=true has_socket=true bytes=372 flushing=false
t=2977078 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=63 ready=true bytes=372
t=2977090 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=64 bytes=372
t=2977101 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=65 has_socket=true ready=true flushing=false bytes=372
t=2977115 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=66 has_socket=true ready=true bytes=372 flushing=false
t=2977125 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=67 bytes=372
t=2977136 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=68 ready=true bytes=372
t=2977149 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=69 bytes=372
t=2977159 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true has_socket=true seq=70
t=2977172 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 seq=71 flushing=false
t=2977183 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 flushing=false seq=72
t=2977194 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=73 has_socket=true bytes=372 ready=true
t=2977207 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=74 bytes=372
t=2977217 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=75 ready=true flushing=false has_socket=true bytes=372
t=2977230 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 flushing=false seq=76
t=2977241 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=77 bytes=372 flushing=false ready=true
t=2977252 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=78 has_socket=true ready=true flushing=false
t=2977265 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=79 has_socket=true ready=true bytes=372
t=2977276 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=80 ready=true bytes=372
🧪 [PROMO] audio_bytes bytes=30108
t=2977290 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=81 has_socket=true ready=true bytes=372
t=2977299 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=82 ready=true flushing=false bytes=372
t=2977310 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=83 ready=true flushing=false bytes=372
t=2977324 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=84
t=2977334 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=85 has_socket=true ready=true flushing=false
t=2977348 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=86 ready=true has_socket=true bytes=372
t=2977357 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=87 bytes=372
t=2977368 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=88 ready=true flushing=false bytes=372
t=2977381 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=89 ready=true has_socket=true bytes=372
t=2977392 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=90 has_socket=true ready=true bytes=372
t=2977404 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=91 has_socket=true bytes=372 ready=true
t=2977415 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=92 has_socket=true bytes=372 ready=true
t=2977427 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=93 bytes=372
t=2977440 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=94
t=2977450 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=95 bytes=372
t=2977462 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=96 has_socket=true ready=true flushing=false
t=2977474 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=97 bytes=372
t=2977485 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 seq=98 has_socket=true
t=2977498 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=99 has_socket=true bytes=372 ready=true
t=2977508 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=100 bytes=372
t=2977519 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=101 bytes=372 ready=true
t=2977531 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=102
t=2977543 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=103 has_socket=true ready=true flushing=false
t=2977556 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=104 ready=true flushing=false bytes=372 has_socket=true
t=2977566 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=105 ready=true has_socket=true flushing=false bytes=372
t=2977578 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=106 bytes=372
t=2977589 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=107 ready=true has_socket=true
t=2977600 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=108 has_socket=true bytes=372 ready=true
t=2977612 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=109 ready=true has_socket=true bytes=372
t=2977624 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 seq=110 has_socket=true
NFO cat=stream evt=pre_send bytes=372 seq=129 has_socket=true ready=true flushing=false
t=2977856 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=130 ready=true flushing=false bytes=372
🛑 [TEN-VAD] Speech end detected
t=2977868 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=131 has_socket=true ready=true flushing=false
t=2977881 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=132 ready=true flushing=false bytes=372 has_socket=true
t=2977891 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=133 bytes=372
t=2977902 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=134 bytes=372 flushing=false ready=true
t=2977916 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=135 bytes=372
t=2977926 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=136 ready=true flushing=false bytes=372 has_socket=true
t=2977939 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=137 has_socket=true ready=true bytes=372 flushing=false
t=2977949 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=138 bytes=372
t=2977961 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=139 bytes=372
t=2977974 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=140
t=2977984 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 seq=141 has_socket=true
t=2977995 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=142 has_socket=true bytes=372 ready=true
t=2978007 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=143 has_socket=true ready=true flushing=false
t=2978019 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=144 ready=true bytes=372
t=2978031 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=145 ready=true flushing=false bytes=372
t=2978042 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=146 bytes=372
t=2978053 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=147 bytes=372
t=2978061 sess=9Hn lvl=INFO cat=stream evt=first_partial ms=1737
t=2978061 sess=9Hn lvl=INFO cat=stream evt=ttft_hotkey ms=1737
t=2978061 sess=9Hn lvl=INFO cat=stream evt=ttft ms=1237
🧪 [PROMO] first_token ms=1864 tokens_in_msg=1
t=2978065 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=148 has_socket=true bytes=372 ready=true
t=2978122 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=149 bytes=372 has_socket=true flushing=false
t=2978122 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=150 bytes=372 has_socket=true flushing=false
t=2978122 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=151 bytes=372 has_socket=true flushing=false
t=2978122 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=152 bytes=372 has_socket=true flushing=false
t=2978123 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=153 bytes=372 has_socket=true flushing=false
t=2978134 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=154 flushing=false
t=2978146 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=155 bytes=372 ready=true flushing=false
t=2978158 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=156 bytes=372 has_socket=true flushing=false
t=2978169 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=157 bytes=372
t=2978181 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=158 flushing=false
t=2978192 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=159 bytes=372 has_socket=true flushing=false
t=2978204 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=160 bytes=372 has_socket=true flushing=false
t=2978216 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=161 ready=true bytes=372
t=2978227 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=162 has_socket=true bytes=372 ready=true
t=2978239 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true seq=163 has_socket=true
t=2978251 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true seq=164 has_socket=true
t=2978262 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 has_socket=true seq=165
t=2978274 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=166 flushing=false ready=true has_socket=true bytes=372
t=2978286 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 has_socket=true seq=167
t=2978298 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 ready=true seq=168
t=2978309 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=169 has_socket=true ready=true bytes=372 flushing=false
t=2978321 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=170 ready=true bytes=372
t=2978332 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=171 ready=true
t=2978397 sess=9Hn lvl=INFO cat=audio evt=level avg_db=-48 peak_db=-48
t=2978397 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=172 ready=true has_socket=true
t=2978397 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=173 ready=true has_socket=true
t=2978397 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=174 ready=true has_socket=true
t=2978397 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=175 ready=true has_socket=true
t=2978397 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=176 ready=true has_socket=true
t=2978401 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=177 ready=true has_socket=true
t=2978414 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=178 bytes=372 has_socket=true flushing=false
t=2978425 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false seq=179 has_socket=true
t=2978469 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true has_socket=true bytes=372 seq=180
t=2978469 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true has_socket=true bytes=372 seq=181
t=2978469 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true has_socket=true bytes=372 seq=182
t=2978471 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=183
t=2978483 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=184
t=2978494 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=185 ready=true flushing=false has_socket=true
t=2978506 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=186 ready=true has_socket=true flushing=false
t=2978518 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=187 bytes=372
t=2978529 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=188 has_socket=true ready=true bytes=372
t=2978541 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=189 ready=true has_socket=true flushing=false
t=2978552 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=190 ready=true flushing=false has_socket=true
t=2978564 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=191
t=2978576 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true has_socket=true seq=192
t=2978587 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=193 has_socket=true flushing=false
t=2978599 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=194 ready=true bytes=372
t=2978611 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 ready=true seq=195
t=2978623 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=196 bytes=372 flushing=false
t=2978634 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=197 ready=true flushing=false bytes=372
t=2978646 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=198 bytes=372 flushing=false
t=2978658 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=199 bytes=372
t=2978669 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=200 has_socket=true bytes=372 ready=true
t=2978681 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=201 ready=true bytes=372
t=2978692 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=202 bytes=372 flushing=false
t=2978704 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=203 flushing=false ready=true has_socket=true bytes=372
t=2978716 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=204 bytes=372 flushing=false
t=2978727 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=205 has_socket=true ready=true flushing=false
t=2978739 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=206 bytes=372 flushing=false
t=2978750 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=207 bytes=372 flushing=false
t=2978762 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=208 bytes=372
t=2978773 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=209
t=2978785 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=210 ready=true flushing=false bytes=372
t=2978797 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=211 bytes=372
t=2978808 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=212 ready=true bytes=372
t=2978820 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=213 bytes=372 flushing=false
t=2978832 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=214 ready=true flushing=false bytes=372
t=2978890 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=215 has_socket=true ready=true flushing=false bytes=372
t=2978890 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=216 has_socket=true ready=true flushing=false bytes=372
t=2978890 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=217 has_socket=true ready=true flushing=false bytes=372
t=2978890 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=218 has_socket=true ready=true flushing=false bytes=372
t=2978890 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=219 has_socket=true ready=true flushing=false bytes=372
t=2978933 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=220 flushing=false has_socket=true
t=2978933 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=221 flushing=false has_socket=true
t=2978933 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=222 flushing=false has_socket=true
t=2978935 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=223 has_socket=true bytes=372 ready=true flushing=false
t=2978947 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=224
t=2978959 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 seq=225 flushing=false
t=2978970 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 seq=226 ready=true
t=2979009 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=227 has_socket=true ready=true flushing=false bytes=372
t=2979009 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=228 has_socket=true ready=true flushing=false bytes=372
t=2979009 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=229 has_socket=true ready=true flushing=false bytes=372
t=2979017 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=230 bytes=372 ready=true
t=2979028 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=231 ready=true flushing=false has_socket=true
t=2979040 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=232
t=2979052 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=233
t=2979063 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=234
t=2979075 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=235
t=2979087 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=236 flushing=false
t=2979098 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=237
t=2979110 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=238 has_socket=true ready=true
throwing -10877
throwing -10877
t=2979180 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 ready=true seq=239
t=2979180 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 ready=true seq=240
t=2979180 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 ready=true seq=241
t=2979180 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 ready=true seq=242
t=2979180 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 ready=true seq=243
t=2979181 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 ready=true seq=244
t=2979191 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=245 has_socket=true ready=true flushing=false bytes=372
t=2979231 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=246 ready=true has_socket=true flushing=false bytes=372
t=2979231 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=247 ready=true has_socket=true flushing=false bytes=372
t=2979231 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=248 ready=true has_socket=true flushing=false bytes=372
t=2979238 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=249
t=2979249 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=250 flushing=false has_socket=true
t=2979261 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=251 has_socket=true bytes=372 ready=true
t=2979272 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=252 has_socket=true flushing=false
t=2979284 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=253
t=2979295 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=254 has_socket=true flushing=false
t=2979329 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 has_socket=true seq=255
t=2979329 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 has_socket=true seq=256
t=2979330 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=257
t=2979342 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=258 flushing=false
t=2979354 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=259 bytes=372 ready=true flushing=false
t=2979365 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=260 flushing=false has_socket=true
t=2979377 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=261 flushing=false
t=2979405 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=262
t=2979405 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=263
t=2979412 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=264
t=2979423 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=265 flushing=false
t=2979435 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=266
t=2979446 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=267
t=2979458 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=268 flushing=false has_socket=true
🛑 [TEN-VAD] Speech end detected
t=2979487 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true has_socket=true seq=269
t=2979487 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true has_socket=true seq=270
t=2979493 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=271 bytes=372 has_socket=true
t=2979504 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=272 bytes=372 has_socket=true
t=2979516 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false has_socket=true seq=273
t=2979528 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=274 flushing=false has_socket=true
t=2979539 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=275 flushing=false bytes=372 has_socket=true
t=2979551 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=276 has_socket=true flushing=false
t=2979562 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=277 ready=true has_socket=true
t=2979574 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=278 bytes=372 has_socket=true
t=2979586 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 has_socket=true seq=279
t=2979597 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=280 has_socket=true flushing=false
t=2979609 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true has_socket=true seq=281
t=2979621 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=282 flushing=false has_socket=true
t=2979632 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=283 has_socket=true flushing=false
t=2979644 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true has_socket=true seq=284
t=2979655 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=285 flushing=false has_socket=true
t=2979667 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=286 bytes=372 has_socket=true
t=2979679 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=287 ready=true flushing=false bytes=372 has_socket=true
t=2979691 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=288 has_socket=true ready=true flushing=false
t=2979702 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=289 has_socket=true bytes=372 ready=true
t=2979714 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=290 ready=true has_socket=true
t=2979725 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=291 bytes=372
t=2979737 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=292 ready=true has_socket=true
t=2979802 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=293 ready=true has_socket=true flushing=false
t=2979802 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=294 ready=true has_socket=true flushing=false
t=2979802 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=295 ready=true has_socket=true flushing=false
t=2979802 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=296 ready=true has_socket=true flushing=false
t=2979802 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=297 ready=true has_socket=true flushing=false
t=2979806 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=298 ready=true has_socket=true flushing=false
t=2979818 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=299 has_socket=true ready=true flushing=false bytes=372
t=2979830 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=300 flushing=false
🛑 [TEN-VAD] Speech end detected
t=2979841 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=301 ready=true has_socket=true flushing=false
t=2979853 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=302
t=2979864 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=303 flushing=false
t=2979877 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=304
t=2979888 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false ready=true seq=305 has_socket=true
t=2979899 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=306 bytes=372 has_socket=true ready=true
t=2979911 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 has_socket=true seq=307
t=2979923 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=308 bytes=372
t=2979934 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=309 flushing=false ready=true has_socket=true bytes=372
t=2979946 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 ready=true seq=310
t=2979958 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=311 flushing=false ready=true has_socket=true
t=2979970 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=312 flushing=false ready=true has_socket=true bytes=372
t=2979981 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=313 bytes=372
t=2979993 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=314 flushing=false ready=true has_socket=true
t=2980004 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false ready=true seq=315 has_socket=true
t=2980016 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=316 bytes=372
t=2980027 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=317 flushing=false ready=true has_socket=true bytes=372
t=2980039 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=318 bytes=372 flushing=false
t=2980051 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=319 bytes=372
t=2980062 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 ready=true seq=320
t=2980074 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=321 bytes=372
t=2980085 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=322 bytes=372 flushing=false
t=2980097 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=323 flushing=false ready=true has_socket=true bytes=372
t=2980108 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false seq=324 has_socket=true
t=2980120 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=325 flushing=false ready=true has_socket=true bytes=372
t=2980132 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=326
t=2980144 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 seq=327 ready=true flushing=false
t=2980207 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=328 has_socket=true ready=true flushing=false bytes=372
t=2980207 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=329 has_socket=true ready=true flushing=false bytes=372
t=2980207 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=330 has_socket=true ready=true flushing=false bytes=372
t=2980207 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=331 has_socket=true ready=true flushing=false bytes=372
t=2980208 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=332 has_socket=true ready=true flushing=false bytes=372
t=2980213 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=333 ready=true
t=2980224 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=334 has_socket=true ready=true flushing=false bytes=372
t=2980236 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=335 ready=true flushing=false
t=2980247 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=336 ready=true flushing=false
t=2980294 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=337 ready=true flushing=false has_socket=true
t=2980294 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=338 ready=true flushing=false has_socket=true
t=2980294 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=339 has_socket=true ready=true bytes=372
t=2980294 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=340 ready=true flushing=false has_socket=true
t=2980305 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=341 flushing=false
t=2980317 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 seq=342 flushing=false
t=2980329 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=343 has_socket=true flushing=false
t=2980340 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=344 ready=true
t=2980352 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 seq=345 flushing=false
t=2980363 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=346 flushing=false has_socket=true
t=2980375 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=347 ready=true has_socket=true flushing=false
t=2980387 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=348 has_socket=true flushing=false
t=2980398 sess=9Hn lvl=INFO cat=audio evt=level avg_db=-47 peak_db=-47
t=2980399 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=349 has_socket=true flushing=false
t=2980410 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=350 has_socket=true flushing=false
t=2980422 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=351 has_socket=true flushing=false
t=2980434 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=352 ready=true flushing=false bytes=372
t=2980446 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=353 ready=true flushing=false bytes=372
t=2980457 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=354 ready=true flushing=false bytes=372
t=2980469 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=355 ready=true bytes=372
t=2980481 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=356 ready=true bytes=372
t=2980492 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=357
t=2980506 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=358 ready=true has_socket=true flushing=false
t=2980515 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=359 ready=true has_socket=true flushing=false
t=2980526 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=360 has_socket=true bytes=372 ready=true
t=2980584 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 seq=361 ready=true
t=2980584 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 seq=362 ready=true
t=2980584 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 seq=363 ready=true
t=2980584 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 seq=364 ready=true
t=2980584 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 seq=365 ready=true
t=2980596 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true seq=366 bytes=372
t=2980608 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=367 flushing=false
t=2980619 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 seq=368 ready=true
t=2980631 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false seq=369 ready=true
t=2980642 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 seq=370 ready=true
t=2980654 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=371
t=2980666 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=372 bytes=372
t=2980677 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=373 ready=true has_socket=true
t=2980689 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=374 bytes=372
t=2980701 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=375 bytes=372 ready=true has_socket=true flushing=false
t=2980712 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=376 bytes=372 ready=true has_socket=true flushing=false
t=2980724 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=377
t=2980735 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=378 has_socket=true ready=true flushing=false
t=2980747 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=379
t=2980758 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=380
t=2980770 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=381 bytes=372
t=2980782 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=382 flushing=false ready=true has_socket=true bytes=372
t=2980794 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=383
t=2980807 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=384
t=2980817 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=385
t=2980829 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true bytes=372 seq=386 ready=true
t=2980840 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=387 ready=true bytes=372 has_socket=true flushing=false
t=2980852 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=388 ready=true has_socket=true
t=2980864 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=389
t=2980878 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=390 ready=true bytes=372 has_socket=true flushing=false
t=2980942 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true seq=391 flushing=false bytes=372
t=2980942 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true seq=392 flushing=false bytes=372
t=2980942 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true seq=393 flushing=false bytes=372
t=2980942 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true seq=394 flushing=false bytes=372
t=2980942 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true seq=395 flushing=false bytes=372
t=2980944 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=396
t=2980956 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=397
t=2980967 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=398 ready=true bytes=372
t=2980979 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true has_socket=true flushing=false seq=399
t=2980991 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=400 flushing=false bytes=372 ready=true
t=2981002 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=401 has_socket=true flushing=false
t=2981014 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=402 has_socket=true flushing=false
t=2981026 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false seq=403 ready=true
t=2981038 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 seq=404 has_socket=true
t=2981049 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=405 bytes=372
t=2981061 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=406 bytes=372
t=2981073 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=407 has_socket=true flushing=false bytes=372
t=2981084 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=408 flushing=false ready=true bytes=372 has_socket=true
t=2981095 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=409 bytes=372
t=2981107 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=410 bytes=372
t=2981169 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=411 flushing=false has_socket=true ready=true
t=2981169 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=412 flushing=false has_socket=true ready=true
t=2981169 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=413 flushing=false has_socket=true ready=true
t=2981169 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=414 flushing=false has_socket=true ready=true
t=2981169 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=415 flushing=false has_socket=true ready=true
t=2981176 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=416
t=2981188 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=417
t=2981200 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=418
t=2981211 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 seq=419 ready=true
t=2981223 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=420
t=2981234 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=421
t=2981246 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=422
t=2981258 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=423 ready=true has_socket=true flushing=false
t=2981270 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 ready=true seq=424
t=2981281 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=425 flushing=false has_socket=true
t=2981293 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=426 ready=true has_socket=true flushing=false
t=2981305 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=427 ready=true has_socket=true flushing=false bytes=372
t=2981316 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=428 ready=true flushing=false bytes=372
t=2981328 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=429 flushing=false has_socket=true
t=2981339 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=430 flushing=false has_socket=true
t=2981351 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=431 ready=true has_socket=true
t=2981362 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=432 has_socket=true ready=true flushing=false bytes=372
t=2981374 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=433 flushing=false has_socket=true
t=2981386 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=434 has_socket=true ready=true flushing=false bytes=372
t=2981397 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=435 ready=true has_socket=true
🤖 [FLY.IO-NER] Server-reported provider: gemini
📥 [NER-STORE] Stored NER entities: 5117 chars - Here's a breakdown of the visible content and what we can infer:

**Active Window:**

*   **Title:**...
✅ [FLY.IO] NER refresh completed successfully
t=2981409 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 ready=true seq=436
t=2981420 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=437 bytes=372
t=2981432 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=438 has_socket=true
t=2981444 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=439 flushing=false has_socket=true
t=2981455 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=440 ready=true has_socket=true
t=2981467 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=441 has_socket=true
t=2981479 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 ready=true seq=442
t=2981490 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=443
t=2981502 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=444 ready=true has_socket=true flushing=false
t=2981513 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=445 bytes=372
t=2981573 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=446 has_socket=true ready=true flushing=false
t=2981573 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=447 has_socket=true ready=true flushing=false
t=2981573 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=448 has_socket=true ready=true flushing=false
t=2981573 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=449 has_socket=true ready=true flushing=false
t=2981573 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=450 has_socket=true ready=true flushing=false
t=2981582 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=451
t=2981620 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=452 bytes=372 ready=true
t=2981620 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=453 bytes=372 ready=true
t=2981620 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=454 bytes=372 ready=true
t=2981629 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=455 ready=true
t=2981641 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=456 bytes=372 has_socket=true flushing=false
t=2981652 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true ready=true bytes=372 seq=457
t=2981664 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=458 bytes=372 has_socket=true flushing=false
t=2981676 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=459 flushing=false bytes=372 ready=true
t=2981687 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true ready=true bytes=372 seq=460
t=2981699 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=461 flushing=false bytes=372 ready=true
t=2981711 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=462 flushing=false bytes=372 ready=true
t=2981722 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=463 flushing=false bytes=372 ready=true
t=2981734 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=464 ready=true
t=2981745 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=465 flushing=false bytes=372 ready=true
t=2981757 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=466 ready=true flushing=false bytes=372
t=2981769 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=467 bytes=372
t=2981781 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=468 ready=true flushing=false bytes=372
t=2981793 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 seq=469 has_socket=true
t=2981804 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 seq=470 has_socket=true
t=2981870 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=471 flushing=false
t=2981870 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=472 flushing=false
t=2981870 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=473 flushing=false
t=2981870 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=474 flushing=false
t=2981870 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=475 flushing=false
t=2981873 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=476 flushing=false
t=2981884 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=477 bytes=372 has_socket=true flushing=false
t=2981896 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=478 ready=true bytes=372 flushing=false has_socket=true
t=2981908 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=479 ready=true bytes=372 flushing=false has_socket=true
t=2981919 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=480 has_socket=true ready=true flushing=false bytes=372
t=2981961 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=481 bytes=372
t=2981961 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=482 bytes=372
t=2981961 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=483 bytes=372
t=2981966 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=484
t=2981977 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true has_socket=true bytes=372 seq=485
t=2981989 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=486 bytes=372 has_socket=true flushing=false
t=2982001 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 seq=487 ready=true
t=2982012 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 seq=488 ready=true
t=2982024 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 seq=489 ready=true
t=2982029 sess=9Hn lvl=INFO cat=stream evt=first_final ms=5706
t=2982029 sess=9Hn lvl=INFO cat=transcript evt=raw_final text="Mission construct is like"
t=2982069 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=490 ready=true has_socket=true
t=2982069 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=491 ready=true has_socket=true
t=2982069 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=492 ready=true has_socket=true
🛑 [TEN-VAD] Speech end detected
t=2982070 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 seq=493 ready=true
t=2982082 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=494 flushing=false
🛑 [TEN-VAD] Speech end detected
t=2982094 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=495
t=2982105 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=496
t=2982117 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=497 bytes=372 flushing=false has_socket=true ready=true
t=2982128 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=498 flushing=false ready=true bytes=372 has_socket=true
t=2982140 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=499 bytes=372 flushing=false has_socket=true ready=true
t=2982151 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=500 bytes=372 flushing=false has_socket=true ready=true
t=2982163 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=501 has_socket=true ready=true flushing=false bytes=372
t=2982176 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=502 flushing=false has_socket=true
t=2982186 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=503 has_socket=true ready=true flushing=false bytes=372
t=2982198 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=504 has_socket=true ready=true bytes=372 flushing=false
t=2982210 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=505 has_socket=true ready=true flushing=false bytes=372
t=2982222 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=506 bytes=372
t=2982234 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 flushing=false seq=507
t=2982245 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=508 flushing=false ready=true has_socket=true bytes=372
t=2982257 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=509 flushing=false ready=true has_socket=true bytes=372
t=2982268 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=510 ready=true bytes=372
t=2982281 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 ready=true seq=511
t=2982350 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=512 bytes=372 has_socket=true flushing=false
t=2982350 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=513 bytes=372 has_socket=true flushing=false
t=2982350 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=514 bytes=372 has_socket=true flushing=false
t=2982350 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=515 bytes=372 has_socket=true flushing=false
t=2982350 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=516 bytes=372 has_socket=true flushing=false
t=2982350 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=517 bytes=372 has_socket=true flushing=false
t=2982361 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=518 bytes=372 has_socket=true flushing=false
t=2982372 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 seq=519 has_socket=true
t=2982384 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 seq=520 has_socket=true
t=2982396 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=521 flushing=false
t=2982407 sess=9Hn lvl=INFO cat=audio evt=level peak_db=-22 avg_db=-22
t=2982407 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=522 flushing=false
t=2982418 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=523 bytes=372 has_socket=true flushing=false
t=2982430 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=524 flushing=false
t=2982478 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=525
t=2982478 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=526
t=2982478 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=527
t=2982478 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=528
t=2982488 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true ready=true seq=529
t=2982500 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true ready=true seq=530
t=2982511 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true ready=true seq=531
t=2982523 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=532 has_socket=true flushing=false
t=2982535 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true ready=true seq=533
t=2982546 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=534 flushing=false ready=true
t=2982585 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=535 ready=true
t=2982585 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=536 ready=true
t=2982585 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=537 ready=true
t=2982593 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=538 ready=true bytes=372
t=2982604 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=539 flushing=false bytes=372 has_socket=true
t=2982616 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=540
t=2982628 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=541 bytes=372
t=2982639 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 ready=true flushing=false seq=542
t=2982651 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=543
t=2982662 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=544 bytes=372 ready=true
t=2982674 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=545 ready=true bytes=372
t=2982685 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=546 ready=true bytes=372
t=2982697 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=547 ready=true bytes=372
t=2982709 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=548 ready=true bytes=372
t=2982721 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=549 bytes=372 ready=true
t=2982732 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=550 bytes=372
t=2982744 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=551 ready=true bytes=372
t=2982755 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=552 ready=true flushing=false bytes=372
t=2982767 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=553 ready=true flushing=false bytes=372
t=2982779 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=554 bytes=372
t=2982790 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=555 bytes=372
t=2982802 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=556 ready=true bytes=372
t=2982858 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=557 flushing=false has_socket=true bytes=372
t=2982858 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=558 flushing=false has_socket=true bytes=372
t=2982858 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=559 flushing=false has_socket=true bytes=372
t=2982858 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=560 ready=true has_socket=true
t=2982860 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=561 ready=true has_socket=true
t=2982871 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=562 has_socket=true ready=true flushing=false bytes=372
t=2982883 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=563
t=2982895 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=564
t=2982906 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=565 bytes=372
t=2982918 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false ready=true seq=566
t=2982929 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=567 flushing=false bytes=372 has_socket=true
t=2982941 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=568 bytes=372
t=2982953 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=569 has_socket=true ready=true flushing=false
t=2982965 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=570 bytes=372
t=2982977 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=571 bytes=372 ready=true has_socket=true
t=2982988 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=572 ready=true bytes=372
t=2982999 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=573 has_socket=true ready=true flushing=false
t=2983011 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=574 ready=true bytes=372
t=2983023 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=575 has_socket=true ready=true flushing=false bytes=372
t=2983078 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=576 ready=true has_socket=true bytes=372 flushing=false
t=2983078 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=577 ready=true has_socket=true bytes=372 flushing=false
t=2983078 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=578 ready=true has_socket=true bytes=372 flushing=false
t=2983078 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=579 ready=true has_socket=true bytes=372 flushing=false
t=2983080 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=580 has_socket=true bytes=372
t=2983092 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true ready=true bytes=372 seq=581
t=2983103 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=582 flushing=false has_socket=true
t=2983115 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=583
t=2983127 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=584
t=2983139 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=585 flushing=false has_socket=true
t=2983150 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=586 ready=true
t=2983162 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=587 ready=true has_socket=true
t=2983174 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=588 ready=true flushing=false bytes=372
t=2983185 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 seq=589 flushing=false ready=true
t=2983197 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 ready=true seq=590
t=2983209 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=591
t=2983220 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=592 bytes=372
t=2983231 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=593 ready=true bytes=372
🛑 [TEN-VAD] Speech end detected
t=2983243 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true ready=true seq=594 bytes=372
t=2983309 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 seq=595 ready=true
t=2983309 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 seq=596 ready=true
t=2983309 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 seq=597 ready=true
t=2983309 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 seq=598 ready=true
t=2983309 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 seq=599 ready=true
t=2983313 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=600 bytes=372 has_socket=true flushing=false
t=2983324 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true bytes=372 ready=true seq=601
🛑 [TEN-VAD] Speech end detected
t=2983336 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false seq=602 bytes=372
t=2983347 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true has_socket=true bytes=372 seq=603
t=2983359 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=604
🛑 Stopping recording
🛑 Stopping Clio streaming transcription
🏥 [AUDIO HEALTH] Health monitoring timer stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
🛑 Stopping unified audio capture
t=2983424 sess=9Hn lvl=INFO cat=audio evt=record_stop
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key plugInPackage
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key CMIOType
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key numberOfDevices
t=2983434 sess=9Hn lvl=INFO cat=audio evt=avcapture_stop
✅ Unified audio capture stopped
t=2983434 sess=9Hn lvl=INFO cat=transcript evt=raw_final text=" early version chatbot"
t=2983435 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=605 flushing=false
t=2983435 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=606 flushing=false
t=2983435 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=607 flushing=false
🗣️ [TEN-VAD] Speech start detected
t=2983464 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=608 ready=true
t=2983464 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=609 flushing=false bytes=372 has_socket=true ready=true
🛑 [TEN-VAD] Speech end detected
📤 Sent end-of-stream signal
📤 Sent manual finalize command
🕐 Using finalization timeout: 400ms (connection took 7261ms)
⚡ [OPTIMISTIC] Skipping wait-for-<fin> path=heuristic tail=100ms pending=0 ms_since_last=117
🔬 [OPTIMISTIC] tokens_after_skip=0 window_ms=500
⏹️ Keepalive timer stopped
⚡ Audio capture already stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
📉 Released connection for account account-bundle (connections: 0)
💾 [COLD-START] Updated successful streaming timestamp
💾 [COLD-START] Updated successful streaming timestamp
✅ Streaming stopped. Final transcript (97 chars, 7.3s, with audio file): "Mission construct is like early version chatbot that used emails to make warming shows. You blast"
t=2983627 sess=9Hn lvl=INFO cat=transcript evt=final text="Mission construct is like early version chatbot that used emails to make warming shows. You blast"
t=2983627 sess=9Hn lvl=INFO cat=transcript evt=session_end divider="────────── session end ──────────"
🌡️ [WARM] warm_socket=yes
⏹️ Keepalive timer stopped
⚠️ WebSocket did close with code 1001 (sid=sock_-5131603304247269425, attemptId=9)
t=2983628 sess=9Hn lvl=WARN cat=stream evt=state state=closed code=1001
🔌 [WS] Disconnected (socketId=sock_-5131603304247269425@attempt_9)
✅ Streaming transcription completed successfully, length: 47 characters
⏱️ [TIMING] Subscription tracking: 0.3ms
⏱️ [TIMING] ASR word tracking: 0.0ms
🧠 Performing intelligent end-context detection for streaming
⏱️ [CONTEXT DETAIL] Cache check: 0.0ms
⚡ [SMART-OPTIMIZATION] Using smart cached screen context (1554 chars) - skipping new capture
⏱️ [STREAMING CONTEXT TIMING] Screen capture + context detection: 0.0ms
🔊 [SoundManager] Attempting to play stop sound
🔊 [SoundManager] NSSound stop sound result: true
🧹 Connection cleanup completed (session resources released)
📝 [GRACE] Recording session ended
📱 Dismissing recorder
🌐 [CONNECT] New single-flight request from warmHold
✅ Streaming transcription processing completed
🌐 [CONNECT] Attempt #10 (loop 1/2) starting…
t=2983752 sess=9Hn lvl=INFO cat=transcript evt=insert_attempt target="Google Chrome" chars=48 text="Mission construct is like early version chatbot "
🔍 [PASTE DEBUG] AXIsProcessTrusted() returned true, proceeding
🔍 [PASTE DEBUG] UseDirectTextInsertion setting: false
🔍 [PASTE DEBUG] Direct insertion disabled, using clipboard paste
⌨️ Using CGEvent-based Command+V
t=2983753 sess=9Hn lvl=INFO cat=transcript evt=insert_result ok=true
📊 [POST-RELEASE E2E] 358ms (finalize=190ms | paste=0ms) | warm_socket=no
t=2983789 sess=9Hn lvl=INFO cat=stream evt=temp_key_fetch_start
⚡ [CACHE-HIT] Retrieved temp key in 33.7ms
t=2983823 sess=9Hn lvl=INFO cat=stream evt=temp_key_fetch source=cached expires_in_s=-1 latency_ms=33
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🌐 [WS CONNECT] Using URL: wss://stt-rt.soniox.com/transcribe-websocket
🔗 [WS] Bound socket id=sock_-66227754045365699@attempt_10
t=2983825 sess=9Hn lvl=INFO cat=stream evt=ws_bind path=/transcribe-websocket target_host=stt-rt.soniox.com attempt=10 socket=sock_-66227754045365699@attempt_10 via_proxy=false target_ip=resolving...
🔑 Successfully connected to Soniox using temp key (36ms key latency)
t=2983826 sess=9Hn lvl=INFO cat=stream evt=ws_bind_resolved target_host=stt-rt.soniox.com socket=sock_-66227754045365699@attempt_10 via_proxy=false target_ip=129.146.176.251 path=/transcribe-websocket attempt=10
t=2985007 sess=9Hn lvl=INFO cat=stream evt=ws_handshake_metrics attempt=10 proxy=false protocol=http/1.1 total_ms=1182 socket=sock_-66227754045365699@attempt_10 connect_ms=896 tls_ms=889 reused=false dns_ms=0
🔌 WebSocket did open (sid=sock_-66227754045365699, attemptId=10)
🌐 [CONNECT] Attempt #10 succeeded
📤 [START] Sent start/config on standby socket (eager mode)
t=2985008 sess=9Hn lvl=INFO cat=stream evt=start_config socket=sock_-66227754045365699@attempt_10 attempt=10 ctx=standby_eager summary=["langs": 2, "valid": true, "audio_format": "pcm_s16le", "ch": 1, "model": "stt-rt-preview-v2", "ctx_len": 36, "json_hash": "647d4d9a98bd6de5", "sr": 16000]
🧾 [START-CONFIG] ctx=standby_eager sum=["langs": 2, "valid": true, "audio_format": "pcm_s16le", "ch": 1, "model": "stt-rt-preview-v2", "ctx_len": 36, "json_hash": "647d4d9a98bd6de5", "sr": 16000]
📤 Sending text frame seq=5489
🧊 [STANDBY] Connected standby socket — keepalive every 10.0s, TTL=60s
🔌 [READY] attemptId=10 socketId=sock_-66227754045365699@attempt_10 start_text_sent=true
🧊 [STANDBY] WebSocket ready in 1260ms (handshake)
👂 [LISTENER] Standby listener task for socketId=sock_-66227754045365699@attempt_10 attemptId=10
🧭 [APP] applicationShouldHandleReopen called - hasVisibleWindows: true
🧭 [APP] ActivationPolicy=.regular (IsMenuBarOnly=false)
🧭 [APP] applicationDidBecomeActive
🧭 [APP] ActivationPolicy=.regular (IsMenuBarOnly=false)
🪟 [DOCK] Found existing window, activating it
🔄 [SYNC_STATE] syncTrialState called - currentTier: pro, isInTrial: false
🔄 [SYNC_STATE] Final state after syncTrialState - currentTier: pro, isInTrial: false
ViewBridge to RemoteViewService Terminated: Error Domain=com.apple.ViewBridge Code=18 "(null)" UserInfo={com.apple.ViewBridge.error.hint=this process disconnected remote view controller -- benign unless unexpected, com.apple.ViewBridge.error.description=NSViewBridgeErrorCanceled}
deferral block timed out after 500ms
deferral block timed out after 500ms
💤 [STANDBY] keepalive_tick
t=2995009 sess=9Hn lvl=INFO cat=stream evt=standby_keepalive_tick
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
📊 [SESSION] Starting recording session #9
🧪 [A/B] warm_socket=yes
🧊➡️🔥 [STANDBY->ACTIVE] Consuming standby socket for new utterance
⏭️ [STANDBY->ACTIVE] START already sent on standby (eager) — skipping re-send
🔄 [CACHE] Context changed - invalidating cache
🔄 [CACHE]   Old: com.google.Chrome|(17) A Yale Student Raised $3.1M in 2 Weeks for an AI Social App | Series, Nathaneo Johnson - YouTube
🔄 [CACHE]   New: com.apple.dt.Xcode|Clio — SonioxStreamingService.swift
🔄 [CACHE]   BundleID Match: false
🔄 [CACHE]   Title Match: false
🔄 [CACHE]   Content Hash: Old=0086db99... New=0086db99...
✅ [STANDBY->ACTIVE] Probe keepalive OK — proceeding to resume queue
⏹️ Keepalive timer stopped
🔄 Keepalive timer started (interval: 15.000000s)
🧪 [PROMO] snapshot attempt=10 socket=sock_-66227754045365699@attempt_10 start_sent=true ws_ready=true standby=false purpose=active cap_sr=16000 cap_ch=1 prebuf=0 last_fp=m=stt-rt-preview-v2|sr=16000|ch=1|h=en,zh|ctx=889740762234866296
t=2996341 sess=9Hn lvl=INFO cat=stream evt=temp_key_fetch_start
🎬 Starting screen capture with verified permissions
⚡ [CACHE-HIT] Retrieved temp key in 0.5ms
t=2996342 sess=9Hn lvl=INFO cat=stream evt=temp_key_fetch latency_ms=0 source=cached expires_in_s=-1
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🧪 [PROMO] config_fp current=m=stt-rt-preview-v2|sr=16000|ch=1|h=en,zh|ctx=889740762234866296 last=m=stt-rt-preview-v2|sr=16000|ch=1|h=en,zh|ctx=889740762234866296
🎤 Registering audio tap for Soniox
t=2996343 sess=9Hn lvl=INFO cat=audio evt=record_start service=Soniox
🔍 Performing audio system pre-flight checks
🎯 Clio — SonioxStreamingService.swift
🌐 [LANG DEBUG] Multi-language setting exists: true, Single language: en
🌐 [LANG DEBUG] Using multi-language selection (prioritized): zh, en
🌐 Using selected languages for OCR: zh-Hans, en-US
throwing -10877
throwing -10877
✅ Pre-flight checks passed
t=2996429 sess=9Hn lvl=INFO cat=audio evt=tap_install ok=true service=Soniox backend=avcapture
t=2996429 sess=9Hn lvl=INFO cat=audio evt=record_start reason=start_capture
t=2996429 sess=9Hn lvl=INFO cat=audio evt=device_pin_start desired_name="MacBook Pro Microphone" desired_uid_hash=4285059772673450742 prev_name="MacBook Pro Microphone" prev_uid_hash=4285059772673450742 prev_id=181 desired_id=181
t=2996429 sess=9Hn lvl=INFO cat=audio evt=capture_backend_selected backend=avcapture
✅ Unified audio capture started
✅ Selected account account-bundle (connections: 1/10)
🧠 [TEN-VAD] Initialized (threshold=0.5, hop=256)
🚀 Starting Clio streaming transcription
🏥 [AUDIO HEALTH] Health monitoring timer started
⏱️ [TIMING] mic_engaged @ 1756226032.469
⏱️ [TIMING] WebSocket connect task completed — will flush after READY
pass
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
t=2996518 sess=9Hn lvl=INFO cat=audio evt=avcapture_start ok=true
t=2996518 sess=9Hn lvl=INFO cat=stream evt=first_audio_buffer_captured ms=47
🧪 [PROMO] first_audio seq=0 bytes=372 approx_db=-60.0
t=2996519 sess=9Hn lvl=INFO cat=audio evt=level avg_db=-60 peak_db=-60
✅ [AUDIO HEALTH] First audio data received - tap is functional
t=2996519 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=0 bytes=372 ready=true flushing=false
t=2996519 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=1 bytes=372 ready=true flushing=false
t=2996519 sess=9Hn lvl=INFO cat=stream evt=first_audio_sent seq=1 ms=48
t=2996519 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=360 has_socket=true ready=true seq=2
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
t=2996523 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=360 seq=3
t=2996535 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 seq=4 has_socket=true
t=2996546 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true seq=5 bytes=372 has_socket=true
t=2996559 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=6 bytes=372 ready=true flushing=false
t=2996570 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false seq=7 has_socket=true
t=2996581 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 ready=true flushing=false seq=8
t=2996593 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=9 bytes=372 flushing=false has_socket=true
t=2996604 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=10 bytes=372 ready=true
t=2996616 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=11 bytes=372 ready=true has_socket=true
🌐 [ASR BREAKDOWN] Total: 433ms | Client↔Proxy: 165ms | Proxy↔Soniox: 268ms | Network: 268ms
🗑️ Evicted oldest temp key to maintain cache size limit
💾 Cached temp key for languages: ["zh", "en"]
🗓️ [TTL-SCHEDULE] Scheduling temp key refresh for key=global in 3000s (expiresAt=2025-08-26 17:33:52 +0000)
✅ [PREFETCH] Successfully prefetched temp key
🎤 [WARMUP] Pre-warming audio system...
✅ [PREWARM] Device enumeration completed
✅ [PREWARM] Audio system pre-warming completed successfully
✅ [WARMUP] Audio system pre-warmed successfully
t=2996631 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true seq=12 bytes=372
t=2996639 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true seq=13 bytes=372
t=2996651 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 seq=14 ready=true
t=2996663 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=15 has_socket=true ready=true flushing=false
t=2996674 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false seq=16 has_socket=true
t=2996686 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=17 has_socket=true flushing=false ready=true
t=2996697 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=18 bytes=372 has_socket=true ready=true
t=2996709 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=19 has_socket=true
🛑 [TEN-VAD] Speech end detected
t=2996721 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=20 has_socket=true ready=true flushing=false
t=2996732 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true seq=21 bytes=372
t=2996744 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=22
t=2996755 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=23 has_socket=true ready=true flushing=false
t=2996767 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=24 has_socket=true flushing=false ready=true
t=2996778 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=25 has_socket=true flushing=false bytes=372 ready=true
t=2996790 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=26 bytes=372 has_socket=true ready=true
🧪 [PROMO] audio_bytes bytes=10020
t=2996802 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false has_socket=true seq=27
t=2996813 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=28 has_socket=true ready=true flushing=false
t=2996825 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true ready=true bytes=372 seq=29
t=2996837 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false seq=30 has_socket=true
t=2996848 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=31 has_socket=true
t=2996860 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=32 ready=true flushing=false bytes=372 has_socket=true
t=2996871 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=33 ready=true flushing=false bytes=372 has_socket=true
t=2996883 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false seq=34 has_socket=true
t=2996895 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false seq=35 has_socket=true
t=2996906 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=36 bytes=372 has_socket=true ready=true
t=2996918 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=37 flushing=false has_socket=true bytes=372 ready=true
t=2996929 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=38 bytes=372 has_socket=true ready=true
t=2996941 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=39 flushing=false has_socket=true ready=true
t=2996953 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=40 ready=true
t=2996964 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=41 ready=true
t=2996976 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true has_socket=true seq=42
🌐 [PATH] Initial path baseline set — no action
t=2996988 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=43
t=2996999 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=44 flushing=false has_socket=true bytes=372 ready=true
t=2997011 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=45 has_socket=true ready=true flushing=false
t=2997022 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=46
t=2997034 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=47 ready=true
t=2997045 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false seq=48 has_socket=true
t=2997057 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=49 flushing=false has_socket=true bytes=372 ready=true
t=2997069 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false seq=50 has_socket=true
t=2997080 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=51 ready=true has_socket=true bytes=372 flushing=false
t=2997092 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=52
t=2997104 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=53 ready=true flushing=false has_socket=true bytes=372
t=2997115 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=54 bytes=372 ready=true
t=2997127 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=55 bytes=372 ready=true
t=2997138 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 seq=56 flushing=false ready=true
t=2997151 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=57 ready=true has_socket=true
t=2997162 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=58 flushing=false has_socket=true ready=true bytes=372
t=2997173 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=59 ready=true has_socket=true flushing=false bytes=372
t=2997185 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=60 ready=true has_socket=true flushing=false bytes=372
t=2997197 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=61
t=2997208 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 seq=62 flushing=false ready=true
t=2997220 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=63
t=2997231 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=64 has_socket=true flushing=false
t=2997243 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=65 has_socket=true flushing=false
t=2997254 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=66
t=2997266 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=67 ready=true has_socket=true flushing=false bytes=372
t=2997278 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false seq=68 has_socket=true
t=2997289 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=69 ready=true has_socket=true flushing=false bytes=372
t=2997301 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false seq=70 ready=true
t=2997312 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=71 ready=true flushing=false has_socket=true bytes=372
t=2997324 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 seq=72 ready=true flushing=false
t=2997336 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=73 has_socket=true flushing=false
t=2997347 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=74 ready=true has_socket=true bytes=372
t=2997359 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=75 ready=true has_socket=true flushing=false bytes=372
t=2997371 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 flushing=false seq=76
t=2997382 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=77 bytes=372 has_socket=true ready=true
t=2997394 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=78 has_socket=true ready=true
🔍 Found 99 text observations
✅ Text extraction successful: 2627 chars, 2627 non-whitespace, 259 words from 99 observations
✅ Captured text successfully
✅ [CAPTURE DEBUG] Screen capture successful: 2713 characters
💾 [SMART-CACHE] Cached new context: com.apple.dt.Xcode|Clio — SonioxStreamingService.swift (2713 chars)
🎯 [CALLBACK DEBUG] Executing callback with fresh content (2713 chars)
🔥 [PREWARM DEBUG] Pre-warming AI connection (target: Gemini), environment: flyio
🔥 [NER-TRIGGER] OCR completion callback triggered with fresh content
🎬 [NER-PREWARM] Using raw OCR text for NER: 2713 characters
🧠 [NER-DEFAULT] Using default NER prompt for general extraction
t=2997418 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=79 flushing=false has_socket=true ready=true bytes=372
t=2997418 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=80 flushing=false has_socket=true ready=true bytes=372
🧪 [PROMO] audio_bytes bytes=30108
t=2997429 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=81 flushing=false ready=true bytes=372
t=2997440 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true seq=82 bytes=372
t=2997452 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=83 ready=true has_socket=true
t=2997464 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=84 has_socket=true ready=true flushing=false
t=2997475 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=85 flushing=false ready=true has_socket=true bytes=372
t=2997487 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=86
t=2997499 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=87 bytes=372 has_socket=true ready=true flushing=false
t=2997510 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=88 has_socket=true bytes=372 ready=true
t=2997522 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=89 has_socket=true ready=true flushing=false
t=2997534 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=90 flushing=false has_socket=true bytes=372 ready=true
t=2997545 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=91 ready=true bytes=372
t=2997557 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=92 bytes=372 ready=true flushing=false
t=2997568 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=93 ready=true has_socket=true
t=2997580 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=94 ready=true has_socket=true bytes=372 flushing=false
t=2997591 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=95 flushing=false has_socket=true bytes=372 ready=true
t=2997603 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=96 ready=true bytes=372
t=2997615 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=97 has_socket=true ready=true flushing=false
t=2997627 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=98 has_socket=true ready=true flushing=false
t=2997638 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=99 has_socket=true ready=true flushing=false
t=2997650 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=100 bytes=372
t=2997661 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=101 bytes=372
t=2997673 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=102 bytes=372 ready=true
t=2997685 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=103 has_socket=true ready=true flushing=false bytes=372
t=2997696 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=104 bytes=372
t=2997710 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=105 bytes=372 ready=true
t=2997719 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=106 bytes=372 ready=true
t=2997731 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=107 bytes=372 ready=true
t=2997744 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=108
t=2997754 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=109 bytes=372
t=2997766 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=110
t=2997778 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=111 bytes=372
t=2997789 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=112 has_socket=true ready=true flushing=false bytes=372
t=2997802 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=113 ready=true bytes=372 flushing=false has_socket=true
t=2997812 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=114 bytes=372 ready=true
t=2997824 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=115 ready=true flushing=false bytes=372 has_socket=true
t=2997836 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=116
t=2997847 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=117 has_socket=true ready=true flushing=false
t=2997860 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=118 bytes=372 has_socket=true flushing=false
t=2997870 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=119 has_socket=true ready=true flushing=false
t=2997882 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=120 bytes=372 ready=true
t=2997894 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=121
t=2997905 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=122 bytes=372 has_socket=true flushing=false
t=2997918 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=123 bytes=372
t=2997928 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=124 has_socket=true ready=true flushing=false
t=2997940 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=125
t=2997953 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=126 bytes=372
t=2997964 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=127
t=2997978 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=128 ready=true
t=2997987 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=129 has_socket=true ready=true flushing=false
t=2997998 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=130 has_socket=true ready=true flushing=false
t=2998010 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=131 ready=true
t=2998021 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=132
t=2998033 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=133 ready=true flushing=false bytes=372 has_socket=true
t=2998044 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=134
t=2998057 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=135 ready=true flushing=false bytes=372 has_socket=true
t=2998070 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=136 ready=true
t=2998080 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=137 bytes=372
t=2998091 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=138 has_socket=true ready=true flushing=false
t=2998102 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=139 bytes=372
t=2998115 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=140 ready=true
t=2998128 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=141 ready=true
t=2998137 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=142 has_socket=true ready=true flushing=false bytes=372
t=2998149 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=143 ready=true
t=2998160 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 seq=144 flushing=false
t=2998173 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=145 bytes=372
t=2998185 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=146 ready=true
t=2998196 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=147 bytes=372
t=2998208 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=148 has_socket=true ready=true flushing=false bytes=372
t=2998219 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=149 bytes=372
t=2998230 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=150 bytes=372
t=2998242 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=151 ready=true flushing=false bytes=372 has_socket=true
t=2998254 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=152 has_socket=true ready=true flushing=false
t=2998265 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=153 has_socket=true ready=true flushing=false
t=2998277 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=154
t=2998288 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=155 ready=true flushing=false bytes=372 has_socket=true
t=2998300 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=156
t=2998312 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=157 has_socket=true ready=true flushing=false
t=2998324 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=158 ready=true flushing=false bytes=372 has_socket=true
t=2998335 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=159 has_socket=true ready=true flushing=false
t=2998347 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=160
t=2998358 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=161 bytes=372
t=2998370 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=162 bytes=372
t=2998382 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=163 has_socket=true ready=true flushing=false
t=2998393 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=164 bytes=372
t=2998404 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=165 bytes=372 has_socket=true flushing=false
t=2998416 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=166 has_socket=true ready=true flushing=false
t=2998428 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=167 bytes=372 has_socket=true flushing=false
t=2998440 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=168 bytes=372
t=2998451 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=169 bytes=372 has_socket=true flushing=false
t=2998463 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=170 has_socket=true ready=true flushing=false
t=2998474 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=171 bytes=372
t=2998486 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=172 has_socket=true ready=true flushing=false
t=2998497 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=173 bytes=372
t=2998509 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=174 bytes=372
t=2998520 sess=9Hn lvl=INFO cat=audio evt=level avg_db=-48 peak_db=-48
t=2998520 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=175 ready=true flushing=false bytes=372 has_socket=true
t=2998532 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=176 bytes=372
t=2998545 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=177
t=2998556 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=178 has_socket=true ready=true flushing=false
t=2998567 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=179 has_socket=true ready=true flushing=false
t=2998579 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=180 bytes=372 has_socket=true flushing=false
t=2998591 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=181 has_socket=true ready=true flushing=false
t=2998602 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=182 ready=true flushing=false bytes=372 has_socket=true
t=2998614 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=183 has_socket=true ready=true flushing=false
t=2998625 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=184
t=2998637 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=185 bytes=372
t=2998648 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=186 ready=true
t=2998660 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=187 ready=true
t=2998672 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=188 ready=true flushing=false bytes=372 has_socket=true
t=2998683 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=189 bytes=372 has_socket=true flushing=false
t=2998694 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=190 bytes=372
t=2998706 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=191 bytes=372
t=2998718 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=192 has_socket=true ready=true flushing=false
t=2998730 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true seq=193 flushing=false bytes=372
t=2998741 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=194 has_socket=true ready=true flushing=false bytes=372
t=2998753 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=195 has_socket=true ready=true flushing=false
t=2998764 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=196 bytes=372
t=2998778 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=197 bytes=372
t=2998787 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=198 bytes=372
t=2998799 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=199 has_socket=true ready=true flushing=false
t=2998811 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=200 has_socket=true ready=true flushing=false
t=2998823 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=201 bytes=372 has_socket=true flushing=false
t=2998834 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=202 bytes=372
t=2998846 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=203 ready=true
t=2998857 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=204 bytes=372
t=2998869 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=205 ready=true flushing=false has_socket=true bytes=372
t=2998881 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=206 has_socket=true ready=true flushing=false
t=2998892 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=207 ready=true
t=2998904 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 seq=208 flushing=false
t=2998915 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=209 has_socket=true ready=true flushing=false bytes=372
t=2998928 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=210 ready=true flushing=false bytes=372 has_socket=true
t=2998938 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=211 bytes=372
t=2998950 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=212 bytes=372
t=2998962 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=213 has_socket=true ready=true flushing=false
t=2998973 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=214 ready=true flushing=false bytes=372 has_socket=true
t=2998985 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=215 bytes=372 has_socket=true flushing=false
t=2998996 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=216 ready=true flushing=false bytes=372 has_socket=true
t=2999008 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=217 bytes=372
t=2999020 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=218 ready=true flushing=false bytes=372 has_socket=true
t=2999031 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=219 ready=true
t=2999043 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=220 has_socket=true ready=true flushing=false bytes=372
t=2999054 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=221 ready=true
t=2999066 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=222 has_socket=true ready=true flushing=false bytes=372
t=2999078 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=223 ready=true flushing=false bytes=372 has_socket=true
t=2999090 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=224 has_socket=true ready=true flushing=false bytes=372
t=2999101 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=225 bytes=372
t=2999113 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=226 has_socket=true ready=true flushing=false bytes=372
throwing -10877
throwing -10877
t=2999242 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=227
t=2999242 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=228
t=2999242 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=229
t=2999242 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=230
t=2999242 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=231
t=2999242 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=232
t=2999243 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=233
t=2999243 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=234 ready=true
t=2999243 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=235
t=2999243 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=236
t=2999243 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=237
t=2999252 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=238 ready=true
t=2999263 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=239 ready=true
t=2999276 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=240 has_socket=true flushing=false bytes=372
t=2999286 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=241 ready=true bytes=372
t=2999298 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=242 bytes=372 ready=true
t=2999310 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=243 ready=true
t=2999321 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=244 ready=true flushing=false bytes=372 has_socket=true
t=2999333 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=245 has_socket=true ready=true flushing=false bytes=372
t=2999345 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=246 has_socket=true ready=true flushing=false
t=2999356 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=247 has_socket=true ready=true flushing=false
t=2999368 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=248 bytes=372 has_socket=true flushing=false
t=2999380 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=249 has_socket=true ready=true flushing=false bytes=372
t=2999391 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=250 ready=true
t=2999403 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=251 bytes=372
t=2999415 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=252 ready=true flushing=false bytes=372 has_socket=true
t=2999426 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=253 has_socket=true ready=true flushing=false bytes=372
t=2999438 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=254 has_socket=true ready=true flushing=false bytes=372
t=2999449 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=255 bytes=372
t=2999461 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=256 bytes=372
t=2999472 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=257
t=2999484 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=258 ready=true
t=2999496 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=259 bytes=372 ready=true
t=2999507 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=260 ready=true
t=2999519 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=261 bytes=372
t=2999531 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=262 ready=true
t=2999542 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=263 has_socket=true ready=true flushing=false
t=2999554 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=264 has_socket=true ready=true flushing=false
t=2999565 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=265 has_socket=true ready=true flushing=false
t=2999577 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=266 ready=true
t=2999589 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=267 has_socket=true ready=true flushing=false
t=2999600 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=268 ready=true
t=2999613 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=269 bytes=372
t=2999624 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=270 has_socket=true ready=true flushing=false bytes=372
t=2999635 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=271 ready=true flushing=false bytes=372 has_socket=true
t=2999646 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=272 has_socket=true ready=true flushing=false
t=2999658 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=273 ready=true flushing=false bytes=372 has_socket=true
t=2999670 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=274 bytes=372
t=2999681 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=275 bytes=372 has_socket=true flushing=false
t=2999693 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=276 bytes=372
t=2999705 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=277 has_socket=true ready=true flushing=false
t=2999716 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=278 ready=true flushing=false bytes=372 has_socket=true
t=2999728 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=279 ready=true flushing=false bytes=372 has_socket=true
t=2999739 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=280 bytes=372
t=2999751 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=281 bytes=372
t=2999763 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=282 bytes=372
t=2999774 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=283 bytes=372
t=2999786 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=284 ready=true
t=2999798 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=285 bytes=372
t=2999809 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=286 has_socket=true ready=true flushing=false bytes=372
t=2999821 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=287 bytes=372 has_socket=true flushing=false
t=2999833 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=288 has_socket=true ready=true flushing=false
t=2999844 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=289 bytes=372
t=2999856 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=290 has_socket=true ready=true flushing=false bytes=372
t=2999867 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=291 bytes=372 ready=true
t=2999879 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=292 has_socket=true ready=true flushing=false
t=2999891 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=293 ready=true flushing=false bytes=372 has_socket=true
t=2999902 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=294 has_socket=true ready=true flushing=false
t=2999914 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=295 ready=true
t=2999925 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=296 bytes=372
t=2999937 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=297 bytes=372
t=2999948 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=298 ready=true
t=2999960 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=299 has_socket=true ready=true flushing=false
t=2999972 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=300 ready=true
t=2999983 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=301 bytes=372
t=2999995 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=302 ready=true
t=3000007 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=303 bytes=372
t=3000018 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=304 bytes=372
t=3000030 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=305 has_socket=true ready=true flushing=false
t=3000041 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=306 has_socket=true ready=true flushing=false
t=3000053 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=307 has_socket=true ready=true flushing=false
t=3000065 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=308 has_socket=true ready=true flushing=false bytes=372
t=3000077 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=309 ready=true flushing=false bytes=372 has_socket=true
t=3000088 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 seq=310 flushing=false
t=3000100 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=311 ready=true
t=3000111 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=312 has_socket=true ready=true flushing=false bytes=372
t=3000123 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=313 bytes=372 ready=true
t=3000135 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=314 ready=true
t=3000146 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=315 bytes=372
t=3000157 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=316 ready=true
t=3000169 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=317 bytes=372
t=3000181 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=318 bytes=372
t=3000192 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 flushing=false seq=319
t=3000204 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=320 bytes=372
t=3000215 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=321 bytes=372
t=3000227 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=322 bytes=372
t=3000239 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=323 bytes=372 ready=true
t=3000250 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=324 bytes=372
t=3000262 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=325 ready=true
t=3000274 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=326 has_socket=true ready=true flushing=false bytes=372
t=3000291 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=327 ready=true
t=3000297 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=328 has_socket=true ready=true flushing=false
t=3000309 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true ready=true bytes=372 seq=329
t=3000320 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=330 has_socket=true ready=true bytes=372 flushing=false
t=3000332 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false ready=true has_socket=true seq=331
t=3000343 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=332 has_socket=true ready=true flushing=false bytes=372
t=3000355 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=333 has_socket=true ready=true flushing=false
t=3000366 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=334 bytes=372 has_socket=true flushing=false
t=3000378 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=335 has_socket=true ready=true flushing=false
t=3000390 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=336 ready=true
t=3000401 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=337 has_socket=true ready=true flushing=false
t=3000413 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=338 ready=true
t=3000424 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=339 ready=true has_socket=true bytes=372 flushing=false
t=3000436 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=340 ready=true has_socket=true bytes=372 flushing=false
t=3000448 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=341 bytes=372 has_socket=true flushing=false
t=3000459 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=342 ready=true
t=3000471 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=343 bytes=372 ready=true
t=3000483 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=344 bytes=372 flushing=false has_socket=true
t=3000494 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=345 bytes=372
t=3000506 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=346 bytes=372
t=3000517 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=347 has_socket=true ready=true flushing=false
t=3000529 sess=9Hn lvl=INFO cat=audio evt=level avg_db=-51 peak_db=-51
t=3000530 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=348 bytes=372 ready=true
🧊 [WARMUP] Skipping (recently run) context=reachabilityChange
t=3000541 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=349 bytes=372
t=3000552 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=350 bytes=372 ready=true
t=3000564 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=351 bytes=372
t=3000578 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true bytes=372 ready=true seq=352
t=3000587 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=353
t=3000599 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=354 has_socket=true ready=true flushing=false
t=3000610 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=355 ready=true flushing=false bytes=372 has_socket=true
t=3000622 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=356 bytes=372
t=3000633 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=357 ready=true has_socket=true
t=3000645 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=358
t=3000657 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=359 bytes=372
t=3000668 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=360 ready=true
t=3000681 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=361 bytes=372 ready=true flushing=false
t=3000691 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=362 bytes=372 has_socket=true ready=true flushing=false
t=3000703 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=363 has_socket=true flushing=false bytes=372
t=3000715 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=364 has_socket=true ready=true flushing=false
t=3000726 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=365 ready=true
t=3000738 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=366 bytes=372 has_socket=true flushing=false
t=3000749 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=367 ready=true
t=3000761 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=368 bytes=372
t=3000773 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=369 bytes=372
t=3000925 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=370 has_socket=true
t=3000925 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=371 has_socket=true
t=3000925 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=372 has_socket=true
t=3000926 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=373 has_socket=true
t=3000926 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=374 has_socket=true
t=3000926 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=375 has_socket=true
t=3000926 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=376 has_socket=true
t=3000926 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=377 has_socket=true
t=3000926 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=378 has_socket=true
t=3000926 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=379 has_socket=true
t=3000926 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=380 has_socket=true
t=3000937 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=381 has_socket=true flushing=false bytes=372 ready=true
t=3000937 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=382 has_socket=true flushing=false bytes=372 ready=true
t=3000938 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=383
t=3000947 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=384 bytes=372 has_socket=true flushing=false
t=3000958 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=385 has_socket=true ready=true flushing=false bytes=372
t=3000970 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=386 ready=true has_socket=true
t=3001050 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=387 bytes=372
t=3001050 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=388 bytes=372
t=3001050 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=389 bytes=372
t=3001050 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=390 bytes=372
t=3001050 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=391 bytes=372
t=3001050 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=392 bytes=372
t=3001051 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=393 has_socket=true ready=true flushing=false
t=3001063 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=394 bytes=372 has_socket=true flushing=false
t=3001074 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=395 has_socket=true ready=true flushing=false bytes=372
t=3001087 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=396 has_socket=true ready=true flushing=false
t=3001098 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=397 bytes=372
t=3001110 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=398 bytes=372 ready=true
t=3001121 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=399
t=3001132 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=400 has_socket=true ready=true flushing=false
t=3001145 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=401 has_socket=true ready=true flushing=false
t=3001156 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=402 bytes=372
t=3001167 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=403
t=3001180 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=404 bytes=372 has_socket=true flushing=false
t=3001191 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=405
t=3001202 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=406 has_socket=true ready=true flushing=false
t=3001214 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=407
t=3001226 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=408 has_socket=true ready=true flushing=false
t=3001237 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=409 ready=true
t=3001249 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=410 ready=true has_socket=true
t=3001261 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=411 has_socket=true ready=true flushing=false
t=3001272 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=412 bytes=372
t=3001283 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=413
t=3001295 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=414 has_socket=true ready=true flushing=false
t=3001307 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=415 bytes=372
t=3001319 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=416 has_socket=true ready=true flushing=false
t=3001352 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=417 bytes=372
t=3001352 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=418 bytes=372
t=3001353 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=419 ready=true
t=3001365 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=420 ready=true
t=3001384 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=421
t=3001388 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=422 ready=true
t=3001400 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=423 has_socket=true ready=true flushing=false
t=3001412 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=424 ready=true
t=3001423 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=425 bytes=372
t=3001434 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=426 ready=true
t=3001446 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=427 bytes=372
t=3001458 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=428 bytes=372
t=3001470 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=429 bytes=372
t=3001481 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=430 ready=true
t=3001492 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=431 has_socket=true ready=true flushing=false
t=3001504 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=432 bytes=372
t=3001516 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=433 ready=true
t=3001528 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=434 ready=true has_socket=true
t=3001539 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=435 bytes=372
t=3001551 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=436 has_socket=true ready=true flushing=false
t=3001562 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=437 ready=true
t=3001574 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=438 has_socket=true ready=true flushing=false
t=3001586 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=439 ready=true
t=3001597 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=440 bytes=372
t=3001609 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=441
t=3001620 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=442 ready=true has_socket=true
t=3001632 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=443 ready=true
t=3001644 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=444 ready=true has_socket=true
t=3001656 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=445 ready=true has_socket=true
t=3001667 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=446 ready=true
t=3001679 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=447 ready=true has_socket=true
t=3001690 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=448 ready=true
t=3001702 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=449 bytes=372
t=3001713 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=450 ready=true
t=3001725 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=451 ready=true flushing=false bytes=372 has_socket=true
t=3001737 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=452 has_socket=true ready=true flushing=false
t=3001748 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=453 ready=true has_socket=true
t=3001760 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=454 has_socket=true ready=true flushing=false
t=3001772 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=455 ready=true has_socket=true
t=3001784 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=456 has_socket=true ready=true flushing=false bytes=372
t=3001795 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=457 ready=true
t=3001807 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=458 bytes=372
t=3001818 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=459 ready=true flushing=false bytes=372 has_socket=true
t=3001830 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=460 ready=true
t=3001843 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=461 ready=true
t=3001853 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=462
t=3001864 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=463 has_socket=true ready=true flushing=false
t=3001876 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=464 ready=true flushing=false bytes=372 has_socket=true
t=3001890 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=465 ready=true bytes=372
t=3001900 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=466 has_socket=true ready=true flushing=false
t=3001910 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=467 ready=true bytes=372
t=3001922 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=468 bytes=372
t=3001934 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=469 ready=true
t=3001945 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=470 has_socket=true ready=true flushing=false
t=3001957 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=471 ready=true has_socket=true
t=3001969 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=472 ready=true
t=3001980 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=473
t=3001992 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=474 bytes=372
t=3002003 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=475 bytes=372 ready=true
t=3002015 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=476 ready=true
t=3002027 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=477 ready=true
t=3002038 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=478 ready=true flushing=false bytes=372 has_socket=true
t=3002050 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=479 ready=true flushing=false bytes=372 has_socket=true
t=3002062 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=480 ready=true
t=3002073 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=481 ready=true
t=3002085 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=482 has_socket=true ready=true flushing=false
t=3002096 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=483
t=3002108 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=484 ready=true flushing=false bytes=372 has_socket=true
t=3002120 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=485
t=3002131 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=486 bytes=372
t=3002143 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=487 ready=true
t=3002154 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=488 has_socket=true ready=true flushing=false
t=3002166 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=489
t=3002177 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=490 ready=true flushing=false bytes=372 has_socket=true
t=3002189 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=491
t=3002201 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=492 bytes=372
t=3002213 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=493 has_socket=true ready=true flushing=false
t=3002224 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=494 ready=true
t=3002235 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=495 ready=true
t=3002247 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=496 bytes=372
t=3002259 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=497 ready=true
t=3002270 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=498 ready=true
t=3002282 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=499 bytes=372 has_socket=true flushing=false
t=3002294 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=500 ready=true flushing=false bytes=372 has_socket=true
t=3002306 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=501 ready=true flushing=false bytes=372 has_socket=true
t=3002317 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=502 ready=true flushing=false bytes=372 has_socket=true
t=3002328 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=503 ready=true flushing=false bytes=372 has_socket=true
t=3002340 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=504 ready=true flushing=false bytes=372 has_socket=true
t=3002352 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=505 ready=true flushing=false bytes=372 has_socket=true
t=3002364 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=506 ready=true flushing=false bytes=372 has_socket=true
t=3002377 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=507 bytes=372
t=3002386 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=508 ready=true
t=3002398 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=509 ready=true flushing=false bytes=372 has_socket=true
t=3002410 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=510 ready=true flushing=false bytes=372 has_socket=true
t=3002422 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=511 ready=true
t=3002433 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=512 ready=true flushing=false bytes=372 has_socket=true
t=3002446 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true bytes=372 ready=true seq=513
t=3002456 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=514 bytes=372
t=3002468 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=515
t=3002480 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=516
t=3002491 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=517 ready=true flushing=false bytes=372 has_socket=true
t=3002503 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=518
t=3002515 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=519
t=3002526 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=520 bytes=372
t=3002537 sess=9Hn lvl=INFO cat=audio evt=level avg_db=-30 peak_db=-30
t=3002538 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=521 ready=true flushing=false bytes=372 has_socket=true
t=3002549 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=522 ready=true
t=3002561 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=523 ready=true flushing=false bytes=372 has_socket=true
t=3002572 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=524
t=3002584 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=525
t=3002596 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=526 ready=true
t=3002607 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=527 bytes=372 has_socket=true flushing=false
t=3002619 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=528 bytes=372
t=3002630 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=529
t=3002642 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=530 bytes=372
t=3002654 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=531 bytes=372 has_socket=true flushing=false
t=3002665 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=532 ready=true
t=3002677 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=533 ready=true flushing=false bytes=372 has_socket=true
t=3002688 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=534
t=3002700 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=535 bytes=372
t=3002712 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=536 bytes=372
t=3002723 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=537 bytes=372 has_socket=true flushing=false
t=3002735 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=538
t=3002747 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=539 ready=true
t=3002758 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=540
t=3002770 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=541 ready=true
t=3002781 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=542
t=3002793 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=543
t=3002805 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=544 bytes=372
t=3002816 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=545
t=3002829 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=546 bytes=372
t=3002839 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=547 bytes=372
t=3002851 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=548 has_socket=true ready=true flushing=false
t=3002863 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=549 bytes=372
t=3002874 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=550 ready=true has_socket=true
t=3002886 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=551 has_socket=true ready=true flushing=false
t=3002897 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=552
t=3002909 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=553
t=3002920 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=554 bytes=372
t=3002933 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=555 ready=true has_socket=true
t=3002944 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=556 ready=true flushing=false bytes=372 has_socket=true
t=3002955 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=557 bytes=372
t=3002967 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=558 bytes=372
🛑 [TEN-VAD] Speech end detected
t=3002979 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=559 ready=true
t=3002990 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=560 has_socket=true ready=true flushing=false
t=3003002 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=561 ready=true
t=3003014 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=562 bytes=372
t=3003025 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=563 has_socket=true ready=true flushing=false
🤖 [FLY.IO-NER] Server-reported provider: gemini
📥 [NER-STORE] Stored NER entities: 6339 chars - The provided image shows a snippet of Swift code within the Xcode IDE, specifically from a file name...
✅ [FLY.IO] NER refresh completed successfully
t=3003038 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=564 ready=true
t=3003048 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=565 ready=true has_socket=true
t=3003060 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=566 bytes=372
t=3003072 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=567 has_socket=true ready=true flushing=false
t=3003083 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=568
t=3003095 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=569
t=3003106 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=570 bytes=372 has_socket=true flushing=false
t=3003118 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=571
t=3003130 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=572 ready=true
t=3003133 sess=9Hn lvl=INFO cat=stream evt=first_partial ms=6662
t=3003133 sess=9Hn lvl=INFO cat=stream evt=ttft_hotkey ms=6662
t=3003133 sess=9Hn lvl=INFO cat=stream evt=ttft ms=19698
🧪 [PROMO] first_token ms=6792 tokens_in_msg=1
t=3003200 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=573 has_socket=true flushing=false ready=true bytes=372
t=3003200 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=574 has_socket=true flushing=false ready=true bytes=372
t=3003200 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=575 has_socket=true flushing=false ready=true bytes=372
t=3003201 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=576 has_socket=true flushing=false ready=true bytes=372
t=3003201 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=577 has_socket=true flushing=false ready=true bytes=372
t=3003201 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=578 has_socket=true flushing=false ready=true bytes=372
t=3003211 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=579 ready=true flushing=false bytes=372 has_socket=true
t=3003222 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=580
t=3003234 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=581 ready=true has_socket=true bytes=372
t=3003246 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=582
t=3003257 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=583 ready=true
t=3003269 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=584 bytes=372 ready=true
t=3003280 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=585 flushing=false bytes=372 has_socket=true
t=3003292 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=586
t=3003335 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=587 flushing=false has_socket=true bytes=372
t=3003335 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=588 flushing=false has_socket=true bytes=372
t=3003335 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=589 flushing=false has_socket=true bytes=372
t=3003338 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=590 ready=true flushing=false bytes=372
t=3003350 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=591 bytes=372 ready=true flushing=false
t=3003362 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=592 bytes=372 ready=true has_socket=true flushing=false
t=3003373 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=593 flushing=false has_socket=true bytes=372
t=3003385 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=594 bytes=372 ready=true has_socket=true flushing=false
t=3003429 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=595 ready=true
t=3003429 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=596 ready=true
t=3003429 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=597 ready=true
t=3003431 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=598 ready=true
t=3003443 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=599
t=3003454 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=600
t=3003466 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=601
t=3003478 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=602 bytes=372 ready=true
t=3003489 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=603 ready=true flushing=false bytes=372 has_socket=true
t=3003501 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=604 bytes=372 ready=true flushing=false
t=3003512 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=605 ready=true has_socket=true flushing=false bytes=372
t=3003524 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=606 bytes=372 has_socket=true ready=true flushing=false
t=3003536 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=607 ready=true has_socket=true
t=3003548 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=608 bytes=372 ready=true
t=3003559 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=609 ready=true bytes=372 has_socket=true flushing=false
t=3003571 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=610 ready=true flushing=false bytes=372 has_socket=true
t=3003582 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=611 ready=true bytes=372 has_socket=true flushing=false
t=3003594 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=612 ready=true bytes=372 has_socket=true flushing=false
t=3003606 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=613 bytes=372
t=3003617 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=614 bytes=372
t=3003629 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=615 bytes=372
t=3003640 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=616 ready=true
t=3003702 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=617
t=3003703 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false seq=618 has_socket=true
t=3003703 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false seq=619 has_socket=true
t=3003703 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false seq=620 has_socket=true
t=3003703 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false seq=621 has_socket=true
t=3003710 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=622 ready=true has_socket=true bytes=372
t=3003722 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=623 ready=true
t=3003733 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=624 ready=true bytes=372
t=3003745 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=625 bytes=372 has_socket=true ready=true
t=3003756 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=626
t=3003768 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=627 flushing=false ready=true has_socket=true
t=3003780 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true seq=628 flushing=false
t=3003791 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=629 has_socket=true ready=true flushing=false bytes=372
t=3003803 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=630 bytes=372
t=3003814 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=631 bytes=372 has_socket=true flushing=false
t=3003827 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=632 bytes=372 has_socket=true flushing=false
t=3003838 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=633 has_socket=true ready=true flushing=false bytes=372
t=3003850 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=634 ready=true bytes=372 has_socket=true flushing=false
t=3003861 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=635 bytes=372
t=3003873 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=636 flushing=false bytes=372
t=3003884 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=637 flushing=false bytes=372
t=3003943 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=638 flushing=false bytes=372 ready=true
t=3003943 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=639 flushing=false bytes=372 ready=true
t=3003943 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=640 flushing=false bytes=372 ready=true
t=3003943 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=641 flushing=false bytes=372 ready=true
t=3003943 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=642 flushing=false bytes=372 ready=true
t=3003954 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=643 bytes=372 has_socket=true ready=true flushing=false
t=3003965 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=644
t=3003977 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=645 has_socket=true ready=true
t=3003988 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=646 has_socket=true ready=true
t=3004000 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=647 has_socket=true ready=true
t=3004012 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=648 ready=true bytes=372
t=3004024 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=649 has_socket=true ready=true flushing=false
t=3004035 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=650 ready=true bytes=372 has_socket=true flushing=false
t=3004047 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true ready=true bytes=372 seq=651
t=3004093 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=652
t=3004093 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=653
t=3004093 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=654
t=3004093 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=655 ready=true
t=3004105 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=656 has_socket=true ready=true bytes=372 flushing=false
t=3004116 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=657 ready=true
throwing -10877
throwing -10877
t=3004184 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=658 has_socket=true ready=true flushing=false
t=3004184 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=659 has_socket=true ready=true flushing=false
t=3004184 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=660 has_socket=true ready=true flushing=false
t=3004184 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=661 has_socket=true ready=true flushing=false
t=3004184 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=662 has_socket=true ready=true flushing=false
t=3004186 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=663 ready=true
t=3004197 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=664
t=3004209 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=665
t=3004221 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=666 ready=true
t=3004232 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=667 has_socket=true ready=true flushing=false
t=3004244 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=668
t=3004255 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=669 has_socket=true ready=true flushing=false
t=3004267 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=670
t=3004279 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=671 has_socket=true ready=true flushing=false bytes=372
t=3004290 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=672 has_socket=true ready=true bytes=372 flushing=false
t=3004302 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 ready=true flushing=false seq=673
t=3004342 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=674
t=3004342 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=675
t=3004343 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=676
t=3004348 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=677 ready=true flushing=false bytes=372
t=3004387 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=678
t=3004387 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=679
t=3004387 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=680
t=3004395 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=681 bytes=372 ready=true flushing=false
t=3004406 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=682 has_socket=true ready=true
t=3004418 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=683 bytes=372 ready=true flushing=false
t=3004430 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=684 bytes=372 ready=true flushing=false
t=3004441 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=685 has_socket=true ready=true
t=3004453 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=686 bytes=372 ready=true flushing=false
t=3004464 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 seq=687 flushing=false
t=3004476 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=688
t=3004488 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 seq=689 flushing=false
t=3004499 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=690 bytes=372 ready=true flushing=false
t=3004511 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=691 bytes=372 ready=true flushing=false
t=3004522 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=692
t=3004563 sess=9Hn lvl=INFO cat=audio evt=level avg_db=-38 peak_db=-38
t=3004563 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true seq=693 bytes=372
t=3004563 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true seq=694 bytes=372
t=3004563 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true seq=695 bytes=372
t=3004569 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=696
t=3004581 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=697 has_socket=true ready=true bytes=372 flushing=false
t=3004592 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true seq=698 bytes=372
t=3004631 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 has_socket=true seq=699
t=3004631 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 has_socket=true seq=700
t=3004631 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 has_socket=true seq=701
t=3004639 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=702
t=3004650 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=703 ready=true
🛑 [TEN-VAD] Speech end detected
t=3004662 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=704
t=3004673 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=705 ready=true has_socket=true
t=3004685 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 ready=true seq=706
t=3004697 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=707 ready=true
t=3004742 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=708 ready=true
t=3004742 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=709 ready=true
t=3004742 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=710 ready=true
t=3004743 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=711 has_socket=true ready=true
t=3004755 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=712 has_socket=true ready=true flushing=false bytes=372
t=3004766 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=713
t=3004778 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=714
t=3004789 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=715
t=3004801 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=716 has_socket=true ready=true
t=3004813 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=717 has_socket=true ready=true
t=3004825 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=718 has_socket=true ready=true bytes=372 flushing=false
t=3004836 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=719 ready=true
t=3004848 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=720
t=3004859 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=721 has_socket=true ready=true
t=3004871 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=722 has_socket=true ready=true bytes=372 flushing=false
t=3004882 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=723 has_socket=true ready=true
t=3004894 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=724 ready=true bytes=372 has_socket=true flushing=false
t=3004907 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=725 ready=true has_socket=true
t=3004918 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=726 has_socket=true ready=true flushing=false
t=3004929 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=727 has_socket=true ready=true flushing=false
t=3004941 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=728 bytes=372
t=3004953 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=729 bytes=372
t=3005022 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=730 has_socket=true ready=true
t=3005022 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=731 has_socket=true ready=true
t=3005022 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=732 flushing=false has_socket=true ready=true
t=3005022 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=733 flushing=false has_socket=true ready=true
t=3005022 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=734 flushing=false has_socket=true ready=true
t=3005022 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=735 flushing=false has_socket=true ready=true
t=3005034 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=736 ready=true bytes=372 flushing=false has_socket=true
t=3005045 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=737 has_socket=true ready=true
t=3005057 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=738 ready=true has_socket=true flushing=false bytes=372
t=3005068 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=739
t=3005080 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=740 ready=true bytes=372 flushing=false has_socket=true
t=3005130 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=741 ready=true bytes=372
t=3005130 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=742 ready=true bytes=372
t=3005130 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=743 ready=true bytes=372
t=3005130 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=744 ready=true bytes=372
t=3005138 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=745 ready=true bytes=372
t=3005149 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true seq=746 bytes=372 has_socket=true
t=3005161 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=747 has_socket=true ready=true
t=3005204 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=748 ready=true has_socket=true flushing=false bytes=372
t=3005204 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=749 ready=true has_socket=true flushing=false bytes=372
t=3005204 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=750 ready=true has_socket=true flushing=false bytes=372
t=3005208 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=751
t=3005219 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=752 ready=true has_socket=true flushing=false bytes=372
t=3005231 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=753 ready=true flushing=false has_socket=true
t=3005242 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=754
t=3005254 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=755 ready=true bytes=372
t=3005265 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 seq=756 has_socket=true
t=3005277 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=757 ready=true has_socket=true flushing=false bytes=372
t=3005289 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=758 bytes=372 has_socket=true ready=true flushing=false
t=3005300 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=759 bytes=372 has_socket=true ready=true flushing=false
t=3005312 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=760 has_socket=true flushing=false
t=3005324 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=761 flushing=false ready=true bytes=372 has_socket=true
t=3005335 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=762 flushing=false ready=true bytes=372 has_socket=true
t=3005347 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=763 flushing=false ready=true bytes=372 has_socket=true
t=3005359 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=764 ready=true flushing=false bytes=372 has_socket=true
t=3005371 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=765 has_socket=true ready=true flushing=false
t=3005383 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=766 bytes=372
t=3005393 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=767 bytes=372
t=3005405 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=768 bytes=372
t=3005417 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=769 ready=true flushing=false bytes=372 has_socket=true
t=3005428 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=770
t=3005440 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=771 ready=true
t=3005502 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=772 has_socket=true
t=3005502 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=773 has_socket=true
t=3005502 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=774 has_socket=true
t=3005502 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=775 has_socket=true
t=3005502 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=776 has_socket=true
t=3005509 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=777 has_socket=true ready=true bytes=372 flushing=false
t=3005521 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=778 bytes=372 ready=true has_socket=true flushing=false
t=3005533 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true seq=779 has_socket=true
t=3005544 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=780 flushing=false ready=true has_socket=true bytes=372
t=3005556 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=781 has_socket=true ready=true bytes=372 flushing=false
t=3005567 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true seq=782 has_socket=true
t=3005579 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=783
t=3005591 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=784
t=3005603 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=785 bytes=372 has_socket=true
t=3005614 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=786 ready=true has_socket=true
t=3005626 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=787 bytes=372 has_socket=true
t=3005637 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=788 bytes=372 ready=true flushing=false has_socket=true
t=3005649 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 seq=789 ready=true
t=3005661 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=790 has_socket=true ready=true flushing=false bytes=372
t=3005673 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=791 has_socket=true ready=true flushing=false bytes=372
t=3005686 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=792 ready=true has_socket=true
t=3005695 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=793 has_socket=true ready=true bytes=372
t=3005707 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=794 flushing=false has_socket=true ready=true bytes=372
t=3005719 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=795 ready=true has_socket=true
t=3005730 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=796 ready=true has_socket=true
t=3005742 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=797 has_socket=true ready=true flushing=false
t=3005753 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=798 ready=true has_socket=true
t=3005766 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=799 has_socket=true ready=true flushing=false
t=3005777 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=800 bytes=372 ready=true flushing=false has_socket=true
t=3005789 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=801
t=3005800 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=802 flushing=false has_socket=true ready=true bytes=372
t=3005864 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=803 has_socket=true ready=true
t=3005864 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=804 has_socket=true ready=true
t=3005864 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=805 has_socket=true ready=true
t=3005864 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=806 has_socket=true ready=true
t=3005864 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=807 has_socket=true ready=true
t=3005869 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=808 bytes=372 flushing=false has_socket=true ready=true
t=3005881 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=809 has_socket=true ready=true
t=3005892 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=810
t=3005904 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=811 bytes=372 has_socket=true
t=3005943 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=812 ready=true has_socket=true flushing=false bytes=372
t=3005944 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=813 ready=true has_socket=true flushing=false bytes=372
t=3005944 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=814 ready=true has_socket=true flushing=false bytes=372
t=3005950 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=815 bytes=372 ready=true flushing=false
t=3005962 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=816 bytes=372 ready=true has_socket=true flushing=false
t=3005974 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=817 bytes=372 has_socket=true
t=3005985 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=818 bytes=372 ready=true has_socket=true flushing=false
t=3005997 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=819 bytes=372 ready=true has_socket=true flushing=false
t=3006009 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=820 bytes=372 has_socket=true
t=3006052 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=821 has_socket=true ready=true
t=3006052 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=822 has_socket=true ready=true
t=3006052 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=823 has_socket=true ready=true
t=3006055 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=824 ready=true
t=3006067 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=825 bytes=372 has_socket=true ready=true flushing=false
t=3006078 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=826 ready=true has_socket=true flushing=false
t=3006090 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=827 has_socket=true ready=true bytes=372 flushing=false
t=3006101 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=828 has_socket=true ready=true
t=3006113 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true bytes=372 seq=829 ready=true
t=3006125 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=830 ready=true
t=3006136 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=831 ready=true
t=3006148 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=832
t=3006159 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=833 has_socket=true ready=true bytes=372 flushing=false
t=3006165 sess=9Hn lvl=INFO cat=stream evt=first_final ms=9694
t=3006165 sess=9Hn lvl=INFO cat=transcript evt=raw_final text="Here are em"
t=3006171 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=834 has_socket=true ready=true
t=3006224 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=835 has_socket=true ready=true
t=3006225 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=836 has_socket=true ready=true
t=3006225 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=837 has_socket=true ready=true
t=3006225 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=838 has_socket=true ready=true
t=3006229 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=839 bytes=372 has_socket=true
t=3006241 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=840 ready=true flushing=false bytes=372
t=3006252 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=841 ready=true flushing=false has_socket=true bytes=372
t=3006264 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=842 flushing=false bytes=372 has_socket=true
t=3006276 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=843 has_socket=true ready=true bytes=372 flushing=false
t=3006288 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false seq=844 ready=true
t=3006299 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=845 ready=true flushing=false bytes=372
t=3006310 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true seq=846 bytes=372
t=3006322 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=847 ready=true flushing=false has_socket=true bytes=372
t=3006334 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=848 has_socket=true ready=true
t=3006346 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=849 bytes=372
t=3006358 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=850 ready=true flushing=false bytes=372 has_socket=true
t=3006369 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=851 bytes=372 ready=true
t=3006422 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=852 has_socket=true bytes=372 ready=true
t=3006422 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=853 has_socket=true bytes=372 ready=true
t=3006422 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=854 has_socket=true bytes=372 ready=true
t=3006422 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=855 has_socket=true bytes=372 ready=true
t=3006426 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=856 ready=true
t=3006438 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=857 bytes=372 has_socket=true ready=true flushing=false
t=3006450 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=858 has_socket=true ready=true bytes=372 flushing=false
t=3006461 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true seq=859 bytes=372
t=3006473 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true seq=860 bytes=372
t=3006485 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true seq=861 bytes=372
t=3006496 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=862 has_socket=true ready=true bytes=372 flushing=false
t=3006508 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=863 ready=true has_socket=true flushing=false bytes=372
t=3006520 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=864 ready=true has_socket=true
t=3006531 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=865 flushing=false has_socket=true ready=true bytes=372
t=3006543 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 seq=866 has_socket=true
t=3006592 sess=9Hn lvl=INFO cat=audio evt=level avg_db=-40 peak_db=-40
t=3006592 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true ready=true seq=867 bytes=372
t=3006592 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true ready=true seq=868 bytes=372
t=3006593 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true ready=true seq=869 bytes=372
t=3006593 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true ready=true seq=870 bytes=372
t=3006601 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=871 has_socket=true ready=true
t=3006612 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=872 has_socket=true ready=true bytes=372
t=3006624 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 seq=873 ready=true
t=3006635 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 ready=true flushing=false seq=874
t=3006672 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=875 has_socket=true flushing=false ready=true bytes=372
t=3006672 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=876 has_socket=true flushing=false ready=true bytes=372
t=3006672 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=877 has_socket=true flushing=false ready=true bytes=372
t=3006682 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=878 flushing=false bytes=372 has_socket=true
t=3006693 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=879 has_socket=true ready=true bytes=372 flushing=false
t=3006705 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=880
t=3006717 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=881 ready=true bytes=372
t=3006728 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=882 flushing=false has_socket=true bytes=372
t=3006740 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=883 ready=true
t=3006752 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=884 ready=true
t=3006763 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true seq=885 bytes=372
t=3006804 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=886 flushing=false has_socket=true bytes=372
t=3006804 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=887 flushing=false has_socket=true bytes=372
t=3006804 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=888 flushing=false has_socket=true bytes=372
t=3006810 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=889 has_socket=true ready=true
t=3006821 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true has_socket=true flushing=false seq=890
t=3006833 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=891 has_socket=true ready=true bytes=372 flushing=false
t=3006845 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=892 flushing=false bytes=372 has_socket=true
t=3006856 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 ready=true flushing=false seq=893
t=3006868 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=894 ready=true
t=3006880 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 has_socket=true seq=895
t=3006891 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=896 bytes=372
t=3006903 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=897 bytes=372 has_socket=true flushing=false
t=3006973 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false has_socket=true seq=898
t=3006974 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false has_socket=true seq=899
t=3006974 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false has_socket=true seq=900
t=3006974 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false has_socket=true seq=901
t=3006974 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false has_socket=true seq=902
t=3006974 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false has_socket=true seq=903
t=3006984 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false has_socket=true seq=904
t=3006995 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=905 flushing=false ready=true bytes=372 has_socket=true
t=3007007 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=906 has_socket=true
t=3007019 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=907 ready=true flushing=false has_socket=true
t=3007030 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=908 has_socket=true bytes=372 ready=true
t=3007042 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=909 bytes=372 ready=true flushing=false
t=3007054 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=910 flushing=false has_socket=true bytes=372 ready=true
t=3007065 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=911 ready=true has_socket=true bytes=372 flushing=false
t=3007077 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false has_socket=true seq=912
t=3007089 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=913 ready=true flushing=false bytes=372 has_socket=true
t=3007101 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=914 ready=true bytes=372 has_socket=true flushing=false
t=3007112 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=915
t=3007176 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true seq=916 bytes=372
t=3007176 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true seq=917 bytes=372
t=3007176 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true seq=918 bytes=372
t=3007176 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true seq=919 bytes=372
t=3007176 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true seq=920 bytes=372
t=3007181 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=921 bytes=372 ready=true flushing=false
t=3007193 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=922 ready=true flushing=false bytes=372 has_socket=true
t=3007205 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false has_socket=true seq=923
t=3007216 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=924 has_socket=true ready=true
t=3007228 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=925 has_socket=true ready=true
t=3007239 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=926 flushing=false ready=true has_socket=true
t=3007251 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 ready=true seq=927
t=3007263 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false seq=928 ready=true
t=3007274 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 ready=true flushing=false seq=929
t=3007327 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=930 bytes=372 ready=true
t=3007327 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=931 bytes=372 ready=true
t=3007327 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=932 bytes=372 ready=true
t=3007327 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=933 bytes=372 ready=true
t=3007332 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=934 ready=true
t=3007344 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false ready=true seq=935
t=3007378 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=936 has_socket=true bytes=372 ready=true
t=3007378 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=937 has_socket=true bytes=372 ready=true
t=3007379 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=938 bytes=372 ready=true has_socket=true
t=3007391 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=939 bytes=372 ready=true flushing=false
t=3007402 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=940 bytes=372 ready=true flushing=false
t=3007413 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=941 has_socket=true bytes=372 ready=true
t=3007425 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=942 has_socket=true bytes=372 ready=true
t=3007437 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=943 ready=true
t=3007449 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=944 ready=true
t=3007460 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=945 has_socket=true bytes=372 ready=true
t=3007466 sess=9Hn lvl=INFO cat=transcript evt=raw_final text="ail lists to Princeton, I think"
t=3007471 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=946 ready=true
t=3007510 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true seq=947 bytes=372
t=3007510 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true seq=948 bytes=372
t=3007510 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true seq=949 bytes=372
t=3007518 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=950 bytes=372 has_socket=true ready=true flushing=false
t=3007530 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=951 has_socket=true ready=true bytes=372 flushing=false
t=3007541 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=952 ready=true
t=3007553 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=953 ready=true
t=3007564 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=954 ready=true
t=3007576 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=955 bytes=372 ready=true flushing=false
t=3007620 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=956 ready=true
t=3007620 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=957 ready=true
t=3007620 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=958 ready=true
t=3007622 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true seq=959 bytes=372
t=3007634 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false seq=960 ready=true
t=3007646 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=961 ready=true bytes=372
t=3007657 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=962 ready=true
t=3007669 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=963 bytes=372 ready=true flushing=false
t=3007680 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false has_socket=true seq=964
t=3007692 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=965 ready=true
t=3007734 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=966 flushing=false has_socket=true bytes=372
t=3007734 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=967 flushing=false has_socket=true bytes=372
t=3007734 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=968 flushing=false has_socket=true bytes=372
t=3007738 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=969 flushing=false has_socket=true bytes=372
t=3007750 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=970 bytes=372 ready=true has_socket=true flushing=false
t=3007762 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=971 flushing=false ready=true has_socket=true
t=3007773 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 seq=972 ready=true
t=3007785 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=973 bytes=372 ready=true flushing=false
t=3007797 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=974 flushing=false has_socket=true bytes=372
t=3007808 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true seq=975 has_socket=true
t=3007820 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true seq=976 has_socket=true
t=3007831 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true seq=977 has_socket=true
t=3007879 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=978 has_socket=true ready=true bytes=372 flushing=false
t=3007880 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=979 ready=true bytes=372
t=3007880 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=980 ready=true bytes=372
t=3007880 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=981 ready=true bytes=372
t=3007889 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=982 bytes=372 ready=true flushing=false
t=3007901 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=983 ready=true flushing=false
t=3007913 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true has_socket=true flushing=false seq=984
t=3007924 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=985 bytes=372 ready=true flushing=false
t=3007936 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=986 bytes=372 ready=true flushing=false
t=3007948 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false has_socket=true seq=987
t=3007992 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=988 has_socket=true ready=true flushing=false
t=3007993 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=989 has_socket=true ready=true flushing=false
t=3007993 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=990 has_socket=true ready=true flushing=false
t=3007994 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=991 ready=true
t=3008005 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=992 has_socket=true ready=true bytes=372 flushing=false
t=3008017 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=993 has_socket=true ready=true flushing=false
t=3008029 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=994 flushing=false has_socket=true bytes=372 ready=true
t=3008040 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=995 flushing=false has_socket=true bytes=372 ready=true
t=3008052 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false has_socket=true seq=996
t=3008064 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=997 ready=true flushing=false
t=3008096 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=998 ready=true
t=3008096 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=999 ready=true
t=3008098 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=1000 ready=true
t=3008110 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=1001 has_socket=true flushing=false bytes=372
t=3008122 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=1002 bytes=372 ready=true flushing=false
t=3008133 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=1003 bytes=372 ready=true flushing=false
t=3008145 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true seq=1004 bytes=372
t=3008156 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false has_socket=true seq=1005
t=3008168 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=1006 ready=true
t=3008180 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=1007 ready=true
t=3008191 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=1008 ready=true
🛑 [TEN-VAD] Speech end detected
t=3008203 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true seq=1009 bytes=372
t=3008215 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true seq=1010 bytes=372
t=3008226 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true seq=1011 bytes=372
t=3008238 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=1012 ready=true bytes=372 has_socket=true flushing=false
t=3008250 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=1013 has_socket=true
t=3008261 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=1014 has_socket=true
t=3008273 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=1015 has_socket=true
t=3008284 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=1016 ready=true bytes=372 has_socket=true flushing=false
t=3008296 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=1017 bytes=372
t=3008308 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=1018 has_socket=true
t=3008319 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=1019 has_socket=true
t=3008331 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=1020 bytes=372
t=3008394 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=1021 ready=true bytes=372 flushing=false
t=3008394 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=1022 ready=true bytes=372 flushing=false
t=3008394 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=1023 ready=true bytes=372 flushing=false
t=3008394 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=1024 ready=true bytes=372 flushing=false
t=3008394 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=1025 ready=true bytes=372 flushing=false
t=3008400 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 seq=1026 flushing=false
t=3008412 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=1027 has_socket=true ready=true
t=3008423 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=1028 has_socket=true ready=true bytes=372 flushing=false
t=3008435 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=1029 bytes=372 ready=true flushing=false
t=3008447 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=1030 has_socket=true ready=true
t=3008459 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=1031 has_socket=true ready=true
t=3008470 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=1032 bytes=372
t=3008482 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=1033 ready=true
t=3008493 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=1034 ready=true bytes=372 has_socket=true flushing=false
t=3008515 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=1035 flushing=false
🛑 [TEN-VAD] Speech end detected
t=3008521 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=1036
t=3008528 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=1037 flushing=false
t=3008540 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=1038 has_socket=true ready=true
t=3008551 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=1039 bytes=372
t=3008563 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=1040 flushing=false bytes=372 ready=true
t=3008576 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=1041
t=3008586 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=1042 has_socket=true flushing=false ready=true
t=3008598 sess=9Hn lvl=INFO cat=audio evt=level peak_db=-46 avg_db=-46
t=3008598 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=1043 bytes=372
t=3008610 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=1044 has_socket=true bytes=372 flushing=false
t=3008621 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=1045 bytes=372
t=3008633 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=1046 flushing=false has_socket=true bytes=372
t=3008644 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=1047 has_socket=true flushing=false ready=true
t=3008656 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=1048
t=3008668 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=1049 ready=true bytes=372 has_socket=true flushing=false
t=3008679 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=1050 has_socket=true flushing=false ready=true
t=3008691 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=1051 ready=true bytes=372 has_socket=true
t=3008702 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=1052 bytes=372
t=3008714 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=1053 bytes=372
t=3008775 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=1054 has_socket=true flushing=false bytes=372
t=3008775 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=1055 has_socket=true flushing=false bytes=372
t=3008775 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=1056 has_socket=true flushing=false bytes=372
t=3008775 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=1057 bytes=372 ready=true
t=3008775 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=1058 bytes=372 ready=true
t=3008784 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true seq=1059 bytes=372
t=3008795 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=1060 ready=true has_socket=true flushing=false bytes=372
t=3008803 sess=9Hn lvl=INFO cat=transcript evt=raw_final text=" a day later, and it k"
t=3008807 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true seq=1061 bytes=372
t=3008818 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=1062 ready=true has_socket=true
t=3008853 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=1063 ready=true has_socket=true flushing=false bytes=372
t=3008853 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=1064 ready=true has_socket=true flushing=false bytes=372
t=3008853 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true seq=1065 bytes=372
t=3008865 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 ready=true flushing=false seq=1066
t=3008876 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=1067 has_socket=true ready=true bytes=372 flushing=false
t=3008888 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=1068 bytes=372 flushing=false has_socket=true ready=true
t=3008899 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 ready=true flushing=false seq=1069
t=3008911 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true seq=1070 bytes=372
t=3008923 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=1071 ready=true
t=3008934 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=1072 ready=true flushing=false bytes=372
t=3008977 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=1073 has_socket=true bytes=372
t=3008977 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true ready=true seq=1074
t=3008977 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true ready=true seq=1075
t=3008981 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 ready=true seq=1076 flushing=false
t=3008993 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=1077 has_socket=true ready=true
t=3009004 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true seq=1078 bytes=372
t=3009016 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=1079 has_socket=true
t=3009027 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=1080 has_socket=true bytes=372 flushing=false ready=true
t=3009039 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=1081 ready=true
🛑 Stopping recording
🛑 Stopping Clio streaming transcription
🏥 [AUDIO HEALTH] Health monitoring timer stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
🛑 Stopping unified audio capture
t=3009108 sess=9Hn lvl=INFO cat=audio evt=record_stop
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key plugInPackage
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key CMIOType
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key numberOfDevices
t=3009117 sess=9Hn lvl=INFO cat=audio evt=avcapture_stop
✅ Unified audio capture stopped
t=3009117 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=1082
t=3009117 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=1083
t=3009117 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=1084 ready=true
t=3009152 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=1085 ready=true has_socket=true
t=3009152 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=1086 ready=true has_socket=true
📤 Sent end-of-stream signal
📤 Sent manual finalize command
🕐 Using finalization timeout: 400ms (connection took 12776ms)
ℹ️ [OPTIMISTIC] Not skipping: end=false pending=0 ms_since_last=93 tail=100 silence_ok=false tokens_quiet_ok=true partial_empty=false uncond=false
🏁 Received <fin> token - finalization complete
t=3009635 sess=9Hn lvl=INFO cat=transcript evt=raw_final text="ind of has some sort of variety, kind of blew up within that student community. People.<end>"
⏹️ Keepalive timer stopped
⚡ Audio capture already stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
📉 Released connection for account account-bundle (connections: 0)
💾 [COLD-START] Updated successful streaming timestamp
💾 [COLD-START] Updated successful streaming timestamp
✅ Streaming stopped. Final transcript (152 chars, 13.2s, with audio file): "Here are email lists to Princeton, I think a day later, and it k ind of has some sort of variety, kind of blew up within that student community. People."
t=3009712 sess=9Hn lvl=INFO cat=transcript evt=final text="Here are email lists to Princeton, I think a day later, and it k ind of has some sort of variety, kind of blew up within that student community. People."
t=3009712 sess=9Hn lvl=INFO cat=transcript evt=session_end divider="────────── session end ──────────"
🌡️ [WARM] warm_socket=yes
⏹️ Keepalive timer stopped
🔌 [WS] Disconnected (socketId=sock_-66227754045365699@attempt_10)
⚠️ WebSocket did close with code 1001 (sid=sock_-66227754045365699, attemptId=10)
t=3009712 sess=9Hn lvl=WARN cat=stream evt=state state=closed code=1001
✅ Streaming transcription completed successfully, length: 152 characters
⏱️ [TIMING] Subscription tracking: 0.3ms
⏱️ [TIMING] ASR word tracking: 0.0ms
🧠 Performing intelligent end-context detection for streaming
⏱️ [CONTEXT DETAIL] Cache check: 0.0ms
⚡ [SMART-OPTIMIZATION] Using smart cached screen context (2713 chars) - skipping new capture
⏱️ [STREAMING CONTEXT TIMING] Screen capture + context detection: 0.0ms
🎯 Starting dynamic context-aware AI enhancement with tracking for text (152 characters)
⚡ [FAST-PATH] Using pre-warmed context - skipping redundant detection
⚡ [PREWARMED] Using pre-warmed NER context fast-path
🔍 [REGISTRY] Starting context detection using new rule engine
🔍 [REGISTRY] Bundle ID: com.google.Chrome
🔍 [REGISTRY] Process name: nil
🔍 [REGISTRY] URL: nil
🔍 [REGISTRY] Window title: (17) A Yale Student Raised $3.1M in 2 Weeks for an AI Social App | Series, Nathaneo Johnson - YouTube
🔍 [REGISTRY] Content length: 2713 chars
🎯 [RULE-ENGINE] Cache hit for com.google.Chrome|||(17) A Yale Student Raised $3.1M in 2 Weeks for an AI Social App | Series, Nathaneo Johnson - YouTube
🔄 [REGISTRY] Rule engine returned .none, checking for high-confidence legacy matches only
🔄 [REGISTRY] Trying legacy Email detector (priority: 100)
📧 [EMAIL] Starting email context detection
🚫 [DYNAMIC] Email exclusion detected in content: excluding from detection
🔄 [REGISTRY] Trying legacy Code Review detector (priority: 90)
💻 [CODE] Starting code context detection
❌ [CODE] Code confidence too low: 0.000000 < 0.300000
🔄 [REGISTRY] Trying legacy Social Media detector (priority: 10)
💬 [CHAT] Starting casual chat context detection
💬 [CHAT] Casual chat context detected - Title matches: 1, Content matches: 3, Confidence: 0.260000
🚫 [REGISTRY] Legacy Social Media context rejected - rule engine returned .none and confidence not high enough (0.260000 < 0.800000)
📝 [REGISTRY] Rule engine returned .none and no high-confidence legacy matches, returning general context
📝 [PREWARMED] Non-code or unknown context → using enhanced system prompt
🚨 [PROMPT-DEBUG] About to call getSystemMessage(for: .transcriptionEnhancement)
🚨 [PROMPT-DEBUG] getSystemMessage called with mode: transcriptionEnhancement
🚨 [PROMPT-DEBUG] RETURNING TRANSCRIPTION ENHANCEMENT PROMPT
🌐 [LANG DEBUG] Multi-language setting exists: true, Single language: en
🌐 [LANG DEBUG] Using multi-language selection (prioritized): zh, en
🚨 [PROMPT-DEBUG] About to call getUserMessage(text:, mode: .transcriptionEnhancement)
🌐 [LANG DEBUG] Multi-language setting exists: true, Single language: en
🌐 [LANG DEBUG] Using multi-language selection (prioritized): zh, en
🌐 [LANG DEBUG] Multi-language setting exists: true, Single language: en
🌐 [LANG DEBUG] Using multi-language selection (prioritized): zh, en
📝 [PREWARMED-SYSTEM] Enhanced system prompt: 'You are an expert in enhancing the text provided within <TRANSCRIPT> tags according to the following guidelines: The information in <CONTEXT_INFORMATI...'
📝 [PREWARMED-USER] Enhanced user prompt: '<CONTEXT_INFORMATION>
NER Context Entities:
The provided image shows a snippet of Swift code within the Xcode IDE, specifically from a file named `Son...'
System Message: You are an expert in enhancing the text provided within <TRANSCRIPT> tags according to the following guidelines: The information in <CONTEXT_INFORMATION> section is ONLY for reference.

### INSTRUCTIO…
User Message: <CONTEXT_INFORMATION>
NER Context Entities:
The provided image shows a snippet of Swift code within the Xcode IDE, specifically from a file named `SonioxStreamingService.swift`. The active window is t…
🌐 Sending custom-prompt request to LLM proxy (provider auto-selected by server)...
🔑 [DEBUG] Getting JWT token...
🔑 [DEBUG] JWT token obtained in 0ms
🎯 [CONFIG-DEBUG] Config 2: Routing to Groq endpoint (https://fly.cliovoice.com/api/llm/proxy) with model: qwen
📝 [TIMING] Request preparation: 0.1ms
🌐 [DEBUG] Sending request to proxy...
🌐 [CONNECT] New single-flight request from warmHold
🌐 [CONNECT] Attempt #11 (loop 1/2) starting…
t=3009880 sess=9Hn lvl=INFO cat=stream evt=temp_key_fetch_start
⚡ [CACHE-HIT] Retrieved temp key in 0.1ms
t=3009880 sess=9Hn lvl=INFO cat=stream evt=temp_key_fetch expires_in_s=-1 source=cached latency_ms=0
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🌐 [WS CONNECT] Using URL: wss://stt-rt.soniox.com/transcribe-websocket
🔗 [WS] Bound socket id=sock_1943519547568010667@attempt_11
t=3009881 sess=9Hn lvl=INFO cat=stream evt=ws_bind target_ip=resolving... target_host=stt-rt.soniox.com attempt=11 via_proxy=false socket=sock_1943519547568010667@attempt_11 path=/transcribe-websocket
🔑 Successfully connected to Soniox using temp key (1ms key latency)
t=3009882 sess=9Hn lvl=INFO cat=stream evt=ws_bind_resolved via_proxy=false target_host=stt-rt.soniox.com attempt=11 path=/transcribe-websocket socket=sock_1943519547568010667@attempt_11 target_ip=129.146.176.251
t=3010968 sess=9Hn lvl=INFO cat=stream evt=ws_handshake_metrics reused=false protocol=http/1.1 attempt=11 proxy=false socket=sock_1943519547568010667@attempt_11 tls_ms=818 dns_ms=0 connect_ms=822 total_ms=1086
🔌 WebSocket did open (sid=sock_1943519547568010667, attemptId=11)
🌐 [CONNECT] Attempt #11 succeeded
📤 [START] Sent start/config on standby socket (eager mode)
t=3010969 sess=9Hn lvl=INFO cat=stream evt=start_config summary=["audio_format": "pcm_s16le", "sr": 16000, "langs": 2, "ctx_len": 36, "model": "stt-rt-preview-v2", "json_hash": "647d4d9a98bd6de5", "ch": 1, "valid": true] attempt=11 socket=sock_1943519547568010667@attempt_11 ctx=standby_eager
🧾 [START-CONFIG] ctx=standby_eager sum=["audio_format": "pcm_s16le", "sr": 16000, "langs": 2, "ctx_len": 36, "model": "stt-rt-preview-v2", "json_hash": "647d4d9a98bd6de5", "ch": 1, "valid": true]
🧊 [STANDBY] Connected standby socket — keepalive every 10.0s, TTL=60s
📤 Sending text frame seq=6577
🔌 [READY] attemptId=11 socketId=sock_1943519547568010667@attempt_11 start_text_sent=true
🧊 [STANDBY] WebSocket ready in 1090ms (handshake)
👂 [LISTENER] Standby listener task for socketId=sock_1943519547568010667@attempt_11 attemptId=11
🌐 [DEBUG] Proxy response received in 4389ms
✅ [SSE] Parsed streaming response: 136 characters
🔍 [CONNECTION HEALTH]
🌐 [LANG DEBUG] Multi-language setting exists: true, Single language: en
🌐 [LANG DEBUG] Using multi-language selection (prioritized): zh, en
✅ Custom-prompt enhancement via proxy succeeded
t=3014221 sess=9Hn lvl=INFO cat=transcript evt=llm_final text="Here are email lists to Princeton. A day later, it kind of has some sort of variety and kind of blew up within that student community."
📊 [DETAILED STREAMING TIMING] Streaming: 636.7ms | Context: 0.0ms | LLM: 4507.6ms | Tracked Overhead: 0.0ms | Unaccounted: 1.3ms | Total: 5145.7ms
🔊 [SoundManager] Attempting to play stop sound
🔊 [SoundManager] NSSound stop sound result: true
🧹 Connection cleanup completed (session resources released)
📝 [GRACE] Recording session ended
📱 Dismissing recorder
📊 [ENHANCEMENT] Tracking 26 words - currentTier: pro, trialWordsRemaining: 2552
✅ Streaming transcription processing completed
t=3014373 sess=9Hn lvl=INFO cat=transcript evt=insert_attempt text="Here are email lists to Princeton. A day later, it kind of has some sort of variety and kind of blew up within that student community. " target="Google Chrome" chars=135
🔍 [PASTE DEBUG] AXIsProcessTrusted() returned true, proceeding
🔍 [PASTE DEBUG] UseDirectTextInsertion setting: false
🔍 [PASTE DEBUG] Direct insertion disabled, using clipboard paste
⌨️ Using CGEvent-based Command+V
t=3014376 sess=9Hn lvl=INFO cat=transcript evt=insert_result ok=true
📊 [POST-RELEASE E2E] 5299ms (finalize=559ms | llm=4507ms | paste=0ms) | warm_socket=no
🧭 [APP] applicationShouldHandleReopen called - hasVisibleWindows: true
🧭 [APP] ActivationPolicy=.regular (IsMenuBarOnly=false)
🧭 [APP] applicationDidBecomeActive
🧭 [APP] ActivationPolicy=.regular (IsMenuBarOnly=false)
🪟 [DOCK] Found existing window, activating it
🔄 [SYNC_STATE] syncTrialState called - currentTier: pro, isInTrial: false
🔄 [SYNC_STATE] Final state after syncTrialState - currentTier: pro, isInTrial: false
deferral block timed out after 500ms
deferral block timed out after 500ms
💤 [STANDBY] keepalive_tick
t=3020970 sess=9Hn lvl=INFO cat=stream evt=standby_keepalive_tick
📱 Showing DynamicNotch recorder (MIT licensed)
🧊 [WARMUP] Skipping (recently run) context=recorderUIShown
🎤 [toggleRecord] Starting recording, current model: soniox-realtime-streaming
🧊 [WARMUP] Skipping (recently run) context=hotkeyDown
🎙️ Starting recording sequence...
📝 [GRACE] Recording session started with 2552 words remaining
🔧 [NER-SETUP] Setting up callback - contextService exists: true
✅ [NER-SETUP] OCR completion callback configured for NER pre-warming - callback exists: true
📊 [SESSION] Starting recording session #10
🧪 [A/B] warm_socket=yes
🧊➡️🔥 [STANDBY->ACTIVE] Consuming standby socket for new utterance
⏭️ [STANDBY->ACTIVE] START already sent on standby (eager) — skipping re-send
🔄 [CACHE] Context changed - invalidating cache
🔄 [CACHE]   Old: com.apple.dt.Xcode|Clio — SonioxStreamingService.swift
🔄 [CACHE]   New: com.google.Chrome|(17) A Yale Student Raised $3.1M in 2 Weeks for an AI Social App | Series, Nathaneo Johnson - YouTube
🔄 [CACHE]   BundleID Match: false
🔄 [CACHE]   Title Match: false
🔄 [CACHE]   Content Hash: Old=737b9c77... New=737b9c77...
✅ [STANDBY->ACTIVE] Probe keepalive OK — proceeding to resume queue
⏹️ Keepalive timer stopped
🔄 Keepalive timer started (interval: 15.000000s)
🧪 [PROMO] snapshot attempt=11 socket=sock_1943519547568010667@attempt_11 start_sent=true ws_ready=true standby=false purpose=active cap_sr=16000 cap_ch=1 prebuf=0 last_fp=m=stt-rt-preview-v2|sr=16000|ch=1|h=en,zh|ctx=889740762234866296
t=3021351 sess=9Hn lvl=INFO cat=stream evt=temp_key_fetch_start
🎬 Starting screen capture with verified permissions
⚡ [CACHE-HIT] Retrieved temp key in 0.5ms
t=3021351 sess=9Hn lvl=INFO cat=stream evt=temp_key_fetch expires_in_s=-1 latency_ms=0 source=cached
🎯 (17) A Yale Student Raised $3.1M in 2 Weeks for an AI Social App | Series, Nathaneo Johnson - YouTube
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🧪 [PROMO] config_fp current=m=stt-rt-preview-v2|sr=16000|ch=1|h=en,zh|ctx=889740762234866296 last=m=stt-rt-preview-v2|sr=16000|ch=1|h=en,zh|ctx=889740762234866296
🎤 Registering audio tap for Soniox
t=3021352 sess=9Hn lvl=INFO cat=audio evt=record_start service=Soniox
🔍 Performing audio system pre-flight checks
🌐 Browser detected, using content-optimized capture settings
🌐 [LANG DEBUG] Multi-language setting exists: true, Single language: en
🌐 [LANG DEBUG] Using multi-language selection (prioritized): zh, en
🌐 Using selected languages for OCR: zh-Hans, en-US
🌐 Browser detected - using optimized OCR settings for webpage content
throwing -10877
throwing -10877
✅ Pre-flight checks passed
t=3021460 sess=9Hn lvl=INFO cat=audio evt=tap_install ok=true service=Soniox backend=avcapture
t=3021460 sess=9Hn lvl=INFO cat=audio evt=record_start reason=start_capture
t=3021460 sess=9Hn lvl=INFO cat=audio evt=device_pin_start prev_name="MacBook Pro Microphone" prev_uid_hash=4285059772673450742 desired_id=181 prev_id=181 desired_uid_hash=4285059772673450742 desired_name="MacBook Pro Microphone"
t=3021460 sess=9Hn lvl=INFO cat=audio evt=capture_backend_selected backend=avcapture
✅ Unified audio capture started
✅ Selected account account-bundle (connections: 1/10)
🧠 [TEN-VAD] Initialized (threshold=0.5, hop=256)
🚀 Starting Clio streaming transcription
🏥 [AUDIO HEALTH] Health monitoring timer started
⏱️ [TIMING] mic_engaged @ 1756226057.508
⏱️ [TIMING] WebSocket connect task completed — will flush after READY
pass
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
t=3021588 sess=9Hn lvl=INFO cat=audio evt=avcapture_start ok=true
t=3021589 sess=9Hn lvl=INFO cat=stream evt=first_audio_buffer_captured ms=79
🧪 [PROMO] first_audio seq=0 bytes=372 approx_db=-60.0
t=3021590 sess=9Hn lvl=INFO cat=audio evt=level peak_db=-60 avg_db=-60
✅ [AUDIO HEALTH] First audio data received - tap is functional
t=3021590 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=0 flushing=false has_socket=true ready=true bytes=372
t=3021590 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=1 flushing=false has_socket=true ready=true bytes=372
t=3021590 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=2 flushing=false has_socket=true ready=true bytes=372
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
t=3021619 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=3 flushing=false ready=true bytes=372 has_socket=true
t=3021619 sess=9Hn lvl=INFO cat=stream evt=first_audio_sent ms=109 seq=1
t=3021620 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=360 flushing=false has_socket=true ready=true seq=4
t=3021620 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=360 flushing=false has_socket=true ready=true seq=5
t=3021620 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true ready=true seq=6
t=3021620 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=7 flushing=false has_socket=true
t=3021632 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=8 has_socket=true ready=true
t=3021644 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=9 flushing=false has_socket=true bytes=372 ready=true
t=3021655 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true ready=true seq=10
t=3021667 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=11 has_socket=true ready=true
t=3021679 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=12 flushing=false bytes=372 has_socket=true
t=3021690 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 seq=13 flushing=false ready=true
t=3021702 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=14
t=3021713 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 seq=15 has_socket=true
t=3021726 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=16 has_socket=true ready=true
t=3021737 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 flushing=false seq=17
🗣️ [TEN-VAD] Speech start detected
t=3021748 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=18 has_socket=true ready=true
t=3021760 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=19 has_socket=true flushing=false
t=3021771 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 ready=true seq=20 flushing=false
t=3021784 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=21 has_socket=true bytes=372 ready=true
t=3021795 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true bytes=372 seq=22 ready=true
🛑 [TEN-VAD] Speech end detected
t=3021806 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 flushing=false seq=23
t=3021818 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 flushing=false seq=24
t=3021830 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 seq=25 flushing=false
t=3021841 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=26 flushing=false has_socket=true
🧪 [PROMO] audio_bytes bytes=10020
t=3021853 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true bytes=372 seq=27 ready=true
t=3021864 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false seq=28 ready=true
t=3021876 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 ready=true seq=29 flushing=false
t=3021888 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=30 ready=true flushing=false bytes=372
t=3021899 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=31 has_socket=true ready=true
t=3021911 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=32 flushing=false ready=true bytes=372 has_socket=true
t=3021922 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=33 ready=true flushing=false has_socket=true
t=3021934 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=34 has_socket=true bytes=372 flushing=false
t=3021946 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=35 has_socket=true ready=true flushing=false
t=3021957 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=36
t=3021969 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 seq=37 flushing=false
t=3021980 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=38 has_socket=true bytes=372 flushing=false
t=3021992 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=39 has_socket=true ready=true bytes=372 flushing=false
t=3022004 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=40
t=3022015 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=41
🌐 [PATH] Initial path baseline set — no action
t=3022027 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=42 has_socket=true ready=true
t=3022039 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=43 has_socket=true ready=true flushing=false
🔍 Found 94 text observations
✅ Text extraction successful: 1424 chars, 1424 non-whitespace, 236 words from 94 observations
t=3022051 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=44 flushing=false ready=true bytes=372 has_socket=true
✅ Captured text successfully
✅ [CAPTURE DEBUG] Screen capture successful: 1584 characters
💾 [SMART-CACHE] Cached new context: com.google.Chrome|(17) A Yale Student Raised $3.1M in 2 Weeks for an AI Social App | Series, Nathaneo Johnson - YouTube (1584 chars)
🎯 [CALLBACK DEBUG] Executing callback with fresh content (1584 chars)
🔥 [PREWARM DEBUG] Pre-warming AI connection (target: Gemini), environment: flyio
🔥 [NER-TRIGGER] OCR completion callback triggered with fresh content
🎬 [NER-PREWARM] Using raw OCR text for NER: 1584 characters
🧠 [NER-DEFAULT] Using default NER prompt for general extraction
t=3022073 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=45 flushing=false
t=3022074 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=46 flushing=false
t=3022085 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=47
t=3022097 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=48 flushing=false ready=true bytes=372 has_socket=true
t=3022109 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 seq=49 flushing=false
t=3022120 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=50 has_socket=true ready=true bytes=372 flushing=false
t=3022132 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=51
t=3022143 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=52 flushing=false ready=true bytes=372 has_socket=true
t=3022155 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=53 bytes=372
t=3022166 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=54 has_socket=true ready=true bytes=372 flushing=false
t=3022178 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=55 flushing=false ready=true bytes=372 has_socket=true
t=3022190 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=56 bytes=372 ready=true has_socket=true flushing=false
t=3022201 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=57 has_socket=true ready=true bytes=372 flushing=false
t=3022213 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=58 has_socket=true ready=true bytes=372 flushing=false
t=3022224 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=59 has_socket=true ready=true bytes=372 flushing=false
t=3022236 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=60 has_socket=true flushing=false ready=true bytes=372
t=3022247 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=61 ready=true bytes=372 has_socket=true flushing=false
t=3022260 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=62 ready=true bytes=372 has_socket=true flushing=false
t=3022271 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=63 flushing=false has_socket=true ready=true bytes=372
t=3022283 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=64 has_socket=true ready=true flushing=false bytes=372
t=3022294 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=65 bytes=372
t=3022306 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=66
t=3022319 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=67 flushing=false has_socket=true ready=true bytes=372
t=3022329 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=68 ready=true flushing=false bytes=372 has_socket=true
t=3022341 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=69
t=3022352 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=70 bytes=372 flushing=false has_socket=true ready=true
t=3022364 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=71 bytes=372 has_socket=true flushing=false
t=3022376 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=72 flushing=false has_socket=true ready=true bytes=372
t=3022387 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=73 bytes=372
t=3022399 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=74 bytes=372
t=3022412 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=75 flushing=false has_socket=true ready=true bytes=372
t=3022422 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=76
t=3022435 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=77 bytes=372
t=3022445 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=78
t=3022457 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=79 ready=true flushing=false bytes=372 has_socket=true
t=3022469 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=80 ready=true flushing=false bytes=372 has_socket=true
🧪 [PROMO] audio_bytes bytes=30108
t=3022480 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=81 ready=true has_socket=true flushing=false bytes=372
t=3022493 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=82 ready=true flushing=false bytes=372 has_socket=true
t=3022505 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=83
t=3022515 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=84 has_socket=true ready=true bytes=372 flushing=false
t=3022526 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=85 has_socket=true
t=3022538 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=86
t=3022550 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=87
t=3022561 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=88 has_socket=true ready=true flushing=false bytes=372
t=3022573 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=89 bytes=372 flushing=false has_socket=true ready=true
t=3022585 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=90 bytes=372
t=3022596 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=91 bytes=372
t=3022608 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=92 bytes=372
t=3022621 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=93 ready=true bytes=372
t=3022631 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=94 flushing=false ready=true has_socket=true
t=3022644 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=95 bytes=372 flushing=false has_socket=true ready=true
t=3022654 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=96 ready=true bytes=372
t=3022666 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=97
t=3022677 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=98 ready=true bytes=372
t=3022689 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true ready=true seq=99
t=3022702 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=100 bytes=372
t=3022713 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=101
t=3022724 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=102 bytes=372
t=3022736 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=103 bytes=372
t=3022747 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=104 bytes=372 flushing=false has_socket=true ready=true
t=3022760 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=105 ready=true bytes=372
t=3022770 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=106 bytes=372
t=3022782 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=107
t=3022794 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true ready=true seq=108
t=3022805 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=109 bytes=372
t=3022810 sess=9Hn lvl=INFO cat=stream evt=first_partial ms=1300
t=3022810 sess=9Hn lvl=INFO cat=stream evt=ttft_hotkey ms=1300
t=3022810 sess=9Hn lvl=INFO cat=stream evt=ttft ms=1073
🧪 [PROMO] first_token ms=1459 tokens_in_msg=1
t=3022818 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=110
t=3022871 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=111 ready=true flushing=false has_socket=true bytes=372
t=3022871 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=112 ready=true flushing=false has_socket=true bytes=372
t=3022871 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=113 ready=true flushing=false has_socket=true bytes=372
t=3022871 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=114 ready=true flushing=false has_socket=true bytes=372
t=3022875 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=115 bytes=372 ready=true flushing=false
t=3022886 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=116 flushing=false ready=true bytes=372 has_socket=true
t=3022898 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 seq=117 flushing=false
t=3022929 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=118 has_socket=true ready=true bytes=372 flushing=false
t=3022929 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=119 has_socket=true ready=true bytes=372 flushing=false
t=3022932 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=120 flushing=false ready=true bytes=372 has_socket=true
t=3022944 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=121 flushing=false ready=true bytes=372 has_socket=true
t=3022956 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=122 flushing=false ready=true bytes=372 has_socket=true
t=3022968 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false seq=123 bytes=372
t=3022979 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=124 flushing=false
t=3022991 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=125 has_socket=true ready=true flushing=false
t=3023002 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=126 flushing=false ready=true bytes=372 has_socket=true
t=3023014 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=127 flushing=false ready=true bytes=372 has_socket=true
t=3023026 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=128 bytes=372 ready=true
t=3023062 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=129 has_socket=true flushing=false bytes=372 ready=true
t=3023062 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=130 has_socket=true flushing=false bytes=372 ready=true
t=3023062 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=131 has_socket=true flushing=false bytes=372 ready=true
t=3023072 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=132 ready=true flushing=false
t=3023084 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=133 flushing=false has_socket=true bytes=372 ready=true
t=3023095 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=134 ready=true flushing=false
t=3023107 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false seq=135 has_socket=true
t=3023119 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false ready=true seq=136
t=3023130 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=137 ready=true flushing=false
t=3023142 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=138 ready=true flushing=false
t=3023153 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=139 has_socket=true ready=true bytes=372 flushing=false
t=3023165 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=140 has_socket=true ready=true bytes=372 flushing=false
t=3023176 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=141 ready=true flushing=false bytes=372 has_socket=true
t=3023188 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=142 ready=true flushing=false bytes=372 has_socket=true
t=3023200 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=143 bytes=372 flushing=false has_socket=true ready=true
t=3023251 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=144 has_socket=true bytes=372 ready=true
t=3023251 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=145 has_socket=true bytes=372 ready=true
t=3023251 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=146 has_socket=true bytes=372 ready=true
t=3023251 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=147 has_socket=true bytes=372 ready=true
t=3023258 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true bytes=372 seq=148 ready=true
t=3023269 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=149 has_socket=true ready=true
t=3023281 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 seq=150 flushing=false
t=3023293 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=151 has_socket=true ready=true
t=3023304 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=152 has_socket=true bytes=372 ready=true
t=3023316 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 ready=true seq=153 flushing=false
t=3023327 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=154 ready=true bytes=372 flushing=false has_socket=true
t=3023339 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=155 has_socket=true ready=true
t=3023351 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=156 ready=true flushing=false bytes=372 has_socket=true
t=3023362 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=157
t=3023374 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true has_socket=true flushing=false seq=158
t=3023386 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true seq=159 flushing=false
t=3023397 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=160 has_socket=true bytes=372
t=3023410 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=161 bytes=372 ready=true
t=3023468 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 seq=162 flushing=false ready=true
t=3023468 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 seq=163 flushing=false ready=true
t=3023468 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 seq=164 flushing=false ready=true
t=3023468 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 seq=165 flushing=false ready=true
t=3023468 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 seq=166 flushing=false ready=true
t=3023478 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false has_socket=true seq=167
t=3023490 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=168 flushing=false has_socket=true
t=3023501 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false ready=true seq=169
t=3023513 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false ready=true seq=170
t=3023525 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=171 has_socket=true ready=true bytes=372 flushing=false
t=3023536 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=172 flushing=false ready=true bytes=372 has_socket=true
t=3023548 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=173 has_socket=true ready=true bytes=372 flushing=false
t=3023560 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=174
t=3023571 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 has_socket=true seq=175
t=3023583 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=176 has_socket=true ready=true bytes=372 flushing=false
t=3023595 sess=9Hn lvl=INFO cat=audio evt=level peak_db=-44 avg_db=-44
t=3023595 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=177 has_socket=true ready=true bytes=372 flushing=false
t=3023607 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=178 bytes=372
t=3023618 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 has_socket=true seq=179
t=3023630 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=180 has_socket=true ready=true bytes=372 flushing=false
t=3023641 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 has_socket=true seq=181
t=3023652 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=182 has_socket=true flushing=false ready=true
t=3023664 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=183 bytes=372
t=3023677 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=184 bytes=372
t=3023688 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 flushing=false seq=185
t=3023700 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=186 has_socket=true ready=true bytes=372 flushing=false
t=3023711 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 has_socket=true seq=187
t=3023723 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=188 bytes=372 ready=true
t=3023734 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=189 has_socket=true ready=true bytes=372 flushing=false
t=3023746 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 has_socket=true seq=190
t=3023757 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=191 has_socket=true ready=true bytes=372 flushing=false
t=3023833 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false has_socket=true seq=192
t=3023833 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false has_socket=true seq=193
t=3023833 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false has_socket=true seq=194
t=3023833 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false has_socket=true seq=195
t=3023833 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false has_socket=true seq=196
t=3023833 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false has_socket=true seq=197
t=3023838 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=198
t=3023850 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=199 has_socket=true ready=true
t=3023861 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=200 has_socket=true ready=true bytes=372 flushing=false
t=3023873 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false ready=true seq=201
t=3023884 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=202 has_socket=true ready=true
t=3023896 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=203 has_socket=true ready=true
t=3023908 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=204 ready=true flushing=false has_socket=true bytes=372
t=3023919 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false seq=205 has_socket=true
t=3023931 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 seq=206 flushing=false
t=3023943 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 seq=207 ready=true flushing=false
t=3023954 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=208 ready=true has_socket=true
t=3023966 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 seq=209 flushing=false
t=3023978 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=210 ready=true flushing=false bytes=372
t=3024043 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=211 bytes=372
t=3024043 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=212 bytes=372
t=3024043 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=213 bytes=372
t=3024043 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=214 bytes=372
t=3024043 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=215 bytes=372
t=3024047 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=216 has_socket=true ready=true bytes=372 flushing=false
t=3024059 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=217 has_socket=true ready=true
t=3024070 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=218
t=3024082 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=219 has_socket=true ready=true bytes=372 flushing=false
t=3024094 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=220
t=3024105 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=221 has_socket=true ready=true
t=3024117 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=222 has_socket=true ready=true bytes=372 flushing=false
throwing -10877
throwing -10877
t=3024190 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=223 has_socket=true ready=true bytes=372 flushing=false
t=3024190 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=224 has_socket=true ready=true bytes=372 flushing=false
t=3024191 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=225 has_socket=true ready=true bytes=372 flushing=false
t=3024191 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=226 has_socket=true ready=true bytes=372 flushing=false
t=3024191 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=227 has_socket=true ready=true bytes=372 flushing=false
t=3024191 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=228 has_socket=true ready=true bytes=372 flushing=false
t=3024221 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=229 has_socket=true ready=true
t=3024221 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=230 has_socket=true ready=true
t=3024221 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=231 has_socket=true ready=true
t=3024249 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false seq=232 has_socket=true
t=3024249 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false seq=233 has_socket=true
t=3024256 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=234 has_socket=true ready=true
t=3024268 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=235 has_socket=true ready=true
t=3024279 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=236 flushing=false ready=true bytes=372 has_socket=true
t=3024291 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=237 ready=true flushing=false has_socket=true bytes=372
t=3024302 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=238 has_socket=true ready=true bytes=372 flushing=false
🤖 [FLY.IO-NER] Server-reported provider: gemini
📥 [NER-STORE] Stored NER entities: 1277 chars - This looks like a YouTube video about a Yale student who raised $3.1 million for an AI social app.

...
✅ [FLY.IO] NER refresh completed successfully
t=3024314 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=239 flushing=false bytes=372 ready=true has_socket=true
t=3024326 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=240 has_socket=true ready=true
t=3024337 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=241 has_socket=true ready=true bytes=372 flushing=false
t=3024349 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=242 has_socket=true ready=true bytes=372 flushing=false
t=3024360 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=243 has_socket=true ready=true bytes=372 flushing=false
t=3024402 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=244 has_socket=true flushing=false ready=true bytes=372
t=3024402 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=245 has_socket=true flushing=false ready=true bytes=372
t=3024402 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=246 has_socket=true flushing=false ready=true bytes=372
t=3024407 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=247 has_socket=true ready=true flushing=false bytes=372
t=3024419 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=248 has_socket=true ready=true flushing=false bytes=372
t=3024430 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=249 ready=true flushing=false has_socket=true bytes=372
t=3024442 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=250
t=3024454 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=251 has_socket=true ready=true flushing=false bytes=372
t=3024465 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=252 flushing=false has_socket=true ready=true
t=3024477 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=253 has_socket=true ready=true
t=3024489 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=254 bytes=372 has_socket=true
t=3024500 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=255
t=3024512 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=256 ready=true flushing=false has_socket=true bytes=372
t=3024523 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=257
t=3024572 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false ready=true seq=258
t=3024572 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false ready=true seq=259
t=3024572 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false ready=true seq=260
t=3024572 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false ready=true seq=261
t=3024581 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=262 has_socket=true ready=true bytes=372 flushing=false
t=3024593 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false ready=true seq=263
t=3024604 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true ready=true bytes=372 seq=264
t=3024616 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true ready=true bytes=372 seq=265
t=3024628 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false ready=true seq=266
t=3024639 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false ready=true seq=267
t=3024651 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=268 bytes=372 ready=true
t=3024662 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false ready=true seq=269
t=3024674 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false ready=true seq=270
t=3024686 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=271 ready=true flushing=false bytes=372 has_socket=true
t=3024698 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=272
t=3024710 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=273 bytes=372 ready=true
t=3024721 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 has_socket=true seq=274
t=3024733 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=275 bytes=372
t=3024797 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 seq=276 flushing=false
t=3024797 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 seq=277 flushing=false
t=3024797 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 seq=278 flushing=false
t=3024797 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 seq=279 flushing=false
t=3024797 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 seq=280 flushing=false
t=3024802 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false seq=281 has_socket=true
t=3024813 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=282 has_socket=true flushing=false ready=true bytes=372
t=3024825 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false seq=283 has_socket=true
t=3024837 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=284 has_socket=true flushing=false
t=3024849 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=285 has_socket=true flushing=false
t=3024860 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=286 has_socket=true flushing=false ready=true bytes=372
t=3024871 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=287 ready=true flushing=false has_socket=true bytes=372
t=3024883 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=288 flushing=false ready=true bytes=372 has_socket=true
t=3024895 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=289 has_socket=true flushing=false ready=true bytes=372
t=3024908 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false seq=290 bytes=372
t=3024919 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=291 ready=true has_socket=true bytes=372
t=3024930 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=292 ready=true has_socket=true bytes=372
t=3024942 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=293
t=3024954 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false ready=true seq=294 has_socket=true
t=3024965 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false ready=true seq=295 has_socket=true
t=3024978 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=296 bytes=372 ready=true
t=3024989 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=297 bytes=372
t=3025000 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=298
t=3025012 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=299
t=3025023 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=300 has_socket=true ready=true bytes=372 flushing=false
t=3025035 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false ready=true seq=301 has_socket=true
t=3025047 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=302
t=3025058 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true seq=303 bytes=372
t=3025070 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false seq=304 bytes=372
t=3025081 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=305 bytes=372
t=3025093 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false ready=true seq=306 has_socket=true
t=3025105 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=307 bytes=372 ready=true
t=3025116 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=308 bytes=372
t=3025128 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=309 bytes=372
t=3025207 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=310 ready=true has_socket=true flushing=false
t=3025207 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=311 ready=true has_socket=true flushing=false
t=3025207 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=312 ready=true has_socket=true flushing=false
t=3025208 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=313 ready=true has_socket=true flushing=false
t=3025208 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=314 ready=true has_socket=true flushing=false
t=3025208 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=315 ready=true has_socket=true flushing=false
t=3025208 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 seq=316 ready=true flushing=false
t=3025247 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=317 has_socket=true ready=true bytes=372 flushing=false
t=3025248 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=318 has_socket=true ready=true bytes=372 flushing=false
t=3025248 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=319 has_socket=true ready=true bytes=372 flushing=false
t=3025254 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false seq=320 has_socket=true
t=3025266 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=321 has_socket=true ready=true bytes=372 flushing=false
t=3025278 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=322 has_socket=true ready=true bytes=372 flushing=false
t=3025289 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=323 has_socket=true ready=true bytes=372 flushing=false
t=3025301 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=324 has_socket=true ready=true
t=3025313 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=325 has_socket=true ready=true bytes=372 flushing=false
t=3025324 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=326 has_socket=true ready=true
t=3025336 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=327 flushing=false bytes=372 has_socket=true
t=3025347 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=328 ready=true flushing=false has_socket=true bytes=372
t=3025359 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=329 flushing=false bytes=372 has_socket=true
t=3025371 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=330 has_socket=true ready=true bytes=372 flushing=false
t=3025382 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=331 ready=true flushing=false has_socket=true bytes=372
t=3025394 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=332 flushing=false has_socket=true ready=true
t=3025406 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=333 flushing=false bytes=372 has_socket=true
t=3025417 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=334 has_socket=true ready=true bytes=372 flushing=false
t=3025429 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=335
t=3025441 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=336 flushing=false has_socket=true ready=true bytes=372
t=3025452 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=337 bytes=372
t=3025464 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=338 flushing=false has_socket=true ready=true bytes=372
t=3025476 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=339 bytes=372 ready=true
t=3025487 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=340 bytes=372 flushing=false has_socket=true ready=true
t=3025500 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=341 bytes=372 flushing=false has_socket=true ready=true
t=3025511 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=342
t=3025523 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=343
t=3025534 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=344 bytes=372 flushing=false has_socket=true ready=true
t=3025545 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=345 ready=true
t=3025557 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=346
t=3025568 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=347 ready=true
t=3025580 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=348 flushing=false has_socket=true ready=true bytes=372
t=3025646 sess=9Hn lvl=INFO cat=audio evt=level avg_db=-38 peak_db=-38
t=3025647 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=349 flushing=false bytes=372
t=3025647 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=350 flushing=false bytes=372
t=3025647 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=351 flushing=false bytes=372
t=3025647 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=352 flushing=false bytes=372
t=3025647 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=353 flushing=false bytes=372
t=3025649 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=354 flushing=false ready=true bytes=372 has_socket=true
t=3025661 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=355
t=3025673 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=356 has_socket=true flushing=false ready=true bytes=372
t=3025684 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=357 flushing=false has_socket=true
t=3025696 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=358 flushing=false has_socket=true bytes=372 ready=true
t=3025736 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=359 has_socket=true ready=true
t=3025736 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=360 has_socket=true ready=true
t=3025736 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=361 has_socket=true ready=true
t=3025743 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=362 has_socket=true ready=true
t=3025754 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=363 flushing=false has_socket=true bytes=372 ready=true
t=3025766 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=364
t=3025777 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=365 has_socket=true ready=true
t=3025789 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=366 has_socket=true ready=true flushing=false bytes=372
t=3025800 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=367 ready=true flushing=false has_socket=true bytes=372
t=3025845 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=368 bytes=372
t=3025845 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=369 bytes=372
t=3025845 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=370 bytes=372
t=3025847 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=371 ready=true flushing=false has_socket=true
t=3025858 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 ready=true flushing=false seq=372
t=3025870 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true has_socket=true seq=373
t=3025881 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true has_socket=true seq=374
t=3025893 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 ready=true flushing=false seq=375
t=3025905 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=376
t=3025916 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 ready=true flushing=false seq=377
t=3025928 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true has_socket=true seq=378
t=3025940 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=379
t=3025940 sess=9Hn lvl=INFO cat=stream evt=first_final ms=4430
t=3025940 sess=9Hn lvl=INFO cat=transcript evt=raw_final text="Startup ide"
t=3025951 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=380 has_socket=true flushing=false ready=true bytes=372
t=3025995 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=381
t=3025995 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=382
t=3025995 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=383
t=3025997 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=384 ready=true
t=3026010 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=385
t=3026021 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=386 has_socket=true ready=true bytes=372 flushing=false
t=3026033 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false seq=387 has_socket=true
t=3026044 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=388 has_socket=true bytes=372
t=3026056 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=389 has_socket=true bytes=372
t=3026067 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=390 has_socket=true ready=true bytes=372 flushing=false
t=3026079 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=391 has_socket=true bytes=372
t=3026091 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=392 has_socket=true ready=true
t=3026102 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=393 ready=true
t=3026115 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=394 bytes=372
t=3026126 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=395 has_socket=true ready=true flushing=false
t=3026138 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=396 bytes=372
t=3026149 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=397 ready=true flushing=false bytes=372 has_socket=true
t=3026161 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=398 bytes=372 has_socket=true flushing=false
t=3026172 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=399 bytes=372 flushing=false has_socket=true ready=true
t=3026245 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=400 flushing=false bytes=372 ready=true
t=3026245 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=401 flushing=false bytes=372 ready=true
t=3026245 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=402 flushing=false bytes=372 ready=true
t=3026245 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=403 flushing=false bytes=372 ready=true
t=3026245 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=404 flushing=false bytes=372 ready=true
t=3026245 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=405 flushing=false bytes=372 ready=true
t=3026253 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=406 bytes=372 has_socket=true
t=3026265 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 flushing=false seq=407
t=3026276 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=408 ready=true flushing=false has_socket=true bytes=372
t=3026288 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=409 has_socket=true ready=true bytes=372 flushing=false
t=3026300 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true ready=true seq=410
t=3026311 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=411
t=3026323 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=412 ready=true flushing=false has_socket=true bytes=372
t=3026334 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=413 has_socket=true ready=true bytes=372 flushing=false
t=3026346 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=414 has_socket=true flushing=false ready=true bytes=372
t=3026358 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=415 has_socket=true
t=3026370 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=416 bytes=372
t=3026381 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=417 bytes=372 has_socket=true flushing=false
t=3026393 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=418
t=3026405 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=419 bytes=372
t=3026416 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=420 bytes=372 has_socket=true flushing=false
t=3026428 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=421 bytes=372
t=3026495 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=422 ready=true
t=3026495 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=423 ready=true
t=3026495 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=424 ready=true
t=3026496 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=425 ready=true
t=3026496 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=426 ready=true
t=3026497 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=427 ready=true
t=3026509 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=428 has_socket=true flushing=false ready=true bytes=372
t=3026520 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true seq=429 bytes=372
t=3026532 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=430 ready=true flushing=false has_socket=true bytes=372
t=3026544 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=431
t=3026555 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false ready=true seq=432
t=3026566 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=433 has_socket=true ready=true flushing=false
t=3026578 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false ready=true seq=434
t=3026590 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=435
t=3026603 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=436 flushing=false has_socket=true bytes=372 ready=true
t=3026614 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 ready=true seq=437
t=3026625 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 ready=true seq=438
t=3026636 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=439
t=3026648 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=440
t=3026713 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false seq=441 has_socket=true
t=3026713 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false seq=442 has_socket=true
t=3026714 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false seq=443 has_socket=true
t=3026714 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false seq=444 has_socket=true
t=3026714 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false seq=445 has_socket=true
t=3026717 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 seq=446 flushing=false
t=3026729 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false seq=447 has_socket=true
t=3026741 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=448 ready=true has_socket=true flushing=false bytes=372
t=3026752 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 seq=449 flushing=false
t=3026764 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false has_socket=true seq=450
t=3026776 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=451 has_socket=true ready=true bytes=372 flushing=false
t=3026787 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=452 has_socket=true ready=true bytes=372 flushing=false
t=3026799 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=453 flushing=false bytes=372 ready=true has_socket=true
t=3026811 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=454 bytes=372
t=3026823 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 seq=455 has_socket=true
t=3026834 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 seq=456 has_socket=true
t=3026845 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 seq=457 has_socket=true
t=3026911 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=458 has_socket=true ready=true
t=3026911 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=459 has_socket=true ready=true
t=3026911 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=460 has_socket=true ready=true
t=3026911 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=461 has_socket=true ready=true
t=3026911 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=462 has_socket=true ready=true
t=3026915 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false seq=463 has_socket=true
t=3026926 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false seq=464 has_socket=true
t=3026938 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=465
t=3026950 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=466 flushing=false ready=true bytes=372 has_socket=true
t=3026961 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=467 has_socket=true ready=true
t=3026973 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false ready=true seq=468
t=3026985 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=469
t=3026996 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=470 ready=true flushing=false has_socket=true bytes=372
t=3027008 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=471 ready=true flushing=false has_socket=true bytes=372
t=3027021 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true seq=472 flushing=false bytes=372
t=3027033 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=473 ready=true flushing=false has_socket=true bytes=372
t=3027096 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false seq=474 has_socket=true
t=3027096 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=475
t=3027096 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=476
t=3027096 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=477
t=3027096 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=478
t=3027101 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=479
t=3027112 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=480 has_socket=true ready=true bytes=372 flushing=false
t=3027124 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false seq=481 has_socket=true
t=3027135 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=482 has_socket=true ready=true flushing=false
t=3027147 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=483 ready=true has_socket=true flushing=false bytes=372
t=3027192 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false ready=true seq=484 has_socket=true
t=3027192 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false ready=true seq=485 has_socket=true
t=3027192 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false ready=true seq=486 has_socket=true
t=3027193 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=487 ready=true flushing=false bytes=372
t=3027205 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=488 ready=true flushing=false bytes=372
t=3027217 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=489 has_socket=true bytes=372 flushing=false
t=3027228 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true has_socket=true seq=490
t=3027237 sess=9Hn lvl=INFO cat=transcript evt=raw_final text="as are a gallery of ide"
t=3027240 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=491 has_socket=true bytes=372 flushing=false
t=3027283 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=492 has_socket=true ready=true
t=3027283 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=493 has_socket=true ready=true
t=3027283 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=494 has_socket=true ready=true
🛑 [TEN-VAD] Speech end detected
t=3027286 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=495
t=3027298 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=496
t=3027309 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false ready=true seq=497 has_socket=true
t=3027321 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=498 has_socket=true ready=true
t=3027333 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=499 flushing=false ready=true bytes=372 has_socket=true
t=3027345 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=500 ready=true flushing=false bytes=372 has_socket=true
t=3027356 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false ready=true seq=501
t=3027367 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true seq=502 flushing=false bytes=372
t=3027379 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=503 bytes=372
t=3027391 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false ready=true seq=504
t=3027402 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true seq=505 flushing=false bytes=372
t=3027414 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false ready=true seq=506
t=3027426 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false ready=true seq=507
t=3027440 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=508 bytes=372 flushing=false has_socket=true ready=true
t=3027450 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=509
t=3027461 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=510 bytes=372 has_socket=true flushing=false
t=3027472 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=511
t=3027485 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=512 bytes=372
t=3027496 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=513 bytes=372
t=3027508 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=514 ready=true flushing=false bytes=372 has_socket=true
t=3027519 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=515 ready=true flushing=false bytes=372 has_socket=true
t=3027531 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=516 bytes=372 flushing=false has_socket=true ready=true
t=3027542 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=517
t=3027555 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=518 ready=true flushing=false bytes=372 has_socket=true
t=3027565 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=519
t=3027577 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true ready=true seq=520
t=3027588 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=521 bytes=372 has_socket=true flushing=false
t=3027600 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 seq=522 ready=true
t=3027612 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=523 ready=true flushing=false bytes=372 has_socket=true
t=3027624 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=524 ready=true flushing=false bytes=372 has_socket=true
t=3027635 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 has_socket=true seq=525
t=3027647 sess=9Hn lvl=INFO cat=audio evt=level avg_db=-36 peak_db=-36
t=3027647 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=526 bytes=372 has_socket=true flushing=false
t=3027658 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=527 bytes=372 flushing=false has_socket=true ready=true
t=3027670 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=528
t=3027682 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=529
t=3027693 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=530 bytes=372 ready=true
t=3027705 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=531 bytes=372 has_socket=true flushing=false
t=3027717 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=532 bytes=372
t=3027728 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=533 bytes=372 ready=true
t=3027740 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=534 bytes=372 flushing=false has_socket=true ready=true
t=3027751 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=535 bytes=372
t=3027763 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=536 bytes=372 flushing=false has_socket=true ready=true
t=3027775 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=537 bytes=372 flushing=false has_socket=true ready=true
t=3027787 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=538 bytes=372 flushing=false has_socket=true ready=true
t=3027856 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=539 ready=true
t=3027856 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=540 ready=true
t=3027856 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=541 ready=true
t=3027856 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=542 ready=true
t=3027856 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=543 ready=true
t=3027856 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=544 ready=true
t=3027867 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=545 flushing=false has_socket=true ready=true bytes=372
t=3027878 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=546 has_socket=true ready=true
t=3027890 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=547 has_socket=true
t=3027902 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=548 has_socket=true ready=true bytes=372 flushing=false
t=3027945 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=549
t=3027945 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=550
t=3027945 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=551
t=3027948 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false seq=552 has_socket=true
t=3027984 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 seq=553 has_socket=true
t=3027984 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 seq=554 has_socket=true
t=3027984 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 seq=555 has_socket=true
t=3027994 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=556 flushing=false ready=true bytes=372 has_socket=true
t=3028006 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=557 ready=true flushing=false has_socket=true bytes=372
t=3028018 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true has_socket=true seq=558
t=3028029 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true has_socket=true seq=559
t=3028041 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=560
t=3028052 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=561 has_socket=true ready=true
t=3028064 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 seq=562 has_socket=true
t=3028076 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=563 ready=true has_socket=true
t=3028087 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=564 ready=true has_socket=true
t=3028099 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false ready=true seq=565
t=3028111 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=566 ready=true has_socket=true
t=3028122 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false ready=true seq=567
t=3028134 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=568 flushing=false bytes=372 has_socket=true
t=3028145 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=569 has_socket=true flushing=false
t=3028157 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false seq=570 has_socket=true
t=3028169 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false seq=571 has_socket=true
t=3028181 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=572 ready=true flushing=false bytes=372 has_socket=true
t=3028192 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=573 bytes=372
t=3028204 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=574 bytes=372 has_socket=true flushing=false
t=3028216 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=575 ready=true flushing=false bytes=372 has_socket=true
t=3028286 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true seq=576 bytes=372 flushing=false
t=3028286 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true seq=577 bytes=372 flushing=false
t=3028286 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true seq=578 bytes=372 flushing=false
t=3028286 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true seq=579 bytes=372 flushing=false
t=3028286 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true seq=580 bytes=372 flushing=false
t=3028286 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true seq=581 bytes=372 flushing=false
t=3028296 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=582 ready=true flushing=false has_socket=true bytes=372
t=3028308 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 seq=583 flushing=false
t=3028320 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 seq=584 flushing=false
t=3028353 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=585 has_socket=true ready=true bytes=372 flushing=false
t=3028354 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=586 has_socket=true ready=true bytes=372 flushing=false
t=3028354 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false ready=true seq=587
t=3028366 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=588 bytes=372
t=3028378 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=589 has_socket=true ready=true bytes=372 flushing=false
t=3028389 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false ready=true seq=590
t=3028401 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=591 has_socket=true ready=true
t=3028412 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=592 flushing=false
t=3028424 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false ready=true seq=593
t=3028436 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=594
t=3028447 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=595 bytes=372 has_socket=true
t=3028459 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=596 bytes=372 has_socket=true
t=3028471 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=597 bytes=372 has_socket=true
t=3028482 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=598 has_socket=true flushing=false ready=true bytes=372
t=3028494 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=599 has_socket=true ready=true bytes=372 flushing=false
t=3028506 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=600 bytes=372
t=3028517 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=601 flushing=false has_socket=true ready=true bytes=372
t=3028529 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=602 ready=true has_socket=true
t=3028540 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=603 flushing=false has_socket=true ready=true bytes=372
t=3028552 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=604 bytes=372 has_socket=true flushing=false
t=3028564 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=605 has_socket=true ready=true flushing=false bytes=372
t=3028577 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=606 bytes=372
t=3028587 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=607 ready=true flushing=false bytes=372 has_socket=true
t=3028599 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=608 bytes=372 ready=true
t=3028605 sess=9Hn lvl=INFO cat=transcript evt=raw_final text="as, kind of as specific"
t=3028611 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=609 bytes=372 ready=true
t=3028671 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=610 bytes=372 flushing=false has_socket=true ready=true
t=3028671 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=611 bytes=372 flushing=false has_socket=true ready=true
t=3028671 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=612 bytes=372 flushing=false has_socket=true ready=true
t=3028671 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=613 bytes=372 flushing=false has_socket=true ready=true
t=3028671 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=614 bytes=372 flushing=false has_socket=true ready=true
t=3028680 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=615 has_socket=true ready=true
t=3028723 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=616
t=3028723 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=617
t=3028723 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=618
t=3028726 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false ready=true seq=619
t=3028738 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=620 has_socket=true ready=true bytes=372 flushing=false
t=3028749 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=621 ready=true flushing=false has_socket=true bytes=372
t=3028761 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false ready=true seq=622
t=3028772 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false has_socket=true seq=623
t=3028784 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=624 flushing=false ready=true bytes=372 has_socket=true
t=3028796 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=625 bytes=372 has_socket=true flushing=false
t=3028807 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=626 has_socket=true flushing=false
t=3028819 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=627 has_socket=true ready=true bytes=372 flushing=false
t=3028831 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=628 bytes=372 has_socket=true flushing=false
t=3028842 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=629 bytes=372 has_socket=true flushing=false
t=3028854 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=630 has_socket=true flushing=false
t=3028866 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=631 ready=true
t=3028878 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=632 ready=true
t=3028889 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=633 ready=true flushing=false has_socket=true bytes=372
t=3028901 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=634 ready=true flushing=false bytes=372 has_socket=true
t=3028912 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=635 ready=true
t=3028970 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false seq=636 has_socket=true
t=3028970 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false seq=637 has_socket=true
t=3028971 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false seq=638 has_socket=true
t=3028971 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false seq=639 has_socket=true
t=3028971 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 ready=true flushing=false seq=640
t=3028981 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=641 flushing=false bytes=372 ready=true has_socket=true
t=3028993 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false seq=642 has_socket=true
t=3029004 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false seq=643 has_socket=true
t=3029016 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=644 has_socket=true ready=true
t=3029028 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=645 has_socket=true ready=true
t=3029039 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=646
t=3029051 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=647 ready=true flushing=false has_socket=true bytes=372
t=3029063 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false seq=648 has_socket=true
t=3029075 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=649 ready=true has_socket=true bytes=372
t=3029087 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=650 has_socket=true
t=3029098 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=651 flushing=false ready=true
t=3029109 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=652 bytes=372 has_socket=true flushing=false
AudioHardware-mac-imp.cpp:1224   AudioObjectRemovePropertyListener: no object with given ID 0
AudioHardware-mac-imp.cpp:1224   AudioObjectRemovePropertyListener: no object with given ID 0
throwing -10877
throwing -10877
t=3029200 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true ready=true seq=653
t=3029201 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true ready=true seq=654
t=3029201 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true ready=true seq=655
t=3029201 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true ready=true seq=656
t=3029201 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true ready=true seq=657
t=3029201 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true ready=true seq=658
t=3029201 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true ready=true seq=659
t=3029202 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=660 ready=true flushing=false bytes=372 has_socket=true
t=3029236 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=661 has_socket=true ready=true
t=3029236 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=662 has_socket=true ready=true
t=3029237 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false seq=663 has_socket=true
t=3029248 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=664 has_socket=true ready=true
t=3029260 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=665 bytes=372
t=3029272 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true has_socket=true seq=666
t=3029284 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=667 flushing=false ready=true bytes=372 has_socket=true
t=3029295 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=668 flushing=false ready=true bytes=372 has_socket=true
t=3029306 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true has_socket=true seq=669
t=3029345 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=670 flushing=false ready=true bytes=372
t=3029345 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=671 flushing=false ready=true bytes=372
t=3029345 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=672 flushing=false ready=true bytes=372
t=3029353 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=673 has_socket=true ready=true
t=3029364 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false ready=true seq=674 has_socket=true
t=3029376 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=675 has_socket=true ready=true flushing=false
t=3029388 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=676 has_socket=true ready=true flushing=false
t=3029400 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=677 ready=true flushing=false has_socket=true bytes=372
t=3029438 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=678 has_socket=true flushing=false ready=true bytes=372
t=3029438 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=679 has_socket=true flushing=false ready=true bytes=372
t=3029438 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=680 has_socket=true flushing=false ready=true bytes=372
t=3029446 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false seq=681 has_socket=true
t=3029457 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false seq=682 has_socket=true
t=3029469 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=683 flushing=false ready=true bytes=372 has_socket=true
t=3029481 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=684 flushing=false ready=true bytes=372 has_socket=true
t=3029492 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=685 ready=true has_socket=true flushing=false bytes=372
t=3029504 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=686 ready=true has_socket=true flushing=false bytes=372
t=3029515 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=687 flushing=false ready=true bytes=372 has_socket=true
t=3029527 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=688 has_socket=true ready=true bytes=372 flushing=false
t=3029539 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=689 has_socket=true ready=true bytes=372 flushing=false
t=3029550 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=690 ready=true has_socket=true flushing=false bytes=372
🛑 [TEN-VAD] Speech end detected
t=3029562 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=691 has_socket=true ready=true bytes=372 flushing=false
t=3029573 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=692 ready=true has_socket=true flushing=false bytes=372
t=3029586 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false seq=693 has_socket=true
t=3029597 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=694 has_socket=true ready=true bytes=372 flushing=false
t=3029609 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=695 bytes=372
t=3029620 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=696 bytes=372
t=3029632 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=697 has_socket=true
t=3029644 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=698 bytes=372
t=3029655 sess=9Hn lvl=INFO cat=audio evt=level avg_db=-50 peak_db=-50
t=3029656 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=699 bytes=372 has_socket=true flushing=false
t=3029667 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=700 bytes=372
t=3029679 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=701 bytes=372 has_socket=true flushing=false
t=3029746 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=702 ready=true flushing=false
t=3029746 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=703 ready=true flushing=false
t=3029746 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=704 ready=true flushing=false
t=3029746 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=705 ready=true flushing=false
t=3029746 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=706 ready=true flushing=false
t=3029747 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false ready=true seq=707
t=3029760 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=708 has_socket=true ready=true bytes=372 flushing=false
t=3029771 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=709 bytes=372
t=3029783 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false ready=true seq=710
t=3029794 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false ready=true seq=711
t=3029806 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=712 has_socket=true ready=true flushing=false bytes=372
t=3029817 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=713 flushing=false ready=true has_socket=true
t=3029867 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=714 ready=true flushing=false bytes=372 has_socket=true
t=3029867 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=715 ready=true flushing=false bytes=372 has_socket=true
t=3029867 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=716 ready=true flushing=false bytes=372 has_socket=true
t=3029867 sess=9Hn lvl=INFO cat=transcript evt=raw_final text=" a range like mainly"
t=3029868 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=717 ready=true flushing=false bytes=372 has_socket=true
t=3029902 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=718 has_socket=true ready=true bytes=372 flushing=false
t=3029902 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=719 has_socket=true ready=true bytes=372 flushing=false
t=3029902 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=720 has_socket=true ready=true bytes=372 flushing=false
t=3029910 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=721
t=3029922 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=722 has_socket=true bytes=372 flushing=false
t=3029933 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false ready=true seq=723
t=3029945 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=724 flushing=false has_socket=true bytes=372
t=3029957 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=725 has_socket=true ready=true bytes=372 flushing=false
t=3029968 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=726 has_socket=true ready=true
t=3029980 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=727 has_socket=true ready=true bytes=372 flushing=false
t=3029992 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=728 has_socket=true ready=true bytes=372
t=3030003 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=729 has_socket=true ready=true
t=3030015 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=730 has_socket=true ready=true bytes=372
t=3030026 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false ready=true seq=731
t=3030038 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false ready=true seq=732
t=3030050 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=733 has_socket=true ready=true bytes=372 flushing=false
t=3030061 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=734 has_socket=true ready=true bytes=372 flushing=false
t=3030074 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=735 flushing=false has_socket=true ready=true bytes=372
t=3030085 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=736 bytes=372 flushing=false has_socket=true ready=true
t=3030097 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=737 ready=true has_socket=true
t=3030108 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=738 bytes=372
t=3030122 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=739 bytes=372 has_socket=true flushing=false
t=3030185 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=740
t=3030185 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=741
t=3030185 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=742
t=3030185 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=743
t=3030185 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=744
t=3030189 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true seq=745 bytes=372
t=3030200 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true bytes=372 ready=true seq=746
t=3030212 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=747 has_socket=true ready=true
t=3030224 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=748 has_socket=true ready=true
t=3030262 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=749 has_socket=true ready=true flushing=false
t=3030262 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=750 has_socket=true ready=true flushing=false
t=3030262 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=751 has_socket=true ready=true flushing=false
t=3030270 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=752 ready=true has_socket=true bytes=372 flushing=false
t=3030282 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=753 has_socket=true ready=true
t=3030293 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=754
🛑 Stopping recording
🛑 Stopping Clio streaming transcription
🏥 [AUDIO HEALTH] Health monitoring timer stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
🛑 Stopping unified audio capture
t=3030348 sess=9Hn lvl=INFO cat=audio evt=record_stop
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key plugInPackage
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key CMIOType
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key numberOfDevices
t=3030357 sess=9Hn lvl=INFO cat=audio evt=avcapture_stop
✅ Unified audio capture stopped
t=3030358 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=755 has_socket=true ready=true
t=3030358 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=756 has_socket=true ready=true
t=3030386 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false ready=true seq=757 has_socket=true
t=3030386 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false ready=true seq=758 has_socket=true
📤 Sent end-of-stream signal
📤 Sent manual finalize command
🕐 Using finalization timeout: 400ms (connection took 8968ms)
ℹ️ [OPTIMISTIC] Not skipping: end=false pending=0 ms_since_last=91 tail=100 silence_ok=true tokens_quiet_ok=true partial_empty=false uncond=false
t=3030511 sess=9Hn lvl=INFO cat=transcript evt=raw_final text=" professional reasons. To realize that, this should be the future of how.<end>"
🏁 Received <fin> token - finalization complete
✅ Received <fin> token after 386ms
⏹️ Keepalive timer stopped
⚡ Audio capture already stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
📉 Released connection for account account-bundle (connections: 0)
💾 [COLD-START] Updated successful streaming timestamp
💾 [COLD-START] Updated successful streaming timestamp
✅ Streaming stopped. Final transcript (151 chars, 9.4s, with audio file): "Startup ideas are a gallery of ide as, kind of as specific a range like mainly professional reasons. To realize that, this should be the future of how."
t=3030870 sess=9Hn lvl=INFO cat=transcript evt=final text="Startup ideas are a gallery of ide as, kind of as specific a range like mainly professional reasons. To realize that, this should be the future of how."
t=3030870 sess=9Hn lvl=INFO cat=transcript evt=session_end divider="────────── session end ──────────"
🌡️ [WARM] warm_socket=yes
⏹️ Keepalive timer stopped
🔌 [WS] Disconnected (socketId=sock_1943519547568010667@attempt_11)
✅ Streaming transcription completed successfully, length: 151 characters
⚠️ WebSocket did close with code 1001 (sid=sock_1943519547568010667, attemptId=11)
⏱️ [TIMING] Subscription tracking: 1.3ms
⏱️ [TIMING] ASR word tracking: 0.1ms
🧠 Performing intelligent end-context detection for streaming
⏱️ [CONTEXT DETAIL] Cache check: 0.0ms
⚡ [SMART-OPTIMIZATION] Using smart cached screen context (1584 chars) - skipping new capture
⏱️ [STREAMING CONTEXT TIMING] Screen capture + context detection: 0.1ms
🎯 Starting dynamic context-aware AI enhancement with tracking for text (151 characters)
⚡ [FAST-PATH] Using pre-warmed context - skipping redundant detection
⚡ [PREWARMED] Using pre-warmed NER context fast-path
t=3030872 sess=9Hn lvl=WARN cat=stream evt=state state=closed code=1001
🔍 [REGISTRY] Starting context detection using new rule engine
🔍 [REGISTRY] Bundle ID: com.google.Chrome
🔍 [REGISTRY] Process name: nil
🔍 [REGISTRY] URL: nil
🔍 [REGISTRY] Window title: (17) A Yale Student Raised $3.1M in 2 Weeks for an AI Social App | Series, Nathaneo Johnson - YouTube
🔍 [REGISTRY] Content length: 1584 chars
🎯 [RULE-ENGINE] Cache hit for com.google.Chrome|||(17) A Yale Student Raised $3.1M in 2 Weeks for an AI Social App | Series, Nathaneo Johnson - YouTube
🔄 [REGISTRY] Rule engine returned .none, checking for high-confidence legacy matches only
🔄 [REGISTRY] Trying legacy Email detector (priority: 100)
📧 [EMAIL] Starting email context detection
🚫 [DYNAMIC] Email exclusion detected in content: excluding from detection
🔄 [REGISTRY] Trying legacy Code Review detector (priority: 90)
💻 [CODE] Starting code context detection
❌ [CODE] Code confidence too low: 0.000000 < 0.300000
🔄 [REGISTRY] Trying legacy Social Media detector (priority: 10)
💬 [CHAT] Starting casual chat context detection
💬 [CHAT] Casual chat context detected - Title matches: 1, Content matches: 4, Confidence: 0.280000
🚫 [REGISTRY] Legacy Social Media context rejected - rule engine returned .none and confidence not high enough (0.280000 < 0.800000)
📝 [REGISTRY] Rule engine returned .none and no high-confidence legacy matches, returning general context
📝 [PREWARMED] Non-code or unknown context → using enhanced system prompt
🚨 [PROMPT-DEBUG] About to call getSystemMessage(for: .transcriptionEnhancement)
🚨 [PROMPT-DEBUG] getSystemMessage called with mode: transcriptionEnhancement
🚨 [PROMPT-DEBUG] RETURNING TRANSCRIPTION ENHANCEMENT PROMPT
🌐 [LANG DEBUG] Multi-language setting exists: true, Single language: en
🌐 [LANG DEBUG] Using multi-language selection (prioritized): zh, en
🚨 [PROMPT-DEBUG] About to call getUserMessage(text:, mode: .transcriptionEnhancement)
🌐 [LANG DEBUG] Multi-language setting exists: true, Single language: en
🌐 [LANG DEBUG] Using multi-language selection (prioritized): zh, en
🌐 [LANG DEBUG] Multi-language setting exists: true, Single language: en
🌐 [LANG DEBUG] Using multi-language selection (prioritized): zh, en
📝 [PREWARMED-SYSTEM] Enhanced system prompt: 'You are an expert in enhancing the text provided within <TRANSCRIPT> tags according to the following guidelines: The information in <CONTEXT_INFORMATI...'
📝 [PREWARMED-USER] Enhanced user prompt: '<CONTEXT_INFORMATION>
NER Context Entities:
This looks like a YouTube video about a Yale student who raised $3.1 million for an AI social app.

Here's...'
System Message: You are an expert in enhancing the text provided within <TRANSCRIPT> tags according to the following guidelines: The information in <CONTEXT_INFORMATION> section is ONLY for reference.

### INSTRUCTIO…
User Message: <CONTEXT_INFORMATION>
NER Context Entities:
This looks like a YouTube video about a Yale student who raised $3.1 million for an AI social app.

Here's a breakdown of what's visible:

*   **Video Title…
🌐 Sending custom-prompt request to LLM proxy (provider auto-selected by server)...
🔑 [DEBUG] Getting JWT token...
🔑 [DEBUG] JWT token obtained in 0ms
🎯 [CONFIG-DEBUG] Config 2: Routing to Groq endpoint (https://fly.cliovoice.com/api/llm/proxy) with model: qwen
📝 [TIMING] Request preparation: 1.1ms
🌐 [DEBUG] Sending request to proxy...
🌐 [CONNECT] New single-flight request from warmHold
🌐 [CONNECT] Attempt #12 (loop 1/2) starting…
t=3031065 sess=9Hn lvl=INFO cat=stream evt=temp_key_fetch_start
⚡ [CACHE-HIT] Retrieved temp key in 0.1ms
t=3031066 sess=9Hn lvl=INFO cat=stream evt=temp_key_fetch expires_in_s=-1 latency_ms=0 source=cached
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🌐 [WS CONNECT] Using URL: wss://stt-rt.soniox.com/transcribe-websocket
🔗 [WS] Bound socket id=sock_-6966478718870120207@attempt_12
t=3031066 sess=9Hn lvl=INFO cat=stream evt=ws_bind attempt=12 socket=sock_-6966478718870120207@attempt_12 via_proxy=false path=/transcribe-websocket target_host=stt-rt.soniox.com target_ip=resolving...
🔑 Successfully connected to Soniox using temp key (21ms key latency)
t=3031087 sess=9Hn lvl=INFO cat=stream evt=ws_bind_resolved via_proxy=false socket=sock_-6966478718870120207@attempt_12 path=/transcribe-websocket target_host=stt-rt.soniox.com target_ip=129.146.176.251 attempt=12
🌐 [DEBUG] Proxy response received in 906ms
✅ [SSE] Parsed streaming response: 147 characters
🔍 [CONNECTION HEALTH]
🌐 [LANG DEBUG] Multi-language setting exists: true, Single language: en
🌐 [LANG DEBUG] Using multi-language selection (prioritized): zh, en
✅ Custom-prompt enhancement via proxy succeeded
t=3031916 sess=9Hn lvl=INFO cat=transcript evt=llm_final text="Startup ideas are a gallery of ideas, as specific as a range like mainly professional reasons. To realize that, this should be the future of how."
📊 [DETAILED STREAMING TIMING] Streaming: 548.6ms | Context: 0.1ms | LLM: 1042.2ms | Tracked Overhead: 0.1ms | Unaccounted: 2.7ms | Total: 1593.6ms
🔊 [SoundManager] Attempting to play stop sound
🔊 [SoundManager] NSSound stop sound result: true
🧹 Connection cleanup completed (session resources released)
📝 [GRACE] Recording session ended
📱 Dismissing recorder
📊 [ENHANCEMENT] Tracking 26 words - currentTier: pro, trialWordsRemaining: 2552
✅ Streaming transcription processing completed
t=3032050 sess=9Hn lvl=INFO cat=transcript evt=insert_attempt target="Google Chrome" chars=146 text="Startup ideas are a gallery of ideas, as specific as a range like mainly professional reasons. To realize that, this should be the future of how. "
🔍 [PASTE DEBUG] AXIsProcessTrusted() returned true, proceeding
🔍 [PASTE DEBUG] UseDirectTextInsertion setting: false
🔍 [PASTE DEBUG] Direct insertion disabled, using clipboard paste
⌨️ Using CGEvent-based Command+V
t=3032050 sess=9Hn lvl=INFO cat=transcript evt=insert_result ok=true
📊 [POST-RELEASE E2E] 1727ms (finalize=490ms | llm=1042ms | paste=0ms) | warm_socket=no
t=3032377 sess=9Hn lvl=INFO cat=stream evt=ws_handshake_metrics dns_ms=0 attempt=12 reused=false socket=sock_-6966478718870120207@attempt_12 connect_ms=1024 total_ms=1310 protocol=http/1.1 tls_ms=1016 proxy=false
🔌 WebSocket did open (sid=sock_-6966478718870120207, attemptId=12)
🌐 [CONNECT] Attempt #12 succeeded
📤 [START] Sent start/config on standby socket (eager mode)
t=3032378 sess=9Hn lvl=INFO cat=stream evt=start_config socket=sock_-6966478718870120207@attempt_12 attempt=12 summary=["valid": true, "ch": 1, "audio_format": "pcm_s16le", "sr": 16000, "langs": 2, "ctx_len": 36, "model": "stt-rt-preview-v2", "json_hash": "74c88fa4ee9a34f7"] ctx=standby_eager
🧾 [START-CONFIG] ctx=standby_eager sum=["valid": true, "ch": 1, "audio_format": "pcm_s16le", "sr": 16000, "langs": 2, "ctx_len": 36, "model": "stt-rt-preview-v2", "json_hash": "74c88fa4ee9a34f7"]
📤 Sending text frame seq=7337
🧊 [STANDBY] Connected standby socket — keepalive every 10.0s, TTL=60s
🔌 [READY] attemptId=12 socketId=sock_-6966478718870120207@attempt_12 start_text_sent=true
🧊 [STANDBY] WebSocket ready in 1314ms (handshake)
👂 [LISTENER] Standby listener task for socketId=sock_-6966478718870120207@attempt_12 attemptId=12
🧭 [APP] applicationShouldHandleReopen called - hasVisibleWindows: true
🧭 [APP] ActivationPolicy=.regular (IsMenuBarOnly=false)
🧭 [APP] applicationDidBecomeActive
🧭 [APP] ActivationPolicy=.regular (IsMenuBarOnly=false)
🪟 [DOCK] Found existing window, activating it
🔄 [SYNC_STATE] syncTrialState called - currentTier: pro, isInTrial: false
🔄 [SYNC_STATE] Final state after syncTrialState - currentTier: pro, isInTrial: false
deferral block timed out after 500ms
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
📊 [SESSION] Starting recording session #11
🧪 [A/B] warm_socket=yes
🧊➡️🔥 [STANDBY->ACTIVE] Consuming standby socket for new utterance
⏭️ [STANDBY->ACTIVE] START already sent on standby (eager) — skipping re-send
✅ [CACHE] Context unchanged - reusing cache (1584 chars)
♻️ [SMART-CACHE] Using cached context: 1584 characters
🔥 [NER-CACHE] Triggering NER callback with cached content (1584 chars)
✅ [NER-CACHE] NER callback triggered with cached content
✅ [STANDBY->ACTIVE] Probe keepalive OK — proceeding to resume queue
⏹️ Keepalive timer stopped
🔄 Keepalive timer started (interval: 15.000000s)
🧪 [PROMO] snapshot attempt=12 socket=sock_-6966478718870120207@attempt_12 start_sent=true ws_ready=true standby=false purpose=active cap_sr=16000 cap_ch=1 prebuf=0 last_fp=m=stt-rt-preview-v2|sr=16000|ch=1|h=en,zh|ctx=889740762234866296
t=3036997 sess=9Hn lvl=INFO cat=stream evt=temp_key_fetch_start
🔥 [PREWARM DEBUG] Pre-warming AI connection (target: Gemini), environment: flyio
⚡ [CACHE-HIT] Retrieved temp key in 0.3ms
t=3036997 sess=9Hn lvl=INFO cat=stream evt=temp_key_fetch source=cached latency_ms=0 expires_in_s=-1
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🧪 [PROMO] config_fp current=m=stt-rt-preview-v2|sr=16000|ch=1|h=en,zh|ctx=889740762234866296 last=m=stt-rt-preview-v2|sr=16000|ch=1|h=en,zh|ctx=889740762234866296
🎤 Registering audio tap for Soniox
t=3037015 sess=9Hn lvl=INFO cat=audio evt=record_start service=Soniox
🔍 Performing audio system pre-flight checks
throwing -10877
throwing -10877
✅ Pre-flight checks passed
t=3037093 sess=9Hn lvl=INFO cat=audio evt=tap_install service=Soniox backend=avcapture ok=true
t=3037093 sess=9Hn lvl=INFO cat=audio evt=record_start reason=start_capture
t=3037093 sess=9Hn lvl=INFO cat=audio evt=device_pin_start prev_name="MacBook Pro Microphone" prev_uid_hash=4285059772673450742 desired_name="MacBook Pro Microphone" desired_uid_hash=4285059772673450742 desired_id=181 prev_id=181
t=3037094 sess=9Hn lvl=INFO cat=audio evt=capture_backend_selected backend=avcapture
✅ Unified audio capture started
✅ Selected account account-bundle (connections: 1/10)
🎬 [NER-PREWARM] Using raw OCR text for NER: 1584 characters
🧠 [NER-DEFAULT] Using default NER prompt for general extraction
🧠 [TEN-VAD] Initialized (threshold=0.5, hop=256)
🚀 Starting Clio streaming transcription
🏥 [AUDIO HEALTH] Health monitoring timer started
⏱️ [TIMING] mic_engaged @ 1756226073.136
⏱️ [TIMING] WebSocket connect task completed — will flush after READY
pass
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
t=3037191 sess=9Hn lvl=INFO cat=audio evt=avcapture_start ok=true
t=3037191 sess=9Hn lvl=INFO cat=stream evt=first_audio_buffer_captured ms=62
🧪 [PROMO] first_audio seq=0 bytes=372 approx_db=-60.0
t=3037192 sess=9Hn lvl=INFO cat=audio evt=level avg_db=-60 peak_db=-60
✅ [AUDIO HEALTH] First audio data received - tap is functional
t=3037192 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=0
t=3037192 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=1 has_socket=true flushing=false
t=3037192 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=2 has_socket=true flushing=false
t=3037192 sess=9Hn lvl=INFO cat=stream evt=first_audio_sent ms=63 seq=1
t=3037192 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=360 seq=3
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
t=3037199 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=360 ready=true seq=4 flushing=false
t=3037210 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=5 has_socket=true bytes=372 flushing=false
t=3037222 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true ready=true seq=6
t=3037234 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true has_socket=true flushing=false seq=7
t=3037245 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=8 flushing=false has_socket=true
t=3037257 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=9 flushing=false ready=true has_socket=true
t=3037268 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=10 flushing=false bytes=372
t=3037280 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true bytes=372 seq=11 ready=true
🌐 [ASR BREAKDOWN] Total: 442ms | Client↔Proxy: 176ms | Proxy↔Soniox: 266ms | Network: 266ms
🗑️ Evicted oldest temp key to maintain cache size limit
💾 Cached temp key for languages: ["zh", "en"]
🗓️ [TTL-SCHEDULE] Scheduling temp key refresh for key=global in 3000s (expiresAt=2025-08-26 17:34:33 +0000)
✅ [PREFETCH] Successfully prefetched temp key
🎤 [WARMUP] Pre-warming audio system...
✅ [PREWARM] Device enumeration completed
✅ [PREWARM] Audio system pre-warming completed successfully
✅ [WARMUP] Audio system pre-warmed successfully
t=3037296 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=12
t=3037303 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=13 has_socket=true flushing=false ready=true
t=3037315 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=14 flushing=false ready=true bytes=372 has_socket=true
t=3037326 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 seq=15 ready=true
t=3037338 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=16 flushing=false ready=true bytes=372 has_socket=true
t=3037350 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=17 bytes=372 ready=true has_socket=true flushing=false
t=3037362 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=18 bytes=372 has_socket=true flushing=false
t=3037373 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true ready=true seq=19
t=3037385 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=20 flushing=false has_socket=true ready=true bytes=372
t=3037398 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=21 flushing=false has_socket=true ready=true bytes=372
t=3037409 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=22 flushing=false has_socket=true ready=true bytes=372
t=3037420 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=23 ready=true flushing=false bytes=372 has_socket=true
t=3037432 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=24 ready=true flushing=false bytes=372 has_socket=true
t=3037443 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=25 bytes=372
t=3037456 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=26 flushing=false has_socket=true ready=true bytes=372
🧪 [PROMO] audio_bytes bytes=10020
t=3037466 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=27 bytes=372 has_socket=true flushing=false
t=3037478 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=28 bytes=372 has_socket=true flushing=false
t=3037491 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=29 bytes=372 ready=true
t=3037501 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=30 flushing=false has_socket=true ready=true bytes=372
t=3037516 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=31 bytes=372
t=3037524 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false seq=32 ready=true
t=3037536 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=33 bytes=372 has_socket=true flushing=false
t=3037550 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=34 flushing=false has_socket=true ready=true bytes=372
t=3037559 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=35 flushing=false has_socket=true ready=true bytes=372
t=3037573 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=36 flushing=false has_socket=true ready=true bytes=372
t=3037583 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=37 ready=true flushing=false bytes=372 has_socket=true
t=3037594 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=38 ready=true flushing=false bytes=372 has_socket=true
t=3037606 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=39 flushing=false has_socket=true ready=true bytes=372
t=3037617 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=40 bytes=372 flushing=false has_socket=true ready=true
t=3037628 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=41 bytes=372 has_socket=true flushing=false
🌐 [PATH] Initial path baseline set — no action
t=3037641 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=42 flushing=false has_socket=true ready=true bytes=372
t=3037652 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=43 bytes=372
t=3037664 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=44 flushing=false has_socket=true ready=true bytes=372
t=3037675 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=45 bytes=372
t=3037687 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=46 bytes=372 has_socket=true flushing=false
t=3037699 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=47 bytes=372 flushing=false has_socket=true ready=true
t=3037710 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true ready=true seq=48
t=3037724 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true ready=true seq=49
t=3037733 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=50 flushing=false has_socket=true ready=true bytes=372
t=3037745 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=51 ready=true flushing=false bytes=372 has_socket=true
t=3037757 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true ready=true seq=52
t=3037768 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=53 bytes=372 flushing=false has_socket=true ready=true
t=3037781 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=54 flushing=false has_socket=true ready=true bytes=372
t=3037791 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=55 flushing=false has_socket=true ready=true bytes=372
t=3037803 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=56 flushing=false has_socket=true ready=true bytes=372
t=3037815 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=57 bytes=372
t=3037826 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=58 bytes=372
t=3037839 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=59 ready=true flushing=false bytes=372 has_socket=true
t=3037849 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=60 bytes=372 has_socket=true flushing=false
🗣️ [TEN-VAD] Speech start detected
t=3037861 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=61 ready=true flushing=false bytes=372 has_socket=true
t=3037874 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=62 ready=true has_socket=true flushing=false
t=3037884 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=63 ready=true flushing=false bytes=372 has_socket=true
t=3037898 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=64 flushing=false has_socket=true ready=true bytes=372
t=3037908 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true ready=true seq=65
t=3037919 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true ready=true seq=66
t=3037932 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true ready=true seq=67
t=3037942 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=68 flushing=false has_socket=true ready=true bytes=372
t=3037954 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=69 flushing=false has_socket=true ready=true bytes=372
t=3037965 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=70 flushing=false has_socket=true ready=true bytes=372
t=3037977 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=71 bytes=372
t=3037990 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=72 bytes=372 flushing=false has_socket=true ready=true
t=3038000 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=73 ready=true bytes=372
t=3038012 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=74 bytes=372 has_socket=true flushing=false
t=3038024 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=75 bytes=372 flushing=false has_socket=true ready=true
t=3038035 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=76
t=3038049 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=77 bytes=372
t=3038058 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=78 flushing=false has_socket=true ready=true bytes=372
t=3038070 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=79 bytes=372
t=3038081 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=80 has_socket=true ready=true
🧪 [PROMO] audio_bytes bytes=30108
t=3038093 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=81 bytes=372 has_socket=true flushing=false
t=3038106 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=82 flushing=false bytes=372
t=3038116 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=83 ready=true flushing=false bytes=372 has_socket=true
t=3038128 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=84 ready=true bytes=372 has_socket=true flushing=false
t=3038141 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=85 bytes=372 flushing=false has_socket=true ready=true
t=3038151 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true seq=86 has_socket=true
t=3038164 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true seq=87 has_socket=true
t=3038175 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=88 bytes=372 flushing=false has_socket=true ready=true
t=3038186 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=89 ready=true flushing=false bytes=372 has_socket=true
t=3038197 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false ready=true has_socket=true seq=90
t=3038209 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=91 bytes=372
t=3038221 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=92 ready=true flushing=false bytes=372 has_socket=true
t=3038232 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=93 bytes=372 has_socket=true flushing=false
t=3038248 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=94 flushing=false has_socket=true ready=true bytes=372
t=3038256 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false ready=true seq=95 has_socket=true
🛑 [TEN-VAD] Speech end detected
t=3038267 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=96 bytes=372 has_socket=true flushing=false
t=3038279 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=97 bytes=372 has_socket=true flushing=false
t=3038291 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=98 ready=true flushing=false bytes=372 has_socket=true
t=3038302 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=99 bytes=372
t=3038315 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=100
t=3038326 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=101
t=3038337 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=102 flushing=false has_socket=true ready=true bytes=372
t=3038348 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=103 bytes=372
t=3038360 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=104 bytes=372 has_socket=true flushing=false
t=3038373 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true seq=105 has_socket=true
t=3038384 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=106 bytes=372
t=3038395 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=107 bytes=372 has_socket=true flushing=false
t=3038407 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=108 has_socket=true bytes=372
t=3038418 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=109 bytes=372 ready=true
t=3038431 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=110 bytes=372
t=3038442 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=111 bytes=372 has_socket=true flushing=false
t=3038453 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=112 bytes=372 has_socket=true flushing=false
t=3038466 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=113 bytes=372 ready=true
t=3038476 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=114 bytes=372
t=3038489 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true seq=115 has_socket=true
t=3038500 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=116 bytes=372 flushing=false has_socket=true ready=true
t=3038511 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=117 bytes=372
t=3038523 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=118 ready=true flushing=false
t=3038534 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=119 bytes=372 flushing=false has_socket=true ready=true
t=3038546 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=120 ready=true flushing=false bytes=372 has_socket=true
t=3038557 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=121 bytes=372 has_socket=true flushing=false
t=3038569 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=122 bytes=372
t=3038582 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false ready=true has_socket=true seq=123
t=3038593 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=124 bytes=372 flushing=false has_socket=true ready=true
t=3038604 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true seq=125 has_socket=true
t=3038616 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=126 bytes=372 ready=true
t=3038627 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=127 ready=true flushing=false bytes=372 has_socket=true
t=3038640 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=128 bytes=372 flushing=false has_socket=true ready=true
t=3038651 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=129 bytes=372
t=3038662 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=130 bytes=372
t=3038674 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=131 bytes=372
t=3038685 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=132 ready=true flushing=false bytes=372 has_socket=true
t=3038698 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=133 bytes=372
t=3038708 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=134 ready=true flushing=false bytes=372 has_socket=true
t=3038720 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=135 bytes=372 ready=true
t=3038731 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=136
t=3038743 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=137 bytes=372
t=3038755 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=138 bytes=372 ready=true
t=3038766 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=139 ready=true flushing=false bytes=372 has_socket=true
t=3038778 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=140 bytes=372 flushing=false has_socket=true ready=true
t=3038790 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=141 has_socket=true flushing=false
t=3038797 sess=9Hn lvl=INFO cat=stream evt=first_partial ms=1671
t=3038797 sess=9Hn lvl=INFO cat=stream evt=ttft_hotkey ms=1671
t=3038798 sess=9Hn lvl=INFO cat=stream evt=ttft ms=949
🧪 [PROMO] first_token ms=1803 tokens_in_msg=1
t=3038801 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=142 ready=true flushing=false bytes=372 has_socket=true
t=3038855 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=143 has_socket=true flushing=false
t=3038855 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=144 has_socket=true flushing=false
t=3038855 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=145 has_socket=true flushing=false
t=3038855 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=146 has_socket=true flushing=false
t=3038859 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=147 has_socket=true flushing=false bytes=372 ready=true
t=3038870 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=148 has_socket=true flushing=false bytes=372 ready=true
t=3038882 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=149
t=3038894 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=150
t=3038905 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=151 has_socket=true ready=true flushing=false
t=3038952 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false seq=152 has_socket=true
t=3038952 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false seq=153 has_socket=true
t=3038952 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false seq=154 has_socket=true
t=3038952 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false seq=155 has_socket=true
t=3038964 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=156 has_socket=true ready=true
t=3038976 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 seq=157 ready=true
t=3038987 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=158
t=3038998 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=159
t=3039010 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true seq=160 bytes=372
t=3039021 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=161 bytes=372 flushing=false ready=true has_socket=true
t=3039059 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=162 bytes=372 has_socket=true flushing=false ready=true
t=3039059 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=163 bytes=372 has_socket=true flushing=false ready=true
t=3039059 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=164 bytes=372 has_socket=true flushing=false ready=true
t=3039068 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=165 ready=true has_socket=true
t=3039080 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=166 ready=true flushing=false bytes=372
t=3039091 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=167 ready=true
t=3039103 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false seq=168 has_socket=true
t=3039114 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=169 flushing=false ready=true bytes=372 has_socket=true
throwing -10877
throwing -10877
t=3039185 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false ready=true seq=170
t=3039185 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false ready=true seq=171
t=3039185 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=172 flushing=false ready=true bytes=372 has_socket=true
t=3039185 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=173 flushing=false ready=true bytes=372 has_socket=true
t=3039185 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=174 flushing=false ready=true bytes=372 has_socket=true
t=3039185 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=175 flushing=false ready=true bytes=372 has_socket=true
🤖 [FLY.IO-NER] Server-reported provider: gemini
t=3039215 sess=9Hn lvl=INFO cat=audio evt=level peak_db=-34 avg_db=-34
t=3039215 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 seq=176 ready=true
📥 [NER-STORE] Stored NER entities: 1391 chars - The user is asking to identify the text content of the active YouTube video on their screen.

The ac...
✅ [FLY.IO] NER refresh completed successfully
t=3039215 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 seq=177 ready=true
t=3039219 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=178 has_socket=true flushing=false ready=true
t=3039231 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 ready=true seq=179 flushing=false
t=3039242 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false seq=180 has_socket=true
t=3039254 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=181 bytes=372 ready=true
t=3039265 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=182 flushing=false
t=3039277 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=183 ready=true bytes=372
t=3039289 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false seq=184 has_socket=true
t=3039300 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=185 flushing=false
t=3039312 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false seq=186 has_socket=true
t=3039323 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true ready=true bytes=372 seq=187
t=3039335 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 ready=true seq=188 flushing=false
t=3039347 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false seq=189 has_socket=true
t=3039358 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=190 flushing=false ready=true bytes=372 has_socket=true
t=3039370 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=191 flushing=false ready=true bytes=372 has_socket=true
t=3039381 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=192 bytes=372 has_socket=true ready=true
t=3039393 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=193 has_socket=true flushing=false
t=3039405 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=194 has_socket=true flushing=false
t=3039416 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=195 bytes=372
t=3039428 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=196 flushing=false has_socket=true ready=true bytes=372
t=3039440 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=197 ready=true flushing=false bytes=372 has_socket=true
t=3039452 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=198 bytes=372
t=3039463 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=199 flushing=false has_socket=true ready=true bytes=372
t=3039534 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=200 ready=true bytes=372
t=3039534 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=201 ready=true bytes=372
t=3039534 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=202 ready=true bytes=372
t=3039534 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=203 ready=true bytes=372
t=3039534 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=204 ready=true bytes=372
t=3039534 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=205 has_socket=true flushing=false
t=3039572 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false seq=206 bytes=372
t=3039572 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false seq=207 bytes=372
t=3039572 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false seq=208 bytes=372
t=3039579 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=209 flushing=false ready=true bytes=372 has_socket=true
t=3039590 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=210 has_socket=true ready=true bytes=372 flushing=false
t=3039602 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=211 ready=true has_socket=true
t=3039614 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=212 ready=true has_socket=true
t=3039625 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=213 flushing=false has_socket=true
t=3039664 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=214
t=3039664 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=215
t=3039664 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=216
t=3039672 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=217 flushing=false has_socket=true ready=true
t=3039683 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=218 flushing=false bytes=372 has_socket=true
t=3039695 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=219 bytes=372 has_socket=true ready=true
t=3039707 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=220
t=3039718 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=221
t=3039730 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=222
t=3039741 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 seq=223 flushing=false ready=true
t=3039782 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=224
t=3039783 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=225
t=3039783 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=226 bytes=372
t=3039788 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=227 flushing=false bytes=372 ready=true has_socket=true
t=3039799 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=228 ready=true flushing=false bytes=372 has_socket=true
🛑 [TEN-VAD] Speech end detected
t=3039811 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 seq=229 has_socket=true
t=3039823 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true bytes=372 seq=230 ready=true
t=3039834 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=231 ready=true has_socket=true flushing=false bytes=372
t=3039846 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=232
t=3039857 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=233 ready=true flushing=false bytes=372 has_socket=true
t=3039869 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=234 ready=true flushing=false bytes=372
🛑 [TEN-VAD] Speech end detected
t=3039881 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=235 ready=true flushing=false bytes=372 has_socket=true
t=3039892 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=236 ready=true has_socket=true
t=3039904 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=237 ready=true bytes=372 has_socket=true flushing=false
t=3039915 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=238 has_socket=true ready=true
t=3039927 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=239 ready=true has_socket=true flushing=false
t=3039939 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=240 ready=true bytes=372 has_socket=true flushing=false
t=3039977 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=241 flushing=false ready=true bytes=372 has_socket=true
t=3039977 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=242 flushing=false ready=true bytes=372 has_socket=true
t=3039977 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=243 flushing=false ready=true bytes=372 has_socket=true
t=3039985 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=244 flushing=false ready=true bytes=372 has_socket=true
t=3039997 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=245
t=3040036 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=246 has_socket=true flushing=false
t=3040036 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=247 has_socket=true flushing=false
t=3040036 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=248 has_socket=true flushing=false
t=3040043 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=249
t=3040055 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=250 ready=true has_socket=true
t=3040066 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 seq=251 ready=true
t=3040078 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=252 has_socket=true bytes=372 ready=true
t=3040090 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=253 ready=true bytes=372
t=3040101 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=254
t=3040113 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=255 ready=true
t=3040146 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=256
t=3040146 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=257
t=3040148 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=258
t=3040159 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=259
t=3040171 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=260
t=3040183 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=261 has_socket=true ready=true
t=3040194 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=262
t=3040206 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 seq=263 ready=true
t=3040217 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=264
t=3040259 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=265
t=3040259 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=266
t=3040259 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=267
t=3040264 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 seq=268 ready=true
t=3040276 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=269 ready=true has_socket=true
t=3040287 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=270 has_socket=true ready=true flushing=false
t=3040299 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=271 has_socket=true ready=true flushing=false
t=3040310 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=272 has_socket=true flushing=false
t=3040322 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=273 ready=true
t=3040333 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 seq=274 ready=true
t=3040345 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=275 has_socket=true ready=true flushing=false
t=3040357 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=276 has_socket=true flushing=false
t=3040368 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=277 has_socket=true flushing=false
t=3040405 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=278 has_socket=true flushing=false
t=3040405 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=279 has_socket=true flushing=false
t=3040405 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=280 has_socket=true flushing=false
t=3040415 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=281
t=3040426 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=282 has_socket=true flushing=false
t=3040438 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=283 has_socket=true ready=true flushing=false
t=3040449 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=284 ready=true flushing=false bytes=372 has_socket=true
t=3040483 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true has_socket=true bytes=372 seq=285
t=3040483 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=286
t=3040484 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=287
t=3040496 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=288 has_socket=true flushing=false
t=3040508 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=289 has_socket=true
t=3040519 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=290 has_socket=true
t=3040531 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=291 has_socket=true flushing=false
t=3040542 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=292
t=3040554 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=293 has_socket=true ready=true flushing=false
t=3040566 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=294 has_socket=true flushing=false
t=3040577 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true seq=295 has_socket=true
t=3040589 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=296 flushing=false ready=true has_socket=true
t=3040600 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=297 has_socket=true ready=true
t=3040612 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=298
t=3040624 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=299 has_socket=true flushing=false
t=3040635 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=300 flushing=false bytes=372
t=3040647 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=301 ready=true flushing=false bytes=372 has_socket=true
t=3040659 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=302 ready=true flushing=false bytes=372 has_socket=true
t=3040670 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=303 has_socket=true ready=true flushing=false bytes=372
t=3040682 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=304 bytes=372 flushing=false has_socket=true ready=true
t=3040694 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=305 ready=true flushing=false bytes=372 has_socket=true
t=3040706 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=306 flushing=false bytes=372
t=3040717 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=307 ready=true flushing=false bytes=372 has_socket=true
t=3040728 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=308 bytes=372
t=3040741 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=309 bytes=372 flushing=false has_socket=true ready=true
t=3040753 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=310 bytes=372
t=3040764 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=311 bytes=372
t=3040775 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=312 bytes=372 flushing=false has_socket=true ready=true
t=3040787 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=313 ready=true flushing=false bytes=372 has_socket=true
t=3040838 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=314
t=3040838 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=315
t=3040838 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=316
t=3040838 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=317
t=3040844 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=318 flushing=false has_socket=true
t=3040888 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=319 bytes=372 flushing=false ready=true
t=3040888 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=320 bytes=372 flushing=false ready=true
t=3040888 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=321 bytes=372 flushing=false ready=true
t=3040891 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 ready=true flushing=false seq=322
t=3040902 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=323 flushing=false bytes=372 ready=true
t=3040914 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=324 has_socket=true ready=true bytes=372
t=3040925 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 ready=true flushing=false seq=325
t=3040962 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 seq=326 flushing=false ready=true
t=3040962 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 seq=327 flushing=false ready=true
t=3040962 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 seq=328 flushing=false ready=true
t=3040972 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=329 flushing=false has_socket=true
t=3040983 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=330 flushing=false has_socket=true
t=3040995 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=331
t=3041007 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=332
t=3041018 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=333 bytes=372 has_socket=true ready=true flushing=false
t=3041030 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=334 bytes=372 flushing=false has_socket=true
t=3041042 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=335 ready=true has_socket=true
t=3041073 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=336 has_socket=true flushing=false
t=3041073 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=337 has_socket=true flushing=false
t=3041076 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=338
t=3041088 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=339 ready=true has_socket=true
t=3041100 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=340
t=3041111 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=341 has_socket=true flushing=false
t=3041123 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=342
t=3041135 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=343 has_socket=true flushing=false
t=3041146 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=344 bytes=372
t=3041158 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=345 bytes=372
t=3041170 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=346
t=3041181 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=347 has_socket=true flushing=false
t=3041193 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=348 has_socket=true flushing=false
t=3041204 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=349 has_socket=true flushing=false
t=3041216 sess=9Hn lvl=INFO cat=audio evt=level avg_db=-54 peak_db=-54
t=3041216 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=350 has_socket=true flushing=false
t=3041262 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=351 bytes=372
t=3041262 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=352 bytes=372
t=3041262 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=353 bytes=372
t=3041262 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=354 has_socket=true flushing=false
t=3041274 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=355 bytes=372
t=3041285 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 seq=356 ready=true flushing=false
t=3041297 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=357 has_socket=true flushing=false
🛑 [TEN-VAD] Speech end detected
t=3041309 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true seq=358 bytes=372
t=3041347 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=359 has_socket=true flushing=false
t=3041348 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=360 has_socket=true flushing=false
t=3041348 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=361 has_socket=true flushing=false
t=3041355 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 ready=true seq=362
t=3041367 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true ready=true bytes=372 seq=363
t=3041378 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=364 has_socket=true flushing=false
t=3041390 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=365 has_socket=true flushing=false
t=3041402 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true ready=true bytes=372 seq=366
t=3041413 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=367 ready=true flushing=false bytes=372 has_socket=true
t=3041425 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 ready=true seq=368
t=3041462 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=369 ready=true flushing=false bytes=372 has_socket=true
t=3041462 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=370 ready=true flushing=false bytes=372 has_socket=true
t=3041462 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=371 ready=true flushing=false bytes=372 has_socket=true
t=3041471 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=372 ready=true
t=3041483 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=373
t=3041495 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=374 ready=true flushing=false bytes=372 has_socket=true
t=3041506 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=375 bytes=372
t=3041518 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=376 ready=true flushing=false bytes=372 has_socket=true
t=3041529 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=377
t=3041541 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=378 has_socket=true flushing=false ready=true
t=3041552 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=379
t=3041564 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=380
t=3041576 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=381 bytes=372 has_socket=true ready=true
t=3041581 sess=9Hn lvl=INFO cat=stream evt=first_final ms=4458
t=3041581 sess=9Hn lvl=INFO cat=transcript evt=raw_final text=Open
t=3041626 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=382 ready=true flushing=false bytes=372 has_socket=true
t=3041626 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=383 ready=true flushing=false bytes=372 has_socket=true
t=3041626 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=384 ready=true flushing=false bytes=372 has_socket=true
t=3041626 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=385 ready=true flushing=false bytes=372 has_socket=true
t=3041634 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=386 bytes=372
t=3041645 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=387 ready=true has_socket=true
t=3041657 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=388 ready=true has_socket=true
t=3041701 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 seq=389 has_socket=true
t=3041701 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 seq=390 has_socket=true
t=3041701 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 seq=391 has_socket=true
t=3041703 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 seq=392 has_socket=true
t=3041715 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=393 has_socket=true ready=true bytes=372
t=3041727 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=394 has_socket=true ready=true flushing=false
t=3041738 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 seq=395 ready=true
t=3041750 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=396
t=3041762 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=397 has_socket=true ready=true bytes=372
t=3041773 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true has_socket=true seq=398 bytes=372
t=3041785 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=399
t=3041796 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true has_socket=true seq=400 bytes=372
t=3041808 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=401
t=3041850 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=402 has_socket=true ready=true flushing=false bytes=372
t=3041850 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=403 has_socket=true ready=true flushing=false bytes=372
t=3041850 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=404 has_socket=true ready=true flushing=false bytes=372
t=3041855 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=405 ready=true flushing=false bytes=372 has_socket=true
t=3041866 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=406 ready=true has_socket=true
t=3041878 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=407 has_socket=true bytes=372 flushing=false ready=true
t=3041889 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=408 ready=true
t=3041901 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=409 has_socket=true ready=true flushing=false bytes=372
t=3041940 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=410 ready=true flushing=false has_socket=true
t=3041940 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=411 ready=true flushing=false has_socket=true
t=3041940 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=412 ready=true flushing=false has_socket=true
t=3041947 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=413 ready=true flushing=false bytes=372
t=3041959 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=414
t=3041970 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=415 bytes=372
t=3041982 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=416 bytes=372
t=3041994 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=417 ready=true flushing=false bytes=372
t=3042035 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false has_socket=true seq=418
t=3042035 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false has_socket=true seq=419
t=3042035 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false has_socket=true seq=420
t=3042040 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false has_socket=true seq=421
t=3042052 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false has_socket=true seq=422
t=3042063 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true seq=423 has_socket=true
t=3042075 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false has_socket=true seq=424
t=3042087 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=425 bytes=372
t=3042098 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=426 ready=true has_socket=true
t=3042110 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 seq=427 has_socket=true
t=3042121 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=428 ready=true has_socket=true
t=3042133 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true seq=429 flushing=false bytes=372
t=3042145 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=430 bytes=372
t=3042156 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true seq=431 has_socket=true
t=3042168 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=432 has_socket=true bytes=372 ready=true flushing=false
t=3042180 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=433 has_socket=true ready=true bytes=372
t=3042191 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=434 ready=true has_socket=true
t=3042203 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=435 ready=true flushing=false has_socket=true bytes=372
t=3042216 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=436 ready=true flushing=false bytes=372 has_socket=true
t=3042227 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=437 bytes=372
t=3042238 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=438 ready=true flushing=false bytes=372 has_socket=true
t=3042250 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=439 ready=true flushing=false has_socket=true bytes=372
t=3042262 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true bytes=372 ready=true seq=440
t=3042273 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=441 ready=true flushing=false bytes=372 has_socket=true
t=3042285 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=442
t=3042296 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true has_socket=true seq=443
t=3042309 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=444 bytes=372
t=3042320 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=445
t=3042331 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=446
t=3042343 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=447
t=3042355 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=448 bytes=372
t=3042366 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=449 has_socket=true ready=true flushing=false bytes=372
t=3042379 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=450 ready=true
t=3042389 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=451 bytes=372
t=3042401 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=452 bytes=372
t=3042463 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=453 ready=true bytes=372 flushing=false has_socket=true
t=3042463 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=454 ready=true bytes=372 flushing=false has_socket=true
t=3042463 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=455 ready=true bytes=372 flushing=false has_socket=true
t=3042463 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=456 ready=true bytes=372 flushing=false has_socket=true
t=3042463 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=457 ready=true bytes=372 flushing=false has_socket=true
t=3042470 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=458 ready=true has_socket=true
t=3042481 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=459
t=3042493 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=460 has_socket=true ready=true flushing=false
t=3042504 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=461 ready=true has_socket=true flushing=false
t=3042516 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=462 bytes=372 has_socket=true ready=true
t=3042528 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=463 bytes=372 has_socket=true ready=true
t=3042539 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=464 ready=true
t=3042551 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=465 bytes=372 flushing=false has_socket=true ready=true
t=3042563 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=466 ready=true flushing=false bytes=372 has_socket=true
t=3042575 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 ready=true seq=467
t=3042586 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=468 ready=true
t=3042649 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=469 ready=true flushing=false bytes=372 has_socket=true
t=3042649 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=470 ready=true flushing=false bytes=372 has_socket=true
t=3042649 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=471 ready=true flushing=false bytes=372 has_socket=true
t=3042649 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=472 ready=true flushing=false bytes=372 has_socket=true
t=3042649 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=473 ready=true flushing=false bytes=372 has_socket=true
t=3042655 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=474 bytes=372
t=3042667 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=475
t=3042679 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=476 has_socket=true ready=true bytes=372
t=3042690 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=477 has_socket=true ready=true flushing=false
t=3042702 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=478 ready=true flushing=false bytes=372 has_socket=true
t=3042714 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=479 ready=true flushing=false bytes=372 has_socket=true
t=3042725 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=480 has_socket=true ready=true flushing=false
t=3042737 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=481 ready=true flushing=false bytes=372 has_socket=true
t=3042749 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=482
t=3042760 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=483 has_socket=true ready=true
t=3042772 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=484
t=3042784 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=485 has_socket=true bytes=372
t=3042795 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false ready=true has_socket=true seq=486
t=3042807 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=487
t=3042819 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=488 flushing=false has_socket=true
t=3042831 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=489 has_socket=true bytes=372
t=3042841 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=490 flushing=false has_socket=true
t=3042845 sess=9Hn lvl=INFO cat=transcript evt=raw_final text=" network. Yeah, I don't think we're compet"
t=3042920 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=491
t=3042920 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=492
t=3042920 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=493
t=3042920 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=494 has_socket=true ready=true bytes=372
t=3042920 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=495 has_socket=true ready=true bytes=372
t=3042920 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=496 has_socket=true ready=true bytes=372
t=3042922 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=497 ready=true has_socket=true
t=3042934 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=498 has_socket=true ready=true bytes=372
t=3042946 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=499 has_socket=true ready=true bytes=372
t=3042957 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=500 has_socket=true
t=3042969 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=501 bytes=372 has_socket=true ready=true
t=3042980 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=502 ready=true has_socket=true
t=3042992 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=503 ready=true bytes=372
t=3043004 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=504 ready=true has_socket=true
t=3043015 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=505 ready=true bytes=372
t=3043027 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=506 has_socket=true
t=3043039 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=507 flushing=false bytes=372
t=3043051 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=508 bytes=372
t=3043062 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 flushing=false seq=509
t=3043074 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=510 bytes=372
🛑 [TEN-VAD] Speech end detected
t=3043086 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=511 bytes=372 has_socket=true flushing=false ready=true
t=3043097 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=512 bytes=372
t=3043169 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=513
t=3043169 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=514
t=3043169 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=515
t=3043169 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=516
t=3043169 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=517
t=3043169 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=518
t=3043178 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=519 flushing=false
t=3043190 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=520 flushing=false
t=3043201 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=521 ready=true
t=3043213 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=522 ready=true
t=3043224 sess=9Hn lvl=INFO cat=audio evt=level avg_db=-35 peak_db=-35
t=3043224 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=523 ready=true has_socket=true
t=3043272 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=524 bytes=372 has_socket=true ready=true flushing=false
t=3043272 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=525 bytes=372 has_socket=true ready=true flushing=false
t=3043272 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=526 bytes=372 has_socket=true ready=true flushing=false
t=3043272 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=527 bytes=372 has_socket=true ready=true flushing=false
t=3043282 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=528 flushing=false has_socket=true ready=true
t=3043294 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=529 ready=true has_socket=true
t=3043306 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false has_socket=true seq=530
t=3043317 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=531 ready=true has_socket=true
t=3043329 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=532 has_socket=true ready=true flushing=false
t=3043341 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=533 has_socket=true ready=true flushing=false
t=3043352 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=534 ready=true
t=3043364 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=535 ready=true
t=3043376 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=536 ready=true
t=3043387 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=537 bytes=372 has_socket=true ready=true
t=3043399 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=538 bytes=372
t=3043412 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=539 has_socket=true flushing=false
t=3043423 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=540 bytes=372
t=3043434 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=541 bytes=372 flushing=false has_socket=true ready=true
t=3043445 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=542 ready=true flushing=false bytes=372 has_socket=true
t=3043457 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=543 bytes=372 flushing=false has_socket=true ready=true
t=3043468 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=544 ready=true flushing=false has_socket=true bytes=372
t=3043531 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=545 has_socket=true ready=true flushing=false
t=3043531 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=546 has_socket=true ready=true flushing=false
t=3043531 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=547 has_socket=true ready=true flushing=false
t=3043531 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=548 has_socket=true ready=true flushing=false
t=3043531 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=549 has_socket=true ready=true flushing=false
t=3043538 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=550 flushing=false has_socket=true
t=3043549 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=551 has_socket=true ready=true flushing=false
t=3043561 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=552 flushing=false has_socket=true
t=3043573 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=553 flushing=false has_socket=true
t=3043584 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=554 bytes=372 has_socket=true ready=true
t=3043624 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=555 bytes=372 flushing=false
t=3043624 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=556 bytes=372 flushing=false
t=3043624 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=557 bytes=372 flushing=false
t=3043631 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=558
t=3043642 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=559 has_socket=true ready=true
t=3043654 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=560 has_socket=true ready=true
t=3043665 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 seq=561 flushing=false
t=3043677 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=562 ready=true has_socket=true
t=3043689 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=563 ready=true flushing=false has_socket=true bytes=372
t=3043700 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=564 has_socket=true ready=true
t=3043712 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=565 bytes=372 has_socket=true
t=3043723 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=566 ready=true has_socket=true
t=3043735 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=567 ready=true flushing=false bytes=372 has_socket=true
t=3043748 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=568 ready=true flushing=false bytes=372 has_socket=true
t=3043759 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=569 bytes=372 flushing=false has_socket=true ready=true
t=3043771 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=570 ready=true flushing=false bytes=372 has_socket=true
t=3043782 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=571 bytes=372
t=3043794 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=572 ready=true flushing=false bytes=372 has_socket=true
t=3043805 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=573 flushing=false bytes=372
t=3043817 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=574 bytes=372 flushing=false has_socket=true ready=true
t=3043829 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=575 ready=true flushing=false has_socket=true bytes=372
🛑 [TEN-VAD] Speech end detected
t=3043840 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=576 ready=true flushing=false bytes=372 has_socket=true
t=3043852 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=577 ready=true flushing=false bytes=372 has_socket=true
t=3043863 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=578 ready=true flushing=false bytes=372 has_socket=true
t=3043875 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=579 ready=true flushing=false bytes=372 has_socket=true
t=3043886 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=580 bytes=372 has_socket=true ready=true flushing=false
t=3043902 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=581 ready=true flushing=false bytes=372
t=3043909 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=582 bytes=372 has_socket=true
t=3043921 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=583 has_socket=true ready=true
🛑 Stopping recording
🛑 Stopping Clio streaming transcription
🏥 [AUDIO HEALTH] Health monitoring timer stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
🛑 Stopping unified audio capture
t=3044010 sess=9Hn lvl=INFO cat=audio evt=record_stop
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key plugInPackage
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key CMIOType
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key numberOfDevices
t=3044019 sess=9Hn lvl=INFO cat=audio evt=avcapture_stop
✅ Unified audio capture stopped
t=3044020 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=584 ready=true bytes=372
t=3044020 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=585 ready=true bytes=372
t=3044020 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=586 ready=true bytes=372
t=3044020 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=587 ready=true bytes=372
t=3044020 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=588 ready=true bytes=372
t=3044051 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=589 ready=true has_socket=true flushing=false bytes=372
t=3044051 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=590 ready=true has_socket=true flushing=false bytes=372
📤 Sent end-of-stream signal
📤 Sent manual finalize command
🕐 Using finalization timeout: 400ms (connection took 7026ms)
ℹ️ [OPTIMISTIC] Not skipping: end=false pending=0 ms_since_last=92 tail=100 silence_ok=false tokens_quiet_ok=false partial_empty=false uncond=false
t=3044151 sess=9Hn lvl=INFO cat=transcript evt=raw_final text="ing against anyone. And the most common"
t=3044486 sess=9Hn lvl=INFO cat=transcript evt=raw_final text=" reason why is all of them have in common a number, a number.<end>"
🏁 Received <fin> token - finalization complete
✅ Received <fin> token after 381ms
⏹️ Keepalive timer stopped
⚡ Audio capture already stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
📉 Released connection for account account-bundle (connections: 0)
💾 [COLD-START] Updated successful streaming timestamp
💾 [COLD-START] Updated successful streaming timestamp
✅ Streaming stopped. Final transcript (148 chars, 7.4s, with audio file): "Open network. Yeah, I don't think we're compet ing against anyone. And the most common  reason why is all of them have in common a number, a number."
t=3044528 sess=9Hn lvl=INFO cat=transcript evt=final text="Open network. Yeah, I don't think we're compet ing against anyone. And the most common  reason why is all of them have in common a number, a number."
t=3044528 sess=9Hn lvl=INFO cat=transcript evt=session_end divider="────────── session end ──────────"
🌡️ [WARM] warm_socket=yes
⏹️ Keepalive timer stopped
🔌 [WS] Disconnected (socketId=sock_-6966478718870120207@attempt_12)
⚠️ WebSocket did close with code 1001 (sid=sock_-6966478718870120207, attemptId=12)
t=3044528 sess=9Hn lvl=WARN cat=stream evt=state code=1001 state=closed
✅ Streaming transcription completed successfully, length: 148 characters
⏱️ [TIMING] Subscription tracking: 0.2ms
⏱️ [TIMING] ASR word tracking: 0.0ms
🧠 Performing intelligent end-context detection for streaming
⏱️ [CONTEXT DETAIL] Cache check: 0.0ms
⚡ [SMART-OPTIMIZATION] Using smart cached screen context (1584 chars) - skipping new capture
⏱️ [STREAMING CONTEXT TIMING] Screen capture + context detection: 0.0ms
🎯 Starting dynamic context-aware AI enhancement with tracking for text (148 characters)
⚡ [FAST-PATH] Using pre-warmed context - skipping redundant detection
⚡ [PREWARMED] Using pre-warmed NER context fast-path
🔍 [REGISTRY] Starting context detection using new rule engine
🔍 [REGISTRY] Bundle ID: com.google.Chrome
🔍 [REGISTRY] Process name: nil
🔍 [REGISTRY] URL: nil
🔍 [REGISTRY] Window title: (17) A Yale Student Raised $3.1M in 2 Weeks for an AI Social App | Series, Nathaneo Johnson - YouTube
🔍 [REGISTRY] Content length: 1584 chars
🎯 [RULE-ENGINE] Cache hit for com.google.Chrome|||(17) A Yale Student Raised $3.1M in 2 Weeks for an AI Social App | Series, Nathaneo Johnson - YouTube
🔄 [REGISTRY] Rule engine returned .none, checking for high-confidence legacy matches only
🔄 [REGISTRY] Trying legacy Email detector (priority: 100)
📧 [EMAIL] Starting email context detection
🚫 [DYNAMIC] Email exclusion detected in content: excluding from detection
🔄 [REGISTRY] Trying legacy Code Review detector (priority: 90)
💻 [CODE] Starting code context detection
❌ [CODE] Code confidence too low: 0.000000 < 0.300000
🔄 [REGISTRY] Trying legacy Social Media detector (priority: 10)
💬 [CHAT] Starting casual chat context detection
💬 [CHAT] Casual chat context detected - Title matches: 1, Content matches: 4, Confidence: 0.280000
🚫 [REGISTRY] Legacy Social Media context rejected - rule engine returned .none and confidence not high enough (0.280000 < 0.800000)
📝 [REGISTRY] Rule engine returned .none and no high-confidence legacy matches, returning general context
📝 [PREWARMED] Non-code or unknown context → using enhanced system prompt
🚨 [PROMPT-DEBUG] About to call getSystemMessage(for: .transcriptionEnhancement)
🚨 [PROMPT-DEBUG] getSystemMessage called with mode: transcriptionEnhancement
🚨 [PROMPT-DEBUG] RETURNING TRANSCRIPTION ENHANCEMENT PROMPT
🌐 [LANG DEBUG] Multi-language setting exists: true, Single language: en
🌐 [LANG DEBUG] Using multi-language selection (prioritized): zh, en
🚨 [PROMPT-DEBUG] About to call getUserMessage(text:, mode: .transcriptionEnhancement)
🌐 [LANG DEBUG] Multi-language setting exists: true, Single language: en
🌐 [LANG DEBUG] Using multi-language selection (prioritized): zh, en
🌐 [LANG DEBUG] Multi-language setting exists: true, Single language: en
🌐 [LANG DEBUG] Using multi-language selection (prioritized): zh, en
📝 [PREWARMED-SYSTEM] Enhanced system prompt: 'You are an expert in enhancing the text provided within <TRANSCRIPT> tags according to the following guidelines: The information in <CONTEXT_INFORMATI...'
📝 [PREWARMED-USER] Enhanced user prompt: '<CONTEXT_INFORMATION>
NER Context Entities:
The user is asking to identify the text content of the active YouTube video on their screen.

The active w...'
System Message: You are an expert in enhancing the text provided within <TRANSCRIPT> tags according to the following guidelines: The information in <CONTEXT_INFORMATION> section is ONLY for reference.

### INSTRUCTIO…
User Message: <CONTEXT_INFORMATION>
NER Context Entities:
The user is asking to identify the text content of the active YouTube video on their screen.

The active window shows a YouTube video titled: **"A Yale Stud…
🌐 Sending custom-prompt request to LLM proxy (provider auto-selected by server)...
🔑 [DEBUG] Getting JWT token...
🔑 [DEBUG] JWT token obtained in 0ms
🎯 [CONFIG-DEBUG] Config 2: Routing to Groq endpoint (https://fly.cliovoice.com/api/llm/proxy) with model: qwen
📝 [TIMING] Request preparation: 0.1ms
🌐 [DEBUG] Sending request to proxy...
🌐 [CONNECT] New single-flight request from warmHold
🌐 [CONNECT] Attempt #13 (loop 1/2) starting…
t=3044704 sess=9Hn lvl=INFO cat=stream evt=temp_key_fetch_start
⚡ [CACHE-HIT] Retrieved temp key in 0.6ms
t=3044705 sess=9Hn lvl=INFO cat=stream evt=temp_key_fetch latency_ms=0 expires_in_s=-1 source=cached
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🌐 [WS CONNECT] Using URL: wss://stt-rt.soniox.com/transcribe-websocket
🔗 [WS] Bound socket id=sock_6478855518580921444@attempt_13
t=3044705 sess=9Hn lvl=INFO cat=stream evt=ws_bind target_ip=resolving... via_proxy=false attempt=13 path=/transcribe-websocket socket=sock_6478855518580921444@attempt_13 target_host=stt-rt.soniox.com
🔑 Successfully connected to Soniox using temp key (2ms key latency)
t=3044707 sess=9Hn lvl=INFO cat=stream evt=ws_bind_resolved target_ip=129.146.176.251 via_proxy=false attempt=13 path=/transcribe-websocket socket=sock_6478855518580921444@attempt_13 target_host=stt-rt.soniox.com
🌐 [DEBUG] Proxy response received in 699ms
✅ [SSE] Parsed streaming response: 121 characters
🔍 [CONNECTION HEALTH]
🌐 [LANG DEBUG] Multi-language setting exists: true, Single language: en
🌐 [LANG DEBUG] Using multi-language selection (prioritized): zh, en
✅ Custom-prompt enhancement via proxy succeeded
t=3045350 sess=9Hn lvl=INFO cat=transcript evt=llm_final text="Open network. I don't think we're competing against anyone. The most common reason is they all have a number in common."
📊 [DETAILED STREAMING TIMING] Streaming: 548.4ms | Context: 0.0ms | LLM: 822.3ms | Tracked Overhead: 0.0ms | Unaccounted: 0.8ms | Total: 1371.6ms
🔊 [SoundManager] Attempting to play stop sound
🔊 [SoundManager] NSSound stop sound result: true
🧹 Connection cleanup completed (session resources released)
📝 [GRACE] Recording session ended
📱 Dismissing recorder
📊 [ENHANCEMENT] Tracking 23 words - currentTier: pro, trialWordsRemaining: 2552
✅ Streaming transcription processing completed
t=3045459 sess=9Hn lvl=INFO cat=transcript evt=insert_attempt target="Google Chrome" chars=120 text="Open network. I don't think we're competing against anyone. The most common reason is they all have a number in common. "
🔍 [PASTE DEBUG] AXIsProcessTrusted() returned true, proceeding
🔍 [PASTE DEBUG] UseDirectTextInsertion setting: false
🔍 [PASTE DEBUG] Direct insertion disabled, using clipboard paste
⌨️ Using CGEvent-based Command+V
t=3045460 sess=9Hn lvl=INFO cat=transcript evt=insert_result ok=true
📊 [POST-RELEASE E2E] 1481ms (finalize=506ms | llm=822ms | paste=0ms) | warm_socket=no
t=3045916 sess=9Hn lvl=INFO cat=stream evt=ws_handshake_metrics tls_ms=933 attempt=13 total_ms=1210 connect_ms=934 reused=false socket=sock_6478855518580921444@attempt_13 proxy=false protocol=http/1.1 dns_ms=1
🔌 WebSocket did open (sid=sock_6478855518580921444, attemptId=13)
🌐 [CONNECT] Attempt #13 succeeded
📤 [START] Sent start/config on standby socket (eager mode)
t=3045917 sess=9Hn lvl=INFO cat=stream evt=start_config ctx=standby_eager summary=["audio_format": "pcm_s16le", "ch": 1, "json_hash": "647d4d9a98bd6de5", "langs": 2, "valid": true, "model": "stt-rt-preview-v2", "ctx_len": 36, "sr": 16000] socket=sock_6478855518580921444@attempt_13 attempt=13
🧾 [START-CONFIG] ctx=standby_eager sum=["audio_format": "pcm_s16le", "ch": 1, "json_hash": "647d4d9a98bd6de5", "langs": 2, "valid": true, "model": "stt-rt-preview-v2", "ctx_len": 36, "sr": 16000]
📤 Sending text frame seq=7929
🧊 [STANDBY] Connected standby socket — keepalive every 10.0s, TTL=60s
🔌 [READY] attemptId=13 socketId=sock_6478855518580921444@attempt_13 start_text_sent=true
🧊 [STANDBY] WebSocket ready in 1216ms (handshake)
👂 [LISTENER] Standby listener task for socketId=sock_6478855518580921444@attempt_13 attemptId=13
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
✅ [CACHE] Context unchanged - reusing cache (1584 chars)
♻️ [SMART-CACHE] Using cached context: 1584 characters
🔥 [NER-CACHE] Triggering NER callback with cached content (1584 chars)
✅ [NER-CACHE] NER callback triggered with cached content
✅ [STANDBY->ACTIVE] Probe keepalive OK — proceeding to resume queue
⏹️ Keepalive timer stopped
🔄 Keepalive timer started (interval: 15.000000s)
🧪 [PROMO] snapshot attempt=13 socket=sock_6478855518580921444@attempt_13 start_sent=true ws_ready=true standby=false purpose=active cap_sr=16000 cap_ch=1 prebuf=0 last_fp=m=stt-rt-preview-v2|sr=16000|ch=1|h=en,zh|ctx=889740762234866296
t=3049004 sess=9Hn lvl=INFO cat=stream evt=temp_key_fetch_start
🔥 [PREWARM DEBUG] Pre-warming AI connection (target: Gemini), environment: flyio
⚡ [CACHE-HIT] Retrieved temp key in 1.8ms
t=3049006 sess=9Hn lvl=INFO cat=stream evt=temp_key_fetch latency_ms=1 source=cached expires_in_s=-1
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🧪 [PROMO] config_fp current=m=stt-rt-preview-v2|sr=16000|ch=1|h=en,zh|ctx=889740762234866296 last=m=stt-rt-preview-v2|sr=16000|ch=1|h=en,zh|ctx=889740762234866296
🎤 Registering audio tap for Soniox
t=3049026 sess=9Hn lvl=INFO cat=audio evt=record_start service=Soniox
🔍 Performing audio system pre-flight checks
throwing -10877
throwing -10877
✅ Pre-flight checks passed
t=3049102 sess=9Hn lvl=INFO cat=audio evt=tap_install ok=true backend=avcapture service=Soniox
t=3049102 sess=9Hn lvl=INFO cat=audio evt=record_start reason=start_capture
t=3049102 sess=9Hn lvl=INFO cat=audio evt=device_pin_start desired_name="MacBook Pro Microphone" prev_id=181 prev_name="MacBook Pro Microphone" prev_uid_hash=4285059772673450742 desired_id=181 desired_uid_hash=4285059772673450742
t=3049103 sess=9Hn lvl=INFO cat=audio evt=capture_backend_selected backend=avcapture
✅ Unified audio capture started
✅ Selected account account-bundle (connections: 1/10)
🎬 [NER-PREWARM] Using raw OCR text for NER: 1584 characters
🧠 [NER-DEFAULT] Using default NER prompt for general extraction
🧠 [TEN-VAD] Initialized (threshold=0.5, hop=256)
🚀 Starting Clio streaming transcription
🏥 [AUDIO HEALTH] Health monitoring timer started
⏱️ [TIMING] mic_engaged @ 1756226085.155
⏱️ [TIMING] WebSocket connect task completed — will flush after READY
pass
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
t=3049191 sess=9Hn lvl=INFO cat=audio evt=avcapture_start ok=true
t=3049192 sess=9Hn lvl=INFO cat=stream evt=first_audio_buffer_captured ms=57
🧪 [PROMO] first_audio seq=0 bytes=372 approx_db=-60.0
t=3049192 sess=9Hn lvl=INFO cat=audio evt=level avg_db=-60 peak_db=-60
✅ [AUDIO HEALTH] First audio data received - tap is functional
t=3049192 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=0
t=3049192 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=1 ready=true has_socket=true flushing=false bytes=372
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
t=3049205 sess=9Hn lvl=INFO cat=stream evt=first_audio_sent seq=1 ms=70
t=3049205 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true ready=true seq=2 bytes=360
t=3049205 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true ready=true seq=3 bytes=360
throwing -10877
throwing -10877
t=3049255 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=4 bytes=372 ready=true
t=3049255 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=5 bytes=372 ready=true
t=3049255 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=6 bytes=372 ready=true
t=3049255 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=7 bytes=372 ready=true
t=3049255 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=8 bytes=372 ready=true
t=3049265 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true has_socket=true seq=9
t=3049276 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true has_socket=true seq=10
t=3049288 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=11 has_socket=true flushing=false ready=true bytes=372
t=3049300 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true has_socket=true seq=12
t=3049311 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true ready=true seq=13
t=3049323 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=14 has_socket=true flushing=false ready=true bytes=372
t=3049335 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true has_socket=true seq=15
t=3049346 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=16 has_socket=true flushing=false ready=true bytes=372
t=3049358 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true has_socket=true seq=17
t=3049369 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true has_socket=true seq=18
t=3049381 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true has_socket=true seq=19
t=3049393 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=20 bytes=372 has_socket=true ready=true
t=3049404 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 has_socket=true seq=21
t=3049416 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false has_socket=true seq=22
t=3049427 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true ready=true seq=23 bytes=372
t=3049439 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=24 has_socket=true flushing=false ready=true bytes=372
t=3049451 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=25 has_socket=true flushing=false ready=true bytes=372
t=3049463 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 ready=true seq=26
🧪 [PROMO] audio_bytes bytes=10020
t=3049475 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=27 flushing=false bytes=372
t=3049486 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 ready=true seq=28
t=3049498 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=29 bytes=372
t=3049511 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=30 bytes=372
t=3049520 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 ready=true seq=31
t=3049533 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=32 bytes=372 has_socket=true flushing=false
t=3049544 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=33 has_socket=true flushing=false bytes=372 ready=true
t=3049556 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=34 bytes=372
t=3049569 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=35 bytes=372
t=3049579 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=36 bytes=372
t=3049591 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=37 bytes=372
t=3049603 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=38 bytes=372
t=3049613 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=39
t=3049627 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=40 has_socket=true ready=true flushing=false bytes=372
t=3049636 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=41 has_socket=true
t=3049648 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=42
🌐 [PATH] Initial path baseline set — no action
t=3049661 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=43 flushing=false bytes=372
t=3049671 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=44 bytes=372 has_socket=true flushing=false
t=3049685 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=45 flushing=false bytes=372
t=3049695 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=46 bytes=372 has_socket=true flushing=false
t=3049706 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true ready=true seq=47
t=3049719 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=48 flushing=false bytes=372
t=3049730 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=49 has_socket=true flushing=false bytes=372 ready=true
t=3049741 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=50 bytes=372
t=3049753 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=51 bytes=372 has_socket=true flushing=false
t=3049764 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=52 bytes=372
t=3049778 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=53 ready=true flushing=false bytes=372 has_socket=true
t=3049787 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 ready=true seq=54
t=3049799 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=55 flushing=false bytes=372
t=3049811 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=56 flushing=false bytes=372
🗣️ [TEN-VAD] Speech start detected
t=3049822 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 ready=true seq=57
t=3049836 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=58 bytes=372
t=3049846 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=59 bytes=372 has_socket=true flushing=false
t=3049857 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=60 bytes=372 has_socket=true flushing=false
t=3049870 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=61 ready=true flushing=false bytes=372 has_socket=true
t=3049881 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=62
t=3049893 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=63 bytes=372
t=3049904 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=64 bytes=372 has_socket=true flushing=false
t=3049915 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=65 flushing=false bytes=372
t=3049927 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=66 has_socket=true ready=true flushing=false bytes=372
t=3049938 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=67 bytes=372
t=3049953 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=68 flushing=false has_socket=true ready=true bytes=372
t=3049962 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=69 bytes=372
t=3049974 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=70 bytes=372
t=3049986 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=71
t=3049996 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=72 bytes=372
t=3050008 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=73 ready=true bytes=372
t=3050020 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=74 bytes=372
t=3050031 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=75 bytes=372
t=3050045 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=76 bytes=372 has_socket=true flushing=false
t=3050055 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=77 ready=true flushing=false bytes=372 has_socket=true
t=3050066 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=78 bytes=372
t=3050079 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=79 bytes=372 has_socket=true flushing=false
t=3050089 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=80 ready=true flushing=false bytes=372 has_socket=true
🧪 [PROMO] audio_bytes bytes=30108
t=3050103 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=81 flushing=false has_socket=true ready=true bytes=372
t=3050112 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=82 flushing=false bytes=372
t=3050125 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=83 bytes=372
t=3050138 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=84 bytes=372
t=3050148 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=85 bytes=372 has_socket=true flushing=false
t=3050161 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=86 ready=true flushing=false has_socket=true
t=3050171 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=87
t=3050183 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=88
t=3050194 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=89 ready=true flushing=false bytes=372 has_socket=true
t=3050205 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=90 bytes=372 flushing=false has_socket=true
t=3050218 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=91 flushing=false bytes=372
t=3050229 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=92 has_socket=true flushing=false ready=true bytes=372
t=3050240 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=93 has_socket=true flushing=false ready=true bytes=372
t=3050252 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=94 bytes=372
t=3050263 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=95 ready=true flushing=false bytes=372 has_socket=true
t=3050277 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=96 ready=true flushing=false bytes=372 has_socket=true
t=3050287 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true bytes=372 ready=true seq=97
t=3050299 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=98 bytes=372 has_socket=true flushing=false
t=3050311 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=99 flushing=false has_socket=true ready=true bytes=372
t=3050321 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=100 bytes=372 has_socket=true flushing=false
t=3050333 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=101 bytes=372
t=3050345 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=102 ready=true flushing=false bytes=372 has_socket=true
t=3050357 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=103 ready=true has_socket=true
t=3050369 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true bytes=372 ready=true seq=104
t=3050380 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=105 flushing=false bytes=372
t=3050391 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=106 bytes=372
t=3050403 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=107 ready=true flushing=false bytes=372 has_socket=true
t=3050415 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=108 has_socket=true flushing=false bytes=372
t=3050428 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=109 flushing=false bytes=372
t=3050438 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=110 bytes=372
t=3050449 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=111
t=3050461 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=112 bytes=372
t=3050473 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=113 bytes=372
t=3050485 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=114 flushing=false has_socket=true bytes=372
t=3050496 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=115 bytes=372
t=3050507 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=116 flushing=false bytes=372
t=3050519 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=117 bytes=372
t=3050530 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=118 ready=true flushing=false bytes=372 has_socket=true
t=3050544 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=119 bytes=372 ready=true
t=3050554 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=120 ready=true flushing=false bytes=372 has_socket=true
t=3050565 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=121
t=3050577 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=122 bytes=372 ready=true
t=3050588 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=123 ready=true flushing=false bytes=372 has_socket=true
t=3050601 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=124 ready=true bytes=372
t=3050612 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=125
t=3050623 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=126
t=3050636 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=127 flushing=false has_socket=true ready=true bytes=372
t=3050647 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=128 ready=true flushing=false has_socket=true bytes=372
t=3050660 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=129 ready=true flushing=false has_socket=true bytes=372
t=3050670 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=130 bytes=372 ready=true
t=3050681 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=131
t=3050694 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=132 ready=true has_socket=true
t=3050705 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=133 flushing=false has_socket=true ready=true bytes=372
t=3050716 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=134 flushing=false has_socket=true ready=true bytes=372
t=3050728 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=135 has_socket=true bytes=372 ready=true flushing=false
t=3050739 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=136 bytes=372 has_socket=true flushing=false
t=3050752 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=137 bytes=372
t=3050763 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=138 flushing=false has_socket=true ready=true bytes=372
t=3050777 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=139 ready=true has_socket=true
t=3050786 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true ready=true seq=140
t=3050798 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=141 bytes=372 has_socket=true flushing=false
t=3050809 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=142 bytes=372 has_socket=true flushing=false
t=3050821 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=143 bytes=372 has_socket=true flushing=false
t=3050832 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=144 bytes=372
t=3050844 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=145 bytes=372 has_socket=true flushing=false
t=3050856 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=146 has_socket=true bytes=372 ready=true flushing=false
t=3050867 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=147 flushing=false has_socket=true ready=true bytes=372
t=3050879 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=148 bytes=372 has_socket=true flushing=false
t=3050891 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=149 ready=true has_socket=true
t=3050902 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=150 bytes=372
t=3050913 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=151 bytes=372
t=3050926 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=152 bytes=372 has_socket=true flushing=false
t=3050937 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=153 has_socket=true ready=true flushing=false bytes=372
t=3050948 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=154 flushing=false has_socket=true ready=true bytes=372
t=3050960 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true ready=true seq=155
t=3050972 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=156 ready=true flushing=false bytes=372 has_socket=true
t=3050983 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=157 flushing=false has_socket=true ready=true bytes=372
t=3050995 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=158 bytes=372
t=3051006 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=159 ready=true flushing=false bytes=372 has_socket=true
t=3051019 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true ready=true seq=160
t=3051030 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=161 flushing=false
t=3051041 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true ready=true seq=162
t=3051053 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=163 bytes=372 has_socket=true flushing=false
t=3051065 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=164 bytes=372 has_socket=true flushing=false
t=3051077 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=165 flushing=false has_socket=true ready=true bytes=372
t=3051088 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=166 flushing=false has_socket=true ready=true bytes=372
t=3051099 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true ready=true seq=167
t=3051112 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=168 flushing=false has_socket=true ready=true bytes=372
t=3051123 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=169 ready=true has_socket=true
t=3051134 sess=9Hn lvl=INFO cat=stream evt=first_partial ms=2001
t=3051134 sess=9Hn lvl=INFO cat=stream evt=ttft_hotkey ms=2001
t=3051134 sess=9Hn lvl=INFO cat=stream evt=ttft ms=1323
🧪 [PROMO] first_token ms=2131 tokens_in_msg=3
t=3051134 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 seq=170 ready=true
t=3051192 sess=9Hn lvl=INFO cat=audio evt=level peak_db=-36 avg_db=-36
t=3051192 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=171 ready=true has_socket=true
t=3051192 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=172 ready=true has_socket=true
t=3051192 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=173 ready=true has_socket=true
t=3051192 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=174 ready=true has_socket=true
t=3051193 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=175 ready=true has_socket=true
t=3051204 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=176
t=3051215 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=177
t=3051227 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=178 bytes=372 has_socket=true ready=true
t=3051238 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 has_socket=true seq=179
t=3051250 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=180 bytes=372
t=3051262 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 flushing=false seq=181
t=3051306 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true has_socket=true bytes=372 seq=182
t=3051306 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true has_socket=true bytes=372 seq=183
t=3051306 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true has_socket=true bytes=372 seq=184
t=3051308 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=185 flushing=false
t=3051320 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=186 flushing=false
t=3051331 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=187 bytes=372 has_socket=true
t=3051343 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=188 bytes=372
t=3051355 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=189 bytes=372
t=3051366 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=190 ready=true has_socket=true bytes=372
t=3051378 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=191 ready=true flushing=false bytes=372 has_socket=true
t=3051390 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=192
t=3051401 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true ready=true seq=193
t=3051413 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true ready=true seq=194
t=3051425 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=195
t=3051436 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=196 ready=true flushing=false bytes=372 has_socket=true
t=3051448 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=197 ready=true flushing=false bytes=372 has_socket=true
t=3051459 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=198 has_socket=true ready=true flushing=false
t=3051471 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=199
t=3051483 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=200 flushing=false has_socket=true ready=true bytes=372
t=3051494 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true ready=true seq=201
t=3051506 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=202 bytes=372
t=3051518 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=203 ready=true bytes=372 has_socket=true flushing=false
t=3051563 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=204 flushing=false has_socket=true
t=3051563 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=205 flushing=false has_socket=true
t=3051563 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=206 flushing=false has_socket=true
t=3051563 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true seq=207 flushing=false
t=3051575 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=208
t=3051587 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=209
t=3051598 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=210 has_socket=true flushing=false ready=true bytes=372
t=3051610 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=211 ready=true
t=3051622 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=212 ready=true has_socket=true
t=3051633 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=213 bytes=372
t=3051645 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=214 ready=true flushing=false bytes=372 has_socket=true
t=3051694 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=215
t=3051695 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=216
t=3051695 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=217
t=3051695 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=218
t=3051703 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=219 ready=true flushing=false bytes=372 has_socket=true
t=3051715 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=220 flushing=false bytes=372
t=3051726 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 seq=221 ready=true flushing=false
t=3051738 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=222 ready=true flushing=false bytes=372 has_socket=true
t=3051749 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=223 ready=true has_socket=true flushing=false
t=3051761 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 seq=224 ready=true
t=3051802 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=225 bytes=372 has_socket=true ready=true
t=3051802 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=226 bytes=372 has_socket=true ready=true
t=3051802 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=227 bytes=372 has_socket=true ready=true
t=3051807 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true has_socket=true seq=228
t=3051819 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=229 bytes=372 ready=true
t=3051831 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=230 ready=true has_socket=true flushing=false
t=3051842 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=231 has_socket=true flushing=false ready=true bytes=372
t=3051854 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true has_socket=true seq=232
t=3051865 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=233 bytes=372 ready=true
t=3051877 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=234 bytes=372 has_socket=true ready=true
t=3051889 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=235
t=3051926 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 seq=236 flushing=false
t=3051926 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 seq=237 flushing=false
t=3051926 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 seq=238 flushing=false
t=3051935 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false has_socket=true seq=239
t=3051947 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true seq=240 bytes=372 flushing=false ready=true
t=3051958 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=241
t=3051970 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=242
t=3051981 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=243 flushing=false
t=3051993 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=244 flushing=false ready=true has_socket=true
t=3052034 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=245 bytes=372 has_socket=true ready=true
t=3052034 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=246 bytes=372 has_socket=true ready=true
t=3052034 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=247 bytes=372 has_socket=true ready=true
🛑 [TEN-VAD] Speech end detected
t=3052039 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=248 has_socket=true bytes=372 ready=true
t=3052051 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=249
🤖 [FLY.IO-NER] Server-reported provider: gemini
📥 [NER-STORE] Stored NER entities: 2563 chars - The user is providing information about their active window on YouTube and asking for assistance. Th...
✅ [FLY.IO] NER refresh completed successfully
t=3052063 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=250 bytes=372 has_socket=true ready=true
t=3052074 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=251 has_socket=true bytes=372 ready=true
t=3052086 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=252 flushing=false
t=3052097 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=253 bytes=372 ready=true
🛑 [TEN-VAD] Speech end detected
t=3052109 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=254 bytes=372 has_socket=true ready=true
t=3052121 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=255 bytes=372
t=3052133 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=256 bytes=372 has_socket=true flushing=false
t=3052144 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=257 ready=true flushing=false bytes=372 has_socket=true
t=3052156 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=258 ready=true flushing=false bytes=372 has_socket=true
t=3052207 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true ready=true seq=259
t=3052207 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true ready=true seq=260
t=3052207 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true ready=true seq=261
t=3052208 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true ready=true seq=262
t=3052214 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=263 bytes=372 has_socket=true ready=true
t=3052225 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=264 has_socket=true bytes=372 ready=true
t=3052237 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true has_socket=true seq=265
t=3052248 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=266 bytes=372 ready=true
t=3052260 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=267 has_socket=true bytes=372 ready=true
t=3052272 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=268 bytes=372 has_socket=true flushing=false
t=3052284 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=269 flushing=false bytes=372
t=3052333 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=270 bytes=372
t=3052333 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=271 bytes=372
t=3052333 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=272 bytes=372
t=3052333 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=273 bytes=372
t=3052341 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true seq=274 has_socket=true bytes=372
t=3052353 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=275 bytes=372 has_socket=true ready=true
t=3052365 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=276
t=3052376 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=277
t=3052388 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=278 bytes=372 ready=true
t=3052399 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=279
t=3052434 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=280
t=3052434 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=281
t=3052435 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=282 bytes=372
t=3052446 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=283 ready=true bytes=372
t=3052458 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=284 has_socket=true ready=true
t=3052469 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false ready=true seq=285
t=3052481 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=286 ready=true flushing=false has_socket=true bytes=372
t=3052514 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=287 bytes=372
t=3052514 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=288 bytes=372
t=3052515 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 seq=289 has_socket=true
t=3052527 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=290
t=3052539 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=291 has_socket=true bytes=372 ready=true flushing=false
t=3052550 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=292 ready=true has_socket=true
t=3052562 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=293
t=3052574 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=294 bytes=372
t=3052585 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=295 bytes=372
t=3052597 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true has_socket=true seq=296
t=3052608 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true bytes=372 ready=true seq=297
t=3052643 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false ready=true seq=298
t=3052643 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false ready=true seq=299
t=3052643 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false ready=true seq=300
t=3052655 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=301 ready=true has_socket=true
t=3052666 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=302 has_socket=true
t=3052678 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=303 ready=true has_socket=true
t=3052690 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false ready=true seq=304
t=3052701 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=305 has_socket=true flushing=false ready=true
t=3052742 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=306 has_socket=true flushing=false ready=true
t=3052742 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=307 has_socket=true flushing=false ready=true
t=3052742 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=308 has_socket=true flushing=false ready=true
t=3052748 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=309 has_socket=true ready=true
t=3052759 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=310 has_socket=true ready=true flushing=false
t=3052771 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=311 bytes=372 has_socket=true ready=true
t=3052783 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 ready=true flushing=false seq=312
t=3052794 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false has_socket=true seq=313
t=3052806 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=314 bytes=372 has_socket=true ready=true
t=3052817 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=315 flushing=false
t=3052860 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=316 ready=true bytes=372 has_socket=true flushing=false
t=3052860 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=317 ready=true bytes=372 has_socket=true flushing=false
t=3052860 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=318 ready=true bytes=372 has_socket=true flushing=false
t=3052864 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true has_socket=true bytes=372 seq=319
t=3052875 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=320 bytes=372 has_socket=true
t=3052887 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=321
t=3052899 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=322 bytes=372 ready=true
t=3052910 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true has_socket=true seq=323
t=3052922 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=324
t=3052933 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=325 bytes=372 has_socket=true
t=3052945 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=326
t=3052957 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=327 has_socket=true flushing=false ready=true bytes=372
t=3052968 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true has_socket=true seq=328
t=3052980 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=329 ready=true flushing=false has_socket=true
t=3052992 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=330
t=3053003 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=331 ready=true flushing=false
t=3053015 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=332 bytes=372
t=3053026 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=333 flushing=false has_socket=true ready=true bytes=372
t=3053038 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=334 bytes=372 has_socket=true flushing=false
t=3053050 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=335 ready=true flushing=false bytes=372 has_socket=true
t=3053061 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=336 flushing=false has_socket=true ready=true bytes=372
t=3053074 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=337 flushing=false has_socket=true
t=3053085 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=338 bytes=372
t=3053096 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=339 ready=true flushing=false bytes=372 has_socket=true
t=3053109 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=340 bytes=372 has_socket=true flushing=false
t=3053120 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=341 flushing=false has_socket=true ready=true bytes=372
t=3053132 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=342 bytes=372 has_socket=true flushing=false
t=3053143 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=343 flushing=false has_socket=true ready=true bytes=372
t=3053155 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=344 ready=true flushing=false bytes=372 has_socket=true
t=3053166 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=345 ready=true flushing=false bytes=372 has_socket=true
t=3053178 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=346
t=3053190 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=347 bytes=372
t=3053201 sess=9Hn lvl=INFO cat=audio evt=level avg_db=-40 peak_db=-40
t=3053201 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=348 flushing=false has_socket=true ready=true bytes=372
t=3053213 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=349
t=3053224 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=350 flushing=false has_socket=true ready=true bytes=372
t=3053236 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=351 bytes=372 has_socket=true flushing=false
t=3053248 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=352 bytes=372
t=3053321 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=353
t=3053321 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=354
t=3053321 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=355
t=3053321 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=356
t=3053321 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=357
t=3053321 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=358
t=3053328 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=359 ready=true
t=3053340 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=360
t=3053351 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=361 flushing=false
t=3053363 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=362 flushing=false
t=3053376 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true seq=363 flushing=false bytes=372
t=3053386 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=364 has_socket=true ready=true
t=3053398 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=365 ready=true
t=3053410 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true seq=366 flushing=false bytes=372
t=3053421 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=367 ready=true
t=3053433 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=368 flushing=false
t=3053445 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true seq=369 bytes=372
t=3053457 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=370 bytes=372
t=3053468 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false seq=371 has_socket=true
t=3053480 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=372 bytes=372
t=3053491 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=373 bytes=372 has_socket=true flushing=false
t=3053503 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=374 bytes=372 has_socket=true flushing=false
t=3053515 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false seq=375 has_socket=true
t=3053581 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 seq=376 has_socket=true
t=3053581 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 seq=377 has_socket=true
t=3053581 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 seq=378 has_socket=true
t=3053581 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 seq=379 has_socket=true
t=3053581 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 seq=380 has_socket=true
t=3053584 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=381
t=3053595 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=382
t=3053607 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=383
t=3053618 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=384
t=3053630 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=385
t=3053642 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=386
t=3053653 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=387
t=3053665 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=388
t=3053679 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=389
t=3053688 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=390 flushing=false
t=3053703 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=391 ready=true flushing=false bytes=372 has_socket=true
t=3053712 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=392 ready=true flushing=false bytes=372 has_socket=true
t=3053724 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=393 has_socket=true
t=3053736 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=394 ready=true flushing=false bytes=372 has_socket=true
t=3053801 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=395 bytes=372 has_socket=true
t=3053801 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=396 bytes=372 has_socket=true
t=3053801 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=397 bytes=372 has_socket=true
t=3053801 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=398 bytes=372 has_socket=true
t=3053801 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=399 bytes=372 has_socket=true
t=3053804 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=400 bytes=372 has_socket=true
t=3053816 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=401 has_socket=true ready=true
t=3053828 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=402
t=3053839 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=403 bytes=372 has_socket=true ready=true
t=3053851 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=404 has_socket=true ready=true
t=3053863 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true has_socket=true seq=405 flushing=false bytes=372
t=3053874 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=406 bytes=372 has_socket=true ready=true
t=3053886 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=407
t=3053897 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=408 bytes=372 has_socket=true ready=true
t=3053910 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 seq=409 flushing=false
t=3053921 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=410
t=3053933 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=411 bytes=372
t=3053945 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=412 bytes=372 has_socket=true flushing=false
t=3054019 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=413 bytes=372 has_socket=true ready=true
t=3054019 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=414 bytes=372 has_socket=true ready=true
t=3054019 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=415 bytes=372 has_socket=true ready=true
t=3054019 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=416 bytes=372 has_socket=true ready=true
t=3054019 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=417 bytes=372 has_socket=true ready=true
t=3054020 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=418 bytes=372 has_socket=true ready=true
t=3054025 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=419
t=3054064 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=420 bytes=372 has_socket=true
t=3054064 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=421 bytes=372 has_socket=true
t=3054064 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=422 bytes=372 has_socket=true
t=3054071 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=423 bytes=372 has_socket=true ready=true
t=3054083 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=424
t=3054095 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=425 bytes=372 ready=true
t=3054106 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=426 bytes=372 has_socket=true ready=true
t=3054118 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=427 bytes=372 has_socket=true
throwing -10877
throwing -10877
t=3054169 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=428
t=3054169 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=429
t=3054169 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=430
t=3054169 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=431
t=3054176 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true has_socket=true seq=432
t=3054204 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=433
t=3054204 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=434
t=3054211 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=435
t=3054222 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=436
t=3054234 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=437 bytes=372 ready=true has_socket=true
t=3054246 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=438 ready=true
t=3054257 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=439
t=3054283 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=440 has_socket=true flushing=false ready=true bytes=372
t=3054283 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=441 has_socket=true flushing=false ready=true bytes=372
t=3054293 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 seq=442 flushing=false
t=3054303 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true has_socket=true seq=443
t=3054315 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=444 has_socket=true flushing=false ready=true bytes=372
t=3054327 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=445 has_socket=true bytes=372 ready=true
t=3054338 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=446 has_socket=true flushing=false ready=true bytes=372
t=3054350 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=447 has_socket=true bytes=372 ready=true
t=3054361 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true has_socket=true seq=448
t=3054373 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=449 has_socket=true bytes=372 ready=true
t=3054385 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=450 has_socket=true bytes=372 ready=true
🛑 [TEN-VAD] Speech end detected
t=3054415 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true has_socket=true seq=451 flushing=false
t=3054415 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 ready=true has_socket=true seq=452 flushing=false
t=3054420 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false seq=453 ready=true
t=3054431 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=454
t=3054443 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=455 ready=true bytes=372
t=3054454 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=456
t=3054466 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=457
t=3054478 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=458
t=3054489 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=459
t=3054501 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false seq=460 ready=true
t=3054513 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=461 bytes=372 ready=true
t=3054550 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 seq=462 flushing=false ready=true
t=3054550 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 seq=463 flushing=false ready=true
t=3054550 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 seq=464 flushing=false ready=true
t=3054559 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 seq=465 flushing=false ready=true
t=3054571 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=466 bytes=372 ready=true
t=3054582 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=467 bytes=372 ready=true
t=3054594 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 seq=468 flushing=false ready=true
t=3054606 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=469 has_socket=true bytes=372 ready=true
t=3054617 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=470 has_socket=true flushing=false ready=true bytes=372
t=3054629 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=471 has_socket=true bytes=372 ready=true
t=3054640 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 seq=472 flushing=false ready=true
t=3054652 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=473 has_socket=true bytes=372 ready=true
t=3054664 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=474
t=3054676 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=475 bytes=372 ready=true
t=3054687 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=476 bytes=372
t=3054699 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=477 ready=true has_socket=true
t=3054711 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=478 bytes=372 has_socket=true flushing=false
t=3054722 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=479 ready=true bytes=372
t=3054734 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=480 bytes=372
t=3054745 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=481 bytes=372
t=3054757 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=482 ready=true flushing=false bytes=372 has_socket=true
t=3054769 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=483 bytes=372 has_socket=true flushing=false
t=3054780 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true seq=484 bytes=372 flushing=false has_socket=true
t=3054792 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=485
t=3054804 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=486
t=3054815 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=487 flushing=false has_socket=true ready=true bytes=372
t=3054828 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=488 ready=true
t=3054838 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=489
t=3054850 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=490 ready=true bytes=372
t=3054862 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=491 ready=true flushing=false bytes=372 has_socket=true
t=3054873 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true ready=true seq=492
t=3054885 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=493 bytes=372
t=3054896 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=494 ready=true flushing=false bytes=372 has_socket=true
t=3054957 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true bytes=372 ready=true seq=495
t=3054958 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true bytes=372 ready=true seq=496
t=3054958 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true bytes=372 ready=true seq=497
t=3054958 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true bytes=372 ready=true seq=498
t=3054958 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true bytes=372 ready=true seq=499
t=3054965 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=500 has_socket=true ready=true
t=3054977 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=501 flushing=false bytes=372
t=3054989 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=502 bytes=372 has_socket=true
t=3055000 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=503 flushing=false bytes=372
t=3055012 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=504 bytes=372 has_socket=true
t=3055023 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=505
t=3055065 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=506
t=3055065 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=507
t=3055065 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=508
t=3055070 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=509 bytes=372 has_socket=true ready=true
t=3055082 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=510 has_socket=true bytes=372 ready=true
t=3055093 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=511 bytes=372 has_socket=true
t=3055105 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=512 has_socket=true bytes=372 ready=true
t=3055116 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=513
t=3055128 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=514 bytes=372 has_socket=true ready=true
t=3055140 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=515 bytes=372 has_socket=true ready=true
t=3055151 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true has_socket=true seq=516
t=3055194 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=517
t=3055194 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=518
t=3055194 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=519
t=3055197 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=520 bytes=372 has_socket=true ready=true
t=3055209 sess=9Hn lvl=INFO cat=audio evt=level avg_db=-48 peak_db=-48
t=3055210 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=521 has_socket=true bytes=372 ready=true
t=3055221 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=522 bytes=372 has_socket=true ready=true
t=3055232 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=523 has_socket=true bytes=372 ready=true
t=3055244 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=524
t=3055255 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=525 has_socket=true bytes=372 ready=true
t=3055267 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=526 bytes=372 has_socket=true ready=true
t=3055279 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=527
t=3055318 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=528 ready=true flushing=false
t=3055318 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=529 ready=true flushing=false
t=3055318 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=530 ready=true flushing=false
t=3055326 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=531 ready=true has_socket=true flushing=false
t=3055337 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=532
t=3055377 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=533 bytes=372
t=3055377 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=534 bytes=372
t=3055377 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=535 bytes=372
t=3055383 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=536 has_socket=true bytes=372 ready=true
t=3055395 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=537 has_socket=true ready=true flushing=false bytes=372
t=3055406 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=538 has_socket=true ready=true bytes=372
t=3055418 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=539
t=3055430 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=540 bytes=372 has_socket=true
t=3055441 sess=9Hn lvl=INFO cat=stream evt=pre_send flushing=false seq=541 has_socket=true ready=true bytes=372
t=3055453 sess=9Hn lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=542 bytes=372 has_socket=true
t=3055465 sess=9Hn lvl=INFO cat=stream evt=pre_send bytes=372 seq=543 ready=true has_socket=true flushing=false
🛑 Stopping recording
🛑 Stopping Clio streaming transcription
🏥 [AUDIO HEALTH] Health monitoring timer stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
🛑 Stopping unified audio capture
t=3055529 sess=9Hn lvl=INFO cat=audio evt=record_stop
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key plugInPackage
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key CMIOType
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key numberOfDevices
t=3055538 sess=9Hn lvl=INFO cat=audio evt=avcapture_stop
✅ Unified audio capture stopped
t=3055539 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=544 ready=true flushing=false has_socket=true bytes=372
t=3055539 sess=9Hn lvl=INFO cat=stream evt=pre_send seq=545 ready=true flushing=false has_socket=true bytes=372
t=3055569 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=546 bytes=372
t=3055569 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=547 bytes=372
t=3055569 sess=9Hn lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=548 bytes=372
📤 Sent end-of-stream signal
📤 Sent manual finalize command
🕐 Using finalization timeout: 400ms (connection took 6535ms)
ℹ️ [OPTIMISTIC] Not skipping: end=false pending=0 ms_since_last=93 tail=100 silence_ok=false tokens_quiet_ok=false partial_empty=false uncond=false
t=3056019 sess=9Hn lvl=INFO cat=stream evt=first_final ms=6889
t=3056019 sess=9Hn lvl=INFO cat=transcript evt=raw_final text="We have"
t=3056044 sess=9Hn lvl=INFO cat=transcript evt=raw_final text=" no numbers on this platform because it's purely agent-to-agent.<end>"
🏁 Received <fin> token - finalization complete
✅ Received <fin> token after 449ms
⏹️ Keepalive timer stopped
⚡ Audio capture already stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
📉 Released connection for account account-bundle (connections: 0)
💾 [COLD-START] Updated successful streaming timestamp
💾 [COLD-START] Updated successful streaming timestamp
✅ Streaming stopped. Final transcript (71 chars, 7.0s, with audio file): "We have no numbers on this platform because it's purely agent-to-agent."
t=3056117 sess=9Hn lvl=INFO cat=transcript evt=final text="We have no numbers on this platform because it's purely agent-to-agent."
t=3056117 sess=9Hn lvl=INFO cat=transcript evt=session_end divider="────────── session end ──────────"
🌡️ [WARM] warm_socket=yes
⏹️ Keepalive timer stopped
🔌 [WS] Disconnected (socketId=sock_6478855518580921444@attempt_13)
⚠️ WebSocket did close with code 1001 (sid=sock_6478855518580921444, attemptId=13)
t=3056120 sess=9Hn lvl=WARN cat=stream evt=state code=1001 state=closed
✅ Streaming transcription completed successfully, length: 71 characters
⏱️ [TIMING] Subscription tracking: 0.3ms
⏱️ [TIMING] ASR word tracking: 0.0ms
🧠 Performing intelligent end-context detection for streaming
⏱️ [CONTEXT DETAIL] Cache check: 0.0ms
⚡ [SMART-OPTIMIZATION] Using smart cached screen context (1584 chars) - skipping new capture
⏱️ [STREAMING CONTEXT TIMING] Screen capture + context detection: 0.0ms
🎯 Starting dynamic context-aware AI enhancement with tracking for text (71 characters)
⚡ [FAST-PATH] Using pre-warmed context - skipping redundant detection
⚡ [PREWARMED] Using pre-warmed NER context fast-path
🔍 [REGISTRY] Starting context detection using new rule engine
🔍 [REGISTRY] Bundle ID: com.google.Chrome
🔍 [REGISTRY] Process name: nil
🔍 [REGISTRY] URL: nil
🔍 [REGISTRY] Window title: (17) A Yale Student Raised $3.1M in 2 Weeks for an AI Social App | Series, Nathaneo Johnson - YouTube
🔍 [REGISTRY] Content length: 1584 chars
🎯 [RULE-ENGINE] Cache hit for com.google.Chrome|||(17) A Yale Student Raised $3.1M in 2 Weeks for an AI Social App | Series, Nathaneo Johnson - YouTube
🔄 [REGISTRY] Rule engine returned .none, checking for high-confidence legacy matches only
🔄 [REGISTRY] Trying legacy Email detector (priority: 100)
📧 [EMAIL] Starting email context detection
🚫 [DYNAMIC] Email exclusion detected in content: excluding from detection
🔄 [REGISTRY] Trying legacy Code Review detector (priority: 90)
💻 [CODE] Starting code context detection
❌ [CODE] Code confidence too low: 0.000000 < 0.300000
🔄 [REGISTRY] Trying legacy Social Media detector (priority: 10)
💬 [CHAT] Starting casual chat context detection
💬 [CHAT] Casual chat context detected - Title matches: 1, Content matches: 4, Confidence: 0.280000
🚫 [REGISTRY] Legacy Social Media context rejected - rule engine returned .none and confidence not high enough (0.280000 < 0.800000)
📝 [REGISTRY] Rule engine returned .none and no high-confidence legacy matches, returning general context
📝 [PREWARMED] Non-code or unknown context → using enhanced system prompt
🚨 [PROMPT-DEBUG] About to call getSystemMessage(for: .transcriptionEnhancement)
🚨 [PROMPT-DEBUG] getSystemMessage called with mode: transcriptionEnhancement
🚨 [PROMPT-DEBUG] RETURNING TRANSCRIPTION ENHANCEMENT PROMPT
🌐 [LANG DEBUG] Multi-language setting exists: true, Single language: en
🌐 [LANG DEBUG] Using multi-language selection (prioritized): zh, en
🚨 [PROMPT-DEBUG] About to call getUserMessage(text:, mode: .transcriptionEnhancement)
🌐 [LANG DEBUG] Multi-language setting exists: true, Single language: en
🌐 [LANG DEBUG] Using multi-language selection (prioritized): zh, en
🌐 [LANG DEBUG] Multi-language setting exists: true, Single language: en
🌐 [LANG DEBUG] Using multi-language selection (prioritized): zh, en
📝 [PREWARMED-SYSTEM] Enhanced system prompt: 'You are an expert in enhancing the text provided within <TRANSCRIPT> tags according to the following guidelines: The information in <CONTEXT_INFORMATI...'
📝 [PREWARMED-USER] Enhanced user prompt: '<CONTEXT_INFORMATION>
NER Context Entities:
The user is providing information about their active window on YouTube and asking for assistance. The cont...'
System Message: You are an expert in enhancing the text provided within <TRANSCRIPT> tags according to the following guidelines: The information in <CONTEXT_INFORMATION> section is ONLY for reference.

### INSTRUCTIO…
User Message: <CONTEXT_INFORMATION>
NER Context Entities:
The user is providing information about their active window on YouTube and asking for assistance. The content of the YouTube video is about a Yale student r…
🌐 Sending custom-prompt request to LLM proxy (provider auto-selected by server)...
🔑 [DEBUG] Getting JWT token...
🔑 [DEBUG] JWT token obtained in 0ms
🎯 [CONFIG-DEBUG] Config 2: Routing to Groq endpoint (https://fly.cliovoice.com/api/llm/proxy) with model: qwen
📝 [TIMING] Request preparation: 0.1ms
🌐 [DEBUG] Sending request to proxy...
🌐 [CONNECT] New single-flight request from warmHold
🌐 [CONNECT] Attempt #14 (loop 1/2) starting…
t=3056263 sess=9Hn lvl=INFO cat=stream evt=temp_key_fetch_start
⚡ [CACHE-HIT] Retrieved temp key in 0.1ms
t=3056263 sess=9Hn lvl=INFO cat=stream evt=temp_key_fetch latency_ms=0 source=cached expires_in_s=-1
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🌐 [WS CONNECT] Using URL: wss://stt-rt.soniox.com/transcribe-websocket
🔗 [WS] Bound socket id=sock_8267799665693305298@attempt_14
t=3056264 sess=9Hn lvl=INFO cat=stream evt=ws_bind target_host=stt-rt.soniox.com target_ip=resolving... via_proxy=false attempt=14 socket=sock_8267799665693305298@attempt_14 path=/transcribe-websocket
🔑 Successfully connected to Soniox using temp key (22ms key latency)
t=3056286 sess=9Hn lvl=INFO cat=stream evt=ws_bind_resolved target_host=stt-rt.soniox.com attempt=14 target_ip=129.146.176.251 via_proxy=false path=/transcribe-websocket socket=sock_8267799665693305298@attempt_14
🌐 [DEBUG] Proxy response received in 672ms
✅ [SSE] Parsed streaming response: 75 characters
🔍 [CONNECTION HEALTH]
🌐 [LANG DEBUG] Multi-language setting exists: true, Single language: en
🌐 [LANG DEBUG] Using multi-language selection (prioritized): zh, en
✅ Custom-prompt enhancement via proxy succeeded
t=3056884 sess=9Hn lvl=INFO cat=transcript evt=llm_final text="We have no numbers on this platform because it's purely agent-to-agent."
📊 [DETAILED STREAMING TIMING] Streaming: 623.0ms | Context: 0.0ms | LLM: 763.2ms | Tracked Overhead: 0.0ms | Unaccounted: 0.9ms | Total: 1387.2ms
🔊 [SoundManager] Attempting to play stop sound
🔊 [SoundManager] NSSound stop sound result: true
🧹 Connection cleanup completed (session resources released)
📝 [GRACE] Recording session ended
📱 Dismissing recorder
📊 [ENHANCEMENT] Tracking 14 words - currentTier: pro, trialWordsRemaining: 2552
✅ Streaming transcription processing completed
t=3057015 sess=9Hn lvl=INFO cat=transcript evt=insert_attempt target="Google Chrome" chars=72 text="We have no numbers on this platform because it's purely agent-to-agent. "
🔍 [PASTE DEBUG] AXIsProcessTrusted() returned true, proceeding
🔍 [PASTE DEBUG] UseDirectTextInsertion setting: false
🔍 [PASTE DEBUG] Direct insertion disabled, using clipboard paste
⌨️ Using CGEvent-based Command+V
t=3057016 sess=9Hn lvl=INFO cat=transcript evt=insert_result ok=true
📊 [POST-RELEASE E2E] 1519ms (finalize=571ms | llm=763ms | paste=0ms) | warm_socket=no
t=3057455 sess=9Hn lvl=INFO cat=stream evt=ws_handshake_metrics tls_ms=917 attempt=14 total_ms=1191 connect_ms=924 reused=false socket=sock_8267799665693305298@attempt_14 proxy=false protocol=http/1.1 dns_ms=0
🔌 WebSocket did open (sid=sock_8267799665693305298, attemptId=14)
🌐 [CONNECT] Attempt #14 succeeded
📤 [START] Sent start/config on standby socket (eager mode)
t=3057457 sess=9Hn lvl=INFO cat=stream evt=start_config socket=sock_8267799665693305298@attempt_14 attempt=14 summary=["valid": true, "sr": 16000, "audio_format": "pcm_s16le", "ctx_len": 36, "model": "stt-rt-preview-v2", "json_hash": "74c88fa4ee9a34f7", "langs": 2, "ch": 1] ctx=standby_eager
🧾 [START-CONFIG] ctx=standby_eager sum=["valid": true, "sr": 16000, "audio_format": "pcm_s16le", "ctx_len": 36, "model": "stt-rt-preview-v2", "json_hash": "74c88fa4ee9a34f7", "langs": 2, "ch": 1]
📤 Sending text frame seq=8479
🧊 [STANDBY] Connected standby socket — keepalive every 10.0s, TTL=60s
🔌 [READY] attemptId=14 socketId=sock_8267799665693305298@attempt_14 start_text_sent=true
🧊 [STANDBY] WebSocket ready in 1196ms (handshake)
👂 [LISTENER] Standby listener task for socketId=sock_8267799665693305298@attempt_14 attemptId=14