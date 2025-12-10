#!/usr/bin/env bash
set -euo pipefail

# Verbose mode
if [[ "${1:-}" == "-v" ]]; then
  set -x
  shift
fi

# Sudo detection
SUDO=""
if [[ "$(id -u)" -ne 0 ]]; then
  SUDO="sudo"
fi

# -------------------------------------------------------------------------
# Maintainer: Vallabhdas Kansagara <vrkansagara@gmail.com> — @vrkansagara
# Purpose: Safely rewrite commit email + optionally sign commits
# -------------------------------------------------------------------------

# Change to current git repo (abort if not inside repo)
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "❌ Not inside a git repository. Aborting."
  exit 1
fi

export FILTER_BRANCH_SQUELCH_WARNING=1


# -------------------------------------------------------------------------
# FIX EMAILS (SAFE & CORRECT)
# -------------------------------------------------------------------------
update_email() {
    OLD_EMAIL="vallabh@vrkansagara.local"
    CORRECT_EMAIL="vrkansagara@gmail.com"
    CORRECT_NAME="Vallabhdas Kansagara"

    echo "🔧 Rewriting author/committer email…"

    git filter-branch --force --env-filter "
if [[ \"\$GIT_COMMITTER_EMAIL\" == \"$OLD_EMAIL\" ]]; then
    export GIT_COMMITTER_NAME=\"$CORRECT_NAME\";
    export GIT_COMMITTER_EMAIL=\"$CORRECT_EMAIL\";
fi
if [[ \"\$GIT_AUTHOR_EMAIL\" == \"$OLD_EMAIL\" ]]; then
    export GIT_AUTHOR_NAME=\"$CORRECT_NAME\";
    export GIT_AUTHOR_EMAIL=\"$CORRECT_EMAIL\";
fi
" --tag-name-filter cat -- --branches --tags
}


# -------------------------------------------------------------------------
# GPG SIGN REWRITE (SAFE VERSION)
# vrkansagara gpg signature
# curl -sL https://gist.githubusercontent.com/vrkansagara/862e1ea96091ddf01d8e3f0786eefae8/raw/bcc458eb4b2c0eb441aaf7a56f385bc6cd4cb25a/vrkansagara.gpg | gpg --import
#
# export GPGKEY=8BA6E7ABD8112B3E
# Correct approach:
# 1) Only rewrite commits where the author == you
# 2) Use ONE commit-tree call, not two
# -------------------------------------------------------------------------
update_signature() {
    GPG_EMAIL="vrkansagara@gmail.com"

    echo "🔏 Rewriting history with signed commits (only yours)…"
    echo "⚠️ WARNING: This rewrites ALL history. Ensure backup or fresh clone."

    git filter-branch --force --commit-filter '
if [ "$GIT_AUTHOR_EMAIL" = "'"$GPG_EMAIL"'" ]; then
    git commit-tree -S "$@"
else
    git commit-tree "$@"
fi
' --tag-name-filter cat -- --branches --tags
}


# -------------------------------------------------------------------------
# HELP HANDLER
# -------------------------------------------------------------------------
if [[ "${1:-}" == "help" ]]; then
    cat <<EOF

Usage:
  ./script.sh email      → Rewrite author/committer email
  ./script.sh sign       → Re-sign commits belonging to your email
  ./script.sh -v email   → Verbose + rewrite emails

Examples:
  ./script.sh email
  ./script.sh sign

EOF
    exit 0
fi


# -------------------------------------------------------------------------
# EXECUTION MODE
# -------------------------------------------------------------------------
case "${1:-}" in
  email)
    update_email
    ;;
  sign)
    update_signature
    ;;
  *)
    echo "❌ Unknown command: ${1:-}"
    echo "Run: ./script.sh help"
    exit 1
    ;;
esac

echo "✔ Done."
