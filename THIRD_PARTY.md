# Third Party Attributions

## bloub Animation System

This plugin's animated avatar is based on the **bloub** project by **Jeremy Perret** (@jeremy-prt):

- **Repository**: https://github.com/jeremy-prt/bloub
- **License**: MIT License
- **Description**: SVG recreation of the x.ai bot avatar (Grok). One shape morphing through 14 states, measured off the reference video frame by frame.

The bloub system provides:
- Radial profile-based shape morphing (64-sample profiles)
- 14 animation states (idle, thinking, wink, wide, alert, notify, exclaim, sleep, egg, hexagon, play, orbit, swirl, burst, comet)
- 8 customizable base shapes (circle, pebble, squircle, capsule, triangle, hexagon, cloud, droplet)
- 13 color palette options
- 7 rest expressions
- Smooth interpolation between states using Catmull-Rom splines
- Eye animation with gaze tracking, blinking, and breathing

This plugin uses a simplified subset of the bloub animation system, focusing on:
- The 8 base shapes for user selection
- Continuous idle morphing animation (8 keyframes)
- Eye blinking and gaze drift animations
- Color tinting via shader effect
- Theme color synchronization

## Bongo Cat Plugin Architecture

The plugin structure, settings panel, and positioning system are modeled after the **Omarchy Bongo Cat** plugin by **HANCORE**:

- **Repository**: https://github.com/HANCORE-linux/omarchy-bongocat
- **License**: MIT License
- **Author**: HANCORE

Adapted patterns:
- Service + Bar Widget architecture
- PanelWindow-based overlay positioning (locked/unlocked modes)
- Drag-to-reposition with mouse wheel resize
- Workspace-specific visibility
- Settings persistence via Omarchy's inline entry updates
- Keyboard navigation shortcuts
- Compact header buttons in panel

## Omarchy Quattro / Quickshell

- **Framework**: Omarchy Quattro shell built on Quickshell
- **Repository**: https://github.com/basecamp/omarchy
- **License**: MIT License

## SVG Animation Technology

The animated avatar uses native SVG SMIL animations (`<animate>` elements) for:
- Shape morphing (path `d` attribute interpolation)
- Eye blinking (transform scaleY)
- Gaze drift (transform translate)
- Breathing (transform scale)

This provides smooth 60fps animation without JavaScript timers, leveraging browser/Qt SVG renderer interpolation.

## Design Inspiration

- **x.ai / Grok Bot Avatar**: The visual design and animation behavior imitates the x.ai chatbot avatar as an artistic exercise
- **Not affiliated with, endorsed by, or connected to x.ai**
- "Grok" and "x.ai" are trademarks of their respective owners

## Color Palette

The default color palette is derived from the bloub customizer:
- `encre` (Ink): #0a0a0c
- `creme` (Cream): #f1efe9
- `brun` (Brown): #8b5e3c
- `rouge` (Red): #e8483f
- `orange` (Orange): #f08a24
- `ambre` (Amber): #f0b429
- `vert` (Green): #3ecf8e
- `turquoise` (Turquoise): #2fbfa0
- `bleu` (Blue): #3b93f0
- `violet` (Violet): #8b5cf6
- `rose` (Pink): #e152b0
- `gris` (Gray): #a3a3a3

## Shape Definitions

The 8 base shapes use mathematical profiles from bloub:
- **Circle**: Constant radius = 1
- **Pebble**: Low-frequency harmonic deformation
- **Squircle**: Superellipse with n=4.2
- **Capsule**: Convex hull of two circles
- **Triangle**: Rounded regular triangle (3 sides)
- **Hexagon**: Rounded regular hexagon (6 sides)
- **Cloud**: Union of 5 overlapping circles
- **Droplet**: Convex hull of two circles (teardrop)

All shapes are normalized to equal visual weight.