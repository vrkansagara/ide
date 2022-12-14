#!/usr/bin/env bash
set -e # This setting is telling the script to exit on a command error.
if [[ "$1" == "-v" ]]; then
  set -x # You refer to a noisy script.(Used to debugging)
fi


fonts_dir="${HOME}/.local/share/fonts"
if [ ! -d "${fonts_dir}" ]; then
	echo "mkdir -p $fonts_dir"
	mkdir -p "${fonts_dir}"
else
	echo "Found fonts dir $fonts_dir"
fi


# clone
git clone https://github.com/powerline/fonts.git --depth=1 /tmp/powerline
# install
cd /tmp/powerline
./install.sh
# clean-up a bit
rm -rf /tmp/powerline

echo "fc-cache -f -v"
fc-cache -f -v


echo "Powerline font installation [Done]."
