### see, it doesnt work, idk why. the third recording. i relaly actually dont understand the root cause...

i am just keeping a socket open, thats it. and resume sending uadio, idk why that wouldnt work lol

why some works but some dont, thats the question i have

----
### this is the clinet log for several transcripts, with the single on socket + using endpoint detection as gate


✅ Trial data integrity validation passed
✅ Trial dates validation passed
🔐 [ENTITLEMENT] Using cached paid entitlement until 2025-08-30 15:20:52 +0000
🔄 [SYNC_STATE] syncTrialState called - currentTier: pro, isInTrial: false
🔄 [SYNC_STATE] Final state after syncTrialState - currentTier: pro, isInTrial: false
📊 [STARTUP] Loaded trial words: 1448/4000, remaining: 2552
🔄 [SYNC_STATE] syncTrialState called - currentTier: pro, isInTrial: true
🔄 [SYNC_STATE] Final state after syncTrialState - currentTier: pro, isInTrial: true
   From: /Users/ZhaobangJetWu/Library/Application Support/com.jetsonai.clio
   To: /Users/ZhaobangJetWu/Library/Application Support/com.cliovoice.clio
   ⏭️ Skipping .DS_Store (already exists)
   ⏭️ Skipping Recordings (already exists)
   ⏭️ Skipping default.store (already exists)
   ⏭️ Skipping WhisperModels (already exists)
🎉 Migration completed successfully!
   Files migrated: 0
   Total size: Zero KB
📝 Legacy data preserved for safety
   You can manually delete it after verifying migration worked correctly
📊 [REGISTRY] Initialization complete with 3 legacy detectors
AddInstanceForFactory: No factory registered for id <CFUUID 0x6000035ff2e0> F8BB1C28-BAE8-11D6-9C31-00039315CD46
      HALC_ShellObject.mm:615    HALC_ShellObject::SetPropertyData: call to the proxy failed, Error: 1852797029 (nope)
      HALC_ShellObject.mm:615    HALC_ShellObject::SetPropertyData: call to the proxy failed, Error: 1852797029 (nope)
Failed to get fallback device
Successfully added device change listener
Successfully added default input change listener
🔑 TempKeyCache initialized
🔄 Background prefetch timer started
⏹️ System keepalive stopped
🔄 System keepalive started (interval: 15 minutes)
🎯 [GATE] State machine enabled for testing
🎹 HotkeyManager initializing at 2025-08-25 02:59:22 +0000
🎹 KeyboardShortcuts library available: toggleMiniRecorder
       LoudnessManager.mm:413   PlatformUtilities::CopyHardwareModelFullName() returns unknown value: Mac16,7, defaulting hw platform key
🔍 [SHORTCUT DEBUG] Library shortcut: F5 (effective: F5)
🔍 [SHORTCUT DEBUG] Custom shortcut: nil
🔍 [SHORTCUT DEBUG] Shortcut configured: true
🎛️ Setting up hands-free shortcut monitor for: Right ⌘
✅ Keyboard shortcut configured: F5
t=000002 sess=qet lvl=INFO cat=sys evt=app_launch ver=1.44.0
🧭 [APP] ActivationPolicy=.regular (IsMenuBarOnly=false)
🧭 [APP] applicationShouldHandleReopen called - hasVisibleWindows: true
🧭 [APP] ActivationPolicy=.regular (IsMenuBarOnly=false)
t=000659 sess=qet lvl=INFO cat=hotkey evt=open_config ready=false
🧪 Testing KeyboardShortcuts library...
🧪 Current shortcut from library: F5
🧪 Current shortcut available: F5
🧪 KeyboardShortcuts library test completed
🔧 [HOTKEY SETUP] Setting up shortcut handler at 2025-08-25 02:59:26 +0000
🧹 [HOTKEY SETUP] Cleared existing handlers
🔧 [HOTKEY SETUP] Attempting to activate KeyboardShortcuts system...
🔧 [HOTKEY SETUP] Forced library initialization
🔧 [HOTKEY SETUP] Library activation complete, ready for real handlers...
🎛️ Setting up hands-free shortcut monitor for: Right ⌘
t=000663 sess=qet lvl=INFO cat=hotkey evt=register ok=true
🧭 [APP] applicationDidBecomeActive
🧭 [APP] ActivationPolicy=.regular (IsMenuBarOnly=false)
🧭 [APP] applicationDidBecomeActive
🧭 [APP] ActivationPolicy=.regular (IsMenuBarOnly=false)
🔐 [ENTITLEMENT] Using cached paid entitlement until 2025-08-30 15:20:52 +0000
🔄 [SYNC_STATE] syncTrialState called - currentTier: pro, isInTrial: false
🔄 [SYNC_STATE] Final state after syncTrialState - currentTier: pro, isInTrial: false
✅ LocalizationManager: Successfully loaded bundle for language: en
Loaded saved device ID: 181
Using saved device: MacBook Pro Microphone
Error: -checkForUpdatesInBackground called but .sessionInProgress == YES
161539          HALC_ProxyIOContext.cpp:1622  HALC_ProxyIOContext::IOWorkLoop: skipping cycle due to overload
🪟 [WINDOW] Configuring window: Clio
🔧 [WINDOW CFG] transparent=true hiddenTitle=true fullSize=true sep=NSTitlebarSeparatorStyle(rawValue: 1) toolbar=false baseline=false
🪟 [WINDOW] Set main window reference: Clio
🪟 [DOCK] Found existing window, activating it
🔥 [WARMUP] ensureReady() invoked context=appActivation
🔥 [SYSTEM-WARMUP] TempKeyCache warmup integration
🚀 [PREFETCH] Starting background temp key prefetch
✅ [MENUBAR] MenuBarView appeared
🧊 [WARMUP] Skipping (recently run) context=appLaunch
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
✅ [AUTH] User authenticated: kentaro@resonantai.co.site
✅ [AUTH] User authenticated: kentaro@resonantai.co.site
Scheduling daily audio cleanup task
✅ [AUTH] Restored session for: kentaro@resonantai.co.site
🔄 [SYNC_STATE] syncTrialState called - currentTier: pro, isInTrial: false
🔄 [SYNC_STATE] Final state after syncTrialState - currentTier: pro, isInTrial: false
Cleanup run finished — removed: 2, failed: 0
🔄 [SYNC_STATE] syncTrialState called - currentTier: pro, isInTrial: false
🔄 [SYNC_STATE] Final state after syncTrialState - currentTier: pro, isInTrial: false
✅ [HOTKEY READY] effective=F5, F5Armed=true
🌐 [ASR BREAKDOWN] Total: 2834ms | Client↔Proxy: 1792ms | Proxy↔Soniox: 1041ms | Network: 1041ms
💾 Cached temp key for languages: ["zh", "en"]
🗓️ [TTL-SCHEDULE] Scheduling temp key refresh for key=global in 3000s (expiresAt=2025-08-25 03:59:29 +0000)
nw_connection_copy_connected_local_endpoint_block_invoke [C7] Client called nw_connection_copy_connected_local_endpoint on unconnected nw_connection
nw_connection_copy_connected_remote_endpoint_block_invoke [C7] Client called nw_connection_copy_connected_remote_endpoint on unconnected nw_connection
nw_connection_copy_protocol_metadata_internal_block_invoke [C7] Client called nw_connection_copy_protocol_metadata_internal on unconnected nw_connection
✅ [PREFETCH] Successfully prefetched temp key
🎤 [WARMUP] Pre-warming audio system...
throwing -10877
throwing -10877
✅ [PREWARM] Audio engine initialized
✅ [PREWARM] Device enumeration completed
CMIO_DAL_CMIOExtension_Device.mm:355:Device legacy uuid isn't present, using new style uuid instead
CMIO_DAL_CMIOExtension_Device.mm:355:Device legacy uuid isn't present, using new style uuid instead
CMIO_DAL_CMIOExtension_Stream.mm:1863:GetPropertyData background replacement pixel buffer size invalid or not available
CMIOHardware.cpp:331:CMIOObjectGetPropertyData Error: 2003332927, failed
✅ [PREWARM] AVCaptureSession pre-configured
✅ [PREWARM] Audio system pre-warming completed successfully
✅ [WARMUP] Audio system pre-warmed successfully
Device list change detected
✅ Successfully updated user stats in Supabase
🔄 Stats synced successfully (FORCED)
📊 242477 words, 1887.4 minutes
✅ Successfully updated user stats in Supabase
🔄 Stats synced successfully (FORCED)
📊 242477 words, 1887.4 minutes
🔄 Handling audio device change
✅ Device change handling completed
📱 Showing DynamicNotch recorder (MIT licensed)
GenerativeModelsAvailability.Parameters: Initialized with invalid language code: zh-CN. Expected to receive two-letter ISO 639 code. e.g. 'zh' or 'en'. Falling back to: zh
AFIsDeviceGreymatterEligible Missing entitlements for os_eligibility lookup
🧊 [WARMUP] Skipping (recently run) context=recorderUIShown
🎤 [toggleRecord] Starting recording, current model: soniox-realtime-streaming
🧊 [WARMUP] Skipping (recently run) context=hotkeyDown
🎙️ Starting recording sequence...
📝 [GRACE] Recording session started with 2552 words remaining
🔧 [NER-SETUP] Setting up callback - contextService exists: true
✅ [NER-SETUP] OCR completion callback configured for NER pre-warming - callback exists: true
🔊 Waking up audio system after 1979s idle time
🎬 Starting screen capture with verified permissions
🎯 Notes
🌐 Using selected languages for OCR: zh-Hans, en-US
📊 [SESSION] Starting recording session #1
🧪 [A/B] warm_socket=yes
🎤 Registering audio tap for Soniox
t=005704 sess=qet lvl=INFO cat=audio evt=record_start service=Soniox
🔍 Performing audio system pre-flight checks
throwing -10877
throwing -10877
✅ Pre-flight checks passed
t=005796 sess=qet lvl=INFO cat=audio evt=tap_install ok=true service=Soniox backend=avcapture
t=005796 sess=qet lvl=INFO cat=audio evt=record_start reason=start_capture
t=005796 sess=qet lvl=INFO cat=audio evt=device_pin_start desired_id=181 prev_name="MacBook Pro Microphone" prev_id=181 desired_uid_hash=281703378278776476 prev_uid_hash=281703378278776476 desired_name="MacBook Pro Microphone"
❄️ Cold start detected - performing full initialization
❄️ Performing cold start initialization
⏭️ Skipping engine cold start (backend=AVCapture)
t=005811 sess=qet lvl=INFO cat=audio evt=capture_backend_selected backend=avcapture
✅ Unified audio capture started
✅ Selected account account-bundle (connections: 1/10)
🧠 [TEN-VAD] Initialized (threshold=0.5, hop=256)
🚀 Starting Clio streaming transcription
🏥 [AUDIO HEALTH] Health monitoring timer started
⏱️ [TIMING] mic_engaged @ 1756090771.728
🆕 [COLD-START] First recording after app launch - applying background warm-up
🌐 [CONNECT] New single-flight request from start
pass
250371          HALC_ProxyIOContext.cpp:1622  HALC_ProxyIOContext::IOWorkLoop: skipping cycle due to overload
               AQMEIO.cpp:201   timed out after 0.011s (251 251); suspension count=0 (IOSuspensions: )
250371          HALC_ProxyIOContext.cpp:1622  HALC_ProxyIOContext::IOWorkLoop: skipping cycle due to overload
🌐 [CONNECT] Attempt #1 (loop 1/3) starting…
⚡ [CACHE-HIT] Retrieved temp key in 0.1ms
🌐 [WS CONNECT] Using URL: wss://stt-rt.soniox.com/transcribe-websocket
🔗 [WS] Bound socket id=sock_2909900799192198704@attempt_1
t=005892 sess=qet lvl=INFO cat=stream evt=ws_bind socket=sock_2909900799192198704@attempt_1
🔑 Successfully connected to Soniox using temp key (3ms key latency)
t=005927 sess=qet lvl=INFO cat=audio evt=avcapture_start ok=true
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
✅ [AUDIO HEALTH] First audio data received - tap is functional
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
🗣️ [TEN-VAD] Speech start detected
186375          HALC_ProxyIOContext.cpp:1622  HALC_ProxyIOContext::IOWorkLoop: skipping cycle due to overload
250371          HALC_ProxyIOContext.cpp:1622  HALC_ProxyIOContext::IOWorkLoop: skipping cycle due to overload
186375          HALC_ProxyIOContext.cpp:1622  HALC_ProxyIOContext::IOWorkLoop: skipping cycle due to overload
250371          HALC_ProxyIOContext.cpp:1622  HALC_ProxyIOContext::IOWorkLoop: skipping cycle due to overload
🔍 Found 89 text observations
✅ Text extraction successful: 1032 chars, 1032 non-whitespace, 190 words from 89 observations
✅ Captured text successfully
✅ [CAPTURE DEBUG] Screen capture successful: 1088 characters
💾 [SMART-CACHE] Cached new context: com.apple.Notes|Notes (1088 chars)
🎯 [CALLBACK DEBUG] Executing callback with fresh content (1088 chars)
🔥 [PREWARM DEBUG] Pre-warming AI connection (target: Gemini), environment: flyio
🔥 [NER-TRIGGER] OCR completion callback triggered with fresh content
🎬 [NER-PREWARM] Using raw OCR text for NER: 1088 characters
🧠 [NER-DEFAULT] Using default NER prompt for general extraction
🧭 [APP] applicationDidBecomeActive
🧭 [APP] ActivationPolicy=.regular (IsMenuBarOnly=false)
🔄 [SYNC_STATE] syncTrialState called - currentTier: pro, isInTrial: false
🔄 [SYNC_STATE] Final state after syncTrialState - currentTier: pro, isInTrial: false
🔥 [COLD-START] Pre-warming connection pool
🔌 WebSocket did open (sid=sock_2909900799192198704, attemptId=1)
🌐 [CONNECT] Attempt #1 succeeded
⏱️ [TIMING] WebSocket connect task completed — will flush after READY
📤 [START] Sent start/config text frame (attemptId=1, socketId=sock_2909900799192198704@attempt_1, start_text_sent=true)
🔌 [READY] attemptId=1 socketId=sock_2909900799192198704@attempt_1 start_text_sent=true
🔌 WebSocket ready after 1670ms - buffered 1.6s of audio
📦 Flushing 136 buffered packets (1.6s of audio, 49924 bytes)
📤 Sent buffered packet 0/136 seq=0 size=360
📤 Sent buffered packet 135/136 seq=135 size=372
✅ Buffer flush complete
⏹️ Keepalive timer stopped
🔄 Keepalive timer started (interval: 15.000000s)
👂 [LISTENER] Starting listener task for socketId=sock_2909900799192198704@attempt_1 attemptId=1
📤 Sending text frame seq=0
🤖 [FLY.IO-NER] Server-reported provider: gemini
📥 [NER-STORE] Stored NER entities: 292 chars - **People:**
* Kentaro

**Organizations:**
* iCloud

**Products:**
* Clio los App

**Projects:**
* Wo...
✅ [FLY.IO] NER refresh completed successfully
⏭️ [SYSTEM-WARMUP] Skipping audio warmup (backend=AVCapture)
🔥 [SYSTEM-WARMUP] Warming up network connections
✅ [SYSTEM-WARMUP] JWT token pre-fetched
🔥 [SYSTEM-WARMUP] TempKeyCache warmup integration
🚀 [PREFETCH] Starting background temp key prefetch
t=009521 sess=qet lvl=INFO cat=stream evt=ttft ms=3397
throwing -10877
throwing -10877
🌐 [ASR BREAKDOWN] Total: 1081ms | Client↔Proxy: 201ms | Proxy↔Soniox: 880ms | Network: 880ms
🗑️ Evicted oldest temp key to maintain cache size limit
💾 Cached temp key for languages: ["zh", "en"]
🗓️ [TTL-SCHEDULE] Scheduling temp key refresh for key=global in 3000s (expiresAt=2025-08-25 03:59:36 +0000)
✅ [PREFETCH] Successfully prefetched temp key
🔥 [COLD-START] URLSession configured with extended timeouts
✅ [COLD-START] Warm-up complete with network stack optimization
t=012861 sess=qet lvl=INFO cat=transcript evt=raw_final text="Testing, one two three. Give it a shot and see whether or not we can make it work.<end>"
throwing -10877
throwing -10877
🛑 Stopping recording
🛑 Stopping Clio streaming transcription
🏥 [AUDIO HEALTH] Health monitoring timer stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
🛑 Stopping unified audio capture
t=016975 sess=qet lvl=INFO cat=audio evt=record_stop
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key plugInPackage
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key CMIOType
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key numberOfDevices
t=016991 sess=qet lvl=INFO cat=audio evt=avcapture_stop
✅ Unified audio capture stopped
t=017073 sess=qet lvl=INFO cat=transcript evt=raw_final text=" Um, but it looks like it might be challenging.<end>"
🏁 [STRICT-END] <end> observed — proceeding without manual finalize
⚡ Audio capture already stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
📉 Released connection for account account-bundle (connections: 0)
💾 [COLD-START] Updated successful streaming timestamp
💾 [COLD-START] Updated successful streaming timestamp
✅ Streaming stopped. Final transcript (129 chars, 11.3s, with audio file): "Testing, one two three. Give it a shot and see whether or not we can make it work. Um, but it looks like it might be challenging."
t=017150 sess=qet lvl=INFO cat=transcript evt=final text="Testing, one two three. Give it a shot and see whether or not we can make it work. Um, but it looks like it might be challenging."
t=017150 sess=qet lvl=INFO cat=transcript evt=session_end divider="────────── session end ──────────"
🌡️ [WARM] warm_socket=yes
🧊 [WARM-HOLD] Started warm hold: 60s timer active, idle keepalives active
t=017150 sess=qet lvl=INFO cat=stream evt=warm_hold state=start
✅ Streaming transcription completed successfully, length: 129 characters
⏱️ [TIMING] Subscription tracking: 0.9ms
⏱️ [TIMING] ASR word tracking: 0.0ms
🧠 Performing intelligent end-context detection for streaming
⏱️ [CONTEXT DETAIL] Cache check: 0.0ms
⚡ [SMART-OPTIMIZATION] Using smart cached screen context (1088 chars) - skipping new capture
⏱️ [STREAMING CONTEXT TIMING] Screen capture + context detection: 0.3ms
🎯 Starting dynamic context-aware AI enhancement with tracking for text (129 characters)
⚡ [FAST-PATH] Using pre-warmed context - skipping redundant detection
⚡ [PREWARMED] Using pre-warmed NER context fast-path
🎯 [RULE-ENGINE] Detected: General
📧 [EMAIL] Starting email context detection
❌ [EMAIL] No title matches and confidence not high enough: 0.000000
💻 [CODE] Starting code context detection
❌ [CODE] Code confidence too low: 0.000000 < 0.300000
💬 [CHAT] Starting casual chat context detection
💬 [CHAT] Casual chat context detected - Title matches: 2, Content matches: 6, Confidence: 0.520000
📝 [REGISTRY] Rule engine returned .none and no high-confidence legacy matches, returning general context
📝 [PREWARMED] Non-code or unknown context → using enhanced system prompt
📝 [PREWARMED-SYSTEM] Enhanced system prompt: 'You are an expert in enhancing the text provided within <TRANSCRIPT> tags according to the following guidelines: The information in <CONTEXT_INFORMATI...'
📝 [PREWARMED-USER] Enhanced user prompt: 'Clean this transcript while maintaining conversational tone.
Break into logical paragraphs if needed.

Examples of preserving code-switching:

Input: ...'
🛰️ Sending to AI provider via proxy: GROQ
🌐 [CUSTOM-PROMPT] Attempting Groq via proxy...
🔑 [DEBUG] Getting JWT token...
🔑 [DEBUG] JWT token obtained in 0ms
🎯 [CONFIG-DEBUG] Config 2: Routing to Groq endpoint (https://fly.cliovoice.com/api/llm/proxy) with model: qwen
📝 [TIMING] Request preparation: 0.1ms
🌐 [DEBUG] Sending request to proxy...
🌐 [DEBUG] Proxy response received in 1191ms
🔄 [FALLBACK] Server timeout detected (408) - flex tier overloaded or network stall
⚠️ [CUSTOM-PROMPT] Groq via proxy failed: The operation couldn’t be completed. (Clio.EnhancementError error 7.)
🔄 [FALLBACK] Enhancement error detected: Clio.EnhancementError.serverError
🤖 [CUSTOM-PROMPT] Attempting Gemini fallback...
🤖 [GEMINI] Request completed in 749.4ms
🤖 [GEMINI] Used fallback provider successfully
✅ [CUSTOM-PROMPT] Gemini fallback succeeded
t=019218 sess=qet lvl=INFO cat=transcript evt=llm_final text="Testing, one two three. Give it a shot and see whether or not we can make it work, but it looks like it might be challenging."
📊 [DETAILED STREAMING TIMING] Streaming: 215.4ms | Context: 0.3ms | LLM: 2065.4ms | Tracked Overhead: 0.0ms | Unaccounted: 1.6ms | Total: 2282.8ms
🔊 [SoundManager] Attempting to play stop sound
🔊 [SoundManager] NSSound stop sound result: true
🧹 Connection cleanup completed (session resources released)
📝 [GRACE] Recording session ended
📱 Dismissing recorder
📊 [ENHANCEMENT] Tracking 26 words - currentTier: pro, trialWordsRemaining: 2552
✅ Streaming transcription processing completed
t=019318 sess=qet lvl=INFO cat=transcript evt=insert_attempt chars=126 target=Notes text="Testing, one two three. Give it a shot and see whether or not we can make it work, but it looks like it might be challenging. "
🔍 [PASTE DEBUG] AXIsProcessTrusted() returned true, proceeding
🔍 [PASTE DEBUG] UseDirectTextInsertion setting: false
🔍 [PASTE DEBUG] Direct insertion disabled, using clipboard paste
250371          HALC_ProxyIOContext.cpp:1622  HALC_ProxyIOContext::IOWorkLoop: skipping cycle due to overload
⌨️ Using CGEvent-based Command+V
t=019381 sess=qet lvl=INFO cat=transcript evt=insert_result ok=true
📊 [POST-RELEASE E2E] 2446ms (finalize=214ms | llm=2065ms | paste=21ms) | warm_socket=no
250371          HALC_ProxyIOContext.cpp:1622  HALC_ProxyIOContext::IOWorkLoop: skipping cycle due to overload
📱 Showing DynamicNotch recorder (MIT licensed)
🧊 [WARMUP] Skipping (recently run) context=recorderUIShown
🎤 [toggleRecord] Starting recording, current model: soniox-realtime-streaming
🧊 [WARMUP] Skipping (recently run) context=hotkeyDown
🎙️ Starting recording sequence...
📝 [GRACE] Recording session started with 2552 words remaining
🔧 [NER-SETUP] Setting up callback - contextService exists: true
✅ [NER-SETUP] OCR completion callback configured for NER pre-warming - callback exists: true
📊 [SESSION] Starting recording session #2
🧪 [A/B] warm_socket=yes
🧊 [WARM-HOLD] Stopped warm hold after 7.8s
t=024975 sess=qet lvl=INFO cat=stream evt=warm_hold state=stop
♻️ [SMART-CACHE] Using cached context: 1088 characters
🔥 [NER-CACHE] Triggering NER callback with cached content (1088 chars)
✅ [NER-CACHE] NER callback triggered with cached content
⚡ [CACHE-HIT] Retrieved temp key in 36.3ms
t=025012 sess=qet lvl=INFO cat=stream evt=ws_reuse reuse=true config_changed=false
🔥 [PREWARM DEBUG] Pre-warming AI connection (target: Gemini), environment: flyio
🎤 Registering audio tap for Soniox
t=025014 sess=qet lvl=INFO cat=audio evt=record_start service=Soniox
🔍 Performing audio system pre-flight checks
throwing -10877
throwing -10877
✅ Pre-flight checks passed
t=025098 sess=qet lvl=INFO cat=audio evt=tap_install backend=avcapture ok=true service=Soniox
t=025098 sess=qet lvl=INFO cat=audio evt=record_start reason=start_capture
t=025099 sess=qet lvl=INFO cat=audio evt=device_pin_start desired_name="MacBook Pro Microphone" desired_id=181 prev_name="MacBook Pro Microphone" desired_uid_hash=281703378278776476 prev_id=181 prev_uid_hash=281703378278776476
t=025099 sess=qet lvl=INFO cat=audio evt=capture_backend_selected backend=avcapture
✅ Unified audio capture started
✅ Selected account account-bundle (connections: 1/10)
👂 [LISTENER] Restarting listener on reused socketId=sock_2909900799192198704@attempt_1 attemptId=1
🧠 [TEN-VAD] Initialized (threshold=0.5, hop=256)
🚀 Starting Clio streaming transcription
🎬 [NER-PREWARM] Using raw OCR text for NER: 1088 characters
🧠 [NER-DEFAULT] Using default NER prompt for general extraction
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
t=025211 sess=qet lvl=INFO cat=audio evt=avcapture_start ok=true
✅ [AUDIO HEALTH] First audio data received - tap is functional
🏥 [AUDIO HEALTH] Health monitoring timer started
⏱️ [TIMING] mic_engaged @ 1756090791.165
⏱️ [TIMING] WebSocket connect task completed — will flush after READY
pass
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
🗣️ [TEN-VAD] Speech start detected
🧭 [APP] applicationDidBecomeActive
🧭 [APP] ActivationPolicy=.regular (IsMenuBarOnly=false)
🌐 [PATH] Initial path baseline set — no action
🔄 [SYNC_STATE] syncTrialState called - currentTier: pro, isInTrial: false
🔄 [SYNC_STATE] Final state after syncTrialState - currentTier: pro, isInTrial: false
🤖 [FLY.IO-NER] Server-reported provider: gemini
📥 [NER-STORE] Stored NER entities: 45 chars - *   **Kentaro Universe**
*   **Kentaro 男士翡翠**...
✅ [FLY.IO] NER refresh completed successfully
t=027650 sess=qet lvl=INFO cat=stream evt=ttft ms=2307
t=029272 sess=qet lvl=INFO cat=transcript evt=raw_final text=" Still wanted to give it a shot.<end>"
throwing -10877
throwing -10877
🛑 Stopping recording
🛑 Stopping Clio streaming transcription
🏥 [AUDIO HEALTH] Health monitoring timer stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
🛑 Stopping unified audio capture
t=031210 sess=qet lvl=INFO cat=audio evt=record_stop
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key plugInPackage
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key CMIOType
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key numberOfDevices
t=031220 sess=qet lvl=INFO cat=audio evt=avcapture_stop
✅ Unified audio capture stopped
🏁 [STRICT-END] <end> observed — proceeding without manual finalize
⚡ Audio capture already stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
📉 Released connection for account account-bundle (connections: 0)
💾 [COLD-START] Updated successful streaming timestamp
💾 [COLD-START] Updated successful streaming timestamp
✅ Streaming stopped. Final transcript (31 chars, 6.1s, with audio file): "Still wanted to give it a shot."
t=031347 sess=qet lvl=INFO cat=transcript evt=final text="Still wanted to give it a shot."
t=031347 sess=qet lvl=INFO cat=transcript evt=session_end divider="────────── session end ──────────"
🌡️ [WARM] warm_socket=yes
🧊 [WARM-HOLD] Started warm hold: 60s timer active, idle keepalives active
t=031347 sess=qet lvl=INFO cat=stream evt=warm_hold state=start
✅ Streaming transcription completed successfully, length: 31 characters
⏱️ [TIMING] Subscription tracking: 0.2ms
⏱️ [TIMING] ASR word tracking: 0.0ms
🧠 Performing intelligent end-context detection for streaming
⏱️ [CONTEXT DETAIL] Cache check: 0.0ms
⚡ [SMART-OPTIMIZATION] Using smart cached screen context (1088 chars) - skipping new capture
⏱️ [STREAMING CONTEXT TIMING] Screen capture + context detection: 0.0ms
🎯 Starting dynamic context-aware AI enhancement with tracking for text (31 characters)
⚡ [FAST-PATH] Using pre-warmed context - skipping redundant detection
⚡ [PREWARMED] Using pre-warmed NER context fast-path
🎯 [RULE-ENGINE] Cache hit for com.apple.Notes|||Notes
📧 [EMAIL] Starting email context detection
❌ [EMAIL] No title matches and confidence not high enough: 0.000000
💻 [CODE] Starting code context detection
❌ [CODE] Code confidence too low: 0.000000 < 0.300000
💬 [CHAT] Starting casual chat context detection
💬 [CHAT] Casual chat context detected - Title matches: 2, Content matches: 6, Confidence: 0.520000
📝 [REGISTRY] Rule engine returned .none and no high-confidence legacy matches, returning general context
📝 [PREWARMED] Non-code or unknown context → using enhanced system prompt
📝 [PREWARMED-SYSTEM] Enhanced system prompt: 'You are an expert in enhancing the text provided within <TRANSCRIPT> tags according to the following guidelines: The information in <CONTEXT_INFORMATI...'
📝 [PREWARMED-USER] Enhanced user prompt: 'Clean this transcript while maintaining conversational tone.
Break into logical paragraphs if needed.

Examples of preserving code-switching:

Input: ...'
🛰️ Sending to AI provider via proxy: GROQ
🌐 [CUSTOM-PROMPT] Attempting Groq via proxy...
🔑 [DEBUG] Getting JWT token...
🔑 [DEBUG] JWT token obtained in 0ms
🎯 [CONFIG-DEBUG] Config 2: Routing to Groq endpoint (https://fly.cliovoice.com/api/llm/proxy) with model: qwen
📝 [TIMING] Request preparation: 0.1ms
🌐 [DEBUG] Sending request to proxy...
🌐 [DEBUG] Proxy response received in 569ms
✅ [DEBUG] Found enhancedText field
🌐 [LLM] Groq: 361ms | TTFT: 345ms
🌐   Client↔Proxy: 208ms
🔍 [CONNECTION HEALTH]
✅ [CUSTOM-PROMPT] Groq via proxy succeeded
t=031987 sess=qet lvl=INFO cat=transcript evt=llm_final text="Still wanted to give it a shot."
📊 [DETAILED STREAMING TIMING] Streaming: 208.0ms | Context: 0.0ms | LLM: 639.1ms | Tracked Overhead: 0.0ms | Unaccounted: 0.8ms | Total: 847.9ms
🔊 [SoundManager] Attempting to play stop sound
🔊 [SoundManager] NSSound stop sound result: true
🧹 Connection cleanup completed (session resources released)
📝 [GRACE] Recording session ended
📱 Dismissing recorder
📊 [ENHANCEMENT] Tracking 7 words - currentTier: pro, trialWordsRemaining: 2552
✅ Streaming transcription processing completed
t=032084 sess=qet lvl=INFO cat=transcript evt=insert_attempt target=Notes chars=32 text="Still wanted to give it a shot. "
🔍 [PASTE DEBUG] AXIsProcessTrusted() returned true, proceeding
🔍 [PASTE DEBUG] UseDirectTextInsertion setting: false
🔍 [PASTE DEBUG] Direct insertion disabled, using clipboard paste
⌨️ Using CGEvent-based Command+V
t=032085 sess=qet lvl=INFO cat=transcript evt=insert_result ok=true
📊 [POST-RELEASE E2E] 945ms (finalize=206ms | llm=639ms | paste=0ms) | warm_socket=yes
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
📊 [SESSION] Starting recording session #3
🧪 [A/B] warm_socket=yes
🧊 [WARM-HOLD] Stopped warm hold after 6.9s
t=038217 sess=qet lvl=INFO cat=stream evt=warm_hold state=stop
♻️ [SMART-CACHE] Using cached context: 1088 characters
🔥 [NER-CACHE] Triggering NER callback with cached content (1088 chars)
✅ [NER-CACHE] NER callback triggered with cached content
⚡ [CACHE-HIT] Retrieved temp key in 33.8ms
t=038251 sess=qet lvl=INFO cat=stream evt=ws_reuse config_changed=false reuse=true
🔥 [PREWARM DEBUG] Pre-warming AI connection (target: Gemini), environment: flyio
🎤 Registering audio tap for Soniox
t=038253 sess=qet lvl=INFO cat=audio evt=record_start service=Soniox
🔍 Performing audio system pre-flight checks
throwing -10877
throwing -10877
✅ Pre-flight checks passed
t=038339 sess=qet lvl=INFO cat=audio evt=tap_install ok=true service=Soniox backend=avcapture
t=038339 sess=qet lvl=INFO cat=audio evt=record_start reason=start_capture
t=038339 sess=qet lvl=INFO cat=audio evt=device_pin_start desired_uid_hash=281703378278776476 prev_name="MacBook Pro Microphone" prev_id=181 prev_uid_hash=281703378278776476 desired_id=181 desired_name="MacBook Pro Microphone"
t=038339 sess=qet lvl=INFO cat=audio evt=capture_backend_selected backend=avcapture
✅ Unified audio capture started
✅ Selected account account-bundle (connections: 1/10)
👂 [LISTENER] Restarting listener on reused socketId=sock_2909900799192198704@attempt_1 attemptId=1
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
🧠 [TEN-VAD] Initialized (threshold=0.5, hop=256)
🚀 Starting Clio streaming transcription
t=038402 sess=qet lvl=INFO cat=audio evt=avcapture_start ok=true
🎬 [NER-PREWARM] Using raw OCR text for NER: 1088 characters
🧠 [NER-DEFAULT] Using default NER prompt for general extraction
✅ [AUDIO HEALTH] First audio data received - tap is functional
🏥 [AUDIO HEALTH] Health monitoring timer started
⏱️ [TIMING] mic_engaged @ 1756090804.356
⏱️ [TIMING] WebSocket connect task completed — will flush after READY
pass
CMIO_Unit_Converter_Audio.cpp:590:RebuildAudioConverter AudioConverterSetProperty(dbca) failed (1886547824)
🗣️ [TEN-VAD] Speech start detected
🌐 [ASR BREAKDOWN] Total: 890ms | Client↔Proxy: 98ms | Proxy↔Soniox: 792ms | Network: 792ms
🗑️ Evicted oldest temp key to maintain cache size limit
💾 Cached temp key for languages: ["zh", "en"]
🗓️ [TTL-SCHEDULE] Scheduling temp key refresh for key=global in 3000s (expiresAt=2025-08-25 04:00:04 +0000)
✅ [PREFETCH] Successfully prefetched temp key
🎤 [WARMUP] Pre-warming audio system...
✅ [PREWARM] Device enumeration completed
✅ [PREWARM] Audio system pre-warming completed successfully
✅ [WARMUP] Audio system pre-warmed successfully
🧭 [APP] applicationDidBecomeActive
🧭 [APP] ActivationPolicy=.regular (IsMenuBarOnly=false)
🌐 [PATH] Initial path baseline set — no action
🔄 [SYNC_STATE] syncTrialState called - currentTier: pro, isInTrial: false
🔄 [SYNC_STATE] Final state after syncTrialState - currentTier: pro, isInTrial: false
🤖 [FLY.IO-NER] Server-reported provider: gemini
📥 [NER-STORE] Stored NER entities: 80 chars - **People:**
* Kentaro

**Organizations:**
* iCloud

**Products:**
* Clio los App...
✅ [FLY.IO] NER refresh completed successfully
throwing -10877
throwing -10877
throwing -10877
throwing -10877
🛑 Stopping recording
🛑 Stopping Clio streaming transcription
🏥 [AUDIO HEALTH] Health monitoring timer stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
🛑 Stopping unified audio capture
t=047254 sess=qet lvl=INFO cat=audio evt=record_stop
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key plugInPackage
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key CMIOType
CMIO_Graph_Helpers_Analytics.mm:36:sendAnalytics Missing key numberOfDevices
t=047262 sess=qet lvl=INFO cat=audio evt=avcapture_stop
✅ Unified audio capture stopped
⏳ [STRICT-END] Waiting for <end> (max=2000ms)
📤 [FALLBACK] Sent manual finalize (no <end> within 2000ms)
⚡ Audio capture already stopped
🔌 Unregistering audio tap for Soniox
⚠️ No tap registered for Soniox
📉 Released connection for account account-bundle (connections: 0)
💾 [COLD-START] Updated successful streaming timestamp
💾 [COLD-START] Updated successful streaming timestamp
✅ Streaming stopped. Final transcript (0 chars, 12.2s, with audio file): ""
t=050640 sess=qet lvl=INFO cat=transcript evt=final text=
t=050640 sess=qet lvl=INFO cat=transcript evt=session_end divider="────────── session end ──────────"
🌡️ [WARM] warm_socket=yes
🧊 [WARM-HOLD] Started warm hold: 60s timer active, idle keepalives active
t=050640 sess=qet lvl=INFO cat=stream evt=warm_hold state=start
⚠️ No text received from streaming transcription
📱 Dismissing recorder
🧹 Connection cleanup completed (session resources released)

