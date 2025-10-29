# Bug Report: NER Prewarm returns 502 and causes Fly.io process restart

## User Information
- Date: 2025-08-15
- Time: ~11:52–11:57 UTC
- Platform: macOS
- App Version: Clio/1420 (from User-Agent in Fly logs)
- User Type: Pro
- User ID (if available): kentaro@resonantai.co.site

## Issue Summary
NER pre-warm requests intermittently fail with HTTP 502. Fly.io logs show the backend process crashes due to an unhandled ReferenceError (FLEX_TIMEOUT_MS is not defined) in the timeout/abort path of the proxy handler. The crash forces a machine restart, which surfaces to the client as a 502 and creates nondeterministic behavior.

## Detailed Description
### Symptoms
- ✅ LLM post-processing via proxy works and returns 200.
- ✅ NER prewarm succeeds for smaller OCR payloads (e.g., 865 chars) within ~1.1s.
- ❌ NER prewarm fails with status 502 on larger OCR payloads (e.g., 2490 chars), coinciding with Fly process crash/restart.
- ⚠️ Network instability warnings present (abnormally slow WebSocket in a separate path, 11.3s connect), but not the primary cause of the 502.

### User Quotes
> i have been getting this issue now, many times in a row -  Pre-warming status 502 for NER why is this? This needs to be a 100% success, can not be nondeterministic but seems like a blackbox to me now…

> I'm not sure if it's app-specific error or a random issue that happens across all app. no idea.

### Steps to Reproduce
1. Start a recording (Right ⌘) with OCR capture enabled.
2. Ensure a large on-screen text (≈2.5k chars) so OCR produces a long payload.
3. NER prewarm triggers with the OCR text (e.g., 2490 characters).
4. Observe client logs: "Pre-warming got status 502".
5. Check Fly logs: llmProxy throws ReferenceError after AbortError; process exits code 1; machine restarts.

### Expected Behavior
- NER prewarm returns 200 and caches entities, regardless of payload size.
- On upstream timeouts, server returns a controlled 504 with a JSON error, without crashing.

### Actual Behavior
- For larger payloads, the server hits a timeout/abort path and then crashes with ReferenceError: FLEX_TIMEOUT_MS is not defined, resulting in 502 to client and Fly machine restart.

## Priority Level
- 🔴 HIGH — Core enhancement (NER prewarm) is flaky, backend process crash observed (but no user data loss).

## Environment Details
- OS Version: macOS (Darwin/24.6.0 from User-Agent)
- Hardware: MacBook Pro Microphone detected as input
- Permissions Granted: Microphone, Screen Recording, Accessibility (all true)
- Network: Online; separate warning of potential VPN/latency issues (WS connect 11.3s) not causative for the 502

## Root Cause
- Server-side bug in timeout/abort handling for the LLM/NER proxy route: FLEX_TIMEOUT_MS is referenced but not defined, so when an AbortError occurs (slow upstream or large payload), the handler throws ReferenceError, crashes Node (exit code 1), and Fly restarts the machine. Client sees 502.

## Evidence
- Client success case (865 chars): "FLY.IO-NER Pre-warming completed in 1080ms … ✅ [FLY.IO] NER refresh completed successfully."
- Client failure case (2490 chars): "⚠️ [FLY.IO] Pre-warming got status 502".
- Fly logs around failure:
  - "❌ [FLY-LLM] Proxy error: DOMException [AbortError]: This operation was aborted"
  - "ReferenceError: FLEX_TIMEOUT_MS is not defined at llmProxy (src/routes/llm.js:145:49)"
  - "INFO Main child exited normally with code: 1" followed by machine restart.

## Decision: Switch NER prewarm to Gemini (server-side)
- Provider change: Make Gemini the primary provider for NER prewarm on the Fly backend. Keep Groq as optional fallback if desired.
- Timeouts: Do not apply an explicit server-side timeout for the Gemini NER path (per product decision). Allow the request to complete naturally; log duration for observability.
- Request shape: Reuse current OCR text payload. Prefer concise prompt and structured JSON extraction for minimal latency.
- Configuration: Support provider override via request (e.g., provider=gemini) but set server default to Gemini.
- Client behavior: Client continues to prewarm via the server; cap OCR payload (recommended 1–1.5k chars) and retain short 5xx retries, but Gemini path is expected to succeed without retries in most cases.
- Security/telemetry: Keeping the call on server preserves key security, caching, and logging.

## Potential Causes
- Undefined constant: FLEX_TIMEOUT_MS not declared before use in response path.
- Tight timeout for heavy NER prompts leading to frequent AbortError on larger payloads.
- Missing NER fallback chain (only GROQ path), making timeout fatal for prewarm.
- Larger OCR payloads increase upstream latency and the chance to hit timeout.
- Occasional cold start behavior on Fly (but secondary to the crash).

## Developer Notes
- Define distinct timeout knobs: FLEX_TIMEOUT_MS (post-processing) vs NER_TIMEOUT_MS (prewarm, longer).
- Always guard header writes: if (!res.headersSent) res.setHeader(...).
- Catch AbortError and return HTTP 504 with Retry-After; avoid throwing after sending headers.
- Consider chunking/capping OCR payload client-side (1–1.5k chars) for prewarm requests to improve success rate.
- Add X-Request-ID from client; log provider, payload size, timeout used, and fallback provider chosen.
- Runtime: Upgrade to Node 20+ (supabase-js deprecation warning on Node 18 is present in logs).
- Fly: Ensure at least one warm instance to reduce cold start spikes if applicable.

## Follow-up Actions
- [ ] Server: Make Gemini the default NER provider (Gemini 1.5 Flash recommended). Add provider override support (provider=gemini|groq).
- [ ] Server: Remove explicit timeout for Gemini NER path. Keep robust error handling; never crash. For non-Gemini paths, still handle AbortError gracefully and return 504.
- [ ] Server: Fix FLEX_TIMEOUT_MS undefined error in proxy handler; guard header writes with !res.headersSent.
- [ ] Server: Optional fallback — if Gemini fails, optionally fallback to Groq; short-circuit on first success.
- [ ] Client: Keep prewarm via server; optionally cap/trim OCR payload to ~1–1.5k chars and keep brief 5xx retries with jitter; fail-open to cached entities.
- [ ] Observability: Log provider, payload size, and total duration for Gemini NER; include X-Request-ID and surface Fly request id on error.
- [ ] Infra: Consider Node 20 upgrade and keep 1 VM warm on Fly to reduce cold starts.
- [ ] Create fix PR and add regression tests for timeout/abort paths and provider selection.

## Status
- [x] Reported
- [x] Investigating
- [x] In Progress
- [x] Testing Fix
- [x] Resolved
- [x] Closed

---

## Correlation with long client↔proxy latency (LLM step)
- Observed: When prewarm returns 502, subsequent LLM call shows long Client↔Proxy times (e.g., 2.3–3.1s) even when Groq processing is modest.
- Likely: Failed prewarm means connection pooling/TLS reuse did not occur; LLM request pays cold handshake and path warmup.
- Action:
  - [ ] Treat prewarm failure as a hint to immediately issue a tiny HEAD/OPTIONS to the LLM proxy to force pool warmup (non-blocking) before sending the full LLM request.
  - [ ] After Gemini prewarm migration, re-measure Client↔Proxy; target < 400ms on warm path.

---

## Appendix A — Client Log Excerpts

```
[Client] Selected excerpts showing success (865 chars) and failure (2490 chars), including "Pre-warming got status 502".

🎹 Custom modifier shortcut triggered: Right ⌘
…
🔥 [NER-PREWARM] Triggering NER pre-warming with OCR text (865 chars)
…
🛩️ [FLY.IO-NER] Pre-warming completed in 1080ms - NER entities extracted: …
✅ [FLY.IO] NER refresh completed successfully
…
🔥 [NER-PREWARM] Triggering NER pre-warming with OCR text (2490 chars)
…
⚠️ [FLY.IO] Pre-warming got status 502
```

## Appendix B — Fly.io Logs Around Failures

```
2025-08-15T11:53:39Z app[5683970eae6308] sin [info]🌐 [FLY-LLM] Model: meta-llama/llama-4-scout-17b-16e-instruct, Text length: 2490 chars
2025-08-15T11:53:40Z app[5683970eae6308] sin [info]❌ [FLY-LLM] Proxy error: DOMException [AbortError]: This operation was aborted
…
ReferenceError: FLEX_TIMEOUT_MS is not defined
    at llmProxy (file:///app/src/routes/llm.js:145:49)
…
INFO Main child exited normally with code: 1
… (machine restarts)

2025-08-15T11:56:37Z app[5683970eae6308] sin [info]🌐 [FLY-LLM] Model: meta-llama/llama-4-scout-17b-16e-instruct, Text length: 3742 chars
2025-08-15T11:56:38Z app[5683970eae6308] sin [info]❌ [FLY-LLM] Proxy error: DOMException [AbortError]: This operation was aborted
…
ReferenceError: FLEX_TIMEOUT_MS is not defined
    at llmProxy (file:///app/src/routes/llm.js:145:49)
…
INFO Main child exited normally with code: 1
```

---

i have been getting this issue now, many times in a row -  Pre-warming status 502 for NER why is this? This needs to be a 100% success, can not be nondeterministic but seems like a blackbox to me now… i dont have any logs to show me whats going on. is it app specific?

I'm not sure if it's app-specific error or a random issue that happens across all app. no idea.


🎹 Custom modifier shortcut triggered: Right ⌘
🎤 [UI] handleToggleMiniRecorder called
🎤 [UI] toggleNotchRecorder called isRecording=false
🔊 [SoundManager] Attempting to play start sound @ 1755258725.444
🔊 [SoundManager] NSSound start sound result: true
⏱️ [TIMING] start_sound_played @ 1755258725.496
📱 Showing DynamicNotch recorder (MIT licensed)
🔍 [DYNAMIC NOTCH DEBUG] Showing notch...
🔍 [DYNAMIC NOTCH DEBUG] Using screen under mouse (preserving mouse-following)
🔍 [DYNAMIC NOTCH SIZE] Using built-in screen notch size: (185.0, 32.0)
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
🎙️ Starting recording sequence...
🎙️ [TOGGLERECORD DEBUG] Starting recording session tracking...
📝 [GRACE] Recording session started with 2552 words remaining
🎙️ [TOGGLERECORD DEBUG] ===============================================
🔧 [NER-SETUP] Setting up callback - contextService exists: true
✅ [NER-SETUP] OCR completion callback configured for NER pre-warming - callback exists: true
🎙️ [RECORD PERMISSION DEBUG] Permission granted: true
🎙️ [RECORD PERMISSION DEBUG] Thread: <_NSMainThread: 0x600003cc4240>{number = 1, name = main}
🎙️ [RECORD PERMISSION DEBUG] Time since app launch: 0.00s
🔄 [AUTH_REFRESH] Session still valid for 5 minutes
🎙️ [ASYNC TASK DEBUG] Starting async recording task...
🎙️ [ASYNC TASK DEBUG] Task thread: <_NSMainThread: 0x600003cc4240>{number = 1, name = main}
🎙️ [ASYNC TASK DEBUG] Re-evaluating model for language settings...
🎙️ [ASYNC TASK DEBUG] Model type: soniox-realtime-streaming, isStreaming: true
🎙️ [SONIOX DEBUG] Starting Soniox streaming transcription...
🎙️ [SONIOX DEBUG] Calling wakeAudioSystemIfNeeded()...
🎙️ [SONIOX DEBUG] Calling sonioxStreamingService.startStreaming()...
📊 [SESSION] Starting recording session #10
✅ Selected account account-bundle (connections: 1/10)
🎬 [CAPTURE DEBUG] Starting smart screen context capture
🔍 [CALLBACK DEBUG] onOCRCompleted callback exists: true
🎯 ScreenCapture detected frontmost app: WeChat (com.tencent.xinWeChat)
🎯 Found matching window: Weixin (WeChat) - layer:0, pid:66681
🎯 ScreenCapture found window: Weixin (WeChat) - matches PowerMode detection
🔄 [CACHE] Context changed - invalidating cache
🔄 [CACHE]   Old: com.apple.dt.Xcode|Clio — DynamicNotchWindowManager.swift
🔄 [CACHE]   New: com.tencent.xinWeChat|Weixin
🔄 [CACHE]   BundleID Match: false
🔄 [CACHE]   Title Match: false
🔄 [CACHE]   Content Hash: Old=4da0d1a1... New=4da0d1a1...
🎬 Starting screen capture with verified permissions
🚀 Starting Clio streaming transcription
🎯 ScreenCapture detected frontmost app: WeChat (com.tencent.xinWeChat)
🎯 Found matching window: Weixin (WeChat) - layer:0, pid:66681
🎯 ScreenCapture found window: Weixin (WeChat) - matches PowerMode detection
🎯 Found window: Weixin (WeChat)
🎯 ScreenCapture detected frontmost app: WeChat (com.tencent.xinWeChat)
🔊 Setting up audio engine...
🎯 Found matching window: Weixin (WeChat) - layer:0, pid:66681
🎯 ScreenCapture found window: Weixin (WeChat) - matches PowerMode detection
🖼️ Attempting window-specific capture for: Weixin (ID: 1804)
✅ Successfully captured window: 2682.000000x1618.000000
🌐 [LANG DEBUG] Multi-language setting exists: true, Single language: en
🌐 [LANG DEBUG] Using multi-language selection (prioritized): zh, en
🌐 [OCR DEBUG] Selected languages from settings: en, zh
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
⏱️ [TIMING] mic_engaged @ 1755258725.973
pass
⚡ [CACHE-HIT] Retrieved temp key in 25.1ms
⏱️ [TIMING] Temp key obtained in 25.1ms
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🔊 [SONIOX DEBUG] Full config: enable_endpoint_detection=true, model=stt-rt-preview-v2, language_hints=Optional(["zh", "en"])
nw_path_necp_check_for_updates Failed to copy updated result (22)
🔍 [DYNAMIC NOTCH DEBUG] Showed notch in compact mode
✅ [AUDIO HEALTH] First audio data received - tap is functional
🔍 Found 76 text observations
✅ Text extraction successful: 807 chars, 807 non-whitespace, 114 words from 76 observations
✅ Captured text successfully
✅ [CAPTURE DEBUG] Screen capture successful: 865 characters
🎯 ScreenCapture detected frontmost app: WeChat (com.tencent.xinWeChat)
🎯 Found matching window: Weixin (WeChat) - layer:0, pid:66681
🎯 ScreenCapture found window: Weixin (WeChat) - matches PowerMode detection
💾 [SMART-CACHE] Cached new context: com.tencent.xinWeChat|Weixin (865 chars)
🎯 [CALLBACK DEBUG] Executing callback with fresh content (865 chars)
🔥 [NER-TRIGGER] OCR completion callback triggered with fresh content
🔥 [NER-PREWARM] Triggering NER pre-warming with OCR text (865 chars)
🔥 [PREWARM DEBUG] prewarmConnection() called - isEnhancementEnabled: true, isConfigured: true
🔥 [PREWARM DEBUG] connectionState: ready
🔥 [PREWARM DEBUG] Pre-warming AI connection for GROQ, environment: flyio
🛩️ [FLY.IO PREWARM] Starting Fly.io NER pre-warming (forced refresh)
🛩️ [FLY.IO-NER] sendFlyioWarmingRequest() called - starting NER processing
🎬 [NER-PREWARM] Using raw OCR text for NER: 865 characters
🛩️ [FLY.IO-NER] OCR text retrieved for NER processing: 865 characters
🧠 [NER-DEFAULT] Using default NER prompt for general extraction
📥 [NER-STORE] Stored NER entities: 401 chars - Here is the list of extracted entities:

**People:**

* 小猫宝宝
* Jetson
* Leo
* 林秀雅
* 黄叔
* 卡卡

**Organ...
🛩️ [FLY.IO-NER] Pre-warming completed in 1080ms - NER entities extracted: Here is the list of extracted entities:

**People:**

* 小猫宝宝
* Jetson
* Leo
* 林秀雅
* 黄叔
* 卡卡

**Organ...
✅ [FLY.IO] NER refresh completed successfully
🔌 WebSocket did open
🔌 WebSocket ready after 1608ms - buffered 0.0s of audio
⏹️ Keepalive timer stopped
🔄 Keepalive timer started (interval: 15.000000s)
🔑 Successfully connected to Soniox using temp key (25ms key latency)
📱 Dismissing recorder
🛑 Stopping Clio streaming transcription
🏥 [AUDIO HEALTH] Health monitoring timer stopped
✅ [TAP CLEANUP] Successfully removed tap during stop
⏹️ Keepalive timer stopped
⚠️ WebSocket did close with code 1001
⚠️ WebSocket connect failed (attempt 1). Retrying in 500ms…
🔄 [RECOVERY] Attempting mid-recording recovery
⏹️ Keepalive timer stopped
✅ [AUDIO HEALTH] First audio data received - tap is functional
📉 Released connection for account account-bundle (connections: 0)
💾 [COLD-START] Updated successful streaming timestamp
✅ Streaming stopped. Final transcript (30 chars, 6.7s, without audio file): "嗯, 是他们的代客, 就是这个这个, 不是很像你们的货品吗?"
🔍 [DYNAMIC NOTCH DEBUG] Hiding notch...
🔊 [SoundManager] Attempting to play esc sound (with fade)
🔍 [DYNAMIC NOTCH DEBUG] Hidden notch
⚡ [CACHE-HIT] Retrieved temp key in 0.2ms
⏱️ [TIMING] Temp key obtained in 0.6ms
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🔊 [SONIOX DEBUG] Full config: enable_endpoint_detection=true, model=stt-rt-preview-v2, language_hints=Optional(["en", "zh"])


===
🎹 Custom modifier shortcut triggered: Right ⌘
🎤 [UI] handleToggleMiniRecorder called
🎤 [UI] toggleNotchRecorder called isRecording=false
🔊 [SoundManager] Attempting to play start sound @ 1755258817.722
🔊 [SoundManager] NSSound start sound result: true
⏱️ [TIMING] start_sound_played @ 1755258817.779
📱 Showing DynamicNotch recorder (MIT licensed)
🔍 [DYNAMIC NOTCH DEBUG] Showing notch...
🔍 [DYNAMIC NOTCH DEBUG] Using screen under mouse (preserving mouse-following)
🔍 [DYNAMIC NOTCH SIZE] Using built-in screen notch size: (185.0, 32.0)
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
🎙️ Starting recording sequence...
🎙️ [TOGGLERECORD DEBUG] Starting recording session tracking...
📝 [GRACE] Recording session started with 2552 words remaining
🎙️ [TOGGLERECORD DEBUG] ===============================================
🔧 [NER-SETUP] Setting up callback - contextService exists: true
✅ [NER-SETUP] OCR completion callback configured for NER pre-warming - callback exists: true
🎙️ [RECORD PERMISSION DEBUG] Permission granted: true
🎙️ [RECORD PERMISSION DEBUG] Thread: <_NSMainThread: 0x600003cc4240>{number = 1, name = main}
🎙️ [RECORD PERMISSION DEBUG] Time since app launch: 0.00s
🔄 [AUTH_REFRESH] Session expires in 4 minutes - refreshing...
🎙️ [ASYNC TASK DEBUG] Starting async recording task...
🎙️ [ASYNC TASK DEBUG] Task thread: <_NSMainThread: 0x600003cc4240>{number = 1, name = main}
🎙️ [ASYNC TASK DEBUG] Re-evaluating model for language settings...
🎙️ [ASYNC TASK DEBUG] Model type: soniox-realtime-streaming, isStreaming: true
🎙️ [SONIOX DEBUG] Starting Soniox streaming transcription...
🎙️ [SONIOX DEBUG] Calling wakeAudioSystemIfNeeded()...
🎙️ [SONIOX DEBUG] Calling sonioxStreamingService.startStreaming()...
📊 [SESSION] Starting recording session #11
✅ Selected account account-bundle (connections: 1/10)
🎬 [CAPTURE DEBUG] Starting smart screen context capture
🔍 [CALLBACK DEBUG] onOCRCompleted callback exists: true
🎯 ScreenCapture detected frontmost app: Xcode (com.apple.dt.Xcode)
🎯 Found matching window: Clio — DynamicNotchWindowManager.swift (Xcode) - layer:0, pid:623
🎯 ScreenCapture found window: Clio — DynamicNotchWindowManager.swift (Xcode) - matches PowerMode detection
🔄 [CACHE] Context changed - invalidating cache
🔄 [CACHE]   Old: com.tencent.xinWeChat|Weixin
🔄 [CACHE]   New: com.apple.dt.Xcode|Clio — DynamicNotchWindowManager.swift
🔄 [CACHE]   BundleID Match: false
🔄 [CACHE]   Title Match: false
🔄 [CACHE]   Content Hash: Old=358a8ad4... New=358a8ad4...
🎬 Starting screen capture with verified permissions
🚀 Starting Clio streaming transcription
🎯 ScreenCapture detected frontmost app: Xcode (com.apple.dt.Xcode)
🎯 Found matching window: Clio — DynamicNotchWindowManager.swift (Xcode) - layer:0, pid:623
🎯 ScreenCapture found window: Clio — DynamicNotchWindowManager.swift (Xcode) - matches PowerMode detection
🎯 Found window: Clio — DynamicNotchWindowManager.swift (Xcode)
🎯 ScreenCapture detected frontmost app: Xcode (com.apple.dt.Xcode)
🔊 Setting up audio engine...
🎯 Found matching window: Clio — DynamicNotchWindowManager.swift (Xcode) - layer:0, pid:623
🎯 ScreenCapture found window: Clio — DynamicNotchWindowManager.swift (Xcode) - matches PowerMode detection
🖼️ Attempting window-specific capture for: Clio — DynamicNotchWindowManager.swift (ID: 268)
✅ Successfully captured window: 3456.000000x2038.000000
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
⏱️ [TIMING] mic_engaged @ 1755258818.257
pass
🔍 [DYNAMIC NOTCH DEBUG] Showed notch in compact mode
⚡ [CACHE-HIT] Retrieved temp key in 24.8ms
⏱️ [TIMING] Temp key obtained in 24.9ms
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🔊 [SONIOX DEBUG] Full config: enable_endpoint_detection=true, model=stt-rt-preview-v2, language_hints=Optional(["en", "zh"])
✅ [AUDIO HEALTH] First audio data received - tap is functional
nw_connection_copy_connected_local_endpoint_block_invoke [C39] Client called nw_connection_copy_connected_local_endpoint on unconnected nw_connection
nw_connection_copy_connected_remote_endpoint_block_invoke [C39] Client called nw_connection_copy_connected_remote_endpoint on unconnected nw_connection
nw_connection_copy_protocol_metadata_internal_block_invoke [C39] Client called nw_connection_copy_protocol_metadata_internal on unconnected nw_connection
🔍 Found 160 text observations
✅ Text extraction successful: 2401 chars, 2401 non-whitespace, 326 words from 160 observations
✅ Captured text successfully
✅ [CAPTURE DEBUG] Screen capture successful: 2490 characters
🎯 ScreenCapture detected frontmost app: Xcode (com.apple.dt.Xcode)
🎯 Found matching window: Clio — DynamicNotchWindowManager.swift (Xcode) - layer:0, pid:623
🎯 ScreenCapture found window: Clio — DynamicNotchWindowManager.swift (Xcode) - matches PowerMode detection
💾 [SMART-CACHE] Cached new context: com.apple.dt.Xcode|Clio — DynamicNotchWindowManager.swift (2490 chars)
🎯 [CALLBACK DEBUG] Executing callback with fresh content (2490 chars)
🔥 [NER-TRIGGER] OCR completion callback triggered with fresh content
🔥 [NER-PREWARM] Triggering NER pre-warming with OCR text (2490 chars)
🔥 [PREWARM DEBUG] prewarmConnection() called - isEnhancementEnabled: true, isConfigured: true
🔥 [PREWARM DEBUG] connectionState: ready
🔥 [PREWARM DEBUG] Pre-warming AI connection for GROQ, environment: flyio
🛩️ [FLY.IO PREWARM] Starting Fly.io NER pre-warming (forced refresh)
🛩️ [FLY.IO-NER] sendFlyioWarmingRequest() called - starting NER processing
🎬 [NER-PREWARM] Using raw OCR text for NER: 2490 characters
🛩️ [FLY.IO-NER] OCR text retrieved for NER processing: 2490 characters
🧠 [NER-DEFAULT] Using default NER prompt for general extraction
✅ [AUTH] Session refreshed
✅ [AUTH_REFRESH] Session refreshed successfully
🔌 WebSocket did open
🔌 WebSocket ready after 1577ms - buffered 0.0s of audio
⏹️ Keepalive timer stopped
🔄 Keepalive timer started (interval: 15.000000s)
🔑 Successfully connected to Soniox using temp key (25ms key latency)
🔍 [USER] Raw trial_ends_at from Supabase: '2025-07-29T13:36:32Z'
🔍 [USER] Parsed trial_ends_at: 2025-07-29 13:36:32 +0000
🔍 [USER] Parsed subscription_status: 'active' → active
🔍 [USER] Parsed subscription_plan: 'pro' → pro
✅ [AUTH] User authenticated: kentaro@resonantai.co.site
✅ [AUTH] User authenticated: kentaro@resonantai.co.site
🔍 [UPDATE_STATE] === updateSubscriptionState() called ===
🔍 [UPDATE_STATE] Current state before update - currentTier: pro, isInTrial: false
🔍 [UPDATE_STATE] 1. Polar canUseApp: false
🔍 [UPDATE_STATE] 1b. Polar shouldUsePolarTrial: false
🔍 [UPDATE_STATE] 2. Supabase session: kentaro@resonantai.co.site
🚨 [DEBUG] Will use TIER 2: Supabase Subscription System
🚨 [DEBUG] Supabase user: kentaro@resonantai.co.site
🚨 [DEBUG] User subscription status: active
🚨 [DEBUG] User subscription plan: pro
🚨 [CRITICAL DEBUG] [TIER 1] Checking Polar license status...
🚨 [CRITICAL DEBUG] License State: trialExpired
🚨 [CRITICAL DEBUG] Can Use App: false
🚨 [CRITICAL DEBUG] Should Use Polar Trial: false
🚨 [CRITICAL DEBUG] SKIPPING POLAR TIER 1 - shouldUsePolarTrial is false
🚨 [CRITICAL DEBUG] This allows Supabase Pro subscription to be checked!
🚨 [CRITICAL DEBUG] About to check Tier 2 condition...
🚨 [CRITICAL DEBUG] supabaseService.currentSession: NOT NIL
🚨 [CRITICAL DEBUG] supabaseService.currentUser: NOT NIL
🚨 [CRITICAL] ENTERED TIER 2 LOGIC!
🔍 [SUBSCRIPTION] [TIER 2] Checking Supabase subscription...
🔍 [SUBSCRIPTION] User email: kentaro@resonantai.co.site
🔍 [SUBSCRIPTION] Raw subscription status: 'active'
🔍 [SUBSCRIPTION] Raw subscription plan: 'pro'
🔍 [SUBSCRIPTION] Status == .active: true
🔍 [SUBSCRIPTION] Plan != nil: true
🔍 [SUBSCRIPTION] Trial ends at: 2025-07-29 13:36:32 +0000
🔍 [SUBSCRIPTION] Subscription expires at: 2025-08-30 15:20:52 +0000
🚨 [DEBUG] Checking subscription condition:
🚨 [DEBUG] user.subscriptionStatus == .active: true
🚨 [DEBUG] user.subscriptionPlan != nil: true
🚨 [DEBUG] Combined condition: true
🚨 [CRITICAL] ABOUT TO CHECK THE MAIN SUBSCRIPTION CONDITION!
🚨 [CRITICAL DEBUG] Checking subscription condition:
🚨 [CRITICAL DEBUG] user.subscriptionStatus: active
🚨 [CRITICAL DEBUG] user.subscriptionStatus.rawValue: 'active'
🚨 [CRITICAL DEBUG] user.subscriptionStatus == .active: true
🚨 [CRITICAL DEBUG] user.subscriptionPlan: Optional(Clio.SubscriptionPlan.pro)
🚨 [CRITICAL DEBUG] user.subscriptionPlan != nil: true
🚨 [CRITICAL DEBUG] Combined condition result: true
✅ [SUBSCRIPTION] [TIER 2] Using Supabase Pro by expiry - pro tier until 2025-08-30 15:20:52 +0000
🔄 [SYNC_STATE] syncTrialState called - currentTier: pro, isInTrial: false
🔄 [SYNC_STATE] Final state after syncTrialState - currentTier: pro, isInTrial: false
⚠️ [FLY.IO] Pre-warming got status 502
⚠️ [FLY.IO] NER refresh failed: The operation couldn't be completed. (Clio.EnhancementError error 9.)
nw_connection_copy_connected_local_endpoint_block_invoke [C42] Client called nw_connection_copy_connected_local_endpoint on unconnected nw_connection
nw_connection_copy_connected_remote_endpoint_block_invoke [C42] Client called nw_connection_copy_connected_remote_endpoint on unconnected nw_connection
nw_connection_copy_protocol_metadata_internal_block_invoke [C42] Client called nw_connection_copy_protocol_metadata_internal on unconnected nw_connection
✅ Successfully updated user stats in Supabase
🔄 Stats synced successfully (FORCED)
📊 193325 words, 1467.2 minutes
🎹 Custom modifier shortcut triggered: Right ⌘
🎤 [UI] handleToggleMiniRecorder called
🎤 [UI] toggleNotchRecorder called isRecording=true
🛑 Stopping recording
🛑 Stopping Clio streaming transcription
🏥 [AUDIO HEALTH] Health monitoring timer stopped
✅ [TAP CLEANUP] Successfully removed tap during stop
📤 Sent end-of-stream signal
✅ [AUDIO HEALTH] First audio data received - tap is functional
📤 Sent manual finalize command
🕐 Using finalization timeout: 2000ms (connection took 8074ms)
🏁 Received <fin> token - finalization complete
✅ Received <fin> token after 369ms
⏹️ Keepalive timer stopped
⚠️ WebSocket did close with code 1001
🔄 [RECOVERY] Attempting mid-recording recovery
⏹️ Keepalive timer stopped
⚠️ WebSocket connect failed (attempt 1). Retrying in 500ms…
📉 Released connection for account account-bundle (connections: 0)
💾 [COLD-START] Updated successful streaming timestamp
✅ Streaming stopped. Final transcript (39 chars, 8.4s, with audio file): "帮我出去找一半的戒指。 加一个额金。 30再加一个这个。 加那个就是新币是什么"
✅ Streaming transcription completed successfully, length: 39 characters
⏱️ [TIMING] Subscription tracking: 0.2ms
⏱️ [TIMING] ASR word tracking: 0.0ms
🧠 Performing intelligent end-context detection for streaming
⏱️ [CONTEXT DETAIL] Cache check: 0.0ms
⚡ [SMART-OPTIMIZATION] Using smart cached screen context (2490 chars) - skipping new capture
⏱️ [STREAMING CONTEXT TIMING] Screen capture + context detection: 0.0ms
🎯 Starting dynamic context-aware AI enhancement with tracking for text (39 characters)
⚡ [FAST-PATH] Using pre-warmed context - skipping redundant detection
⚡ [PREWARMED] Using pre-warmed NER context for Code Review enhancement
🌐 [LANG DEBUG] Multi-language setting exists: true, Single language: en
🌐 [LANG DEBUG] Using multi-language selection (prioritized): zh, en
🔍 [NER-DEBUG] getNERContextData called - nerEntities exists: true, connectionState: ready
✅ [NER-CONTEXT] Using NER entities from pre-warming (401 chars)
🔍 [NER-CONTENT] NER entities preview: Here is the list of extracted entities:

**People:**

* 小猫宝宝
* Jetson
* Leo
* 林秀雅
* 黄叔
* 卡卡

**Organizations:**

* WeChat
* 世纪储能
* Founder Park
* Amagi
* ShareAl
* BFA
* 橘子汽水铺
* 36氪Pro
* 投资界
* 海外独角兽
*...
💻 Sending to AI provider with pre-warmed code context
💻 [PREWARMED-SYSTEM] Code system prompt: 'You are an expert at enhancing the text provided within <TRANSCRIPT> tags according to the following guidelines for developers. The information in <CO...'
💻 [PREWARMED-USER] Code user prompt: '
<DICTIONARY_TERMS>
Groq, Clio
</DICTIONARY_TERMS>

<CONTEXT_INFORMATION>
NER Context Entities:
Here is the list of extracted entities:

**People:**

...'
🛰️ Sending to AI provider via proxy: GROQ
System Message: You are an expert at enhancing the text provided within <TRANSCRIPT> tags according to the following guidelines for developers. The information in <CONTEXT_INFORMATION> section is ONLY for reference.

### INSTRUCTIONS:
1. Aggressively remove all filler words, guess words, stutters and repetitions in all languages, such as: 嗯, 呃, 啊, 那个, 就是, 然后, 怎么说, 就是说, 那什么, 额, 呢, 吧, 哎, um, uh, like, you know, so, well, I mean, kind of, sort of, basically, literally, right, alright
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
    Input: "connection persistence test py"
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
Here is the list of extracted entities:

**People:**

* 小猫宝宝
* Jetson
* Leo
* 林秀雅
* 黄叔
* 卡卡

**Organizations:**

* WeChat
* 世纪储能
* Founder Park
* Amagi
* ShareAl
* BFA
* 橘子汽水铺
* 36氪Pro
* 投资界
* 海外独角兽
* OpenAI
* Perplexity

**Product/ Project Names:**

* ChatGPT
* GPT-5
* ScreenCoder
* RTE Dev 
* Orange Al 
* IBC 

**Other:**

* BET 
* Officia Accounts 
* Service Accounts 
* Voice Agent 
* AI 
* AIGC
</CONTEXT_INFORMATION>

DICTIONARY USAGE:
Fix ASR errors using <DICTIONARY_TERMS>: phonetic matches, partial matches, common errors (e.g., "clod code" → "Claude Code")

CONTEXT USAGE:
<CONTEXT_INFORMATION> provides technical terms for accuracy. Prioritize context spellings over transcript. Clean transcript only - don't respond to it.

Process the following transcript:

<TRANSCRIPT>
帮我出去找一半的戒指。 加一个额金。 30再加一个这个。 加那个就是新币是什么
</TRANSCRIPT>
🌐 [CUSTOM-PROMPT] Attempting Groq via proxy...
🔑 [DEBUG] Getting JWT token...
🔑 [DEBUG] JWT token obtained in 0ms
📝 [TIMING] Request preparation: 0.1ms
🌐 [DEBUG] Sending request to proxy...
⚡ [CACHE-HIT] Retrieved temp key in 0.2ms
⏱️ [TIMING] Temp key obtained in 0.5ms
🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled
🔊 [SONIOX DEBUG] Full config: enable_endpoint_detection=true, model=stt-rt-preview-v2, language_hints=Optional(["zh", "en"])
🌐 [DEBUG] Proxy response received in 615ms
📊 [DEBUG] HTTP Status: 200
📋 [DEBUG] Response Headers: [AnyHashable("Date"): Fri, 15 Aug 2025 11:53:47 GMT, AnyHashable("Via"): 2 fly.io, AnyHashable("x-powered-by"): Express, AnyHashable("Vary"): Origin, AnyHashable("fly-request-id"): 01K2PS8C11WMHVPGX5GY4CHFAG-sin, AnyHashable("Content-Type"): application/json; charset=utf-8, AnyHashable("Etag"): W/"5b8-Uzm1NGzXv/VISffM6Rx+PcKREi8", AnyHashable("access-control-allow-credentials"): true, AnyHashable("Server"): Fly/90dd1273b (2025-08-14), AnyHashable("Content-Encoding"): br]
✅ [DEBUG] Found enhancedText field
🌐 [LLM] Groq: 157ms | TTFT: 127ms
🌐   Client↔Proxy: 459ms
🔍 [CONNECTION HEALTH]
🌐 [LANG DEBUG] Multi-language setting exists: true, Single language: en
🌐 [LANG DEBUG] Using multi-language selection (prioritized): zh, en
✅ [CUSTOM-PROMPT] Groq via proxy succeeded
📊 [DETAILED STREAMING TIMING] Streaming: 477.3ms | Context: 0.0ms | LLM: 640.2ms | Tracked Overhead: 0.0ms | Unaccounted: 0.6ms | Total: 1118.2ms
🔍 [OVERHEAD BREAKDOWN] Prompt: 0.0ms | ASR Track: 0.0ms | Window Info: 0.0ms | Word Track: 0.0ms | Database: 0.0ms
🔊 [SoundManager] Attempting to play stop sound
🔊 [SoundManager] NSSound stop sound result: true
🔍 [PASTE DEBUG] AXIsProcessTrusted: true, shouldCancelRecording: false, text length: 40
🔍 [PASTE DEBUG] Calling CursorPaster.pasteAtCursor() after 0.05s delay
📱 Dismissing recorder
🔍 [DYNAMIC NOTCH DEBUG] Hiding notch...
🧹 Connection cleanup completed (session resources released)
📝 [GRACE] Recording session ended
📊 [ENHANCEMENT] Tracking 32 words - currentTier: pro, trialWordsRemaining: 2552
🔍 [PASTE DEBUG] About to execute CursorPaster.pasteAtCursor()
🔍 [PASTE DEBUG] CursorPaster.pasteAtCursor() called with text length: 40
🔍 [PASTE DEBUG] AXIsProcessTrusted() returned true, proceeding
🔍 [PASTE DEBUG] UseDirectTextInsertion setting: false
🔍 [PASTE DEBUG] Direct insertion disabled, using clipboard paste
⌨️ Using CGEvent-based Command+V
🔍 [PASTE DEBUG] CursorPaster.pasteAtCursor() completed
🔍 [DYNAMIC NOTCH DEBUG] Hidden notch
✅ Streaming transcription processing completed
🔌 WebSocket did open
🔌 WebSocket ready after 11293ms - buffered 0.0s of audio
⚠️ ABNORMAL DELAY: WebSocket took 11.3s to connect!
⚠️ This may indicate VPN instability or network issues.
⏹️ Keepalive timer stopped
🔄 Keepalive timer started (interval: 15.000000s)
🔑 Successfully connected to Soniox using temp key (0ms key latency)


====
fly log that might help u

Last login: Fri Aug 15 19:04:17 on ttys012

The default interactive shell is now zsh.
To update your account to use zsh, please run `chsh -s /bin/zsh`.
For more details, please visit https://support.apple.com/kb/HT208050.
(base) ZhaobangJetWu (main *) ~
$ fly logs -a clio-backend-fly
2025-08-15T11:52:07Z app[5683970eae6308] sin [info]🌐 [FLY-METRICS] Performance Summary:
2025-08-15T11:52:07Z app[5683970eae6308] sin [info]🌐   Total: 876ms | Network: 179ms (21%) | Groq: 686ms (79%) | Proxy: 0ms (0%)
2025-08-15T11:52:07Z app[5683970eae6308] sin [info]🌐   Groq Breakdown: Queue=275ms | Prompt=25ms | Completion=386ms | TTFT=300ms
2025-08-15T11:52:07Z app[5683970eae6308] sin [info]🌐   Bottleneck: groq_processing | Recommendation: Groq processing dominates - consider model optimization or flex tier alternatives
2025-08-15T11:52:07Z app[5683970eae6308] sin [info]🌐   Connection: 🔄 NEW CONNECTION (handshake ~512ms) | Pattern: cold_start
2025-08-15T11:52:07Z app[5683970eae6308] sin [info]🌐   Region: sin | Client: unknown | Payload: 2KB→1KB
2025-08-15T11:52:07Z app[5683970eae6308] sin [info]{"timestamp":"2025-08-15T11:52:07.461Z","level":"NETWORK_METRICS","total_ms":876,"ttfb_ms":853,"groq_ms":686,"proxy_ms":0,"network_ms":179,"breakdown_percent":{"network_latency":21,"groq_processing":79,"proxy_overhead":0,"download_time":1},"primary_bottleneck":"groq_processing","client_country":"unknown","client_ip":"54.169.43.104, 66.241.125.161","server_region":"sin","request_kb":1.5,"response_kb":1,"groq_queue_ms":275,"groq_prompt_ms":25,"groq_completion_ms":386,"groq_ttft_ms":300,"connection_reused":false,"handshake_cost_estimate":512,"time_since_last_request":1755258726593,"full_diagnostics":{"network":{"groq_connection":{"ttfb":853,"total_time":865,"download_time":12,"connection_reused":false,"time_since_last_request":1755258726593,"estimated_handshake_cost":512},"client":{"ip":"54.169.43.104, 66.241.125.161","country":"unknown","user_agent":"Clio/1420 CFNetwork/3826.600.41 Darwin/24.6.0","connection_type":"unknown"}},"processing":{"proxy_overhead":{"pre_processing":0,"post_processing":0,"total":0,"breakdown":{"auth":0,"validation":0,"json_parsing":0,"response_building":0}},"groq_internal":{"total":686,"queue":275,"prompt":25,"completion":386,"ttft":300}},"efficiency":{"time_breakdown_percent":{"network_latency":21,"groq_processing":79,"proxy_overhead":0,"download_time":1},"insights":{"primary_bottleneck":"groq_processing","optimization_target":"Groq processing dominates - consider model optimization or flex tier alternatives","connection_efficiency":{"likely_reused":false,"handshake_cost_estimate":512,"client_pattern":"cold_start"}}},"infrastructure":{"server_region":"sin","server_instance":"5683970e","timestamp":"2025-08-15T11:52:07.461Z","request_size":1552,"response_size":1014},"totals":{"end_to_end":876,"external_api":865,"proxy_work":0,"groq_processing":686,"network_latency":179},"groq_details":{"queue_time":275,"prompt_time":25,"completion_time":386,"ttft":300},"breakdown":{"network":21,"groq":79,"proxy":0}}}
2025-08-15T11:52:07Z app[5683970eae6308] sin [info]POST /api/llm/proxy - 200 (883ms)
2025-08-15T11:53:39Z app[5683970eae6308] sin [info]🌐 [FLY-LLM] Model: meta-llama/llama-4-scout-17b-16e-instruct, Text length: 2490 chars
2025-08-15T11:53:40Z app[5683970eae6308] sin [info]❌ [FLY-LLM] Proxy error: DOMException [AbortError]: This operation was aborted
2025-08-15T11:53:40Z app[5683970eae6308] sin [info]    at node:internal/deps/undici/undici:12637:11
2025-08-15T11:53:40Z app[5683970eae6308] sin [info]    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)
2025-08-15T11:53:40Z app[5683970eae6308] sin [info]    at async llmProxy (file:///app/src/routes/llm.js:78:26)
2025-08-15T11:53:40Z app[5683970eae6308] sin [info]file:///app/src/routes/llm.js:145
2025-08-15T11:53:40Z app[5683970eae6308] sin [info]      res.setHeader('X-Flex-Timeout-MS', String(FLEX_TIMEOUT_MS));
2025-08-15T11:53:40Z app[5683970eae6308] sin [info]                                                ^
2025-08-15T11:53:40Z app[5683970eae6308] sin [info]ReferenceError: FLEX_TIMEOUT_MS is not defined
2025-08-15T11:53:40Z app[5683970eae6308] sin [info]    at llmProxy (file:///app/src/routes/llm.js:145:49)
2025-08-15T11:53:40Z app[5683970eae6308] sin [info]    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)
2025-08-15T11:53:40Z app[5683970eae6308] sin [info]Node.js v18.20.8
2025-08-15T11:53:40Z proxy[5683970eae6308] sin [error][PU02] could not complete HTTP request to instance: connection closed before message completed
2025-08-15T11:53:40Z app[5683970eae6308] sin [info]npm notice
2025-08-15T11:53:40Z app[5683970eae6308] sin [info]npm notice New major version of npm available! 10.8.2 -> 11.5.2
2025-08-15T11:53:40Z app[5683970eae6308] sin [info]npm notice Changelog: https://github.com/npm/cli/releases/tag/v11.5.2
2025-08-15T11:53:40Z app[5683970eae6308] sin [info]npm notice To update run: npm install -g npm@11.5.2
2025-08-15T11:53:40Z app[5683970eae6308] sin [info]npm notice
2025-08-15T11:53:40Z app[5683970eae6308] sin [info] INFO Main child exited normally with code: 1
2025-08-15T11:53:40Z app[5683970eae6308] sin [info] INFO Starting clean up.
2025-08-15T11:53:40Z app[5683970eae6308] sin [info] WARN could not unmount /rootfs: EINVAL: Invalid argument
2025-08-15T11:53:40Z app[5683970eae6308] sin [info][  100.821975] reboot: Restarting system
2025-08-15T11:53:42Z app[5683970eae6308] sin [info]2025-08-15T11:53:42.872166451 [01K2A5BMF9XXQBYHK379ZN3EVM:main] Running Firecracker v1.12.1
2025-08-15T11:53:42Z app[5683970eae6308] sin [info]2025-08-15T11:53:42.872297002 [01K2A5BMF9XXQBYHK379ZN3EVM:main] Listening on API socket ("/fc.sock").
2025-08-15T11:53:43Z app[5683970eae6308] sin [info] INFO Starting init (commit: 6c3309ba)...
2025-08-15T11:53:43Z app[5683970eae6308] sin [info] INFO Preparing to run: `docker-entrypoint.sh npm start` as nodejs
2025-08-15T11:53:43Z app[5683970eae6308] sin [info] INFO [fly api proxy] listening at /.fly/api
2025-08-15T11:53:43Z runner[5683970eae6308] sin [info]Machine started in 858ms
2025-08-15T11:53:43Z app[5683970eae6308] sin [info]2025/08/15 11:53:43 INFO SSH listening listen_address=[fdaa:25:25c4:a7b:4ff:9914:1cd8:2]:22
2025-08-15T11:53:44Z app[5683970eae6308] sin [info]> clio-flyio-api@1.0.0 start
2025-08-15T11:53:44Z app[5683970eae6308] sin [info]> node src/index.js
2025-08-15T11:53:44Z app[5683970eae6308] sin [info]⚠️  Node.js 18 and below are deprecated and will no longer be supported in future versions of @supabase/supabase-js. Please upgrade to Node.js 20 or later. For more information, visit: https://github.com/orgs/supabase/discussions/37217
2025-08-15T11:53:44Z app[5683970eae6308] sin [info]🚀 Clio Fly.io API Server running on port 3000
2025-08-15T11:53:44Z app[5683970eae6308] sin [info]🌍 Region: sin
2025-08-15T11:53:44Z app[5683970eae6308] sin [info]🔗 Health check: http://localhost:3000/health
2025-08-15T11:53:44Z app[5683970eae6308] sin [info]📡 Ready to receive requests from www.cliovoice.com
2025-08-15T11:53:46Z app[5683970eae6308] sin [info]🌐 [FLY-LLM] Model: qwen/qwen3-32b, Text length: 936 chars
2025-08-15T11:53:47Z app[5683970eae6308] sin [info]🐛 [DEBUG] Timestamps: response_complete=1755258827321, response_built=1755258827321, diff=0
2025-08-15T11:53:47Z app[5683970eae6308] sin [info]🌐 [FLY-METRICS] Performance Summary:
2025-08-15T11:53:47Z app[5683970eae6308] sin [info]🌐   Total: 529ms | Network: 359ms (69%) | Groq: 157ms (30%) | Proxy: 1ms (0%)
2025-08-15T11:53:47Z app[5683970eae6308] sin [info]🌐   Groq Breakdown: Queue=54ms | Prompt=73ms | Completion=30ms | TTFT=127ms
2025-08-15T11:53:47Z app[5683970eae6308] sin [info]🌐   Bottleneck: network | Recommendation: Network latency high - check edge regions or connection pooling
2025-08-15T11:53:47Z app[5683970eae6308] sin [info]🌐   Connection: 🔄 NEW CONNECTION (handshake ~304ms) | Pattern: cold_start
2025-08-15T11:53:47Z app[5683970eae6308] sin [info]🌐   Region: sin | Client: unknown | Payload: 5KB→1KB
2025-08-15T11:53:47Z app[5683970eae6308] sin [info]{"timestamp":"2025-08-15T11:53:47.326Z","level":"NETWORK_METRICS","total_ms":529,"ttfb_ms":507,"groq_ms":157,"proxy_ms":1,"network_ms":359,"breakdown_percent":{"network_latency":69,"groq_processing":30,"proxy_overhead":0,"download_time":2},"primary_bottleneck":"network","client_country":"unknown","client_ip":"54.169.43.104, 66.241.125.161","server_region":"sin","request_kb":5.4,"response_kb":0.6,"groq_queue_ms":54,"groq_prompt_ms":73,"groq_completion_ms":30,"groq_ttft_ms":127,"connection_reused":false,"handshake_cost_estimate":304,"time_since_last_request":1755258826805,"full_diagnostics":{"network":{"groq_connection":{"ttfb":507,"total_time":516,"download_time":9,"connection_reused":false,"time_since_last_request":1755258826805,"estimated_handshake_cost":304},"client":{"ip":"54.169.43.104, 66.241.125.161","country":"unknown","user_agent":"Clio/1420 CFNetwork/3826.600.41 Darwin/24.6.0","connection_type":"unknown"}},"processing":{"proxy_overhead":{"pre_processing":1,"post_processing":0,"total":1,"breakdown":{"auth":0,"validation":1,"json_parsing":0,"response_building":0}},"groq_internal":{"total":157,"queue":54,"prompt":73,"completion":30,"ttft":127}},"efficiency":{"time_breakdown_percent":{"network_latency":69,"groq_processing":30,"proxy_overhead":0,"download_time":2},"insights":{"primary_bottleneck":"network","optimization_target":"Network latency high - check edge regions or connection pooling","connection_efficiency":{"likely_reused":false,"handshake_cost_estimate":304,"client_pattern":"cold_start"}}},"infrastructure":{"server_region":"sin","server_instance":"5683970e","timestamp":"2025-08-15T11:53:47.326Z","request_size":5566,"response_size":580},"totals":{"end_to_end":529,"external_api":516,"proxy_work":1,"groq_processing":157,"network_latency":359},"groq_details":{"queue_time":54,"prompt_time":73,"completion_time":30,"ttft":127},"breakdown":{"network":69,"groq":30,"proxy":0}}}
2025-08-15T11:53:47Z app[5683970eae6308] sin [info]POST /api/llm/proxy - 200 (537ms)
2025-08-15T11:56:37Z app[5683970eae6308] sin [info]🌐 [FLY-LLM] Model: meta-llama/llama-4-scout-17b-16e-instruct, Text length: 3742 chars
2025-08-15T11:56:38Z app[5683970eae6308] sin [info]❌ [FLY-LLM] Proxy error: DOMException [AbortError]: This operation was aborted
2025-08-15T11:56:38Z app[5683970eae6308] sin [info]    at node:internal/deps/undici/undici:12637:11
2025-08-15T11:56:38Z app[5683970eae6308] sin [info]    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)
2025-08-15T11:56:38Z app[5683970eae6308] sin [info]    at async llmProxy (file:///app/src/routes/llm.js:78:26)
2025-08-15T11:56:38Z app[5683970eae6308] sin [info]file:///app/src/routes/llm.js:145
2025-08-15T11:56:38Z app[5683970eae6308] sin [info]      res.setHeader('X-Flex-Timeout-MS', String(FLEX_TIMEOUT_MS));
2025-08-15T11:56:38Z app[5683970eae6308] sin [info]                                                ^
2025-08-15T11:56:38Z app[5683970eae6308] sin [info]ReferenceError: FLEX_TIMEOUT_MS is not defined
2025-08-15T11:56:38Z app[5683970eae6308] sin [info]    at llmProxy (file:///app/src/routes/llm.js:145:49)
2025-08-15T11:56:38Z app[5683970eae6308] sin [info]    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)
2025-08-15T11:56:38Z app[5683970eae6308] sin [info]Node.js v18.20.8
2025-08-15T11:56:38Z proxy[5683970eae6308] sin [error][PU02] could not complete HTTP request to instance: connection closed before message completed
2025-08-15T11:56:38Z app[5683970eae6308] sin [info]npm notice
2025-08-15T11:56:38Z app[5683970eae6308] sin [info]npm notice New major version of npm available! 10.8.2 -> 11.5.2
2025-08-15T11:56:38Z app[5683970eae6308] sin [info]npm notice Changelog: https://github.com/npm/cli/releases/tag/v11.5.2
2025-08-15T11:56:38Z app[5683970eae6308] sin [info]npm notice To update run: npm install -g npm@11.5.2
2025-08-15T11:56:38Z app[5683970eae6308] sin [info]npm notice
2025-08-15T11:56:39Z app[5683970eae6308] sin [info] INFO Main child exited normally with code: 1
2025-08-15T11:56:39Z app[5683970eae6308] sin [info] INFO Starting clean up.
2025-08-15T11:56:39Z app[5683970eae6308] sin [info] WARN could not unmount /rootfs: EINVAL: Invalid argument
2025-08-15T11:56:39Z app[5683970eae6308] sin [info][  176.908910] reboot: Restarting system
2025-08-15T11:56:43Z app[5683970eae6308] sin [info]2025-08-15T11:56:43.356397405 [01K2A5BMF9XXQBYHK379ZN3EVM:main] Running Firecracker v1.12.1
2025-08-15T11:56:43Z app[5683970eae6308] sin [info]2025-08-15T11:56:43.356548407 [01K2A5BMF9XXQBYHK379ZN3EVM:main] Listening on API socket ("/fc.sock").
2025-08-15T11:56:44Z app[5683970eae6308] sin [info] INFO Starting init (commit: 6c3309ba)...
2025-08-15T11:56:44Z app[5683970eae6308] sin [info] INFO Preparing to run: `docker-entrypoint.sh npm start` as nodejs
2025-08-15T11:56:44Z app[5683970eae6308] sin [info] INFO [fly api proxy] listening at /.fly/api
2025-08-15T11:56:44Z runner[5683970eae6308] sin [info]Machine started in 839ms
2025-08-15T11:56:44Z app[5683970eae6308] sin [info]2025/08/15 11:56:44 INFO SSH listening listen_address=[fdaa:25:25c4:a7b:4ff:9914:1cd8:2]:22
2025-08-15T11:56:44Z app[5683970eae6308] sin [info]> clio-flyio-api@1.0.0 start
2025-08-15T11:56:44Z app[5683970eae6308] sin [info]> node src/index.js
2025-08-15T11:56:45Z app[5683970eae6308] sin [info]⚠️  Node.js 18 and below are deprecated and will no longer be supported in future versions of @supabase/supabase-js. Please upgrade to Node.js 20 or later. For more information, visit: https://github.com/orgs/supabase/discussions/37217
2025-08-15T11:56:45Z app[5683970eae6308] sin [info]🚀 Clio Fly.io API Server running on port 3000
2025-08-15T11:56:45Z app[5683970eae6308] sin [info]🌍 Region: sin
2025-08-15T11:56:45Z app[5683970eae6308] sin [info]🔗 Health check: http://localhost:3000/health
2025-08-15T11:56:45Z app[5683970eae6308] sin [info]📡 Ready to receive requests from www.cliovoice.com
2025-08-15T11:56:55Z app[5683970eae6308] sin [info]🌐 [FLY-LLM] Model: qwen/qwen3-32b, Text length: 618 chars
2025-08-15T11:56:55Z app[5683970eae6308] sin [info]🐛 [DEBUG] Timestamps: response_complete=1755259015721, response_built=1755259015721, diff=0
2025-08-15T11:56:55Z app[5683970eae6308] sin [info]🌐 [FLY-METRICS] Performance Summary:
2025-08-15T11:56:55Z app[5683970eae6308] sin [info]🌐   Total: 430ms | Network: 187ms (45%) | Groq: 231ms (55%) | Proxy: 1ms (0%)
2025-08-15T11:56:55Z app[5683970eae6308] sin [info]🌐   Groq Breakdown: Queue=54ms | Prompt=124ms | Completion=53ms | TTFT=178ms
2025-08-15T11:56:55Z app[5683970eae6308] sin [info]🌐   Bottleneck: groq_processing | Recommendation: Balanced performance - consider overall optimization
2025-08-15T11:56:55Z app[5683970eae6308] sin [info]🌐   Connection: 🔄 NEW CONNECTION (handshake ~244ms) | Pattern: cold_start
2025-08-15T11:56:55Z app[5683970eae6308] sin [info]🌐   Region: sin | Client: unknown | Payload: 5KB→1KB
2025-08-15T11:56:55Z app[5683970eae6308] sin [info]{"timestamp":"2025-08-15T11:56:55.722Z","level":"NETWORK_METRICS","total_ms":430,"ttfb_ms":406,"groq_ms":231,"proxy_ms":1,"network_ms":187,"breakdown_percent":{"network_latency":45,"groq_processing":55,"proxy_overhead":0,"download_time":3},"primary_bottleneck":"groq_processing","client_country":"unknown","client_ip":"54.169.43.104, 66.241.125.161","server_region":"sin","request_kb":5.1,"response_kb":0.6,"groq_queue_ms":54,"groq_prompt_ms":124,"groq_completion_ms":53,"groq_ttft_ms":178,"connection_reused":false,"handshake_cost_estimate":244,"time_since_last_request":1755259015303,"full_diagnostics":{"network":{"groq_connection":{"ttfb":406,"total_time":418,"download_time":12,"connection_reused":false,"time_since_last_request":1755259015303,"estimated_handshake_cost":244},"client":{"ip":"54.169.43.104, 66.241.125.161","country":"unknown","user_agent":"Clio/1420 CFNetwork/3826.600.41 Darwin/24.6.0","connection_type":"unknown"}},"processing":{"proxy_overhead":{"pre_processing":1,"post_processing":0,"total":1,"breakdown":{"auth":0,"validation":1,"json_parsing":0,"response_building":0}},"groq_internal":{"total":231,"queue":54,"prompt":124,"completion":53,"ttft":178}},"efficiency":{"time_breakdown_percent":{"network_latency":45,"groq_processing":55,"proxy_overhead":0,"download_time":3},"insights":{"primary_bottleneck":"groq_processing","optimization_target":"Balanced performance - consider overall optimization","connection_efficiency":{"likely_reused":false,"handshake_cost_estimate":244,"client_pattern":"cold_start"}}},"infrastructure":{"server_region":"sin","server_instance":"5683970e","timestamp":"2025-08-15T11:56:55.722Z","request_size":5205,"response_size":652},"totals":{"end_to_end":430,"external_api":418,"proxy_work":1,"groq_processing":231,"network_latency":187},"groq_details":{"queue_time":54,"prompt_time":124,"completion_time":53,"ttft":178},"breakdown":{"network":45,"groq":55,"proxy":0}}}
2025-08-15T11:56:55Z app[5683970eae6308] sin [info]POST /api/llm/proxy - 200 (437ms)

---

## Resolution and Validation (2025-08-15)
- Change: Made Gemini the default provider for NER prewarm; added provider-aware warmup; fixed Groq timeout crash; enabled fallback to Groq when needed.
- Client validation:
  - ✅ NER pre-warming completed in ~717ms (Gemini).
  - ✅ No more 502; Fly VM remains healthy (no restarts).
  - ✅ LLM post-process Client↔Proxy ~209–424ms; Groq ~218ms; total LLM ~454ms (warm path).
- Status: ✅ Resolved (to be Closed after a day of no recurrences).

