#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import csv
import json
import os
from dataclasses import dataclass, asdict
from typing import Dict, List, Tuple

from .utils import (
    normalize_text,
    canonical_pair,
    pair_skeleton,
    soft_sim,
    new_tokens_in_output,
    numbers_with_units,
    has_self_correction,
    has_parenthetical_not_but,
    grammar_artifacts,
    disfluency_count,
    code_switch_ratio,
)


@dataclass
class Row:
    input: str
    output: str
    idx: int


@dataclass
class Verdict:
    keep: bool
    reasons: List[str]


@dataclass
class ReportRow:
    idx: int
    reason: str
    input: str
    output: str


class DisfluencyLinter:
    def __init__(self,
                 soft_dup_threshold: float = 0.92,
                 min_disfluencies: int = 2,
                 max_disfluencies: int = 6,
                 target_ratio_latin: Tuple[float, float] = (0.2, 0.8),
                 hard_dedup_only: bool = False):
        self.soft_dup_threshold = soft_dup_threshold
        self.min_disfluencies = min_disfluencies
        self.max_disfluencies = max_disfluencies
        self.target_ratio_latin = target_ratio_latin
        self.hard_dedup_only = hard_dedup_only
        self._seen_canon: Dict[str, int] = {}
        self._skeleton_index: List[Tuple[str, int]] = []

    def dedup_and_lint(self, rows: List[Row]) -> Tuple[List[Row], List[ReportRow]]:
        kept: List[Row] = []
        report: List[ReportRow] = []

        for r in rows:
            # Hard dedup by canonical hash
            canon = canonical_pair(r.input, r.output)
            if canon in self._seen_canon:
                report.append(ReportRow(r.idx, "hard_duplicate", r.input, r.output))
                continue

            if not self.hard_dedup_only:
                # Soft dedup: near-duplicate skeletons
                sk = pair_skeleton(r.input, r.output)
                is_soft_dup = False
                for sk_prev, idx_prev in self._skeleton_index[-2000:]:  # recent window for speed
                    if soft_sim(sk, sk_prev) >= self.soft_dup_threshold:
                        report.append(ReportRow(r.idx, f"soft_duplicate~{idx_prev}", r.input, r.output))
                        is_soft_dup = True
                        break
                if is_soft_dup:
                    continue

                verdict = self._lint_row(r)
                if verdict.keep:
                    kept.append(r)
                    self._seen_canon[canon] = r.idx
                    self._skeleton_index.append((sk, r.idx))
                else:
                    for reason in verdict.reasons:
                        report.append(ReportRow(r.idx, reason, r.input, r.output))
            else:
                # Hard-dedup-only mode: keep everything except exact duplicates
                kept.append(r)
                # Still index skeletons for potential later phases (no filtering here)
                sk = pair_skeleton(r.input, r.output)
                self._seen_canon[canon] = r.idx
                self._skeleton_index.append((sk, r.idx))

        return kept, report

    def _lint_row(self, r: Row) -> Verdict:
        reasons: List[str] = []

        # Delete-only: output tokens must not introduce new alphanumeric tokens
        new_toks = new_tokens_in_output(r.input, r.output)
        if new_toks:
            reasons.append("delete_only_violation:new_tokens=" + ",".join(new_toks[:6]))

        # Entity lock: numbers/units must not change
        nums_in = set(numbers_with_units(r.input))
        nums_out = set(numbers_with_units(r.output))
        if nums_out - nums_in:
            reasons.append("entity_violation:numbers_units_changed")

        # Disfluency density on input
        dcount = disfluency_count(r.input)
        if dcount < self.min_disfluencies:
            reasons.append(f"too_trivial:disfluency_count={dcount}")
        elif dcount > self.max_disfluencies:
            reasons.append(f"too_noisy:disfluency_count={dcount}")

        # Parenthetical vs self-correction classification
        has_parenth = has_parenthetical_not_but(r.input)
        has_self = has_self_correction(r.input)
        if has_parenth and not has_self:
            # Output should preserve the parenthetical relation; basic grammar check
            arts = grammar_artifacts(r.output)
            if arts:
                reasons.append("parenthetical_artifact:" + "+".join(arts))
        if has_self:
            # Output should remove the wrong part; low-signal heuristic: if output still contains both A and B separated by comma & has self markers removed
            # We cannot know A/B spans robustly here; leave to human if both appear as in input
            pass

        # Code-switch ratio (soft constraint; only warn)
        ratios = code_switch_ratio(r.input)
        rl = ratios["ratio_latin"]
        low, high = self.target_ratio_latin
        if not (low <= rl <= high):
            # don't block; just warn
            pass

        # Grammar artifacts generally
        arts = grammar_artifacts(r.output)
        for a in arts:
            reasons.append("grammar_artifact:" + a)

        keep = len([x for x in reasons if not x.startswith("too_trivial")]) == 0
        # allow trivial filtering separately during balancing; don't keep rows with any hard violations
        hard = [x for x in reasons if x.startswith("delete_only_violation") or x.startswith("entity_violation") or x.startswith("parenthetical_artifact") or x.startswith("grammar_artifact")]
        if hard:
            keep = False

        return Verdict(keep=keep, reasons=reasons)


def read_jsonl(path: str) -> List[Row]:
    rows: List[Row] = []
    with open(path, 'r', encoding='utf-8') as f:
        for idx, line in enumerate(f, start=1):
            line = line.strip()
            if not line:
                continue
            try:
                obj = json.loads(line)
            except Exception:
                # lines like "123|{json}" from previews; try to split
                if '|' in line:
                    _, rest = line.split('|', 1)
                    obj = json.loads(rest)
                else:
                    continue
            if not isinstance(obj, dict):
                continue
            inp = obj.get('input', '')
            out = obj.get('output', '')
            if inp and out:
                rows.append(Row(input=inp, output=out, idx=idx))
    return rows


def write_jsonl(path: str, rows: List[Row]):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w', encoding='utf-8') as f:
        for r in rows:
            f.write(json.dumps({"input": r.input, "output": r.output}, ensure_ascii=False) + "\n")


def write_report(path: str, report: List[ReportRow]):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w', encoding='utf-8', newline='') as f:
        w = csv.writer(f)
        w.writerow(["idx", "reason", "input", "output"])
        for rr in report:
            w.writerow([rr.idx, rr.reason, rr.input, rr.output])


def main():
    ap = argparse.ArgumentParser(description="Disfluency dataset linter and deduplicator")
    ap.add_argument("--in", dest="inp", required=True, help="Path to input JSONL (input/output pairs)")
    ap.add_argument("--out", dest="out", required=True, help="Path to write cleaned JSONL")
    ap.add_argument("--report", dest="report", required=True, help="Path to write CSV report for removed/flagged rows")
    ap.add_argument("--soft-th", dest="soft_th", type=float, default=0.92, help="Soft duplicate similarity threshold")
    ap.add_argument("--min-d", dest="min_d", type=int, default=2, help="Minimum disfluencies in input")
    ap.add_argument("--max-d", dest="max_d", type=int, default=6, help="Maximum disfluencies in input")
    ap.add_argument("--hard-dedup-only", dest="hard_dedup_only", action="store_true", help="Only remove exact duplicates; skip soft dedup and all other checks")

    args = ap.parse_args()

    rows = read_jsonl(args.inp)
    linter = DisfluencyLinter(soft_dup_threshold=args.soft_th,
                              min_disfluencies=args.min_d,
                              max_disfluencies=args.max_d,
                              hard_dedup_only=args.hard_dedup_only)

    kept, report = linter.dedup_and_lint(rows)

    write_jsonl(args.out, kept)
    write_report(args.report, report)

    print(json.dumps({
        "input_rows": len(rows),
        "kept_rows": len(kept),
        "removed_rows": len(report)
    }, ensure_ascii=False))


if __name__ == "__main__":
    main()

