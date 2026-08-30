#!/usr/bin/env bash
# Neutral 1920x1080 PNG slates from script.json (no Playwright required).
# Full illustrated slides: node scripts/make_slides.mjs && node scripts/shoot_slides.mjs
set -euo pipefail
ROOT="${1:-.}"
SCRIPT="${2:-$ROOT/script.json}"
OUTDIR="${3:-$ROOT/frames}"
FONT="${FONT:-/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf}"
if [[ ! -f "$FONT" ]]; then
  FONT=$(fc-list : file | python3 -c 'import sys; print(sys.stdin.readline().split(":")[0].strip())')
fi
mkdir -p "$OUTDIR"
python3 - "$SCRIPT" "$OUTDIR" "$FONT" << 'PY2'
import json, subprocess, sys
from pathlib import Path
script, outdir, font = sys.argv[1:4]
scenes = json.loads(Path(script).read_text())
for s in scenes:
    sid = s["id"]
    title = s.get("title") or "videomaker ready"
    sub = s.get("sub") or ""
    kicker = s.get("kicker") or "VIDEOMAKER"
    png = Path(outdir) / f"scene{sid}.png"
    # escape drawtext specials
    def esc(t):
        t = t.replace("\\", "\\\\").replace(":", "\\:").replace("'", "\u2019")
        return "'" + t + "'"
    vf = (
        f"drawtext=fontfile={font}:text={esc(kicker)}:fontcolor=0xD9A441:fontsize=36:"
        f"x=80:y=56,"
        f"drawtext=fontfile={font}:text={esc(title)}:fontcolor=white:fontsize=72:"
        f"x=80:y=200,"
        f"drawtext=fontfile={font}:text={esc(sub)}:fontcolor=0xB8C7DD:fontsize=36:"
        f"x=80:y=320"
    )
    subprocess.check_call([
        "ffmpeg", "-y", "-loglevel", "error",
        "-f", "lavfi", "-i", "color=c=0x0E1626:s=1920x1080:d=1",
        "-vf", vf, "-frames:v", "1", str(png),
    ])
    print("slate", png)
PY2
