#!/usr/bin/env bash
# Maintainer :- vallabhdas kansagara <vrkansagara@gmail.com>
# Mode: SAFE — No permission changes executed unless specific options added later.
# Today: Prints help + enables --inspect <path> functionality.

set -o errexit
set -o pipefail
set -o nounset

PROGNAME="${0##*/}"
VERBOSE=0

# ------------- Colors -------------
if [ -t 1 ]; then
    if command -v tput >/dev/null 2>&1; then
        COLOR_RESET="$(tput sgr0 || true)"
        COLOR_GREEN="$(tput setaf 2 || true)"
        COLOR_YELLOW="$(tput setaf 3 || true)"
        COLOR_RED="$(tput setaf 1 || true)"
    else
        COLOR_RESET=$'\e[0m'
        COLOR_GREEN=$'\e[32m'
        COLOR_YELLOW=$'\e[33m'
        COLOR_RED=$'\e[31m'
    fi
else
    COLOR_RESET=""
    COLOR_GREEN=""
    COLOR_YELLOW=""
    COLOR_RED=""
fi

ok()    { printf '%b%s%b\n' "$COLOR_GREEN" "$*" "$COLOR_RESET"; }
warn()  { printf '%b%s%b\n' "$COLOR_YELLOW" "$*" "$COLOR_RESET"; }
fatal() { printf '%b%s%b\n' "$COLOR_RED" "$*" "$COLOR_RESET" >&2; exit 1; }

usage() {
cat <<EOF

$PROGNAME — Home Permission Utility (SAFE MODE — No changes applied)

USAGE:
  $PROGNAME --inspect <PATH>

OPTIONS:
  --inspect <file|directory>
      Inspect permissions, ownership, and user's ability to read/write/execute.

  -v
      Verbose output

  -h, --help
      Show this help message (printed automatically every run)

DESCRIPTION:
  This version of the script NEVER modifies permissions.
  It ONLY prints help unless --inspect is used.

EXAMPLES:
  $PROGNAME --inspect ~/myfile.txt
  $PROGNAME --inspect /var/www/html

EOF
}

# Always show help and continue processing arguments
usage

# ------------ INSPECT FUNCTION ------------
inspect_path() {
    local target="$1"

    if [ ! -e "$target" ]; then
        fatal "Path does not exist: $target"
    fi

    local abs
    abs="$(readlink -f "$target")"

    local owner group perms type
    owner="$(stat -c %U "$abs")"
    group="$(stat -c %G "$abs")"
    perms="$(stat -c %A "$abs")"
    type="$(stat -c %F "$abs")"
    octal="$(stat -c %a "$abs")"

    echo ""
    ok "INSPECTION RESULT"
    echo "  Path:           $abs"
    echo "  Type:           $type"
    echo "  Permissions:    $perms  (octal: $octal)"
    echo "  Owner:          $owner"
    echo "  Group:          $group"
    echo ""

    local me my_groups
    me="$(id -un)"
    my_groups="$(id -nG)"

    echo " Current User: $me"
    echo " User Groups:  $my_groups"
    echo ""

    # capability tests
    echo " Capability Check:"
    [ -r "$abs" ] && echo "  ✔ User can READ"    || echo "  ✘ User CANNOT READ"
    [ -w "$abs" ] && echo "  ✔ User can WRITE"   || echo "  ✘ User CANNOT WRITE"
    [ -x "$abs" ] && echo "  ✔ User can EXECUTE" || echo "  ✘ User CANNOT EXECUTE"

    echo ""

    # Group permission checks:
    echo " Group ($group) Permission Check:"
    if id -nG "$me" | grep -qw "$group"; then
        echo "  ✔ User belongs to group '$group'"
        [ -r "$abs" ] && echo "  ✔ Group can READ"    || echo "  ✘ Group CANNOT READ"
        [ -w "$abs" ] && echo "  ✔ Group can WRITE"   || echo "  ✘ Group CANNOT WRITE"
        [ -x "$abs" ] && echo "  ✔ Group can EXECUTE" || echo "  ✘ Group CANNOT EXECUTE"
    else
        warn "  User does NOT belong to group '$group'"
    fi

    # SELinux (if exists)
    if command -v ls >/dev/null 2>&1 && ls -Z "$abs" >/dev/null 2>&1; then
        echo ""
        echo " SELinux Context:"
        ls -Zd "$abs"
    fi

    echo ""
    ok "INSPECTION COMPLETE"
}

# ------------- Parse arguments -------------
if [ $# -eq 0 ]; then
    exit 0
fi

while [ $# -gt 0 ]; do
    case "$1" in
        --inspect)
            [ $# -lt 2 ] && fatal "Missing argument for --inspect"
            inspect_path "$2"
            exit 0
            ;;
        -v)
            VERBOSE=1
            shift
            ;;
        -h|--help)
            exit 0
            ;;
        *)
            fatal "Unknown argument: $1"
            ;;
    esac
done
