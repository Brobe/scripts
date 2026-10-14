#!/usr/bin/env bash

tmux new-session -d -s restore
tmux send-keys -t restore '~/.tmux/plugins/tmux-resurrect/scripts/restore.sh; tmux kill-session -t restore' C-m
