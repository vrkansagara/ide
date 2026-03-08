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
# Battery status (Linux, first available BAT)
########################################
Battery() {
    local dir bat

    for bat in /sys/class/power_supply/BAT{0,1,2}; do
        [[ -d "$bat" ]] && { dir="$bat"; break; }
    done

    [[ -n "$dir" ]] || return 0

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

    display="$(find /tmp/.X11-unix -maxdepth 1 -name 'X*' 2>/dev/null | sed 's#.*/X##' | head -n1)"
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
    local parent term ver

    parent="$(ps -p $$ -o ppid= 2>/dev/null | tr -d ' ')"
    term="$(ps -p "$parent" -o comm= 2>/dev/null)"

    [[ -n "$term" ]] || { printf "unknown\n"; return 1; }

    # Try common version flags
    for v in --version -version -V -v; do
        ver="$("$term" "$v" 2>&1 | head -n1)" && {
            printf "%s\n" "$ver"
            return
        }
    done

    # Debian fallback
    if command -v dpkg &>/dev/null; then
        dpkg -l "$term" 2>/dev/null | awk '/^ii/{print $2, $3; exit}'
        return
    fi

    printf "%s (version unknown)\n" "$term"
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
    [[ -n "$1" ]] || { printf "Usage: ft <extension>\n" >&2; return 1; }
    find . -type f -name "*.$1"
}

########################################
# Find files by filename fragment
# Usage: f <fragment>
########################################
f() {
    [[ -n "$1" ]] || { printf "Usage: f <fragment>\n" >&2; return 1; }
    find . -type f -name "*$1*"
}

########################################
# Top used shell commands from history
# Usage: lt [N]  (default: 10)
########################################
lt() {
    local n="${1:-10}"
    history | awk '{a[$2]++} END {for (i in a) print a[i], i}' \
        | sort -rn | head -n "$n"
}

########################################
# Detect OS type; exports $MACHINE_TYPE
########################################
machine() {
    case "$(uname -s)" in
        Linux*)   MACHINE_TYPE=linux  ;;
        Darwin*)  MACHINE_TYPE=mac    ;;
        CYGWIN*)  MACHINE_TYPE=cygwin ;;
        MINGW*)   MACHINE_TYPE=mingw  ;;
        MSYS_NT*) MACHINE_TYPE=git    ;;
        *)        MACHINE_TYPE=unknown ;;
    esac
    export MACHINE_TYPE
}

########################################
# mkdir + cd in one step
# Usage: mkcd <dir>
########################################
mkcd() {
    [[ -n "$1" ]] || { printf "Usage: mkcd <dir>\n" >&2; return 1; }
    mkdir -p "$1" && cd "$1" || return 1
}

fPortKill() {
    if lsof -t -i:$1 >/dev/null; then
        sudo kill -9 $(lsof -t -i:$1)
        echo "Port $1 killed"
    else
        echo "Nothing running on port $1"
    fi
}

########################################
# Init: detect machine type at source time
########################################
machine
