#!/usr/bin/env bash
# ==============================================================================
# python3.sh — Enterprise-grade Python pip installer and venv manager
# ==============================================================================
# Maintainer : Vallabhdas Kansagara <vrkansagara@gmail.com> — @vrkansagara
# Version    : 2.0.0
#
# Description: Safe Python pip installation and virtual environment management.
#              NEVER modifies or breaks system Python packages.
#              Default behaviour (no args): show help.
#
# Reference patterns taken from:
#   - nodejs.sh  (multi-mode dispatch, download_with_retries, nounset guards)
#   - pip.sh     (pip bootstrap via get-pip.py, apt integration)

set -o errexit
set -o pipefail
set -o nounset

# Use SCRIPT_VERSION (not VERSION) to avoid collisions with sourced scripts.
readonly SCRIPT_VERSION="2.0.0"
readonly PROGNAME="${0##*/}"
VERBOSE=0
SUDO_CMD=""

# Directory where all managed venvs are stored.
readonly VENV_BASE_DIR="${HOME}/.venvs"

# Resolved at runtime by require_python3.
PYTHON3=""

# Optional venv target (set by --venv <name>).
TARGET_VENV=""

# ─── Colors ──────────────────────────────────────────────────────────────────
_init_colors() {
    if [ -t 1 ] && command -v tput >/dev/null 2>&1; then
        C_RESET="$(tput sgr0   2>/dev/null || printf '')"; C_GREEN="$(tput setaf 2 2>/dev/null || printf '')"
        C_YELLOW="$(tput setaf 3 2>/dev/null || printf '')"; C_RED="$(tput setaf 1 2>/dev/null || printf '')"
        C_CYAN="$(tput setaf 6  2>/dev/null || printf '')"; C_BOLD="$(tput bold   2>/dev/null || printf '')"
        C_MAGENTA="$(tput setaf 5 2>/dev/null || printf '')"
    else
        C_RESET=''; C_GREEN=''; C_YELLOW=''; C_RED=''; C_CYAN=''; C_BOLD=''; C_MAGENTA=''
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

${C_BOLD}Description:${C_RESET}
  Enterprise-grade Python pip installer and virtual environment manager.
  NEVER modifies or breaks system Python packages.

${C_BOLD}Commands:${C_RESET}
  --install-pip              Install/upgrade pip safely (user scope or venv)
  --create-venv  <name>      Create a new virtual environment in ${VENV_BASE_DIR}/
  --activate-venv <name>     Print the source command to activate a venv
  --list-venv                List all managed virtual environments
  --delete-venv  <name>      Delete a managed virtual environment (with confirm)
  --install-pkg  <pkg...>    Install package(s) into active venv or --user scope
  --update-pkgs              Upgrade all packages in the current/target venv
  --freeze      [file]       Freeze packages to requirements.txt (default name)
  --venv-info   [name]       Show details of a specific or all venvs
  --menu                     Launch the interactive venv management menu

${C_BOLD}Modifiers (must precede the command they target):${C_RESET}
  --venv <name>              Target a specific venv for --install-pkg / --update-pkgs / --freeze

${C_BOLD}Global options:${C_RESET}
  -v, --verbose              Enable verbose/debug output (set -x)
  --version                  Print version and exit
  -h, --help                 Show this help (also the default when no args given)

${C_BOLD}Safety guarantees:${C_RESET}
  - pip is never run globally as root without explicit apt-based system install
  - System Python packages are never removed or overwritten
  - Bare pip installs always use --user scope when outside a venv
  - Debian/Ubuntu externally-managed-environment is respected via apt
  - Venv deletion requires interactive confirmation

${C_BOLD}Examples:${C_RESET}
  ${PROGNAME} --install-pip
  ${PROGNAME} --create-venv myproject
  ${PROGNAME} --activate-venv myproject
  ${PROGNAME} --install-pkg requests flask
  ${PROGNAME} --venv myproject --install-pkg django gunicorn
  ${PROGNAME} --venv myproject --update-pkgs
  ${PROGNAME} --venv myproject --freeze requirements.txt
  ${PROGNAME} --menu
EOF
}

# ─── Shared helpers ───────────────────────────────────────────────────────────
_run() {
    if [ -n "$SUDO_CMD" ]; then "$SUDO_CMD" "$@"; else "$@"; fi
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

require_python3() {
    [ -n "$PYTHON3" ] && return 0
    PYTHON3="$(command -v python3 || true)"
    [ -z "$PYTHON3" ] && fatal "python3 not found in PATH. Install Python 3 first."
    log "Using Python: ${PYTHON3} ($("$PYTHON3" --version 2>&1))"
}

is_in_venv() {
    [ -n "${VIRTUAL_ENV:-}" ]
}

# Detect Debian/Ubuntu PEP-668 externally-managed-environment restriction.
# Checks for the EXTERNALLY-MANAGED marker file in the stdlib directory,
# which is the canonical method described in PEP 668.
is_externally_managed() {
    local stdlib_path
    stdlib_path="$("$PYTHON3" -c \
        "import sysconfig; print(sysconfig.get_path('stdlib'))" 2>/dev/null || true)"
    [ -n "$stdlib_path" ] && [ -f "${stdlib_path}/EXTERNALLY-MANAGED" ]
}

# Retry-capable downloader (pattern from nodejs.sh).
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

# ─── Venv path helpers ────────────────────────────────────────────────────────
_venv_path()   { printf '%s/%s' "$VENV_BASE_DIR" "$1"; }
_venv_python() { printf '%s/%s/bin/python' "$VENV_BASE_DIR" "$1"; }
_venv_pip()    { printf '%s/%s/bin/pip'    "$VENV_BASE_DIR" "$1"; }

_assert_venv_exists() {
    local name="$1"
    local vpath
    vpath="$(_venv_path "$name")"
    [ -d "$vpath" ] && [ -f "${vpath}/bin/activate" ] || \
        fatal "Venv '${name}' not found at ${vpath}. Create it with: ${PROGNAME} --create-venv ${name}"
}

# Resolve which pip binary to use: venv > active venv > fatal.
# Writes result into global PIP_BIN (avoids subshell).
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

PIP_BIN=""

# ─── Command: install pip ─────────────────────────────────────────────────────
cmd_install_pip() {
    require_python3
    section "Installing / upgrading pip"

    # ── Step 1: apt-based systems — install via the system package manager ──
    # This is the only safe method on Debian/Ubuntu with PEP-668 enforcement.
    if command_exists apt-get; then
        info "apt-based system detected — installing python3-pip, python3-venv via apt..."
        _run apt-get install -y python3-pip python3-venv python3-setuptools
        ok "System pip packages installed via apt."
    fi

    # ── Step 2: active venv — safe to upgrade pip directly ─────────────────
    if is_in_venv; then
        info "Active venv detected — upgrading pip inside venv..."
        "$PYTHON3" -m pip install --upgrade pip setuptools wheel

    # ── Step 3: PEP-668 externally-managed system — do NOT run get-pip.py ──
    # Running pip install (even --user) outside a venv is blocked by
    # /usr/lib/python3.x/EXTERNALLY-MANAGED on Debian/Ubuntu 23.04+.
    # The system pip from apt is sufficient; users should work inside venvs.
    elif is_externally_managed; then
        warn "Externally-managed environment detected (PEP 668 / Debian policy)."
        info "System pip is managed by apt — get-pip.py bootstrap is not needed."
        info "To install third-party packages, use a virtual environment:"
        printf '    %b%s --create-venv <name>%b\n' "$C_CYAN" "$PROGNAME" "$C_RESET"
        info "For standalone CLI tools, pipx is recommended:"
        printf '    %bapt install pipx && pipx install <app>%b\n' "$C_CYAN" "$C_RESET"

    # ── Step 4: non-managed system — bootstrap pip with --user scope ────────
    else
        info "Installing pip via official get-pip.py bootstrap (--user scope)..."
        local tmp
        tmp="$(mktemp -t get-pip-XXXX.py)"
        # SC2064: intentional — expand $tmp NOW so path is baked into the trap.
        # shellcheck disable=SC2064
        trap "rm -f '${tmp}'" EXIT

        download_with_retries "https://bootstrap.pypa.io/get-pip.py" "$tmp" 3 5

        # --user installs into ~/.local — never touches /usr system paths.
        "$PYTHON3" "$tmp" --user --upgrade pip setuptools wheel
    fi

    section "Verifying pip"
    "$PYTHON3" -m pip --version
    ok "pip installation complete."
}

# ─── Command: create venv ─────────────────────────────────────────────────────
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

    if "$PYTHON3" -m venv --help >/dev/null 2>&1; then
        "$PYTHON3" -m venv "$venv_path"
    elif command_exists virtualenv; then
        virtualenv "$venv_path"
    else
        fatal "Neither 'venv' module nor 'virtualenv' command is available. " \
              "Run: ${PROGNAME} --install-pip  or  apt-get install python3-venv"
    fi

    step "Upgrading pip/setuptools/wheel inside new venv..."
    "${venv_path}/bin/python" -m pip install --quiet --upgrade pip setuptools wheel

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

# ─── Command: list venvs ──────────────────────────────────────────────────────
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
        # Strip trailing slash for comparison
        [ "${active_venv}" = "${venv_dir%/}" ] && tag="${C_GREEN} [ACTIVE]${C_RESET}"
        printf '%b%-22s%b %-10s %-10s %s%b\n' \
            "$C_CYAN" "$name" "$C_RESET" \
            "$py_ver" "$pip_ver" "$venv_dir" "$tag"
    done
    printf '\n'
}

# ─── Command: delete venv ─────────────────────────────────────────────────────
cmd_delete_venv() {
    local name="${1:-}"
    [ -z "$name" ] && fatal "Venv name required. Usage: ${PROGNAME} --delete-venv <name>"
    _assert_venv_exists "$name"

    local venv_path
    venv_path="$(_venv_path "$name")"

    if [ "${VIRTUAL_ENV:-}" = "$venv_path" ]; then
        fatal "Cannot delete the currently ACTIVE venv '${name}'. Run 'deactivate' first."
    fi

    section "Delete virtual environment: ${name}"
    warn "This will permanently remove: ${venv_path}"
    confirm "Proceed with deletion?" || { info "Cancelled."; return 0; }

    rm -rf "$venv_path"
    ok "Venv '${name}' deleted."
}

# ─── Command: install packages ────────────────────────────────────────────────
cmd_install_pkg() {
    # $@: package names (already stripped of the --install-pkg token by caller)
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

# ─── Command: upgrade all packages in a venv ──────────────────────────────────
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

# ─── Interactive menu ─────────────────────────────────────────────────────────
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

  1)  Install / upgrade pip
  2)  Create virtual environment
  3)  List virtual environments
  4)  Show activation command for a venv
  5)  Install packages (into venv or --user)
  6)  Upgrade all packages in a venv
  7)  Show venv info & package list
  8)  Freeze requirements.txt
  9)  Delete a virtual environment
  0)  Exit

MENU
        printf '%bChoice [0-9]: %b' "$C_BOLD" "$C_RESET"
        read -r choice

        case "$choice" in
            1)
                cmd_install_pip
                ;;
            2)
                printf 'New venv name: '
                read -r vname
                [ -z "$vname" ] && warn "Name cannot be empty." && continue
                cmd_create_venv "$vname"
                ;;
            3)
                cmd_list_venv
                ;;
            4)
                cmd_list_venv
                printf 'Venv name to activate: '
                read -r vname
                [ -z "$vname" ] && warn "Name cannot be empty." && continue
                cmd_activate_venv "$vname"
                ;;
            5)
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
            6)
                cmd_list_venv
                printf 'Venv name to upgrade (leave blank for active venv): '
                read -r vname
                TARGET_VENV="${vname:-}"
                cmd_update_pkgs
                TARGET_VENV=""
                ;;
            7)
                printf 'Venv name for details (leave blank to list all): '
                read -r vname
                cmd_venv_info "${vname:-}"
                ;;
            8)
                printf 'Venv name (leave blank for active venv): '
                read -r vname
                TARGET_VENV="${vname:-}"
                printf 'Output file [requirements.txt]: '
                read -r _outfile
                cmd_freeze "${_outfile:-requirements.txt}"
                TARGET_VENV=""
                ;;
            9)
                cmd_list_venv
                printf 'Venv name to delete: '
                read -r vname
                [ -z "$vname" ] && warn "Name cannot be empty." && continue
                cmd_delete_venv "$vname"
                ;;
            0|q|Q)
                info "Goodbye."
                exit 0
                ;;
            *)
                warn "Invalid choice '${choice}'. Enter a number 0-9."
                ;;
        esac
    done
}

# ─── Main entry point ─────────────────────────────────────────────────────────
main() {
    # Default: show help when invoked with no arguments.
    if [ "$#" -eq 0 ]; then
        usage
        exit 0
    fi

    # ── Global flags (process first, before mode dispatch) ──
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

    # ── Privilege detection (for apt-get calls) ──
    if [ "$(id -u)" -ne 0 ]; then
        command_exists sudo && SUDO_CMD="sudo" || \
            warn "sudo not found — operations requiring root may fail."
    fi

    # ── Command dispatch ──
    while [ "${1:-}" != "" ]; do
        case "$1" in
            # ── Modifier: target venv ──────────────────────────────────────
            --venv)
                shift
                [ -z "${1:-}" ] && fatal "--venv requires a name argument."
                TARGET_VENV="$1"
                shift
                ;;

            # ── Commands ──────────────────────────────────────────────────
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
            --delete-venv)
                shift
                cmd_delete_venv "${1:-}"
                shift
                ;;
            --install-pkg)
                shift
                # Collect all non-flag tokens as package names.
                _pkgs=()
                while [ "${1:-}" != "" ] && [[ "$1" != --* ]]; do
                    _pkgs+=("$1")
                    shift
                done
                cmd_install_pkg "${_pkgs[@]}"
                ;;
            --update-pkgs)
                cmd_update_pkgs
                shift
                ;;
            --freeze)
                shift
                # Optional filename argument.
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

main "$@"
