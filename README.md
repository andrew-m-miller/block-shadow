# BlockShadow

A Matchbox shader for Autodesk Flame that builds a solid, block style drop
shadow from a matte. The matte is extruded along an angle, optionally
softened with a gaussian blur, then the fill (a flat colour or the Front
input) is comped over it.

![BlockShadow output: a fill colour with a hard dark shadow down-right, the Front input as fill with a yellow shadow down-left, and a blue fill with a long soft shadow](docs/preview.png)

*Top: Fill Colour, Angle -45, Length 16. Middle: Use Front as Fill, Angle
-135, Length 30. Bottom: Angle -60, Length 60, Softness 8. Shown comped over
a background.*

## Files

| File | Purpose |
| --- | --- |
| `BlockShadow.1.glsl` | Pass 1: builds the fill and carries the matte |
| `BlockShadow.2.glsl` | Pass 2: extrudes the matte into the block shadow |
| `BlockShadow.3.glsl` | Pass 3: blurs the shadow horizontally |
| `BlockShadow.4.glsl` | Pass 4: blurs the shadow vertically and comps the fill over it |
| `BlockShadow.xml` | UI definition: inputs, controls, layout |

Keep all five files together and keep the names as they are. Flame runs the
numbered passes in order and reads the `.xml` to build the node's UI.

## Install

1. Copy all four `BlockShadow.*.glsl` files and `BlockShadow.xml` into the
   same folder on your Flame workstation. A shared location such as
   `/opt/Autodesk/shared/matchbox/shaders/` makes it available to every
   project, but any folder Flame can browse to works.
2. In Batch, add a **Matchbox** node. In the file browser that opens, go to
   that folder and pick `BlockShadow.1.glsl`.
3. Connect your Front (RGB) and Matte (A), and optionally a Shadow Fill,
   then use the node's Result and Matte outputs.

You can also load it the same way from a Matchbox in Action or on the
timeline where Matchbox effects are supported.

## Inputs

- **Front:** RGB. Only used when **Use Front as Fill** is on.
- **Matte:** the shape that casts the shadow. Required.
- **Shadow Fill:** RGB, optional. A gradient, texture or any other image to
  colour the shadow with. Only used when **Use Shadow Fill Input** is on.

## Controls

**Shadow**

- **Angle:** shadow direction in degrees. 0 is right, 90 is up, and the
  default of -45 is down-right.
- **Length:** how far the shadow extrudes, in pixels.
- **Softness:** gaussian blur on the shadow, in pixels (sigma). 0 keeps the
  edges hard.
- **Shadow Opacity:** how see-through the shadow is. 1 is solid, 0 is
  invisible. It affects both the RGB and the output matte.
- **Shadow Only:** output just the shadow, without the fill. The shadow isn't
  cut out where the fill sits, so comping the fill back over it gives the
  same result as the normal output.

**Fill**

- **Use Front as Fill:** use the Front input instead of Fill Colour.
- **Front Premultiplied:** turn on if the Front is already premultiplied by
  the matte, so it isn't multiplied again. Only applies with Use Front as
  Fill.
- **Fill Colour:** the fill's colour when not using the Front.

**Shadow Fill**

- **Use Shadow Fill Input:** colour the shadow with the Shadow Fill input
  instead of Shadow Colour. The input is lined up with the frame, not
  extruded with the shadow, so a gradient stays put as the shadow moves.
- **Shadow Colour:** the shadow's colour when not using the Shadow Fill
  input.

## Outputs

- **RGB:** the fill comped over the shadow, premultiplied.
- **Alpha / Matte:** the fill and shadow mattes combined.

With **Shadow Only** on, RGB is the premultiplied shadow and the matte is
the shadow's matte alone.

## Notes

- The shadow takes one sample per pixel of Length, capped at 4096, so very
  long shadows cost more to render.
- Each blur pass takes about 6 × Softness samples per pixel. Softness is
  capped at 340, and large values are slower too.
- Anything outside the frame is treated as empty, so mattes touching the
  frame edge don't smear into the shadow.
