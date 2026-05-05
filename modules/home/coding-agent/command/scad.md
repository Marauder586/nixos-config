---
description: Generate a parametric OpenSCAD part from a natural-language spec, render it to STL.
agent: modeler
---

# /scad $ARGUMENTS

Build an OpenSCAD part for: **$ARGUMENTS**

Steps:

1. Ask 1-2 clarifying questions only if dimensions are missing.
2. Write a parametric `.scad` to `~/comfy-out/$slug.scad`. Top-level vars
   for every dimension; comment `// [min:max]` ranges so it works in the
   Customizer.
3. Render: `openscad -o ~/comfy-out/$slug.stl ~/comfy-out/$slug.scad`.
4. Report back path, bounding box, and a one-line `f3d ~/comfy-out/$slug.stl`
   command for inspection.
