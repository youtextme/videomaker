#!/usr/bin/env bash
# Program-evaluable checks for factory.sh (example fixture only).
set -euo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
cd "$HERE"
FIXTURE="$HERE/example/idea/fixture.txt"
NAME="example_fixture_lane"
OUT="$HERE/out/${NAME}.mp4"

if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "BLOCKED: ffmpeg missing" >&2
  exit 2
fi
if ! command -v espeak-ng >/dev/null 2>&1; then
  echo "BLOCKED: espeak-ng missing" >&2
  exit 2
fi

MP4_LINE="$(scripts/factory.sh -f "$FIXTURE" -n "$NAME" "$OUT")"
MP4="$(printf '%s\n' "$MP4_LINE" | grep '^FACTORY_MP4=' | tail -1 | cut -d= -f2-)"
[[ -n "$MP4" ]] || { echo "factory did not print FACTORY_MP4" >&2; exit 1; }
[[ -f "$MP4" ]] || { echo "missing output: $MP4" >&2; exit 1; }

duration="$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$MP4")"
vcodec="$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_name,width,height -of csv=p=0 "$MP4")"
acodec="$(ffprobe -v error -select_streams a:0 -show_entries stream=codec_name -of csv=p=0 "$MP4")"

python3 - "$duration" "$vcodec" "$acodec" << 'PY'
import sys
dur = float(sys.argv[1])
v = sys.argv[2].split(",")
a = sys.argv[3]
assert 28 <= dur <= 32, f"duration {dur} not in [28,32]"
assert v[0] == "h264" and int(v[1]) == 1920 and int(v[2]) == 1080, f"bad video stream: {v}"
assert a == "aac", f"bad audio stream: {a}"
print(f"PASS duration={dur:.3f} video={','.join(v)} audio={a}")
PY

echo "PASS mp4=$MP4"
