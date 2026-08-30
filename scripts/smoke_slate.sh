#!/usr/bin/env bash
# FACTORY ONLY. Colored ffmpeg cards via scripts/make_slates.sh.
# NOT the Girish Ken Burns lane (that is scripts/render_30s.sh: vendor make_slides + shoot_slides).
# Assembly reuses vendor Ken Burns zoompan via scripts/build_video.sh.
set -euo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
cd "$HERE"
mkdir -p out frames audio segs
cp example/slate/script.json script.json
scripts/make_slates.sh . script.json frames
scripts/tts_espeak.sh . script.json audio

SCENES=$(python3 -c "import json; print(len(json.load(open('script.json'))))")
TARGET="${TARGET_SECONDS:-30}"
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
scripts/build_video.sh "$PAD" "$SCENES" . out/videomaker_ready_30s.mp4
echo "SMOKE_MP4=$HERE/out/videomaker_ready_30s.mp4"
ffprobe -v error -show_entries format=duration,size -of default=nw=1 out/videomaker_ready_30s.mp4
ffprobe -v error -select_streams v:0 -show_entries stream=codec_name,width,height -of default=nw=1 out/videomaker_ready_30s.mp4
ffprobe -v error -select_streams a:0 -show_entries stream=codec_name -of default=nw=1 out/videomaker_ready_30s.mp4
