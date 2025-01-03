#!/usr/bin/env bash
set -e # This setting is telling the script to exit on a command error.
if [[ "$1" == "-v" ]]; then
  shift
	set -x # You refer to a noisy script.(Used to debugging)
fi

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- vallabhdas kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note       :- Init script
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

${SUDO} apt install xdotool

cd /tmp
${SUDO} rm -rf /tmp/jq $(pwd)/bin/jq
wget https://github.com/stedolan/jq/releases/latest/download/jq-linux64 -O jq
chmod +x /tmp/jq
echo '{"foo": 0}' | /tmp/jq .
mv /tmp/jq $(pwd)/bin

cd /tmp
${SUDO} rm -rf /tmp/JMESPath $(pwd)/bin/JMESPath
wget https://github.com/jmespath/jp/releases/latest/download/jp-linux-amd64 -O JMESPath
chmod +x /tmp/JMESPath
echo '{"a": "foo", "b": "bar", "c": "baz"}' | /tmp/JMESPath a
mv /tmp/JMESPath $(pwd)/bin

${SUDO} chmod +x $HOME/.vim/bin/*
