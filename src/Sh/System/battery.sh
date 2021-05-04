#!/usr/bin/env bash

# set -e # This setting is telling the script to exit on a command error.
# set -x # You refer to a noisy script.(Used to debugging)
export DEBIAN_FRONTEND=noninteractive

if [ "$(whoami)" != "root" \]; then
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
	${SUDO} apt-get install -y acpi
fi

while true
do
	export DISPLAY=:0.0
	battery_level=`acpi -b | grep -P -o '[0-9]+(?=%)'`

	#check if AC is plugged in
	if on_ac_power; then

		#check if the battery level is over 90%
		if [ $battery_level -ge 99 ]; then
			notify-send -u critical "Please unplug your AC adapter" "Battery
			level: ${battery_level}% (charged above 99%)" -i battery-full-charged
		fi

	fi

	echo "Current battery level is $battery_level"

	sleep 300 # 5 minute
done
