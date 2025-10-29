# Incident Report: iMac mic selected, but no visualizer movement and empty transcripts (silent input)

Date: 2025-08-19 03:48Z
Reporter: Agent Mode
File analyzed: bug-reports/log_list/xiaoya_log.txt

## Summary
Two consecutive sessions show that:
- The audio tap is installed and delivering buffers (first_buffer appears quickly).
- The WebSocket is bound and becomes ready (session 1 immediately; session 2 after a brief reconnect).
- No ASR tokens are produced (no raw_final/partial lines at all), and the final transcript is empty both times.

This pattern strongly indicates that the audio signal frames reaching the app/ASR are effectively silent (near-zero amplitude), not a network/WS issue.

## Evidence with timestamps
Time base: `t=` values are milliseconds since app start. Lines below are quoted from xiaoya_log.txt.

Session 1
- 13,898 ms: session_start
  - `t=013898 sess=8t8 lvl=INFO cat=transcript evt=session_start`
- 14,006 ms: input_selected = iMac麦克风 (ch=1)
  - `t=014006 sess=8t8 lvl=INFO cat=audio evt=input_selected name=iMac麦克风 ch=1 uid_hash=-2290550308593812417`
- 14,154 ms: ws_bind attempt_1
  - `t=014154 sess=8t8 lvl=INFO cat=stream evt=ws_bind socket=...@attempt_1`
- 14,215 ms: first_buffer (audio tap active)
  - `t=014215 sess=8t8 lvl=INFO cat=audio evt=first_buffer`
- 15,207 ms: start_sent + ready (socket usable)
  - `t=015207 sess=8t8 lvl=INFO cat=stream evt=start_sent attempt=1`
  - `t=015207 sess=8t8 lvl=INFO cat=stream evt=ready socket=...@attempt_1 attempt=1`
- 22,412 ms: final text is empty; session_end
  - `t=022412 sess=8t8 lvl=INFO cat=transcript evt=final text=`
  - `t=022412 sess=8t8 lvl=INFO cat=transcript evt=session_end`

Session 2
- 29,940 ms: session_start
  - `t=029940 sess=8t8 lvl=INFO cat=transcript evt=session_start`
- 30,043 ms: input_selected iMac麦克风
  - `t=030043 sess=8t8 lvl=INFO cat=audio evt=input_selected ...`
- 30,235 ms: first_buffer
  - `t=030235 sess=8t8 lvl=INFO cat=audio evt=first_buffer`
- 30,645 ms: state=closed 1001
  - `t=030645 sess=8t8 lvl=WARN cat=stream evt=state code=1001 state=closed`
- 30,855 ms: ws_bind attempt_2
  - `t=030855 sess=8t8 lvl=INFO cat=stream evt=ws_bind socket=...@attempt_2`
- 32,705 ms: start_sent + ready (socket recovered)
  - `t=032705 sess=8t8 lvl=INFO cat=stream evt=start_sent attempt=2`
  - `t=032705 sess=8t8 lvl=INFO cat=stream evt=ready socket=...@attempt_2 attempt=2`
- 39,102 ms: final text is empty; session_end
  - `t=039102 sess=8t8 lvl=INFO cat=transcript evt=final text=`
  - `t=039102 sess=8t8 lvl=INFO cat=transcript evt=session_end`

Notably absent in both sessions:
- No `cat=transcript evt=raw_final` (or raw_partial) lines at all.

## Interpretation
- Audio capture pipeline is alive (first_buffer seen quickly twice).
- WebSocket connectivity is OK (ready achieved in both sessions; a brief reconnect in session 2).
- The ASR emits no tokens → the audio samples delivered are effectively silent.

## Likely causes on the iMac
- Input level/gain extremely low for the selected iMac microphone in macOS Sound settings.
- Interference from virtual/aggregate devices (seen: OrayVirtualAudioDevice; CADefaultDeviceAggregate). Even when iMac mic is selected, route/format quirks or aggregate defaults can result in zeroed frames to client apps.
- Less likely: per-app mic permission (we would not get first_buffer if permission was denied), or pure ASR failure (we’d expect errors or some tokens).

## Recommended user checks
1) macOS System Settings → Sound → Input
   - Ensure “iMac麦克风” is selected; raise the input level and confirm the OS-level meter moves while speaking.
2) Disable virtual/aggregate devices
   - Temporarily remove OrayVirtualAudioDevice and any aggregates. Reboot if needed, then retry with only the built-in mic.
3) Try a known-good input
   - Use AirPods mic or a USB mic. If the visualizer moves and transcript appears, the issue is specific to the built-in path on this machine.
4) Quick sanity check outside the app
   - Record in QuickTime for a few seconds with iMac mic; confirm the waveform shows real amplitude.

## App-side improvements (to self-diagnose next time)
- Add amplitude-based silence watchdog:
  - If maxAudioLevelSinceStart < threshold (e.g., 0.02) after 2–3s of first_buffer, log `audio evt=silence_detected {max_level}` and take recovery action (refresh tap → restart capture → force switch to built-in mic).
- Emit level snapshots periodically for visibility: `audio evt=level_snapshot {level, max_level}` every N packets.
- When final text is empty, emit a diagnostic postmortem line: `transcript evt=final_empty_diagnosis {duration_s, buffers, max_level, ws_retries}`.

## Conclusion
WebSocket is functioning; the problem appears to be silent input frames from the selected device path on this iMac. With user-level checks and app-side silence detection/recovery logs, we can both fix and confidently diagnose similar cases across other users.

---

## Update: 2025-08-19 ~05:30Z — Additional sessions with enhanced logs

Two more runs were captured with the new structured logging and the Compatibility Mode toggle (one ON, one OFF). Both show the same failure mode: initial valid audio, then sustained silence (-120 dB) and empty final transcript.

### Environment snapshot
- App version: 1.44.0
- Machine: iMac (Chinese locale for device name: "iMac麦克风")
- Input devices present at startup:
  - iMac麦克风 (built-in, 1 ch)
  - OrayVirtualAudioDevice (virtual, 2 ch)
- During session after route change, CoreAudio reported a transient synthesized aggregate:
  - CADefaultDeviceAggregate-… (common when defaults are manipulated or system re-evaluates routing)

### Session A: Compatibility Mode ON (input pinning enabled)
- Toggle: audio evt=compat_mode_toggle enabled=true
- Selected input: iMac麦克风 (uid_hash matches across logs)
- Pinning: device_pin_start → device_pin_verify ok=true (default input = iMac麦克风)
- Route change and device scan follow, including CADefaultDeviceAggregate-…
- Audio flow:
  - first_buffer received promptly
  - initial level approx -18 dB (valid signal)
  - later levels collapse to -120 dB (silence)
  - silence_detected fired after 3s below -50 dB
- Final transcript: empty

Excerpt:
```
t=042081 transcript session_start
t=042193 audio input_selected iMac麦克风
t=042209 audio device_pin_start … desired=prev=iMac麦克风 id=80
t=042282 audio device_pin_verify ok=true current=desired=iMac麦克风 id=80
t=042287 audio route_change devices_changed
t=042287 audio current_default id=80 name=iMac麦克风
t=042288 audio devices … includes CADefaultDeviceAggregate-4827-0, OrayVirtualAudioDevice
t=042386 audio first_buffer
t=042389 audio level avg_db=-18
…
t=044488 audio level avg_db=-120
t=045591 audio silence_detected device=iMac麦克风 threshold_db=-50 duration_s=3
…
t=054742 transcript final text=
```

### Session B: VoiceInk-style (Compatibility Mode OFF — no system pinning)
- No device_pin_* logs as expected
- Route change triggered devices_changed; current_default confirmed as iMac麦克风
- Audio flow:
  - first_buffer received promptly
  - initial level approx -24 dB (valid)
  - later levels collapse to -120 dB
  - silence_detected fired
  - Intermittent brief recoveries to ~-13 to -16 dB seen after reselecting the same input, but then back to -120 dB
- Final transcript: empty

Excerpt:
```
t=011021 transcript session_start
t=011129 audio input_selected iMac麦克风
t=011223 audio route_change devices_changed
t=011223 audio current_default id=80 name=iMac麦克风
t=011224 audio devices … includes CADefaultDeviceAggregate-4876-0, OrayVirtualAudioDevice
t=011323 audio first_buffer
t=011326 audio level avg_db=-24
…
t=013426 audio level avg_db=-120
t=014528 audio silence_detected threshold_db=-50 duration_s=3 device=iMac麦克风
…
t=017772 audio level avg_db=-13  (brief recovery)
…
t=019875 audio level avg_db=-120
…
t=032184 transcript final text=
```

### Observations (Sessions A & B)
- Input selection is correct and stable per logs; default input remains iMac麦克风 (verified by current_default).
- Initial buffers carry non-zero audio (levels around -24 to -18 dB), proving capture path is alive initially.
- Without any explicit app-side device switch, levels drop to -120 dB and remain there for long stretches.
- Presence of virtual and aggregate devices (OrayVirtualAudioDevice, CADefaultDeviceAggregate-…) correlates with the onset of silence, even when not selected.
- The behavior reproduces with both modes (with and without system pinning), so the root cause is likely external routing/driver behavior rather than our pinning logic.

### Hypothesis (re-evaluated 2025-08-19 ~07:55 Z)
The evidence now points to an **implementation issue in Clio’s audio-capture path** rather than a fundamental hardware or macOS driver limitation.

Supporting facts:
- **Wispr Flow works** on the same iMac/MacBook Air with the built-in mic, so the hardware/driver stack *can* deliver real audio samples.
- Clio’s own logs show **valid levels (~-18 dB) for the first few buffers** before collapsing to –120 dB, implying the input graph becomes silent *after* start-up.
- The failure occurs with and without system pinning, so merely changing the default device is not the trigger.

Most plausible software pitfalls to investigate:
1. **Graph not being pulled** – if nothing downstream consumes audio frames, CoreAudio renders silence.
2. **Channel mismatch** – built-in mic is mono; if we average ch1+ch2 we might read an empty channel.
3. **Format negotiation** – requesting stereo/16 kHz when the device is mono/48 kHz can lead CoreAudio to zero-fill.
4. **Route-change handling** – reconnecting nodes with an incompatible format after a device change can brick the stream.

### Proposed remediation plan (app-side)
- Extend Compatibility Mode to also pin output to Built-in Output during session (restore on stop):
  - Implement getDefaultOutputDevice()/setDefaultOutputDevice()
  - Emit audio evt=output_pin_start, output_pin_verify, output_restore
- Add audio evt=current_default_output logs mirroring input logs at:
  - session_start
  - every route_change
  - silence_detected
- On silence_detected (sustained below threshold):
  - If default output is not built-in, auto-switch to Built-in Output and restart the tap (still in Compatibility Mode); log audio evt=auto_switch_output
- Keep VoiceInk-style as default; these behaviors only apply when Compatibility Mode is enabled.

### User-side mitigations to try on affected machine
- System Settings → Sound: Input = iMac microphone; Output = Built-in speakers.
- Control Center mic mode: set to Standard (not Voice Isolation) for the active app.
- Audio MIDI Setup: remove/disable Aggregate Device and Mixed Input; unload Oray/other virtual drivers; reboot if needed.
- As a last resort: restart CoreAudio daemon (sudo killall coreaudiod), then retry.

### Immediate next-steps checklist
- [ ] Log per-channel RMS (lvl0, lvl1, …) in the input tap to catch channel-selection issues.
- [ ] Guarantee the graph is rendered by connecting a muted mixer → output (or use manual-render mode).
- [ ] Add a runtime flag to switch between **AVAudioEngine** (current) and an **AVCaptureSession** backend for quick A/B tests.
- [ ] Keep the existing silence watchdog; on trigger, restart the engine and prompt the user to change input if silence persists.
- [ ] Once capture is reliable, *optionally* add output pin/verify/restore under Compatibility Mode.
- [ ] Re-test on the affected iMac/MacBook Air and compare against Wispr Flow.

---

## Update: 2025-08-19 ~08:58 Z — New "fcj" session & Voice-Processing I/O Plan

### What we just tested
A fresh diagnostic build (bundle ID **com.cliovoice.clio**) was run on the same iMac.  The key log excerpt:

```
t=012161 audio first_buffer          # good audio
…
t=012164 audio level avg_db=-13      # healthy level
…
t=012064 audio route_change devices_changed  # **before** silence starts
…
t=014263 audio level avg_db=-120     # silence continues
…
t=015367 audio silence_detected …
```

Observations:
1. We *do* receive valid audio right after the tap is installed.
2. A CoreAudio **route change** fires (devices_changed) and immediately after that all samples are zero (-120 dB).
3. Re-pinning the built-in mic briefly restores signal (-9 dB) but it collapses again within seconds.
4. The behaviour is identical with **Compatibility Mode ON and OFF** (i.e. with and without system-wide device pinning).

### What *didn’t* work so far
- System pinning of the default input device.
- Re-starting the tap after silence_detected.
- Leaving the system default unchanged (VoiceInk-style).

Both paths still end up with zero samples once CoreAudio wiggles the device routing.

### Why we’re trying **Voice-Processing I/O** next
`kAudioUnitSubType_VoiceProcessingIO` (aka "voice-processing unit") is Apple’s purpose-built duplex audio unit that:
- Wraps the HAL and **keeps the capture thread running** even when CoreAudio briefly moves the default device.
- Provides built-in noise suppression, echo cancellation and AGC similar to WebRTC.
- Exposes separate **input and output busses**, so we can tap the processed mic stream while muting playback.
- Is the same building block Apple recommends for real-time VoIP and dictation (see WWDC 2023 session 10256).

Expected outcome:
- After switching the engine to use Voice-Processing I/O, the capture path should **survive transient device/route changes** instead of quietly zero-filling.
- We should no longer see large stretches of ‑120 dB after the first healthy buffer.
- If the theory is wrong, we can still fall back to `AVCaptureSession` by flipping the `CaptureBackend` runtime flag.

### Implementation notes
- We will attach a `AVAudioUnit` using the component description `{ kAudioUnitType_Output, kAudioUnitSubType_VoiceProcessingIO, kAudioUnitManufacturer_Apple }`.
- The input bus (1) will be connected to our main mixer and tapped; the output bus (0) will be routed to a muted mixer to satisfy the graph.
- Auto-restart logic will call `audioEngine.start()` again inside `configurationChangeHandler`.
- All new behaviour is **behind the existing runtime flag** so we can toggle it without rebuilding.

### Next experiments
1. Implement Voice-Processing I/O + auto-restart and ship a test build.
2. Collect logs on the failing iMac and MacBook Air.
3. If silence still occurs, enable `CaptureBackend = AVCaptureSession` for an A/B test.

*End of update*
- [ ] Log per-channel RMS (lvl0, lvl1, …) in the input tap to catch channel-selection issues.
- [ ] Guarantee the graph is rendered by connecting a muted mixer → output (or use manual-render mode).
- [ ] Add a runtime flag to switch between **AVAudioEngine** (current) and an **AVCaptureSession** backend for quick A/B tests.
- [ ] Keep the existing silence watchdog; on trigger, restart the engine and prompt the user to change input if silence persists.
- [ ] Once capture is reliable, *optionally* add output pin/verify/restore under Compatibility Mode.
- [ ] Re-test on the affected iMac/MacBook Air and compare against Wispr Flow.

