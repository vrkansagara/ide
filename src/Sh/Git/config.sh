#!/usr/bin/env bash
# ==============================================================================
# config.sh — Git global configuration provisioner (aliases, signing, settings)
# ==============================================================================
# Maintainer : Vallabhdas Kansagara <vrkansagara@gmail.com> — @vrkansagara
# Version    : 2.0.0

set -o errexit
set -o pipefail
set -o nounset

readonly VERSION="2.0.0"
readonly PROGNAME="${0##*/}"
VERBOSE=0
SUDO_CMD=""

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

info()    { printf '%b[INFO]  %s%b\n' "$C_GREEN"  "$*" "$C_RESET"; }
warn()    { printf '%b[WARN]  %s%b\n' "$C_YELLOW" "$*" "$C_RESET"; }
fatal()   { printf '%b[FATAL] %s%b\n' "$C_RED"    "$*" "$C_RESET" >&2; exit 1; }
ok()      { printf '%b[OK]    %s%b\n' "$C_GREEN"  "$*" "$C_RESET"; }
log()     { [ "$VERBOSE" -ne 0 ] && printf '[DEBUG] %s\n' "$*" || true; }
section() { printf '\n%b=== %s ===%b\n' "${C_BOLD}${C_CYAN}" "$*" "$C_RESET"; }

# -------------------------------------------------------------------------
#  Maintainer :- Vallabhdas Kansagara <vrkansagara@gmail.com> — @vrkansagara
# -------------------------------------------------------------------------

usage() {
    cat <<EOF
Usage: ${PROGNAME} [OPTIONS]

  Provision global Git configuration: install dependencies (gnupg2, git-flow),
  back up any existing ~/.gitconfig, apply settings (commit signing, editor,
  diff/merge tools, aliases, profile switching), and generate ~/.gitignore.

Options:
  -v, --verbose   Enable verbose/debug output
  --version       Print version and exit
  -h, --help      Show this help message
EOF
}

_run() {
    if [ -n "$SUDO_CMD" ]; then "$SUDO_CMD" "$@"; else "$@"; fi
}

parse_args() {
    while [ $# -gt 0 ]; do
        case "$1" in
            -v|--verbose)
                VERBOSE=1
                set -x
                shift
                ;;
            --version)
                printf '%s\n' "$VERSION"
                exit 0
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                fatal "Unknown option: $1"
                ;;
        esac
    done
}

main() {
    parse_args "$@"

    if [ "$(id -u)" -ne 0 ]; then
        command -v sudo >/dev/null 2>&1 && SUDO_CMD="sudo" || warn "sudo not found."
    fi

    # -------------------------------------------------
    # Script directory (safe)
    # -------------------------------------------------
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    cd "$SCRIPT_DIR"

    info "Running Git Agent Provisioner"
    info "Working directory: ${SCRIPT_DIR}"

    # -------------------------------------------------------------------------
    # Install Dependencies
    # -------------------------------------------------------------------------
    section "Installing dependencies"
    if [[ "$(uname -s)" == "Darwin" ]]; then
        if ! command -v brew >/dev/null 2>&1; then
            fatal "Homebrew not found. Install from https://brew.sh"
        fi
        brew install gnupg git-flow zsh-completions
    else
        export DEBIAN_FRONTEND=noninteractive
        _run apt-get update -y
        _run apt-get install --no-install-recommends -y \
            gnupg2 \
            git-flow \
            ca-certificates
    fi

    # -------------------------------------------------------------------------
    # Backup existing global gitconfig
    # -------------------------------------------------------------------------
    section "Backing up existing gitconfig"
    if [[ -f "$HOME/.gitconfig" ]]; then
        TS="$(date +%Y%m%d%H%M%S)"
        info "Backing up ~/.gitconfig -> ~/.gitconfig.backup.${TS}"
        mv "$HOME/.gitconfig" "$HOME/.gitconfig.backup.${TS}"
    fi

    # -------------------------------------------------------------------------
    # Git configuration
    # -------------------------------------------------------------------------
    section "Applying Git configuration"
    info "Applying Git configuration ($(date))..."

    add_config() {
        local name key value

        if [ "$#" -ne 3 ]; then
            warn "Usage: add_config <alias> <config.key> <value>" >&2
            return 1
        fi

        name="$1"
        key="$2"
        value="$3"

        # Escape value safely for git alias
        value=${value//\"/\\\"}

        git config --global alias."$name" \
            "config --global $key \"$value\""
    }


    git config --global commit.gpgsign true
    git config --global core.editor "vim"
    git config --global core.excludesFile "$HOME/.gitignore"
    git config --global core.fileMode false
    git config --global credential.helper "store"   # plaintext storage
    git config --global diff.tool "vimdiff"
    git config --global gpg.program "gpg"
    git config --global help.autocorrect 0
    git config --global http.postBuffer 524288000
    git config --global init.defaultBranch main
    git config --global merge.conflictstyle diff3
    git config --global merge.tool "vimdiff"
    git config --global mergetool.prompt false
    git config --global pull.rebase false
    git config --global url."https://".insteadOf "git://"
    git config --global user.name "Vallabhdas Kansagara"
    git config --global user.signingkey "8BA6E7ABD8112B3E"

    # Warn if GPG key is missing
    if ! gpg --list-secret-keys 8BA6E7ABD8112B3E >/dev/null 2>&1; then
        warn "GPG key 8BA6E7ABD8112B3E not found locally"
    fi

    # Profile switching
    add_config personal user.email vrkansagara@gmail.com
    add_config work user.email v.kansagara@easternenterprise.com

    # -------------------------------------------------------------------------
    # Git aliases (cleaned & safe)
    # -------------------------------------------------------------------------
    section "Configuring Git aliases"

    add_alias() {
        git config --global alias."$1" "$2"
    }

    add_alias add-unmerged '!git diff --name-only --diff-filter=U | xargs -r git add'

    add_alias br 'branch'

    add_alias cam 'commit -a -m'
    add_alias cas 'commit -a -s'
    add_alias casm 'commit -a -s -m'
    add_alias cb 'checkout -b'
    add_alias cf 'config --list'
    add_alias ci 'commit'
    add_alias cm 'commit -m'
    add_alias co 'checkout'
    add_alias conflicts 'diff --name-only --diff-filter=U'
    add_alias cs 'commit -S -v'
    add_alias csm 'commit -s -m'
    add_alias current 'rev-parse --verify HEAD'

    add_alias dv 'difftool -t vimdiff -y'

    add_alias edit-unmerged '!git diff --name-only --diff-filter=U | xargs -r vim'

    add_alias fa 'fetch --all'

    add_alias gb 'branch'
    add_alias gba 'branch -a'
    add_alias gbd 'branch -d'
    add_alias gbr 'branch --remote'
    add_alias gcSignature 'log -1 --show-signature'

    # FIXED: gc alias (no recursion)
    # immediately expires all reflog entries and then runs an aggressive garbage collection to reclaim maximum disk space
    add_alias gc '!git reflog expire --expire=now --all && git gc --prune=now --aggressive'

    add_alias gca 'commit -v -a'
    add_alias gcaF 'commit -v -a --amend'
    add_alias gcanF 'commit -v -a --no-edit --amend'
    add_alias gcansF 'commit -v -a -s --no-edit --amend'
    add_alias gcnF 'commit -v --no-edit --amend'

    add_alias lga 'log --graph --max-count=10'
    add_alias lg 'log --stat'
    add_alias lgg 'log --graph'
    add_alias lgga 'log --graph --decorate --all'
    add_alias ll 'log --oneline'
    add_alias log 'log --oneline --decorate --graph'
    add_alias loga 'log --oneline --decorate --graph --all'

    add_alias p 'push'
    add_alias pd 'push --dry-run'
    add_alias pf 'push --force'
    add_alias pfwl 'push --force-with-lease'
    add_alias pofwl 'push -u origin HEAD --force-with-lease'
    add_alias pr 'pull --rebase'

    add_alias rv 'remote -v'

    add_alias sb 'status -sb'
    add_alias st 'status -sb'
    add_alias ss 'status --short'

    # Stash aliases (shell-safe)
    add_alias stashAdd '!sh -c "git stash push -m \"Save at - $(date +%Y%m%d%H%M%S)\""'
    add_alias stashApply 'stash apply stash@{0}'
    add_alias stashList 'stash list'

    add_alias undo 'reset --soft HEAD~1'
    add_alias unstage 'reset HEAD --'


    # -------------------------------------------------------------------------
    # Global Gitignore
    # -------------------------------------------------------------------------
    section "Generating global gitignore"
    if [[ -f ".gitignore" ]]; then
        info "Generating ~/.gitignore..."
        sed 's/\r//' ".gitignore" | sort -u > "$HOME/.gitignore"
    fi

    ok "Git configuration completed successfully."
    exit 0
}

main "$@"
