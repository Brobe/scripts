#!/usr/bin/env bash

info() { echo -e "\033[33m[-] $*\033[0m"; }    # yellow
error() { echo -e "\033[31m[!] $*\033[0m"; }   # red
ok() { echo -e "\033[32m[+] $*\033[0m"; }      # green

submit-exer() {
    exercism submit
}

mark-complete() {
    local languagefile="$1"
    local exercise="$2"
    sed -i "s/^$exercise\$/$exercise-COMPLETED/" "$languagefile"
}

get-next-exer() {
    local languagefile="$1"
    next_exer=$(grep -v "COMPLETED$" $languagefile | head -n 1)
    echo "$next_exer"
}

download-and-cd() {
    local programinglanguage="$1"
    local next_exercise="$2"
    exercism download --track="$programinglanguage" --exercise="$next_exercise" --force
    next_dir=~/exercism/"$programinglanguage"/"$next_exercise"
    cd "$next_dir"
}


while true; do
    cwd="$PWD"
    exer="${cwd##*/}"   # last dir
    lang="${cwd%/*}"    # remove last component
    lang="${lang##*/}"  # get parent dir name
    lfile=~/exercism/"$lang-exercises"

    info "Running test for $exer ($lang track)..."
    
    exercism test

    ok "Test complete!"

    # Continue Y/N?
    read -p "Mark as completed? (Y/N) " confirm

    if [[ $confirm == [yY] ]]; then
        info "Submiting $exer..."
        submit-exer
        info "Marking $exer complete..."
        mark-complete "$lfile" "$exer"
        ok "Marked..."
        info "Getting next exercise..."
        next_exer=$(get-next-exer "$lfile")
        ok "Next exercise is $next_exer"
        info "Downloading and moving to $next_exer..."
        download-and-cd "$lang" "$next_exer"
        ok "Moved! Now in $PWD"

    elif [[ $confirm == [nN] ]]; then
        error "Stoping..."
        break
        
    else
        error "Something went wrong with your choice. Exiting"
        exit 0
    fi


done

