#!/bin/bash

# Created by Kevin "Kassimo" Qian 2017

OPTIND=1
BASEFILE="$HOME/.dotbase" # In case, may need realpath to remove trailing /
BASE="" # BASE is the path where we will place .git. For the paths of tracked files, we will record full path in .dotrc (with realpath to fetch the full path)
RCFILE="$HOME/.dotrc"
RC=""

FILEARR=()

function array_contains { 
    local array="$1[@]"
    local seeking=$2
    local in=1
    for element in "${!array}"; do
        if [[ $element == $seeking ]]; then
            in=0
            break
        fi
    done
    return $in
}

function err_exit {
    echo "-dot: $1" >&2
    exit 1
}

function dot_ok {
    exit 0
}

function dot_err {
    exit 1
}

# Check and read dot related files for init and info update
function dot_init {
    touch "$RCFILE" # create .dotrc if not exist
    touch "$BASEFILE"
    
    # readarray FILEARR < "$BASEFILE" # bash 4+ only
    let i=0
    while IFS=$'\n' read -r line_data; do
        if [[ "${line_data}" = *[[:space:]]* ]] || [ -z "${line_data}" ]; then continue; fi
        FILEARR[i]="${line_data}"
        ((++i))
    done < "$RCFILE"
    
    BASE=$(cat "$BASEFILE")
}

# call dot_init here
dot_init

while getopts "uwrb:iofpsem:l:ac:" opt
do
    case "$opt" in
    u) # show usage and exit (u = usage)
        echo "Usage: dot -uvwriofpmla -b='/basepath' -c='Commit Message' -s [filenames]"
        dot_ok
        ;;
    w) # show what is included in dotfiles git add config (w = what)
        if [ -z "$BASE" ]; then
            echo "Base path for dotfiles is empty. Have you set your base path with -b yet?"
            dot_ok
        else
            echo "Dotfiles tracked: "
            cat "$RCFILE"
        fi
        
        dot_ok
        ;;
    r) # reset all and discard original git (r = reset)
        while true; do
            read -p "Do you really want to clear dot settings and git? [N/y] " yn
            case $yn in
                [Yy]* ) 
                    if [ ! -z "$BASE" ]; then
                        if [ ! -d "$BASE" ]; then
                            rm -rf "$RCFILE" "$BASEFILE"
                            err_exit "-r: Clean not complete due to invalid base path: $BASE. Only config files are cleaned"
                        else
                            rm -rf "$BASE/.git" "$RCFILE" "$BASEFILE"
                        fi
                    else
                        rm -rf "$RCFILE" "$BASEFILE"
                        err_exit "-r: Clean not complete as base path not set"
                    fi

                    BASE=""
                    RC=""

                    echo "dot settings and git cleaned"

                    break
                    ;;
                [Nn]* )
                    echo "Cancelled"
                    break
                    ;;
                * ) 
                    echo "Please answer yes or no: [N/y] "
                    ;;
            esac
        done

        dot_ok
        ;;
    b) # set base directory of all dotfiles to be tracked (b = base)
        # check if argument is truly a directory
        if [ ! -d "$OPTARG" ]; then
            err_exit "-b: $OPTARG is not a directory"
        fi

        # saving realpath into .dotbase
        realpath "$OPTARG" > "$BASEFILE"
        
        echo "Base directory of dotfiles is set to $OPTARG"

        dot_ok
        ;;
    i) # init dotfiles git (i = init)
        # check if the base is set or not
        if [ -z "$BASE" ]; then
            err_exit "Please, set base directory for all tracked dotfiles with -b"
        fi

        git init "$BASE"
        if [[ $? -ne 0 ]]; then
            err_exit "-i: Git init error"
        fi
        
        dot_ok
        ;;
    o) # git remote set origin (o = origin)
        if [ -z "$BASE" ]; then err_exit "-o: base path is empty"; fi
        if [ ! -d "$BASE/.git" ]; then err_exit "-o: no directory named $BASE/.git"; fi
        git --git-dir="$BASE/.git" remote add origin "$OPTARG"
        
        if [ $? -ne 0 ]; then err_exit "-o: Git remote add origin error"; else dot_ok; fi
        ;;
    f) # git pull (f = fetch)
        if [ -z "$BASE" ]; then err_exit "-f: base path is empty"; fi
        if [ ! -d "$BASE/.git" ]; then err_exit "-f: no directory named $BASE/.git"; fi
        git --git-dir="$BASE/.git" fetch
        
        if [ $? -ne 0 ]; then err_exit "-f: Git fetch error"; else dot_ok; fi
        ;;
    p) # git push origin master (p = push)
        if [ -z "$BASE" ]; then err_exit "-p: base path is empty"; fi
        if [ ! -d "$BASE/.git" ]; then err_exit "-p: no directory named $BASE/.git"; fi
        git --git-dir="$BASE/.git" push origin master
        
        if [ $? -ne 0 ]; then err_exit "-p: Git push error"; else dot_ok; fi
        ;;
    s) # record and overwrite all files that need to be tracked in .dotrc (s = save)
        shift
        > "$RCFILE"
        echo "Resetting tracked dotfiles"
        for var in "$@"
        do
            if [ ! -f "$var" ] && [ ! -d "$var" ]; then
                echo "Error: $var is not a valid file or directory"
            else
                echo "$(realpath $var)" >> "$RCFILE"
                echo "Adding $(realpath $var) to tracked dotfiles"
            fi
        done

        dot_ok
        ;;
    e) # record and overwrite, but would instead include all .* files/directories in BASE directory EXCEPT for those specially specified in the later excluding arguments (e = exclude)
        arr=()
        
        while IFS=  read -r -d $'\0'; do
            arr+=("$REPLY")
        done < <(find "$BASE" -maxdepth 1 -name ".[^.]*" -print0)
        
        shift
        > "$RCFILE"
        echo "Resetting tracked dotfiles"
        
        exarr=( "$@" )
        for var in "${arr[@]}"
        do
            if [ ! -f "$var" ] && [ ! -d "$var" ]; then
                echo "Error: $var is not a valid file or directory"
            else
                if array_contains exarr "$var"; then
                    echo "Excluding $(realpath $var)"
                else
                    echo "$(realpath $var)" >> "$RCFILE"
                    echo "Adding $(realpath $var) to tracked dotfiles"
                fi
            fi
        done
        
        dot_ok
        ;;
    m) # add a single file to all the dotfiles that need to be tracked (m = more)
        optpath=$(realpath "$OPTARG")
        for i in "${FILEARR[@]}"
        do
            currpath=$(realpath "$i")
            if [[ "$currpath" == "$optpath" ]]; then
                echo "$optpath already tracked"
                dot_ok
            fi
        done
        # not found
        echo "$optpath" >> "$RCFILE"
        echo "Adding $optpath to tracked dotfiles"
        dot_ok
        ;;
    l) # remove some file from .dotrc tracking (l = less)
        > "$RCFILE" # clear file first to avoid trouble
        optpath=$(realpath "$OPTARG")
        for i in "${FILEARR[@]}"
        do
            currpath=$(realpath "$i")
            if [ "$currpath" != "$optpath" ]; then
                echo "$currpath" >> "$RCFILE"
            else
                echo "Removing $currpath from tracked dotfiles. The file will live on, but updates no longer tracked"
            fi
        done
        dot_ok
        ;;
    a) # stage all files specified in .dotrc (a = add)
        if [ -z "$BASE" ]; then err_exit "-a: base path is empty"; fi
        if [ ! -d "$BASE/.git" ]; then err_exit "-a: no directory named $BASE/.git"; fi
        # git --git-dir="$BASE/.git" add # TODO: what to add?
        
        for i in "${FILEARR[@]}"
        do
            git --git-dir="$BASE/.git" add "$i"
        done
        
        if [ $? -ne 0 ]; then err_exit "-a: Git add error"; else dot_ok; fi
        ;;
    c) # commit with commit message (c = commit)
        if [ -z "$BASE" ]; then err_exit "-c: base path is empty"; fi
        if [ ! -d "$BASE/.git" ]; then err_exit "-c: no directory named $BASE/.git"; fi
        git --git-dir="$BASE/.git" commit -m "$OPTARG"
        
        if [ $? -ne 0 ]; then err_exit "-o: Git commit error"; else dot_ok; fi
        ;;
    :)
        err_exit "Missing argument"
        ;;
    \?)
        err_exit "Invalid option: -$OPTARG" >&2
        ;;
    esac
done
