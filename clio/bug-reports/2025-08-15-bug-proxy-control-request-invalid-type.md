# MEDIUM BUG: Proxy 400 "Control request invalid type"

## Summary
- Severity: 🟠 MEDIUM
- Components: Proxy routes (Fly.io), control message handling
- Impact: Noisy 400s during streaming; may trigger reconnects in some paths; adds noise to telemetry.

## Evidence (logs)
```
❌ Clio API Error: 400 - Control request invalid type.
```

## Hypothesis
- Control message intended for an LLM route is hitting an ASR or unrelated route; or payload schema mismatch.

## Acceptance criteria (QA)
- No 400 control errors during ASR sessions on healthy networks.
- Control messages routed/validated correctly.

## Fix direction
- Audit `clio-flyio-api` control endpoints; ensure ASR streaming path never sends control payloads there.
- Add request logging (route, body schema) for offending 400s and unit tests.

## Test plan
- Stream under load; confirm absence of 400 control errors.

---
Status: ❌ OPEN | Owner: Backend/API
