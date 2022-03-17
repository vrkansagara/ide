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

echo " Docker related permission..."
${SUDO} apt-get install \
		apt-transport-https \
		ca-certificates \
		curl \
		gnupg \
		lsb-release
		${SUDO} curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
		if [ -f "/usr/bin/docker" ]; then
		${SUDO} chmod 666 /var/run/docker.sock
		${SUDO} groupadd docker
		${SUDO} usermod -aG docker ${USER}
		if [ -d "$HOME/$USER/.docker" ]; then
		${SUDO} chown "$USER":"$USER" /home/"$USER"/.docker -R
		${SUDO} chmod g+rwx "$HOME/.docker" -R
		fi
		fi


		if [ ! -f "/usr/bin/docker-compose" ]; then
		${SUDO} curl -L "https://github.com/docker/compose/releases/download/1.28.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
		${SUDO} chmod +x /usr/local/bin/docker-compose
		${SUDO} ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

		fi
		${SUDO} sysctl -w vm.max_map_count=262144
		echo "[DONE] Docker compose script "

		# curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
		# DRY_RUN=1 sh /tmp/get-docker.sh
