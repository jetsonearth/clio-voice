# PERFORMANCE: Precise temp-key refresh scheduling

## Goal
Guarantee cache hits without waste.

## Approach
- On issuance, schedule one-shot refresh at `expiresAt − 10m` per language set.
- Safety: app activation + 5m cadence checks; hotkey/UI ensure-ready is non-blocking.
- Coalesce in-flight fetches for the same language set.

## Acceptance criteria
- 0 cold key fetches during active usage sessions.
- Background network cost minimal; no duplicate fetches for same key.

## Test
- Sleep/wake, long idle, language changes.

---
Status: ✅ CLOSED | Owner: Platform/Networking

## Notes
- 5m cadence + event triggers implemented via WarmupCoordinator.
- TTL-based one-shot refresh at `expiresAt − 10m` implemented; single global key (not language-bound) with in-flight coalescing.

## Validation (client logs)
- "🗓️ [TTL-SCHEDULE] Scheduling temp key refresh for key=global in 3000s (expiresAt=…)"
- "⚡ [CACHE-HIT] Retrieved temp key in 12.0ms"
- "✅ [PREFETCH] Successfully prefetched temp key"
- No per-recording temp-key fetches observed; recordings proceeded with cache hits.
