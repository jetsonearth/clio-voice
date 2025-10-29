#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import re
import unicodedata
from collections import Counter
from difflib import SequenceMatcher
from typing import List, Tuple, Dict

ZH_FILLERS = [
    "嗯", "呃", "啊", "那个", "就是", "怎么说", "就是说", "那什么", "额", "哎", "你知道吧"
]
EN_FILLERS = [
    "um", "uh", "like", "you know", "i mean", "kind of", "sort of", "basically", "literally"
]
SELF_CORR_MARKERS_EN = [
    "sorry", "i meant", "correction", "let me correct", "i misspoke"
]
SELF_CORR_MARKERS_ZH = [
    "不是", "哦不对", "更准确说是", "更正", "我刚刚说错了", "纠正一下", "我的意思是"
]

CONNECTORS_EN = ["but", "however", "though", "although", "rather", "instead"]
CONNECTORS_ZH = ["但是", "不过", "然而", "而是", "而且"]

PUNCT_CHARS = set(
    list(".,!?;:'\"()[]{}<>") + [
        "，", "。", "！", "？", "；", "：", "（", "）", "【", "】", "《", "》", "—", "–", "…", "、"
    ]
)

FULLWIDTH_MAP = {
    ord("，"): ",",
    ord("。"): ".",
    ord("！"): "!",
    ord("？"): "?",
    ord("；"): ";",
    ord("："): ":",
    ord("（"): "(",
    ord("）"): ")",
    ord("【"): "[",
    ord("】"): "]",
    ord("《"): "<",
    ord("》"): ">",
    ord("“"): '"',
    ord("”"): '"',
    ord("‘"): "'",
    ord("’"): "'",
    ord("—"): "—",
    ord("–"): "—",
    ord("…"): "...",
}

UNITS = [
    "gb", "mb", "kb", "tb", "kg", "g", "km", "m", "cm", "mm", "mph", "km/h", "%",
    "°c", "°f", "小时", "分钟", "点", "年", "月", "日"
]

RE_NUM_UNIT = re.compile(
    r"(?i)"  # case-insensitive
    r"([+-]?(?:\d{1,3}(?:[\.,]\d{3})+|\d+)(?:[\.,]\d+)?)"  # number like 1,234.56 or 1234 or 12.3
    r"\s*(%|°C|°F|km/h|mph|[A-Za-z]{1,4}|小时|分钟|点|年|月|日)?"
)

RE_LATIN_WORD = re.compile(r"(?i)[a-z][a-z'\-]{1,}")
RE_NUMBER = re.compile(r"[0-9]+(?:[\.,][0-9]+)*")

RE_EN_PARENTHE_NOT_BUT = re.compile(r"(?i)not\b(.{0,80}?)\bbut\b")
RE_ZH_PARENTHE_NOT_BUT = re.compile(r"不是(.{0,40}?)而是")

RE_SELF_CORR_EN = re.compile(r"(?i)(sorry|i\s+meant|correction|i\s+misspoke)")
RE_SELF_CORR_ZH = re.compile(r"(不是|哦不对|更准确说是|更正|我刚刚说错了|纠正一下|我的意思是)")

RE_DANGLING_BUT = re.compile(r"(?i),\s*but\s+the\s+[^,，。]+,\s+it\b")
RE_DANGLING_DANSHI = re.compile(r"，\s*(但是|不过|然而)\s*[^，。]*，\s*它|这|那")

# Simple repetition patterns: "我，我" or "I, I" or "I—I"
RE_REP_COMMA = re.compile(r"(\b\w+\b)[，,]\s*\1\b")
RE_REP_DASH = re.compile(r"(\b\w+\b)[—-]\s*\1\b")


def is_cjk(ch: str) -> bool:
    code = ord(ch)
    return (
        0x4E00 <= code <= 0x9FFF or  # CJK Unified Ideographs
        0x3400 <= code <= 0x4DBF or  # CJK Unified Ideographs Extension A
        0x20000 <= code <= 0x2A6DF or  # Extension B
        0x2A700 <= code <= 0x2B73F or  # Extension C
        0x2B740 <= code <= 0x2B81F or  # Extension D
        0x2B820 <= code <= 0x2CEAF or  # Extension E
        0xF900 <= code <= 0xFAFF or  # CJK Compatibility Ideographs
        0x2F800 <= code <= 0x2FA1F
    )


def normalize_text(s: str) -> str:
    if s is None:
        return ""
    s = unicodedata.normalize("NFKC", s)
    s = s.translate(FULLWIDTH_MAP)
    # collapse whitespace
    s = re.sub(r"\s+", " ", s).strip()
    return s


def strip_fillers(s: str) -> str:
    t = s
    for f in ZH_FILLERS:
        t = t.replace(f, " ")
    for f in EN_FILLERS:
        # word-boundary remove, case-insensitive
        t = re.sub(rf"(?i)\b{re.escape(f)}\b", " ", t)
    t = re.sub(r"\s+", " ", t)
    return t.strip()


def tokenize(s: str) -> List[str]:
    tokens: List[str] = []
    buf = []
    mode = None  # 'latin', 'digit', 'cjk', 'other'

    def flush():
        nonlocal buf, tokens
        if buf:
            tokens.append("".join(buf))
            buf = []

    for ch in s:
        cat = unicodedata.category(ch)
        if is_cjk(ch):
            flush()
            tokens.append(ch)
            mode = None
        elif ch.isalpha():
            if mode == 'latin':
                buf.append(ch)
            else:
                flush()
                buf = [ch]
                mode = 'latin'
        elif ch.isdigit():
            if mode in ('latin', 'digit'):
                buf.append(ch)
                mode = 'latin' if mode == 'latin' else 'digit'
            else:
                flush()
                buf = [ch]
                mode = 'digit'
        else:
            # punctuation or other
            flush()
            tokens.append(ch)
            mode = None
    flush()
    return tokens


def is_punct(tok: str) -> bool:
    return len(tok) == 1 and (tok in PUNCT_CHARS or unicodedata.category(tok).startswith('P'))


def token_multiset(s: str) -> Counter:
    s_norm = normalize_text(s)
    toks = [t.lower() for t in tokenize(s_norm) if not is_punct(t)]
    return Counter(toks)


def new_tokens_in_output(inp: str, out: str) -> List[str]:
    ci = token_multiset(inp)
    co = token_multiset(out)
    new_tokens = []
    for tok, cnt in co.items():
        if ci.get(tok, 0) < cnt:
            new_tokens.append(tok)
    return new_tokens


def numbers_with_units(s: str) -> List[str]:
    s_norm = normalize_text(s)
    items: List[str] = []
    for m in RE_NUM_UNIT.finditer(s_norm):
        num = m.group(1)
        unit = m.group(2) or ""
        key = f"{num}{unit.lower()}"
        items.append(key)
    return items


def has_self_correction(s: str) -> bool:
    return bool(RE_SELF_CORR_EN.search(s) or RE_SELF_CORR_ZH.search(s))


def has_parenthetical_not_but(s: str) -> bool:
    return bool(RE_EN_PARENTHE_NOT_BUT.search(s) or RE_ZH_PARENTHE_NOT_BUT.search(s))


def grammar_artifacts(s: str) -> List[str]:
    issues = []
    if RE_DANGLING_BUT.search(s):
        issues.append("dangling_but_en")
    if RE_DANGLING_DANSHI.search(s):
        issues.append("dangling_but_zh")
    return issues


def disfluency_count(s: str) -> int:
    s_norm = normalize_text(s)
    count = 0
    for f in ZH_FILLERS:
        count += s_norm.count(f)
    for f in EN_FILLERS:
        count += len(re.findall(rf"(?i)\b{re.escape(f)}\b", s_norm))
    count += len(RE_REP_COMMA.findall(s_norm))
    count += len(RE_REP_DASH.findall(s_norm))
    # Rough count for em-dashes as restarts
    count += s_norm.count("—")
    return count


def code_switch_ratio(s: str) -> Dict[str, float]:
    s_norm = normalize_text(s)
    latin = sum(1 for ch in s_norm if 'A' <= ch <= 'Z' or 'a' <= ch <= 'z')
    cjk = sum(1 for ch in s_norm if is_cjk(ch))
    total = latin + cjk
    return {
        "latin": latin,
        "cjk": cjk,
        "ratio_latin": (latin / total) if total else 0.0,
        "ratio_cjk": (cjk / total) if total else 0.0,
    }


def canonical_pair(inp: str, out: str) -> str:
    # normalize and remove trivial filler spacing for exact dedup
    a = normalize_text(strip_fillers(inp)).lower()
    b = normalize_text(strip_fillers(out)).lower()
    a = RE_NUMBER.sub("<NUM>", a)
    b = RE_NUMBER.sub("<NUM>", b)
    return a + " || " + b


def skeletonize(s: str) -> str:
    s0 = normalize_text(s).lower()
    # keep key cue words for classification
    # mask numbers
    s1 = RE_NUMBER.sub("<num>", s0)
    # collapse english words
    s1 = RE_LATIN_WORD.sub("<en>", s1)
    # collapse long runs of CJK to <zh>
    s1 = re.sub(r"[\u4e00-\u9fff]{2,}", "<zh>", s1)
    # strip fillers (we don't want them to differentiate samples)
    s1 = strip_fillers(s1)
    s1 = re.sub(r"\s+", " ", s1).strip()
    return s1


def pair_skeleton(inp: str, out: str) -> str:
    return skeletonize(inp) + " || " + skeletonize(out)


def soft_sim(a: str, b: str) -> float:
    return SequenceMatcher(None, a, b).ratio()

