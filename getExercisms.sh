#!/usr/bin/env bash

prog=$1

echo "Getting exercises for $prog"
mapfile -t exers < <(curl -s https://exercism.org/api/v2/tracks/$prog/exercises | jq -r '.exercises[].slug')
#count=$((0))
#for e in $exers; do
#    ((count++))
#done
#count=$(echo $exers | wc --words)
count=${#exers[@]}
echo "Found $count exercises"
echo "Downloading..."

curr=0
for e in "${exers[@]}"; do
    #echo "exercism download --track=$prog --exercise=$e"
    #exeroutput=$(exercism download --track=$prog --exercise=hello-world 2>&1)
    if [[ -d "$HOME/exercism/$prog/$e" ]]; then
        ((curr++))
        ./progress-bar -p "$curr $count"
        continue
    fi
    while true; do
        exeroutput=$(exercism download --track=$prog --exercise=$e 2>&1 >/dev/null)
        if echo $exeroutput | grep -q "Error"; then
            if echo $exeroutput | grep -q "status 429"; then
                ./progress-bar -e "Too many requests, taking a break ($curr of $count done)"
                for ((i = 40; i > 0; i--)); do
                    echo -ne "\r$i "
                    sleep 1
                done
                continue
            elif echo $exeroutput | grep -q "expected"; then
                continue
            elif echo $exeroutput | grep -q "already exists"; then
                ./progress-bar -e "exercise $e already exists"
            else
                ./progress-bar -e "unknown error $exeroutput"
            fi
        fi
        break
    done

    ((curr++))
    ./progress-bar -p "$curr $count"
done

# ./progress-bar -p "$count $count"

echo "Done! $(ls $HOME/exercism/$prog | wc --word) of $count exercises for $prog has been downloaded."
echo "Exiting..."


