#!/usr/bin/env python3
"""Turn a user-supplied idea string into a 4-scene script.json for the 30s lane."""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

VARIANTS = [
    ("tower", "#D9A441", "OPEN"),
    ("palace", "#C73E3A", "POINT"),
    ("hanok", "#2F6D80", "DETAIL"),
    ("sunrise", "#E07A3F", "CLOSE"),
]
MAX_NARRATION_WORDS = 16
MAX_TITLE_WORDS = 6
MAX_SUB_WORDS = 8


def split_sentences(text: str) -> list[str]:
    text = re.sub(r"\s+", " ", text.strip())
    if not text:
        return []
    parts = re.split(r"(?<=[.!?])\s+", text)
    return [p.strip() for p in parts if p.strip()]


def split_words(text: str, n: int) -> list[str]:
    words = text.split()
    if not words:
        return [""] * n
    size = max(1, (len(words) + n - 1) // n)
    chunks: list[str] = []
    for i in range(0, len(words), size):
        chunks.append(" ".join(words[i : i + size]))
    while len(chunks) < n:
        chunks.append(chunks[-1] if chunks else text)
    return chunks[:n]


def trim_words(text: str, limit: int) -> str:
    words = text.split()
    if len(words) <= limit:
        return text.strip()
    return " ".join(words[:limit]).rstrip(",.;:") + "."


def short_label(text: str, limit: int) -> str:
    words = text.split()
    if not words:
        return "idea"
    label = " ".join(words[:limit])
    return label[0].upper() + label[1:] if label else "idea"


def idea_chunks(idea: str) -> list[str]:
    sentences = split_sentences(idea)
    if len(sentences) >= 4:
        return [trim_words(s, MAX_NARRATION_WORDS) for s in sentences[:4]]
    if len(sentences) == 1:
        return [trim_words(c, MAX_NARRATION_WORDS) for c in split_words(sentences[0], 4)]
    padded = sentences[:]
    while len(padded) < 4:
        padded.append(padded[-1])
    return [trim_words(s, MAX_NARRATION_WORDS) for s in padded[:4]]


def build_scenes(idea: str) -> list[dict]:
    chunks = idea_chunks(idea)
    scenes: list[dict] = []
    for idx, (variant, accent, kicker) in enumerate(VARIANTS):
        chunk = chunks[idx]
        title = short_label(chunk, MAX_TITLE_WORDS)
        sub = short_label(chunk, MAX_SUB_WORDS)
        scenes.append(
            {
                "id": idx + 1,
                "variant": variant,
                "accent": accent,
                "kicker": kicker,
                "title": title,
                "sub": sub,
                "caption": chunk,
                "narration": chunk,
            }
        )
    return scenes


def main() -> int:
    parser = argparse.ArgumentParser(description="Convert a user idea into script.json")
    parser.add_argument("-o", "--output", default="script.json", help="Output JSON path")
    parser.add_argument("idea", nargs="?", help="Idea text (otherwise read stdin)")
    args = parser.parse_args()

    idea = args.idea if args.idea is not None else sys.stdin.read()
    idea = idea.strip()
    if not idea:
        print("BLOCKED: empty idea", file=sys.stderr)
        return 1

    scenes = build_scenes(idea)
    out = Path(args.output)
    out.write_text(json.dumps(scenes, indent=2) + "\n", encoding="utf-8")
    print(f"wrote {out} scenes={len(scenes)}", file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
