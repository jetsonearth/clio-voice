# CRITICAL BUG: Pre-buffer audio loss and out-of-order flush

## Summary
- Severity: 🔴 CRITICAL
- Components: `SonioxStreamingService.swift` (preBufferPackets lifecycle, flush ordering)
- Impact: First seconds of speech are missing or appear later; users lose the intro. Saved audio may be complete while streaming transcript is missing the head.

## Evidence (logs)
- Cold WS connects (3–21s) while buffering; transcript misses intro; saved file intact.
- Overlapping flush with sequence overlap:
```
📦 Flushing 36 buffered packets … seq=0..50
📦 Flushing 14 buffered packets … seq=1..14 (overlap)
```

## Hypothesis
- `preBufferPackets` reset/cleared during capture restart or reconnect before flush.
- Overlapping connects bind buffer to an old socket; early packets dropped.

## Acceptance criteria (QA)
- Buffered packet count preserved across restarts/reconnects until flush.
- `droppedBufferedPackets=0` before live streaming.
- First tokens cover the first 1s of audio (aligned with `mic_engaged`).

## Reproduction
1. Cold start; start speaking immediately.
2. Slow WS connect (VPN/latency).
3. Verify transcript retains exact intro words; no reordering.

## Fix direction
- Session-scoped buffer with explicit state machine:
  - buffering → ws_connected → flushing_buffered → live_streaming
- Never clear/replace `preBufferPackets` until flush completes.
- On reconnect, reuse the same buffer; flush fully before live packets.
- Metrics: `bufferedBeforeFlush`, `flushedCount`, `droppedBufferedPackets`.

## Test plan
- Unit: buffer survives simulated capture restart.
- Integration: forced reconnect prior to connect ready preserves intro.

---
Status: 🟡 PARTIALLY MITIGATED | Owner: Audio/Realtime

## Current status notes
- After lifecycle hardening (single-flight connect), dual-start reordering is no longer observed in new logs.
- Keeping this bug OPEN until per-session sequence reset and buffer state machine are implemented to fully harden ordering.
