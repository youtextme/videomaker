# prompt-to-video

Turn any URL, article, or text prompt into a **60-second narrated explainer video** — rendered
**100% locally** on Windows with open-source tools. No paid APIs, no rate limits, no cloud.

```
text/URL ──► scene script (JSON) ──► HTML/SVG slides ──► Playwright PNGs
                                                        │
                 ffmpeg concat + Ken Burns ◄── SAPI TTS WAVs
                                                        ▼
                                        out/<name>.mp4  (1920x1080 h264+aac, ~60s)
```

See `SKILL.md` for the agent skill definition and `scripts/` for the pipeline.

## Quickstart (cold machine)

```powershell
winget install Gyan.FFmpeg          # ffmpeg 9.x full build
git clone https://github.com/youtextme/prompt-to-video
cd prompt-to-video/example
node ../scripts/make_slides.mjs                          # scenes/*.html + script.json
node ../scripts/shoot_slides.mjs 8                       # frames/*.png (needs `npm i playwright`)
powershell -File ../scripts/tts_sapi.ps1 -Rate 3         # audio/*.wav (Windows built-in voice)
powershell -File ../scripts/build_video.ps1              # out/language_and_the_mind_seoul_60s.mp4
ffprobe -v error -show_entries format=duration -of csv=p=0 out\language_and_the_mind_seoul_60s.mp4
```

Verified output: duration **58.86 s**, h264 1920x1080 + aac, exit codes 0.

## Rules baked in

- **Local only**: ffmpeg + SAPI + Playwright. Nothing networked, nothing paid.
- **Likeness safety**: never deepfake/animate a real person's face or voice — especially minors.
  Use the included original cartoon guide character instead.
- **Receipts**: a run isn't done until ffprobe numbers are printed.

## Example

Source article: [The Voice Inside — Language and the Mind](https://youtextme.github.io/language-and-the-mind/)
distilled into 8 scenes presented by a cartoon local guide in illustrated Seoul.

## License

MIT
