#!/usr/bin/env bash
set -e # This setting is telling the script to exit on a command error.
if [[ "$1" == "-v" ]]; then
  set -x # You refer to a noisy script.(Used to debugging)
fi

echo ""
export DEBIAN_FRONTEND=noninteractive
CURRENT_DATE=$(date "+%Y%m%d%H%M%S")

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note		  :-
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
# Bash script to control the monitor brightness

ORIGINAL_LEVEL=$(xrandr --verbose | grep -m 1 -i brightness | cut -f2 -d ' ')
echo "Original brightness level is :- ${ORIGINAL_LEVEL} "

SYNTAX="\\n \\t SYNTAX:  dimmer level \\n \\t Where 'level' ranges from 0 to 100.\\n";

LEVEL=$1

if [[ $LEVEL -gt 100 ]]; then
    echo -e $SYNTAX;
    exit 1;
fi

if [[ $LEVEL -lt 0 ]]; then
    echo -e $SYNTAX;
    exit 1;
fi

brightness_level="$(( $LEVEL / 100)).$(( $LEVEL % 100 ))"
screenname=$(xrandr | grep " connected" | cut -f1 -d" ")
xrandr --output $screenname --brightness $brightness_level;
echo -e "[info]: Screen Brightness level set to" $LEVEL"%"
