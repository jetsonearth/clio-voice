# CRITICAL BUG: WebSocket connection continuation leak and concurrent connects

## Summary
- Severity: 🔴 CRITICAL
- Components: `SonioxStreamingService.swift` (WebSocket lifecycle), task continuations
- Impact: Race conditions during connect cause repeated reconnects, dangling tasks, and unstable state. Correlates with missing early audio and inconsistent buffer flush.

## Evidence (logs)
- Continuation misuse:
```
SWIFT TASK CONTINUATION MISUSE: connectWebSocket() leaked its continuation without resuming it.
```
- Overlapping lifecycle:
```
🔌 WebSocket did open
❌ WebSocket receive error: Socket is not connected
⚠️ WebSocket did close with code 1000
```
- Multiple "did open" events per session with buffered durations ranging 3–21s.

## Root-cause hypothesis
- `connectionReadinessTask` not resumed on all paths (success, error, timeout, cancel).
- Duplicate `connectWebSocket()` calls; duplicate `didOpen` not deduped.
- Recovery (device-change/tap refresh) racing with connect startup.

## Scope to inspect
- `SonioxStreamingService.swift`
  - `connectWebSocket()` and `withCheckedThrowingContinuation`
  - `urlSession(_:webSocketTask:didOpenWithProtocol:)`
  - `urlSession(_:webSocketTask:didCloseWith:reason:)`
  - Connect retry guards (single-flight) and cancellation
  - Recovery entry points during connect

## Acceptance criteria (QA)
- Only one connect attempt in-flight per session (log attempt-id).
- Continuation resumed exactly once; no continuation misuse warnings.
- Duplicate `didOpen` ignored; no concurrent sockets.
- On failure, waiters get error within ≤10s.

## Reproduction
1. Fresh launch or >10 min idle.
2. Start recording on high-latency/VPN.
3. Observe multiple `did open`, continuation warnings, early transcript gaps.

## Fix direction
- Single-flight connect with stored `connectTask`.
- Always resume continuation (success/error/timeout/cancel); then nil it.
- Ignore duplicate `didOpen` if already ready; log and return.
- Gate recovery so it cannot preempt connect sequencing.

## Test plan
- Slow network: single connect; no continuation warnings.
- Force close mid-connect: continuation resumes with error.
- Warm path: no deadlocks; quick readiness.

---
Status: ✅ RESOLVED | Owner: Audio/Realtime

## Implementation notes
- Added `isConnecting` guard; late `didOpen` ignored after stop.
- Recovery gated while connecting.

## Validation (client logs)
- Single connect and single `didOpen`; no continuation misuse warnings.
- Example:
```
🔌 WebSocket did open
🔌 WebSocket ready after 1458–1608ms - buffered 0–1.6s of audio
✅ Buffer flush complete
```
- Late `didOpen` after stop no longer triggers finalize; stale sockets cancelled.
