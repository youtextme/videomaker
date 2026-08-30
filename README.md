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
| `scripts/factory.sh` | — | user idea (JSON, `-f`, stdin, or text) → ffmpeg cards + vendor Ken Burns |
| `scripts/idea_to_script.py` | — | deterministic 4-scene JSON from raw idea text (called by factory.sh) |
| `scripts/make_slates.sh` | — | FACTORY smoke only. Not Girish's cut. |

Source: https://github.com/youtextme/prompt-to-video (MIT). SKILL.md is vendored.


## Factory (idea in)

User supplies an idea — never hardcoded in repo. `scripts/factory.sh` will not invent a topic.

```bash
sudo apt-get install -y ffmpeg espeak-ng fonts-dejavu-core

# existing: script.json path
scripts/factory.sh example/slate/script.json out/videomaker_ready_30s.mp4

# raw idea from file, stdin, or argument (via idea_to_script.py → same factory lane)
scripts/factory.sh -f path/to/your_idea.txt -n my_slug out/my_slug.mp4
scripts/factory.sh -n my_slug "Your idea text here."
echo "Your idea" | scripts/factory.sh -n my_slug
```

Prints `FACTORY_MP4=<absolute path>` and ffprobe lines. The bundled slate is factory status, not a product story. Missing input exits 2.

Program-evaluable Done:

| Check | Command |
|-------|---------|
| duration ∈ [28, 32]s | `ffprobe -v error -show_entries format=duration -of csv=p=0 out/<name>.mp4` |
| h264 1920×1080 | `ffprobe -v error -select_streams v:0 -show_entries stream=codec_name,width,height -of default=nw=1 out/<name>.mp4` |
| aac audio | `ffprobe -v error -select_streams a:0 -show_entries stream=codec_name -of default=nw=1 out/<name>.mp4` |
| path printed | last `FACTORY_MP4=` line from `scripts/factory.sh` |

Automated test (example fixture only — not a product topic):

```bash
bash tests/render_lane_test.sh
```

Human checklist:

```bash
sudo apt-get install -y ffmpeg espeak-ng fonts-dejavu-core
bash tests/render_lane_test.sh
# expect: PASS duration=... video=h264,1920,1080 audio=aac
# expect: PASS mp4=.../out/example_fixture_lane.mp4
ffprobe -v error -show_entries format=duration -of csv=p=0 out/example_fixture_lane.mp4
ffprobe -v error -select_streams v:0 -show_entries stream=codec_name,width,height -of default=nw=1 out/example_fixture_lane.mp4
ffprobe -v error -select_streams a:0 -show_entries stream=codec_name -of default=nw=1 out/example_fixture_lane.mp4
scripts/factory.sh -f example/idea/fixture.txt -n example_fixture_lane out/example_fixture_lane.mp4
```

## Render on Linux (Playwright lane)

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
