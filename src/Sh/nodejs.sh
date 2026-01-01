#!/usr/bin/env bash
set -euo pipefail
# =====================================================
# Maintainer: Vallabhdas Kansagara <vrkansagara@gmail.com>
# Description: Safe node / nvm helper for installing nvm, node, and
#              running npm updates in a low-RAM, low-CPU friendly way.
# =====================================================

# ---------------------------
# Enable verbose debugging
# ---------------------------
if [[ "${1:-}" == "-v" ]]; then
  shift
  set -x
fi

# ---------------------------
# Globals
# ---------------------------
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

NICE_CMD="$(command -v nice || true)"
IONICE_CMD="$(command -v ionice || true)"

SUDO=""
if [[ "$(id -u)" -ne 0 ]] && command -v sudo >/dev/null 2>&1; then
  SUDO="sudo"
fi

# ---------------------------
# Helpers
# ---------------------------
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

usage() {
  cat <<'USAGE'
Usage: deploy-node-helper.sh [-v] [--nvm] [--nodejs] [--node-latest]

Options:
  -v              Enable bash debug (xtrace)
  --nvm           Install NVM (idempotent, safe)
  --nodejs        Install Node.js via NVM (LTS + latest)
  --node-latest   Update project dependencies safely
  --help, -h      Show this help
USAGE
  exit 0
}

# ---------------------------
# Download helper
# ---------------------------
download_with_retries() {
  local url="$1" dest="$2" tries="${3:-3}" wait="${4:-3}"

  for _ in $(seq 1 "$tries"); do
    if command_exists curl; then
      curl -fsSL --connect-timeout 10 "$url" -o "$dest" && return 0
    elif command_exists wget; then
      wget -qO "$dest" "$url" && return 0
    fi
    sleep "$wait"
  done

  echo "Download failed: $url" >&2
  return 1
}

# ---------------------------
# NVM Install
# ---------------------------
nvmInstall() {
  if [[ "$(id -u)" -eq 0 ]]; then
    echo "❌ Do not install NVM as root." >&2
    return 1
  fi

  if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
    # shellcheck source=/dev/null
    . "$HOME/.nvm/nvm.sh"
    echo "✔ NVM already installed."
    return 0
  fi

  tmp=""
  trap '[[ -n "$tmp" ]] && rm -f "$tmp"' EXIT

  tmp="$(mktemp -t nvm-install-XXXX.sh)"

  download_with_retries \
    "https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh" \
    "$tmp" 5 4

  bash "$tmp"

  if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
    # shellcheck source=/dev/null
    . "$HOME/.nvm/nvm.sh"
    echo "✔ NVM installed successfully."
  else
    echo "❌ NVM install failed." >&2
    return 1
  fi
}

# ---------------------------
# Node Install
# ---------------------------
nodejsInstall() {
  if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
    # shellcheck source=/dev/null
    . "$HOME/.nvm/nvm.sh"
  else
    echo "❌ NVM not loaded. Run --nvm first." >&2
    return 1
  fi

  echo "Installing Node LTS..."
  nice -n 10 nvm install --lts || true
  nvm use --lts

  echo "Installing latest stable Node..."
  nice -n 10 nvm install node || true

  echo "✔ Installed Node versions:"
  nvm ls
}

# ---------------------------
# Update Project Dependencies
# ---------------------------
nodeLatest() {
  if ! command_exists npm; then
    echo "❌ npm not found." >&2
    return 1
  fi

  local run_cmd="npm install --no-audit --no-fund --silent"
  [[ -f package-lock.json ]] && run_cmd="npm ci --no-audit --no-fund --silent"

  echo "Running dependency install..."
  if [[ -n "$IONICE_CMD" && -n "$NICE_CMD" ]]; then
    nice -n 10 ionice -c 2 $run_cmd
  else
    nice -n 10 $run_cmd
  fi

  if command_exists npx; then
    echo "Updating package.json versions (ncu)..."
    npx -y npm-check-updates -u --silent || true
    npm update --silent || true
  fi

  if [[ -d node_modules/.bin ]]; then
    find node_modules/.bin -type f -exec chmod u+x {} \; || true
  fi

  echo "✔ Node dependencies updated."
}

# ---------------------------
# Main
# ---------------------------
main() {
  # 👇 SHOW HELP IF NO ARGUMENTS
  if [[ "$#" -eq 0 ]]; then
    usage
  fi

  while [[ "${1:-}" ]]; do
    case "$1" in
      --nvm) nvmInstall ;;
      --nodejs) nodejsInstall ;;
      --node-latest) nodeLatest ;;
      --help|-h) usage ;;
      *) echo "❌ Unknown option: $1"; usage ;;
    esac
    shift
  done
}

main "$@"
