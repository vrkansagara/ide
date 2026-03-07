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
# IMDSv1 (plain HTTP, no token) — may be disabled on instances requiring IMDSv2
# IMDSv2 alias fetches a session token first, then queries with it
# ------------------------------------------------------------------------------
alias myAwsMyInfo='curl -fSs http://169.254.169.254/latest/meta-data/'
alias myAwsMyInfoV2='TOKEN=$(curl -fSs -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600") && curl -fSs -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/'
