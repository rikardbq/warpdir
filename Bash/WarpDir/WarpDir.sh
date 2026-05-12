#!/bin/bash

# WarpDir <3
if [ ! $WD_ROOT ]; then
    echo "lib not sourced yet, sourcing it now (see README.md) for how to get rid of this message"
    SELF_DIR="$(dirname ${BASH_SOURCE[0]})"
    if [ ! -f "$SELF_DIR/lib" ]; then
        echo "lib file not found!"
        return
    else
        . "$SELF_DIR/lib"
    fi
fi
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
                generate_error $ERROR_KIND__ALIAS_ALREADY_EXIST
            elif [ $(is_reserved_keyword $2) -eq 1 ]; then
                generate_error $ERROR_KIND__ALIAS_NOT_ALLOWED_KEYWORD_RESERVED $(join_list_on "," ${WD_COMMANDS[@]})
            else
                export WD_PREV_PWD=($PWD ${WD_PREV_PWD[1]})
                echo "$2|$PWD" >> $WD_FULL_PATH
            fi
        else
            generate_error $ERROR_KIND__ALIAS_NOT_PROVIDED
        fi
        ;;
    "rename")
        if [ "$2" -a "$3" ]; then
            if [ $(alias_exist $2) -eq 0 ]; then
                generate_error $ERROR_KIND__ALIAS_NOT_EXIST
            fi
            if [ $(alias_exist $3) -eq 1 ]; then
                generate_error $ERROR_KIND__ALIAS_ALREADY_EXIST
            elif [ $(is_reserved_keyword $3) -eq 1 ]; then
                generate_error $ERROR_KIND__ALIAS_NOT_ALLOWED_KEYWORD_RESERVED $(join_list_on "," ${WD_COMMANDS[@]})
            fi
            handle_rename $2 $3
        else
            generate_error $ERROR_KIND__ALIAS_NOT_PROVIDED
        fi
        ;;
    "remove")
        if [ $2 ]; then
            if [ $(alias_exist $2) -eq 0 ]; then
                generate_error $ERROR_KIND__ALIAS_NOT_EXIST
            else
                handle_remove $2
            fi
        else
            generate_error $ERROR_KIND__ALIAS_NOT_PROVIDED
        fi
        ;;
    "list")
        echo -e "\nAlias|Target\n-----|------\n$(get_wd_entries)\n" | column -L -ts "|"
        ;;
    *)
        if [ $(alias_exist $1) -eq 0 ]; then
            generate_error $ERROR_KIND__ALIAS_NOT_EXIST
        else
            goto_alias_target $1
        fi
        ;;
    esac
elif [ ${WD_PREV_PWD[0]} ]; then
    if [ $PWD == ${WD_PREV_PWD[0]} ]; then
        cd ${WD_PREV_PWD[1]}
    else
        cd ${WD_PREV_PWD[0]}
    fi
fi

check_autocomplete
