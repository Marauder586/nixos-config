# Marauder's local agent guide

You are running on a NixOS workstation. The user (`marauder`) prefers terse,
direct answers and complete, working code over long explanations.

## Compute & models

- **Inference:** Ollama on the mochi host. From the mochi-guest VM the host is
  reachable at `http://10.0.2.2:11434` (OpenAI-compatible at `/v1`).
- **Default model:** `qwen2.5-coder:7b` — fast, solid for most edits.
- **Smart model:** `qwen3.5:35b` — slower, use for design / debugging when
  the small model gets stuck.
- **Chat fallback:** `llama3.1:8b`.
- **Embeddings:** `nomic-embed-text`.
- **Image gen / image-to-3D:** ComfyUI on the mochi host at
  `$COMFYUI_URL` (`http://10.0.2.2:8188`). Use the `comfyui` MCP tool.

## Sub-agents (call with `@<name>`)

- `@coder` — implement and edit code, runs tests.
- `@researcher` — web research, reads docs, summarizes.
- `@modeler` — 3D model authoring (OpenSCAD, FreeCAD, Blender Python).
- `@artist` — image generation via ComfyUI.
- `@pipeline` — image-to-3D end-to-end pipeline.

## Slash commands

- `/scad` — ask for a part by spec, get an OpenSCAD file plus an STL render.
- `/imggen` — text-to-image via ComfyUI.
- `/img23d` — image to 3D mesh (Hunyuan3D-2 / TripoSR).
- `/refactor` — targeted refactor of selected files.
- `/review` — code review of the current branch.

## Skills index

Skill notes live under `skills/`. Read them when the topic comes up.

- `skills/coding.md` — style, testing, git etiquette
- `skills/web-research.md` — fetch / search / Playwright workflow
- `skills/3d-modeling.md` — CAD / mesh / slicer toolbelt
- `skills/image-generation.md` — ComfyUI prompts and workflows
- `skills/image-to-3d.md` — image → mesh pipeline (Hunyuan3D-2 etc.)

## Conventions

- Repo lives at `~/nixos-config`. Rebuild: `sudo nixos-rebuild switch --flake .#mochi-guest`.
- Use the `Edit` tool for existing files, `Write` only for new ones.
- Run tests / formatters before declaring a task done.
- Never push to `main` without explicit permission.
- For temp files, use `~/comfy-out/` (already in place) or `/tmp`.
