# Clio

**macOS dictation that feels personal, intentional, and yours**

[![License](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
![Platform](https://img.shields.io/badge/platform-macOS%2014.0%2B-brightgreen)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)

---

## A Builder's Note

In January 2025 I opened a blank Swift file with a simple promise to myself: *maybe voice could make my Mac feel quieter*. I had never shipped a macOS app, never lived inside AppKit, and definitely did not expect to learn audio pipelines, CoreML quirks, and Accessibility APIs all at once. Clio began as a private tool so I could think out loud, transcribe fast, and keep everything on my machine.

Somewhere between debugging hotkeys at 2 a.m. and teaching myself SwiftUI by brute force, the project stopped being “for me only.” Dictation deserves to be infrastructure—not a gated SaaS add-on or yet another subscription. So I’m open-sourcing the entire stack, hoping other builders will treat voice as a primitive we can improve together. If you are reading this, consider it an invitation to add your own rituals, shortcuts, and ideas to Clio.

---

## Why Clio Exists

- **Voice as infrastructure**: A locally owned pipeline that slots into any workflow instead of asking you to relocate your thoughts to a web app.
- **Privacy without performance trade-offs**: Whisper.cpp, Metal acceleration, and the Keychain mean fast transcription with zero server round-trips.
- **Context-aware by default**: PowerMode watches which app or URL you’re in and reshapes prompts, models, and formatting in real time.
- **For builders, writers, and tinkerers**: Pull it, fork it, gut it—Clio is documented, scriptable, and ready for your own experiments.

---

## What You Get

### 🎙️ Fluent Dictation
- 200 wpm transcription backed by Whisper Flash/Turbo or your own fine-tuned models
- Push-to-talk, hold-to-record, and automatic cursor insertion
- Multi-language support with confidence scoring and inline correction commands

### 🧠 Context & Enhancement
- PowerMode profiles for writing apps, IDEs, browsers, and any bundle identifier you care about
- Optional AI enhancement that routes through Groq, Soniox, OpenAI, Anthropic, or local Ollama models
- Custom prompts and style presets (“memo,” “stand-up notes,” “support ticket,” etc.)

### 🔒 Local-First Security
- Audio never leaves the device unless you explicitly wire up a cloud provider
- API keys live in the macOS Keychain
- Automatic cleanup of temporary recordings and transcripts

### ⚙️ Integrations & Extensibility
- Whisper.cpp submodule for on-device inference
- Sparkle-powered updates for signed releases
- KeyboardShortcuts + AppKit Accessibility hooks for system-wide hotkeys
- A modular `Services`, `Managers`, and `StateMachine` layout so you can drop in new providers or UI experiments

---

## Quick Start

```bash
git clone https://github.com/studio-kensense/clio.git
cd clio
open Clio.xcodeproj
```

Build with Xcode 15+ (`⌘R`) or run the CLI build:

```bash
xcodebuild -project Clio.xcodeproj -scheme Clio -configuration Debug build
```

Prefer binaries? Download the latest signed DMG from the [Releases](https://github.com/studio-kensense/clio/releases) page, drag to `/Applications`, and grant microphone/accessibility permissions on first launch.

---

## First Launch Checklist

1. **Permissions** – macOS will prompt for Microphone, Accessibility, and (optionally) Screen Recording so Clio can insert text at your cursor and capture on-screen context.
2. **Models** – Choose Whisper Flash for speed (~130 MB) or Turbo for accuracy (~1.6 GB). You can sideload custom GGML models inside `~/Library/Application Support/Clio/Models`.
3. **Hotkeys** – Set global shortcuts for toggle-recording and push-to-talk. They live under **Settings → Shortcuts**.
4. **API Keys (optional)** – Drop Groq and Soniox keys into **Settings → Cloud API Keys**. They’re stored locally and never synced.

After that, tap your shortcut, speak naturally, and watch text flow wherever your caret lives—Notes, Xcode, Notion, or even the Terminal.

---

## Workflow Recipes

- **Draft mode** – Use PowerMode to auto-format Slack updates or daily journals with headings and bullet styles.
- **Pair-programming journal** – Switch to a “code” profile that disables auto-punctuation, respects camelCase, and keeps markdown fences intact.
- **Meeting memory** – Route long-form audio through Soniox low-latency streaming and hand the transcript to Groq for summaries.
- **Hands-free coding** – Combine push-to-talk with cursor control tools (Raycast, Hammerspoon, etc.) for voice-driven scaffolding.

If you build a workflow worth sharing, drop it in `docs/recipes` (or open an issue) so the rest of us can steal it.

---

## Architecture at a Glance

- `Core/WhisperState.swift` – Orchestrates recording, VAD, chunking, and transcription jobs.
- `Services/AIEnhancementService.swift` – Provider-agnostic layer for Groq, OpenAI, Anthropic, Gemini, and Ollama.
- `Managers/PowerModeManager.swift` – Keeps context about foreground apps/URLs and applies presets.
- `Whisper/whisper.cpp` – The embedded inference engine with Metal + CoreML acceleration.
- `StateMachine/` – Guards all the little edge cases (lost focus, permission changes, model swaps) so sessions stay stable.

Everything is written in Swift with a strict 4-space indent, plenty of structs, and zero force unwraps. Tests live in `ClioTests/` and `ClioUITests/`; Python tooling and CI scripts sit at the repo root.

---

## Roadmap & Community

- **Short term** – polish onboarding, add more preset voices/styles, expose the automation hooks I use daily.
- **Medium term** – ship a plug-in surface so you can call any local LLM or automation script after transcription.
- **Long term** – keep Clio fast, private, and boring in the best possible way. Dictation should feel like a keyboard, not a product funnel.

Issues and PRs are welcome. Please read [CONTRIBUTING.md](CONTRIBUTING.md) for coding style, testing expectations, and how to run the deployment scripts (`build_release.sh`, `create_dmg.sh`, etc.).

---

## License

Clio ships under the **Clio Community License v1.0**, which keeps the code open for personal and non-commercial use while requiring derivative work to remain non-commercial. Need a commercial license? Reach out via issues or email and we can figure out terms. Read the full text in [LICENSE](LICENSE).

---

## Credits

- **boring.notch** – The recorder UI leans on the thoughtful interaction patterns pioneered by [TheBoredTeam/boring.notch](https://github.com/TheBoredTeam/boring.notch).
- **Soniox** – Streaming and batch ASR capabilities are powered by Soniox models; huge thanks for low-latency accuracy.

If your work ends up inside Clio, let me know so I can brag about it here.

---

### Thank You

Clio exists because people keep cheering for indie infrastructure. If this helped you, star the repo, file an issue, or tell me how you are bending it to your workflow. I built this to talk to my Mac without apology; now it’s yours to shape.

— jetson
