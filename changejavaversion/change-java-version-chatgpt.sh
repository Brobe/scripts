#!/usr/bin/env bash

# Show current Java versions
archlinux-java status

# Get all installed Java versions
# We'll decorate java-17 with a note for exercism
java_list=$(archlinux-java status | tail -n +2 | awk '
{
    note = ""
    if ($1 == "java-17-openjdk") note="This version is needed to do Exercism exercises; might change for later exercises"
    printf "%s\t%s\n", $1, note
}')

# Use fzf to select a version
# --with-nth=1 ensures only the Java version is used for selection
# --preview shows the note
fzfoutput=$(echo "$java_list" | fzf \
    --with-nth=1 \
    --delimiter='\t' \
    --preview 'echo {2}' \
    --prompt="Select Java version: " \
    --height=10 \
    --border \
    --ansi \
    --reverse \
    --pointer='>' \
)

# Check if something was selected
if [ -n "$fzfoutput" ]; then
    sudo archlinux-java set "$fzfoutput"
    echo "Java set to $fzfoutput"
else
    echo "No selection made, exiting."
fi
