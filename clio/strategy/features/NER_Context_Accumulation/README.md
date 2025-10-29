## Session-Scoped NER Accumulation (Option B)

Goal: For long sessions with multiple documents/pages, accumulate high-signal entities across significant context changes to provide richer, but bounded, context to the final LLM postprocess. OCR/NER still never runs at end-of-recording.

Principles
- Metadata-only mode detection; ASR never blocks on OCR/NER.
- OCR+cloud NER run only during recording on significant context changes (debounced). Never at end.
- Keep the accumulated NER store compact, deduplicated, and recency-weighted to avoid prompt pollution.

Data model
- Store: `SessionNERStore { items: [NERItem], capacity: Int }`
- `NERItem { text: String, type: String, firstSeenAt: Date, lastSeenAt: Date, count: Int, source: {app, url, title} }`

Policy knobs (configurable per context type via rule engine)
- `accumulationEnabled`: bool (default false)
- `maxItems`: e.g., 150
- `maxPerType`: e.g., 60 for functions, 60 for variables, 30 for classes
- `ttlSeconds`: optional decay for items that haven’t been referenced recently
- `triggerOnChange`: app/bundle/url/title change boundaries

Update rules
1) On significant context change (per policy), when OCR returns → run cloud NER and get entities.
2) Normalize tokens (case, trimming, collapse whitespace) and classify by type.
3) Merge into store:
   - Increment `count`, set `lastSeenAt = now`, `firstSeenAt` if new.
   - Deduplicate by `text+type` key.
4) Apply caps:
   - Enforce `maxPerType` by dropping lowest-score items (score = f(recency, frequency)).
   - Enforce global `maxItems` after per-type capping.
5) Optional decay: drop items with `now - lastSeenAt > ttlSeconds` if set.

Serving to LLM
- Final prompt takes top-K items by score per type, rendered as compact bullet/CSV sections.
- Include lightweight provenance only when helpful (e.g., url domain).

Latency behavior
- ASR unaffected.
- No OCR/NER at end. All updates happen during recording as OCR arrives.

Fail-safes
- If OCR lags or rate limits hit, reuse last known NER snapshot; do not block.
- Hard caps ensure prompt stays small and predictable.

Minimal implementation steps
1) Introduce `SessionNERStore` with merge/cap APIs.
2) Wire into prewarm+NER completion callback; guard by policy flags.
3) Add rule-engine flags for per-context accumulation config.
4) Update final LLM builder to read top-K from store.

Notes
- Start with conservative caps (e.g., 80–120 items total). Tune based on quality.
- Consider separate budgets for code vs non-code contexts.
