# Image-to-3D skill

Pipeline: **prompt → reference image → 3D mesh → cleaned STL**.

Runs on ComfyUI on the mochi host. The custom nodes (and model weights)
ship with the host's `comfyui` service when `features.comfyui-image-to-3d`
is enabled.

## Model menu

| Model         | Output         | VRAM (1024²) | Notes                                                |
| ------------- | -------------- | ------------ | ---------------------------------------------------- |
| Hunyuan3D-2   | textured GLB   | ~12 GB       | **Default.** Best quality. Tencent / kijai nodes.    |
| TripoSR       | geometry OBJ   | ~6 GB        | Fastest. No textures.                                |
| InstantMesh   | textured OBJ   | ~10 GB       | Solid fallback when Hunyuan refuses or hangs.        |
| TRELLIS       | textured GLB   | ~16 GB       | Highest fidelity but custom CUDA ops, RDNA4 unstable.|

## Reference image guidelines (matters more than the model)

- Square aspect (1024×1024).
- Single subject, centered.
- Plain background — pure white or 50%-grey works best.
- Three-quarter or front view.
- Even lighting, no harsh shadows.
- Avoid motion blur, transparency, reflective surfaces.

If the user-supplied image violates these, either (a) ask them to retake,
or (b) preprocess: `magick input.png -gravity center -extent 1024x1024 \
-background white -alpha remove squared.png`.

## End-to-end recipe

```bash
# 1. Generate or accept reference image  (prompt → PNG)
#    -> ~/comfy-out/$slug.png

# 2. Submit Hunyuan3D-2 workflow
JOB=$(jq --arg img "$slug.png" \
  '.["10"].inputs.image = $img' \
  ~/.config/opencode/skills/comfyui-workflows/img-to-3d-hunyuan3d.json \
  | curl -s -X POST "$COMFYUI_URL/prompt" -H 'content-type: application/json' -d @- \
  | jq -r .prompt_id)

# 3. Poll until /history/$JOB has output
while ! curl -s "$COMFYUI_URL/history/$JOB" | jq -e '.[].outputs' >/dev/null; do
  sleep 3
done

# 4. Pull the GLB
GLB=$(curl -s "$COMFYUI_URL/history/$JOB" | jq -r '.[].outputs."42".gltf[0].filename')
curl -s "$COMFYUI_URL/view?filename=$GLB&type=output" -o ~/comfy-out/$slug.glb

# 5. Convert / decimate / export STL
assimp export ~/comfy-out/$slug.glb ~/comfy-out/$slug-raw.stl
meshlabserver -i ~/comfy-out/$slug-raw.stl -o ~/comfy-out/$slug.stl \
  -s ~/.config/opencode/skills/meshlab-decimate-50k.mlx

# 6. Visual check
f3d ~/comfy-out/$slug.stl
```

## Quality / failure modes

| Symptom                              | Fix                                        |
| ------------------------------------ | ------------------------------------------ |
| Backside is mush                     | Retry with a 3/4 view image.               |
| Mesh self-intersecting               | Run MeshLab "Close Holes" + "Re-Mesh".     |
| Texture is mirrored                  | `assimp export -fi flipuvs ...`.           |
| GLB looks fine, STL is nonsense      | Vertex colours dropped; export OBJ instead.|
| Hunyuan crashes OOM                  | Fall back to TripoSR workflow.             |
