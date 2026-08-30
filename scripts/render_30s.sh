#!/usr/bin/env bash
# Girish cut: Playwright Ken Burns via vendor/prompt-to-video. Not colored slates.
# Usage: scripts/render_30s.sh [script.json] [outfile.mp4]
set -euo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
cd "$HERE"
SCRIPT_JSON="${1:-script.json}"
OUTFILE="${2:-out/videomaker_30s.mp4}"
TARGET="${TARGET_SECONDS:-30}"
VENDOR="$HERE/vendor/prompt-to-video/scripts"

if [[ ! -f "$SCRIPT_JSON" ]]; then
  echo "missing $SCRIPT_JSON" >&2
  exit 1
fi
if [[ "$SCRIPT_JSON" != "script.json" ]]; then
  cp "$SCRIPT_JSON" script.json
fi

if ! command -v node >/dev/null 2>&1; then
  echo "BLOCKED: node required to call vendor shoot_slides" >&2
  exit 1
fi
if ! node -e "require('playwright')" >/dev/null 2>&1; then
  echo "BLOCKED: Playwright required. Girish cut must use vendor shoot_slides, not make_slates.sh" >&2
  exit 1
fi

SCENES=$(python3 -c "import json; print(len(json.load(open('script.json'))))")
node "$VENDOR/make_slides.mjs" script.json
node "$VENDOR/shoot_slides.mjs" "$SCENES"
scripts/tts_espeak.sh . script.json audio

PAD=$(python3 - "$SCENES" "$TARGET" << 'PY2'
import subprocess, sys
from pathlib import Path
n = int(sys.argv[1]); target = float(sys.argv[2])
speech = 0.0
for i in range(1, n+1):
    wav = Path("audio") / f"scene{i}.wav"
    out = subprocess.check_output([
        "ffprobe", "-v", "error", "-show_entries", "format=duration",
        "-of", "csv=p=0", str(wav)
    ], text=True).strip()
    speech += float(out)
pad = (target - speech) / n if n else 0.6
pad = max(0.15, min(2.5, pad))
print(f"{pad:.3f}")
print(f"speech_seconds={speech:.2f} pad_each={pad:.3f}", file=sys.stderr)
PY2
)
PAD=$(echo "$PAD" | head -n1)
export PAD SCENES ROOT=. OUTFILE
scripts/build_video.sh "$PAD" "$SCENES" . "$OUTFILE"
