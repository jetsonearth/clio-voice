import Foundation
import os.log

/// Manages audio file creation, accumulation, and WAV file writing for transcription services
class AudioFileManager {
    
    // MARK: - Properties
    
    private let logger = Logger(subsystem: "com.jetsonai.clio", category: "AudioFileManager")
    
    /// Serialize access to mutable audio buffer to avoid data races from concurrent taps/flush
    private let dataLock = NSLock()

    /// Protects metadata (URLs, timers) from concurrent mutation
    private let stateLock = NSLock()
    
    /// Accumulated audio data during recording
    private(set) var audioAccumulator = Data()
    
    /// Current audio file URL being written to
    private(set) var audioFileURL: URL?
    
    /// Directory where recordings are stored
    private let recordingsDirectory: URL
    
    /// Recording start time for duration calculation
    private(set) var recordingStartTime: Date?
    
    /// Total recording duration
    private(set) var recordingDuration: TimeInterval = 0
    
    // MARK: - Audio Format Properties
    
    /// Sample rate for audio capture (set from parent service)
    var captureSampleRate: Int = 16000
    
    /// Channel count for audio capture (set from parent service)
    var captureChannelCount: Int = 1
    
    // MARK: - Initialization
    
    init(recordingsDirectory: URL) {
        self.recordingsDirectory = recordingsDirectory
        createRecordingsDirectoryIfNeeded()
    }
    
    // MARK: - Public Interface
    
    /// Initialize a new audio file for recording
    func initializeAudioFile() {
        // Serialize metadata reset to avoid racing with async save/stop flows
        stateLock.lock()
        defer { stateLock.unlock() }

        // Generate unique filename
        let fileName = "\(UUID().uuidString).wav"
        audioFileURL = recordingsDirectory.appendingPathComponent(fileName)

        // Reset audio accumulator (thread-safe)
        dataLock.lock()
        audioAccumulator.removeAll(keepingCapacity: false)
        dataLock.unlock()

        recordingStartTime = Date()
        recordingDuration = 0

        // logger.notice("🎵 Initialized audio file: \(fileName)")  // Reduced logging verbosity
    }
    
    /// Add audio data to the accumulator
    func appendAudioData(_ data: Data) {
        dataLock.lock()
        audioAccumulator.append(data)
        dataLock.unlock()
    }
    
    /// Save accumulated audio data to WAV file
    func saveAudioToFile() async -> URL? {
        // Capture URL atomically; it may be swapped by initializeAudioFile
        let targetURL: URL?
        stateLock.lock()
        targetURL = audioFileURL
        stateLock.unlock()

        guard let audioFileURL = targetURL else {
            logger.warning("⚠️ No audio file URL to save")
            return nil
        }
        // Snapshot PCM under lock to avoid races with appenders
        dataLock.lock()
        let pcmSnapshot = audioAccumulator
        dataLock.unlock()
        guard !pcmSnapshot.isEmpty else {
            logger.warning("⚠️ No audio data to save")
            return nil
        }
        
        do {
            // Create WAV file with accumulated PCM data
            try await writeWAVFile(pcmData: pcmSnapshot, to: audioFileURL)
            // logger.notice("✅ Saved audio file: \(audioFileURL.lastPathComponent) (\(pcmSnapshot.count) bytes)")
            return audioFileURL
        } catch {
            logger.error("❌ Failed to save audio file: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Update recording duration based on start time
    func updateRecordingDuration() {
        stateLock.lock()
        if let startTime = recordingStartTime {
            recordingDuration = Date().timeIntervalSince(startTime)
        }
        stateLock.unlock()
    }
    
    /// Get the current audio file URL (for external access)
    var currentAudioFileURL: URL? {
        stateLock.lock()
        let url = audioFileURL
        stateLock.unlock()
        return url
    }
    
    /// Get the current recording duration (for external access)
    var currentRecordingDuration: TimeInterval {
        stateLock.lock()
        let duration = recordingDuration
        stateLock.unlock()
        return duration
    }
    
    /// Get the recording start time (for external access)
    var currentRecordingStartTime: Date? {
        stateLock.lock()
        let start = recordingStartTime
        stateLock.unlock()
        return start
    }
    
    // MARK: - Private Methods
    
    private func createRecordingsDirectoryIfNeeded() {
        do {
            try FileManager.default.createDirectory(at: recordingsDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            logger.error("❌ Error creating recordings directory: \(error.localizedDescription)")
        }
    }
    
    private func writeWAVFile(pcmData: Data, to url: URL) async throws {
        // Use actual capture sample rate for WAV header
        let actualSampleRate = UInt32(captureSampleRate)
        let actualChannels = UInt16(captureChannelCount)
        let bitsPerSample: UInt16 = 16
        let byteRate = actualSampleRate * UInt32(actualChannels) * UInt32(bitsPerSample) / 8
        let blockAlign = actualChannels * bitsPerSample / 8
        
        let pcmLength = pcmData.count
        let fileLength = pcmLength + 44 // PCM data + WAV header
        
        var wavHeader = Data()
        
        // RIFF chunk descriptor
        wavHeader.append("RIFF".data(using: .ascii)!)
        wavHeader.append(withUnsafeBytes(of: UInt32(fileLength - 8).littleEndian) { Data($0) })
        wavHeader.append("WAVE".data(using: .ascii)!)
        
        // fmt sub-chunk
        wavHeader.append("fmt ".data(using: .ascii)!)
        wavHeader.append(withUnsafeBytes(of: UInt32(16).littleEndian) { Data($0) }) // Sub-chunk size
        wavHeader.append(withUnsafeBytes(of: UInt16(1).littleEndian) { Data($0) })  // Audio format (PCM)
        wavHeader.append(withUnsafeBytes(of: actualChannels.littleEndian) { Data($0) })  // Number of channels
        wavHeader.append(withUnsafeBytes(of: actualSampleRate.littleEndian) { Data($0) }) // Sample rate
        wavHeader.append(withUnsafeBytes(of: byteRate.littleEndian) { Data($0) }) // Byte rate
        wavHeader.append(withUnsafeBytes(of: blockAlign.littleEndian) { Data($0) })  // Block align
        wavHeader.append(withUnsafeBytes(of: bitsPerSample.littleEndian) { Data($0) }) // Bits per sample
        
        // data sub-chunk
        wavHeader.append("data".data(using: .ascii)!)
        wavHeader.append(withUnsafeBytes(of: UInt32(pcmLength).littleEndian) { Data($0) })
        
        // Write header + PCM data to file
        var fileData = wavHeader
        fileData.append(pcmData)
        
        try fileData.write(to: url)
    }
}
