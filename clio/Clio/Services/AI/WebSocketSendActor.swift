import Foundation
import os

/// Serializes WebSocket `send` operations so that audio packets are always delivered in FIFO order.
/// Both buffered-flush tasks and real-time audio taps should call the actor instead of
/// invoking `URLSessionWebSocketTask.send(_:)` directly.
/// 
/// ENHANCED: Now ensures TRUE sequential transmission with confirmation before sending next packet
actor WebSocketSendActor {
private let logger = Logger(subsystem: "com.cliovoice.clio", category: "WebSocketSendActor")
    private var socket: URLSessionWebSocketTask?
    
    // Packet sequence tracking for debugging
    private var sequenceNumber: UInt64 = 0
    private var lastSendTime: Date?
    
    // Send queue to ensure true FIFO even at network level
    private var sendQueue: [(data: Data?, string: String?, sequence: UInt64)] = []
    private var isSending = false
    
    // Pause flag to stop processing during recovery
    private var isPaused = false
    
    // Delegate-style callback for send failures that likely require reconnect
    // Use a string payload to keep it Sendable/safe across isolation boundaries
    private var onSendFailureHandler: ((String) -> Void)? = nil
    
    /// Replace the underlying socket (e.g. after reconnect).
    /// Behavior change: when binding a NEW socket, we keep the queue but force a paused state.
    /// The caller must enqueue the start text first (via sendStartFirst) and then resumeQueue().
    func setSocket(_ socket: URLSessionWebSocketTask?) {
        self.socket = socket
        if socket == nil {
            // Pause but DO NOT clear the queue — preserve for replay after reconnect
            isPaused = true
            isSending = false
            // Keep sequenceNumber to preserve ordering across reconnects
        } else {
            // New socket bound: stay paused until start/config text is queued first
            isPaused = true
            isSending = false
        }
    }

    /// Insert a start/config text frame at the FRONT of the queue so it is the first
    /// thing sent on a freshly bound socket before any buffered audio frames.
    func sendStartFirst(_ string: String) async {
        let seq = sequenceNumber
        sequenceNumber += 1
        sendQueue.insert((data: nil, string: string, sequence: seq), at: 0)
    }
    
    /// Install a handler to be notified on send failures.
    func setOnSendFailure(_ handler: @escaping (String) -> Void) {
        self.onSendFailureHandler = handler
    }
    
    /// Explicitly pause the queue (e.g. while reconnecting)
    func pauseQueue() {
        isPaused = true
    }
    
    /// Resume processing after recovery
    func resumeQueue() async {
        isPaused = false
        await processQueue()
    }
    
    /// Send binary data in FIFO order with TRUE sequential guarantee
    func send(_ data: Data) async {
        let seq = sequenceNumber
        sequenceNumber += 1
        
        // Add to queue
        sendQueue.append((data: data, string: nil, sequence: seq))
        
        // Process queue if not already processing
        await processQueue()
    }
    
    /// Convenience for string frames (config / control messages).
    func send(_ string: String) async {
        let seq = sequenceNumber
        sequenceNumber += 1
        
        // Add to queue
        sendQueue.append((data: nil, string: string, sequence: seq))
        
        // Process queue if not already processing
        await processQueue()
    }
    
    /// Process the send queue sequentially - ensures network-level ordering
    private func processQueue() async {
        guard !isSending, !isPaused, let socket = socket else { return }
// Backpressure notice when queue exceeds a threshold
        if sendQueue.count > 500 {
StructuredLog.shared.log(cat: .stream, evt: "backpressure", lvl: .warn, ["queue": sendQueue.count])
        }
        
        isSending = true
        defer { isSending = false }
        
        while !sendQueue.isEmpty {
            if isPaused { return }
            let item = sendQueue.removeFirst()
            
            // Log packet timing for debugging
            let now = Date()
            if let lastTime = lastSendTime {
                let delta = now.timeIntervalSince(lastTime) * 1000 // ms
                if delta < 1.0 { // Sub-millisecond sends might cause reordering
                    // logger.debug("⚡ RAPID SEND: seq=\(item.sequence) delta=\(String(format: "%.2f", delta))ms")
                }
            }
            lastSendTime = now
            
            do {
                if let data = item.data {
                    // Only log every 100th packet to reduce noise
                    if item.sequence == 0 || item.sequence % 100 == 0 {
                        // logger.debug("📤 Sending audio packet seq=\(item.sequence) size=\(data.count)")
                    }
                    try await socket.send(.data(data))
                } else if let string = item.string {
                    logger.debug("📤 Sending text frame seq=\(item.sequence)")
                    try await socket.send(.string(string))
                }
                
                // CRITICAL: Proper pacing to prevent WebSocket backpressure
                // Buffer flush needs more spacing than live audio (which is naturally paced)
                if !sendQueue.isEmpty {
                    // Use longer delay for buffer flush to prevent overloading WebSocket
                    let isBufferFlush = sendQueue.count > 10 // Assume buffer flush if many packets queued
                    let delay = isBufferFlush ? 5_000_000 : 1_000_000 // 5ms for buffer, 1ms for live
                    try await Task.sleep(nanoseconds: UInt64(delay))
                }
                
            } catch {
                // Special-case cancellation to avoid noisy spam during reconnects
                if (error is CancellationError) || error.localizedDescription.lowercased().contains("cancel") {
                    // Preserve the packet and pause; recovery flow will handle reconnect and resume
                    sendQueue.insert(item, at: 0)
                    logger.debug("⏹️ Send cancelled — pausing queue (seq=\(item.sequence), queue_len=\(self.sendQueue.count))")
                    isPaused = true
                    return
                }
                logger.error("❌ Failed to send frame seq=\(item.sequence): \(error.localizedDescription)")
                StructuredLog.shared.log(cat: .stream, evt: "error", lvl: .err, ["phase": "send", "seq": Int(item.sequence)])
                
                // Notify service to recover if socket likely dead
                let msg = error.localizedDescription.lowercased()
                if msg.contains("socket is not connected") || msg.contains("broken pipe") || msg.contains("connection reset") {
                    // Re-queue the failed packet at the FRONT to guarantee replay after reconnect
                    sendQueue.insert(item, at: 0)
                    logger.error("🚑 Re-queueing failed packet seq=\(item.sequence) requeue=true queue_len=\(self.sendQueue.count)")
                    // Pause queue and request recovery
                    isPaused = true
                    Task { [handler = onSendFailureHandler] in
                        handler?(error.localizedDescription)
                    }
                    // Stop processing now; service will resume after reconnect
                    return
                }
                
// Otherwise, don't drop the entire queue on single failure
                if sendQueue.count > 5000 {
                    // Only clear queue if it's getting too large (prevent memory issues)
                    logger.error("🚨 QUEUE OVERFLOW: Clearing \(self.sendQueue.count) packets due to excessive buildup")
                    sendQueue.removeAll()
                    break
                } else {
                    // Re-queue non-fatal failure once to try again; if it keeps failing, the condition above will kick in
                    sendQueue.insert(item, at: 0)
                    logger.warning("⚠️ Transient send error — requeue=true seq=\(item.sequence) queue_len=\(self.sendQueue.count)")
                    // Small backoff to avoid tight loop on repeatable errors
                    try? await Task.sleep(nanoseconds: 5_000_000)
                    continue
                }
            }
        }
    }
    
    /// Get current queue depth for monitoring
    func getQueueDepth() -> Int {
        return sendQueue.count
    }
    
    /// Get current sequence number for debugging
    func getCurrentSequence() -> UInt64 {
        return sequenceNumber
    }
    
    /// Reset sequence number for new session on reused socket
    func resetSequenceForNewSession() {
        sequenceNumber = 0
        logger.debug("🔄 [SEQUENCE-RESET] Reset sequence to 0 for new session on reused socket")
    }
    
    /// Wait until queue is drained (empty and not sending). Returns true if drained within timeout.
    func waitUntilDrained(timeoutMs: Int) async -> Bool {
        let deadline = Date().addingTimeInterval(Double(timeoutMs) / 1000.0)
        while Date() < deadline {
            if sendQueue.isEmpty && !isSending { return true }
            // If paused, we can't drain; wait briefly and continue
            try? await Task.sleep(nanoseconds: 20_000_000) // 20ms
        }
        return sendQueue.isEmpty && !isSending
    }

    /// Milliseconds since the last successful send, if any
    func millisSinceLastSend() -> Int? {
        guard let last = lastSendTime else { return nil }
        return Int(Date().timeIntervalSince(last) * 1000)
    }
}
