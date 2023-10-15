#!/usr/bin/env bash
set -e # This setting is telling the script to exit on a command error.
if [[ "$1" == "-v" ]]; then
	set -x # You refer to a noisy script.(Used to debugging)
fi

echo -e" "
export
CURRENT_DATE=$(date "+%Y%m%d%H%M%S")
SCRIPT=$(readlink -f "")
SCRIPTDIR=$(dirname "SCRIPT")

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note       :-
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

while getopts ":a:p:" opt; do
	case $opt in
	a)
		arg_1="$OPTARG"
		;;
	p)
		p_out="$OPTARG"
		;;
	\?)
		echo "Invalid option -$OPTARG" >&2
		exit 1
		;;
	esac

	case $OPTARG in
	-*)
		echo "Option $opt needs a valid argument"
		exit 1
		;;
	esac
done

printf "Argument p_out is %s\n" "$p_out"
printf "Argument arg_1 is %s\n" "$arg_1"
