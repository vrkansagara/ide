#!/usr/bin/env bash

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
