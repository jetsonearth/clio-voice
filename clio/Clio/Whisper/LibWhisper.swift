import Foundation
#if canImport(whisper)
import whisper
#else
#error("Unable to import whisper module. Please check your project configuration.")
#endif
import os

enum WhisperError: Error {
    case couldNotInitializeContext
}

// Meet Whisper C++ constraint: Don't access from more than one thread at a time.
actor WhisperContext {
    private var context: OpaquePointer?
    private var languageCString: [CChar]?
    private var prompt: String?
    private var promptCString: [CChar]?
    // Built-in VAD support
    private var vadModelPath: String?
    private var vadModelPathCString: [CChar]?
    private let logger = Logger(subsystem: "com.jetsonai.clio", category: "WhisperContext")

    private init() {
        // Private initializer without context
    }

    init(context: OpaquePointer) {
        self.context = context
    }

    deinit {
        if let context = context {
            whisper_free(context)
        }
    }

    func fullTranscribe(samples: [Float]) {
        guard let context = context else { return }
        
        // Leave 2 processors free (i.e. the high-efficiency cores).
        let maxThreads = max(1, min(8, cpuCount() - 2))
        // Use beam search (same as CLI default "--beam-size 5 --best-of 5") for higher accuracy
        var params = whisper_full_default_params(WHISPER_SAMPLING_BEAM_SEARCH)
        params.beam_search.beam_size = 5
        // Align temperature schedule with CLI (-tp 0)
        params.temperature = 0.0
        params.temperature_inc = 0.0
        
        // Read language directly from UserDefaults
        let selectedLanguage = UserDefaults.standard.string(forKey: "SelectedLanguage") ?? "auto"
        if selectedLanguage != "auto" {
            languageCString = Array(selectedLanguage.utf8CString)
            params.language = languageCString?.withUnsafeBufferPointer { ptr in
                ptr.baseAddress
            }
            logger.notice("🌐 Using language: \(selectedLanguage)")
        } else {
            languageCString = nil
            params.language = nil
            logger.notice("🌐 Using auto language detection")
        }
        
        if let prompt = prompt, !prompt.isEmpty {
            promptCString = Array(prompt.utf8CString)
            params.initial_prompt = promptCString?.withUnsafeBufferPointer { ptr in
                ptr.baseAddress
            }
            logger.notice("💬 Using prompt for transcription in language: \(selectedLanguage)")
        } else {
            promptCString = nil
            params.initial_prompt = nil
        }
        
        params.print_realtime   = true
        params.print_progress   = false
        params.print_timestamps = false  // Disable for better accuracy
        params.print_special    = false
        params.translate        = false

        // --- VAD configuration (uses Whisper internal VAD) ---
        if let path = vadModelPath {
            params.vad = true
            // keep the C string alive during the whisper_full call
            vadModelPathCString = Array(path.utf8CString)
            params.vad_model_path = vadModelPathCString?.withUnsafeBufferPointer { $0.baseAddress }

            var vparams = whisper_vad_default_params()
            vparams.threshold = 0.60
            vparams.min_silence_duration_ms = 300
            params.vad_params = vparams
        } else {
            params.vad = false
        }
        // ------------------------------------------------------
        params.n_threads        = Int32(maxThreads)
        params.offset_ms        = 0
        // Disable cross-recording context to prevent token repetition between separate recordings
        params.no_context       = true
        params.single_segment   = false
        params.no_timestamps    = true    // Critical: Reduces hallucinations by 4x (from GitHub issue #1724)
        
        // Parameters optimized for accuracy based on whisper.cpp issues
        params.suppress_blank = true      // Suppress blank outputs
        params.suppress_nst = true        // Suppress non-speech tokens

        whisper_reset_timings(context)
        logger.notice("⚙️ Starting whisper transcription")
        samples.withUnsafeBufferPointer { samples in
            if (whisper_full(context, params, samples.baseAddress, Int32(samples.count)) != 0) {
                logger.error("❌ Failed to run whisper model")
            } else {
                // Print detected language info before timings
                let langId = whisper_full_lang_id(context)
                let detectedLang = String(cString: whisper_lang_str(langId))
                logger.notice("✅ Transcription completed - Language: \(detectedLang)")
                
            }
        }
        
        languageCString = nil
        promptCString = nil
    }

    func getTranscription() -> String {
        guard let context = context else { return "" }
        var transcription = ""
        for i in 0..<whisper_full_n_segments(context) {
            transcription += String(cString: whisper_full_get_segment_text(context, i))
        }
        // Local Whisper stack is deprecated; return as-is
        return transcription
    }

    static func createContext(path: String) async throws -> WhisperContext {
        // Create empty context first
        let whisperContext = WhisperContext()
        
        // Initialize the context within the actor's isolated context
        try await whisperContext.initializeModel(path: path)
        
        return whisperContext
    }
    
    private func initializeModel(path: String) throws {
        var params = whisper_context_default_params()
        // Enable FlashAttention when running on device for large speed ups (aligns with CLI "--flash-attn")
        params.flash_attn = true
        #if targetEnvironment(simulator)
        params.use_gpu = false
        logger.notice("🖥️ Running on simulator, using CPU")
        #endif
        
        let context = whisper_init_from_file_with_params(path, params)
        if let context {
            self.context = context
        } else {
            logger.error("❌ Couldn't load model at \(path)")
            throw WhisperError.couldNotInitializeContext
        }
    }

    func releaseResources() {
        if let context = context {
            whisper_free(context)
            self.context = nil
        }
        languageCString = nil
    }

    func setPrompt(_ prompt: String?) {
        self.prompt = prompt
        logger.debug("💬 Prompt set: \(prompt ?? "none")")
    }

    // Inject VAD model path from caller
    func setVADModelPath(_ path: String?) {
        self.vadModelPath = path
    }

    /// Clear previous timing information (no direct API to clear text ctx)
    func resetTimings() {
        guard let context = context else { return }
        whisper_reset_timings(context)
    }
}

fileprivate func cpuCount() -> Int {
    ProcessInfo.processInfo.processorCount
}
