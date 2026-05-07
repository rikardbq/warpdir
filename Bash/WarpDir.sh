#!/bin/bash

# WarpDir <3
WD_ROOT=".wd"
WD_DIRS="dirs"
WD_FULL_PATH="$HOME/$WD_ROOT/$WD_DIRS"
WD_COMMANDS=("help" "save" "rename" "remove" "list")

join_list_on() {
    local IFS=$1
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
    for cmd in ${WD_COMMANDS[@]}; do
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

handle_remove() {
    local wd_prompted=1
    local filtered_entries=()
    while [ $wd_prompted -eq 1 ]; do
        read -p "are you sure you want to remove alias [ $1 ]? (N/y) " user_input
        if [ "$user_input" == "" -o "${user_input,,}" == "n" ]; then
            echo "nothing changed"
            wd_prompted=0
        elif [ "${user_input,,}" == "y" ]; then
            for entry in $(get_wd_entries); do
                local IFS="|"
                read -ra split_entry <<< "$entry"
                if [ "$1" != "${split_entry[0]}" ]; then
                    filtered_entries+="$entry "
                fi
            done
            local IFS=" "
            if [ "$filtered_entries" ]; then
                echo $(join_list_on $'\n' $filtered_entries) > $WD_FULL_PATH
            else
                echo -n "" > $WD_FULL_PATH
            fi
            wd_prompted=0
        fi
    done
}

handle_rename() {
    local filtered_entries=()
    for entry in $(get_wd_entries); do
        local IFS="|"
        read -ra split_entry <<< "$entry"
        if [ "$1" == "${split_entry[0]}" ]; then
            filtered_entries+="$2|${split_entry[1]} "
        else
            filtered_entries+="$entry "
        fi
    done
    local IFS=" "
    echo $(join_list_on $'\n' $filtered_entries) > $WD_FULL_PATH
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
        echo -e "Commands:\n\n\t<no argument> (will toggle between current and previous directory)\n\n\tlist\n\n\tsave [alias]\n\n\trename [alias new_alias]\n\n\tremove [alias]\n\n"
        ;;
    "save")
        if [ $2 ]; then
            if [ $(alias_exist $2) -eq 1 ]; then
                echo "alias already exist"
            elif [ $(is_reserved_keyword $2) -eq 1 ]; then
                echo "alias not allowed [$(join_list_on "," ${WD_COMMANDS[@]})] are reserved keywords"
            else
                export WD_PREV_PWD=($PWD ${WD_PREV_PWD[1]})
                echo "$2|$PWD" >> $WD_FULL_PATH
            fi
        else
            echo "alias not provided"
        fi
        ;;
    "rename")
        if [ $2 -a $3 ]; then
            if [ $(alias_exist $2) -eq 0 ]; then
                echo "alias does not exist"
                return
            fi
            if [ $(alias_exist $3) -eq 1 ]; then
                echo "alias already exist"
                return
            elif [ $(is_reserved_keyword $3) -eq 1 ]; then
                echo "alias not allowed [$(join_list_on "," ${WD_COMMANDS[@]})] are reserved keywords"
                return
            fi
            handle_rename $2 $3
        else
            echo "alias not provided"
        fi
        ;;
    "remove")
        if [ $2 ]; then
            if [ $(alias_exist $2) -eq 0 ]; then
                echo "alias does not exist"
            else
                handle_remove $2
            fi
        else
            echo "alias not provided"
        fi
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

complete -W "$(join_list_on " " ${WD_COMMANDS[@]})" wd
