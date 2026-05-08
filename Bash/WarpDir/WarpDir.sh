#!/bin/bash

# WarpDir <3
SELF_DIR="$(dirname ${BASH_SOURCE[0]})"
. "$SELF_DIR/lib"

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

if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion -o -f /etc/bash_completion ]; then
        complete -W "$(join_list_on " " ${WD_COMMANDS[@]}) $(get_wd_aliases)" wd
    fi
fi
