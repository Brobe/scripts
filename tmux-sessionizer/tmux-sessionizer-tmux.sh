#!/usr/bin/env bash

mapfile -t search_dirs < ~/scripts/tmux-sessionizer/search-dirs
mapfile -t searched_dirs < <(find "${search_dirs[@]}" -maxdepth 1 -type d)
mapfile -t tmux_sessions < <(tmux list-sessions -F '#S')

sessions=()
directories=()

for sess in "${tmux_sessions[@]}"; do
    sessions+=(" session: $sess")
done

directories+=(" $HOME")

for dir in "${searched_dirs[@]}"; do
    display_dir="${dir/#"$HOME"/\~}"
    directories+=(" $display_dir")
done

if [[ $1 == "--filter" ]]; then
    query="$2"

    printf '%s\n' "${sessions[@]}" |
        fzf --filter="$query" --nth=3..
    printf '%s\n' "${directories[@]}" |
        fzf --filter="$query" --nth=2..

    exit 0
fi

if [[ $# -eq 1 ]]; then
    selected=$1
else
    fzf_height=100%
    fzf_margin=0
    if [[ -z "$TMUX" && -z "$GHOSTTY_QUICK_TERMINAL" ]]; then
        fzf_height=70%
        fzf_margin=0,20%
    fi
    selected=$(printf '\n' | fzf \
        --disabled \
        --no-sort \
        --bind 'start:reload("$HOME/scripts/tmux-sessionizer/tmux-sessionizer-tmux.sh" --filter {q}),change:reload("$HOME/scripts/tmux-sessionizer/tmux-sessionizer-tmux.sh" --filter {q})' \
        --border="none" \
        --list-label=' Session & Directories ' \
        --input-label=' Input ' \
        --height="$fzf_height" \
        --margin="$fzf_margin" \
        --preview-window='right:65%' \
        --preview-label=' Preview ' \
        --style full \
        --preview '
    item={}
    if [[ $item == \ session:* ]]; then
        sess="${item# session: }"
        tmux capture-pane -ep -t "$sess" -S -40
    else
        if [[ $item == \ * ]]; then
            dir="${item# }"
        else
            dir="${item# }"
        fi
        dir="${dir/#\~/$HOME}"
        if [ -d "$dir/.git" ]; then
            echo_ok " ===== Status ====="
            git -C "$dir" -c color.status=always status
            echo ""
            echo_info " =====  Log   ====="
            git -C "$dir" log -n 5 --oneline --color=always
            echo ""
        fi
        echo_ok " =====   ls   ====="
        ls -a "$dir" --color=always
    fi
    ')
fi

if [[ -z $selected ]]; then
    exit 0
fi

if [[ "$selected" == " session: "* ]]; then
    session_name="${selected# session: }"
    tmux switch-client -t "$session_name" 2>/dev/null || tmux attach-session -t "$session_name"
else
    if [[ "$selected" == " "* ]]; then
        selected="${selected# }"
        selected_name="home"
    else
        selected="${selected# }"
        selected_name=$(basename "$selected" | tr . _)
    fi
    selected="${selected/#\~/$HOME}"

    tmux_running=$(pgrep tmux)

    if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
        tmux new-session -s $selected_name -n main -c $selected
        exit 0
    fi

    if ! tmux has-session -t=$selected_name 2> /dev/null; then
        tmux new-session -ds $selected_name -n main -c $selected
    fi

    if [[ -z $TMUX ]]; then
        tmux attach -t $selected_name
    else
        tmux switch-client -t $selected_name
    fi
fi
