Issue #1 - pressed hotkey only once, a quick keydown and keyup, ui notch recorder shows and persists, mic is also on. but wss is not connected (good). 

expected behavior - quick tap and go should just hide the ui recorder and not connected to wss.


client log for proof:

🔄 [SYNC] LicenseSyncService initialized - Full Integration
🛠️ Debug mode - security checks relaxed
🔐 [ENTITLEMENT] Using cached paid entitlement until 2025-08-30 15:20:52 +0000
🔄 [SYNC_STATE] syncTrialState called - currentTier: pro, isInTrial: false
🔄 [SYNC_STATE] Final state after syncTrialState - currentTier: pro, isInTrial: false
📊 [STARTUP] Loaded trial words: 1448/4000, remaining: 2552
AudioCleanup ready
🔄 Found legacy data, starting migration...
   From: /Users/ZhaobangJetWu/Library/Application Support/com.jetsonai.clio
   To: /Users/ZhaobangJetWu/Library/Application Support/com.jetsonai.clio
   ⏭️ Skipping .DS_Store (already exists)
   ⏭️ Skipping Recordings (already exists)
   ⏭️ Skipping default.store (already exists)
   ⏭️ Skipping default.store-wal (already exists)
   ⏭️ Skipping default.store-shm (already exists)
   ⏭️ Skipping WhisperModels (already exists)
🎉 Migration completed successfully!
   Files migrated: 0
   Total size: Zero KB
📝 Legacy data preserved for safety
   You can manually delete it after verifying migration worked correctly
💾 SwiftData storage location: /Users/ZhaobangJetWu/Library/Application Support/com.jetsonai.clio/default.store
✅ [RULE-ENGINE] Successfully loaded configuration with 2 contexts
🚀 [REGISTRY] Initializing default context detectors
✅ [REGISTRY] Registered legacy detector for Email with priority 100
✅ [REGISTRY] Registered legacy detector for Code Review with priority 90
✅ [REGISTRY] Registered legacy detector for Social Media with priority 10
📊 [REGISTRY] Initialization complete with 3 legacy detectors
AddInstanceForFactory: No factory registered for id <CFUUID 0x600003d2f340> F8BB1C28-BAE8-11D6-9C31-00039315CD46
      HALC_ShellObject.mm:615    HALC_ShellObject::SetPropertyData: call to the proxy failed, Error: 1852797029 (nope)
      HALC_ShellObject.mm:615    HALC_ShellObject::SetPropertyData: call to the proxy failed, Error: 1852797029 (nope)
      HALC_ShellObject.mm:615    HALC_ShellObject::SetPropertyData: call to the proxy failed, Error: 1852797029 (nope)
Failed to get fallback device
Successfully added device change listener
Successfully added default input change listener
🔑 TempKeyCache initialized
🔄 Background prefetch timer started
⏹️ System keepalive stopped
🔄 System keepalive started (interval: 15 minutes)
🎹 HotkeyManager initializing at 2025-08-18 00:38:35 +0000
🎹 KeyboardShortcuts library available: toggleMiniRecorder
       LoudnessManager.mm:413   PlatformUtilities::CopyHardwareModelFullName() returns unknown value: Mac16,7, defaulting hw platform key
🔍 [SHORTCUT DEBUG] Library shortcut: F5 (effective: F5)
🔍 [SHORTCUT DEBUG] Custom shortcut: nil
🔍 [SHORTCUT DEBUG] Shortcut configured: true
🎛️ Setting up hands-free shortcut monitor for: Left ⌥
✅ Keyboard shortcut configured: F5
🧭 [APP] applicationDidFinishLaunching
🧭 [APP] ActivationPolicy=.regular (IsMenuBarOnly=false)
🧪 Testing KeyboardShortcuts library...
🧪 Current shortcut from library: F5
🧪 Current shortcut available: F5
🧪 KeyboardShortcuts library test completed
🔧 [HOTKEY SETUP] Setting up shortcut handler at 2025-08-18 00:38:35 +0000
🧹 [HOTKEY SETUP] Cleared existing handlers
🔧 [HOTKEY SETUP] Attempting to activate KeyboardShortcuts system...
🔧 [HOTKEY SETUP] Forced library initialization
🔧 [HOTKEY SETUP] Library activation complete, ready for real handlers...
🎛️ Setting up hands-free shortcut monitor for: Left ⌥
🧭 [APP] applicationDidBecomeActive
🧭 [APP] ActivationPolicy=.regular (IsMenuBarOnly=false)
🧭 [APP] ActivationPolicy=.regular (IsMenuBarOnly=false)
🔐 [ENTITLEMENT] Using cached paid entitlement until 2025-08-30 15:20:52 +0000
🔄 [SYNC_STATE] syncTrialState called - currentTier: pro, isInTrial: false
🔄 [SYNC_STATE] Final state after syncTrialState - currentTier: pro, isInTrial: false
✅ LocalizationManager: Successfully loaded bundle for language: en
Trusting system default input: MacBook Pro Microphone
🔥 [WARMUP] ensureReady() invoked context=appActivation
🔥 [SYSTEM-WARMUP] TempKeyCache warmup integration
🚀 [PREFETCH] Starting background temp key prefetch
✅ [MENUBAR] MenuBarView appeared
🔄 [AUTH_REFRESH] Manually triggering authentication refresh...
🔄 [AUTH_REFRESH] No session to refresh
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
✅ [AUTH] Restored session for: kentaro@resonantai.co.site
Error: -checkForUpdatesInBackground called but .sessionInProgress == YES
✅ [AUTH] User authenticated: kentaro@resonantai.co.site
✅ [AUTH] User authenticated: kentaro@resonantai.co.site
🌐 [ASR BREAKDOWN] Total: 1652ms | Client↔Proxy: 885ms | Proxy↔Soniox: 767ms | Network: 767ms
💾 Cached temp key for languages: ["zh", "en"]
🗓️ [TTL-SCHEDULE] Scheduling temp key refresh for key=global in 3000s (expiresAt=2025-08-18 01:38:37 +0000)
🔄 [SYNC_STATE] syncTrialState called - currentTier: pro, isInTrial: false
🔄 [SYNC_STATE] Final state after syncTrialState - currentTier: pro, isInTrial: false
🔄 [SYNC_STATE] syncTrialState called - currentTier: pro, isInTrial: false
🔄 [SYNC_STATE] Final state after syncTrialState - currentTier: pro, isInTrial: false
✅ [PREFETCH] Successfully prefetched temp key
✅ [HOTKEY READY] effective=F5, F5Armed=true
🚀 [GATE SESSION START] ═══ F5 KeyDown Event ═══
🏁 [GATE SESSION END] ═══ F5 KeyUp Event ═══
👆 [GATE] Mis-touch: auto-hide with no finalize
🔍 [DYNAMIC NOTCH DEBUG] Showing notch...
📱 [GATE] Full UI shown (heavy work deferred until promotion)
GenerativeModelsAvailability.Parameters: Initialized with invalid language code: zh-CN. Expected to receive two-letter ISO 639 code. e.g. 'zh' or 'en'. Falling back to: zh
AFIsDeviceGreymatterEligible Missing entitlements for os_eligibility lookup
🧊 [WARMUP] Skipping (recently run) context=recorderUIShown
🔍 [DYNAMIC NOTCH DEBUG] Using screen under mouse (preserving mouse-following)
🔍 [DYNAMIC NOTCH SIZE] Using built-in screen notch size: (185.0, 32.0)
🔍 [DYNAMIC NOTCH DEBUG] Showed notch in compact mode
173351          HALC_ProxyIOContext.cpp:1622  HALC_ProxyIOContext::IOWorkLoop: skipping cycle due to overload
✅ Successfully updated user stats in Supabase
🔄 Stats synced successfully (FORCED)
📊 211388 words, 1618.7 minutes
✅ Successfully updated user stats in Supabase
🔄 Stats synced successfully (FORCED)
📊 211388 words, 1618.7 minutes