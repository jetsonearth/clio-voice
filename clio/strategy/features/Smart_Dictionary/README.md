## Smart Dictionary: Personalized Correction Mining and Contextual Hotwording

### TL;DR
- Automatically learn from users’ immediate edits to ASR output (wrong → right) and store them as per-user dictionary entries.
- Use these entries during recognition via prompt injection, hotword boosting, grammars, or reranking to reduce repeated errors and improve personalization.
- On-device by default with privacy controls, decay/prune policies, and per-domain/language segmentation.

---

### Background
Dictation systems frequently repeat user-specific errors (names, jargon, project terms). Users often correct these manually. Smart Dictionary closes the loop: detect those corrections near-real time, mine them as structured entries, and bias the recognizer on subsequent segments/sessions. This increases accuracy, reduces friction, and creates compounding personalization with minimal user effort.

This document defines the product, UX, data model, and system design for implementing Smart Dictionary in Clio, referencing existing insertion flows (`ClipboardManager.swift`, `CursorPaster.swift`) and ASR stack (`RecordingEngine.swift`, `AIEnhancementService.swift`).

---

### Goals
- Learn user-specific terms and phrases by observing immediate edits to recently emitted ASR text.
- Use learned entries to improve recognition quality with minimal latency overhead.
- Provide transparent controls to view, edit, and disable personalization.
- Keep data on-device by default; add optional account-based sync (opt-in).

### Non-Goals
- Full style/grammar personalization beyond targeted phrase/word corrections.
- Cross-user or global model training.
- Aggressive biasing that risks hallucinations or domain bleed.

---

### Personas
- Power Dictator: Dictates emails, docs, and code; expects terms to “stick” after one correction.
- Domain Specialist: Uses medical/legal/engineering jargon; needs per-domain dictionaries.
- Privacy-Conscious User: Wants on-device only, with explicit control over what’s stored and synced.

---

### User Stories
- As a user, when I fix a misrecognized name, the system should correctly recognize it next time in the same session and in future sessions.
- As a user, I can open Settings to review, edit, or delete learned entries and turn the feature on/off.
- As a user, I expect the system not to over-bias unrelated text or introduce new errors.
- As a domain user, I want dictionaries to be scoped to language/app/workspace so my coding terms don’t affect chat or email.

---

### UX and Controls
- Settings → Dictation → Smart Dictionary
  - Toggle: Enable Smart Dictionary
  - Scope: Per language, per app, or global
  - Max entries, Max boost level
  - View list (search, sort by recency/frequency)
  - Edit/Delete entries
  - Export/Import (local file); Sync (opt-in)
  - Privacy: On-device storage by default; clear all data

Inline Feedback (optional, low-friction):
- Snackbar/toast after first few successful recalls: “Saved to Smart Dictionary: ‘AcmeCorp’ → ‘ACME Corp’” with “Manage” link.

---

### Data Model (Per User, Per Language, Optional Per Domain)
- key_canonical: lowercased, punctuation-normalized phrase key
- display_variants: array of representative forms
- phonetic_forms: optional G2P/phoneme sequences
- language_code: e.g., en-US, ja-JP
- domain/app_scope: optional app id or workspace tag
- contexts_seen: compact n-gram context sketches or top co-occurring tokens
- counts: total_observed, recent_observed
- score: float; function of recency, frequency, original ASR confidence, edit latency, and op type
- last_seen_at: timestamp
- ttl_decay_params: decay factors for pruning

Storage: SQLite/Core Data on-device. Optional encrypted sync later (Supabase/Polar) with consent.

---

### System Architecture

```mermaid
flowchart TD
  A[ASR emits segment] --> B[Insertion Manager
  (Clipboard/Direct Insert)]
  B --> C[Edit Observer
  (AX API / Editor Hook)]
  C --> D[Alignment & Diff
  (token-level)]
  D --> E[Validation & Scoring
  (latency, ops, confidence)]
  E --> F[Smart Dictionary Store
  (per user/lang/domain)]
  F --> G[Hotword Provider]
  G --> H[ASR Context Injection
  (prompt/grammar/bias/rerank)]
  H -->|improved hypothesis| A
```

Key Code Touchpoints:
- `Clio/Clio/Managers/ClipboardManager.swift`: text insertion/paste flows
- `Clio/Clio/Managers/CursorPaster.swift`: cursor-aware insertion
- `Clio/Clio/Whisper/RecordingEngine.swift`: segment lifecycle, prompts
- `Clio/Clio/Services/AI/AIEnhancementService.swift`: reranking, context packaging

---

### Detection & Learning Pipeline
1) Event Capture
   - Record each emitted segment: text, segment_id, char range in target surface, timestamps, ASR confidence if available.
   - Observe edits in the same surface for a sliding window (e.g., 90 seconds, or until caret leaves far away).
   - macOS: Prefer our own insertion surfaces; optionally subscribe to Accessibility (AX) edit events when feasible.

2) Segmentation Mapping
   - Maintain mapping from emitted tokens → document ranges.
   - Coalesce micro-segments if they were committed together.

3) Diff & Alignment
   - Compute token-level Levenshtein diff between emitted span and final edited span.
   - Extract wrong_phrase → right_phrase for substitution operations; capture local context (±2–3 tokens).

4) Validation Heuristics (False-Positive Reduction)
   - Edit latency threshold (e.g., < 90s, exponentially decayed score).
   - Op types: prioritize substitutions; ignore pure punctuation/casing unless repeated ≥ N times.
   - Original ASR confidence low/medium preferred, or high edit locality.
   - Ignore very large rewrites unless repeated across sessions.
   - Language and app/domain match.

5) Scoring
   - score = w1*frequency + w2*recency_decay + w3*(1 - asr_confidence) + w4*context_match_rate + w5*edit_latency_factor + w6*substitution_bonus
   - Promote when score ≥ threshold; demote with time-based decay or if contradicted by later edits.

6) Storage & Lifecycle
   - Insert/Update dictionary entry with counters and timestamps.
   - Maintain max size (e.g., 200 entries per language/scope); prune by lowest score.
   - Separate “style” entries (capitalization, punctuation) from lexical entries.

7) Runtime Injection to ASR
   - Prompt/Prefix Injection: add top-K hotwords + minimal context to `initial_prompt` for each segment in `RecordingEngine`.
   - Grammar (GBNF) Injection: synthesize a small alternation for top-K phrases where grammar support exists.
   - Logit Biasing: apply token-level bias for hotwords when decoder API supports it; cap max bias.
   - N-best Reranking: boost hypotheses that contain high-score entries with contextual alignment.
   - Context Gating: activate only when nearby context matches (n-gram overlap) or user-selected domain mode.

---

### Integration with Whisper (Clio)
- Prompt Path: extend `RecordingEngine` to generate an `initial_prompt` that includes top-K scored phrases per active language and domain; ensure size/latency limits.
- Grammar Path: if using whisper.cpp grammars, emit a scoped GBNF for the current segment with an alternation of top-K phrases. Example:

```bnf
root ::= (phrase | token)+
phrase ::= "acme" " corp" | "kubernetes" | "xcode" | "zhaobang" " wu"
```

- Rerank Path: in `AIEnhancementService`, add a feature-based reranker: +β for dictionary matches, +γ for context proximity; validate via A/B.
- Safety: cap K (e.g., 50–150), cap per-phrase bias, and enforce cooldown if WER worsens.

---

### Platform Considerations (macOS)
- Primary: capture via our own insertion pipeline (`ClipboardManager.swift`, `CursorPaster.swift`) with full knowledge of emitted spans and caret ranges.
- Optional: AX-based edit observation when users type in third-party apps; restrict to nearby spans in time and location to minimize noise.
- Respect app permissions and privacy settings; provide a clear toggle.

---

### API Surface (Proposed)

Swift Protocols/Types:
```swift
public struct SmartDictionaryEntry: Codable, Hashable {
  public let canonicalKey: String
  public var displayVariants: [String]
  public var phoneticForms: [String]?
  public let languageCode: String
  public var domainScope: String?
  public var contextsSeen: [String]
  public var totalCount: Int
  public var recentCount: Int
  public var score: Double
  public var lastSeenAt: Date
}

public protocol SmartDictionaryService {
  func recordCorrection(
    wrong: String,
    right: String,
    languageCode: String,
    domainScope: String?,
    localContext: [String],
    asrConfidence: Double?,
    editLatencyMs: Int
  )

  func topHotwords(
    languageCode: String,
    domainScope: String?,
    maxCount: Int
  ) -> [SmartDictionaryEntry]

  func removeEntry(canonicalKey: String, languageCode: String, domainScope: String?)
  func clearAll(languageCode: String?)
}
```

Suggested Files:
- `Clio/Clio/Services/Text/SmartDictionaryService.swift` (implementation)
- `Clio/Clio/Services/Text/SmartDictionaryStore.swift` (SQLite/Core Data adapter)
- `Clio/Clio/Views/Settings/SmartDictionarySettingsView.swift` (UI)

---

### Privacy & Security
- On-device storage by default; no network transmission unless user opts into sync.
- Clear, revocable consent for sync; separate toggle per language/domain if needed.
- Easy “Delete all” and per-entry delete.
- Do not record raw surrounding document content beyond minimal n-gram context; store hashed/lightweight sketches if possible.

---

### Risk Mitigation
- Over-biasing → hallucinations: cap bias and K; require context gating; rollback path.
- Domain bleed: scope entries by app/workspace; default to same-app activation.
- Multi-language collision: separate per language; auto-LID if mixed text.
- False positives from stylistic edits: maintain separate style bucket with lower influence; require repetition to promote.

---

### Metrics & Success Criteria
- WER reduction on repeated-entity test sets (personalized vs control).
- Correction rate: fraction of segments with manual edits declined over time.
- Time-to-correct: reduction in user time fixing repeated terms.
- Precision of learned entries: manual audit pass rate ≥ 95% for “promoted” items.
- Opt-in/Opt-out rates; retention impact for power dictators.

---

### Experimentation
- A/B with user-level randomization: control (no personalization) vs prompt-only vs prompt+rerank vs grammar.
- Tune K, bias caps, scoring weights, and context-gating thresholds.
- Track guardrail metrics: hallucination proxy rate, off-domain inserts, latency.

---

### Rollout Plan
Phase 0: Internal dogfood (prompt-only, small K, on-device only)
- Implement store + basic scoring + prompt injection.
- UI to view/delete entries; logs behind debug flag.

Phase 1: Beta cohort
- Add reranking and context gating; refine heuristics.
- Add per-app scoping and multi-language support.

Phase 2: Public GA
- Add optional sync; advanced management UI (search, import/export).
- Add grammar path where supported; finalize caps/safeties.

---

### Internationalization & Special Cases
- Names and transliteration: rely on phonetic forms where available; allow multiword phrases.
- CJK and languages without whitespace: diff at character/subword granularity; maintain robust normalization.
- Casing and punctuation in style bucket; display variants preserve user-preferred case.

---

### Open Questions
- Preferred maximum K and bias caps per device class? Dynamic based on latency budget?
- What is the minimal viable AX integration to capture third‑party edits reliably without excess noise?
- Should we allow user-defined domains (e.g., “My Project X”) with manual assignment?
- Export/import format: JSON schema stability across versions.

---

### Appendix A: Example Prompt Snippet
```
[Personal hotwords]
acme corp; kubernetes; zhaobang wu; lamotrigine; ingress; grpc; supabase

Instructions: Prefer the above spellings if acoustically plausible. Do not force them unless context matches.
```

### Appendix B: Example GBNF Alternation
```bnf
hotword ::= "acme" " corp" | "kubernetes" | "zhaobang" " wu" | "grpc"
```

### Appendix C: Scoring Pseudocode
```swift
let base = frequencyWeight * log(1 + totalCount)
let freshness = recencyWeight * exp(-timeSinceLastSeen / halfLife)
let uncertainty = confidenceWeight * (1 - (asrConfidence ?? 0.7))
let locality = contextWeight * contextMatchRate
let latencyBonus = latencyWeight * exp(-editLatencyMs / 60000)
let opBonus = substitutionBonus
let score = base + freshness + uncertainty + locality + latencyBonus + opBonus
```


