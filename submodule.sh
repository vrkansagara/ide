#!/usr/bin/env bash
# ==============================================================================
# submodule.sh — Vim plugin manager via git submodules (idempotent setup)
# ==============================================================================
# Maintainer : Vallabhdas Kansagara <vrkansagara@gmail.com> — @vrkansagara
# Version    : 2.0.0
#
#  Purpose    : Idempotent setup and update of Vim plugins via git submodules.
#
#  Usage: ./submodule.sh [OPTIONS]
#
#  Modes (mutually exclusive; default is --install):
#    --install     Add any missing submodules and initialise all  (default)
#    --update      Pull the latest upstream commit for every submodule
#    --clean       Remove all plugin submodules, then re-install from scratch
#
#  Options:
#    -v, --verbose   Enable verbose output (set -x)
#    -n, --dry-run   Print commands without executing them
#    --jobs N        Parallel jobs for submodule update (default: 4)
#    -h, --help      Show this help
# ==============================================================================

set -o errexit
set -o pipefail
set -o nounset

# ------------------------------------------------------------------------------
# Constants + state
# ------------------------------------------------------------------------------
readonly VERSION="2.0.0"
readonly PROGNAME="${0##*/}"
readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly SCRIPT_VERSION="2.0.0"
readonly VIM_DIR="${HOME}/.vim"
readonly PACK_DIR="${VIM_DIR}/pack"
readonly LOG_FILE="/tmp/vim-submodule-$$.log"
readonly GITMODULES="${VIM_DIR}/.gitmodules"

VERBOSE=0
SUDO_CMD=""

# ------------------------------------------------------------------------------
# Plugin registry  (url  dest-path-relative-to-VIM_DIR)
# ------------------------------------------------------------------------------
# Plugin list uses declare -a (bash array) — [[ ]] is required here for
# bash array syntax; this is intentional and exempt from the [ ] rule.
declare -a PLUGINS=(
  # Core plugins
  "https://github.com/junegunn/fzf.git                         pack/vendor/start/fzf"
  "https://github.com/junegunn/fzf.vim.git                     pack/vendor/start/fzf.vim"
  "https://github.com/tpope/vim-commentary.git                 pack/vendor/start/vim-commentary"
  "https://github.com/mg979/vim-visual-multi.git               pack/vendor/start/vim-visual-multi"
  "https://github.com/tpope/vim-surround.git                   pack/vendor/start/vim-surround"
  "https://github.com/tpope/vim-fugitive.git                   pack/vendor/start/vim-fugitive"
  "https://github.com/ctrlpvim/ctrlp.vim.git                   pack/vendor/start/ctrlp"
  "https://github.com/mileszs/ack.vim.git                      pack/vendor/start/ack"
  "https://github.com/airblade/vim-gitgutter.git               pack/vendor/start/vim-gitgutter"
  "https://github.com/vim-airline/vim-airline.git              pack/vendor/start/vim-airline"
  "https://github.com/vim-airline/vim-airline-themes.git       pack/vendor/start/vim-airline-themes"
  "https://github.com/arnaud-lb/vim-php-namespace.git          pack/vendor/start/vim-php-namespace"
  "https://github.com/preservim/nerdtree.git                   pack/vendor/start/nerdtree"
  "https://github.com/mattn/emmet-vim.git                      pack/vendor/start/emmet-vim"
  "https://github.com/tbknl/vimproject.git                     pack/vendor/start/vimproject"
  "https://github.com/rust-lang/rust.vim.git                   pack/vendor/start/rust"
  "https://github.com/kdheepak/JuliaFormatter.vim.git          pack/vendor/start/JuliaFormatter"
  "https://github.com/skywind3000/vim-quickui.git              pack/vendor/start/vim-quickui"
  # Color themes
  "https://github.com/NLKNguyen/papercolor-theme.git           pack/colors/start/papercolor-theme"
  "https://github.com/gosukiwi/vim-atom-dark.git               pack/colors/start/vim-atom-dark"
  "https://github.com/google/vim-colorscheme-primary.git       pack/colors/start/vim-colorscheme-primary"
  "https://github.com/vim-scripts/peaksea.git                  pack/colors/start/peaksea"
)

# ------------------------------------------------------------------------------
# Mutable state
# ------------------------------------------------------------------------------
MODE="install"
DRY_RUN=false
JOBS=4
COUNT_ADDED=0
COUNT_SKIPPED=0
COUNT_FAILED=0

# ------------------------------------------------------------------------------
# Color block
# ------------------------------------------------------------------------------
_init_colors() {
    if [ -t 1 ] && command -v tput >/dev/null 2>&1; then
        C_RESET="$(tput sgr0   2>/dev/null || printf '')"; C_GREEN="$(tput setaf 2 2>/dev/null || printf '')"
        C_YELLOW="$(tput setaf 3 2>/dev/null || printf '')"; C_RED="$(tput setaf 1 2>/dev/null || printf '')"
        C_CYAN="$(tput setaf 6  2>/dev/null || printf '')"; C_BOLD="$(tput bold   2>/dev/null || printf '')"
    else
        C_RESET=''; C_GREEN=''; C_YELLOW=''; C_RED=''; C_CYAN=''; C_BOLD=''
    fi
}
_init_colors

# ------------------------------------------------------------------------------
# Logging helpers
# ------------------------------------------------------------------------------
info()    { printf '%b[INFO]  %s%b\n' "$C_GREEN"  "$*" "$C_RESET" | tee -a "${LOG_FILE}"; }
warn()    { printf '%b[WARN]  %s%b\n' "$C_YELLOW" "$*" "$C_RESET" | tee -a "${LOG_FILE}" >&2; }
fatal()   { printf '%b[FATAL] %s%b\n' "$C_RED"    "$*" "$C_RESET" | tee -a "${LOG_FILE}" >&2; exit 1; }
ok()      { printf '%b[OK]    %s%b\n' "$C_GREEN"  "$*" "$C_RESET" | tee -a "${LOG_FILE}"; }
log()     { [ "$VERBOSE" -ne 0 ] && printf '[DEBUG] %s\n' "$*" | tee -a "${LOG_FILE}" || true; }
section() { printf '\n%b=== %s ===%b\n' "${C_BOLD}${C_CYAN}" "$*" "$C_RESET"; }

# ------------------------------------------------------------------------------
# Error trap
# ------------------------------------------------------------------------------
on_error() {
    local code=$? line="${BASH_LINENO[0]}"
    warn "Unexpected failure at line ${line} (exit ${code}). See: ${LOG_FILE}"
    print_summary
    exit "${code}"
}
trap on_error ERR

# ------------------------------------------------------------------------------
# Usage
# ------------------------------------------------------------------------------
usage() {
    grep '^#  ' "${BASH_SOURCE[0]}" | sed 's/^#  //'
}

# ------------------------------------------------------------------------------
# Sudo wrapper
# ------------------------------------------------------------------------------
_run() {
    if [ -n "$SUDO_CMD" ]; then "$SUDO_CMD" "$@"; else "$@"; fi
}

# ------------------------------------------------------------------------------
# Argument parsing
# ------------------------------------------------------------------------------
parse_args() {
    while [ $# -gt 0 ]; do
        case "$1" in
            --install)    MODE="install"; shift ;;
            --update)     MODE="update";  shift ;;
            --clean)      MODE="clean";   shift ;;
            -v|--verbose) VERBOSE=1; set -x; shift ;;
            -n|--dry-run) DRY_RUN=true; shift ;;
            --jobs)
                printf '%s' "$2" | grep -qE '^[0-9]+$' || fatal "--jobs requires a positive integer"
                JOBS="$2"; shift 2 ;;
            --version)    printf '%s v%s\n' "$PROGNAME" "$VERSION"; exit 0 ;;
            -h|--help)    usage; exit 0 ;;
            --)           shift; break ;;
            -*)           fatal "Unknown option: '$1'. Use -h for help." ;;
            *)            break ;;
        esac
    done
}

# ------------------------------------------------------------------------------
# Helpers
# ------------------------------------------------------------------------------

# Run a command or print it in dry-run mode.
run() {
    if [ "${DRY_RUN}" = "true" ]; then
        info "[DRY-RUN] $*"
        return 0
    fi
    "$@"
}

# Check whether a submodule path is already registered in .gitmodules.
is_registered() {
    local dest="$1"
    grep -qF "path = ${dest}" "${GITMODULES}" 2>/dev/null
}

# ------------------------------------------------------------------------------
# Add a single submodule (idempotent).
# ------------------------------------------------------------------------------
add_submodule() {
    local url="$1"
    local dest="$2"
    local name
    name="$(basename "${url}" .git)"

    if is_registered "${dest}"; then
        warn "  Already registered: ${name} (${dest})"
        COUNT_SKIPPED=$(( COUNT_SKIPPED + 1 ))
        return 0
    fi

    info "  Adding: ${name} -> ${dest}"
    if run git submodule add --depth=1 "${url}" "${dest}" >>"${LOG_FILE}" 2>&1; then
        ok "  Added: ${name}"
        COUNT_ADDED=$(( COUNT_ADDED + 1 ))
    else
        warn "  Failed to add: ${name} -- skipping."
        COUNT_FAILED=$(( COUNT_FAILED + 1 ))
    fi
}

# ------------------------------------------------------------------------------
# Mode: install — add missing submodules, then initialise all.
# ------------------------------------------------------------------------------
do_install() {
    info "Mode: install"

    mkdir -p "${PACK_DIR}/vendor/start" "${PACK_DIR}/colors/start"

    local entry url dest
    for entry in "${PLUGINS[@]}"; do
        read -r url dest <<< "${entry}"
        add_submodule "${url}" "${dest}"
    done

    info "Initialising and cloning submodules (jobs=${JOBS})..."
    run git submodule update --init --recursive --jobs "${JOBS}" >>"${LOG_FILE}" 2>&1
}

# ------------------------------------------------------------------------------
# Mode: update — pull the latest upstream for every submodule.
# ------------------------------------------------------------------------------
do_update() {
    info "Mode: update (fetching latest from upstream)"
    run git submodule update --init --recursive --remote --merge --jobs "${JOBS}" >>"${LOG_FILE}" 2>&1
}

# ------------------------------------------------------------------------------
# Mode: clean — deinit all submodules, wipe pack/, then re-install.
# ------------------------------------------------------------------------------
do_clean() {
    printf '%b[!]%b This will REMOVE all Vim plugin submodules and re-install from scratch.\n' \
        "${C_YELLOW}" "${C_RESET}"
    read -r -p "    Continue? [y/N]: " input
    case "${input}" in
        y|Y|yes|YES) : ;;
        *) info "Aborted."; exit 0 ;;
    esac

    warn "Deinitialising all submodules..."
    run git submodule deinit --force --all >>"${LOG_FILE}" 2>&1 || true

    warn "Removing tracked submodule paths from git index..."
    run git rm --force --cached -r pack >>"${LOG_FILE}" 2>&1 || true

    warn "Removing pack directories..."
    _run rm -rf "${PACK_DIR}"

    warn "Removing .git/modules metadata..."
    _run rm -rf "${VIM_DIR}/.git/modules"

    warn "Clearing .gitmodules..."
    if [ "${DRY_RUN}" = "false" ]; then
        : > "${GITMODULES}"
    else
        info "[DRY-RUN] > ${GITMODULES}"
    fi

    ok "Clean complete. Re-installing..."
    do_install
}

# ------------------------------------------------------------------------------
# Composer (optional, best-effort)
# ------------------------------------------------------------------------------
run_composer() {
    local composer="${VIM_DIR}/bin/composer"
    if [ ! -x "${composer}" ]; then
        warn "Composer not found at ${composer} -- skipping."
        return
    fi
    info "Running composer..."
    run "${composer}" self-update >>"${LOG_FILE}" 2>&1
    run "${composer}" install \
        --prefer-dist --no-scripts --no-progress --no-interaction --no-dev \
        >>"${LOG_FILE}" 2>&1
    ok "Composer done."
}

# ------------------------------------------------------------------------------
# Summary
# ------------------------------------------------------------------------------
print_summary() {
    printf '\n'
    printf '==============================\n'
    printf ' Summary\n'
    printf '==============================\n'
    printf '  Added   : %s\n' "${COUNT_ADDED}"
    printf '  Skipped : %s\n' "${COUNT_SKIPPED}"
    printf '  Failed  : %s\n' "${COUNT_FAILED}"
    printf '  Log     : %s\n' "${LOG_FILE}"
    printf '==============================\n'
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------
main() {
    parse_args "$@"
    if [ "$(id -u)" -ne 0 ]; then
        command -v sudo >/dev/null 2>&1 && SUDO_CMD="sudo" || warn "sudo not found."
    fi

    # Touch log file early so subsequent tee calls work.
    touch "${LOG_FILE}"

    # Must be inside the vim directory (git repo root for submodule commands).
    cd "${VIM_DIR}" || fatal "Vim directory not found: ${VIM_DIR}"

    [ -d ".git" ] || fatal "${VIM_DIR} is not a git repository."

    printf '==============================\n'
    printf ' %s v%s\n' "${SCRIPT_NAME}" "${SCRIPT_VERSION}"
    printf ' %s\n' "$(date '+%Y-%m-%d %H:%M:%S')"
    [ "${DRY_RUN}" = "true" ] && printf ' DRY-RUN -- no changes will be made.\n' || true
    printf '==============================\n'

    case "${MODE}" in
        install) do_install ;;
        update)  do_update  ;;
        clean)   do_clean   ;;
    esac

    run_composer
    print_summary
    ok "Done."
}

main "$@"
