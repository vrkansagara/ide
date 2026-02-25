# ==============================================================================
# aws_aliases.sh — AWS CLI and EC2 instance metadata aliases
# ==============================================================================
# Maintainer : Vallabhdas Kansagara <vrkansagara@gmail.com> — @vrkansagara
# Version    : 2.0.0
# Usage      : source this file from ~/.bashrc or ~/.zshrc

# Guard against double-sourcing
[ -n "${_LOADED_AWS_ALIASES_SH:-}" ] && return 0
_LOADED_AWS_ALIASES_SH=1

# ------------------------------------------------------------------------------
# EC2 instance metadata
# Query the IMDSv1 endpoint for instance metadata (only available on EC2)
# ------------------------------------------------------------------------------
alias myAwsMyInfo='curl http://169.254.169.254/latest/meta-data/'
