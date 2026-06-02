# HexaBotArt

HexaBotArt is a Processing sketch that converts images into drawing paths for drawbots, polargraph machines, and marker-based plotters. It can export both SVG and Klipper-compatible GCODE output, and supports up to 6 Copic marker pens with swappable drawing styles.

## Features

- Image-to-path conversion with multiple path-finding strategies
- SVG export for combined and per-pen output
- Klipper GCODE export for Makelangelo-style polar drawing
- 6-pen Copic marker support with 25 predefined color sets
- Runtime controls for pen distribution, zoom, view modes, and export
- Configuration controlled from `Config.pde`

## Requirements

- Processing 3 or newer
- No external libraries required

## Running

1. Open `HexaBotArt.pde` in the Processing IDE.
2. Press **Run** (Ctrl+R).
3. Use the keyboard controls to select a path-finding module, adjust pen distribution, and save output.

## Controls

| Key | Description |
|---|---|
| `p` | Cycle Path Finding Module (PFM) |
| `r` | Rotate drawing |
| `[` | Zoom in |
| `]` | Zoom out |
| `\` | Reset zoom / offset / rotation |
| `O` | Show original image |
| `o` | Show pre-processed image |
| `l` | Show processed line image |
| `d` | Show full rendered drawing |
| `Ctrl+1`…`Ctrl+6` | Show individual pen layers |
| `S` | Stop path finding early |
| `Esc` | Exit sketch |
| `,` / `.` | Decrease / increase total lines |
| `g` | Generate SVG output |
| `s` | Save PNG screenshot |
| `G` | Toggle grid overlay |
| `t` | Redistribute lines evenly across pens |
| `y` | Send all lines to pen 0 |
| `9` / `0` | Lighten / darken pen distribution |
| `1`–`6` | Increase line weight for pen 1–6 |
| `Shift+1`–`Shift+6` | Decrease line weight for pen 1–6 |
| `:` / `;` | Cycle Copic marker sets |

## Output

- `svg/` — generated SVG files (combined and per pen)
- `gcode/` — generated Klipper GCODE files when enabled
- `renderings/` — saved PNG screenshots

## Configuration

All settings live in `Config.pde`.

Key settings:

- `paper_size_x` / `paper_size_y` — paper dimensions in mm
- `pen_count` — number of pens
- `current_copic_set` — active Copic palette index
- `MM_TO_PX` — scale conversion factor
- `makelangelo` — enable GCODE export
- `penup` / `pendown` — servo positions

## Project structure

- `HexaBotArt.pde` — main sketch and application flow
- `BotDrawing.pde` — drawing buffer, rendering, and pen distribution
- `BotLine.pde` — line segment data structure
- `Bresenham.pde` — raster line and brightness sampling utilities
- `Copic.pde` — Copic palette database and nearest-color matching
- `Config.pde` — sketch configuration constants
- `gcodeout_klipper.pde` — Klipper GCODE exporter
- `gcodeout_marlin.pde_` — disabled Marlin GCODE exporter
- `PFM_original.pde`, `PFM_spiral.pde`, `PFM_squares.pde` — path-finding modules
- `svgout.pde` — SVG export routines
- `helpers.pde` — helper UI and display utilities

## Notes

This project is inspired by `Drawbot_image_to_gcode_v2` and extended for multi-pen Copic workflows. Demo images are available in `pics/`, and sample outputs are stored in `svg/`.
