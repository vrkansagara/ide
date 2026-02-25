#!/usr/bin/env bash
# ==============================================================================
# gnupg.sh — Install and configure GnuPG2 for signing and encryption
# ==============================================================================
# Maintainer : Vallabhdas Kansagara <vrkansagara@gmail.com> — @vrkansagara
# Version    : 2.0.0

set -o errexit
set -o pipefail
set -o nounset

readonly VERSION="2.0.0"
readonly PROGNAME="${0##*/}"
VERBOSE=0
SUDO_CMD=""

CURRENT_DATE="$(date "+%Y%m%d%H%M%S")"
export CURRENT_DATE

_init_colors() {
    if [ -t 1 ] && command -v tput >/dev/null 2>&1; then
        C_RESET="$(tput sgr0   2>/dev/null || printf '')"; C_GREEN="$(tput setaf 2 2>/dev/null || printf '')"
        C_YELLOW="$(tput setaf 3 2>/dev/null || printf '')"; C_RED="$(tput setaf 1 2>/dev/null || printf '')"
        C_CYAN="$(tput setaf 6  2>/dev/null || printf '')"; C_BOLD="$(tput bold   2>/dev/null || printf '')"
    else
        C_RESET=''; C_GREEN=''; C_YELLOW=''; C_RED=''; C_CYAN=''; C_BOLD=''
    fi
}
_init_colors

info()    { printf '%b[INFO]  %s%b\n' "$C_GREEN"  "$*" "$C_RESET"; }
warn()    { printf '%b[WARN]  %s%b\n' "$C_YELLOW" "$*" "$C_RESET"; }
fatal()   { printf '%b[FATAL] %s%b\n' "$C_RED"    "$*" "$C_RESET" >&2; exit 1; }
ok()      { printf '%b[OK]    %s%b\n' "$C_GREEN"  "$*" "$C_RESET"; }
log()     { [ "$VERBOSE" -ne 0 ] && printf '[DEBUG] %s\n' "$*" || true; }
section() { printf '\n%b=== %s ===%b\n' "${C_BOLD}${C_CYAN}" "$*" "$C_RESET"; }

usage() {
    cat <<EOF
Usage: $PROGNAME [-v|--verbose] [--version] [-h|--help]

Description:
  Installs gnupg2, configures the ~/.gnupg directory with correct permissions,
  optionally imports a private key, configures git for GPG commit signing, and
  verifies the GPG setup.

Options:
  -v, --verbose   Enable verbose/debug output
  --version       Print version and exit
  -h, --help      Show this help message and exit
EOF
}

_run() {
    if [ -n "$SUDO_CMD" ]; then "$SUDO_CMD" "$@"; else "$@"; fi
}

parse_args() {
    while [ "${1:-}" != "" ]; do
        case "$1" in
            -v | --verbose)
                VERBOSE=1
                set -x
                ;;
            --version)
                printf '%s version %s\n' "$PROGNAME" "$VERSION"
                exit 0
                ;;
            -h | --help)
                usage
                exit 0
                ;;
            *)
                warn "Unknown argument: $1"
                usage
                exit 1
                ;;
        esac
        shift
    done
}

main() {
    parse_args "$@"

    if [ "$(id -u)" -ne 0 ]; then
        command -v sudo >/dev/null 2>&1 && SUDO_CMD="sudo" || warn "sudo not found."
    fi

    _run apt-get install -y --reinstall --no-install-recommends gnupg2
    _run mkdir -p "$HOME/.gnupg"
    # To fix the " gpg: WARNING: unsafe permissions on homedir '/home/path/to/user/.gnupg' " error
    # Make sure that the .gnupg directory and its contents is accessibile by your user.
    _run chown -R "$USER" "$HOME/.gnupg/"

    # Also correct the permissions and access rights on the directory
    _run chmod 600 "$HOME/.gnupg/"*
    _run chmod 700 "$HOME/.gnupg"

    # gpg --output public.pgp --armor --export username@email
    # gpg --output private.pgp --armor --export-secret-key username@email

    # gpg --default-new-key-algo rsa4096 --gen-key
    # Generate a new pgp key: (better to use gpg2 instead of gpg in all below commands)
    # gpg --gen-key
    # maybe you need some random work in your OS to generate a key. so run this command: `find ./* /home/username -type d | xargs grep some_random_string > /dev/null`

    if [ -f "~/.ssh/gnupg/vrkansagara-sec.key" ]; then
        gpg --import ~/.ssh/gnupg/vrkansagara-sec.key
    fi

    # check current keys:
    gpg --list-secret-keys --keyid-format LONG

    # See your gpg public key:
    # gpg --armor --export YOUR_KEY_ID
    # YOUR_KEY_ID is the hash in front of `sec` in previous command. (for example sec 4096R/234FAA343232333 => key id is: 234FAA343232333)

    # Set a gpg key for git:
    # git config --global user.signingkey your_key_id

    # To sign a single commit:
    # git commit -S -a -m "Test a signed commit"

    # Auto-sign all commits global
    git config --global commit.gpgsign true

    # Kill running gpg-agent( os will start it again)
    _run killall gpg-agent || true

    # Export gpg as tty to avoid confusion( Warning :- you have to add into dot file)
    export GPG_TTY
    GPG_TTY="$(tty)"

    # Lets test it
    echo "test" | gpg --clearsign
}
main "$@"
