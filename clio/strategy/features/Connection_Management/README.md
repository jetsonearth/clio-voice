We did keep the same WebSocket open after manual fin, and we tried to reuse it for the next session. The logs confirm this (“Reusing READY socket — sent START without reconnect”). But Soniox rejected control frames on that reused socket (“Control request invalid type”) and Network.framework closed it shortly after. So, manual fin is not a dead TCP/WS stop in our code, but practically it behaves like one because the server won’t accept a new START on that same socket.

Thoughts on your workaround
•  Your idea is solid: don’t reuse the “finished” socket. Instead, after we send manual fin and get <fin>, immediately open a fresh standby WebSocket and keep it READY with keepalives, without sending audio until the user starts next recording.
•  Maintain an adaptive warm-hold for this standby socket:
•  Default hold: 60s (configurable).
•  Refresh the hold on user intent signals: lightweight UI shown, hotkeyDown, focus changes—each bumps the “expiresAt” another 60s.
•  Pause the countdown during active recording (do not tear down mid-session).
•  Never tear down while a connect is in-flight or while ready and about to be used.
•  Cap to one standby + one active connection to avoid overuse.
•  On startRecording:
•  If standby is READY, just send START on the standby socket (no reconnect), and promote it to “active”.
•  Immediately (in background) spin up a new standby socket again post-promotion, so we always have one hot spare for the next session.
•  On finalize:
•  Retire the active socket (close it cleanly).
•  Ensure the standby is connecting/READY; if not, start it now.
•  Keepalive/ping:
•  WS pings every ~20s, app-level keepalive/control every ~15s during idle standby.
•  If path flips (VPN/utun4), proactively re-establish the standby socket on the new path.

Why this works better
•  It avoids the Soniox protocol issue on reusing a “finished” socket.
•  It hides the 1–2s connect-to-ready by overlapping: the next session uses a socket that’s already READY.
•  The adaptive timer with refresh and pause semantics ensures we don’t accidentally tear down during an active session or right as the user starts one.

Defaults I’d suggest
•  warmStandbyHoldSeconds: 60 (refresh on intent to 60 again)
•  warmStandbyMaxCumulative: 300 (5 minutes) to avoid an endless zombie if the user never records again
•  keepalivePingInterval: 20s; app keepalive tick: 15s
•  intent refresh triggers: lightweight UI shown, hotkeyDown, resume-from-idle, manual fin completion

Net: manual fin isn’t a hard stop in our code, but reusing that same socket isn’t viable with Soniox. The standby-socket model you propose is the right workaround: always keep a fresh, READY socket alive (with an adaptive, refreshed timer), promote it instantly on record, and replenish the standby in the background.