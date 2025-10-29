import Foundation

// Thread-safe store for pre-roll audio packets captured before the WebSocket is ready.
// Using an actor guarantees serialized access and removes data races on the backing array.
actor PrebufferStore {
    private var packets: [Data] = []

    func append(_ data: Data) {
        packets.append(data)
    }

    func appendMany(_ items: [Data]) {
        guard !items.isEmpty else { return }
        packets.append(contentsOf: items)
    }

    // Returns a snapshot and clears the buffer (FIFO order preserved)
    func popAll() -> [Data] {
        let out = packets
        packets.removeAll()
        return out
    }

    func clear() {
        packets.removeAll()
    }

    func isEmpty() -> Bool { packets.isEmpty }

    func count() -> Int { packets.count }

    func totalBytes() -> Int {
        packets.reduce(0) { $0 + $1.count }
    }

    // Snapshot without clearing
    func copy() -> [Data] { packets }
}
