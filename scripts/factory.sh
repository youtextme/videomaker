#!/usr/bin/env bash
# Local factory: user idea (script.json, -f file, stdin, or text arg) → ~30s mp4.
# Will not invent a topic. ffmpeg cards + vendor Ken Burns via build_video.sh.
# Girish Playwright lane remains scripts/render_30s.sh (not used here).
set -euo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
cd "$HERE"

SCRIPT_PATH=""
OUTFILE="out/videomaker_30s.mp4"
IDEA_FILE=""
IDEA_TEXT=""
NAME=""

usage() {
  cat >&2 <<'EOF'
Usage:
  scripts/factory.sh script.json [outfile.mp4]
  scripts/factory.sh -f idea.txt [-n slug] [outfile.mp4]
  scripts/factory.sh -n slug "idea text"
  echo "idea" | scripts/factory.sh [-n slug] [outfile.mp4]
EOF
}

slugify() {
  python3 - "$1" << 'PY'
import re, sys
text = sys.argv[1].lower()
text = re.sub(r"[^a-z0-9]+", "_", text).strip("_")
print(text[:48] or "idea")
PY
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -f|--file)
      [[ $# -ge 2 ]] || { echo "factory: missing path after $1" >&2; usage; exit 2; }
      IDEA_FILE="$2"
      shift 2
      ;;
    -n|--name)
      [[ $# -ge 2 ]] || { echo "factory: missing slug after $1" >&2; usage; exit 2; }
      NAME="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      IDEA_TEXT="$*"
      break
      ;;
    -*)
      echo "factory: unknown option $1" >&2
      usage
      exit 2
      ;;
    *)
      if [[ -z "$SCRIPT_PATH" && -z "$IDEA_FILE" && -z "$IDEA_TEXT" ]]; then
        if [[ -f "$1" ]]; then
          SCRIPT_PATH="$1"
          shift
          [[ $# -gt 0 ]] && OUTFILE="$1" && shift
        else
          IDEA_TEXT="$1"
          shift
          [[ $# -gt 0 ]] && OUTFILE="$1" && shift
        fi
      else
        OUTFILE="$1"
        shift
      fi
      ;;
  esac
done

if [[ $# -gt 0 ]]; then
  echo "factory: unexpected argument: $*" >&2
  usage
  exit 2
fi

RAW_IDEA=""
if [[ -n "$IDEA_FILE" ]]; then
  [[ -f "$IDEA_FILE" ]] || { echo "factory: missing $IDEA_FILE" >&2; exit 2; }
  RAW_IDEA="$(cat "$IDEA_FILE")"
elif [[ -n "$IDEA_TEXT" ]]; then
  RAW_IDEA="$IDEA_TEXT"
elif [[ -z "$SCRIPT_PATH" ]] && [[ ! -t 0 ]]; then
  RAW_IDEA="$(cat)"
fi

if [[ -n "$RAW_IDEA" ]]; then
  RAW_IDEA="$(printf '%s' "$RAW_IDEA" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
  if [[ -z "$RAW_IDEA" ]]; then
    echo "factory: empty idea. will not invent a topic." >&2
    exit 2
  fi
  mkdir -p .factory
  GENERATED=".factory/script.json"
  python3 "$HERE/scripts/idea_to_script.py" -o "$GENERATED" "$RAW_IDEA" >&2
  SCRIPT_PATH="$GENERATED"
  if [[ -n "$NAME" ]]; then
    OUTFILE="out/$(slugify "$NAME").mp4"
  elif [[ -n "$IDEA_FILE" ]]; then
    base="$(basename "$IDEA_FILE")"
    OUTFILE="out/$(slugify "${base%.*}").mp4"
  fi
fi

if [[ -z "$SCRIPT_PATH" ]]; then
  echo "factory: need script.json or a user idea. will not invent a topic." >&2
  usage
  exit 2
fi
if [[ ! -f "$SCRIPT_PATH" ]]; then
  echo "factory: missing $SCRIPT_PATH" >&2
  exit 2
fi

python3 - "$SCRIPT_PATH" << 'PY2'
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
cp "$SCRIPT_PATH" script.json
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
