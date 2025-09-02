#!/bin/bash

# Directory where wallpapers are stored
WALL_DIR="$HOME/images/wallpapers"

# Get a random image from the directory
WALL=$(find "$WALL_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" \) | shuf -n 1)

# Use hyprctl reload to set the wallpaper
hyprctl hyprpaper reload ,"$WALL"

