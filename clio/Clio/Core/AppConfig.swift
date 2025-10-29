import Foundation

/// Application-wide configuration for debug logging and features
struct RuntimeConfig {
    // MARK: - Debug Logging Controls
    static let isDebugBuild: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()

    /// Master switch for verbose runtime logging. Safe to leave true in Debug; keep false in Release.
    static let enableVerboseLogging: Bool = {
        // Default off; can be overridden by `defaults write com.cliovoice.clio EnableVerboseLogging -bool true`
        if let override = UserDefaults.standard.object(forKey: "EnableVerboseLogging") as? Bool {
            return override
        }
        return false
    }()

    /// One-click kill switch to silence ALL logs in distributed builds (Console.app, stdout, stderr)
    /// - In Debug: defaults to false (can be overridden by UserDefaults key "SilenceAllLogs")
    /// - In Release: defaults to true (can be overridden by UserDefaults key "SilenceAllLogs" if needed)
    static let silenceAllLogsByDefault: Bool = {
        #if DEBUG
        return false
        #else
        return true
        #endif
    }()

    /// Returns whether logging should be fully silenced at runtime
    /// Users can force-override via: `defaults write com.cliovoice.clio SilenceAllLogs -bool true`
    static var shouldSilenceAllLogs: Bool {
        let override = UserDefaults.standard.object(forKey: "SilenceAllLogs") as? Bool
        return override ?? silenceAllLogsByDefault
    }

    /// Cap for any large payloads we might log (context/OCR/etc.)
    static let maxLoggedPayloadChars: Int = 200
    
    /// When true, log the full (untruncated) prompts sent to the LLM (system + user).
    /// Off by default for safety. Enable via:
    ///   defaults write com.cliovoice.clio LogFullPrompt -bool true
    static var logFullPrompt: Bool {
        let override = UserDefaults.standard.object(forKey: "LogFullPrompt") as? Bool
        return override ?? false
    }
    
    /// When true, log full OCR text and full NER system prompt during NER prewarm/debug.
    /// Off by default. Enable via:
    ///   defaults write com.cliovoice.clio LogNERFullInputs -bool true
    /// or defaults write com.jetsonai.clio LogNERFullInputs -bool true (depending on bundle id)
    static var logNERFullInputs: Bool {
        let override = UserDefaults.standard.object(forKey: "LogNERFullInputs") as? Bool
        return override ?? false
    }

    /// Truncate an arbitrary string to a safe preview length.
    static func truncate(_ text: String, limit: Int = maxLoggedPayloadChars) -> String {
        guard text.count > limit else { return text }
        let prefixText = text.prefix(limit)
        return String(prefixText) + "…" // ellipsis indicates truncation
    }

    // MARK: - Audio Capture Backend
    /// Which capture backend to use.
    ///  - 0 = AVAudioEngine
    ///  - 1 = AVCaptureSession (default)
    /// Change at runtime via:
    ///   `defaults write com.cliovoice.clio CaptureBackend -int 0` (to force AVAudioEngine)
    enum CaptureBackend: Int {
        case audioEngine = 0
        case avCaptureSession = 1
    }
    /// Current backend choice (persistent via UserDefaults)
    static var captureBackend: CaptureBackend {
        // Default to AVCaptureSession when no value is stored
        let raw = UserDefaults.standard.object(forKey: "CaptureBackend") as? Int ?? 1
        return CaptureBackend(rawValue: raw) ?? .avCaptureSession
    }

    // Preview preflight and health-probe controls
    /// Skip preflight checks when starting preview capture (notch lightweight show).
    /// Defaults to true. Override via:
    ///   defaults write com.cliovoice.clio SkipPreflightOnPreview -bool false
    static var skipPreflightOnPreview: Bool {
        let override = UserDefaults.standard.object(forKey: "SkipPreflightOnPreview") as? Bool
        return override ?? true
    }

    /// Throttle interval for audio preflight checks (seconds). Within this window, repeated
    /// preflight requests are skipped to keep UI snappy when toggling the recorder frequently.
    /// Defaults to 60 seconds. Override via:
    ///   defaults write com.cliovoice.clio PreflightMinIntervalSeconds -float 60
    static var preflightMinIntervalSeconds: TimeInterval {
        let value = UserDefaults.standard.object(forKey: "PreflightMinIntervalSeconds") as? Double
        return (value ?? 60.0) > 0 ? (value ?? 60.0) : 60.0
    }

    /// Avoid constructing AVAudioEngine during health probes when using the AVCapture backend.
    /// Defaults to true. Override via:
    ///   defaults write com.cliovoice.clio AvoidAVAudioEngineHealthProbe -bool false
    static var avoidAVAudioEngineHealthProbe: Bool {
        let override = UserDefaults.standard.object(forKey: "AvoidAVAudioEngineHealthProbe") as? Bool
        return override ?? true
    }

    // MARK: - Feature Flags
    /// Compatibility Mode: when enabled, we pin system devices and use aggressive recovery.
    /// Default is false (VoiceInk-style: non-intrusive, do not change system defaults).
    /// Toggle via: `defaults write com.cliovoice.clio CompatibilityModeEnabled -bool true`
    static var enableCompatibilityMode: Bool {
        let override = UserDefaults.standard.object(forKey: "CompatibilityModeEnabled") as? Bool
        return override ?? false
    }

    /// Disable AVCaptureSession early soft restart (stopRunning/startRunning at ~350ms) if no buffer.
    /// This restart toggles the mic privacy indicator. Default: true (disabled) to prevent flicker.
    ///   defaults write com.cliovoice.clio DisableAVCaptureSoftRestart -bool false
    static var disableAVCaptureSoftRestart: Bool {
        let override = UserDefaults.standard.object(forKey: "DisableAVCaptureSoftRestart") as? Bool
        return override ?? true
    }

    /// Disable AVCapture→AVAudioEngine hard fallback at ~900ms if no buffers. Default: true (disabled)
    /// so we do not flip backends during early startup on healthy systems.
    ///   defaults write com.cliovoice.clio DisableAVCaptureHardFallback -bool false
    static var disableAVCaptureHardFallback: Bool {
        let override = UserDefaults.standard.object(forKey: "DisableAVCaptureHardFallback") as? Bool
        return override ?? true
    }

    /// Extra tail hold (ms) before stopping AVAudioRecorder to avoid clipping trailing syllables.
    /// Defaults to 220ms. Override via:
    ///   defaults write com.cliovoice.clio RecordingTailHoldMs -int 220
    static var recordingTailHoldMs: Int {
        let value = UserDefaults.standard.object(forKey: "RecordingTailHoldMs") as? Int
        let resolved = value ?? 220
        return resolved > 0 ? resolved : 0
    }
    /// Controls whether the startup audio-capture watchdog (which can restart the mic ~2–3s after start)
    /// is enabled. Defaults to false to avoid mic indicator flicker and possible clipping.
    /// Enable via: `defaults write com.cliovoice.clio EnableStartupAudioCaptureWatchdog -bool true`
    static var enableStartupAudioCaptureWatchdog: Bool {
        let override = UserDefaults.standard.object(forKey: "EnableStartupAudioCaptureWatchdog") as? Bool
        return override ?? false
    }

    /// Developer-only: Force showing onboarding regardless of prior completion or auth state.
    /// Enable via: `defaults write com.cliovoice.clio ForceShowOnboarding -bool true`
    static var forceShowOnboarding: Bool {
        let override = UserDefaults.standard.object(forKey: "ForceShowOnboarding") as? Bool
        return override ?? false
    }

    /// Developer-only: Force showing the post‑update showcase (mini-onboarding) regardless of version.
    /// Enable via: `defaults write com.cliovoice.clio ForceShowUpdates -bool true`
    static var forceShowUpdates: Bool {
        let override = UserDefaults.standard.object(forKey: "ForceShowUpdates") as? Bool
        return override ?? false
    }

    /// Whether to keep the Soniox WebSocket open between sessions (warm socket).
    /// Defaults to false to minimize background resource usage; enable to reduce TTFT between sessions.
    /// Toggle via: `defaults write com.cliovoice.clio KeepWarmSocketBetweenSessions -bool true`
    static var keepWarmSocketBetweenSessions: Bool {
        let override = UserDefaults.standard.object(forKey: "KeepWarmSocketBetweenSessions") as? Bool
        return override ?? false
    }

    /// Enable the per‑utterance standby socket plan for Soniox: pre-connect a fresh socket after each
    /// recording finishes, keep it alive with idle keepalives, and send START at the next key down
    /// before any audio. This avoids START-on-reuse (400) while keeping TTFT low.
    /// Toggle via: `defaults write com.cliovoice.clio EnableStandbySocket -bool true`
    static var enableStandbySocket: Bool {
        let override = UserDefaults.standard.object(forKey: "EnableStandbySocket") as? Bool
        return override ?? true
    }

    /// A/B toggle: disable wakeAudioSystemIfNeeded() before starting capture.
    /// Defaults to true (wake disabled). To re-enable wake behavior, set to false via:
    ///   defaults write com.cliovoice.clio DisableAudioWake -bool false
    static var disableAudioWake: Bool {
        let override = UserDefaults.standard.object(forKey: "DisableAudioWake") as? Bool
        return override ?? true
    }

    /// A/B toggle: disable unified audio health checks during capture (they run every 5s by default).
    /// Defaults to true (health checks disabled). To enable health checks, set to false via:
    ///   defaults write com.cliovoice.clio DisableAudioHealthCheck -bool false
    static var disableAudioHealthCheck: Bool {
        let override = UserDefaults.standard.object(forKey: "DisableAudioHealthCheck") as? Bool
        return override ?? true
    }

    // MARK: - UI Animation Tuning
    /// Reduce expensive UI effects (layered blurs, offscreen composition) for smoother performance on lower headroom machines.
    /// Toggle via: `defaults write com.cliovoice.clio ReducedUIEffects -bool true`
    static var reducedUIEffects: Bool {
        let override = UserDefaults.standard.object(forKey: "ReducedUIEffects") as? Bool
        return override ?? false
    }

    // MARK: - Notch/UI responsiveness tuning
    /// Skip lookup of the frontmost application's icon for the notch trailing view.
    /// This avoids synchronous LaunchServices work on the first frame. Default false.
    ///   defaults write com.cliovoice.clio DisableAppIconLookup -bool true
    static var disableAppIconLookup: Bool {
        let override = UserDefaults.standard.object(forKey: "DisableAppIconLookup") as? Bool
        return override ?? false
    }

    /// Optional delay (ms) before attempting frontmost app icon lookup to let the notch render its first pixels.
    /// Default 350ms.
    ///   defaults write com.cliovoice.clio UIAppIconFetchDelayMs -int 150
    static var appIconFetchDelayMs: Int {
        let value = UserDefaults.standard.object(forKey: "UIAppIconFetchDelayMs") as? Int
        return max(0, min(1000, value ?? 350))
    }

    /// Keep the DynamicNotch window alive between sessions (skip deinit on hide).
    /// Enable via: `defaults write com.cliovoice.clio NotchKeepAliveEnabled -bool true`
    static var notchKeepAliveEnabled: Bool {
        let override = UserDefaults.standard.object(forKey: "NotchKeepAliveEnabled") as? Bool
        return override ?? false
    }

    /// Pre‑initialize the DynamicNotch window at app activation (kept hidden) so the first
    /// hotkey shows immediately without paying window creation/layout cost.
    /// Enable via: `defaults write com.cliovoice.clio NotchPrewarmOnActivation -bool true`
    static var notchPrewarmOnActivation: Bool {
        let override = UserDefaults.standard.object(forKey: "NotchPrewarmOnActivation") as? Bool
        return override ?? false
    }

    /// Notch opening animation duration in milliseconds. Defaults to 600ms; when reduced UI effects are on, defaults to 250ms.
    /// Override via: `defaults write com.cliovoice.clio UINotchOpenDurationMs -int 250`
    static var notchOpenAnimationDurationMs: Int {
        if let override = UserDefaults.standard.object(forKey: "UINotchOpenDurationMs") as? Int {
            // clamp to a reasonable range (allow 0 when InstantNotchOpen is disabled)
            return max(0, min(1000, override))
        }
        return reducedUIEffects ? 250 : 350
    }

    /// Force the notch to open with zero-duration animation for instant first pixels.
    /// Enable via: `defaults write com.cliovoice.clio InstantNotchOpen -bool true`
    static var instantNotchOpenEnabled: Bool {
        let override = UserDefaults.standard.object(forKey: "InstantNotchOpen") as? Bool
        return override ?? false
    }

    /// High FPS for UI animation ticker (frames per second). Default 45. Lower for less main-thread pressure.
    ///   defaults write com.cliovoice.clio UIAnimationFPSHigh -float 45
    static var uiAnimationFPSHigh: Double {
        let value = UserDefaults.standard.object(forKey: "UIAnimationFPSHigh") as? Double
        let fps = (value ?? 45.0)
        return max(10.0, min(60.0, fps))
    }
    /// Low FPS for UI animation ticker (frames per second). Default 30.
    ///   defaults write com.cliovoice.clio UIAnimationFPSLow -float 30
    static var uiAnimationFPSLow: Double {
        let value = UserDefaults.standard.object(forKey: "UIAnimationFPSLow") as? Double
        let fps = (value ?? 30.0)
        return max(10.0, min(60.0, fps))
    }
    /// Disable visualizer bar animations (updates become immediate). Default true.
    ///   defaults write com.cliovoice.clio DisableVisualizerAnimation -bool true
    static var disableVisualizerAnimation: Bool {
        let override = UserDefaults.standard.object(forKey: "DisableVisualizerAnimation") as? Bool
        return override ?? true
    }

    /// Enable running AVCapture sampleBuffer delegate off-main via a lightweight proxy.
    /// This moves CMSampleBuffer -> AVAudioPCMBuffer conversion off the main actor while
    /// preserving delivery semantics. Default true for better responsiveness.
    ///   defaults write com.cliovoice.clio OffMainAVCaptureDelegate -bool true
    static var offMainAVCaptureDelegateEnabled: Bool {
        let override = UserDefaults.standard.object(forKey: "OffMainAVCaptureDelegate") as? Bool
        return override ?? true
    }

    /// Disable warmup at app launch to isolate startup issues
    ///   defaults write com.cliovoice.clio DisableWarmupOnLaunch -bool true
    static var disableWarmupOnLaunch: Bool {
        let override = UserDefaults.standard.object(forKey: "DisableWarmupOnLaunch") as? Bool
        return override ?? false
    }

    /// Enable lightweight mic preview (pre-roll buffering) on key down.
    /// Defaults to true. Turn off to test UI open without preview mic contention.
    ///   defaults write com.cliovoice.clio EnablePreviewCapture -bool false
    static var enablePreviewCapture: Bool {
        let override = UserDefaults.standard.object(forKey: "EnablePreviewCapture") as? Bool
        return override ?? true
    }

    /// Delay (ms) before starting preview capture after showing lightweight UI.
    /// Gives the notch time to render before audio stack initialization hits the main thread.
    /// Defaults: 30ms; when reduced UI effects are on, 120ms. Override via: `defaults write com.cliovoice.clio UIPreviewCaptureDelayMs -int 120`
    static var previewCaptureStartDelayMs: Int {
        if let override = UserDefaults.standard.object(forKey: "UIPreviewCaptureDelayMs") as? Int {
            return max(0, min(1000, override))
        }
        return reducedUIEffects ? 120 : 0
    }

    /// Optional delay (ms) before invoking the heavy startStreaming/toggleRecord path after showing the notch.
    /// Default 0. Set to ~100–150ms to give the notch time to paint before audio stack work begins.
    ///   defaults write com.cliovoice.clio UIStartStreamingDelayMs -int 120
    static var startStreamingDelayMs: Int {
        let value = UserDefaults.standard.object(forKey: "UIStartStreamingDelayMs") as? Int
        return max(0, min(1000, value ?? 0))
    }

    /// Enable preview capture for Mini recorder as well (pre-roll buffering before promotion).
    /// Defaults to true to preserve user expectation of immediate speech after hotkey.
    ///   defaults write com.cliovoice.clio PreviewCaptureForMini -bool false
    static var previewCaptureForMini: Bool {
        let override = UserDefaults.standard.object(forKey: "PreviewCaptureForMini") as? Bool
        return override ?? true
    }

    /// Enable preview capture for Hands-Free mode.
    /// Defaults to true.
    ///   defaults write com.cliovoice.clio PreviewCaptureForHandsFree -bool false
    static var previewCaptureForHandsFree: Bool {
        let override = UserDefaults.standard.object(forKey: "PreviewCaptureForHandsFree") as? Bool
        return override ?? true
    }

    /// Grace period (ms) after promotion before allowing capture restarts.
    /// Prevents momentary stop/start that can make the macOS mic indicator "double flash".
    /// Defaults to 600ms; set smaller to be more aggressive.
    ///   defaults write com.cliovoice.clio CaptureRestartGraceMs -int 600
    static var captureRestartGraceMs: Int {
        if let override = UserDefaults.standard.object(forKey: "CaptureRestartGraceMs") as? Int {
            return max(0, min(3000, override))
        }
        return 600
    }


    /// Idle keepalive interval (seconds) used for a connected standby socket (no START, no audio yet).
    /// Defaults to 10 seconds. Adjust via: `defaults write com.cliovoice.clio StandbyKeepaliveIntervalSeconds -float 10`
    static var standbyKeepaliveIntervalSeconds: TimeInterval {
        let value = UserDefaults.standard.object(forKey: "StandbyKeepaliveIntervalSeconds") as? Double
        return (value ?? 10.0) > 0 ? (value ?? 10.0) : 10.0
    }

    /// Maximum time-to-live for a standby socket (seconds). After this time with no new recording,
    /// the standby connection will be closed. Defaults to 60 seconds.
    /// Adjust via: `defaults write com.cliovoice.clio StandbyTTLSeconds -float 60`
    static var standbyTTLSeconds: TimeInterval {
        let value = UserDefaults.standard.object(forKey: "StandbyTTLSeconds") as? Double
        return (value ?? 60.0) > 0 ? (value ?? 60.0) : 60.0
    }

    /// Optional: delay (in seconds) before the watchdog evaluates conditions.
    /// Defaults to 6.0s when the watchdog is enabled, to reduce early-session interference.
    /// Override via: `defaults write com.cliovoice.clio StartupAudioCaptureWatchdogDelaySeconds -float 6.0`
    static var startupAudioCaptureWatchdogDelaySeconds: TimeInterval {
        let value = UserDefaults.standard.object(forKey: "StartupAudioCaptureWatchdogDelaySeconds") as? Double
        // Only use positive values; otherwise fall back to a safer default
        return (value ?? 6.0) > 0 ? (value ?? 6.0) : 6.0
    }

    /// Speech watchdog timeout in seconds. How long to wait for tokens after detecting speech before triggering recovery.
    /// Defaults to 5.0s. Override via: `defaults write com.cliovoice.clio SpeechWatchdogTimeoutSeconds -float 5.0`
    static var speechWatchdogTimeoutSeconds: TimeInterval {
        let value = UserDefaults.standard.object(forKey: "SpeechWatchdogTimeoutSeconds") as? Double
        return (value ?? 5.0) > 0 ? (value ?? 5.0) : 5.0
    }

    /// Minimum speech bytes required for watchdog to trigger. Defaults to 10,000 bytes (~0.31s at 16kHz mono 16-bit).
    /// Override via: `defaults write com.cliovoice.clio SpeechWatchdogMinBytes -int 10000`
    static var speechWatchdogMinBytes: Int {
        let value = UserDefaults.standard.object(forKey: "SpeechWatchdogMinBytes") as? Int
        return (value ?? 10_000) > 0 ? (value ?? 10_000) : 10_000
    }

    // MARK: - Fast Finalize Settings

    // MARK: - Early Send/Flush Tuning
    /// Soft fallback window (ms) after mic engagement to allow sending/flushing even if speech latch hasn't fired.
    /// Keeps ambient noise limited but avoids starving the first words in PTT. Defaults to 120ms.
    /// Override via: `defaults write com.cliovoice.clio SpeechSendFallbackMs -int 120`
    static var speechSendFallbackMs: Int {
        let v = UserDefaults.standard.object(forKey: "SpeechSendFallbackMs") as? Int
        let val = v ?? 120
        return val > 0 ? val : 120
    }
    /// Enable fast finalize skip to reduce E2E latency from ~500-700ms to ~0-150ms.
    /// Defaults to true for best user experience.
    /// Toggle via: `defaults write com.cliovoice.clio EnableFastFinalizeSkip -bool false`
    static var enableFastFinalizeSkip: Bool {
        let override = UserDefaults.standard.object(forKey: "EnableFastFinalizeSkip") as? Bool
        return override ?? true
    }

    /// Quiet tail window (ms) required before skipping finalize wait.
    /// Defaults to 120ms. Lower = more aggressive, higher = more conservative.
    /// Override via: `defaults write com.cliovoice.clio FastFinalizeTailMs -int 150`
    static var fastFinalizeTailMs: Int {
        let value = UserDefaults.standard.object(forKey: "FastFinalizeTailMs") as? Int
        return (value ?? 120) > 0 ? (value ?? 120) : 120
    }

    /// Guard window (ms) to observe late tokens after fast skip (telemetry only).
    /// Defaults to 500ms. Used to validate skip safety.
    /// Override via: `defaults write com.cliovoice.clio FastFinalizeGuardWindowMs -int 400`
    static var fastFinalizeGuardWindowMs: Int {
        let value = UserDefaults.standard.object(forKey: "FastFinalizeGuardWindowMs") as? Int
        return (value ?? 500) > 0 ? (value ?? 500) : 500
    }

    /// Optional: Unconditional fast finalize when <end> seen and queue is empty.
    /// Defaults to false. Enable via: `defaults write com.cliovoice.clio FastFinalizeUnconditionalEndSkip -bool true`
    static var fastFinalizeUnconditionalEndSkip: Bool {
        let override = UserDefaults.standard.object(forKey: "FastFinalizeUnconditionalEndSkip") as? Bool
        return override ?? false
    }

    /// When using the standby socket plan, cap the post-finalize wait-for-<fin> window to reduce latency.
    /// Defaults to 400ms. Adjust via: `defaults write com.cliovoice.clio FinalizeFinMaxWaitMs -int 400`
    static var finalizeFinMaxWaitMs: Int {
        let upper = UserDefaults.standard.object(forKey: "FinalizeFinMaxWaitMs") as? Int
        let lower = UserDefaults.standard.object(forKey: "finalizeFinMaxWaitMs") as? Int
        let value = upper ?? lower
        let v = value ?? 400
        return v > 0 ? v : 400
    }

    /// Post‑EOS lookup window (soft cap, milliseconds) to wait for a final <end> that arrives after EOS.
    /// Defaults to 200ms. Override via: `defaults write com.cliovoice.clio EndWindowSoftMs -int 200`
    /// For compatibility, also reads lowercase key `endWindowSoftMs`.
    static var endWindowSoftMs: Int {
        let upper = UserDefaults.standard.object(forKey: "EndWindowSoftMs") as? Int
        let lower = UserDefaults.standard.object(forKey: "endWindowSoftMs") as? Int
        let v = upper ?? lower ?? 200
        return v > 0 ? v : 200
    }

    /// Post‑EOS lookup window hard cap (milliseconds). Defaults to 350ms.
    /// Override via: `defaults write com.cliovoice.clio EndWindowHardMs -int 350`
    /// For compatibility, also reads lowercase key `endWindowHardMs`.
    static var endWindowHardMs: Int {
        let upper = UserDefaults.standard.object(forKey: "EndWindowHardMs") as? Int
        let lower = UserDefaults.standard.object(forKey: "endWindowHardMs") as? Int
        let v = upper ?? lower ?? 350
        return v > 0 ? v : 350
    }

    /// When falling back to manual finalize (no <end> within the window), commit only known‑final text
    /// (drop trailing nonfinal fragment) before background finalize completes. Defaults to true.
    /// Toggle via: `defaults write com.cliovoice.clio DropTrailingNonfinalOnFallback -bool true`
    static var dropTrailingNonfinalOnFallback: Bool {
        let override = UserDefaults.standard.object(forKey: "DropTrailingNonfinalOnFallback") as? Bool
        return override ?? true
    }

    /// When enabled, logs a sanitized summary of the START/config we send to Soniox and
    /// repeats it on error responses. Defaults to false to avoid noisy logs.
    /// Toggle via: `defaults write com.cliovoice.clio LogASRStartConfig -bool true`
    static var logASRStartConfig: Bool {
        let override = UserDefaults.standard.object(forKey: "LogASRStartConfig") as? Bool
        return override ?? false
    }

    // MARK: - Audio Route Policy
    /// Prefer using the built-in microphone for input when AirPods (or other Bluetooth) are the current output device.
    /// This avoids A2DP↔HFP route switches, keeping start/cancel tones instant and stereo.
    /// Defaults to true; can be overridden via: `defaults write com.cliovoice.clio PreferBuiltinMicForAirPods -bool false`
    static var preferBuiltinMicForAirPodsOutput: Bool {
        let override = UserDefaults.standard.object(forKey: "PreferBuiltinMicForAirPods") as? Bool
        return override ?? true
    }
}
