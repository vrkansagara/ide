#!/usr/bin/env bash
# set -e # This setting is telling the script to exit on a command error.
# set -x # You refer to a noisy script.(Used to debugging)

echo
CURRENT_DATE=$(date "+%Y%m%d%H%M%S")
export DEBIAN_FRONTEND=noninteractive

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note		  :- Set brightness with xbacklight, but never go below 1 (as that's "off Increment to use.
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
echo "Your current graphics driver is "

lspci -vnn | grep -A12 VGA

# ls -lA /sys/class/backlight/

defaultIncreseBy=500
defaultDescreaseBy=1000

curBrightness=$(cat /sys/class/backlight/intel_backlight/brightness)

userValueForBrightness=0

case "$1" in
	"up")
		if [[ $curBrightness -eq 0 ]]; then
			userValueForBrightness=1
		else
			userValueForBrightness=`expr $curBrightness + $defaultIncreseBy `
		fi
	;;
	"down")
		if [[ $curBrightness -le 5 ]]; then
			userValueForBrightness=3
		else
			userValueForBrightness=`expr $curBrightness - $defaultDescreaseBy`
		fi
	;;
	*)
		echo "Unsupported: \"$1\""
		exit 1
esac

echo $userValueForBrightness | ${SUDO} tee /sys/class/backlight/intel_backlight/brightness
