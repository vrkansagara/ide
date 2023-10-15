#!/usr/bin/env bash
set -e # This setting is telling the script to exit on a command error.
if [[ "$1" == "-v" ]]; then
	set -x # You refer to a noisy script.(Used to debugging)
fi

export

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi

CURRENT_DATE=$(date "+%Y%m%d%H%M%S")

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note		  :-
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
${SUDO} apt-get install apt-transport-https
${SUDO} apt-get install apt-transport-https
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | ${SUDO} tee /etc/apt/sources.list.d/elastic-7.x.list
${SUDO} apt-get update && ${SUDO} apt-get install elasticsearch

exit

# /etc/security/limits.conf
# Ensure ElasticSearch can open files and lock memory!
elasticsearch soft nofile 65536
elasticsearch hard nofile 65536
elasticsearch - memlock unlimited

# /etc/security/limits.conf,
# allow user 'elasticsearch' mlockall
elasticsearch soft memlock unlimited
elasticsearch hard memlock unlimited
