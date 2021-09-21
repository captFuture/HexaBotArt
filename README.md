# HexaDrawBotArt

Heavily depending on https://github.com/Scott-Cooper/Drawbot_image_to_gcode_v2
Changed output to svg and some other functions as well as keystoke map in gui.

This code is used to generate svg files for drawbots, polargraphs or other vertical drawing machines. \
It takes an original image, manipulates it and generates a drawing path that kinda sorta looks like the original image. \
This code was specifically written to work with multiple Copic markers. \
The code was intended to be heavily modified to generate different and unique drawing styles.

## Key Bindings:
| Key | Description |
| ------------- |:-------------|
| p | Load next "Path Finding Module" (PFM) |
| r | Rotate drawing |
| [ | Zoom in |
| ] | Zoom out |
| \ | Reset drawing zoom, offset and rotation |
| O | Display original image (capital letter) |
| o | Display image to be drawn after pre-processing (lower case letter) |
| l | Display image after the path finding module has manipulated it |
| d | Display drawing with all pens |
| \<ctrl> 1 | Display drawing, pen 0 only |
| \<ctrl> 2 | Display drawing, pen 1 only |
| \<ctrl> 3 | Display drawing, pen 2 only |
| \<ctrl> 4 | Display drawing, pen 3 only |
| \<ctrl> 5 | Display drawing, pen 4 only |
| \<ctrl> 6 | Display drawing, pen 5 only |
| S | Stop path finding prematurely |
| Esc | Exit running program |
| , | Decrease the total number of lines drawn |
| . | Increase the total number of lines drawn |
| g | Generate all SVGs with lines as displayed |
| G | Toggle grid |
| t | Redistribute percentage of lines drawn by each pen evenly |
| y | Redistribute 100% of lines drawn to pen 0 |
| 9 | Change distribution of lines drawn (lighten) |
| 0 | Change distribution of lines drawn (darken) |
| 1 | Increase percentage of lines drawn by pen 0 |
| 2 | Increase percentage of lines drawn by pen 1 |
| 3 | Increase percentage of lines drawn by pen 2 |
| 4 | Increase percentage of lines drawn by pen 3 |
| 5 | Increase percentage of lines drawn by pen 4 |
| 6 | Increase percentage of lines drawn by pen 5 |
| shift 0 | Decrease percentage of lines drawn by pen 0 |
| shift 1 | Decrease percentage of lines drawn by pen 1 |
| shift 2 | Decrease percentage of lines drawn by pen 2 |
| shift 3 | Decrease percentage of lines drawn by pen 3 |
| shift 4 | Decrease percentage of lines drawn by pen 4 |
| shift 5 | Decrease percentage of lines drawn by pen 5 |

| : | Change Copic marker sets, increment |
| ; | Change Copic marker sets, decrement |


Some Demodrawings done on a Makelangelo Robot http://www.makelangelo.com/

![drawbot1](http://tarantl.com/drawbot1.jpg)
![drawbot2](http://tarantl.com/drawbot2.jpg)
![drawbot3](http://tarantl.com/drawbot3.jpg)

There are some demo Images in the /pics folder and generated files are in the /svg folder.
The file named "compplete_****.svg shows the complete drawing and in the subfolder there is a file for each color. I then load the svgs into the Makelangelo one by one, home the machine, insert the pen and start.


I use a special gondola on my Makelangelo 5:
https://www.thingiverse.com/thing:4929245


+++ LATEST REVISION +++
Makelangelo 5+ can now be flashed with an official Marlin Firmware
The latest version of HexaBotArt generates GCODE files compatible with Marlin for Makelangelo

Thanks to Dan from Marginally Clever https://github.com/MarginallyClever
Check out his great Machines and let's join forces :D