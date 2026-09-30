# BlockShadow

A Matchbox shader for Autodesk Flame that builds a solid, block style drop
shadow from a matte. The matte is extruded along an angle, then the fill
(a flat colour or the Front input) is comped over it.

![BlockShadow output: a fill colour with a dark shadow down-right, and the Front input as fill with a yellow shadow down-left](docs/preview.png)

*Top: Fill Colour, Angle -45, Length 16. Bottom: Use Front as Fill, Angle
-135, Length 30. Shown comped over a background.*

## Files

| File | Purpose |
| --- | --- |
| `BlockShadow.glsl` | The shader |
| `BlockShadow.xml` | UI definition: inputs, controls, layout |

Keep both files together and keep them named the same. Flame looks for the
`.xml` next to the `.glsl` to build the node's UI.

## Install

1. Copy `BlockShadow.glsl` and `BlockShadow.xml` into the same folder on
   your Flame workstation. A shared location such as
   `/opt/Autodesk/shared/matchbox/shaders/` makes it available to every
   project, but any folder Flame can browse to works.
2. In Batch, add a **Matchbox** node. In the file browser that opens, go to
   that folder and pick `BlockShadow.glsl`.
3. Connect your Front (RGB) and Matte (A), then use the node's Result and
   Matte outputs.

You can also load it the same way from a Matchbox in Action or on the
timeline where Matchbox effects are supported.

## Inputs

- **Front:** RGB. Only used when **Use Front as Fill** is on.
- **Matte:** the shape that casts the shadow. Required.

## Controls

**Shadow**

- **Angle:** shadow direction in degrees. 0 is right, 90 is up, and the
  default of -45 is down-right.
- **Length:** how far the shadow extrudes, in pixels.
- **Shadow Colour:** the shadow's colour.

**Fill**

- **Use Front as Fill:** use the Front input instead of Fill Colour.
- **Front Premultiplied:** turn on if the Front is already premultiplied by
  the matte, so it isn't multiplied again. Only applies with Use Front as
  Fill.
- **Fill Colour:** the fill's colour when not using the Front.

## Outputs

- **RGB:** the fill comped over the shadow, premultiplied.
- **Alpha / Matte:** the fill and shadow mattes combined.

## Notes

- The shadow takes one sample per pixel of Length, capped at 4096, so very
  long shadows cost more to render.
- Anything outside the frame is treated as empty, so mattes touching the
  frame edge don't smear into the shadow.
