#!/bin/sh
# Render box.scad to a PNG using OpenSCAD CLI.
# Usage: ./render.sh

set -e

cd "$(dirname "$0")"

# Camera: human-eye perspective, standing on the ground 50m from the entrance
# Format: eyex,eyey,eyez,centerx,centery,centerz
# Eye at (5000, 0, 170) — 50m away facing the entrance, eye height ~1.7m
# Looking at the center of the landing pad
openscad \
    -o box.png \
    --imgsize=1920,1080 \
    --camera=5000,0,170,0,0,300 \
    --colorscheme=Tomorrow \
    box.scad

echo "Rendered box.png"
