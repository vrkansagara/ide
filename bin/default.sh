#!/usr/bin/env bash
# set -e # This setting is telling the script to exit on a command error.
# set -x # You refer to a noisy script.(Used to debugging)

echo -e "\n\n\n"
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

${SUDO} apt-get install alsa utils neofetch arandr --yes --no-install-recommends

echo "===========INFORMATION==========="
printf "Argument display is %s\n" "$display"
printf "Argument arg_1 is %s\n" "$arg_1"
echo "===========INFORMATION==========="

if [[ "$display" == 2 ]]; then
    echo "Selecting primary display"
     xrandr \
     --output eDP-1 --mode 1366x768 --pos 1920x0 --rotate normal \
     --output HDMI-1  --primary --mode 1920x1080 --pos 0x0 --rotate normal \
     --output DP-1 --off

elif [[ "$display" == 3 ]]; then
    xrandr \
    --output eDP-1 --mode 1366x768 --pos 3286x0 --rotate normal \
    --output HDMI-1 --mode 1920x1080 --pos 1366x0 --rotate normal --primary \
    --output DP-1 --mode 1366x768 --pos 0x0 --rotate normal
else
    echo "Current screen setting."
    xrandr \
    --output eDP-1 --mode 1366x768 --pos 0x0 --rotate normal --primary\
    --output HDMI-1 --off \
    --output DP-1 --off
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
gsettings set org.gnome.desktop.calendar show-weekdate true

# Enable hot corner
gsettings set org.gnome.desktop.interface enable-hot-corners true

# Show battery percentage
gsettings set org.gnome.desktop.interface show-battery-percentage true

# Disable cursor blinking
gsettings set org.gnome.desktop.interface cursor-blink false

# Disable laptop middle click to avoid unwanted pasting
gsettings set org.gnome.desktop.interface gtk-enable-primary-paste false

# Set Do not disturbe as ON ( By default )
gsettings set org.gnome.desktop.notifications show-banners true

# Set natural scrolling for touchpad and mouse
gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll true
gsettings set org.gnome.desktop.peripherals.mouse natural-scroll true

# Set right handed
gsettings set org.gnome.desktop.peripherals.mouse left-handed false

# Set default volume to unmute with 45% audio
# pactl list sinks short | awk '{print $2}'
#speaker
pactl set-default-sink alsa_output.usb-Jieli_Technology_UACDemoV1.0_1120022704060017-01.iec958-stereo
# Headphon
# pactl set-default-sink alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__hw_sofhdadsp__sink

pactl set-sink-mute @DEFAULT_SINK@ 0
pactl set-sink-volume @DEFAULT_SINK@ 45%

${SUDO} systemctl stop bluetooth

# set default brightness
$HOME/.vim/bin/brightness.sh set 15000
