# RecorderStateMachine Migration Plan

## Executive Summary

This document outlines the migration from the current distributed state management architecture (4 independent state machines) to a single, deterministic `RecorderStateMachine` to eliminate race conditions and non-deterministic behavior in F5 key interactions.

**Expert Validation**: Both o3 (8/10 confidence) and Gemini 2.5 Pro (9/10 confidence) strongly validate this approach as industry best practice, similar to PTT controllers in real-time communication apps.

## Problem Analysis

### Current Architecture Issues
1. **Distributed State**: 4 independent state machines trying to coordinate single F5 interaction
   - `HotkeyManager`: F5 event capture and routing
   - `InputGate`: Timing coordination (PTT/double-tap/mis-touch detection)
   - `WhisperState`: Main recording state with 30+ @Published properties
   - `WhisperState+UI`: UI management with Intent-based API

2. **Root Cause of Race Conditions**:
   - State duplication: `started/isRecording`, `handsFreeLocked/isHandsFreeLocked`
   - Async coordination overhead: `await MainActor.run { Task { await ... } }`
   - UI update storms from 30+ @Published properties
   - Multiple timing windows where state can diverge during async transitions

3. **Specific Failure Modes**:
   - Hands-free stop race: `reset()` clears `suppressNextKeyUp` before setting it
   - Temporal coupling: `dismissRecorder()` resets UI, but delayed progress updates retrigger showing
   - Non-deterministic behavior despite "deterministic rules and single source of truth"

## Proposed Solution: Single RecorderStateMachine

### Architecture Overview
```swift
actor RecorderStateMachine {
    enum State {
        case idle
        case lightweightShown(since: Date)
        case pttActive(since: Date) 
        case handsFreeLocked(since: Date)
        case stopping
    }
    
    enum Event {
        case keyDown
        case keyUp
        case promotionTimeout
        case recordingComplete
        case audioLevelExceeded
        case userCancelled
    }
    
    enum Command {
        case showLightweightUI
        case startRecording(mode: RecorderMode)
        case stopRecording
        case hideUI
        case playSound(SoundType)
        case updateUI(RecorderViewModel)
    }
    
    func handle(_ event: Event) async -> [Command] {
        // Deterministic state transitions
        // Returns commands to execute (show UI, start recording, etc.)
    }
}
```

### Key Benefits
- **Eliminates Race Conditions**: Atomic state transitions through Swift actor isolation
- **Single Source of Truth**: All F5 interaction state in one place
- **Testable**: Virtual-time unit tests for deterministic behavior validation
- **Performant**: Eliminates async coordination overhead and UI update storms
- **Maintainable**: All logic centralized, easier to reason about and debug

## Migration Strategy

### Phase 1: Foundation (Week 1)
**Goal**: Create state machine skeleton and prove the pattern works

#### Step 1.1: Create Core State Machine
- [ ] Create `RecorderStateMachine.swift` with State/Event/Command enums
- [ ] Implement basic `handle(_:)` function with idle → recording → stopping loop
- [ ] Add `RecorderViewModel` struct to replace distributed @Published properties

#### Step 1.2: Prove Pattern with Single Path
- [ ] Replace one InputGate → WhisperState call with RecorderStateMachine event
- [ ] Choose simplest path: F5 down → PTT recording → F5 up → stop
- [ ] Verify existing behavior is maintained

#### Step 1.3: Add Virtual-Time Testing
- [ ] Create `TestClock` protocol for dependency injection
- [ ] Write first unit test: `idle → keyDown → promotionTimeout → pttActive`
- [ ] Validate deterministic state transitions

**Success Criteria**: One complete F5 interaction path works through state machine with passing unit test

### Phase 2: Migration (Week 2-3)
**Goal**: Gradually migrate all InputGate logic while maintaining behavior

#### Step 2.1: Migrate Timing Logic
- [ ] Move promotion windows (PTT, double-tap) into RecorderStateMachine
- [ ] Replace InputGate timers with state machine events
- [ ] Implement mis-touch detection in state machine

#### Step 2.2: Migrate Complex Interactions
- [ ] Double-tap hands-free logic
- [ ] Hands-free stop behavior
- [ ] Cooldown and debounce mechanisms

#### Step 2.3: Consolidate UI State
- [ ] Replace 30+ @Published properties with single `@Published var viewModel: RecorderViewModel`
- [ ] Update SwiftUI views to bind to consolidated view model
- [ ] Measure UI update performance improvement

**Success Criteria**: All F5 interactions work through state machine, UI updates reduced by 80%+

### Phase 3: Cleanup (Week 4)
**Goal**: Remove distributed components and optimize

#### Step 3.1: Remove State Duplication
- [ ] Delete timing logic from InputGate
- [ ] Remove redundant @Published properties from WhisperState
- [ ] InputGate becomes simple event forwarder

#### Step 3.2: Comprehensive Testing
- [ ] Add unit tests for all state transitions
- [ ] Test edge cases: rapid key presses, timing boundary conditions
- [ ] Performance testing: ensure <2ms for audio callbacks

#### Step 3.3: Final Cleanup
- [ ] Consider removing InputGate entirely (or keep as thin wrapper)
- [ ] Documentation and code comments
- [ ] Performance monitoring and logging

**Success Criteria**: Simplified architecture, comprehensive test coverage, improved performance

## Implementation Details

### State Machine Design

#### State Transitions
```
idle → [keyDown] → lightweightShown
lightweightShown → [promotionTimeout] → pttActive
lightweightShown → [keyUp] → idle (mis-touch)
lightweightShown → [keyDown] → handsFreeLocked (double-tap)
pttActive → [keyUp] → stopping → idle
handsFreeLocked → [keyDown] → stopping → idle
stopping → [recordingComplete] → idle
```

#### Command Execution
Commands must be executed **after** state transition to maintain atomicity:
```swift
func handle(_ event: Event) async -> [Command] {
    let (newState, commands) = transition(from: currentState, event: event)
    currentState = newState
    return commands
}
```

#### UI Update Strategy
Single consolidated view model eliminates update storms:
```swift
struct RecorderViewModel {
    let isRecording: Bool
    let isHandsFreeLocked: Bool
    let sessionState: SessionState
    let isVisualizerActive: Bool
    // ... other derived properties
}
```

### Critical Implementation Rules

#### 1. ALL External Interactions Must Use Events
```swift
// ✅ Correct: External systems send events
await recorderStateMachine.send(.keyDown)

// ❌ Wrong: Direct state access creates back-door races
recorderStateMachine.currentState = .recording
```

#### 2. Commands Must Be Awaited in Order
```swift
// ✅ Correct: Wait for completion before next event
for command in commands {
    await execute(command)
}

// ❌ Wrong: Parallel execution can create logical races
Task {
    for command in commands {
        await execute(command)
    }
}
```

#### 3. Heavy Audio Processing Stays Off-Actor
```swift
// ✅ Correct: Audio processing on background queue
audioProcessor.onLevelChange = { level in
    if level > threshold {
        Task { await stateMachine.send(.audioLevelExceeded) }
    }
}
```

### Testing Strategy

#### Virtual-Time Unit Tests
```swift
func testDoubleTapHandsFree() async {
    let clock = TestClock()
    let stateMachine = RecorderStateMachine(clock: clock)
    
    // First tap
    let commands1 = await stateMachine.handle(.keyDown)
    XCTAssertEqual(commands1, [.showLightweightUI])
    
    // Second tap within window
    clock.advance(by: .milliseconds(200))
    let commands2 = await stateMachine.handle(.keyDown)
    XCTAssertEqual(commands2, [.startRecording(.handsFreeLocked), .playSound(.lock)])
    
    // Verify state
    XCTAssertEqual(stateMachine.currentState, .handsFreeLocked)
}
```

#### Performance Tests
```swift
func testAudioCallbackPerformance() async {
    // Ensure state machine responds to audio events in <2ms
    let startTime = CFAbsoluteTimeGetCurrent()
    await stateMachine.send(.audioLevelExceeded)
    let duration = CFAbsoluteTimeGetCurrent() - startTime
    XCTAssertLessThan(duration, 0.002) // 2ms threshold
}
```

## Risk Assessment & Mitigation

### High-Risk Areas

#### 1. Command Execution Ordering
**Risk**: Parallel command execution creates logical races
**Mitigation**: Await command completion before processing next event

#### 2. Back-Door State Access
**Risk**: External systems bypass event system, reintroduce races
**Mitigation**: Make state machine internal state private, only expose events

#### 3. State Enum Growth
**Risk**: Single enum becomes unwieldy as features grow
**Mitigation**: Monitor enum size, split into hierarchical sub-FSMs at 15+ states

#### 4. Migration Complexity
**Risk**: Refactoring 4 components simultaneously introduces bugs
**Mitigation**: Incremental migration, maintain existing behavior at each step

### Medium-Risk Areas

#### 1. Performance Regression
**Risk**: Single actor becomes bottleneck
**Mitigation**: Performance testing, keep heavy audio processing off-actor

#### 2. Test Coverage Gaps
**Risk**: Complex timing interactions not covered by tests
**Mitigation**: Comprehensive test matrix for all state/event combinations

## Success Metrics

### Functional Metrics
- [ ] Zero race conditions in F5 key interactions
- [ ] Deterministic behavior in all timing scenarios
- [ ] Maintained existing UX (PTT, double-tap, mis-touch detection)

### Performance Metrics
- [ ] UI update frequency reduced by 80%+ (from 30+ properties to 1)
- [ ] Audio callback response time <2ms
- [ ] State transition latency <1ms

### Quality Metrics
- [ ] 100% test coverage for state transitions
- [ ] Virtual-time tests for all timing scenarios
- [ ] Simplified architecture: 4 components → 1 state machine

## Dependencies & Prerequisites

### Technical Dependencies
- Swift 5.9+ with actor support
- Existing SwiftUI reactive UI framework
- Current async/await architecture

### Team Dependencies
- Code review for state machine design
- QA testing for behavior regression
- User testing for UX validation

## Timeline

| Week | Phase | Deliverables |
|------|-------|--------------|
| 1 | Foundation | Core state machine, first working path, initial tests |
| 2-3 | Migration | All logic migrated, UI consolidated, comprehensive testing |
| 4 | Cleanup | Simplified architecture, documentation, performance optimization |

## Conclusion

The RecorderStateMachine migration represents a fundamental architectural improvement that directly addresses the root cause of race conditions in the current system. With strong expert validation (8-9/10 confidence from o3 and Gemini 2.5 Pro) and a proven pattern used in real-time communication apps, this approach provides:

1. **Immediate Benefits**: Elimination of race conditions and non-deterministic behavior
2. **Long-term Value**: Simplified maintenance, easier testing, better performance
3. **User Impact**: Reliable, predictable F5 key interactions

The incremental migration strategy minimizes risk while ensuring continuous functionality throughout the transition.