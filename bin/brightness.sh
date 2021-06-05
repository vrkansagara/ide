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

command=""
value=""

if [ $# -ge 2 ] ; then
    # Two arguments: first is command, second is "value"
    command=$1
    value=$2
else
    if [ $# -eq 1 ] ; then
        # One argument: use as command, and use default value to 5
        command=$1
        value=100
    else
        # Otherwise: prompt
        echo "Please enter up/down for the brightness change:"
        read command
        echo "Enter brightness value:"
        read value
    fi
fi

# echo "Your current graphics driver is "
# lspci -vnn | grep -A12 VGA

# ls -lA /sys/class/backlight/

curBrightness=$(cat /sys/class/backlight/intel_backlight/brightness)
userValueForBrightness=0

case "$command" in
	"up")
			userValueForBrightness=`expr $curBrightness + $value`
	;;
	"down")
		userValueForBrightness=`expr $curBrightness - $value`
		if [[ $userValueForBrightness -le 100 ]]; then
			userValueForBrightness=100
		fi
	;;
	"set")
		if [[ $curBrightness -le 100 ]]; then
			userValueForBrightness=100
			echo 1000 | ${SUDO} tee /sys/class/backlight/intel_backlight/brightness

		else
			echo $value | ${SUDO} tee /sys/class/backlight/intel_backlight/brightness

		fi
		exit;
	;;
	*)
		echo "Unsupported: \"$1\""
		exit 1
esac

echo "Current brightness level is  => $curBrightness"
echo "Current brightness change to => $userValueForBrightness"

echo $userValueForBrightness | ${SUDO} tee /sys/class/backlight/intel_backlight/brightness
