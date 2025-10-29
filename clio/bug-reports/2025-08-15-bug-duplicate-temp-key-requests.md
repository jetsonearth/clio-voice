# HIGH BUG: Duplicate temp key requests under contention

## Summary
- Severity: 🔴 HIGH
- Components: `TempKeyCache.swift`, key fetch coalescing
- Impact: Multiple simultaneous temp-key requests increase latency/load; can worsen cold-start times.

## Evidence (logs)
```
🔑 [FRESH-KEY] Fetched and cached temp key in 1519ms
🔑 [FRESH-KEY] Fetched and cached temp key in 2360ms
```
(Back-to-back within same session.)

## Hypothesis
- Concurrent callers to `getCachedTempKey` miss cache and trigger parallel fetches for same language set.

## Acceptance criteria (QA)
- At most one in-flight fetch per `(languages)` key; others await same result.
- Cache hit rate high after warmup; no back-to-back fresh fetches for same key.

## Fix direction
- Introduce in-flight coalescing map (promise) keyed by languages; dedupe concurrent requests.

## Test plan
- Race test: 3 concurrent callers → 1 network request.

---
Status: ✅ CLOSED | Owner: Platform/Networking

## Resolution
- Implemented in-flight coalescing in `TempKeyCache` using `inFlightPrefetchKeys` keyed by a single global key (temp key not language-bound).
- TTL-based one-shot refresh prevents redundant refresh bursts.

## Validation
- No back-to-back fresh fetches observed for same session; logs show single fetch + subsequent cache hits.
