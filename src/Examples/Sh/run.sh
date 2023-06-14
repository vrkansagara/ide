#!/usr/bin/env bash
set -e # This setting is telling the script to exit on a command error.
if [[ "$1" == "-v" ]]; then
  set -x # You refer to a noisy script.(Used to debugging)
fi

echo ""
export DEBIAN_FRONTEND=noninteractive
CURRENT_DATE=$(date "+%Y%m%d%H%M%S")

if [ "$(whoami)" != "root" ]; then
SUDO=sudo
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note		  :- https://tldp.org/LDP/abs/html/io-redirection.html
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

start=$(date +"%s")

bold=$(tput bold)
normal=$(tput sgr0)
echo "this is ${bold}bold${normal} but this isn't"

stop=$(date +"%s")

executionTime=$(($stop-$start))
echo "$(($executionTime / 60)) minutes and $(($executionTime % 60)) seconds elapsed."
