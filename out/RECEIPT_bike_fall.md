# RECEIPT — bike fall safety 60s

## Need
Playable ~60s (±5s) h264+aac mp4 Instagram-ready teaching a 10-year-old: prevent → fall smart → check → recover. Cartoon/slate + local TTS only. No deepfake, no YouTube kid clips, no Remotion/paid APIs/Whisper/Grok grind.

## Outcome: **proven** (local render). Publish: see below.

## Proven
- Script: 8 scenes at `example/bike-fall/script.json` (also copied to `script.json`)
- Landscape: `/workspace/videomaker/out/bike_fall_safety_60s.mp4`
  - duration=60.055667s
  - size=2861635 bytes
  - video=h264 1920x1080
  - audio=aac 48000 Hz
- Vertical reel crop (center scale/crop, no Ken Burns rewrite): `/workspace/videomaker/out/bike_fall_safety_60s_reel.mp4`
  - duration=60.063s
  - size=943817 bytes
  - video=h264 1080x1920
  - audio=aac
- Factory: `ESPEAK_RATE=170 TARGET_SECONDS=60 scripts/factory.sh example/bike-fall/script.json out/bike_fall_safety_60s.mp4`
- Speech pad path hit planned_total_seconds=60.0
- Content: kid-safe consensus bike safety only (helmet, look/soft brakes, driveway/doors/earbuds/bright colors, tuck chin/no stiff arms/roll, sit-breathe-check, adult help red flags, brush off/ride when ready)
- Likeness: abstract ffmpeg slates + espeak-ng only

## Killed
- Remotion, paid APIs, Whisper, deepfake/likeness, YouTube scrapes of real kids, Grok grind for narration body

## Blocked
- (fill after publish attempt)

## Instagram re-export
1. Prefer `out/bike_fall_safety_60s_reel.mp4` (9:16) for Reels upload.
2. Or upload landscape `bike_fall_safety_60s.mp4` and crop center in Instagram (safe zone: keep titles mid-frame; slates are left-anchored so vertical crop already centers the frame).
3. Re-run: `cd /workspace/videomaker && ESPEAK_RATE=170 TARGET_SECONDS=60 scripts/factory.sh example/bike-fall/script.json out/bike_fall_safety_60s.mp4` then optional reel crop:
   `ffmpeg -y -i out/bike_fall_safety_60s.mp4 -vf "scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920" -c:v libx264 -pix_fmt yuv420p -c:a aac -movflags +faststart out/bike_fall_safety_60s_reel.mp4`

## POS notes
- Writer = grind worker; TokenNoCap/Gemini-flash-preview drafted then shortened for duration gate.
- Served-by: local factory (make_slates + tts_espeak + build_video Ken Burns).
