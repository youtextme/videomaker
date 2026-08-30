#!/usr/bin/env bash
# Thin 30s wrapper around the prompt-to-video Ken Burns lane.
# Usage: scripts/render_30s.sh [script.json] [outfile.mp4]
set -euo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
cd "$HERE"
SCRIPT_JSON="${1:-script.json}"
OUTFILE="${2:-out/videomaker_30s.mp4}"
TARGET="${TARGET_SECONDS:-30}"
SCENES="${SCENES:-}"

if [[ ! -f "$SCRIPT_JSON" ]]; then
  echo "missing $SCRIPT_JSON" >&2
  exit 1
fi

python3 -c "import json,pathlib,sys; json.load(pathlib.Path('$SCRIPT_JSON').open())"

if [[ "$SCRIPT_JSON" != "script.json" ]]; then
  cp "$SCRIPT_JSON" script.json
fi

if [[ -z "$SCENES" ]]; then
  SCENES=$(python3 -c "import json; print(len(json.load(open('script.json'))))")
fi

# Slides: Playwright if available, else ffmpeg slates (smoke / Linux box)
if command -v node >/dev/null 2>&1 && node -e "require('playwright')" >/dev/null 2>&1; then
  node scripts/make_slides.mjs script.json
  node scripts/shoot_slides.mjs "$SCENES"
else
  scripts/make_slates.sh . script.json frames
fi

scripts/tts_espeak.sh . script.json audio

PAD=$(python3 - "$SCENES" "$TARGET" << 'PY2'
import math, subprocess, sys
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
remain = target - speech
pad = remain / n if n else 0.6
# keep a little hold between scenes; clamp so we still land near target
pad = max(0.15, min(2.5, pad))
print(f"{pad:.3f}")
print(f"speech_seconds={speech:.2f} pad_each={pad:.3f} planned={speech + pad*n:.2f}", file=sys.stderr)
PY2
)

PAD=$(echo "$PAD" | head -n1)
export PAD SCENES ROOT=. OUTFILE
scripts/build_video.sh "$PAD" "$SCENES" . "$OUTFILE"
