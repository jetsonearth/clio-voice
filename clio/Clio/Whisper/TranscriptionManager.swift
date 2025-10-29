import Foundation
import SwiftUI
import os

#if !CLIO_ENABLE_LOCAL_MODEL
// Local transcription engine is not used in this build. Provide a minimal no-op
// class to satisfy any stale references without shipping engine code.
@MainActor
@Observable
class TranscriptionManager {
    var selectedEngine: TranscriptionEngine = .whisperCpp
    var isEngineReady = false
    var isTranscribing = false
    var lastTranscriptionResult: TranscriptionResult?
    var engineError: Error?
    var performanceMetrics: [String: Double] = [:]

    init() {}
}

#else

// MARK: - Transcription Manager

@MainActor
@Observable
class TranscriptionManager {
    
    // MARK: - Observable Properties
    
    var selectedEngine: TranscriptionEngine {
        didSet {
            UserDefaults.standard.set(selectedEngine.rawValue, forKey: "SelectedTranscriptionEngine")
            logger.notice("🔄 Transcription engine changed to: \(self.selectedEngine.displayName)")
        }
    }
    
    var isEngineReady = false
    var isTranscribing = false
    var lastTranscriptionResult: TranscriptionResult?
    var engineError: Error?
    
    // Performance tracking
    var performanceMetrics: [String: Double] = [:]
    
    // MARK: - Private Properties
    
    private let whisperCppAdapter = WhisperCppAdapter()
    private let logger = Logger(subsystem: "com.jetsonai.clio", category: "TranscriptionManager")
    
    // Reference to existing VAD context for whisper.cpp integration
    private weak var vadContext: WhisperVADContext?
    
    // MARK: - Computed Properties
    
    private var currentEngine: TranscriptionEngineProtocol {
        switch selectedEngine {
        case .whisperCpp:
            return whisperCppAdapter
        }
    }
    
//    var engineStatusText: String {
//        if isEngineReady {
//            return "Ready (\(currentEngine.engineName))"
//        } else if isTranscribing {
//            return "Transcribing... (\(currentEngine.engineName))"
//        } else {
//            return "Not Ready (\(currentEngine.engineName))"
//        }
//    }
    
    // MARK: - Initialization
    
    init() {
        // Load saved engine preference
        let savedEngine = UserDefaults.standard.string(forKey: "SelectedTranscriptionEngine") ?? TranscriptionEngine.whisperCpp.rawValue
        self.selectedEngine = TranscriptionEngine(rawValue: savedEngine) ?? .whisperCpp
        
        logger.notice("🚀 TranscriptionManager initialized with engine: \(self.selectedEngine.displayName)")
        
        updateEngineReadyState()
    }
    
    // MARK: - Engine Management
    
    func initializeEngine(modelPath: String) async throws {
        logger.notice("🔧 Initializing \(self.selectedEngine.displayName) with model: \(modelPath)")
        
        do {
            try await currentEngine.initializeModel(modelPath: modelPath)
            updateEngineReadyState()
            logger.notice("✅ Engine initialized successfully")
        } catch {
            engineError = error
            logger.error("❌ Failed to initialize engine: \(error.localizedDescription)")
            throw error
        }
    }
    
    func switchEngine(to newEngine: TranscriptionEngine) async {
        guard newEngine != selectedEngine else { return }
        
        logger.notice("🔄 Switching engine from \(self.selectedEngine.displayName) to \(newEngine.displayName)")
        
        // Release current engine resources
        await currentEngine.releaseResources()
        
        // Update selected engine
        selectedEngine = newEngine
        updateEngineReadyState()
        
        logger.notice("✅ Engine switched successfully")
    }
    
    private func updateEngineReadyState() {
        isEngineReady = currentEngine.isReady
    }
    
    // MARK: - Transcription Methods
    
    func transcribe(audioPath: String) async throws -> TranscriptionResult {
        guard isEngineReady else {
            throw TranscriptionManagerError.engineNotReady
        }
        
        guard !isTranscribing else {
            throw TranscriptionManagerError.transcriptionInProgress
        }
        
        isTranscribing = true
        engineError = nil
        
        defer {
            isTranscribing = false
        }
        
        do {
            logger.notice("🎯 Starting transcription with \(self.selectedEngine.displayName)")
            let result = try await currentEngine.transcribe(audioPath: audioPath)
            
            lastTranscriptionResult = result
            updatePerformanceMetrics(result)
            
            logger.notice("✅ Transcription completed: \(result.text.prefix(50))...")
            return result
            
        } catch {
            engineError = error
            logger.error("❌ Transcription failed: \(error.localizedDescription)")
            throw error
        }
    }
    
    func transcribe(samples: [Float]) async throws -> TranscriptionResult {
        guard isEngineReady else {
            throw TranscriptionManagerError.engineNotReady
        }
        
        guard !isTranscribing else {
            throw TranscriptionManagerError.transcriptionInProgress
        }
        
        isTranscribing = true
        engineError = nil
        
        defer {
            isTranscribing = false
        }
        
        do {
            let result = try await currentEngine.transcribe(samples: samples)

            lastTranscriptionResult = result
            updatePerformanceMetrics(result)
            
            logger.notice("✅ Transcription completed: \(result.text.prefix(50))...")
            return result
            
        } catch {
            engineError = error
            logger.error("❌ Transcription failed: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Performance Test
    
    func runPerformanceTest(audioPath: String) async -> TranscriptionResult? {
        logger.notice("🏁 Starting performance test")
        
        do {
            let result = try await transcribe(audioPath: audioPath)
            logger.notice("🏁 Performance test completed")
            return result
        } catch {
            logger.error("❌ Performance test failed: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Streaming (Future Implementation)
    
    func startStreaming() async throws {
        try await currentEngine.startStreaming()
    }
    
    func stopStreaming() async {
        await currentEngine.stopStreaming()
    }
    
    // MARK: - Resource Management
    
//    func releaseResources() async {
//        logger.notice("🧹 Releasing all transcription resources")
//        await whisperCppAdapter.releaseResources()
//        updateEngineReadyState()
//    }
    
    // MARK: - VAD Integration
    
    func setVADContext(_ vadContext: WhisperVADContext?) {
        self.vadContext = vadContext
        logger.notice("🎙️ VAD context \(vadContext != nil ? "set" : "cleared")")
    }
    
    // MARK: - Helper Methods
    
    private func updatePerformanceMetrics(_ result: TranscriptionResult) {
        let engineKey = result.engineUsed.rawValue
        performanceMetrics["\(engineKey)_last_time"] = result.processingTimeMs
        performanceMetrics["\(engineKey)_text_length"] = Double(result.text.count)
        
        // Calculate characters per second
        if result.processingTimeMs > 0 {
            performanceMetrics["\(engineKey)_chars_per_second"] = Double(result.text.count) / (result.processingTimeMs / 1000.0)
        }
    }
}

#endif

// MARK: - Whisper.cpp Adapter

#if CLIO_ENABLE_LOCAL_MODEL
final class WhisperCppAdapter: TranscriptionEngineProtocol {
    private var whisperContext: WhisperContext?
    private var activeModelName: String?
    private let audioProcessor = AudioProcessor()
    private let logger = Logger(subsystem: "com.cliovoice.clio", category: "WhisperCppAdapter")

    func initializeModel(modelPath: String) async throws {
        logger.notice("🧠 Initializing whisper.cpp context with model: \(modelPath)")
        whisperContext = try await WhisperContext.createContext(path: modelPath)
        activeModelName = URL(fileURLWithPath: modelPath).deletingPathExtension().lastPathComponent
    }

    func transcribe(audioPath: String) async throws -> TranscriptionResult {
        let url = URL(fileURLWithPath: audioPath)
        let samples = try await audioProcessor.processAudioToSamples(url)
        return try await transcribe(samples: samples)
    }

    func transcribe(samples: [Float]) async throws -> TranscriptionResult {
        guard let context = whisperContext else {
            throw TranscriptionManagerError.engineNotReady
        }

        let start = Date()
        await context.fullTranscribe(samples: samples)
        var text = await context.getTranscription()
        text = WhisperTextFormatter.format(text)
        let latencyMs = Date().timeIntervalSince(start) * 1000

        return TranscriptionResult(
            text: text,
            segments: [],
            processingTimeMs: latencyMs,
            engineUsed: .whisperCpp,
            modelName: activeModelName
        )
    }

    func startStreaming() async throws {
        throw TranscriptionManagerError.unsupportedEngine
    }

    func stopStreaming() async {}

    var isReady: Bool {
        whisperContext != nil
    }

    var engineName: String { "Whisper.cpp" }

    func releaseResources() async {
        await whisperContext?.releaseResources()
        whisperContext = nil
        activeModelName = nil
        logger.notice("🧹 Released whisper.cpp resources")
    }
}
#endif

// MARK: - Error Types

enum TranscriptionManagerError: Error, LocalizedError {
    case engineNotReady
    case transcriptionInProgress
    case unsupportedEngine
    
    var errorDescription: String? {
        switch self {
        case .engineNotReady:
            return "Transcription engine is not ready. Please initialize a model first."
        case .transcriptionInProgress:
            return "Transcription is already in progress."
        case .unsupportedEngine:
            return "The selected transcription engine is not supported."
        }
    }
}
