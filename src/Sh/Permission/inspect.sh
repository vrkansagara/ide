#!/usr/bin/env bash
# =============================================================================
# inspect.sh — Enterprise-grade file/directory permission inspector
# =============================================================================
# Maintainer : Vallabhdas Kansagara <vrkansagara@gmail.com> — @vrkansagara
# Version    : 2.0.0
# Mode       : SAFE — read-only, never modifies permissions
# =============================================================================
set -o errexit
set -o pipefail
set -o nounset

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------
readonly VERSION="2.0.0"
readonly PROGNAME="${0##*/}"

# ---------------------------------------------------------------------------
# Defaults
# ---------------------------------------------------------------------------
VERBOSE=0

# ---------------------------------------------------------------------------
# Colours
# ---------------------------------------------------------------------------
_init_colors() {
    if [ -t 1 ] && command -v tput >/dev/null 2>&1; then
        C_RESET="$(tput sgr0   2>/dev/null || printf '')";  C_GREEN="$(tput setaf 2 2>/dev/null || printf '')"
        C_YELLOW="$(tput setaf 3 2>/dev/null || printf '')"; C_RED="$(tput setaf 1 2>/dev/null || printf '')"
        C_CYAN="$(tput setaf 6 2>/dev/null || printf '')";   C_BOLD="$(tput bold 2>/dev/null || printf '')"
    else
        C_RESET=''; C_GREEN=''; C_YELLOW=''; C_RED=''; C_CYAN=''; C_BOLD=''
    fi
}
_init_colors

# ---------------------------------------------------------------------------
# Logging
# ---------------------------------------------------------------------------
info()    { printf '%b[INFO]  %s%b\n' "$C_GREEN"  "$*" "$C_RESET"; }
warn()    { printf '%b[WARN]  %s%b\n' "$C_YELLOW" "$*" "$C_RESET"; }
fatal()   { printf '%b[FATAL] %s%b\n' "$C_RED"    "$*" "$C_RESET" >&2; exit 1; }
ok()      { printf '%b[OK]    %s%b\n' "$C_GREEN"  "$*" "$C_RESET"; }
log()     { [ "$VERBOSE" -ne 0 ] && printf '[DEBUG] %s\n' "$*" || true; }
section() { printf '\n%b=== %s ===%b\n' "${C_BOLD}${C_CYAN}" "$*" "$C_RESET"; }

# ---------------------------------------------------------------------------
# Usage
# ---------------------------------------------------------------------------
usage() {
    cat <<EOF
${C_BOLD}${PROGNAME}${C_RESET} v${VERSION} — Permission inspector (read-only, no changes)

${C_BOLD}USAGE${C_RESET}
  $PROGNAME --inspect <PATH> [OPTIONS]
  $PROGNAME -h | --help

${C_BOLD}DESCRIPTION${C_RESET}
  Inspects and reports permissions, ownership, octal mode, capability checks,
  group membership, and SELinux context for a given file or directory.
  This script NEVER modifies any permissions.

${C_BOLD}OPTIONS${C_RESET}
  --inspect PATH    Path to inspect (file or directory)
  -v, --verbose     Verbose / debug output
  --version         Print version and exit
  -h, --help        Show this help and exit

${C_BOLD}EXAMPLES${C_RESET}
  $PROGNAME --inspect ~/myfile.txt
  $PROGNAME --inspect /var/www/html
  $PROGNAME --inspect /etc/passwd -v

EOF
}

# ---------------------------------------------------------------------------
# Octal permission extraction
# Parses symbolic permission string (e.g. -rwxr-x---) into octal digits.
# Needed for portable group/other capability reporting from stat output.
# ---------------------------------------------------------------------------
_sym_to_octal() {
    local sym="$1"   # e.g. "-rwxr-x---"
    # Strip leading type char, leaving 9 permission chars
    local bits="${sym:1}"
    local result=0
    local i=0 char digit

    for i in 0 1 2; do
        digit=0
        # r bit
        char="${bits:$((i * 3)):1}";  [ "$char" = "r" ] && digit=$((digit + 4))
        # w bit
        char="${bits:$((i * 3 + 1)):1}"; [ "$char" = "w" ] && digit=$((digit + 2))
        # x / s / S / t / T bit
        char="${bits:$((i * 3 + 2)):1}"
        case "$char" in
            x|s|t) digit=$((digit + 1)) ;;
        esac
        result="${result}${digit}"
    done
    printf '%s' "$result"
}

# ---------------------------------------------------------------------------
# Capability check from raw symbolic string
# Usage: _can SYMBOLIC_STRING ENTITY_OFFSET
#   ENTITY_OFFSET: 0=owner(chars 1-3), 3=group(4-6), 6=other(7-9)
# ---------------------------------------------------------------------------
_can_read()    { local s="${1:$(($2 + 1)):1}"; [ "$s" = "r" ] && echo "yes" || echo "no"; }
_can_write()   { local s="${1:$(($2 + 2)):1}"; [ "$s" = "w" ] && echo "yes" || echo "no"; }
_can_execute() { local s="${1:$(($2 + 3)):1}"
                 case "$s" in x|s|t) echo "yes" ;; *) echo "no" ;; esac; }

# ---------------------------------------------------------------------------
# Core inspection function
# ---------------------------------------------------------------------------
inspect_path() {
    local target="$1"

    [ -e "$target" ] || [ -L "$target" ] \
        || fatal "Path does not exist: $target"

    local abs
    abs="$(readlink -f "$target" 2>/dev/null || realpath "$target" 2>/dev/null || printf '%s' "$target")"

    # Gather stat fields
    local owner group sym_perms file_type octal_perms
    owner="$(stat -c '%U' "$abs" 2>/dev/null)" \
        || fatal "Cannot stat '$abs' — check permissions."
    group="$(stat -c '%G' "$abs")"
    sym_perms="$(stat -c '%A' "$abs")"
    file_type="$(stat -c '%F' "$abs")"
    octal_perms="$(stat -c '%a' "$abs")"

    local me my_groups
    me="$(id -un)"
    my_groups="$(id -Gn)"

    # ---- Report ----
    section "Inspection: $abs"

    printf '\n'
    printf '  %-18s %s\n' "Path:"        "$abs"
    printf '  %-18s %s\n' "Type:"        "$file_type"
    printf '  %-18s %s  (octal: %s)\n' "Permissions:" "$sym_perms" "$octal_perms"
    printf '  %-18s %s\n' "Owner:"       "$owner"
    printf '  %-18s %s\n' "Owner group:" "$group"
    printf '\n'
    printf '  %-18s %s\n' "Current user:"   "$me"
    printf '  %-18s %s\n' "User groups:"    "$my_groups"
    printf '\n'

    # ---- Effective capability check for CURRENT USER ----
    section "Current User Capabilities"
    local r_result w_result x_result
    r_result="$([ -r "$abs" ] && echo "YES" || echo "NO")"
    w_result="$([ -w "$abs" ] && echo "YES" || echo "NO")"
    x_result="$([ -x "$abs" ] && echo "YES" || echo "NO")"

    _capability_line "Read"    "$r_result"
    _capability_line "Write"   "$w_result"
    _capability_line "Execute" "$x_result"
    printf '\n'

    # ---- Owner permission bits ----
    section "Permission Bits — Owner ($owner)"
    _capability_line "Read"    "$(_can_read    "$sym_perms" 0)"
    _capability_line "Write"   "$(_can_write   "$sym_perms" 0)"
    _capability_line "Execute" "$(_can_execute "$sym_perms" 0)"
    printf '\n'

    # ---- Group permission bits ----
    section "Permission Bits — Group ($group)"
    local in_group="no"
    if printf '%s' " $my_groups " | grep -qw "$group" 2>/dev/null; then
        in_group="yes"
    fi
    printf '  %-18s %s\n' "User in group:" "$in_group"
    _capability_line "Read"    "$(_can_read    "$sym_perms" 3)"
    _capability_line "Write"   "$(_can_write   "$sym_perms" 3)"
    _capability_line "Execute" "$(_can_execute "$sym_perms" 3)"
    printf '\n'

    # ---- Other permission bits ----
    section "Permission Bits — Other"
    _capability_line "Read"    "$(_can_read    "$sym_perms" 6)"
    _capability_line "Write"   "$(_can_write   "$sym_perms" 6)"
    _capability_line "Execute" "$(_can_execute "$sym_perms" 6)"
    printf '\n'

    # ---- Special bits ----
    section "Special Bits"
    local setuid setgid sticky
    setuid="$(printf '%s' "$sym_perms" | grep -c 's' || true)"
    setgid="$(printf '%s' "$sym_perms" | grep -c 'S\|s' || true)"
    sticky="$(printf '%s' "$sym_perms" | grep -c 't\|T' || true)"
    printf '  %-18s %s\n' "Setuid (SUID):" "$([ "$setuid" -gt 0 ] && echo "SET" || echo "not set")"
    printf '  %-18s %s\n' "Setgid (SGID):" "$([ "$setgid" -gt 0 ] && echo "SET" || echo "not set")"
    printf '  %-18s %s\n' "Sticky bit:"    "$([ "$sticky" -gt 0 ] && echo "SET" || echo "not set")"
    printf '\n'

    # ---- SELinux context (if available) ----
    if command -v ls >/dev/null 2>&1 && ls -Zd "$abs" >/dev/null 2>&1; then
        section "SELinux Context"
        ls -Zd "$abs" 2>/dev/null || true
        printf '\n'
    else
        log "SELinux not active or ls -Z not supported; skipping context."
    fi

    ok "Inspection complete: $abs"
}

# ---------------------------------------------------------------------------
# Helper: print a capability line with colour
# ---------------------------------------------------------------------------
_capability_line() {
    local label="$1"
    local result="$2"   # "YES" / "yes" = green, anything else = yellow
    case "$result" in
        YES|yes)
            printf '  %b%-10s : %s%b\n' "$C_GREEN"  "$label" "$result" "$C_RESET" ;;
        NO|no)
            printf '  %b%-10s : %s%b\n' "$C_YELLOW" "$label" "$result" "$C_RESET" ;;
        *)
            printf '  %-10s : %s\n' "$label" "$result" ;;
    esac
}

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------
parse_args() {
    local inspect_target=""

    if [ $# -eq 0 ]; then
        usage
        exit 0
    fi

    while [ $# -gt 0 ]; do
        case "$1" in
            --inspect)
                [ $# -lt 2 ] && fatal "Missing argument for --inspect"
                inspect_target="$2"; shift 2 ;;
            -v|--verbose)
                VERBOSE=1; shift ;;
            --version)
                printf '%s v%s\n' "$PROGNAME" "$VERSION"; exit 0 ;;
            -h|--help)
                usage; exit 0 ;;
            --)
                shift; break ;;
            -*)
                fatal "Unknown option: '$1'. Run with -h for help." ;;
            *)
                # Positional argument treated as inspect target
                inspect_target="$1"; shift ;;
        esac
    done

    [ -n "$inspect_target" ] || fatal "No path specified. Use --inspect <PATH> or see -h."
    inspect_path "$inspect_target"
}

# ===========================================================================
# MAIN
# ===========================================================================
main() {
    usage
    parse_args "$@"
}

main "$@"
