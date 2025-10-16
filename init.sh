#!/usr/bin/env bash
#
# System / Developer environment bootstrap script
#
# Maintainer : vallabhdas kansagara <vrkansagara@gmail.com> — @vrkansagara
# Original   : https://raw.githubusercontent.com/vrkansagara/ide/master/init.sh
#
# Safe one-liner run (ALWAYS review before piping to sh):
#   bash <(curl -fsSL https://raw.githubusercontent.com/vrkansagara/ide/master/init.sh)
#
# Features:
#  - Safe shell options + error trapping
#  - Argument parsing (see --help)
#  - Optional skipping of upgrades / oh-my-zsh
#  - Idempotent tooling install (jq, JMESPath)
#  - Supports custom binary directory
#  - Dry-run mode
#  - Minimal mode
#  - Non-interactive apt
#

set -euo pipefail

# ---------- Defaults ----------
BIN_DIR_DEFAULT="$HOME/.vim/bin"   # Preserved for backward compatibility
BIN_DIR="${BIN_DIR:-$BIN_DIR_DEFAULT}"
INSTALL_PACKAGES=1
DO_UPGRADE=1
FORCE=0
DRY_RUN=0
VERBOSE=0
INSTALL_OHMYZSH=1
MINIMAL=0

# ---------- Logging ----------
COLOR="${NO_COLOR:-1}"
if [[ -t 1 && $COLOR -eq 1 ]]; then
  BOLD=$'\033[1m'; RED=$'\033[31m'; YELLOW=$'\033[33m'; GREEN=$'\033[32m'; BLUE=$'\033[34m'; RESET=$'\033[0m'
else
  BOLD=""; RED=""; YELLOW=""; GREEN=""; BLUE=""; RESET=""
fi

log()  { printf '%s\n' "$*"; }
info() { log "${BLUE}[INFO]${RESET} $*"; }
warn() { log "${YELLOW}[WARN]${RESET} $*"; }
err()  { log "${RED}[ERR ]${RESET} $*" >&2; }
ok()   { log "${GREEN}[ OK ]${RESET} $*"; }

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

# ---------- Error handling ----------
trap 'err "Failed at line $LINENO: $BASH_COMMAND"; exit 1' ERR

# ---------- Help ----------
usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Options:
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
  BIN_DIR=/custom/path    (same as --bin-dir)
  NO_COLOR=1              (same as --no-color)

Examples:
  $(basename "$0") --minimal
  BIN_DIR="\$HOME/.local/bin" $(basename "$0") --skip-ohmyzsh
EOF
}

# ---------- Argument parsing ----------
for arg in "$@"; do
  case "$arg" in
    -h|--help) usage; exit 0 ;;
    -v|--verbose) VERBOSE=1; set -x ;;
    --dry-run) DRY_RUN=1 ;;
    --no-upgrade) DO_UPGRADE=0 ;;
    --no-packages) INSTALL_PACKAGES=0 ;;
    --skip-ohmyzsh) INSTALL_OHMYZSH=0 ;;
    --bin-dir=*) BIN_DIR="${arg#*=}" ;;
    --force) FORCE=1 ;;
    --minimal) MINIMAL=1 ;;
    --no-color) COLOR=0 ;;
    *) err "Unknown argument: $arg"; usage; exit 2 ;;
  esac
done

# ---------- Preconditions ----------
if ! command -v apt-get >/dev/null 2>&1; then
  err "apt-get not found. This script targets Debian/Ubuntu-based systems."
  exit 1
fi

if [[ "$(id -u)" -ne 0 ]]; then
  SUDO="sudo"
else
  SUDO=""
fi

# Non-interactive apt
export DEBIAN_FRONTEND=noninteractive

# ---------- Package sets ----------
BASE_PACKAGES=(
  git gitk htop nmap elinks arandr gufw ufw zsh curl xdotool cpulimit guake
)

MINIMAL_PACKAGES=(
  git zsh curl htop
)

if (( MINIMAL )); then
  PKGS=("${MINIMAL_PACKAGES[@]}")
else
  PKGS=("${BASE_PACKAGES[@]}")
fi

# ---------- Functions ----------
ensure_dir() {
  local d="$1"
  if [[ ! -d "$d" ]]; then
    run "mkdir -p '$d'"
    ok "Created directory: $d"
  fi
}

download_binary() {
  # Args: url target expected_sha256(optional)
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
      err "Checksum mismatch for $target (expected $expect_sha got $got)"
      exit 1
    fi
  fi

  run "chmod +x '$tmp'"
  run "mv '$tmp' '$target'"
  ok "Installed $(basename "$target") -> $target"
}

install_or_skip_binary() {
  # Args: name path url checksum(optional) test_command(optional)
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

update_system() {
  info "Updating package lists"
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
  if (( INSTALL_PACKAGES )); then
    info "Installing packages: ${PKGS[*]}"
    run "$SUDO apt-get install -y ${PKGS[*]}"
  else
    warn "Skipping package install (--no-packages)"
  fi
}

install_ohmyzsh() {
  if (( INSTALL_OHMYZSH == 0 )); then
    warn "Skipping Oh My Zsh (--skip-ohmyzsh)"
    return
  fi
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    ok "Oh My Zsh already installed."
  else
    info "Installing Oh My Zsh (unattended)"
    # RUNZSH=no avoids auto-shell switch, CHSH=yes allows shell change
    run "export RUNZSH=no CHSH=yes KEEP_ZSHRC=yes; sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""
  fi

  # Change default shell if needed
  local zpath
  zpath="$(command -v zsh || true)"
  if [[ -n "$zpath" && "$SHELL" != "$zpath" ]]; then
    info "Switching default shell to $zpath"
    run "chsh -s '$zpath' $(whoami)"
  fi
}

ensure_path_notice() {
  case ":$PATH:" in
    *":$BIN_DIR:"*) : ;;
    *)
      warn "BIN_DIR ($BIN_DIR) is not in PATH. Add the following to your shell profile:"
      echo "  export PATH=\"$BIN_DIR:\$PATH\""
      ;;
  esac
}

# ---------- Execution Flow ----------
info "Starting bootstrap (minimal=$MINIMAL dry-run=$DRY_RUN force=$FORCE)"

ensure_dir "$BIN_DIR"
ensure_dir "$HOME/www"
ensure_dir "$HOME/git/vrkansagara"
ensure_dir "$HOME/Applications"

# Network sanity check (optional soft fail)
if ! curl -fsSI https://github.com >/dev/null 2>&1; then
  warn "Network/GitHub may be unreachable. Continuing, but downloads may fail."
fi

update_system
install_packages
install_ohmyzsh

# ---------- Tool installs ----------
info "Installing user-level binaries into $BIN_DIR"

# jq (latest release)
install_or_skip_binary \
  "jq" \
  "$BIN_DIR/jq" \
  "https://github.com/stedolan/jq/releases/latest/download/jq-linux64" \
  "" \
  "--version"

# JMESPath CLI (jp)
install_or_skip_binary \
  "JMESPath (jp)" \
  "$BIN_DIR/JMESPath" \
  "https://github.com/jmespath/jp/releases/latest/download/jp-linux-amd64" \
  "" \
  "--help"

# Quick functional tests (non-fatal if they fail)
if [[ -x "$BIN_DIR/jq" ]]; then
  echo '{"foo": 0}' | "$BIN_DIR/jq" . >/dev/null 2>&1 && ok "jq test OK" || warn "jq test failed"
fi
if [[ -x "$BIN_DIR/JMESPath" ]]; then
  echo '{"a": "foo"}' | "$BIN_DIR/JMESPath" a >/dev/null 2>&1 && ok "JMESPath test OK" || warn "JMESPath test failed"
fi

# Ensure executability (some shells might strip)
run "chmod -f +x '$BIN_DIR'/* || true"

ensure_path_notice

ok "Bootstrap completed successfully."

if (( DRY_RUN )); then
  warn "This was a dry run. No changes were applied."
fi
