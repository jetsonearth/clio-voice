import Foundation
import SwiftUI
import AVFoundation
import SwiftData
import os

@MainActor
class AudioTranscriptionService: ObservableObject {
    @Published var isTranscribing = false
    @Published var messageLog = ""
    @Published var currentError: TranscriptionError?
    
    private var whisperContext: WhisperContext?
    private let modelContext: ModelContext
    private let enhancementService: AIEnhancementService?
    private let recordingEngine: RecordingEngine
    private let logger = Logger(subsystem: "com.jetsonai.clio", category: "AudioTranscriptionService")
    
    enum TranscriptionError: Error {
        case noAudioFile
        case transcriptionFailed
        case modelNotLoaded
        case invalidAudioFormat
    }
    
    init(modelContext: ModelContext, recordingEngine: RecordingEngine) {
        self.modelContext = modelContext
        self.recordingEngine = recordingEngine
        self.enhancementService = recordingEngine.enhancementService
    }
    
    func retranscribeAudio(from url: URL, using whisperModel: WhisperModel) async throws -> Transcription {
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw TranscriptionError.noAudioFile
        }
        
        let processingStartTime = Date() // T0 for retranscription
        
        await MainActor.run {
            isTranscribing = true
            messageLog = "Loading model...\n"
        }
        
        // Load the whisper model if needed
        if whisperContext == nil {
            do {
                whisperContext = try await WhisperContext.createContext(path: whisperModel.url.path)
                messageLog += "Model loaded successfully.\n"
            } catch {
                logger.error("❌ Failed to load model: \(error.localizedDescription)")
                messageLog += "Failed to load model: \(error.localizedDescription)\n"
                isTranscribing = false
                throw TranscriptionError.modelNotLoaded
            }
        }
        
        guard let whisperContext = whisperContext else {
            isTranscribing = false
            throw TranscriptionError.modelNotLoaded
        }
        
        // Handle compressed audio files by decompressing them first
        var workingURL = url
        let isCompressed = url.pathExtension.lowercased() == "m4a" || url.pathExtension.lowercased() == "mp3"
        
        if isCompressed {
            messageLog += "Decompressing audio file...\n"
            let compressionService = AudioCompressionService()
            let tempWAVURL = url.deletingPathExtension().appendingPathExtension("wav")
            
            do {
                _ = try await compressionService.decompressAudio(from: url, to: tempWAVURL)
                workingURL = tempWAVURL
                messageLog += "Audio decompressed successfully.\n"
            } catch {
                logger.error("❌ Failed to decompress audio: \(error.localizedDescription)")
                messageLog += "Failed to decompress audio: \(error.localizedDescription)\n"
                isTranscribing = false
                throw TranscriptionError.invalidAudioFormat
            }
        }
        
        // Get audio duration
        let audioAsset = AVURLAsset(url: workingURL)
        let duration = CMTimeGetSeconds(try await audioAsset.load(.duration))
        
        // Create a permanent copy of the audio file
        let recordingsDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("com.jetsonai.clio")
            .appendingPathComponent("Recordings")
        
        let fileName = "retranscribed_\(UUID().uuidString).wav"
        let permanentURL = recordingsDirectory.appendingPathComponent(fileName)
        
        do {
            try FileManager.default.copyItem(at: workingURL, to: permanentURL)
            
            // Clean up temporary decompressed file if we created one
            if isCompressed && workingURL != url {
                try? FileManager.default.removeItem(at: workingURL)
            }
        } catch {
            logger.error("❌ Failed to create permanent copy of audio: \(error.localizedDescription)")
            messageLog += "Failed to create permanent copy of audio: \(error.localizedDescription)\n"
            
            // Clean up temporary file on error
            if isCompressed && workingURL != url {
                try? FileManager.default.removeItem(at: workingURL)
            }
            
            isTranscribing = false
            throw error
        }
        
        let permanentURLString = permanentURL.absoluteString
        
        // Transcribe the audio
        messageLog += "Transcribing audio...\n"
        
        do {
            // Read audio samples
            let samples = try readAudioSamples(permanentURL)
            
            // Process with Whisper - using the same prompt as RecordingEngine
            messageLog += "Setting prompt: \(recordingEngine.whisperPrompt.transcriptionPrompt)\n"
            await whisperContext.setPrompt(recordingEngine.whisperPrompt.transcriptionPrompt)
            
            try await whisperContext.fullTranscribe(samples: samples)
            var text = await whisperContext.getTranscription()
            text = text.trimmingCharacters(in: .whitespacesAndNewlines)
            logger.notice("✅ Retranscription completed successfully, length: \(text.count) characters")
            
            // Calculate processing latency (T1 - T0)
            let processingLatencyMs = Date().timeIntervalSince(processingStartTime) * 1000
            
            // Apply word replacements if enabled
            if UserDefaults.standard.bool(forKey: "IsWordReplacementEnabled") {
                text = WordReplacementService.shared.applyReplacements(to: text)
                logger.notice("✅ Word replacements applied")
            }
            
            // Apply AI enhancement if enabled - using the same enhancement service as RecordingEngine
            if let enhancementService = enhancementService,
               enhancementService.isEnhancementEnabled,
               enhancementService.isConfigured {
                do {
                    messageLog += "Enhancing transcription with AI...\n"
                    let preclean = RawDisfluencySanitizer.clean(text)
                    let enhancedText = try await enhancementService.enhance(preclean)
                    messageLog += "Enhancement completed.\n"
                    
                    let newTranscription = Transcription(
                        text: text,
                        duration: duration,
                        enhancedText: enhancedText,
                        audioFileURL: permanentURLString,
                        processingLatencyMs: processingLatencyMs
                    )
                    modelContext.insert(newTranscription)
                    do {
                        try modelContext.save()
                    } catch {
                        logger.error("❌ Failed to save transcription: \(error.localizedDescription)")
                        messageLog += "Failed to save transcription: \(error.localizedDescription)\n"
                    }
                    
                    await MainActor.run {
                        isTranscribing = false
                        messageLog += "Done: \(enhancedText)\n"
                    }
                    
                    return newTranscription
                } catch {
                    messageLog += "Enhancement failed: \(error.localizedDescription). Using original transcription.\n"
                    let newTranscription = Transcription(
                        text: text,
                        duration: duration,
                        audioFileURL: permanentURLString,
                        processingLatencyMs: processingLatencyMs
                    )
                    modelContext.insert(newTranscription)
                    do {
                        try modelContext.save()
                    } catch {
                        logger.error("❌ Failed to save transcription: \(error.localizedDescription)")
                        messageLog += "Failed to save transcription: \(error.localizedDescription)\n"
                    }
                    
                    await MainActor.run {
                        isTranscribing = false
                        messageLog += "Done: \(text)\n"
                    }
                    
                    return newTranscription
                }
            } else {
                let newTranscription = Transcription(
                    text: text,
                    duration: duration,
                    audioFileURL: permanentURLString,
                    processingLatencyMs: processingLatencyMs
                )
                modelContext.insert(newTranscription)
                do {
                    try modelContext.save()
                } catch {
                    logger.error("❌ Failed to save transcription: \(error.localizedDescription)")
                    messageLog += "Failed to save transcription: \(error.localizedDescription)\n"
                }
                
                await MainActor.run {
                    isTranscribing = false
                    messageLog += "Done: \(text)\n"
                }
                
                return newTranscription
            }
        } catch {
            logger.error("❌ Transcription failed: \(error.localizedDescription)")
            messageLog += "Transcription failed: \(error.localizedDescription)\n"
            currentError = .transcriptionFailed
            isTranscribing = false
            throw error
        }
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
}
