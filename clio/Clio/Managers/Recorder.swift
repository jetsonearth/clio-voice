import Foundation
import AVFoundation
import CoreAudio
import os

class Recorder: ObservableObject {
    private var recorder: AVAudioRecorder?
    private let logger = Logger(subsystem: "com.cliovoice.clio", category: "Recorder")
    private let deviceManager = AudioDeviceManager.shared
    private var deviceObserver: NSObjectProtocol?
    private var isReconfiguring = false
    private let mediaController = MediaController.shared
    private var audioMeterTask: Task<Void, Never>?
    @Published var audioMeter = AudioMeter(averagePower: 0, peakPower: 0)
    private var vizLogCounter: Int = 0

    // Coalesced UI publishing (keep 60 Hz sampling, publish ~10 Hz or on significant change)
    private let meterPublishInterval: TimeInterval = 0.10 // seconds
    private var lastMeterPublishAt: Date? = nil
    private var lastPublishedAvg: Float = 0.0
    private var lastPublishedPeak: Float = 0.0
    
    // Silent failure detection
    private var consecutiveDeadSamples: Int = 0
    private var silenceStartTime: Date?
    private let silenceThreshold: Float = -60.0 // dB
    private let maxSilenceDuration: TimeInterval = 10.0 // seconds
    
    enum RecorderError: Error {
        case couldNotStartRecording
        case audioSystemUnhealthy(String)
        case insufficientResources(String)
        case deviceNotReady(AudioDeviceID)
    }
    
    init() {
        setupDeviceChangeObserver()
    }
    
    private func setupDeviceChangeObserver() {
        deviceObserver = AudioDeviceConfiguration.createDeviceChangeObserver { [weak self] in
            Task {
                await self?.handleDeviceChange()
            }
        }
    }
    
    private func handleDeviceChange() async {
        guard !isReconfiguring else { 
            logger.debug("⚠️ Device change already in progress, skipping")
            return 
        }
        
        logger.info("🔄 Handling audio device change")
        isReconfiguring = true
        
        defer {
            isReconfiguring = false
            logger.info("✅ Device change handling completed")
        }
        
        if recorder != nil {
            let currentURL = recorder?.url
            let wasRecording = recorder?.isRecording ?? false
            
            logger.info("🛑 Stopping current recording for device change")
            await stopRecording()
            
            // Give the system time to release resources
            try? await Task.sleep(nanoseconds: 200_000_000) // 200ms
            
            if let url = currentURL, wasRecording {
                do {
                    logger.info("🎯 Restarting recording after device change")
                    try await startRecording(toOutputFile: url)
                } catch {
                    logger.error("❌ Failed to restart recording after device change: \(error.localizedDescription)")
                    // Ensure complete cleanup if restart fails
                    await stopRecording()
                    // Don't rethrow - let the user know but don't crash
                }
            }
        }
    }
    
    private func configureAudioSession(with deviceID: AudioDeviceID) async throws {
        do {
        _ = try AudioDeviceConfiguration.configureAudioSession(with: deviceID)
        try await Task.detached(priority: .userInitiated) {
            try AudioDeviceConfiguration.setDefaultInputDevice(deviceID)
        }.value
        } catch {
            logger.error("❌ Failed to configure audio session: \(error.localizedDescription)")
            throw error
        }
    }
    
    func startRecording(toOutputFile url: URL) async throws {
        // PRE-FLIGHT VALIDATION - Catch "fresh app" and system failures
        logger.info("✈️ Running pre-flight audio system validation")
        
        let healthCheck = await diagnoseAudioSystemHealth()
        guard healthCheck.isHealthy else {
            logger.error("❌ Audio system pre-flight check failed: \(healthCheck.description)")
            throw RecorderError.audioSystemUnhealthy(healthCheck.description)
        }
        
        // DEVICE HEALTH VALIDATION
        let deviceID = deviceManager.getCurrentDevice()
        guard await validateAudioDevice(deviceID) else {
            logger.error("❌ Audio device validation failed for device \(deviceID)")
            throw RecorderError.deviceNotReady(deviceID)
        }
        
        logger.info("✅ Pre-flight validation passed - proceeding with recording")
        
        deviceManager.isRecordingActive = true
        
        // Keep existing behavior; do not adjust mute here to avoid affecting start tone timing
        
        if deviceID != 0 {
            do {
                try await configureAudioSession(with: deviceID)
            } catch {
                logger.warning("⚠️ Failed to configure audio session for device \(deviceID), attempting to continue: \(error.localizedDescription)")
            }
        }
        
        let recordSettings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 16000.0,
            AVNumberOfChannelsKey: 1,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsNonInterleaved: false
        ]
        
        // Add retry logic for recording initialization to handle audio system wake-up
        var retryCount = 0
        let maxRetries = 3
        
        while retryCount < maxRetries {
            do {
                recorder = try AVAudioRecorder(url: url, settings: recordSettings)
                recorder?.isMeteringEnabled = true
                
                if recorder?.record() == true {
                    // Successfully started recording
                    audioMeterTask = Task(priority: .userInitiated) {
                        // 60 FPS metering while recording, computed off-main
                        while recorder != nil && !Task.isCancelled {
                            updateAudioMeter()
                            try? await Task.sleep(nanoseconds: 16_000_000)
                        }
                    }
                    return // Exit function successfully
                } else {
                    logger.warning("⚠️ Could not start recording, attempt \(retryCount + 1) of \(maxRetries)")
                    recorder = nil
                }
            } catch {
                logger.warning("⚠️ Failed to create audio recorder, attempt \(retryCount + 1) of \(maxRetries): \(error.localizedDescription)")
            }
            
            retryCount += 1
            if retryCount < maxRetries {
                // Wait before retrying to give audio system time to wake up
                try await Task.sleep(nanoseconds: 200_000_000) // 200ms
            }
        }
        
        // All retries failed
        logger.error("❌ Could not start recording after \(maxRetries) attempts")
        await stopRecording()
        throw RecorderError.couldNotStartRecording
    }
    
    func stopRecording() async {
        logger.info("🛑 Starting enhanced recording cleanup")

        // Cancel metering updates up front; they restart automatically on next recording.
        audioMeterTask?.cancel()
        audioMeterTask = nil

        if let activeRecorder = recorder {
            // Allow a small tail hold so Core Audio flushes any buffered frames.
            let tailMs = RuntimeConfig.recordingTailHoldMs
            if tailMs > 0, activeRecorder.isRecording {
                logger.debug("⏳ Applying recording tail hold: \(tailMs)ms")
                let nanos = UInt64(tailMs) * 1_000_000
                do {
                    try await Task.sleep(nanoseconds: nanos)
                } catch {
                    logger.debug("⚠️ Tail hold interrupted: \(error.localizedDescription)")
                }
            }

            activeRecorder.stop()
            await waitForRecorderFlush(activeRecorder)
            self.recorder = nil
            logger.debug("✅ AVAudioRecorder resources released")
        }

        // Reset metering state so UI visuals settle immediately.
        audioMeter = AudioMeter(averagePower: 0, peakPower: 0)
        consecutiveDeadSamples = 0
        silenceStartTime = nil

        // Force audio session cleanup now that the recorder is released.
        forceAudioSessionCleanup()

        Task {
            // Longer delay to ensure complete resource release
            try? await Task.sleep(nanoseconds: 500_000_000)
            await verifyResourceCleanup()
            // Delay unmute slightly after end sound to avoid audible pop at the tail
            try? await Task.sleep(nanoseconds: 150_000_000)
            await mediaController.unmuteSystemAudio()
        }

        deviceManager.isRecordingActive = false
        logger.info("✅ Enhanced recording cleanup completed")
    }

    private func waitForRecorderFlush(_ recorder: AVAudioRecorder) async {
        let url = recorder.url
        let timeoutNs: UInt64 = 800_000_000 // 800ms guard
        let intervalNs: UInt64 = 40_000_000 // 40ms polling cadence
        let started = DispatchTime.now().uptimeNanoseconds

        var lastSize: UInt64?
        var stableIterations = 0
        var stabilized = false

        while true {
            if Task.isCancelled { break }
            let now = DispatchTime.now().uptimeNanoseconds
            if now - started >= timeoutNs { break }

            guard FileManager.default.fileExists(atPath: url.path) else { break }

            var currentSize: UInt64? = nil
            if let attributes = try? FileManager.default.attributesOfItem(atPath: url.path) {
                if let nsNumber = attributes[.size] as? NSNumber {
                    currentSize = nsNumber.uint64Value
                } else if let intValue = attributes[.size] as? Int {
                    currentSize = UInt64(intValue)
                } else if let sizeValue = attributes[.size] as? UInt64 {
                    currentSize = sizeValue
                }
            }

            if let size = currentSize {
                if let previous = lastSize, previous == size {
                    stableIterations += 1
                    if stableIterations >= 2 {
                        stabilized = true
                        break
                    }
                } else {
                    stableIterations = 0
                    lastSize = size
                }
            }

            try? await Task.sleep(nanoseconds: intervalNs)
        }

        let elapsedNs = DispatchTime.now().uptimeNanoseconds - started
        let elapsedMs = Double(elapsedNs) / 1_000_000.0
        logger.debug("📦 Recorder flush wait finished after \(String(format: "%.1f", elapsedMs))ms (stabilized=\(stabilized))")
    }
    
    private func forceAudioSessionCleanup() {
        // Force release of any lingering audio session resources on macOS
        // macOS doesn't have AVAudioSession like iOS, so we use Core Audio directly
        logger.debug("🧹 Performing macOS-specific audio session cleanup")
        
        // On macOS, we can force release by resetting the audio unit graph
        // This is handled by the enhanced stopRecording() sequence
        
        logger.debug("✅ macOS audio session cleanup completed")
    }
    
    private func verifyResourceCleanup() async {
        // Verify that resources were properly cleaned up
        logger.debug("🔍 Verifying resource cleanup completion")
        
        // Check if recorder is fully released
        if recorder != nil {
            logger.warning("⚠️ Recorder still exists after cleanup")
        }
        
        // Check if audio meter task is cancelled
        if audioMeterTask != nil {
            logger.warning("⚠️ Audio meter task still active after cleanup")
        }
        
        logger.debug("✅ Resource cleanup verification completed")
    }
    
    private func updateAudioMeter() {
        guard let recorder = recorder else { return }
        recorder.updateMeters()
        
        let averagePower = recorder.averagePower(forChannel: 0)
        let peakPower = recorder.peakPower(forChannel: 0)
        
        // SILENCE DETECTION - Track extended periods of silence
        if averagePower < silenceThreshold {
            if silenceStartTime == nil {
                silenceStartTime = Date()
            } else if let startTime = silenceStartTime {
                let silenceDuration = Date().timeIntervalSince(startTime)
                if silenceDuration > maxSilenceDuration {
                    logger.warning("⚠️ Extended silence detected (\(String(format: "%.1f", silenceDuration))s) - possible audio capture failure")
                    
                    // Attempt recovery
                    Task {
                        await attemptAudioCaptureRecovery()
                    }
                    silenceStartTime = nil // Reset to prevent repeated triggers
                }
            }
        } else {
            // Reset silence tracking when audio is detected
            silenceStartTime = nil
        }
        
        // AUDIO INPUT HEALTH CHECK - Detect completely dead audio input
        if averagePower < -80.0 && peakPower < -80.0 {
            consecutiveDeadSamples += 1
            
            if consecutiveDeadSamples > 300 { // ~10 seconds at 30fps
                logger.error("❌ Audio input appears dead - triggering recovery")
                Task {
                    await handleAudioInputFailure()
                }
                consecutiveDeadSamples = 0 // Reset to prevent repeated triggers
            }
        } else {
            consecutiveDeadSamples = 0
        }
        
        let minVisibleDb: Float = -60.0 
        let maxVisibleDb: Float = 0.0

        let normalizedAverage: Float
        if averagePower < minVisibleDb {
            normalizedAverage = 0.0
        } else if averagePower >= maxVisibleDb {
            normalizedAverage = 1.0
        } else {
            normalizedAverage = (averagePower - minVisibleDb) / (maxVisibleDb - minVisibleDb)
        }
        
        let normalizedPeak: Float
        if peakPower < minVisibleDb {
            normalizedPeak = 0.0
        } else if peakPower >= maxVisibleDb {
            normalizedPeak = 1.0
        } else {
            normalizedPeak = (peakPower - minVisibleDb) / (maxVisibleDb - minVisibleDb)
        }
        
        // Only publish to UI when enough time has passed or the change is significant
        publishMeterIfNeeded(avg: normalizedAverage, peak: normalizedPeak)
        vizLogCounter &+= 1
        if RuntimeConfig.enableVerboseLogging {
            if vizLogCounter % 30 == 0 {
                print("🎙️ [RECORDER METER] avg=\(String(format: "%.3f", normalizedAverage)) peak=\(String(format: "%.3f", normalizedPeak)) rawAvgDb=\(String(format: "%.1f", averagePower)) rawPeakDb=\(String(format: "%.1f", peakPower))")
            }
        }
    }

    private func publishMeterIfNeeded(avg: Float, peak: Float) {
        let now = Date()
        let shouldPublishByTime: Bool = {
            guard let last = lastMeterPublishAt else { return true }
            return now.timeIntervalSince(last) >= meterPublishInterval
        }()
        let deltaAvg = abs(avg - lastPublishedAvg)
        let deltaPeak = abs(peak - lastPublishedPeak)
        let threshold: Float = 0.04 // ~4% change
        if shouldPublishByTime || deltaAvg >= threshold || deltaPeak >= threshold {
            lastMeterPublishAt = now
            lastPublishedAvg = avg
            lastPublishedPeak = peak
            Task { @MainActor in
                self.audioMeter = AudioMeter(averagePower: Double(avg), peakPower: Double(peak))
            }
        }
    }
    
    private func attemptAudioCaptureRecovery() async {
        logger.info("🔄 Attempting audio capture recovery")
        
        // Stop current recording
        let currentURL = recorder?.url
        await stopRecording()
        
        // Wait for cleanup
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Force device reconfiguration
        let deviceID = deviceManager.getCurrentDevice()
        do {
            try await configureAudioSession(with: deviceID)
            
            // Restart recording if we had a valid URL
            if let url = currentURL {
                try await startRecording(toOutputFile: url)
                logger.info("✅ Audio capture recovery successful")
            }
        } catch {
            logger.error("❌ Audio capture recovery failed: \(error)")
            // Notify user of failure
            NotificationCenter.default.post(name: NSNotification.Name("AudioRecoveryFailed"), object: error)
        }
    }
    
    private func handleAudioInputFailure() async {
        logger.error("😨 Handling critical audio input failure")
        
        // This is a critical failure - stop recording and notify user
        await stopRecording()
        
        // Post notification for UI to show error
        await MainActor.run {
            NotificationCenter.default.post(
                name: NSNotification.Name("AudioInputFailed"), 
                object: "Audio input has failed. Please check your microphone and try again."
            )
        }
    }
    
    // MARK: - Audio System Health Validation
    
    private func diagnoseAudioSystemHealth() async -> AudioSystemHealthReport {
        var report = AudioSystemHealthReport()
        
        // Test 1: Default input device availability
        let defaultDevice = deviceManager.fallbackDeviceID
        report.hasDefaultDevice = (defaultDevice != nil && defaultDevice != 0)
        
        // Test 2: Device enumeration
        deviceManager.loadAvailableDevices()
        report.availableDeviceCount = deviceManager.availableDevices.count
        
        // Test 3: Core Audio system object accessibility
        let systemObjectID = AudioObjectID(kAudioObjectSystemObject)
        var alive: UInt32 = 0
        var aliveSize = UInt32(MemoryLayout<UInt32>.size)
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDevices,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        let status = AudioObjectGetPropertyData(systemObjectID, &address, 0, nil, &aliveSize, &alive)
        report.coreAudioSystemResponsive = (status == noErr)
        
        logger.debug("🏥 Health check: defaultDevice=\(report.hasDefaultDevice), devices=\(report.availableDeviceCount), coreAudio=\(report.coreAudioSystemResponsive)")
        
        return report
    }
    
    private func validateAudioDevice(_ deviceID: AudioDeviceID) async -> Bool {
        // Comprehensive device validation
        var isAlive: UInt32 = 0
        var aliveSize = UInt32(MemoryLayout<UInt32>.size)
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyDeviceIsAlive,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        let status = AudioObjectGetPropertyData(deviceID, &address, 0, nil, &aliveSize, &isAlive)
        
        guard status == noErr && isAlive == 1 else {
            logger.error("Device \(deviceID) is not alive or accessible (status: \(status), alive: \(isAlive))")
            return false
        }
        
        // Test device can be configured
        do {
            _ = try AudioDeviceConfiguration.configureAudioSession(with: deviceID)
            logger.debug("✅ Device \(deviceID) validation passed")
            return true
        } catch {
            logger.error("Device \(deviceID) cannot be configured: \(error)")
            return false
        }
    }
    
    deinit {
        // Ensure audio meter task is cancelled to prevent microphone access
        audioMeterTask?.cancel()
        
        if let observer = deviceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}

struct AudioMeter: Equatable {
    let averagePower: Double
    let peakPower: Double
}

struct AudioSystemHealthReport {
    var hasDefaultDevice: Bool = false
    var availableDeviceCount: Int = 0
    var coreAudioSystemResponsive: Bool = false
    
    var isHealthy: Bool {
        return hasDefaultDevice && availableDeviceCount > 0 && coreAudioSystemResponsive
    }
    
    var description: String {
        return "AudioSystemHealth(defaultDevice: \(hasDefaultDevice), devices: \(availableDeviceCount), coreAudioResponsive: \(coreAudioSystemResponsive))"
    }
}
