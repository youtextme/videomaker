---
name: prompt-to-video
description: Turns any URL, article, or text prompt into a fully-narrated 60-second explainer video, rendered 100% locally on Windows with open-source tools (ffmpeg + Windows SAPI TTS + Playwright slide rendering). No paid APIs, no rate limits, no cloud. Use when the user says "make a video", "prompt to video", "60 second explainer", "turn this article into video", or asks for narrated slideshow/Ken Burns videos.
---

# Prompt to Video — local open-source pipeline

Turn text/URL → script → slides (HTML/SVG) → local TTS → ffmpeg mp4 (~60s, 1920x1080).
Zero cloud: everything runs on the machine. Verified end-to-end on Windows 11 + PowerShell 5.1.

## Hard rules

1. LOCAL ONLY: no paid APIs, no rate-limited services, no uploads. ffmpeg (gyan build) + System.Speech + Playwright.
2. LIKENESS SAFETY: NEVER animate/deepfake a real person's face or voice — especially minors.
   If given a photo of a real person, use an ORIGINAL cartoon character instead and say why.
3. Every "done" claim ships with receipts: ffprobe duration/resolution + exit codes.

## Pipeline

Work in a project dir `<slug>/` with `frames/ audio/ scenes/ segs/ out/`.

1. **Distill** source into 6-10 scenes of ~18-22 spoken words each (~150 words ≈ 55s at SAPI rate 3).
2. **Script** — copy `scripts/make_slides.mjs`, edit the `scenes[]` array:
   `id, variant (tower|palace|hanok|river|sunrise), accent hex, kicker, title, sub, caption (on-screen subtitle), narration (spoken)`.
3. **Slides**: `node scripts/make_slides.mjs` → `scenes/sceneN.html`.
4. **Render**: `node scripts/shoot_slides.mjs 8` (Playwright) → `frames/sceneN.png`
   (or screenshot each file:// scene via an agent browser tool at 1920x1080).
5. **TTS**: `powershell -File scripts/tts_sapi.ps1 -Rate 3` → `audio/sceneN.wav`.
   Measure: `ffprobe -v error -show_entries format=duration -of csv=p=0 audio\sceneN.wav`.
   Tune to land total speech ≈ 52-56s: raise/lower `-Rate` (0..4), trim narration.
6. **Assemble**: `powershell -File scripts/build_video.ps1` → `out/<name>.mp4`
   (Ken Burns zoompan alternating in/out per scene, apad +0.6s per scene, concat, h264 crf19 + aac).
7. **Verify**: ffprobe duration ∈ [55,65], streams = h264+aac, spot-extract a frame and view it.

## Tuning cheatsheet

- Too long → `-Rate 4` or cut words; too short → `-Pad 0.9` on build_video.ps1.
- Different voice → edit tts_sapi.ps1 `$synth.SelectVoice(...)`; list voices via
  `powershell -c "Add-Type -AssemblyName System.Speech; (New-Object System.Speech.Synthesis.SpeechSynthesizer).GetInstalledVoices() | % {$_.VoiceInfo.Name}"`.
- New backdrops → add an SVG block to `skylines` in make_slides.mjs (1920x1080 viewBox).

## Requirements

Windows w/ ffmpeg in PATH (`winget install Gyan.FFmpeg`), Node ≥ 20, Python not required,
Playwright optional for headless screenshots (`npm i playwright` or use agent browser MCP).
