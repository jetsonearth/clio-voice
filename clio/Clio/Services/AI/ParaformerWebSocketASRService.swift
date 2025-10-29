//
//  ParaformerWebSocketASRService.swift


import Foundation
import Network
import AVFoundation
import Combine
import SwiftUI
import os

/// Paraformer WebSocket ASR Service for real-time speech recognition
/// Supports multiple languages including Chinese dialects, English, Japanese, Korean, German, French, and Russian
@MainActor
class ParaformerWebSocketASRService: NSObject, ObservableObject {
    
    // MARK: - Properties
    
    @Published var isStreaming = false
    @Published var partialTranscript = ""
    @Published var finalBuffer = ""
    @Published var connectionStatus: ConnectionStatus = .disconnected
    @Published var streamingAudioLevel: Double = 0.0
    
    // Expose recording info for transcript creation
    var lastRecordingDuration: TimeInterval { recordingDuration }
    var lastAudioFileURL: URL? { audioFileURL }
    
    private var webSocket: URLSessionWebSocketTask?
    private var audioEngine: AVAudioEngine?
    private var inputNode: AVAudioInputNode?
    private var urlSession: URLSession?
    private var audioConverter: AVAudioConverter?
    private var converterBuffer: AVAudioPCMBuffer?
    // Serializes WebSocket sends to preserve order
    private let sendActor = WebSocketSendActor()
    private var audioFormat: AVAudioFormat?
    private let logger = Logger(subsystem: "com.jetsonai.clio", category: "ParaformerStreaming")

    // Indicates that the server has sent its final "finished" message
    private var finishedReceived: Bool = false
    // Indicates that the server has sent the <fin> token after finalization
    private var finTokenReceived: Bool = false
    private var listenerTask: Task<Void, Never>? = nil

    // Expose a meter for the audio visualizer
    @Published var paraformerMeter = AudioMeter(averagePower: 0, peakPower: 0)
    
    // Transcription buffer management
    private var transcriptionBuffer = TranscriptionBuffer()
    private var lastFinalTokenTime: Date?
    private let segmentPauseThreshold: TimeInterval = 0.5 // 500ms pause = new segment
    
    // Audio buffer accumulation and file saving
    private var audioAccumulator = Data()
    private let audioChunkSize = 32000 // 1 second of audio at 16kHz mono (16-bit)
    private var recordingStartTime: Date?
    private var recordingDuration: TimeInterval = 0.0
    private var audioFileURL: URL?
    private var currentTaskId: String = ""
    
    // Buffer for audio captured before WebSocket is fully ready (like Soniox)
    private let prebuffer = PrebufferStore()
    private var webSocketReady: Bool = false
    
    // Audio configuration - will be set dynamically based on hardware
    private var captureSampleRate: Double = 48000.0  // Default, will be updated
    private var captureChannelCount: UInt32 = 1      // Default, will be updated
    private let sampleRate: Double = 16000.0         // Keep for legacy compatibility
    private let bufferSize: AVAudioFrameCount = 1024
    
    // MARK: - Enums
    
    enum ConnectionStatus {
        case disconnected
        case connecting
        case connected
        case error(String)
    }
    
    enum ParaformerError: Error {
        case sessionNotConfigured
        case noJWTToken
        case temporaryKeyRequestFailed
        case webSocketConnectionFailed
        case audioEngineError
        case invalidResponse
        case authenticationFailed
    }
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        // Lazy initialization - setupAudioEngine() will be called when startStreaming() is invoked
        
        // Listen for app termination to force cleanup
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(forceCleanup),
            name: .forceCleanupAudioResources,
            object: nil
        )
    }
    
    deinit {
        // Remove notification observer
        NotificationCenter.default.removeObserver(self)
        
        // Avoid scheduling async work that captures self in deinit; perform minimal synchronous cleanup
        let ws = webSocket
        webSocket = nil
        ws?.cancel(with: .goingAway, reason: nil)
        urlSession?.invalidateAndCancel()
        
        // Stop engine/tap synchronously if possible
        if let engine = audioEngine, engine.isRunning { engine.stop() }
        inputNode?.removeTap(onBus: 0)
        audioEngine = nil
        inputNode = nil
        audioConverter = nil
        converterBuffer = nil
    }
    
    // MARK: - Public Methods (Soniox-style)
    
    /// Start streaming audio to Paraformer with temporary API key
    func startStreaming() async {
        guard !isStreaming else {
            logger.warning("⚠️ Already streaming")
            return
        }
        
        logger.notice("🚀 Starting Paraformer streaming...")
        
        do {
            await MainActor.run {
                connectionStatus = .connecting
                isStreaming = true
                partialTranscript = ""
                finalBuffer = ""
                recordingStartTime = Date()
                recordingDuration = 0.0
                audioAccumulator.removeAll()
                webSocketReady = false
            }
            
            // Clear any stale prebuffer before starting capture
            await prebuffer.clear()
            
            // Start audio capture FIRST (like Soniox) - this begins buffering immediately
            try await startAudioCapture()
            
            // Get JWT token for our API (same as Soniox)
            let jwtToken = try await TokenManager.shared.getValidToken()
            
            // Request temporary API key from Vercel
            let tempKeyInfo = try await requestTemporaryApiKey(jwtToken: jwtToken)
            
            // Connect to Paraformer with temporary key
            try await connectToParaformerWithTempKey(tempKeyInfo: tempKeyInfo)
            
        } catch {
            logger.error("❌ Failed to start Paraformer streaming: \(error)")
            await MainActor.run {
                connectionStatus = .error("Failed to connect: \(error.localizedDescription)")
                isStreaming = false
            }
        }
    }
    
    /// Stop streaming audio to Paraformer
    func stopStreaming() async {
        guard isStreaming else {
            logger.warning("⚠️ Not currently streaming")
            return
        }
        
        logger.notice("🛑 Stopping Paraformer streaming...")
        
        // IMPORTANT: Give Paraformer time to process the last bit of speech
        // Unlike Soniox (which has manual finalization), we need to wait briefly
        logger.debug("⏳ Waiting 200ms for final speech processing...")
        try? await Task.sleep(nanoseconds: 200_000_000) // 200ms delay
        
        // CRITICAL: Stop audio engine FIRST to release microphone immediately
        await stopAudioEngine()
        
        // Update state immediately to prevent UI issues
        await MainActor.run {
            isStreaming = false
            connectionStatus = .disconnected
            recordingDuration = recordingStartTime?.timeIntervalSinceNow.magnitude ?? 0.0
        }
        
        // Send end-of-stream signal
        await sendEndOfStream()
        
        // Wait a moment for final results to arrive
        logger.debug("⏳ Waiting for final results...")
        try? await Task.sleep(nanoseconds: 300_000_000) // 300ms for final results
        
        // Clean up connection last
        await cleanupConnection()
        
        logger.notice("✅ Paraformer streaming stopped")
    }
    
    // MARK: - Temporary API Key Management
    
    private struct TemporaryKeyInfo {
        let apiKey: String
        let expiresAt: String
        let websocketUrl: String
        let config: ParaformerConfig
    }
    
    private func requestTemporaryApiKey(jwtToken: String) async throws -> TemporaryKeyInfo {
        let url = URL(string: "https://www.cliovoice.com/api/asr/paraformer-temp-key")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")
        
        let languageHints = getParaformerLanguageHints()
        let requestBody: [String: Any] = [
            "languages": languageHints,
            "duration": 600,  // 10 minutes should be plenty for most recordings
            "hotwords": getDictionaryContext()
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ParaformerError.temporaryKeyRequestFailed
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let tempApiKey = json["temporaryApiKey"] as? String,
              let expiresAt = json["expiresAt"] as? String,
              let websocketUrl = json["websocketUrl"] as? String,
              let configDict = json["config"] as? [String: Any] else {
            throw ParaformerError.temporaryKeyRequestFailed
        }
        
        // Parse the config
        let configLanguageHints = (configDict["language_hints"] as? [String]) ?? getParaformerLanguageHints()
        let hotwords = (configDict["hotwords"] as? [String]) ?? getDictionaryContext()
        
        let config = ParaformerConfig(
            apiKey: tempApiKey,
            model: "paraformer-realtime-v2",
            sampleRate: Int(captureSampleRate),
            language: configLanguageHints.first ?? "zh",
            languageHints: configLanguageHints,
            enableHeartbeat: true,
            enableInverseTextNormalization: true,
            enablePunctuation: true,
            hotwords: hotwords
        )
        
        return TemporaryKeyInfo(
            apiKey: tempApiKey,
            expiresAt: expiresAt,
            websocketUrl: websocketUrl,
            config: config
        )
    }
    
    private func connectToParaformerWithTempKey(tempKeyInfo: TemporaryKeyInfo) async throws {
        // Use the official DashScope WebSocket URL
        guard let url = URL(string: "wss://dashscope.aliyuncs.com/api-ws/v1/inference") else {
            throw ParaformerError.webSocketConnectionFailed
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(tempKeyInfo.apiKey)", forHTTPHeaderField: "Authorization")
        
        urlSession = URLSession(configuration: .default)
        webSocket = urlSession?.webSocketTask(with: request)
        webSocket?.resume()
        await sendActor.setSocket(webSocket)
        
        // Send "run-task" instruction in DashScope WebSocket protocol format
        currentTaskId = UUID().uuidString
        let runTaskMessage = [
            "header": [
                "action": "run-task",
                "task_id": currentTaskId,
                "streaming": "duplex"
            ],
            "payload": [
                "task_group": "audio",
                "task": "asr",
                "function": "recognition",
                "model": "paraformer-realtime-v2",
                "parameters": [
                    "format": "pcm",
                    "sample_rate": Int(captureSampleRate),
                    "language_hints": tempKeyInfo.config.languageHints ?? ["zh"],
                    "punctuation_prediction_enabled": true,
                    "inverse_text_normalization_enabled": true,
                    "heartbeat": true
                ],
                "input": [:] as [String: Any]
            ]
        ] as [String: Any]
        
        let configData = try JSONSerialization.data(withJSONObject: runTaskMessage)
        let configString = String(data: configData, encoding: .utf8) ?? ""
        logger.notice("📤 Sending run-task to Paraformer: \(configString)")
        
        let message = URLSessionWebSocketTask.Message.string(configString)
        try await webSocket?.send(message)
        
        // Wait for task-started event before proceeding
        var taskStarted = false
        let startTime = Date()
        
        while !taskStarted && Date().timeIntervalSince(startTime) < 10.0 {
            do {
                let response = try await webSocket?.receive()
                switch response {
                case .string(let text):
                    logger.notice("📝 Paraformer response: \(text)")
                    if text.contains("task-started") {
                        taskStarted = true
                        logger.notice("✅ Received task-started from Paraformer")
                    }
                    await handleTextMessage(text)
                case .data(let data):
                    await handleRecognitionResult(data)
                case .none:
                    break
                @unknown default:
                    break
                }
            } catch {
                logger.warning("⚠️ Error waiting for task-started: \(error)")
                break
            }
        }
        
        if !taskStarted {
            logger.warning("⚠️ Did not receive task-started event, proceeding anyway")
        }
        
        // Mark WebSocket ready and flush pre-buffered packets (like Soniox)
        await finalizeConnection()
        
        await MainActor.run {
            connectionStatus = .connected
        }
        
        logger.notice("🔑 Connected to Paraformer using temporary API key")
    }
    
    // MARK: - Private Methods
    
    private func finalizeConnection() async {
        // Calculate how much audio was buffered before WebSocket came online
        let totalBytes = await prebuffer.totalBytes()
        let bufferDuration = Double(totalBytes / 2) / captureSampleRate
        
        // Log WebSocket ready timing
        if let startTime = recordingStartTime {
            let connectionDelay = Date().timeIntervalSince(startTime) * 1000 // ms
            logger.notice("🔌 WebSocket ready after \(String(format: "%.0f", connectionDelay))ms - buffered \(String(format: "%.1f", bufferDuration))s of audio")
        }
        
        // Mark WebSocket ready so the tap can start flushing buffered audio
        webSocketReady = true
        
        // Flush any pre-buffered packets (like Soniox)
        let hadBuffered = !(await prebuffer.isEmpty())
        if hadBuffered {
            let count = await prebuffer.count()
            logger.notice("📦 Flushing \(count) buffered packets (\(String(format: "%.1f", bufferDuration))s of audio)")
            let packets = await prebuffer.popAll()
            for pkt in packets {
                await sendActor.send(pkt)
            }
            logger.notice("✅ Buffer flush complete")
        }
        
        // Start listening for messages
        startListening()
        
        // Start audio engine after successful connection
        await startAudioEngine()
    }
    
    private func setupAudioEngine() {
        // This function is now redundant - audio engine setup is done in startAudioCapture()
        // Keeping this stub for any existing references
        logger.debug("📱 setupAudioEngine() called - audio engine will be set up in startAudioCapture()")
    }
    
    private func startAudioCapture() async throws {
        logger.notice("🎤 Starting Paraformer audio capture...")
        
        audioEngine = AVAudioEngine()
        inputNode = audioEngine?.inputNode
        
        guard let audioEngine = audioEngine,
              let inputNode = inputNode else {
            throw ParaformerError.audioEngineError
        }
        
        // Use the input node's hardware format (like Soniox does)
        let hardwareFormat = inputNode.inputFormat(forBus: 0)
        logger.notice("🎤 Hardware format: \(hardwareFormat)")
        
        // Remember the format so we can send accurate metadata to Paraformer
        captureSampleRate = hardwareFormat.sampleRate
        captureChannelCount = UInt32(hardwareFormat.channelCount)
        
        // Configure audio format for 16kHz mono (used for conversion)
        audioFormat = AVAudioFormat(
            commonFormat: .pcmFormatInt16,
            sampleRate: sampleRate,
            channels: 1,
            interleaved: false
        )
        
        logger.notice("🎤 Audio engine configured with hardware format: \(hardwareFormat.sampleRate)Hz, \(hardwareFormat.channelCount) channels")
        
        // Install tap using hardware format – we'll send the actual format to Paraformer
        inputNode.installTap(onBus: 0, bufferSize: bufferSize, format: hardwareFormat) { [weak self] buffer, _ in
            Task { [weak self] in
                await self?.processAudioBuffer(buffer)
            }
        }
        
        // Bluetooth/AirPods stabilization similar to Soniox
        let isBluetoothInput = AudioDeviceManager.shared.isCurrentInputBluetooth
        if isBluetoothInput {
            try? await Task.sleep(nanoseconds: 200_000_000)
        }
        
        var attempts = 0
        let maxAttempts = isBluetoothInput ? 6 : 3
        let backoffNs: UInt64 = isBluetoothInput ? 300_000_000 : 200_000_000
        var startError: Error?
        while attempts < maxAttempts {
            do {
                try audioEngine.start()
                startError = nil
                break
            } catch {
                attempts += 1
                startError = error
                if attempts < maxAttempts {
                    try await Task.sleep(nanoseconds: backoffNs)
                }
            }
        }
        if let startError { throw startError }
        logger.notice("✅ Paraformer audio capture started")
    }
    
    private func startAudioEngine() async {
        // Audio engine is already started in startAudioCapture
        // This method is kept for compatibility and logs
        logger.notice("✅ Paraformer audio engine already started via startAudioCapture")
    }
    
    private func stopAudioEngine() async {
        logger.notice("🛑 Stopping Paraformer audio engine...")
        
        // Ensure we stop everything synchronously on main thread
        await MainActor.run {
            if let engine = audioEngine, engine.isRunning {
                engine.stop()
                logger.debug("🔇 Audio engine stopped")
            }
            
            if let input = inputNode {
                input.removeTap(onBus: 0)
                logger.debug("🔌 Audio tap removed")
            }
            
            audioEngine = nil
            inputNode = nil
            audioConverter = nil
            converterBuffer = nil
            
            // Reset audio levels
            streamingAudioLevel = 0.0
            paraformerMeter = AudioMeter(averagePower: 0, peakPower: 0)
        }
        
        logger.notice("✅ Paraformer audio engine stopped")
    }
    
    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        // Convert buffer and get audio level (like Soniox)
        let (audioData, audioLevel) = convertBufferToPCMData(buffer)
        
        // Update audio level for visualizer immediately (like Soniox)
        Task { @MainActor in
            self.streamingAudioLevel = audioLevel
            self.paraformerMeter = AudioMeter(averagePower: audioLevel, peakPower: audioLevel)
        }
        
        // Debug: Log audio levels to verify they're being calculated
        if audioLevel > 0.1 {  // Only log when there's significant audio
            logger.debug("🎵 Audio level: \(String(format: "%.3f", audioLevel)) (WebSocket ready: \(self.webSocketReady))")
        }
        
        guard !audioData.isEmpty else { return }
        
        // Send audio data via WebSocket
        Task {
            await sendAudioData(audioData)
        }
    }
    
    private func convertBufferToPCMData(_ buffer: AVAudioPCMBuffer) -> (Data, Double) {
        guard let floatChannelData = buffer.floatChannelData else { 
            return (Data(), 0.0)
        }
        
        let frameLength = Int(buffer.frameLength)
        let channelCount = Int(buffer.format.channelCount)
        
        // Convert Float32 to Int16 for Paraformer API
        var int16Data = [Int16]()
        int16Data.reserveCapacity(frameLength)
        
        var peak: Float = 0.0  // Use peak amplitude like Soniox, not average
        let channelData = floatChannelData[0]
        
        for i in 0..<frameLength {
            let sample = channelData[i]
            let clampedSample = max(-1.0, min(1.0, sample))
            let int16Sample = Int16(clampedSample * Float(Int16.max))
            int16Data.append(int16Sample)
            
            // Track peak amplitude (like Soniox)
            peak = max(peak, abs(sample))
        }
        
        let audioData = Data(bytes: int16Data, count: frameLength * 2)
        
        // Calculate audio level using peak amplitude (exactly like Soniox)
        let db = 20.0 * log10(Double(peak) + 1e-9)
        
        // Map dB to 0-1 range for visualizer
        let minVisibleDb: Double = -60.0
        let maxVisibleDb: Double = 0.0
        let clamped = max(minVisibleDb, min(maxVisibleDb, db))
        let audioLevel = (clamped - minVisibleDb) / (maxVisibleDb - minVisibleDb)
        
        return (audioData, audioLevel)
    }
    
    // MARK: - Legacy method removed - now using Alibaba Cloud WebSocket protocol format
    
    private func sendAudioData(_ audioData: Data) async {
        // Accumulate audio for file saving
        audioAccumulator.append(audioData)
        
        // Send immediately if WebSocket is ready, otherwise buffer (like Soniox)
        if webSocketReady {
            await sendActor.send(audioData)
        } else {
            // Buffer audio while WebSocket is connecting - this preserves early speech!
            await prebuffer.append(audioData)
        }
    }
    
    private func sendEndOfStream() async {
        // Send "finish-task" instruction in correct Alibaba Cloud WebSocket protocol format
        let finishTaskMessage = [
            "header": [
                "action": "finish-task",
                "task_id": currentTaskId,
                "streaming": "duplex"
            ],
            "payload": [
                "input": [:] as [String: Any]
            ]
        ] as [String: Any]
        
        do {
            let data = try JSONSerialization.data(withJSONObject: finishTaskMessage)
            let message = URLSessionWebSocketTask.Message.string(String(data: data, encoding: .utf8) ?? "")
            try await webSocket?.send(message)
            logger.notice("📤 Sent finish-task instruction to Paraformer")
        } catch {
            logger.error("❌ Failed to send finish-task: \(error)")
        }
        
        // Save accumulated audio to file
        await saveAccumulatedAudio()
    }
    
    private func cleanupConnection() async {
        listenerTask?.cancel()
        listenerTask = nil
        
        webSocket?.cancel(with: .goingAway, reason: nil)
        webSocket = nil
        urlSession = nil
        await sendActor.setSocket(nil)
        
        finishedReceived = false
        finTokenReceived = false
        
        logger.notice("🧹 Paraformer connection cleaned up")
    }
    
    private func startListening() {
        listenerTask = Task {
            await receiveMessages()
        }
    }
    
    
    private func saveAccumulatedAudio() async {
        guard !audioAccumulator.isEmpty else { return }
        
        do {
            // Create a temporary file URL
            let tempDir = FileManager.default.temporaryDirectory
            let fileName = "paraformer_audio_\(UUID().uuidString).wav"
            let tempFileURL = tempDir.appendingPathComponent(fileName)
            
            // Create WAV header and write to file
            let wavData = createWAVFile(from: audioAccumulator)
            try wavData.write(to: tempFileURL)
            
            await MainActor.run {
                audioFileURL = tempFileURL
            }
            
            logger.notice("💾 Saved Paraformer audio to: \(tempFileURL.lastPathComponent)")
            
        } catch {
            logger.error("❌ Failed to save Paraformer audio: \(error)")
        }
    }
    
    private func createWAVFile(from pcmData: Data) -> Data {
        let sampleRate: UInt32 = UInt32(captureSampleRate)
        let bitsPerSample: UInt16 = 16
        let channels: UInt16 = UInt16(captureChannelCount)
        
        var wavData = Data()
        
        // WAV header
        wavData.append("RIFF".data(using: .ascii)!)
        wavData.append(withUnsafeBytes(of: UInt32(36 + pcmData.count)) { Data($0) })
        wavData.append("WAVE".data(using: .ascii)!)
        wavData.append("fmt ".data(using: .ascii)!)
        wavData.append(withUnsafeBytes(of: UInt32(16)) { Data($0) }) // Format chunk size
        wavData.append(withUnsafeBytes(of: UInt16(1)) { Data($0) }) // Audio format (PCM)
        wavData.append(withUnsafeBytes(of: channels) { Data($0) })
        wavData.append(withUnsafeBytes(of: sampleRate) { Data($0) })
        wavData.append(withUnsafeBytes(of: UInt32(sampleRate * UInt32(channels * bitsPerSample / 8))) { Data($0) }) // Byte rate
        wavData.append(withUnsafeBytes(of: UInt16(channels * bitsPerSample / 8)) { Data($0) }) // Block align
        wavData.append(withUnsafeBytes(of: bitsPerSample) { Data($0) })
        wavData.append("data".data(using: .ascii)!)
        wavData.append(withUnsafeBytes(of: UInt32(pcmData.count)) { Data($0) })
        
        // PCM data
        wavData.append(pcmData)
        
        return wavData
    }
    
    private func receiveMessages() async {
        guard let webSocket = webSocket else { return }
        
        while !Task.isCancelled {
            do {
                let message = try await webSocket.receive()
                
                switch message {
                case .data(let data):
                    await handleRecognitionResult(data)
                case .string(let text):
                    await handleTextMessage(text)
                @unknown default:
                    break
                }
                
            } catch {
                let ns = error as NSError
                let isSocketNotConnected = (ns.domain == NSPOSIXErrorDomain && ns.code == 57) || ns.localizedDescription.lowercased().contains("socket is not connected")
                if Task.isCancelled || isSocketNotConnected {
                    logger.debug("🔌 [WS] Receive ended (benign): \(ns.localizedDescription)")
                    await MainActor.run { connectionStatus = .disconnected }
                    break
                }
                logger.error("❌ WebSocket receive error: \(error)")
                await MainActor.run {
                    connectionStatus = .error(error.localizedDescription)
                }
                break
            }
        }
    }
    
    private func handleRecognitionResult(_ data: Data) async {
        do {
            // Parse as DashScope WebSocket protocol response
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                logger.warning("⚠️ Invalid JSON format in recognition result")
                return
            }
            
            logger.debug("📝 Paraformer JSON response: \(json)")
            
            // Check for header information
            if let header = json["header"] as? [String: Any] {
                let event = header["event"] as? String ?? ""
                let statusCode = header["code"] as? Int ?? 0
                
                // Handle error responses
                if statusCode != 20000 && statusCode != 0 {
                    let message = header["message"] as? String ?? "Unknown error"
                    logger.error("❌ Paraformer error \(statusCode): \(message)")
                    return
                }
                
                // Handle different event types
                switch event {
                case "task-started":
                    logger.notice("📝 Paraformer task started")
                case "result-generated":
                    await handleResultGenerated(json)
                case "task-finished":
                    logger.notice("✅ Paraformer task finished")
                default:
                    logger.debug("📝 Paraformer event: \(event)")
                }
            }
            
            // Handle payload data for result-generated events
            if let payload = json["payload"] as? [String: Any],
               let output = payload["output"] as? [String: Any] {
                await handleOutputResult(output)
            }
            
        } catch {
            logger.error("❌ Failed to decode Paraformer result: \(error)")
        }
    }
    
    private func handleResultGenerated(_ json: [String: Any]) async {
        guard let payload = json["payload"] as? [String: Any],
              let output = payload["output"] as? [String: Any] else {
            logger.warning("⚠️ Invalid result-generated format")
            return
        }
        
        // Handle DashScope format - look for sentence in output
        if let sentence = output["sentence"] as? [String: Any],
           let text = sentence["text"] as? String {
            
            let sentenceEnd = sentence["sentence_end"] as? Bool ?? false
            let endTime = sentence["end_time"]
            
            await MainActor.run {
                if sentenceEnd || endTime != nil {
                    // Final result - APPEND to buffer, don't replace
                    finalBuffer += text.hasSuffix(" ") ? text : text + " "
                    partialTranscript = ""
                    logger.notice("✅ Final result: \(text)")
                } else {
                    // Partial result - just update display
                    partialTranscript = text
                    logger.debug("📝 Partial result: \(text)")
                }
            }
        }
        
        // Also check for direct text field
        if let text = output["text"] as? String {
            await MainActor.run {
                finalBuffer += text.hasSuffix(" ") ? text : text + " "
                partialTranscript = ""
            }
            logger.notice("✅ Direct result: \(text)")
        }
    }
    
    private func handlePartialResult(_ json: [String: Any]) async {
        if let payload = json["payload"] as? [String: Any],
           let output = payload["output"] as? [String: Any],
           let sentence = output["sentence"] as? [String: Any],
           let text = sentence["text"] as? String {
            
            await MainActor.run {
                partialTranscript = text
            }
            logger.debug("📝 Partial: \(text)")
        }
    }
    
    private func handleFinalResult(_ json: [String: Any]) async {
        if let payload = json["payload"] as? [String: Any],
           let output = payload["output"] as? [String: Any],
           let sentence = output["sentence"] as? [String: Any],
           let text = sentence["text"] as? String {
            
            await MainActor.run {
                finalBuffer += text
                partialTranscript = "" // Clear partial
            }
            logger.notice("✅ Final: \(text)")
        }
    }
    
    private func handleOutputResult(_ output: [String: Any]) async {
        // Handle direct output format (for compatibility)
        if let sentence = output["sentence"] as? [String: Any],
           let text = sentence["text"] as? String {
            
            let confidence = sentence["confidence"] as? Double ?? 0.0
            
            await MainActor.run {
                // Check if this looks like a final result (has confidence or certain indicators)
                if confidence > 0.0 || text.hasSuffix(".") || text.hasSuffix("。") {
                    finalBuffer += text
                    partialTranscript = ""
                } else {
                    partialTranscript = text
                }
            }
            
            let confidenceStr = confidence > 0.0 ? " (confidence: \(String(format: "%.2f", confidence)))" : ""
            logger.notice("📝 Result: \(text)\(confidenceStr)")
        }
    }
    
    private func handleTextMessage(_ text: String) async {
        logger.debug("📝 Paraformer text message: \(text)")
        
        // Try to parse as JSON for structured responses
        if let data = text.data(using: .utf8) {
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    await handleRecognitionResult(data)
                    return
                }
            } catch {
                // Not JSON, handle as plain text
            }
        }
        
        // Handle special control messages
        if text.contains("finished") || text.contains("TranscriptionCompleted") {
            finishedReceived = true
            logger.notice("✅ Paraformer session finished")
        }
        
        // Handle error messages
        if text.contains("error") || text.contains("Error") {
            logger.error("❌ Paraformer error message: \(text)")
        }
    }
    
    // MARK: - Language and Context Helpers
    
    /// Get language hints for Paraformer based on user selection
    private func getParaformerLanguageHints() -> [String] {
        // Get user's selected languages from multiple language selection
        guard let selectedLanguagesData = UserDefaults.standard.data(forKey: "SelectedLanguages") else {
            // Fallback to single language selection for backward compatibility
            let selectedLanguage = UserDefaults.standard.string(forKey: "SelectedLanguage") ?? "zh"
            return [selectedLanguage == "auto" ? "zh" : selectedLanguage]
        }
        
        do {
            let selectedLanguages = try JSONDecoder().decode(Set<String>.self, from: selectedLanguagesData)
            
            // Validate all selected languages are supported by Paraformer
            let validLanguages = selectedLanguages.filter { ParaformerWebSocketASRService.supportedLanguages.keys.contains($0) }
            
            // If auto is selected, return Chinese as default
            if validLanguages.contains("auto") {
                return ["zh"]
            }
            
            // Return valid languages or default to Chinese if none valid
            return validLanguages.isEmpty ? ["zh"] : Array(validLanguages)
        } catch {
            logger.error("Failed to decode selected languages: \(error)")
            // Fallback to single language selection
            let selectedLanguage = UserDefaults.standard.string(forKey: "SelectedLanguage") ?? "zh"
            return [selectedLanguage == "auto" ? "zh" : selectedLanguage]
        }
    }
    
    /// Get dictionary context/hotwords for Paraformer
    private func getDictionaryContext() -> [String] {
        // Get user's custom words from UserDefaults (same as WordReplacementService)
        guard let replacements = UserDefaults.standard.dictionary(forKey: "wordReplacements") as? [String: String] else {
            return []
        }
        
        // Return both keys (original words) and values (replacement words) as hotwords
        let allWords = Array(replacements.keys) + Array(replacements.values)
        return Array(Set(allWords)) // Remove duplicates
    }
    
    @objc private func forceCleanup() {
        logger.notice("🧹 Force cleanup triggered by app termination")
        Task {
            await stopStreaming()
            await cleanupConnection()
            await stopAudioEngine()
        }
    }
}

// MARK: - Data Models

// Legacy models kept for compatibility - the service now uses Alibaba Cloud WebSocket protocol

struct ParaformerConfig: Codable {
    let apiKey: String
    let model: String
    let sampleRate: Int
    let language: String
    let languageHints: [String]?
    let enableHeartbeat: Bool
    let enableInverseTextNormalization: Bool
    let enablePunctuation: Bool
    let hotwords: [String]?
    
    enum CodingKeys: String, CodingKey {
        case apiKey = "api_key"
        case model
        case sampleRate = "sample_rate"
        case language
        case languageHints = "language_hints"
        case enableHeartbeat = "enable_heartbeat"
        case enableInverseTextNormalization = "inverse_text_normalization_enabled"
        case enablePunctuation = "enable_punctuation"
        case hotwords
    }
}

// MARK: - Extensions

extension ParaformerWebSocketASRService {
    
    /// Get supported languages for Paraformer v2
    static var supportedLanguages: [String: String] {
        return [
            "zh": "Chinese (Mandarin)",
            "zh-CN": "Chinese (Simplified)",
            "zh-TW": "Chinese (Traditional)",
            "zh-HK": "Chinese (Hong Kong)",
            "zh-SH": "Chinese (Shanghai)",
            "zh-WU": "Chinese (Wu)",
            "zh-MIN": "Chinese (Min/Hokkien)",
            "zh-NE": "Chinese (Northeast)",
            "zh-GS": "Chinese (Gansu)",
            "zh-GZ": "Chinese (Guangzhou)",
            "zh-HN": "Chinese (Henan)",
            "zh-HB": "Chinese (Hubei)",
            "zh-HUN": "Chinese (Hunan)",
            "zh-JX": "Chinese (Jiangxi)",
            "zh-NX": "Chinese (Ningxia)",
            "zh-SX": "Chinese (Shanxi)",
            "zh-SN": "Chinese (Shaanxi)",
            "zh-SD": "Chinese (Shandong)",
            "zh-SC": "Chinese (Sichuan)",
            "zh-TJ": "Chinese (Tianjin)",
            "zh-YN": "Chinese (Yunnan)",
            "zh-YUE": "Chinese (Cantonese)",
            "en": "English",
            "ja": "Japanese",
            "ko": "Korean",
            "de": "German",
            "fr": "French",
            "ru": "Russian"
        ]
    }
}
