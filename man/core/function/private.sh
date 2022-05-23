# - - -
# Private helper functions:
#

#
# __rerun_options_populate_ - generate a command argument string populating them with answer values
#
#
_rerun_options_populate() {
    (( $# < 2 )) && {
        echo >&2 "usage: _rerun_options_populate: module command ?answers?"
        return 2
    }
    local -r module=$1 command=$2 answers=${3:-}
    local -r module_dir=$(rerun_module_exists "$module") || rerun_syntax_error "module not found: \"$module\""
    local argline=() metadata option
    for cmd_option in $(rerun_options "$(dirname "$module_dir")" "$module" "$command")
    do
        metadata=$(dirname "$module_dir")/$module/options/$cmd_option/metadata
        local varname arg argval
        option=$(
            # shellcheck source=/dev/null
            . "$metadata"; # source the option metadata
            [[ -n "$LONG" ]] && flag="$LONG" || flag="$NAME"
            if [[ -r "$answers" ]]
            then
                varname=$(echo "$NAME" | tr a-z A-Z | tr "-" "_")
                arg=$(grep "^${varname}=" "$answers")
                argval=${arg#*=}
            fi
            [[ -n "$arg" ]] && printf -- "--%s %s" "$flag" "${argval}"
        )
        argline+=("$option")
    done
    echo "${argline[@]:-}"
}



#
# __rerun_banner_ - Prints logo and version info with a rainbow of colors!
#
# Notes:
#
# * Prints ANSI color codes into your output
_rerun_banner() {
    if [[ -n "${RERUN_COLOR:-}" ]]
    then
    echo $(tput setaf 1) " _ __ ___ _ __ _   _ _ __"
    echo $(tput setaf 2) "| '__/ _ \ '__| | | | '_ \ "
    echo $(tput setaf 3) "| | |  __/ |  | |_| | | | |"
    echo $(tput setaf 4) "|_|  \___|_|   \__,_|_| |_|"
    echo $(tput setaf 5) "Version: ${RERUN_VERSION:-}. License: Apache 2.0."$(tput sgr0)
    else
    echo " _ __ ___ _ __ _   _ _ __"
    echo "| '__/ _ \ '__| | | | '_ \ "
    echo "| | |  __/ |  | |_| | | | |"
    echo "|_|  \___|_|   \__,_|_| |_|"
    echo "Version: ${RERUN_VERSION:-}. License: Apache 2.0."
    fi
}


#
# __rerun_examples_ - Print usage examples
#
#
_rerun_examples() {
    (( $# != 1 )) && {
        rerun_die "wrong # args: should be: _rerun_examples prog"
    }
    local -r prog=$1
    echo >&2 "Examples:"
echo "
| # List installed modules:
| \$ $prog
| # List  commands:
| \$ $prog stubbs
| # Execute a command:
| \$ $prog stubbs:add-module --module freddy"
}

#
# __rerun_man_page_ - Show man page for the module
#
# Notes:
#
# * Each module can have a Unix man page.
# * Use stubbs:docs to generate the man page if one doesn't
# already exist. Display the man page with `nroff`.

_rerun_man_page() {
    (( $# != 1 )) && {
        rerun_die "wrong # args: should be: _rerun_man module"
    }
    local -r module=$1
    for path_element in $(rerun_module_path_elements "$RERUN_MODULES")
    do
        if [[ ! -f "$path_element/$module/$module.1"
                && -f "$path_element/stubbs/commands/docs/script" ]]
        then ${RERUN:-rerun} stubbs:docs --module "$module"
        fi
        if [[ -f "$path_element/$module/$module.1" ]]
        then nroff -man "$path_element/$module/$module.1" | ${PAGER:-more}
        else echo >&2 "Manual could not be generated."
        fi
    done
}

PAD="  "

# __rerun_module_summary_ - Print a module summary.
#
# Arguments
#
# * directory: Module directory
#
_rerun_module_summary() {
    (( $# != 1 && $# != 2 )) && {
        rerun_die "wrong # args: should be: _rerun_module_summary module_dir"
    }
    local -r module_dir=$1
    local -r module_name_path=$2
    local module_name module_desc module_vers
    if rerun_module_exists "$(basename "$module_dir")" 0
    then
        module_name=$([ -n "$module_name_path" ] && echo $module_name_path || basename "$module_dir")
        module_desc=$(rerun_property_get "$module_dir" DESCRIPTION)
        module_vers=$(rerun_property_get "$module_dir" VERSION) || module_vers=""
        printf "%s%s  (v%s)  \n   %s%s\n" \
            "$(rerun_color green "$module_name")" \
            "$module_desc" \
            "$module_vers" \
            "${PAD:-}" \
            "$(rerun_color cyan "$module_dir")"
    fi
}

# __rerun_modules_summary_ - List the modules.
#
# Arguments
#
# * path: Path to directories containing modules
#
# Notes:
#
# * When rerun is installed in the system location
# and rerun modules is different to the system location,
# then list the system installed ones separately.
#
_rerun_modules_summary() {
    (( $# != 1 )) && {
        rerun_die "wrong # args: should be: _rerun_modules_summary directory"
    }
    printf "%s\n" "$(rerun_color yellow "Available modules:")"

    shopt -s nullglob # enable
    set +u
    for directory in $(rerun_module_path_elements "$1")
    do
        for module in $directory/*
        do
            [[ -f "$module/metadata" ]] && _rerun_module_summary "$module"
            for module_sub in $module/*
            do
                module_name_path=${module_sub#$directory/}
                [[ -f "$module_sub/metadata" ]] && _rerun_module_summary "$module_sub" "$module_name_path"
            done
        done
        if [[ ${RERUN_LOCATION:-} = "${RERUN_DEFAULT_BINDIR}"
                && $path_element != "${RERUN_DEFAULT_LIBDIR}/rerun/modules" ]]
        then
            echo
            printf "%s\n" "$(rerun_color yellow "Available modules in \"${RERUN_DEFAULT_LIBDIR}/rerun/modules\":")"
            for module in ${RERUN_DEFAULT_LIBDIR}/rerun/modules/*
            do
               [[ -f "$module/metadata" ]] && _rerun_module_summary "$module"
            done
        fi
    done
    set -u
}

#
# __rerun_commands_summary_ - List commands
#
#
_rerun_commands_summary() {
    (( $# != 2 )) && {
        rerun_die "wrong # args: should be: _rerun_commands_summary directory module"
    }
    local -r directory=$1
    local module=$2

    local -r module_dir=$(rerun_module_exists "$module") || rerun_syntax_error "module not found: \"$module\""
    printf "%s\n" "$(rerun_color yellow "Available commands in module, \"$module\":")"
    shopt -s nullglob # enable
    local cmd_name metadata
    for cmd in $module_dir/commands/*/metadata
	do
        cmd_name=$(basename "$(dirname "$cmd")")
        metadata=$module_dir/commands/${cmd_name}/metadata
        [[ -f "$metadata" ]] && cmd_desc=$(rerun_property_get "$(dirname "$cmd")" DESCRIPTION)
        printf "%s\n" "$(rerun_color green "${cmd_name}: \"${cmd_desc}\"")"
        if [[ -d "$module_dir/commands/${cmd_name}" ]]
        then
            #
            # List the command options
            local module=${module##*/}
            local -a options=( $(rerun_options "$(dirname "$module_dir")" "$module" "$cmd_name") )
            [[ -z "${options:-}" ]] && continue
            for opt in "${options[@]}"
            do
                local opt_metadata=$module_dir/options/${opt}/metadata
                if [[ -r "$opt_metadata" ]]
                then
                (   set +u
                    argstring="" summary=""
                    # shellcheck source=/dev/null
                    . "$opt_metadata" ; # Read the option's metadata.
                    if [[ -n "${SHORT}" ]]; then
                       argstring=$(printf ' --%s|-%s'  "$NAME" "$SHORT")
                    else
                       argstring=$(printf " --%s" "$NAME" )
                    fi
                    [[ "$ARGUMENTS" == "true" ]] && {
                        # Lookup the default but set expand=false to not evalute possible variable.
                        DEFAULT=$(rerun_property_get "$module_dir/options/${opt}" DEFAULT false)
                        argstring=$(printf "%s <%s>" "$argstring" "$(rerun_color ul "${DEFAULT}")")
                    }
                    if [[ "$REQUIRED" != "true" ]]; then
                        summary=$(printf "[%s]: \"%s\"" "${argstring}" "$DESCRIPTION")
                    else
                        summary=$(printf "%s: \"%s\"" "${argstring}" "$DESCRIPTION")
                    fi
                    echo -e "$PAD $summary"
                    set -u
                )
                else
                    # limited usage summary.
                    echo -e "$PAD --$opt <>: \"no description\"";
                fi
            done
        fi
    done

}