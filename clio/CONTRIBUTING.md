## Contributing to Clio

Thanks for your interest in improving Clio! This project welcomes issues and pull requests.

### Start Here
- Read the repository guidelines in `AGENTS.md` (coding style, tests, commits, PRs).
- Open the project: `open Clio.xcodeproj` and build/run with `⌘+R`.
- Run tests:
  - Swift: `xcodebuild test -project Clio.xcodeproj -scheme Clio -destination 'platform=macOS'`
  - Python (optional tooling): create a venv, `pip install -r requirements.txt`, then run your tests.

### Pull Requests
- Follow Conventional Commits (e.g., `feat(ui): improve recorder interface`).
- Use the PR template (`.github/pull_request_template.md`) and include:
  - Description, linked issues, screenshots/GIFs for UI, and test plan.
- Add/adjust tests in `ClioTests/` and `ClioUITests/` as needed.

### Code Style
- Swift: 4-space indent, Swift API Design Guidelines; types `UpperCamelCase`, members `lowerCamelCase`.
- Python: PEP 8; files `snake_case.py`.

### Security
- Do not commit secrets or API keys. Use environment vars or local, ignored configs.

Questions? Open a GitHub Discussion or Issue with reproduction details.

