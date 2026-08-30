#!/usr/bin/env bash
# Linux TTS using espeak-ng (local, no network). Windows path: tts_sapi.ps1
set -euo pipefail
ROOT="${1:-.}"
SCRIPT="${2:-$ROOT/script.json}"
OUTDIR="${3:-$ROOT/audio}"
RATE="${ESPEAK_RATE:-145}"
VOICE="${ESPEAK_VOICE:-en-us}"
mkdir -p "$OUTDIR"
python3 - "$SCRIPT" "$OUTDIR" "$RATE" "$VOICE" << 'PY2'
import json, subprocess, sys
from pathlib import Path
script, outdir, rate, voice = sys.argv[1:5]
scenes = json.loads(Path(script).read_text())
for s in scenes:
    sid = s["id"]
    text = s["narration"]
    wav = Path(outdir) / f"scene{sid}.wav"
    cmd = ["espeak-ng", "-w", str(wav), "-s", str(rate), "-v", voice, text]
    subprocess.check_call(cmd)
    print(f"wrote {wav}")
PY2
