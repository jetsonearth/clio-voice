import Foundation
import AVFoundation
import CoreAudio
import os

/// Optimizes audio performance for Bluetooth devices by pre-initializing CoreAudio and forcing profile transitions
final class BluetoothAudioOptimizer {
    static let shared = BluetoothAudioOptimizer()
    
    private let logger = Logger(subsystem: "com.cliovoice.clio", category: "BluetoothAudioOptimizer")
    
    private var audioEngine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    private var mixerNode: AVAudioMixerNode?
    private var preloadedBuffers: [String: AVAudioPCMBuffer] = [:]
    private var isWarm = false
    private let bufferLock = NSLock()
    
    // Audio format for consistent playback
    private let standardFormat = AVAudioFormat(standardFormatWithSampleRate: 48000, channels: 2)!
    
    private init() {
        logger.info("🎧 BluetoothAudioOptimizer initialized")
    }
    
    /// Performs aggressive early warmup on app launch to eliminate first-press latency
    func performEarlyWarmup() {
        guard !isWarm else {
            logger.debug("🎧 Audio already warm, skipping warmup")
            return
        }
        
        let startTime = Date()
        logger.info("🎧 Starting aggressive audio warmup for Bluetooth optimization")
        
        // Perform warmup on high-priority background queue to not block UI
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            // Step 1: Initialize the audio engine
            self.initializeAudioEngine()
            
            // Step 2: Force Bluetooth profile transition if needed
            if AudioDeviceManager.shared.isCurrentOutputBluetooth {
                self.logger.info("🎧 Bluetooth output detected, forcing profile transition")
                self.forceBluetoothProfileTransition()
            }
            
            // Step 3: Pre-warm the audio pipeline with silent playback
            self.primeAudioPipeline()
            
            let elapsed = Date().timeIntervalSince(startTime) * 1000
            self.logger.info("⏱️ [TIMING] Audio warmup completed in \(String(format: "%.1f", elapsed))ms")
            
            self.isWarm = true
        }
    }
    
    /// Initializes and configures the AVAudioEngine for low-latency playback
    private func initializeAudioEngine() {
        do {
            logger.debug("🎧 Initializing AVAudioEngine")
            
            // Create engine and nodes
            audioEngine = AVAudioEngine()
            playerNode = AVAudioPlayerNode()
            mixerNode = AVAudioMixerNode()
            
            guard let engine = audioEngine,
                  let player = playerNode,
                  let mixer = mixerNode else {
                logger.error("🎧 Failed to create audio nodes")
                return
            }
            
            // Attach nodes to engine
            engine.attach(player)
            engine.attach(mixer)
            
            // Connect nodes: player -> mixer -> output
            engine.connect(player, to: mixer, format: standardFormat)
            engine.connect(mixer, to: engine.mainMixerNode, format: standardFormat)
            
            // Configure for low latency
            engine.mainMixerNode.outputVolume = 0.7
            
            // Prepare and start the engine
            engine.prepare()
            try engine.start()
            
            logger.info("🎧 AVAudioEngine started successfully")
            
        } catch {
            logger.error("🎧 Failed to initialize audio engine: \(error.localizedDescription)")
        }
    }
    
    /// Forces a Bluetooth profile transition to pay the cost upfront
    private func forceBluetoothProfileTransition() {
        let startTime = Date()
        
        do {
            // Create a minimal recorder to trigger HFP profile switch
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("warmup.wav")
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatLinearPCM),
                AVSampleRateKey: 48000.0,  // Use 48kHz for AirPods native rate
                AVNumberOfChannelsKey: 1,
                AVLinearPCMBitDepthKey: 16,
                AVLinearPCMIsFloatKey: false
            ]
            
            let recorder = try AVAudioRecorder(url: tempURL, settings: settings)
            
            // Start recording for 1ms to trigger profile switch
            recorder.record()
            Thread.sleep(forTimeInterval: 0.001)
            recorder.stop()
            recorder.deleteRecording()
            
            let elapsed = Date().timeIntervalSince(startTime) * 1000
            logger.info("⏱️ [TIMING] Bluetooth profile transition completed in \(String(format: "%.1f", elapsed))ms")
            
        } catch {
            logger.warning("🎧 Could not force Bluetooth profile transition: \(error.localizedDescription)")
        }
    }
    
    /// Primes the audio pipeline with silent playback
    private func primeAudioPipeline() {
        guard let engine = audioEngine,
              let player = playerNode else {
            logger.warning("🎧 Cannot prime pipeline - engine not initialized")
            return
        }
        
        do {
            // Create a silent buffer (1ms of silence)
            let frameCount = AVAudioFrameCount(48) // 1ms at 48kHz
            guard let buffer = AVAudioPCMBuffer(pcmFormat: standardFormat, frameCapacity: frameCount) else {
                logger.warning("🎧 Could not create silent buffer")
                return
            }
            
            buffer.frameLength = frameCount
            
            // Fill with silence
            if let channelData = buffer.floatChannelData {
                for channel in 0..<Int(standardFormat.channelCount) {
                    for frame in 0..<Int(frameCount) {
                        channelData[channel][frame] = 0.0
                    }
                }
            }
            
            // Play the silent buffer to warm up the pipeline
            player.scheduleBuffer(buffer, completionHandler: nil)
            player.play()
            
            // Let it play briefly then stop
            Thread.sleep(forTimeInterval: 0.01)
            player.stop()
            
            logger.debug("🎧 Audio pipeline primed successfully")
            
        } catch {
            logger.warning("🎧 Could not prime audio pipeline: \(error.localizedDescription)")
        }
    }
    
    /// Pre-loads a sound file into a memory buffer for instant playback
    func preloadSound(named fileName: String, extension ext: String = "mp3") -> Bool {
        bufferLock.lock()
        defer { bufferLock.unlock() }
        
        // Check if already loaded
        if preloadedBuffers[fileName] != nil {
            return true
        }
        
        guard let url = Bundle.main.url(forResource: fileName, withExtension: ext) else {
            logger.warning("🎧 Sound file not found: \(fileName).\(ext)")
            return false
        }
        
        do {
            let file = try AVAudioFile(forReading: url)
            let format = file.processingFormat
            let frameCount = AVAudioFrameCount(file.length)
            
            guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
                logger.warning("🎧 Could not create buffer for: \(fileName)")
                return false
            }
            
            try file.read(into: buffer)
            buffer.frameLength = frameCount
            
            // Convert to standard format if needed
            if format != standardFormat {
                guard let convertedBuffer = convertBuffer(buffer, to: standardFormat) else {
                    logger.warning("🎧 Could not convert buffer format for: \(fileName)")
                    return false
                }
                preloadedBuffers[fileName] = convertedBuffer
            } else {
                preloadedBuffers[fileName] = buffer
            }
            
            logger.debug("🎧 Pre-loaded sound: \(fileName)")
            return true
            
        } catch {
            logger.error("🎧 Failed to pre-load sound \(fileName): \(error.localizedDescription)")
            return false
        }
    }
    
    /// Converts an audio buffer to a different format
    private func convertBuffer(_ buffer: AVAudioPCMBuffer, to format: AVAudioFormat) -> AVAudioPCMBuffer? {
        guard let converter = AVAudioConverter(from: buffer.format, to: format) else {
            return nil
        }
        
        let ratio = format.sampleRate / buffer.format.sampleRate
        let outputFrameCapacity = AVAudioFrameCount(Double(buffer.frameLength) * ratio)
        
        guard let outputBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: outputFrameCapacity) else {
            return nil
        }
        
        let inputBlock: AVAudioConverterInputBlock = { _, outStatus in
            outStatus.pointee = .haveData
            return buffer
        }
        
        var error: NSError?
        let status = converter.convert(to: outputBuffer, error: &error, withInputFrom: inputBlock)
        
        if status == .error {
            logger.warning("🎧 Buffer conversion failed: \(error?.localizedDescription ?? "unknown error")")
            return nil
        }
        
        return outputBuffer
    }
    
    /// Plays a pre-loaded sound with zero latency
    func playSound(named fileName: String, volume: Float = 0.7) {
        guard isWarm else {
            logger.warning("🎧 Audio not warm, performing emergency warmup")
            performEarlyWarmup()
            return
        }
        
        guard let engine = audioEngine,
              let player = playerNode,
              engine.isRunning else {
            logger.warning("🎧 Audio engine not running")
            return
        }
        
        bufferLock.lock()
        guard let buffer = preloadedBuffers[fileName] else {
            bufferLock.unlock()
            logger.warning("🎧 Sound not pre-loaded: \(fileName)")
            // Try to load it now as fallback
            if preloadSound(named: fileName) {
                playSound(named: fileName, volume: volume)
            }
            return
        }
        bufferLock.unlock()
        
        // Set volume
        mixerNode?.outputVolume = volume
        
        // Schedule and play immediately (non-blocking)
        player.scheduleBuffer(buffer, at: nil, options: .interrupts, completionHandler: nil)
        
        if !player.isPlaying {
            player.play()
        }
        
        let timestamp = String(format: "%.3f", Date().timeIntervalSince1970)
        print("⏱️ [TIMING] sound_played_instant @ \(timestamp)")
    }
    
    /// Shuts down the audio engine when not needed
    func shutdown() {
        logger.info("🎧 Shutting down audio optimizer")
        
        playerNode?.stop()
        audioEngine?.stop()
        
        audioEngine = nil
        playerNode = nil
        mixerNode = nil
        
        bufferLock.lock()
        preloadedBuffers.removeAll()
        bufferLock.unlock()
        
        isWarm = false
    }
    
    /// Returns whether the audio system is warmed up and ready
    var isReady: Bool {
        return isWarm && audioEngine?.isRunning == true
    }
}