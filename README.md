# BlockShadow

A Matchbox shader for Autodesk Flame that builds a solid, block style drop
shadow from a matte. The matte is extruded along an angle, or towards a
vanishing point, and the shadow can be set back from the fill, shaded along
its length, softened with a gaussian blur and outlined. The fill (the Front
input or a flat colour) is comped over it.

![BlockShadow output in six rows: outlined letters with a black block shadow, the Front as the fill with a yellow shadow, a shadow shaded from red to dark and fading out, a perspective extrusion towards a point above the frame, a long soft shadow, and a striped gradient shadow from the Shadow Fill input](docs/preview.png)

*From top: Outline set to Both, width 4 (Angle -45, Length 22). The Front
as the fill (Angle -135, Length 30). Shade Extrusion from red to dark with
Far Opacity 0.2 (Angle -60, Length 70). Perspective towards a point above
the frame, Depth 0.3, shaded. A soft shadow (Angle -60, Length 60, Softness
8). A striped gradient from the Shadow Fill input (Angle -50, Length 40).
Shown comped over a background.*

## Files

| File | Purpose |
| --- | --- |
| `AM_BlockShadow.1.glsl` | Pass 1: builds the fill and carries the matte |
| `AM_BlockShadow.2.glsl` | Pass 2: distance to the fill, horizontal |
| `AM_BlockShadow.3.glsl` | Pass 3: distance to the fill, vertical |
| `AM_BlockShadow.4.glsl` | Pass 4: extrudes the matte into the block shadow and cuts out the Gap |
| `AM_BlockShadow.5.glsl` | Pass 5: distance to the silhouette (fill and shadow), horizontal |
| `AM_BlockShadow.6.glsl` | Pass 6: distance to the silhouette, vertical |
| `AM_BlockShadow.7.glsl` | Pass 7: blurs the shadow horizontally |
| `AM_BlockShadow.8.glsl` | Pass 8: blurs the shadow vertically and comps everything |
| `AM_BlockShadow.xml` | UI definition: inputs, controls, layout |
| `AM_BlockShadow.1.glsl.p` | Thumbnail shown in Flame's shader browser |

Keep all ten files together and keep the names as they are. Flame runs the
numbered passes in order and reads the `.xml` to build the node's UI.

## Install

1. Copy all eight `AM_BlockShadow.*.glsl` files, `AM_BlockShadow.xml` and
   the `AM_BlockShadow.1.glsl.p` thumbnail into the same folder on your
   Flame workstation. A shared location such as
   `/opt/Autodesk/shared/matchbox/shaders/` makes it available to every
   project, but any folder Flame can browse to works.
2. In Batch, add a **Matchbox** node. In the file browser that opens, go to
   that folder and pick `AM_BlockShadow.1.glsl`.
3. Connect your Front (RGB) and Matte (A), and optionally a Shadow Fill,
   then use the node's Result and Matte outputs.

You can also load it the same way from a Matchbox in Action or on the
timeline where Matchbox effects are supported.

## Inputs

- **Front:** RGB. Required. The node's output resolution and tagged colour
  space come from this input. It's also the fill, unless **Use Fill
  Colour** is on. In that case its pixels aren't used, so you can connect
  any clip with the resolution and colour space you want, such as the same
  clip that feeds the Matte.
- **Matte:** the shape that casts the shadow. Required.
- **Shadow Fill:** RGB, optional. A gradient, texture or any other image to
  colour the shadow with. Only used when **Use Shadow Fill Input** is on.

## Controls

The controls are on three pages.

### Block Shadow page

**Shadow**

- **Angle:** shadow direction in degrees. 0 is right, 90 is up, and the
  default of -45 is down-right. Hidden when Perspective is on.
- **Length:** how far the shadow extrudes, in pixels. Hidden when
  Perspective is on.
- **Gap:** space between the fill and the shadow, in pixels. The shadow is
  lengthened by the same amount, so the visible part stays Length long.
- **Softness:** gaussian blur on the shadow, in pixels (sigma). 0 keeps the
  edges hard.
- **Shadow Opacity:** how see-through the shadow is. 1 is solid, 0 is
  invisible. It affects both the RGB and the output matte.

**Fill**

- **Use Fill Colour:** fill with a flat colour instead of the Front input.
  Off by default.
- **Fill Colour:** the fill's colour. Only shown when Use Fill Colour is on.
- **Front Premultiplied:** turn on if the Front is already premultiplied by
  the matte, so it isn't multiplied again. Only shown when Use Fill Colour
  is off.

**Shadow Fill**

- **Use Shadow Fill Input:** colour the shadow with the Shadow Fill input
  instead of Shadow Colour. The input is lined up with the frame, not
  extruded with the shadow, so a gradient stays put as the shadow moves.
- **Shadow Colour:** the shadow's colour. Only shown when Use Shadow Fill
  Input is off.
- **Shade Extrusion:** shade the shadow along its length, from its colour
  next to the fill to Far Colour and Far Opacity at the far end. This makes
  it read as a 3D block rather than a flat cast shadow.
- **Far Colour:** colour at the far end of the shadow. Only shown when
  Shade Extrusion is on.
- **Far Opacity:** opacity at the far end. Lower it to fade the shadow out
  with distance. Only shown when Shade Extrusion is on.

**Output**

- **Shadow Only:** output just the shadow and its Silhouette outline,
  without the fill or the Fill outline. The shadow isn't cut out where the
  fill sits (beyond any Gap), so comping the fill back over it gives the
  same result as the normal output.

### Outline page

- **Outline:** which outline to draw.
  - **Off:** no outline.
  - **Fill:** around the fill, including where it sits over the shadow.
  - **Silhouette:** around the outside of the fill and shadow together.
  - **Both:** both outlines, the look in the top row of the preview.
- **Outline Width:** in pixels. Hidden when Outline is Off.
- **Outline Colour:** hidden when Outline is Off.

### Perspective page

- **Perspective:** extrude towards a vanishing point instead of along a
  fixed angle. Angle and Length are hidden while it's on.
- **Vanishing Point:** the point the shadow recedes towards, in frame
  coordinates (0 to 1, with 0.5, 0.5 the centre). It can sit outside the
  frame.
- **Depth:** how far the shadow reaches towards the vanishing point. 0 is
  none and 0.5 is halfway.

## Outputs

- **RGB:** everything comped together, premultiplied. Back to front: the
  Silhouette outline, the shadow, the Fill outline, then the fill.
- **Alpha / Matte:** the combined matte of all of those.

With **Shadow Only** on, RGB is the premultiplied shadow and its Silhouette
outline, and the matte is theirs alone.

## Notes

- **Resolution:** Length, Gap, Softness and Outline Width scale with the
  frame height, so a setup keeps its look when the resolution changes.
- **Non-square pixels:** angles and distances account for the clip's pixel
  aspect ratio, so the shadow keeps its angle on anamorphic formats.
- **Outlines and softness:** outlines follow the hard edges of the fill and
  shadow, so they stay crisp when Softness is up.
- **Outlines and opacity:** outlines don't fade with Shadow Opacity. Set
  Shadow Opacity to 0 with a Silhouette outline for a hollow, outline-only
  shadow.
- **Render cost:** the shadow takes one sample per pixel of Length, capped
  at 4096. Each blur pass takes about 6 × Softness samples per pixel, with
  Softness capped at 340. The outline and Gap passes take about twice their
  width in samples. Large values of any of these are slower.
- **Frame edges:** anything outside the frame is treated as empty, so
  mattes touching the frame edge don't smear into the shadow.
