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

        logger.notice("🔄 Starting community re-transcription for: \(audioURL.lastPathComponent)")

        await MainActor.run {
            isReTranscribing = false
            statusMessage = "Cloud re-transcription is not available in the open-source build."
        }
        throw ReTranscriptionError.connectionFailed("Cloud re-transcription is not available in the open-source build.")
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
