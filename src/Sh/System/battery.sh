#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi

if ! command -v acpi &> /dev/null
then
	echo "Install acpi for better level check up"
	${SUDO} apt-get install -y acpi
fi

while true                                                                                                                                                                              
do
	export DISPLAY=:0.0
	battery_level=`acpi -b | grep -P -o '[0-9]+(?=%)'`
	if on_ac_power; then                                #check if AC is plugged in
		if [ $battery_level -ge 99 ]; then              #check if the battery level is over 90%
			notify-send -u critical "Please unplug your AC adapter" "Battery level: ${battery_level}% (charged above 100%)" -i battery-full-charged
		fi
	fi
	echo "Current battery level is $battery_level"
	sleep 30                                             #wait for 30 seconds before checking again
done

