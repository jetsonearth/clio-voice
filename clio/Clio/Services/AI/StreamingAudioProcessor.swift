import Foundation
import AVFoundation
import os

final class StreamingAudioProcessor {
    struct Config {
        let targetSampleRate: Double
        let targetChannels: AVAudioChannelCount
    }

    struct ConverterFailureSnapshot {
        let occurrences: Int
        let status: OSStatus
        let inputSampleRate: Double
        let inputChannels: AVAudioChannelCount
        let timestamp: Date
    }

    private let logger: Logger
    private let config: Config

    // Converter reuse and serialization to avoid thread races
    private var audioConverter: AVAudioConverter?
    private var converterBuffer: AVAudioPCMBuffer?
    private let resampleQueue = DispatchQueue(label: "com.cliovoice.clio.audioProcessor.resample", qos: .userInitiated)
    private var converterFailureCount: Int = 0
    private var lastConverterFailure: (status: OSStatus, format: AVAudioFormat, timestamp: Date)?

    init(config: Config, logger: Logger) {
        self.config = config
        self.logger = logger
    }

    func process(buffer: AVAudioPCMBuffer) -> (data: Data, level: Double)? {
        let format = buffer.format
        // Fast path: 48kHz mono Float32 → 16kHz s16le via decimation
        if format.sampleRate == 48000 && format.commonFormat == .pcmFormatFloat32 {
            if format.channelCount == 1 {
                return decimate48000To16000(buffer)
            } else if format.channelCount == 2 {
                return decimateStereo48000To16000(buffer)
            }
        }
        // General path: resample to target Float32, then convert to s16le
        guard let resampled = resampleToTargetSync(buffer) else { return nil }
        return convertFloatBufferToPCMData(resampled)
    }

    // MARK: - Fast path decimator for 48k → 16k
    private func decimate48000To16000(_ buffer: AVAudioPCMBuffer) -> (data: Data, level: Double)? {
        guard let floatData = buffer.floatChannelData?[0] else { return nil }
        let frames = Int(buffer.frameLength)
        if frames == 0 { return nil }
        var pcm = Data()
        pcm.reserveCapacity((frames / 3) * 2)
        var peak: Float = 0
        var i = 0
        while i < frames {
            let s = floatData[i]
            peak = max(peak, abs(s))
            let clamped = max(-1.0, min(1.0, s))
            let int16 = Int16(clamped * 32767.0)
            var le = int16.littleEndian
            withUnsafeBytes(of: &le) { pcm.append(contentsOf: $0) }
            i += 3
        }
        let db = 20.0 * log10(Double(peak) + 1e-9)
        let minDb = -60.0, maxDb = 0.0
        let clampedDb = max(minDb, min(maxDb, db))
        let level = (clampedDb - minDb) / (maxDb - minDb)
        return (pcm, level)
    }

    private func decimateStereo48000To16000(_ buffer: AVAudioPCMBuffer) -> (data: Data, level: Double)? {
        guard let left = buffer.floatChannelData?[0], let right = buffer.floatChannelData?[1] else { return nil }
        let frames = Int(buffer.frameLength)
        if frames == 0 { return nil }
        var pcm = Data()
        pcm.reserveCapacity((frames / 3) * 2)
        var peak: Float = 0
        var i = 0
        while i < frames {
            let l = left[i]
            let r = right[i]
            let mixed = (l + r) * 0.5
            peak = max(peak, abs(mixed))
            let clamped = max(-1.0, min(1.0, mixed))
            let int16 = Int16(clamped * 32767.0)
            var le = int16.littleEndian
            withUnsafeBytes(of: &le) { pcm.append(contentsOf: $0) }
            i += 3
        }
        let db = 20.0 * log10(Double(peak) + 1e-9)
        let minDb = -60.0, maxDb = 0.0
        let clampedDb = max(minDb, min(maxDb, db))
        let level = (clampedDb - minDb) / (maxDb - minDb)
        return (pcm, level)
    }

    // MARK: - Resampling path
    private func ensureAudioConverter(for inputFormat: AVAudioFormat) {
        let targetFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32,
                                         sampleRate: config.targetSampleRate,
                                         channels: config.targetChannels,
                                         interleaved: false)!
        if audioConverter == nil || audioConverter?.inputFormat != inputFormat || audioConverter?.outputFormat != targetFormat {
            audioConverter = AVAudioConverter(from: inputFormat, to: targetFormat)
            converterBuffer = nil
            logger.debug("🔁 [AUDIO CONVERTER] Rebuilt converter input=(sr=\(Int(inputFormat.sampleRate)) ch=\(inputFormat.channelCount) fmt=\(inputFormat.commonFormat.rawValue)) → output=(sr=\(Int(targetFormat.sampleRate)) ch=\(targetFormat.channelCount) fmt=\(targetFormat.commonFormat.rawValue))")
        }
    }

    private func resampleToTargetSync(_ input: AVAudioPCMBuffer) -> AVAudioPCMBuffer? {
        if input.format.sampleRate == config.targetSampleRate &&
            input.format.channelCount == config.targetChannels &&
            input.format.commonFormat == .pcmFormatFloat32 {
            return input
        }
        return resampleQueue.sync {
            let targetFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32,
                                             sampleRate: config.targetSampleRate,
                                             channels: config.targetChannels,
                                             interleaved: false)!
            ensureAudioConverter(for: input.format)
            guard let converter = audioConverter else { return nil }
            let ratio = config.targetSampleRate / input.format.sampleRate
            let outFrames = AVAudioFrameCount(max(1, Int(Double(input.frameLength) * ratio) + 8))
            if converterBuffer == nil || converterBuffer?.frameCapacity != outFrames || converterBuffer?.format != targetFormat {
                converterBuffer = AVAudioPCMBuffer(pcmFormat: targetFormat, frameCapacity: outFrames)
            }
            guard let outBuffer = converterBuffer else { return nil }
            outBuffer.frameLength = outFrames
            var provided = false
        let status = converter.convert(to: outBuffer, error: nil) { _, outStatus -> AVAudioBuffer? in
            if provided {
                outStatus.pointee = .endOfStream
                return nil
            }
            provided = true
                outStatus.pointee = .haveData
                return input
            }
            switch status {
            case .haveData, .inputRanDry, .endOfStream:
                converterFailureCount = 0
                lastConverterFailure = nil
                return outBuffer
            default:
                let inFmt = input.format
                let statusValue = status.rawValue
                logger.error("❌ [AUDIO CONVERTER] convert status=\(statusValue) in(sr=\(Int(inFmt.sampleRate)) ch=\(inFmt.channelCount) fmt=\(inFmt.commonFormat.rawValue)) → out(sr=\(Int(targetFormat.sampleRate)) ch=\(targetFormat.channelCount) fmt=\(targetFormat.commonFormat.rawValue))")
                converterFailureCount += 1
                lastConverterFailure = (OSStatus(statusValue), inFmt, Date())
                return nil
            }
        }
    }

    private func convertFloatBufferToPCMData(_ buffer: AVAudioPCMBuffer) -> (Data, Double) {
        guard let floatChannelData = buffer.floatChannelData else {
            logger.warning("⚠️ No float channel data available")
            return (Data(), 0.0)
        }
        let frameLength = Int(buffer.frameLength)
        let channelCount = Int(buffer.format.channelCount)
        var pcmData = Data()
        pcmData.reserveCapacity(frameLength * channelCount * 2)
        var peak: Float = 0.0
        for frame in 0..<frameLength {
            let sample = floatChannelData[0][frame]
            peak = max(peak, abs(sample))
            let int16Sample = Int16(max(-32768, min(32767, sample * 32767.0)))
            var le = int16Sample.littleEndian
            withUnsafeBytes(of: &le) { bytes in
                pcmData.append(contentsOf: bytes)
            }
        }
        let db = 20.0 * log10(Double(peak) + 1e-9)
        let minVisibleDb = -60.0
        let maxVisibleDb = 0.0
        let clamped = max(minVisibleDb, min(maxVisibleDb, db))
        let audioLevel = (clamped - minVisibleDb) / (maxVisibleDb - minVisibleDb)
        return (pcmData, audioLevel)
    }

    func drainConverterFailureSnapshot() -> ConverterFailureSnapshot? {
        resampleQueue.sync {
            guard converterFailureCount > 0, let last = lastConverterFailure else { return nil }
            let snapshot = ConverterFailureSnapshot(
                occurrences: converterFailureCount,
                status: last.status,
                inputSampleRate: last.format.sampleRate,
                inputChannels: last.format.channelCount,
                timestamp: last.timestamp
            )
            converterFailureCount = 0
            lastConverterFailure = nil
            return snapshot
        }
    }

    func resetConverter() {
        resampleQueue.sync {
            audioConverter = nil
            converterBuffer = nil
            converterFailureCount = 0
            lastConverterFailure = nil
        }
    }
}
