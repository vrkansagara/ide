#!/usr/bin/env bash
set -e # This setting is telling the script to exit on a command error.
shopt -s extglob

if [[ "$1" == "-v" ]]; then
  set -x # You refer to a noisy script.(Used to debugging)
  shift
fi

if [ "$(whoami)" != "root" ]; then
  sudo="sudo"
fi

export GREEN=$'\e[0;32m'
export RED=$'\e[0;31m'
export NC=$'\e[0m'

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- vallabhdas kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Ref        :- my firewall my way
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

flushIptables() {
  $sudo ufw reset
  echo "$RED firewall rule(s) are flushed $NC "
}

function default() {
  $sudo ufw enable
  # Lets deny in and out both ( Only allow policy )
  $sudo ufw default deny outgoing
  $sudo ufw default deny incoming

  # Mind the gap ( SSH ..... DO NOT CHANGE)
  # ssh -T git@github.com
  sudo ufw deny in 22/tcp
  sudo ufw allow out 22/tcp

  # Allow only...

  # Webserver
  sudo ufw allow in 80/tcp
  sudo ufw allow out 80/tcp
  sudo ufw allow in 443/tcp
  sudo ufw allow out 443/tcp
  sudo ufw allow out to any port 53

  # Email stuff
  $sudo ufw allow in smtp
  $sudo ufw reject out smtp

  # Speedtest.net
  sudo ufw allow out to any port 5060
  sudo ufw allow out to any port 8080
  sudo ufw allow out to any port 554
}

main() {
  if [[ "$1" == "--start" ]]; then
    shift
    $sudo ufw enable
  fi

  if [[ "$1" == "--stop" ]]; then
    shift
    $sudo ufw enable
  fi

  if [[ "$1" == "--flush" ]]; then
    shift
    flushIptables
  fi

  if [[ "$1" == "--status" ]]; then
    shift
    $sudo ufw status verbose
  fi

  if [[ "$1" == "--default" ]]; then
    shift
    default
    $sudo ufw reload
  fi

  if [[ "$1" == "--log" ]]; then
    shift
    $sudo dmesg -w | grep '\[UFW'
  fi
}

main "$@"