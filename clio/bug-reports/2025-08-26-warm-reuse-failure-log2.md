## 1 Success
📱 Showing DynamicNotch recorder (MIT licensed)
🧊 [WARMUP] Skipping (recently run) context=recorderUIShown
🎤 [toggleRecord] Starting recording, current model: soniox-realtime-streaming
🧊 [WARMUP] Skipping (recently run) context=hotkeyDown
🎙️ Starting recording sequence...
📝 [GRACE] Recording session started with 2552 words remaining
🔧 [NER-SETUP] Setting up callback - contextService exists: true
✅ [NER-SETUP] OCR completion callback configured for NER pre-warming - callback exists: true
🔊 Waking up audio system after 365s idle time
⏰ [CACHE] Cache is stale (age: 364.5s, ttl=120s)
🎬 Starting screen capture with verified permissions
🎯 Clio — clean.swift
🌐 [LANG DEBUG] Multi-language setting exists: true, Single language: en
🌐 [LANG DEBUG] Using multi-language selection (prioritized): zh, en
🌐 Using selected languages for OCR: zh-Hans, en-US
📊 [SESSION] Starting recording session #12
🧪 [A/B] warm_socket=yes
🎤 Registering audio tap for Soniox
t=1213335 sess=I7F lvl=INFO cat=audio evt=record_start service=Soniox
🔍 Performing audio system pre-flight checks
throwing -10877
throwing -10877
✅ Pre-flight checks passed
t=1213429 sess=I7F lvl=INFO cat=audio evt=tap_install backend=avcapture ok=true service=Soniox
t=1213429 sess=I7F lvl=INFO cat=audio evt=record_start reason=start_capture
t=1213429 sess=I7F lvl=INFO cat=audio evt=device_pin_start desired_id=181 desired_uid_hash=-1685521486385182984 prev_id=181 prev_uid_hash=-1685521486385182984 desired_name="MacBook Pro Microphone" prev_name="MacBook Pro Microphone"
❄️ Cold start detected - performing full initialization
❄️ Performing cold start initialization
⏭️ Skipping engine cold start (backend=AVCapture)
t=1213431 sess=I7F lvl=INFO cat=audio evt=capture_backend_selected backend=avcapture
✅ Unified audio capture started
✅ Selected account account-bundle (connections: 1/10)
🧠 [TEN-VAD] Initialized (threshold=0.5, hop=256)
🚀 Starting Clio streaming transcription
🏥 [AUDIO HEALTH] Health monitoring timer started
⏱️ [TIMING] mic_engaged @ 1756279989.009
🌐 [CONNECT] New single-flight request from start
🌐 [CONNECT] Attempt #15 (loop 1/3) starting…
pass
t=1213466 sess=I7F lvl=INFO cat=stream evt=temp_key_fetch_start
⚡ [CACHE-HIT] Retrieved temp key in 0.9ms
t=1213468 sess=I7F lvl=INFO cat=stream evt=temp_key_fetch expires_in_s=-1 latency_ms=0 source=cached
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🌐 [WS CONNECT] Using URL: wss://stt-rt.soniox.com/transcribe-websocket
🔗 [WS] Bound socket id=sock_7230939708807454817@attempt_15
t=1213468 sess=I7F lvl=INFO cat=stream evt=ws_bind socket=sock_7230939708807454817@attempt_15 target_host=stt-rt.soniox.com via_proxy=false path=/transcribe-websocket target_ip=resolving... attempt=15
🔑 Successfully connected to Soniox using temp key (2ms key latency)
nw_path_necp_check_for_updates Failed to copy updated result (22)
t=1213470 sess=I7F lvl=INFO cat=stream evt=ws_bind_resolved target_ip=129.146.176.251 path=/transcribe-websocket target_host=stt-rt.soniox.com socket=sock_7230939708807454817@attempt_15 attempt=15 via_proxy=false
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
t=1213507 sess=I7F lvl=INFO cat=audio evt=avcapture_start ok=true
t=1213507 sess=I7F lvl=INFO cat=stream evt=first_audio_buffer_captured ms=73
t=1213507 sess=I7F lvl=INFO cat=audio evt=level avg_db=-60 peak_db=-60
✅ [AUDIO HEALTH] First audio data received - tap is functional
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
🗣️ [TEN-VAD] Speech start detected
🛑 [TEN-VAD] Speech end detected
🔍 Found 82 text observations
✅ Text extraction successful: 1002 chars, 1002 non-whitespace, 158 words from 82 observations
✅ Captured text successfully
✅ [CAPTURE DEBUG] Screen capture successful: 1071 characters
💾 [SMART-CACHE] Cached new context: com.apple.dt.Xcode|Clio — clean.swift (1071 chars)
🎯 [CALLBACK DEBUG] Executing callback with fresh content (1071 chars)
🔥 [PREWARM DEBUG] Pre-warming AI connection (target: Gemini), environment: flyio
🔥 [NER-TRIGGER] OCR completion callback triggered with fresh content
🎬 [NER-PREWARM] Using raw OCR text for NER: 1071 characters
🧠 [NER-DEFAULT] Using default NER prompt for general extraction
t=1215512 sess=I7F lvl=INFO cat=audio evt=level peak_db=-30 avg_db=-30
t=1215576 sess=I7F lvl=INFO cat=stream evt=ws_handshake_metrics attempt=15 tls_ms=1583 reused=false protocol=http/1.1 connect_ms=1583 total_ms=2106 proxy=false dns_ms=1 socket=sock_7230939708807454817@attempt_15
🔌 WebSocket did open (sid=sock_7230939708807454817, attemptId=15)
🌐 [CONNECT] Attempt #15 succeeded
📤 [START] Sent start/config text frame (attemptId=15, socketId=sock_7230939708807454817@attempt_15, start_text_sent=true)
t=1215577 sess=I7F lvl=INFO cat=stream evt=start_config ctx=active socket=sock_7230939708807454817@attempt_15 summary=["ch": 1, "sr": 16000, "langs": 2, "ctx_len": 36, "json_hash": "74c88fa4ee9a34f7", "valid": true, "audio_format": "pcm_s16le", "model": "stt-rt-preview-v2"] attempt=15
🧾 [START-CONFIG] ctx=active sum=["ch": 1, "sr": 16000, "langs": 2, "ctx_len": 36, "json_hash": "74c88fa4ee9a34f7", "valid": true, "audio_format": "pcm_s16le", "model": "stt-rt-preview-v2"]
🔌 [READY] attemptId=15 socketId=sock_7230939708807454817@attempt_15 start_text_sent=true
🔌 WebSocket ready after 2144ms - buffered 2.1s of audio
📦 Flushing 180 buffered packets (2.1s of audio, 66936 bytes)
⏱️ [TIMING] WebSocket connect task completed — will flush after READY
📤 Sent buffered packet 0/180 seq=0 size=372
📤 Sent buffered packet 179/180 seq=179 size=372
📦 Flushing 1 additional packets that arrived during flush
✅ Buffer flush complete
⏱️ [SPEECH-WATCHDOG] Arming watchdog: deadline=2.000000s attempt=15
🧪 [PROMO] speech_watchdog_arm attempt=15 speaking=true bytes_threshold=10000 gates isStreaming=true ws_ready=true start_sent=true hasTokens=false
⏹️ Keepalive timer stopped
🔄 Keepalive timer started (interval: 15.000000s)
👂 [LISTENER] Starting listener task for socketId=sock_7230939708807454817@attempt_15 attemptId=15
📤 Sending text frame seq=18938
t=1215593 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 ready=true flushing=false seq=181
t=1215593 sess=I7F lvl=INFO cat=stream evt=first_audio_sent ms=2159 seq=181
t=1215607 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=182 ready=true bytes=372
t=1215617 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=183 ready=true bytes=372
t=1215628 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=184
t=1215640 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 ready=true flushing=false seq=185
t=1215652 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=186 bytes=372 flushing=false
t=1215665 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=187 flushing=false ready=true has_socket=true
t=1215674 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=188 flushing=false has_socket=true ready=true
t=1215686 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=189 has_socket=true flushing=false ready=true
t=1215699 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=190 has_socket=true flushing=false ready=true
t=1215709 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=191 ready=true bytes=372
t=1215723 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=192
t=1215734 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=193 has_socket=true flushing=false ready=true
t=1215744 sess=I7F lvl=INFO cat=stream evt=pre_send seq=194 flushing=false ready=true bytes=372 has_socket=true
t=1215757 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=195
t=1215768 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true seq=196 flushing=false
t=1215779 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true seq=197 bytes=372
t=1215791 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=198 ready=true bytes=372
t=1215802 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=199 has_socket=true
t=1215814 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 seq=200 flushing=false
t=1215825 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=201
t=1215837 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true seq=202 bytes=372
t=1215849 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=203
t=1215860 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=204
t=1215873 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=205
t=1215884 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=206
t=1215895 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true ready=true bytes=372 seq=207
t=1215906 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=208 ready=true bytes=372
t=1215918 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=209 has_socket=true
t=1215932 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=210
t=1215942 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=211
t=1215953 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true bytes=372 seq=212 ready=true
t=1215966 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=213
t=1215976 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=214 flushing=false
t=1215989 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=215 ready=true bytes=372
t=1216000 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=216 ready=true bytes=372
t=1216012 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=217 ready=true bytes=372
t=1216024 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 seq=218 ready=true flushing=false
t=1216035 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 seq=219 ready=true flushing=false
t=1216049 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=220 ready=true bytes=372
t=1216057 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=221 has_socket=true bytes=372
t=1216069 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true bytes=372 seq=222 ready=true
t=1216083 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=223
t=1216092 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=224
t=1216106 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=225 ready=true bytes=372
t=1216118 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=226 flushing=false bytes=372
t=1216127 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=227 has_socket=true flushing=false
t=1216140 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=228 has_socket=true bytes=372
t=1216151 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true ready=true seq=229
t=1216162 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 ready=true has_socket=true flushing=false seq=230
t=1216174 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 seq=231 flushing=false
t=1216186 sess=I7F lvl=INFO cat=stream evt=pre_send seq=232 has_socket=true ready=true flushing=false bytes=372
t=1216200 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true ready=true seq=233
t=1216209 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=234 ready=true bytes=372
t=1216220 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 ready=true has_socket=true flushing=false seq=235
t=1216234 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=236 bytes=372
t=1216243 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=237
t=1216256 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true seq=238 bytes=372
t=1216266 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=239
t=1216278 sess=I7F lvl=INFO cat=stream evt=pre_send seq=240 ready=true flushing=false has_socket=true bytes=372
t=1216290 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=241 ready=true bytes=372
t=1216302 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=242 ready=true bytes=372
t=1216315 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=243
t=1216324 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=244 flushing=false ready=true bytes=372
t=1216336 sess=I7F lvl=INFO cat=stream evt=pre_send seq=245 flushing=false ready=true has_socket=true bytes=372
t=1216348 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=246 flushing=false has_socket=true
t=1216359 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=247 flushing=false has_socket=true
t=1216372 sess=I7F lvl=INFO cat=stream evt=pre_send seq=248 ready=true flushing=false has_socket=true bytes=372
t=1216383 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=249 ready=true bytes=372
t=1216394 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=250
t=1216407 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=251 bytes=372 flushing=false
t=1216419 sess=I7F lvl=INFO cat=stream evt=pre_send seq=252 ready=true flushing=false has_socket=true bytes=372
t=1216431 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=253 ready=true bytes=372
t=1216441 sess=I7F lvl=INFO cat=stream evt=pre_send seq=254 ready=true flushing=false has_socket=true bytes=372
t=1216452 sess=I7F lvl=INFO cat=stream evt=pre_send seq=255 ready=true flushing=false has_socket=true bytes=372
t=1216465 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=256
t=1216475 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=257
t=1216487 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true seq=258 bytes=372
t=1216499 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false has_socket=true seq=259
t=1216510 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false has_socket=true seq=260
t=1216523 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false has_socket=true seq=261
t=1216536 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false seq=262 has_socket=true bytes=372 ready=true
t=1216545 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=263 has_socket=true ready=true flushing=false
t=1216557 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false seq=264 has_socket=true bytes=372 ready=true
t=1216568 sess=I7F lvl=INFO cat=stream evt=pre_send seq=265 ready=true flushing=false has_socket=true bytes=372
t=1216584 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=266 has_socket=true ready=true flushing=false
t=1216591 sess=I7F lvl=INFO cat=stream evt=pre_send seq=267 has_socket=true bytes=372 ready=true flushing=false
t=1216603 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=268 bytes=372 ready=true
t=1216615 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false has_socket=true seq=269
t=1216626 sess=I7F lvl=INFO cat=stream evt=pre_send seq=270 ready=true flushing=false has_socket=true bytes=372
t=1216640 sess=I7F lvl=INFO cat=stream evt=pre_send seq=271 ready=true flushing=false has_socket=true bytes=372
t=1216650 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 ready=true seq=272
t=1216661 sess=I7F lvl=INFO cat=stream evt=pre_send seq=273 ready=true flushing=false has_socket=true bytes=372
t=1216672 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=274 bytes=372
t=1216685 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 ready=true seq=275
t=1216699 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=276
t=1216707 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false seq=277 has_socket=true bytes=372 ready=true
t=1216719 sess=I7F lvl=INFO cat=stream evt=pre_send seq=278 ready=true flushing=false has_socket=true bytes=372
t=1216733 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=279 flushing=false ready=true has_socket=true
t=1216743 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=280 flushing=false ready=true has_socket=true
t=1216756 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=281
t=1216768 sess=I7F lvl=INFO cat=stream evt=pre_send seq=282 ready=true flushing=false has_socket=true bytes=372
t=1216777 sess=I7F lvl=INFO cat=stream evt=pre_send seq=283 ready=true flushing=false has_socket=true bytes=372
t=1216790 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=284 bytes=372 ready=true
t=1216801 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true ready=true seq=285
t=1216812 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=286 has_socket=true ready=true flushing=false
t=1216823 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=287 flushing=false has_socket=true
t=1216835 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=288
t=1216847 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false seq=289 has_socket=true bytes=372 ready=true
t=1216858 sess=I7F lvl=INFO cat=stream evt=pre_send seq=290 ready=true flushing=false has_socket=true bytes=372
t=1216873 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=291
t=1216883 sess=I7F lvl=INFO cat=stream evt=pre_send seq=292 ready=true flushing=false has_socket=true bytes=372
t=1216893 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=293
t=1216907 sess=I7F lvl=INFO cat=stream evt=pre_send seq=294 ready=true flushing=false has_socket=true bytes=372
t=1216917 sess=I7F lvl=INFO cat=stream evt=pre_send seq=295 ready=true flushing=false has_socket=true bytes=372
t=1216928 sess=I7F lvl=INFO cat=stream evt=pre_send seq=296 ready=true flushing=false has_socket=true bytes=372
t=1216941 sess=I7F lvl=INFO cat=stream evt=pre_send seq=297 ready=true flushing=false has_socket=true bytes=372
t=1216953 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=298 ready=true bytes=372
t=1216965 sess=I7F lvl=INFO cat=stream evt=pre_send seq=299 ready=true flushing=false has_socket=true bytes=372
t=1216974 sess=I7F lvl=INFO cat=stream evt=pre_send seq=300 ready=true flushing=false has_socket=true bytes=372
t=1216986 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true ready=true seq=301 bytes=372
t=1217000 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false ready=true seq=302
t=1217009 sess=I7F lvl=INFO cat=stream evt=pre_send seq=303 ready=true flushing=false has_socket=true bytes=372
t=1217023 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=304
t=1217032 sess=I7F lvl=INFO cat=stream evt=pre_send seq=305 flushing=false ready=true has_socket=true bytes=372
t=1217044 sess=I7F lvl=INFO cat=stream evt=pre_send seq=306 flushing=false has_socket=true ready=true bytes=372
t=1217056 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true ready=true seq=307 bytes=372
t=1217069 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=308 flushing=false ready=true has_socket=true
t=1217082 sess=I7F lvl=INFO cat=stream evt=pre_send seq=309 ready=true flushing=false has_socket=true bytes=372
t=1217091 sess=I7F lvl=INFO cat=stream evt=pre_send seq=310 flushing=false has_socket=true ready=true bytes=372
t=1217102 sess=I7F lvl=INFO cat=stream evt=pre_send seq=311 flushing=false has_socket=true ready=true bytes=372
t=1217115 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=312 has_socket=true bytes=372 flushing=false
t=1217126 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false has_socket=true seq=313
t=1217137 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false ready=true seq=314
t=1217149 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=315
t=1217161 sess=I7F lvl=INFO cat=stream evt=pre_send seq=316 flushing=false has_socket=true ready=true bytes=372
t=1217174 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false seq=317 ready=true bytes=372 has_socket=true
t=1217184 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=318
t=1217196 sess=I7F lvl=INFO cat=stream evt=pre_send seq=319 ready=true has_socket=true flushing=false bytes=372
t=1217208 sess=I7F lvl=INFO cat=stream evt=pre_send seq=320 flushing=false has_socket=true ready=true bytes=372
t=1217220 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=321 has_socket=true ready=true flushing=false
t=1217234 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 ready=true has_socket=true flushing=false seq=322
t=1217242 sess=I7F lvl=INFO cat=stream evt=pre_send seq=323 ready=true has_socket=true flushing=false bytes=372
t=1217252 sess=I7F lvl=INFO cat=stream evt=first_partial ms=3817
t=1217252 sess=I7F lvl=INFO cat=stream evt=ttft_hotkey ms=3817
t=1217252 sess=I7F lvl=INFO cat=stream evt=ttft ms=3575
🛑 [SPEECH-WATCHDOG] Cancelled
t=1217253 sess=I7F lvl=INFO cat=stream evt=pre_send seq=324 flushing=false has_socket=true ready=true bytes=372
t=1217265 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=325
t=1217334 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 has_socket=true seq=326
t=1217334 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 has_socket=true seq=327
t=1217334 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 has_socket=true seq=328
t=1217334 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 has_socket=true seq=329
t=1217334 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 has_socket=true seq=330
t=1217335 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 seq=331 flushing=false
throwing -10877
throwing -10877
t=1217519 sess=I7F lvl=INFO cat=audio evt=level peak_db=-37 avg_db=-37
t=1217519 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=332
t=1217519 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=333
t=1217519 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=334
t=1217519 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=335
t=1217519 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=336
t=1217519 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=337
t=1217519 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=338
t=1217519 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=339
t=1217519 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=340
t=1217519 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=341
t=1217519 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=342
t=1217519 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=343
t=1217519 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=344
t=1217520 sess=I7F lvl=INFO cat=stream evt=pre_send seq=345 has_socket=true ready=true flushing=false bytes=372
t=1217520 sess=I7F lvl=INFO cat=stream evt=pre_send seq=346 has_socket=true ready=true flushing=false bytes=372
t=1217520 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=347
t=1217579 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=348 has_socket=true ready=true
t=1217579 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=349 has_socket=true ready=true
t=1217605 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=350 ready=true has_socket=true
t=1217605 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=351 ready=true has_socket=true
t=1217605 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=352 ready=true has_socket=true
t=1217605 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=353 ready=true has_socket=true
t=1217605 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=354 ready=true has_socket=true
t=1217638 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true bytes=372 seq=355 ready=true
t=1217638 sess=I7F lvl=INFO cat=stream evt=pre_send seq=356 has_socket=true ready=true flushing=false bytes=372
t=1217638 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true bytes=372 seq=357 ready=true
t=1217647 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=358 ready=true has_socket=true
t=1217659 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=359
t=1217671 sess=I7F lvl=INFO cat=stream evt=pre_send seq=360 has_socket=true ready=true flushing=false bytes=372
t=1217708 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=361 flushing=false ready=true bytes=372
t=1217708 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=362 flushing=false ready=true bytes=372
t=1217708 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=363 flushing=false ready=true bytes=372
t=1217741 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=364 has_socket=true
t=1217741 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=365
t=1217741 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=366
t=1217770 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=367 flushing=false bytes=372
t=1217771 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=368 flushing=false bytes=372
t=1217802 sess=I7F lvl=INFO cat=stream evt=pre_send seq=369 flushing=false ready=true bytes=372 has_socket=true
t=1217802 sess=I7F lvl=INFO cat=stream evt=pre_send seq=370 flushing=false ready=true bytes=372 has_socket=true
t=1217802 sess=I7F lvl=INFO cat=stream evt=pre_send seq=371 flushing=false ready=true bytes=372 has_socket=true
t=1217838 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=372 bytes=372
t=1217839 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=373 bytes=372
t=1217839 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=374 bytes=372
t=1217873 sess=I7F lvl=INFO cat=stream evt=pre_send seq=375 has_socket=true flushing=false ready=true bytes=372
t=1217873 sess=I7F lvl=INFO cat=stream evt=pre_send seq=376 has_socket=true flushing=false ready=true bytes=372
t=1217873 sess=I7F lvl=INFO cat=stream evt=pre_send seq=377 has_socket=true flushing=false ready=true bytes=372
t=1217880 sess=I7F lvl=INFO cat=stream evt=pre_send seq=378 ready=true flushing=false has_socket=true bytes=372
t=1217891 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false has_socket=true seq=379
t=1217903 sess=I7F lvl=INFO cat=stream evt=pre_send seq=380 flushing=false has_socket=true ready=true bytes=372
t=1217915 sess=I7F lvl=INFO cat=stream evt=pre_send seq=381 flushing=false has_socket=true ready=true bytes=372
t=1217926 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 seq=382 flushing=false
t=1217938 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false has_socket=true seq=383
t=1217949 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false has_socket=true seq=384
t=1217961 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=385 bytes=372
t=1217973 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=386 ready=true has_socket=true
t=1217984 sess=I7F lvl=INFO cat=stream evt=pre_send seq=387 has_socket=true bytes=372 flushing=false ready=true
t=1218024 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true seq=388 has_socket=true
t=1218024 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true seq=389 has_socket=true
t=1218025 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true seq=390 has_socket=true
t=1218085 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=391 has_socket=true ready=true flushing=false
t=1218085 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=392 has_socket=true ready=true flushing=false
t=1218085 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=393 has_socket=true ready=true flushing=false
t=1218085 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false ready=true seq=394
t=1218085 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false ready=true seq=395
t=1218089 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=396
🤖 [FLY.IO-NER] Server-reported provider: gemini
t=1218161 sess=I7F lvl=INFO cat=stream evt=pre_send seq=397 flushing=false bytes=372 has_socket=true ready=true
t=1218161 sess=I7F lvl=INFO cat=stream evt=pre_send seq=398 flushing=false bytes=372 has_socket=true ready=true
t=1218161 sess=I7F lvl=INFO cat=stream evt=pre_send seq=399 flushing=false bytes=372 has_socket=true ready=true
📥 [NER-STORE] Stored NER entities: 3474 chars - Here's a breakdown of the information presented in the screenshot:

**Active Window & Application:**...
✅ [FLY.IO] NER refresh completed successfully
t=1218161 sess=I7F lvl=INFO cat=stream evt=pre_send seq=400 flushing=false bytes=372 has_socket=true ready=true
t=1218161 sess=I7F lvl=INFO cat=stream evt=pre_send seq=401 flushing=false bytes=372 has_socket=true ready=true
t=1218161 sess=I7F lvl=INFO cat=stream evt=pre_send seq=402 flushing=false bytes=372 has_socket=true ready=true
t=1218236 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=403
t=1218236 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=404
t=1218236 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=405
t=1218236 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=406
t=1218236 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=407
t=1218236 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=408
t=1218240 sess=I7F lvl=INFO cat=stream evt=pre_send seq=409 flushing=false bytes=372 has_socket=true ready=true
t=1218278 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=410
t=1218278 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=411
t=1218278 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=412
t=1218316 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=413
t=1218316 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=414
t=1218316 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=415
t=1218322 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=416 has_socket=true flushing=false
t=1218333 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=417
t=1218344 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 seq=418 flushing=false
t=1218390 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=419 ready=true bytes=372 flushing=false
t=1218390 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=420 ready=true bytes=372 flushing=false
t=1218390 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=421 ready=true bytes=372 flushing=false
t=1218425 sess=I7F lvl=INFO cat=stream evt=pre_send seq=422 flushing=false has_socket=true ready=true bytes=372
t=1218426 sess=I7F lvl=INFO cat=stream evt=pre_send seq=423 flushing=false has_socket=true ready=true bytes=372
t=1218426 sess=I7F lvl=INFO cat=stream evt=pre_send seq=424 flushing=false has_socket=true ready=true bytes=372
t=1218426 sess=I7F lvl=INFO cat=stream evt=pre_send seq=425 flushing=false has_socket=true ready=true bytes=372
t=1218476 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=426 ready=true bytes=372 flushing=false
t=1218476 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=427 ready=true bytes=372 flushing=false
t=1218476 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=428 ready=true bytes=372 flushing=false
t=1218476 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=429 ready=true bytes=372 flushing=false
t=1218539 sess=I7F lvl=INFO cat=stream evt=pre_send seq=430 flushing=false has_socket=true ready=true bytes=372
t=1218539 sess=I7F lvl=INFO cat=stream evt=pre_send seq=431 flushing=false has_socket=true ready=true bytes=372
t=1218539 sess=I7F lvl=INFO cat=stream evt=pre_send seq=432 flushing=false has_socket=true ready=true bytes=372
t=1218540 sess=I7F lvl=INFO cat=stream evt=pre_send seq=433 flushing=false has_socket=true ready=true bytes=372
t=1218540 sess=I7F lvl=INFO cat=stream evt=pre_send seq=434 flushing=false has_socket=true ready=true bytes=372
t=1218574 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false has_socket=true seq=435
t=1218574 sess=I7F lvl=INFO cat=stream evt=pre_send seq=436 flushing=false has_socket=true ready=true bytes=372
t=1218574 sess=I7F lvl=INFO cat=stream evt=pre_send seq=437 flushing=false has_socket=true ready=true bytes=372
t=1218576 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false has_socket=true seq=438
t=1218608 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=439
t=1218608 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=440
t=1218643 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=441 ready=true flushing=false bytes=372
t=1218643 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=442 ready=true flushing=false bytes=372
t=1218643 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=443 ready=true flushing=false bytes=372
t=1218646 sess=I7F lvl=INFO cat=stream evt=pre_send seq=444 flushing=false bytes=372 has_socket=true ready=true
t=1218658 sess=I7F lvl=INFO cat=stream evt=pre_send seq=445 flushing=false ready=true has_socket=true bytes=372
t=1218688 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false ready=true has_socket=true bytes=372 seq=446
t=1218688 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false ready=true has_socket=true bytes=372 seq=447
t=1218722 sess=I7F lvl=INFO cat=stream evt=pre_send seq=448 flushing=false bytes=372 has_socket=true ready=true
t=1218722 sess=I7F lvl=INFO cat=stream evt=pre_send seq=449 flushing=false bytes=372 has_socket=true ready=true
t=1218722 sess=I7F lvl=INFO cat=stream evt=pre_send seq=450 flushing=false bytes=372 has_socket=true ready=true
t=1218727 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 seq=451 flushing=false
t=1218766 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false seq=452 has_socket=true
t=1218766 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false seq=453 has_socket=true
t=1218766 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false seq=454 has_socket=true
t=1218801 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=455 has_socket=true ready=true flushing=false
t=1218801 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=456 has_socket=true ready=true flushing=false
t=1218802 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=457 has_socket=true ready=true flushing=false
t=1218809 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=458 has_socket=true ready=true flushing=false
t=1218848 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=459 flushing=false has_socket=true bytes=372
t=1218848 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=460 flushing=false has_socket=true bytes=372
t=1218848 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=461 flushing=false has_socket=true bytes=372
t=1218881 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false seq=462 has_socket=true ready=true bytes=372
t=1218881 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false seq=463 has_socket=true ready=true bytes=372
t=1218881 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false seq=464 has_socket=true ready=true bytes=372
t=1218890 sess=I7F lvl=INFO cat=stream evt=pre_send seq=465 flushing=false bytes=372 has_socket=true ready=true
t=1218901 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=466 has_socket=true ready=true
t=1218913 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=467 has_socket=true ready=true flushing=false
t=1218925 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false seq=468 has_socket=true ready=true bytes=372
t=1218936 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=469 has_socket=true ready=true flushing=false
t=1218948 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 seq=470 flushing=false ready=true
t=1218959 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=471 flushing=false has_socket=true bytes=372
t=1218971 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=472 has_socket=true ready=true
t=1218983 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 ready=true has_socket=true flushing=false seq=473
t=1218994 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 ready=true seq=474 flushing=false
t=1219006 sess=I7F lvl=INFO cat=stream evt=pre_send seq=475 flushing=false bytes=372 has_socket=true ready=true
t=1219018 sess=I7F lvl=INFO cat=stream evt=pre_send seq=476 ready=true flushing=false bytes=372 has_socket=true
t=1219029 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=477 ready=true has_socket=true
t=1219041 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 flushing=false seq=478
t=1219053 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=479 bytes=372
t=1219064 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=480 bytes=372
t=1219076 sess=I7F lvl=INFO cat=stream evt=pre_send seq=481 flushing=false has_socket=true ready=true bytes=372
t=1219089 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=482 bytes=372
t=1219099 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=483 bytes=372
t=1219156 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true has_socket=true seq=484
t=1219156 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true has_socket=true seq=485
t=1219156 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true has_socket=true seq=486
t=1219156 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true has_socket=true seq=487
t=1219190 sess=I7F lvl=INFO cat=stream evt=pre_send seq=488 flushing=false bytes=372 has_socket=true ready=true
t=1219190 sess=I7F lvl=INFO cat=stream evt=pre_send seq=489 flushing=false bytes=372 has_socket=true ready=true
t=1219190 sess=I7F lvl=INFO cat=stream evt=pre_send seq=490 flushing=false bytes=372 has_socket=true ready=true
t=1219192 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true seq=491 bytes=372
t=1219203 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=492 flushing=false has_socket=true bytes=372
t=1219215 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=493 ready=true has_socket=true flushing=false
t=1219227 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=494 flushing=false bytes=372 has_socket=true
t=1219238 sess=I7F lvl=INFO cat=stream evt=pre_send seq=495 flushing=false has_socket=true ready=true bytes=372
t=1219250 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=496
t=1219261 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 seq=497 flushing=false
t=1219273 sess=I7F lvl=INFO cat=stream evt=pre_send seq=498 flushing=false has_socket=true ready=true bytes=372
🛑 [TEN-VAD] Speech end detected
t=1219284 sess=I7F lvl=INFO cat=stream evt=pre_send seq=499 flushing=false has_socket=true ready=true bytes=372
t=1219296 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=500
t=1219308 sess=I7F lvl=INFO cat=stream evt=pre_send seq=501 flushing=false has_socket=true ready=true bytes=372
t=1219349 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=502 flushing=false bytes=372
t=1219349 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=503 flushing=false bytes=372
t=1219349 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=504 flushing=false bytes=372
t=1219381 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=505 flushing=false bytes=372 ready=true
t=1219381 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=506 flushing=false bytes=372 ready=true
t=1219381 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=507 flushing=false bytes=372 ready=true
t=1219389 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=508 flushing=false bytes=372 ready=true
t=1219401 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=509 ready=true bytes=372 flushing=false
t=1219412 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=510 ready=true bytes=372 flushing=false
t=1219424 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=511 flushing=false bytes=372
t=1219425 sess=I7F lvl=INFO cat=stream evt=first_final ms=5990
t=1219425 sess=I7F lvl=INFO cat=transcript evt=raw_final text="In fact, almost all"
t=1219477 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=512 ready=true bytes=372 flushing=false
t=1219477 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=513 ready=true bytes=372 flushing=false
t=1219477 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=514 ready=true bytes=372 flushing=false
t=1219478 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=515 ready=true bytes=372 flushing=false
t=1219511 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=516 has_socket=true bytes=372
t=1219511 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=517 has_socket=true bytes=372
t=1219511 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=518 has_socket=true bytes=372
t=1219517 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=519 has_socket=true
t=1219528 sess=I7F lvl=INFO cat=audio evt=level avg_db=-33 peak_db=-33
t=1219528 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false ready=true seq=520 has_socket=true bytes=372
t=1219540 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=521 ready=true has_socket=true
t=1219551 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=522 ready=true bytes=372 flushing=false
t=1219563 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=523 ready=true bytes=372 flushing=false
t=1219575 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=524 ready=true bytes=372 flushing=false
t=1219586 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=525 ready=true bytes=372 flushing=false
t=1219598 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=526 bytes=372
t=1219610 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=527
t=1219622 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=528 ready=true has_socket=true
t=1219633 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=529
t=1219644 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=530
t=1219656 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=531 ready=true has_socket=true
t=1219668 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false ready=true seq=532 has_socket=true bytes=372
t=1219679 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false has_socket=true seq=533
t=1219691 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=534 ready=true has_socket=true
t=1219743 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=535 ready=true has_socket=true flushing=false
t=1219743 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=536 ready=true has_socket=true flushing=false
t=1219743 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=537 ready=true has_socket=true flushing=false
t=1219743 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=538 ready=true has_socket=true flushing=false
t=1219780 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true seq=539 flushing=false bytes=372
t=1219780 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true seq=540 flushing=false bytes=372
t=1219780 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true seq=541 flushing=false bytes=372
t=1219784 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=542
t=1219819 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=543 ready=true bytes=372 flushing=false
t=1219819 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=544 ready=true bytes=372 flushing=false
t=1219819 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=545 ready=true bytes=372 flushing=false
t=1219850 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=546 bytes=372
t=1219851 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=547 bytes=372
t=1219853 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false has_socket=true seq=548
t=1219865 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false has_socket=true seq=549
t=1219877 sess=I7F lvl=INFO cat=stream evt=pre_send seq=550 bytes=372 has_socket=true ready=true flushing=false
t=1219888 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false has_socket=true seq=551
t=1219900 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=552
t=1219912 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false has_socket=true seq=553
t=1219949 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=554 flushing=false bytes=372
t=1219949 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=555 flushing=false bytes=372
t=1219949 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=556 flushing=false bytes=372
t=1219979 sess=I7F lvl=INFO cat=stream evt=pre_send seq=557 bytes=372 has_socket=true ready=true flushing=false
t=1219979 sess=I7F lvl=INFO cat=stream evt=pre_send seq=558 bytes=372 has_socket=true ready=true flushing=false
t=1219981 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=559 bytes=372
t=1219993 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=560 flushing=false bytes=372
t=1220005 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=561 bytes=372
t=1220016 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=562 flushing=false bytes=372
t=1220028 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=563 bytes=372
t=1220039 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=564
t=1220051 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=565 ready=true bytes=372 flushing=false
t=1220062 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 seq=566 ready=true
t=1220074 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true ready=true seq=567 bytes=372
t=1220086 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=568 bytes=372 flushing=false
t=1220097 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=569 ready=true bytes=372 flushing=false
t=1220109 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=570 ready=true bytes=372 flushing=false
t=1220120 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=571 ready=true bytes=372 flushing=false
t=1220165 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=572 flushing=false bytes=372
t=1220165 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=573 flushing=false bytes=372
t=1220165 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=574 flushing=false bytes=372
t=1220198 sess=I7F lvl=INFO cat=stream evt=pre_send seq=575 has_socket=true ready=true flushing=false bytes=372
t=1220198 sess=I7F lvl=INFO cat=stream evt=pre_send seq=576 has_socket=true ready=true flushing=false bytes=372
t=1220198 sess=I7F lvl=INFO cat=stream evt=pre_send seq=577 has_socket=true ready=true flushing=false bytes=372
t=1220202 sess=I7F lvl=INFO cat=stream evt=pre_send seq=578 has_socket=true ready=true flushing=false bytes=372
t=1220214 sess=I7F lvl=INFO cat=stream evt=pre_send seq=579 has_socket=true ready=true flushing=false bytes=372
t=1220225 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=580 ready=true has_socket=true
t=1220237 sess=I7F lvl=INFO cat=stream evt=pre_send seq=581 has_socket=true ready=true flushing=false bytes=372
t=1220248 sess=I7F lvl=INFO cat=stream evt=pre_send seq=582 has_socket=true ready=true flushing=false bytes=372
t=1220260 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=583 ready=true bytes=372 flushing=false
t=1220271 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=584 flushing=false bytes=372
t=1220283 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false seq=585 has_socket=true ready=true bytes=372
t=1220295 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=586 ready=true bytes=372 flushing=false
t=1220306 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true bytes=372 seq=587 ready=true
t=1220318 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=588 ready=true bytes=372 flushing=false
t=1220329 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=589 ready=true bytes=372 flushing=false
t=1220341 sess=I7F lvl=INFO cat=stream evt=pre_send seq=590 has_socket=true ready=true flushing=false bytes=372
t=1220353 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=591
t=1220364 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=592 ready=true has_socket=true
t=1220376 sess=I7F lvl=INFO cat=stream evt=pre_send seq=593 has_socket=true ready=true flushing=false bytes=372
t=1220388 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=594
t=1220399 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=595 ready=true bytes=372 flushing=false
t=1220411 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=596 ready=true has_socket=true
t=1220423 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true ready=true seq=597
t=1220494 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=598 ready=true has_socket=true
t=1220495 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false seq=599 bytes=372
t=1220495 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=600 has_socket=true
t=1220495 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=601 has_socket=true
t=1220495 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=602 has_socket=true
t=1220495 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=603 ready=true has_socket=true flushing=false
t=1220532 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=604 bytes=372
t=1220532 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=605 bytes=372
t=1220532 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=606 bytes=372
t=1220538 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false has_socket=true seq=607
t=1220550 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=608
t=1220562 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false has_socket=true seq=609
t=1220573 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=610 has_socket=true bytes=372
t=1220585 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false has_socket=true seq=611
t=1220596 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 seq=612 flushing=false
t=1220608 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=613 flushing=false bytes=372
t=1220640 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=614
t=1220640 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=615
t=1220671 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=616 has_socket=true ready=true
t=1220671 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=617 has_socket=true ready=true
t=1220671 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=618 has_socket=true ready=true
t=1220678 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=619 ready=true bytes=372 flushing=false
t=1220690 sess=I7F lvl=INFO cat=stream evt=pre_send seq=620 flushing=false has_socket=true ready=true bytes=372
t=1220701 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 seq=621 flushing=false
t=1220713 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=622
t=1220724 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=623 ready=true bytes=372 flushing=false
t=1220730 sess=I7F lvl=INFO cat=transcript evt=raw_final text=" of them experienced l"
t=1220736 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 seq=624 flushing=false
t=1220768 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=625 bytes=372
t=1220768 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=626 bytes=372
t=1220800 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=627
t=1220800 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=628
t=1220800 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=629
t=1220805 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=630
t=1220817 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false has_socket=true seq=631
t=1220829 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=632
t=1220840 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=633 ready=true bytes=372 flushing=false
t=1220852 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=634 ready=true bytes=372 flushing=false
t=1220863 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=635 ready=true bytes=372 flushing=false
t=1220876 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=636
t=1220887 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=637 ready=true bytes=372 flushing=false
t=1220898 sess=I7F lvl=INFO cat=stream evt=pre_send seq=638 flushing=false has_socket=true ready=true bytes=372
t=1220910 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false has_socket=true seq=639
t=1220922 sess=I7F lvl=INFO cat=stream evt=pre_send seq=640 flushing=false has_socket=true ready=true bytes=372
t=1220933 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=641
t=1220945 sess=I7F lvl=INFO cat=stream evt=pre_send seq=642 flushing=false has_socket=true ready=true bytes=372
🛑 [TEN-VAD] Speech end detected
t=1220956 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=643 ready=true bytes=372 flushing=false
t=1220968 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=644 ready=true bytes=372 flushing=false
t=1220980 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=645 ready=true has_socket=true
t=1220991 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=646 ready=true has_socket=true
t=1221003 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=647 ready=true bytes=372 flushing=false
t=1221015 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 ready=true flushing=false seq=648
t=1221026 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=649 has_socket=true ready=true flushing=false
t=1221039 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false has_socket=true seq=650
t=1221097 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=651 ready=true has_socket=true
t=1221097 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=652 ready=true has_socket=true
t=1221097 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=653 ready=true has_socket=true
t=1221097 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=654 ready=true has_socket=true
t=1221097 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=655 ready=true has_socket=true
t=1221133 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 ready=true seq=656 flushing=false
t=1221134 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 ready=true seq=657 flushing=false
t=1221134 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 ready=true seq=658 flushing=false
t=1221142 sess=I7F lvl=INFO cat=stream evt=pre_send seq=659 has_socket=true ready=true flushing=false bytes=372
t=1221154 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 seq=660 ready=true
t=1221166 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=661
t=1221177 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false has_socket=true seq=662
t=1221188 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=663
t=1221201 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false seq=664 has_socket=true
t=1221212 sess=I7F lvl=INFO cat=stream evt=pre_send seq=665 flushing=false has_socket=true ready=true bytes=372
t=1221223 sess=I7F lvl=INFO cat=stream evt=pre_send seq=666 has_socket=true ready=true flushing=false bytes=372
t=1221267 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=667
t=1221267 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=668
t=1221267 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=669
t=1221306 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false seq=670 bytes=372 has_socket=true ready=true
t=1221306 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false seq=671 bytes=372 has_socket=true ready=true
t=1221306 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false seq=672 bytes=372 has_socket=true ready=true
t=1221306 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false seq=673 bytes=372 has_socket=true ready=true
t=1221316 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=674
t=1221328 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=675 has_socket=true flushing=false
t=1221339 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=676
t=1221352 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=677 has_socket=true ready=true flushing=false
t=1221363 sess=I7F lvl=INFO cat=stream evt=pre_send seq=678 flushing=false has_socket=true ready=true bytes=372
t=1221374 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=679
t=1221386 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=680 has_socket=true flushing=false
t=1221397 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=681
t=1221409 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=682
t=1221421 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true bytes=372 seq=683 ready=true
t=1221432 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true bytes=372 seq=684 ready=true
t=1221444 sess=I7F lvl=INFO cat=stream evt=pre_send seq=685 flushing=false has_socket=true ready=true bytes=372
t=1221456 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=686
🛑 [TEN-VAD] Speech end detected
t=1221529 sess=I7F lvl=INFO cat=audio evt=level avg_db=-42 peak_db=-42
t=1221529 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=687 has_socket=true ready=true flushing=false
t=1221529 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=688 has_socket=true ready=true flushing=false
t=1221529 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=689 has_socket=true ready=true flushing=false
t=1221530 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=690 has_socket=true ready=true flushing=false
t=1221530 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=691 has_socket=true ready=true flushing=false
t=1221530 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=692 has_socket=true ready=true flushing=false
🛑 Stopping recording
🛑 Stopping Clio streaming transcription
🏥 [AUDIO HEALTH] Health monitoring timer stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
🛑 Stopping unified audio capture
t=1221585 sess=I7F lvl=INFO cat=audio evt=record_stop
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key plugInPackage
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key CMIOType
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key numberOfDevices
t=1221594 sess=I7F lvl=INFO cat=audio evt=avcapture_stop
✅ Unified audio capture stopped
t=1221595 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=693 ready=true
t=1221595 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=694 ready=true
t=1221624 sess=I7F lvl=INFO cat=stream evt=pre_send seq=695 flushing=false has_socket=true ready=true bytes=372
t=1221624 sess=I7F lvl=INFO cat=stream evt=pre_send seq=696 flushing=false has_socket=true ready=true bytes=372
t=1221624 sess=I7F lvl=INFO cat=stream evt=pre_send seq=697 flushing=false has_socket=true ready=true bytes=372
📤 Sent end-of-stream signal
📤 Sent manual finalize command
🕐 Using finalization timeout: 400ms (connection took 8285ms)
ℹ️ [OPTIMISTIC] Not skipping: end=false pending=0 ms_since_last=91 tail=100 silence_ok=false tokens_quiet_ok=false partial_empty=false uncond=false
t=1222071 sess=I7F lvl=INFO cat=transcript evt=raw_final text="ittle to no measurable impact"
⚠️ Timed out waiting for <fin> token after 496ms — merging partial transcript
⏹️ Keepalive timer stopped
⚡ Audio capture already stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
📉 Released connection for account account-bundle (connections: 0)
💾 [COLD-START] Updated successful streaming timestamp
💾 [COLD-START] Updated successful streaming timestamp
✅ Streaming transcription completed successfully, length: 125 characters
✅ Streaming stopped. Final transcript (125 chars, 8.8s, with audio file): "In fact, almost all of them experienced l ittle to no measurable impact on the bottom line. In addition, the study found that"
🌡️ [WARM] warm_socket=yes
⏱️ [TIMING] Subscription tracking: 0.5ms
⏱️ [TIMING] ASR word tracking: 0.0ms
🧠 Performing intelligent end-context detection for streaming
⏱️ [CONTEXT DETAIL] Cache check: 0.0ms
⚡ [SMART-OPTIMIZATION] Using smart cached screen context (1071 chars) - skipping new capture
⏱️ [STREAMING CONTEXT TIMING] Screen capture + context detection: 0.0ms
t=1222219 sess=I7F lvl=INFO cat=transcript evt=final text="In fact, almost all of them experienced l ittle to no measurable impact on the bottom line. In addition, the study found that"
t=1222219 sess=I7F lvl=INFO cat=transcript evt=session_end divider="────────── session end ──────────"
🔊 [SoundManager] Attempting to play stop sound
🔊 [SoundManager] NSSound stop sound result: true
🧹 Connection cleanup completed (session resources released)
📝 [GRACE] Recording session ended
📱 Dismissing recorder
⏹️ Keepalive timer stopped
⚠️ WebSocket did close with code 1001 (sid=sock_7230939708807454817, attemptId=15)
t=1222276 sess=I7F lvl=WARN cat=stream evt=state state=closed code=1001
✅ Streaming transcription processing completed
🔌 [WS] Disconnected (socketId=sock_7230939708807454817@attempt_15)
t=1222341 sess=I7F lvl=INFO cat=transcript evt=insert_attempt target=Xcode chars=126 text="In fact, almost all of them experienced l ittle to no measurable impact on the bottom line. In addition, the study found that "
🔍 [PASTE DEBUG] AXIsProcessTrusted() returned true, proceeding
🔍 [PASTE DEBUG] UseDirectTextInsertion setting: false
🔍 [PASTE DEBUG] Direct insertion disabled, using clipboard paste
⌨️ Using CGEvent-based Command+V
t=1222367 sess=I7F lvl=INFO cat=transcript evt=insert_result ok=true
📊 [POST-RELEASE E2E] 809ms (paste=0ms) | warm_socket=no
t=1222374 sess=I7F lvl=INFO cat=transcript evt=raw_final text=" on the bottom line. In addition, the study found that...<end>"
🌐 [CONNECT] New single-flight request from warmHold
🌐 [CONNECT] Attempt #16 (loop 1/2) starting…
t=1222545 sess=I7F lvl=INFO cat=stream evt=temp_key_fetch_start
⚡ [CACHE-HIT] Retrieved temp key in 0.1ms
t=1222546 sess=I7F lvl=INFO cat=stream evt=temp_key_fetch latency_ms=0 source=cached expires_in_s=-1
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🌐 [WS CONNECT] Using URL: wss://stt-rt.soniox.com/transcribe-websocket
🔗 [WS] Bound socket id=sock_-6127485600891781528@attempt_16
t=1222546 sess=I7F lvl=INFO cat=stream evt=ws_bind path=/transcribe-websocket socket=sock_-6127485600891781528@attempt_16 attempt=16 target_host=stt-rt.soniox.com target_ip=resolving... via_proxy=false
🔑 Successfully connected to Soniox using temp key (1ms key latency)
t=1222551 sess=I7F lvl=INFO cat=stream evt=ws_bind_resolved target_host=stt-rt.soniox.com attempt=16 target_ip=129.146.176.251 path=/transcribe-websocket via_proxy=false socket=sock_-6127485600891781528@attempt_16
t=1224725 sess=I7F lvl=INFO cat=stream evt=ws_handshake_metrics protocol=http/1.1 proxy=false dns_ms=0 connect_ms=1560 socket=sock_-6127485600891781528@attempt_16 attempt=16 tls_ms=1560 reused=false total_ms=2177
🔌 WebSocket did open (sid=sock_-6127485600891781528, attemptId=16)
📤 [START] Sent start/config on standby socket (eager mode)
t=1224726 sess=I7F lvl=INFO cat=stream evt=start_config summary=["ctx_len": 36, "valid": true, "audio_format": "pcm_s16le", "langs": 2, "model": "stt-rt-preview-v2", "sr": 16000, "ch": 1, "json_hash": "74c88fa4ee9a34f7"] socket=sock_-6127485600891781528@attempt_16 attempt=16 ctx=standby_eager
🧾 [START-CONFIG] ctx=standby_eager sum=["ctx_len": 36, "valid": true, "audio_format": "pcm_s16le", "langs": 2, "model": "stt-rt-preview-v2", "sr": 16000, "ch": 1, "json_hash": "74c88fa4ee9a34f7"]
🌐 [CONNECT] Attempt #16 succeeded
📤 Sending text frame seq=19637
🧊 [STANDBY] Connected standby socket — keepalive every 10.0s, TTL=60s
🔌 [READY] attemptId=16 socketId=sock_-6127485600891781528@attempt_16 start_text_sent=true
🧊 [STANDBY] WebSocket ready in 2184ms (handshake)
👂 [LISTENER] Standby listener task for socketId=sock_-6127485600891781528@attempt_16 attemptId=16
🧭 [APP] applicationDidBecomeActive
🧭 [APP] ActivationPolicy=.regular (IsMenuBarOnly=false)
🧭 [APP] applicationShouldHandleReopen called - hasVisibleWindows: true
🧭 [APP] ActivationPolicy=.regular (IsMenuBarOnly=false)
🪟 [DOCK] Found existing window, activating it
🔄 [SYNC_STATE] syncTrialState called - currentTier: pro, isInTrial: false
🔄 [SYNC_STATE] Final state after syncTrialState - currentTier: pro, isInTrial: false
💤 [STANDBY] keepalive_tick
t=1234732 sess=I7F lvl=INFO cat=stream evt=standby_keepalive_tick
💤 [STANDBY] keepalive_tick
t=1244731 sess=I7F lvl=INFO cat=stream evt=standby_keepalive_tick


## 2 Success
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
✅ [CACHE] Context unchanged - reusing cache (1071 chars)
♻️ [SMART-CACHE] Using cached context: 1071 characters
🔥 [NER-CACHE] Triggering NER callback with cached content (1071 chars)
✅ [NER-CACHE] NER callback triggered with cached content
✅ [STANDBY->ACTIVE] Probe keepalive OK — proceeding to resume queue
⏹️ Keepalive timer stopped
🔄 Keepalive timer started (interval: 15.000000s)
🧪 [PROMO] snapshot attempt=16 socket=sock_-6127485600891781528@attempt_16 start_sent=true ws_ready=true standby=false purpose=active cap_sr=16000 cap_ch=1 prebuf=0 last_fp=m=stt-rt-preview-v2|sr=16000|ch=1|h=en,zh|ctx=599674829880034847
t=1245872 sess=I7F lvl=INFO cat=stream evt=temp_key_fetch_start
🔥 [PREWARM DEBUG] Pre-warming AI connection (target: Gemini), environment: flyio
⚡ [CACHE-HIT] Retrieved temp key in 1.4ms
t=1245873 sess=I7F lvl=INFO cat=stream evt=temp_key_fetch latency_ms=1 expires_in_s=-1 source=cached
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🧪 [PROMO] config_fp current=m=stt-rt-preview-v2|sr=16000|ch=1|h=en,zh|ctx=599674829880034847 last=m=stt-rt-preview-v2|sr=16000|ch=1|h=en,zh|ctx=599674829880034847
🎤 Registering audio tap for Soniox
t=1245893 sess=I7F lvl=INFO cat=audio evt=record_start service=Soniox
🔍 Performing audio system pre-flight checks
throwing -10877
throwing -10877
✅ Pre-flight checks passed
t=1245987 sess=I7F lvl=INFO cat=audio evt=tap_install backend=avcapture service=Soniox ok=true
t=1245987 sess=I7F lvl=INFO cat=audio evt=record_start reason=start_capture
t=1245987 sess=I7F lvl=INFO cat=audio evt=device_pin_start desired_uid_hash=-1685521486385182984 prev_name="MacBook Pro Microphone" desired_name="MacBook Pro Microphone" prev_uid_hash=-1685521486385182984 desired_id=181 prev_id=181
t=1245987 sess=I7F lvl=INFO cat=audio evt=capture_backend_selected backend=avcapture
✅ Unified audio capture started
✅ Selected account account-bundle (connections: 1/10)
🎬 [NER-PREWARM] Using raw OCR text for NER: 1071 characters
🧠 [NER-DEFAULT] Using default NER prompt for general extraction
🧠 [TEN-VAD] Initialized (threshold=0.5, hop=256)
🚀 Starting Clio streaming transcription
🏥 [AUDIO HEALTH] Health monitoring timer started
⏱️ [TIMING] mic_engaged @ 1756280021.603
⏱️ [TIMING] WebSocket connect task completed — will flush after READY
pass
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
t=1246137 sess=I7F lvl=INFO cat=audio evt=avcapture_start ok=true
t=1246137 sess=I7F lvl=INFO cat=stream evt=first_audio_buffer_captured ms=107
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
🧪 [PROMO] first_audio seq=0 bytes=372 approx_db=-60.0
t=1246139 sess=I7F lvl=INFO cat=audio evt=level avg_db=-60 peak_db=-60
✅ [AUDIO HEALTH] First audio data received - tap is functional
t=1246139 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 flushing=false seq=0
t=1246187 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true seq=1 flushing=false
t=1246187 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true seq=2 flushing=false
t=1246187 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true seq=3 flushing=false
t=1246187 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true seq=4 flushing=false
t=1246187 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true seq=5 flushing=false
t=1246187 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true seq=6 flushing=false
t=1246187 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=360 has_socket=true seq=7 flushing=false
t=1246187 sess=I7F lvl=INFO cat=stream evt=first_audio_sent seq=0 ms=158
🌐 [ASR BREAKDOWN] Total: 549ms | Client↔Proxy: 286ms | Proxy↔Soniox: 263ms | Network: 263ms
🗑️ Evicted oldest temp key to maintain cache size limit
💾 Cached temp key for languages: ["zh", "en"]
🗓️ [TTL-SCHEDULE] Scheduling temp key refresh for key=global in 3000s (expiresAt=2025-08-27 08:33:41 +0000)
t=1246188 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=360 has_socket=true ready=true flushing=false seq=8
t=1246188 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=9
t=1246188 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=10
t=1246188 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=11
t=1246188 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=12
✅ [PREFETCH] Successfully prefetched temp key
🎤 [WARMUP] Pre-warming audio system...
✅ [PREWARM] Device enumeration completed
✅ [PREWARM] Audio system pre-warming completed successfully
✅ [WARMUP] Audio system pre-warmed successfully
t=1246201 sess=I7F lvl=INFO cat=stream evt=pre_send seq=13 ready=true has_socket=true bytes=372 flushing=false
t=1246208 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=14
t=1246219 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true seq=15 flushing=false
t=1246231 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 seq=16 has_socket=true
t=1246242 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=17
🗣️ [TEN-VAD] Speech start detected
t=1246254 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true seq=18 flushing=false
t=1246266 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=19
🛑 [TEN-VAD] Speech end detected
t=1246277 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=20
t=1246289 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=21 bytes=372 flushing=false has_socket=true
t=1246301 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=22 bytes=372 flushing=false has_socket=true
t=1246312 sess=I7F lvl=INFO cat=stream evt=pre_send seq=23 flushing=false ready=true has_socket=true bytes=372
t=1246324 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=24 has_socket=true flushing=false bytes=372
t=1246335 sess=I7F lvl=INFO cat=stream evt=pre_send seq=25 flushing=false ready=true has_socket=true bytes=372
t=1246347 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 seq=26 has_socket=true
🧪 [PROMO] audio_bytes bytes=10020
t=1246359 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=27
t=1246370 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=28
t=1246382 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=29 ready=true bytes=372 flushing=false
t=1246401 sess=I7F lvl=INFO cat=stream evt=pre_send seq=30 ready=true flushing=false bytes=372 has_socket=true
t=1246406 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=31
t=1246417 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=32 bytes=372 flushing=false has_socket=true
t=1246428 sess=I7F lvl=INFO cat=stream evt=pre_send seq=33 flushing=false bytes=372 ready=true has_socket=true
t=1246440 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=34
t=1246453 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=35
t=1246464 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=36 has_socket=true ready=true flushing=false
t=1246476 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false has_socket=true seq=37
t=1246487 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true ready=true seq=38
t=1246498 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=39
t=1246510 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=40 ready=true flushing=false bytes=372
t=1246524 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=41
t=1246537 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false has_socket=true seq=42
🌐 [PATH] Initial path baseline set — no action
t=1246545 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=43
t=1246557 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=44
t=1246570 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true has_socket=true seq=45
t=1246579 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=46
t=1246591 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=47
t=1246603 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=48
t=1246614 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=49
t=1246626 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false ready=true seq=50
t=1246637 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=51 has_socket=true flushing=false
t=1246650 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=52
t=1246661 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=53
t=1246673 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=54
t=1246687 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=55
t=1246696 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 ready=true seq=56 flushing=false
t=1246708 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=57
t=1246720 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=58 ready=true
t=1246730 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=59
t=1246744 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=60 flushing=false
t=1246754 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=61 has_socket=true ready=true flushing=false
t=1246766 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=62
t=1246777 sess=I7F lvl=INFO cat=stream evt=pre_send seq=63 bytes=372 flushing=false ready=true has_socket=true
t=1246790 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=64
t=1246802 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true ready=true seq=65
t=1246812 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=66 ready=true has_socket=true
t=1246823 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=67
t=1246835 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true ready=true seq=68
t=1246846 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true seq=69 bytes=372
t=1246860 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=70
t=1246871 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false has_socket=true seq=71
t=1246882 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false ready=true seq=72
t=1246893 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false ready=true seq=73
t=1246911 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=74 ready=true has_socket=true flushing=false
t=1246923 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=75
t=1246928 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=76
t=1246940 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true seq=77 bytes=372
t=1246952 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=78 ready=true flushing=false has_socket=true
t=1246963 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=79
t=1246975 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=80
🧪 [PROMO] audio_bytes bytes=30108
t=1246986 sess=I7F lvl=INFO cat=stream evt=pre_send seq=81 bytes=372 flushing=false ready=true has_socket=true
t=1246999 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=82
t=1247010 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false seq=83 ready=true bytes=372 has_socket=true
t=1247021 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=84
t=1247033 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=85
t=1247044 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=86
t=1247056 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false has_socket=true seq=87
t=1247069 sess=I7F lvl=INFO cat=stream evt=pre_send seq=88 bytes=372 ready=true has_socket=true flushing=false
t=1247079 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=89 bytes=372 has_socket=true flushing=false
t=1247091 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true seq=90 bytes=372
t=1247102 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=91
t=1247114 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=92 has_socket=true flushing=false
t=1247126 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=93
t=1247137 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 seq=94 flushing=false
t=1247149 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=95
t=1247160 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false has_socket=true seq=96
t=1247173 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=97
t=1247185 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=98 has_socket=true flushing=false ready=true
t=1247195 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=99 flushing=false ready=true bytes=372
t=1247206 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true seq=100 bytes=372
t=1247220 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true ready=true seq=101
t=1247230 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=102
t=1247242 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false ready=true seq=103 has_socket=true bytes=372
t=1247253 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false has_socket=true seq=104
t=1247265 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=105 has_socket=true flushing=false
t=1247277 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true seq=106 bytes=372
t=1247289 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=107
throwing -10877
throwing -10877
t=1247372 sess=I7F lvl=INFO cat=stream evt=pre_send seq=108 ready=true bytes=372 has_socket=true flushing=false
t=1247372 sess=I7F lvl=INFO cat=stream evt=pre_send seq=109 ready=true bytes=372 has_socket=true flushing=false
t=1247372 sess=I7F lvl=INFO cat=stream evt=pre_send seq=110 ready=true bytes=372 has_socket=true flushing=false
t=1247372 sess=I7F lvl=INFO cat=stream evt=pre_send seq=111 ready=true bytes=372 has_socket=true flushing=false
t=1247372 sess=I7F lvl=INFO cat=stream evt=pre_send seq=112 ready=true bytes=372 has_socket=true flushing=false
t=1247373 sess=I7F lvl=INFO cat=stream evt=pre_send seq=113 ready=true bytes=372 has_socket=true flushing=false
t=1247373 sess=I7F lvl=INFO cat=stream evt=pre_send seq=114 ready=true bytes=372 has_socket=true flushing=false
t=1247380 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 flushing=false seq=115
t=1247392 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=116 ready=true has_socket=true
t=1247404 sess=I7F lvl=INFO cat=stream evt=pre_send seq=117 flushing=false bytes=372 has_socket=true ready=true
t=1247421 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=118
t=1247427 sess=I7F lvl=INFO cat=stream evt=pre_send seq=119 flushing=false bytes=372 has_socket=true ready=true
t=1247438 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=120 has_socket=true
t=1247451 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=121
t=1247462 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=122 has_socket=true ready=true flushing=false
t=1247474 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=123
t=1247485 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=124 bytes=372 ready=true flushing=false
t=1247498 sess=I7F lvl=INFO cat=stream evt=pre_send seq=125 flushing=false ready=true bytes=372 has_socket=true
t=1247510 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=126 flushing=false
t=1247520 sess=I7F lvl=INFO cat=stream evt=pre_send seq=127 ready=true has_socket=true bytes=372 flushing=false
t=1247532 sess=I7F lvl=INFO cat=stream evt=pre_send seq=128 flushing=false ready=true has_socket=true bytes=372
t=1247543 sess=I7F lvl=INFO cat=stream evt=pre_send seq=129 flushing=false ready=true has_socket=true bytes=372
t=1247555 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=130
t=1247566 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=131 bytes=372 ready=true flushing=false
t=1247578 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=132
t=1247590 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=133
t=1247601 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=134
t=1247616 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=135
t=1247625 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=136
t=1247636 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false ready=true seq=137
t=1247648 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=138
t=1247659 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=139
t=1247671 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=140 bytes=372
t=1247683 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=141
t=1247695 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=142
t=1247706 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false ready=true seq=143
t=1247718 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=144
t=1247729 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=145 flushing=false
t=1247740 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=146
t=1247752 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=147
t=1247764 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 ready=true seq=148
t=1247776 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 ready=true seq=149 flushing=false
t=1247787 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 ready=true seq=150
t=1247799 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 ready=true seq=151 flushing=false
t=1247810 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 ready=true seq=152
t=1247822 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=153 has_socket=true ready=true flushing=false
t=1247834 sess=I7F lvl=INFO cat=stream evt=pre_send seq=154 bytes=372 flushing=false has_socket=true ready=true
t=1247846 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=155 ready=true flushing=false has_socket=true
t=1247857 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=156 flushing=false
t=1247868 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=157 bytes=372 has_socket=true
t=1247879 sess=I7F lvl=INFO cat=stream evt=first_partial ms=1849
t=1247879 sess=I7F lvl=INFO cat=stream evt=ttft_hotkey ms=1849
t=1247879 sess=I7F lvl=INFO cat=stream evt=ttft ms=1636
🧪 [PROMO] first_token ms=2008 tokens_in_msg=1
t=1247881 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=158 has_socket=true ready=true flushing=false
t=1247974 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true seq=159 flushing=false
t=1247974 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true seq=160 flushing=false
t=1247974 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true seq=161 flushing=false
t=1247974 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true seq=162 flushing=false
t=1247974 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true seq=163 flushing=false
t=1247974 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true seq=164 flushing=false
t=1247974 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true seq=165 flushing=false
t=1247974 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true seq=166 flushing=false
t=1247984 sess=I7F lvl=INFO cat=stream evt=pre_send seq=167 flushing=false ready=true has_socket=true bytes=372
t=1247996 sess=I7F lvl=INFO cat=stream evt=pre_send seq=168 flushing=false ready=true has_socket=true bytes=372
t=1248007 sess=I7F lvl=INFO cat=stream evt=pre_send seq=169 flushing=false ready=true has_socket=true bytes=372
t=1248019 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=170
t=1248031 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=171 has_socket=true flushing=false bytes=372
t=1248042 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=172 has_socket=true flushing=false bytes=372
t=1248054 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true seq=173 flushing=false
t=1248065 sess=I7F lvl=INFO cat=stream evt=pre_send seq=174 flushing=false ready=true has_socket=true bytes=372
t=1248077 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=175 bytes=372
t=1248089 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=176 has_socket=true flushing=false bytes=372
t=1248100 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 seq=177 ready=true
t=1248112 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=178 has_socket=true bytes=372 flushing=false
t=1248123 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=179
t=1248169 sess=I7F lvl=INFO cat=audio evt=level peak_db=-35 avg_db=-35
t=1248169 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=180
t=1248169 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=181
t=1248169 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=182
t=1248202 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=183 ready=true has_socket=true flushing=false
t=1248202 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=184 ready=true has_socket=true flushing=false
t=1248202 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=185 ready=true has_socket=true flushing=false
t=1248205 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=186 ready=true flushing=false
t=1248216 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=187 has_socket=true
t=1248228 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=188 flushing=false ready=true bytes=372
t=1248239 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=189 has_socket=true
t=1248267 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=190 bytes=372
t=1248267 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=191 bytes=372
t=1248300 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=192 ready=true
t=1248300 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=193 ready=true
t=1248300 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=194 ready=true
t=1248309 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=195 bytes=372 has_socket=true
t=1248321 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=196 has_socket=true
t=1248332 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=197 ready=true flushing=false
t=1248344 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=198 ready=true flushing=false
t=1248355 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=199
t=1248367 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=200
t=1248400 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=201 flushing=false has_socket=true ready=true
t=1248400 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=202 flushing=false has_socket=true ready=true
t=1248432 sess=I7F lvl=INFO cat=stream evt=pre_send seq=203 flushing=false bytes=372 has_socket=true ready=true
t=1248432 sess=I7F lvl=INFO cat=stream evt=pre_send seq=204 flushing=false bytes=372 has_socket=true ready=true
t=1248432 sess=I7F lvl=INFO cat=stream evt=pre_send seq=205 flushing=false bytes=372 has_socket=true ready=true
t=1248437 sess=I7F lvl=INFO cat=stream evt=pre_send seq=206 bytes=372 has_socket=true ready=true flushing=false
t=1248448 sess=I7F lvl=INFO cat=stream evt=pre_send seq=207 has_socket=true flushing=false ready=true bytes=372
t=1248460 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=208
t=1248472 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=209
t=1248483 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=210 ready=true has_socket=true
t=1248495 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=211
t=1248506 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=212 bytes=372 flushing=false has_socket=true
t=1248572 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=213
t=1248572 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=214
t=1248572 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=215
t=1248572 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=216
t=1248572 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=217
t=1248576 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=218 has_socket=true flushing=false bytes=372
t=1248588 sess=I7F lvl=INFO cat=stream evt=pre_send seq=219 has_socket=true flushing=false ready=true bytes=372
t=1248650 sess=I7F lvl=INFO cat=stream evt=pre_send seq=220 has_socket=true flushing=false ready=true bytes=372
t=1248650 sess=I7F lvl=INFO cat=stream evt=pre_send seq=221 has_socket=true flushing=false ready=true bytes=372
t=1248650 sess=I7F lvl=INFO cat=stream evt=pre_send seq=222 has_socket=true flushing=false ready=true bytes=372
t=1248650 sess=I7F lvl=INFO cat=stream evt=pre_send seq=223 has_socket=true flushing=false ready=true bytes=372
t=1248650 sess=I7F lvl=INFO cat=stream evt=pre_send seq=224 has_socket=true flushing=false ready=true bytes=372
t=1248657 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=225
t=1248669 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=226
t=1248681 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=227 ready=true flushing=false
t=1248692 sess=I7F lvl=INFO cat=stream evt=pre_send seq=228 bytes=372 has_socket=true flushing=false ready=true
t=1248704 sess=I7F lvl=INFO cat=stream evt=pre_send seq=229 bytes=372 has_socket=true flushing=false ready=true
t=1248715 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=230 has_socket=true
t=1248784 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=231 has_socket=true
t=1248785 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=232 has_socket=true
t=1248785 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=233 has_socket=true
t=1248785 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=234 bytes=372 has_socket=true
t=1248785 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=235 bytes=372 has_socket=true
t=1248785 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=236
t=1248797 sess=I7F lvl=INFO cat=stream evt=pre_send seq=237 flushing=false ready=true bytes=372 has_socket=true
t=1248809 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=238
t=1248820 sess=I7F lvl=INFO cat=stream evt=pre_send seq=239 flushing=false ready=true bytes=372 has_socket=true
t=1248832 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=240 bytes=372 has_socket=true
t=1248891 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true ready=true seq=241
t=1248891 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true ready=true seq=242
t=1248892 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true ready=true seq=243
t=1248892 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true ready=true seq=244
t=1248892 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true ready=true seq=245
t=1248901 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=246 bytes=372 flushing=false has_socket=true
t=1248913 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 seq=247 flushing=false
t=1248924 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true seq=248 flushing=false
t=1248936 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=249 bytes=372 has_socket=true
t=1248954 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=250 has_socket=true
t=1248959 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=251 bytes=372 flushing=false has_socket=true
t=1248987 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true seq=252 flushing=false
t=1248987 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true seq=253 flushing=false
t=1249019 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true seq=254 flushing=false bytes=372
t=1249019 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true seq=255 flushing=false bytes=372
t=1249019 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true seq=256 flushing=false bytes=372
t=1249029 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true seq=257 flushing=false
t=1249041 sess=I7F lvl=INFO cat=stream evt=pre_send seq=258 flushing=false ready=true bytes=372 has_socket=true
t=1249052 sess=I7F lvl=INFO cat=stream evt=pre_send seq=259 ready=true has_socket=true flushing=false bytes=372
t=1249064 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=260 has_socket=true flushing=false bytes=372
t=1249075 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=261 has_socket=true
t=1249087 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true seq=262 bytes=372
t=1249118 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true seq=263 flushing=false
t=1249118 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true seq=264 flushing=false
t=1249149 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true seq=265 flushing=false
t=1249149 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true seq=266 flushing=false
t=1249149 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true seq=267 flushing=false
t=1249157 sess=I7F lvl=INFO cat=stream evt=pre_send seq=268 ready=true bytes=372 flushing=false has_socket=true
t=1249168 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=269 has_socket=true flushing=false bytes=372
t=1249180 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=270 ready=true flushing=false
t=1249192 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=271 has_socket=true flushing=false bytes=372
t=1249203 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=272 has_socket=true ready=true flushing=false
t=1249215 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=273 has_socket=true flushing=false bytes=372
t=1249226 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true seq=274 flushing=false
t=1249238 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true seq=275 flushing=false
t=1249250 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true seq=276 flushing=false
t=1249261 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=277
t=1249273 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true seq=278 flushing=false
t=1249284 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=279
t=1249296 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=280
t=1249308 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=281 bytes=372
t=1249319 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=282 has_socket=true flushing=false bytes=372
t=1249372 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=283
t=1249372 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=284
t=1249372 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=285
t=1249372 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=286
t=1249407 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=287 bytes=372 flushing=false has_socket=true
t=1249407 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=288 bytes=372 flushing=false has_socket=true
t=1249407 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=289 bytes=372 flushing=false has_socket=true
t=1249412 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true seq=290 flushing=false
t=1249424 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=291 bytes=372 flushing=false has_socket=true
t=1249435 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=292 bytes=372 ready=true
t=1249447 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=293
t=1249458 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=294 has_socket=true flushing=false bytes=372
t=1249471 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=295 has_socket=true flushing=false bytes=372
t=1249482 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=296
t=1249493 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=297
t=1249505 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=298
t=1249517 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=299 bytes=372 flushing=false has_socket=true
t=1249528 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=300
t=1249601 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=301
t=1249601 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=302
t=1249601 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=303
t=1249601 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=304
t=1249601 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=305
t=1249601 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=306
t=1249609 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true seq=307 flushing=false
t=1249621 sess=I7F lvl=INFO cat=stream evt=pre_send seq=308 flushing=false bytes=372 ready=true has_socket=true
t=1249633 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=309
t=1249645 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true seq=310 flushing=false
t=1249656 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true seq=311 flushing=false
t=1249667 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=312
t=1249679 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=313
t=1249741 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true ready=true seq=314
t=1249741 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true ready=true seq=315
t=1249741 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true ready=true seq=316
t=1249741 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true ready=true seq=317
t=1249741 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true ready=true seq=318
t=1249749 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=319
t=1249760 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=320 has_socket=true flushing=false bytes=372
t=1249772 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=321 has_socket=true flushing=false bytes=372
t=1249784 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=322
t=1249821 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=323 has_socket=true flushing=false bytes=372
t=1249821 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=324 has_socket=true flushing=false bytes=372
t=1249821 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=325 has_socket=true flushing=false bytes=372
t=1249853 sess=I7F lvl=INFO cat=stream evt=pre_send seq=326 ready=true flushing=false has_socket=true bytes=372
t=1249853 sess=I7F lvl=INFO cat=stream evt=pre_send seq=327 ready=true flushing=false has_socket=true bytes=372
t=1249853 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true ready=true seq=328
t=1249865 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=329 bytes=372
t=1249877 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true seq=330 flushing=false
t=1249888 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=331 has_socket=true
t=1249900 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=332
t=1249911 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=333
t=1249923 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=334 bytes=372 flushing=false has_socket=true
t=1249934 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=335
t=1249946 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=336
t=1249958 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=337 has_socket=true ready=true
🛑 [TEN-VAD] Speech end detected
t=1249970 sess=I7F lvl=INFO cat=stream evt=pre_send seq=338 ready=true flushing=false has_socket=true bytes=372
t=1249981 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=339 ready=true flushing=false
t=1249992 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=340 ready=true flushing=false
t=1250004 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=341 ready=true flushing=false
t=1250016 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=342 bytes=372 flushing=false has_socket=true
t=1250028 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=343
t=1250096 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=344 bytes=372 ready=true
t=1250096 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=345 bytes=372 ready=true
t=1250097 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=346 bytes=372 ready=true
t=1250097 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=347 bytes=372 ready=true
t=1250097 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=348 bytes=372 ready=true
t=1250097 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=349
t=1250109 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=350
t=1250120 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true seq=351 flushing=false
t=1250132 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=352 has_socket=true
t=1250143 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=353 ready=true flushing=false
t=1250203 sess=I7F lvl=INFO cat=audio evt=level avg_db=-38 peak_db=-38
t=1250203 sess=I7F lvl=INFO cat=stream evt=pre_send seq=354 ready=true has_socket=true flushing=false bytes=372
t=1250203 sess=I7F lvl=INFO cat=stream evt=pre_send seq=355 ready=true has_socket=true flushing=false bytes=372
t=1250203 sess=I7F lvl=INFO cat=stream evt=pre_send seq=356 ready=true has_socket=true flushing=false bytes=372
t=1250203 sess=I7F lvl=INFO cat=stream evt=pre_send seq=357 ready=true has_socket=true flushing=false bytes=372
t=1250203 sess=I7F lvl=INFO cat=stream evt=pre_send seq=358 ready=true has_socket=true flushing=false bytes=372
t=1250213 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=359
t=1250225 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=360 ready=true
t=1250236 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=361
t=1250248 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=362
t=1250260 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=363
t=1250271 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true seq=364 flushing=false
t=1250330 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=365 has_socket=true flushing=false bytes=372
t=1250330 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=366 has_socket=true flushing=false bytes=372
t=1250330 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=367 has_socket=true flushing=false bytes=372
t=1250330 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=368 has_socket=true flushing=false bytes=372
t=1250330 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=369 has_socket=true flushing=false bytes=372
t=1250341 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=370
t=1250352 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=371 has_socket=true flushing=false bytes=372
t=1250364 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=372 bytes=372 flushing=false has_socket=true
t=1250376 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false seq=373 ready=true
t=1250387 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true seq=374 flushing=false
t=1250399 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true ready=true bytes=372 seq=375
t=1250410 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=376
t=1250422 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=377
t=1250434 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false seq=378 ready=true
t=1250445 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=379 bytes=372 flushing=false has_socket=true
t=1250457 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=380 ready=true flushing=false
t=1250469 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=381 bytes=372
t=1250486 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true ready=true seq=382
t=1250492 sess=I7F lvl=INFO cat=stream evt=pre_send seq=383 has_socket=true flushing=false ready=true bytes=372
t=1250534 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=384 ready=true flushing=false
t=1250534 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=385
t=1250534 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=386 ready=true flushing=false
t=1250567 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=387 flushing=false bytes=372 ready=true
t=1250567 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=388 flushing=false bytes=372 ready=true
t=1250567 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=389 ready=true flushing=false
t=1250573 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=390 bytes=372
t=1250585 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=391 flushing=false bytes=372 ready=true
t=1250596 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=392
t=1250608 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false ready=true has_socket=true bytes=372 seq=393
🛑 [TEN-VAD] Speech end detected
t=1250610 sess=I7F lvl=INFO cat=stream evt=first_final ms=4581
t=1250610 sess=I7F lvl=INFO cat=transcript evt=raw_final text=My
t=1250620 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=394
🤖 [FLY.IO-NER] Server-reported provider: gemini
📥 [NER-STORE] Stored NER entities: 2895 chars - The user has provided a screenshot of their Xcode IDE. Here's a breakdown of what's visible and the ...
✅ [FLY.IO] NER refresh completed successfully
t=1250684 sess=I7F lvl=INFO cat=stream evt=pre_send seq=395 has_socket=true flushing=false ready=true bytes=372
t=1250684 sess=I7F lvl=INFO cat=stream evt=pre_send seq=396 has_socket=true flushing=false ready=true bytes=372
t=1250684 sess=I7F lvl=INFO cat=stream evt=pre_send seq=397 has_socket=true flushing=false ready=true bytes=372
t=1250684 sess=I7F lvl=INFO cat=stream evt=pre_send seq=398 has_socket=true flushing=false ready=true bytes=372
t=1250684 sess=I7F lvl=INFO cat=stream evt=pre_send seq=399 has_socket=true flushing=false ready=true bytes=372
t=1250689 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=400
t=1250701 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 seq=401 ready=true
t=1250712 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 ready=true has_socket=true flushing=false seq=402
t=1250724 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=403
t=1250736 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=404 bytes=372
t=1250747 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=405
t=1250759 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=406 has_socket=true flushing=false bytes=372
t=1250803 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=407 has_socket=true flushing=false bytes=372
t=1250803 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=408 has_socket=true flushing=false bytes=372
t=1250804 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=409 has_socket=true flushing=false bytes=372
t=1250835 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=410
t=1250836 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=411
t=1250836 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=412
t=1250840 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true seq=413 flushing=false
t=1250852 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=414
t=1250863 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=415 bytes=372
t=1250875 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=416 bytes=372
t=1250952 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=417
t=1250952 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=418
t=1250952 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=419
t=1250952 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=420
t=1250952 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=421
t=1250952 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=422
t=1250956 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=423 has_socket=true flushing=false bytes=372
t=1250968 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=424 has_socket=true flushing=false bytes=372
t=1250979 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=425 has_socket=true flushing=false bytes=372
t=1250998 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 flushing=false seq=426
t=1251003 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=427 has_socket=true flushing=false bytes=372
t=1251015 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=428 bytes=372 has_socket=true
t=1251026 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=429 ready=true flushing=false
t=1251038 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=430 has_socket=true flushing=false bytes=372
t=1251049 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 flushing=false seq=431
t=1251061 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=432
t=1251072 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=433
t=1251084 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=434 bytes=372 flushing=false has_socket=true
t=1251095 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=435 bytes=372 flushing=false has_socket=true
t=1251107 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=436 bytes=372 has_socket=true
t=1251119 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=437 has_socket=true flushing=false bytes=372
t=1251191 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=438 has_socket=true
t=1251191 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=439 has_socket=true
t=1251191 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=440 has_socket=true
t=1251191 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=441 has_socket=true
t=1251191 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=442 has_socket=true
t=1251191 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=443 has_socket=true
t=1251200 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=444
t=1251212 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false ready=true has_socket=true bytes=372 seq=445
t=1251223 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=446
t=1251293 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=447
t=1251293 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=448
t=1251293 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=449
t=1251293 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=450
t=1251293 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=451
t=1251293 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=452
t=1251305 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=453 bytes=372 flushing=false has_socket=true
t=1251316 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=454
t=1251328 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=455 has_socket=true flushing=false bytes=372
t=1251339 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true seq=456 flushing=false
t=1251351 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=457 bytes=372 flushing=false has_socket=true
t=1251362 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=458 has_socket=true flushing=false bytes=372
t=1251374 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=459 ready=true flushing=false
t=1251386 sess=I7F lvl=INFO cat=stream evt=pre_send seq=460 has_socket=true flushing=false ready=true bytes=372
t=1251397 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true seq=461 flushing=false
t=1251409 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=462 bytes=372 flushing=false has_socket=true
t=1251421 sess=I7F lvl=INFO cat=stream evt=pre_send seq=463 has_socket=true ready=true flushing=false bytes=372
t=1251432 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=464
t=1251444 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=465 has_socket=true
t=1251456 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=466 bytes=372 flushing=false has_socket=true
t=1251498 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 flushing=false seq=467
t=1251498 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 flushing=false seq=468
t=1251498 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 flushing=false seq=469
t=1251533 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=470
t=1251534 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=471
t=1251534 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=472
t=1251551 sess=I7F lvl=INFO cat=stream evt=pre_send seq=473 has_socket=true flushing=false ready=true bytes=372
t=1251551 sess=I7F lvl=INFO cat=stream evt=pre_send seq=474 has_socket=true flushing=false ready=true bytes=372
t=1251560 sess=I7F lvl=INFO cat=stream evt=pre_send seq=475 has_socket=true flushing=false ready=true bytes=372
t=1251571 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=476 has_socket=true flushing=false bytes=372
t=1251583 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=477 has_socket=true ready=true flushing=false
t=1251643 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 seq=478 flushing=false ready=true
t=1251643 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 seq=479 flushing=false ready=true
t=1251643 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 seq=480 flushing=false ready=true
t=1251643 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 seq=481 flushing=false ready=true
t=1251643 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 seq=482 flushing=false ready=true
t=1251653 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=483
t=1251664 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=484
t=1251676 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true seq=485 flushing=false
t=1251688 sess=I7F lvl=INFO cat=stream evt=pre_send seq=486 flushing=false has_socket=true ready=true bytes=372
t=1251699 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 seq=487 flushing=false ready=true
t=1251711 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=488
t=1251723 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=489 flushing=false has_socket=true bytes=372
t=1251792 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=490 ready=true flushing=false
t=1251792 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=491 ready=true flushing=false
t=1251792 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=492 ready=true flushing=false
t=1251792 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=493 ready=true flushing=false
t=1251792 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=494 ready=true flushing=false
t=1251792 sess=I7F lvl=INFO cat=stream evt=pre_send seq=495 has_socket=true flushing=false ready=true bytes=372
t=1251804 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=496
t=1251815 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=497 ready=true bytes=372
t=1251827 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false ready=true has_socket=true bytes=372 seq=498
t=1251838 sess=I7F lvl=INFO cat=stream evt=pre_send seq=499 ready=true has_socket=true flushing=false bytes=372
t=1251850 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true seq=500 flushing=false
t=1251862 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=501 ready=true flushing=false
t=1251873 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=502
t=1251885 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=503 ready=true flushing=false has_socket=true
t=1251897 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=504 bytes=372 flushing=false has_socket=true
t=1251908 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=505 has_socket=true flushing=false bytes=372
t=1251920 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=506
t=1251932 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=507 bytes=372 flushing=false has_socket=true
t=1251943 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=508
t=1251955 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=509 has_socket=true flushing=false bytes=372
t=1251966 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=510
t=1251978 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=511 ready=true flushing=false
t=1251990 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=512
t=1252012 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=513 has_socket=true flushing=false bytes=372
t=1252026 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=514 has_socket=true
t=1252026 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=515 has_socket=true
t=1252036 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=516
t=1252048 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=517
t=1252059 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=518 ready=true flushing=false
t=1252072 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=519
t=1252083 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=520
t=1252095 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=521
t=1252106 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=522
t=1252118 sess=I7F lvl=INFO cat=stream evt=pre_send seq=523 flushing=false ready=true has_socket=true bytes=372
t=1252129 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=524 ready=true flushing=false has_socket=true
t=1252141 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 seq=525 flushing=false
t=1252153 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=526 flushing=false
t=1252164 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=527
t=1252177 sess=I7F lvl=INFO cat=stream evt=pre_send seq=528 ready=true bytes=372 has_socket=true flushing=false
t=1252186 sess=I7F lvl=INFO cat=transcript evt=raw_final text=" company has been trying to roll out their"
t=1252188 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=529
t=1252294 sess=I7F lvl=INFO cat=audio evt=level peak_db=-35 avg_db=-35
t=1252294 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false ready=true has_socket=true bytes=372 seq=530
t=1252294 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false ready=true has_socket=true bytes=372 seq=531
t=1252294 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false ready=true has_socket=true bytes=372 seq=532
t=1252294 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false ready=true has_socket=true bytes=372 seq=533
t=1252294 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false ready=true has_socket=true bytes=372 seq=534
t=1252294 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false ready=true has_socket=true bytes=372 seq=535
t=1252294 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false ready=true has_socket=true bytes=372 seq=536
t=1252294 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false ready=true has_socket=true bytes=372 seq=537
t=1252294 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false ready=true has_socket=true bytes=372 seq=538
throwing -10877
throwing -10877
t=1252534 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 seq=539 flushing=false
t=1252534 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 seq=540 flushing=false
t=1252534 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=541
t=1252534 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=542 ready=true flushing=false
t=1252534 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=543 has_socket=true flushing=false bytes=372
t=1252534 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=544 has_socket=true flushing=false bytes=372
t=1252534 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=545 has_socket=true flushing=false bytes=372
t=1252535 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=546 has_socket=true flushing=false bytes=372
t=1252535 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=547 has_socket=true flushing=false bytes=372
t=1252535 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=548 has_socket=true flushing=false bytes=372
t=1252535 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=549 has_socket=true flushing=false bytes=372
t=1252535 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=550 has_socket=true flushing=false bytes=372
t=1252535 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=551 has_socket=true flushing=false bytes=372
t=1252535 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=552 has_socket=true flushing=false bytes=372
t=1252535 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 flushing=false seq=553
t=1252572 sess=I7F lvl=INFO cat=stream evt=pre_send seq=554 flushing=false bytes=372 has_socket=true ready=true
t=1252572 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true seq=555 flushing=false
t=1252572 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true seq=556 flushing=false
t=1252572 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true seq=557 flushing=false
t=1252572 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true seq=558 flushing=false
🛑 [TEN-VAD] Speech end detected
t=1252573 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true seq=559 bytes=372
t=1252573 sess=I7F lvl=INFO cat=stream evt=pre_send seq=560 has_socket=true ready=true flushing=false bytes=372
t=1252580 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=561
t=1252580 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=562
t=1252626 sess=I7F lvl=INFO cat=stream evt=pre_send seq=563 flushing=false ready=true bytes=372 has_socket=true
t=1252627 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=564
t=1252627 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=565
t=1252627 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=566
t=1252680 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=567 ready=true flushing=false
t=1252717 sess=I7F lvl=INFO cat=stream evt=pre_send seq=568 flushing=false bytes=372 has_socket=true ready=true
t=1252717 sess=I7F lvl=INFO cat=stream evt=pre_send seq=569 flushing=false bytes=372 has_socket=true ready=true
t=1252717 sess=I7F lvl=INFO cat=stream evt=pre_send seq=570 flushing=false bytes=372 has_socket=true ready=true
t=1252717 sess=I7F lvl=INFO cat=stream evt=pre_send seq=571 flushing=false bytes=372 has_socket=true ready=true
t=1252723 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false seq=572 ready=true has_socket=true bytes=372
t=1252723 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false seq=573 ready=true has_socket=true bytes=372
t=1252723 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false seq=574 ready=true has_socket=true bytes=372
t=1252723 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true seq=575 bytes=372
t=1252794 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=576
t=1252794 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=577
t=1252794 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=578
t=1252795 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=579 has_socket=true
t=1252795 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=580 has_socket=true
t=1252795 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=581 has_socket=true
t=1252831 sess=I7F lvl=INFO cat=stream evt=pre_send seq=582 bytes=372 flushing=false has_socket=true ready=true
t=1252832 sess=I7F lvl=INFO cat=stream evt=pre_send seq=583 bytes=372 flushing=false has_socket=true ready=true
t=1252832 sess=I7F lvl=INFO cat=stream evt=pre_send seq=584 bytes=372 flushing=false has_socket=true ready=true
t=1252837 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=585
t=1252849 sess=I7F lvl=INFO cat=stream evt=pre_send seq=586 has_socket=true flushing=false ready=true bytes=372
t=1252919 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=587 ready=true flushing=false
t=1252919 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=588 ready=true flushing=false
t=1252919 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=589 ready=true flushing=false
t=1252919 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true ready=true seq=590
t=1252919 sess=I7F lvl=INFO cat=stream evt=pre_send seq=591 bytes=372 has_socket=true flushing=false ready=true
t=1252919 sess=I7F lvl=INFO cat=stream evt=pre_send seq=592 bytes=372 has_socket=true flushing=false ready=true
t=1252930 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=593 has_socket=true
t=1252942 sess=I7F lvl=INFO cat=stream evt=pre_send seq=594 bytes=372 has_socket=true ready=true flushing=false
t=1252953 sess=I7F lvl=INFO cat=stream evt=pre_send seq=595 bytes=372 has_socket=true ready=true flushing=false
t=1252965 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true seq=596 flushing=false
t=1252976 sess=I7F lvl=INFO cat=stream evt=pre_send seq=597 ready=true has_socket=true bytes=372 flushing=false
t=1252988 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 flushing=false seq=598
t=1253000 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 flushing=false seq=599
t=1253011 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=600
t=1253033 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 flushing=false seq=601
t=1253034 sess=I7F lvl=INFO cat=stream evt=pre_send seq=602 flushing=false bytes=372 has_socket=true ready=true
t=1253046 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=603 flushing=false bytes=372 ready=true
t=1253058 sess=I7F lvl=INFO cat=stream evt=pre_send seq=604 ready=true has_socket=true bytes=372 flushing=false
t=1253069 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 flushing=false seq=605
t=1253140 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=606 bytes=372
t=1253140 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=607 bytes=372
t=1253140 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false ready=true has_socket=true bytes=372 seq=608
t=1253141 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false ready=true has_socket=true bytes=372 seq=609
t=1253141 sess=I7F lvl=INFO cat=stream evt=pre_send seq=610 has_socket=true ready=true flushing=false bytes=372
t=1253141 sess=I7F lvl=INFO cat=stream evt=pre_send seq=611 has_socket=true ready=true flushing=false bytes=372
t=1253151 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=612 ready=true has_socket=true
t=1253162 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=613 ready=true has_socket=true
t=1253174 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=614 flushing=false ready=true has_socket=true
t=1253185 sess=I7F lvl=INFO cat=stream evt=pre_send seq=615 flushing=false bytes=372 has_socket=true ready=true
t=1253197 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=616 has_socket=true flushing=false
t=1253230 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 flushing=false seq=617
t=1253231 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 flushing=false seq=618
t=1253264 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=619 bytes=372 flushing=false has_socket=true
t=1253264 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=620 bytes=372 flushing=false has_socket=true
t=1253264 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=621 bytes=372 flushing=false has_socket=true
t=1253267 sess=I7F lvl=INFO cat=stream evt=pre_send seq=622 ready=true has_socket=true bytes=372 flushing=false
t=1253278 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 flushing=false seq=623
t=1253290 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=624 has_socket=true
t=1253301 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=625 has_socket=true
t=1253307 sess=I7F lvl=INFO cat=transcript evt=raw_final text=" own AI tooling and had a"
t=1253313 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=626 ready=true flushing=false bytes=372
t=1253384 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=627
t=1253384 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=628
t=1253385 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true ready=true seq=629
t=1253385 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true ready=true seq=630
t=1253385 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true ready=true seq=631
t=1253385 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=632
t=1253394 sess=I7F lvl=INFO cat=stream evt=pre_send seq=633 flushing=false bytes=372 has_socket=true ready=true
t=1253406 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true seq=634 bytes=372
t=1253417 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=635
t=1253429 sess=I7F lvl=INFO cat=stream evt=pre_send seq=636 has_socket=true ready=true flushing=false bytes=372
t=1253441 sess=I7F lvl=INFO cat=stream evt=pre_send seq=637 flushing=false bytes=372 has_socket=true ready=true
t=1253452 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=638 ready=true flushing=false
t=1253464 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=639 flushing=false ready=true bytes=372
t=1253476 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=640 has_socket=true
t=1253487 sess=I7F lvl=INFO cat=stream evt=pre_send seq=641 has_socket=true bytes=372 ready=true flushing=false
t=1253555 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=642 ready=true flushing=false
t=1253555 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=643 ready=true flushing=false
t=1253555 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=644 ready=true flushing=false
🛑 [TEN-VAD] Speech end detected
t=1253555 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=645 ready=true flushing=false
t=1253555 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=646 ready=true flushing=false
🛑 Stopping recording
🛑 Stopping Clio streaming transcription
t=1253595 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true seq=647 flushing=false
🏥 [AUDIO HEALTH] Health monitoring timer stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
🛑 Stopping unified audio capture
t=1253623 sess=I7F lvl=INFO cat=audio evt=record_stop
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key plugInPackage
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key CMIOType
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key numberOfDevices
t=1253632 sess=I7F lvl=INFO cat=audio evt=avcapture_stop
✅ Unified audio capture stopped
t=1253632 sess=I7F lvl=INFO cat=stream evt=pre_send seq=648 flushing=false bytes=372 has_socket=true ready=true
t=1253632 sess=I7F lvl=INFO cat=stream evt=pre_send seq=649 flushing=false bytes=372 has_socket=true ready=true
t=1253632 sess=I7F lvl=INFO cat=stream evt=pre_send seq=650 flushing=false bytes=372 has_socket=true ready=true
t=1253661 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=651 flushing=false bytes=372
t=1253661 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=652 flushing=false bytes=372
📤 Sent end-of-stream signal
📤 Sent manual finalize command
🕐 Using finalization timeout: 400ms (connection took 7732ms)
ℹ️ [OPTIMISTIC] Not skipping: end=false pending=0 ms_since_last=98 tail=100 silence_ok=false tokens_quiet_ok=true partial_empty=false uncond=false
⚠️ Timed out waiting for <fin> token after 484ms — merging partial transcript
⏹️ Keepalive timer stopped
⚡ Audio capture already stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
📉 Released connection for account account-bundle (connections: 0)
💾 [COLD-START] Updated successful streaming timestamp
💾 [COLD-START] Updated successful streaming timestamp
✅ Streaming transcription completed successfully, length: 135 characters
✅ Streaming stopped. Final transcript (135 chars, 8.2s, with audio file): "My company has been trying to roll out their own AI tooling and had a much higher failure rate. But because why pay for an AI tool when"
t=1254249 sess=I7F lvl=INFO cat=transcript evt=final text="My company has been trying to roll out their own AI tooling and had a much higher failure rate. But because why pay for an AI tool when"
⏱️ [TIMING] Subscription tracking: 0.9ms
⏱️ [TIMING] ASR word tracking: 0.1ms
🌡️ [WARM] warm_socket=yes
🧠 Performing intelligent end-context detection for streaming
⏱️ [CONTEXT DETAIL] Cache check: 0.0ms
⚡ [SMART-OPTIMIZATION] Using smart cached screen context (1071 chars) - skipping new capture
⏱️ [STREAMING CONTEXT TIMING] Screen capture + context detection: 0.1ms
t=1254251 sess=I7F lvl=INFO cat=transcript evt=session_end divider="────────── session end ──────────"
🔊 [SoundManager] Attempting to play stop sound
🔊 [SoundManager] NSSound stop sound result: true
🧹 Connection cleanup completed (session resources released)
📝 [GRACE] Recording session ended
📱 Dismissing recorder
⏹️ Keepalive timer stopped
⚠️ WebSocket did close with code 1001 (sid=sock_-6127485600891781528, attemptId=16)
t=1254327 sess=I7F lvl=WARN cat=stream evt=state state=closed code=1001
✅ Streaming transcription processing completed
t=1254373 sess=I7F lvl=INFO cat=transcript evt=insert_attempt target=Xcode chars=136 text="My company has been trying to roll out their own AI tooling and had a much higher failure rate. But because why pay for an AI tool when "
🔍 [PASTE DEBUG] AXIsProcessTrusted() returned true, proceeding
🔍 [PASTE DEBUG] UseDirectTextInsertion setting: false
🔍 [PASTE DEBUG] Direct insertion disabled, using clipboard paste
⌨️ Using CGEvent-based Command+V
t=1254382 sess=I7F lvl=INFO cat=transcript evt=insert_result ok=true
📊 [POST-RELEASE E2E] 786ms (paste=0ms) | warm_socket=no
🔌 [WS] Disconnected (socketId=sock_-6127485600891781528@attempt_16)
t=1254421 sess=I7F lvl=INFO cat=transcript evt=raw_final text=" much higher failure rate. But because YPay for an AI tool would.<end>"
🌐 [CONNECT] New single-flight request from warmHold
🌐 [CONNECT] Attempt #17 (loop 1/2) starting…
t=1254706 sess=I7F lvl=INFO cat=stream evt=temp_key_fetch_start
⚡ [CACHE-HIT] Retrieved temp key in 6.6ms
t=1254713 sess=I7F lvl=INFO cat=stream evt=temp_key_fetch latency_ms=6 expires_in_s=-1 source=cached
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🌐 [WS CONNECT] Using URL: wss://stt-rt.soniox.com/transcribe-websocket
🔗 [WS] Bound socket id=sock_1683487913678001120@attempt_17
t=1254714 sess=I7F lvl=INFO cat=stream evt=ws_bind path=/transcribe-websocket socket=sock_1683487913678001120@attempt_17 target_host=stt-rt.soniox.com target_ip=resolving... via_proxy=false attempt=17
🔑 Successfully connected to Soniox using temp key (8ms key latency)
t=1254716 sess=I7F lvl=INFO cat=stream evt=ws_bind_resolved via_proxy=false target_ip=129.146.176.251 path=/transcribe-websocket socket=sock_1683487913678001120@attempt_17 attempt=17 target_host=stt-rt.soniox.com




#3 Success
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
🎤 Registering audio tap for Soniox
t=1262295 sess=I7F lvl=INFO cat=audio evt=record_start service=Soniox
🔍 Performing audio system pre-flight checks
throwing -10877
throwing -10877
✅ Pre-flight checks passed
t=1262375 sess=I7F lvl=INFO cat=audio evt=tap_install service=Soniox backend=avcapture ok=true
t=1262375 sess=I7F lvl=INFO cat=audio evt=record_start reason=start_capture
t=1262375 sess=I7F lvl=INFO cat=audio evt=device_pin_start desired_id=181 prev_id=181 prev_name="MacBook Pro Microphone" desired_uid_hash=-1685521486385182984 prev_uid_hash=-1685521486385182984 desired_name="MacBook Pro Microphone"
t=1262376 sess=I7F lvl=INFO cat=audio evt=capture_backend_selected backend=avcapture
✅ Unified audio capture started
✅ Selected account account-bundle (connections: 1/10)
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
✅ [CACHE] Context unchanged - reusing cache (1071 chars)
♻️ [SMART-CACHE] Using cached context: 1071 characters
🔥 [NER-CACHE] Triggering NER callback with cached content (1071 chars)
✅ [NER-CACHE] NER callback triggered with cached content
🧠 [TEN-VAD] Initialized (threshold=0.5, hop=256)
🚀 Starting Clio streaming transcription
t=1262538 sess=I7F lvl=INFO cat=audio evt=avcapture_start ok=true
🔥 [PREWARM DEBUG] Pre-warming AI connection (target: Gemini), environment: flyio
t=1262539 sess=I7F lvl=INFO cat=stream evt=first_audio_buffer_captured ms=0
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
t=1262562 sess=I7F lvl=INFO cat=audio evt=level peak_db=-60 avg_db=-60
✅ [AUDIO HEALTH] First audio data received - tap is functional
🎬 [NER-PREWARM] Using raw OCR text for NER: 1071 characters
🧠 [NER-DEFAULT] Using default NER prompt for general extraction
🏥 [AUDIO HEALTH] Health monitoring timer started
⏱️ [TIMING] mic_engaged @ 1756280038.165
🔁 [CONNECT] Coalesced request from start onto in-flight attempt #17
pass
throwing -10877
throwing -10877
⏳ [CONNECT-WATCHDOG] Attempt #17 has been connecting for >8s without readiness. startTextSent=false socketId=sock_1683487913678001120@attempt_17
🗣️ [TEN-VAD] Speech start detected
🛑 [TEN-VAD] Speech end detected
🛑 [TEN-VAD] Speech end detected
🛑 [TEN-VAD] Speech end detected
🛑 [TEN-VAD] Speech end detected
t=1264572 sess=I7F lvl=INFO cat=audio evt=level avg_db=-40 peak_db=-40
🛑 [TEN-VAD] Speech end detected
📦 Buffer growing: 200 packets (74388 bytes)
🤖 [FLY.IO-NER] Server-reported provider: gemini
📥 [NER-STORE] Stored NER entities: 3274 chars - The user has provided a screenshot of Xcode, specifically showing a Swift file named "clean.swift" w...
✅ [FLY.IO] NER refresh completed successfully
t=1266580 sess=I7F lvl=INFO cat=audio evt=level peak_db=-30 avg_db=-30
⏳ [CONNECT-TIMEOUT] Readiness not signaled within 12s — aborting connect (attempt=17)
⏹️ Keepalive timer stopped
🔌 [WS] Disconnected (socketId=sock_1683487913678001120@attempt_17)
t=1266721 sess=I7F lvl=INFO cat=stream evt=ws_handshake_metrics dns_ms=1 connect_ms=8125 reused=false total_ms=-1 proxy=false attempt=17 protocol=http/1.1 socket= tls_ms=8123
🌐 [CONNECT] Attempt #17 failed: URL session not configured
⚠️ WebSocket connect failed (attempt 1). Retrying in 250ms…
🔥 [COLD-START] URLSession configured with extended timeouts
🛑 [TEN-VAD] Speech end detected
🌐 [CONNECT] Attempt #18 (loop 2/2) starting…
t=1266978 sess=I7F lvl=INFO cat=stream evt=temp_key_fetch_start
⚡ [CACHE-HIT] Retrieved temp key in 0.3ms
t=1266979 sess=I7F lvl=INFO cat=stream evt=temp_key_fetch expires_in_s=-1 latency_ms=0 source=cached
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🌐 [WS CONNECT] Using URL: wss://stt-rt.soniox.com/transcribe-websocket
🔗 [WS] Bound socket id=sock_-7659192919766987974@attempt_18
t=1266983 sess=I7F lvl=INFO cat=stream evt=ws_bind attempt=18 path=/transcribe-websocket via_proxy=false target_ip=resolving... socket=sock_-7659192919766987974@attempt_18 target_host=stt-rt.soniox.com
🔑 Successfully connected to Soniox using temp key (6ms key latency)
t=1266985 sess=I7F lvl=INFO cat=stream evt=ws_bind_resolved path=/transcribe-websocket target_ip=129.146.176.251 via_proxy=false socket=sock_-7659192919766987974@attempt_18 attempt=18 target_host=stt-rt.soniox.com
📦 Buffer growing: 400 packets (148788 bytes)
throwing -10877
throwing -10877
t=1268589 sess=I7F lvl=INFO cat=audio evt=level peak_db=-35 avg_db=-35
t=1269053 sess=I7F lvl=INFO cat=stream evt=ws_handshake_metrics reused=false dns_ms=1 proxy=false attempt=18 tls_ms=1601 connect_ms=1603 total_ms=2069 protocol=http/1.1 socket=sock_-7659192919766987974@attempt_18
🔌 WebSocket did open (sid=sock_-7659192919766987974, attemptId=18)
🌐 [CONNECT] Attempt #18 succeeded
📤 [START] Sent start/config on standby socket (eager mode)
t=1269054 sess=I7F lvl=INFO cat=stream evt=start_config socket=sock_-7659192919766987974@attempt_18 attempt=18 summary=["ctx_len": 36, "langs": 2, "valid": true, "ch": 1, "audio_format": "pcm_s16le", "sr": 16000, "model": "stt-rt-preview-v2", "json_hash": "647d4d9a98bd6de5"] ctx=standby_eager
🧾 [START-CONFIG] ctx=standby_eager sum=["ctx_len": 36, "langs": 2, "valid": true, "ch": 1, "audio_format": "pcm_s16le", "sr": 16000, "model": "stt-rt-preview-v2", "json_hash": "647d4d9a98bd6de5"]
📤 Sending text frame seq=20291
⏱️ [TIMING] WebSocket connect task completed — will flush after READY
🧊 [STANDBY] Connected standby socket — keepalive every 10.0s, TTL=60s
🔌 [READY] attemptId=18 socketId=sock_-7659192919766987974@attempt_18 start_text_sent=true
🧊 [STANDBY] WebSocket ready in 2078ms (handshake)
📦 Flushing 570 buffered packets (6.6s of audio, 212028 bytes)
📤 Sent buffered packet 0/570 seq=0 size=372
📤 Sent buffered packet 569/570 seq=569 size=372
📦 Flushing 7 additional packets that arrived during flush
✅ Buffer flush complete
👂 [LISTENER] Standby listener task for socketId=sock_-7659192919766987974@attempt_18 attemptId=18
t=1269146 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=577
t=1269146 sess=I7F lvl=INFO cat=stream evt=first_audio_sent seq=577 ms=6607
t=1269157 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false seq=578 has_socket=true
t=1269169 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=579
t=1269181 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false seq=580 has_socket=true
t=1269192 sess=I7F lvl=INFO cat=stream evt=pre_send seq=581 has_socket=true flushing=false ready=true bytes=372
t=1269204 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=582
t=1269215 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=583
t=1269227 sess=I7F lvl=INFO cat=stream evt=pre_send seq=584 has_socket=true flushing=false ready=true bytes=372
t=1269239 sess=I7F lvl=INFO cat=stream evt=pre_send seq=585 has_socket=true flushing=false ready=true bytes=372
t=1269250 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=586
t=1269262 sess=I7F lvl=INFO cat=stream evt=pre_send seq=587 has_socket=true flushing=false ready=true bytes=372
t=1269273 sess=I7F lvl=INFO cat=stream evt=pre_send seq=588 has_socket=true flushing=false ready=true bytes=372
t=1269286 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=589
t=1269359 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=590
t=1269359 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=591
t=1269359 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=592
t=1269359 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=593
t=1269359 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=594
t=1269359 sess=I7F lvl=INFO cat=stream evt=pre_send seq=595 has_socket=true ready=true flushing=false bytes=372
t=1269381 sess=I7F lvl=INFO cat=stream evt=pre_send seq=596 has_socket=true flushing=false ready=true bytes=372
t=1269382 sess=I7F lvl=INFO cat=stream evt=pre_send seq=597 has_socket=true flushing=false ready=true bytes=372
t=1269390 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=598
t=1269401 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=599
t=1269413 sess=I7F lvl=INFO cat=stream evt=pre_send seq=600 has_socket=true flushing=false ready=true bytes=372
t=1269425 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=601
t=1269436 sess=I7F lvl=INFO cat=stream evt=pre_send seq=602 has_socket=true flushing=false ready=true bytes=372
t=1269448 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=603
t=1269460 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=604
t=1269472 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=605
t=1269483 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 seq=606 has_socket=true
t=1269495 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=607
t=1269506 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=608
t=1269518 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=609
t=1269529 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=610 has_socket=true flushing=false ready=true
t=1269541 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=611
t=1269553 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=612
t=1269564 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=613
t=1269576 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=614 flushing=false
t=1269587 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=615
t=1269599 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=616 flushing=false
t=1269611 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=617
t=1269622 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=618
t=1269635 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=619
t=1269646 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=620
t=1269657 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=621
t=1269669 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=622
t=1269681 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=623 flushing=false
t=1269692 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=624 has_socket=true flushing=false
t=1269704 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=625
t=1269715 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=626
t=1269727 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=627
t=1269739 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=628
t=1269750 sess=I7F lvl=INFO cat=stream evt=pre_send seq=629 has_socket=true bytes=372 flushing=false ready=true
t=1269762 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false has_socket=true seq=630
t=1269773 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=631
t=1269785 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=632
t=1269797 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=633
t=1269824 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=634
t=1269824 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 ready=true seq=635
t=1269841 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=636
t=1269843 sess=I7F lvl=INFO cat=stream evt=pre_send seq=637 has_socket=true flushing=false ready=true bytes=372
t=1269876 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=638
t=1269876 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=639
t=1269877 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true flushing=false seq=640
t=1269889 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=641
t=1269901 sess=I7F lvl=INFO cat=stream evt=pre_send seq=642 has_socket=true ready=true flushing=false bytes=372
t=1269912 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=643
t=1269924 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=644
t=1269936 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=645
t=1269948 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=646 has_socket=true flushing=false
t=1269959 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=647 flushing=false
t=1269972 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=648 bytes=372 has_socket=true flushing=false
t=1269982 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 seq=649 flushing=false
t=1269994 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=650 has_socket=true flushing=false
t=1270005 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false has_socket=true seq=651
t=1270017 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=652 has_socket=true flushing=false
t=1270029 sess=I7F lvl=INFO cat=stream evt=pre_send seq=653 flushing=false ready=true has_socket=true bytes=372
t=1270040 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false ready=true seq=654 has_socket=true bytes=372
t=1270052 sess=I7F lvl=INFO cat=stream evt=pre_send seq=655 flushing=false ready=true has_socket=true bytes=372
t=1270063 sess=I7F lvl=INFO cat=stream evt=pre_send seq=656 flushing=false ready=true has_socket=true bytes=372
t=1270076 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=657 flushing=false
t=1270087 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=658 has_socket=true flushing=false
t=1270098 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=659 flushing=false
t=1270110 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 ready=true seq=660
t=1270117 sess=I7F lvl=INFO cat=stream evt=first_partial ms=7578
t=1270117 sess=I7F lvl=INFO cat=stream evt=ttft_hotkey ms=7578
t=1270117 sess=I7F lvl=INFO cat=stream evt=ttft ms=6971
t=1270122 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=661 bytes=372 has_socket=true flushing=false
t=1270226 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=662
t=1270226 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=663
t=1270226 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=664
t=1270226 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=665
t=1270227 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=666
t=1270227 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=667
t=1270227 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=668
t=1270227 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=669
t=1270227 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true bytes=372 seq=670
t=1270237 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=671
t=1270294 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false seq=672 has_socket=true
t=1270294 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false seq=673 has_socket=true
t=1270294 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false seq=674 has_socket=true
t=1270294 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false seq=675 has_socket=true
t=1270295 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false seq=676 ready=true has_socket=true bytes=372
t=1270359 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=677
t=1270359 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=678
t=1270359 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=679
t=1270359 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=680
t=1270359 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=681
t=1270372 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true bytes=372 seq=682 ready=true
t=1270397 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false seq=683 has_socket=true
t=1270397 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=684
t=1270411 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=685 ready=true
t=1270441 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=686
t=1270465 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=687 ready=true has_socket=true flushing=false
t=1270465 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 seq=688 flushing=false ready=true
t=1270466 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false has_socket=true seq=689
t=1270466 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false has_socket=true seq=690
t=1270521 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=691
t=1270521 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=692
t=1270521 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=693
t=1270522 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=694
t=1270522 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=695
t=1270579 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false seq=696 has_socket=true
t=1270579 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false seq=697 has_socket=true
t=1270579 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false seq=698 has_socket=true
t=1270580 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false seq=699 has_socket=true
t=1270580 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false seq=700 has_socket=true
t=1270611 sess=I7F lvl=INFO cat=audio evt=level avg_db=-35 peak_db=-35
t=1270611 sess=I7F lvl=INFO cat=stream evt=pre_send seq=701 has_socket=true flushing=false ready=true bytes=372
t=1270611 sess=I7F lvl=INFO cat=stream evt=pre_send seq=702 has_socket=true flushing=false ready=true bytes=372
t=1270611 sess=I7F lvl=INFO cat=stream evt=pre_send seq=703 has_socket=true flushing=false ready=true bytes=372
t=1270620 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false seq=704 bytes=372 has_socket=true ready=true
t=1270679 sess=I7F lvl=INFO cat=stream evt=pre_send seq=705 has_socket=true ready=true flushing=false bytes=372
t=1270679 sess=I7F lvl=INFO cat=stream evt=pre_send seq=706 has_socket=true ready=true flushing=false bytes=372
t=1270679 sess=I7F lvl=INFO cat=stream evt=pre_send seq=707 has_socket=true ready=true flushing=false bytes=372
t=1270679 sess=I7F lvl=INFO cat=stream evt=pre_send seq=708 has_socket=true ready=true flushing=false bytes=372
t=1270679 sess=I7F lvl=INFO cat=stream evt=pre_send seq=709 has_socket=true ready=true flushing=false bytes=372
t=1270714 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false ready=true has_socket=true seq=710 bytes=372
t=1270714 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false ready=true has_socket=true seq=711 bytes=372
t=1270714 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false ready=true has_socket=true seq=712 bytes=372
t=1270768 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=713 ready=true
t=1270769 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=714 ready=true
t=1270769 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=715 ready=true
t=1270769 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true seq=716 ready=true
t=1270799 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false has_socket=true seq=717
t=1270799 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false has_socket=true seq=718
t=1270799 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false has_socket=true seq=719
t=1270825 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true bytes=372 seq=720 ready=true
t=1270825 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true bytes=372 seq=721 ready=true
t=1270863 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 ready=true seq=722 flushing=false
t=1270863 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 ready=true seq=723 flushing=false
t=1270863 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 ready=true seq=724 flushing=false
t=1270876 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=725 bytes=372 flushing=false
t=1270876 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=726 ready=true has_socket=true flushing=false
t=1270887 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 ready=true seq=727 flushing=false
t=1270950 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=728 bytes=372 has_socket=true
t=1270950 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=729 bytes=372 has_socket=true
t=1270950 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=730 bytes=372 has_socket=true
t=1270950 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=731 bytes=372 has_socket=true
t=1270950 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=732 bytes=372 has_socket=true
t=1270957 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true has_socket=true seq=733
t=1270985 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=734 ready=true bytes=372 flushing=false
t=1270985 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=735 ready=true bytes=372 flushing=false
t=1271015 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false ready=true seq=736 has_socket=true bytes=372
t=1271015 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false ready=true seq=737 has_socket=true bytes=372
t=1271015 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=738 has_socket=true flushing=false
t=1271049 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false seq=739 has_socket=true
t=1271049 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false seq=740 has_socket=true
t=1271103 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=741
t=1271103 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=742
t=1271103 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=743
🛑 [TEN-VAD] Speech end detected
t=1271104 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=744
t=1271104 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=745
t=1271135 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=746
t=1271135 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=747
t=1271135 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=748
t=1271190 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=749 has_socket=true
t=1271190 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=750 has_socket=true
t=1271190 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=751 has_socket=true
t=1271190 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=752 has_socket=true
t=1271190 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=753 has_socket=true
t=1271201 sess=I7F lvl=INFO cat=stream evt=pre_send seq=754 has_socket=true flushing=false ready=true bytes=372
t=1271225 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false seq=755 bytes=372
t=1271225 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false seq=756 bytes=372
t=1271278 sess=I7F lvl=INFO cat=stream evt=pre_send seq=757 has_socket=true flushing=false ready=true bytes=372
t=1271278 sess=I7F lvl=INFO cat=stream evt=pre_send seq=758 has_socket=true flushing=false ready=true bytes=372
t=1271278 sess=I7F lvl=INFO cat=stream evt=pre_send seq=759 has_socket=true flushing=false ready=true bytes=372
t=1271278 sess=I7F lvl=INFO cat=stream evt=first_final ms=8739
t=1271278 sess=I7F lvl=INFO cat=transcript evt=raw_final text=You
t=1271278 sess=I7F lvl=INFO cat=stream evt=pre_send seq=760 has_socket=true flushing=false ready=true bytes=372
t=1271331 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=761 flushing=false
t=1271331 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=762 flushing=false
t=1271331 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=763 flushing=false
t=1271356 sess=I7F lvl=INFO cat=stream evt=pre_send seq=764 flushing=false bytes=372 has_socket=true ready=true
t=1271356 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=765 flushing=false has_socket=true
t=1271357 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=766 has_socket=true ready=true flushing=false
t=1271357 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=767 has_socket=true ready=true flushing=false
t=1271420 sess=I7F lvl=INFO cat=stream evt=pre_send seq=768 has_socket=true flushing=false ready=true bytes=372
t=1271420 sess=I7F lvl=INFO cat=stream evt=pre_send seq=769 has_socket=true flushing=false ready=true bytes=372
t=1271420 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false has_socket=true seq=770
t=1271444 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false seq=771 has_socket=true
t=1271444 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false seq=772 has_socket=true
t=1271445 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false seq=773 has_socket=true
t=1271445 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false seq=774 has_socket=true
t=1271453 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false seq=775 has_socket=true
t=1271492 sess=I7F lvl=INFO cat=stream evt=pre_send seq=776 has_socket=true flushing=false ready=true bytes=372
t=1271492 sess=I7F lvl=INFO cat=stream evt=pre_send seq=777 has_socket=true flushing=false ready=true bytes=372
t=1271492 sess=I7F lvl=INFO cat=stream evt=pre_send seq=778 has_socket=true flushing=false ready=true bytes=372
t=1271492 sess=I7F lvl=INFO cat=stream evt=pre_send seq=779 has_socket=true flushing=false ready=true bytes=372
t=1271524 sess=I7F lvl=INFO cat=stream evt=pre_send seq=780 has_socket=true flushing=false ready=true bytes=372
t=1271524 sess=I7F lvl=INFO cat=stream evt=pre_send seq=781 has_socket=true flushing=false ready=true bytes=372
t=1271526 sess=I7F lvl=INFO cat=stream evt=pre_send seq=782 has_socket=true flushing=false ready=true bytes=372
t=1271564 sess=I7F lvl=INFO cat=stream evt=pre_send seq=783 bytes=372 has_socket=true ready=true flushing=false
t=1271564 sess=I7F lvl=INFO cat=stream evt=pre_send seq=784 bytes=372 has_socket=true ready=true flushing=false
t=1271564 sess=I7F lvl=INFO cat=stream evt=pre_send seq=785 bytes=372 has_socket=true ready=true flushing=false
t=1271595 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=786 ready=true flushing=false
t=1271595 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=787 ready=true flushing=false
t=1271595 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=788 ready=true
t=1271607 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=789
t=1271619 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=790 ready=true
t=1271630 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=791 flushing=false ready=true bytes=372
t=1271642 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=792
t=1271654 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=793 ready=true
t=1271666 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=794 bytes=372 ready=true
t=1271677 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=795 ready=true bytes=372
t=1271688 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=796 ready=true
t=1271700 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=797 ready=true
t=1271712 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 ready=true seq=798 flushing=false
🛑 Stopping recording
🛑 Stopping Clio streaming transcription
🏥 [AUDIO HEALTH] Health monitoring timer stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
🛑 Stopping unified audio capture
t=1271802 sess=I7F lvl=INFO cat=audio evt=record_stop
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key plugInPackage
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key CMIOType
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key numberOfDevices
t=1271810 sess=I7F lvl=INFO cat=audio evt=avcapture_stop
✅ Unified audio capture stopped
t=1271810 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=799 ready=true bytes=372
t=1271811 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=800 ready=true bytes=372
t=1271811 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=801 ready=true bytes=372
t=1271811 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=802 ready=true bytes=372
t=1271811 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=803 ready=true bytes=372
t=1271845 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=804
t=1271845 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=805
🗣️ [TEN-VAD] Speech start detected
📤 Sent end-of-stream signal
📤 Sent manual finalize command
🕐 Using finalization timeout: 400ms (connection took 9398ms)
ℹ️ [OPTIMISTIC] Not skipping: end=false pending=0 ms_since_last=89 tail=100 silence_ok=false tokens_quiet_ok=true partial_empty=false uncond=false
t=1272283 sess=I7F lvl=INFO cat=transcript evt=raw_final text=" can build a worse version yoursel"
⚠️ Timed out waiting for <fin> token after 527ms — merging partial transcript
⏹️ Keepalive timer stopped
⚡ Audio capture already stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
📉 Released connection for account account-bundle (connections: 0)
💾 [COLD-START] Updated successful streaming timestamp
💾 [COLD-START] Updated successful streaming timestamp
✅ Streaming transcription completed successfully, length: 107 characters
✅ Streaming stopped. Final transcript (107 chars, 9.9s, with audio file): "You can build a worse version yoursel f. Companies that hate a third party were better off, and I think the"
🌡️ [WARM] warm_socket=yes
⏱️ [TIMING] Subscription tracking: 0.3ms
⏱️ [TIMING] ASR word tracking: 0.0ms
🧠 Performing intelligent end-context detection for streaming
⏱️ [CONTEXT DETAIL] Cache check: 0.0ms
⚡ [SMART-OPTIMIZATION] Using smart cached screen context (1071 chars) - skipping new capture
⏱️ [STREAMING CONTEXT TIMING] Screen capture + context detection: 0.0ms
t=1272491 sess=I7F lvl=INFO cat=transcript evt=final text="You can build a worse version yoursel f. Companies that hate a third party were better off, and I think the"
t=1272491 sess=I7F lvl=INFO cat=transcript evt=session_end divider="────────── session end ──────────"
🔊 [SoundManager] Attempting to play stop sound
🔊 [SoundManager] NSSound stop sound result: true
🧹 Connection cleanup completed (session resources released)
📝 [GRACE] Recording session ended
📱 Dismissing recorder
⏹️ Keepalive timer stopped
⚠️ WebSocket did close with code 1001 (sid=sock_-7659192919766987974, attemptId=18)
t=1272566 sess=I7F lvl=WARN cat=stream evt=state code=1001 state=closed
✅ Streaming transcription processing completed
t=1272589 sess=I7F lvl=INFO cat=transcript evt=insert_attempt chars=108 text="You can build a worse version yoursel f. Companies that hate a third party were better off, and I think the " target=Xcode
🔍 [PASTE DEBUG] AXIsProcessTrusted() returned true, proceeding
🔍 [PASTE DEBUG] UseDirectTextInsertion setting: false
🔍 [PASTE DEBUG] Direct insertion disabled, using clipboard paste
⌨️ Using CGEvent-based Command+V
t=1272590 sess=I7F lvl=INFO cat=transcript evt=insert_result ok=true
📊 [POST-RELEASE E2E] 814ms (paste=0ms) | warm_socket=no
🔌 [WS] Disconnected (socketId=sock_-7659192919766987974@attempt_18)
🌐 [CONNECT] New single-flight request from warmHold
🌐 [CONNECT] Attempt #19 (loop 1/2) starting…
t=1272813 sess=I7F lvl=INFO cat=stream evt=temp_key_fetch_start
⚡ [CACHE-HIT] Retrieved temp key in 0.4ms
t=1272814 sess=I7F lvl=INFO cat=stream evt=temp_key_fetch source=cached expires_in_s=-1 latency_ms=0
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🌐 [WS CONNECT] Using URL: wss://stt-rt.soniox.com/transcribe-websocket
🔗 [WS] Bound socket id=sock_-4477072826087931552@attempt_19
t=1272814 sess=I7F lvl=INFO cat=stream evt=ws_bind via_proxy=false target_host=stt-rt.soniox.com target_ip=resolving... attempt=19 path=/transcribe-websocket socket=sock_-4477072826087931552@attempt_19
🔑 Successfully connected to Soniox using temp key (1ms key latency)
t=1272816 sess=I7F lvl=INFO cat=stream evt=ws_bind_resolved target_ip=129.146.176.251 via_proxy=false attempt=19 path=/transcribe-websocket socket=sock_-4477072826087931552@attempt_19 target_host=stt-rt.soniox.com
t=1274918 sess=I7F lvl=INFO cat=stream evt=ws_handshake_metrics proxy=false attempt=19 total_ms=2102 socket=sock_-4477072826087931552@attempt_19 connect_ms=1628 tls_ms=1628 dns_ms=0 reused=false protocol=http/1.1
🔌 WebSocket did open (sid=sock_-4477072826087931552, attemptId=19)
📤 [START] Sent start/config on standby socket (eager mode)
t=1275324 sess=I7F lvl=INFO cat=stream evt=start_config attempt=19 summary=["ch": 1, "langs": 2, "sr": 16000, "model": "stt-rt-preview-v2", "ctx_len": 36, "json_hash": "74c88fa4ee9a34f7", "audio_format": "pcm_s16le", "valid": true] ctx=standby_eager socket=sock_-4477072826087931552@attempt_19
🧾 [START-CONFIG] ctx=standby_eager sum=["ch": 1, "langs": 2, "sr": 16000, "model": "stt-rt-preview-v2", "ctx_len": 36, "json_hash": "74c88fa4ee9a34f7", "audio_format": "pcm_s16le", "valid": true]
🌐 [CONNECT] Attempt #19 succeeded
📤 Sending text frame seq=21098
🧊 [STANDBY] Connected standby socket — keepalive every 10.0s, TTL=60s
🔌 [READY] attemptId=19 socketId=sock_-4477072826087931552@attempt_19 start_text_sent=true
🧊 [STANDBY] WebSocket ready in 2523ms (handshake)
⏱️ [STANDBY] TTL reached (60s) — closing standby socket
⏹️ Keepalive timer stopped
👂 [LISTENER] Standby listener task for socketId=sock_-4477072826087931552@attempt_19 attemptId=19
🔌 [WS] Disconnected (socketId=sock_-4477072826087931552@attempt_19)
⚠️ WebSocket did close with code 1001 (sid=sock_-4477072826087931552, attemptId=19)
t=1275336 sess=I7F lvl=WARN cat=stream evt=state code=1001 state=closed





## 4 Failure
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
🎤 Registering audio tap for Soniox
t=1311420 sess=I7F lvl=INFO cat=audio evt=record_start service=Soniox
🔍 Performing audio system pre-flight checks
throwing -10877
throwing -10877
✅ Pre-flight checks passed
t=1311510 sess=I7F lvl=INFO cat=audio evt=tap_install service=Soniox backend=avcapture ok=true
t=1311510 sess=I7F lvl=INFO cat=audio evt=record_start reason=start_capture
t=1311511 sess=I7F lvl=INFO cat=audio evt=device_pin_start desired_name="MacBook Pro Microphone" desired_uid_hash=-1685521486385182984 desired_id=181 prev_id=181 prev_name="MacBook Pro Microphone" prev_uid_hash=-1685521486385182984
❄️ Cold start detected - performing full initialization
✅ [CACHE] Context unchanged - reusing cache (1071 chars)
♻️ [SMART-CACHE] Using cached context: 1071 characters
🔥 [NER-CACHE] Triggering NER callback with cached content (1071 chars)
✅ [NER-CACHE] NER callback triggered with cached content
❄️ Performing cold start initialization
⏭️ Skipping engine cold start (backend=AVCapture)
🔥 [PREWARM DEBUG] Pre-warming AI connection (target: Gemini), environment: flyio
t=1311596 sess=I7F lvl=INFO cat=audio evt=capture_backend_selected backend=avcapture
✅ Unified audio capture started
✅ Selected account account-bundle (connections: 1/10)
🧠 [TEN-VAD] Initialized (threshold=0.5, hop=256)
🚀 Starting Clio streaming transcription
🎬 [NER-PREWARM] Using raw OCR text for NER: 1071 characters
🧠 [NER-DEFAULT] Using default NER prompt for general extraction
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
t=1311707 sess=I7F lvl=INFO cat=audio evt=avcapture_start ok=true
t=1311741 sess=I7F lvl=INFO cat=stream evt=first_audio_buffer_captured ms=34
t=1311742 sess=I7F lvl=INFO cat=audio evt=level avg_db=-60 peak_db=-60
✅ [AUDIO HEALTH] First audio data received - tap is functional
🏥 [AUDIO HEALTH] Health monitoring timer started
⏱️ [TIMING] mic_engaged @ 1756280087.315
🌐 [CONNECT] New single-flight request from start
pass
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
🌐 [CONNECT] Attempt #20 (loop 1/3) starting…
t=1311769 sess=I7F lvl=INFO cat=stream evt=temp_key_fetch_start
⚡ [CACHE-HIT] Retrieved temp key in 0.1ms
t=1311769 sess=I7F lvl=INFO cat=stream evt=temp_key_fetch source=cached latency_ms=0 expires_in_s=-1
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🌐 [WS CONNECT] Using URL: wss://stt-rt.soniox.com/transcribe-websocket
🔗 [WS] Bound socket id=sock_2722754041283062614@attempt_20
t=1311770 sess=I7F lvl=INFO cat=stream evt=ws_bind attempt=20 via_proxy=false socket=sock_2722754041283062614@attempt_20 target_ip=resolving... path=/transcribe-websocket target_host=stt-rt.soniox.com
🔑 Successfully connected to Soniox using temp key (14ms key latency)
t=1311783 sess=I7F lvl=INFO cat=stream evt=ws_bind_resolved target_host=stt-rt.soniox.com target_ip=129.146.176.251 socket=sock_2722754041283062614@attempt_20 attempt=20 via_proxy=false path=/transcribe-websocket
🛑 [TEN-VAD] Speech end detected
throwing -10877
throwing -10877
🌐 [ASR BREAKDOWN] Total: 1344ms | Client↔Proxy: 380ms | Proxy↔Soniox: 964ms | Network: 964ms
🗑️ Evicted oldest temp key to maintain cache size limit
💾 Cached temp key for languages: ["en", "zh"]
🗓️ [TTL-SCHEDULE] Scheduling temp key refresh for key=global in 3000s (expiresAt=2025-08-27 08:34:48 +0000)
🛑 [TEN-VAD] Speech end detected
✅ [PREFETCH] Successfully prefetched temp key
🎤 [WARMUP] Pre-warming audio system...
✅ [PREWARM] Device enumeration completed
✅ [PREWARM] Audio system pre-warming completed successfully
✅ [WARMUP] Audio system pre-warmed successfully
🛑 [TEN-VAD] Speech end detected
🛑 [TEN-VAD] Speech end detected
t=1313658 sess=I7F lvl=INFO cat=stream evt=ws_handshake_metrics dns_ms=1 tls_ms=1425 protocol=http/1.1 total_ms=1887 proxy=false attempt=20 reused=false socket=sock_2722754041283062614@attempt_20 connect_ms=1425
🔌 WebSocket did open (sid=sock_2722754041283062614, attemptId=20)
🌐 [CONNECT] Attempt #20 succeeded
📤 [START] Sent start/config text frame (attemptId=20, socketId=sock_2722754041283062614@attempt_20, start_text_sent=true)
t=1313659 sess=I7F lvl=INFO cat=stream evt=start_config ctx=active summary=["sr": 16000, "valid": true, "json_hash": "647d4d9a98bd6de5", "ch": 1, "audio_format": "pcm_s16le", "ctx_len": 36, "langs": 2, "model": "stt-rt-preview-v2"] attempt=20 socket=sock_2722754041283062614@attempt_20
🧾 [START-CONFIG] ctx=active sum=["sr": 16000, "valid": true, "json_hash": "647d4d9a98bd6de5", "ch": 1, "audio_format": "pcm_s16le", "ctx_len": 36, "langs": 2, "model": "stt-rt-preview-v2"]
🔌 [READY] attemptId=20 socketId=sock_2722754041283062614@attempt_20 start_text_sent=true
🔌 WebSocket ready after 1954ms - buffered 2.0s of audio
📦 Flushing 173 buffered packets (2.0s of audio, 64332 bytes)
⏱️ [TIMING] WebSocket connect task completed — will flush after READY
📤 Sent buffered packet 0/173 seq=0 size=372
📤 Sent buffered packet 172/173 seq=172 size=372
📦 Flushing 3 additional packets that arrived during flush
✅ Buffer flush complete
⏱️ [SPEECH-WATCHDOG] Arming watchdog: deadline=2.000000s attempt=20
🧪 [PROMO] speech_watchdog_arm attempt=20 speaking=true bytes_threshold=10000 gates isStreaming=true ws_ready=true start_sent=true hasTokens=false
⏹️ Keepalive timer stopped
🔄 Keepalive timer started (interval: 15.000000s)
📤 Sending text frame seq=21099
👂 [LISTENER] Starting listener task for socketId=sock_2722754041283062614@attempt_20 attemptId=20
t=1313698 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=176 has_socket=true flushing=false ready=true
t=1313698 sess=I7F lvl=INFO cat=stream evt=first_audio_sent seq=176 ms=1991
t=1313709 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false seq=177 has_socket=true bytes=372 ready=true
t=1313721 sess=I7F lvl=INFO cat=stream evt=pre_send seq=178 has_socket=true flushing=false bytes=372 ready=true
t=1313733 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=179
t=1313744 sess=I7F lvl=INFO cat=audio evt=level peak_db=-38 avg_db=-38
t=1313745 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 ready=true seq=180
t=1313756 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=181
t=1313768 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=182 has_socket=true ready=true flushing=false
t=1313780 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=183 has_socket=true ready=true flushing=false
t=1313791 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 ready=true seq=184 flushing=false
t=1313802 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true seq=185 bytes=372
t=1313815 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=186 flushing=false
t=1313826 sess=I7F lvl=INFO cat=stream evt=pre_send seq=187 has_socket=true flushing=false bytes=372 ready=true
t=1313837 sess=I7F lvl=INFO cat=stream evt=pre_send seq=188 has_socket=true flushing=false bytes=372 ready=true
t=1313849 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=189
t=1313861 sess=I7F lvl=INFO cat=stream evt=pre_send seq=190 has_socket=true flushing=false bytes=372 ready=true
t=1313872 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true bytes=372 seq=191 flushing=false
t=1313884 sess=I7F lvl=INFO cat=stream evt=pre_send seq=192 has_socket=true flushing=false bytes=372 ready=true
t=1313895 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=193 flushing=false has_socket=true
t=1313907 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=194 flushing=false has_socket=true
t=1313919 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 ready=true seq=195 flushing=false
t=1313931 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=196 flushing=false has_socket=true
t=1313942 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=197 ready=true
t=1313953 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 ready=true has_socket=true seq=198 flushing=false
t=1313965 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=199 flushing=false has_socket=true
t=1313977 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=200 bytes=372 ready=true
t=1313990 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=201 flushing=false has_socket=true
t=1314024 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=202 has_socket=true
t=1314024 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=203 has_socket=true
t=1314024 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=204 has_socket=true
t=1314034 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=205 has_socket=true
t=1314046 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false ready=true seq=206
t=1314058 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=207 flushing=false has_socket=true
t=1314070 sess=I7F lvl=INFO cat=stream evt=pre_send seq=208 has_socket=true flushing=false bytes=372 ready=true
t=1314081 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 ready=true seq=209 flushing=false
t=1314093 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false ready=true seq=210
t=1314105 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 ready=true seq=211 flushing=false
t=1314116 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false ready=true seq=212
t=1314128 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false seq=213 has_socket=true ready=true
t=1314140 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false seq=214 ready=true has_socket=true bytes=372
t=1314151 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 ready=true seq=215 flushing=false
t=1314164 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 ready=true seq=216 flushing=false
t=1314174 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 seq=217 has_socket=true
t=1314251 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true ready=true bytes=372 seq=218
t=1314251 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true ready=true bytes=372 seq=219
t=1314251 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true ready=true bytes=372 seq=220
t=1314251 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true ready=true bytes=372 seq=221
t=1314251 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true ready=true bytes=372 seq=222
t=1314251 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true ready=true bytes=372 seq=223
t=1314255 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true ready=true bytes=372 seq=224
t=1314267 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=225 has_socket=true ready=true flushing=false
t=1314278 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=226 has_socket=true ready=true flushing=false
t=1314290 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=227 ready=true
t=1314302 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false seq=228 ready=true has_socket=true bytes=372
t=1314314 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=229 ready=true
t=1314325 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=230 flushing=false has_socket=true
t=1314337 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=231 has_socket=true flushing=false
t=1314349 sess=I7F lvl=INFO cat=stream evt=pre_send seq=232 ready=true has_socket=true flushing=false bytes=372
t=1314360 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false seq=233 ready=true has_socket=true bytes=372
t=1314372 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 ready=true has_socket=true flushing=false seq=234
t=1314383 sess=I7F lvl=INFO cat=stream evt=pre_send seq=235 has_socket=true flushing=false bytes=372 ready=true
t=1314395 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false seq=236 ready=true has_socket=true bytes=372
t=1314406 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 seq=237 has_socket=true flushing=false
t=1314418 sess=I7F lvl=INFO cat=stream evt=pre_send seq=238 bytes=372 flushing=false ready=true has_socket=true
t=1314430 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=239
t=1314441 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false seq=240 has_socket=true ready=true bytes=372
t=1314453 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false seq=241 ready=true has_socket=true bytes=372
t=1314465 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false has_socket=true seq=242
t=1314476 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false has_socket=true seq=243
t=1314488 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false seq=244 has_socket=true ready=true bytes=372
t=1314499 sess=I7F lvl=INFO cat=stream evt=pre_send seq=245 bytes=372 flushing=false has_socket=true ready=true
t=1314545 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true ready=true bytes=372 seq=246
t=1314545 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true ready=true bytes=372 seq=247
t=1314545 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true ready=true bytes=372 seq=248
t=1314545 sess=I7F lvl=INFO cat=stream evt=pre_send seq=249 has_socket=true bytes=372 flushing=false ready=true
t=1314557 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false seq=250 bytes=372
t=1314569 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false seq=251 bytes=372
t=1314580 sess=I7F lvl=INFO cat=stream evt=pre_send seq=252 flushing=false ready=true has_socket=true bytes=372
t=1314592 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=253
t=1314604 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 seq=254 flushing=false
t=1314615 sess=I7F lvl=INFO cat=stream evt=pre_send seq=255 flushing=false ready=true has_socket=true bytes=372
t=1314627 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=256 ready=true
t=1314639 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=257 flushing=false has_socket=true ready=true
t=1314650 sess=I7F lvl=INFO cat=stream evt=pre_send seq=258 flushing=false ready=true has_socket=true bytes=372
t=1314662 sess=I7F lvl=INFO cat=stream evt=pre_send seq=259 flushing=false ready=true has_socket=true bytes=372
t=1314674 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=260 ready=true
t=1314685 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true seq=261 bytes=372 ready=true flushing=false
t=1314698 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 ready=true has_socket=true seq=262
t=1314708 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false ready=true seq=263
t=1314720 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=264 flushing=false has_socket=true ready=true
t=1314732 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=265 flushing=false has_socket=true ready=true
t=1314743 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true seq=266 bytes=372
t=1314756 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 seq=267 flushing=false
t=1314766 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=268 has_socket=true flushing=false
t=1314778 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 ready=true has_socket=true flushing=false seq=269
t=1314789 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 flushing=false ready=true seq=270
t=1314801 sess=I7F lvl=INFO cat=stream evt=pre_send seq=271 flushing=false ready=true has_socket=true bytes=372
t=1314812 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=272 flushing=false has_socket=true ready=true
t=1314824 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=273 flushing=false has_socket=true ready=true
t=1314836 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=274 ready=true
t=1314847 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=275 ready=true
t=1314859 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=276 ready=true
t=1314872 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true seq=277 bytes=372
t=1314882 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 ready=true seq=278
t=1314894 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true seq=279 bytes=372
t=1314906 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 ready=true seq=280
t=1314917 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=281 flushing=false has_socket=true ready=true
t=1314929 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=282 flushing=false has_socket=true ready=true
t=1314941 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true seq=283 bytes=372
t=1314952 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true seq=284 bytes=372
t=1314964 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true seq=285 bytes=372
t=1314977 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 ready=true seq=286
t=1314987 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true ready=true seq=287 flushing=false
t=1314999 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=288 flushing=false has_socket=true ready=true
t=1315010 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false has_socket=true seq=289 bytes=372
t=1315060 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false seq=290 has_socket=true
t=1315060 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false seq=291 has_socket=true
t=1315060 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false seq=292 has_socket=true
t=1315060 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false seq=293 has_socket=true
t=1315068 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false seq=294 bytes=372
t=1315079 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false seq=295 bytes=372
t=1315091 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 has_socket=true seq=296
t=1315094 sess=I7F lvl=INFO cat=stream evt=first_partial ms=3387
t=1315094 sess=I7F lvl=INFO cat=stream evt=ttft_hotkey ms=3387
t=1315094 sess=I7F lvl=INFO cat=stream evt=ttft ms=43248
🛑 [SPEECH-WATCHDOG] Cancelled
t=1315103 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=297 ready=true
t=1315190 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=298 has_socket=true
t=1315190 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=299 has_socket=true
t=1315190 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=300 has_socket=true
t=1315190 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=301 has_socket=true
t=1315190 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=302 has_socket=true
t=1315190 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false ready=true has_socket=true seq=303
t=1315190 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true ready=true bytes=372 seq=304
t=1315195 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false ready=true bytes=372 has_socket=true seq=305
t=1315259 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false seq=306 ready=true bytes=372 has_socket=true
t=1315259 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false seq=307 ready=true bytes=372 has_socket=true
t=1315259 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false seq=308 ready=true bytes=372 has_socket=true
t=1315259 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false seq=309 bytes=372
t=1315259 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false seq=310 bytes=372
t=1315265 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=311 has_socket=true ready=true flushing=false
t=1315293 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=312
t=1315293 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false ready=true seq=313
t=1315355 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=314
t=1315355 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=315
t=1315355 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 has_socket=true flushing=false seq=316
t=1315384 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true ready=true bytes=372 seq=317
t=1315384 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true ready=true bytes=372 seq=318
t=1315418 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=319 has_socket=true flushing=false ready=true
t=1315418 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=320 has_socket=true flushing=false ready=true
t=1315419 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=321 has_socket=true flushing=false ready=true
t=1315419 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=322 has_socket=true
t=1315419 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=323 has_socket=true
t=1315419 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=324 has_socket=true
t=1315428 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 seq=325 flushing=false
t=1315439 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true bytes=372 seq=326 ready=true
t=1315472 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=327 has_socket=true ready=true flushing=false
t=1315472 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=328 has_socket=true ready=true flushing=false
t=1315534 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false seq=329 bytes=372
t=1315534 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false seq=330 bytes=372
t=1315534 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false seq=331 bytes=372
t=1315534 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false seq=332 bytes=372
t=1315534 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false seq=333 bytes=372
t=1315534 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false seq=334 bytes=372
t=1315577 sess=I7F lvl=INFO cat=stream evt=pre_send seq=335 flushing=false has_socket=true ready=true bytes=372
t=1315577 sess=I7F lvl=INFO cat=stream evt=pre_send seq=336 flushing=false has_socket=true ready=true bytes=372
t=1315577 sess=I7F lvl=INFO cat=stream evt=pre_send seq=337 flushing=false has_socket=true ready=true bytes=372
t=1315587 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=338 has_socket=true ready=true flushing=false
t=1315590 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 seq=339 has_socket=true ready=true
t=1315602 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 ready=true flushing=false seq=340 has_socket=true
t=1315613 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=341 has_socket=true ready=true flushing=false
t=1315625 sess=I7F lvl=INFO cat=stream evt=pre_send seq=342 ready=true flushing=false has_socket=true bytes=372
t=1315694 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true ready=true bytes=372 seq=343
t=1315695 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true ready=true bytes=372 seq=344
t=1315695 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true ready=true bytes=372 seq=345
t=1315695 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true ready=true bytes=372 seq=346
t=1315695 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true ready=true bytes=372 seq=347
t=1315695 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=348
t=1315706 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true ready=true bytes=372 seq=349
🤖 [FLY.IO-NER] Server-reported provider: gemini
t=1315772 sess=I7F lvl=INFO cat=audio evt=level avg_db=-40 peak_db=-40
t=1315772 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=350
📥 [NER-STORE] Stored NER entities: 3223 chars - The user has provided a screenshot of their Xcode IDE, with the active file being `clean.swift` with...
✅ [FLY.IO] NER refresh completed successfully
t=1315773 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=351
t=1315773 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=352
t=1315773 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=353
t=1315773 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true bytes=372 seq=354
t=1315776 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false seq=355 ready=true bytes=372
t=1315788 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false ready=true seq=356 bytes=372
t=1315799 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=357 has_socket=true
t=1315883 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true ready=true seq=358
t=1315883 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true ready=true seq=359
t=1315883 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=360 has_socket=true bytes=372
🛑 [TEN-VAD] Speech end detected
t=1315883 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false seq=361 has_socket=true bytes=372
t=1315883 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=362 bytes=372
t=1315883 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=363 bytes=372
t=1315883 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=364 bytes=372
t=1315892 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false seq=365 has_socket=true
t=1315904 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false seq=366 bytes=372
t=1315915 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false ready=true has_socket=true bytes=372 seq=367
t=1315927 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 seq=368 flushing=false ready=true
t=1315938 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 seq=369 flushing=false ready=true
t=1315950 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false ready=true has_socket=true bytes=372 seq=370
t=1316013 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=371 ready=true flushing=false
t=1316013 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=372 ready=true flushing=false
t=1316013 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=373 ready=true flushing=false
t=1316013 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=374 ready=true flushing=false
t=1316013 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=375 ready=true flushing=false
t=1316020 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=376 has_socket=true ready=true flushing=false
t=1316032 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false seq=377 bytes=372
t=1316043 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false seq=378 bytes=372
🛑 [TEN-VAD] Speech end detected
t=1316054 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false seq=379 bytes=372
t=1316066 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 seq=380 has_socket=true
t=1316078 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true seq=381 bytes=372 flushing=false
t=1316090 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false seq=382 bytes=372
t=1316101 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 seq=383 flushing=false ready=true
t=1316113 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=384
t=1316124 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true flushing=false seq=385 ready=true
t=1316136 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 seq=386 flushing=false ready=true
t=1316204 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=387 flushing=false has_socket=true bytes=372
t=1316204 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=388 flushing=false has_socket=true bytes=372
t=1316204 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=389 flushing=false has_socket=true bytes=372
t=1316204 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=390 flushing=false has_socket=true bytes=372
t=1316204 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=391 flushing=false has_socket=true bytes=372
t=1316206 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 ready=true has_socket=true flushing=false seq=392
t=1316217 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false seq=393 has_socket=true
t=1316229 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true bytes=372 seq=394 flushing=false ready=true
t=1316240 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=395 ready=true bytes=372
t=1316252 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true seq=396 ready=true bytes=372
t=1316285 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=397
t=1316285 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=398
t=1316315 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false seq=399 has_socket=true
t=1316315 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false seq=400 has_socket=true
t=1316315 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true bytes=372 flushing=false seq=401 has_socket=true
t=1316322 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=402 has_socket=true ready=true flushing=false
t=1316333 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=403 has_socket=true ready=true flushing=false
t=1316345 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=404 bytes=372
t=1316356 sess=I7F lvl=INFO cat=stream evt=pre_send seq=405 flushing=false bytes=372 has_socket=true ready=true
t=1316368 sess=I7F lvl=INFO cat=stream evt=pre_send seq=406 flushing=false bytes=372 has_socket=true ready=true
t=1316380 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=407 has_socket=true ready=true flushing=false
t=1316391 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 flushing=false has_socket=true ready=true seq=408
t=1316403 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true ready=true bytes=372 seq=409
t=1316415 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true bytes=372 seq=410 ready=true
t=1316426 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false seq=411 bytes=372
t=1316438 sess=I7F lvl=INFO cat=stream evt=pre_send seq=412 flushing=false bytes=372 has_socket=true ready=true
t=1316449 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false has_socket=true bytes=372 seq=413 ready=true
t=1316461 sess=I7F lvl=INFO cat=stream evt=pre_send seq=414 has_socket=true ready=true flushing=false bytes=372
🛑 Stopping recording
🛑 Stopping Clio streaming transcription
🏥 [AUDIO HEALTH] Health monitoring timer stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
🛑 Stopping unified audio capture
t=1316572 sess=I7F lvl=INFO cat=audio evt=record_stop
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key plugInPackage
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key CMIOType
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key numberOfDevices
t=1316582 sess=I7F lvl=INFO cat=audio evt=avcapture_stop
✅ Unified audio capture stopped
t=1316586 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false seq=415 ready=true bytes=372 has_socket=true
t=1316586 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false seq=416 ready=true bytes=372 has_socket=true
t=1316586 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false seq=417 ready=true bytes=372 has_socket=true
t=1316586 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false seq=418 ready=true bytes=372 has_socket=true
t=1316624 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=419 has_socket=true flushing=false ready=true
t=1316624 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 seq=420 has_socket=true flushing=false ready=true
t=1316624 sess=I7F lvl=INFO cat=stream evt=pre_send seq=421 bytes=372 flushing=false has_socket=true ready=true
t=1316624 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 seq=422 ready=true
t=1316624 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 flushing=false seq=423
📤 Sent end-of-stream signal
📤 Sent manual finalize command
🕐 Using finalization timeout: 400ms (connection took 5034ms)
ℹ️ [OPTIMISTIC] Not skipping: end=false pending=0 ms_since_last=109 tail=100 silence_ok=false tokens_quiet_ok=false partial_empty=false uncond=false
t=1317001 sess=I7F lvl=INFO cat=stream evt=first_final ms=5294
t=1317001 sess=I7F lvl=INFO cat=transcript evt=raw_final text="BT brittle workflows lack a context and misalignment.<end>"
⚠️ Timed out waiting for <fin> token after 491ms — merging partial transcript
⏹️ Keepalive timer stopped
⚡ Audio capture already stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
📉 Released connection for account account-bundle (connections: 0)
💾 [COLD-START] Updated successful streaming timestamp
💾 [COLD-START] Updated successful streaming timestamp
✅ Streaming transcription completed successfully, length: 53 characters
✅ Streaming stopped. Final transcript (53 chars, 5.5s, with audio file): "BT brittle workflows lack a context and misalignment."
🌡️ [WARM] warm_socket=yes
⏱️ [TIMING] Subscription tracking: 0.3ms
⏱️ [TIMING] ASR word tracking: 0.0ms
🧠 Performing intelligent end-context detection for streaming
⏱️ [CONTEXT DETAIL] Cache check: 0.0ms
⚡ [SMART-OPTIMIZATION] Using smart cached screen context (1071 chars) - skipping new capture
⏱️ [STREAMING CONTEXT TIMING] Screen capture + context detection: 0.0ms
t=1317236 sess=I7F lvl=INFO cat=transcript evt=final text="BT brittle workflows lack a context and misalignment."
t=1317237 sess=I7F lvl=INFO cat=transcript evt=session_end divider="────────── session end ──────────"
🔊 [SoundManager] Attempting to play stop sound
🔊 [SoundManager] NSSound stop sound result: true
🧹 Connection cleanup completed (session resources released)
📝 [GRACE] Recording session ended
📱 Dismissing recorder
⏹️ Keepalive timer stopped
⚠️ WebSocket did close with code 1001 (sid=sock_2722754041283062614, attemptId=20)
t=1317290 sess=I7F lvl=WARN cat=stream evt=state state=closed code=1001
✅ Streaming transcription processing completed
🔌 [WS] Disconnected (socketId=sock_2722754041283062614@attempt_20)
t=1317345 sess=I7F lvl=INFO cat=transcript evt=insert_attempt target=Xcode chars=54 text="BT brittle workflows lack a context and misalignment. "
🔍 [PASTE DEBUG] AXIsProcessTrusted() returned true, proceeding
🔍 [PASTE DEBUG] UseDirectTextInsertion setting: false
🔍 [PASTE DEBUG] Direct insertion disabled, using clipboard paste
⌨️ Using CGEvent-based Command+V
t=1317371 sess=I7F lvl=INFO cat=transcript evt=insert_result ok=true
📊 [POST-RELEASE E2E] 858ms (paste=0ms) | warm_socket=no
🌐 [CONNECT] New single-flight request from warmHold
🌐 [CONNECT] Attempt #21 (loop 1/2) starting…
t=1317583 sess=I7F lvl=INFO cat=stream evt=temp_key_fetch_start
⚡ [CACHE-HIT] Retrieved temp key in 0.1ms
t=1317583 sess=I7F lvl=INFO cat=stream evt=temp_key_fetch latency_ms=0 source=cached expires_in_s=-1
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🌐 [WS CONNECT] Using URL: wss://stt-rt.soniox.com/transcribe-websocket
🔗 [WS] Bound socket id=sock_-6207851525875821616@attempt_21
t=1317584 sess=I7F lvl=INFO cat=stream evt=ws_bind target_ip=resolving... attempt=21 via_proxy=false path=/transcribe-websocket target_host=stt-rt.soniox.com socket=sock_-6207851525875821616@attempt_21
🔑 Successfully connected to Soniox using temp key (1ms key latency)
t=1317585 sess=I7F lvl=INFO cat=stream evt=ws_bind_resolved target_ip=129.146.176.251 attempt=21 target_host=stt-rt.soniox.com via_proxy=false socket=sock_-6207851525875821616@attempt_21 path=/transcribe-websocket
t=1319662 sess=I7F lvl=INFO cat=stream evt=ws_handshake_metrics connect_ms=1605 total_ms=2077 proxy=false protocol=http/1.1 socket=sock_-6207851525875821616@attempt_21 dns_ms=0 tls_ms=1605 reused=false attempt=21
🔌 WebSocket did open (sid=sock_-6207851525875821616, attemptId=21)
📤 [START] Sent start/config on standby socket (eager mode)
t=1319672 sess=I7F lvl=INFO cat=stream evt=start_config ctx=standby_eager attempt=21 socket=sock_-6207851525875821616@attempt_21 summary=["audio_format": "pcm_s16le", "ch": 1, "valid": true, "langs": 2, "sr": 16000, "ctx_len": 36, "json_hash": "74c88fa4ee9a34f7", "model": "stt-rt-preview-v2"]
🧾 [START-CONFIG] ctx=standby_eager sum=["audio_format": "pcm_s16le", "ch": 1, "valid": true, "langs": 2, "sr": 16000, "ctx_len": 36, "json_hash": "74c88fa4ee9a34f7", "model": "stt-rt-preview-v2"]
🌐 [CONNECT] Attempt #21 succeeded
📤 Sending text frame seq=21524
🧊 [STANDBY] Connected standby socket — keepalive every 10.0s, TTL=60s
⏱️ [STANDBY] TTL reached (60s) — closing standby socket
⏹️ Keepalive timer stopped
🔌 [READY] attemptId=21 socketId=sock_-6207851525875821616@attempt_21 start_text_sent=true
🧊 [STANDBY] WebSocket ready in 2090ms (handshake)
🔌 [WS] Disconnected (socketId=sock_-6207851525875821616@attempt_21)
👂 [LISTENER] Standby listener task for socketId= attemptId=21
⚠️ WebSocket did close with code 1001 (sid=sock_-6207851525875821616, attemptId=21)
t=1319673 sess=I7F lvl=WARN cat=stream evt=state state=closed code=1001




## 5 Failure
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
🎤 Registering audio tap for Soniox
t=1419373 sess=I7F lvl=INFO cat=audio evt=record_start service=Soniox
🔍 Performing audio system pre-flight checks
throwing -10877
throwing -10877
✅ Pre-flight checks passed
t=1419479 sess=I7F lvl=INFO cat=audio evt=tap_install service=Soniox ok=true backend=avcapture
t=1419479 sess=I7F lvl=INFO cat=audio evt=record_start reason=start_capture
t=1419479 sess=I7F lvl=INFO cat=audio evt=device_pin_start prev_name="MacBook Pro Microphone" desired_uid_hash=-1685521486385182984 prev_id=181 desired_name="MacBook Pro Microphone" desired_id=181 prev_uid_hash=-1685521486385182984
❄️ Cold start detected - performing full initialization
⏰ [CACHE] Cache is stale (age: 205.6s, ttl=120s)
❄️ Performing cold start initialization
⏭️ Skipping engine cold start (backend=AVCapture)
🎬 Starting screen capture with verified permissions
t=1419563 sess=I7F lvl=INFO cat=audio evt=capture_backend_selected backend=avcapture
✅ Unified audio capture started
✅ Selected account account-bundle (connections: 1/10)
🧠 [TEN-VAD] Initialized (threshold=0.5, hop=256)
🚀 Starting Clio streaming transcription
🎯 2025-08-26-warm-reuse-failure-log2.md — clio-project (Workspace) — Untracked
🌐 [LANG DEBUG] Multi-language setting exists: true, Single language: en
🌐 [LANG DEBUG] Using multi-language selection (prioritized): zh, en
🌐 Using selected languages for OCR: zh-Hans, en-US
t=1419621 sess=I7F lvl=INFO cat=audio evt=avcapture_start ok=true
🏥 [AUDIO HEALTH] Health monitoring timer started
⏱️ [TIMING] mic_engaged @ 1756280195.193
⏱️ [TIMING] WebSocket connect task completed — will flush after READY
pass
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
t=1419736 sess=I7F lvl=INFO cat=stream evt=first_audio_buffer_captured ms=115
t=1419738 sess=I7F lvl=INFO cat=audio evt=level avg_db=-60 peak_db=-60
✅ [AUDIO HEALTH] First audio data received - tap is functional
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
🗣️ [TEN-VAD] Speech start detected
🛑 [TEN-VAD] Speech end detected
🌐 [PATH] Initial path baseline set — no action
🌐 [ASR BREAKDOWN] Total: 1034ms | Client↔Proxy: 245ms | Proxy↔Soniox: 788ms | Network: 788ms
🗑️ Evicted oldest temp key to maintain cache size limit
💾 Cached temp key for languages: ["en", "zh"]
🗓️ [TTL-SCHEDULE] Scheduling temp key refresh for key=global in 3000s (expiresAt=2025-08-27 08:36:35 +0000)
✅ [PREFETCH] Successfully prefetched temp key
🎤 [WARMUP] Pre-warming audio system...
✅ [PREWARM] Device enumeration completed
✅ [PREWARM] Audio system pre-warming completed successfully
✅ [WARMUP] Audio system pre-warmed successfully
🛑 [TEN-VAD] Speech end detected
🛑 [TEN-VAD] Speech end detected
🔍 Found 191 text observations
✅ Text extraction successful: 6220 chars, 6220 non-whitespace, 749 words from 191 observations
✅ Captured text successfully
✅ [CAPTURE DEBUG] Screen capture successful: 6348 characters
💾 [SMART-CACHE] Cached new context: com.todesktop.230313mzl4w4u92|2025-08-26-warm-reuse-failure-log2.md — clio-project (Workspace) — Untracked (6348 chars)
🎯 [CALLBACK DEBUG] Executing callback with fresh content (6348 chars)
🔥 [PREWARM DEBUG] Pre-warming AI connection (target: Gemini), environment: flyio
🔥 [NER-TRIGGER] OCR completion callback triggered with fresh content
🎬 [NER-PREWARM] Using raw OCR text for NER: 6348 characters
🧠 [NER-DEFAULT] Using default NER prompt for general extraction
t=1421738 sess=I7F lvl=INFO cat=audio evt=level peak_db=-27 avg_db=-27
📦 Buffer growing: 200 packets (74376 bytes)
throwing -10877
throwing -10877
🛑 [TEN-VAD] Speech end detected
t=1423748 sess=I7F lvl=INFO cat=audio evt=level peak_db=-44 avg_db=-44
📦 Buffer growing: 400 packets (148776 bytes)
t=1425755 sess=I7F lvl=INFO cat=audio evt=level avg_db=-45 peak_db=-45
📦 Buffer growing: 600 packets (223176 bytes)
🤖 [FLY.IO-NER] Server-reported provider: gemini
📥 [NER-STORE] Stored NER entities: 4319 chars - This is a log file detailing a failure in a "warm reuse" scenario within the Clio project, likely re...
✅ [FLY.IO] NER refresh completed successfully
throwing -10877
throwing -10877
t=1427765 sess=I7F lvl=INFO cat=audio evt=level peak_db=-49 avg_db=-49
📦 Buffer growing: 800 packets (297576 bytes)
t=1429775 sess=I7F lvl=INFO cat=audio evt=level peak_db=-41 avg_db=-41
📦 Buffer growing: 1000 packets (371976 bytes)
t=1431781 sess=I7F lvl=INFO cat=audio evt=level peak_db=-40 avg_db=-40
throwing -10877
throwing -10877
📦 Buffer growing: 1200 packets (446376 bytes)
t=1433790 sess=I7F lvl=INFO cat=audio evt=level peak_db=-43 avg_db=-43
t=1435799 sess=I7F lvl=INFO cat=audio evt=level peak_db=-43 avg_db=-43
📦 Buffer growing: 1400 packets (520776 bytes)
throwing -10877
throwing -10877
t=1437807 sess=I7F lvl=INFO cat=audio evt=level peak_db=-40 avg_db=-40
📦 Buffer growing: 1600 packets (595176 bytes)
🛑 [TEN-VAD] Speech end detected
🔊 [SoundManager] Attempting to play esc sound (with fade)
📱 Dismissing recorder
🛑 Stopping Clio streaming transcription
🏥 [AUDIO HEALTH] Health monitoring timer stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
🛑 Stopping unified audio capture
t=1438664 sess=I7F lvl=INFO cat=audio evt=record_stop
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key plugInPackage
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key CMIOType
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key numberOfDevices
t=1438674 sess=I7F lvl=INFO cat=audio evt=avcapture_stop
✅ Unified audio capture stopped
⏹️ Keepalive timer stopped
⚡ Audio capture already stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
📉 Released connection for account account-bundle (connections: 0)
💾 [COLD-START] Updated successful streaming timestamp
💾 [COLD-START] Updated successful streaming timestamp
✅ Streaming stopped. Final transcript (0 chars, 19.1s, without audio file): ""
🌡️ [WARM] warm_socket=yes
t=1438706 sess=I7F lvl=INFO cat=transcript evt=final text=
t=1438706 sess=I7F lvl=INFO cat=transcript evt=session_end divider="────────── session end ──────────"
⏹️ Keepalive timer stopped
🔌 [WS] Disconnected (socketId=)
🌐 [CONNECT] New single-flight request from warmHold
🌐 [CONNECT] Attempt #22 (loop 1/2) starting…
t=1438827 sess=I7F lvl=INFO cat=stream evt=temp_key_fetch_start
⚡ [CACHE-HIT] Retrieved temp key in 0.1ms
t=1438828 sess=I7F lvl=INFO cat=stream evt=temp_key_fetch expires_in_s=-1 source=cached latency_ms=0
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🌐 [WS CONNECT] Using URL: wss://stt-rt.soniox.com/transcribe-websocket
🔗 [WS] Bound socket id=sock_6075960214443211114@attempt_22
t=1438861 sess=I7F lvl=INFO cat=stream evt=ws_bind socket=sock_6075960214443211114@attempt_22 attempt=22 target_ip=resolving... target_host=stt-rt.soniox.com path=/transcribe-websocket via_proxy=false
🔑 Successfully connected to Soniox using temp key (34ms key latency)
t=1438862 sess=I7F lvl=INFO cat=stream evt=ws_bind_resolved attempt=22 target_ip=129.146.176.251 target_host=stt-rt.soniox.com via_proxy=false path=/transcribe-websocket socket=sock_6075960214443211114@attempt_22
t=1440718 sess=I7F lvl=INFO cat=stream evt=ws_handshake_metrics reused=false attempt=22 connect_ms=1434 proxy=false total_ms=1888 protocol=http/1.1 dns_ms=0 socket=sock_6075960214443211114@attempt_22 tls_ms=1434
🔌 WebSocket did open (sid=sock_6075960214443211114, attemptId=22)
📤 [START] Sent start/config on standby socket (eager mode)
t=1440719 sess=I7F lvl=INFO cat=stream evt=start_config ctx=standby_eager attempt=22 socket=sock_6075960214443211114@attempt_22 summary=["audio_format": "pcm_s16le", "langs": 2, "ctx_len": 36, "sr": 16000, "valid": true, "ch": 1, "json_hash": "647d4d9a98bd6de5", "model": "stt-rt-preview-v2"]
🧾 [START-CONFIG] ctx=standby_eager sum=["audio_format": "pcm_s16le", "langs": 2, "ctx_len": 36, "sr": 16000, "valid": true, "ch": 1, "json_hash": "647d4d9a98bd6de5", "model": "stt-rt-preview-v2"]
📤 Sending text frame seq=21525
🌐 [CONNECT] Attempt #22 succeeded
🧊 [STANDBY] Connected standby socket — keepalive every 10.0s, TTL=60s
🔌 [READY] attemptId=22 socketId=sock_6075960214443211114@attempt_22 start_text_sent=true
🧊 [STANDBY] WebSocket ready in 1902ms (handshake)
📦 Flushing 1640 buffered packets (19.1s of audio, 610056 bytes)
📤 Sent buffered packet 0/1640 seq=0 size=372
📤 Sent buffered packet 1639/1640 seq=1639 size=372
✅ Buffer flush complete
👂 [LISTENER] Standby listener task for socketId=sock_6075960214443211114@attempt_22 attemptId=22
t=1441824 sess=I7F lvl=INFO cat=stream evt=first_partial ms=22203
t=1441824 sess=I7F lvl=INFO cat=stream evt=ttft_hotkey ms=22203
t=1442982 sess=I7F lvl=INFO cat=stream evt=first_final ms=23361
t=1442983 sess=I7F lvl=INFO cat=transcript evt=raw_final text="This one failure, it's even more prominent.<end>"
💤 [STANDBY] keepalive_tick
t=1450730 sess=I7F lvl=INFO cat=stream evt=standby_keepalive_tick
💤 [STANDBY] keepalive_tick
t=1460730 sess=I7F lvl=INFO cat=stream evt=standby_keepalive_tick




## 6 Success
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
📊 [SESSION] Starting recording session #17
🧪 [A/B] warm_socket=yes
🧊➡️🔥 [STANDBY->ACTIVE] Consuming standby socket for new utterance
⏭️ [STANDBY->ACTIVE] START already sent on standby (eager) — skipping re-send
🔄 [CACHE] Context changed - invalidating cache
🔄 [CACHE]   Old: com.todesktop.230313mzl4w4u92|2025-08-26-warm-reuse-failure-log2.md — clio-project (Workspace) — Untracked
🔄 [CACHE]   New: com.apple.dt.Xcode|Clio — clean.swift
🔄 [CACHE]   BundleID Match: false
🔄 [CACHE]   Title Match: false
🔄 [CACHE]   Content Hash: Old=c2e8198e... New=c2e8198e...
✅ [STANDBY->ACTIVE] Probe keepalive OK — proceeding to resume queue
⏹️ Keepalive timer stopped
🔄 Keepalive timer started (interval: 15.000000s)
🧪 [PROMO] snapshot attempt=22 socket=sock_6075960214443211114@attempt_22 start_sent=true ws_ready=true standby=false purpose=active cap_sr=16000 cap_ch=1 prebuf=0 last_fp=m=stt-rt-preview-v2|sr=16000|ch=1|h=en,zh|ctx=599674829880034847
t=1465476 sess=I7F lvl=INFO cat=stream evt=temp_key_fetch_start
🎬 Starting screen capture with verified permissions
⚡ [CACHE-HIT] Retrieved temp key in 0.3ms
t=1465477 sess=I7F lvl=INFO cat=stream evt=temp_key_fetch source=cached expires_in_s=-1 latency_ms=0
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🧪 [PROMO] config_fp current=m=stt-rt-preview-v2|sr=16000|ch=1|h=en,zh|ctx=599674829880034847 last=m=stt-rt-preview-v2|sr=16000|ch=1|h=en,zh|ctx=599674829880034847
🎤 Registering audio tap for Soniox
t=1465477 sess=I7F lvl=INFO cat=audio evt=record_start service=Soniox
🔍 Performing audio system pre-flight checks
🎯 Clio — clean.swift
🌐 [LANG DEBUG] Multi-language setting exists: true, Single language: en
🌐 [LANG DEBUG] Using multi-language selection (prioritized): zh, en
🌐 Using selected languages for OCR: zh-Hans, en-US
throwing -10877
throwing -10877
✅ Pre-flight checks passed
t=1465603 sess=I7F lvl=INFO cat=audio evt=tap_install backend=avcapture ok=true service=Soniox
t=1465604 sess=I7F lvl=INFO cat=audio evt=record_start reason=start_capture
t=1465604 sess=I7F lvl=INFO cat=audio evt=device_pin_start prev_id=181 prev_uid_hash=-1685521486385182984 desired_uid_hash=-1685521486385182984 desired_id=181 prev_name="MacBook Pro Microphone" desired_name="MacBook Pro Microphone"
t=1465604 sess=I7F lvl=INFO cat=audio evt=capture_backend_selected backend=avcapture
✅ Unified audio capture started
✅ Selected account account-bundle (connections: 1/10)
🧠 [TEN-VAD] Initialized (threshold=0.5, hop=256)
🚀 Starting Clio streaming transcription
🏥 [AUDIO HEALTH] Health monitoring timer started
⏱️ [TIMING] mic_engaged @ 1756280241.228
⏱️ [TIMING] WebSocket connect task completed — will flush after READY
pass
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
t=1465716 sess=I7F lvl=INFO cat=audio evt=avcapture_start ok=true
t=1465717 sess=I7F lvl=INFO cat=stream evt=first_audio_buffer_captured ms=61
🧪 [PROMO] first_audio seq=0 bytes=372 approx_db=-60.0
t=1465719 sess=I7F lvl=INFO cat=audio evt=level avg_db=-60 peak_db=-60
✅ [AUDIO HEALTH] First audio data received - tap is functional
t=1465719 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=0 bytes=372 flushing=false
t=1465719 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=1 bytes=372 flushing=false
t=1465719 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=2 bytes=372 flushing=false
t=1465719 sess=I7F lvl=INFO cat=stream evt=first_audio_sent seq=1 ms=63
t=1465719 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true seq=3 bytes=360 flushing=false
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
🌐 [ASR BREAKDOWN] Total: 515ms | Client↔Proxy: 248ms | Proxy↔Soniox: 266ms | Network: 265ms
t=1465753 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=360 seq=4 ready=true
t=1465753 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 seq=5 ready=true
t=1465753 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true flushing=false bytes=372 seq=6 ready=true
🗑️ Evicted oldest temp key to maintain cache size limit
💾 Cached temp key for languages: ["en", "zh"]
🗓️ [TTL-SCHEDULE] Scheduling temp key refresh for key=global in 3000s (expiresAt=2025-08-27 08:37:21 +0000)
✅ [PREFETCH] Successfully prefetched temp key
🎤 [WARMUP] Pre-warming audio system...
✅ [PREWARM] Device enumeration completed
✅ [PREWARM] Audio system pre-warming completed successfully
✅ [WARMUP] Audio system pre-warmed successfully
t=1465760 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=7 has_socket=true flushing=false
t=1465772 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true flushing=false bytes=372 has_socket=true seq=8
t=1465784 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true bytes=372 seq=9 flushing=false
t=1465795 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 has_socket=true seq=10 ready=true flushing=false
t=1465807 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=11 flushing=false bytes=372 has_socket=true
t=1465819 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true has_socket=true flushing=false bytes=372 seq=12
t=1465831 sess=I7F lvl=INFO cat=stream evt=pre_send ready=true seq=13 bytes=372 flushing=false has_socket=true
t=1465842 sess=I7F lvl=INFO cat=stream evt=pre_send flushing=false bytes=372 has_socket=true seq=14 ready=true
t=1465854 sess=I7F lvl=INFO cat=stream evt=pre_send has_socket=true ready=true flushing=false bytes=372 seq=15
t=1465865 sess=I7F lvl=INFO cat=stream evt=pre_send bytes=372 ready=true seq=16 flushing=false has_socket=true
🗣️ [TEN-VAD] Speech start detected