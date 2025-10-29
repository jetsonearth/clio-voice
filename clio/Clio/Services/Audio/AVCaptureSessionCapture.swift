//
//  AVCaptureSessionCapture.swift
//  Clio
//
//  Push-based microphone capture using AVCaptureSession.
//  Designed to avoid AVAudioEngine pull-graph issues and stay pinned
//  to a specific hardware UID throughout route changes.
//
//  Capture pipeline:
//  • Opens AVCaptureDevice by uniqueID (or default built-in mic).
//  • Configures AVCaptureAudioDataOutput for LPCM (mono 48 kHz).
//  • Delivers raw sample bytes via delegate callback.
//  • Listens for session runtime errors / device disconnects and
//    automatically rebuilds the session, re-binding to the same UID.
//
//  Integrates with UnifiedAudioManager as CaptureBackend == 3.
//  Services can register as MicCaptureDelegate to receive buffers.
//
//  Created by Agent on 2025-08-19.
//

import AVFoundation
import os

// MARK: - Delegate

protocol MicCaptureDelegate: AnyObject {
    /// Called on `queue` with raw PCM bytes captured from the microphone.
    /// - Parameters:
    ///   - data: Audio data (16-bit signed little-endian PCM, mono, 48 kHz).
    ///   - presentationTime: CMSampleBuffer presentation timestamp.
    func micCapture(didCapturePCM data: Data, presentationTime: CMTime)
}

// MARK: - Capture class

final class AVCaptureSessionCapture: NSObject {
    private let logger = Logger(subsystem: "com.jetsonai.clio", category: "AVCaptureSessionCapture")
    
    private let session = AVCaptureSession()
    private let queue = DispatchQueue(label: "mic.capture.queue")
    private let output = AVCaptureAudioDataOutput()
    private var input: AVCaptureDeviceInput?
    
    weak var delegate: MicCaptureDelegate?
    
    private(set) var currentDeviceUID: String?
    
    // MARK: - Control
    
    func start(using deviceUID: String? = nil) throws {
        let uidDesc = deviceUID ?? "default"
        logger.info("Starting AVCaptureSession using UID=\(uidDesc)")
        
        session.beginConfiguration()
        #if os(iOS)
        session.automaticallyConfiguresApplicationAudioSession = false
        #endif
        
        // Select device (macOS-safe discovery)
        let device: AVCaptureDevice = {
            if let uid = deviceUID {
                let discovery = AVCaptureDevice.DiscoverySession(
                    deviceTypes: [.microphone],
                    mediaType: .audio,
                    position: .unspecified
                )
                if let found = discovery.devices.first(where: { $0.uniqueID == uid }) {
                    return found
                }
            }
            if let def = AVCaptureDevice.default(for: .audio) {
                return def
            }
            // Fallback to first discovered microphone
            let discovery = AVCaptureDevice.DiscoverySession(
                deviceTypes: [.microphone],
                mediaType: .audio,
                position: .unspecified
            )
            guard let first = discovery.devices.first else {
                fatalError("No audio capture devices available")
            }
            return first
        }()
        currentDeviceUID = device.uniqueID
        
        // Input
        let newInput = try AVCaptureDeviceInput(device: device)
        if let old = input { session.removeInput(old) }
        if session.canAddInput(newInput) { session.addInput(newInput) }
        input = newInput
        
        // Output
        output.setSampleBufferDelegate(self, queue: queue)
        output.audioSettings = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVSampleRateKey: 48_000,
            AVNumberOfChannelsKey: 1,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsNonInterleaved: false
        ] as [String : Any]
        if session.canAddOutput(output) { session.addOutput(output) }
        
        session.commitConfiguration()
        session.startRunning()
        
        // Observe errors / device changes
        NotificationCenter.default.addObserver(self, selector: #selector(handleRuntimeError(_:)), name: .AVCaptureSessionRuntimeError, object: session)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDeviceWasDisconnected(_:)), name: .AVCaptureDeviceWasDisconnected, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDeviceWasConnected(_:)), name: .AVCaptureDeviceWasConnected, object: nil)
    }
    
    func stop() {
        logger.info("🛑 Stopping AVCaptureSession")
        session.stopRunning()
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        stop()
    }
    
    // MARK: - Notifications
    
    @objc private func handleRuntimeError(_ n: Notification) {
        logger.error("⚠️ AVCaptureSession runtime error: \(String(describing: n.userInfo)) — restarting")
        restartWithSameUID()
    }
    
    @objc private func handleDeviceWasDisconnected(_ n: Notification) {
        guard let device = n.object as? AVCaptureDevice else { return }
        logger.warning("🔌 Device disconnected: \(device.localizedName)")
        if device.uniqueID == currentDeviceUID {
            restartWithSameUID()
        }
    }
    
    @objc private func handleDeviceWasConnected(_ n: Notification) {
        // We stay pinned to UID; nothing unless our device returns.
    }
    
    private func restartWithSameUID() {
        let uid = currentDeviceUID
        stop()
        try? start(using: uid)
    }
}

// MARK: - SampleBuffer delegate

extension AVCaptureSessionCapture: AVCaptureAudioDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let block = CMSampleBufferGetDataBuffer(sampleBuffer) else { return }
        var length: Int = 0
        var dataPointer: UnsafeMutablePointer<Int8>?
        guard CMBlockBufferGetDataPointer(block, atOffset: 0, lengthAtOffsetOut: nil, totalLengthOut: &length, dataPointerOut: &dataPointer) == noErr else { return }
        if let ptr = dataPointer, length > 0 {
            let data = Data(bytes: ptr, count: length)
            delegate?.micCapture(didCapturePCM: data, presentationTime: CMSampleBufferGetPresentationTimeStamp(sampleBuffer))
        }
    }
}

