#!/usr/bin/env bash
set -e # This setting is telling the script to exit on a command error.
if [[ "$1" == "-v" ]]; then
	set -x # You refer to a noisy script.(Used to debugging)
fi

CURRENT_DATE=$(date "+%Y%m%d%H%M%S")
export

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note		  :- https://www.rust-lang.org/tools/install
#  Note(Other)		  :- https://forge.rust-lang.org/infra/other-installation-methods.html
#  Ref: https://github.com/orgs/mozilla/repositories?language=rust&type=all
#  Ref: https://github.com/torvalds/linux/search?l=rust
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

${SUDO} apt-get install --yes --no-install-recommends build-essential

if [[ "$1" == "-r" ]]; then
	rustup self uninstall
fi

if [[ "$1" == "-r" ]]; then
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
fi
