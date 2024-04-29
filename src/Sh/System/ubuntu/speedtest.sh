#!/usr/bin/env bash
set -e # This setting is telling the script to exit on a command error.
if [[ "$1" == "-v" ]]; then
	set -x # You refer to a noisy script.(Used to debugging)
fi

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- vallabhdas kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note		  :- Kernel development reference. ( sanitize using shellcheck)
#  Note		  :- Make sure cron is installed (sudo apt-get install cron)
#  @url     :- https://www.speedtest.net/apps/cli
#  @usage   :- every 15 minutes.
# */15 * * * * sh /home/vrkansagara/.vim/src/Sh/System/ubuntu/speedtest.sh >> /dev/null 2>&1  (no output)
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

## If migrating from prior bintray install instructions please first...
# sudo rm /etc/apt/sources.list.d/speedtest.list
# sudo apt-get update
# sudo apt-get remove speedtest
## Other non-official binaries will conflict with Speedtest CLI
# Example how to remove using apt-get
# sudo apt-get remove speedtest-cli

if ! command -v shellcheck &>/dev/null; then
	echo "Install shellcheck for shell script sanitization"
	${SUDO} apt-get install shellcheck
fi

if ! command -v speedtest &>/dev/null; then
	echo "Install speed test for speedtest"
	${SUDO} apt-get install curl
	curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | ${SUDO} bash
	${SUDO} apt-get install speedtest
fi

#speedtest -p no > /tmp/speedtest-"${CURRENT_DATE}".txt
echo "Speed test started at [ $(date) ]" | tee -a  /tmp/speedtest.txt
speedtest --secure | tee -a  /tmp/speedtest.txt
