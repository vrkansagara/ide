# ==============================================================================
# php_aliases.sh — PHP development server and Composer aliases
# ==============================================================================
# Maintainer : Vallabhdas Kansagara <vrkansagara@gmail.com> — @vrkansagara
# Version    : 2.0.0
# Usage      : source this file from ~/.bashrc or ~/.zshrc

# Guard against double-sourcing
[ -n "${_LOADED_PHP_ALIASES_SH:-}" ] && return 0
_LOADED_PHP_ALIASES_SH=1

# ------------------------------------------------------------------------------
# PHP built-in development server
# ------------------------------------------------------------------------------
# Start server in current directory (document root = ./)
alias myPhpRun='php -S 0.0.0.0:12345 -d ./'

# Start server with public/index.php as router, document root = public/
alias myPhpRunInPublic='php -S 0.0.0.0:12345 -d public/index.php -t public'

# Start server with web/index.php as router, document root = web/ (php7)
alias myPhpRunInWeb='php7 -S 0.0.0.0:12345 -d web/index.php -t web'

# ------------------------------------------------------------------------------
# PHP Laminas / Composer server
# ------------------------------------------------------------------------------
alias myPhpComposerRun='composer run-script serve --timeout 0'
