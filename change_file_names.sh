#!/bin/bash
# Rename files in the current directory:
# Replace:
#     *) Spaces with underscores
#     *) " - " with "-"
#     *) Removes parentheses

taget_dir="$(pwd)"
cd $taget_dir || exit 1

for f in *; do
    # Skip if not regular file
    [ -f "$f" ] || continue
    
    # Create new filename
    newname=$(echo "$f" | sed -E 's/ - /-/g; s/[[:space:]]+/_/g; s/[()]//g')

    # Skip if the name is the same
    [[ "$f" == "$newname" ]] && continue

    # Check for conflicts
    if [[ -e "$newname" ]]; then
        echo "[!] Skipping '$f' -> '$newname' (taget exists)"
    else
        mv -v -- "$f" "$newname"
    fi
done

