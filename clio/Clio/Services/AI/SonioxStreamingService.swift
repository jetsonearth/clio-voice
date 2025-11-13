import Foundation
import AVFoundation
// Timer utilities
import class Foundation.Timer
import CoreAudio
import SwiftUI
import os
import Network

class SonioxStreamingService: NSObject, ObservableObject, URLSessionWebSocketDelegate, URLSessionTaskDelegate {
    @Published var isStreaming = false
    @Published var partialTranscript = ""
    @Published var finalBuffer = ""
    @Published var connectionStatus: ConnectionStatus = .disconnected
    @Published var streamingAudioLevel: Double = 0.0
    @Published var micEngaged: Bool = false
    @Published var isSpeaking: Bool = false
    
    // Instant mic preview (pre‑promotion) support
    internal var previewTapId: AudioTapIdentifier? = nil
    internal var isPreviewActive: Bool = false
    
    // Buffer flush state tracking to prevent race conditions
    private var isFlushingBuffer = false
    
    // Buffering state machine for clearer control flow
    internal enum BufferingState {
        case idle
        case prebuffering
        case flushing
        case live
    }
    internal var bufferingState: BufferingState = .idle
    
    // Expose recording info for transcript creation
    var lastRecordingDuration: TimeInterval { audioFileManager.currentRecordingDuration }
    var lastAudioFileURL: URL? { audioFileManager.currentAudioFileURL }
    
    enum ConnectionStatus {
        case disconnected
        case connecting
        case connected
        case error(String)
    }
    
    private enum ConnectionErrorType {
        case sslError
        case connectionReset
        case authenticationError
        case networkError
        case genericError
    }
    
    internal var webSocket: URLSessionWebSocketTask?
    // Legacy engine fields removed; UnifiedAudioManager owns capture lifecycle
    internal var unifiedTapId: AudioTapIdentifier? = nil
    private var usingUnifiedManager: Bool = true
    internal var urlSession: URLSession?
    
    private let targetSampleRate: Double = 16000
    private let targetChannels: AVAudioChannelCount = 1
    // Serializes all WebSocket sends so packets stay in order
    internal let sendActor = WebSocketSendActor()
    internal let logger = Logger(subsystem: "com.cliovoice.clio", category: "SonioxStreaming")
    internal let warmupManager: ConnectionWarmupManager
    internal let audioProcessor: StreamingAudioProcessor
    internal let networkMonitor: NetworkHealthMonitor
    
    // Network path monitoring for proactive recovery
    private var pathMonitor: NWPathMonitor?
    private let pathMonitorQueue = DispatchQueue(label: "com.cliovoice.clio.pathmonitor")
    private var lastPathStatus: NWPath.Status?
    private var lastInterfaceType: NWInterface.InterfaceType?
    private var pathChangeDebounceWorkItem: DispatchWorkItem?
    private var lastConnectedAt: Date?
    private let pathChangeCooldownSeconds: TimeInterval = 2.0
    // Local guard to throttle path-change initiated recoveries
    private var lastPathRecoveryAt: Date?
    
    // Temporarily mute active keepalives during warm-socket reuse START handshake
    internal var keepaliveMutedUntil: Date? = nil

    // Indicates that the server has sent its final "finished" message
    internal var finishedReceived: Bool = false
    // Indicates that the server has sent the <fin> token after finalization
    internal var finTokenReceived: Bool = false
    // Timestamp when finalization completed (for grace period before reuse)
    private var lastFinalizationTime: Date?
    // Minimum delay before attempting to reuse a socket after finalization
    private let minimumReuseGracePeriod: TimeInterval = 0.5  // 500ms grace period
    // Indicates we've observed an <end> token from endpoint detection
    internal var endTokenSeen: Bool = false
    // Timestamp of the most recent <end> token received (for post‑EOS lookup window)
    internal var endTokenLastSeenAt: Date? = nil
    internal var listenerTask: Task<Void, Never>? = nil
    
    // Warm-hold state (keep socket open between sessions)
    internal var isWarmHoldActive: Bool = false
    internal var warmHoldStartTime: Date? = nil  // Track when warm hold started for 60s timeout
    // Config fingerprint used to decide if reuse is safe (ignores api_key)
    private var lastConfigFingerprint: String? = nil

    // Eligibility tracking for standby preconnect
    private var didEstablishActiveSocketThisSession: Bool = false
    private var didSendAnyAudioThisSession: Bool = false
    
    // WebSocket connection readiness tracking
    // Single-resume gate to bind continuation to a specific connect attempt
    internal var continuationGate = ConnectionGate()
    internal var readinessTimeoutTask: Task<Void, Never>?

    // Prevent concurrent connect attempts and help gate recovery while connecting
    internal var isConnecting: Bool = false
    // Single-flight: coalesce all connect requests into one in-flight Task
    private var inFlightConnect: Task<Void, Error>? = nil
    private enum ConnectSource: String { case start, preconnect, warmHold, pathChange, sendFailure, midRecovery, captureRestart, backgroundRetry }
    // Track connect-attempt start time for accurate handshake timing (incl. standby)
    private var connectAttemptStartAt: Date? = nil

    // Connection attempt/session identifiers for diagnostics
    private var connectionAttemptCounter: Int = 0
    private var currentAttemptId: Int = 0
    internal var currentSocketId: String = ""
    internal var startTextSentForCurrentSocket: Bool = false
    internal var socketAttemptId: Int = 0
    // Guard to tie readiness timeout to a specific connect attempt
    private var readinessGuardId: UInt64 = 0 // legacy guard; gate now handles attempt scoping
    // Pending start/config to send after didOpen
    private var pendingStartConfigString: String?
    // Safety cache of last start/config string for potential re-send
    private var lastStartConfigString: String?
    // Cached last sent config summary (sanitized) for error correlation
    private var lastStartConfigSummary: [String: Any]? = nil

    // Standby socket plan
    internal enum ConnectPurpose { case active, standby }
    internal var connectPurpose: ConnectPurpose = .active
    internal var isStandbySocket: Bool = false
    internal var standbyTTLTask: Task<Void, Never>? = nil
    
    // Recovery coordination to prevent overlapping recoveries
    private var isRecovering: Bool = false
    // Prevent overlapping stops (double key-up or reentrancy during recovery)
    private var isStopping: Bool = false
    private let converterFailureTracker = ConverterFailureTracker()
    private let converterFailureThreshold = 3
    private let converterRecoveryQueue = DispatchQueue(label: "com.cliovoice.clio.converterRecovery")
    private var converterRecoveryInFlight: Bool = false
    private var lastConverterRecoveryAt: Date?
    private var consecutiveTransportFailures: Int = 0
    private var lastTransportFailureAt: Date?
    private var lastTransportResetAt: Date?
    private var isTransportResetting = false
    private let transportFailureWindow: TimeInterval = 8.0
    private let transportResetCooldown: TimeInterval = 2.0

    // Expose a meter for the audio visualizer
    @Published var sonioxMeter = AudioMeter(averagePower: 0, peakPower: 0)
    
    // Device-change handling
    private var deviceChangeObserver: NSObjectProtocol?
    private var deviceChangeDebouncer = Debouncer(delay: 0.5)
    private var isRestartingForDeviceChange: Bool = false
    private var lastCaptureDeviceID: AudioDeviceID = 0
    
    // Transcription buffer management
    internal var transcriptionBuffer = TranscriptionBuffer()
    private var lastFinalTokenTime: Date?
    private let segmentPauseThreshold: TimeInterval = 0.5 // 500ms pause = new segment
    
    // TEN-VAD speech detector (disabled)
    // private var tenVad: TenVADDetector?
    
    // Audio file management
    internal let audioFileManager: AudioFileManager
    private let audioChunkSize = 32000 // 1 second of audio at 16kHz mono (16-bit)
    
    // Vocabulary and dictionary management
    private let vocabularyManager = VocabularyManager()
    weak var contextService: ContextService?
    
    // Audio format constants
    private let sampleRate: Double = 16000
    private let channels: UInt32 = 1
    private let bitDepth: UInt32 = 16
    // Runtime-detected capture format that we will echo back to Soniox
    private var captureSampleRate: Int = 16000
    private var captureChannelCount: Int = 1

    // Buffer for audio captured before WebSocket is fully ready
    internal let prebuffer = PrebufferStore()
    internal var webSocketReady: Bool = false
    internal var firstBufferReceivedAt: Date?
    // Diagnostics: track preview and streaming tap timing to detect gaps
    internal var previewStartedAt: Date? = nil
    private var streamingTapAttachedAt: Date? = nil
    internal var timers = StreamingTimers()
    // Gate warm-up window and probe writer
        
    // Session pinning state (system default input)
    private var pinnedPrevDefaultInput: AudioDeviceID?
    private var pinnedDesiredInput: AudioDeviceID?
    
    // Audio level logs and silence watchdog
    private var lastLevelLogAt: Date? = nil
    internal var silenceBelowThresholdSince: Date? = nil
    private let levelLogInterval: TimeInterval = 2.0
    private let silenceThresholdDb: Double = -50.0
    private let silenceDurationSec: TimeInterval = 3.0
    private var emittedSilenceEventForThisSession = false
    
    // Packet sequence monitoring for debugging out-of-order issues
    private var packetSequence: UInt64 = 0
    private var lastReceivedSequence: UInt64 = 0

    // MARK: - Watchdog v2 (Readiness + TTFT) state
    internal var readinessDidRestartTap = false
    internal var readinessDidReopenWS = false
    internal var uiSubscribers: Int = 0
    internal var firstAudioCapturedFlag: Bool = false
    internal var speechLatched: Bool = false
    internal var audioMsSinceLatch: Int = 0
    internal var firstPartialReceived: Bool = false
    internal var uiPaintedFirstToken: Bool = false
    internal var tMicEngagedAt: Date? = nil
    internal var tWsReadyAt: Date? = nil
    internal var tFirstAudioAt: Date? = nil
    internal var tFirstPartialAt: Date? = nil
    internal var tUiFirstPaintAt: Date? = nil
    internal var ttftPhase: Int = 0
    internal var sloEmittedThisSession: Bool = false
    internal var useNewWatchdogs: Bool = false

    // Noise-floor based speech latch tuning
    internal var noisePrimingStartAt: Date? = nil
    internal var noiseFloorDb: Double = -60.0
    internal var noisePrimed: Bool = false

    /// Reset per-session sequencing state (prebuffer is preserved and flushed after READY)
    private func resetSessionSequencing() {
        packetSequence = 0
        bufferingState = .idle
        prebufferFlushedThisSession = false
    }
    
    // Keepalive management (active streaming)
    internal let keepaliveInterval: TimeInterval = 15.0 // Send every 15 seconds (well under 20s requirement)
    
    
    // System keepalive management (background warm-up)
    private let systemKeepaliveInterval: TimeInterval = 15 * 60 // 15 minutes (reduced to prevent idle issues)
    
    // Audio health monitoring
    internal var lastAudioDataReceivedTime: Date?
    internal var hasReceivedAudioData = false
    private var recordingSessionCount = 0
    private let maxSessionsBeforeReset = 20
    // Timers are managed via StreamingTimers (silentCapture, startupWatchdog, keepalive, systemKeepalive)
    internal var maxAudioLevelSinceStart: Double = 0.0
    internal var hasAnyTokensReceived: Bool = false
    private var didStartupRecoveryAttempt: Bool = false
    private var didStartRetryOccur: Bool = false

    // Observability
    private var firstTokenLogged: Bool = false
    private var firstPartialLoggedFromHotkey: Bool = false
    private var firstFinalLoggedFromHotkey: Bool = false
    private var firstAudioSentLogged: Bool = false
    // Token activity tracking for finalize heuristics
    internal var lastTokenActivityAt: Date?
    
    // Snapshot of last non-empty partial to avoid empty finals when last message clears partials
    internal var lastNonEmptyPartialSnapshot: String = ""
    
    // Track if we have already flushed prebuffer this session (after real speech latch)
    private var prebufferFlushedThisSession: Bool = false
    // Post-finalize guard window to observe any late tokens after a fast skip
    internal var postFinalizeGuardUntil: Date?
    internal var postFinalizeTokensAfterSkipCount: Int = 0
    // Fast finalize configuration (now uses RuntimeConfig)
    internal var fastFinalizeTailMs: Int { RuntimeConfig.fastFinalizeTailMs }
    internal var fastFinalizeGuardWindowMs: Int { RuntimeConfig.fastFinalizeGuardWindowMs }
    internal var enableFastFinalizeSkip: Bool { RuntimeConfig.enableFastFinalizeSkip }
    // Fallback: if speech latch hasn't fired shortly after mic engagement, allow sends anyway
    private var speechSendFallbackMs: Int { RuntimeConfig.speechSendFallbackMs }

    // Speech-gated stall detection (replaces READY+2s watchdog)
    internal var firstSpeechAt: Date? = nil
    internal var bytesSinceFirstSpeech: Int = 0
    internal var speechWatchdogTask: Task<Void, Never>? = nil
    internal var speechTokenDeadlineSeconds: TimeInterval { RuntimeConfig.speechWatchdogTimeoutSeconds }
    internal var minSpeechBytesForWatchdog: Int { RuntimeConfig.speechWatchdogMinBytes }
        private let speechDbThreshold: Double = -42.0 // consider as speech when above this
        internal var speechFramesAboveThreshold: Int = 0
        private let framesRequiredForSpeechStart: Int = 3

        // Promotion diagnostics
        internal var promotionAt: Date? = nil
        internal var bytesSentSincePromotion: Int = 0
        internal var didLogPromotionFirstAudio: Bool = false
        internal var didLogPromotionFirstToken: Bool = false
        internal var nextPromotionBytesMilestone: Int = 10_000

    // Defer capture restart while connecting to avoid being skipped
    internal var pendingCaptureRestart: Bool = false
    // Audio health recovery throttling and thresholds
    private let audioHealthNoBufferTimeoutSeconds: TimeInterval = 5.0
    private var lastHealthRecoveryAt: Date?
    // Fast-cancel flag: when true, stopStreaming skips finalize/waits and file save
    private var fastCancelRequested: Bool = false
    // Listener/logging guards
    internal var isShuttingDown: Bool = false
    private var lastSuccessLoggedAttemptId: Int = -1
    
    // Soniox API configuration
    private let sonioxEndpoint = "wss://stt-rt.soniox.com/transcribe-websocket"
    // PERFORMANCE OPTIMIZATION: TempKey caching to eliminate 200-500ms latency
    private let tempKeyCache = TempKeyCache.shared
    
    private var apiKey: String {
        // SECURITY: No direct API keys allowed in client applications
        // All ASR requests must go through secure proxy server
        // This prevents API key exposure and ensures proper authentication
        return ""
    }
    
    override init() {
        // Initialize recordings directory and audio file manager
        let recordingsDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("com.cliovoice.clio")
            .appendingPathComponent("Recordings")
        
        self.audioFileManager = AudioFileManager(recordingsDirectory: recordingsDirectory)
        // Initialize warmup/keepalive manager
        let warmConfig = ConnectionWarmupManager.Config(
            keepaliveInterval: keepaliveInterval,
            systemKeepaliveInterval: systemKeepaliveInterval,
            coldStartThresholdSeconds: 3600
        )
        self.warmupManager = ConnectionWarmupManager(config: warmConfig, logger: logger)
        self.audioProcessor = StreamingAudioProcessor(
            config: .init(targetSampleRate: targetSampleRate, targetChannels: targetChannels),
            logger: logger
        )
        self.networkMonitor = NetworkHealthMonitor(logger: logger)

        super.init()
        setupURLSession()
        // Initialize UI subscriber count
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            self.uiSubscribers = AnimationTicker.shared.currentSubscriberCount()
        }
        // Observe UI ticker subscriber changes
        NotificationCenter.default.addObserver(forName: .animationTickerChanged, object: nil, queue: .main) { [weak self] note in
            guard let self = self else { return }
            let cnt = (note.userInfo?["subscribers"] as? Int) ?? AnimationTicker.shared.currentSubscriberCount()
            self.uiSubscribers = cnt
            self.trySatisfyReadiness()
        }
        
        // Wire send failure callback for mid-stream recovery
        Task { [weak self] in
            await self?.configureSendActorCallbacks()
        }
        
        // Wire warmup manager callbacks and start background system keepalive
        warmupManager.isStreamingProvider = { [weak self] in self?.isStreaming ?? false }
        warmupManager.onActiveKeepaliveTick = { [weak self] in await self?.sendKeepalive() }
        warmupManager.onColdStartReinitializeURLSession = { [weak self] in
            guard let self = self else { return }
            if self.inFlightConnect == nil && !self.isConnecting {
                self.setupURLSession(isColdStart: true)
            } else {
                self.logger.debug("⏸️ [COLD-START] Skipping URLSession reinit (connect in flight)")
            }
        }
        warmupManager.startSystemKeepalive()

        // Wire network health monitor
        networkMonitor.isStreaming = { [weak self] in self?.isStreaming ?? false }
        networkMonitor.isConnecting = { [weak self] in self?.isConnecting ?? false }
        networkMonitor.getLastConnectedAt = { [weak self] in self?.lastConnectedAt }
        networkMonitor.onPathChangeRecover = { [weak self] in
            guard let self = self else { return }
            // Skip if not actively streaming
            guard self.isStreaming else { return }
            // Skip if a connect or recovery is already in progress
            if self.isConnecting || self.isRecovering {
                self.logger.debug("⏸️ [PATH] Skipping recovery (connecting/recovering)")
                return
            }
            // Throttle rapid consecutive recoveries
            if let last = self.lastPathRecoveryAt, Date().timeIntervalSince(last) < 2.0 {
                self.logger.debug("🌐 [PATH] Recovery within throttle window — ignored")
                return
            }
            self.lastPathRecoveryAt = Date()
            await self.rebuildTransport(reason: "path_change", showBanner: true)
        }
        
        // Listen for app termination to force cleanup
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(forceCleanup),
            name: .forceCleanupAudioResources,
            object: nil
        )

        // Observe device changes to seamlessly restart capture when needed
        deviceChangeObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("AudioDeviceChanged"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self, self.isStreaming else { return }
            // Debounce rapid device/default flips (common with Bluetooth handoff)
            self.deviceChangeDebouncer.schedule { [weak self] in
                Task { [weak self] in
                    guard let self = self, self.isStreaming else { return }
                    if self.isRestartingForDeviceChange { return }
                    self.isRestartingForDeviceChange = true
                    self.logger.notice("🔁 [DEVICE] Device/default changed – refreshing capture path")
                    await self.restartAudioCaptureWithoutClosingWebSocket()
                    self.isRestartingForDeviceChange = false
                }
            }
        }

        // Diagnostics: listen for snapshot requests
        NotificationCenter.default.addObserver(self, selector: #selector(handleDiagnosticsSnapshot), name: .diagnosticsSnapshot, object: nil)
    }
    
    deinit {
        // Remove observers and timers synchronously; avoid spawning async tasks that capture self
        NotificationCenter.default.removeObserver(self)
        timers.cancelAll()
        
        // VAD disabled; nothing to release here
        
        // Tear down socket/session quickly without awaiting
        let ws = webSocket
        webSocket = nil
        ws?.cancel(with: .goingAway, reason: nil)
        urlSession?.invalidateAndCancel()
        
        // Ensure capture engine stops without capturing self
        if let id = unifiedTapId { Task.detached { await UnifiedAudioManager.shared.unregisterAudioTap(identifier: id) } }
        Task.detached { await UnifiedAudioManager.shared.stopCapture() }
    }
    
    
    internal func setupURLSession(isColdStart: Bool = false) {
        let config = URLSessionConfiguration.default
        
        // Adjust timeouts based on cold start status
        if isColdStart {
            // More generous timeouts for cold start scenarios
            config.timeoutIntervalForRequest = 45  // Increased from 30s
            config.timeoutIntervalForResource = 600 // Increased from 300s
            config.httpMaximumConnectionsPerHost = 2
            logger.debug("🔥 [COLD-START] URLSession configured with extended timeouts")
        } else {
            // Standard timeouts for warm scenarios  
            config.timeoutIntervalForRequest = 20  // Reduced from 30s for faster failures
            config.timeoutIntervalForResource = 120 // Reduced from 300s
            config.httpMaximumConnectionsPerHost = 4
        }
        
        // Use self as delegate so we can observe WebSocket open/close events for reliability
        urlSession = URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }
    
    /// Helper to check if we're in connected state
    private func isConnectedStatus() -> Bool {
        switch connectionStatus {
        case .connected:
            return true
        default:
            return false
        }
    }
    
    
    
    /// Perform cold-start warm-up sequence
    private func classifyError(_ error: Error) -> ConnectionErrorType {
        switch networkMonitor.classify(error) {
        case .sslError: return .sslError
        case .connectionReset: return .connectionReset
        case .authenticationError: return .authenticationError
        case .networkError: return .networkError
        case .genericError: return .genericError
        }
    }
    
    // When true, suppresses the next recovery toast (used for benign control errors).
    private var suppressRecoveryToastOnce: Bool = false
    
    private func performMidRecordingRecovery() async {
        // Single-flight guard
        if isRecovering {
            logger.debug("⏳ [RECOVERY] Already in progress — skipping nested request")
            return
        }
        isRecovering = true
        defer { isRecovering = false }
        logger.notice("🔄 [RECOVERY] Attempting mid-recording recovery")
        if !suppressRecoveryToastOnce {
            ToastBanner.shared.show(title: "Reconnecting…", subtitle: "Audio is buffered. Continuing shortly")
        } else {
            suppressRecoveryToastOnce = false
        }
        
        // Preserve interim transcript state (more complete than finalBuffer)
        let savedTranscript = transcriptionBuffer.finalText
        logger.notice("💾 Saved transcript state: \(savedTranscript.count) characters")
        
        // Pause send queue while we recover
        await sendActor.pauseQueue()
        
        // Disconnect socket-only (do not mark shutdown) and brief settle
        await disconnectWebSocket(isRecovery: true)
        try? await Task.sleep(nanoseconds: 300_000_000) // 300ms
        
        // Reconnect and resume queue
        do {
            try await connectShared(source: .midRecovery, maxRetries: 3)
            // Brief stability check
            try? await Task.sleep(nanoseconds: 200_000_000)
            await sendActor.resumeQueue()
            ToastBanner.shared.show(title: "Reconnected", subtitle: "Continuing transcription")
        } catch {
            logger.error("❌ Recovery connect failed: \(error.localizedDescription)")
        }
        
        // Restore transcript continuity (force-complete current segment so UI advances)
        await MainActor.run {
            self.transcriptionBuffer.forceCompleteCurrentSegment()
        }
    }
    
    /// Classify connection errors for targeted handling
    private func classifyConnectionError(_ error: Error) -> ConnectionErrorType {
        return classifyError(error)
    }
    
    /// Attempt to recover from connection failures during recording without losing transcript
    private func attemptMidRecordingRecovery(errorType: ConnectionErrorType) async -> Bool {
        logger.notice("🚨 Starting mid-recording recovery for error type")
        
        // Save current transcript state
        let savedTranscript = transcriptionBuffer.finalText
        logger.notice("💾 Saved transcript state: \(savedTranscript.count) characters")
        
        // Stop current connection cleanly (recovery-aware)
        await disconnectWebSocket(isRecovery: true)
        
        // Handle error-specific recovery
        await handleSpecificError(errorType, attempt: 1)
        
        // Attempt to reconnect
        do {
            try await connectShared(source: .midRecovery, maxRetries: 3)
            
            // Brief stability check
            try await Task.sleep(nanoseconds: 500_000_000) // 500ms
            
            if await MainActor.run(body: { self.isConnectedStatus() }) {
                // Restore transcript state
                await MainActor.run {
                    self.transcriptionBuffer.forceCompleteCurrentSegment()
                    // Note: finalBuffer will be updated through the existing observation
                }
                
                logger.notice("✅ Mid-recording recovery completed successfully")
                return true
            }
        } catch {
            logger.error("❌ Mid-recording recovery failed: \(error.localizedDescription)")
        }
        
        return false
    }
    
    /// Handle specific error types with targeted recovery strategies
    private func handleSpecificError(_ errorType: ConnectionErrorType, attempt: Int) async {
        switch errorType {
        case .sslError:
            // Brief pause to let SSL state reset
            try? await Task.sleep(nanoseconds: 500_000_000) // 500ms
            
        case .authenticationError:
            // Clear any cached credentials
            logger.notice("🔑 Clearing cached credentials for retry")
            
        case .connectionReset:
            // Standard reconnection delay
            let delay = TimeInterval(min(attempt * 2, 10))
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            
        case .networkError:
            // Wait for network to stabilize
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            
        case .genericError:
            // Standard retry delay
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        }
    }
    
    
    
    // MARK: - Audio Engine Recovery (legacy) – now handled by UnifiedAudioManager
    
    private func checkAudioHealth() async {
        guard isStreaming, let lastReceived = lastAudioDataReceivedTime else { return }

        let timeSinceLastAudio = Date().timeIntervalSince(lastReceived)
        if timeSinceLastAudio > audioHealthNoBufferTimeoutSeconds && hasReceivedAudioData {
            // Rate-limit recovery to avoid flapping
            if let last = lastHealthRecoveryAt, Date().timeIntervalSince(last) < 10.0 {
                logger.debug("🩺 [AUDIO HEALTH] Recovery suppressed (cooldown active)")
                return
            }

            logger.error("⚠️ [AUDIO HEALTH] No audio buffers for \(String(format: "%.1f", timeSinceLastAudio))s – attempting tap-only capture restart (WebSocket stays open)")
            let previousRecoveryAt = lastHealthRecoveryAt
            lastHealthRecoveryAt = Date()

            // Prefer non-destructive recovery: restart only the capture path
            await restartAudioCaptureWithoutClosingWebSocket()

            // After restart, reset health markers so we don't immediately retrigger
            hasReceivedAudioData = false
            lastAudioDataReceivedTime = nil

            // Escalation: if we keep going silent, force-switch to built-in microphone
            // Check if we had a prior recovery recently (within 15s)
            if let previous = previousRecoveryAt, Date().timeIntervalSince(previous) < 15.0 {
                logger.warning("🚨 [AUDIO HEALTH] Repeated silence – switching input to built-in mic and restarting capture")
                _ = AudioDeviceManager.shared.forceSwitchToBuiltIn()
                ToastBanner.shared.show(title: "Audio input became unstable", subtitle: "Switched to Built‑in Microphone to recover")
                await restartAudioCaptureWithoutClosingWebSocket()
                hasReceivedAudioData = false
                lastAudioDataReceivedTime = nil
            }
        }
    }
    
    
    // MARK: - Send Actor Wiring
    
    private func configureSendActorCallbacks() async {
        await sendActor.setOnSendFailure { [weak self] errStr in
            guard let self = self else { return }
            self.logger.error("❌ Send path reported failure: \(errStr)")
            Task { [weak self] in
                await self?.recoverFromSendFailure(reason: errStr)
            }
        }
    }
    
    // MARK: - Public API
    
    /// Preconnect Soniox WebSocket before audio starts (no tap/capture)
    /// Safe to call when not streaming. No-ops if already ready or connecting.
//    func prepareForRecording() async {
//        guard !isStreaming else { return }
//        if webSocketReady { return }
//        do {
//            try await connectShared(source: .preconnect, maxRetries: 2)
//        } catch {
//            logger.debug("⚠️ Preconnect failed (non-fatal): \(error.localizedDescription)")
//        }
//    }

    /// Begin full streaming session (promotion): assumes preview may be running and upgrades it
    func startStreaming() async {
        // Increment session count and check if reset needed
        recordingSessionCount += 1
        logger.notice("📊 [SESSION] Starting recording session #\(self.recordingSessionCount)")
        
        // Prevent duplicate starts (e.g., rapid keyDown/keyUp sequences)
        guard !isStreaming else {
            logger.warning("⚠️ Already streaming")
            return
        }

        // Emit explicit backend/compat markers for this session
        let backendStr = (RuntimeConfig.captureBackend == .audioEngine) ? "audio_engine" : "avcapture"
        // StructuredLog.shared.log(cat: .audio, evt: "session_backend", lvl: .info, ["backend": backendStr])
        // StructuredLog.shared.log(cat: .audio, evt: "compat_state", lvl: .info, ["enabled": RuntimeConfig.enableCompatibilityMode])
        
        // A/B marker for warm-socket behavior
        logger.notice("🧪 [A/B] warm_socket=\(RuntimeConfig.keepWarmSocketBetweenSessions ? "yes" : "no")")
        // Track whether we're actually reusing a warm socket this session
        TimingMetrics.shared.wasWarmSocketReused = false  // Reset at start of each session
        
        // If a previous WebSocket is still ready and warm-socket is enabled, decide reuse vs reconnect
        // If standby socket feature is enabled and one is ready, convert it to active now
        if RuntimeConfig.enableStandbySocket, isStandbySocket, webSocket != nil, webSocketReady, !isConnecting {
            logger.notice("🧊➡️🔥 [STANDBY->ACTIVE] Consuming standby socket for new utterance")
            // Stop standby TTL/keepalive
            timers.cancel(.idleKeepalive)
            standbyTTLTask?.cancel(); standbyTTLTask = nil
            isStandbySocket = false
            connectPurpose = .active
            // START handling: if eager START already sent, skip; otherwise send START now
            if startTextSentForCurrentSocket {
                logger.notice("⏭️ [STANDBY->ACTIVE] START already sent on standby (eager) — skipping re-send")
            } else {
                do {
                    let startConfig = try await buildStartConfigStringForReuse()
                    await sendActor.sendStartFirst(startConfig)
                    startTextSentForCurrentSocket = true
                    logger.notice("📤 [START] Sent start/config on former standby socket (now active)")
                } catch {
                    logger.error("❌ [STANDBY] Failed to build START for standby consumption: \(error.localizedDescription)")
                }
            }
            // Before resuming, probe with a keepalive to verify socket health; if it fails, reconnect now
            do {
                try await sendControlText("{\"type\": \"keepalive\"}", expectedAttemptId: socketAttemptId)
                logger.debug("✅ [STANDBY->ACTIVE] Probe keepalive OK — proceeding to resume queue")
            } catch {
                logger.warning("⚠️ [STANDBY->ACTIVE] Probe keepalive failed — reconnecting before sending audio: \(error.localizedDescription)")
                await disconnectWebSocket()
                do {
                    try await connectShared(source: .start, maxRetries: 3)
                    logger.notice("🔁 [STANDBY->ACTIVE] Reconnected fresh active socket after probe failure")
                } catch {
                    logger.error("❌ [STANDBY->ACTIVE] Reconnect failed after probe failure: \(error.localizedDescription)")
                }
            }
            // Promote to active: start active keepalives and resume send queue so audio can flow
            warmupManager.startActiveKeepalive()
            // Record promotion snapshot and reset promotion diagnostics
            self.promotionAt = Date()
            self.bytesSentSincePromotion = 0
            self.didLogPromotionFirstAudio = false
            self.didLogPromotionFirstToken = false
            self.nextPromotionBytesMilestone = 10_000
            let prebufCount = await self.prebuffer.count()
            self.logger.notice("🧪 [PROMO] snapshot attempt=\(self.socketAttemptId) socket=\(self.currentSocketId) start_sent=\(self.startTextSentForCurrentSocket) ws_ready=\(self.webSocketReady) standby=\(self.isStandbySocket) purpose=\(String(describing: self.connectPurpose)) cap_sr=\(self.audioFileManager.captureSampleRate) cap_ch=\(self.audioFileManager.captureChannelCount) prebuf=\(prebufCount) last_fp=\(self.lastConfigFingerprint ?? "nil")")
            do {
                let info = try await self.buildTempKeyInfo()
                let currFp = self.computeConfigFingerprint(info.config)
                self.logger.notice("🧪 [PROMO] config_fp current=\(currFp) last=\(self.lastConfigFingerprint ?? "nil")")
            } catch {
                self.logger.debug("🧪 [PROMO] config_fp build_failed: \(error.localizedDescription)")
            }
            // Immediately flush any prebuffer collected during preview on promotion to avoid losing early speech
            if self.webSocketReady {
                let total = await self.prebuffer.totalBytes()
                if total > 0 {
                    self.logger.notice("📦 [PROMO] Flushing prebuffer on promotion (bytes=\(total))")
                    await self.flushPrebufferNow(totalBufferedBytes: total, bufferDuration: 0)
                }
            }
            await sendActor.resumeQueue()
            // Listener is already running (or will be from finalize); proceed with normal capture setup below
        } else if RuntimeConfig.keepWarmSocketBetweenSessions, webSocket != nil, webSocketReady, !isConnecting {
            // Check if enough time has passed since last finalization (grace period)
            if let lastFinTime = lastFinalizationTime {
                let timeSinceFinalization = Date().timeIntervalSince(lastFinTime) 
                if timeSinceFinalization < minimumReuseGracePeriod {
                    logger.notice("⏳ [REUSE] Too soon after finalization: \(Int(timeSinceFinalization * 1000))ms < \(Int(self.minimumReuseGracePeriod * 1000))ms - closing socket")
                    await disconnectWebSocket()
                    TimingMetrics.shared.wasWarmSocketReused = false
                    // Clear finalization time after rejecting reuse
                    lastFinalizationTime = nil
                    // Continue with normal connection flow
                } else {
                    // Grace period has passed, can attempt reuse
                    if RuntimeConfig.enableVerboseLogging {
                        logger.debug("✅ [REUSE] Grace period satisfied: \(Int(timeSinceFinalization * 1000))ms since finalization")
                    }
                }
            }
            
            // Stop idle warm-hold (if active) as we are starting a new recording
            stopWarmHold()
            
            // Only proceed with reuse check if we still have a ready socket after grace period check
            if webSocket != nil && webSocketReady {
                do {
                    // Build current config fingerprint (ignoring api_key)
                    let info = try await buildTempKeyInfo()
                    let currentFingerprint = computeConfigFingerprint(info.config)
                    if let lastFp = lastConfigFingerprint, lastFp == currentFingerprint {
                        // Config unchanged → reuse the existing session WITHOUT re-sending START
                        if RuntimeConfig.enableVerboseLogging {
                            logger.notice("🔁 [REUSE] ws_reuse=true config_changed=false — reusing existing session (no re-START)")
                        }
                        StructuredLog.shared.log(cat: .stream, evt: "ws_reuse", lvl: .info, ["reuse": true, "config_changed": false])
                        TimingMetrics.shared.wasWarmSocketReused = true
                        // Also set a fallback flag for CursorPaster to read if timing races
                        UserDefaults.standard.set(true, forKey: "LastWarmSocketReused")
                        // Ensure queue is unpaused in case a prior recovery paused it
                        await self.sendActor.resumeQueue()
                        // Make sure gating reflects that START was already sent on this socket
                        if !self.startTextSentForCurrentSocket { self.startTextSentForCurrentSocket = true }
                        // Restart listener on reused socket (previous listener was cancelled at the end of last session)
                        if self.listenerTask == nil, let _ = self.webSocket {
                            self.listenerTask = Task { [weak self] in
                                guard let self = self else { return }
                                self.logger.debug("👂 [LISTENER] Restarting listener on reused socketId=\(self.currentSocketId) attemptId=\(self.socketAttemptId)")
                                await self.listenForMessages()
                            }
                        }
                        if RuntimeConfig.enableVerboseLogging {
                            self.logger.notice("📤 [REUSE] Continuing on warm socket without re-sending START (start_text_sent=\(self.startTextSentForCurrentSocket))")
                        }
                    } else {
                        // Config changed → close and reconnect to apply new settings
                        if RuntimeConfig.enableVerboseLogging {
                            logger.notice("🧩 [REUSE] ws_reuse=false config_changed=true — closing socket to apply new config")
                        }
                        StructuredLog.shared.log(cat: .stream, evt: "ws_reuse", lvl: .info, ["reuse": false, "config_changed": true])
                        await disconnectWebSocket()
                        TimingMetrics.shared.wasWarmSocketReused = false  // New connection needed
                    }
                } catch {
                    logger.error("❌ [REUSE] Failed to compute current config for reuse decision: \(error.localizedDescription)")
                    // Fall back to normal behavior (connect task will ensure connection)
                }
            }
        }
        
        // Start audio capture via UnifiedAudioManager
        do {
            let id = AudioTapIdentifier(serviceName: "Soniox")
            unifiedTapId = id
            try await UnifiedAudioManager.shared.registerAudioTap(
                identifier: id,
                format: nil,
                bufferSize: 1024,
                tapBlock: { [weak self] buffer, _ in
                    guard let self = self else { return }
                    Task { await self.processAudioBuffer(buffer) }
                }
            )
            try await UnifiedAudioManager.shared.startCapture()
            // Record streaming tap attach time and log preview→streaming gap if any
            streamingTapAttachedAt = Date()
            if let t0 = previewStartedAt, let t1 = streamingTapAttachedAt {
                let gapMs = Int(t1.timeIntervalSince(t0) * 1000)
                StructuredLog.shared.log(cat: .audio, evt: "preview_to_streaming_gap", lvl: .info, ["gap_ms": gapMs])
                if RuntimeConfig.enableVerboseLogging {
                    logger.notice("⏱️ [PREVIEW→STREAM] gap_ms=\(gapMs)")
                }
            }
            // If a lightweight preview tap is active, remove it now to avoid duplicate processing
            if let previewId = previewTapId {
                await UnifiedAudioManager.shared.unregisterAudioTap(identifier: previewId)
                previewTapId = nil
                isPreviewActive = false
            }
        } catch {
            logger.error("❌ Failed to start unified audio capture: \(error.localizedDescription)")
        }
        
        // Log current input device details to aid debugging route/format issues
        // do {
        //     let deviceId = AudioDeviceManager.shared.getCurrentDevice()
        //     let deviceName = AudioDeviceManager.shared.getDeviceName(deviceID: deviceId) ?? "unknown"
        //     let device
        //     logger.notice("🎧 [AUDIO INPUT] Using device id=\(deviceId) name=\(deviceName) uid=\(deviceUid)")
        // }
        
        if recordingSessionCount >= maxSessionsBeforeReset {
            logger.warning("🔄 [MAINTENANCE] Reached \(self.maxSessionsBeforeReset) sessions - refreshing unified capture state")
            // With UnifiedAudioManager, a full engine reset is not necessary here.
            recordingSessionCount = 0
        }
        
        // Reset health monitoring + startup watchdog flags
        hasReceivedAudioData = false
        lastAudioDataReceivedTime = nil
        hasAnyTokensReceived = false
        didStartupRecoveryAttempt = false
        maxAudioLevelSinceStart = 0.0
        firstTokenLogged = false
        firstPartialLoggedFromHotkey = false
        firstFinalLoggedFromHotkey = false
        firstAudioSentLogged = false
        
        // Reset standby eligibility flags for this new session
        didEstablishActiveSocketThisSession = false
        didSendAnyAudioThisSession = false
        
        // TEN-VAD disabled: fall back to energy-based detection for speaking state
        // tenVad = TenVADDetector(threshold: 0.5, hop: 256)
        // tenVad?.onSpeechStart = { [weak self] in /* set isSpeaking true */ }
        // tenVad?.onSpeechEnd   = { [weak self] in /* set isSpeaking false */ }
        logger.notice("🚀 Starting Clio streaming transcription")
        // StructuredLog.shared.log(cat: .transcript, evt: "session_start", lvl: .info, ["divider": "────────── session start ──────────"])
        
        // Begin per-session structured log capture window (disabled)
        // let tag = String(format: "%03d", self.recordingSessionCount)
        // StructuredLog.shared.beginSessionCapture(tag: tag)
        
        // Initialize TimingMetrics for this session
        TimingMetrics.shared.resetForNewSession()
        
        
        isShuttingDown = false
        await MainActor.run {
            isStreaming = true
            connectionStatus = .connecting
            transcriptionBuffer.reset()
            partialTranscript = ""
            finalBuffer = ""
            lastFinalTokenTime = nil
            finishedReceived = false
            finTokenReceived = false
            endTokenSeen = false
            // Reset stale markers from prior session
            endTokenLastSeenAt = nil
            lastNonEmptyPartialSnapshot = ""
            micEngaged = false
            firstBufferReceivedAt = nil
            timers.cancel(.firstBufferTapRefresh)
            timers.cancel(.firstBufferEngineRestart)
        }
        // Reset watchdog-v2 session state
        tMicEngagedAt = Date()
        tWsReadyAt = nil
        tFirstAudioAt = nil
        tFirstPartialAt = nil
        tUiFirstPaintAt = nil
        firstAudioCapturedFlag = false
        speechLatched = false
        audioMsSinceLatch = 0
        firstPartialReceived = false
        uiPaintedFirstToken = false
        sloEmittedThisSession = false
        ttftPhase = 0
        readinessDidRestartTap = false
        readinessDidReopenWS = false
        // Capture current UI subscriber count
        await MainActor.run { self.uiSubscribers = AnimationTicker.shared.currentSubscriberCount() }
        // Start readiness watchdog (monotonic via DispatchSourceTimer)
        startReadinessWatchdog()
        
        // Preserve any pre-roll captured during preview; keep buffer intact via actor
        var hadPreviewPreRoll = false
        if bufferingState == .prebuffering {
            hadPreviewPreRoll = !(await prebuffer.isEmpty())
        }
        
        // Reset per-session sequence only; prebuffer is preserved and will be flushed after READY
        resetSessionSequencing()
        
        if hadPreviewPreRoll {
            bufferingState = .prebuffering
        }
        
        // Initialize audio file for saving
        audioFileManager.initializeAudioFile()
        
        // Start path monitoring for proactive recovery
        networkMonitor.start()
        
        // logger.notice("📝 Starting new transcription session")  // Reduced logging verbosity
        
        do {
            // Using UnifiedAudioManager for capture; skip legacy engine setup
            // Schedule first-buffer watchdogs (still useful for early-silence detection)
            await scheduleFirstBufferWatchdogs()
            
            // Start audio health monitoring timer (off-main)
            timers.scheduleRepeating(.silentCapture, every: 1.0) { [weak self] in
                Task { [weak self] in
                    await self?.checkAudioHealth()
                }
            }
            logger.notice("🏥 [AUDIO HEALTH] Health monitoring timer started")

            // Startup watchdog (feature-flagged): optionally restart capture later if BOTH conditions hold.
            if RuntimeConfig.enableStartupAudioCaptureWatchdog {
                timers.cancel(.startupWatchdog)
                timers.scheduleOnce(.startupWatchdog, after: RuntimeConfig.startupAudioCaptureWatchdogDelaySeconds) { [weak self] in
                    Task { [weak self] in
                        guard let self = self, self.isStreaming else { return }
                        let hasAudio = self.hasReceivedAudioData
                        let noTokens = !self.hasAnyTokensReceived
                        let noFirstBuffer = (self.firstBufferReceivedAt == nil)
                        // Case 1: audio is flowing but ASR produced no tokens yet
                        if hasAudio && noTokens && !self.didStartupRecoveryAttempt {
                            self.didStartupRecoveryAttempt = true
                            self.logger.warning("🚑 [STARTUP WATCHDOG] hasAudio=\(hasAudio) noTokens=\(noTokens) – restarting capture")
                            await self.restartAudioCaptureWithoutClosingWebSocket()
                            return
                        }
                        // Case 2: no buffer ever arrived – restart unified capture immediately
                        if noFirstBuffer && !self.didStartupRecoveryAttempt {
                            self.didStartupRecoveryAttempt = true
                            self.logger.warning("🚑 [STARTUP WATCHDOG] No first buffer yet – restarting unified capture")
                            await self.restartAudioCaptureWithoutClosingWebSocket()
                        }
                    }
                }
            }
            
            // Cold-start debugging and warmup in PARALLEL with WebSocket connection
            let isFirstLaunch = warmupManager.isColdStart()
            
            // Connect WebSocket in parallel - audio will buffer until connection is ready
            Task {
                do {
                    // If cold start, do warmup in background WITHOUT blocking WebSocket connection
                    if isFirstLaunch {
                        logger.notice("🆕 [COLD-START] First recording after app launch - applying background warm-up")
                        // Start warmup in background but don't await it
                        Task.detached(priority: .background) { [weak self] in
                            await self?.warmupManager.performColdStartWarmup()
                        }
                    }
                    try await self.connectShared(source: .start, maxRetries: 3)
                    logger.notice("⏱️ [TIMING] WebSocket connect task completed — will flush after READY")
                } catch {
                    logger.error("❌ WebSocket connection failed: \(error.localizedDescription)")
                    await self.stopStreaming()
                }
            }
        } catch {
            logger.error("❌ Failed to start streaming: \(error.localizedDescription)")
            
            // Check if it's an audio format failure that might benefit from recovery
            if let sonioxError = error as? SonioxError,
               sonioxError == .audioFormatSetupFailed {
                logger.warning("🔄 [RECOVERY] Audio format failure detected - attempting recovery")
                // UnifiedAudioManager handles engine lifecycle; recreateAudioEngine no longer needed
                
                // Try unified capture restart after recovery
                await self.restartAudioCaptureWithoutClosingWebSocket()
if await UnifiedAudioManager.shared.isCapturing {
                    logger.notice("✅ [RECOVERY] Successfully recovered after audio engine reset")
                    return // Success after recovery
                } else {
                    logger.error("❌ [RECOVERY] Unified capture restart did not start capturing")
                }
            }
            
            await stopStreaming()
            await MainActor.run {
                connectionStatus = .error(error.localizedDescription)
            }
        }
    }
    
    func stopStreaming() async {
            guard isStreaming else { return }
            if isStopping { return }
            isStopping = true
            defer { isStopping = false }
            let fastCancel = fastCancelRequested
            
            // Mark keyUp timestamp for post-release E2E timing
            if TimingMetrics.shared.keyUpTs == nil { TimingMetrics.shared.keyUpTs = Date() }
            
            logger.notice("🛑 Stopping Clio streaming transcription")
            isShuttingDown = true
            
            // Stop health monitoring timer
            await MainActor.run {
                timers.cancel(.silentCapture)
                logger.debug("🏥 [AUDIO HEALTH] Health monitoring timer stopped")
                timers.cancel(.startupWatchdog)
                timers.cancel(.firstBufferTapRefresh)
                timers.cancel(.firstBufferEngineRestart)
                timers.cancel(.readinessWatchdog)
                timers.cancel(.ttftWatchdog)
            }
            // Cancel any speech watchdog and reset speech markers
            cancelSpeechWatchdog()
            firstSpeechAt = nil
            bytesSinceFirstSpeech = 0
            speechFramesAboveThreshold = 0
            // VAD disabled
            
            // CRITICAL FIX: Wait for WebSocket to be ready before finalizing
            // This prevents losing audio from short recordings when connection is slow
            if !fastCancel && !webSocketReady {
                logger.notice("⏳ WebSocket not ready yet - waiting up to 10 seconds to avoid losing audio")
                let waitStart = Date()
                
                // Wait up to 10 seconds for WebSocket to become ready
                for _ in 0..<100 { // 100 * 100ms = 10 seconds max wait
                    if webSocketReady {
                        let waitTime = Date().timeIntervalSince(waitStart) * 1000
                        logger.notice("✅ WebSocket became ready after \(Int(waitTime))ms - proceeding with finalization")
                        break
                    }
                    try? await Task.sleep(nanoseconds: 100_000_000) // 100ms
                }
                
                if !webSocketReady {
                    let waitTime = Date().timeIntervalSince(waitStart) * 1000
                    logger.warning("⚠️ WebSocket still not ready after \(Int(waitTime))ms - proceeding anyway")
                }
            }
            
            // Stop audio capture to prevent sending more audio
            if let id = unifiedTapId {
                await UnifiedAudioManager.shared.unregisterAudioTap(identifier: id)
            }
            await UnifiedAudioManager.shared.stopCapture()
            
    // THEN: Drain queue, finalize, and wait for final tokens (skip on fast cancel)
        await runFinalizationSequence(fastCancel: fastCancel)
        #if false
            do {
                // Drain-before-finalize to avoid truncation on tail
                let queued = await sendActor.getQueueDepth()
                if queued > 0 {
                    logger.notice("🧺 [DRAIN] Starting drain-before-finalize queued=\(queued)")
                }
                // Conditional tail wait: only when needed
                let ageMs = await sendActor.millisSinceLastSend() ?? 9999
                if queued > 0 {
                    // Keep conservative tail if there are pending frames
                    try? await Task.sleep(nanoseconds: 250_000_000)
                } else if ageMs < 120 {
                    // Recent send: small tail to capture stragglers
                    try? await Task.sleep(nanoseconds: 90_000_000)
                } // else: skip waiting entirely

                // Adaptive drain timeout
                let drainTimeout = queued > 0 ? 600 : 250
                let drained = await sendActor.waitUntilDrained(timeoutMs: drainTimeout)
                if !drained {
                    let remaining = await sendActor.getQueueDepth()
                    logger.warning("⏳ [DRAIN] Timeout waiting for queue to drain — proceeding with EOS (remaining=\(remaining))")
                } else if queued > 0 {
                    logger.notice("✅ [DRAIN] Queue drained before finalize")
                }

                // If any preview/prebuffer audio remains and we are READY, flush it so we don't lose early speech
                if self.webSocketReady {
                    let bytes = await self.prebuffer.totalBytes()
                    if bytes > 0 {
                        self.logger.notice("📦 [STOP] Flushing prebuffer before EOS (bytes=\(bytes))")
                        await self.flushPrebufferNow(totalBufferedBytes: bytes, bufferDuration: 0)
                        // Allow a tiny tail so server can emit tokens
                        try? await Task.sleep(nanoseconds: 120_000_000)
                    }
                }

                // Snapshot quiet window BEFORE sending EOS/control frames to avoid resetting tail checks
                let preQuietMs = await sendActor.millisSinceLastSend() ?? 9999
                
                // Send empty binary frame to signal end of audio
                try await webSocket.send(.data(Data()))
                logger.debug("📤 Sent end-of-stream signal")

                // Post‑EOS decision: if we saw a recent <end> just before EOS and nothing new arrived after it,
                // trust it and skip manual finalize. Otherwise, briefly wait for a post‑EOS <end>.
                let eosAt = Date()
                let softMs = RuntimeConfig.endWindowSoftMs
                let hardMs = RuntimeConfig.endWindowHardMs
                
                let noPendingTokens = self.partialTranscript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                let depthAfterEOS = await sendActor.getQueueDepth()
                let noUnsentAudio = depthAfterEOS == 0
                
                var didSendFinalize = false
                var didQuickDrop = false
                var skippedByPreEosEnd = false
                if let endAt = self.endTokenLastSeenAt, noPendingTokens, noUnsentAudio {
                    let sinceEndMs = Int(eosAt.timeIntervalSince(endAt) * 1000)
                    let noTokensAfterEnd = (self.lastTokenActivityAt == nil) || (self.lastTokenActivityAt! <= endAt)
                    if noTokensAfterEnd {
                        // Accept the most recent <end> observed before EOS regardless of age, provided no final tokens followed it.
                        logger.notice("🏁 Using pre‑EOS <end> (last seen \(sinceEndMs)ms before EOS) — skipping manual finalize")
                        if TimingMetrics.shared.clientFinalizeTs == nil { TimingMetrics.shared.clientFinalizeTs = Date() }
                        self.transcriptionBuffer.checkAndCompleteSegment()
                        // Prefer merged partials if available to avoid empty results
                        if !self.partialTranscript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            let merged = self.normalizedJoin(self.transcriptionBuffer.finalText, self.partialTranscript)
                            self.finalBuffer = merged
                        } else {
                            self.finalBuffer = self.transcriptionBuffer.finalText
                        }
                        skippedByPreEosEnd = true
                    }
                }
                
                if !skippedByPreEosEnd {
                    // Briefly wait for a post‑EOS <end> (soft window, then hard cap)
                    var sawEndAfterStop = false
                    let softDeadline = eosAt.addingTimeInterval(TimeInterval(softMs) / 1000.0)
                    while Date() < softDeadline {
                        if let endAt = self.endTokenLastSeenAt, endAt >= eosAt { sawEndAfterStop = true; break }
                        try? await Task.sleep(nanoseconds: 20_000_000) // 20ms slices
                    }
                    if !sawEndAfterStop {
                        let hardDeadline = eosAt.addingTimeInterval(TimeInterval(hardMs) / 1000.0)
                        while Date() < hardDeadline {
                            if let endAt = self.endTokenLastSeenAt, endAt >= eosAt { sawEndAfterStop = true; break }
                            try? await Task.sleep(nanoseconds: 20_000_000)
                        }
                    }
                    if sawEndAfterStop && noPendingTokens && noUnsentAudio {
                        // Trust endpoint detection for the FINAL end that arrived after EOS.
                        logger.notice("🏁 Received <end> after EOS — skipping manual finalize")
                        if TimingMetrics.shared.clientFinalizeTs == nil { TimingMetrics.shared.clientFinalizeTs = Date() }
                        // Ensure current segment is completed for clean final text.
                        self.transcriptionBuffer.checkAndCompleteSegment()
                        let currentPartial = self.partialTranscript.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !currentPartial.isEmpty {
                            let merged = self.normalizedJoin(self.transcriptionBuffer.finalText, currentPartial)
                            self.finalBuffer = merged
                        } else if !self.lastNonEmptyPartialSnapshot.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && self.hasAnyTokensReceived {
                            let merged = self.normalizedJoin(self.transcriptionBuffer.finalText, self.lastNonEmptyPartialSnapshot)
                            self.finalBuffer = merged
                            self.logger.notice("🛟 [FALLBACK] Using snapshot partial for final (pre‑EOS path)")
                        } else {
                            self.finalBuffer = self.transcriptionBuffer.finalText
                        }
                    } else {
                        // Fallback: no post‑EOS <end> within window → policy: quick‑drop for long, manual finalize for short
                        // Estimate words from final+partial (use final when partial is empty)
                        let baseFinal = self.transcriptionBuffer.finalText
                        let mergedForCount = self.partialTranscript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? baseFinal
                            : self.normalizedJoin(baseFinal, self.partialTranscript)
                        let estimatedWordCount = TextUtils.countWords(in: mergedForCount)
                        // Use live duration from start time (recordingDuration is finalized later)
                        let liveDuration: TimeInterval = self.audioFileManager.currentRecordingStartTime.map { Date().timeIntervalSince($0) } ?? 0
                        let isShort = (liveDuration < 12) || (estimatedWordCount < 20)

                        if isShort {
                            // Short utterance: ask server to finalize (safer for tails)
                            let msSinceLastSend = await sendActor.millisSinceLastSend() ?? 0
                            let trailing = max(50, min(msSinceLastSend, 500))
                            let finalizeCmd = "{\"type\": \"finalize\", \"trailing_silence_ms\": \(trailing)}"
                            let expectedAttempt = socketAttemptId
                            try await sendControlText(finalizeCmd, expectedAttemptId: expectedAttempt)
                            logger.debug("📤 Sent manual finalize command (short utterance policy)")
                            didSendFinalize = true
                        } else {
                            // Long utterance: QUICK‑DROP — finalize locally and do not wait for <fin>
                            if let endAt = self.endTokenLastSeenAt {
                                let ageMs = Int(eosAt.timeIntervalSince(endAt) * 1000)
                                logger.notice("⚡ [QUICK-DROP] No post‑EOS <end> in \(hardMs)ms (last pre‑EOS <end> was \(ageMs)ms before EOS) — committing local final (words=\(estimatedWordCount), dur=\(String(format: "%.1f", liveDuration))s)")
                            } else {
                                logger.notice("⚡ [QUICK-DROP] No post‑EOS <end> in \(hardMs)ms — committing local final (words=\(estimatedWordCount), dur=\(String(format: "%.1f", liveDuration))s)")
                            }
                            if TimingMetrics.shared.clientFinalizeTs == nil { TimingMetrics.shared.clientFinalizeTs = Date() }
                            self.transcriptionBuffer.forceCompleteCurrentSegment()
                            if !self.partialTranscript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                let merged = self.normalizedJoin(self.transcriptionBuffer.finalText, self.partialTranscript)
                                self.finalBuffer = merged
                            } else {
                                self.finalBuffer = self.transcriptionBuffer.finalText
                            }
                            didQuickDrop = true
                        }
                    }
                }

                if didSendFinalize {
                    // Heuristic: for short utterances (low duration or few words), strictly wait for <fin>
                    // to avoid truncation. Estimate words from final+partial (use final when partial empty).
                    let wordsForWaitEstimate: Int = {
                        let baseFinal = self.transcriptionBuffer.finalText
                        let source = self.partialTranscript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? baseFinal : self.normalizedJoin(baseFinal, self.partialTranscript)
                        return TextUtils.countWords(in: source)
                    }()
                    let liveDuration2: TimeInterval = self.audioFileManager.currentRecordingStartTime.map { Date().timeIntervalSince($0) } ?? 0
                    let strictFinalizeShortUtterance = (liveDuration2 < 12) || (wordsForWaitEstimate < 20)

                    // Adaptive timeout based on connection delay
                    // If WebSocket took long to connect, Soniox server is also cold-starting
                    let connectionDelay = audioFileManager.currentRecordingStartTime.map { Date().timeIntervalSince($0) * 1000 } ?? 0
                    // Keep base latency small; at most ~2.0s even on slow connect
                    var baseTimeout = connectionDelay > 3000 ? 40 : 30 // 40*50ms≈2.0s, 30*50ms≈1.5s
                    // Always bound fin wait to a small window (defaults to FinalizeFinMaxWaitMs)
                    // regardless of short/long to keep post-release finalize bounded.
                    do {
                        let cap = max(1, RuntimeConfig.finalizeFinMaxWaitMs / 50) // 50ms ticks
                        baseTimeout = min(baseTimeout, cap)
                    }
                    // For strict short utterances, wait up to ~1s for <fin> (20 * 50ms)
                    if strictFinalizeShortUtterance { baseTimeout = 20 }
                    
                    logger.debug("🕐 Using finalization timeout: \(baseTimeout * 50)ms (connection took \(Int(connectionDelay))ms)")
                    
                    let startTime = Date()
                    // Optimistic short-circuit: if endpoint-detection end seen and nothing pending, skip wait
                    let pendingDepth = await sendActor.getQueueDepth()
                    let msSinceLast = max(preQuietMs, await sendActor.millisSinceLastSend() ?? 9999)
                    let tailMs = fastFinalizeTailMs
                    // Add token-quiet/partial-empty requirement to end-path skip
                    let partialEmpty = self.partialTranscript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    let noRecentTokensOkEnd: Bool = {
                        guard let t = self.lastTokenActivityAt else { return true }
                        return Int(Date().timeIntervalSince(t) * 1000) >= tailMs
                    }()
                    
                    // Primary fast path: server endpoint detection fired (<end>) and wire is quiet + token quiet/partial empty
                    var skipByEnd = endTokenSeen && (pendingDepth == 0) && (msSinceLast >= tailMs) && (partialEmpty || noRecentTokensOkEnd)
                    
                    // Guarantee-tail-then-skip for <end>: if <end> seen and queue empty but msSinceLast < tail,
                    // wait only the remaining tail and then permit skip. This keeps latency bounded by tailMs.
                    if enableFastFinalizeSkip && endTokenSeen && pendingDepth == 0 && !skipByEnd && !RuntimeConfig.fastFinalizeUnconditionalEndSkip {
                        let remaining = max(0, tailMs - msSinceLast)
                        if remaining > 0 {
                            logger.debug("⏳ [OPTIMISTIC] Waiting remaining tail before skip (remaining=\(remaining)ms, ms_since_last=\(msSinceLast), tail=\(tailMs))")
                            try? await Task.sleep(nanoseconds: UInt64(remaining) * 1_000_000)
                        }
                        // Re-evaluate conditions after short sleep
                        let msAfter = await sendActor.millisSinceLastSend() ?? 9999
                        let depthAfter = await sendActor.getQueueDepth()
                        let partialEmptyAfter = self.partialTranscript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        let noRecentTokensOkAfter: Bool = {
                            guard let t = self.lastTokenActivityAt else { return true }
                            return Int(Date().timeIntervalSince(t) * 1000) >= tailMs
                        }()
                        skipByEnd = endTokenSeen && (depthAfter == 0) && (msAfter >= tailMs) && (partialEmptyAfter || noRecentTokensOkAfter)
                    }
                    
                    // Fallback fast path: no <end>, but we see local silence, no recent tokens, and wire quiet
                    let localSilenceOk: Bool = {
                        if let since = silenceBelowThresholdSince { return Int(Date().timeIntervalSince(since) * 1000) >= tailMs }
                        return false
                    }()
                    let noRecentTokensOk: Bool = {
                        guard let t = lastTokenActivityAt else { return true }
                        return Int(Date().timeIntervalSince(t) * 1000) >= tailMs
                    }()
                    let skipByHeuristic = !endTokenSeen && (pendingDepth == 0) && (msSinceLast >= tailMs) && localSilenceOk && noRecentTokensOk
                    
                    // Unconditional end-skip option: if enabled and <end> is seen with empty queue, skip immediately
                    let unconditionalEndSkip = RuntimeConfig.fastFinalizeUnconditionalEndSkip && endTokenSeen && (pendingDepth == 0)
                    
                    // End path bypasses short gating; heuristic path still respects it
                    let shouldOptimisticSkip = enableFastFinalizeSkip && (
                        (endTokenSeen && (unconditionalEndSkip || skipByEnd)) ||
                        (!endTokenSeen && !strictFinalizeShortUtterance && skipByHeuristic)
                    )
                    if shouldOptimisticSkip {
                        let path = unconditionalEndSkip ? "end_unconditional" : (skipByEnd ? "end" : "heuristic")
                        logger.notice("⚡ [OPTIMISTIC] Skipping wait-for-<fin> path=\(path) tail=\(tailMs)ms pending=\(pendingDepth) ms_since_last=\(msSinceLast)")
                        // Record client-side finalize timestamp for E2E metrics
                        if TimingMetrics.shared.clientFinalizeTs == nil { TimingMetrics.shared.clientFinalizeTs = Date() }
                        // Start a short observation window to detect any late finals after skip (telemetry only)
                        self.postFinalizeTokensAfterSkipCount = 0
                        self.postFinalizeGuardUntil = Date().addingTimeInterval(Double(fastFinalizeGuardWindowMs) / 1000.0)
                        // Merge any leftover partial immediately so we don't lose tail words after fast end
                        if !self.partialTranscript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            self.transcriptionBuffer.forceCompleteCurrentSegment()
                            let merged = self.normalizedJoin(self.transcriptionBuffer.finalText, self.partialTranscript)
                            self.finalBuffer = merged
                        }
                    } else {
                        // Diagnostics: log why we did not skip
                        logger.debug("ℹ️ [OPTIMISTIC] Not skipping: end=\(self.endTokenSeen) pending=\(pendingDepth) ms_since_last=\(msSinceLast) tail=\(tailMs) silence_ok=\(localSilenceOk) tokens_quiet_ok=\(noRecentTokensOk) partial_empty=\(partialEmpty) uncond=\(RuntimeConfig.fastFinalizeUnconditionalEndSkip)")
                    }
                    
                    for _ in 0..<baseTimeout {
                        if shouldOptimisticSkip { break }
                        if finTokenReceived || finishedReceived {
                            let elapsed = Date().timeIntervalSince(startTime) * 1000
                            logger.notice("✅ Received <fin> token after \(Int(elapsed))ms")
                            break
                        }
                        try? await Task.sleep(nanoseconds: 50_000_000)
                    }
                    
                    if !finTokenReceived && !shouldOptimisticSkip {
                        let elapsed = Date().timeIntervalSince(startTime) * 1000
                        logger.warning("⚠️ Timed out waiting for <fin> token after \(Int(elapsed))ms — merging partial transcript")
                        // Safety: merge any partial tokens into the final text so we don't lose tails
                        if !partialTranscript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            self.transcriptionBuffer.forceCompleteCurrentSegment()
                            let merged = self.normalizedJoin(self.transcriptionBuffer.finalText, self.partialTranscript)
                            self.finalBuffer = merged
                        }
                    }
                    // Telemetry: if we took the fast path, log any late finals observed shortly after
                    if shouldOptimisticSkip, let _ = self.postFinalizeGuardUntil {
                        logger.debug("🔬 [OPTIMISTIC] tokens_after_skip=\(self.postFinalizeTokensAfterSkipCount) window_ms=\(self.fastFinalizeGuardWindowMs)")
                        self.postFinalizeGuardUntil = nil
                    }
                }
            } catch {
                logger.error("❌ Failed to send finalization: \(error.localizedDescription)")
            }
        #endif

        // Stop listener cleanly
        listenerTask?.cancel()
        listenerTask = nil

        // Instead of always disconnecting, optionally keep a warm socket window
        if RuntimeConfig.enableVerboseLogging {
            logger.debug("⏹️ Keepalive timer stopped")
        }
        // Stop path monitoring when not streaming
        networkMonitor.stop()
        
        // Stop unified capture and unregister tap
        await UnifiedAudioManager.shared.stopCapture()
        if let id = unifiedTapId {
            await UnifiedAudioManager.shared.unregisterAudioTap(identifier: id)
            unifiedTapId = nil
        }

        // Calculate actual recording duration
        audioFileManager.updateRecordingDuration()
        
        // Save audio file (skip on fast cancel)
        let savedAudioURL: URL? = fastCancel ? nil : await audioFileManager.saveAudioToFile()
        
        await MainActor.run {
            isStreaming = false
            connectionStatus = .disconnected
            streamingAudioLevel = 0.0 // Reset audio level
            micEngaged = false
            transcriptionBuffer.forceCompleteCurrentSegment()
            let trimmedFinal = finalBuffer.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedFinal.isEmpty {
                let trimmedPartial = partialTranscript.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmedPartial.isEmpty {
                    finalBuffer = normalizedJoin(transcriptionBuffer.finalText, trimmedPartial)
                    self.logger.notice("🛟 [FALLBACK] Merged current partial into final at end")
                } else if !lastNonEmptyPartialSnapshot.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && hasAnyTokensReceived {
                    finalBuffer = normalizedJoin(transcriptionBuffer.finalText, lastNonEmptyPartialSnapshot)
                    self.logger.notice("🛟 [FALLBACK] Merged snapshot partial into final at end")
                } else {
                    finalBuffer = transcriptionBuffer.finalText
                }
            }
        }
        
        let durationStr = String(format: "%.1fs", audioFileManager.currentRecordingDuration)
        let audioStatus = savedAudioURL != nil ? "with audio file" : "without audio file"
        
        // Track successful streaming for cold-start detection
        warmupManager.markStreamSuccessful()
        logger.debug("💾 [COLD-START] Updated successful streaming timestamp")
        
        // Promotion: log if no tokens arrived before stop
        if self.promotionAt != nil && self.finalBuffer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let qdepth = await self.sendActor.getQueueDepth()
            self.logger.error("🧪 [PROMO] no_tokens_before_stop bytes_sent=\(self.bytesSentSincePromotion) queue_depth=\(qdepth)")
        }
        // Reset promotion diagnostics after session ends
        self.promotionAt = nil
        self.bytesSentSincePromotion = 0
        self.didLogPromotionFirstAudio = false
        self.didLogPromotionFirstToken = false
        self.nextPromotionBytesMilestone = 10_000
        
        Task.detached { [finalText = self.finalBuffer, durationStr, audioStatus] in
            // Structured logs off-main
            self.logger.notice("✅ Streaming stopped. Final transcript (\(finalText.count) chars, \(durationStr), \(audioStatus)): \"\(finalText)\"")
            StructuredLog.shared.log(cat: .transcript, evt: "final", lvl: .info, ["text": finalText])
            StructuredLog.shared.log(cat: .transcript, evt: "session_end", lvl: .info, ["divider": "────────── session end ──────────"]) 
        }
        fastCancelRequested = false

        // Warm-socket decisions in background
        Task.detached { [weak self] in
            guard let self = self else { return }
            self.logger.notice("🌡️ [WARM] warm_socket=\(RuntimeConfig.keepWarmSocketBetweenSessions ? "yes" : "no")")
            // Only create a standby socket if this utterance established a real active WS session
            let eligibleForStandby = self.didEstablishActiveSocketThisSession
            if RuntimeConfig.enableStandbySocket && eligibleForStandby {
                await self.disconnectWebSocket()
                await self.preconnectStandbyIfEnabled()
            } else if RuntimeConfig.keepWarmSocketBetweenSessions && self.webSocketReady {
                await self.startWarmHold()
            } else {
                await self.disconnectWebSocket()
            }
        }
    }


    /// Fast path for cancel: skip finalize wait and audio file save
    func stopStreamingFastCancel() async {
        fastCancelRequested = true
        // On fast-cancel we skip any warm-hold implicitly by proceeding to immediate stop
        await stopStreaming()
    }

    // MARK: - Timer Utilities

    // MARK: - Readiness Watchdog (pre-speech)
    

    

    // MARK: - TTFT Watchdog (speech-latched)

    

    

    

    

    // MARK: - Escalation helpers
    

    // UI reports it has painted the first token
    @MainActor
    func noteUIPaintedFirstToken() {
        guard isStreaming, !uiPaintedFirstToken else { return }
        uiPaintedFirstToken = true
        tUiFirstPaintAt = Date()
        StructuredLog.shared.log(cat: .ui, evt: "ui_first_paint", lvl: .info, [:])
        maybeFulfillTTFT()
    }

    
    // MARK: - Helper: Flush prebuffer now (after real speech latch)
    internal func flushPrebufferNow(totalBufferedBytes: Int? = nil, bufferDuration: Double? = nil) async {
        let totalBytes: Int
        if let provided = totalBufferedBytes {
            totalBytes = provided
        } else {
            totalBytes = await prebuffer.totalBytes()
        }
        let duration = bufferDuration ?? (Double(totalBytes / 2) / Double(audioFileManager.captureSampleRate))
        let hadBuffered = !(await prebuffer.isEmpty())
        guard hadBuffered else { return }
        isFlushingBuffer = true
        bufferingState = .flushing
        let packetCount = await prebuffer.count()
        logger.notice("📦 Flushing \(packetCount) buffered packets (\(String(format: "%.1f", duration))s of audio, \(totalBytes) bytes)")
        let packetsToFlush = await prebuffer.popAll()
        for (index, pkt) in packetsToFlush.enumerated() {
            let seq = packetSequence
            packetSequence += 1
            audioFileManager.appendAudioData(pkt)
            await sendActor.send(pkt)
            if index == 0 || index == packetsToFlush.count - 1 {
                logger.debug("📤 Sent buffered packet \(index)/\(packetsToFlush.count) seq=\(seq) size=\(pkt.count)")
            }
        }
        let additionalPackets = await prebuffer.popAll()
        if !additionalPackets.isEmpty {
            logger.notice("📦 Flushing \(additionalPackets.count) additional packets that arrived during flush")
            for pkt in additionalPackets {
                let seq = packetSequence
                packetSequence += 1
                audioFileManager.appendAudioData(pkt)
                await sendActor.send(pkt)
            }
        }
        if !RuntimeConfig.shouldSilenceAllLogs { logger.notice("✅ Buffer flush complete") }
        isFlushingBuffer = false
        bufferingState = .live
    }
    
    // MARK: - Retry Helper

    /// Public single-flight entry point that coalesces all connect requests
    private func connectShared(source: ConnectSource, maxRetries: Int = 3) async throws {
        if webSocketReady { return }
        if let t = inFlightConnect {
            logger.debug("🔁 [CONNECT] Coalesced request from \(source.rawValue) onto in-flight attempt #\(self.currentAttemptId)")
            return try await t.value
        }
        let task = Task { () -> Void in
            defer { inFlightConnect = nil }
            try await connectWebSocketWithRetry(maxRetries: maxRetries)
        }
        inFlightConnect = task
        logger.notice("🌐 [CONNECT] New single-flight request from \(source.rawValue)")
        return try await task.value
    }

    /// Attempts to establish the WebSocket connection with limited retries (awaitable version)
    /// This blocks until connection is established or all retries are exhausted
    private func connectWebSocketWithRetry(maxRetries: Int = 3, initialDelay: TimeInterval = 0.25) async throws {
        if webSocketReady { return }
        var attempt = 0
        var delay = initialDelay
        while attempt < maxRetries {
            do {
                connectionAttemptCounter += 1
                currentAttemptId = connectionAttemptCounter
                logger.notice("🌐 [CONNECT] Attempt #\(self.currentAttemptId) (loop \(attempt+1)/\(maxRetries)) starting…")
                // Mark attempt start for accurate handshake timing
                self.connectAttemptStartAt = Date()
                try await self.connectWebSocket()
                // Success — connection is ready
                self.consecutiveTransportFailures = 0
                if self.lastSuccessLoggedAttemptId != self.currentAttemptId {
                    logger.notice("🌐 [CONNECT] Attempt #\(self.currentAttemptId) succeeded")
                    self.lastSuccessLoggedAttemptId = self.currentAttemptId
                }
                return
            } catch {
                logger.warning("🌐 [CONNECT] Attempt #\(self.currentAttemptId) failed: \(error.localizedDescription)")
                attempt += 1
                let errorType = self.classifyError(error)
                await self.recordTransportFailure(for: errorType, context: "connect_retry")

                // Determine if we should retry based on error type
                let shouldRetry = switch errorType {
                case .sslError:
                    true // SSL errors can be transient
                case .connectionReset:
                    true // Connection resets are often recoverable
                case .authenticationError:
                    false // Auth errors typically need different account
                case .networkError:
                    true // Network errors often recover
                case .genericError:
                    true // Give generic errors a chance
                }
                
                if !shouldRetry || attempt >= maxRetries {
                    self.logger.error("❌ WebSocket connection failed after \(attempt) attempts: \(error.localizedDescription)")
                    
                    // Bubble the error up
                    throw error
                }
                self.logger.notice("⚠️ WebSocket connect failed (attempt \(attempt)). Retrying in \(Int(delay * 1000))ms…")
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                delay = min(delay * 2, 10.0) // Exponential back-off capped at 10s
            }
        }
        throw SonioxError.sessionNotConfigured // All retries exhausted
    }

    /// Attempts to establish the WebSocket connection with limited retries so that transient
    /// network hiccups (e.g. brief Wi-Fi drops, VPN reconnects) don't immediately result in a
    /// failed recording. This runs on a background Task so we don't block the audio tap.
    private func connectWithRetry(maxRetries: Int = 3, initialDelay: TimeInterval = 1.0) {
        Task<Void, Never> {
            var attempt = 0
            var delay = initialDelay
            while attempt < maxRetries && self.isStreaming {
                if self.webSocketReady { return }
                do {
                    try await self.connectShared(source: .backgroundRetry, maxRetries: maxRetries)
                    // Success — exit the retry loop
                    self.consecutiveTransportFailures = 0
                    return
                } catch {
                    attempt += 1
                    let errorType = self.classifyError(error)
                    await self.recordTransportFailure(for: errorType, context: "background_retry")

                    // Determine if we should retry based on error type
                    let shouldRetry = switch errorType {
                    case .sslError:
                        true // SSL errors can be transient
                    case .connectionReset:
                        true // Connection resets are often recoverable
                    case .authenticationError:
                        false // Auth errors typically need different account
                    case .networkError:
                        true // Network errors often recover
                    case .genericError:
                        true // Give generic errors a chance
                    }
                    
                    if !shouldRetry || attempt >= maxRetries || !self.isStreaming {
                        self.logger.error("❌ WebSocket connection failed after \(attempt) attempts: \(error.localizedDescription)")
                        
                        // Bubble the error to UI
                        await MainActor.run {
                            self.connectionStatus = .error("Connection failed – please check your internet connection and try again")
                        }
                        // Stop the recording sequence since we can't recover.
                        await self.stopStreaming()
                        return
                    }
                    self.logger.notice("⚠️ WebSocket connect failed (attempt \(attempt)). Retrying in \(Int(delay * 1000))ms…")
                    try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    delay = min(delay * 2, 10.0) // Exponential back-off capped at 10s
                }
            }
        }
    }
    
    // MARK: - WebSocket Management
    
    private func connectWebSocket() async throws {
        // Single-flight guard: if already connecting, wait briefly for readiness
        // Flush any stale waiter before beginning a new connect attempt
        continuationGate.cancelIfPending(SonioxError.sessionNotConfigured)
        if webSocketReady { return }
        if isConnecting {
            // Poll until either ready or no longer connecting
            for _ in 0..<200 { // up to ~10s
                if webSocketReady || !isConnecting { break }
                try? await Task.sleep(nanoseconds: 50_000_000)
            }
            if webSocketReady { return }
        }

        isConnecting = true
        // Reset per-attempt flags
        startTextSentForCurrentSocket = false
        currentSocketId = ""
        // Start a watchdog that only logs if readiness isn't signaled in time
            await MainActor.run {
                timers.cancel(.connectionWatchdog)
                timers.scheduleOnce(.connectionWatchdog, after: 8.0) { [weak self] in
                    guard let self = self, self.isConnecting else { return }
                    self.logger.error("⏳ [CONNECT-WATCHDOG] Attempt #\(self.currentAttemptId) has been connecting for >8s without readiness. startTextSent=\(self.startTextSentForCurrentSocket) socketId=\(self.currentSocketId)")
                }
            }
        do {
            // Use Soniox temporary API keys for secure proxy-only connection
            try await connectWithTemporaryKey()
            
            // Wait for WebSocket to be fully ready before returning
            try await withTaskCancellationHandler(operation: {
                try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                    // Install gate for this attempt via actor to avoid races
                    continuationGate.install(continuation, attemptId: currentAttemptId)
                    // Hard timeout tied to attempt
                    readinessTimeoutTask?.cancel()
                    let thisAttempt = currentAttemptId
                    readinessTimeoutTask = Task { [weak self] in
                        try? await Task.sleep(nanoseconds: 12_000_000_000) // 12s
                        guard let self = self else { return }
                    if self.isConnecting && !self.webSocketReady {
                            self.logger.error("⏳ [CONNECT-TIMEOUT] Readiness not signaled within 12s — aborting connect (attempt=\(thisAttempt))")
                            self.continuationGate.resumeFailure(SonioxError.sessionNotConfigured, for: thisAttempt)
                            await self.disconnectWebSocket()
                            // Force refresh URLSession to avoid reusing a stale transport after sleep
                            self.urlSession?.invalidateAndCancel()
                            self.urlSession = nil
                            self.setupURLSession(isColdStart: true)
                        }
                    }
                }
            }, onCancel: {
                // Ensure no leaked waiter on cancellation
                self.continuationGate.cancelIfPending(SonioxError.sessionNotConfigured)
            })
        } catch {
            isConnecting = false
            timers.cancel(.connectionWatchdog)
            throw error
        }
    }
    
    private func connectWithTemporaryKey() async throws {
        let startTime = Date()
        
        // Build start/config from cache and current audio settings, then connect
        let updatedTempKeyInfo = try await buildTempKeyInfo()
        
        // Connect directly to Soniox using cached/fresh temporary key
        try await connectToSonioxWithTempKey(tempKeyInfo: updatedTempKeyInfo)
        
        let keyLatency = Date().timeIntervalSince(startTime) * 1000
        logger.notice("🔑 Successfully connected to Soniox using temp key (\(String(format: "%.0f", keyLatency))ms key latency)")
    }

    /// Pre-connect a standby socket: connect WS handshake but do NOT send START; keep alive until TTL
    internal func preconnectStandbyIfEnabled() {
        guard RuntimeConfig.enableStandbySocket else { return }
        // Only when not streaming and no active webSocket
        if isStreaming { return }
        if webSocket != nil { return }
        Task {
            do {
                self.connectPurpose = .standby
                self.isStandbySocket = true
                try await self.connectShared(source: .warmHold, maxRetries: 2)
                // At this point, didOpen/finalizeConnection has run; no START has been sent for standby
                self.startStandbyKeepaliveAndTTL()
            } catch {
                self.logger.debug("⚠️ Standby preconnect failed (non-fatal): \(error.localizedDescription)")
                self.connectPurpose = .active
                self.isStandbySocket = false
            }
        }
    }

    
    
    /// Build a fresh start/config payload using cached temp key and current audio/language settings.
    /// This is used both for new connections and for reusing an already-open socket between sessions.
    private func buildTempKeyInfo() async throws -> TemporaryKeyInfo {
        // Get user's language preferences
        var languageHints = getSonioxLanguageHints()
        languageHints.removeAll(where: { $0.lowercased() == "zh-hant" })
        let tempKeyInfo: TemporaryKeyInfo
        do {
            tempKeyInfo = try await tempKeyCache.getCachedTempKey(languages: languageHints)
        } catch TempKeyCacheError.missingAPIKey {
            throw SonioxError.missingAPIKey
        }
        
        var updatedConfig = tempKeyInfo.config
        // Build context on the main actor (depends on ContextService state)
        let contextPayload: SonioxContext? = await MainActor.run {
            let builder = SonioxContextBuilder(
                contextService: self.contextService ?? ContextService.shared,
                vocabularyManager: self.vocabularyManager
            )
            return builder.buildContext()
        }
        // Force-enable non-final tokens to ensure partials display immediately
        updatedConfig = SonioxConfig(
            api_key: updatedConfig.api_key,
            model: "stt-rt-v3",
            audio_format: updatedConfig.audio_format,
            sample_rate: audioFileManager.captureSampleRate,
            num_channels: audioFileManager.captureChannelCount,
            language_hints: languageHints,
            enable_non_final_tokens: true,
            enable_endpoint_detection: true,
            // max_non_final_tokens_duration_ms: 5000, // Deprecated by Soniox as of Sept 1st 2024
            context: contextPayload
        )
        
        if RuntimeConfig.enableVerboseLogging {
            logger.notice("🔊 [SONIOX DEBUG] Config updated with endpoint_detection enabled")
        }
        if let hints = updatedConfig.language_hints { assert(!hints.contains { $0.lowercased() == "zh-hant" }) }
        
        return TemporaryKeyInfo(
            apiKey: tempKeyInfo.apiKey,
            expiresAt: tempKeyInfo.expiresAt,
            websocketUrl: tempKeyInfo.websocketUrl,
            config: updatedConfig
        )
    }
    
    /// Build just the start/config JSON string for sending START on an already-open WebSocket.
    private func buildStartConfigStringForReuse() async throws -> String {
        let info = try await buildTempKeyInfo()
        let data = try JSONEncoder().encode(info.config)
        return String(data: data, encoding: .utf8) ?? "{}"
    }

    // MARK: - START/Config Logging (sanitized)
    private func shortHash(_ s: String) -> String {
        var hash: UInt64 = 1469598103934665603 // FNV-1a 64-bit offset
        for b in s.utf8 { hash ^= UInt64(b); hash &*= 1099511628211 }
        return String(format: "%016llx", hash)
    }

    private func summarizeConfigJSON(_ json: String) -> [String: Any] {
        guard let data = json.data(using: .utf8),
              var obj = (try? JSONSerialization.jsonObject(with: data) as? [String: Any]) else {
            return ["valid": false, "json_hash": shortHash(json)]
        }
        let model = obj["model"] as? String ?? ""
        let audioFmt = obj["audio_format"] as? String ?? ""
        let sr = obj["sample_rate"] as? Int ?? (obj["sample_rate"] as? Double).map { Int($0) } ?? 0
        let ch = obj["num_channels"] as? Int ?? (obj["num_channels"] as? Double).map { Int($0) } ?? 0
        let langs = (obj["language_hints"] as? [Any])?.count ?? 0
        
        var ctxSummary: [String: Any] = [:]
        if let ctxDict = obj["context"] as? [String: Any] {
            ctxSummary["sections"] = Array(ctxDict.keys).sorted()
            ctxSummary["general"] = (ctxDict["general"] as? [Any])?.count ?? 0
            ctxSummary["terms"] = (ctxDict["terms"] as? [Any])?.count ?? 0
            ctxSummary["translation_terms"] = (ctxDict["translation_terms"] as? [Any])?.count ?? 0
            ctxSummary["text_len"] = (ctxDict["text"] as? String)?.count ?? 0
        } else if let ctxString = obj["context"] as? String {
            ctxSummary["text_len"] = ctxString.count
        }
        
        obj["api_key"] = "***"
        if obj["context"] != nil {
            obj["context"] = "[[redacted]]"
        }
        let sanitizedJSON: String = {
            if let sData = try? JSONSerialization.data(withJSONObject: obj, options: [.sortedKeys]),
               let s = String(data: sData, encoding: .utf8) {
                return s
            }
            return json
        }()
        let jh = shortHash(sanitizedJSON)
        var summary: [String: Any] = [
            "valid": true,
            "model": model,
            "audio_format": audioFmt,
            "sr": sr,
            "ch": ch,
            "langs": langs,
            "json_hash": jh
        ]
        if !ctxSummary.isEmpty {
            summary["context"] = ctxSummary
        }
        return summary
    }

    private func logStartConfigIfEnabled(context: String, json: String) {
        guard RuntimeConfig.logASRStartConfig else { return }
        let sum = summarizeConfigJSON(json)
        lastStartConfigSummary = sum
        StructuredLog.shared.log(cat: .stream, evt: "start_config", lvl: .info, [
            "ctx": context,
            "attempt": socketAttemptId,
            "socket": currentSocketId,
            "summary": sum
        ])
        if RuntimeConfig.enableVerboseLogging {
            logger.notice("🧾 [START-CONFIG] ctx=\(context) sum=\(sum)")
        }
    }

    internal func finalizeConnection() async {
        // Mark connection flow complete from the client's perspective
        isConnecting = false
        await MainActor.run { self.timers.cancel(.connectionWatchdog) }
        readinessTimeoutTask?.cancel(); readinessTimeoutTask = nil
        // Mark guard fulfilled so any late timeout won't fire for this attempt
        readinessGuardId &+= 1

        // Signal readiness to any waiter for this attempt (idempotent)
        continuationGate.resumeSuccess(for: socketAttemptId)

        // Send start/config text frame FIRST via send actor now that socket is open
        if !startTextSentForCurrentSocket {
            // Only auto-send START on active connections; standby sockets deliberately skip START here
            if connectPurpose == .active {
                if let startConfig = pendingStartConfigString {
                    await sendActor.sendStartFirst(startConfig)
                    startTextSentForCurrentSocket = true
                    logger.notice("📤 [START] Sent start/config text frame (attemptId=\(self.socketAttemptId), socketId=\(self.currentSocketId), start_text_sent=true)")
                    // Log sanitized summary for debugging/correlation
                    logStartConfigIfEnabled(context: "active", json: startConfig)
                } else {
                    logger.error("⚠️ [START] Missing pending start/config string on finalize — proceeding, but ASR may reject audio")
                }
            } else {
                // Standby connection: send START eagerly to allow keepalives pre-keydown
                if let startConfig = pendingStartConfigString {
                    await sendActor.sendStartFirst(startConfig)
                    startTextSentForCurrentSocket = true
                    logger.notice("📤 [START] Sent start/config on standby socket (eager mode)")
                    // Log sanitized summary for debugging/correlation
                    logStartConfigIfEnabled(context: "standby_eager", json: startConfig)
                    // IMPORTANT: flush the START frame immediately so it precedes any standby keepalive
                    await sendActor.resumeQueue()
                } else {
                    logger.error("⚠️ [STANDBY] Missing pending start/config string for eager START — standby will not accept keepalive")
                }
            }
        }
        pendingStartConfigString = nil

        logger.notice("🔌 [READY] attemptId=\(self.socketAttemptId) socketId=\(self.currentSocketId) start_text_sent=\(self.startTextSentForCurrentSocket)")
        // StructuredLog.shared.log(cat: .stream, evt: "ready", lvl: .info, ["attempt": socketAttemptId, "socket": currentSocketId])
        // CRITICAL FIX: Don't mark ready until AFTER flushing buffered packets
        // This prevents live packets from being sent before buffered ones
        
        // Calculate how much audio was buffered before WebSocket came online
        let totalBufferedBytes = await prebuffer.totalBytes()
        let bufferDuration = Double(totalBufferedBytes / 2) / Double(audioFileManager.captureSampleRate)
        
        // Reset per-attempt speech byte counter so TTFT watchdog measures this socket
        if firstSpeechAt != nil {
            bytesSinceFirstSpeech = 0
        }

        // Log WebSocket ready timing
        if connectPurpose == .standby {
            // For standby, measure handshake duration from attempt start; do not tie to audio start
            if let started = connectAttemptStartAt {
                let ms = Date().timeIntervalSince(started) * 1000
                logger.notice("🧊 [STANDBY] WebSocket ready in \(String(format: "%.0f", ms))ms (handshake)")
                if ms > 10000 {
                    logger.error("⚠️ ABNORMAL DELAY: Standby handshake took \(String(format: "%.1f", ms/1000))s — likely VPN or network stall")
                } else if ms > 5000 {
                    logger.warning("🌐 SLOW STANDBY HANDSHAKE: \(String(format: "%.1f", ms/1000))s (possibly VPN-related)")
                }
            } else {
                logger.debug("🧊 [STANDBY] WebSocket ready (no timing baseline)")
            }
        } else if let startTime = audioFileManager.currentRecordingStartTime {
            let connectionDelay = Date().timeIntervalSince(startTime) * 1000 // ms
            logger.notice("🔌 WebSocket ready after \(String(format: "%.0f", connectionDelay))ms - buffered \(String(format: "%.1f", bufferDuration))s of audio")
            
            // Warn if connection took abnormally long
            if connectionDelay > 10000 { // 10 seconds
                logger.error("⚠️ ABNORMAL DELAY: WebSocket took \(String(format: "%.1f", connectionDelay/1000))s to connect!")
                logger.error("⚠️ This may indicate VPN instability or network issues.")
            } else if connectionDelay > 5000 { // 5 seconds  
                logger.warning("🌐 SLOW CONNECTION: \(String(format: "%.1f", connectionDelay/1000))s (possibly VPN-related)")
            }
        }
        
        // Flush any pre-buffered packets FIRST
        let hadBuffered = !(await prebuffer.isEmpty())
        // ACTIVE sessions: flush any pre‑roll immediately at READY so we never lose first words in PTT
        if connectPurpose == .active, hadBuffered {
            await flushPrebufferNow(totalBufferedBytes: totalBufferedBytes, bufferDuration: bufferDuration)
        }
        
        // NOW mark WebSocket ready - this ensures strict FIFO ordering
        webSocketReady = true
        tWsReadyAt = Date()
        trySatisfyReadiness()
        DebugLogger.debug("perf:socket_ready", category: .performance)
        if connectPurpose == .active {
            didEstablishActiveSocketThisSession = true
        }
        lastConnectedAt = Date()
        
        if connectPurpose == .standby {
            // Standby socket ready — do not start listener loop aggressively; still listen to catch server close
            // Start the listener for control frames but treat it as standby mode
            listenerTask = Task {
                logger.debug("👂 [LISTENER] Standby listener task for socketId=\(self.currentSocketId) attemptId=\(self.socketAttemptId)")
                await listenForMessages()
            }
            return
        }

        // Watchdog disabled: observe-only mode
        // if useNewWatchdogs, firstSpeechAt != nil { startTTFTWatchdog() }
        // else { maybeStartSpeechWatchdogIfEligible() }
        
        // Start listening for responses
        listenerTask = Task { 
            logger.debug("👂 [LISTENER] Starting listener task for socketId=\(self.currentSocketId) attemptId=\(self.socketAttemptId)")
            await listenForMessages() 
        }

        // If a capture restart was deferred during connect, perform it now
        if pendingCaptureRestart {
            pendingCaptureRestart = false
            Task { [weak self] in
                await self?.restartAudioCaptureWithoutClosingWebSocket()
            }
        }
        
        // Start active keepalive via manager
        warmupManager.startActiveKeepalive()
        
        // Resume any paused sends now that socket is ready
        await sendActor.resumeQueue()

        // Note: Removed READY-based startup watchdog that re-sent start/config.
        // Speech-gated watchdog will start after first speech is detected.
        
        // logger.notice("✅ WebSocket connected and configured")  // Reduced logging verbosity
    }
    
    internal func disconnectWebSocket() async {
        await disconnectWebSocket(isRecovery: false)
    }

    
    
    internal func disconnectWebSocket(isRecovery: Bool) async {
        warmupManager.stopActiveKeepalive()
        // Stop any warm-hold before disconnecting
        stopWarmHold()
        webSocket?.cancel(with: .goingAway, reason: nil)
        // During recovery, do not mark as shutting down — we are preserving the session
        if !isRecovery { isShuttingDown = true }
        webSocket = nil
        webSocketReady = false  // CRITICAL: Reset ready flag for VPN disconnections
        // Cancel any speech watchdog when socket is dropped
        cancelSpeechWatchdog()
        // VAD disabled
        isConnecting = false
        await MainActor.run { self.timers.cancel(.connectionWatchdog) }
        readinessTimeoutTask?.cancel(); readinessTimeoutTask = nil
        // Mark guard fulfilled so any late timeout won't fire for this attempt
        readinessGuardId &+= 1
        logger.debug("🔌 [WS] Disconnected (socketId=\(self.currentSocketId))")
        currentSocketId = ""
        startTextSentForCurrentSocket = false
            timers.cancel(.firstBufferTapRefresh)
            timers.cancel(.firstBufferEngineRestart)
        // Detach from actor
        await sendActor.setSocket(nil)
        await sendActor.pauseQueue()
        
        // If we're disconnecting while waiting for connection readiness, signal failure
        continuationGate.cancelIfPending(SonioxError.sessionNotConfigured)
        
        // logger.notice("🔌 WebSocket disconnected")  // Reduced logging verbosity
    }
    
    private func listenForMessages() async {
        while webSocket != nil {
            do {
                guard let message = try await webSocket?.receive() else { break }
                
                switch message {
                case .data(let data):
                    await handleTranscriptionResponse(data)
                case .string(let text):
                    if let data = text.data(using: .utf8) {
                        await handleTranscriptionResponse(data)
                    }
                @unknown default:
                    logger.warning("⚠️ Unknown WebSocket message type")
                }
            } catch {
                if Task.isCancelled { break }
                let ns = error as NSError
                let isSocketNotConnected = (ns.domain == NSPOSIXErrorDomain && ns.code == 57) || ns.localizedDescription.lowercased().contains("socket is not connected")
                // Downgrade benign closes (planned shutdown, standby TTL close, or not streaming)
                if isSocketNotConnected && (isShuttingDown || isStandbySocket || !isStreaming) {
                    logger.debug("🔌 [WS] Receive ended after planned close (benign): \(ns.localizedDescription)")
                    break
                }
                logger.error("❌ WebSocket receive error: \(error.localizedDescription)")
                
                // Classify the error to determine recovery strategy
                let errorType = classifyError(error)
                
                // For mid-recording disconnections, attempt recovery
                if errorType == .connectionReset && isStreaming {
                    logger.notice("🔄 Connection reset during recording - attempting recovery")
                    await performMidRecordingRecovery()
                    return
                }
                
                // For SSL errors, might be transient
                if errorType == .sslError && isStreaming {
                    logger.notice("🔒 SSL error during recording - will retry connection")
                    await performMidRecordingRecovery()
                    return
                }
                
                // Stop streaming and cleanup audio capture when WebSocket fails critically
                // Avoid stopping if a recovery is in progress
                if !isRecovering {
                    await stopStreaming()
                }
                break
            }
        }
    }
    
    private func handleTranscriptionResponse(_ data: Data) async {
        do {
            // First try to parse as error response
            if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let errorCode = jsonObject["error_code"] {
                // Soniox sends numeric error codes; handle both Int and String representations
                let codeInt: Int? = {
                    if let i = errorCode as? Int { return i }
                    if let s = errorCode as? String, let i = Int(s) { return i }
                    return nil
                }()
                let codeString = codeInt.map(String.init) ?? (errorCode as? String) ?? "Unknown"
                let errorMessage = jsonObject["error_message"] as? String ?? "Unknown error"
                // If we sent a benign control message by mistake earlier (e.g., keepalive JSON),
                // the server may reply 400 Control request invalid type. Suppress the next toast.
                if codeInt == 400 && errorMessage.lowercased().contains("invalid type") {
                    suppressRecoveryToastOnce = true
                }
                // On any error, optionally log the most recent START/config summary for correlation
                if RuntimeConfig.logASRStartConfig, let cfg = self.lastStartConfigString {
                    let sum = self.summarizeConfigJSON(cfg)
                    StructuredLog.shared.log(cat: .stream, evt: "start_config_on_error", lvl: .err, [
                        "attempt": self.socketAttemptId,
                        "socket": self.currentSocketId,
                        "code": codeString,
                        "msg": errorMessage,
                        "summary": sum
                    ])
                    if RuntimeConfig.enableVerboseLogging {
                        self.logger.error("🧾 [START-CONFIG@ERR] code=\(codeString) sum=\(sum)")
                    }
                }
                // Silence benign idle/late 408 timeouts during or after shutdown/finalization
                if let ci = codeInt, ci == 408, (!isStreaming || finTokenReceived || isShuttingDown) {
                    // Downgrade to debug to avoid noise
                    logger.debug("⏳ [POST-FIN] Ignoring late 408 timeout after finalize/shutdown")
                    return
                }
                // Otherwise log as error
                logger.error("❌ Clio API Error: \(codeString) - \(errorMessage)")
                return
            }
            
            let response = try JSONDecoder().decode(SonioxResponse.self, from: data)
            
            await MainActor.run {
                // Update partial transcript with latest partial results
                let partialText = response.tokens.filter { !$0.is_final }.map { $0.text }.joined()
                // Update UI with partials immediately
                self.partialTranscript = partialText
                // Maintain snapshot of last non-empty partial to avoid empty finals when cleared at end
                if !partialText.isEmpty {
                    self.lastNonEmptyPartialSnapshot = partialText
                }
                if !partialText.isEmpty && !self.firstPartialReceived {
                    self.firstPartialReceived = true
                    self.tFirstPartialAt = Date()
                    self.maybeFulfillTTFT()
                }
                
                if !self.firstPartialLoggedFromHotkey, !partialText.isEmpty {
                    if let t0 = self.audioFileManager.currentRecordingStartTime {
                        StreamingDiagnostics.logFirstPartial(t0: t0)
                    }
                    DebugLogger.debug("perf:first_partial", category: .performance)
                    self.firstPartialLoggedFromHotkey = true
                }
                // Record any token activity for finalize heuristics
                if !response.tokens.isEmpty { self.lastTokenActivityAt = Date() }
                if !partialText.isEmpty || response.tokens.contains(where: { $0.is_final }) {
                    // First-token observability (TTFT from firstSpeech)
                    if !self.hasAnyTokensReceived, let t0 = self.firstSpeechAt {
                        let ttftMs = Int(Date().timeIntervalSince(t0) * 1000)
                        StructuredLog.shared.log(cat: .stream, evt: "ttft", lvl: .info, ["ms": ttftMs])
                        self.firstTokenLogged = true
                    }
                    self.hasAnyTokensReceived = true
                    // Promotion: first token after promotion
                    if self.promotionAt != nil && !self.didLogPromotionFirstToken {
                        let ms = Int(Date().timeIntervalSince(self.promotionAt!) * 1000)
                        self.logger.notice("🧪 [PROMO] first_token ms=\(ms) tokens_in_msg=\(response.tokens.count)")
                        self.didLogPromotionFirstToken = true
                    }
                    // Unmute active keepalives after first token activity
                    self.keepaliveMutedUntil = nil
                    // Cancel speech watchdog on first token activity
                    self.cancelSpeechWatchdog()
                }
                
                // Check for <fin> token (signals end of finalization)
                let finTokens = response.tokens.filter { $0.is_final && $0.text == "<fin>" }
                if !finTokens.isEmpty {
                    logger.notice("🏁 Received <fin> token - finalization complete")
                    self.finTokenReceived = true
                    self.lastFinalizationTime = Date()  // Track when finalization completed
                    // Capture fin timestamp for post-release E2E timing
                    if TimingMetrics.shared.finTs == nil { TimingMetrics.shared.finTs = Date() }
                }
                
                // Explicitly detect <end> endpoint token (token-level, not substring)
                let endTokens = response.tokens.filter { $0.is_final && $0.text == "<end>" }
                if !endTokens.isEmpty {
                    self.endTokenSeen = true
                    self.endTokenLastSeenAt = Date()
                }
                
                // Process final tokens (excluding <fin>)
                let finalTokens = response.tokens.filter { $0.is_final && $0.text != "<fin>" }
                if !finalTokens.isEmpty {
                    if !self.firstFinalLoggedFromHotkey {
                        if let t0 = self.audioFileManager.currentRecordingStartTime {
                            StreamingDiagnostics.logFirstFinal(t0: t0)
                        }
                        DebugLogger.debug("perf:first_final", category: .performance)
                        self.firstFinalLoggedFromHotkey = true
                    }
                    // Count any late finals during the post-finalize observation window (for telemetry)
                    if let guardUntil = self.postFinalizeGuardUntil, Date() <= guardUntil {
                        self.postFinalizeTokensAfterSkipCount &+= finalTokens.count
                    }
                    let finalChunk = finalTokens.map { $0.text }.joined()
                    StructuredLog.shared.log(cat: .transcript, evt: "raw_final", lvl: .info, ["text": finalChunk])
                    // If endpoint detection emitted an <end> sentinel inside final chunk, mark it
                    if finalChunk.contains("<end>") { self.endTokenSeen = true; self.endTokenLastSeenAt = Date() }
                }
                let newFinalCount = finalTokens.count
                
                // Accumulate all final tokens from this response
                for token in finalTokens {
                    self.transcriptionBuffer.addFinalToken(token.text)
                }
                
                // Check if we should complete a segment after adding all tokens
                if newFinalCount > 0 {
                    // Check for pause-based segmentation
                    if let lastTime = self.lastFinalTokenTime {
                        let timeSinceLastToken = Date().timeIntervalSince(lastTime)
                        if timeSinceLastToken > self.segmentPauseThreshold && self.transcriptionBuffer.hasUncompletedSegment {
                            // Force complete current segment due to pause
                            self.transcriptionBuffer.forceCompleteCurrentSegment()
                        }
                    }
                    
                    self.transcriptionBuffer.checkAndCompleteSegment()
                    self.lastFinalTokenTime = Date()
                }
                
                // Update final buffer for display
                self.finalBuffer = self.transcriptionBuffer.finalText
                
                // Log meaningful status update only when we get new final tokens
                if newFinalCount > 0 {
                    // logger.notice("✅ Finalized \(newFinalCount) tokens. Total transcript: \"\(self.finalBuffer)\"")
                }
            }

            // Detect explicit stream completion cue – only rely on "finished": true
            if let jsonObj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let finishedFlag = jsonObj["finished"] as? Bool, finishedFlag {
                finishedReceived = true
            }
            
        } catch {
            logger.error("❌ Failed to decode transcription response: \(error.localizedDescription)")
        }
    }
    
    // Normalize boundary spacing between two strings (left + right)
    internal func normalizedJoin(_ left: String, _ right: String) -> String {
        // Helpers
        func firstNonWhitespace(in s: String) -> Character? {
            for ch in s { if !ch.isWhitespace { return ch } }
            return nil
        }
        func lastNonWhitespace(in s: String) -> Character? {
            for ch in s.reversed() { if !ch.isWhitespace { return ch } }
            return nil
        }
        func trimTrailingSpaces(_ s: String) -> String {
            var s = s
            while let last = s.last, last.isWhitespace { s.removeLast() }
            return s
        }
        func dropLeadingSpaces(_ s: String) -> String {
            String(s.drop { $0.isWhitespace })
        }
        func isCJK(_ c: Character) -> Bool {
            for scalar in c.unicodeScalars {
                switch scalar.value {
                case 0x4E00...0x9FFF,
                     0x3400...0x4DBF,
                     0x20000...0x2A6DF,
                     0x2A700...0x2B73F,
                     0x2B740...0x2B81F,
                     0x2B820...0x2CEAF,
                     0xF900...0xFAFF,
                     0x2F800...0x2FA1F:
                    return true
                default:
                    continue
                }
            }
            return false
        }
        let closingPunctuation = CharacterSet(charactersIn: ".!?,:;)]}”’\"")

        let lChar = lastNonWhitespace(in: left)
        let rChar = firstNonWhitespace(in: right)
        let rightHasLeadingSpace = right.first?.isWhitespace == true

        var shouldSpace = false
        if let l = lChar, let r = rChar {
            let lIsCJK = isCJK(l)
            let rIsCJK = isCJK(r)
            let leftIsClosingPunct = l.unicodeScalars.first.map { closingPunctuation.contains($0) } ?? false

            if lIsCJK && rIsCJK {
                shouldSpace = false
            } else if leftIsClosingPunct {
                shouldSpace = !rIsCJK
            } else {
                shouldSpace = rightHasLeadingSpace && !(lIsCJK && rIsCJK)
            }
        }

        var leftTrim = trimTrailingSpaces(left)
        let rightTrimLead = dropLeadingSpaces(right)
        if shouldSpace { leftTrim.append(" ") }
        return leftTrim + rightTrimLead
    }
    
    // MARK: - First Buffer Watchdogs
    internal func scheduleFirstBufferWatchdogs() async {
        await MainActor.run {
            // Observe-only: do not restart capture before first buffer. Park timers quietly with logs.
            timers.cancel(.firstBufferTapRefresh)
            timers.cancel(.firstBufferEngineRestart)

            let isBluetooth = AudioDeviceManager.shared.isCurrentInputBluetooth
            let wasPreviewing = (self.bufferingState == .prebuffering)
            let tapRefreshDelay: TimeInterval = isBluetooth || didStartRetryOccur ? 0.5 : (wasPreviewing ? 0.35 : 0.22)
            let engineRestartDelay: TimeInterval = isBluetooth || didStartRetryOccur ? 1.0 : (wasPreviewing ? 0.9 : 0.65)

            timers.scheduleOnce(.firstBufferTapRefresh, after: tapRefreshDelay) { [weak self] in
                guard let self = self, self.isStreaming, self.firstBufferReceivedAt == nil else { return }
                self.logger.warning("⏳ [FIRST-BUFFER] No buffer by \(tapRefreshDelay)s – observe-only (no restart)")
            }

            timers.scheduleOnce(.firstBufferEngineRestart, after: engineRestartDelay) { [weak self] in
                guard let self = self, self.isStreaming, self.firstBufferReceivedAt == nil else { return }
                self.logger.error("⏳ [FIRST-BUFFER] Still no buffer by \(engineRestartDelay)s – observe-only (no restart)")
            }
        }
    }

    // MARK: - macOS Audio Management
    // Note: On macOS, AVAudioEngine handles audio session management automatically.
    // Unlike iOS, we don't need manual AVAudioSession configuration.
    // This function is kept for potential future macOS-specific audio setup if needed.
    
    
    // MARK: - Tap processing during active streaming
    internal func processAudioBuffer(_ buffer: AVAudioPCMBuffer) async {
        guard isStreaming else { return }
        
        // Mark mic engaged at first buffer
        if firstBufferReceivedAt == nil {
            firstBufferReceivedAt = Date()
            if let t0 = audioFileManager.currentRecordingStartTime {
                StreamingDiagnostics.logFirstAudioBufferCaptured(t0: t0)
            }
            await MainActor.run { micEngaged = true }
            await MainActor.run {
                timers.cancel(.firstBufferTapRefresh)
                timers.cancel(.firstBufferEngineRestart)
            }

            let metrics = TimingMetrics.shared
            if metrics.notchIntentTs != nil || metrics.notchShowCallTs != nil || metrics.notchMode != nil {
                let deltas = metrics.markNotchFirstAudio()
                var fields: [String: Any] = [:]
                if let mode = metrics.notchMode { fields["mode"] = mode }
                if let intentMs = deltas.intentToAudioMs { fields["intent_to_first_audio_ms"] = intentMs }
                if let showCallMs = deltas.showCallToAudioMs { fields["show_call_to_first_audio_ms"] = showCallMs }
                if let shownMs = deltas.shownToAudioMs { fields["shown_to_first_audio_ms"] = shownMs }
                StructuredLog.shared.log(cat: .ui, evt: "notch_first_audio", lvl: .info, fields)
            }

            // Watchdog-v2: mark first audio captured for readiness
            firstAudioCapturedFlag = true
            tFirstAudioAt = Date()
            if tMicEngagedAt == nil { tMicEngagedAt = tFirstAudioAt }
            trySatisfyReadiness()
            // Begin noise-floor priming window
            noisePrimingStartAt = Date()
            noisePrimed = false
        }

        // Use generic audio processor for conversion and level
        guard let processed = audioProcessor.process(buffer: buffer) else {
            if let snapshot = audioProcessor.drainConverterFailureSnapshot() {
                await handleConverterFailure(snapshot)
            }
            await MainActor.run {
                self.streamingAudioLevel = 0.0
                self.sonioxMeter = AudioMeter(averagePower: 0, peakPower: 0)
            }
            return
        }

        await converterFailureTracker.reset()
        let audioData = processed.data
        let audioLevel = processed.level
        
        // Update audio level for visualizer
        await MainActor.run {
            self.streamingAudioLevel = audioLevel
            self.sonioxMeter = AudioMeter(averagePower: audioLevel, peakPower: audioLevel)
            if audioLevel > self.maxAudioLevelSinceStart {
                self.maxAudioLevelSinceStart = audioLevel
            }
        }
        
        // Emit periodic structured RMS/peak logs and silence detection
        let now = Date()
        let levelClamped = max(min(audioLevel, 1.0), 0.0)
        // audioLevel is already normalized 0..1 for -60..0 dB; convert back to approximate dB for logging
        let approxDb = (-60.0) + (levelClamped * 60.0)
        
        // Compute a soft override to allow sending even if energy-based latch hasn't fired
        let gateOverride: Bool = {
            guard let t0 = tMicEngagedAt else { return false }
            return Date().timeIntervalSince(t0) >= Double(speechSendFallbackMs) / 1000.0
        }()

        // Promotion: first audio after promotion snapshot
        if self.promotionAt != nil && !self.didLogPromotionFirstAudio {
            self.logger.debug("🧪 [PROMO] first_audio seq=\(self.packetSequence) bytes=\(audioData.count) approx_db=\(String(format: "%.1f", approxDb))")
            self.didLogPromotionFirstAudio = true
        }

        // TEN-VAD disabled: use energy-based fallback + simple noise-floor latch
        do {
            // Speech detection (energy-based fallback)
            if firstSpeechAt == nil {
                // Update noise floor for first ~150ms
                if let t = noisePrimingStartAt, !noisePrimed {
                    if Date().timeIntervalSince(t) < 0.15 {
                        // simple running average
                        noiseFloorDb = max(-60.0, min(0.0, (noiseFloorDb * 0.9) + approxDb * 0.1))
                    } else {
                        noisePrimed = true
                    }
                }
                let dynamicThreshold = max(noiseFloorDb + 12.0, -48.0)
                let over = approxDb > dynamicThreshold
                if over {
                    speechFramesAboveThreshold += 1
                    if speechFramesAboveThreshold >= 5 { // require ~5 frames
                        firstSpeechAt = Date()
                        bytesSinceFirstSpeech = 0
                        speechLatched = true
                        audioMsSinceLatch = 0
                        let dbVal = String(format: "%.1f", approxDb)
                        logger.debug("🗣️ [SPEECH] LATCH (frames=\(self.speechFramesAboveThreshold), db=\(dbVal), thr=\(String(format: "%.1f", dynamicThreshold)))")
                        // TTFT watchdog disabled: observe-only mode
                        // if webSocketReady { startTTFTWatchdog() }
                        // Cancel readiness watchdog once speech begins
                        timers.cancel(.readinessWatchdog)
                        // Flush any prebuffer now that we have real speech latched
                        Task { [weak self] in
                            guard let self = self else { return }
                            guard self.webSocketReady else { return }
                            let isEmpty = await self.prebuffer.isEmpty()
                            if !isEmpty {
                                let total = await self.prebuffer.totalBytes()
                                await self.flushPrebufferNow(totalBufferedBytes: total, bufferDuration: 0 /* recompute inside */)
                            }
                        }
                    }
                } else {
                    speechFramesAboveThreshold = 0
                }
            } else {
                // Speech ongoing; ensure TTFT watchdog is started if READY
                if webSocketReady && useNewWatchdogs { /* ensure started */ }
            }
        }
        
        // If WS is ready and the gate override has elapsed, flush any prebuffer even without latch
        if webSocketReady && gateOverride {
            let total = await prebuffer.totalBytes()
            if total > 0 {
                await flushPrebufferNow(totalBufferedBytes: total, bufferDuration: 0 /* recompute inside */)
            }
        }
        
        if RuntimeConfig.enableVerboseLogging {
            if lastLevelLogAt == nil || now.timeIntervalSince(lastLevelLogAt!) >= levelLogInterval {
                lastLevelLogAt = now
            StructuredLog.shared.log(cat: .audio, evt: "level", lvl: .info, [
                    "avg_db": Double(round(approxDb * 10) / 10),
                    "peak_db": Double(round(approxDb * 10) / 10)
                ])
            }
        }
        if approxDb < silenceThresholdDb {
            if silenceBelowThresholdSince == nil { silenceBelowThresholdSince = now }
            if !emittedSilenceEventForThisSession, let since = silenceBelowThresholdSince, now.timeIntervalSince(since) >= silenceDurationSec {
                emittedSilenceEventForThisSession = true
                let dev = AudioDeviceManager.shared.getCurrentDevice()
                let name = AudioDeviceManager.shared.getDeviceName(deviceID: dev) ?? "unknown"
                let uid = AudioDeviceManager.shared.getDeviceUID(deviceID: dev) ?? ""
                StructuredLog.shared.log(cat: .audio, evt: "silence_detected", lvl: .warn, [
                    "threshold_db": silenceThresholdDb,
                    "duration_s": silenceDurationSec,
                    "device_id": Int(dev),
                    "device_name": name,
                    "device_uid_hash": String(uid.hashValue)
                ])
            }
        } else {
            silenceBelowThresholdSince = nil
        }
        
        guard !audioData.isEmpty else { return }
        
        // Track that we're receiving audio data (health monitoring)
        lastAudioDataReceivedTime = Date()
        if !hasReceivedAudioData {
            hasReceivedAudioData = true
        if !RuntimeConfig.shouldSilenceAllLogs { logger.notice("✅ [AUDIO HEALTH] First audio data received - tap is functional") }
            // Initialize gate warm-up window (disabled)
            // if firstBufferReceivedAt != nil {
            //     if self.gateWarmupUntil == nil {
            //         self.gateWarmupUntil = Date().addingTimeInterval(1.5)
            //         self.probeWriter = WarmupProbeWriter(targetSampleRate: targetSampleRate)
            //     }
            // }
        }
        
        // If WebSocket ready and connected, allow send on speech latch OR timed override
        if let webSocket = webSocket, webSocketReady, (speechLatched || gateOverride) {
            // Pre-send diagnostics (disabled by default; only in verbose mode)
            if RuntimeConfig.enableVerboseLogging {
                StructuredLog.shared.log(cat: .stream, evt: "pre_send", lvl: .info, [
                    "has_socket": true,
                    "ready": true,
                    "flushing": isFlushingBuffer,
                    "bytes": audioData.count,
                    "seq": Int(packetSequence)
                ])
            }
            // If buffer is being flushed, add to buffer instead of sending directly
            if isFlushingBuffer {
                await prebuffer.append(audioData)
                // Only log every 10th packet during flush to reduce noise
                let c = await self.prebuffer.count()
                if c % 10 == 0 {
                    logger.debug("📦 Buffering during flush: \(c) packets")
                }
                return
            }
            
            // Gate warm-up (disabled writing probe)
            let now = Date()
            // let warmupActive = (gateWarmupUntil != nil) && (now < gateWarmupUntil!)
            // if warmupActive {
            //     probeWriter?.append(pcm: audioData)
            // }
            
            // Track packet sequence for debugging
            let currentSeq = self.packetSequence
            self.packetSequence += 1
            
            do {
                // Track bytes since speech for watchdog thresholding
                if firstSpeechAt != nil {
                    bytesSinceFirstSpeech &+= audioData.count
                    // Convert bytes to ms given 16-bit mono at capture sample rate
                    let bytesPerMs = max(1, (audioFileManager.captureSampleRate * audioFileManager.captureChannelCount * 2) / 1000)
                    audioMsSinceLatch &+= (audioData.count / bytesPerMs)
                }
                // Promotion: accumulate bytes and emit milestones
                if self.promotionAt != nil {
                    self.bytesSentSincePromotion &+= audioData.count
                    if self.bytesSentSincePromotion >= self.nextPromotionBytesMilestone {
                        self.logger.debug("🧪 [PROMO] audio_bytes bytes=\(self.bytesSentSincePromotion)")
                        if self.nextPromotionBytesMilestone < 30_000 {
                            self.nextPromotionBytesMilestone = 30_000
                        } else {
                            self.nextPromotionBytesMilestone = Int.max
                        }
                    }
                }
                // Append to audio file only when we actually send to server (avoid double-writing prebuffer)
                audioFileManager.appendAudioData(audioData)
                await sendActor.send(audioData)
                if !firstAudioSentLogged {
                    firstAudioSentLogged = true
                    DebugLogger.debug("perf:first_audio_sent", category: .performance)
                    didSendAnyAudioThisSession = true
                    if let t0 = audioFileManager.currentRecordingStartTime {
                        StreamingDiagnostics.logFirstAudioSent(t0: t0, seq: Int(currentSeq))
                    }
                }
                // Log only occasional packets to keep noise low
                if RuntimeConfig.enableVerboseLogging {
                    if currentSeq % 200 == 0 { // further reduce frequency
                        // StructuredLog.shared.log(cat: .stream, evt: "send_audio", lvl: .info, ["seq": Int(currentSeq), "bytes": audioData.count])
                    }
                }
                // Finalize probe if warm-up ended (disabled)
                // if let until = gateWarmupUntil, now >= until {
                //     // Disabled saving probe to file
                //     gateWarmupUntil = nil
                //     probeWriter = nil
                // }
            } catch {
                logger.error("❌ Failed to send audio data: \(error.localizedDescription)")
                let errorType = classifyError(error)

                // Attempt mid-recording recovery for recoverable errors
                if errorType == .connectionReset || errorType == .networkError || errorType == .sslError {
                Task {
                        let recovered = await self.attemptMidRecordingRecovery(errorType: errorType)
                        if !recovered {
                            await self.stopStreaming()
                        }
                    }
                } else {
                    // Non-recoverable – stop streaming to avoid locking the microphone
                    Task {
                        await self.stopStreaming()
                    }
                }
            }
        } else {
            // Buffer audio while WebSocket is connecting - this preserves early speech!
            if bufferingState == .idle { bufferingState = .prebuffering }
            await prebuffer.append(audioData)
            
            // Log buffer size every 200 packets to monitor filling
            if RuntimeConfig.enableVerboseLogging {
                let c = await self.prebuffer.count()
                if c % 200 == 0 {
                    let totalBytes = await self.prebuffer.totalBytes()
                    logger.debug("📦 Buffer growing: \(c) packets (\(totalBytes) bytes)")
                    // StructuredLog.shared.log(cat: .stream, evt: "prebuffer", lvl: .info, ["packets": c, "bytes": totalBytes])
                }
            }
        }
    }
    
    
    
    // MARK: - Resampling removed; handled by AudioProcessor
    
    // MARK: - Language Support
    
    private func getSonioxLanguageHints() -> [String] {
        // Get user's selected languages from multiple language selection
        guard let selectedLanguagesData = UserDefaults.standard.data(forKey: "SelectedLanguages") else {
            // Fallback to single language selection for backward compatibility
            let selectedLanguage = UserDefaults.standard.string(forKey: "SelectedLanguage") ?? "en"
            return [selectedLanguage == "auto" ? "en" : selectedLanguage]
        }
        
        do {
            let selectedLanguages = try JSONDecoder().decode(Set<String>.self, from: selectedLanguagesData)
            
            // Normalize Traditional Chinese pseudo option → base Chinese for Soniox
            var normalized: Set<String> = []
            for code in selectedLanguages {
                let lower = code.lowercased()
                if lower == "zh-hant" || lower == "zh-tw" {
                    normalized.insert("zh")
                }
                normalized.insert(code)
            }
            // Validate all selected languages are supported by Soniox
            let validLanguages = normalized.filter { SonioxLanguages.isValidLanguage($0) }
            
            // If auto is selected, return only English (Soniox auto-detection)
            if validLanguages.contains("auto") {
                return ["en"]
            }
            
            // Return valid languages or default to English if none valid
            return validLanguages.isEmpty ? ["en"] : Array(validLanguages)
        } catch {
            logger.error("Failed to decode selected languages: \(error)")
            // Fallback to single language selection
            let selectedLanguage = UserDefaults.standard.string(forKey: "SelectedLanguage") ?? "en"
            return [selectedLanguage == "auto" ? "en" : selectedLanguage]
        }
    }
    
    // MARK: - Temporary API Key Management
    // 
    // PERFORMANCE OPTIMIZATION: Direct temp key requests replaced by TempKeyCache
    // This eliminates 200-500ms latency per connection by pre-fetching and caching keys
    // See TempKeyCache.swift for the new implementation
    
    private func connectToSonioxWithTempKey(tempKeyInfo: TemporaryKeyInfo) async throws {
        // Coerce to secure WebSocket scheme and log the final URL for debugging
        var finalURLString = tempKeyInfo.websocketUrl
        if let comps = URLComponents(string: finalURLString) {
            var mutable = comps
            let scheme = (comps.scheme ?? "").lowercased()
            // Upgrade any http/https/ws to wss
            if scheme == "http" || scheme == "https" || scheme == "ws" {
                mutable.scheme = "wss"
            }
            // Default host/path fallback if scheme-only was provided incorrectly
            if mutable.host == nil || mutable.host?.isEmpty == true {
                mutable.host = "stt-rt.soniox.com"
            }
            if mutable.path.isEmpty {
                mutable.path = "/transcribe-websocket"
            }
            if let fixed = mutable.url?.absoluteString {
                finalURLString = fixed
            }
        }
        guard let url = URL(string: finalURLString) else {
            throw SonioxError.invalidEndpoint
        }
        if !RuntimeConfig.shouldSilenceAllLogs { logger.notice("🌐 [WS CONNECT] Using URL: \(url.scheme ?? "?")://\(url.host ?? "?")\(url.path)") }
        
        // Lazily (re)initialize URLSession if needed to avoid spurious 'session not configured' failures
        if urlSession == nil {
            setupURLSession()
        }
        // If a previous cancel invalidated the session, recreate it
        if let session = urlSession, session.delegate == nil {
            setupURLSession()
        }
        guard let urlSession = urlSession else {
            throw SonioxError.sessionNotConfigured
        }
        
        webSocket = urlSession.webSocketTask(with: url)
        webSocket?.resume()
        // Ensure send actor knows the new socket
        await sendActor.setSocket(webSocket)
        
        // Track a human-readable socket id for logs (object identity + attempt id)
        if let ws = webSocket {
            currentSocketId = "sock_\(ObjectIdentifier(ws).hashValue)@attempt_\(currentAttemptId)"
            socketAttemptId = currentAttemptId
            logger.debug("🔗 [WS] Bound socket id=\(self.currentSocketId)")
            StreamingDiagnostics.logWsBind(socketId: currentSocketId, attempt: socketAttemptId, url: url)
        }
        
        // Prepare configuration with temporary API key (start text frame), but DEFER sending until didOpen
        let configData = try JSONEncoder().encode(tempKeyInfo.config)
        let configString = String(data: configData, encoding: .utf8) ?? "Invalid UTF8"
        pendingStartConfigString = configString
        lastStartConfigString = configString
        lastConfigFingerprint = computeConfigFingerprint(tempKeyInfo.config)
        startTextSentForCurrentSocket = false
        
        // We now wait for the URLSessionWebSocketDelegate callback `didOpenWithProtocol` to
        // confirm that the socket is fully ready before sending start and flushing any buffered audio.
    }
    
    

    // Compute a stable fingerprint for determining if config changed (ignores api_key)
    private func computeConfigFingerprint(_ config: SonioxConfig) -> String {
        let model = config.model
        let sr = config.sample_rate ?? 0
        let ch = config.num_channels ?? 0
        let hints = (config.language_hints ?? []).map { $0.lowercased() }.sorted().joined(separator: ",")
        let ctxHash: String = {
            guard let context = config.context,
                  let data = try? JSONEncoder().encode(context),
                  let ctxString = String(data: data, encoding: .utf8) else {
                return "none"
            }
            return shortHash(ctxString)
        }()
        return "m=\(model)|sr=\(sr)|ch=\(ch)|h=\(hints)|ctx=\(ctxHash)"
    }
    
    // MARK: - System Keepalive Management
    
    private func startSystemKeepalive() {
        warmupManager.startSystemKeepalive()
    }
    
    private func stopSystemKeepalive() {
        warmupManager.stopSystemKeepalive()
    }
    
    @objc private func forceCleanup() {
        logger.notice("🧹 Force cleanup triggered by app termination")
        stopSystemKeepalive()
        Task {
            await stopStreaming()
            if let id = unifiedTapId {
                await UnifiedAudioManager.shared.unregisterAudioTap(identifier: id)
            }
            await UnifiedAudioManager.shared.stopCapture()
        }
    }
        // Centralized control-text sender with validation to avoid invalid types
    internal func sendControlText(_ json: String, expectedAttemptId: Int? = nil) async throws {
        // Allow only known control messages
        let isFinalize = json.contains("\"type\": \"finalize\"")
        let isKeepalive = json.contains("\"type\": \"keepalive\"")
        if !(isFinalize || isKeepalive) {
            logger.error("❌ [CONTROL] Refusing to send unknown control text: \(json.prefix(80))…")
            throw SonioxError.sessionNotConfigured
        }
        // Gate keepalive so it never precedes START on a fresh socket
        if isKeepalive && !startTextSentForCurrentSocket {
            logger.debug("⏸️ [KEEPALIVE] muted (start_text_sent=false)")
            throw SonioxError.sessionNotConfigured
        }
        // If the caller provided an expected attempt, ensure we are still on that generation
        if let expected = expectedAttemptId, expected != socketAttemptId {
            logger.debug("♻️ [CONTROL] Skipping control send for stale attemptId=\(expected); current=\(self.socketAttemptId)")
            throw SonioxError.sessionNotConfigured
        }
        guard let ws = webSocket else { throw SonioxError.sessionNotConfigured }
        try await ws.send(.string(json))
    }

    // MARK: - Speech Watchdog (speech-gated stall detection)
    

    

    // MARK: - External Warmup Helpers (bridges to ConnectionWarmupManager)
    func prewarmASRTransport() async {
        await warmupManager.prewarmASRTransport()
    }

    private func handleConverterFailure(_ snapshot: StreamingAudioProcessor.ConverterFailureSnapshot) async {
        let streak = await converterFailureTracker.increment(by: snapshot.occurrences)
        logger.warning("⚠️ [AUDIO CONVERTER] consecutive failures=\(streak) status=\(snapshot.status) input_sr=\(Int(snapshot.inputSampleRate)) input_ch=\(snapshot.inputChannels)")
        if streak >= converterFailureThreshold {
            await converterFailureTracker.reset()
            attemptConverterRecovery(snapshot: snapshot)
        }
    }

    private func attemptConverterRecovery(snapshot: StreamingAudioProcessor.ConverterFailureSnapshot) {
        let shouldTrigger: Bool = converterRecoveryQueue.sync {
            let now = Date()
            if converterRecoveryInFlight { return false }
            if let last = lastConverterRecoveryAt, now.timeIntervalSince(last) < 1.0 { return false }
            converterRecoveryInFlight = true
            lastConverterRecoveryAt = now
            return true
        }

        guard shouldTrigger else { return }

        logger.notice("🔁 [AUDIO CONVERTER] triggering capture refresh after failures (status=\(snapshot.status), sr=\(Int(snapshot.inputSampleRate)), ch=\(snapshot.inputChannels))")
        audioProcessor.resetConverter()

        Task.detached(priority: .utility) { [weak self] in
            await UnifiedAudioManager.shared.rebuildCapturePipeline(reason: "converter_failure")
            self?.converterRecoveryQueue.async {
                self?.converterRecoveryInFlight = false
            }
        }
    }
    private func recordTransportFailure(for errorType: ConnectionErrorType, context: String) async {
        switch errorType {
        case .networkError, .sslError, .connectionReset:
            break
        default:
            consecutiveTransportFailures = 0
            return
        }

        let now = Date()
        if let last = lastTransportFailureAt, now.timeIntervalSince(last) > transportFailureWindow {
            consecutiveTransportFailures = 0
        }
        lastTransportFailureAt = now
        consecutiveTransportFailures += 1

        logger.debug("📉 [TRANSPORT] failure #\(self.consecutiveTransportFailures) context=\(context)")

        if consecutiveTransportFailures >= 1 {
            consecutiveTransportFailures = 0
            await rebuildTransport(reason: "\(context)_\(errorType)", showBanner: isStreaming)
        }
    }

    func rebuildTransport(reason: String, showBanner: Bool) async {
        if isTransportResetting {
            logger.debug("⏳ [TRANSPORT] Reset already in progress — skipping (reason=\(reason))")
            return
        }
        let now = Date()
        if let last = lastTransportResetAt, now.timeIntervalSince(last) < transportResetCooldown {
            logger.debug("⏭️ [TRANSPORT] Reset skipped due to cooldown (reason=\(reason))")
            return
        }
        isTransportResetting = true
        lastTransportResetAt = now
        defer { isTransportResetting = false }

        logger.warning("🔄 [TRANSPORT] Rebuilding network stack (reason=\(reason))")

        readinessTimeoutTask?.cancel()
        continuationGate.cancelIfPending(SonioxError.sessionNotConfigured)
        inFlightConnect?.cancel()
        inFlightConnect = nil
        isConnecting = false
        webSocketReady = false

        if showBanner {
            ToastBanner.shared.show(title: "Reconnecting…", subtitle: "Refreshing network stack")
        }

        if isStreaming {
            await sendActor.pauseQueue()
        }

        await disconnectWebSocket(isRecovery: true)

        urlSession?.invalidateAndCancel()
        urlSession = nil
        ProxySessionManager.shared.rebuildSession()
        setupURLSession(isColdStart: true)

        if isStreaming {
            try? await Task.sleep(nanoseconds: 300_000_000)
            do {
                try await connectShared(source: .midRecovery, maxRetries: 3)
                await sendActor.resumeQueue()
                ToastBanner.shared.show(title: "Reconnected", subtitle: "Continuing transcription")
            } catch {
                logger.error("❌ [TRANSPORT] Failed to rebuild connection: \(error.localizedDescription)")
                await sendActor.resumeQueue()
                await MainActor.run {
                    self.connectionStatus = .error("Connection lost – please check your internet connection")
                }
                await stopStreaming()
            }
        } else {
            preconnectStandbyIfEnabled()
        }
    }
}

private actor ConverterFailureTracker {
    private var streak: Int = 0

    func increment(by amount: Int) -> Int {
        streak += amount
        return streak
    }

    func reset() {
        streak = 0
    }
}

    

// MARK: - Network Path Monitoring
extension SonioxStreamingService {
    private func recoverFromSendFailure(reason: String) async {
        guard isStreaming else { return }
        logger.error("🚑 [RECOVERY] Recovering from send failure: \(reason)")
        await sendActor.pauseQueue()
        await disconnectWebSocket()
        try? await Task.sleep(nanoseconds: 200_000_000)
        do {
            // Use single-flight to avoid overlapping attempts
            try await connectShared(source: .sendFailure, maxRetries: 3)
            await sendActor.resumeQueue()
        } catch {
            // Do NOT stop the session immediately. Keep buffering and retry in background briefly.
            logger.error("❌ Send-failure recovery failed: \(error.localizedDescription)")
            let errorType = classifyError(error)
            await recordTransportFailure(for: errorType, context: "send_failure")
            await MainActor.run { self.connectionStatus = .connecting }
            self.connectWithRetry(maxRetries: 3, initialDelay: 0.5)
        }
    }
}

// MARK: - Error Types

enum SonioxError: LocalizedError {
    case invalidEndpoint
    case sessionNotConfigured
    case audioFormatSetupFailed
    case missingAPIKey
    
    var errorDescription: String? {
        switch self {
        case .invalidEndpoint:
            return "Invalid Soniox WebSocket endpoint"
        case .sessionNotConfigured:
            return "URL session not configured"
        case .audioFormatSetupFailed:
            return "Failed to setup audio format"
        case .missingAPIKey:
            return "Add a Soniox API key in Settings → Cloud Access"
        }
    }
}

// MARK: - URLSessionTaskDelegate (Handshake metrics)
extension SonioxStreamingService {
    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        StreamingDiagnostics.logHandshakeMetrics(socketId: currentSocketId, attempt: socketAttemptId, metrics: metrics)
    }
}
