# Clear MODULE and COMMAND in case they were incidentally declared in the environment.

MODULE="" COMMAND=""

# Parse rerun command and their options.
# Use regex to split up command strings.
if [[ "$@" =~ ([^:]+)([:]?[ ]?)([-A-Za-z0-9_]*)([ ]*)(.*) ]]
then
    MODULE=${BASH_REMATCH[1]};     # module
    [ "${BASH_REMATCH[2]}" == ': ' ] && shift ; # eat the extra space char
    COMMAND=${BASH_REMATCH[3]/ /}; # command
    #- BASH_REMATCH[4] contains the whitespace separating command and options.
    #- BASH_REMATCH[5] contains command options.
else
    [[ -n "${1:-}" ]] && MODULE=${1/:/};   # module (minus colon)
fi
# Shift over so the remaining arguments are left to the command options.
(( "$#" > 0 )) && shift;

# Read answer file and set positional parameters from them.
if [[ -n "${ANSWERS:-}" && -f "${ANSWERS:-}" ]]
then
    eval set -- "$@" "$(_rerun_options_populate "$MODULE" "$COMMAND" "$ANSWERS")"
fi




#
# Execute rerun
# ===============

# Summary: module or command
# --------------------------
#
# **rerun** provides two listing modes: module and commands.
# If a user specifies `rerun` without arguments, a listing
# of module names and their descriptions is displayed.
# If a user specifies a module name: `rerun <module>`,
# then a listing of commands and their options are displayed.
#
# If no module or command are specified, display a listing of modules, showing each
# module's name and description. Modules are read from the directory referenced
# using the `$RERUN_MODULES` environment variable.

if [[ -z "$MODULE" && -z "$COMMAND" ]]
then

    _rerun_modules_summary "$RERUN_MODULES"

    exit 0

# If a module name is specified, show the command set.
# For each command, show that command's option list in summary form
# displaying requirement, name, flags, defaults and description.

elif [[ -n "$MODULE" && -z "$COMMAND" ]]
then

    _rerun_commands_summary "$RERUN_MODULES" "$MODULE"

    exit 0

fi

#
# - - -
#

# Execute script
# ----------------
#
# Set the `RERUN` environment variable so subsequent
# invocations can use the same executable.
#
RERUN=$(rerun_path_absolute "$0")
export RERUN
#

#
# Execute the specified command.
# The remaining positional parameters are passed as command options.
#
rerun_command_execute "$MODULE" "$COMMAND" "$@"

#
# Exit rerun with the script execution's exit code.
exit $?
# - - -
# Done!


# More
# ----

# _(c) 2012-2018 Alex Honor - Apache 2 License_
