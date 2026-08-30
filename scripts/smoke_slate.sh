#!/usr/bin/env bash
# FACTORY ONLY. Colored ffmpeg cards. NOT the Girish Ken Burns lane.
# Girish cut: scripts/render_30s.sh (vendor make_slides + shoot_slides).
set -euo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
cd "$HERE"
mkdir -p out frames audio segs
cp example/slate/script.json script.json
scripts/render_30s.sh script.json out/videomaker_ready_30s.mp4
echo "SMOKE_MP4=$HERE/out/videomaker_ready_30s.mp4"
ffprobe -v error -show_entries format=duration,size -of default=nw=1 out/videomaker_ready_30s.mp4
ffprobe -v error -select_streams v:0 -show_entries stream=codec_name,width,height -of default=nw=1 out/videomaker_ready_30s.mp4
ffprobe -v error -select_streams a:0 -show_entries stream=codec_name -of default=nw=1 out/videomaker_ready_30s.mp4
