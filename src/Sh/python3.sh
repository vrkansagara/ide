#!/usr/bin/env bash
# ==============================================================================
# python3.sh — Smart Python project environment manager
# ==============================================================================
# Maintainer : Vallabhdas Kansagara <vrkansagara@gmail.com> — @vrkansagara
# Version    : 3.0.0
#
# Description:
#   Smart entry-point for any Python project. Run from your project directory
#   and it auto-detects (or creates) a virtual environment, then gives you a
#   focused quick-menu: REPL, requirements install, package install, freeze.
#   All classic venv management commands remain available via --menu or flags.
#
# Venv detection order (for current working directory):
#   1. $VIRTUAL_ENV already set          (already active in shell)
#   2. .venv/bin/activate                (local project venv)
#   3. venv/bin/activate                 (local project venv — alternate name)
#   4. .python-venv marker file          → named venv in ~/.venvs/
#   5. ~/.venvs/<cwd-basename>/          (managed venv matched by project name)
#
# Reference patterns taken from:
#   - nodejs.sh  (multi-mode dispatch, download_with_retries, nounset guards)
#   - pip.sh     (pip bootstrap via get-pip.py, apt integration)

set -o errexit
set -o pipefail
set -o nounset

readonly SCRIPT_VERSION="3.0.0"
readonly PROGNAME="${0##*/}"
VERBOSE=0
SUDO_CMD=""

# Directory where all managed venvs are stored.
readonly VENV_BASE_DIR="${HOME}/.venvs"

# Resolved at runtime by require_python3.
PYTHON3=""

# Optional venv target (set by --venv <name>).
TARGET_VENV=""

# Pip binary resolved by _resolve_pip_bin.
PIP_BIN=""

# Project venv detection results (set by _detect_project_venv).
DETECTED_VENV_PATH=""
DETECTED_VENV_NAME=""
DETECTED_VENV_TYPE=""   # active | local | managed

# ─── Colors ──────────────────────────────────────────────────────────────────
_init_colors() {
    if [ -t 1 ] && command -v tput >/dev/null 2>&1; then
        C_RESET="$(tput sgr0    2>/dev/null || printf '')";
        C_GREEN="$(tput setaf 2 2>/dev/null || printf '')"
        C_YELLOW="$(tput setaf 3 2>/dev/null || printf '')"
        C_RED="$(tput setaf 1   2>/dev/null || printf '')"
        C_CYAN="$(tput setaf 6  2>/dev/null || printf '')"
        C_BOLD="$(tput bold     2>/dev/null || printf '')"
        C_MAGENTA="$(tput setaf 5 2>/dev/null || printf '')"
    else
        C_RESET=''; C_GREEN=''; C_YELLOW=''; C_RED=''
        C_CYAN=''; C_BOLD=''; C_MAGENTA=''
    fi
}
_init_colors

info()    { printf '%b[INFO]  %s%b\n' "$C_GREEN"   "$*" "$C_RESET"; }
warn()    { printf '%b[WARN]  %s%b\n' "$C_YELLOW"  "$*" "$C_RESET"; }
fatal()   { printf '%b[FATAL] %s%b\n' "$C_RED"     "$*" "$C_RESET" >&2; exit 1; }
ok()      { printf '%b[OK]    %s%b\n' "$C_GREEN"   "$*" "$C_RESET"; }
log()     { [ "$VERBOSE" -ne 0 ] && printf '[DEBUG] %s\n' "$*" || true; }
section() { printf '\n%b=== %s ===%b\n' "${C_BOLD}${C_CYAN}" "$*" "$C_RESET"; }
step()    { printf '%b  -> %s%b\n' "$C_MAGENTA" "$*" "$C_RESET"; }

on_error() {
    local code=$? line="${BASH_LINENO[0]}"
    warn "Unexpected failure at line ${line} (exit ${code})."
    exit "${code}"
}
trap on_error ERR

# ─── Usage ────────────────────────────────────────────────────────────────────
usage() {
    cat <<EOF
${C_BOLD}Usage:${C_RESET} ${PROGNAME} [OPTIONS] [COMMAND] [ARGS...]

${C_BOLD}Default (no args):${C_RESET}
  Scans current directory for a Python virtual environment.
  • Found    → project quick-menu  (REPL, install, freeze, info, …)
  • Not found → offer to create one, then enter quick-menu

${C_BOLD}Project commands:${C_RESET}
  --project                  Smart project mode for CWD (same as no args)

${C_BOLD}Venv management:${C_RESET}
  --create-venv  <name>      Create a new managed venv in ${VENV_BASE_DIR}/
  --activate-venv <name>     Print the source command to activate a venv
  --list-venv                List all managed virtual environments
  --count-venv               Show total count of managed virtual environments
  --delete-venv  <name>      Delete a managed virtual environment (with confirm)
  --venv-info   [name]       Show details of a specific or all venvs
  --install-pip              Install/upgrade pip safely (user scope or venv)

${C_BOLD}Package management:${C_RESET}
  --install-pkg  <pkg...>    Install package(s) into active venv or --user scope
  --install-reqs [file]      Install from requirements.txt (default) in CWD
  --update-pkgs              Upgrade all packages in the current/target venv
  --freeze      [file]       Freeze packages to requirements.txt (default name)

${C_BOLD}REPL / Shell:${C_RESET}
  --console     [name]       Launch an interactive Python REPL inside a venv
  --shell       [name]       Open a bash/zsh subshell with the venv activated

${C_BOLD}Interactive:${C_RESET}
  --menu                     Launch the full interactive management menu

${C_BOLD}Modifiers (must precede the command they target):${C_RESET}
  --venv <name>              Target a specific venv for pkg/reqs/update/freeze

${C_BOLD}Global options:${C_RESET}
  -v, --verbose              Enable verbose/debug output (set -x)
  --version                  Print version and exit
  -h, --help                 Show this help

${C_BOLD}Safety guarantees:${C_RESET}
  - pip is never run globally as root without explicit apt-based system install
  - System Python packages are never removed or overwritten
  - Bare pip installs always use --user scope when outside a venv
  - Debian/Ubuntu externally-managed-environment (PEP 668) is respected
  - Venv deletion requires interactive confirmation

${C_BOLD}Venv detection order (for current directory):${C_RESET}
  1. \$VIRTUAL_ENV already set          → already active
  2. .venv/bin/activate                → local project venv
  3. venv/bin/activate                 → local project venv (alternate)
  4. .python-venv marker file          → named venv in ${VENV_BASE_DIR}/
  5. ${VENV_BASE_DIR}/<dirname>/       → managed venv matched by project name

${C_BOLD}Examples:${C_RESET}
  cd ~/projects/myapp && ${PROGNAME}              # smart project mode
  ${PROGNAME} --project                           # same as above, explicit
  ${PROGNAME} --create-venv myproject
  ${PROGNAME} --venv myproject --install-reqs
  ${PROGNAME} --venv myproject --install-pkg django gunicorn
  ${PROGNAME} --console myproject
  ${PROGNAME} --shell                             # shell for CWD's venv
  ${PROGNAME} --shell myproject                   # shell for named venv
  ${PROGNAME} --menu
EOF
}

# ─── Shared helpers ───────────────────────────────────────────────────────────
_run() {
    if [ -n "$SUDO_CMD" ]; then "$SUDO_CMD" "$@"; else "$@"; fi
}

command_exists() { command -v "$1" >/dev/null 2>&1; }

require_python3() {
    [ -n "$PYTHON3" ] && return 0
    PYTHON3="$(command -v python3 || true)"
    [ -z "$PYTHON3" ] && fatal "python3 not found in PATH. Install Python 3 first."
    log "Using Python: ${PYTHON3} ($("$PYTHON3" --version 2>&1))"
}

is_in_venv() { [ -n "${VIRTUAL_ENV:-}" ]; }

# Detect Debian/Ubuntu PEP-668 externally-managed-environment restriction.
is_externally_managed() {
    local stdlib_path
    stdlib_path="$("$PYTHON3" -c \
        "import sysconfig; print(sysconfig.get_path('stdlib'))" 2>/dev/null || true)"
    [ -n "$stdlib_path" ] && [ -f "${stdlib_path}/EXTERNALLY-MANAGED" ]
}

# Retry-capable downloader.
download_with_retries() {
    local url="$1" dest="$2" tries="${3:-3}" wait="${4:-3}"
    local attempt
    for attempt in $(seq 1 "$tries"); do
        if command_exists curl; then
            curl -fsSL --connect-timeout 10 "$url" -o "$dest" && return 0
        elif command_exists wget; then
            wget -qO "$dest" "$url" && return 0
        fi
        warn "Download attempt ${attempt} failed, retrying in ${wait}s..."
        sleep "$wait"
    done
    fatal "Download failed after ${tries} attempts: ${url}"
}

confirm() {
    local msg="$1"
    printf '%b[CONFIRM]%b %s [y/N]: ' "$C_YELLOW" "$C_RESET" "$msg"
    read -r _answer
    case "${_answer}" in
        [yY]|[yY][eE][sS]) return 0 ;;
        *) return 1 ;;
    esac
}

# ─── Managed-venv path helpers ────────────────────────────────────────────────
_venv_path()   { printf '%s/%s' "$VENV_BASE_DIR" "$1"; }
_venv_python() { printf '%s/%s/bin/python' "$VENV_BASE_DIR" "$1"; }
_venv_pip()    { printf '%s/%s/bin/pip'    "$VENV_BASE_DIR" "$1"; }

_assert_venv_exists() {
    local name="$1" vpath
    vpath="$(_venv_path "$name")"
    [ -d "$vpath" ] && [ -f "${vpath}/bin/activate" ] || \
        fatal "Venv '${name}' not found at ${vpath}. Create it with: ${PROGNAME} --create-venv ${name}"
}

# Resolve which pip binary to use for classic commands; writes into PIP_BIN.
_resolve_pip_bin() {
    if [ -n "$TARGET_VENV" ]; then
        _assert_venv_exists "$TARGET_VENV"
        PIP_BIN="$(_venv_pip "$TARGET_VENV")"
    elif is_in_venv; then
        PIP_BIN="${VIRTUAL_ENV}/bin/pip"
    else
        fatal "No active venv and no --venv specified. Activate a venv or use --venv <name>."
    fi
}

# ─── Project venv detection ───────────────────────────────────────────────────
# Sets DETECTED_VENV_PATH, DETECTED_VENV_NAME, DETECTED_VENV_TYPE.
# Returns 0 if a venv was found for CWD, 1 otherwise.
_detect_project_venv() {
    DETECTED_VENV_PATH=""
    DETECTED_VENV_NAME=""
    DETECTED_VENV_TYPE=""

    # 1. Already active in shell
    if [ -n "${VIRTUAL_ENV:-}" ]; then
        DETECTED_VENV_PATH="$VIRTUAL_ENV"
        DETECTED_VENV_NAME="$(basename "$VIRTUAL_ENV")"
        DETECTED_VENV_TYPE="active"
        return 0
    fi

    # 2. Local .venv/ inside CWD
    if [ -f "${PWD}/.venv/bin/activate" ]; then
        DETECTED_VENV_PATH="${PWD}/.venv"
        DETECTED_VENV_NAME=".venv"
        DETECTED_VENV_TYPE="local"
        return 0
    fi

    # 3. Local venv/ inside CWD
    if [ -f "${PWD}/venv/bin/activate" ]; then
        DETECTED_VENV_PATH="${PWD}/venv"
        DETECTED_VENV_NAME="venv"
        DETECTED_VENV_TYPE="local"
        return 0
    fi

    # 4. .python-venv marker file → named managed venv
    if [ -f "${PWD}/.python-venv" ]; then
        local marker_name
        marker_name="$(tr -d '[:space:]' < "${PWD}/.python-venv")"
        if [ -n "$marker_name" ] && [ -f "${VENV_BASE_DIR}/${marker_name}/bin/activate" ]; then
            DETECTED_VENV_PATH="${VENV_BASE_DIR}/${marker_name}"
            DETECTED_VENV_NAME="$marker_name"
            DETECTED_VENV_TYPE="managed"
            return 0
        fi
    fi

    # 5. ~/.venvs/<cwd-basename>
    local proj_name
    proj_name="$(basename "$PWD")"
    if [ -f "${VENV_BASE_DIR}/${proj_name}/bin/activate" ]; then
        DETECTED_VENV_PATH="${VENV_BASE_DIR}/${proj_name}"
        DETECTED_VENV_NAME="$proj_name"
        DETECTED_VENV_TYPE="managed"
        return 0
    fi

    return 1
}

# ─── Internal helper: launch a subshell with a venv activated ────────────────
# Accepts the full path to the venv directory.
_launch_venv_shell() {
    local venv_path="$1"
    local shell_bin="${SHELL:-bash}"
    local shell_name
    shell_name="$(basename "$shell_bin")"

    section "Venv shell — $(basename "$venv_path")"
    printf '  %-10s %s\n' "Shell:"  "$shell_bin"
    printf '  %-10s %s\n' "Venv:"   "$venv_path"
    printf '  %-10s %s\n' "Python:" "$("${venv_path}/bin/python" --version 2>&1)"
    printf '\n%b  Type "exit" or Ctrl-D to leave the venv shell.%b\n\n' "$C_YELLOW" "$C_RESET"

    local tmprc
    tmprc="$(mktemp /tmp/python3sh-XXXX.sh)"
    # shellcheck disable=SC2064
    trap "rm -f '${tmprc}'" EXIT

    case "$shell_name" in
        bash)
            {
                printf '[ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"\n'
                printf '. "%s/bin/activate"\n' "$venv_path"
            } > "$tmprc"
            exec "$shell_bin" --rcfile "$tmprc"
            ;;
        zsh)
            local zdotdir
            zdotdir="$(mktemp -d /tmp/python3zsh-XXXX)"
            # shellcheck disable=SC2064
            trap "rm -rf '${zdotdir}'; rm -f '${tmprc}'" EXIT
            {
                printf '[ -f "$HOME/.zshrc" ] && . "$HOME/.zshrc"\n'
                printf '. "%s/bin/activate"\n' "$venv_path"
            } > "${zdotdir}/.zshrc"
            ZDOTDIR="$zdotdir" exec "$shell_bin"
            ;;
        *)
            # Generic fallback: export VIRTUAL_ENV + prepend bin to PATH.
            exec env \
                VIRTUAL_ENV="$venv_path" \
                PATH="${venv_path}/bin:${PATH}" \
                "$shell_bin"
            ;;
    esac
}

# ─── Internal helper: create a venv at an arbitrary path ─────────────────────
_create_venv_at() {
    local venv_path="$1"
    require_python3
    if "$PYTHON3" -m venv --help >/dev/null 2>&1; then
        "$PYTHON3" -m venv "$venv_path"
    elif command_exists virtualenv; then
        virtualenv "$venv_path"
    else
        fatal "Neither 'venv' module nor 'virtualenv' available. Run: ${PROGNAME} --install-pip"
    fi
    step "Upgrading pip/setuptools/wheel..."
    "${venv_path}/bin/python" -m pip install --quiet --upgrade pip setuptools wheel
}

# ─── Project quick-menu: venv exists ─────────────────────────────────────────
_project_menu_with_venv() {
    local project_dir="$1" project_name="$2"
    local choice

    while true; do
        # Header — inner width = 64, content = 2 spaces + 62-char path field
        local _disp_dir="$project_dir"
        [ "${#_disp_dir}" -gt 62 ] && _disp_dir="...${_disp_dir: -59}"
        printf '\n%b┌─ Project ──────────────────────────────────────────────────────┐%b\n' \
            "${C_BOLD}${C_CYAN}" "$C_RESET"
        printf '%b│%b  %-62s%b│%b\n' "${C_BOLD}${C_CYAN}" "$C_RESET" \
            "$_disp_dir" "${C_BOLD}${C_CYAN}" "$C_RESET"
        printf '%b└────────────────────────────────────────────────────────────────┘%b\n' \
            "${C_BOLD}${C_CYAN}" "$C_RESET"

        local status_color status_label
        if [ "$DETECTED_VENV_TYPE" = "active" ]; then
            status_color="$C_GREEN"; status_label="ACTIVE"
        else
            status_color="$C_YELLOW"; status_label="inactive"
        fi
        printf '  Venv   : %b%s%b  [%b%s%b]  %b%s%b\n' \
            "$C_CYAN"         "$DETECTED_VENV_NAME"  "$C_RESET" \
            "$status_color"   "$status_label"         "$C_RESET" \
            ""                "$DETECTED_VENV_PATH"  "$C_RESET"
        printf '  Python : %s\n' "$("${DETECTED_VENV_PATH}/bin/python" --version 2>&1)"

        if [ "$DETECTED_VENV_TYPE" != "active" ]; then
            printf '  %bTo activate : source %s/bin/activate%b\n' \
                "$C_YELLOW" "$DETECTED_VENV_PATH" "$C_RESET"
        fi

        local reqs_hint=""
        [ -f "${project_dir}/requirements.txt" ] && \
            reqs_hint="  ${C_GREEN}[requirements.txt found]${C_RESET}"

        printf '\n'
        printf '  %b1)%b  Open shell with venv activated\n'               "$C_BOLD" "$C_RESET"
        printf '  %b2)%b  Open Python REPL (console)\n'                    "$C_BOLD" "$C_RESET"
        printf "  %b3)%b  Install from requirements.txt%b\n"               "$C_BOLD" "$C_RESET" "$reqs_hint"
        printf '  %b4)%b  Install package(s)\n'                            "$C_BOLD" "$C_RESET"
        printf '  %b5)%b  Freeze → requirements.txt\n'                    "$C_BOLD" "$C_RESET"
        printf '  %b6)%b  Show venv info & installed packages\n'           "$C_BOLD" "$C_RESET"
        printf '  %b7)%b  Upgrade all packages\n'                         "$C_BOLD" "$C_RESET"
        printf '  %b8)%b  Full management menu\n'                         "$C_BOLD" "$C_RESET"
        printf '  %b0)%b  Exit\n\n'                                        "$C_BOLD" "$C_RESET"
        printf '%bChoice [0-8]: %b' "$C_BOLD" "$C_RESET"
        read -r choice

        case "$choice" in
            1)
                section "Venv shell — ${DETECTED_VENV_NAME}"
                _launch_venv_shell "$DETECTED_VENV_PATH"
                ;;
            2)
                section "Python REPL — ${DETECTED_VENV_NAME}"
                info "Python: $("${DETECTED_VENV_PATH}/bin/python" --version 2>&1)"
                info "Type 'exit()' or Ctrl-D to leave."
                printf '\n'
                exec "${DETECTED_VENV_PATH}/bin/python"
                ;;
            3)
                local reqfile="${project_dir}/requirements.txt"
                if [ ! -f "$reqfile" ]; then
                    printf 'Path to requirements file [requirements.txt]: '
                    read -r _rf
                    reqfile="${_rf:-requirements.txt}"
                    [[ "$reqfile" != /* ]] && reqfile="${project_dir}/${reqfile}"
                fi
                [ -f "$reqfile" ] || { warn "File not found: ${reqfile}"; continue; }
                local pkg_count
                pkg_count="$(grep -cE '^[^#[:space:]]' "$reqfile" 2>/dev/null || true)"
                section "Installing requirements (${pkg_count} packages)"
                info "File: ${reqfile}"
                "${DETECTED_VENV_PATH}/bin/pip" install -r "$reqfile"
                ok "Requirements installed."
                ;;
            4)
                printf 'Package(s) to install (space-separated): '
                IFS=' ' read -r -a _pkgs
                if [ "${#_pkgs[@]}" -gt 0 ]; then
                    section "Installing: ${_pkgs[*]}"
                    "${DETECTED_VENV_PATH}/bin/pip" install --upgrade "${_pkgs[@]}"
                    ok "Installed: ${_pkgs[*]}"
                else
                    warn "No packages entered."
                fi
                ;;
            5)
                printf 'Output file [%s/requirements.txt]: ' "$project_dir"
                read -r _outfile
                _outfile="${_outfile:-${project_dir}/requirements.txt}"
                "${DETECTED_VENV_PATH}/bin/pip" freeze > "$_outfile"
                ok "Saved $(wc -l < "$_outfile") packages to: ${_outfile}"
                ;;
            6)
                section "Venv info — ${DETECTED_VENV_NAME}"
                printf '  %-12s %s\n' "Name:"   "$DETECTED_VENV_NAME"
                printf '  %-12s %s\n' "Type:"   "$DETECTED_VENV_TYPE"
                printf '  %-12s %s\n' "Path:"   "$DETECTED_VENV_PATH"
                printf '  %-12s %s\n' "Python:" "$("${DETECTED_VENV_PATH}/bin/python" --version 2>&1)"
                printf '  %-12s %s\n' "Pip:"    "$("${DETECTED_VENV_PATH}/bin/pip"    --version 2>&1)"
                printf '\n  Installed packages:\n'
                "${DETECTED_VENV_PATH}/bin/pip" list --format=columns 2>/dev/null || true
                ;;
            7)
                section "Upgrading all packages — ${DETECTED_VENV_NAME}"
                local outdated
                outdated="$("${DETECTED_VENV_PATH}/bin/pip" list --outdated --format=columns \
                    2>/dev/null | awk 'NR>2 {print $1}')" || true
                if [ -z "$outdated" ]; then
                    ok "All packages are already up to date."
                else
                    "${DETECTED_VENV_PATH}/bin/pip" list --outdated --format=columns
                    local pkg
                    while IFS= read -r pkg; do
                        [ -z "$pkg" ] && continue
                        step "Upgrading: ${pkg}"
                        "${DETECTED_VENV_PATH}/bin/pip" install --upgrade "$pkg" \
                            || warn "Could not upgrade: ${pkg}"
                    done <<< "$outdated"
                    ok "Upgrade complete."
                fi
                ;;
            8)
                cmd_menu
                return
                ;;
            0|q|Q)
                info "Goodbye."
                exit 0
                ;;
            *)
                warn "Invalid choice '${choice}'. Enter a number 0-8."
                ;;
        esac
    done
}

# ─── Project quick-menu: no venv found ───────────────────────────────────────
_project_menu_no_venv() {
    local project_dir="$1" project_name="$2"
    local choice

    local _disp_dir="$project_dir"
    [ "${#_disp_dir}" -gt 62 ] && _disp_dir="...${_disp_dir: -59}"
    printf '\n%b┌─ Project ──────────────────────────────────────────────────────┐%b\n' \
        "${C_BOLD}${C_CYAN}" "$C_RESET"
    printf '%b│%b  %-62s%b│%b\n' "${C_BOLD}${C_CYAN}" "$C_RESET" \
        "$_disp_dir" "${C_BOLD}${C_CYAN}" "$C_RESET"
    printf '%b└────────────────────────────────────────────────────────────────┘%b\n' \
        "${C_BOLD}${C_CYAN}" "$C_RESET"
    warn "No Python virtual environment found for this project."
    printf '\n'
    printf '  %b1)%b  Create local venv     (%b.venv/%b inside project dir)\n' \
        "$C_BOLD" "$C_RESET" "$C_CYAN" "$C_RESET"
    printf '  %b2)%b  Create managed venv   (%b~/.venvs/%s%b)\n' \
        "$C_BOLD" "$C_RESET" "$C_CYAN" "$project_name" "$C_RESET"
    printf '  %b3)%b  Map existing venv     (link a venv from %b~/.venvs/%b to this project)\n' \
        "$C_BOLD" "$C_RESET" "$C_CYAN" "$C_RESET"
    printf '  %b4)%b  Full management menu\n' "$C_BOLD" "$C_RESET"
    printf '  %b0)%b  Exit\n\n' "$C_BOLD" "$C_RESET"
    printf '%bChoice [0-4]: %b' "$C_BOLD" "$C_RESET"
    read -r choice

    case "$choice" in
        1)
            local venv_path="${project_dir}/.venv"
            section "Creating local venv: ${venv_path}"
            _create_venv_at "$venv_path"
            ok "Local venv created at: ${venv_path}"
            printf '\n  %bActivate with: source %s/bin/activate%b\n\n' \
                "$C_CYAN" "$venv_path" "$C_RESET"
            DETECTED_VENV_PATH="$venv_path"
            DETECTED_VENV_NAME=".venv"
            DETECTED_VENV_TYPE="local"
            _project_menu_with_venv "$project_dir" "$project_name"
            ;;
        2)
            local vname
            printf 'Venv name [%s]: ' "$project_name"
            read -r vname
            vname="${vname:-$project_name}"
            cmd_create_venv "$vname"
            printf '%s\n' "$vname" > "${project_dir}/.python-venv"
            ok "Wrote .python-venv marker → '${vname}' (used for future auto-detection)."
            DETECTED_VENV_PATH="${VENV_BASE_DIR}/${vname}"
            DETECTED_VENV_NAME="$vname"
            DETECTED_VENV_TYPE="managed"
            _project_menu_with_venv "$project_dir" "$project_name"
            ;;
        3)
            # Show available managed venvs then let user pick one to map.
            if [ ! -d "$VENV_BASE_DIR" ] || [ -z "$(ls -A "$VENV_BASE_DIR" 2>/dev/null)" ]; then
                warn "No managed venvs found in ${VENV_BASE_DIR}. Create one first."
                _project_menu_no_venv "$project_dir" "$project_name"
                return
            fi
            cmd_list_venv
            printf 'Venv name to map to this project: '
            local map_name
            read -r map_name
            [ -z "$map_name" ] && warn "Name cannot be empty." && \
                _project_menu_no_venv "$project_dir" "$project_name" && return
            _assert_venv_exists "$map_name"
            printf '%s\n' "$map_name" > "${project_dir}/.python-venv"
            ok "Mapped: .python-venv → '${map_name}'"
            info "This project will now auto-detect '${map_name}' on every run."
            DETECTED_VENV_PATH="${VENV_BASE_DIR}/${map_name}"
            DETECTED_VENV_NAME="$map_name"
            DETECTED_VENV_TYPE="managed"
            _project_menu_with_venv "$project_dir" "$project_name"
            ;;
        4)
            cmd_menu
            ;;
        0|q|Q)
            info "Goodbye."
            exit 0
            ;;
        *)
            warn "Invalid choice '${choice}'."
            _project_menu_no_venv "$project_dir" "$project_name"
            ;;
    esac
}

# ─── Command: smart project mode ─────────────────────────────────────────────
cmd_smart_project() {
    require_python3
    local project_dir="$PWD"
    local project_name
    project_name="$(basename "$project_dir")"

    if _detect_project_venv; then
        _project_menu_with_venv "$project_dir" "$project_name"
    else
        _project_menu_no_venv "$project_dir" "$project_name"
    fi
}

# ─── Command: install pip ─────────────────────────────────────────────────────
cmd_install_pip() {
    require_python3
    section "Installing / upgrading pip"

    # apt-based systems — install via package manager (only safe method on Debian/Ubuntu).
    if command_exists apt-get; then
        info "apt-based system detected — installing python3-pip, python3-venv via apt..."
        _run apt-get install -y python3-pip python3-venv python3-setuptools
        ok "System pip packages installed via apt."
    fi

    if is_in_venv; then
        info "Active venv detected — upgrading pip inside venv..."
        "$PYTHON3" -m pip install --upgrade pip setuptools wheel
    elif is_externally_managed; then
        warn "Externally-managed environment detected (PEP 668 / Debian policy)."
        info "System pip is managed by apt — get-pip.py bootstrap is not needed."
        info "To install third-party packages, use a virtual environment:"
        printf '    %b%s --project%b\n' "$C_CYAN" "$PROGNAME" "$C_RESET"
        info "For standalone CLI tools, pipx is recommended:"
        printf '    %bapt install pipx && pipx install <app>%b\n' "$C_CYAN" "$C_RESET"
    else
        info "Installing pip via official get-pip.py bootstrap (--user scope)..."
        local tmp
        tmp="$(mktemp -t get-pip-XXXX.py)"
        # shellcheck disable=SC2064
        trap "rm -f '${tmp}'" EXIT
        download_with_retries "https://bootstrap.pypa.io/get-pip.py" "$tmp" 3 5
        "$PYTHON3" "$tmp" --user --upgrade pip setuptools wheel
    fi

    section "Verifying pip"
    "$PYTHON3" -m pip --version
    ok "pip installation complete."
}

# ─── Command: create managed venv ────────────────────────────────────────────
cmd_create_venv() {
    local name="${1:-}"
    [ -z "$name" ] && fatal "Venv name required. Usage: ${PROGNAME} --create-venv <name>"
    require_python3

    local venv_path
    venv_path="$(_venv_path "$name")"
    section "Creating virtual environment: ${name}"

    if [ -d "$venv_path" ]; then
        warn "Venv '${name}' already exists at: ${venv_path}"
        confirm "Re-create it from scratch?" || { info "Skipped."; return 0; }
        rm -rf "$venv_path"
    fi

    mkdir -p "$VENV_BASE_DIR"
    _create_venv_at "$venv_path"
    ok "Venv '${name}' created at: ${venv_path}"
    printf '\n  Activate with:\n    %bsource %s/bin/activate%b\n\n' \
        "$C_CYAN" "$venv_path" "$C_RESET"
}

# ─── Command: print activation command ───────────────────────────────────────
cmd_activate_venv() {
    local name="${1:-}"
    [ -z "$name" ] && fatal "Venv name required. Usage: ${PROGNAME} --activate-venv <name>"
    _assert_venv_exists "$name"

    section "Activation command for: ${name}"
    printf '\n  %bsource %s/bin/activate%b\n\n' \
        "$C_CYAN" "$(_venv_path "$name")" "$C_RESET"
    info "To leave the venv run: deactivate"
}

# ─── Command: list managed venvs ─────────────────────────────────────────────
cmd_list_venv() {
    section "Managed virtual environments  (${VENV_BASE_DIR})"

    if [ ! -d "$VENV_BASE_DIR" ] || [ -z "$(ls -A "$VENV_BASE_DIR" 2>/dev/null)" ]; then
        warn "No virtual environments found. Create one with: ${PROGNAME} --create-venv <name>"
        return 0
    fi

    local active_venv="${VIRTUAL_ENV:-}"
    printf '\n%-22s %-10s %-10s %s\n' "NAME" "PYTHON" "PIP" "PATH"
    printf '%0.s─' {1..80}; printf '\n'

    local venv_dir name py_ver pip_ver tag
    for venv_dir in "${VENV_BASE_DIR}"/*/; do
        [ -d "$venv_dir" ] || continue
        name="$(basename "$venv_dir")"
        py_ver="$("${venv_dir}bin/python" --version 2>&1 | awk '{print $2}')" || py_ver="?"
        pip_ver="$("${venv_dir}bin/pip"   --version 2>&1 | awk '{print $2}')" || pip_ver="?"
        tag=""
        [ "${active_venv}" = "${venv_dir%/}" ] && tag="${C_GREEN} [ACTIVE]${C_RESET}"
        printf '%b%-22s%b %-10s %-10s %s%b\n' \
            "$C_CYAN" "$name" "$C_RESET" \
            "$py_ver" "$pip_ver" "$venv_dir" "$tag"
    done
    printf '\n'
}

# ─── Command: count managed venvs ────────────────────────────────────────────
cmd_count_venv() {
    section "Virtual environment count  (${VENV_BASE_DIR})"

    if [ ! -d "$VENV_BASE_DIR" ]; then
        printf '  %b0%b virtual environments found.\n' "$C_YELLOW" "$C_RESET"
        return 0
    fi

    local count=0
    for venv_dir in "${VENV_BASE_DIR}"/*/; do
        [ -d "$venv_dir" ] && [ -f "${venv_dir}bin/activate" ] && count=$((count + 1))
    done
    printf '  %b%d%b virtual environment(s) managed under %s\n' \
        "$C_CYAN" "$count" "$C_RESET" "$VENV_BASE_DIR"
}

# ─── Command: delete managed venv ────────────────────────────────────────────
cmd_delete_venv() {
    local name="${1:-}"
    [ -z "$name" ] && fatal "Venv name required. Usage: ${PROGNAME} --delete-venv <name>"
    _assert_venv_exists "$name"

    local venv_path
    venv_path="$(_venv_path "$name")"
    [ "${VIRTUAL_ENV:-}" = "$venv_path" ] && \
        fatal "Cannot delete the currently ACTIVE venv '${name}'. Run 'deactivate' first."

    section "Delete virtual environment: ${name}"
    warn "This will permanently remove: ${venv_path}"
    confirm "Proceed with deletion?" || { info "Cancelled."; return 0; }
    rm -rf "$venv_path"
    ok "Venv '${name}' deleted."
}

# ─── Command: install packages ────────────────────────────────────────────────
cmd_install_pkg() {
    local pkgs=("$@")
    [ "${#pkgs[@]}" -eq 0 ] && fatal "No packages specified. Usage: ${PROGNAME} --install-pkg <pkg...>"
    require_python3

    if [ -n "$TARGET_VENV" ]; then
        _assert_venv_exists "$TARGET_VENV"
        section "Installing into venv '${TARGET_VENV}': ${pkgs[*]}"
        "$(_venv_pip "$TARGET_VENV")" install --upgrade "${pkgs[@]}"
    elif is_in_venv; then
        section "Installing into active venv '${VIRTUAL_ENV}': ${pkgs[*]}"
        "${VIRTUAL_ENV}/bin/pip" install --upgrade "${pkgs[@]}"
    else
        warn "No venv active and no --venv specified — using --user scope (safe)."
        section "Installing (--user scope): ${pkgs[*]}"
        "$PYTHON3" -m pip install --user "${pkgs[@]}"
    fi
    ok "Installed: ${pkgs[*]}"
}

# ─── Command: install from requirements file ─────────────────────────────────
cmd_install_reqs() {
    local reqfile="${1:-requirements.txt}"
    require_python3

    # Resolve relative paths against CWD so the user can just cd into the project.
    [[ "$reqfile" != /* ]] && reqfile="${PWD}/${reqfile}"
    [ -f "$reqfile" ] || fatal "Requirements file not found: ${reqfile}"

    local pkg_count
    pkg_count="$(grep -cE '^[^#[:space:]]' "$reqfile" 2>/dev/null || true)"

    if [ -n "$TARGET_VENV" ]; then
        _assert_venv_exists "$TARGET_VENV"
        section "Installing requirements into venv '${TARGET_VENV}'"
        info "File : ${reqfile}  (${pkg_count} packages)"
        "$(_venv_pip "$TARGET_VENV")" install -r "$reqfile"
    elif is_in_venv; then
        section "Installing requirements into active venv: ${VIRTUAL_ENV}"
        info "File : ${reqfile}  (${pkg_count} packages)"
        "${VIRTUAL_ENV}/bin/pip" install -r "$reqfile"
    else
        warn "No venv active and no --venv specified — using --user scope (safe)."
        section "Installing requirements (--user scope)"
        info "File : ${reqfile}  (${pkg_count} packages)"
        "$PYTHON3" -m pip install --user -r "$reqfile"
    fi
    ok "Requirements installed from: ${reqfile}"
}

# ─── Command: upgrade all packages ───────────────────────────────────────────
cmd_update_pkgs() {
    require_python3
    _resolve_pip_bin

    section "Upgrading all packages (${TARGET_VENV:-${VIRTUAL_ENV:-active venv}})"

    local outdated
    outdated="$("$PIP_BIN" list --outdated --format=columns 2>/dev/null \
        | awk 'NR>2 {print $1}')" || true

    if [ -z "$outdated" ]; then
        ok "All packages are already up to date."
        return 0
    fi

    info "Outdated packages:"
    "$PIP_BIN" list --outdated --format=columns

    local pkg
    while IFS= read -r pkg; do
        [ -z "$pkg" ] && continue
        step "Upgrading: ${pkg}"
        "$PIP_BIN" install --upgrade "$pkg" || warn "Could not upgrade: ${pkg}"
    done <<< "$outdated"

    ok "Package update complete."
}

# ─── Command: freeze requirements ────────────────────────────────────────────
cmd_freeze() {
    local outfile="${1:-requirements.txt}"
    require_python3

    local pip_cmd
    if [ -n "$TARGET_VENV" ]; then
        _assert_venv_exists "$TARGET_VENV"
        pip_cmd="$(_venv_pip "$TARGET_VENV")"
        section "Freezing venv '${TARGET_VENV}' → ${outfile}"
    elif is_in_venv; then
        pip_cmd="${VIRTUAL_ENV}/bin/pip"
        section "Freezing active venv '${VIRTUAL_ENV}' → ${outfile}"
    else
        warn "No venv active — freezing user-scope packages (may include unrelated deps)."
        section "Freezing user packages → ${outfile}"
        pip_cmd="$PYTHON3 -m pip"
    fi

    $pip_cmd freeze > "$outfile"
    ok "Saved $(wc -l < "$outfile") packages to: ${outfile}"
}

# ─── Command: venv info ───────────────────────────────────────────────────────
cmd_venv_info() {
    local name="${1:-}"
    section "Virtual environment info"

    if [ -n "$name" ]; then
        _assert_venv_exists "$name"
        local vpath
        vpath="$(_venv_path "$name")"
        printf '  %-12s %s\n' "Name:"   "$name"
        printf '  %-12s %s\n' "Path:"   "$vpath"
        printf '  %-12s %s\n' "Python:" "$("${vpath}/bin/python" --version 2>&1)"
        printf '  %-12s %s\n' "Pip:"    "$("${vpath}/bin/pip"    --version 2>&1)"
        printf '\n  Installed packages:\n'
        "${vpath}/bin/pip" list --format=columns 2>/dev/null || true
    else
        if is_in_venv; then
            printf '  Active venv : %b%s%b\n' "$C_GREEN" "$VIRTUAL_ENV" "$C_RESET"
        else
            warn "No venv currently active."
        fi
        cmd_list_venv
    fi
}

# ─── Command: Python REPL console ────────────────────────────────────────────
cmd_console() {
    local name="${1:-}"
    require_python3

    local py_bin
    if [ -n "$name" ]; then
        _assert_venv_exists "$name"
        py_bin="$(_venv_python "$name")"
        section "Python console — venv: ${name}"
    elif is_in_venv; then
        py_bin="${VIRTUAL_ENV}/bin/python"
        section "Python console — active venv: ${VIRTUAL_ENV}"
    else
        fatal "No venv specified and no active venv. Use: ${PROGNAME} --console <name>"
    fi

    info "Python: $("$py_bin" --version 2>&1)"
    info "Type 'exit()' or Ctrl-D to leave."
    printf '\n'
    exec "$py_bin"
}

# ─── Command: subshell with venv activated ───────────────────────────────────
cmd_shell() {
    local name="${1:-}"
    require_python3

    local venv_path
    if [ -n "$name" ]; then
        _assert_venv_exists "$name"
        venv_path="$(_venv_path "$name")"
    elif [ -n "$TARGET_VENV" ]; then
        _assert_venv_exists "$TARGET_VENV"
        venv_path="$(_venv_path "$TARGET_VENV")"
    elif _detect_project_venv; then
        venv_path="$DETECTED_VENV_PATH"
    elif is_in_venv; then
        venv_path="$VIRTUAL_ENV"
    else
        fatal "No venv found. Use --venv <name> or run from a project directory with a venv."
    fi

    _launch_venv_shell "$venv_path"
}

# ─── Full interactive menu ─────────────────────────────────────────────────────
cmd_menu() {
    require_python3
    local choice vname

    while true; do
        printf '\n%b╔══ Python & Venv Manager — %s (v%s) ══╗%b\n' \
            "${C_BOLD}${C_CYAN}" "$PROGNAME" "$SCRIPT_VERSION" "$C_RESET"
        if is_in_venv; then
            printf '%b  Active venv : %s%b\n' "$C_GREEN" "$VIRTUAL_ENV" "$C_RESET"
        else
            printf '%b  No venv active%b\n' "$C_YELLOW" "$C_RESET"
        fi

        cat <<'MENU'

  1)  Smart project — scan CWD, create or manage env
  ─────────────────────────────────────────────────
  2)  Install / upgrade pip
  3)  Create managed virtual environment
  4)  List virtual environments
  5)  Count virtual environments
  6)  Show activation command for a venv
  7)  Show venv info & package list
  8)  Delete a virtual environment
  ─────────────────────────────────────────────────
  9)  Install packages (into venv or --user)
  10) Install from requirements.txt
  11) Upgrade all packages in a venv
  12) Freeze → requirements.txt
  ─────────────────────────────────────────────────
  13) Open Python console (REPL) for a venv
  14) Open shell (bash/zsh) with venv activated
  ─────────────────────────────────────────────────
  0)  Exit

MENU
        printf '%bChoice [0-14]: %b' "$C_BOLD" "$C_RESET"
        read -r choice

        case "$choice" in
            1)
                cmd_smart_project
                ;;
            2)
                cmd_install_pip
                ;;
            3)
                printf 'New venv name: '
                read -r vname
                [ -z "$vname" ] && warn "Name cannot be empty." && continue
                cmd_create_venv "$vname"
                ;;
            4)
                cmd_list_venv
                ;;
            5)
                cmd_count_venv
                ;;
            6)
                cmd_list_venv
                printf 'Venv name to activate: '
                read -r vname
                [ -z "$vname" ] && warn "Name cannot be empty." && continue
                cmd_activate_venv "$vname"
                ;;
            7)
                printf 'Venv name for details (leave blank to list all): '
                read -r vname
                cmd_venv_info "${vname:-}"
                ;;
            8)
                cmd_list_venv
                printf 'Venv name to delete: '
                read -r vname
                [ -z "$vname" ] && warn "Name cannot be empty." && continue
                cmd_delete_venv "$vname"
                ;;
            9)
                printf 'Target venv name (leave blank for active venv / --user): '
                read -r vname
                TARGET_VENV="${vname:-}"
                printf 'Package(s) to install (space-separated): '
                IFS=' ' read -r -a _pkgs
                if [ "${#_pkgs[@]}" -eq 0 ]; then
                    warn "No packages entered."
                else
                    cmd_install_pkg "${_pkgs[@]}"
                fi
                TARGET_VENV=""
                ;;
            10)
                printf 'Requirements file path [requirements.txt]: '
                read -r _reqfile
                printf 'Target venv name (leave blank for active venv / --user): '
                read -r vname
                TARGET_VENV="${vname:-}"
                cmd_install_reqs "${_reqfile:-requirements.txt}"
                TARGET_VENV=""
                ;;
            11)
                cmd_list_venv
                printf 'Venv name to upgrade (leave blank for active venv): '
                read -r vname
                TARGET_VENV="${vname:-}"
                cmd_update_pkgs
                TARGET_VENV=""
                ;;
            12)
                printf 'Venv name (leave blank for active venv): '
                read -r vname
                TARGET_VENV="${vname:-}"
                printf 'Output file [requirements.txt]: '
                read -r _outfile
                cmd_freeze "${_outfile:-requirements.txt}"
                TARGET_VENV=""
                ;;
            13)
                cmd_list_venv
                printf 'Venv name for console (leave blank for active venv): '
                read -r vname
                cmd_console "${vname:-}"
                ;;
            14)
                cmd_list_venv
                printf 'Venv name for shell (leave blank for CWD auto-detect / active venv): '
                read -r vname
                TARGET_VENV="${vname:-}"
                cmd_shell "${vname:-}"
                TARGET_VENV=""
                ;;
            0|q|Q)
                info "Goodbye."
                exit 0
                ;;
            *)
                warn "Invalid choice '${choice}'. Enter a number 0-14."
                ;;
        esac
    done
}

# ─── Main entry point ─────────────────────────────────────────────────────────
main() {
    # Default: no args → smart project mode for CWD.
    if [ "$#" -eq 0 ]; then
        _priv_detect
        cmd_smart_project
        exit 0
    fi

    # Global flags — process before command dispatch.
    while [ $# -gt 0 ]; do
        case "$1" in
            -v|--verbose)
                VERBOSE=1
                set -x
                shift
                ;;
            --version)
                printf '%s version %s\n' "$PROGNAME" "$SCRIPT_VERSION"
                exit 0
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                break
                ;;
        esac
    done

    _priv_detect

    # Command dispatch.
    while [ "${1:-}" != "" ]; do
        case "$1" in
            --venv)
                shift
                [ -z "${1:-}" ] && fatal "--venv requires a name argument."
                TARGET_VENV="$1"
                shift
                ;;
            --project)
                cmd_smart_project
                shift
                ;;
            --install-pip)
                cmd_install_pip
                shift
                ;;
            --create-venv)
                shift
                cmd_create_venv "${1:-}"
                shift
                ;;
            --activate-venv)
                shift
                cmd_activate_venv "${1:-}"
                shift
                ;;
            --list-venv)
                cmd_list_venv
                shift
                ;;
            --count-venv)
                cmd_count_venv
                shift
                ;;
            --delete-venv)
                shift
                cmd_delete_venv "${1:-}"
                shift
                ;;
            --install-pkg)
                shift
                _pkgs=()
                while [ "${1:-}" != "" ] && [[ "$1" != --* ]]; do
                    _pkgs+=("$1"); shift
                done
                cmd_install_pkg "${_pkgs[@]}"
                ;;
            --install-reqs)
                shift
                _reqs_file="${1:-}"
                if [ -n "$_reqs_file" ] && [[ "$_reqs_file" != --* ]]; then
                    cmd_install_reqs "$_reqs_file"
                    shift
                else
                    cmd_install_reqs "requirements.txt"
                fi
                ;;
            --update-pkgs)
                cmd_update_pkgs
                shift
                ;;
            --freeze)
                shift
                _freeze_file="${1:-}"
                if [ -n "$_freeze_file" ] && [[ "$_freeze_file" != --* ]]; then
                    cmd_freeze "$_freeze_file"
                    shift
                else
                    cmd_freeze "requirements.txt"
                fi
                ;;
            --venv-info)
                shift
                _info_name="${1:-}"
                if [ -n "$_info_name" ] && [[ "$_info_name" != --* ]]; then
                    cmd_venv_info "$_info_name"
                    shift
                else
                    cmd_venv_info ""
                fi
                ;;
            --console)
                shift
                _console_name="${1:-}"
                if [ -n "$_console_name" ] && [[ "$_console_name" != --* ]]; then
                    cmd_console "$_console_name"
                    shift
                else
                    cmd_console ""
                fi
                ;;
            --shell)
                shift
                _shell_name="${1:-}"
                if [ -n "$_shell_name" ] && [[ "$_shell_name" != --* ]]; then
                    cmd_shell "$_shell_name"
                    shift
                else
                    cmd_shell ""
                fi
                ;;
            --menu)
                cmd_menu
                exit 0
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                fatal "Unknown command: '$1'. Run '${PROGNAME} --help' for usage."
                ;;
        esac
    done

    exit 0
}

# Privilege detection for apt-get calls (extracted so both paths can call it).
_priv_detect() {
    if [ "$(id -u)" -ne 0 ]; then
        command_exists sudo && SUDO_CMD="sudo" || \
            warn "sudo not found — operations requiring root may fail."
    fi
}

main "$@"
