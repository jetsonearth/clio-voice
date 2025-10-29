# PERFORMANCE: DNS/TLS prewarm cadence (5 minutes + on launch/activation)

## Goal
Reduce WS connect time by keeping DNS/TCP/TLS paths warm.

## Approach
- Run existing `prewarmDNSResolution()` and `prewarmConnectionPool()` at launch/activation.
- Repeat every 5 minutes (gate by recent activity to save power).

## Acceptance criteria
- WS connect median reduced by >50% on typical networks.
- Overhead: HEAD warms complete < 200ms per cycle; no user-visible impact.

## Test
- Measure WS connect TTFB before/after across VPN and normal networks.

---
Status: ✅ DONE | Owner: Platform/Networking

## Status notes
- WarmupCoordinator now invokes Soniox DNS/TCP/TLS prewarms (`prewarmDNSResolution`, `prewarmConnectionPool`) on launch/activation and every 5 minutes.
- Gated by rate-limiter; overhead <200ms per cycle in typical logs.
- Expect WS connect medians to drop on warm paths; verify via existing connection timing logs.
