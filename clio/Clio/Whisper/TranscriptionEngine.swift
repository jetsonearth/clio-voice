import Foundation

// MARK: - Transcription Engine Protocol

/// Protocol defining the interface for different transcription engines
protocol TranscriptionEngineProtocol {
    /// Initialize the engine with a model
    func initializeModel(modelPath: String) async throws
    
    /// Transcribe audio from file path
    func transcribe(audioPath: String) async throws -> TranscriptionResult
    
    /// Transcribe audio from samples
    func transcribe(samples: [Float]) async throws -> TranscriptionResult
    
    /// Start streaming transcription (if supported)
    func startStreaming() async throws
    
    /// Stop streaming transcription (if supported)
    func stopStreaming() async
    
    /// Check if engine is ready for transcription
    var isReady: Bool { get }
    
    /// Get engine name
    var engineName: String { get }
    
    /// Release resources
    func releaseResources() async
}

// MARK: - Transcription Engine Types

enum TranscriptionEngine: String, CaseIterable {
    case whisperCpp = "whisper_cpp"
    
    var displayName: String {
        switch self {
        case .whisperCpp: 
            return "Whisper.cpp"
        }
    }
    
    var description: String {
        switch self {
        case .whisperCpp:
            return "Production engine with CoreML acceleration"
        }
    }
    
    var isExperimental: Bool {
        switch self {
        case .whisperCpp: return false
        }
    }
}

// MARK: - Transcription Result

struct TranscriptionResult {
    let text: String
    let segments: [TranscriptionSegment]
    let processingTimeMs: Double
    let engineUsed: TranscriptionEngine
    let modelName: String?
    
    init(text: String, segments: [TranscriptionSegment] = [], processingTimeMs: Double, engineUsed: TranscriptionEngine, modelName: String? = nil) {
        self.text = text
        self.segments = segments
        self.processingTimeMs = processingTimeMs
        self.engineUsed = engineUsed
        self.modelName = modelName
    }
}

// MARK: - Transcription Segment

struct TranscriptionSegment {
    let start: Double    // Start time in seconds
    let end: Double      // End time in seconds
    let text: String     // Transcribed text for this segment
    
    init(start: Double, end: Double, text: String) {
        self.start = start
        self.end = end
        self.text = text
    }
}