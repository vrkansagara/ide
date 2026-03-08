#!/bin/sh

# A dmenu binary prompt script.
# Gives a dmenu prompt labeled with $1 to perform command $2.
# For example:
# `./prompt "Are you sure to close all session?" "pkill -u $USER -9"`

[ "$(printf "No\\nYes" | dmenu -i -p "$1" -nb darkred -sb red -sf white -nf gray )" = "Yes" ] && $2
