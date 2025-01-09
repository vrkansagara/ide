#!/usr/bin/env bash
set -e # This setting is telling the script to exit on a command error.
if [[ "$1" == "-v" ]]; then
  set -x # You refer to a noisy script.(Used to debugging)
  shift
fi

if [ "$(uname -s)" == 'Darwin' ]; then
  echo "This script does not support Mac Os"
  exit 0
fi

if [ "$(whoami)" != "root" ]; then
  sudo="sudo"
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  maintainer :- vallabhdas kansagara<vrkansagara@gmail.com> — @vrkansagara
#  note		    :- debian base distro, add current user to sudo list
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

$sudo touch /etc/sudoers.d/90-cloud-init-users

# User rules for (only tee - replace file)
echo "$USER ALL=(ALL) NOPASSWD:ALL" | $sudo tee /etc/sudoers.d/90-cloud-init-users

echo "User [$USER] does not require to enter password."
exit 0
