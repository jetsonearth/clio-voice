# Incident Report: Rare WS reconnect + large prebuffer leading to truncated transcript

Date: 2025-08-19 03:36Z
Reporter: Agent Mode (analysis based on provided logs)
Files analyzed:
- bug-reports/log_list/jane_log2.txt
- bug-reports/log_list/jetson(me)_log.txt

## Summary
On Jane’s machine, one session exhibited a long delay before the WebSocket became ready. During that delay, audio was captured (first_buffer) and buffered locally while multiple reconnect attempts occurred. The prebuffer grew to ~10 seconds of audio. Once the socket finally became ready, only a short final transcript was produced, indicating the backlog was only partially consumed by the ASR service (or truncated by endpoint heuristics). Other sessions on both machines look healthy and follow the expected lifecycle.

This is a rare but important edge case: “mic is on, but UI shows loading and no streaming text for many seconds; when text appears, it is only part of what was spoken.”

## Evidence (with timestamps)
Time base: `t=` values are milliseconds since app start. Delays are the difference between the `t=` values.

From jane_log2.txt, problematic session (Session 2):

1) Session start and immediate audio capture
- 27,484 ms: transcript session_start
  - `t=027484 sess=Yhq lvl=INFO cat=transcript evt=session_start ...`
- 27,837 ms: audio first_buffer (microphone is live; audio tapping works)
  - `t=027837 sess=Yhq lvl=INFO cat=audio evt=first_buffer`
- 27,840 ms: stream send_audio seq=0 (we start queuing frames, but socket isn’t ready yet)
  - `t=027840 sess=Yhq lvl=INFO cat=stream evt=send_audio seq=0 bytes=3200`

2) WebSocket closes and reconnect attempts
- 28,233 ms: stream state=closed code=1001 (first socket attempt dropped)
  - `t=028233 sess=Yhq lvl=WARN cat=stream evt=state code=1001 state=closed`
- 28,433 ms: ws_bind attempt_2
  - `t=028433 sess=Yhq lvl=INFO cat=stream evt=ws_bind socket=...@attempt_2`

3) Prebuffer growth (evidence of continued audio capture while waiting)
- 33,218 ms: prebuffer packets=50 bytes=160000  → roughly 5 seconds of audio
  - `t=033218 sess=Yhq lvl=INFO cat=stream evt=prebuffer packets=50 bytes=160000`
- 38,221 ms: prebuffer packets=100 bytes=320000 → roughly 10 seconds of audio
  - `t=038221 sess=Yhq lvl=INFO cat=stream evt=prebuffer packets=100 bytes=320000`

4) Socket finally binds and becomes ready (long delay from session_start)
- 40,950 ms: ws_bind attempt_3
  - `t=040950 sess=Yhq lvl=INFO cat=stream evt=ws_bind socket=...@attempt_3`
- 41,801 ms: start_sent and ready
  - `t=041801 sess=Yhq lvl=INFO cat=stream evt=start_sent attempt=3`
  - `t=041801 sess=Yhq lvl=INFO cat=stream evt=ready attempt=3 ...`

Delay to ready (evidence):
- session_start → ready: 41,801 − 27,484 = 14,317 ms (≈ 14.3 s)
- first_buffer → ready: 41,801 − 27,837 = 13,964 ms (≈ 14.0 s)
- prebuffer grew to ~10 s during the wait, confirming continuous capture while the socket was not ready.

5) Outcome: short final transcript compared to expected speech content
- 45,366 ms: transcript final text = 我在Jane的电脑上测试 (short sentence)
  - `t=045366 sess=Yhq lvl=INFO cat=transcript evt=final text=我在Jane的电脑上测试`

By contrast, Jane’s sessions 1 and 3, and all of Jetson’s sessions, show the healthy flow with minimal delay to ready and no extended prebuffer.

## Likely cause
- Transient network or TLS/WS condition caused an early socket closure (code 1001) and delayed successful bind/ready.
- During the ~14 s wait to ready, our app kept capturing audio and buffering it locally (as designed). The backlog reached ~10 s (`prebuffer` lines), which some ASR backends can partially drop or mishandle upon late flush due to endpoint detection, timeouts, or input framing constraints.
- Net effect: When finally connected, only a portion of the buffered audio was processed, producing a truncated final transcript.

Notes:
- This looks like an interaction between transient network state and the ASR service’s handling of large delayed backlogs. Our app’s behavior (buffer while connecting, then flush) is correct in principle, but we should make it more robust around large prebuffer and delayed readiness.

## Recommendations
Short-term mitigations (low risk):
- Add explicit flush logging around backlog handling so we can see exactly how many packets/bytes get flushed after `ready`:
  - `stream evt=flush_start {packets, seconds, bytes}`
  - `stream evt=flush_done {packets_sent, ms}`
- Cap prebuffer duration (e.g., 5–6 s). If exceeded before `ready`:
  - Option A (simpler): restart audio capture on reconnect and discard stale backlog with a user notice ("Reconnected — please repeat the last sentence").
  - Option B (advanced): split and pace backlog flush to avoid server throttling.
- For sessions starting with large prebuffer, temporarily relax endpoint detection parameters (e.g., increase `max_non_final_tokens_duration_ms`) for the initial chunk to reduce premature finalization.
- Surface UI status when `ready` is delayed ("Connecting… buffering Xs") to set expectations.

Longer-term improvements:
- Implement adaptive recovery when `state=closed` occurs within the first second of a session: pause capture briefly, rebind, then resume with a fresh start to minimize backlog.
- Add telemetry to correlate “ready latency” distribution and backlog size across users to identify affected environments (VPNs, specific Wi‑Fi setups).

## Are successful transcriptions similar across machines?
Yes. Healthy sessions on different computers follow the same shape:
- `session_start` → `first_buffer` → `ws_bind` → `start_sent` → `ready` → `raw_final` chunks → `final` → `llm_final` → `insert_result ok`.
Minor timing variance is normal; multi‑second `ready` delays with growing `prebuffer` are red flags.

## Clarification on the `t=` field
- `t=` is in milliseconds since app start. To compute intervals, subtract `t=` values. In the problematic session, `ready` at 41,801 ms minus `session_start` at 27,484 ms gives ≈ 14.3 s.
- We can optionally add human-readable deltas to the logs (e.g., `lat_ms=14317`) if desired.

## Preparedness for iMac test (no visualizer movement)
Current logs that help diagnose “no mic level / no transcript”:
- `audio evt=input_selected` (device name/uid_hash/channels)
- `audio evt=first_buffer` (first audio frame observed)
- `audio evt=first_buffer_timeout` with actions `tap_refresh` or `restart_capture` (watchdog)
- `AUDIO HEALTH` logs about silence and recovery
- `stream evt=ws_bind/start_sent/ready/state` to see connection state

If the visualizer doesn’t move and `first_buffer` never appears, it indicates tap/engine setup issues or a bad input route. Our watchdog should emit `first_buffer_timeout` and attempt recovery; those lines will be key. If they’re missing, we should add more guard logs around tap installation and `start` failures (e.g., explicit logging for `-10877` retries and final failure codes).

Suggested extra logging (optional):
- On tap install: explicitly log hardware sampleRate/channelCount and selected device again.
- On engine start retry loops: log `attempt`, `nsError.code` (especially `-10877`) and cumulative backoff spent.
- On forced device switch to built-in mic: log before/after device identities.

## Conclusion
This was a rare reconnect + backlog edge case. The core app logic is sound, but large prebuffer windows during delayed WS readiness can lead to partial/transient ASR results. The recommended mitigations (flush logs, prebuffer cap with recovery, relaxed endpoint detection on reconnect, and clearer UI) should make the behavior more robust and diagnosable.

