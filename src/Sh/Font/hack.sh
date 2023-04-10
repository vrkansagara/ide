#!/usr/bin/env bash
set -e # This setting is telling the script to exit on a command error.
if [[ "$1" == "-v" ]]; then
  set -x # You refer to a noisy script.(Used to debugging)
fi


fonts_dir="${HOME}/.local/share/fonts"
mkdir -p $fonts_dir

if [ ! -d "${fonts_dir}" ]; then
	echo "mkdir -p $fonts_dir"
	mkdir -p "${fonts_dir}"
else
	echo "Found fonts dir $fonts_dir"
fi


# clone
# git clone https://github.com/source-foundry/Hack.git --depth=1 /tmp/font-Hack

mkdir -p cd /tmp/font-Hack
cd /tmp/font-Hack
wget https://github.com/source-foundry/Hack/releases/download/v3.003/Hack-v3.003-ttf.zip
unzip Hack-v3.003-ttf.zip
cd /tmp/font-Hack/ttf

cp * fonts_dir

echo "fc-cache -f -v"
fc-cache -f -v

echo "Checking hack font is installaed ?."

fc-list | grep "Hack"
echo "Hack font installation [Done]."
