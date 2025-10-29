# Repository Guidelines

## Project Structure & Modules
- `Clio/`: Swift app source. Key folders: `Core`, `Services`, `Managers`, `Models`, `Views`, `Whisper`, `Utils`, `Resources`, `Assets(.xcassets)`, `Localization`, `Config`, `ViewModels`, `StateMachine`, `Preview Content`.
- `ClioTests/`, `ClioUITests/`: Unit/UI tests (XCTest/XCUITest).
- `whisper.cpp/`, `whisper.xcframework/`: Local transcription engine.
- Scripts: `build_release.sh`, `create_dmg.sh`, `deploy_*.sh`.
- Python utilities/tests: `requirements.txt`, `test_*.py` in repo root.

## Build, Test, and Development
- Open in Xcode: `open Clio.xcodeproj` → build/run with `⌘+R`.
- CLI build: `xcodebuild -project Clio.xcodeproj -scheme Clio -configuration Debug build`.
- Run tests (XCTest): `xcodebuild test -project Clio.xcodeproj -scheme Clio -destination 'platform=macOS'`.
- Python tests (optional): `python3 -m venv venv && source venv/bin/activate && pip install -r requirements.txt && pytest`.

## Coding Style & Naming
- Swift: 4‑space indent; follow Swift API Design Guidelines. Types `UpperCamelCase`; functions/vars `lowerCamelCase`. One primary type per file; prefer `struct` where possible; avoid force‑unwraps.
- Python: PEP 8; 4 spaces; functions `snake_case`, classes `PascalCase`; files `snake_case.py`.
- Filenames: Swift files `PascalCase.swift` matching the primary type (e.g., `AIEnhancementService.swift`).

## Testing Guidelines
- Swift: Add unit tests in `ClioTests/` and UI tests in `ClioUITests/`. Name test methods `test…()` and keep them deterministic.
- Python: Name files `test_*.py` and functions `test_*`. Avoid network calls in unit tests.
- Aim to cover new logic paths; include edge cases for audio/ASR flows and configuration parsing.

## Commit & Pull Request Guidelines
- Use Conventional Commits: `feat(scope): summary`, `fix(scope): …`, `chore(scope): …`, etc. Keep messages imperative and concise.
- PRs: include a clear description, linked issues, testing steps, and screenshots/GIFs for UI changes. Note any config/model updates and migration steps.

## Security & Configuration Tips
- Do not commit secrets or API keys. Use environment variables or local config files ignored by Git.
- macOS permissions (Microphone, Accessibility, Screen Recording) are required for full functionality—see README “Setup”.
- Distribution helpers: `setup_notarization.sh` and `create_dmg.sh`. See `docs/` for additional build notes.

