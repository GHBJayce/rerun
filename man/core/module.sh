# Set the absolute path to this invocation of the rerun script. Drives the Linux FSH usage convention where
# modules located in ${RERUN_DEFAULT_LIBDIR}/rerun/modules are appended to the modules in RERUN_MODULES.
RERUN_LOCATION="$(cd "$(dirname "${BASH_SOURCE[0]:-}" )" && pwd)"
# fix issue #206
if [[ -x /usr/bin/readlink && "$(uname)" == 'Linux' ]]; then
    RERUN_LOCATION=$(/usr/bin/readlink -f "$RERUN_LOCATION")
fi


# Default the RERUN_MODULES environment variable.
# If it is not set, then default it to either the system
# install location or relative to the rerun executable.
# TODO: add a unit test for this.

if [[ -z "${RERUN_MODULES:-}" ]]
then
    if [[ "$RERUN_LOCATION" = "${RERUN_DEFAULT_BINDIR}" ]]
    then
      RERUN_MODULES="${RERUN_DEFAULT_LIBDIR}/rerun/modules";
    else
      RERUN_MODULES=${RERUN_LOCATION}/modules; # Set module directory relative to the `rerun` script:
    fi
fi


# Ensure the modules directory path is defined and at least one element is a directory.
#
[[ -n "${RERUN_MODULES:-}" ]] || {
    rerun_die "RERUN_MODULES is not defined"
}
__rerun_module_has_valid_dir__=1
for path_element in $(rerun_module_path_elements "$RERUN_MODULES")
do
    if [[ -d "$path_element" ]]
    then
        __rerun_module_has_valid_dir__=0
        break
    fi
done
[[ $__rerun_module_has_valid_dir__ = 0 ]] || {
    rerun_die "RERUN_MODULES does not contain any valid directories: $RERUN_MODULES"
}