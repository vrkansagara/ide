#!/usr/bin/env bash
# set -e # This setting is telling the script to exit on a command error.
# set -x # You refer to a noisy script.(Used to debugging)

echo
CURRENT_DATE=$(date "+%Y%m%d%H%M%S")
export DEBIAN_FRONTEND=noninteractive

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note		  :-
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
/usr/bin/cpulimit -l 40 ~/Applications/phpStorm/bin/phpstorm.sh &
/usr/bin/cpulimit -l 40 /usr/bin/google-chrome &
/usr/bin/cpulimit -l 40 /usr/bin/firefox &

# /usr/bin/cpulimit -l 20 ~/Application/robo3t-1.4.3-linux-x86_64-48f7dfd/bin/robo3t &
/usr/bin/cpulimit -l 20 /snap/bin/skype &
/usr/bin/cpulimit -l 20 /usr/bin/keepassxc &
/usr/bin/cpulimit -l 20 /usr/share/teams/teams &
/usr/bin/cpulimit -l 20 /usr/bin/obs &

/usr/bin/cpulimit -l 10 /snap/bin/postman &
/usr/bin/cpulimit -l 10 /usr/bin/openfortigui &
/usr/bin/cpulimit -l 5 /usr/bin/clipit &

# cd /home/vallabh/htdocs/adminMongo
# /usr/bin/cpulimit -l 10 /usr/local/bin/yarn start &

