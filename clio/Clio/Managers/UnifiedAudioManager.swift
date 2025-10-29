
//
//  UnifiedAudioManager.swift
//  Clio
//
//  Unified audio management for all recording and streaming services
//  Ensures consistent validation, initialization, and error handling
//

import Foundation
import AVFoundation
import os
import Combine
import CoreAudio

// OSStatus helpers
fileprivate func _desc(_ status: OSStatus) -> String {
    let u = UInt32(bitPattern: status)
    let hex = String(format: "0x%08X", u)
    let bytes: [UInt8] = [
        UInt8((u >> 24) & 0xFF),
        UInt8((u >> 16) & 0xFF),
        UInt8((u >> 8) & 0xFF),
        UInt8(u & 0xFF)
    ]
    let isPrintable = bytes.allSatisfy { $0 >= 32 && $0 <= 126 }
    let fourCC = isPrintable ? String(bytes: bytes, encoding: .ascii) ?? "" : ""
    let name: String? = {
        switch status {
        case 0: return "noErr"
        case -50: return "paramErr"
        case -10879: return "kAudioUnitErr_InvalidProperty"
        case -10878: return "kAudioUnitErr_InvalidParameter"
        case -10877: return "kAudioUnitErr_InvalidElement"
        case -10876: return "kAudioUnitErr_NoConnection"
        case -10875: return "kAudioUnitErr_FailedInitialization"
        case -10874: return "kAudioUnitErr_TooManyFramesToProcess"
        case -10868: return "kAudioUnitErr_PropertyNotInUse"
        case -10865: return "kAudioUnitErr_PropertyNotWritable"
        case -10863: return "kAudioUnitErr_InvalidScope"
        case -10861: return "kAudioUnitErr_Initialized"
        default: return nil
        }
    }()
    if let n = name, !fourCC.isEmpty { return "\(status) (\(hex), '\(fourCC)') \(n)" }
    if let n = name { return "\(status) (\(hex)) \(n)" }
    if !fourCC.isEmpty { return "\(status) (\(hex), '\(fourCC)')" }
    return "\(status) (\(hex))"
}

/// Central audio manager that all services must use for audio capture
/// Ensures proper initialization, validation, and resource management
public final class UnifiedAudioManager: NSObject, ObservableObject {

    // MARK: - Singleton
    public static let shared = UnifiedAudioManager()

    // MARK: - Properties
    private let logger = Logger(subsystem: "com.cliovoice.clio", category: "UnifiedAudioManager")

    @Published public private(set) var isCapturing = false
    private var perfFirstBufferLogged: Bool = false

    // Session pinning state
    private var pinnedPrevDefaultInput: AudioDeviceID?
    private var pinnedDesiredInput: AudioDeviceID?
    @Published public private(set) var audioSystemHealth: AudioSystemHealth = .unknown
    @Published public private(set) var lastError: Error?

    // Audio engine components
    private var audioEngine: AVAudioEngine?
    private var inputNode: AVAudioInputNode?
    private var currentTaps = Set<AudioTapIdentifier>()

    // AVCaptureSession backend
    private var avCaptureSession: AVCaptureSession?
    private var avCaptureOutput: AVCaptureAudioDataOutput?
    private var avDelegateProxy: OffMainAVCaptureDelegate?
    private let avCaptureQueue = DispatchQueue(label: "com.cliovoice.clio.avcapture", qos: .userInitiated)
    private var captureTapBlock: ((AVAudioPCMBuffer, AVAudioTime) -> Void)?
    // Tracks which logical service owns the current AVCapture forwarding tap.
    // Prevents unrelated unregisters (e.g., preview teardown) from clearing the active stream tap.
    private var avCaptureActiveTap: AudioTapIdentifier?
    private var lastAVCaptureBufferAt: Date? = nil

    // Level logging and silence watchdog
    private var lastLevelLogAt: Date? = nil
    private var silenceBelowThresholdSince: Date? = nil
    private let levelLogInterval: TimeInterval = 2.0
    private let silenceThresholdDb: Double = -50.0
    private let silenceDurationSec: TimeInterval = 3.0
    private var emittedSilenceEventForThisSession = false

    // Cold start management
    private var isFirstCapture = true
    private var lastCaptureTime: Date?
    private let coldStartThreshold: TimeInterval = 30.0 // 30 seconds of idle = cold start

    // Audio system health monitoring
    private var healthCheckTimer: DispatchSourceTimer?
    private let healthCheckInterval: TimeInterval = 5.0
    private var softNoFirstBufferRestartScheduled: Bool = false
    private var quickNoFirstBufferRefreshScheduled: Bool = false

    // Preflight throttling
    private var lastPreflightAt: Date? = nil

    // MARK: - Initialization
    private override init() {
        super.init()
        startHealthMonitoring()
        // Listen for diagnostic snapshot requests
        NotificationCenter.default.addObserver(self, selector: #selector(handleDiagnosticsSnapshot), name: .diagnosticsSnapshot, object: nil)
    }

    // MARK: - Public API

    /// Register an audio tap for a service
    /// - Parameters:
    ///   - identifier: Unique identifier for the tap
    ///   - format: Audio format for the tap (nil = hardware format)
    ///   - bufferSize: Buffer size for audio processing
    ///   - tapBlock: Block to process audio buffers
    public func registerAudioTap(
        identifier: AudioTapIdentifier,
        format: AVAudioFormat? = nil,
        bufferSize: AVAudioFrameCount = 1024,
        tapBlock: @escaping (AVAudioPCMBuffer, AVAudioTime) -> Void,
        preflight: Bool = true
    ) async throws {
        logger.info("🎤 Registering audio tap for \(identifier.serviceName)")
        StructuredLog.shared.log(cat: .audio, evt: "record_start", lvl: .info, ["service": identifier.serviceName])

        // Perform pre-flight checks (throttled) unless explicitly skipped
        if preflight {
            let now = Date()
            let shouldThrottle: Bool = {
                if let last = lastPreflightAt {
                    return now.timeIntervalSince(last) < RuntimeConfig.preflightMinIntervalSeconds
                }
                return false
            }()
            if shouldThrottle {
                StructuredLog.shared.log(cat: .audio, evt: "preflight_skip_throttle", lvl: .info, [
                    "since_last_s": Int(Date().timeIntervalSince(lastPreflightAt ?? .distantPast))
                ])
            } else {
                try await performPreFlightChecks()
                lastPreflightAt = now
            }
        }

        if RuntimeConfig.captureBackend == .audioEngine {
            // Initialize audio engine if needed
            try await initializeAudioEngine()

            // Install the tap
            guard let inputNode = inputNode else {
                throw AudioError.engineNotInitialized
            }

            var hardwareFormat = inputNode.inputFormat(forBus: 0)
            // Work-around: before the engine is started the input format can report 0 Hz / 0 channels
            // which makes installTap crash.  If we detect an invalid format, fall back to a sane
            // default (48 kHz mono Float32) that will be updated automatically once the engine starts.
            if hardwareFormat.sampleRate == 0 || hardwareFormat.channelCount == 0 {
                if let safeFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32,
                                                  sampleRate: 48_000,
                                                  channels: 1,
                                                  interleaved: false) {
                    logger.warning("⚠️ Input node reports invalid format (0 Hz / 0 ch) before engine start – using fallback 48 kHz mono for tap installation")
                    hardwareFormat = safeFormat
                }
            }
            let tapFormat = format ?? hardwareFormat
            // Wrap the user tap to emit a first-buffer perf marker exactly once
            let wrappedTap: (AVAudioPCMBuffer, AVAudioTime) -> Void = { [weak self] buffer, time in
                if let self = self, !self.perfFirstBufferLogged {
                    self.perfFirstBufferLogged = true
                    DebugLogger.debug("perf:first_audio_buffer", category: .performance)
                }
                tapBlock(buffer, time)
            }
            StructuredLog.shared.log(cat: .audio, evt: "engine_config", lvl: .info, [
                "hw_sr": Int(hardwareFormat.sampleRate),
                "hw_ch": hardwareFormat.channelCount,
                "tap_sr": Int(tapFormat.sampleRate),
                "tap_ch": tapFormat.channelCount,
                "buf_frames": Int(bufferSize)
            ])

            inputNode.installTap(
                onBus: 0,
                bufferSize: bufferSize,
                format: tapFormat
            ) { buffer, time in
                // Emit perf marker on first buffer for audio engine path
                if !self.perfFirstBufferLogged {
                    self.perfFirstBufferLogged = true
                    DebugLogger.debug("perf:first_audio_buffer", category: .performance)
                }
                // Compute per-channel and overall RMS/peak (Float32 path)
                var avgDb: Double? = nil
                var peakDb: Double? = nil
                if let chData = buffer.floatChannelData {
                    let frames = Int(buffer.frameLength)
                    let channels = Int(buffer.format.channelCount)
                    if frames > 0 && channels > 0 {
                        var sumSq: Double = 0
                        var perChannelRMS: [Double] = Array(repeating: 0, count: channels)
                        var peak: Double = 0
                        for ch in 0..<channels {
                            var chSumSq: Double = 0
                            let ptr = chData[ch]
                            let buf = UnsafeBufferPointer(start: ptr, count: frames)
                            for s in buf {
                                let v = Double(s)
                                sumSq += v * v
                                chSumSq += v * v
                                let a = abs(v)
                                if a > peak { peak = a }
                            }
                            let chRMS = sqrt(max(chSumSq / Double(frames), 1e-12))
                            perChannelRMS[ch] = chRMS
                        }
                        let n = Double(frames * channels)
                        let rms = sqrt(max(sumSq / max(n, 1.0), 1e-12))
                        avgDb = 20.0 * log10(rms)
                        let peakClamped = max(peak, 1e-12)
                        peakDb = 20.0 * log10(peakClamped)
                        // Per-channel dB values
                        for (idx, chRMS) in perChannelRMS.enumerated() {
                            let chDb = 20.0 * log10(chRMS)
                            StructuredLog.shared.log(cat: .audio, evt: "level_chan", lvl: .info, [
                                "chan": idx,
                                "db": Double(round(chDb * 10)/10)
                            ])
                        }
                    }
                }
                // Periodic level log
                let now = Date()
                if let a = avgDb, let p = peakDb {
                    if self.lastLevelLogAt == nil || now.timeIntervalSince(self.lastLevelLogAt!) >= self.levelLogInterval {
                        self.lastLevelLogAt = now
                        StructuredLog.shared.log(cat: .audio, evt: "level", lvl: .info, [
                            "avg_db": Double(round(a * 10) / 10),
                            "peak_db": Double(round(p * 10) / 10)
                        ])
                    }
                    // Silence watchdog
                    if a < self.silenceThresholdDb {
                        if self.silenceBelowThresholdSince == nil {
                            self.silenceBelowThresholdSince = now
                        }
                        if !self.emittedSilenceEventForThisSession, let since = self.silenceBelowThresholdSince, now.timeIntervalSince(since) >= self.silenceDurationSec {
                            self.emittedSilenceEventForThisSession = true
                            let adm = AudioDeviceManager.shared
                            let dev = adm.getCurrentDevice()
                            let name = adm.getDeviceName(deviceID: dev) ?? "unknown"
                            let uid = adm.getDeviceUID(deviceID: dev) ?? ""
                            StructuredLog.shared.log(cat: .audio, evt: "silence_detected", lvl: .warn, [
                                "threshold_db": self.silenceThresholdDb,
                                "duration_s": self.silenceDurationSec,
                                "device_id": Int(dev),
                                "device_name": name,
                                "device_uid_hash": String(uid.hashValue)
                            ])
                        }
                    } else {
                        self.silenceBelowThresholdSince = nil
                    }
                }

                tapBlock(buffer, time)
            }

            currentTaps.insert(identifier)
            logger.info("✅ Audio tap registered for \(identifier.serviceName)")
            StructuredLog.shared.log(cat: .audio, evt: "tap_install", lvl: .info, ["ok": true, "service": identifier.serviceName])
        } else {
            // AVCapture backend: store a wrapped tap block; capture will feed it
            self.captureTapBlock = { [weak self] buffer, time in
                if let self = self, !self.perfFirstBufferLogged {
                    self.perfFirstBufferLogged = true
                    DebugLogger.debug("perf:first_audio_buffer", category: .performance)
                }
                tapBlock(buffer, time)
            }
            // Record owner so later unregisters don't accidentally clear an active stream tap
            self.avCaptureActiveTap = identifier
            StructuredLog.shared.log(cat: .audio, evt: "tap_install", lvl: .info, ["ok": true, "service": identifier.serviceName, "backend": "avcapture"])
        }
    }

    /// Unregister an audio tap
    public func unregisterAudioTap(identifier: AudioTapIdentifier) async {
        logger.info("🔌 Unregistering audio tap for \(identifier.serviceName)")

        // For AVAudioEngine backend, track taps via set
        if RuntimeConfig.captureBackend == .audioEngine {
            guard currentTaps.contains(identifier) else {
                logger.warning("⚠️ No tap registered for \(identifier.serviceName)")
                return
            }
            currentTaps.remove(identifier)
            // If no more taps, stop the engine
            if currentTaps.isEmpty {
                await stopAudioEngine()
            }
        } else {
            // AVCapture backend: only clear the forwarding tap if this identifier owns it.
            if let owner = avCaptureActiveTap, owner == identifier {
                self.captureTapBlock = nil
                self.avCaptureActiveTap = nil
            } else {
                // Another tap (e.g., preview) is being unregistered — keep the active stream tap
                // intact. This avoids losing audio callbacks during promotion.
                logger.debug("ℹ️ Skipping tap clear for \(identifier.serviceName); active owner=\(self.avCaptureActiveTap?.serviceName ?? "none")")
            }
        }
    }

    /// Start audio capture (called by services when they begin recording/streaming)
    public func startCapture() async throws {
        guard !isCapturing else {
            logger.info("⚡ Audio capture already active")
            return
        }

        // logger.info("🎬 Starting unified audio capture")
        StructuredLog.shared.log(cat: .audio, evt: "record_start", lvl: .info, ["reason": "start_capture"])
        perfFirstBufferLogged = false
        DebugLogger.debug("perf:capture_start", category: .performance)

        // VoiceInk-style by default: do NOT pin system devices unless Compatibility Mode is enabled
        if RuntimeConfig.enableCompatibilityMode {
            let adm = AudioDeviceManager.shared
            let desired = adm.getCurrentDevice()
            let prev = AudioDeviceConfiguration.getDefaultInputDevice()
            pinnedPrevDefaultInput = prev
            pinnedDesiredInput = desired
            if desired != 0 {
                // Lightweight id-only log to avoid main-thread name/uid lookups
                StructuredLog.shared.log(cat: .audio, evt: "device_pin_start", lvl: .info, [
                    "prev_id": Int(prev ?? 0),
                    "desired_id": Int(desired)
                ])
                // Resolve names/UIDs off-main and emit a follow-up metadata log
                Task.detached(priority: .utility) {
                    let prevName = prev.flatMap { adm.getDeviceName(deviceID: $0) } ?? "unknown"
                    let prevUID = prev.flatMap { adm.getDeviceUID(deviceID: $0) } ?? ""
                    let desiredName = adm.getDeviceName(deviceID: desired) ?? "unknown"
                    let desiredUID = adm.getDeviceUID(deviceID: desired) ?? ""
                    StructuredLog.shared.log(cat: .audio, evt: "device_pin_meta", lvl: .info, [
                        "prev_name": prevName,
                        "prev_uid_hash": String(prevUID.hashValue),
                        "desired_name": desiredName,
                        "desired_uid_hash": String(desiredUID.hashValue)
                    ])
                }
                // Avoid re-applying if already default
                if let prev, prev == desired {
                    StructuredLog.shared.log(cat: .audio, evt: "device_pin_skip", lvl: .info, [
                        "reason": "already_default",
                        "desired_id": Int(desired)
                    ])
                } else {
                    let t0 = Date()
                    do {
                        // Run potentially blocking CoreAudio property set off-main
                        try await Task.detached(priority: .userInitiated) {
                            try AudioDeviceConfiguration.setDefaultInputDevice(desired)
                        }.value
                        let dt = Int(Date().timeIntervalSince(t0) * 1000)
                        StructuredLog.shared.log(cat: .audio, evt: "device_pin_ok", lvl: .info, [
                            "dt_ms": dt,
                            "desired_id": Int(desired)
                        ])
                    } catch {
                        let dt = Int(Date().timeIntervalSince(t0) * 1000)
                        StructuredLog.shared.log(cat: .audio, evt: "device_pin_error", lvl: .err, [
                            "dt_ms": dt,
                            "error": "set_default_failed",
                            "message": String(describing: error),
                            "desired_id": Int(desired)
                        ])
                    }
                }
            }
        } else {
            pinnedPrevDefaultInput = nil
            pinnedDesiredInput = nil
        }

        // Check if this is a cold start
        let isColdStart = checkIfColdStart()
        if isColdStart {
            logger.warning("❄️ Cold start detected - performing full initialization")
            // Run cold start in background but await completion to maintain proper sequencing
            try await Task.detached(priority: .userInitiated) {
                do {
                    try await self.performColdStartInitialization()
                } catch {
                    await MainActor.run {
                        self.logger.error("❌ Cold start initialization failed: \(error)")
                    }
                    throw error
                }
            }.value
        }

        if RuntimeConfig.captureBackend == .audioEngine {
            // Start the audio engine
            guard let engine = audioEngine else {
                throw AudioError.engineNotInitialized
            }

            if !engine.isRunning {
                try engine.start()
            }

            // After start, validate hardware format; if still invalid, fall back to AVCapture
            let hwFmtPost = inputNode?.inputFormat(forBus: 0)
            if let fmt = hwFmtPost, (fmt.sampleRate == 0 || fmt.channelCount == 0) {
                logger.error("❌ AVAudioEngine input still invalid after start – falling back to AVCapture")
                StructuredLog.shared.log(cat: .audio, evt: "engine_invalid_hw_format", lvl: .err, [String: Any]())
                await stopAudioEngine()
                try await startAVCaptureSession()
            }

            // Verify pinning after engine start (only in Compatibility Mode)
            if RuntimeConfig.enableCompatibilityMode, let desired = pinnedDesiredInput {
                let adm = AudioDeviceManager.shared
                let current = AudioDeviceConfiguration.getDefaultInputDevice()
                let ok = (current == desired)
                let currName = current.flatMap { adm.getDeviceName(deviceID: $0) } ?? "unknown"
                let currUID = current.flatMap { adm.getDeviceUID(deviceID: $0) } ?? ""
                let desiredName = adm.getDeviceName(deviceID: desired) ?? "unknown"
                let desiredUID = adm.getDeviceUID(deviceID: desired) ?? ""
                let payloadVerify: [String: Any] = [
                    "ok": ok,
                    "current_id": Int(current ?? 0),
                    "current_name": currName,
                    "current_uid_hash": String(currUID.hashValue),
                    "desired_id": Int(desired),
                    "desired_name": desiredName,
                    "desired_uid_hash": String(desiredUID.hashValue)
                ]
                StructuredLog.shared.log(cat: .audio, evt: "device_pin_verify", lvl: ok ? .info : .warn, payloadVerify)
            }
        } else {
            // Start AVCapture session
            try await startAVCaptureSession()
        }

        await MainActor.run { self.isCapturing = true }
        lastCaptureTime = Date()
        isFirstCapture = false
        emittedSilenceEventForThisSession = false
        lastLevelLogAt = nil
        silenceBelowThresholdSince = nil

        logger.info("✅ Unified audio capture started")
    }

    /// Stop audio capture
    public func stopCapture() async {
        guard isCapturing else {
            logger.info("⚡ Audio capture already stopped")
            return
        }

        logger.info("🛑 Stopping unified audio capture")
        StructuredLog.shared.log(cat: .audio, evt: "record_stop", lvl: .info, [String: Any]())

        await MainActor.run { self.isCapturing = false }
        lastCaptureTime = Date()

        // Don't stop engine immediately - services might restart quickly
        // Engine will be stopped when all taps are removed

        // Stop AVCapture if active
        await stopAVCaptureSession()

        logger.info("✅ Unified audio capture stopped")
    }

    public func refreshCapturePipelineForStreaming(reason: String) async {
        guard isCapturing else { return }

        if RuntimeConfig.captureBackend == .avCaptureSession {
            let before = await MainActor.run { self.lastAVCaptureBufferAt }
            await refreshAVCaptureTap()

            try? await Task.sleep(nanoseconds: 150_000_000)

            let after = await MainActor.run { self.lastAVCaptureBufferAt }
            if before == after {
                StructuredLog.shared.log(cat: .audio, evt: "capture_refresh_retry", lvl: .warn, [
                    "reason": reason
                ])
                await restartAVCaptureSession(reason: reason)
            }
        } else {
            await rebuildAudioEngineCapture(reason: reason)
        }
    }

    public func rebuildCapturePipeline(reason: String) async {
        StructuredLog.shared.log(cat: .audio, evt: "capture_rebuild", lvl: .warn, ["reason": reason])
        if RuntimeConfig.captureBackend == .avCaptureSession {
            await restartAVCaptureSession(reason: reason)
        } else {
            await rebuildAudioEngineCapture(reason: reason)
        }
    }

    // MARK: - Private Methods
    private func performPreFlightChecks() async throws {
        logger.info("🔍 Performing audio system pre-flight checks")

        // Check microphone permission
        let micPermission = await checkMicrophonePermission()
        guard micPermission else {
            throw AudioError.microphonePermissionDenied
        }

        // Check audio system health
        let health = await diagnoseAudioSystemHealth()
        await MainActor.run { self.audioSystemHealth = health }

        guard health.isHealthy else {
            logger.error("❌ Audio system unhealthy: \(health.description)")
            throw AudioError.audioSystemUnhealthy(health.description)
        }

        logger.info("✅ Pre-flight checks passed")
    }

    private func initializeAudioEngine() async throws {
        // Ensure we are using the desired backend; for v1 we only support AVAudioEngine
        guard RuntimeConfig.captureBackend == .audioEngine else {
            StructuredLog.shared.log(cat: .audio, evt: "capture_backend_selected", lvl: .info, ["backend": "avcapture"])
            // Engine not needed in AVCapture mode
            return
        }
        StructuredLog.shared.log(cat: .audio, evt: "capture_backend_selected", lvl: .info, ["backend": "audio_engine"])
        if audioEngine == nil {
            logger.info("🔧 Initializing audio engine")

            audioEngine = AVAudioEngine()
            // Ensure graph is pulled: connect input → mainMixer → output (volume 0)
            if let engine = audioEngine {
                let mixer = engine.mainMixerNode
                mixer.outputVolume = 0 // mute
                let input = engine.inputNode
                let hwFmt = input.inputFormat(forBus: 0)
                engine.connect(input, to: mixer, format: hwFmt)
                engine.connect(mixer, to: engine.outputNode, format: hwFmt)
            }
            inputNode = audioEngine?.inputNode

            // On macOS, optionally pin the engine input node to a specific CoreAudio device (WhisperKit-style)
            #if os(macOS)
            if RuntimeConfig.enableCompatibilityMode {
                if let inputNode = inputNode, let au = inputNode.audioUnit {
                    let adm = AudioDeviceManager.shared
                    let target = adm.getCurrentDevice()
                    if target != 0 {
                        var dev = target
let status = AudioUnitSetProperty(
                            au,
                            kAudioOutputUnitProperty_CurrentDevice,
                            kAudioUnitScope_Global,
                            0,
                            &dev,
                            UInt32(MemoryLayout<AudioDeviceID>.size)
                        )
                        if status != noErr {
                            StructuredLog.shared.log(cat: .audio, evt: "engine_pin_input_failed", lvl: .err, ["status": Int(status), "status_desc": _desc(status)])
                            logger.error("❌ Failed to pin AVAudioEngine input (status=\(_desc(status)))")
                        } else {
                            let name = adm.getDeviceName(deviceID: target) ?? "unknown"
                            let uid = adm.getDeviceUID(deviceID: target) ?? ""
                            StructuredLog.shared.log(cat: .audio, evt: "engine_pin_input", lvl: .info, [
                                "device_id": Int(target),
                                "device_name": name,
                                "device_uid_hash": String(uid.hashValue)
                            ])
                            logger.info("📌 Pinned AVAudioEngine input to device ID=\(target) name=\(name)")
                        }
                    } else {
                        logger.warning("⚠️ No valid target device to pin (deviceID=0)")
                    }
                } else {
                    logger.warning("⚠️ Input node or audio unit unavailable; cannot pin device")
                }
            }
            #endif

            // Configure for optimal performance
            let hardwareFormat = inputNode?.inputFormat(forBus: 0)
            if let f = hardwareFormat {
                StructuredLog.shared.log(cat: .audio, evt: "engine_start", lvl: .info, [
                    "ok": true,
                    "hw_sr": Int(f.sampleRate),
                    "hw_ch": f.channelCount
                ])
            } else {
                StructuredLog.shared.log(cat: .audio, evt: "engine_start", lvl: .err, ["ok": false])
            }
            let fmtDesc = String(describing: hardwareFormat)
            logger.info("🎤 Hardware format: \(fmtDesc)")
        }
    }

    private func stopAudioEngine() async {
        logger.info("🛑 Stopping audio engine")
        StructuredLog.shared.log(cat: .audio, evt: "engine_stop", lvl: .info, [String: Any]())

        if let engine = audioEngine, engine.isRunning {
            engine.stop()
        }

        if let input = inputNode {
            input.removeTap(onBus: 0)
        }

        audioEngine = nil
        inputNode = nil

        // Restore previous default input only if Compatibility Mode pinned one
        if RuntimeConfig.enableCompatibilityMode, let prev = pinnedPrevDefaultInput {
            let adm = AudioDeviceManager.shared
            let prevName = adm.getDeviceName(deviceID: prev) ?? "unknown"
            let prevUID = adm.getDeviceUID(deviceID: prev) ?? ""
            let t0 = Date()
            do {
                try await Task.detached(priority: .userInitiated) {
                    try AudioDeviceConfiguration.setDefaultInputDevice(prev)
                }.value
                let dt = Int(Date().timeIntervalSince(t0) * 1000)
                StructuredLog.shared.log(cat: .audio, evt: "device_restore", lvl: .info, [
                    "dt_ms": dt,
                    "restored_id": Int(prev),
                    "restored_name": prevName,
                    "restored_uid_hash": String(prevUID.hashValue)
                ])
            } catch {
                let dt = Int(Date().timeIntervalSince(t0) * 1000)
                StructuredLog.shared.log(cat: .audio, evt: "device_restore_error", lvl: .err, [
                    "dt_ms": dt,
                    "error": "restore_failed",
                    "message": String(describing: error),
                    "restored_id": Int(prev),
                    "restored_name": prevName,
                    "restored_uid_hash": String(prevUID.hashValue)
                ])
            }
        }
        pinnedPrevDefaultInput = nil
        pinnedDesiredInput = nil

        logger.info("✅ Audio engine stopped")
    }

    private func checkIfColdStart() -> Bool {
        guard !isFirstCapture else { return true }

        if let lastTime = lastCaptureTime {
            let timeSinceLastCapture = Date().timeIntervalSince(lastTime)
            return timeSinceLastCapture > coldStartThreshold
        }

        return true
    }

    private func performColdStartInitialization() async throws {
        logger.info("❄️ Performing cold start initialization")

        // Only perform engine-specific cold start when using the audio engine backend
        guard RuntimeConfig.captureBackend == .audioEngine else {
            logger.info("⏭️ Skipping engine cold start (backend=AVCapture)")
            return
        }

        // Reset audio system state
        await stopAudioEngine()

        // Brief delay to ensure clean state
        try await Task.sleep(nanoseconds: 100_000_000) // 100ms

        // Reinitialize with fresh state
        try await initializeAudioEngine()

        // Warm up the audio system with a test recording
        logger.info("🔥 Warming up audio system")
        if let engine = audioEngine {
            try engine.start()
            try await Task.sleep(nanoseconds: 50_000_000) // 50ms warm-up
            engine.stop()
        }

        logger.info("✅ Cold start initialization complete")
    }

    private func checkMicrophonePermission() async -> Bool {
        #if os(macOS)
        // On macOS, check if we have microphone access
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .audio)
        default:
            return false
        }
        #else
        return true // iOS handled differently
        #endif
    }

    private func diagnoseAudioSystemHealth() async -> AudioSystemHealth {
        var issues: [String] = []

        // Check for available input devices
        #if os(macOS)
        let devices = AVCaptureDevice.devices(for: .audio)
        if devices.isEmpty {
            issues.append("No audio input devices found")
        }
        #endif

        // Avoid constructing AVAudioEngine for health probes when using AVCapture backend
        let shouldProbeWithEngine: Bool = (RuntimeConfig.captureBackend == .audioEngine) && !RuntimeConfig.avoidAVAudioEngineHealthProbe
        if shouldProbeWithEngine {
            // Non-invasive check: inspect input format without starting any engine
            let testEngine = AVAudioEngine()
            let testNode = testEngine.inputNode
            let format = testNode.inputFormat(forBus: 0)
            if format.sampleRate == 0 {
                issues.append("Invalid audio format detected")
            }
        }

        return AudioSystemHealth(
            isHealthy: issues.isEmpty,
            issues: issues,
            timestamp: Date()
        )
    }

    private func startHealthMonitoring() {
        let t = DispatchSource.makeTimerSource(queue: DispatchQueue(label: "com.cliovoice.clio.audio-health", qos: .utility))
        t.schedule(deadline: .now() + healthCheckInterval, repeating: healthCheckInterval, leeway: .milliseconds(50))
        t.setEventHandler { [weak self] in
            guard let self = self else { return }
            // Only run while capturing and if not disabled via runtime toggle
            guard self.isCapturing, !RuntimeConfig.disableAudioHealthCheck else { return }
            Task.detached(priority: .utility) { [weak self] in
                guard let self = self else { return }
                let health = await self.diagnoseAudioSystemHealth()
                await MainActor.run {
                    self.audioSystemHealth = health
                    if !health.isHealthy {
                        self.logger.warning("⚠️ Audio system health degraded: \(health.description)")
                    }
                }
            }
        }
        healthCheckTimer = t
        t.resume()
    }

    // MARK: - Diagnostics
    @objc private func handleDiagnosticsSnapshot() {
        Task { @MainActor in
            self.debugSnapshot(tag: "broadcast")
        }
    }

    @MainActor
    public func debugSnapshot(tag: String) {
        let engineRunning = audioEngine?.isRunning ?? false
        let avcRunning = avCaptureSession?.isRunning ?? false
        StructuredLog.shared.log(cat: .audio, evt: "ua_snapshot", lvl: .info, [
            "tag": tag,
            "isCapturing": isCapturing,
            "currentTaps": currentTaps.count,
            "engineRunning": engineRunning,
            "avCaptureRunning": avcRunning
        ])
    }
    // MARK: - AVCaptureSession Backend
    private func startAVCaptureSession() async throws {
        StructuredLog.shared.log(cat: .audio, evt: "capture_backend_selected", lvl: .info, ["backend": "avcapture"])
        let session: AVCaptureSession = avCaptureSession ?? AVCaptureSession()

        let t0 = Date()
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            avCaptureQueue.async {
                session.beginConfiguration()
                if session.canSetSessionPreset(.high) { session.sessionPreset = .high }

                // Ensure at least one audio input
                let hasAudioInput = session.inputs.contains { ($0 as? AVCaptureDeviceInput)?.device.hasMediaType(.audio) == true }
                if !hasAudioInput {
                    guard let device = AVCaptureDevice.default(for: .audio) else {
                        StructuredLog.shared.log(cat: .audio, evt: "avcapture_start_failed", lvl: .err, ["message": "No AVCapture audio device available"]) ;
                        session.commitConfiguration()
                        cont.resume(throwing: AudioError.engineNotInitialized)
                        return
                    }
                    do {
                        let input = try AVCaptureDeviceInput(device: device)
                        if session.canAddInput(input) { session.addInput(input) } else {
                            StructuredLog.shared.log(cat: .audio, evt: "avcapture_start_failed", lvl: .err, ["message": "Cannot add AVCapture input"])
                            session.commitConfiguration()
                            cont.resume(throwing: AudioError.engineNotInitialized)
                            return
                        }
                    } catch {
                        StructuredLog.shared.log(cat: .audio, evt: "avcapture_start_failed", lvl: .err, ["message": "Failed to create AVCaptureDeviceInput", "err": String(describing: error)])
                        session.commitConfiguration()
                        cont.resume(throwing: error)
                        return
                    }
                }

                // Ensure output and delegate are attached
                var output: AVCaptureAudioDataOutput
                if let existingOut = self.avCaptureOutput, session.outputs.contains(existingOut) {
                    output = existingOut
                } else {
                    output = AVCaptureAudioDataOutput()
                    output.audioSettings = [
                        AVFormatIDKey: kAudioFormatLinearPCM,
                        AVLinearPCMIsFloatKey: true,
                        AVLinearPCMBitDepthKey: 32,
                        AVLinearPCMIsBigEndianKey: false,
                        AVLinearPCMIsNonInterleaved: true,
                        AVSampleRateKey: 48000,
                        AVNumberOfChannelsKey: 1
                    ]
                    if RuntimeConfig.offMainAVCaptureDelegateEnabled {
                        // Run delegate off-main via proxy; forward back to manager on main to preserve semantics
                        let proxy = OffMainAVCaptureDelegate { [weak self] pcm, when in
                            guard let self = self else { return }
                            Task { @MainActor in
                                self.lastAVCaptureBufferAt = Date()
                                if let block = self.captureTapBlock {
                                    block(pcm, when)
                                }
                            }
                        }
                        self.avDelegateProxy = proxy
                        output.setSampleBufferDelegate(proxy, queue: self.avCaptureQueue)
                    } else {
                        output.setSampleBufferDelegate(self, queue: self.avCaptureQueue)
                    }
                    if session.canAddOutput(output) {
                        session.addOutput(output)
                    } else {
                        StructuredLog.shared.log(cat: .audio, evt: "avcapture_start_failed", lvl: .err, ["message": "Cannot add AVCapture output"])
                        session.commitConfiguration()
                        cont.resume(throwing: AudioError.engineNotInitialized)
                        return
                    }
                }

                session.commitConfiguration()
                self.avCaptureSession = session
                self.avCaptureOutput = output
                self.lastAVCaptureBufferAt = nil
                self.softNoFirstBufferRestartScheduled = false
                self.quickNoFirstBufferRefreshScheduled = false
                cont.resume()
            }
        }
        let dt = Int(Date().timeIntervalSince(t0) * 1000)
        StructuredLog.shared.log(cat: .audio, evt: "avcapture_config", lvl: .info, ["dt_ms": dt])

        // Start running on the session queue to avoid main-thread stalls
        let startGroup = DispatchGroup()
        startGroup.enter()
        avCaptureQueue.async {
            if !session.isRunning { session.startRunning() }
            startGroup.leave()
        }
        avCaptureQueue.async {
            startGroup.wait()
            Task { @MainActor in
                let running = session.isRunning
StructuredLog.shared.log(cat: .audio, evt: "avcapture_start", lvl: running ? .info : .err, ["ok": running])
                // Quick delegate refresh if no buffers arrive within ~150ms (zombie converter guard)
                if RuntimeConfig.captureBackend == .avCaptureSession {
                    if !self.quickNoFirstBufferRefreshScheduled {
                        self.quickNoFirstBufferRefreshScheduled = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
                            guard let self = self else { return }
                            if self.lastAVCaptureBufferAt == nil {
                                StructuredLog.shared.log(cat: .audio, evt: "avcapture_no_first_buffer_quick_refresh", lvl: .warn, [:])
                                Task { await self.refreshAVCaptureTap() }
                            }
                        }
                    }
                }
                // Soft watchdog (disabled by default to avoid privacy indicator flicker)
                if !RuntimeConfig.disableAVCaptureSoftRestart {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
                        guard let self else { return }
                        if self.avCaptureSession === session {
                            if self.lastAVCaptureBufferAt == nil && !self.softNoFirstBufferRestartScheduled {
                                self.softNoFirstBufferRestartScheduled = true
                                StructuredLog.shared.log(cat: .audio, evt: "avcapture_no_first_buffer_soft", lvl: .warn, [String: Any]())
                                // Prefer soft delegate refresh instead of stop/start
                                Task { await self.refreshAVCaptureTap() }
                            }
                        }
                    }
                }
                // Hard fallback (disabled by default): only if explicitly enabled
                if !RuntimeConfig.disableAVCaptureHardFallback {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { [weak self] in
                        guard let self else { return }
                        if self.avCaptureSession === session {
                            if self.lastAVCaptureBufferAt == nil {
                                StructuredLog.shared.log(cat: .audio, evt: "avcapture_no_buffers", lvl: .err, [String: Any]())
                                Task { @MainActor in
                                    await self.fallbackToEngineFromAVCapture()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private func stopAVCaptureSession() async {
        var dt: Int = 0
        let output = self.avCaptureOutput
        let session = self.avCaptureSession
        if let session {
            let t0 = Date()
            // Perform teardown on the capture queue to synchronize with delegate callbacks
            await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
                avCaptureQueue.async {
                    // First, ensure no more delegate callbacks are delivered
                    if let output = output {
                        output.setSampleBufferDelegate(nil, queue: nil)
                    }
                    // Then stop the session if running
                    if session.isRunning {
                        session.stopRunning()
                    }
                    cont.resume()
                }
            }
            dt = Int(Date().timeIntervalSince(t0) * 1000)
        }
        // Clear strong references after delegate has been nilled on the capture queue
        avCaptureOutput = nil
        avCaptureSession = nil
        avDelegateProxy = nil
        StructuredLog.shared.log(cat: .audio, evt: "avcapture_stop", lvl: .info, ["dt_ms": dt])
    }

    private func restartAVCaptureSession(reason: String) async {
        StructuredLog.shared.log(cat: .audio, evt: "avcapture_restart", lvl: .warn, [
            "reason": reason
        ])
        await stopAVCaptureSession()
        do {
            try await startAVCaptureSession()
            StructuredLog.shared.log(cat: .audio, evt: "avcapture_restart_ok", lvl: .info, [
                "reason": reason
            ])
        } catch {
            StructuredLog.shared.log(cat: .audio, evt: "avcapture_restart_failed", lvl: .err, [
                "reason": reason,
                "error": String(describing: error)
            ])
            logger.error("❌ Failed to restart AVCapture session for \(reason): \(error)")
        }
    }

    /// Refresh the AVCapture delegate/tap without stopping the session.
    /// This avoids toggling the macOS microphone privacy indicator.
    public func refreshAVCaptureTap() async {
        guard RuntimeConfig.captureBackend == .avCaptureSession else { return }
        guard let session = self.avCaptureSession, let output = self.avCaptureOutput else { return }
        await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
            avCaptureQueue.async { [weak self] in
                guard let self = self else { cont.resume(); return }
                // Keep session running; just rebind delegate
                output.setSampleBufferDelegate(nil, queue: nil)
                if RuntimeConfig.offMainAVCaptureDelegateEnabled {
                    let proxy = OffMainAVCaptureDelegate { [weak self] pcm, when in
                        guard let self = self else { return }
                        Task { @MainActor in
                            self.lastAVCaptureBufferAt = Date()
                            if let block = self.captureTapBlock { block(pcm, when) }
                        }
                    }
                    self.avDelegateProxy = proxy
                    output.setSampleBufferDelegate(proxy, queue: self.avCaptureQueue)
                } else {
                    output.setSampleBufferDelegate(self, queue: self.avCaptureQueue)
                }
                // If session was accidentally stopped, start it again (unlikely here)
                if !session.isRunning { session.startRunning() }
                cont.resume()
            }
        }
    }

    private func rebuildAudioEngineCapture(reason: String) async {
        guard RuntimeConfig.captureBackend == .audioEngine else { return }
        do {
            try await MainActor.run {
                if let engine = self.audioEngine, engine.isRunning {
                    engine.stop()
                }
                self.audioEngine = nil
                self.inputNode = nil
            }
            try await initializeAudioEngine()
            try await MainActor.run {
                if let engine = self.audioEngine, !engine.isRunning {
                    try engine.start()
                }
            }
            StructuredLog.shared.log(cat: .audio, evt: "audio_engine_rebuild_ok", lvl: .info, ["reason": reason])
        } catch {
            StructuredLog.shared.log(cat: .audio, evt: "audio_engine_rebuild_failed", lvl: .err, [
                "reason": reason,
                "error": String(describing: error)
            ])
            logger.error("❌ Failed to rebuild audio engine for \(reason): \(error)")
        }
    }
}

// MARK: - AVCaptureAudioDataOutputSampleBufferDelegate
extension UnifiedAudioManager: AVCaptureAudioDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let block = self.captureTapBlock else { return }
        guard let formatDesc = CMSampleBufferGetFormatDescription(sampleBuffer) else { return }
        guard let asbd = CMAudioFormatDescriptionGetStreamBasicDescription(formatDesc) else { return }
        let channels = AVAudioChannelCount(asbd.pointee.mChannelsPerFrame)
        let sampleRate = Double(asbd.pointee.mSampleRate)
        let commonFormat: AVAudioCommonFormat = .pcmFormatFloat32
        guard let format = AVAudioFormat(commonFormat: commonFormat, sampleRate: sampleRate, channels: channels, interleaved: false) else { return }

        guard let numSamples = CMSampleBufferGetNumSamples(sampleBuffer) as Int?, numSamples > 0 else { return }

        // Extract AudioBufferList safely: first query required size, then allocate
        var blockBuffer: CMBlockBuffer? = nil
        var sizeNeeded: Int = 0
        var status = CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(
            sampleBuffer,
            bufferListSizeNeededOut: &sizeNeeded,
            bufferListOut: nil,
            bufferListSize: 0,
            blockBufferAllocator: kCFAllocatorDefault,
            blockBufferMemoryAllocator: kCFAllocatorDefault,
            flags: kCMSampleBufferFlag_AudioBufferList_Assure16ByteAlignment,
            blockBufferOut: &blockBuffer
        )
        if status != noErr || sizeNeeded <= 0 { return }

        let rawPtr = UnsafeMutableRawPointer.allocate(byteCount: sizeNeeded, alignment: MemoryLayout<AudioBufferList>.alignment)
        defer { rawPtr.deallocate() }
        let ablPtr = rawPtr.bindMemory(to: AudioBufferList.self, capacity: 1)
        status = CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(
            sampleBuffer,
            bufferListSizeNeededOut: nil,
            bufferListOut: ablPtr,
            bufferListSize: sizeNeeded,
            blockBufferAllocator: kCFAllocatorDefault,
            blockBufferMemoryAllocator: kCFAllocatorDefault,
            flags: kCMSampleBufferFlag_AudioBufferList_Assure16ByteAlignment,
            blockBufferOut: &blockBuffer
        )
        if status != noErr { return }

        let audioBufferListPointer = UnsafeMutableAudioBufferListPointer(ablPtr)
        // Create destination AVAudioPCMBuffer
        guard let pcmBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(numSamples)) else { return }
        pcmBuffer.frameLength = AVAudioFrameCount(numSamples)

        // Copy deinterleaved float data per channel if available
        for (channelIndex, audioBuffer) in audioBufferListPointer.enumerated() {
            let src = audioBuffer.mData?.assumingMemoryBound(to: Float.self)
            let dst = pcmBuffer.floatChannelData?[min(channelIndex, Int(pcmBuffer.format.channelCount) - 1)]
            if let src = src, let dst = dst {
                let count = min(Int(audioBuffer.mDataByteSize) / MemoryLayout<Float>.size, Int(numSamples))
                dst.assign(from: src, count: count)
            }
        }

        // Mark that capture produced data
        lastAVCaptureBufferAt = Date()
        let when = AVAudioTime(hostTime: mach_absolute_time())
        block(pcmBuffer, when)
    }
}

// MARK: - Fallback Handling
extension UnifiedAudioManager {
    fileprivate func fallbackToEngineFromAVCapture() async {
        // Stop AVCapture
        await stopAVCaptureSession()
        // Initialize engine and install a forwarding tap using the existing captureTapBlock
        do {
            try await initializeAudioEngine()
            guard let input = inputNode else { return }
            let hwFmt = input.inputFormat(forBus: 0)
            let bufSize: AVAudioFrameCount = 1024
            input.removeTap(onBus: 0)
            input.installTap(onBus: 0, bufferSize: bufSize, format: hwFmt) { [weak self] buffer, time in
                guard let self = self, let block = self.captureTapBlock else { return }
                block(buffer, time)
            }
            if let engine = audioEngine, !engine.isRunning { try engine.start() }
            StructuredLog.shared.log(cat: .audio, evt: "backend_fallback_to_engine", lvl: .warn, [String: Any]())
        } catch {
            StructuredLog.shared.log(cat: .audio, evt: "backend_fallback_failed", lvl: .err, ["error": String(describing: error)])
        }
    }
    
    // MARK: - Warmup Methods
    
    /// Pre-warm the audio system to eliminate cold start delays
    /// This method initializes audio components without starting capture
    public func prewarmAudioSystem() async {
        // logger.notice("🎤 [PREWARM] Starting audio system pre-warming...")
        
        do {
            // Pre-warm audio engine initialization
            if audioEngine == nil {
                audioEngine = AVAudioEngine()
                inputNode = audioEngine?.inputNode
                logger.notice("✅ [PREWARM] Audio engine initialized")
            }
            
            // Pre-warm device enumeration and validation
            AudioDeviceManager.shared.loadAvailableDevices()
            logger.notice("✅ [PREWARM] Device enumeration completed")
            
            // Pre-warm AVCaptureSession setup (but don't start it)
            if avCaptureSession == nil {
                let session = AVCaptureSession()
                session.beginConfiguration()
                if session.canSetSessionPreset(.high) { 
                    session.sessionPreset = .high 
                }
                
                if let device = AVCaptureDevice.default(for: .audio) {
                    let input = try AVCaptureDeviceInput(device: device)
                    if session.canAddInput(input) {
                        session.addInput(input)
                        logger.notice("✅ [PREWARM] AVCaptureSession pre-configured")
                    }
                }
                session.commitConfiguration()
                avCaptureSession = session
            }
            
            logger.notice("✅ [PREWARM] Audio system pre-warming completed successfully")
            
        } catch {
            logger.error("❌ [PREWARM] Audio system pre-warming failed: \(error)")
        }
    }
}

// MARK: - Supporting Types

public struct AudioTapIdentifier: Hashable {
    let serviceName: String
    let id: UUID

    init(serviceName: String) {
        self.serviceName = serviceName
        self.id = UUID()
    }
}

public struct AudioSystemHealth {
    let isHealthy: Bool
    let issues: [String]
    let timestamp: Date

    static let unknown = AudioSystemHealth(
        isHealthy: true,
        issues: [],
        timestamp: Date.distantPast
    )

    var description: String {
        if isHealthy {
            return "Healthy"
        } else {
            return "Issues: \(issues.joined(separator: ", "))"
        }
    }
}

public enum AudioError: LocalizedError {
    case engineNotInitialized
    case microphonePermissionDenied
    case audioSystemUnhealthy(String)
    case tapRegistrationFailed(String)

    public var errorDescription: String? {
        switch self {
        case .engineNotInitialized:
            return "Audio engine not initialized"
        case .microphonePermissionDenied:
            return "Microphone permission denied"
        case .audioSystemUnhealthy(let description):
            return "Audio system unhealthy: \(description)"
        case .tapRegistrationFailed(let reason):
            return "Failed to register audio tap: \(reason)"
        }
    }
}

// MARK: - Notification Names

public extension Notification.Name {
    static let audioSystemHealthChanged = Notification.Name("audioSystemHealthChanged")
    // forceCleanupAudioResources is already defined elsewhere in the codebase
}
