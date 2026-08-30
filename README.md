# videomaker

**30-second video factory** for Prompt OS. Girish drops an idea later. This repo is the render lane only — not a first video topic.

```
Need (idea later) ──► scene JSON ──► vendor make_slides + shoot_slides (Playwright PNG)
                                      |
           ffmpeg concat + Ken Burns ◄── local TTS (espeak-ng / SAPI)
                                      v
                    out/<name>.mp4  (1920x1080 h264+aac, ~30s)
```

Writer is not the grader. A run is not done until ffprobe duration is printed.

## Need (frozen for this scaffold)

Ship a real repo with a working **30s** render lane that **reuses** [youtextme/prompt-to-video](https://github.com/youtextme/prompt-to-video). Do not invent the first video. Do not rebuild a renderer.

## Critique

- Writer never grades itself.
- Terminal status only: **proven** / **killed** / **blocked**.
- Kill: Remotion, custom encoder, Whisper, paid APIs, deepfake / real-person likeness (especially minors), inventing Girish's first video idea.

## Reuse

| This repo | Existing wheel | Change |
|-----------|----------------|--------|
| `vendor/prompt-to-video/scripts/build_video.ps1` | Ken Burns zoompan + concat | unchanged vendor copy |
| `scripts/build_video.ps1` / `scripts/build_video.sh` | same `scale=2304:1296,zoompan=...` | default **4 scenes**, 30s outfile |
| `vendor/prompt-to-video/scripts/make_slides.mjs` | HTML/SVG slides + mascot | called in place; accepts `script.json` |
| `vendor/prompt-to-video/scripts/shoot_slides.mjs` | Playwright 1920x1080 PNG | called in place |
| `vendor/prompt-to-video/scripts/tts_sapi.ps1` | Windows SAPI | called in place |
| `scripts/tts_espeak.sh` | — | Linux/CI local TTS (espeak-ng) |
| `scripts/factory.sh` | — | idea in (script.json required). ffmpeg cards + vendor Ken Burns. |
| `scripts/make_slates.sh` | — | FACTORY smoke only. Not Girish's cut. |

Source: https://github.com/youtextme/prompt-to-video (MIT). SKILL.md is vendored.


## Factory (idea in)

Girish drops a real idea later as `script.json`. The factory will not invent a topic.

```bash
scripts/factory.sh example/slate/script.json out/videomaker_ready_30s.mp4
```

The bundled slate is factory status, not a product story. Missing input exits 2.

## Render on Linux (this box / CI)

Girish cut needs `ffmpeg`, `espeak-ng`, and Playwright. Smoke slates are factory-only.

```bash
sudo apt-get install -y ffmpeg espeak-ng fonts-dejavu-core
scripts/render_30s.sh example/slate/script.json out/videomaker_30s.mp4
ffprobe -v error -show_entries format=duration -of csv=p=0 out/videomaker_30s.mp4
```

Smoke (neutral slate titled **videomaker ready**, not a product story):

```bash
scripts/smoke_slate.sh
```

## Render on Windows (SAPI)

```powershell
winget install Gyan.FFmpeg
node vendor/prompt-to-video/scripts/make_slides.mjs script.json
node vendor/prompt-to-video/scripts/shoot_slides.mjs 4
powershell -File vendor/prompt-to-video/scripts/tts_sapi.ps1 -Rate 3
powershell -File scripts/build_video.ps1
ffprobe -v error -show_entries format=duration -of csv=p=0 out\videomaker_30s.mp4
```

## Done

- `ffprobe` duration **~30s (±2s)**
- playable **mp4** path printed
- streams: h264 1920x1080 + aac

## OpenCode

Project `opencode.json` allows `edit` + `bash` and keeps the `tokennocap` provider. It does **not** change `~/.config/opencode/opencode.json` (global stays `edit=deny` / `bash=deny`).

## License

MIT. Includes MIT copies of prompt-to-video under `vendor/prompt-to-video/`.
