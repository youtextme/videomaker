#!/usr/bin/env bash
# Local factory: idea in (script.json) → ~30s 1920x1080 h264+aac mp4.
# Will not invent a topic. Girish Playwright lane is scripts/render_30s.sh.
# This path: ffmpeg cards via make_slates.sh, Ken Burns assemble via build_video.sh.
set -euo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
cd "$HERE"

IDEA="${1:-}"
OUTFILE="${2:-out/videomaker_30s.mp4}"

if [[ -z "$IDEA" ]]; then
  echo "factory: need a script.json idea. will not invent a topic." >&2
  exit 2
fi
if [[ ! -f "$IDEA" ]]; then
  echo "factory: missing $IDEA" >&2
  exit 2
fi

python3 - "$IDEA" << 'PY2'
import json, sys
from pathlib import Path
p = Path(sys.argv[1])
try:
    data = json.loads(p.read_text())
except Exception:
    print("factory: idea must be a JSON scene array. will not invent a topic.", file=sys.stderr)
    sys.exit(2)
if not isinstance(data, list) or not data:
    print("factory: idea must be a JSON scene array. will not invent a topic.", file=sys.stderr)
    sys.exit(2)
for s in data:
    if not isinstance(s, dict) or "id" not in s or "narration" not in s:
        print("factory: idea must be a JSON scene array. will not invent a topic.", file=sys.stderr)
        sys.exit(2)
PY2

mkdir -p out frames audio segs
cp "$IDEA" script.json
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
scripts/build_video.sh "$PAD" "$SCENES" . "$OUTFILE"

ABS_OUTFILE="$HERE/$OUTFILE"
echo "FACTORY_MP4=$ABS_OUTFILE"

DUR_SIZE=$(ffprobe -v error -show_entries format=duration,size -of default=nw=1 "$ABS_OUTFILE")
VIDEO_CODEC=$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_name,width,height -of default=nw=1 "$ABS_OUTFILE")
AUDIO_CODEC=$(ffprobe -v error -select_streams a:0 -show_entries stream=codec_name -of default=nw=1 "$ABS_OUTFILE")

echo "$DUR_SIZE"
echo "$VIDEO_CODEC"
echo "$AUDIO_CODEC"

DURATION=$(echo "$DUR_SIZE" | grep -E '^duration=' | cut -d= -f2)
SIZE=$(echo "$DUR_SIZE" | grep -E '^size=' | cut -d= -f2)
VCODEC=$(echo "$VIDEO_CODEC" | grep -E '^codec_name=' | cut -d= -f2)
WIDTH=$(echo "$VIDEO_CODEC" | grep -E '^width=' | cut -d= -f2)
HEIGHT=$(echo "$VIDEO_CODEC" | grep -E '^height=' | cut -d= -f2)
ACODEC=$(echo "$AUDIO_CODEC" | grep -E '^codec_name=' | cut -d= -f2)

mkdir -p out
cat > out/RECEIPT.txt <<EOF
file=$ABS_OUTFILE
duration=$DURATION
size=$SIZE
video=${VCODEC} ${WIDTH}x${HEIGHT}
audio=$ACODEC
lane=factory.sh
EOF

echo "Wrote out/RECEIPT.txt"
echo "FACTORY_MP4=$ABS_OUTFILE"
