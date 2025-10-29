# Changelog - Version 1.62

**Release Date:** September 18, 2025  
**Branch:** main

## 🎙 Transcription Fidelity
- **Catalog-Driven Filler Cleanup:** Introduced `FillerCatalog` with editable JSON rules so disfluency lists can expand without code changes.
- **Raw Transcript Sanitizer:** Added `RawDisfluencySanitizer` to tidy small ASR snippets while keeping mixed-language phrasing intact.
- **Soniox Finalization Guardrails:** Extracted a dedicated finalization sequence that drains queued audio, respects pre-EOS `<end>` tokens, and stitches late arrivals to stop clipped endings.

## 🧠 Context & AI Enhancements
- **Active Browser Detection:** New `ActiveBrowserURL` helper reads the frontmost browser host so command mode can tailor prompts to web apps.
- **Prompt Hardening & Telemetry:** Refined multilingual prompts, logging, and fallback handling to protect against accidental translation and capture full AI request payloads for debugging.

## 🎛 Voice & Shortcut Controls
- **Side-Specific Modifiers:** Hotkey capture now records left/right modifier keys, rejects incidental writes, and stabilizes push-to-talk, hands-free, and assistant shortcuts.
- **Command Transform Flow:** Selection command service prewarms context, guarantees clipboard restoration, and records command-mode entries for history.

## 🎨 UI & Localization
- **AI Editing Strength Copy:** Updated cards, layout, and localized bullets to promise "mixed languages" instead of "code-switching."
- **Navigation Consistency:** Sidebar labels and onboarding windows received sizing and terminology fixes to match the latest personalization copy.
- **Recorder Delay Elimination** Eliminate notch render delay on older machines.

---

**Build:** 1.62  
**Compatibility:** macOS 14.0+  
**Highlights:** Reliable transcript endings, smarter context awareness, and safer global shortcuts.
