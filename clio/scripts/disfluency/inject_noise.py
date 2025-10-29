#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import json
import os
import random
from typing import List, Dict

from .utils import normalize_text

ZH_FILLERS = ["嗯", "呃", "啊", "那个", "就是", "你知道吧", "怎么说", "就是说", "那什么", "额", "哎"]
EN_FILLERS = ["um", "uh", "like", "you know", "i mean", "kind of", "sort of", "basically", "literally"]
SELF_EN = ["sorry", "i meant", "correction", "i misspoke"]
SELF_ZH = ["不是", "哦不对", "更准确说是", "更正", "我刚刚说错了", "纠正一下", "我的意思是"]

def inject_fillers(text: str, rng: random.Random) -> str:
    t = text
    # Insert a filler before random commas or clause breaks
    positions = []
    for i, ch in enumerate(t):
        if ch in [',', '，', '。', '—', ';', '；']:
            positions.append(i)
    k = rng.randint(0, min(2, max(0, len(positions)//4)))
    for _ in range(k):
        if not positions:
            break
        i = rng.choice(positions)
        filler = rng.choice(ZH_FILLERS + EN_FILLERS)
        t = t[:i] + (" " + filler + ", ") + t[i:]
    return t


def inject_repetitions(text: str, rng: random.Random) -> str:
    words = list(text)
    if len(words) < 2:
        return text
    idxs = [i for i,ch in enumerate(words) if ch.strip() and ch != '—']
    if not idxs:
        return text
    i = rng.choice(idxs)
    # repeat a token with comma or dash
    rep = words[i]
    style = rng.choice([', ', '—'])
    words.insert(i+1, style + rep)
    return ''.join(words)


def inject_restart(text: str, rng: random.Random) -> str:
    # add an em-dash restart somewhere mid-sentence
    t = text
    if len(t) < 6:
        return t
    i = rng.randint(1, max(1, len(t)-2))
    return t[:i] + '—' + t[i:]


def inject_parenthetical_not_but(text: str, rng: random.Random) -> str:
    # Convert a neutral clause into a parenthetical contrast: "not A, but B"
    # Heuristic: split on first comma and wrap
    parts = text.split(',')
    if len(parts) >= 2:
        A = parts[0].strip()
        B = ','.join(parts[1:]).strip()
        if A and B:
            return f"{A}— not the former, but {B}"
    return text


def inject_self_correction(text: str, rng: random.Random) -> str:
    # Add a clear self-correction marker, ensuring delete-only gold remains original text
    parts = text.split(',')
    if len(parts) >= 2:
        A = parts[0].strip()
        B = ','.join(parts[1:]).strip()
        if A and B:
            marker = rng.choice(SELF_EN + SELF_ZH)
            return f"{A}. {marker}, {B}"
    return text


def synthesize(clean: str, seed: int, density: int = 3) -> str:
    rng = random.Random(seed)
    t = clean
    ops = [inject_fillers, inject_repetitions, inject_restart]
    # optionally add one of parenthetical or self-correction
    if rng.random() < 0.5:
        ops.append(inject_parenthetical_not_but)
    else:
        ops.append(inject_self_correction)
    rng.shuffle(ops)
    for i in range(min(density, len(ops))):
        t = ops[i](t, rng)
    return normalize_text(t)


def main():
    ap = argparse.ArgumentParser(description="Deterministic noise injector for disfluency synthesis")
    ap.add_argument("--in", dest="inp", required=True, help="Path to JSONL of clean sentences (expects {'clean': str} per line or {'output': str})")
    ap.add_argument("--out", dest="out", required=True, help="Path to write JSONL with {'input','output'} pairs")
    ap.add_argument("--seed", dest="seed", type=int, default=42, help="Global random seed")
    ap.add_argument("--density", dest="density", type=int, default=3, help="Disfluency operations per sample")
    args = ap.parse_args()

    os.makedirs(os.path.dirname(args.out), exist_ok=True)

    rng = random.Random(args.seed)
    with open(args.inp, 'r', encoding='utf-8') as fi, open(args.out, 'w', encoding='utf-8') as fo:
        for line in fi:
            line = line.strip()
            if not line:
                continue
            obj = json.loads(line)
            clean = obj.get('clean') or obj.get('output') or obj.get('text')
            if not clean:
                continue
            seed = rng.randint(0, 10_000_000)
            noisy = synthesize(clean, seed=seed, density=args.density)
            fo.write(json.dumps({"input": noisy, "output": clean}, ensure_ascii=False) + "\n")


if __name__ == "__main__":
    main()

