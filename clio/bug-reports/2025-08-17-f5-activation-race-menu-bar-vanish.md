# Bug Report: Plain F5 interception causes activation race → menu bar vanishes or app backgrounds

- Date: 2025-08-17
- Platform: macOS (Apple Silicon)
- Priority: 🔴 HIGH (Tier 1 risk) — core UX: app intermittently backgrounds at launch; menu bar disappears; hotkey unreliable at boot

## Issue Summary
Binding dictation to plain F5 (no modifiers) triggers our F5 override path that installs a session/head‑insert CGEvent tap. When this tap is started around the AppKit activation window, activation AppleEvents can time out ("AppleEvent activation suspension timed out"). Result: the app falls to background and/or the SwiftUI `MenuBarExtra` icon vanishes, despite logs showing it was constructed.

Mutual exclusivity observed:
- If F5 tap starts early → F5 works, but app backgrounds and menu bar icon disappears
- If F5 tap is delayed/disabled → app foreground/menu bar are stable, but F5 isn’t armed initially

## Detailed Description
### Symptoms
- ✅ Recording works, Soniox streaming works, warmups/NER flow OK
- ✅ When F5 works: press/hold PTT and double‑tap hands‑free behave as designed (via `InputGate`)
- ❌ Intermittent: on fresh launch, app shows for ~200ms then backgrounds; Dock click doesn’t foreground; menu bar icon disappears
- ❌ Alternate runs: app foreground/menu bar OK, but F5 not active until later (or never)
- ⚠️ Repeated logs: `AppleEvent activation suspension timed out`

### Steps to Reproduce
1. Bind dictation hotkey to plain F5 in Settings → Shortcuts (no modifiers)
2. Quit Clio and relaunch
3. Observe startup logs and UI
4. Often: menu bar icon appears then vanishes; app backgrounds and cannot be foregrounded via Dock
5. Alternate runs: app stays foreground; F5 not active for ~1s+ or not at all

### Expected Behavior
- App foregrounds and remains interactive after launch
- Menu bar icon persists
- F5 override active without impacting activation/foregrounding

### Actual Behavior
Activation handshake times out intermittently when F5 tap is armed early. Menu bar icon disappears even though `MenuBarView` logged `onAppear`. App backgrounds and Dock click has no effect.

## Environment Details
- OS: macOS (darwin 24.6.0)
- Hardware: Mac16,7 (per logs)
- Permissions: Microphone/Screen Recording granted. Accessibility trusted.

## Technical Context
- `HotkeyManager.configureFunctionKeyInterception(for:)`
  - When the bound key is plain F5 (code 96), starts `F5ToF16Remapper` (CGEvent tap).
  - Updated to route F5 Down/Up to `handleDictationKeyDown/Up()` so `InputGate` enforces PTT/double‑tap.
- `F5ToF16Remapper`: head‑insert session event tap; swallows F5 events; runs on worker thread once started.
- `AppDelegate.updateActivationPolicy()`: confirms `.regular`; `IsMenuBarOnly=false` during failures.
- SwiftUI `MenuBarExtra`: `MenuBarView` logs `appeared`, no `disappeared` even when icon vanishes visually.

## Observed Logs (abridged)
- `✅ [MENUBAR] MenuBarView appeared`
- `AppleEvent activation suspension timed out`
- `✅ F5→F16 remapper started (event tap)` and `thread runloop started`

## Root Cause Hypothesis
Creating the CGEvent tap for plain F5 during AppKit’s activation window can delay/interrupt activation AppleEvents. Activation doesn’t complete reliably, causing Dock/menu bar glitches despite scenes being constructed. This is timing‑dependent, hence the mutual exclusivity between F5 being armed and a stable foreground/menu bar.

## What We Tried (today)
1. Routed F5 through `InputGate` (Down→`handleDictationKeyDown`, Up→`handleDictationKeyUp`)
2. Avoided synchronous AX prompt and launch‑time tap creation; bail if not trusted
3. Deferred hotkey setup until `didBecomeActive`; added fallback deferred attempt
4. Post‑activation deferred arm for F5 (~1s after activation), and stop on `didResignActive`
5. Diagnostics: activation policy `.regular`, MenuBarView appear, no disappear

Outcome: Race persists on some boots; when F5 arms near activation, foreground/menu bar can still be impacted. When we push arming later, F5 isn’t ready soon enough.

## Proposed Fix (clean and minimal)
- Split F5 path from generic setup:
  1) On `didBecomeActive`: do not arm tap immediately. After main runloop idles at least once and ≥1.5–2.0s have passed, arm the tap on a worker thread. Verify `NSApp.isActive` at arming time.
  2) On `didResignActive`: stop the tap immediately.
  3) Never prompt AX at launch; prompt only when the user selects F5 or on first arming attempt.
  4) Add a watchdog: if activation timeout occurs while a tap is active, auto‑stop the tap and retry arming after a longer delay (e.g., 3s) once foreground is confirmed.
- Alternative (if plain F5 isn’t required): use a modifier with F5 so the Carbon hotkey path is used; no tap, no activation risk.

## Follow‑up Actions
- [ ] Implement strictly post‑activation arming (≥1.5–2.0s + runloop idle) and resign‑active teardown
- [ ] Guard arming with `NSApp.isActive`
- [ ] Add activation‑timeout watchdog
- [ ] Cold‑boot test x10; expect zero timeouts, F5 active ≤2s after boot
- [ ] Document behavior in `HotkeyManager`

## Status
- Reported, Investigating

## Notes for Next Agent
Repro is sensitive to boot timing. Use multiple cold launches. Watch for `MenuBarView appeared` followed by `activation suspension timed out`. Key files: `HotkeyManager.swift`, `F5ToF16Remapper.swift`, `AppDelegate.swift`.

---

## Live Updates (2025-08-17)

### 05:18–05:21 UTC
- Change: Deferred warmup/cadence to post-activation; enforced stricter 2s settled delay and active-state recheck before arming F5.
- Log snapshot shows:
  - `✅ [MENUBAR] MenuBarView appeared`
  - `AppleEvent activation suspension timed out` still occurs.
  - No `F5→F16 remapper started` line in these runs, indicating F5 tap likely wasn’t armed yet; activation still failed. This broadens the cause beyond the F5 tap alone.
- Observation: `applicationDidBecomeActive` log often doesn’t appear on failing runs → activation event is not delivered (handshake stalled). Policy remains `.regular`.

### Current Hypothesis Update
- The F5 tap is a trigger but not the only one. Something else on main/activation window can still starve the activation AppleEvents. Candidates:
  - Sparkle background check (error lines: `-checkForUpdatesInBackground called but .sessionInProgress == YES`).
  - Early global monitors (hands-free monitor), though these are lighter than taps.
  - Other initializations in `ClioApp.init()` constructing many services before activation.

### Next-step Experiments (binary toggles)
1) Disable Sparkle auto check on startup (skip `silentlyCheckForUpdates()` on `ContentView` onAppear) and test 5 cold launches.
2) Temporarily disable hands-free global/local monitors on launch (enable after didBecomeActive) and test 5 cold launches.
3) (If needed) Minimal scene: temporarily comment MenuBarExtra, launch only WindowGroup once to rule out SwiftUI menu bar path.
4) Instrument a watchdog: if no `didBecomeActive` within 800ms, log and force `NSApp.activate(ignoringOtherApps: true)` + focus main window (for diagnosis only).

### Status
- Still reproducible without arming F5 tap. Activation race likely multi-factor. Proceeding with (1) Sparkle-off A/B first.

### 05:25 UTC
- User reverted delayed-enable change. Fresh launch logs still show:
  - `✅ [MENUBAR] MenuBarView appeared`
  - `AppleEvent activation suspension timed out` (activation still failing)
  - No F5 remapper/tap lines in this run → failure happens without arming F5.
  - HotkeyManager prints early: `🎛️ Setting up hands-free shortcut monitor for: Left ⌥` before activation logs.
- New suspicion: early global NSEvent monitors (hands‑free) may also contribute to the activation race on some machines, even if they are lighter than taps.

#### Next Experiments (narrow to HotkeyManager only)
1) Gate both hands‑free monitors and any global/local monitors until `didBecomeActive` (no monitors before activation). Verify across 5 cold launches.
2) If (1) passes, re‑introduce only KeyboardShortcuts handler (no monitors, no tap) pre‑activation and retest.
3) If (1) still fails, temporarily prevent HotkeyManager initialization until after main UI `.onAppear`, then enable; retest.

#### Notes
- Sparkle errors are present but historically not the trigger per user’s prior diagnosis.
- Activation policy remains `.regular`; `IsMenuBarOnly=false` when failing.

### 05:50–06:55 UTC
- New symptom: During hands‑free sessions (double‑tap to lock), pressing F5 to stop sometimes triggers Apple Dictation instead of stopping. Logs show `F5→F16 remapper stopped` mid‑session even while Settings still displays F5.
- Root cause update: `configureFunctionKeyInterception()` was tearing down the interception when the library returned nil or a transient non‑plain‑F state. That can happen from capture UI/reads mid‑session.
- Changes applied:
  - Sticky interception: do not tear down the remapper when shortcut is nil; keep current mapping until a definitive, non‑plain‑F change.
  - Protect on resignActive: skip stopping F5 remapper when hands‑free is locked to avoid Dictation capturing F5 during the lock window.
- Next steps:
  - If teardown still appears while hands‑free is active, add guards around all teardown paths (including recovery/retry paths) to check `shouldProtectF5Interception()`.
  - Add explicit logs whenever teardown occurs with reason tags (userChange, resignActive, libraryNil, etc.) to pinpoint source.

### 07:02–07:11 UTC
- New persistence issue: After setting F5 in Settings and relaunching, F5 sometimes does not work until re‑setting in UI. Logs show the library reports `F5`, but the remapper is not always started immediately; later runs also show remapper stopped mid‑session.
- Hypothesis: transient nil reads from KeyboardShortcuts or capture UI cause teardown/skip of arming, leaving F5 to Dictation until user re‑sets.
- Mitigation added:
  - Sticky library shortcut: remember last known non‑nil library shortcut and use it as effective when current read is nil; avoid teardown in that state.
  - Logging: show both current and effective shortcuts in `[SHORTCUT DEBUG]` to confirm stickiness.
- Next steps:
  - If remapper still stops unexpectedly, add reason‑tagged logs for all teardown paths, and guard teardown with hands‑free protection + sticky effective shortcut present.

### 07:18–07:45 UTC
- Observation: On recent cold launches, no app freeze/backgrounding or menu bar disappearance was observed. Activation events delivered and policy remained `.regular`. The activation race is downgraded to "under observation" for now.
- Current blocker: F5 reliability mid‑session. Logs show `✅ F5→F16 remapper started` followed by `✅ F5→F16 remapper stopped`, often after double‑tap to hands‑free. Around the same time, logs show `🔍 [SHORTCUT DEBUG] Library shortcut: nil (effective: F5)` and `🔍 [SHORTCUT DEBUG] Custom shortcut: Right ⌘`, then "Setting up custom shortcut monitor for: Right ⌘". After this swap, plain F5 is no longer intercepted and Apple Dictation can capture it until the user re‑sets F5 in Settings.
- Updated hypothesis: `updateShortcutStatus()` reacts to transient library `nil` and incidental `customShortcut` writes that do not originate from the explicit capture UI, causing a reconfigure that tears down the F5 remapper despite the sticky logic. The hands‑free/double‑tap path likely installs monitors or triggers reads that race with shortcut state.
- Evidence from this session:
  - `✅ F5→F16 remapper started (event tap)` … `✅ F5→F16 remapper stopped`
  - `🔍 [SHORTCUT DEBUG] Library shortcut: nil (effective: F5)`
  - `🔍 [SHORTCUT DEBUG] Custom shortcut: Right ⌘`
  - `🎹 Setting up custom shortcut monitor for: Right ⌘`

- Mitigations to implement next:
  1) Block incidental writes to `customShortcut` unless an explicit Settings capture session is active (introduce `inCaptureSession` guard).
  2) Prefer the library F5 when present: treat plain F5 from `KeyboardShortcuts` as authoritative and ignore `customShortcut` for interception decisions if both exist.
  3) Guard all teardown sites with `shouldProtectF5Interception()` when hands‑free is locked and when an effective library shortcut of F5 exists (even if current library read is nil).
  4) Add reason‑tagged logs at every start/stop site: `startReason=` userSelectF5 | postActivationAutoArm | recovery; `stopReason=` resignActive | userChangedShortcut | customShortcutWrite | libraryNilTransient | teardownForReconfig.
  5) Add a watchdog to immediately re‑arm interception (e.g., after 100–200ms) if it stops while hands‑free is locked and `stopReason` is not `userChangedShortcut`.

- Checklist updates:
  - [ ] Implement `inCaptureSession` and block non‑capture writes to `customShortcut`.
  - [ ] Make interception preference order: library F5 > custom shortcut.
  - [ ] Wrap all teardown/start sites with reason‑tagged logs and `shouldProtectF5Interception()` guards.
  - [ ] Add watchdog re‑arm during hands‑free lock on unexpected stop.
  - [ ] Regression: 10x cold boots (expect activation stable, F5 armed ≤2s) and 20x hands‑free cycles (expect F5 continues to stop recording; never hands off to Dictation).

- Current status:
  - Activation/menu bar: stable in recent runs; keep monitoring.
  - F5 interception: unstable mid‑session; primary Tier‑1 risk now centers on unexpected teardown and shortcut source swapping.
