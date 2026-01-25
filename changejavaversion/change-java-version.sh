#!/usr/bin/env bash
# Seems that it has to be jav version 17 to work with testcases
# └─$ archlinux-java status
# Available Java environments:
#   java-17-openjdk (default)
#   java-25-openjdk
# 
# ┌──(br0b3rt0  rarch)-[~/exercism/kotlin/hello-world]  20:52
# └─$ sudo archlinux-java set java-17-openjdk

default_java=$(archlinux-java status | awk '/default/{print $1}')
java_list=$(archlinux-java status | tail -n +2 | awk '{print $1}')

fzfoutput=$(echo "$java_list" | fzf --prompt="Select Java (current default: $default_java): ")

if [ -n "$fzfoutput" ]; then
    sudo archlinux-java set "$fzfoutput"
    echo "Java set to $fzfoutput"
else
    echo "No selection made, exiting."
fi

