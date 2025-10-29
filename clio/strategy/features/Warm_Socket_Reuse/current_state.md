Short debrief and recommendation

Where we are right now

•  Socket lifecycle
•  We open one Soniox websocket, send START/config once, and keep it open across hotkey sessions (warm hold).
•  Between hotkey sessions we do not re-send START on the same socket (after seeing 400 invalid control errors when trying that).
•  On key up, we now:
◦  Drain the send queue.
◦  Strictly wait for the <end> token up to 2s; if still not seen, send one manual finalize and wait briefly for <fin>/finished.
◦  If <end> was seen, we currently skip manual finalize for latency. We then keep the socket in warm-hold for up to 60s with keepalives.
•  On hotkey down (next session), we reuse the same open socket and restart the listener; audio is sent immediately (no new START).
•  Audio pipeline
•  Unified capture path with TEN‑VAD, FIFO send actor, prebuffering and flush on initial connect, and a 1s speech watchdog intended to force mid‑recording recovery if you speak but no tokens arrive.
•  What’s working
•  Cold start path works well: connect, send START, flush prebuffer, get tokens, <end> arrives, low latency.
•  Some warm reuses work (session #2 in the log).
•  What breaks intermittently
•  Warm reuse sometimes yields “no tokens at all” (your session #3):
◦  Audio tap is alive and sending.
◦  Listener is restarted.
◦  No <end> arrives, manual finalize produces no text, final transcript is empty.
◦  No 4xx error frame arrives from the server (at least none logged).
◦  The speech watchdog didn’t recover the session (didn’t fire, or fired too late).

Why does “keep one socket and only gate audio” sometimes fail?

•  Protocol/state mismatch on server side
•  Many ASR WS implementations support “one session, multiple utterances” gated only by endpoint detection. However, some require an explicit boundary reset between utterances. With Soniox, evidence is mixed:
◦  Re-sending START on an already-open session produced 400 invalid control errors (so START is not allowed mid-session).
◦  Skipping finalize after <end> may leave the server’s internal state in a condition where it expects a “segment boundary” signal that we’re not sending. When this happens, sending more audio may be ignored, leading to the “no tokens” symptom you saw in session #3.
•  Race/ordering risks
•  On reuse we cancel/restart the listener and immediately begin sending audio. If the server requires seeing some control/boundary or if we start sending before the listener is actually reading, we could miss an early warning/error frame or leave the server stuck waiting for a boundary it never gets.
•  Watchdog didn’t rescue
•  The speech watchdog should hard-reconnect if you’re speaking and no tokens arrive within 1s. The fact it didn’t fire suggests a gating condition wasn’t satisfied (e.g., speakingNow check or bytesSinceFirstSpeech threshold), or a race with webSocketReady/startTextSent flags on reuse.

Bottom line on “single continuous stream and gate audio only”
•  It’s theoretically doable if the server truly supports multi-utterance sessions without any control reset. In practice, with Soniox’s current behavior, it’s brittle. The 400 on re-START confirms they don’t accept a repeated config mid-session. If they also sometimes require an explicit end/finalize cycle to accept the next utterance, pure audio gating will intermittently fail the way you observed.

What we should change immediately (low-risk hardening)

•  Always send finalize at stop
•  Even when <end> is seen, send a quick finalize and wait up to ~300 ms for <fin>/finished. This cleanly ends the server-side “segment” and reduces the chance the next utterance starts in a confused state.
•  Beef up watchdog observability
•  Log when the speech watchdog arms, its deadline, and why it fires or doesn’t fire (conditions snapshot). If we still see a no-token reuse, automatically force a mid-recording recovery (disconnect/reconnect) at 1s to salvage the session.
•  Add clear, bounded reuse grace
•  You already wait a reuse grace period; keep it, but make sure we never start sending audio until the listener is running, and we’ve confirmed the previous session received <fin> or we sent finalize.

If that still flakes: adopt the per‑utterance socket plan (your second approach)

Your proposal, refined to avoid the START-400 and idle timeouts:

•  Core idea
•  Use one socket per utterance, but pre-connect the next socket in the background so TTFT stays low.
•  Concrete flow
•  On key up:
◦  Drain -> wait for <end> (<=2s) -> send finalize (always) -> short wait for <fin> (<=300–500ms) -> close socket.
◦  Immediately begin creating the next socket in the background. Connect it (WS handshake) but do NOT send START yet.
•  Warm standby (idle, 60s max):
◦  Keep the standby connection alive with keepalives. Don’t send START; that avoids the server starting a segment and timing out on silence, dont send any audio to server because users maybe speaking while they are thinking, and they might not want their thoughts transcribed. They are ready to transcribe when they pressed key down again.
•  On key down:
◦  If standby is connected, send START/config as the very first frame, then flush any prebuffered audio. This is a single frame and should be near-instant (tens of ms) because the WS is already open (should just be like how we are doing the normal connect, but make sure, do we really send START/config?)
◦  If no standby (or it aged out), fall back to normal connect; buffer and flush as we do today.
•  On key up:
◦  Finalize, close active socket, spawn next standby again.
•  Pros
•  Each utterance gets a fresh server state; no mid-session START needed (so no 400).
•  Latency remains low because the handshake is paid ahead of time; START on an open socket is cheap.
•  Eliminates the hardest class of warm-reuse failures (server lingering state across utterances).
•  Cons / caveats
•  More lifecycle complexity (manage an “active” and a “standby” socket).
•  Must keep idle keepalives to avoid server 20s timeouts and suppress benign 408 after close.
•  Ensure we never send audio before START on the active socket.

Why this should solve your third-session failure
•  The failure is almost certainly a server-side state boundary issue. Per-utterance sockets give you a clean state every time while still being “warm.” By sending START exactly once per socket (and only on that new socket), we avoid the protocol violation (400) and avoid relying on server heuristics to accept new audio after an <end> without finalize.

Answering your core question directly

•  Is the “single stream, only gate audio” path doable? Possibly, but it’s unreliable with Soniox’s current websocket semantics. Without a documented “new utterance/reset” control you can send between hotkey sessions, pure gating will continue to be fickle. When it works, it’s great; when it doesn’t, it fails silently as you’ve seen.
•  Is the per-utterance “standby socket” plan viable? Yes. It is the robust way to get the benefits of warmth without protocol ambiguity:
•  Open socket A + START on first use → transcribe → finalize + close.
•  Immediately open socket B (standby, no START yet).
•  On next hotkey down, send START over B and go.
•  Repeat.

Suggested next steps

•  Quick hardening (keep current model):
•  Change stop to always send finalize (even after <end>), 300 ms wait for <fin>.
•  Add explicit logs when the speech watchdog arms/fires with condition dumps.
•  If watchdog fires, hard-reconnect mid-session.
•  If any “no tokens on reuse” reappears after this, switch to the per‑utterance standby model:
•  Implement a second socket state (standby) with connect-only and no START until keydown.
•  Use idle keepalives on standby, 60 s TTL.
•  On keydown, START + flush; on keyup, finalize + close active; spawn a fresh standby.

----

there are one thing requring changes: "Drain -> wait for <end> (<=2s) -> send finalize (always) -> short wait for <fin> (<=300–500ms) -> close socket." - i have noticed that wait for <end> doesn't necessarily work because u might be in the middle of speaking and u pressed key up to stop recording, but since endpoint detection detects speech end semantically, u might not see the end arrives in 2s. i think i have already solved this in my current impelmentations (pls check my code) because i noticed that one time, i was speaking non stop and theres no endpoint detected and then 30s in i pressed key up to stop transcription, what happened was, it only sent 1 setnece to llm, while i had 5 setnenes but since i was speaking too fast, it didnt do it right

it used to be using manual finalziation to solve this - when i am done speaking, exactly when i finsh, i send hotkey up and manual fin fires so server waits 500-700ms for that fin to arrive. but now i am using endpoint detection so its differnet. the goal is trying to minimize the wait on the manual fin as much as possible

actually, i have a differnet idea 

why dont we both wait for <end> and also send manual fin at the exact same time? then whichever comes first makrs the final transcript?

so for endpoint detection, make sure at the moment of stop recording finish, we wait for audio queue to drain (so no more partial transcript will arrive from soniox) and then we commit the rest of the partial transcirpt if theres no <end> flag arriving or if after the most recent <end>, there are still text left, we put all of these as the complete transcript and send to llm

usually endpoint detection will be much faster than manual fin

i hope this makes sense?