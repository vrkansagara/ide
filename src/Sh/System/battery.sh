#!/usr/bin/env bash

# set -e # This setting is telling the script to exit on a command error.
# set -x # You refer to a noisy script.(Used to debugging)
export DEBIAN_FRONTEND=noninteractive
echo " "

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi

CURRENT_DATE=$(date "+%Y%m%d%H%M%S")

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note		  :-
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if ! command -v acpi &> /dev/null
then
	echo "Install acpi for better level check up"
	${SUDO} apt-get install -y acpi powermgmt-base
fi

while true
do
	export DISPLAY=:0.0
	battery_level=`acpi -b | grep -P -o '[0-9]+(?=%)'`

	echo "Current battery level is $battery_level"

	#check if the battery level is lower then 10%
	if [ $battery_level -le 5 ]; then
		notify-send -u critical "Please plug your AC adapter" "Battery level: ${battery_level}% (lower then 5%)"
	fi

	#check if AC is plugged in
	if on_ac_power; then

		#check if the battery level is over 90%
		if [ $battery_level -ge 99 ]; then
			notify-send -u critical "Please unplug your AC adapter" "Battery level: ${battery_level}% (charged above 99%)" -i battery-full-charged
		fi

	fi

	#wait for 300 seconds (5 minute ) before checking again
	sleep 300
done
