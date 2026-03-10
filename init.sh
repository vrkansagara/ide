#!/usr/bin/env bash
# ==============================================================================
# init.sh — Bootstrap + fresh-install script for vrkansagara IDE/Vim config
# ==============================================================================
# Maintainer : Vallabhdas Kansagara <vrkansagara@gmail.com> — @vrkansagara
# Version    : 3.0.0
#
# Safe one-liner (always review before piping to sh):
#   bash <(curl -fsSL https://raw.githubusercontent.com/vrkansagara/ide/master/init.sh)
#
# Fresh install (clone + bootstrap):
#   bash <(curl -fsSL https://raw.githubusercontent.com/vrkansagara/ide/master/init.sh) --clone
#
# Features:
#   --clone         Clone repo, back up ~/.vim*, install symlinks, then bootstrap
#   --dry-run       Show what would happen, do not execute
#   --minimal       Install a reduced package set
#   --no-upgrade    Skip apt upgrade step
#   --no-packages   Skip apt package installs
#   --skip-ohmyzsh  Skip Oh My Zsh install
#   --bin-dir=DIR   Override binary install dir (default: ~/.vim/bin)
#   --force         Reinstall / overwrite existing binaries
#   --no-color      Disable ANSI colors
#   -v, --verbose   Echo every command
# ==============================================================================

set -o errexit
set -o pipefail
set -o nounset

# --------------------------------------------------------------------------
# Defaults
# --------------------------------------------------------------------------
readonly VERSION="3.0.0"
readonly PROGNAME="${0##*/}"

BIN_DIR_DEFAULT="$HOME/.vim/bin"
BIN_DIR="${BIN_DIR:-$BIN_DIR_DEFAULT}"

CLONE_MODE=0
INSTALL_PACKAGES=1
DO_UPGRADE=1
FORCE=0
DRY_RUN=0
VERBOSE=0
INSTALL_OHMYZSH=1
MINIMAL=0
COLOR="${NO_COLOR:-1}"

# --------------------------------------------------------------------------
# Colors
# --------------------------------------------------------------------------
if [[ -t 1 && $COLOR -eq 1 ]]; then
  BOLD=$'\033[1m'; RED=$'\033[31m'; YELLOW=$'\033[33m'
  GREEN=$'\033[32m'; BLUE=$'\033[34m'; CYAN=$'\033[36m'; RESET=$'\033[0m'
else
  BOLD=""; RED=""; YELLOW=""; GREEN=""; BLUE=""; CYAN=""; RESET=""
fi

# --------------------------------------------------------------------------
# Logging
# --------------------------------------------------------------------------
log()     { printf '%s\n' "$*"; }
info()    { log "${BLUE}[INFO]${RESET}  $*"; }
warn()    { log "${YELLOW}[WARN]${RESET}  $*"; }
err()     { log "${RED}[ERR ]${RESET}  $*" >&2; }
ok()      { log "${GREEN}[ OK ]${RESET}  $*"; }
fatal()   { log "${RED}[FATAL]${RESET} $*" >&2; exit 1; }
section() { printf '\n%b=== %s ===%b\n' "${BOLD}${CYAN}" "$*" "${RESET}"; }

# --------------------------------------------------------------------------
# Error trap
# --------------------------------------------------------------------------
trap 'err "Failed at line $LINENO: $BASH_COMMAND"; exit 1' ERR

# --------------------------------------------------------------------------
# Command runner (respects --dry-run and --verbose)
# --------------------------------------------------------------------------
run() {
  if (( DRY_RUN )); then
    echo "[DRY-RUN] $*"
  else
    if (( VERBOSE )); then
      echo "+ $*"
    fi
    eval "$@"
  fi
}

# --------------------------------------------------------------------------
# Usage
# --------------------------------------------------------------------------
usage() {
  cat <<EOF
Usage: $PROGNAME [OPTIONS]

Bootstrap the developer environment. With --clone, also performs a
fresh install (clone repo, back up existing config, set up symlinks).

Options:
      --clone            Fresh install: clone, backup ~/.vim*, symlinks, bootstrap
  -v, --verbose          Verbose command echo
      --dry-run          Show what would happen, do not execute
      --no-upgrade       Skip apt upgrade step
      --no-packages      Do not install apt packages
      --skip-ohmyzsh     Do not install Oh My Zsh
      --bin-dir=DIR      Override binary install dir (default: $BIN_DIR_DEFAULT)
      --force            Reinstall / overwrite existing binaries
      --minimal          Install a reduced package set
      --no-color         Disable ANSI colors
  -h, --help             Show this help

Environment overrides:
  BIN_DIR=/custom/path   (same as --bin-dir)
  NO_COLOR=1             (same as --no-color)

Examples:
  $PROGNAME --clone                        # fresh install + bootstrap
  $PROGNAME --minimal --skip-ohmyzsh       # bootstrap only, minimal packages
  BIN_DIR="\$HOME/.local/bin" $PROGNAME    # custom bin dir
EOF
}

# --------------------------------------------------------------------------
# Argument parsing
# --------------------------------------------------------------------------
for arg in "$@"; do
  case "$arg" in
    -h|--help)        usage; exit 0 ;;
    -v|--verbose)     VERBOSE=1; set -x ;;
    --clone)          CLONE_MODE=1 ;;
    --dry-run)        DRY_RUN=1 ;;
    --no-upgrade)     DO_UPGRADE=0 ;;
    --no-packages)    INSTALL_PACKAGES=0 ;;
    --skip-ohmyzsh)   INSTALL_OHMYZSH=0 ;;
    --bin-dir=*)      BIN_DIR="${arg#*=}" ;;
    --force)          FORCE=1 ;;
    --minimal)        MINIMAL=1 ;;
    --no-color)       COLOR=0 ;;
    --version)        printf '%s v%s\n' "$PROGNAME" "$VERSION"; exit 0 ;;
    *)                err "Unknown argument: $arg"; usage; exit 2 ;;
  esac
done

# --------------------------------------------------------------------------
# Preconditions
# --------------------------------------------------------------------------
if ! command -v apt-get >/dev/null 2>&1; then
  fatal "apt-get not found. This script targets Debian/Ubuntu-based systems."
fi

if [[ "$(id -u)" -ne 0 ]]; then
  SUDO="sudo"
else
  SUDO=""
fi

export DEBIAN_FRONTEND=noninteractive

# --------------------------------------------------------------------------
# Package sets
# --------------------------------------------------------------------------
BASE_PACKAGES=(
  git gitk zsh curl htop dos2unix nmap elinks arandr gufw ufw xdotool cpulimit guake vim alacarte
)

MINIMAL_PACKAGES=(
  git gitk zsh curl htop dos2unix arandr vim
)

if (( MINIMAL )); then
  PKGS=("${MINIMAL_PACKAGES[@]}")
else
  PKGS=("${BASE_PACKAGES[@]}")
fi

# --------------------------------------------------------------------------
# Helper: ensure directory exists
# --------------------------------------------------------------------------
ensure_dir() {
  local d="$1"
  if [[ ! -d "$d" ]]; then
    run "mkdir -p '$d'"
    ok "Created directory: $d"
  fi
}

# --------------------------------------------------------------------------
# Helper: download a binary with optional checksum verification
# --------------------------------------------------------------------------
download_binary() {
  local url="$1" target="$2" expect_sha="${3:-}"
  local tmp
  tmp="$(mktemp)"

  info "Downloading: $url"
  run "curl -fsSL '$url' -o '$tmp'"

  if [[ -n "$expect_sha" ]]; then
    local got
    got="$(sha256sum "$tmp" | awk '{print $1}')"
    if [[ "$got" != "$expect_sha" ]]; then
      rm -f "$tmp"
      fatal "Checksum mismatch for $target (expected $expect_sha got $got)"
    fi
  fi

  run "chmod +x '$tmp'"
  run "mv '$tmp' '$target'"
  ok "Installed $(basename "$target") -> $target"
}

# --------------------------------------------------------------------------
# Helper: install a binary, skip if already present (unless --force)
# --------------------------------------------------------------------------
install_or_skip_binary() {
  local name="$1" path="$2" url="$3" checksum="${4:-}" test_cmd="${5:-}"

  if [[ -x "$path" && $FORCE -eq 0 ]]; then
    if [[ -n "$test_cmd" ]]; then
      if eval "$path $test_cmd" >/dev/null 2>&1; then
        ok "$name already present ($path)"
        return
      else
        warn "$name present but test command failed; reinstalling."
      fi
    else
      ok "$name already present ($path)"
      return
    fi
  fi

  download_binary "$url" "$path" "$checksum"
}

# --------------------------------------------------------------------------
# Phase 1 (--clone): Clone repo, backup, install symlinks
# --------------------------------------------------------------------------
clone_and_install() {
  section "Fresh install: clone vrkansagara/ide"

  local CURRENT_DATE
  CURRENT_DATE="$(date '+%Y%m%d%H%M%S')"

  local BACKUP_DIR="${HOME}/.old/vim-${CURRENT_DATE}"
  local CLONE_DIR="/tmp/.vim-${CURRENT_DATE}"

  info "Backup dir  : $BACKUP_DIR"
  info "Clone target: $CLONE_DIR"

  ensure_dir "$BACKUP_DIR"

  section "Cloning repository"
  run "git clone --recursive --branch master --depth 1 \
    https://github.com/vrkansagara/ide.git '$CLONE_DIR'"

  section "Backing up existing ~/.vim*"
  if ls "${HOME}"/.vim* >/dev/null 2>&1; then
    info "Moving existing ~/.vim* to $BACKUP_DIR"
    run "mv -f \"\${HOME}\"/.vim* '$BACKUP_DIR'" 2>/dev/null || true
  else
    info "No existing ~/.vim* found — nothing to back up."
  fi

  section "Installing vim configuration"
  run "mv '$CLONE_DIR' '$HOME/.vim'"
  ensure_dir "$HOME/.vim/pack/vendor/start/"
  run "rm -rf '$HOME/.vim/pack/'*"
  run "sh '$HOME/.vim/submodule.sh'"

  section "Setting up symbolic links"
  run "mv \"\${HOME}/.zshrc\" /tmp/.zshrc.pre-ide 2>/dev/null || true"
  run "mv \"\${HOME}/.vimrc\"  /tmp/.vimrc.pre-ide  2>/dev/null || true"
  run "mv \"\${HOME}/.bashrc\" /tmp/.bashrc.pre-ide 2>/dev/null || true"
  run "mv '$HOME/.vim/coc-settings.dist.json' '$HOME/.vim/coc-settings.json' 2>/dev/null || true"

  run "ln -sf '$HOME/.vim/src/Dotfiles/zshrc'  '$HOME/.zshrc'"
  run "ln -sf '$HOME/.vim/vimrc.vim'            '$HOME/.vimrc'"
  run "ln -sf '$HOME/.vim/src/Dotfiles/bashrc'  '$HOME/.bashrc'"
  run "ln -sf '$HOME/.vim/src/Sh/Git/hooks/pre-commit' '$HOME/.vim/.git/hooks/pre-commit'"

  ensure_dir "$HOME/.vim/data/cache"

  section "Setting permissions"
  run "chmod -R +x '$HOME/.vim/src/Sh/'* '$HOME/.vim/bin'"

  ok "Repository cloned and symlinks configured."
}

# --------------------------------------------------------------------------
# Phase 2: System bootstrap
# --------------------------------------------------------------------------
update_system() {
  section "Updating package lists"
  run "$SUDO apt-get update -y"

  if (( DO_UPGRADE )); then
    info "Upgrading system"
    run "$SUDO apt-get upgrade -y -V"
  else
    warn "Skipping system upgrade (--no-upgrade)"
  fi

  info "Fixing broken dependencies (if any)"
  run "$SUDO apt-get install -f -y"

  info "Removing unused packages"
  run "$SUDO apt-get autoremove -y"

  info "Cleaning apt cache"
  run "$SUDO apt-get clean"
}

install_packages() {
  section "Installing packages"
  if (( INSTALL_PACKAGES )); then
    info "Packages: ${PKGS[*]}"
    run "$SUDO apt-get install -y ${PKGS[*]}"
  else
    warn "Skipping package install (--no-packages)"
  fi
}

install_ohmyzsh() {
  section "Oh My Zsh"
  if (( INSTALL_OHMYZSH == 0 )); then
    warn "Skipping Oh My Zsh (--skip-ohmyzsh)"
    return
  fi

  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    ok "Oh My Zsh already installed."
  else
    info "Installing Oh My Zsh (unattended)"
    run "export RUNZSH=no CHSH=yes KEEP_ZSHRC=yes; \
      sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""
  fi

  local zpath
  zpath="$(command -v zsh || true)"
  if [[ -n "$zpath" && "$SHELL" != "$zpath" ]]; then
    info "Switching default shell to $zpath"
    run "chsh -s '$zpath' $(id -un)"
  fi
}

install_binaries() {
  section "Installing user-level binaries into $BIN_DIR"

  install_or_skip_binary \
    "jq" \
    "$BIN_DIR/jq" \
    "https://github.com/stedolan/jq/releases/latest/download/jq-linux64" \
    "" "--version"

  install_or_skip_binary \
    "JMESPath (jp)" \
    "$BIN_DIR/JMESPath" \
    "https://github.com/jmespath/jp/releases/latest/download/jp-linux-amd64" \
    "" "--help"

  if [[ -x "$BIN_DIR/jq" ]]; then
    echo '{"foo": 0}' | "$BIN_DIR/jq" . >/dev/null 2>&1 && ok "jq smoke test OK" || warn "jq smoke test failed"
  fi
  if [[ -x "$BIN_DIR/JMESPath" ]]; then
    echo '{"a": "foo"}' | "$BIN_DIR/JMESPath" a >/dev/null 2>&1 && ok "JMESPath smoke test OK" || warn "JMESPath smoke test failed"
  fi

  run "chmod -f +x '$BIN_DIR'/* || true"
}

ensure_path_notice() {
  case ":$PATH:" in
    *":$BIN_DIR:"*) : ;;
    *)
      warn "BIN_DIR ($BIN_DIR) is not in PATH. Add to your shell profile:"
      echo "  export PATH=\"$BIN_DIR:\$PATH\""
      ;;
  esac
}

prevents_tampering() {
  run "$SUDO chattr +i '$HOME/.vim/.claude/settings.local.json' 2>/dev/null || true"
}

# --------------------------------------------------------------------------
# Main
# --------------------------------------------------------------------------
info "Starting $PROGNAME v$VERSION (clone=$CLONE_MODE minimal=$MINIMAL dry-run=$DRY_RUN force=$FORCE)"

# Phase 1 — optional fresh clone + symlinks
if (( CLONE_MODE )); then
  clone_and_install
fi

# Phase 2 — always: create standard directories
ensure_dir "$BIN_DIR"
ensure_dir "$HOME/www"
ensure_dir "$HOME/git/vrkansagara"
ensure_dir "$HOME/applications"
ensure_dir "$HOME/tmp"
ensure_dir "$HOME/logs"

# Network sanity check (soft fail)
if ! curl -fsSI https://github.com >/dev/null 2>&1; then
  warn "Network/GitHub may be unreachable. Continuing, but downloads may fail."
fi

update_system
install_packages
install_ohmyzsh
install_binaries
ensure_path_notice
prevents_tampering

ok "Bootstrap completed successfully."

if (( DRY_RUN )); then
  warn "This was a dry run. No changes were applied."
fi
