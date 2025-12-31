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
            echo "gnome-terminal $(dpkg -l gnome-terminal | awk '/^ii/{print $3}')"
            found=1
            ;;
        lxterminal*)
            echo "lxterminal $(dpkg -l lxterminal | awk '/^ii/{print $3}')"
            found=1
            ;;
        rxvt*)
            echo "rxvt $(dpkg -l rxvt | awk '/^ii/{print $3}')"
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
# Usage: tgz archive dir [-t]
########################################
tgz() {
    local name="$1"
    local target="$2"

    [[ -n "$name" && -n "$target" ]] || {
        echo "Usage: tgz <name> <dir> [-t]"
        return 1
    }

    if [[ "${3:-}" == "-t" ]]; then
        tar -czvf "${name}-$(date '+%Y%m%d%H%M%S').tgz" "$target"
    else
        tar -czvf "${name}.tgz" "$target"
    fi
}

########################################
# Find by extension
########################################
ft() {
    find . -type f -name "*.$1"
}

########################################
# Find by filename fragment
########################################
f() {
    find . -type f -name "*$1*"
}

########################################
# Top used commands
########################################
lt() {
    history | awk '{a[$2]++} END {for (i in a) print a[i], i}' \
        | sort -rn | head
}

########################################
# Detect OS
########################################
machine() {
    case "$(uname -s)" in
        Linux*)  machine=linux ;;
        Darwin*) machine=mac ;;
        CYGWIN*) machine=cygwin ;;
        MINGW*)  machine=mingw ;;
        MSYS_NT*) machine=git ;;
        *) machine="UNKNOWN" ;;
    esac
    export machine
}

########################################
# Git shortcut function (IMPORTANT)
########################################
# Remove alias if exists
unalias g 2>/dev/null || true

# Function version of `g`
g() {
    git "$@"
}

########################################
# Init
########################################
main() {
    machine
}
main
