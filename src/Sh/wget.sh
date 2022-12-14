#!/usr/bin/env bash
set -e # This setting is telling the script to exit on a command error.
if [[ "$1" == "-v" ]]; then
  set -x # You refer to a noisy script.(Used to debugging)
fi

echo " "
CURRENT_DATE="$(date "+%Y%m%d%H%M%S")"
export CURRENT_DATE
export DEBIAN_FRONTEND=noninteractive

if [ "$(whoami)" != "root" ]; then
  SUDO=sudo
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note       :- VIM compile from source.
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

${SUDO} apt-get install wget

wget --wait=2 \
  --level=inf \
  --limit-rate=20K \
  --recursive \
  --html-extension \
  --page-requisites \
  --user-agent=Mozilla \
  --no-parent \
  --convert-links \
  --adjust-extension \
  --no-clobber \
  -e robots=off \
  --domains example.com \
  https://example.com
