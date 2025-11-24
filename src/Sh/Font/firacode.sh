#!/usr/bin/env bash
set -e # This setting is telling the script to exit on a command error.
if [[ "$1" == "-v" ]]; then
  set -x # You refer to a noisy script.(Used to debugging)
  shift
fi

#fonts_dir="${HOME}/.local/share/fonts"
#if [ ! -d "${fonts_dir}" ]; then
#	echo "mkdir -p $fonts_dir"
#	mkdir -p "${fonts_dir}"
#else
#	echo "Found fonts dir $fonts_dir"
#fi
#
#for type in Bold Light Medium Regular Retina; do
#	file_path="${HOME}/.local/share/fonts/FiraCode-${type}.ttf"
#	file_url="https://github.com/tonsky/FiraCode/blob/master/distr/ttf/FiraCode-${type}.ttf?raw=true"
#	if [ ! -e "${file_path}" ]; then
#		echo "wget -O $file_path $file_url"
#		wget -O "${file_path}" "${file_url}"
#	else
#		echo "Found existing file $file_path"
#	fi;
#done

${SUDO} apt install fonts-firacode

echo "fc-cache -f -v"
fc-cache -f -v

echo "Fira code font installation [Done]."
exit 0
