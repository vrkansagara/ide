#!/usr/bin/env bash

set -e  # Exit on error

# Enable verbose mode
if [[ "${1:-}" == "-v" ]]; then
    set -x
    shift
fi

# Use sudo if not root
if [ "$(id -u)" -ne 0 ]; then
    SUDO=sudo
else
    SUDO=""
fi

# ---------------------------------------------------------------------------
# Maintainer :- vallabhdas kansagara <vrkansagara@gmail.com> — @vrkansagara
# Note       :- Automated SSH safe setup with correct permissions
# ---------------------------------------------------------------------------

# Install keychain (non-interactive)
export DEBIAN_FRONTEND=noninteractive
$SUDO apt-get update -qq
$SUDO apt-get install -y --no-install-recommends keychain

echo "$USER is the only one owning $HOME/.ssh directory"

# Ensure ~/.ssh exists
mkdir -p "$HOME/.ssh"

# Append to SSH config safely (as user, not root)
SSH_CONFIG="$HOME/.ssh/config"

printf '%s\n' "Host *
    AddKeysToAgent yes
    IdentityFile ~/.ssh/id_rsa
    IdentityFile ~/.ssh/id_rsa_vrkansagara
" | $SUDO tee -a "$SSH_CONFIG" >/dev/null

# Fix ownership of config
$SUDO chown "$USER":"$USER" "$SSH_CONFIG"
$SUDO chmod 600 "$SSH_CONFIG"

echo "Generating sample SSH key directory (if needed)"
cd "$HOME/.ssh"

# ---------------------------------------------------------------------------
# Correct SSH permissions
# ---------------------------------------------------------------------------

echo "Applying SSH golden permissions..."

# Folder (correct)
$SUDO chmod 700 "$HOME/.ssh"

# Private keys (safe loop)
for key in "$HOME/.ssh"/id_*; do
    if [[ -f "$key" && ! "$key" =~ \.pub$ ]]; then
        $SUDO chmod 600 "$key"
    fi
done

# Public keys must remain world-readable
for pub in "$HOME/.ssh"/*.pub; do
    [[ -f "$pub" ]] && $SUDO chmod 644 "$pub"
done

# ---------------------------------------------------------------------------
# Start ssh-agent only if not running
# ---------------------------------------------------------------------------
if ! pgrep -u "$USER" ssh-agent >/dev/null 2>&1; then
    eval "$(ssh-agent -s)"
fi

# Add keys if they exist
[[ -f "$HOME/.ssh/id_rsa" ]] && ssh-add "$HOME/.ssh/id_rsa"
[[ -f "$HOME/.ssh/id_rsa_vrkansagara" ]] && ssh-add "$HOME/.ssh/id_rsa_vrkansagara"

# ---------------------------------------------------------------------------
# GPG import (fix tilde expansion)
# ---------------------------------------------------------------------------
$SUDO chown -R "$USER":"$USER" ~/.gnupg
$SUDO chmod 700 ~/.gnupg
$SUDO chmod 600 ~/.gnupg/*
if [ -f "$HOME/.ssh/gnupg/vrkansagara-sec.key" ]; then
    gpg --import "$HOME/.ssh/gnupg/vrkansagara-sec.key"
fi
gpgconf --kill gpg-agent
gpgconf --launch gpg-agent
gpg --list-keys


echo "[DONE] Linux $HOME/.ssh directory permission applied safely."
exit 0

# NOTES:
# "Host *"
#     UseKeychain yes (macOS only)
#     AddKeysToAgent yes
#     IdentityFile ~/.ssh/id_rsa
#
# mysql could not connect the SSH tunnel → access denied for 'none'
# ssh-keygen -p -m PEM -f
