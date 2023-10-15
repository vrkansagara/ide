#!/usr/bin/env bash
set -e # This setting is telling the script to exit on a command error.
# set -x # You refer to a noisy script.(Used to debugging)

CURRENT_DATE=$(date "+%Y%m%d%H%M%S")
export

SCRIPT=$(readlink -f "$0")
SCRIPTDIR=$(dirname "$SCRIPT")

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi

if ! command -v ls &>/dev/null; then
	echo "ls command not found"
fi

echo $0

full_path=$(realpath $0)
echo "This is full_path " $full_path

dir_path=$(dirname $full_path)
echo "This is dir_path" $dir_path

echo $CURRENT_DATE
echo $(date)
echo "Current home folder is " $(pwd)

echo "Ctrl+s to freeze output/error and press Ctrl+q to continue script and press Ctrl+c to cancle the program."
for i in {1..10}; do
	echo "$i"
	sleep 0.3
done
