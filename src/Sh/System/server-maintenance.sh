#!/usr/bin/env bash
set -e # This setting is telling the script to exit on a command error.
if [[ "$1" == "-v" ]]; then
	set -x # You refer to a noisy script.(Used to debugging)
fi

echo ""
export
CURRENT_DATE=$(date "+%Y%m%d%H%M%S")
SCRIPT=$(readlink -f "")
SCRIPTDIR=$(dirname "$SCRIPT")

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note		  :-
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

Ref:- https://newbedev.com/disable-all-services-except-ssh
Disable all services, except ssh
emergency-net.target

[Unit]
Description=Maintenance Mode with Networking and SSH
Requires=maintenance.target systemd-networkd.service sshd.service
After=maintenance.target systemd-networkd.service sshd.service
AllowIsolate=yes

# systemctl isolate maintenance.target

# systemctl isolate multi-user.target
