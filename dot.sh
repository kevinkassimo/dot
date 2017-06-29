#!/bin/sh

OPTIND=1
VERBOSE=false
BASEFILE="$HOME/.dotbase" # In case, may need realpath to remove trailing /
BASE=""
RCFILE="$HOME/.dotrc"
RC=""

function err_exit {
    echo "-dot: $1"
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
    OLDIFS=IFS
    IFS="
    " # setting newline as IFS
    
# while read 
    BASE=$(cat "$BASEFILE")

}

#function check_basepath {
#    if [ -z "$BASE" ]; then
#        if $1; then
#            err_exit "Base path for dotfiles is empty. Have you set your base path with -b yet?"
#        else
#            echo "Base path for dotfiles is empty. Have you set your base path with -b yet?"
#        fi
#    fi
#}

# call dot_init here
dot_init

while getopts "uvwrb:iofpsmlac:" opt
do
    case "$opt" in
    u) # show usage and exit
        echo "Usage: dot -uva -c='Commit Message' -s [filenames]"
        dot_ok
        ;;
    v) # turn on verbose mode
        VERBOSE=true
        ;;
    w) # show what is included in dotfiles git add config
        if [ -z "$BASE" ]; then
            echo "Base path for dotfiles is empty. Have you set your base path with -b yet?"
            dot_ok
        else
            echo "Dotfiles tracked: "
            cat "$RCFILE"
        fi
        
        dot_ok
        ;;
    r) # reset all and discard original git
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

                    if $VERBOSE; then
                        echo "dot settings and git cleaned"
                    fi

                    break
                    ;;
                [Nn]* )
                    if $VERBOSE; then
                        echo "Cancelled"
                    fi
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
        
        if $VERBOSE ; then
            echo "Base directory of dotfiles is set to $OPTARG"
        fi

        dot_ok
        ;;
    i) # init dotfiles git (i = init)
        # check if the base is set or not
        if [ -z "$BASE" ]; then
            err_exit "Please, set base directory for all tracked dotfiles with -b"
        fi

        git init $BASE
        if [[ $? -ne 0 ]]; then
            err_exit "-i: Git init error"
        fi
        dot_ok
        ;;
    o) # git remote set origin (o = origin)
        ;;
    f) # git pull (f = fetch)
        ;;
    p) # git push origin master (p = push)
        ;;
    s) # record and overwrite all files that need to be tracked in .dotrc (s = save)
        
        

        exit 0
        ;;
    m) # add a single file to all the dotfiles that need to be tracked (m = more)
        ;;
    l) # remove some file from .dotrc tracking (l = less)
        ;;
    a) # stage all files specified in .dotrc (a = add)
        
        ;;
    c) # commit with commit message (c = commit)
        ;;
    :)
        ;;
    \?)
        echo "Invalid option: -$OPTARG" >&2
        exit 1
        ;;
    esac
done
