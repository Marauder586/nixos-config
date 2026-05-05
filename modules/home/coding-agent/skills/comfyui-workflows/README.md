# ComfyUI workflow templates

Drop ComfyUI workflow JSON files here and they become available to the
`@artist` and `@pipeline` sub-agents. Two ways to author a workflow:

1. **Build it visually.** Open ComfyUI in the browser
   (`xdg-open http://10.0.2.2:8188`), wire nodes, then **Save → API
   Format**. Drop the resulting `.json` in this directory.
2. **Hand-edit JSON.** Each top-level key is a node id; `class_type` picks
   the node, `inputs` are its parameters. The `comfyui` MCP `queue_prompt`
   action expects exactly this shape.

## Naming convention

- `txt-to-img-<checkpoint>.json`
- `img-to-img-<checkpoint>.json`
- `img-to-3d-<model>.json`
- `controlnet-<kind>-<checkpoint>.json`

## Field overrides

Skills patch workflows in-flight via `jq`. Common overrides:

| Override                | Path                                        |
| ----------------------- | ------------------------------------------- |
| Positive prompt         | `."6".inputs.text`                          |
| Negative prompt         | `."7".inputs.text`                          |
| Seed                    | `."3".inputs.seed`                          |
| Steps                   | `."3".inputs.steps`                         |
| CFG                     | `."3".inputs.cfg`                           |
| Input image (img2img)   | `."10".inputs.image`                        |

(IDs vary per workflow — open the JSON to confirm before patching.)

## Provided templates

Drop these in once you've authored them in the ComfyUI UI:

- `txt-to-img-sdxl.json`
- `txt-to-img-flux.json`
- `txt-to-img-sd15.json`
- `img-to-img-sdxl.json`
- `img-to-3d-hunyuan3d.json`
- `img-to-3d-triposr.json`
- `img-to-3d-instantmesh.json`

The first time the agent runs and a template is missing, it should ask
the user to open ComfyUI, build the workflow, and save it as API JSON to
the appropriate filename — these are not redistributable because the
exact node graph depends on the model files installed on the host.
