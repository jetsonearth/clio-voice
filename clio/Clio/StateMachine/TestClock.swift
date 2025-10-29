import Foundation

/// Test clock for deterministic virtual-time testing
class TestClock: ClockProtocol {
    private var currentTime: Date
    private var pendingSleeps: [(Date, CheckedContinuation<Void, Error>)] = []
    
    init(startTime: Date = Date()) {
        self.currentTime = startTime
    }
    
    func now() -> Date {
        return currentTime
    }
    
    func sleep(for duration: TimeInterval) async throws {
        let wakeTime = currentTime.addingTimeInterval(duration)
        
        return try await withCheckedThrowingContinuation { continuation in
            pendingSleeps.append((wakeTime, continuation))
            pendingSleeps.sort { $0.0 < $1.0 }
        }
    }
    
    /// Advance time and resume any completed sleeps
    func advance(by duration: TimeInterval) {
        currentTime = currentTime.addingTimeInterval(duration)
        
        // Resume any sleeps that have completed
        var completedSleeps: [CheckedContinuation<Void, Error>] = []
        pendingSleeps.removeAll { wakeTime, continuation in
            if wakeTime <= currentTime {
                completedSleeps.append(continuation)
                return true
            }
            return false
        }
        
        // Resume completed sleeps
        for continuation in completedSleeps {
            continuation.resume()
        }
    }
    
    /// Set absolute time
    func setTime(_ time: Date) {
        let duration = time.timeIntervalSince(currentTime)
        advance(by: duration)
    }
    
    /// Check if there are pending sleeps
    func hasPendingSleeps() -> Bool {
        return !pendingSleeps.isEmpty
    }
    
    /// Get next wake time
    func nextWakeTime() -> Date? {
        return pendingSleeps.first?.0
    }
}
