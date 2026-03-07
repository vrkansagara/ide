# ==============================================================================
# bash_improvement.sh — Readline / inputrc bootstrapping for interactive shells
# ==============================================================================
# Maintainer : Vallabhdas Kansagara <vrkansagara@gmail.com> — @vrkansagara
# Version    : 2.0.0
# Usage      : source this file from ~/.bashrc or ~/.zshrc

# Guard against double-sourcing
[ -n "${_LOADED_BASH_IMPROVEMENT_SH:-}" ] && return 0
_LOADED_BASH_IMPROVEMENT_SH=1

# ------------------------------------------------------------------------------
# If ~/.inputrc does not yet exist: seed it from /etc/inputrc and enable
# case-insensitive tab completion.
# ------------------------------------------------------------------------------
if [ ! -e "$HOME/.inputrc" ]; then
    printf '$include /etc/inputrc\n' > "$HOME/.inputrc"
    # Enable case-insensitive tab completion (readline directive, not a bash bind command)
    printf 'set completion-ignore-case on\n' >> "$HOME/.inputrc"
fi
