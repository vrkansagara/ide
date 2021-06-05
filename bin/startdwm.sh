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
#  Note		  :- Start DWM without restart ( execute it through ~/.xinitrc)
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


(conky | while read LINE; do xsetroot -name "$LINE"; done) &

# while true; do
# 	battery_level=`acpi -b | grep -P -o '[0-9]+(?=%)'`
# 	# xsetroot -name "$( date +"%F %r %A" ) ---- Battery($battery_level)"
# 	xsetroot -name "$( date +"%F %r %A" )"

#    sleep 1s    # Update time every minute
# done &

# relaunch DWM if the binary changes, otherwise bail
csum=""
new_csum=$(sha1sum $(which dwm))

# while true; do
#     if [ "$csum" != "$new_csum" ]
#     then
#         csum=$new_csum
#         /usr/bin/dwm > /dev/null
#     else
#         exit 0
#     fi
#     new_csum=$(sha1sum $(which dwm))
#     sleep 0.5
# done

while true;  do  /usr/local/bin/dwm > /dev/null; done;

