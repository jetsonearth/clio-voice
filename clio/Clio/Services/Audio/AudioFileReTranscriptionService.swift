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
            statusMessage = "Preparing audio for re-transcription..."
        }

        logger.notice("🔄 Starting community re-transcription for: \(audioURL.lastPathComponent)")
        
        guard let sonioxKey = SonioxAPIKeyStore.shared.apiKey, !sonioxKey.isEmpty else {
            await MainActor.run {
                isReTranscribing = false
                statusMessage = "Add your Soniox API key in Settings → Cloud Access."
            }
            throw ReTranscriptionError.missingAPIKey
        }
        
        let languageHints = determineLanguageHints()
        let transcriber = SonioxFileTranscriber(apiKey: sonioxKey, languageHints: languageHints, logger: logger)
        
        let finalText = try await transcriber.transcribe(
            audioURL: audioURL,
            progressHandler: { fraction in
                Task { @MainActor in
                    self.progress = fraction
                    if fraction < 0.2 {
                        self.statusMessage = "Uploading audio to Soniox..."
                    } else if fraction < 0.3 {
                        self.statusMessage = "Creating transcription job..."
                    } else if fraction < 0.95 {
                        self.statusMessage = "Transcribing audio..."
                    } else {
                        self.statusMessage = "Finalizing..."
                    }
                }
            }
        )
        
        guard !finalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            await MainActor.run {
                isReTranscribing = false
                statusMessage = "Soniox returned an empty transcript."
            }
            throw ReTranscriptionError.emptyTranscription
        }
        
        // Apply LLM enhancement if enabled
        var enhancedText: String? = nil
        if enhancementService.isEnhancementEnabled {
            await MainActor.run {
                statusMessage = "Enhancing transcript with AI..."
                progress = 0.98
            }
            
            logger.notice("🤖 Applying AI enhancement to re-transcribed text...")
            do {
                enhancedText = try await enhancementService.enhance(finalText)
                logger.notice("✅ AI enhancement completed")
            } catch {
                logger.warning("⚠️ AI enhancement failed, using raw transcript: \(error.localizedDescription)")
                enhancedText = nil
            }
        }
        
        await MainActor.run {
            originalTranscription.text = finalText
            originalTranscription.enhancedText = enhancedText
            // Keep original duration
            originalTranscription.processingLatencyMs = nil
            originalTranscription.llmLatencyMs = nil
            originalTranscription.totalLatencyMs = nil
            originalTranscription.aiProvider = enhancedText != nil ? "Soniox Async + AI Enhanced" : "Soniox Async (re-transcribed)"
            statusMessage = "Re-transcription complete."
            progress = 1.0
            isReTranscribing = false
        }
        
        logger.notice("✅ Re-transcription completed successfully")
        return originalTranscription
    }
    
    // MARK: - Helpers
    
    private func determineLanguageHints() -> [String] {
        let selected = UserDefaults.standard.string(forKey: "SelectedLanguage") ?? "en"
        if selected.lowercased() == "auto" {
            return ["en"]
        }
        if selected.lowercased() == "zh-hant" {
            return ["zh"]
        }
        return [selected]
    }
}

enum ReTranscriptionError: LocalizedError {
    case connectionFailed(String)
    case connectionTimeout
    case emptyTranscription
    case missingAPIKey
    
    var errorDescription: String? {
        switch self {
        case .connectionFailed(let message):
            return "Failed to connect to Soniox: \(message)"
        case .connectionTimeout:
            return "Connection to Soniox timed out (max 5 minutes)"
        case .emptyTranscription:
            return "Re-transcription produced empty result"
        case .missingAPIKey:
            return "Add your Soniox API key in Settings → Cloud Access"
        }
    }
}

// MARK: - Low-level Soniox REST API client (for async transcription)

private actor SonioxFileTranscriber {
    private let apiKey: String
    private let logger: Logger
    private let baseURL = "https://api.soniox.com"
    private let languageHints: [String]
    
    init(apiKey: String, languageHints: [String], logger: Logger) {
        self.apiKey = apiKey
        self.languageHints = languageHints
        self.logger = logger
    }
    
    func transcribe(
        audioURL: URL,
        progressHandler: @escaping @Sendable (Double) -> Void
    ) async throws -> String {
        // Validate file exists
        guard FileManager.default.fileExists(atPath: audioURL.path) else {
            logger.error("❌ Audio file not found at: \(audioURL.path)")
            throw ReTranscriptionError.connectionFailed("Audio file not found")
        }
        
        logger.notice("🎯 Starting transcription for: \(audioURL.lastPathComponent)")
        let session = URLSession(configuration: .default)
        
        // Step 1: Upload file
        logger.notice("📤 Uploading file to Soniox...")
        progressHandler(0.1)
        let fileId = try await uploadFile(audioURL: audioURL, session: session)
        
        // Step 2: Create transcription job
        logger.notice("🎬 Creating transcription job...")
        progressHandler(0.2)
        let transcriptionId = try await createTranscription(fileId: fileId, session: session)
        
        // Step 3: Poll for completion
        logger.notice("⏳ Waiting for transcription to complete...")
        progressHandler(0.3)
        try await waitForCompletion(transcriptionId: transcriptionId, session: session, progressHandler: progressHandler)
        
        // Step 4: Get transcript
        logger.notice("📥 Retrieving transcript...")
        progressHandler(0.95)
        let transcript = try await getTranscript(transcriptionId: transcriptionId, session: session)
        
        // Step 5: Cleanup
        logger.notice("🧹 Cleaning up...")
        try? await deleteTranscription(transcriptionId: transcriptionId, session: session)
        try? await deleteFile(fileId: fileId, session: session)
        
        progressHandler(1.0)
        return transcript
    }
    
    private func uploadFile(audioURL: URL, session: URLSession) async throws -> String {
        let url = URL(string: "\(baseURL)/v1/files")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(audioURL.lastPathComponent)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: audio/wav\r\n\r\n".data(using: .utf8)!)
        
        let audioData = try Data(contentsOf: audioURL)
        logger.notice("📊 Uploading file size: \(audioData.count) bytes")
        body.append(audioData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        do {
            let (data, response) = try await session.upload(for: request, from: body)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ReTranscriptionError.connectionFailed("Invalid response type")
            }
            
            logger.notice("📡 Upload response status: \(httpResponse.statusCode)")
            
            // Accept both 200 (OK) and 201 (Created) as success
            if httpResponse.statusCode != 200 && httpResponse.statusCode != 201 {
                let responseBody = String(data: data, encoding: .utf8) ?? "Unable to decode response"
                logger.error("❌ Upload failed with status \(httpResponse.statusCode): \(responseBody)")
                throw ReTranscriptionError.connectionFailed("File upload failed (HTTP \(httpResponse.statusCode)): \(responseBody)")
            }
            
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            guard let fileId = json?["id"] as? String else {
                let responseBody = String(data: data, encoding: .utf8) ?? "Unable to decode response"
                logger.error("❌ Failed to parse file ID from response: \(responseBody)")
                throw ReTranscriptionError.connectionFailed("Failed to get file ID from response")
            }
            
            logger.notice("✅ File uploaded: \(fileId)")
            return fileId
        } catch let error as ReTranscriptionError {
            throw error
        } catch {
            logger.error("❌ Upload error: \(error.localizedDescription)")
            throw ReTranscriptionError.connectionFailed("Upload error: \(error.localizedDescription)")
        }
    }
    
    private func createTranscription(fileId: String, session: URLSession) async throws -> String {
        let url = URL(string: "\(baseURL)/v1/transcriptions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let config: [String: Any] = [
            "model": "stt-async-v3",
            "file_id": fileId,
            "language_hints": languageHints,
            "enable_language_identification": false,
            "enable_speaker_diarization": false
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: config)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ReTranscriptionError.connectionFailed("Invalid response type")
            }
            
            logger.notice("📡 Create transcription response status: \(httpResponse.statusCode)")
            
            // Accept both 200 (OK) and 201 (Created) as success
            if httpResponse.statusCode != 200 && httpResponse.statusCode != 201 {
                let responseBody = String(data: data, encoding: .utf8) ?? "Unable to decode response"
                logger.error("❌ Create transcription failed with status \(httpResponse.statusCode): \(responseBody)")
                throw ReTranscriptionError.connectionFailed("Transcription creation failed (HTTP \(httpResponse.statusCode))")
            }
            
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            guard let transcriptionId = json?["id"] as? String else {
                let responseBody = String(data: data, encoding: .utf8) ?? "Unable to decode response"
                logger.error("❌ Failed to parse transcription ID: \(responseBody)")
                throw ReTranscriptionError.connectionFailed("Failed to get transcription ID")
            }
            
            logger.notice("✅ Transcription created: \(transcriptionId)")
            return transcriptionId
        } catch let error as ReTranscriptionError {
            throw error
        } catch {
            logger.error("❌ Create transcription error: \(error.localizedDescription)")
            throw ReTranscriptionError.connectionFailed("Create transcription error: \(error.localizedDescription)")
        }
    }
    
    private func waitForCompletion(transcriptionId: String, session: URLSession, progressHandler: @escaping @Sendable (Double) -> Void) async throws {
        let url = URL(string: "\(baseURL)/v1/transcriptions/\(transcriptionId)")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        var attempts = 0
        let maxAttempts = 300 // 5 minutes max
        
        while attempts < maxAttempts {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw ReTranscriptionError.connectionFailed("Status check failed")
            }
            
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            guard let status = json?["status"] as? String else {
                throw ReTranscriptionError.connectionFailed("Failed to get status")
            }
            
            if status == "completed" {
                logger.notice("✅ Transcription completed")
                return
            } else if status == "error" {
                let errorMessage = json?["error_message"] as? String ?? "Unknown error"
                throw ReTranscriptionError.connectionFailed("Transcription error: \(errorMessage)")
            }
            
            // Update progress (30% to 90% during waiting)
            let progress = 0.3 + (Double(attempts) / Double(maxAttempts)) * 0.6
            progressHandler(min(progress, 0.9))
            
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            attempts += 1
        }
        
        throw ReTranscriptionError.connectionTimeout
    }
    
    private func getTranscript(transcriptionId: String, session: URLSession) async throws -> String {
        let url = URL(string: "\(baseURL)/v1/transcriptions/\(transcriptionId)/transcript")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw ReTranscriptionError.connectionFailed("Transcript retrieval failed")
        }
        
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let tokens = json?["tokens"] as? [[String: Any]] else {
            throw ReTranscriptionError.connectionFailed("Failed to parse tokens")
        }
        
        // Render tokens to text
        var text = ""
        for token in tokens {
            if let tokenText = token["text"] as? String {
                text += tokenText
            }
        }
        
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func deleteTranscription(transcriptionId: String, session: URLSession) async throws {
        let url = URL(string: "\(baseURL)/v1/transcriptions/\(transcriptionId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        _ = try await session.data(for: request)
        logger.debug("🗑️ Deleted transcription: \(transcriptionId)")
    }
    
    private func deleteFile(fileId: String, session: URLSession) async throws {
        let url = URL(string: "\(baseURL)/v1/files/\(fileId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        _ = try await session.data(for: request)
        logger.debug("🗑️ Deleted file: \(fileId)")
    }
}
