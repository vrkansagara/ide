#!/usr/bin/env bash
# ==============================================================================
# install.sh — Compatibility shim; functionality merged into init.sh v3.0.0
# ==============================================================================
# Maintainer : Vallabhdas Kansagara <vrkansagara@gmail.com> — @vrkansagara
#
# This file exists so the original one-liner still works:
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/vrkansagara/ide/master/install.sh)"
#
# It simply delegates to init.sh --clone, which performs the full
# fresh-install (clone, backup, symlinks) followed by system bootstrap.
# ==============================================================================

set -o errexit
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

exec bash "${SCRIPT_DIR}/init.sh" --clone "$@"
