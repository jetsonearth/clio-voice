## Semantic Clause & Paragraph Splitting (Deterministic, Cross‑Language)

### Why
- **Problem**: Intermittent truncation of final sentences in enhanced output.
- **Root cause**: `DeterministicTextSplitter` enforced a cap on “significant” sentences per paragraph and trimmed overflow, which could remove trailing content depending on tokenization.
- **Goal**: Deterministic, language‑agnostic splitting that feels semantic; never drop content; avoid LLM prompts and language‑specific cue lexicons.

### Scope
- **Impacted code**: `Clio/Clio/Services/Text/DeterministicTextSplitter.swift`, `Clio/Clio/Services/Text/PostEnhancementFormatter.swift`
- **Consumers**: Post‑enhancement formatting pipeline (`PostEnhancementFormatter.apply(...)`)

---

## What we had (Before)
- Normalize text, detect language via `NLLanguageRecognizer`.
- Segment into sentences using `NLTokenizer(.sentence)`.
- Group sentences toward ~50 words per paragraph.
- Enforce `maxSignificantSentencesPerParagraph` (default 4) by trimming any overflow from the group (this could drop trailing sentences/content).

### Failure modes
- Trailing content disappeared when a paragraph exceeded the significant‑sentence cap.
- Apparent randomness because sentence tokenization and “significance” classification vary with punctuation/language mix.

---

## What we shipped (Fix)
- **Invariant**: Never drop content.
- **Behavior**: When the significant‑sentence cap would be exceeded, start a new paragraph and preserve all remaining sentences in order.
- **Effect**: Same constraints for readability, but overflow results in additional paragraphs instead of text loss.

File: `Clio/Clio/Services/Text/DeterministicTextSplitter.swift`
- Changed the overflow branch to split into multiple paragraphs (content‑preserving) rather than trimming.

---

## What we are doing next (Deterministic Semantic Splitting)
We’ll keep the pipeline deterministic and cross‑language by augmenting splitting with **Unicode‑aware boundary scoring** and simple structure preservation.

### Design principles
- **Deterministic**: No LLM prompts, no model variability.
- **Language‑agnostic**: Avoid cue lexicons; rely on Unicode punctuation and tokenization.
- **Content‑preserving**: 100% of input text must be present in output.
- **Simple & fast**: Heuristics with clear knobs; no heavy ML.

### Pipeline
1) **Sentence splitting**
   - Use `NLTokenizer(.sentence)` (Apple NL) for robust, cross‑language sentence boundaries.

2) **Candidate clause boundaries (within a sentence)**
   - Identify punctuation boundaries using Unicode categories (UAX#29), including CJK full‑width punctuation.
   - Weights:
     - **Strong**: `. ! ?` and `。！？` → +3
     - **Medium**: `; :` and `；：` → +2
     - **Weak**: `, 、，` → +1
   - Avoid splitting inside quotes/parentheses: −1 if boundary is within `() [] {} "" ''`.

3) **Context signals**
   - +1 if next token likely begins a new thought (uppercase Latin start, CJK ideograph boundary, opening quote/bracket).
   - +1 if current clause length ≥ `minWords` (e.g., 3–4); −2 if shorter (discourage fragments).
   - Optional ASR timing: +k if pause > threshold between tokens (if word timings available).

4) **Clause selection strategy**
   - Greedy selection: grow a clause until hitting `targetClauseWords` (e.g., 12–18) or encountering a strong boundary with clause ≥ `minWords`. Choose the highest‑scoring boundary encountered.
   - Alternative (future): small DP maximizing total boundary scores with `[minWords, maxWords]` per clause.

5) **Paragraph assembly**
   - Accumulate clauses to ~`targetParagraphWords` (default 50). If adding a clause would exceed the limit, or would exceed `maxSignificantSentencesPerParagraph`, start a new paragraph.
   - **Never drop content.**

6) **Structure preservation**
   - **Lists**: detect numbered/bulleted lines via regex (e.g., `^\s*([0-9]+[\.)]|[-*•])\s+`) and preserve line breaks.
   - **Code/backticks**: pass‑through; do not reflow inside inline backticks or fenced code blocks.
   - **No translation**; only safe whitespace normalization.

### Configuration knobs
- `targetParagraphWords` (default 50)
- `maxSignificantSentencesPerParagraph` (default 4)
- Clause: `minWords`, `targetClauseWords`, `maxWords`
- Punctuation weights (strong/medium/weak)
- Timing boost (if audio timings available)

### Pseudocode sketch
```swift
// High level flow in PostEnhancementFormatter.apply()
let paragraphs = DeterministicTextSplitter.split(text, options)
return ChineseScriptConverter.convertIfNeeded(paragraphs.joined(separator: "\n\n")).trimmingCharacters(in: .whitespacesAndNewlines)
```

```swift
// Clause scoring (within each sentence)
for boundary in sentenceBoundaries(text) {
  var score = punctuationWeight(boundary)
  if nextTokenLikelyNewThought(boundary) { score += 1 }
  if insideQuotesOrParens(boundary) { score -= 1 }
  if currentClauseLen < minWords { score -= 2 }
  candidates.append((boundary, score))
}
// Greedy selection honoring min/target/max words per clause
```

---

## Edge cases
- **CJK** continuous text with full‑width punctuation (。！？；：、，): supported via Unicode categories.
- **Mixed language / code‑switching**: handled by NL tokenization; no cue lexicons required.
- **Lists/Markdown**: preserved via regex detection; no collapsing.
- **Quotes/Brackets**: avoid splits mid‑quote/paren via scoring penalty.

---

## Testing
- Unit tests for `DeterministicTextSplitter`:
  - Exceeding significant‑sentence cap never drops content.
  - English long sentences with commas/semicolons.
  - CJK with `。！？；：、，`.
  - Mixed English/CJK code‑switching.
  - Lists and markdown preservation (numbered, dashed bullets).
  - Code/backticks pass‑through.
- Golden tests: multiple sample transcripts → stable deterministic outputs.

---

## Metrics & Telemetry
- Track: paragraph count, clause count, avg words per paragraph/clause.
- Boundary quality: ratio of strong/medium/weak splits to tune weights.
- Optional privacy‑aware proxy: rate of manual edits after paste (as an indicator of coherence).

---

## Rollout
- Phase 0 (done): content‑preserving fix (overflow → new paragraphs).
- Phase 1: introduce clause boundary scoring behind a feature flag (e.g., `DeterministicClauseSplittingEnabled`).
- Phase 2: tune weights/thresholds using metrics + golden tests.

---

## Alternatives considered
- **LLM‑based semantic splitting**: rejected due to non‑determinism, latency, cost, and unpredictability on short inputs.
- **Language cue lexicons**: brittle and high maintenance across languages and code‑switching.

---

## Future improvements
- Use ASR pause durations to boost boundary scores at natural pauses.
- Adaptive targets: conversational vs summaries adjust `targetParagraphWords` and clause targets.
- User‑visible toggle: “tighter paragraphs” vs “looser paragraphs”.
- Optional tiny on‑device classifier for boundaries (still deterministic with fixed model/seed).

---

## References (in repo)
- `Clio/Clio/Services/Text/DeterministicTextSplitter.swift`
- `Clio/Clio/Services/Text/PostEnhancementFormatter.swift`
- `Clio/strategy/features/text_splitting_deterministic.md`
- `Clio/strategy/features/deterministic_postprocessing_zh_conversion_and_clause_splitter.md`

---

## Owner & Status
- **Owner**: Core text pipeline
- **Status**: Phase 0 fix shipped; Phase 1 design in this doc
