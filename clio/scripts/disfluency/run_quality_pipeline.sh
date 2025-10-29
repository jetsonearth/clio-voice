#!/usr/bin/env bash
set -euo pipefail

# Disfluency dataset quality pipeline
# 1) Lint + dedup existing JSONL
# 2) (Optional) Synthesize new data from clean seeds

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
SYN_DIR="$ROOT_DIR/../synthetic-data"
IN="$SYN_DIR/data.jsonl"
OUT_DIR="$SYN_DIR/cleaned"
CLEANED_JSONL="$OUT_DIR/data.cleaned.jsonl"
REPORT_CSV="$OUT_DIR/data.lint_report.csv"

PYTHON=${PYTHON:-python3}
# Ensure Python can import the 'scripts' package regardless of caller CWD
export PYTHONPATH="$ROOT_DIR:${PYTHONPATH:-}"

mkdir -p "$OUT_DIR"

echo "[1/1] Linting + dedup: $IN -> $CLEANED_JSONL"
$PYTHON -m scripts.disfluency.lint_dataset --in "$IN" --out "$CLEANED_JSONL" --report "$REPORT_CSV" --soft-th 0.92 --min-d 2 --max-d 6

echo "Done. Outputs:"
echo "  Cleaned JSONL: $CLEANED_JSONL"
echo "  Report CSV:    $REPORT_CSV"
