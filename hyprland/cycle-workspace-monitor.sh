#!/bin/bash

# Requires: jq, hyprctl

# Get active workspace  ID
WS_ID=$(hyprctl activeworkspace -j | jq '.id')

# Get monitor list
MONITORS=($(hyprctl monitors -j | jq -r '.[].name'))
NUM_MONITORS=${#MONITORS[@]}

# Get current monitor of the workspace
CURRENT_MONITOR=$(hyprctl activeworkspace -j | jq -r '.monitor')

# Find index of current monitor
for i in "${!MONITORS[@]}"; do
    if [[ "${MONITORS[$i]}" == "$CURRENT_MONITOR" ]]; then
        CURRENT_INDEX=$i
        break
    fi
done

# Compute next monitor index (cyclic)
NEXT_INDEX=$(( (CURRENT_INDEX + 1) % NUM_MONITORS ))
NEXT_MONITOR=${MONITORS[$NEXT_INDEX]}

# Move the workspace
hyprctl dispatch moveworkspacetomonitor "$WS_ID" "$NEXT_MONITOR"

