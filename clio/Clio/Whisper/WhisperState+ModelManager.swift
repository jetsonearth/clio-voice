#if CLIO_ENABLE_LOCAL_MODEL
import Foundation
import os
import Zip
import SwiftUI

// MARK: - Model Management Extension
extension WhisperState {
    
    // MARK: - Model Directory Management
    
    func createModelsDirectoryIfNeeded() {
        do {
            try FileManager.default.createDirectory(at: modelsDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            logError("Error creating models directory", error)
        }
    }
    
    func loadAvailableModels() {
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: modelsDirectory, includingPropertiesForKeys: nil)
            var models: [WhisperModel] = fileURLs.compactMap { url in
                guard url.pathExtension == "bin" else { return nil }
                return WhisperModel(name: url.deletingPathExtension().lastPathComponent, url: url)
            }
            
            // Add cloud models from predefined models
            let cloudModels: [WhisperModel] = predefinedModels.filter { $0.isCloudModel }.map { predefinedModel in
                // Create a dummy URL for cloud models since they don't use local files
                let dummyURL = URL(fileURLWithPath: "/tmp/\(predefinedModel.name)")
                return WhisperModel(name: predefinedModel.name, url: dummyURL)
            }
            
            models.append(contentsOf: cloudModels)
            availableModels = models
        } catch {
            logError("Error loading available models", error)
        }
    }
    
    // MARK: - Model Loading
    
    func loadModel(_ model: WhisperModel) async throws {
        
        // Server-side validation before loading
        let hasAccess = await ModelAccessControl.shared.validateModelAccess(model)
        guard hasAccess else {
            logger.error("❌ [loadModel] Server denied access to model: \(model.name)")
            throw WhisperStateError.accessDenied
        }
        
        // Check if this is a cloud model - skip file validation for cloud models
        let isCloudModel = model.name.contains("soniox")
        
        if isCloudModel {
            // For cloud models, simply mark the state as ready and exit early.
            isModelLoaded = true
            currentModel = model
            canTranscribe = true
            logger.notice("☁️ [loadModel] Cloud model \(model.name) marked as active")
            return
        }
        
        // Validate model file integrity (local models only)
        let isValidFile = await ModelValidationService.shared.validateModelFile(model, at: model.url)
        guard isValidFile else {
            logger.error("❌ [loadModel] Model file integrity check failed: \(model.name)")
            throw WhisperStateError.invalidModelFile
        }
        
        isModelLoading = true
        defer { isModelLoading = false }

        if let existingContext = whisperContext {
            await existingContext.releaseResources()
            whisperContext = nil
        }

        let context = try await WhisperContext.createContext(path: model.url.path)
        whisperContext = context
        isModelLoaded = true
        currentModel = model
        canTranscribe = true
        logger.notice("✅ [loadModel] Local model ready: \(model.name)")
    }

    func unloadCurrentModel() async {
        if let existingContext = whisperContext {
            await existingContext.releaseResources()
            whisperContext = nil
        }
        isModelLoaded = false
    }
    
    func setDefaultModel(_ model: WhisperModel) async {
        logger.notice("🎯 [setDefaultModel] Setting default model: \(model.name)")
        
        // Server-side access validation
        let hasAccess = await ModelAccessControl.shared.validateModelAccess(model)
        guard hasAccess else {
            logger.error("❌ [setDefaultModel] Server denied access to model: \(model.name)")
            
            // Show upgrade prompt
            await MainActor.run {
                SubscriptionManager.shared.promptUpgrade(from: "model_selection")
            }
            return
        }
        
        if model.name.contains("soniox") {
            currentModel = model
            canTranscribe = true
        } else {
            do {
                try await loadModel(model)
            } catch {
                logger.error("❌ [setDefaultModel] Failed to load local model: \(error.localizedDescription)")
                currentError = .modelLoadFailed
                return
            }
        }

        UserDefaults.standard.set(model.name, forKey: "CurrentModel")
        canTranscribe = true
        logger.notice("✅ [setDefaultModel] Model set successfully with server validation: \(model.name)")
        logger.notice("📋 [setDefaultModel] Current model is now: \(self.currentModel?.name ?? "nil")")
    }
    
    // MARK: - Model Download & Management
    
    /// Helper function to download a file from a URL with progress tracking **without** loading the
    /// entire file in memory. The method streams the bits onto disk and returns the final file URL
    /// once the download succeeds.
    private func downloadFileWithProgress(from url: URL, progressKey: String) async throws -> URL {
        // Write into a unique temporary file inside the models directory. We return this URL so the
        // caller can move/rename it as needed.
        let destinationURL = modelsDirectory.appendingPathComponent(UUID().uuidString)

        // Initialise progress.
        DispatchQueue.main.async {
            self.downloadProgress[progressKey] = 0.0
        }

        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<URL, Error>) in
            let task = URLSession.shared.downloadTask(with: url) { tempURL, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    continuation.resume(throwing: URLError(.badServerResponse))
                    return
                }
                
                // Check for 404 specifically
                if httpResponse.statusCode == 404 {
                    continuation.resume(throwing: URLError(.fileDoesNotExist))
                    return
                }
                
                guard (200...299).contains(httpResponse.statusCode),
                      let tempURL = tempURL else {
                    continuation.resume(throwing: URLError(.badServerResponse))
                    return
                }

                do {
                    // Move the downloaded file to the final destination inside modelsDirectory.
                    try FileManager.default.moveItem(at: tempURL, to: destinationURL)
                    continuation.resume(returning: destinationURL)
                } catch {
                    continuation.resume(throwing: error)
                }
            }

            // Observe both the download task progress and bytes
            let observation = task.progress.observe(\.fractionCompleted, options: [.initial, .new]) { progress, _ in
                DispatchQueue.main.async {
                    let currentProgress = progress.fractionCompleted
                    self.downloadProgress[progressKey] = currentProgress
                    
                    // Log progress at key milestones
                    let percentage = Int(currentProgress * 100)
                    if percentage % 10 == 0 || percentage == 1 || percentage == 99 {
                        self.logger.info("📥 Download progress for \(progressKey): \(percentage)% (\(progress.completedUnitCount) / \(progress.totalUnitCount) bytes)")
                    }
                }
            }
            // Retain the observation so that it continues to receive KVO updates
            DispatchQueue.main.async {
                self.downloadObservations[progressKey] = observation
            }
            
            task.resume()
            
            // Clean up once the task completes
            task.taskDescription = progressKey // use description to identify

            task.observe(\.state, options: [.new]) { [weak self] task, change in
                guard let self = self else { return }
                if task.state == .completed {
                    DispatchQueue.main.async {
                        self.downloadObservations.removeValue(forKey: progressKey)
                    }
                }
            }
            
            // Removed withExtendedLifetime – the observation is now retained in the
            // `downloadObservations` dictionary.
        }
    }
    
    // Shows an alert about Core ML support and first-run optimization
    private func showCoreMLAlert(for model: PredefinedModel, completion: @escaping () -> Void) {
        Task { @MainActor in
            let alert = NSAlert()
            alert.messageText = "Download \(model.displayName) Model"
            alert.informativeText = model.name.contains("q5") || model.name.contains("q8") 
                ? "This will download the \(model.displayName) model (\(model.size))."
                : "This Whisper model supports Core ML, which can improve performance by 2-4x on Apple Silicon devices.\n\nDuring the first run, it can take several minutes to optimize the model for your system. Subsequent runs will be much faster."
            alert.alertStyle = .informational
            alert.addButton(withTitle: "Download")
            alert.addButton(withTitle: "Cancel")
            
            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                completion()
            }
        }
    }
    
    func downloadModel(_ model: PredefinedModel, confirm: Bool = true) async {
        guard let url = URL(string: model.downloadURL) else { return }
        
        // Create a temporary WhisperModel to check access
        let tempModel = WhisperModel(name: model.name, url: URL(fileURLWithPath: ""))
        
        // Check subscription access before downloading
        do {
            try ModelAccessControl.shared.validateWhisperModelAccess(tempModel)
        } catch {
            logger.error("❌ [downloadModel] Access denied for model \(model.name): \(error.localizedDescription)")
            
            // Show upgrade prompt
            await MainActor.run {
                SubscriptionManager.shared.promptUpgrade(from: "model_download")
            }
            return
        }
        
        if confirm {
            // Present confirmation alert (legacy path)
            await MainActor.run {
                showCoreMLAlert(for: model) {
                    Task { await self.performModelDownload(model, url) }
                }
            }
        } else {
            // Start download silently (used by custom sheet)
            await performModelDownload(model, url)
        }
    }
    
    private func performModelDownload(_ model: PredefinedModel, _ url: URL) async {
        logger.info("🚀 Starting download for model: \(model.name) from URL: \(url)")
        logger.info("📊 Model size: \(model.size)")
        do {
            let whisperModel = try await downloadMainModel(model, from: url)
            
            // Try to download CoreML if available, but don't fail if it doesn't exist
            if let coreMLZipURL = whisperModel.coreMLZipDownloadURL,
               let coreMLURL = URL(string: coreMLZipURL) {
                do {
                    try await downloadAndSetupCoreMLModel(for: whisperModel, from: coreMLURL)
                    logger.info("Successfully downloaded CoreML model for: \(model.name)")
                } catch {
                    // Log the error but continue - CoreML is optional
                    logger.warning("CoreML model not available or failed to download for \(model.name): \(error)")
                    // Clear the CoreML progress indicator
                    self.downloadProgress.removeValue(forKey: model.name + "_coreml")
                }
            }
            
            availableModels.append(whisperModel)
            await MainActor.run {
                self.downloadProgress.removeValue(forKey: model.name + "_main")
                self.downloadProgress.removeValue(forKey: model.name + "_coreml")
                // If user requested offline mode, immediately make the new model active
                if UserDefaults.standard.bool(forKey: "UseLocalModel") {
                    Task { await self.setDefaultModel(whisperModel) }
                }
            }
            logger.info("✅ Successfully downloaded model: \(model.name)")
        } catch {
            logger.error("Failed to download model \(model.name): \(error)")
            handleModelDownloadError(model, error)
        }
    }
    
    private func downloadMainModel(_ model: PredefinedModel, from url: URL) async throws -> WhisperModel {
        let progressKeyMain = model.name + "_main"
        let tempURL = try await downloadFileWithProgress(from: url, progressKey: progressKeyMain)

        let destinationURL = modelsDirectory.appendingPathComponent(model.filename)

        // Remove any previous copy before moving.
        try? FileManager.default.removeItem(at: destinationURL)
        try FileManager.default.moveItem(at: tempURL, to: destinationURL)

        return WhisperModel(name: model.name, url: destinationURL)
    }
    
    private func downloadAndSetupCoreMLModel(for model: WhisperModel, from url: URL) async throws {
        let progressKeyCoreML = model.name + "_coreml"
        let tempURL = try await downloadFileWithProgress(from: url, progressKey: progressKeyCoreML)

        let coreMLZipPath = modelsDirectory.appendingPathComponent("\(model.name)-encoder.mlmodelc.zip")

        try? FileManager.default.removeItem(at: coreMLZipPath)
        try FileManager.default.moveItem(at: tempURL, to: coreMLZipPath)

        try await unzipAndSetupCoreMLModel(for: model, zipPath: coreMLZipPath, progressKey: progressKeyCoreML)
    }
    
    private func unzipAndSetupCoreMLModel(for model: WhisperModel, zipPath: URL, progressKey: String) async throws {
        let coreMLDestination = modelsDirectory.appendingPathComponent("\(model.name)-encoder.mlmodelc")
        
        try? FileManager.default.removeItem(at: coreMLDestination)
        try await unzipCoreMLFile(zipPath, to: modelsDirectory)
        _ = try verifyAndCleanupCoreMLFiles(model, coreMLDestination, zipPath, progressKey)
    }
    
    private func unzipCoreMLFile(_ zipPath: URL, to destination: URL) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            do {
                try FileManager.default.createDirectory(at: destination, withIntermediateDirectories: true)
                try Zip.unzipFile(zipPath, destination: destination, overwrite: true, password: nil)
                continuation.resume()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    private func verifyAndCleanupCoreMLFiles(_ model: WhisperModel, _ destination: URL, _ zipPath: URL, _ progressKey: String) throws -> WhisperModel {
        var model = model
        
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: destination.path, isDirectory: &isDirectory), isDirectory.boolValue else {
            try? FileManager.default.removeItem(at: zipPath)
            throw WhisperStateError.unzipFailed
        }
        
        try? FileManager.default.removeItem(at: zipPath)
        model.coreMLEncoderURL = destination
        self.downloadProgress.removeValue(forKey: progressKey)
        
        return model
    }
    
    private func handleModelDownloadError(_ model: PredefinedModel, _ error: Error) {
        currentError = .modelDownloadFailed
        self.downloadProgress.removeValue(forKey: model.name + "_main")
        self.downloadProgress.removeValue(forKey: model.name + "_coreml")
    }
    
    func deleteModel(_ model: WhisperModel) async {
        do {
            // Delete main model file
            try FileManager.default.removeItem(at: model.url)
            
            // Delete CoreML model if it exists
            if let coreMLURL = model.coreMLEncoderURL {
                try? FileManager.default.removeItem(at: coreMLURL)
            } else {
                // Check if there's a CoreML directory matching the model name
                let coreMLDir = modelsDirectory.appendingPathComponent("\(model.name)-encoder.mlmodelc")
                if FileManager.default.fileExists(atPath: coreMLDir.path) {
                    try? FileManager.default.removeItem(at: coreMLDir)
                }
            }
            
            // Update model state
            availableModels.removeAll { $0.id == model.id }
            if currentModel?.id == model.id {
                currentModel = nil
                canTranscribe = false
            }
        } catch {
            logError("Error deleting model: \(model.name)", error)
            currentError = .modelDeletionFailed
        }
    }
    
    func unloadModel() {
        // Prevent unloading while a recording session is in progress
        if isRecording {
            logger.warning("⏭️ unloadModel() called during an active recording – skipping to avoid interruption")
            return
        }
        Task {
            await whisperContext?.releaseResources()
            whisperContext = nil
            isModelLoaded = false
            
            if let recordedFile = recordedFile {
                try? FileManager.default.removeItem(at: recordedFile)
                self.recordedFile = nil
            }
        }
    }
    
    func clearDownloadedModels() async {
        for model in availableModels {
            do {
                try FileManager.default.removeItem(at: model.url)
            } catch {
                logError("Error deleting model during cleanup", error)
            }
        }
        availableModels.removeAll()
    }
    
    // MARK: - VAD Model Management (removed)
    
    // MARK: - Resource Management
    
    func cleanupModelResources() async {
        try? await Task.sleep(nanoseconds: 300_000_000)
        
        await whisperContext?.releaseResources()
        whisperContext = nil
        isModelLoaded = false
    }
    
    // MARK: - Helper Methods
    
    private func logError(_ message: String, _ error: Error) {
        self.logger.error("\(message): \(error.localizedDescription)")
    }
}

// MARK: - Download Progress View
struct DownloadProgressView: View {
    let modelName: String
    let downloadProgress: [String: Double]
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var mainProgress: Double {
        downloadProgress[modelName + "_main"] ?? 0
    }
    
    private var coreMLProgress: Double {
        supportsCoreML ? (downloadProgress[modelName + "_coreml"] ?? 0) : 0
    }
    
    private var supportsCoreML: Bool {
        !modelName.contains("q5") && !modelName.contains("q8")
    }
    
    private var totalProgress: Double {
        supportsCoreML ? (mainProgress * 0.5) + (coreMLProgress * 0.5) : mainProgress
    }
    
    private var downloadPhase: String {
        // Check if we're currently downloading the CoreML model
        if supportsCoreML && downloadProgress[modelName + "_coreml"] != nil {
            return "Downloading Core ML Model for \(modelName)"
        }
        // Otherwise, we're downloading the main model
        return "Downloading \(modelName) Model"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Status text with clean typography
            Text(downloadPhase)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(.secondaryLabelColor))
            
            // Clean progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.separatorColor).opacity(0.3))
                        .frame(height: 6)
                    
                    // Progress indicator
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.controlAccentColor))
                        .frame(width: max(0, min(geometry.size.width * totalProgress, geometry.size.width)), height: 6)
                }
            }
            .frame(height: 6)
            
            // Percentage indicator in Apple style
            HStack {
                Spacer()
                Text("\(Int(totalProgress * 100))%")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(Color(.secondaryLabelColor))
            }
        }
        .padding(.vertical, 4)
        .animation(.smooth, value: totalProgress)
    }
} 
#endif
