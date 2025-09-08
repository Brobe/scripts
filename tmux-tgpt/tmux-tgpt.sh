#!/bin/bash

if tmux has-session -t tgpt 2> /dev/null; then
    tmux attach -t tgpt
else
    tmux new-session -s tgpt "tgpt -i"
fi
