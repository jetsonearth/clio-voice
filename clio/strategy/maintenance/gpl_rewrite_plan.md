## Executive Summary

Objective: remove or clean‑room rewrite all GPL‑derived source currently compiled into the macOS app target so Clio can ship under a proprietary EULA. Until the high‑similarity set is eliminated, keep GPL in the repo and do not distribute closed‑source binaries.

Deliverables (DoD):
- 0 files in `gpl_similarity_report.csv` with similarity ≥ 0.60 that are members of the app target.
- Pre‑build guard in Xcode that blocks VoiceInk/GPL/`mailto:` literals.
- Progress and audit trail preserved in `strategy/research/*` and this document.
- `LICENSE` switched from GPL to our EULA after final audit passes.

## Scope of Work

Inputs used for scoping:
- Automated similarity scan (comment/whitespace normalized) between `Clio/Clio/**/*.swift` and `VoiceInk/VoiceInk/**/*.swift`.
- Report: `strategy/research/gpl_similarity_report.csv` (similarity >= 0.60).
- Unused-type heuristic: `strategy/research/unused_candidates.csv`.

Out of scope:
- Node server repos, website, docs. This plan focuses only on the macOS app target.

High‑priority files for immediate rewrite (similarity ≥ 0.98):
- Views/Recorder/NotchShape.swift
- Views/PromptEditorView.swift
- Views/Common/CardBackground.swift
- PowerMode/AppPicker.swift
- Managers/ClipboardManager.swift
- Views/Components/InfoTip.swift
- Services/Text/DeterministicTextSplitter.swift (design parity OK; implementation must be rewritten)
- Views/Recorder/NotchRecorderPanel.swift
- Whisper/WhisperHallucinationFilter.swift
- Services/Data/PromptMigrationService.swift
- Views/Settings/AudioCleanupManager.swift
- Whisper/WhisperPrompt.swift
- Managers/EmailSupport.swift (now modified; still rewrite to be safe)

Secondary files (0.90–0.97):
- DictionaryView.swift, KeyboardShortcutView.swift, MenuBarManager.swift, MetricCard.swift, TimeEfficiencyView.swift, NotchWindowManager.swift, etc. See CSV for the full list.

Tertiary files (0.60–0.89):
- Items with looser similarity; evaluate case-by-case for retention vs. rewrite.

## Rewrite Strategy (Clean‑Room)

1. Specification First
   - For each file, write a short spec: inputs, outputs, dependencies, state, error handling, and UI behavior.
   - Save specs under `strategy/specs/<relative-path>.md`.

2. New Implementation
   - New filenames can remain the same but the internal structure must change (types, method breakdown, data flow).
   - No copy/paste; refer only to the spec and runtime behavior of Clio.
   - Prefer smaller, composable types with unit tests.
   - UI components: recreate view hierarchy from wireframes/screenshots; avoid identical struct layout and property names.
   - Services/Managers: re‑model state and dependencies; prefer protocols for seams; change method naming and flow.

3. Validation
   - Add unit/UI smoke tests per component where feasible.
   - Peer review for structural differences and confirm similarity < 0.30 against the original.

4. Deprecation and Removal
   - Once a component is replaced, remove the old file and re-run similarity checks. Update the CSV.

5. Acceptance Criteria per file
- Builds clean; no app‑target references to the old type names.
- Similarity < 0.30 vs. upstream file (normalized).
- Same user‑visible behavior (or a documented intentional change).

## CI/Build Guards

Add a pre-build script to fail the build when forbidden patterns are present in the app target:

```bash
set -euo pipefail
ROOT="$PROJECT_DIR/Clio/Clio"
if command -v rg >/dev/null 2>&1; then RG=rg; else echo "ripgrep (rg) required"; exit 1; fi

# Block brand/licensing leftovers
$RG -n --hidden --iglob '!**/node_modules/**' '(VoiceInk|GNU GENERAL PUBLIC LICENSE)' "$ROOT" && {
  echo 'Blocked terms found (VoiceInk/GPL) in app sources'; exit 2; }

# Enforce support email indirection
$RG -n --iglob '!**/node_modules/**' 'mailto:\S+@\S+' "$ROOT" && {
  echo 'Hardcoded mailto found; use SupportConfig.supportEmail'; exit 3; }
```

Also add a nightly (or pre‑commit) job to regenerate `gpl_similarity_report.csv` and alert when any item ≥ 0.60 appears. Store the latest CSV under `strategy/research/purging/` and attach to PRs.

Optional guard: fail if any file from the flagged list is still a target member. Maintain `strategy/research/purging/flagged_target_members.txt` and keep it empty.

## Phased Plan & Timeline

- Phase 0: Gatekeeping (0.5 day)
  - Add pre-build script; commit.

- Phase 1: Critical UI/Core (2–3 days)
  - Rewrite the 10–12 files listed in High-priority.

- Phase 2: Secondary Components (3–4 days)
  - Menu/UI helpers, metrics, keyboard, dictionary, window managers.

- Phase 3: Tail & Cleanup (1–2 days)
  - Tertiary items; remove any unused files from `unused_candidates.csv`.

## Unused/Dead Code Cleanup

- Review `strategy/research/unused_candidates.csv` and prune types not referenced outside their declaration. Confirm with the Xcode target membership and compile once after removal.

## Licensing Decision Points

- Until rewrites are merged, ship only with GPL in place or refrain from distribution.
- Alternative: reach out to the VoiceInk author for a commercial license to cover derivative portions.

## Deliverables

- Rewritten Swift files replacing flagged components (tests included where practical)
- Updated CI/build checks
- Updated `LICENSE`/EULA once the code is clean

## Progress

- [x] Centralize support email, update links
- [x] Add similarity report and rewrite plan docs
- [x] Disable notch recorder path (mini only); deprecate notch classes
- [x] Remove PowerMode hooks from runtime (shortcuts, ActiveWindowService calls)
- [x] Remove VAD usage and local hallucination filter application
- [x] Remove unused PowerMode files under `Clio/Clio/PowerMode/*`
- [ ] Remove Whisper local stack entirely (WhisperContext, local transcribe path)
- [ ] Prune unused localized strings (PowerMode keys)
- [ ] Add pre-build grep guard and nightly similarity check
- [ ] Replace GPL license with EULA once rewrites complete

## Operational Playbook (Handoff)

1) Re‑run audits
- Similarity: run the scripts in `strategy/research/purging/script.txt` to regenerate `gpl_similarity_report.csv` and `unused_candidates.csv`.
- Target membership audit: in Xcode, select each file ≥ 0.60 and confirm the target checkbox; uncheck if safe, otherwise schedule rewrite.

2) Rewrite queue (suggested order)
- CardBackground.swift, PromptEditorView.swift, ClipboardManager.swift, InfoTip.swift, AnimatedSaveButton.swift.
- DeterministicTextSplitter.swift, PromptMigrationService.swift, AudioCleanupManager.swift, CustomPrompt.swift, MetricCard.swift.

3) Replacement patterns
- Views: rebuild layout using new subview structs and different property naming; avoid duplicating extension helpers.
- Managers: inject dependencies, restructure public API, change state storage, and split into smaller files for clarity.

4) Testing & QA
- Smoke tests: launch app, onboarding, record/transcribe, enhancement on/off, copy to clipboard, prompts selection.
- Regression: hotkey toggle, mini recorder lifecycle, window/context detection, Soniox dictionary context.

5) Risk & Mitigations
- Risk: lingering high‑similarity UI files. Mitigation: exclude from target until rewritten.
- Risk: accidental literal leaks. Mitigation: pre‑build guard and repository grep pre‑commit.
- Risk: schedule creep. Mitigation: parallelize UI rewrites and service rewrites; track burndown via CSV deltas.

6) Communication
- Use PR checklist to link the updated CSV and confirm no flagged files remain in target membership.
- When the list is empty and guard in place, switch `LICENSE` to EULA in the same PR.

7) Rollback Plan
- If a rewrite introduces regressions, revert to previous commit but keep the file excluded from target until fixed, or temporarily ship behind a feature flag.

## Quick Commands

- Re‑run similarity scan and unused types: see `strategy/research/purging/script.txt`.
- Repo grep (manual sanity):
```bash
rg -n "VoiceInk|GNU GENERAL PUBLIC LICENSE" Clio/Clio || true
rg -n "mailto:\\S+@\\S+" Clio/Clio || true
```



