#!/usr/bin/env bash
set -e # This setting is telling the script to exit on a command error.
if [[ "$1" == "-v" ]]; then
  set -x # You refer to a noisy script.(Used to debugging)
fi

export CURRENT_DATE=$(date "+%Y%m%d%H%M%S")

if [ "$(whoami)" != "root" ]; then
  SUDO=sudo
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- vallabhdas kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note		  :- Installation script for the zaproxy
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


#https://github.com/zaproxy/zaproxy/releases/download/v2.14.0/ZAP_2_14_0_unix.sh
#https://software.opensuse.org/download.html?project=home%3Acabelo&package=owasp-zap

${SUDO} apt update
cd /tmp
wget https://github.com/zaproxy/zaproxy/releases/download/v2.14.0/ZAP_2_14_0_unix.sh
${SUDO} bash ZAP_2_14_0_unix.sh