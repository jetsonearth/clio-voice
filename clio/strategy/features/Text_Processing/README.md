# Deterministic Post-Processing: Paragraph Splitting + zh→Hant Conversion

## Summary
- Deterministic, offline post-processing pipeline replaces brittle prompt-based instructions.
- Two core capabilities:
  - Paragraph splitting that is “semantic-ish” with linguistic rules (NLTokenizer + heuristics), consistent across runs/languages.
  - Simplified Chinese (Hans) → Traditional Chinese (Hant) conversion using OpenCC with Taiwan default, Hong Kong optional, preserving non‑Han content and code‑switching.
- Applied after LLM enhancement so final output is formatted and localized deterministically.

## Goals
- Deterministic paragraph structure without relying on LLM behavior.
- Enforce Traditional output for Chinese when selected.
- Keep solution fully offline, low‑latency, robust for long transcripts.

## Non‑Goals
- Deep semantic parsing or discourse modeling.
- Translation between languages (only script conversion for Han characters).

## Architecture
- DeterministicTextSplitter: sentence tokenization + paragraph assembly via thresholds (words/sentences per paragraph, “significant sentence” caps, short‑sentence merging).
- ChineseScriptConverter: OpenCC‑backed converter; Taiwan default (.twStandard + .twIdiom), Hong Kong optional (.hkStandard), guarded with `#if canImport(OpenCC)` and converter caching.
- PostEnhancementFormatter: orchestration layer used post‑LLM enhancement to apply splitting and conversion.

### Integration points
- `AIEnhancementService` applies PostEnhancementFormatter to all enhancement responses (primary + fallback providers).
- Optional pre‑LLM: local formatter can use the same splitter for ASR output.

## “Semantic‑ish” Splitting
1) Detect dominant language (or use SelectedLanguages) with `NLLanguageRecognizer`.
2) Tokenize sentences with `NLTokenizer(.sentence)` for stable boundaries.
3) Assemble paragraphs with heuristics:
- Target word count per paragraph (default 30–50)
- Cap of significant sentences (default 3–4), where a significant sentence has ≥ N words (default 3–4)
- Merge ultra‑short sentences into neighbors
- For CJK, prefer sentence‑count thresholds over word‑count
4) Join with a blank line between paragraphs.

Optional future: ClauseSplitter
- Within‑sentence clause splits via punctuation + discourse markers.
- Minimal per‑language rule tables (EN, ZH, JA, KO, ES) for better handling of long compounds.
- Safeguards: avoid quotes/URLs, only split “and/而且/そして/그리고” when clause length exceeds a threshold, merge short clauses, honor long ASR pauses if timestamps available.

## Chinese Script Conversion (OpenCC)
- Trigger when SelectedLanguages include `zh‑Hant` / `zh‑TW` / `zh‑HK`.
- Default Taiwan style (+ idioms). Use HK standard if `zh‑HK` is present.
- English/non‑Han are untouched; preserves mixed‑language code‑switching.
- OSLog markers: availability, cached/initialized converter used, errors.
- Packaging: ensure the OpenCC product from SwiftyOpenCC is linked to the app target so its resources bundle is copied; otherwise conversion is a no‑op by design.

## Control Flow
ASR → optional pre‑LLM splitter → LLM Enhancement → PostEnhancementFormatter (splitter → OpenCC) → output.

## Configuration
- No new UI needed for TW default; HK auto‑activates if `zh‑HK` is later exposed in language selection.
- Optional: toggle “Force Traditional output for Chinese.”

## Observability
- PostEnhancementFormatter can log paragraph counts.
- ChineseScriptConverter logs OpenCC availability/init/cache/error events.

## Performance
- NLTokenizer: O(n) over characters.
- OpenCC: lightweight; converters are cached; negligible relative to LLM latency.

## Edge Cases
- Non‑Chinese text: conversion no‑op; splitting still applies.
- Already‑Traditional input: idempotent.
- Mixed scripts: only Han converted, other scripts untouched.
- Very short transcripts: 1 paragraph.

## Test Plan
- Unit: EN, ZH, mixed EN+ZH; ensure stable paragraphing and correct TW/HK conversion samples.
- Integration: end‑to‑end enhancement produces Traditional output when zh‑Hant selected; logs confirm OpenCC availability.

## Rollout
- Phase 1 (done): deterministic splitter + conversion wired post‑LLM; prompts cleaned to remove those two instructions.
- Phase 2 (optional): ClauseSplitter + per‑language rule tables.
- Phase 3 (optional): UI toggle for Traditional variant and “force Traditional.”

## Acceptance Criteria
- With Chinese (Traditional) selected, output is consistently Traditional (TW default).
- Paragraphing deterministic and consistent for identical input.
- No LLM instructions required for splitting or conversion.
