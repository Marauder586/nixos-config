---
description: Generate an image from a prompt via the host ComfyUI.
agent: artist
---

# /imggen $ARGUMENTS

Generate an image: **$ARGUMENTS**

1. Pick the right checkpoint (Flux for photoreal, SDXL for stylised, SD1.5
   for fast iteration). Default: SDXL.
2. Submit via the `comfyui` MCP `queue_prompt` with the
   `skills/comfyui-workflows/txt-to-img-sdxl.json` workflow, replacing the
   positive prompt.
3. Save output to `~/comfy-out/$(date +%s).png`.
4. Print the path and a `xdg-open <path>` command.
