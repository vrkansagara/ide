#!/usr/bin/env bash
# set -e # This setting is telling the script to exit on a command error.
# set -x # You refer to a noisy script.(Used to debugging)

echo " "
CURRENT_DATE=$(date "+%Y%m%d%H%M%S")
export DEBIAN_FRONTEND=noninteractive

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note		  :- Know about your system.
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

echo "Current memory usage (Used/Available)"
free -mh | awk '/^Mem:/ {print $3 "/" $2}'

echo "Show CPU temperature"
sensors

lspci -nn | grep -i audio 
speaker-test -t wav -c 2
dmesg | grep snd 
${SUDO} alsactl init
aplay -l
amixer
cat /proc/asound/cards
inxi -Fxz
# create a 10 second output, 30 fps (300 frames total), with a frame size of 640x360 (testsrc.mpg)
ffmpeg -f lavfi -i testsrc=duration=10:size=1280x720:rate=30 /tmp/testsrc.mpg

sensors| grep -i rpm | awk '{ print "Fan "$3"/"$11" RPM"}'
