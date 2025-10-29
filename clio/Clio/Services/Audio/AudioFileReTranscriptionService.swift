import Foundation
import AVFoundation
import SwiftData
import os

@MainActor
class AudioFileReTranscriptionService: ObservableObject {
    @Published var isReTranscribing = false
    @Published var progress: Double = 0.0
    @Published var statusMessage = ""
    
    private let logger = Logger(subsystem: "com.jetsonai.clio", category: "AudioFileReTranscription")
    private var audioPlayer: AVAudioPlayer?
    private var playbackTimer: Timer?
    private let modelContext: ModelContext
    private let enhancementService: AIEnhancementService

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        // Create a fresh ContextService for enhancement; it will reuse cached context if available
        let contextService = ContextService()
        self.enhancementService = AIEnhancementService(contextService: contextService, modelContext: modelContext)
    }

    func reTranscribeWithSoniox(audioURL: URL, originalTranscription: Transcription) async throws -> Transcription {
        await MainActor.run {
            isReTranscribing = true
            progress = 0.0
            statusMessage = "Uploading audio for re-transcription..."
        }

        logger.notice("🔄 Starting Soniox file-upload re-transcription for: \(audioURL.lastPathComponent)")

        // Read audio bytes (ensure full file is read)
        let audioData = try Data(contentsOf: audioURL, options: .mappedIfSafe)
        logger.notice("🎧 [RETRANSCRIBE] Local file size: \(audioData.count) bytes for \(audioURL.lastPathComponent)")

        // Build request to backend retranscribe endpoint
        guard let token = try? await TokenManager.shared.getValidToken() else {
            throw ReTranscriptionError.connectionFailed("Auth token unavailable")
        }

        // Prepare query parameters: language hints + context
        let languageHints = SonioxLanguages.defaultHintsJoined()
        let context = ContextService().getContextData()

        // Build URL
        let base = APIConfig.apiBaseURL
        let fileName = audioURL.lastPathComponent
        var comps = URLComponents(string: "\(base)/asr/retranscribe-file")!
        comps.queryItems = [
            URLQueryItem(name: "fileName", value: fileName),
            URLQueryItem(name: "languageHints", value: languageHints)
        ]

        var request = URLRequest(url: comps.url!)
        request.httpMethod = "POST"
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        request.setValue(String(audioData.count), forHTTPHeaderField: "Content-Length")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = audioData
        request.timeoutInterval = 120

        let start = CFAbsoluteTimeGetCurrent()
        let (data, response) = try await URLSession.shared.data(for: request)
        let elapsed = (CFAbsoluteTimeGetCurrent() - start) * 1000
        logger.notice("⏱️ [RETRANSCRIBE] Backend roundtrip: \(Int(elapsed))ms")

        guard let http = response as? HTTPURLResponse else {
            throw ReTranscriptionError.connectionFailed("Invalid response")
        }

        if http.statusCode == 202 {
            await MainActor.run {
                statusMessage = "Transcription in progress. Please try again shortly."
                isReTranscribing = false
            }
            throw ReTranscriptionError.connectionFailed("Transcription still processing")
        }

        guard http.statusCode == 200,
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            let body = String(data: data, encoding: .utf8) ?? ""
            logger.error("❌ [RETRANSCRIBE] HTTP \(http.statusCode): \(body)")
            throw ReTranscriptionError.connectionFailed("Retranscribe failed: \(http.statusCode)")
        }

        let text = (json["text"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if text.isEmpty {
            await MainActor.run {
                statusMessage = "Transcription returned empty text"
                isReTranscribing = false
            }
            throw ReTranscriptionError.emptyTranscription
        }

        // Build values to persist as a NEW record (do not mutate original)
        var finalText = text
        var enhancedText: String? = nil
        var llmLatency: Double? = nil

        // LLM post-processing (non-blocking failure)
        do {
            let llmStart = CFAbsoluteTimeGetCurrent()
            let enhanced = try await enhancementService.enhance(text)
            llmLatency = (CFAbsoluteTimeGetCurrent() - llmStart) * 1000
            enhancedText = enhanced
        } catch {
            logger.notice("⚠️ [RETRANSCRIBE] Enhancement failed, keeping raw text: \(error.localizedDescription)")
        }

        // Create a new Transcription that reuses the SAME audio file
        let newItem = Transcription(
            text: finalText,
            duration: originalTranscription.duration,
            enhancedText: enhancedText,
            audioFileURL: originalTranscription.audioFileURL,
            processingLatencyMs: elapsed,
            llmLatencyMs: llmLatency,
            totalLatencyMs: (llmLatency ?? 0) + elapsed,
            aiProvider: enhancedText == nil ? nil : enhancementService.getAIService()?.selectedProvider.rawValue
        )
        modelContext.insert(newItem)

        await MainActor.run {
            statusMessage = "Re-transcription completed! (new entry created)"
            progress = 1.0
            isReTranscribing = false
        }

        return newItem
    }
    
}

enum ReTranscriptionError: LocalizedError {
    case connectionFailed(String)
    case connectionTimeout
    case audioFormatError
    case audioBufferError
    case audioConversionError(String)
    case emptyTranscription
    
    var errorDescription: String? {
        switch self {
        case .connectionFailed(let message):
            return "Failed to connect to Soniox: \(message)"
        case .connectionTimeout:
            return "Connection to Soniox timed out"
        case .audioFormatError:
            return "Unable to set up audio format conversion"
        case .audioBufferError:
            return "Failed to create audio buffer"
        case .audioConversionError(let message):
            return "Audio conversion failed: \(message)"
        case .emptyTranscription:
            return "Re-transcription produced empty result"
        }
    }
}
