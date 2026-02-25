# ==============================================================================
# bash_functions.sh — General-purpose shell utility functions
# ==============================================================================
# Maintainer : Vallabhdas Kansagara <vrkansagara@gmail.com> — @vrkansagara
# Version    : 2.0.0
# Usage      : source this file from ~/.bashrc or ~/.zshrc

# Guard against double-sourcing
[ -n "${_LOADED_BASH_FUNCTIONS_SH:-}" ] && return 0
_LOADED_BASH_FUNCTIONS_SH=1

########################################
# Date with ordinal suffix
########################################
Day() {
    local day
    day="$(date '+%e' | tr -d ' ')"

    case "$day" in
        1|21|31) printf "%sst\n" "$day" ;;
        2|22)    printf "%snd\n" "$day" ;;
        3|23)    printf "%srd\n" "$day" ;;
        *)       printf "%sth\n" "$day" ;;
    esac
}

########################################
# Battery status (Linux, BAT0 safe)
########################################
Battery() {
    local dir="/sys/class/power_supply/BAT0"

    [[ -d "$dir" ]] || return 0

    if grep -q '^Charging' "$dir/status" 2>/dev/null; then
        printf "+"
    fi

    cat "$dir/capacity" 2>/dev/null
}

########################################
# Notify-send from root or script
########################################
myNotifySend() {
    local display user uid

    display="$(ls /tmp/.X11-unix/X* 2>/dev/null | sed 's#.*/X##' | head -n1)"
    [[ -n "$display" ]] || return 1
    display=":$display"

    user="$(who | awk -v d="$display" '$0 ~ d {print $1; exit}')"
    [[ -n "$user" ]] || return 1

    uid="$(id -u "$user")"

    sudo -u "$user" \
        DISPLAY="$display" \
        DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$uid/bus" \
        notify-send "$@"
}

########################################
# Detect terminal and version
########################################
which_term() {
    local parent term found=0

    parent="$(ps -p $$ -o ppid=)"
    term="$(ps -p "$parent" -o comm=)"

    case "$term" in
        gnome-terminal*)
            printf "gnome-terminal %s\n" "$(dpkg -l gnome-terminal | awk '/^ii/{print $3}')"
            found=1
            ;;
        lxterminal*)
            printf "lxterminal %s\n" "$(dpkg -l lxterminal | awk '/^ii/{print $3}')"
            found=1
            ;;
        rxvt*)
            printf "rxvt %s\n" "$(dpkg -l rxvt | awk '/^ii/{print $3}')"
            found=1
            ;;
    esac

    if [[ $found -eq 0 ]]; then
        for v in --version -version -V -v; do
            if "$term" "$v" &>/dev/null; then
                "$term" "$v"
                return
            fi
        done
        dpkg -l "$term" 2>/dev/null | awk '/^ii/{print $2, $3}'
    fi
}

########################################
# Measure shell startup time
########################################
timezsh() {
    local shell="${1:-$SHELL}"
    for _ in {1..10}; do
        /usr/bin/time "$shell" -i -c exit
    done
}

########################################
# Profile zsh startup
########################################
profzsh() {
    local shell="${1:-$SHELL}"
    ZPROF=true "$shell" -i -c exit
}

########################################
# Tar + gzip helper
# Usage: tgz <name> <dir> [-t]
#   -t  appends a timestamp to the archive name
########################################
tgz() {
    local name="$1"
    local target="$2"

    [[ -n "$name" && -n "$target" ]] || {
        printf "Usage: tgz <name> <dir> [-t]\n" >&2
        return 1
    }

    if [[ "${3:-}" == "-t" ]]; then
        tar -czvf "${name}-$(date '+%Y%m%d%H%M%S').tgz" "$target"
    else
        tar -czvf "${name}.tgz" "$target"
    fi
}

########################################
# Find files by extension
# Usage: ft <extension>
########################################
ft() {
    find . -type f -name "*.$1"
}

########################################
# Find files by filename fragment
# Usage: f <fragment>
########################################
f() {
    find . -type f -name "*$1*"
}

########################################
# Top used shell commands from history
########################################
lt() {
    history | awk '{a[$2]++} END {for (i in a) print a[i], i}' \
        | sort -rn | head
}

########################################
# Detect OS type; exports $machine
########################################
machine() {
    case "$(uname -s)" in
        Linux*)   machine=linux  ;;
        Darwin*)  machine=mac    ;;
        CYGWIN*)  machine=cygwin ;;
        MINGW*)   machine=mingw  ;;
        MSYS_NT*) machine=git    ;;
        *)        machine="UNKNOWN" ;;
    esac
    export machine
}

########################################
# Git passthrough function
########################################
# Remove alias if exists
# unalias ggs 2>/dev/null || true

ggfff() {
    git "$@"
}

########################################
# Init: detect machine type at source time
########################################
machine
