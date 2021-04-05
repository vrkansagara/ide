#!/usr/bin/env bash

fonts_dir="${HOME}/.local/share/fonts"
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
