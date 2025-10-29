# PERFORMANCE: Preconnect WebSocket before audio / short-lived persistence

## Goal
Remove 3–20s WS/TLS cold-start from the critical path.

## Approach
- On recorder UI appear or hotkey down, start WS connect and send config; begin audio only after `webSocketReady`.
- Keep one idle socket alive 60–120s (adaptive) with heartbeats; reuse if the user records again.

## Acceptance criteria
- First-token latency < 1.5s on warmed network; < 3s on cold/VPN.
- No extra sockets leaked; max 1 idle socket per user; auto-close on pressure.

## Test
- Cold/warm scenarios; VPN; repeated starts within 2 minutes.

---
Status: ✅ DONE | Owner: Audio/Realtime

## Status notes
- Preconnect added via `prepareForRecording()`; called on recorder UI show.
- Warm-socket hold now adaptive (15s idle>5m, 60s default, 90s for burst usage) with heartbeats.
- Network path monitor added; triggers proactive reconnect on path changes.
- Tracking first-token improvements in client logs; observed WS ready ~1.1–1.3s on warm paths.
