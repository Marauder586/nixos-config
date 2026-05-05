---
description: Image to 3D mesh. Generates an image first if given a text prompt, then converts to GLB+STL.
agent: pipeline
---

# /img23d $ARGUMENTS

Run the image-to-3D pipeline for: **$ARGUMENTS**

If `$ARGUMENTS` is a path to an existing image, skip stage 1.
Otherwise, delegate to `@artist` to generate a square reference image first.

Then submit `skills/comfyui-workflows/img-to-3d-hunyuan3d.json` via the
`comfyui` MCP, fetch the resulting GLB, run MeshLab cleanup, and report:

- Source image path
- GLB path
- Decimated STL path
- Poly count and bounding box
