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
#  Note		  :-
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

# Name: /usr/local/bin/audioswitch
# Usage: audioswitch; audioswitch 1; audioswitch 2;  audioswitch 3; audioswitch 4

CARD_1="pci-0000_03_00.1"             ### HDMI Audio Controller of NVidia GTX 660
CARD_1_PROFILE_1="hdmi-stereo"          # LG ULTRAWIDE
CARD_1_PROFILE_2="hdmi-stereo-extra1"   # LG TV
CARD_0="pci-0000_00_1b.0"             ### Built-in Audio
CARD_0_PROFILE_1="iec958-stereo"        # Digital Output
CARD_0_PROFILE_2="analog-stereo"        # Headphones

# Read the user's input
CHOICE="${@}"
choice() {
    if   [ "$CHOICE" == 1 ]; then CARD="$CARD_1"; PROF="$CARD_1_PROFILE_1" # LG ULTRAWIDE
    elif [ "$CHOICE" == 2 ]; then CARD="$CARD_1"; PROF="$CARD_1_PROFILE_2" # LG TV
    elif [ "$CHOICE" == 3 ]; then CARD="$CARD_0"; PROF="$CARD_0_PROFILE_1" # Digital Output
    elif [ "$CHOICE" == 4 ]; then CARD="$CARD_0"; PROF="$CARD_0_PROFILE_2" # Headphones
    else
        echo -e "\nYou should choice between:"
        echo -e "\n\t[1] LG ULTRAWIDE\n\t[2] LG TV\n\t[3] Digital Output\n\t[4] Headphones\n\t[5] Exit\n"
        echo -n "Your choice: "; read CHOICE; echo; choice; # call the function again
    fi
}; choice # call the function

# Set the choosen card profile as sink
pactl set-card-profile "alsa_card.${CARD}" "output:${PROF}";

# Set the default sink to the new one
pacmd set-default-sink "alsa_output.${CARD}.${PROF}" &> /dev/null

# Redirect the existing inputs to the new sink
for i in $(pacmd list-sink-inputs | grep index | awk '{print $2}'); do
    if [[ "$CHOICE" == "5" ]]; then
        exit
    fi
    pacmd move-sink-input "$i" "alsa_output.${CARD}.${PROF}" &> /dev/null
done

