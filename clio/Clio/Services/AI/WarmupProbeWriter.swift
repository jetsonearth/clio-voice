import Foundation

/// Diagnostic utility for capturing and writing warmup audio probes to WAV files
/// Used for debugging audio capture issues during system warmup periods
struct WarmupProbeWriter {
    private let sampleRate: Double
    private var pcm = Data()
    
    init(targetSampleRate: Double) {
        self.sampleRate = targetSampleRate
    }
    
    mutating func append(pcm data: Data) {
        pcm.append(data)
    }
    
    mutating func finalizeToWav(path: String) -> URL? {
        let url = URL(fileURLWithPath: path)
        do {
            // Write simple WAV header with mono 16-bit PCM at target SR
            let actualSampleRate = UInt32(sampleRate)
            let actualChannels: UInt16 = 1
            let bitsPerSample: UInt16 = 16
            let byteRate = actualSampleRate * UInt32(actualChannels) * UInt32(bitsPerSample) / 8
            let blockAlign = actualChannels * bitsPerSample / 8
            let pcmLength = pcm.count
            let fileLength = pcmLength + 44
            var wav = Data()
            wav.append("RIFF".data(using: .ascii)!)
            wav.append(withUnsafeBytes(of: UInt32(fileLength - 8).littleEndian) { Data($0) })
            wav.append("WAVE".data(using: .ascii)!)
            wav.append("fmt ".data(using: .ascii)!)
            wav.append(withUnsafeBytes(of: UInt32(16).littleEndian) { Data($0) })
            wav.append(withUnsafeBytes(of: UInt16(1).littleEndian) { Data($0) })
            wav.append(withUnsafeBytes(of: actualChannels.littleEndian) { Data($0) })
            wav.append(withUnsafeBytes(of: actualSampleRate.littleEndian) { Data($0) })
            wav.append(withUnsafeBytes(of: byteRate.littleEndian) { Data($0) })
            wav.append(withUnsafeBytes(of: blockAlign.littleEndian) { Data($0) })
            wav.append(withUnsafeBytes(of: bitsPerSample.littleEndian) { Data($0) })
            wav.append("data".data(using: .ascii)!)
            wav.append(withUnsafeBytes(of: UInt32(pcmLength).littleEndian) { Data($0) })
            wav.append(pcm)
            try wav.write(to: url, options: .atomic)
            return url
        } catch {
            return nil
        }
    }
}