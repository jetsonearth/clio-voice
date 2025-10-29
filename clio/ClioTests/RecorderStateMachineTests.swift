import XCTest
@testable import Clio

class RecorderStateMachineTests: XCTestCase {
    var testClock: TestClock!
    var stateMachine: RecorderStateMachine!
    
    override func setUp() async throws {
        try await super.setUp()
        testClock = TestClock()
        stateMachine = RecorderStateMachine(clock: testClock)
    }
    
    override func tearDown() async throws {
        stateMachine = nil
        testClock = nil
        try await super.tearDown()
    }
    
    // MARK: - Basic State Transitions
    
    func testInitialState() async {
        let state = await stateMachine.getCurrentState()
        XCTAssertEqual(state, .idle)
        
        let viewModel = await stateMachine.getViewModel()
        XCTAssertEqual(viewModel, RecorderViewModel.idle)
    }
    
    func testKeyDownShowsLightweightUI() async {
        let commands = await stateMachine.send(.keyDown)
        
        // Should show lightweight UI and schedule promotion
        XCTAssertTrue(commands.contains(.showLightweightUI))
        XCTAssertTrue(commands.contains(.playSound(.keyDown)))
        XCTAssertTrue(commands.contains { if case .schedulePromotion = $0 { return true }; return false })
        XCTAssertTrue(commands.contains { if case .updateUI = $0 { return true }; return false })
        
        let state = await stateMachine.getCurrentState()
        if case .lightweightShown = state {
            // Success
        } else {
            XCTFail("Expected lightweightShown state, got \(state)")
        }
        
        let viewModel = await stateMachine.getViewModel()
        XCTAssertTrue(viewModel.isAttemptingToRecord)
        XCTAssertTrue(viewModel.isVisualizerActive)
        XCTAssertFalse(viewModel.isRecording)
    }
    
    func testMisTouchDetection() async {
        // Key down
        _ = await stateMachine.send(.keyDown)
        
        // Key up before promotion (mis-touch)
        let commands = await stateMachine.send(.keyUp)
        
        // Should return to idle and schedule hide
        let state = await stateMachine.getCurrentState()
        XCTAssertEqual(state, .idle)
        
        let viewModel = await stateMachine.getViewModel()
        XCTAssertEqual(viewModel, RecorderViewModel.idle)

        // Should include keyUp sound on mis-touch
        XCTAssertTrue(commands.contains(.playSound(.keyUp)))
    }
    
    func testPTTPromotion() async {
        // Key down
        _ = await stateMachine.send(.keyDown)
        
        // Wait for promotion timeout
        testClock.advance(by: 0.3)
        let commands = await stateMachine.send(.promotionTimeout)
        
        // Should start PTT recording
        XCTAssertTrue(commands.contains(.startRecording(mode: .ptt)))
        XCTAssertTrue(commands.contains { if case .updateUI = $0 { return true }; return false })
        
        let state = await stateMachine.getCurrentState()
        if case .pttActive = state {
            // Success
        } else {
            XCTFail("Expected pttActive state, got \(state)")
        }
        
        let viewModel = await stateMachine.getViewModel()
        XCTAssertTrue(viewModel.isRecording)
        XCTAssertFalse(viewModel.isHandsFreeLocked)
        XCTAssertFalse(viewModel.isAttemptingToRecord)
    }
    
    func testPTTRelease() async {
        // Setup PTT recording
        _ = await stateMachine.send(.keyDown)
        testClock.advance(by: 0.3)
        _ = await stateMachine.send(.promotionTimeout)
        
        // Release key
        let commands = await stateMachine.send(.keyUp)
        
        // Should stop recording
        XCTAssertTrue(commands.contains(.stopRecording))
        XCTAssertTrue(commands.contains(.playSound(.keyUp)))
        
        let state = await stateMachine.getCurrentState()
        XCTAssertEqual(state, .stopping)
        
        // Complete recording
        let completeCommands = await stateMachine.send(.recordingComplete)
        XCTAssertTrue(completeCommands.contains(.hideUI))
        
        let finalState = await stateMachine.getCurrentState()
        XCTAssertEqual(finalState, .idle)
    }
    
    func testDoubleTapHandsFree() async {
        let startTime = testClock.now()
        
        // First tap
        _ = await stateMachine.send(.keyDown)
        
        // Second tap within double-tap window
        testClock.advance(by: 0.2) // 200ms - within 400ms window
        let commands = await stateMachine.send(.keyDown)
        
        // Should enter hands-free mode
        XCTAssertTrue(commands.contains(.cancelTimers))
        XCTAssertTrue(commands.contains(.startRecording(mode: .handsFreeLocked)))
        XCTAssertTrue(commands.contains(.playSound(.lock)))
        
        let state = await stateMachine.getCurrentState()
        if case .handsFreeLocked = state {
            // Success
        } else {
            XCTFail("Expected handsFreeLocked state, got \(state)")
        }
        
        let viewModel = await stateMachine.getViewModel()
        XCTAssertTrue(viewModel.isRecording)
        XCTAssertTrue(viewModel.isHandsFreeLocked)
    }
    
    func testHandsFreeStop() async {
        // Setup hands-free recording
        _ = await stateMachine.send(.keyDown)
        testClock.advance(by: 0.2)
        _ = await stateMachine.send(.keyDown)
        
        // Key press to stop hands-free
        let commands = await stateMachine.send(.keyDown)
        
        // Should stop recording
        XCTAssertTrue(commands.contains(.stopRecording))
        XCTAssertTrue(commands.contains(.playSound(.keyUp)))
        
        let state = await stateMachine.getCurrentState()
        XCTAssertEqual(state, .stopping)
    }
    
    func testUserCancellation() async {
        // Start recording
        _ = await stateMachine.send(.keyDown)
        testClock.advance(by: 0.3)
        _ = await stateMachine.send(.promotionTimeout)
        
        // User cancels
        let commands = await stateMachine.send(.userCancelled)
        
        // Should enter stopping, issue stopRecording and play cancel sound
        XCTAssertTrue(commands.contains(.cancelTimers))
        XCTAssertTrue(commands.contains(.stopRecording))
        XCTAssertTrue(commands.contains(.playSound(.cancel)))
        
        let state = await stateMachine.getCurrentState()
        XCTAssertEqual(state, .stopping)
        
        // Complete recording → hide UI and return to idle
        let complete = await stateMachine.send(.recordingComplete)
        XCTAssertTrue(complete.contains(.hideUI))
        let final = await stateMachine.getCurrentState()
        XCTAssertEqual(final, .idle)
    }

    func testLightweightCancelImmediateHideNoCancelSound() async {
        // Show lightweight
        _ = await stateMachine.send(.keyDown)
        
        // Cancel while lightweight is showing
        let commands = await stateMachine.send(.userCancelled)
        
        // Should hide immediately, no cancel sound, return to idle
        XCTAssertTrue(commands.contains(.hideUI))
        XCTAssertFalse(commands.contains(.playSound(.cancel)))
        let state = await stateMachine.getCurrentState()
        XCTAssertEqual(state, .idle)
    }
    
    // MARK: - Timing Edge Cases
    
    func testDoubleTapOutsideWindow() async {
        // First tap
        _ = await stateMachine.send(.keyDown)
        
        // Second tap outside double-tap window
        testClock.advance(by: 0.5) // 500ms - outside 400ms window
        let commands = await stateMachine.send(.keyDown)
        
        // Should NOT enter hands-free mode, should stay in lightweight
        XCTAssertFalse(commands.contains(.startRecording(mode: .handsFreeLocked)))
        
        let state = await stateMachine.getCurrentState()
        if case .lightweightShown = state {
            // Success - still in lightweight mode
        } else {
            XCTFail("Expected to stay in lightweightShown state, got \(state)")
        }
    }
    
    func testRapidKeyPresses() async {
        // Rapid key down/up/down sequence
        _ = await stateMachine.send(.keyDown)
        _ = await stateMachine.send(.keyUp) // mis-touch
        
        let state1 = await stateMachine.getCurrentState()
        XCTAssertEqual(state1, .idle)
        
        // Immediate second press
        let commands = await stateMachine.send(.keyDown)
        XCTAssertTrue(commands.contains(.showLightweightUI))
        
        let state2 = await stateMachine.getCurrentState()
        if case .lightweightShown = state2 {
            // Success
        } else {
            XCTFail("Expected lightweightShown state after rapid sequence, got \(state2)")
        }
    }
    
    // MARK: - Performance Tests
    
    func testStateTransitionPerformance() async {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Perform multiple rapid state transitions
        for _ in 0..<1000 {
            _ = await stateMachine.send(.keyDown)
            _ = await stateMachine.send(.keyUp)
        }
        
        let duration = CFAbsoluteTimeGetCurrent() - startTime
        XCTAssertLessThan(duration, 0.1, "1000 state transitions should complete in <100ms")
    }
}