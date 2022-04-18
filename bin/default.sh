#!/usr/bin/env bash
# set -e # This setting is telling the script to exit on a command error.
# set -x # You refer to a noisy script.(Used to debugging)

echo ""
export DEBIAN_FRONTEND=noninteractive
CURRENT_DATE=$(date "+%Y%m%d%H%M%S")
SCRIPT=$(readlink -f "")
SCRIPTDIR=$(dirname "SCRIPT")

if [ "$(whoami)" != "root" ]; then
    SUDO=sudo
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note		  :- Set my default configuration for the working style.
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

xrandr --output eDP-1 --primary --mode 1366x768 --pos 0x0 --rotate normal \
--output HDMI-1 --off --output DP-1 --off

# Enable secound into clock
gsettings set org.gnome.desktop.interface clock-show-seconds true

# Enable week number into calender
gsettings set org.gnome.desktop.interface clock-show-weekday true

# Enable hot corner
gsettings set org.gnome.desktop.interface enable-hot-corners true

# Show battery percentage
gsettings set org.gnome.desktop.interface show-battery-percentage true

# Disable cursor blinking
gsettings set org.gnome.desktop.interface cursor-blink false

# Disable laptop middle click to avoid unwanted pasting
gsettings set org.gnome.desktop.interface gtk-enable-primary-paste false
