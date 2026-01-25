#!/usr/bin/env bash

info() { echo -e "\033[33m[-] $*\033[0m"; }    # yellow
error() { echo -e "\033[31m[!] $*\033[0m"; }   # red
ok() { echo -e "\033[32m[+] $*\033[0m"; }      # green

open-readme() {
    tmux send-keys "nvim README.md" C-m
}

open-code() {
    local lang="$1"

    if [[ "$lang" == "kotlin" ]]; then
        tmux send-keys "nvim src/main/kotlin/*" C-m
    elif [[ "$lang" == "python" ]]; then
        local edir="$2"
        impl=$(ls $edir/*.py | grep -v '_test.py')
        tmux send-keys "nvim \"$impl\"" C-m
    elif [[ "$lang" == "go" ]]; then
        local edir="$2"
        impl=$(ls $edir/*.go | grep -v '_test.go')
        tmux send-keys "nvim \"$impl\"" C-m
        
    else
        tmux send-keys "ls" C-m
    fi
}

if [[ -z "$TMUX" ]]; then
    error "Must be run inside tmux"
    exit 1
fi

lang="$1"
lfile=~/exercism/"$lang-exercises"

next_exer=$(grep -v "COMPLETED$" $lfile | head -n 1)
next_dir=~/exercism/"$lang"/"$next_exer"



if [ -d "$next_dir" ] && [ -f "$next_dir/README.md" ]; then
    tmux send-keys "cd $next_dir" C-m
    tmux new-window -c "$next_dir" -n "$next_exer"
    open-readme
    tmux split-window -h -c "$next_dir"
    open-code "$lang" "$next_dir"
else
    error "Something is not right with the exercise"
    exercism download --track="$lang" --exercise="$next_exer" --force
    if [ -d "$next_dir" ] && [ -f "README.md" ]; then
        tmux new-window -c "$next_dir" -n "$next_exer"
        open-readme
        tmux split-window -h -c "$next_dir"
        open-code "$lang""$next_dir"
    else
        echo "Something went wrong check excercism output for errors"
    fi
fi

