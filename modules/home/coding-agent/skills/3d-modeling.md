# 3D modeling skill

## Installed tools

| Tool                  | Strength                                       |
| --------------------- | ---------------------------------------------- |
| OpenSCAD (`openscad`) | Code-driven parametric modelling. CSG-first.   |
| FreeCAD (`freecadcmd`)| Constraint-based CAD with Python API.          |
| Blender (`blender -b`)| Sculpting, animation, bpy scripting.           |
| MeshLab (`meshlabserver`) | Mesh repair, decimation, filters.          |
| `assimp`              | Convert between 40+ 3D formats.                |
| `f3d`                 | Fast 3D viewer (STL/OBJ/GLB/PLY).              |
| PrusaSlicer / SuperSlicer | FFF + SLA slicing.                         |

## OpenSCAD recipes

### Parametric box with rounded corners

```scad
// box.scad — usage: openscad -o box.stl box.scad
width  = 60; // [10:200]
depth  = 40; // [10:200]
height = 25; // [5:100]
wall   = 1.6;
radius = 3;

module rrect(w, d, r) {
    minkowski() {
        square([w - 2*r, d - 2*r], center = true);
        circle(r = r, $fn = 32);
    }
}

difference() {
    linear_extrude(height) rrect(width, depth, radius);
    translate([0, 0, wall])
        linear_extrude(height) rrect(width - 2*wall, depth - 2*wall, radius - wall);
}
```

Render: `openscad -o box.stl box.scad`.
Customizer-driven render: `openscad -p params.json -P preset -o box.stl box.scad`.

## FreeCAD scripting

```python
# part.py — run with: freecadcmd part.py
import FreeCAD as App
import Part

doc = App.newDocument("part")
box = doc.addObject("Part::Box", "Box")
box.Length, box.Width, box.Height = 60, 40, 25
doc.recompute()
Part.export([box], "/tmp/part.step")
```

## Blender headless

```python
# scene.py
import bpy, sys
argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
in_path, out_path = argv

bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=in_path)
bpy.ops.export_mesh.stl(filepath=out_path, use_selection=False)
```

```bash
blender -b -P scene.py -- input.glb output.stl
```

## Mesh repair pipeline

```bash
# Auto-fix common STL issues (manifold, normals)
meshlabserver -i broken.stl -o fixed.stl \
  -s repair.mlx
# Decimate to a target face count
meshlabserver -i fixed.stl -o decimated.stl \
  -s decimate.mlx
# Verify visually
f3d decimated.stl
```

A baseline `repair.mlx` lives at `skills/meshlab-repair.mlx`.

## Format conversion

```bash
assimp export in.glb out.stl              # textured GLB → printable STL
assimp export in.obj out.ply              # OBJ → PLY
assimp export -fi flipuvs in.fbx out.glb  # FBX → GLB, fix UVs
```

## Slicing for FFF print

```bash
prusa-slicer --export-gcode \
  --load ~/.config/PrusaSlicer/profiles/printer.ini \
  --load ~/.config/PrusaSlicer/profiles/material.ini \
  decimated.stl
```
