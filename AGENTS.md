# AGENTS.md — videomaker

**Every prompt and change in this repo runs through Prompt Operating System (POS).**

Source of truth: [prompt-operating-system](https://github.com/youtextme/prompt-operating-system)

This file is repo law. Thin contracts live in `pos/`.

---

## Need freeze

Read `pos/need.md` before writing product code. This scaffold's Need is: **working 30s render lane**. Girish's first video idea is **not** in this repo yet — do not invent one.

## Writer is not the grader

The writer reports facts (paths, ffprobe numbers, exit codes). A separate Critique pass grades. Self-grade is forbidden.

## Terminal outcomes

Only **proven**, **killed**, or **blocked**. Never "looks good."

## Likeness

No deepfake / likeness of real people or minors. No cloned real voices. Use original cartoon slides from prompt-to-video or abstract slates.

## Reuse

Do not rebuild Remotion, a custom encoder, Whisper, or a paid API. Call or vendor [prompt-to-video](https://github.com/youtextme/prompt-to-video). Ken Burns filter stays the vendor zoompan line.

## OpenCode

Use the **project** `opencode.json` (`permission.edit=allow`, `permission.bash=allow`, tokennocap provider). Do not permanently weaken `~/.config/opencode/opencode.json`.
