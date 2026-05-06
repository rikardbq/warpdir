#!/bin/bash

# WarpDir <3
WD_ROOT=".wd"
WD_DIRS="dirs"
WD_FULL_PATH="$HOME/$WD_ROOT/$WD_DIRS"
WD_COMMANDS=("help" "save" "rename" "remove" "list")

join_list_on() {
    local IFS="$1"
    shift 1
    echo "$*"
}

get_wd_entries() {
    local IFS=" "
    echo $(cat $WD_FULL_PATH)
}

find_entry_by_alias() {
    local val=""
    for entry in $(get_wd_entries); do
        local IFS="|"
        read -ra split_entry <<< "$entry"
        if [ "$1" == "${split_entry[0]}" ]; then
            val=$entry
            break;
        fi
    done
    echo $val
}

alias_exist() {
    local entry=$(find_entry_by_alias $1)
    if [ "$entry" != "" ]; then
        echo 1
    else
        echo 0
    fi
}

is_reserved_keyword() {
    local reserved=0
    for cmd in $WD_COMMANDS; do
        if [ "$1" == "$cmd" ]; then
            reserved=1
            break;
        fi
    done
    echo $reserved
}

goto_alias_target() {
    local entry=$(find_entry_by_alias $1)
    read -ra split_entry <<< "$entry"
    if [ "$entry" != "" ]; then
        local target=${split_entry[1]}
        export WD_PREV_PWD=($PWD $target)
        cd $target
    fi
}

if [ ! -d "$HOME/$WD_ROOT" ]; then
    mkdir $HOME/$WD_ROOT
fi
if [ ! -f "$WD_FULL_PATH" ]; then
    touch $WD_FULL_PATH
fi

if [ $1 ]; then
    case $1 in
    "help")
        echo "help"
        ;;
    "save")
        if [ $2 ]; then
            if [ $(alias_exist $2) -eq 1 ]; then
                echo "alias already exist"
            elif [ $(is_reserved_keyword $2) -eq 1 ]; then
                echo "alias not allowed [$(join_list_on "," $WD_COMMANDS)] are reserved keywords"
            else
                export WD_PREV_PWD=($PWD ${WD_PREV_PWD[1]})
                echo "$2|$PWD" >> $WD_FULL_PATH
            fi
        else
            echo "alias not provided"
        fi
        ;;
    "rename")
        echo "rename!"
        ;;
    "remove")
        echo "remove!"
        ;;
    "list")
        echo -e "Alias|Target\n-----|------\n$(get_wd_entries)" | column -ts "|"
        ;;
    *)
        if [ $(alias_exist $1) -eq 0 ]; then
            echo "alias does not exist"
        else
            goto_alias_target $1
        fi
        ;;
    esac
elif [ ${WD_PREV_PWD[1]} ]; then
    if [ $PWD == ${WD_PREV_PWD[1]} ]; then
        cd ${WD_PREV_PWD[0]}
    else
        cd ${WD_PREV_PWD[1]}
    fi
fi
