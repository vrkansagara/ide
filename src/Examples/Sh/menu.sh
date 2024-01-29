#!/usr/bin/env bash
PS3="Select menu item: "
items=(
  "MenuMenuMenuMenuMenuMenuMenuMenuMenuMenu 1 \n"
  "MenuMenuMenuMenuMenuMenuMenuMenuMenuMenu 2"
  "MenuMenuMenuMenuMenuMenuMenuMenuMenuMenu 3"
  "MenuMenuMenuMenuMenuMenuMenuMenuMenuMenu 4"
)

while true; do
    select item in "${items[@]}" Quit
    do
        case $REPLY in
            1) echo "Selected item #$REPLY which means $item"; break;;
            2) echo "Selected item #$REPLY which means $item"; break;;
            3) echo "Selected item #$REPLY which means $item"; break;;
            4) echo "Selected item #$REPLY which means $item"; break;;
            $((${#items[@]}+1))) echo "We're done!"; break 2;;
            *) echo "Ooops - unknown choice $REPLY"; break;
        esac
    done
done