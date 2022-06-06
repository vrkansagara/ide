#!/usr/bin/env bash
# set -e # This setting is telling the script to exit on a command error.
# set -x # You refer to a noisy script.(Used to debugging)

echo -e " "
export DEBIAN_FRONTEND=noninteractive
CURRENT_DATE=$(date "+%Y%m%d%H%M%S")
SCRIPT=$(readlink -f "")
SCRIPTDIR=$(dirname "SCRIPT")

if [ "$(whoami)" != "root" ]; then
    SUDO=sudo
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note       :- Set my default configuration for the working style.
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
while getopts ":a:d:" opt; do
    case $opt in
        a) arg_1="$OPTARG"
            ;;
        d) display="$OPTARG"
            ;;
        \?) echo "Invalid option -$OPTARG" >&2
            exit 1
            ;;
    esac

    case $OPTARG in
        -*) echo "Option $opt needs a valid argument"
            exit 1
            ;;
    esac
done

${SUDO} apt-get install neofetch arandr --yes --no-install-recommends

echo "===========INFORMATION==========="
printf "Argument display is %s\n" "$display"
printf "Argument arg_1 is %s\n" "$arg_1"
echo "===========INFORMATION==========="

echo -e "\n\n\n"


if [[ "$display" == 1 ]]; then
    echo "Selecting primary display"
    xrandr --output eDP-1 --primary --mode 1366x768 --pos 0x0 --rotate normal --output HDMI-1 --off --output DP-1 --off
else
    echo "External monitor enabling..."
    # xrandr --output HDMI-1 --off --auto --same-as eDP-1
    xrandr --output eDP-1 --primary --mode 1366x768 --pos 0x0 --rotate normal --output HDMI-1 --mode 1366x768 --pos 1366x0 --rotate normal --output DP-1 --off
    # xrandr --output eDP-1 --primary --mode 1366x768 --pos 0x399 --rotate normal --output HDMI-1 --off --output DP-1 --off --output DP-1-1 --off --output DP-1-2 --mode 2560x1440 --pos 1366x0 --rotate normal --output DP-1-3 --off
fi

# Check list of timezones which is available into system.
# timedatectl list-timezones | grep -i Europ

# Set default timeszone for the current system
# ${SUDO} timedatectl set-timezone Europe/Amsterdam
${SUDO} timedatectl set-timezone Asia/Kolkata

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
