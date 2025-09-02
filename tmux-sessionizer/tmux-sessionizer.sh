#!/usr/bin/env bash

#search_dirs=$(cat ~/scripts/tmux-sessionizer/search-dirs | tr "\n" " ")
mapfile -t search_dirs < ~/scripts/tmux-sessionizer/search-dirs
searched_dirs=$(find "${search_dirs[@]}" -maxdepth 1 -type d)
mapfile -t tmux_sessions < <(tmux list-sessions -F '#S')

combined_list=()
for dir in "${searched_dirs[@]}"; do
    combined_list+=("$dir")
done
for sess in "${tmux_sessions[@]}"; do
    combined_list+=("session: $sess")
done

if [[ $# -eq 1 ]]; then
    selected=$1
else
    selected=$(printf '%s\n' "${combined_list[@]}" | fzf)
    #selected=$(find "${search_dirs[@]}" -maxdepth 1 -type d | fzf)
    #selected=$(find "${search_dirs[@]}" -mindepth 1 -maxdepth 1 -type d | fzf)
fi

if [[ -z $selected ]]; then
    exit 0
fi

if [[ "$selected" == session:* ]]; then
    session_name="${selected#session: }"
    tmux switch-client -t "$session_name" 2>/dev/null || tmux attach-session -t "$session_name"
else
    selected_name=$(basename "$selected" | tr . _)
    tmux_running=$(pgrep tmux)

    if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
        tmux new-session -s $selected_name -c $selected
        exit 0
    fi

    if ! tmux has-session -t=$selected_name 2> /dev/null; then
        tmux new-session -ds $selected_name -c $selected
    fi

    if [[ -z $TMUX ]]; then
        tmux attach -t $selected_name
    else
        tmux switch-client -t $selected_name
    fi
fi
