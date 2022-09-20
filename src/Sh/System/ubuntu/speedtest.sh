#!/usr/bin/env bash
# set -e # This setting is telling the script to exit on a command error.
# set -x # You refer to a noisy script.(Used to debugging)

echo ""
export DEBIAN_FRONTEND=noninteractive
CURRENT_DATE=$(date "+%Y%m%d%H%M%S")
SCRIPT=$(readlink -f "")
SCRIPTDIR="$(dirname "$SCRIPT")"
export SCRIPTDIR

if [ "$(whoami)" != "root" ]; then
    SUDO=sudo
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note		  :- Kernel development reference. ( sanitize using shellcheck)
#  @url     :- https://www.speedtest.net/apps/cli
#  @usage   :- every 15 minutes.
# */15 * * * * sh /home/vallabh/.vim/src/Sh/System/ubuntu/speedtest.sh >> /dev/null 2>&1  (no output)
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

## If migrating from prior bintray install instructions please first...
# sudo rm /etc/apt/sources.list.d/speedtest.list
# sudo apt-get update
# sudo apt-get remove speedtest
## Other non-official binaries will conflict with Speedtest CLI
# Example how to remove using apt-get
# sudo apt-get remove speedtest-cli

if ! command -v speedtest &> /dev/null
then
	echo "Install speedtest for speedtest"
	${SUDO} apt-get install curl
  curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | ${SUDO} bash
  ${SUDO} apt-get install speedtest
fi

speedtest -p no > /tmp/speedtest-"${CURRENT_DATE}".txt

