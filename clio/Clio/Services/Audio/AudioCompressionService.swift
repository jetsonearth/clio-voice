import Foundation
import AVFoundation
import os

class AudioCompressionService {
    private let logger = Logger(subsystem: "com.jetsonai.clio", category: "AudioCompressionService")
    
    enum CompressionFormat {
        case aac
        case mp3
        
        var fileExtension: String {
            switch self {
            case .aac: return "m4a"
            case .mp3: return "mp3"
            }
        }
        
        var formatID: AudioFormatID {
            switch self {
            case .aac: return kAudioFormatMPEG4AAC
            case .mp3: return kAudioFormatMPEGLayer3
            }
        }
    }
    
    enum CompressionError: LocalizedError {
        case invalidInputFile
        case compressionFailed
        case outputFileCreationFailed
        case unsupportedFormat
        
        var errorDescription: String? {
            switch self {
            case .invalidInputFile:
                return "Invalid input audio file"
            case .compressionFailed:
                return "Audio compression failed"
            case .outputFileCreationFailed:
                return "Failed to create compressed output file"
            case .unsupportedFormat:
                return "Unsupported audio format"
            }
        }
    }
    
    /// Compress an audio file to AAC format with significant size reduction
    /// - Parameters:
    ///   - inputURL: Source WAV file URL
    ///   - outputURL: Destination compressed file URL
    ///   - format: Compression format (default: AAC)
    ///   - quality: Audio quality (0.0-1.0, default: 0.6 for good compression/quality balance)
    /// - Returns: Compressed file size in bytes
    func compressAudio(
        from inputURL: URL,
        to outputURL: URL,
        format: CompressionFormat = .aac,
        quality: Float = 0.6
    ) async throws -> Int64 {
        logger.notice("🗜️ [COMPRESSION] Starting audio compression")
        logger.notice("🗜️ [COMPRESSION] Input: \(inputURL.path)")
        logger.notice("🗜️ [COMPRESSION] Output: \(outputURL.path)")
        
        // Verify input file exists and get its size
        guard FileManager.default.fileExists(atPath: inputURL.path) else {
            logger.error("❌ [COMPRESSION] Input file does not exist: \(inputURL.path)")
            throw CompressionError.invalidInputFile
        }
        
        do {
            let inputAttributes = try FileManager.default.attributesOfItem(atPath: inputURL.path)
            let inputSize = inputAttributes[.size] as? Int64 ?? 0
            logger.notice("🗜️ [COMPRESSION] Input file size: \(inputSize) bytes (\(String(format: "%.1f", Double(inputSize) / 1024 / 1024))MB)")
        } catch {
            logger.error("❌ [COMPRESSION] Failed to get input file size: \(error)")
        }
        
        // Remove existing output file if it exists
        if FileManager.default.fileExists(atPath: outputURL.path) {
            do {
                try FileManager.default.removeItem(at: outputURL)
                logger.notice("🗜️ [COMPRESSION] Removed existing output file")
            } catch {
                logger.error("❌ [COMPRESSION] Failed to remove existing output file: \(error)")
            }
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            // Create and validate asset
            let asset = AVURLAsset(url: inputURL)
            logger.notice("🗜️ [COMPRESSION] Created AVURLAsset")
            
            // Create export session with appropriate preset for compression
            let presetName: String
            switch format {
            case .aac:
                presetName = AVAssetExportPresetAppleM4A
            case .mp3:
                presetName = AVAssetExportPresetMediumQuality
            }
            
            logger.notice("🗜️ [COMPRESSION] Using preset: \(presetName)")
            
            // Log asset info
            let duration = asset.duration
            let durationSeconds = CMTimeGetSeconds(duration)
            logger.notice("🗜️ [COMPRESSION] Asset duration: \(String(format: "%.1f", durationSeconds))s")
            
            guard let exportSession = AVAssetExportSession(asset: asset, presetName: presetName) else {
                logger.error("❌ [COMPRESSION] Failed to create AVAssetExportSession")
                continuation.resume(throwing: CompressionError.compressionFailed)
                return
            }
            
            logger.notice("🗜️ [COMPRESSION] Created export session successfully")
            
            exportSession.outputURL = outputURL
            exportSession.outputFileType = format == .aac ? .m4a : .mp3
            exportSession.shouldOptimizeForNetworkUse = true
            
            logger.notice("🗜️ [COMPRESSION] Output file type: \(exportSession.outputFileType?.rawValue ?? "unknown")")
            logger.notice("🗜️ [COMPRESSION] Supported file types: \(exportSession.supportedFileTypes.map { $0.rawValue })")
            
            // Verify output file type is supported
            guard exportSession.supportedFileTypes.contains(exportSession.outputFileType!) else {
                logger.error("❌ [COMPRESSION] Output file type not supported")
                continuation.resume(throwing: CompressionError.unsupportedFormat)
                return
            }
            
            // Start compression
            logger.notice("🗜️ [COMPRESSION] Starting export...")
            exportSession.exportAsynchronously { [self] in
                logger.notice("🗜️ [COMPRESSION] Export completed with status: \(exportSession.status.rawValue)")
                
                switch exportSession.status {
                case .completed:
                    logger.notice("✅ [COMPRESSION] Export completed successfully")
                    do {
                        let attributes = try FileManager.default.attributesOfItem(atPath: outputURL.path)
                        let fileSize = attributes[.size] as? Int64 ?? 0
                        logger.notice("✅ [COMPRESSION] Output file size: \(fileSize) bytes (\(String(format: "%.1f", Double(fileSize) / 1024 / 1024))MB)")
                        continuation.resume(returning: fileSize)
                    } catch {
                        logger.error("❌ [COMPRESSION] Failed to get compressed file size: \(error)")
                        continuation.resume(throwing: CompressionError.outputFileCreationFailed)
                    }
                    
                case .failed:
                    logger.error("❌ [COMPRESSION] Export failed: \(exportSession.error?.localizedDescription ?? "Unknown error")")
                    if let error = exportSession.error {
                        logger.error("❌ [COMPRESSION] Error details: \(error)")
                    }
                    continuation.resume(throwing: CompressionError.compressionFailed)
                    
                case .cancelled:
                    logger.warning("⚠️ [COMPRESSION] Export cancelled")
                    continuation.resume(throwing: CompressionError.compressionFailed)
                    
                default:
                    logger.error("❌ [COMPRESSION] Unexpected export session status: \(exportSession.status.rawValue)")
                    continuation.resume(throwing: CompressionError.compressionFailed)
                }
            }
        }
    }
    
    /// Decompress audio file back to WAV format for whisper processing
    /// - Parameters:
    ///   - compressedURL: Compressed audio file URL
    ///   - outputURL: Destination WAV file URL
    /// - Returns: Decompressed file size in bytes
    func decompressAudio(from compressedURL: URL, to outputURL: URL) async throws -> Int64 {
        logger.notice("📤 Decompressing audio: \(compressedURL.lastPathComponent) -> \(outputURL.lastPathComponent)")
        
        // Remove existing output file if it exists
        if FileManager.default.fileExists(atPath: outputURL.path) {
            try FileManager.default.removeItem(at: outputURL)
        }
        
        // Use AudioProcessor for decompression to ensure whisper compatibility
        let audioProcessor = AudioProcessor()
        
        do {
            let samples = try await audioProcessor.processAudioToSamples(compressedURL)
            
            // Convert samples back to WAV format
            try writeWAVFile(samples: samples, to: outputURL)
            
            // Get file size
            let attributes = try FileManager.default.attributesOfItem(atPath: outputURL.path)
            let fileSize = attributes[.size] as? Int64 ?? 0
            logger.notice("✅ Decompression completed. File size: \(fileSize) bytes")
            return fileSize
        } catch {
            logger.error("❌ Decompression failed: \(error.localizedDescription)")
            throw CompressionError.compressionFailed
        }
    }
    
    /// Write float samples to a WAV file with whisper-compatible format
    private func writeWAVFile(samples: [Float], to url: URL) throws {
        let sampleRate: UInt32 = 16000
        let numChannels: UInt16 = 1
        let bitsPerSample: UInt16 = 16
        let bytesPerSample = bitsPerSample / 8
        let numSamples = UInt32(samples.count)
        let dataSize = numSamples * UInt32(bytesPerSample)
        let fileSize = 36 + dataSize
        
        var data = Data()
        
        // WAV Header
        data.append("RIFF".data(using: .ascii)!)
        withUnsafeBytes(of: fileSize.littleEndian) { data.append(contentsOf: $0) }
        data.append("WAVE".data(using: .ascii)!)
        
        // Format chunk
        data.append("fmt ".data(using: .ascii)!)
        let formatChunkSize: UInt32 = 16
        withUnsafeBytes(of: formatChunkSize.littleEndian) { data.append(contentsOf: $0) }
        let audioFormat: UInt16 = 1 // PCM
        withUnsafeBytes(of: audioFormat.littleEndian) { data.append(contentsOf: $0) }
        withUnsafeBytes(of: numChannels.littleEndian) { data.append(contentsOf: $0) }
        withUnsafeBytes(of: sampleRate.littleEndian) { data.append(contentsOf: $0) }
        let byteRate = sampleRate * UInt32(numChannels) * UInt32(bytesPerSample)
        withUnsafeBytes(of: byteRate.littleEndian) { data.append(contentsOf: $0) }
        let blockAlign = numChannels * bytesPerSample
        withUnsafeBytes(of: blockAlign.littleEndian) { data.append(contentsOf: $0) }
        withUnsafeBytes(of: bitsPerSample.littleEndian) { data.append(contentsOf: $0) }
        
        // Data chunk
        data.append("data".data(using: .ascii)!)
        withUnsafeBytes(of: dataSize.littleEndian) { data.append(contentsOf: $0) }
        
        // Convert float samples to 16-bit PCM
        for sample in samples {
            let intSample = Int16(max(-32767, min(32767, sample * 32767)))
            withUnsafeBytes(of: intSample.littleEndian) { data.append(contentsOf: $0) }
        }
        
        try data.write(to: url)
    }
    
    /// Calculate compression ratio between original and compressed files
    /// - Parameters:
    ///   - originalURL: Original file URL
    ///   - compressedURL: Compressed file URL
    /// - Returns: Compression ratio (e.g., 0.1 means 90% size reduction)
    func calculateCompressionRatio(original originalURL: URL, compressed compressedURL: URL) -> Double? {
        do {
            let originalAttributes = try FileManager.default.attributesOfItem(atPath: originalURL.path)
            let compressedAttributes = try FileManager.default.attributesOfItem(atPath: compressedURL.path)
            
            guard let originalSize = originalAttributes[.size] as? Int64,
                  let compressedSize = compressedAttributes[.size] as? Int64,
                  originalSize > 0 else {
                return nil
            }
            
            let ratio = Double(compressedSize) / Double(originalSize)
            logger.notice("📊 Compression ratio: \(String(format: "%.1f", ratio * 100))% (saved \(String(format: "%.1f", (1 - ratio) * 100))%)")
            return ratio
        } catch {
            logger.error("❌ Failed to calculate compression ratio: \(error)")
            return nil
        }
    }
}