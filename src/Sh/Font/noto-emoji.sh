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

file_path="${HOME}/.local/share/fonts/NotoColorEmoji.ttf"
file_url="https://github.com/googlefonts/noto-emoji/blob/main/fonts/NotoColorEmoji.ttf?raw=true"
if [ ! -e "${file_path}" ]; then
    echo "wget -O $file_path $file_url"
    wget -O "${file_path}" "${file_url}"
else
    echo "Found existing file $file_path"
fi;

echo "fc-cache -f -v"
fc-cache -f -v

fc-list | grep -i emoji
echo "NotoColorEmoji font installation [Done]."
exit 0
