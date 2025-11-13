import Foundation
import SwiftUI
import AVFoundation
import SwiftData
import AppKit
import KeyboardShortcuts
import os
import Combine

@MainActor
class RecordingEngine: NSObject, ObservableObject, AVAudioRecorderDelegate {
    // When set, the next completed transcript will be treated as a command instruction
    // instead of being pasted. The string passed is the spoken instruction.
    var commandModeCallback: ((String) -> Task<Void, Never>)? = nil
    @Published var isModelLoaded = false
    @Published var canTranscribe = false
    @Published var isRecording = false
    @Published var isAttemptingToRecord = false  // Set immediately when recording is initiated
    @Published var currentModel: WhisperModel?
    @Published var isModelLoading = false
    @Published var availableModels: [WhisperModel] = []
    // Local Whisper model management is disabled in this build; keep empty list to satisfy bindings.
    @Published var predefinedModels: [PredefinedModel] = PredefinedModels.models
    @Published var clipboardMessage = ""
    @Published var miniRecorderError: String?
    @Published var isProcessing = false
    @Published var shouldCancelRecording = false
    @Published var isTranscribing = false
    @Published var transcriptionProgress: CGFloat = 0.0
    private var progressTimer: Timer?
    
    // Streaming transcript for real-time display
    @Published var streamingPartialText: String = ""
    @Published var streamingFinalText: String = ""
    // Single render payload to enable atomic UI updates
    @Published var streamingAttributed: AttributedString = AttributedString("")
    // Layered rendering payloads for soft styling in the view
    @Published var streamingFinalCrispAttributed: AttributedString = AttributedString("")
    @Published var streamingPartialOverlayAttributed: AttributedString = AttributedString("")
    // Increments when partial is promoted to final (for subtle fade cues)
    @Published var streamingPromotionCounter: Int = 0
    
    // Session state machine
    enum RecorderMode { case ptt, hf }
    enum SessionState: Equatable {
        case idle
        case showingLightweight(gen: UInt64)
        case starting(mode: RecorderMode, gen: UInt64)
        case recording(mode: RecorderMode, gen: UInt64)
        case stopping(gen: UInt64)
        case cancelling(gen: UInt64)
    }
    @Published var sessionState: SessionState = .idle
    var uiGenerationCounter: UInt64 = 0
    @Published var recorderMode: RecorderMode = .ptt
    
    // Track current UI generation token from the notch manager to guard hides
    @Published var currentUIGenerationToken: UInt64? = nil

    // MiniRecorder mode setting
    var isStreamingTranscriptEnabled: Bool {
        UserDefaults.standard.bool(forKey: "streamingTranscriptEnabled")
    }
    
    // Progress tracking phases
    private func updateTranscriptionProgress(to phase: TranscriptionPhase) {
        Task { @MainActor in
            let targetProgress: CGFloat = {
                switch phase {
                case .starting: return 0.0
                case .transcriptionComplete: return 0.55  // More realistic for streaming complete
                case .processingComplete: return 0.85     // AI enhancement starts  
                case .enhancementComplete: return 1.0     // Completion
                case .finished: return 1.0
                }
            }()
            
            withAnimation(.easeOut(duration: 0.4)) {
                transcriptionProgress = targetProgress
            }
        }
    }
    
    // Add random progress increments between milestones
    private func addRandomProgress(maxIncrease: CGFloat = 0.1) {
        Task { @MainActor in
            let randomIncrease = CGFloat.random(in: 0.02...maxIncrease)
            let newProgress = min(transcriptionProgress + randomIncrease, 0.95) // Never exceed 95% before final milestone
            
            withAnimation(.easeOut(duration: Double.random(in: 0.2...0.6))) {
                transcriptionProgress = newProgress
            }
        }
    }
    
    private func prepareRawTranscript(from text: String, applyWordReplacement: Bool) -> String {
        var output = text
        if applyWordReplacement && UserDefaults.standard.bool(forKey: "IsWordReplacementEnabled") {
            output = WordReplacementService.shared.applyReplacements(to: output)
        }
        let cleaned = RawDisfluencySanitizer.clean(output)
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func startProgressTimer() {
        stopProgressTimer() // Clean up any existing timer
        // Do not start progress timer when using notch recorder; notch uses triangle loader
        guard recorderType != "notch" else { return }
        progressTimer = Timer.scheduledTimer(withTimeInterval: Double.random(in: 1.2...1.8), repeats: true) { [weak self] _ in
            guard let self = self else { return }
            // Update progress; component no longer animates each tick
            self.addRandomProgress(maxIncrease: 0.06)
        }
    }
    
    func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }
    
    private enum TranscriptionPhase {
        case starting
        case transcriptionComplete
        case processingComplete  
        case enhancementComplete
        case finished
    }
    @Published var isAutoCopyEnabled: Bool = UserDefaults.standard.object(forKey: "IsAutoCopyEnabled") as? Bool ?? true {
        didSet {
            UserDefaults.standard.set(isAutoCopyEnabled, forKey: "IsAutoCopyEnabled")
        }
    }
    // Initialize recorder type from UserDefaults
    @Published var recorderType: String = "notch" // Default to notch recorder
    // @Published var recorderType: String = UserDefaults.standard.bool(forKey: "RecorderStyleIsNotch") ? "notch" : "mini"
    var notchWindowManager: DynamicNotchWindowManager?
    
    @Published var isVisualizerActive = false
    // Reflect hands-free lock state for UI badges (set by HotkeyManager)
    @Published var isHandsFreeLocked: Bool = false

    // Suppress global system paste when certain UI (e.g., Try It) wants to manage output locally
    @Published var suppressSystemPaste: Bool = false
    // Expose the last final output (enhanced if available) so views can render without system paste
    @Published var lastOutputText: String = ""
    
    // Track recording sessions so duplicate stop invocations do not re-run the pipeline
    private var currentRecordingSessionID: UUID?
    private var stopPipelineInFlightSessionID: UUID?
    private var lastCompletedRecordingSessionID: UUID?
    
    // PHASE 3: Update @Published properties from state machine's view model
    func updateFromStateMachine() async {
        guard useStateMachineForState, let stateMachine = recorderStateMachine else { return }
        
        let viewModel = await stateMachine.getViewModel()
        let currentState = await stateMachine.getCurrentState()
        
        await MainActor.run {
            // Only update properties if they have actually changed to avoid unnecessary UI updates
            if self.isRecording != viewModel.isRecording {
                self.isRecording = viewModel.isRecording
            }
            if self.isAttemptingToRecord != viewModel.isAttemptingToRecord {
                self.isAttemptingToRecord = viewModel.isAttemptingToRecord
            }
            if self.isHandsFreeLocked != viewModel.isHandsFreeLocked {
                self.isHandsFreeLocked = viewModel.isHandsFreeLocked
            }
            if self.canTranscribe != viewModel.canTranscribe {
                self.canTranscribe = viewModel.canTranscribe
            }
            if self.isVisualizerActive != viewModel.isVisualizerActive {
                self.isVisualizerActive = viewModel.isVisualizerActive
            }
            
            // PHASE 3: Update sessionState to match state machine's state
            let newSessionState: SessionState = {
                switch currentState {
                case .idle:
                    return .idle
                case .lightweightShown:
                    return .showingLightweight(gen: self.uiGenerationCounter)
                case .pttActive:
                    return .recording(mode: .ptt, gen: self.uiGenerationCounter)
                case .handsFreeLocked:
                    return .recording(mode: .hf, gen: self.uiGenerationCounter)
                case .stopping:
                    return .stopping(gen: self.uiGenerationCounter)
                }
            }()
            
            if self.sessionState != newSessionState {
                self.sessionState = newSessionState
            }
        }
    }
    @Published var showCancelConfirmation = false
    /// High-frequency audio level updates are now delivered via `audioLevel` to avoid
    /// triggering objectWillChange on every 20 Hz tick.  Views that need the level
    /// should observe `audioLevel.level` instead.
    var currentAudioMeter: AudioMeter = AudioMeter(averagePower: 0, peakPower: 0)

    /// Lightweight publisher dedicated to high-frequency audio-meter updates so that other views don’t have to observe RecordingEngine directly.
    let audioLevel = AudioLevelPublisher()
    /// Rendering cache for streaming transcript snapshots (crisp + overlay)
    let streamingTextCache = StreamingTextCache()
    
    @Published var isMiniRecorderVisible = false {
        didSet {
            if isMiniRecorderVisible {
                showRecorderPanel()
            } else {
                hideRecorderPanel()
            }
        }
    }
    
    // Latency tracking
    private var processingStartTime: Date? // T0: when recording stops
    
    // Local Whisper removed
    var whisperContext: WhisperContext?
    var vadContext: WhisperVADContext?
    let recorder = Recorder()
    var recordedFile: URL? = nil
    let whisperPrompt = WhisperPrompt()
    
    // Prompt detection service for trigger word handling
    private let promptDetectionService = PromptDetectionService()
    
    let modelContext: ModelContext
    
    private var modelUrl: URL? {
        let possibleURLs = [
            Bundle.main.url(forResource: "ggml-base.en", withExtension: "bin", subdirectory: "Models"),
            Bundle.main.url(forResource: "ggml-base.en", withExtension: "bin"),
            Bundle.main.bundleURL.appendingPathComponent("Models/ggml-base.en.bin")
        ]
        
        for url in possibleURLs {
            if let url = url, FileManager.default.fileExists(atPath: url.path) {
                return url
            }
        }
        return nil
    }
    
    private enum LoadError: Error {
        case couldNotLocateModel
    }
    
    let modelsDirectory: URL
    let recordingsDirectory: URL
    let enhancementService: AIEnhancementService?
    let contextService: ContextService?
    var licenseViewModel: LicenseViewModel
    let sonioxStreamingService = SonioxStreamingService()
    private let subscriptionManager = SubscriptionManager.shared
    private let modelAccessControl = ModelAccessControl.shared
    let logger = Logger(subsystem: "com.jetsonai.clio", category: "RecordingEngine")
    private var cancellables: Set<AnyCancellable> = []
    // Notch recorder removed (no instance kept)
    var miniWindowManager: MiniWindowManager?
    var cancelConfirmationWindowManager: CancelConfirmationWindowManager?
    // Track temporary input override when AirPods output is active
    private var previousInputDeviceID: AudioDeviceID?
    private var didOverrideInputThisSession: Bool = false
    
    // For model progress tracking
    @Published var downloadProgress: [String: Double] = [:]
    
    /// Keeps strong references to download progress observations so they are not
    /// deallocated prematurely while a download is in progress. The key is the
    /// same `progressKey` used in the `downloadProgress` dictionary.
    var downloadObservations: [String: NSKeyValueObservation] = [:]
    
    // PHASE 3: Reference to state machine for consolidated state
    private var recorderStateMachine: RecorderStateMachine?
    private var useStateMachineForState: Bool = false
    
    // PHASE 3: Post-initialization setup for state machine connection
    func setupRecorderStateMachine(_ stateMachine: RecorderStateMachine) {
        self.recorderStateMachine = stateMachine
        self.useStateMachineForState = UserDefaults.standard.bool(forKey: "EnableRecorderStateMachine")
        print("🎯 [WHISPER STATE] State machine connected, enabled: \(useStateMachineForState)")
    }
    
    init(modelContext: ModelContext, enhancementService: AIEnhancementService? = nil, contextService: ContextService? = nil) {
        self.modelContext = modelContext
        self.modelsDirectory = RecordingEngine.resolveModelsDirectory()
        self.recordingsDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(Bundle.main.bundleIdentifier ?? "com.cliovoice.clio")
            .appendingPathComponent("Recordings")
        self.enhancementService = enhancementService
        self.contextService = contextService
        self.licenseViewModel = LicenseViewModel.shared
        
        super.init()
        
        sonioxStreamingService.contextService = contextService
        
        // Bind streaming transcript from Soniox service
        setupStreamingTranscriptBinding()
        
        setupNotifications()
        createModelsDirectoryIfNeeded()
        createRecordingsDirectoryIfNeeded()
        loadAvailableModels()
        // Ensure cloud streaming models are always available in non-local builds
        registerStreamingModelsIfNeeded()
        
        // Initialize cancel confirmation window manager
        cancelConfirmationWindowManager = CancelConfirmationWindowManager(recordingEngine: self)
        
        // Setup audio meter updates
        setupAudioMeterUpdates()
        
        // Initialize VAD context
        // TEMPORARILY DISABLED: Testing VAD corruption hypothesis - causes UI freeze
        // Task {
        //     await initializeVAD()
        // }
        
        // Initialize always-on mini recorder immediately to avoid first-press race condition
        initializeAlwaysOnMiniRecorder()
        
        // Set canTranscribe immediately for cloud models to avoid first-press race condition
        let useLocalModel = UserDefaults.standard.bool(forKey: "UseLocalModel")
        if !useLocalModel {
            canTranscribe = true
            // logger.notice("✅ [RecordingEngine init] canTranscribe enabled immediately for cloud setup")
        }
        
        if let savedModelName = UserDefaults.standard.string(forKey: "CurrentModel") {
            // logger.notice("🔍 [RecordingEngine init] Saved model name from UserDefaults: \(savedModelName)")
            if let savedModel = availableModels.first(where: { $0.name == savedModelName }) {
                currentModel = savedModel
                // logger.notice("✅ [RecordingEngine init] Restored current model: \(savedModel.name)")
            } else {
                logger.error("❌ [RecordingEngine init] Could not find saved model in availableModels")
                logger.notice("📋 [RecordingEngine init] Available models: \(self.availableModels.map { $0.name })")
                // Set default to Clio Ultra if saved model not found
                setDefaultToClioUltra()
            }
        } else {
            logger.notice("⚠️ [RecordingEngine init] No saved model in UserDefaults")
            // Set default to Clio Ultra on first launch
            setDefaultToClioUltra()
        }
    }

    /// Inserts streaming (cloud) models into `availableModels` if missing so that
    /// the app can operate without any local Whisper downloads.
    private func registerStreamingModelsIfNeeded() {
        let sonioxId = "soniox-realtime-streaming"
        if !availableModels.contains(where: { $0.name == sonioxId }) {
            let dummy = URL(string: "https://cloud/soniox")!
            availableModels.append(WhisperModel(name: sonioxId, url: dummy))
        }
    }
    
    private func createRecordingsDirectoryIfNeeded() {
        do {
            try FileManager.default.createDirectory(at: recordingsDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            logger.error("Error creating recordings directory: \(error.localizedDescription)")
        }
    }
    
    private func setupStreamingTranscriptBinding() {
        let processingQueue = DispatchQueue(label: "com.cliovoice.clio.streaming.render", qos: .userInitiated)
        // Publish an atomic combined model each frame to prevent duplicate-render flashes.
        let partialPub = sonioxStreamingService.$partialTranscript
            .throttle(for: .seconds(0.016), scheduler: DispatchQueue.main, latest: true)
            .removeDuplicates()

        let finalPub = sonioxStreamingService.$finalBuffer
            .removeDuplicates()

        // Payload for logging + equality coalescing
        struct StreamingRenderPayload: Equatable {
            let attributed: AttributedString
            let finalLen: Int
            let partialExclusiveLen: Int
            let dropCount: Int
            let finalTailTokens: [String]
            let partialHeadTokens: [String]
            let crisp: AttributedString
            let blurOverlay: AttributedString
        }

        Publishers.CombineLatest(finalPub, partialPub)
            .receive(on: processingQueue)
            .map { [weak self] (finalText, partialText) -> StreamingRenderPayload in
                guard let self = self else {
                    return StreamingRenderPayload(
                        attributed: AttributedString(""),
                        finalLen: 0,
                        partialExclusiveLen: 0,
                        dropCount: 0,
                        finalTailTokens: [],
                        partialHeadTokens: [],
                        crisp: AttributedString(""),
                        blurOverlay: AttributedString("")
                    )
                }

                // Compute overlap (token-first, then char-normalized fallback)
                let dropToken = self.computeTokenBoundaryOverlapDropCount(final: finalText, partial: partialText)
                let dropChar = self.computeCharOverlapDropCount(final: finalText, partial: partialText)
                let drop = max(dropToken, dropChar) // prefer stricter drop

                var sanitized = String(partialText.dropFirst(drop))
                if !finalText.isEmpty {
                    while let f = sanitized.first, f.isWhitespace { sanitized.removeFirst() }
                }

                // Build attributed output using raw final/partial; do NOT run replacements here.
                // Replacements should be applied only once to the final text at commit time.
                var out = AttributedString("")
                if !finalText.isEmpty {
                    var a = AttributedString(finalText)
                    a.foregroundColor = .white
                    out += a
                }
                if !finalText.isEmpty && !sanitized.isEmpty {
                    if self.needsBoundarySpace(between: finalText, and: sanitized) {
                        var space = AttributedString(" ")
                        space.foregroundColor = .white
                        out += space
                    }
                }
                if !sanitized.isEmpty {
                    var p = AttributedString(sanitized)
                    p.foregroundColor = Color.white.opacity(0.6)
                    out += p
                }

                // Build crisp (final only)
                var crisp = AttributedString("")
                if !finalText.isEmpty {
                    var a = AttributedString(finalText)
                    a.foregroundColor = .white
                    crisp += a
                }

                // Build blur overlay: transparent final prefix + partial with soft shadow
                var blur = AttributedString("")
                if !finalText.isEmpty {
                    let spacer = (!sanitized.isEmpty && self.needsBoundarySpace(between: finalText, and: sanitized)) ? " " : ""
                    var transparentPrefix = AttributedString(finalText + spacer)
                    transparentPrefix.foregroundColor = Color.white.opacity(0.0)
                    blur += transparentPrefix
                }
                if !sanitized.isEmpty {
                    var p = AttributedString(sanitized)
                    p.foregroundColor = Color.white.opacity(0.8)
                    blur += p
                }

                let finalTokens = self.tokenizeNormalized(finalText)
                let partialTokens = self.tokenizeNormalized(sanitized)
                let tail = Array(finalTokens.suffix(6))
                let head = Array(partialTokens.prefix(6))

                return StreamingRenderPayload(
                    attributed: out,
                    finalLen: finalText.count,
                    partialExclusiveLen: sanitized.count,
                    dropCount: drop,
                    finalTailTokens: tail,
                    partialHeadTokens: head,
                    crisp: crisp,
                    blurOverlay: blur
                )
            }
            // Coalesce to display-frame cadence off-main and keep latest
            .collect(.byTime(processingQueue, .milliseconds(16)))
            .compactMap { $0.last }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] payload in
                guard let self = self else { return }
                // Update cache snapshot for Timeline-driven views
                self.streamingTextCache.set(StreamingTextCache.Snapshot(crisp: payload.crisp, overlay: payload.blurOverlay))
                // Maintain existing published properties for compatibility
                self.streamingAttributed = payload.attributed
                self.streamingFinalCrispAttributed = payload.crisp
                self.streamingPartialOverlayAttributed = payload.blurOverlay
                self._streamingEpoch &+= 1
                let epoch = self._streamingEpoch
                if payload.dropCount > 0 { self.streamingPromotionCounter &+= 1 }
                // UI first-paint signal for TTFT watchdog (idempotent)
                if payload.finalLen > 0 || payload.partialExclusiveLen > 0 {
                    Task { @MainActor in
                        self.sonioxStreamingService.noteUIPaintedFirstToken()
                    }
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Overlap sanitization helpers
    // Character-normalized overlap (fallback)
    private func computeCharOverlapDropCount(final: String, partial: String) -> Int {
        let finalNorm = buildNormalizedStream(for: final, mapCounts: false)
        let partialNorm = buildNormalizedStream(for: partial, mapCounts: true)
        let finalChars = finalNorm.chars
        let partialChars = partialNorm.chars
        let partialPrefixCounts = partialNorm.prefixOriginalCounts

        guard !finalChars.isEmpty, !partialChars.isEmpty else { return 0 }
        let limit = min(finalChars.count, partialChars.count)
        if limit == 0 { return 0 }
        var k = limit
        while k > 0 {
            if Array(finalChars.suffix(k)) == Array(partialChars.prefix(k)) {
                return partialPrefixCounts[k - 1]
            }
            k -= 1
        }
        return 0
    }

    // Token-boundary overlap within a small window. Returns number of ORIGINAL characters
    // to drop from partial to eliminate the overlapped prefix.
    private func computeTokenBoundaryOverlapDropCount(final: String, partial: String, window: Int = 20) -> Int {
        // Tokenize streams (normalized to alphanumerics-only tokens)
        let finalTokens = tokenizeNormalized(final)
        let (partialTokens, partialTokenPrefixCounts) = tokenizeNormalizedWithPrefixCounts(partial)

        guard !finalTokens.isEmpty, !partialTokens.isEmpty else { return 0 }
        let searchLimit = min(window, min(finalTokens.count, partialTokens.count))
        if searchLimit == 0 { return 0 }

        var k = searchLimit
        while k > 0 {
            if Array(finalTokens.suffix(k)) == Array(partialTokens.prefix(k)) {
                // Map token count -> original character count using the end index of kth token
                return partialTokenPrefixCounts[k - 1]
            }
            k -= 1
        }
        return 0
    }

    // Tokenization helpers (normalized)
    // Produces lowercase alphanumeric tokens; non-alphanumerics act as separators.
    private func tokenizeNormalized(_ s: String) -> [String] {
        var tokens: [String] = []
        var current: String = ""
        for ch in s.lowercased() {
            if ch.isLetter || ch.isNumber {
                current.append(ch)
            } else {
                if !current.isEmpty { tokens.append(current); current.removeAll(keepingCapacity: true) }
            }
        }
        if !current.isEmpty { tokens.append(current) }
        return tokens
    }

    // Same as tokenizeNormalized but also returns, for the PARTIAL string, the original
    // character count at the end of each token.
    private func tokenizeNormalizedWithPrefixCounts(_ s: String) -> ([String], [Int]) {
        var tokens: [String] = []
        var prefixCounts: [Int] = []
        var current: String = ""
        var index: Int = 0
        for ch in s.lowercased() {
            index += 1 // count original characters
            if ch.isLetter || ch.isNumber {
                current.append(ch)
            } else {
                if !current.isEmpty {
                    tokens.append(current)
                    prefixCounts.append(index - 1) // token ended just before this separator
                    current.removeAll(keepingCapacity: true)
                }
            }
        }
        if !current.isEmpty {
            tokens.append(current)
            prefixCounts.append(index)
        }
        return (tokens, prefixCounts)
    }

    private func buildNormalizedStream(for s: String, mapCounts: Bool) -> (chars: [Character], prefixOriginalCounts: [Int]) {
        var chars: [Character] = []
        var counts: [Int] = []
        var originalCount = 0
        var previous: Character? = nil
        for ch in s {
            originalCount += 1
            guard let norm = normalize(ch) else { continue }
            if norm == " " && previous == " " { continue }
            chars.append(norm)
            previous = norm
            if mapCounts { counts.append(originalCount) }
        }
        return (chars, counts)
    }

    private func normalize(_ ch: Character) -> Character? {
        if ch.isWhitespace { return " " }
        let dashes: Set<Character> = ["-", "–", "—", "−"]
        if dashes.contains(ch) { return "-" }
        let zeroWidth: Set<Character> = ["\u{200B}", "\u{200C}", "\u{200D}"]
        if zeroWidth.contains(ch) { return nil }
        let quotes: Set<Character> = ["“", "”", "‟", "❝", "❞", "＂"]
        if quotes.contains(ch) { return "\"".first }
        let apostrophes: Set<Character> = ["'", "’", "ʼ", "＇"]
        if apostrophes.contains(ch) { return "'".first }
        return String(ch).lowercased().first
    }

    /// Determines whether a visible space is needed between `final` and `partial`
    /// to avoid concatenating two word fragments into a single incorrect token
    /// (e.g., "make d" + "ictation" → "make dictation").
    private func needsBoundarySpace(between final: String, and partial: String) -> Bool {
        guard let lastFinal = final.last, let firstPartial = partial.first else { return false }
        let isFinalAlnum = lastFinal.isLetter || lastFinal.isNumber
        let isPartialAlnum = firstPartial.isLetter || firstPartial.isNumber
        // Insert a space only when both sides are alphanumeric and final does not end with hyphen
        if isFinalAlnum && isPartialAlnum {
            // Avoid extra space when language is CJK (Chinese/Japanese/Korean) where spacing is not used
            if lastFinal.isCJK || firstPartial.isCJK { return false }
            if lastFinal == "-" { return false }
            return true
        }
        return false
    }


    // Sequence number for streaming render emissions
    private var _streamingEpoch: Int = 0
    
    private func setDefaultToClioUltra() {
        // Check UseLocalModel preference
        let useLocalModel = UserDefaults.standard.bool(forKey: "UseLocalModel")
        
        if useLocalModel {
            // Check if any local model is available; avoid silently falling back to cloud.
            if let turboModel = availableModels.first(where: { $0.name == "ggml-large-v3-turbo" }) {
                currentModel = turboModel
                UserDefaults.standard.set("ggml-large-v3-turbo", forKey: "CurrentModel")
                logger.notice("🔒 [RecordingEngine init] UseLocalModel enabled - set default to Whisper v3 Turbo")
            } else if let anyLocal = availableModels.first(where: { $0.url.isFileURL }) {
                currentModel = anyLocal
                UserDefaults.standard.set(anyLocal.name, forKey: "CurrentModel")
                logger.notice("🔒 [RecordingEngine init] UseLocalModel enabled - using local model \(anyLocal.name)")
            } else {
                logger.notice("⚠️ [RecordingEngine init] UseLocalModel enabled but no local models present - waiting for download")
                canTranscribe = false
            }
        } else {
            // Default to Soniox (cloud)
            setDefaultToStreamingModel()
        }
    }
    
    private func setDefaultToStreamingModel() {
        // Automatically choose the best streaming model based on language selection
        // Ensure streaming models are present
        registerStreamingModelsIfNeeded()
        if let streamingModel = getStreamingModelForLanguage() {
            // Set both UserDefaults and currentModel
            currentModel = streamingModel
            UserDefaults.standard.set(streamingModel.name, forKey: "CurrentModel")
            canTranscribe = true
            // logger.notice("🎯 [RecordingEngine init] Set default model to: \(streamingModel.name)")
            // logger.notice("✅ [RecordingEngine init] canTranscribe set to true for cloud model")
        } else {
            logger.error("❌ [RecordingEngine init] No streaming model found in availableModels")
            logger.notice("📋 [RecordingEngine init] Available models: \(self.availableModels.map { $0.name })")
            logger.notice("📋 [RecordingEngine init] Predefined models: \(self.predefinedModels.map { $0.name })")
        }
    }

    func activateStreamingMode() {
        setDefaultToStreamingModel()
    }
    
    private func initializeVAD() async {
        // logger.info("🚀 Starting VAD initialization...")
        // Local VAD removed
        vadContext = nil
        
        // Check if VAD model exists, if not download it
        // logger.info("📍 VAD model path: \(self.vadModelPath)")
        // Skip VAD model download
        
        // Initialize VAD with model
        // No VAD initialization
    }
    
    func toggleRecord() async {
        if isRecording {
            // Reset attempt flag when stopping
            await MainActor.run {
                isAttemptingToRecord = false
            }
            logger.notice("🛑 Stopping recording")
            
            if let inFlight = stopPipelineInFlightSessionID {
                logger.notice("🧯 [STOP GUARD] Stop pipeline already running for session \(inFlight); ignoring duplicate request.")
                return
            }
            
            var resolvedSessionID = currentRecordingSessionID
            if resolvedSessionID == nil {
                resolvedSessionID = UUID()
                currentRecordingSessionID = resolvedSessionID
                if let resolved = resolvedSessionID {
                    logger.debug("🧩 [STOP GUARD] Generated session id for legacy path: \(resolved)")
                }
            }
            
            if let lastCompleted = lastCompletedRecordingSessionID,
               let resolved = resolvedSessionID,
               lastCompleted == resolved {
                logger.notice("🧯 [STOP GUARD] Session \(resolved) already finalized; skipping duplicate stop pipeline.")
                return
            }
            
            guard let activeSessionID = resolvedSessionID else {
                logger.warning("⚠️ [STOP GUARD] Unable to resolve session id; skipping duplicate guard fallback.")
                return
            }
            
            stopPipelineInFlightSessionID = activeSessionID
            defer {
                stopPipelineInFlightSessionID = nil
                lastCompletedRecordingSessionID = activeSessionID
                currentRecordingSessionID = nil
            }
            
            // Check if we're using streaming transcription
            let isSonioxModel = currentModel?.name == "soniox-realtime-streaming" // Clio Ultra
            let isStreamingModel = isSonioxModel
            
            await self.setSessionStateStopping()
            await MainActor.run {
                isRecording = false
                isAttemptingToRecord = false  // Reset attempt flag
                isVisualizerActive = false
                isHandsFreeLocked = false     // Ensure HF badge is cleared on stop
                processingStartTime = Date()
                
                // Set processing state immediately for streaming models to show wave visualizer
                if isStreamingModel {
                    isProcessing = true
                    isTranscribing = true
                    canTranscribe = false
                    updateTranscriptionProgress(to: .starting)
                    startProgressTimer()
                }
            }
            
            if isSonioxModel {
                // Stop Soniox streaming and get final transcript
                await sonioxStreamingService.stopStreaming()
                if !shouldCancelRecording {
                    await handleStreamingTranscriptionComplete()
                }
            } else {
                // Traditional batch processing
                await recorder.stopRecording()
                if let recordedFile {
                    if !shouldCancelRecording {
                        await transcribeAudio(recordedFile)
                    }
                } else {
                    logger.error("❌ No recorded file found after stopping recording")
                }
            }

            // Restore previous input if we temporarily overrode it for AirPods route
            if didOverrideInputThisSession, let prev = previousInputDeviceID {
                do {
                    try await Task.detached(priority: .userInitiated) {
                        try AudioDeviceConfiguration.setDefaultInputDevice(prev)
                    }.value
                } catch {
                    logger.warning("⚠️ Failed to restore previous input device: \(error.localizedDescription)")
                }
                didOverrideInputThisSession = false
                previousInputDeviceID = nil
            }
        } else {
            // Note: isAttemptingToRecord is now set earlier in toggleMiniRecorder() for immediate UI response
            
            // print("🎙️ [TOGGLERECORD DEBUG] ===============================================")
            // print("🎙️ [TOGGLERECORD DEBUG] Starting recording attempt")
            // print("🎙️ [TOGGLERECORD DEBUG] Current model: \(self.currentModel?.name ?? "nil")")
            // print("🎙️ [TOGGLERECORD DEBUG] canTranscribe: \(self.canTranscribe)")
            
            logger.notice("🎤 [toggleRecord] Starting recording, current model: \(self.currentModel?.name ?? "nil")")
            if self.currentModel == nil {
                // Auto-select a streaming model when none is chosen
                setDefaultToStreamingModel()
            }
            guard self.currentModel != nil else {
                // print("🎙️ [TOGGLERECORD DEBUG] ❌ BLOCKED: No model selected and no streaming fallback available!")
                await MainActor.run { isAttemptingToRecord = false }
                logger.error("❌ [toggleRecord] No model selected and no streaming fallback available!")
                return
            }
            
            shouldCancelRecording = false
            // print("🎙️ [TOGGLERECORD DEBUG] ✅ All checks passed - starting recording sequence")
            // Non-blocking, idempotent warmup on hotkey
            WarmupCoordinator.shared.ensureReady(.hotkeyDown)
            logger.notice("🎙️ Starting recording sequence...")

            if recorderType == "notch" {
                let modeLabel: String
                switch recorderMode {
                case .hf:
                    modeLabel = "hf"
                case .ptt:
                    modeLabel = "ptt"
                @unknown default:
                    modeLabel = "unknown"
                }
                TimingMetrics.shared.markNotchIntent(mode: modeLabel)
                var fields: [String: Any] = [
                    "mode": modeLabel,
                    "hf_locked": isHandsFreeLocked
                ]
                fields["recorder_type"] = recorderType
                StructuredLog.shared.log(cat: .ui, evt: "notch_intent", lvl: .info, fields)
            }
            
            // Start tracking recording session for grace period
            // print("🎙️ [TOGGLERECORD DEBUG] Starting recording session tracking...")
            subscriptionManager.startRecordingSession()
            // print("🎙️ [TOGGLERECORD DEBUG] ===============================================")
            
            // Set up OCR completion callback for NER pre-warming instead of immediate pre-warming
            setupOCRCompletionCallback()
            
            let pendingSessionID = UUID()
            
            requestRecordPermission { [self, pendingSessionID] granted in
                // print("🎙️ [RECORD PERMISSION DEBUG] Permission granted: \(granted)")
                // print("🎙️ [RECORD PERMISSION DEBUG] Thread: \(Thread.current)")
                // print("🎙️ [RECORD PERMISSION DEBUG] Time since app launch: \(String(format: "%.2f", Date().timeIntervalSince(Date())))s")
                if granted {
                    Task {
                        // print("🎙️ [ASYNC TASK DEBUG] Starting async recording task...")
                        // print("🎙️ [ASYNC TASK DEBUG] Task thread: \(Thread.current)")
                        var sessionAssigned = false
                        do {
                            // Route policy: Prefer built-in mic when AirPods (Bluetooth) are output to avoid HFP switch
                            if RuntimeConfig.preferBuiltinMicForAirPodsOutput && AudioDeviceManager.shared.isCurrentOutputBluetooth {
                                // Save current input to restore later
                                let currentInputId = AudioDeviceManager.shared.getCurrentDevice()
                                self.previousInputDeviceID = currentInputId

                                // Prefer built-in/internal Mac microphone and exclude Continuity/iOS devices
                                let candidates = AudioDeviceManager.shared.availableDevices
                                let nonBt = candidates.first { device in
                                    let n = device.name.lowercased()
                                    if n.contains("airpods") || n.contains("bluetooth") || n.contains("beats") { return false }
                                    if n.contains("iphone") || n.contains("ipad") || n.contains("continuity") || n.contains("sidecar") { return false }
                                // Prefer internal/built-in mics (avoid generic "microphone" which matches iPhone Microphone)
                                return n.contains("built-in") || n.contains("internal") || n.contains("macbook")
                                } ?? candidates.first { device in
                                    let n = device.name.lowercased()
                                    return !n.contains("airpods") && !n.contains("bluetooth") && !n.contains("beats") && !n.contains("iphone") && !n.contains("ipad")
                                }

                                if let chosen = nonBt {
                                    do {
                                        try await Task.detached(priority: .userInitiated) {
                                            try AudioDeviceConfiguration.setDefaultInputDevice(chosen.id)
                                        }.value
                                        self.didOverrideInputThisSession = true
                                    } catch {
                                        self.logger.warning("⚠️ Failed to set non-Bluetooth input: \(error.localizedDescription)")
                                        self.didOverrideInputThisSession = false
                                    }
                                }
                            }

                            // Re-evaluate model choice based on current language settings
                            // print("🎙️ [ASYNC TASK DEBUG] Re-evaluating model for language settings...")
                            self.reevaluateModelForLanguageSettings()
                            
                            // Start screen context capture in background (non-blocking)
                            if let contextService = self.contextService {
                                Task {
                                    await contextService.captureScreenContext()
                                }
                            }
                            
                            // Check if we're using streaming transcription
                            let isSonioxModel = self.currentModel?.name == "soniox-realtime-streaming"
                            let isStreamingModel = isSonioxModel
                            
                            // print("🎙️ [ASYNC TASK DEBUG] Model type: \(self.currentModel?.name ?? "nil"), isStreaming: \(isStreamingModel)")
                            
                            if isSonioxModel {
                                // print("🎙️ [SONIOX DEBUG] Starting Soniox streaming transcription...")
                                // Start Soniox streaming transcription
                                // Starting Soniox streaming
                                // print("🎙️ [SONIOX DEBUG] Calling wakeAudioSystemIfNeeded()...")
                                let t0 = Date()
                                if !RuntimeConfig.disableAudioWake {
                                    await self.wakeAudioSystemIfNeeded()
                                    let dt = Int(Date().timeIntervalSince(t0) * 1000)
                                    StructuredLog.shared.log(cat: .audio, evt: "audio_wake", lvl: .info, ["dt_ms": dt, "skipped": false])
                                } else {
                                    StructuredLog.shared.log(cat: .audio, evt: "audio_wake", lvl: .info, ["skipped": true])
                                }
                                // If we just changed input to avoid AirPods HFP, allow route to stabilize briefly
                                if self.didOverrideInputThisSession {
                                    try? await Task.sleep(nanoseconds: 250_000_000)
                                }
                                // print("🎙️ [SONIOX DEBUG] Calling sonioxStreamingService.startStreaming()...")
                                // Run streaming start off-main to avoid MainActor inheritance
                                let svc = self.sonioxStreamingService
                                await Task.detached(priority: .userInitiated) {
                                    await svc.startStreaming()
                                }.value
                                // print("🎙️ [SONIOX DEBUG] Soniox streaming started successfully!")
                                print("⏱️ [TIMING] mic_engaged @ \(String(format: "%.3f", Date().timeIntervalSince1970))")
                                
                                await MainActor.run {
                                    self.isRecording = true
                                    self.isVisualizerActive = true
                                }
                                self.currentRecordingSessionID = pendingSessionID
                                self.stopPipelineInFlightSessionID = nil
                                self.lastCompletedRecordingSessionID = nil
                                sessionAssigned = true
                                await self.setSessionStateRecording(mode: self.recorderMode)
                                await MainActor.run {
                                    // Enable high-activity animation mode during recording
                                    AnimationTicker.shared.setHighActivity(true)
                                }
                            } else {
                                print("🎙️ [BATCH DEBUG] Starting traditional batch recording...")
                                // Traditional batch recording
                                // --- Prepare temporary file URL within Application Support base directory ---
                                let baseAppSupportDirectory = self.recordingsDirectory.deletingLastPathComponent()
                                let file = baseAppSupportDirectory.appendingPathComponent("output.wav")
                                // Ensure the base directory exists
                                try? FileManager.default.createDirectory(at: baseAppSupportDirectory, withIntermediateDirectories: true)
                                // Clean up any old temporary file first
                                self.recordedFile = file
                                
                                print("🎙️ [BATCH DEBUG] File path: \(file.path)")
                                print("🎙️ [BATCH DEBUG] Directory exists: \(FileManager.default.fileExists(atPath: baseAppSupportDirectory.path))")

                                // Wake up audio system by playing a silent audio if the system has been idle
                                print("🎙️ [BATCH DEBUG] Calling wakeAudioSystemIfNeeded()...")
                                let t0b = Date()
                                if !RuntimeConfig.disableAudioWake {
                                    await self.wakeAudioSystemIfNeeded()
                                    let dt = Int(Date().timeIntervalSince(t0b) * 1000)
                                    StructuredLog.shared.log(cat: .audio, evt: "audio_wake", lvl: .info, ["dt_ms": dt, "skipped": false])
                                    print("🎙️ [BATCH DEBUG] wakeAudioSystemIfNeeded() completed in \(dt)ms")
                                } else {
                                    StructuredLog.shared.log(cat: .audio, evt: "audio_wake", lvl: .info, ["skipped": true])
                                    print("🎙️ [BATCH DEBUG] wakeAudioSystemIfNeeded() skipped via DisableAudioWake")
                                }
                                
                                // NER pre-warm now only runs after OCR completes via onOCRCompleted callback
                                
                                print("🎙️ [BATCH DEBUG] About to call recorder.startRecording()...")
                                print("🎙️ [BATCH DEBUG] Recorder ready for recording")
                                try await self.recorder.startRecording(toOutputFile: file)
                                print("🎙️ [BATCH DEBUG] recorder.startRecording() completed successfully!")
                                print("⏱️ [TIMING] mic_engaged @ \(String(format: "%.3f", Date().timeIntervalSince1970))")
                                self.logger.notice("✅ Audio engine started successfully.")

                                await MainActor.run {
                                    self.isRecording = true
                                    self.isVisualizerActive = true
                                }
                                self.currentRecordingSessionID = pendingSessionID
                                self.stopPipelineInFlightSessionID = nil
                                self.lastCompletedRecordingSessionID = nil
                                sessionAssigned = true
                                print("🎙️ [BATCH DEBUG] Set isRecording=true, isVisualizerActive=true")
                            }
                            

                            if let currentModel = await self.currentModel, await self.whisperContext == nil {
                                do {
                                    try await self.loadModel(currentModel)
                                } catch {
                                    self.logger.error("❌ Model loading failed: \(error.localizedDescription)")
                                    
                                    // SECURITY: Stop recording immediately if model access is denied
                                    if error is RecordingEngineError && (error as! RecordingEngineError) == .accessDenied {
                                        self.logger.error("🚨 [SECURITY] Access denied - stopping recording immediately")
                                        self.currentRecordingSessionID = nil
                                        self.stopPipelineInFlightSessionID = nil
                                        self.lastCompletedRecordingSessionID = nil
                                        sessionAssigned = false
                                        await self.recorder.stopRecording()
                                        return
                                    }
                                }
                            }

                        } catch {
                            print("🚨 [ERROR DEBUG] Recording start failed with error: \(error)")
                            print("🚨 [ERROR DEBUG] Error type: \(type(of: error))")
                            print("🚨 [ERROR DEBUG] Error description: \(error.localizedDescription)")
                            if let nsError = error as NSError? {
                                print("🚨 [ERROR DEBUG] NSError domain: \(nsError.domain), code: \(nsError.code)")
                                print("🚨 [ERROR DEBUG] NSError userInfo: \(nsError.userInfo)")
                            }
                            self.logger.error("❌ Failed to start recording: \(error.localizedDescription)")
                            if sessionAssigned {
                                self.currentRecordingSessionID = nil
                                self.stopPipelineInFlightSessionID = nil
                                self.lastCompletedRecordingSessionID = nil
                                sessionAssigned = false
                            }
                            // Ensure recorder is properly stopped on start failure
                            await self.recorder.stopRecording()
                            await MainActor.run {
                                self.isRecording = false
                                self.isVisualizerActive = false
                            }
                            if let url = self.recordedFile {
                                try? FileManager.default.removeItem(at: url)
                                self.recordedFile = nil
                                self.logger.notice("🗑️ Cleaned up temporary recording file after failed start.")
                            }
                        }
                    }
                } else {
                    logger.error("❌ Recording permission denied.")
                }
            }
        }
    }
    
    private func requestRecordPermission(response: @escaping (Bool) -> Void) {
#if os(macOS)
        response(true)
#else
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            response(granted)
        }
#endif
    }
    
    // MARK: - Language Detection
    
    /// Checks if a language code represents Chinese
    private func isChineseLanguage(_ languageCode: String) -> Bool {
        let chineseLanguages = ["zh", "zh-Hans", "zh-Hant", "zh-CN", "zh-TW", "zh-HK", "zh-MO"]
        return chineseLanguages.contains(languageCode) || languageCode.hasPrefix("zh")
    }

    /// Returns the default streaming model for the current language configuration.
    private func getStreamingModelForLanguage() -> WhisperModel? {
        return availableModels.first(where: { $0.name == "soniox-realtime-streaming" })
    }
    
    /// Force re-evaluation of the current model based on language settings
    /// Call this when language settings change or to fix incorrect model selection
    func reevaluateModelForLanguageSettings() {
        let useLocalModel = UserDefaults.standard.bool(forKey: "UseLocalModel")
        
        // logger.notice("🔍 [REEVALUATE] UseLocalModel: \(useLocalModel)")
        // logger.notice("🔍 [REEVALUATE] Current model: \(self.currentModel?.name ?? "nil")")
        
        if useLocalModel {
            // Keep local model if explicitly enabled
            // logger.notice("🔒 [REEVALUATE] UseLocalModel enabled - keeping current local model")
            return
        }
        
        // Force switch to appropriate streaming model
        // logger.notice("🌐 [REEVALUATE] Switching to streaming model based on language settings")
        setDefaultToStreamingModel()
    }
    
    // MARK: - Audio Meter Updates
    
    private var audioMeterTimer: Timer?
    private var audioMeterCancellable: AnyCancellable?
    
    private func setupAudioMeterUpdates() {
        // Performance optimization: Reduce frequency from 15Hz to 10Hz for better CPU efficiency
        // Push audio-meter updates at ~10 Hz **only while recording** and publish through `audioLevel`.
        audioMeterTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, self.isRecording else { return }

            Task { @MainActor in
                let level: AudioMeter
                if self.currentModel?.name == "soniox-realtime-streaming" {
                    // Soniox streaming engine already computes a level value.
                    level = AudioMeter(
                        averagePower: self.sonioxStreamingService.streamingAudioLevel,
                        peakPower: self.sonioxStreamingService.streamingAudioLevel
                    )
                } else {
                    // Use traditional recorder audio meter for local models.
                    level = self.recorder.audioMeter
                }

                // Update both the legacy property (for existing views) and
                // the new lightweight publisher.
                self.currentAudioMeter = level
                self.audioLevel.level = level
            }
        }
    }
    
    // MARK: AVAudioRecorderDelegate
    
    nonisolated func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error {
            Task {
                await handleRecError(error)
            }
        }
    }
    
    private func handleRecError(_ error: Error) async {
        logger.error("Recording error: \(error.localizedDescription)")
        isRecording = false
        // Ensure proper cleanup when recording errors occur
        await recorder.stopRecording()
    }
    
    // MARK: - Always-On Mini Recorder
    
    private func initializeAlwaysOnMiniRecorder() {
        // Only initialize for mini recorder type
        guard recorderType == "mini" else { return }
        
        // Create mini window manager if it doesn't exist
        if miniWindowManager == nil {
            miniWindowManager = MiniWindowManager(recordingEngine: self, recorder: recorder)
            logger.info("Created always-on mini window manager")
        }
        
        // Show the always-on circle without setting isVisible flag to prevent race condition
        miniWindowManager?.showAlwaysOn()
        logger.info("Initialized always-on mini recorder circle")
    }
    
    private func wakeAudioSystemIfNeeded() async {
        // Track last activity time to determine if audio system needs wake-up
        let lastActivityKey = "LastAudioActivityTime"
        let lastActivity = UserDefaults.standard.object(forKey: lastActivityKey) as? Date ?? Date.distantPast
        let idleTime = Date().timeIntervalSince(lastActivity)
        
        // If idle for more than 5 minutes, wake up the audio system
        if idleTime > 300 { // 5 minutes
            logger.info("🔊 Waking up audio system after \(Int(idleTime))s idle time")
            
            do {
                // Create proper silent WAV data instead of raw zeros
                let silentWAVData = createSilentWAVData(durationMs: 100)
                let silentPlayer = try AVAudioPlayer(data: silentWAVData)
                silentPlayer.volume = 0
                silentPlayer.prepareToPlay()
                silentPlayer.play()
                
                // Wait a moment for audio system to fully wake
                try await Task.sleep(nanoseconds: 100_000_000) // 100ms
            } catch {
                logger.warning("⚠️ Failed to wake audio system: \(error.localizedDescription)")
            }
        }
        
        // Update last activity time
        UserDefaults.standard.set(Date(), forKey: lastActivityKey)
    }
    
    /// Creates silent WAV data for audio system wake-up
    private func createSilentWAVData(durationMs: Int) -> Data {
        let sampleRate = 16000
        let channels = 1
        let bitsPerSample = 16
        let durationSeconds = Double(durationMs) / 1000.0
        let numSamples = Int(Double(sampleRate) * durationSeconds)
        let dataSize = numSamples * channels * (bitsPerSample / 8)
        
        var wavData = Data()
        
        // WAV header (44 bytes)
        wavData.append("RIFF".data(using: .ascii)!)
        wavData.append(withUnsafeBytes(of: UInt32(36 + dataSize).littleEndian) { Data($0) }) // File size
        wavData.append("WAVE".data(using: .ascii)!)
        
        // fmt sub-chunk
        wavData.append("fmt ".data(using: .ascii)!)
        wavData.append(withUnsafeBytes(of: UInt32(16).littleEndian) { Data($0) }) // Sub-chunk size
        wavData.append(withUnsafeBytes(of: UInt16(1).littleEndian) { Data($0) }) // Audio format (PCM)
        wavData.append(withUnsafeBytes(of: UInt16(channels).littleEndian) { Data($0) }) // Channels
        wavData.append(withUnsafeBytes(of: UInt32(sampleRate).littleEndian) { Data($0) }) // Sample rate
        wavData.append(withUnsafeBytes(of: UInt32(sampleRate * channels * bitsPerSample / 8).littleEndian) { Data($0) }) // Byte rate
        wavData.append(withUnsafeBytes(of: UInt16(channels * bitsPerSample / 8).littleEndian) { Data($0) }) // Block align
        wavData.append(withUnsafeBytes(of: UInt16(bitsPerSample).littleEndian) { Data($0) }) // Bits per sample
        
        // data sub-chunk
        wavData.append("data".data(using: .ascii)!)
        wavData.append(withUnsafeBytes(of: UInt32(dataSize).littleEndian) { Data($0) })
        
        // Add silent PCM data (all zeros)
        wavData.append(Data(repeating: 0, count: dataSize))
        
        return wavData
    }
    
    nonisolated func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        Task {
            await onDidFinishRecording(success: flag)
        }
    }
    
    private func onDidFinishRecording(success: Bool) {
        if !success {
            logger.error("Recording did not finish successfully")
        }
    }

    private func transcribeAudio(_ url: URL) async {
        if shouldCancelRecording { return }
        await MainActor.run {
            isProcessing = true
            isTranscribing = true
            canTranscribe = false
            updateTranscriptionProgress(to: .starting)
            startProgressTimer()
        }
        defer {
            if shouldCancelRecording {
                Task {
                    // Keep model loaded even when cancelled
                    // await cleanupModelResources()
                }
            }
        }
        guard let currentModel = currentModel else {
            logger.error("❌ Cannot transcribe: No model selected")
            currentError = .modelLoadFailed
            return
        }
        
        logger.notice("🎯 [transcribeAudio] Starting transcription with model: \(currentModel.name)")

        // Check subscription access for the current model
        do {
            try modelAccessControl.validateWhisperModelAccess(currentModel)
        } catch {
            logger.error("❌ Cannot transcribe: \(error.localizedDescription)")
            currentError = .modelLoadFailed
            
            // Show custom recording failed dialog
            await MainActor.run {
                let modelName = PredefinedModels.models.first(where: { $0.name == currentModel.name })?.displayName ?? currentModel.name
                NotificationCenter.default.post(
                    name: .showRecordingFailedDialog,
                    object: nil,
                    userInfo: ["modelName": modelName]
                )
            }
            return
        }
        
        // Local Whisper path disabled: skip loadModel() calls
        guard let whisperContext = whisperContext else {
            logger.error("❌ Cannot transcribe: Model could not be loaded")
            currentError = .modelLoadFailed
            return
        }
        logger.notice("🔄 Starting transcription with model: \(currentModel.name)")
        do {
            let permanentURL = try saveRecordingPermanently(url)
            let permanentURLString = permanentURL.absoluteString
            if shouldCancelRecording { return }
            let data = try readAudioSamples(url)
            if shouldCancelRecording { return }
            
            // Get the actual audio duration from the file
            let audioAsset = AVURLAsset(url: url)
            let actualDuration = CMTimeGetSeconds(try await audioAsset.load(.duration))
            logger.notice("📊 Audio file duration: \(actualDuration) seconds")
            
            // VAD removed; use original samples
            let processedSamples = data
            
            // Ensure we're using the most recent prompt from UserDefaults
            let currentPrompt = UserDefaults.standard.string(forKey: "TranscriptionPrompt") ?? whisperPrompt.transcriptionPrompt
            await whisperContext.setPrompt(currentPrompt)
            // Ensure VAD model is available and wired (bundled Silero, with fallback to AppSupport)
            await ensureVADReadyForWhisper(whisperContext)
            
            // VAD path not used
            
            if shouldCancelRecording { return }
            // Pass 'no_context = true' so each recording starts fresh
            await whisperContext.fullTranscribe(samples: processedSamples)
            if shouldCancelRecording { return }
            var text = await whisperContext.getTranscription()
            text = text.trimmingCharacters(in: .whitespacesAndNewlines)
            // Deterministic formatting prior to AI enhancement (paragraphing + zh Hans → Hant)
            text = PostEnhancementFormatter.apply(text)
            logger.notice("✅ Transcription completed successfully, length: \(text.count) characters")
            
            // Calculate ACTUAL ASR latency (T1 - T0) - Only Whisper processing time
            let asrLatencyMs: Double? = processingStartTime.map { startTime in
                Date().timeIntervalSince(startTime) * 1000 // Convert to milliseconds
            }
            
            if UserDefaults.standard.bool(forKey: "IsWordReplacementEnabled") {
                text = WordReplacementService.shared.applyReplacements(to: text)
                logger.notice("✅ Word replacements applied")
            }
            
            var promptDetectionResult: PromptDetectionService.PromptDetectionResult? = nil
            let originalText = text 
            
            // Note: ASR word tracking removed for local transcription - only count streaming/API usage for trials
            
            if let enhancementService = enhancementService, enhancementService.isConfigured {
                // Skip prompt detection when there are no trigger words configured
                let hasTriggers = !enhancementService.allPrompts.allSatisfy { $0.triggerWords.isEmpty }
                if hasTriggers {
                    Task.detached { [weak enhancementService, promptDetectionService] in
                        guard let svc = enhancementService else { return }
                        let detectionResult = await promptDetectionService.analyzeText(text, with: svc)
                        await promptDetectionService.applyDetectionResult(detectionResult, to: svc)
                    }
                }
            }
            
            // Intelligent context detection: Capture context at the END of recording
            // Track context capture timing separately to reveal hidden latency
            var contextCaptureLatencyMs: Double = 0
            
            if let enhancementService = enhancementService,
               enhancementService.isEnhancementEnabled,
               enhancementService.isConfigured {
                logger.debug("🧠 Performing intelligent end-context detection")
                
                let contextStartTime = Date()
                
                
                // Capture screen context from the final location
                if let contextService = contextService {
                    await contextService.captureEndContext()
                }
                
                contextCaptureLatencyMs = Date().timeIntervalSince(contextStartTime) * 1000
                logger.notice("⏱️ [CONTEXT TIMING] Screen capture + context detection: \(String(format: "%.1f", contextCaptureLatencyMs))ms")
            }
            
            if let enhancementService = enhancementService,
               enhancementService.isEnhancementEnabled,
               enhancementService.isConfigured {
                do {
                    if shouldCancelRecording { return }
                    // Use processed text (without trigger words) for AI enhancement
                    let textForAI = promptDetectionResult?.processedText ?? text
                    // Pre-clean disfluencies/fillers before sending to the LLM
                    let precleanForAI = RawDisfluencySanitizer.clean(textForAI)
                    
                    // Track total latency from recording stop to enhanced text ready
                    let totalStartTime = processingStartTime ?? Date()
                    updateTranscriptionProgress(to: .processingComplete) // AI enhancement starts
                    // Use prewarmed NER/context; avoid stop-path window info fetching
                    let enhancementResult = try await enhancementService.enhanceWithDynamicContextTracking(
                        precleanForAI,
                        windowTitle: nil,
                        windowContent: nil,
                        usePrewarmedContext: true
                    )
                    let totalLatencyMs = Date().timeIntervalSince(totalStartTime) * 1000
                    
                    // Offload word tracking and DB save to background to keep stop-path overhead ~0ms
                    let enhancedTextForSave = enhancementResult.enhancedText
                    let providerForSave = enhancementResult.provider
                    let modelForSave = enhancementResult.model
                    let llmLatencyForSave = enhancementResult.llmLatencyMs
                    let totalLatencyForSave = totalLatencyMs
                    let originalTextForSave = originalText
                    let durationForSave = actualDuration
                    let audioURLForSave = permanentURLString
                    let asrLatencyForSave = asrLatencyMs
                    Task.detached { [subscriptionManager, modelContext] in
                        let enhancedWordCount = TextUtils.countWords(in: enhancedTextForSave)
                        await MainActor.run {
                            subscriptionManager.trackEnhancement(wordCount: enhancedWordCount)
                        }
                        await MainActor.run {
                            let newTranscription = Transcription(
                                text: originalTextForSave,
                                duration: durationForSave,
                                enhancedText: enhancedTextForSave,
                                audioFileURL: audioURLForSave,
                                processingLatencyMs: asrLatencyForSave,
                                llmLatencyMs: llmLatencyForSave,
                                totalLatencyMs: totalLatencyForSave,
                                aiProvider: "\(providerForSave) (\(modelForSave))"
                            )
                            modelContext.insert(newTranscription)
                            try? modelContext.save()
                        }
                    }
                    
                    text = enhancementResult.enhancedText
                    
                    // Track word count for enhanced text
                    let wordCount = TextUtils.countWords(in: enhancementResult.enhancedText)
                    subscriptionManager.trackEnhancement(wordCount: wordCount)
                } catch {
                    let fallbackText = prepareRawTranscript(from: originalText, applyWordReplacement: false)
                    let newTranscription = Transcription(
                        text: fallbackText,
                        duration: actualDuration,
                        audioFileURL: permanentURLString,
                        processingLatencyMs: asrLatencyMs
                    )
                    modelContext.insert(newTranscription)
                    try? modelContext.save()
                    text = fallbackText
                }
            } else {
                let finalText = prepareRawTranscript(from: originalText, applyWordReplacement: false)
                let newTranscription = Transcription(
                    text: finalText,
                    duration: actualDuration,
                    audioFileURL: permanentURLString,
                    processingLatencyMs: asrLatencyMs
                )
                modelContext.insert(newTranscription)
                try? modelContext.save()
                text = finalText
            }
            
            // Sync usage stats after transcription (non-blocking)
            Task {
                await UserStatsService.shared.syncStatsIfNeeded()
            }
            // COMMENTED OUT: Original Clio trial expiration message
            // This was preventing transcription in the open-source build
            // Replace this section with your own licensing/gatekeeper logic as needed
            /*
            if case .trialExpired = licenseViewModel.licenseState {
                text = """
                    Your trial has expired. Upgrade to Clio Pro at tryclio.com/buy
                    \n\(text)
                    """
            }
            */

            // Log context information if deep context is enabled (for debugging purposes)
            if RuntimeConfig.enableVerboseLogging, let contextService = contextService {
                let contextInfo = contextService.appendContextToTranscription("")
                if !contextInfo.isEmpty {
                    logger.notice("📱 [DEEP CONTEXT] Captured context: \(RuntimeConfig.truncate(contextInfo))")
                }
            }
            
            // Do not append trailing space; keep exact punctuation

            if !shouldCancelRecording {
                SoundManager.shared.playStopSound()
            }
            // Publish for UI consumers (e.g., Try It)
            lastOutputText = text
            if AXIsProcessTrusted() && !shouldCancelRecording && !suppressSystemPaste {
                // Paste immediately so the clipboard snapshot inside CursorPaster captures the user's original clipboard
                // before any optional auto-copy below touches it. CursorPaster will restore the original clipboard
                // after issuing the paste.
                CursorPaster.pasteAtCursor(text)
            }
            if isAutoCopyEnabled && !shouldCancelRecording {
                // Note: This will be temporarily overridden by CursorPaster's clipboard restore, preserving
                // the user's original clipboard as intended. The on-screen "copied" message remains for UX consistency.
                let success = ClipboardManager.copyToClipboard(text)
                if success {
                    clipboardMessage = "Transcription copied to clipboard"
                } else {
                    clipboardMessage = "Failed to copy to clipboard"
                }
            }
            try? FileManager.default.removeItem(at: url)
            
            if let result = promptDetectionResult, 
               let enhancementService = enhancementService, 
               result.shouldEnableAI {
                await promptDetectionService.restoreOriginalSettings(result, to: enhancementService)
            }
            
            await dismissRecorder()
            // Don't cleanup model resources to keep it ready for next recording
            // await cleanupModelResources()
            
            // Clean up AI connection pre-warming
            enhancementService?.cleanupConnection()
            
            // End recording session tracking
            subscriptionManager.endRecordingSession()
            
        } catch {
            currentError = .transcriptionFailed
            // Keep model loaded even on error for next recording
            // await cleanupModelResources()
            await dismissRecorder()
            
            // Clean up AI connection pre-warming on error
            enhancementService?.cleanupConnection()
            
            // End recording session tracking on error
            subscriptionManager.endRecordingSession()
        }
    }
    
    private func handleStreamingTranscriptionComplete() async {
        // Processing streaming transcription result
        
        // Processing states already set in toggleRecord() for streaming models
        
        defer {
            if shouldCancelRecording {
                Task {
                    // Clean up streaming session
                    await sonioxStreamingService.stopStreaming()
                }
            }
        }
        
        // If user cancelled, skip processing entirely and dismiss UI immediately
        if shouldCancelRecording {
            // Clear any lingering command-mode arming so a future dictation isn't misrouted
            if self.commandModeCallback != nil {
                logger.notice("🧹 [COMMAND] Clearing stale commandModeCallback on cancel")
                self.commandModeCallback = nil
            }
            await dismissRecorder()
            enhancementService?.cleanupConnection()
            return
        }

        // Get final transcript from streaming service
        var text = sonioxStreamingService.finalBuffer.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Final safety filter: Remove any remaining <end> tokens that might have leaked through
        text = text.replacingOccurrences(of: "<end>", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !text.isEmpty else {
            logger.warning("⚠️ No text received from streaming transcription")
            // If command mode was armed but no words were captured, make sure it doesn't leak into the next session
            if self.commandModeCallback != nil {
                logger.notice("🧹 [COMMAND] Clearing stale commandModeCallback on empty transcript")
                self.commandModeCallback = nil
            }
            await dismissRecorder()
            
            // Clean up AI connection pre-warming when cancelled
            enhancementService?.cleanupConnection()
            
            return
        }
        
        logger.notice("✅ Streaming transcription completed successfully, length: \(text.count) characters")
        // Capture command mode flag and, if active, invoke callback (bypass paste/copy later)
        if let cb = self.commandModeCallback {
            // Match Dictation timing: play stop sound now, then run command insertion, then close UI when done
            if !shouldCancelRecording { SoundManager.shared.playStopSound() }
            let task = cb(text)
            self.commandModeCallback = nil
            // Cleanup after insertion completes, but don't block this method
            Task { @MainActor in
                await task.value
                enhancementService?.cleanupConnection()
                subscriptionManager.endRecordingSession()
                stopProgressTimer()
                await dismissRecorder()
            }
            return
        }
        updateTranscriptionProgress(to: .transcriptionComplete)
        
        // Calculate streaming latency (much faster than batch)
        let streamingLatencyMs: Double? = processingStartTime.map { startTime in
            Date().timeIntervalSince(startTime) * 1000
        }
        
        // Get actual duration and audio file URL from streaming service
        let actualDuration = sonioxStreamingService.lastRecordingDuration
        let audioFileURL = sonioxStreamingService.lastAudioFileURL?.absoluteString ?? "streaming://soniox"
        
        if shouldCancelRecording { await dismissRecorder(); enhancementService?.cleanupConnection(); return }
        // Do NOT apply word replacements here for streaming; apply once later to the final text (post enhancement or raw if skipped).
        // Normalize numbers/units on Simplified first, then convert to Traditional if needed
        text = PostEnhancementFormatter.apply(text)
        
        var promptDetectionResult: PromptDetectionService.PromptDetectionResult? = nil
        let originalText = text
        
        
        // Handle prompt detection for trigger words (non-blocking, only if triggers exist)
        var promptDetectionTime: Double = 0
        if let enhancementService = enhancementService, enhancementService.isConfigured {
            let hasTriggers = !enhancementService.allPrompts.allSatisfy { $0.triggerWords.isEmpty }
            if hasTriggers {
                let promptDetectionStart = Date()
                Task.detached { [promptDetectionService] in
                    let prompts = await MainActor.run { enhancementService.allPrompts }
                    // Quick re-check to avoid race
                    if prompts.allSatisfy({ $0.triggerWords.isEmpty }) { return }
                    let detectionResult = await promptDetectionService.analyzeText(text, with: enhancementService)
                    await promptDetectionService.applyDetectionResult(detectionResult, to: enhancementService)
                    let elapsed = Date().timeIntervalSince(promptDetectionStart) * 1000
                    print("⏱️ [TIMING] Prompt detection (async): \(String(format: "%.1f", elapsed))ms")
                }
            }
        }
        
        // Track context capture timing separately for streaming
        var contextCaptureLatencyMs: Double = 0
        
        // Capture screen context from the final location for streaming models
        if let enhancementService = enhancementService,
           enhancementService.isEnhancementEnabled,
           enhancementService.isConfigured {
            logger.debug("🧠 Performing intelligent end-context detection for streaming")
            
            let contextStartTime = Date()
            
            
            // Capture screen context from the final location
            if let contextService = contextService {
                await contextService.captureEndContext()
            }
            
            contextCaptureLatencyMs = Date().timeIntervalSince(contextStartTime) * 1000
            logger.notice("⏱️ [STREAMING CONTEXT TIMING] Screen capture + context detection: \(String(format: "%.1f", contextCaptureLatencyMs))ms")
        } else {
            contextCaptureLatencyMs = 0.0
            logger.notice("⏱️ [STREAMING CONTEXT TIMING] End context disabled for performance - using parallel capture: \(String(format: "%.1f", contextCaptureLatencyMs))ms")
        }
        
        // Simple heuristic: skip enhancement for short utterances (applies to Soniox streaming only)
        let shouldSkipEnhancement: Bool = {
            let wordCount = TextUtils.countWords(in: originalText)
            let duration = actualDuration
            return wordCount < 30 || duration < 13
        }()
        
        if shouldCancelRecording { await dismissRecorder(); enhancementService?.cleanupConnection(); return }
        if shouldSkipEnhancement {
            let finalOut = prepareRawTranscript(from: originalText, applyWordReplacement: true)
            let newTranscription = Transcription(
                text: finalOut,
                duration: actualDuration,
                audioFileURL: audioFileURL,
                processingLatencyMs: streamingLatencyMs
            )
            modelContext.insert(newTranscription)
            try? modelContext.save()
            text = finalOut
        } else if let enhancementService = enhancementService,
                  enhancementService.isEnhancementEnabled,
                  enhancementService.isConfigured {
            do {
                if shouldCancelRecording { await dismissRecorder(); enhancementService.cleanupConnection(); return }
                if shouldCancelRecording { return }
                let textForAI = promptDetectionResult?.processedText ?? text
                // Pre-clean disfluencies/fillers before sending to the LLM
                let precleanForAI = RawDisfluencySanitizer.clean(textForAI)
                let totalStartTime = processingStartTime ?? Date()
                updateTranscriptionProgress(to: .processingComplete)
                let enhancementResult = try await enhancementService.enhanceWithDynamicContextTracking(
                    precleanForAI,
                    windowTitle: nil,
                    windowContent: nil,
                    usePrewarmedContext: true
                )
                let totalLatencyMs = Date().timeIntervalSince(totalStartTime) * 1000
                // Apply replacements once on the enhanced text
                var enhancedFinal = enhancementResult.enhancedText
                if UserDefaults.standard.bool(forKey: "IsWordReplacementEnabled") {
                    enhancedFinal = WordReplacementService.shared.applyReplacements(to: enhancedFinal)
                }
                let enhancedTextForSave = enhancedFinal
                let providerForSave = enhancementResult.provider
                let modelForSave = enhancementResult.model
                Task.detached { [subscriptionManager, modelContext] in
                    let wordCount = TextUtils.countWords(in: enhancedTextForSave)
                    await MainActor.run {
                        subscriptionManager.trackEnhancement(wordCount: wordCount)
                        let newTranscription = Transcription(
                            text: originalText,
                            duration: actualDuration,
                            enhancedText: enhancedTextForSave,
                            audioFileURL: audioFileURL,
                            processingLatencyMs: streamingLatencyMs,
                            llmLatencyMs: enhancementResult.llmLatencyMs,
                            totalLatencyMs: totalLatencyMs,
                            aiProvider: "\(providerForSave) (\(modelForSave))"
                        )
                        modelContext.insert(newTranscription)
                        try? modelContext.save()
                    }
                }
                // Debug breakdown (non-blocking)
                let detailedOverheadMs = promptDetectionTime
                let accountedTime = (streamingLatencyMs ?? 0) + contextCaptureLatencyMs + enhancementResult.llmLatencyMs + detailedOverheadMs
                let unaccountedTime = totalLatencyMs - accountedTime
                print("📊 [DETAILED STREAMING TIMING] Streaming: \(String(format: "%.1f", streamingLatencyMs ?? 0))ms | Context: \(String(format: "%.1f", contextCaptureLatencyMs))ms | LLM: \(String(format: "%.1f", enhancementResult.llmLatencyMs))ms | Tracked Overhead: \(String(format: "%.1f", detailedOverheadMs))ms | Unaccounted: \(String(format: "%.1f", unaccountedTime))ms | Total: \(String(format: "%.1f", totalLatencyMs))ms")
                text = enhancedTextForSave
            } catch {
                let fallbackText = prepareRawTranscript(from: originalText, applyWordReplacement: true)
                let newTranscription = Transcription(
                    text: fallbackText,
                    duration: actualDuration,
                    audioFileURL: audioFileURL,
                    processingLatencyMs: streamingLatencyMs
                )
                modelContext.insert(newTranscription)
                try? modelContext.save()
                text = fallbackText
            }
        } else {
            // Enhancement disabled/unavailable — persist raw ASR with replacements applied
            let finalOut = prepareRawTranscript(from: originalText, applyWordReplacement: true)
            let newTranscription = Transcription(
                text: finalOut,
                duration: actualDuration,
                audioFileURL: audioFileURL,
                processingLatencyMs: streamingLatencyMs
            )
            modelContext.insert(newTranscription)
            try? modelContext.save()
            text = finalOut
        }
        
        // Sync usage stats (non-blocking)
        Task { await UserStatsService.shared.syncStatsIfNeeded() }
        
        // Paste + cleanup (no trailing space)
        if !shouldCancelRecording { SoundManager.shared.playStopSound() }
        let axTrusted = AXIsProcessTrusted()
        // Publish for UI consumers (e.g., Try It)
        lastOutputText = text
        if axTrusted && !shouldCancelRecording && !suppressSystemPaste {
            // Paste immediately so the clipboard snapshot inside CursorPaster captures the user's original clipboard
            // before any optional auto-copy below touches it. CursorPaster will restore the original clipboard
            // after issuing the paste.
            CursorPaster.pasteAtCursor(text)
        }
        if isAutoCopyEnabled && !shouldCancelRecording {
            // Note: This will be temporarily overridden by CursorPaster's clipboard restore, preserving
            // the user's original clipboard as intended. The on-screen message remains for UX consistency.
            let success = ClipboardManager.copyToClipboard(text)
            clipboardMessage = success ? "Streaming transcription copied to clipboard" : "Failed to copy to clipboard"
        }
        if let result = promptDetectionResult,
           let enhancementService = enhancementService,
           result.shouldEnableAI {
            await promptDetectionService.restoreOriginalSettings(result, to: enhancementService)
        }
        enhancementService?.cleanupConnection()
        subscriptionManager.endRecordingSession()
        Task { @MainActor in withAnimation(.easeOut(duration: 0.2)) { transcriptionProgress = 1.0 } }
        stopProgressTimer()
        await dismissRecorder()
        logger.notice("✅ Streaming transcription processing completed")
    }
    
    // MARK: - NER Pre-warming Setup
    
    /// Set up callback to trigger NER pre-warming when OCR completes
    private func setupOCRCompletionCallback() {
        // Offline Mode: perform a minimal LLM warmup (no OCR/NER) and skip wiring the OCR callback
        if UserDefaults.standard.bool(forKey: "UseLocalModel") {
            logger.notice("🔥 [PREWARM] Offline mode quick warmup (no OCR/NER)")
            enhancementService?.prewarmKeepAlivePing()
            contextService?.onOCRCompleted = nil
            return
        }
        guard let contextService = contextService,
              let enhancementService = enhancementService else {
            logger.notice("⚠️ [NER-SETUP] Missing context or enhancement service - context: \(self.contextService != nil), enhancement: \(self.enhancementService != nil)")
            return
        }
        
        logger.notice("🔧 [NER-SETUP] Setting up callback - contextService exists: \(contextService != nil)")
        
        // Set up callback to trigger pre-warming when OCR text is available
        contextService.onOCRCompleted = { [weak self, weak enhancementService] ocrText in
            guard let self = self, let enhancementService = enhancementService else { 
                print("⚠️ [NER-CALLBACK] Weak references lost - self: \(self != nil), enhancementService: \(enhancementService != nil)")
                return 
            }
            
            Task {
                // Double-guard at call time for offline mode
                if UserDefaults.standard.bool(forKey: "UseLocalModel") {
                    self.logger.notice("🔥 Pre-warming skipped: offline mode enabled (callback)")
                    return
                }
                // self.logger.notice("🔥 [NER-PREWARM] Triggering NER pre-warming with OCR text (\(ocrText.count) chars)")
                enhancementService.prewarmConnection()
            }
        }
        
        // Verify callback is set by checking if it exists
        let callbackExists = contextService.onOCRCompleted != nil
        logger.notice("✅ [NER-SETUP] OCR completion callback configured for NER pre-warming - callback exists: \(callbackExists)")
    }

    private func readAudioSamples(_ url: URL) throws -> [Float] {
        return try decodeWaveFile(url)
    }

    private func decodeWaveFile(_ url: URL) throws -> [Float] {
        let data = try Data(contentsOf: url)
        let floats = stride(from: 44, to: data.count, by: 2).map {
            return data[$0..<$0 + 2].withUnsafeBytes {
                let short = Int16(littleEndian: $0.load(as: Int16.self))
                return max(-1.0, min(Float(short) / 32767.0, 1.0))
            }
        }
        return floats
    }

    @Published var currentError: RecordingEngineError?

    func getEnhancementService() -> AIEnhancementService? {
        return enhancementService
    }

    private func saveRecordingPermanently(_ tempURL: URL) throws -> URL {
        let fileName = "\(UUID().uuidString).wav"
        let permanentURL = recordingsDirectory.appendingPathComponent(fileName)
        try FileManager.default.copyItem(at: tempURL, to: permanentURL)
        
        // Compress audio in background to save storage space
        Task {
            await compressAudioFile(permanentURL)
        }
        
        return permanentURL
    }
    
    private func compressAudioFile(_ originalURL: URL) async {
        logger.notice("🗜️ [WHISPER] Starting compression process for: \(originalURL.lastPathComponent)")
        let compressionService = AudioCompressionService()
        
        do {
            // Create compressed filename with .m4a extension
            let compressedURL = originalURL.deletingPathExtension().appendingPathExtension("m4a")
            logger.notice("🗜️ [WHISPER] Compressing \(originalURL.lastPathComponent) → \(compressedURL.lastPathComponent)")
            
            // Get original file size for comparison
            let originalAttributes = try FileManager.default.attributesOfItem(atPath: originalURL.path)
            let originalSize = originalAttributes[.size] as? Int64 ?? 0
            logger.notice("🗜️ [WHISPER] Original file size: \(originalSize) bytes (\(String(format: "%.1f", Double(originalSize) / 1024 / 1024))MB)")
            
            // Compress the audio file
            let compressedSize = try await compressionService.compressAudio(
                from: originalURL,
                to: compressedURL,
                format: .aac,
                quality: 0.6
            )
            
            logger.notice("🗜️ [WHISPER] Compression completed - checking results...")
            
            // Verify compressed file exists and has reasonable size
            guard FileManager.default.fileExists(atPath: compressedURL.path) else {
                logger.error("❌ [WHISPER] Compressed file was not created at: \(compressedURL.path)")
                return
            }
            
            // Verify file sizes
            if compressedSize > 0 && originalSize > 0 {
                let savings = originalSize - compressedSize
                let percentage = Double(savings) / Double(originalSize) * 100
                logger.notice("💾 [WHISPER] Audio compressed successfully!")
                logger.notice("💾 [WHISPER] Size: \(originalSize) → \(compressedSize) bytes")
                logger.notice("💾 [WHISPER] Saved: \(savings) bytes (\(String(format: "%.1f", percentage))% reduction)")
                
                // Replace original with compressed file if compression was successful
                logger.notice("🗜️ [WHISPER] Replacing original WAV with compressed M4A...")
                try FileManager.default.removeItem(at: originalURL)
                logger.notice("✅ [WHISPER] Original WAV file removed")
                
                // Update the transcription record to point to compressed file
                await updateTranscriptionAudioURL(from: originalURL.absoluteString, to: compressedURL.absoluteString)
                logger.notice("✅ [WHISPER] Transcription record updated to point to compressed file")
            } else {
                logger.error("❌ [WHISPER] Invalid file sizes - Original: \(originalSize), Compressed: \(compressedSize)")
                // Clean up failed compression file
                if FileManager.default.fileExists(atPath: compressedURL.path) {
                    try? FileManager.default.removeItem(at: compressedURL)
                }
            }
        } catch {
            logger.error("❌ [WHISPER] Failed to compress audio file: \(error.localizedDescription)")
            logger.error("❌ [WHISPER] Error details: \(error)")
            
            // If compression failed, the original WAV file remains
            logger.notice("ℹ️ [WHISPER] Original WAV file preserved due to compression failure")
        }
    }
    
    private func updateTranscriptionAudioURL(from originalURL: String, to compressedURL: String) async {
        await MainActor.run {
            // Find and update the transcription record
            let descriptor = FetchDescriptor<Transcription>(
                predicate: #Predicate { transcription in
                    transcription.audioFileURL == originalURL
                }
            )
            
            do {
                let transcriptions = try modelContext.fetch(descriptor)
                for transcription in transcriptions {
                    transcription.audioFileURL = compressedURL
                }
                try modelContext.save()
            } catch {
                logger.error("❌ Failed to update transcription audio URL: \(error)")
            }
        }
    }
    
    deinit {
        audioMeterTimer?.invalidate()
        audioMeterTimer = nil
    }
}

// MARK: - Models directory resolver (handles legacy bundle ids)
extension RecordingEngine {
    static func resolveModelsDirectory() -> URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let currentId = Bundle.main.bundleIdentifier ?? "com.cliovoice.clio"
        let candidates = [
            appSupport.appendingPathComponent(currentId).appendingPathComponent("WhisperModels"),
            appSupport.appendingPathComponent("com.cliovoice.clio").appendingPathComponent("WhisperModels"),
            appSupport.appendingPathComponent("com.jetsonai.clio").appendingPathComponent("WhisperModels")
        ]

        // Prefer the first existing directory that contains any .bin models
        for dir in candidates {
            var isDir: ObjCBool = false
            if FileManager.default.fileExists(atPath: dir.path, isDirectory: &isDir), isDir.boolValue {
                if let files = try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil).filter({ $0.pathExtension == "bin" }), !files.isEmpty {
                    return dir
                }
            }
        }
        // Fallback to the current bundle id path
        return appSupport.appendingPathComponent(currentId).appendingPathComponent("WhisperModels")
    }

    /// Ensure the bundled Silero VAD model is present and set on the Whisper context.
    /// - Prefers the bundled copy inside the app for immediate use.
    /// - Also installs a copy into Application Support/WhisperModels for legacy paths.
    @MainActor
    func ensureVADReadyForWhisper(_ ctx: WhisperContext) async {
        // 1) Preferred: point Whisper to the bundled resource path
        var bundledPath: String? = nil
        if let p = Bundle.main.path(forResource: "ggml-silero-v5.1.2", ofType: "bin") {
            bundledPath = p
        }

        // 2) Ensure the App Support copy exists for any code expecting that location
        if !isVADModelDownloaded {
            do {
                let fm = FileManager.default
                try fm.createDirectory(at: modelsDirectory, withIntermediateDirectories: true)
                if let src = bundledPath { try? fm.copyItem(atPath: src, toPath: vadModelPath) }
            } catch {
                logger.warning("⚠️ Failed to install VAD model to App Support: \(error.localizedDescription)")
            }
        }

        // 3) Wire into Whisper context (prefer bundled, fallback to App Support)
        if let usePath = bundledPath ?? (isVADModelDownloaded ? vadModelPath : nil) {
            await ctx.setVADModelPath(usePath)
        } else {
            // As a last resort, disable VAD (Whisper will still run)
            await ctx.setVADModelPath(nil)
        }
    }
}

struct WhisperModel: Identifiable {
    let id = UUID()
    let name: String
    let url: URL
    var coreMLEncoderURL: URL? // Path to the unzipped .mlmodelc directory
    var isCoreMLDownloaded: Bool { coreMLEncoderURL != nil }
    
    var downloadURL: String {
        "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/\(filename)"
    }
    
    var filename: String {
        "\(name).bin"
    }
    
    // Core ML related properties
    var coreMLZipDownloadURL: String? {
        // Only non-quantized models have Core ML versions
        guard !name.contains("q5") && !name.contains("q8") else { return nil }
        return "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/\(name)-encoder.mlmodelc.zip"
    }
    
    var coreMLEncoderDirectoryName: String? {
        guard coreMLZipDownloadURL != nil else { return nil }
        return "\(name)-encoder.mlmodelc"
    }
}

private class TaskDelegate: NSObject, URLSessionTaskDelegate {
    private let continuation: CheckedContinuation<Void, Never>
    
    init(_ continuation: CheckedContinuation<Void, Never>) {
        self.continuation = continuation
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        continuation.resume()
    }
}

extension Notification.Name {
    static let toggleMiniRecorder = Notification.Name("toggleMiniRecorder")
    static let forceCleanupAudioResources = Notification.Name("forceCleanupAudioResources")
}

// MARK: - Character utilities used for spacing rules
private extension Character {
    var isCJK: Bool {
        guard let scalar = unicodeScalars.first else { return false }
        switch scalar.value {
        case 0x4E00...0x9FFF,      // CJK Unified Ideographs
             0x3400...0x4DBF,      // CJK Unified Ideographs Extension A
             0x20000...0x2A6DF,    // CJK Unified Ideographs Extension B
             0x2A700...0x2B73F,    // Extension C
             0x2B740...0x2B81F,    // Extension D
             0x2B820...0x2CEAF,    // Extension E
             0x2CEB0...0x2EBEF,    // Extension F
             0x3040...0x309F,      // Hiragana
             0x30A0...0x30FF,      // Katakana
             0xAC00...0xD7AF:      // Hangul Syllables
            return true
        default:
            return false
        }
    }
}
