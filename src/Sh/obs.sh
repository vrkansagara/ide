#!/usr/bin/env bash
set -e # This setting is telling the script to exit on a command error.
if [[ "$1" == "-v" ]]; then
	set -x # You refer to a noisy script.(Used to debugging)
	shift
fi

export CURRENT_DATE=$(date "+%Y%m%d%H%M%S")
export SCRIPT=$(readlink -f "")
export SCRIPTDIR=$(dirname "$SCRIPT")

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- vallabhdas kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note		  :-
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

${SUDO} add-apt-repository ppa:obsproject/obs-studio
${SUDO} apt-get install --yes --no-install-recommends ffmpeg obs-studio youtube-dl

echo "Installation of OBS studio is ...[DONE]"

exit 0
