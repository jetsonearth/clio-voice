import Foundation
#if canImport(whisper)
import whisper
#else
#error("Unable to import whisper module. Please check your project configuration.")
#endif
import os

enum WhisperVADError: Error {
    case couldNotInitializeVAD
    case vadModelNotFound
    case invalidAudioData
    case vadProcessingFailed
}

// VAD segment representing a speech region
struct VADSegment {
    let startTime: Float  // Start time in seconds
    let endTime: Float    // End time in seconds
    let startSample: Int  // Start sample index
    let endSample: Int    // End sample index
}

// Swift wrapper for whisper_vad_params
struct VADParams {
    // Tuned defaults – less aggressive splitting
    // These values reduce micro-segments and improve overall transcription speed
    var threshold: Float = 0.60              // Require higher speech probability
    var minSpeechDurationMs: Int32 = 600     // Ignore bursts shorter than 0.6 s
    var minSilenceDurationMs: Int32 = 400    // Need ≥0.4 s pause to split
    var maxSpeechDurationS: Float = 45.0     // Allow longer continuous speech
    var speechPadMs: Int32 = 100             // Extra padding so edge words aren’t clipped
    var samplesOverlap: Float = 0.1          // Overlap when copying samples
    
    // Convert to C struct
    var cParams: whisper_vad_params {
        var params = whisper_vad_params()
        params.threshold = threshold
        params.min_speech_duration_ms = minSpeechDurationMs
        params.min_silence_duration_ms = minSilenceDurationMs
        params.max_speech_duration_s = maxSpeechDurationS
        params.speech_pad_ms = speechPadMs
        params.samples_overlap = samplesOverlap
        return params
    }
}

// Thread-safe VAD context wrapper
actor WhisperVADContext {
    private var vadContext: OpaquePointer?
    private let logger = Logger(subsystem: "com.jetsonai.clio", category: "WhisperVAD")
    
    init() {
        // Initializer without context - will be loaded later
    }
    
    deinit {
        if let vadContext = vadContext {
            whisper_vad_free(vadContext)
        }
    }
    
    // Initialize VAD from model file
    func initializeFromFile(modelPath: String) throws {
        // logger.info("Loading VAD model from: \(modelPath)")  // Reduced logging verbosity
        
        // Check if file exists
        guard FileManager.default.fileExists(atPath: modelPath) else {
            throw WhisperVADError.vadModelNotFound
        }
        
        // Initialize with default params
        var contextParams = whisper_vad_default_context_params()
        contextParams.use_gpu = true  // Enable GPU if available
        
        // Load VAD model
        vadContext = whisper_vad_init_from_file_with_params(modelPath, contextParams)
        
        guard vadContext != nil else {
            logger.error("Failed to initialize VAD context")
            throw WhisperVADError.couldNotInitializeVAD
        }
        
        // logger.info("VAD model loaded successfully")  // Reduced logging verbosity
    }
    
    // Process audio samples and detect speech segments
    func detectSpeechSegments(samples: [Float], params: VADParams = VADParams()) throws -> [VADSegment] {
        guard let vadContext = vadContext else {
            throw WhisperVADError.couldNotInitializeVAD
        }
        
        guard !samples.isEmpty else {
            throw WhisperVADError.invalidAudioData
        }
        
        // logger.info("Processing \(samples.count) samples for VAD")  // Reduced logging verbosity
        
        // Get speech segments directly
        let cParams = params.cParams
        guard let segmentsPtr = samples.withUnsafeBufferPointer({ samplesPtr in
            whisper_vad_segments_from_samples(
                vadContext,
                cParams,
                samplesPtr.baseAddress,
                Int32(samples.count)
            )
        }) else {
            logger.error("Failed to extract speech segments")
            throw WhisperVADError.vadProcessingFailed
        }
        
        defer {
            whisper_vad_free_segments(segmentsPtr)
        }
        
        // Convert C segments to Swift structs
        let segmentCount = Int(whisper_vad_segments_n_segments(segmentsPtr))
        var segments: [VADSegment] = []
        
        for i in 0..<segmentCount {
            let t0 = whisper_vad_segments_get_segment_t0(segmentsPtr, Int32(i))
            let t1 = whisper_vad_segments_get_segment_t1(segmentsPtr, Int32(i))
            
            // logger.debug("Raw VAD segment \(i): t0=\(t0), t1=\(t1)")  // Reduced logging verbosity
            
            // t0 and t1 appear to be in centiseconds (1/100th of a second)
            // Convert to seconds first, then to sample indices (assuming 16kHz)
            let startTimeSeconds = t0 / 100.0
            let endTimeSeconds = t1 / 100.0
            let startSample = Int(startTimeSeconds * 16000.0)
            let endSample = Int(endTimeSeconds * 16000.0)
            
            // logger.debug("Converted segment \(i): \(startTimeSeconds)s-\(endTimeSeconds)s, samples: \(startSample)-\(endSample)")  // Reduced logging verbosity
            
            segments.append(VADSegment(
                startTime: startTimeSeconds,
                endTime: endTimeSeconds,
                startSample: startSample,
                endSample: endSample
            ))
        }
        
        // logger.info("Detected \(segments.count) speech segments")  // Reduced logging verbosity
        if segments.isEmpty {
            logger.warning("⚠️ No speech segments detected - this might indicate all audio was silence")
        }
        // Commented out per-segment debug logging for reduced verbosity
        // else {
        //     for (i, segment) in segments.enumerated() {
        //         logger.debug("Segment \(i): \(String(format: "%.3f", segment.startTime))s - \(String(format: "%.3f", segment.endTime))s (duration: \(String(format: "%.3f", segment.endTime - segment.startTime))s)")
        //     }
        // }
        
        return segments
    }
    
    // Extract speech-only samples based on VAD segments
    func extractSpeechSamples(from samples: [Float], segments: [VADSegment]) -> [Float] {
        var speechSamples: [Float] = []
        
        // logger.debug("Extracting speech from \(segments.count) segments, total samples: \(samples.count)")  // Reduced logging verbosity
        
        for (i, segment) in segments.enumerated() {
            let startIdx = max(0, segment.startSample)
            let endIdx = min(samples.count, segment.endSample)
            
            // logger.debug("Segment \(i): startSample=\(segment.startSample), endSample=\(segment.endSample), startIdx=\(startIdx), endIdx=\(endIdx)")  // Reduced logging verbosity
            
            if startIdx < endIdx {
                let segmentSamples = endIdx - startIdx
                speechSamples.append(contentsOf: samples[startIdx..<endIdx])
                // logger.debug("Added \(segmentSamples) samples from segment \(i)")  // Reduced logging verbosity
            } else {
                logger.warning("Skipping segment \(i): invalid range [\(startIdx), \(endIdx))")
            }
        }
        
        let silenceRemoved = Float(samples.count - speechSamples.count) / Float(samples.count) * 100
        // logger.info("Extracted \(speechSamples.count) speech samples from \(samples.count) total (removed \(String(format: "%.1f", silenceRemoved))% silence)")  // Reduced logging verbosity
        
        return speechSamples
    }
    
    // Get VAD processing statistics
    func getVADStats(originalSamples: Int, speechSamples: Int) -> (silencePercentage: Float, speechDuration: Float) {
        let silencePercentage = Float(originalSamples - speechSamples) / Float(originalSamples) * 100
        let speechDuration = Float(speechSamples) / 16000.0  // Assuming 16kHz
        return (silencePercentage, speechDuration)
    }
}

// Extension to RecordingEngine for VAD integration
extension RecordingEngine {
    // VAD model URL - Using HuggingFace repository
    static let vadModelURL = "https://huggingface.co/ggml-org/whisper-vad/resolve/main/ggml-silero-v5.1.2.bin"
    static let vadModelFileName = "ggml-silero-v5.1.2.bin"
    
    // Get VAD model path
    var vadModelPath: String {
        return modelsDirectory.appendingPathComponent(Self.vadModelFileName).path
    }
    
    // Check if VAD model exists
    var isVADModelDownloaded: Bool {
        return FileManager.default.fileExists(atPath: vadModelPath)
    }
}