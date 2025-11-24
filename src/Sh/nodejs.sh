#!/usr/bin/env bash
set -euo pipefail
# =====================================================
# Maintainer: Vallabhdas Kansagara <vrkansagara@gmail.com>
# Description: Safe node / nvm helper for installing nvm, node, and
#              running npm updates in a low-RAM, low-CPU friendly way.
# =====================================================
#
# NOTE: This script preserves your original comments and behaviour,
#       but hardens the operations for production / constrained hosts.
#       Use --help to see available commands.
#

# enable verbose debugging with -v
if [[ "${1:-}" == "-v" ]]; then
  shift
  set -x
fi

# ---------------------------
# Environment / globals
# ---------------------------
# PWD utility similar to original
PWD=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

# Prefer nice/ionice when available to reduce impact on low-CPU/RAM hosts
NICE_CMD="$(command -v nice || true)"
IONICE_CMD="$(command -v ionice || true)"

# Detect sudo only if required. Avoid running nvm installer as root.
SUDO=""
if [[ "$(id -u)" -ne 0 ]]; then
  if command -v sudo >/dev/null 2>&1; then
    SUDO="sudo"
  fi
fi

# Helper: portable check for command existence
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# usage/help
usage() {
  cat <<'USAGE'
Usage: deploy-node-helper.sh [-v] [--nvm] [--nodejs] [--node-latest] [--help]

Options:
  -v              Enable bash xtrace (debug)
  --nvm           Install NVM (idempotent)
  --nodejs        Install node via nvm (latest + lts)
  --node-latest   Update project node deps: npm ci, npx npm-check-updates -u, npm update
  --help          Show this help
USAGE
  exit 0
}

# ---------------------------
# Safe downloader (curl fallback) with retries
# ---------------------------
download_with_retries() {
  local url="$1"
  local dest="$2"
  local tries="${3:-3}"
  local wait_sec="${4:-3}"

  if command_exists curl; then
    for i in $(seq 1 "$tries"); do
      if curl -fsSL --connect-timeout 10 "$url" -o "$dest"; then
        return 0
      fi
      sleep "$wait_sec"
    done
    return 1
  elif command_exists wget; then
    for i in $(seq 1 "$tries"); do
      if wget -qO "$dest" "$url"; then
        return 0
      fi
      sleep "$wait_sec"
    done
    return 1
  else
    echo "No curl or wget available to download $url" >&2
    return 1
  fi
}

# ---------------------------
# nvmInstall — idempotent and safe
# ---------------------------
nvmInstall() {
  # NVM is a per-user tool; DO NOT run nvm install as root. If running as root,
  # warn and exit to avoid contaminating root's home directory.
  if [[ "$(id -u)" -eq 0 ]]; then
    echo "Refusing to install nvm as root. Run this as a regular user." >&2
    return 1
  fi

  # If nvm already exists and is loadable, skip (idempotent)
  if command_exists nvm || [[ -s "$HOME/.nvm/nvm.sh" ]]; then
    # try to source
    if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
      # shellcheck source=/dev/null
      . "$HOME/.nvm/nvm.sh"
      echo "NVM already installed and loaded."
      return 0
    fi
  fi

  # Install prerequisites minimally if needed (curl) - do not assume apt exists
  if ! command_exists curl && ! command_exists wget; then
    if command_exists apt-get; then
      echo "Installing curl (required for nvm installation) via apt-get..."
      $SUDO apt-get update -y -qq
      $SUDO apt-get install -y -qq curl ca-certificates || {
        echo "Failed to install curl via apt-get." >&2
        return 1
      }
    else
      echo "Neither curl nor wget present and apt-get not available. Cannot install nvm." >&2
      return 1
    fi
  fi

  local tmp_install_sh
  tmp_install_sh="$(mktemp -t nvm-install-XXXX.sh)"
  trap 'rm -f "$tmp_install_sh" >/dev/null 2>&1 || true' RETURN

  # Use recommended nvm installer URL (pinned tag is safer)
  local nvm_install_url="https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh"

  echo "Downloading nvm installer..."
  if ! download_with_retries "$nvm_install_url" "$tmp_install_sh" 5 4; then
    echo "Failed to download nvm installer." >&2
    return 1
  fi

  chmod +x "$tmp_install_sh"

  # Run installer in a subshell to avoid polluting the current shell
  echo "Running nvm installer..."
  if ! bash "$tmp_install_sh"; then
    echo "nvm installer failed." >&2
    return 1
  fi

  # source nvm to current shell
  if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
    # shellcheck source=/dev/null
    . "$HOME/.nvm/nvm.sh"
    echo "NVM installed and loaded."
    return 0
  fi

  echo "nvm installation completed but nvm.sh not found." >&2
  return 1
}

# ---------------------------
# nodejsInstall — install node via nvm
# ---------------------------
nodejsInstall() {
  if ! command_exists nvm; then
    echo "nvm not found. Run with --nvm first." >&2
    return 1
  fi

  # Keep builds low impact by preferring LTS then latest stable as requested
  echo "Installing latest Node and LTS via nvm (idempotent)..."
  if [[ -n "$NICE_CMD" ]]; then
    # reduce priority for CPU-bound builds
    nice -n 10 nvm install node || true
    nice -n 10 nvm install --latest-npm || true
    nice -n 10 nvm use --latest-npm || true
    nice -n 10 nvm install --lts || true
    nice -n 10 nvm use --lts || true
  else
    nvm install node || true
    nvm install --latest-npm || true
    nvm use --latest-npm || true
    nvm install --lts || true
    nvm use --lts || true
  fi

  echo "Node versions (nvm):"
  nvm ls
}

# ---------------------------
# nodeLatest — update project deps safely (low RAM)
# ---------------------------
nodeLatest() {
  # Ensure npm present
  if ! command_exists npm; then
    echo "npm not found. Ensure node is installed and available in PATH." >&2
    return 1
  fi

  # Run in current working dir (expected to be project root). Use npm ci for reproducible,
  # but fall back to npm install if package-lock.json absent. For low-RAM hosts we run under nice/ionice.
  if [[ -f package-lock.json ]]; then
    echo "Running npm ci (reproducible install)..."
    if [[ -n "$NICE_CMD" || -n "$IONICE_CMD" ]]; then
      if [[ -n "$IONICE_CMD" && -n "$NICE_CMD" ]]; then
        nice -n 10 ionice -c 2 npm ci --no-audit --no-fund --prefer-offline --silent
      else
        nice -n 10 npm ci --no-audit --no-fund --prefer-offline --silent
      fi
    else
      npm ci --no-audit --no-fund --prefer-offline --silent
    fi
  else
    echo "No package-lock.json found — running npm install (best effort)"
    if [[ -n "$NICE_CMD" || -n "$IONICE_CMD" ]]; then
      if [[ -n "$IONICE_CMD" && -n "$NICE_CMD" ]]; then
        nice -n 10 ionice -c 2 npm install --no-audit --no-fund --silent
      else
        nice -n 10 npm install --no-audit --no-fund --silent
      fi
    else
      npm install --no-audit --no-fund --silent
    fi
  fi

  # Ensure bin executables are runnable for current user only (avoid chmod -R a+x)
  if [[ -d node_modules/.bin ]]; then
    find node_modules/.bin -type f -exec chmod u+x {} \; || true
  fi

  # Use npx to run npm-check-updates without globally installing it (keeps environment clean)
  if command_exists npx; then
    echo "Running npx npm-check-updates (ncu) to update package.json dependencies..."
    # Use --target minor if you want more conservative updates, here we use default (latest)
    if ! npx -y npm-check-updates -u --packageFile package.json --silent; then
      echo "ncu reported non-zero exit; continuing (non-fatal)." >&2
    fi

    # Update packages (best effort). Use npm update which will respect package.json changes.
    echo "Running npm update..."
    if [[ -n "$NICE_CMD" && -n "$IONICE_CMD" ]]; then
      nice -n 10 ionice -c 2 npm update --silent || true
    else
      nice -n 10 npm update --silent || true
    fi
  else
    echo "npx not available — skipping npm-check-updates step."
  fi

  # Rebuild native modules (node-sass) if present but do so in low-impact mode
  if [[ -d node_modules && -f package.json && $(jq -r '.dependencies["node-sass"] // empty' package.json 2>/dev/null || true) ]]; then
    echo "node-sass present — running rebuild (may be CPU intensive)"
    if [[ -n "$NICE_CMD" && -n "$IONICE_CMD" ]]; then
      nice -n 10 ionice -c 2 npm rebuild node-sass --silent || true
    else
      npm rebuild node-sass --silent || true
    fi
  fi

  echo "Node deps updated (best effort)."
}

# ---------------------------
# main dispatcher (keeps behaviour similar to original)
# ---------------------------
main() {
  if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    usage
  fi

  while [[ "${1:-}" != "" ]]; do
    case "$1" in
      --nvm)
        nvmInstall || exit 1
        shift
        ;;
      --nodejs)
        nodejsInstall || exit 1
        shift
        ;;
      --node-latest)
        nodeLatest || exit 1
        shift
        ;;
      --help|-h)
        usage
        ;;
      *)
        echo "Unknown argument: $1" >&2
        usage
        ;;
    esac
  done
}

main "$@"
