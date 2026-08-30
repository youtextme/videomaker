#!/usr/bin/env bash
# Assembles frames/*.png + audio/*.wav with the prompt-to-video Ken Burns filter.
# Filter copied from vendor/prompt-to-video/scripts/build_video.ps1 — do not rewrite.
set -euo pipefail
PAD="${PAD:-0.6}"
SCENES="${SCENES:-4}"
ROOT="${ROOT:-.}"
OUTFILE="${OUTFILE:-$ROOT/out/videomaker_30s.mp4}"
if [[ $# -ge 1 ]]; then PAD="$1"; fi
if [[ $# -ge 2 ]]; then SCENES="$2"; fi
if [[ $# -ge 3 ]]; then ROOT="$3"; fi
if [[ $# -ge 4 ]]; then OUTFILE="$4"; fi

mkdir -p "$(dirname "$OUTFILE")" "$ROOT/segs"
LIST="$ROOT/segs/list.txt"
: > "$LIST"
total=0

for i in $(seq 1 "$SCENES"); do
  wav="$ROOT/audio/scene${i}.wav"
  png="$ROOT/frames/scene${i}.png"
  dur=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$wav")
  dur=$(python3 -c "print(float('$dur') + float('$PAD'))")
  total=$(python3 -c "print(float('$total') + float('$dur'))")
  frames=$(python3 -c "import math; print(math.ceil(float('$dur') * 30))")
  seg="$ROOT/segs/seg${i}.mp4"
  if (( i % 2 == 1 )); then
    zexpr="min(1+0.0011*on,1.14)"
  else
    zexpr="max(1.14-0.0011*on,1.0)"
  fi
  vf="scale=2304:1296,zoompan=z='${zexpr}':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=${frames}:s=1920x1080:fps=30,format=yuv420p"
  af="apad=whole_dur=${dur},aresample=48000"
  ffmpeg -y -loglevel error -loop 1 -i "$png" -i "$wav" \
    -filter_complex "[0:v]${vf}[v];[1:a]${af}[a]" \
    -map "[v]" -map "[a]" -t "$dur" -r 30 \
    -c:v libx264 -preset medium -crf 19 -c:a aac -b:a 160k "$seg"
  echo "file '$(realpath "$seg")'" >> "$LIST"
done

python3 -c "print('planned_total_seconds=' + str(round(float('$total'), 2)))"
ffmpeg -y -loglevel error -f concat -safe 0 -i "$LIST" -c copy "$OUTFILE"
echo "FINAL $OUTFILE"
ffprobe -v error -show_entries format=duration,size -of default=nw=1 "$OUTFILE"
