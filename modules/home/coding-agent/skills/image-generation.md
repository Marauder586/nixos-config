# Image generation skill (ComfyUI)

ComfyUI runs on the **mochi host**. From the guest it is reachable at
`$COMFYUI_URL` (default `http://10.0.2.2:8188`).

## Access patterns

### Via the `comfyui` MCP (preferred)

```
comfyui.list_workflows()           # list saved workflow JSONs
comfyui.queue_prompt(workflow=...) # POST /prompt
comfyui.get_image(prompt_id=...)   # GET /history then /view
```

### Via the HTTP API directly

```bash
# Probe
curl -s "$COMFYUI_URL/system_stats" | jq

# Submit a prompt graph
curl -s -X POST "$COMFYUI_URL/prompt" \
  -H 'content-type: application/json' \
  -d @workflow.json | jq -r .prompt_id

# Poll
curl -s "$COMFYUI_URL/history/$PROMPT_ID" | jq

# Download the result
curl -s "$COMFYUI_URL/view?filename=$NAME&type=output" -o out.png
```

## Workflow templates

Reusable JSON graphs live at `skills/comfyui-workflows/`:

- `txt-to-img-sdxl.json` — SDXL base+refiner, 1024².
- `txt-to-img-flux.json` — Flux.1-dev fp8.
- `txt-to-img-sd15.json` — SD 1.5 quick draft, 512².
- `img-to-img-sdxl.json` — denoise from a starting image.
- `img-to-3d-hunyuan3d.json` — Hunyuan3D-2 (textured mesh).
- `img-to-3d-triposr.json` — TripoSR (geometry only).
- `img-to-3d-instantmesh.json` — InstantMesh fallback.

Replace the `text` field of CLIP-text-encode nodes (id `"6"` in most
templates) with the user prompt. Replace seed in KSampler node when you
want determinism.

## Prompt anatomy

```
<subject>, <action / pose>, <medium>, <lighting>, <style cues>
```

Examples:

- `a brass pocket watch on a velvet cloth, macro photo, soft window light, shallow depth of field, 8k`
- `low-poly fox character, T-pose, plain white background, isometric view, blender render`

Negative prompt boilerplate:

```
blurry, low quality, jpeg artifacts, watermark, text, deformed, extra limbs
```

## Quality knobs

| Knob              | Effect                                                  |
| ----------------- | ------------------------------------------------------- |
| `steps`           | More = better detail, diminishing returns past 30.      |
| `cfg`             | 5-7 photoreal, 7-10 stylised. Higher = more literal.    |
| `sampler`         | `dpmpp_2m_karras` is a good default.                    |
| `denoise`         | img2img: 0.3 light edit, 0.7 heavy reimagining.         |
| `width / height`  | SDXL likes multiples of 64; native 1024².               |

## Output convention

Save to `~/comfy-out/<unix-timestamp>-<slug>.png`. Print the path and a
`xdg-open` command back to the user.
