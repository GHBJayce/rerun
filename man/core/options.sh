# Parse rerun command line options
# --------------------------------

export RERUN_VERBOSE=

# There are two sets of options, `rerun` specific arguments
# and command options.

while (( "$#" > 0 )); do
    OPT="$1"
    case "$OPT" in
	-h*|--h*)
        _rerun_banner
        ! rerun_option_usage
        _rerun_examples "$(basename "$0")"
        exit 0
	    ;;
	--banner)  _rerun_banner ; exit 0
	    ;;
  	-G)
	    export RERUN_COLOR="true"
	    ;;
	-v)
        RERUN_VERBOSE="-vx"
	    ;;
    -x)
        RERUN_VERBOSE="-x"
        ;;
  	-V)
	    RERUN_VERBOSE="-vx"
	    set -vx
	    ;;
  	--version)
	    echo >&2 "$RERUN_VERSION"
            exit 0
	    ;;
	--man*)
	    rerun_option_check "$#" "$1"
	    _rerun_man_page "$2"
	    exit 0
	    ;;
	--loglevel)
            rerun_option_check "$#" "$1"
            rerun_log level "$2"
            shift
            ;;
	-M)
	    rerun_option_check "$#" "$1"
	    RERUN_MODULES=$(rerun_path_absolute "$2")
	    shift
	    ;;
	-A|--answer[s]*)
	    rerun_option_check "$#" "$1"
	    ANSWERS="$2"
        [[ ! -f $ANSWERS ]] && rerun_syntax_error "answers file not found: $ANSWERS"
	    shift
	    ;;
	-S|--sudo-user)
            rerun_option_check "$#" "$1"
            SUDO_USER="$2"
            shift
            ;;
	*)
	    break;# Ignore remaining arguments as they are for the module.
    esac
    shift
done