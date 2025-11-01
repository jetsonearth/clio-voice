import Foundation

#if canImport(ten_vad)

final class TenVADDetector {
    typealias SpeechHandler = () -> Void
    typealias ProbabilityHandler = (Float) -> Void

    var onSpeechStart: SpeechHandler?
    var onSpeechEnd: SpeechHandler?
    var onProbability: ProbabilityHandler?

    private let hopSize: Int
    private let threshold: Float

    private var handle: ten_vad_handle_t?
    private var pending = Data()
    private var lastFlag: Int32 = 0
    private let queue = DispatchQueue(label: "com.cliovoice.clio.tenvad")
    private let queueKey = DispatchSpecificKey<UInt8>()

    init?(threshold: Float = 0.5, hopSize: Int = 256) {
        self.threshold = threshold
        self.hopSize = hopSize
        var h: ten_vad_handle_t? = nil
        let rc = ten_vad_create(&h, size_t(hopSize), threshold)
        guard rc == 0, h != nil else { return nil }
        self.handle = h
        queue.setSpecific(key: queueKey, value: 1)
    }

    deinit {
        if DispatchQueue.getSpecific(key: queueKey) != nil {
            if handle != nil {
                var h: ten_vad_handle_t? = handle
                _ = ten_vad_destroy(&h)
                handle = nil
            }
            pending.removeAll(keepingCapacity: false)
        } else {
            queue.sync {
                if handle != nil {
                    var h: ten_vad_handle_t? = handle
                    _ = ten_vad_destroy(&h)
                    handle = nil
                }
                pending.removeAll(keepingCapacity: false)
            }
        }
    }

    func isVoicing() -> Bool {
        if DispatchQueue.getSpecific(key: queueKey) != nil {
            return lastFlag == 1
        }
        var active = false
        queue.sync { active = (lastFlag == 1) }
        return active
    }

    func reset() {
        if DispatchQueue.getSpecific(key: queueKey) != nil {
            pending.removeAll(keepingCapacity: true)
            lastFlag = 0
            return
        }
        queue.sync {
            pending.removeAll(keepingCapacity: true)
            lastFlag = 0
        }
    }

    func process(pcm16: Data) {
        queue.async {
            guard let h = self.handle else { return }
            self.pending.append(pcm16)
            let frameBytes = self.hopSize * MemoryLayout<Int16>.size
            while self.pending.count >= frameBytes {
                let frame = self.pending.prefix(frameBytes)
                self.pending.removeFirst(frameBytes)

                var prob: Float = 0
                var flag: Int32 = 0
                frame.withUnsafeBytes { rawBuf in
                    let ptr = rawBuf.bindMemory(to: Int16.self).baseAddress!
                    _ = ten_vad_process(h, ptr, size_t(self.hopSize), &prob, &flag)
                }
                self.onProbability?(prob)

                if self.lastFlag == 0 && flag == 1 {
                    self.onSpeechStart?()
                }
                if self.lastFlag == 1 && flag == 0 {
                    self.onSpeechEnd?()
                }
                self.lastFlag = flag
            }
        }
    }
}

#else

final class TenVADDetector {
    typealias SpeechHandler = () -> Void
    typealias ProbabilityHandler = (Float) -> Void

    var onSpeechStart: SpeechHandler?
    var onSpeechEnd: SpeechHandler?
    var onProbability: ProbabilityHandler?

    init?(threshold: Float = 0.5, hopSize: Int = 256) {
        return nil
    }

    func isVoicing() -> Bool { false }
    func reset() {}
    func process(pcm16: Data) {}
}

#endif
