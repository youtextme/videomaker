# Need — videomaker scaffold

**Status:** scaffold write (writer report; Critique grades)
**Surface:** 30-second Prompt-OS video factory — render lane only

---

## Job

Create repo `youtextme/videomaker` with a working **30s** render lane that **reuses** [youtextme/prompt-to-video](https://github.com/youtextme/prompt-to-video). Girish drops an idea later. Do not invent a first video topic. Do not render a dummy story as "the" product.

## Success

- Public GitHub repo matching sibling `prompt-to-video` visibility (public).
- README: factory + Need to Critique + reuse table + Linux (ffmpeg+espeak) + Windows (SAPI).
- Thin wrappers: 4 scenes, shorter VO, **same** Ken Burns ffmpeg as vendor.
- `AGENTS.md` + `pos/need.md`: Need freeze, writer != grader, terminal proven|killed|blocked, no likeness/deepfake of real people or minors.
- Neutral smoke slate titled **videomaker ready** under `out/`.
- Project `opencode.json` allows edit+bash; global config untouched.

## Kill

- Rebuilding Remotion / encoder from scratch
- Paid APIs
- Inventing Girish's first video idea
- Deepfake / real-person likeness
- Grok or Cursor Cloud Agent

## Done (checkable)

| # | Check |
|---|-------|
| 1 | Repo URL exists |
| 2 | Wrappers call or vendor prompt-to-video Ken Burns (no new encoder) |
| 3 | Smoke mp4 path under `out/` |
| 4 | ffprobe duration in [28, 32] seconds |
| 5 | No API keys printed |

## Boundary

- Linux TTS = espeak-ng or piper; Windows SAPI remains optional.
- TokenNoCap / OpenCode project config only; do not weaken global deny.
- Neutral slate is factory status, not a product story.
