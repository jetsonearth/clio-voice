## Assistant Mode and Wake-Word Activation (Draft)

Goal: Allow users to switch from transcript enhancement to an interactive assistant that answers questions or performs actions, activated by a wake phrase (e.g., “Clio, help …”).

Principles
- Non-blocking: ASR always streams; assistant mode does not delay capture.
- Privacy-first: wake-word detection runs locally; no audio sent until after activation.
- Explicit state: UI reflects when assistant mode is active and listening/responding.

States
- Enhancement Mode (default): current pipeline; OCR→NER for context, LLM postprocess transcript.
- Assistant Mode (activated): pipeline routes user utterances to Q&A/task execution flow.

Activation
- Wake phrase variants (configurable): “Clio”, “Clio help”, “Clio run”.
- Detection options:
  - Local keyword spotting (KWS) on-device (Porcupine, Vosk-KWS, or CoreML).
  - Optional fallback: text trigger if the first tokens in transcript match wake phrase.

Flow
1) Recording ongoing in Enhancement Mode.
2) Wake phrase detected locally → transition to Assistant Mode.
3) Capture current context (reuse cached OCR/NER) and build Assistant prompt (tools, persona, safety).
4) Route user utterances to Assistant LLM; stream responses to UI.
5) Optional tools: file ops, clipboard, code edits (behind user consent gates).
6) Exit on command (“stop assistant”) or timeout of inactivity.

Prompts
- System: Assistant capabilities, tool schema, safety rails.
- Context: Reuse cached NER, window metadata (bundle/title/url), minimal OCR snippets.
- User: raw ASR (cleaned) since last assistant turn.

Latency & RPM
- Prewarm Assistant LLM channel separately from Enhancement prewarm.
- Debounce wake detection to avoid flapping.
- Rate-limit tool calls; batch low-priority actions.

Telemetry
- Track activations, false positives, time-in-assistant, tool usage.

MVP Scope
- Text-only answers in overlay.
- Wake via transcript trigger (“Clio …”) before adding audio KWS.
- No tools; just context-aware Q&A.

V2
- On-device KWS; add simple tools (copy result, open link, run command with confirm).

## Assistant Mode and Wake-Word Activation (Draft)

Goal: Allow users to switch from transcript enhancement to an interactive assistant that answers questions or performs actions, activated by a wake phrase (e.g., “Clio, help …”).

Principles
- Non-blocking: ASR always streams; assistant mode does not delay capture.
- Privacy-first: wake-word detection runs locally; no audio sent until after activation.
- Explicit state: UI reflects when assistant mode is active and listening/responding.

States
- Enhancement Mode (default): current pipeline; OCR→NER for context, LLM postprocess transcript.
- Assistant Mode (activated): pipeline routes user utterances to Q&A/task execution flow.

Activation
- Wake phrase variants (configurable): “Clio”, “Clio help”, “Clio run”.
- Detection options:
  - Local keyword spotting (KWS) on-device (Porcupine, Vosk-KWS, or custom CoreML).
  - Optional fallback: text trigger if the first tokens in transcript match wake phrase.

Flow
1) Recording ongoing in Enhancement Mode.
2) Wake phrase detected locally → transition to Assistant Mode.
3) Capture current context (reuse cached OCR/NER) and build Assistant prompt (tools, persona, safety).
4) Route user utterances to Assistant LLM; stream responses to UI.
5) Optional tools: file ops, clipboard, code edits (behind user consent gates).
6) Exit on command (“stop assistant”) or timeout of inactivity.

Prompts
- System: Assistant capabilities, tool schema, safety rails.
- Context: Reuse cached NER, window metadata (bundle/title/url), minimal OCR snippets.
- User: raw ASR (cleaned) since last assistant turn.

Latency & RPM
- Prewarm Assistant LLM channel separately from Enhancement prewarm.
- Debounce wake detection to avoid flapping.
- Rate-limit tool calls; batch low-priority actions.

Telemetry
- Track activations, false positives, time-in-assistant, tool usage.

MVP Scope
- Text-only answers in overlay.
- Wake via transcript trigger (“Clio …”) before adding audio KWS.
- No tools; just context-aware Q&A.

V2
- On-device KWS; add simple tools (copy result, open link, run command with confirm).

