# Disfluency Data Quality Toolkit

This toolkit enforces high-quality, high-diversity training pairs for code-switched disfluency removal.

What it does
- Dedup: removes exact (hard) and near-duplicate (soft) pairs
- Delete-only guard: rejects outputs that introduce new alphanumeric tokens
- Entity/number lock: flags changes to numbers/units
- Parenthetical vs self-correction heuristics: flags outputs with dangling conjunctions when input is a parenthetical (e.g., "not A, but B" / "不是A，而是B")
- Grammar artifact detector: flags outputs like ", but the Jiankou part, it …"
- Disfluency density control: ensures inputs contain 2–6 disfluencies
- Code-switch ratio measurement: helps maintain zh/en balance
- Deterministic noise injector: clean → noisy synthesis for delete-only-by-construction data

Layout
- scripts/disfluency/utils.py — text utilities, tokenization, heuristics
- scripts/disfluency/lint_dataset.py — linter + dedup CLI
- scripts/disfluency/inject_noise.py — noise injector (clean→noisy)
- scripts/disfluency/run_quality_pipeline.sh — convenience runner for linting

Install
- Requires Python 3.9+

Usage
1) Lint + dedup your existing JSONL

```bash
PYTHON=python3 bash scripts/disfluency/run_quality_pipeline.sh
```
Outputs
- ../synthetic-data/cleaned/data.cleaned.jsonl
- ../synthetic-data/cleaned/data.lint_report.csv (rows removed or flagged, with reasons)

2) Synthesize new pairs from clean seeds (optional)

Prepare a seeds.jsonl where every line has one of:
- {"clean": "我明天去广州。"}
- {"output": "We ended up in Seoul, the street food near Myeongdong was the best."}

Run:
```bash
python3 -m scripts.disfluency.inject_noise --in seeds.jsonl --out ../synthetic-data/synth.noisy.jsonl --density 3
```

Tuning
- Soft-duplicate threshold: --soft-th (default 0.92). Increase to be stricter (more pruning of templates like New Zealand→Iceland).
- Disfluency density: --min-d/--max-d (default 2–6).

Notes
- Keep a frozen golden eval set (200+ pairs) out of training.
- For rows flagged as parenthetical_artifact/grammar_artifact, consider either manual repair or a constrained LLM fixer that must pass the linter before acceptance.

