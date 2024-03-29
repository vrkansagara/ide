#!/usr/bin/env bash
set -e # This setting is telling the script to exit on a command error.
if [[ "$1" == "-v" ]]; then
	set -x # You refer to a noisy script.(Used to debugging)
fi

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- vallabhdas kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note		  :-
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

youtube-dl $1

mp3(){
  youtube-dl \
  --ignore-errors \
  --extract-audio \
  --audio-format mp3 \
  --audio-quality 0
  -f bestaudio \
  -t  \
  -o "$2/%(title)s.%(ext)s"
  $1
}

main() {
  	if [[ "$1" == "--mp3" ]]; then
  		mp3 $2 $3
  	fi
}

main "$@"

echo "Installation of OBS studio is ...[DONE]"

exit 0
