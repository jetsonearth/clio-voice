# Clio Bug Report: Mac Mic Audio Not Captured (Ivan & Xiaoya)

## Executive Summary

On certain iMac machines (specifically Ivan's and Xiaoya's), Clio fails to transcribe any content when using the **built-in Mac microphone**, despite functioning perfectly with **AirPods** on the same machines and working normally on other users' machines (Jane and Jetson) with Mac mics.

The failure mode is consistent: the app reaches `ready`, receives initial `first_buffer`, but **never emits any `send_audio` packets** to the ASR server. Consequently, no transcript is ever generated, and the session ends with an empty `final` result.

This behavior is **not caused by device permissions, WebSocket/network issues, or AVAudioEngine initialization**, all of which complete successfully. The core observable fault is the complete absence of outbound audio transmission (`send_audio`) despite proper session setup.

---

## Dataset Reviewed

6 session logs were reviewed, covering 4 unique users:

| User       | Input Device     | Result | `send_audio` | `final` text |
|------------|------------------|--------|--------------|---------------|
| Ivan       | AirPods          | ✅ OK  | ✅ Present   | ✅ Present    |
| Ivan       | Mac Mic          | ❌ Bug | ❌ Absent    | ❌ Empty      |
| Xiaoya     | AirPods          | ✅ OK  | ✅ Present   | ✅ Present    |
| Xiaoya     | Mac Mic          | ❌ Bug | ❌ Absent    | ❌ Empty      |
| Jane       | Mac Mic          | ✅ OK  | ✅ Present   | ✅ Present    |
| Jetson     | Mac Mic          | ✅ OK  | ✅ Present   | ✅ Present    |

---

## High-Level Observations

### ✅ What Works in All Cases:
- `stream evt=ready` always fires (WS connected and initialized)
- `first_buffer` always appears (indicates capture + tap worked)
- `input_selected` appears and updates correctly
- Logs confirm that the selected mic device is `iMac麦克风` (Mac built-in mic) in the failing sessions
- `route_change` / `devices_changed` fires in **both** healthy and failing sessions (not a discriminant)

### ❌ What Fails Uniquely in Buggy Runs (Ivan-MacMic and Xiaoya-MacMic)
- No `send_audio` packets are ever emitted (despite `ready` and `first_buffer`)
- No `raw_partial`, `raw_final`, or `final` transcription tokens are generated
- Sessions end with: `final text=` (empty)
- Sometimes `silence_detected` appears, but **not always** (e.g., Xiaoya-MacMic logs show failure without `silence_detected`)

### 🟡 AirPods Appear to Work Reliably
- Same machines (Ivan, Xiaoya) succeed using AirPods
- Sessions with AirPods exhibit proper `send_audio` behavior and receive token outputs

---

## Concrete Evidence from Logs

### 🟥 Ivan-MacMic (Failing)
- `ready` fires → `first_buffer` received → `input_selected: iMac麦克风`
- No `send_audio` ever logged
- `silence_detected 3000ms @ level=-50.7 dB`
- No transcript tokens appear
- Session ends with: `final text=`

### 🟩 Ivan-AirPods (Working)
- `ready` fires → `first_buffer` received → `send_audio seq=50/100/150...`
- `raw_final`, `final` emitted successfully

### 🟥 Xiaoya-MacMic (Failing)
- Multiple `ready` events
- Multiple `input_selected: iMac麦克风`
- **Never** emits `send_audio`
- `final text=` blank in all 4 retry attempts

### 🟩 Xiaoya-AirPods (Working)
- `ready` → `send_audio` → `raw_final` → `final` emitted
- Even after a `route_change`, session resumes correctly

### 🟩 Jane-MacMic (Working)
- Multiple successful runs
- In each case, `send_audio` appears right after `ready`
- Tokens are emitted every time

### 🟩 Jetson-MacMic (Working)
- Stable behavior under multiple restarts and even device churn (many devices present)
- `send_audio` packets present and transcripts consistently generated

---

## Key Patterns & Differential Signal

- The single observable difference between all good and bad runs is the **absence of `send_audio` after `ready`**
- `first_buffer` is present in all cases, so capture is not broken
- No evidence of HAL or audio engine failure
- WebSocket is stable and binds cleanly (`ws_bind` → `ready`)
- In healthy logs, `send_audio` appears within 0.5–1.5s of `ready`
- In failing logs, even after multiple restarts or route changes, **`send_audio` is never sent**

---

## Open Questions for Deeper Investigation

1. **What conditions must be met for the transport to start sending audio?**
   - Is there a gating condition tied to dB levels, VAD, or buffer duration?

2. **Is the `send_audio` loop waiting on a state that never flips to "ready" after reselection or silence detection?**

3. **Is there a meter/VAD logic mismatch between capture thread and transport sender?**
   - Could a channel mismatch or very quiet input cause the sender logic to stall?

4. **Is the state machine for stream transitions too strict?**
   - E.g., does it require both non-silent input *and* some initialization complete signal before triggering `send_audio`?

5. **Are we sampling the wrong channel or buffer post-rebind?**
   - If the built-in mic is mono and something expects stereo, is a zero channel being averaged in?

6. **Is the first 1–2s of PCM ever sent on Ivan/Xiaoya-MacMic?**
   - No data in logs → a WAV dump (`/tmp/clio_probe.wav`) would confirm

---

## Hypothesis Summary (non-prescriptive)

- Issue is **not backend, engine, or permissions-related**
- Route churn is survivable; Jetson’s logs prove it
- AirPods work because they provide a steady noise floor that may trip a gating condition
- Built-in mic may idle too low to trigger “send audio” state under quiet conditions
- The bug is likely in **app-side gate or state machine**, not in ASR, WebSocket, or audio HAL

---

## Recap of Repro Conditions

To trigger the bug:
- Use Ivan or Xiaoya’s iMac
- Select the built-in microphone
- Start a Clio session, speak normally
- Observe `first_buffer` and `ready` logs appear, but **no `send_audio` emitted**
- Session ends with empty `final`

To avoid bug:
- Use AirPods (or any other input with higher ambient floor)
- Same machine, same app version → works perfectly

---

## Suggestion for Debug Continuation

The next step is for a deep review of the logic that connects:
- `stream.ready`
- `first_buffer`
- `gate_state`
- `transport.send_audio`

The logs indicate all systems are running, but **something in the client application is blocking outbound PCM**. The gate is either too strict or mis-triggered.

No single point shows ASR, WS, or HAL failure.

This behavior should be reproducible and observable with additional instrumentation or forcing conditions (e.g. synthetic audio input, gate override).

End of report.

