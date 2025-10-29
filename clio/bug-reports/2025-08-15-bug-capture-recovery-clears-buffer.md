# HIGH BUG: Capture recovery during connect resets buffer/state

## Summary
- Severity: 🔴 HIGH
- Components: Audio engine restart paths, tap refresh, device-change handling
- Impact: While WS is connecting, capture recovery reinstalls tap and may clear/replace the pre-buffer, risking data loss.

## Evidence (logs)
```
🔁 [DEVICE] Device/default changed – refreshing capture path
🔄 [CAPTURE RECOVERY] Restarting audio capture without closing WebSocket
🌐 [RECOVERY] WebSocket not ready during capture restart – initiating connection
```

## Hypothesis
- Recovery triggers before WS readiness and interferes with pre-buffer ownership.

## Acceptance criteria (QA)
- During connect, recovery does not reset or reduce `preBufferPackets`.
- If recovery must run, it pauses until WS ready or preserves buffer safely.

## Reproduction
- Cold start; speak; trigger device route change while connecting.

## Fix direction
- Gate recovery while `connecting == true`.
- Or use a safe path that continues appending to the same pre-buffer queue.

## Test plan
- Simulated device-change during connect; verify buffer size unchanged.

---
Status: ✅ RESOLVED | Owner: Audio/Realtime

## Resolution
- Gated capture recovery while WebSocket is connecting; recovery now logs "[CAPTURE RECOVERY] Skipping … while connecting" and does not touch `preBufferPackets`.
- Added buffering state machine (idle → prebuffering → flushing → live) to prevent state churn during connect/flush.

## Validation
- During connect, device-change/recovery events do not reduce `preBufferPackets`; subsequent flush shows original buffered duration; transcripts intact.
