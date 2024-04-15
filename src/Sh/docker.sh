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
#  Note       :-
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


echo " Lets remove Docker related stuff..."
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

echo " Docker related permission..."
# Add Docker's official GPG key:
${SUDO} apt-get update
${SUDO} apt-get install ca-certificates curl
${SUDO} install -m 0755 -d /etc/apt/keyrings
${SUDO} curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
${SUDO} chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
          $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
  ${SUDO} tee /etc/apt/sources.list.d/docker.list >/dev/null
${SUDO} apt-get update

${SUDO} apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

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

#${SUDO} sysctl -w vm.max_map_count=262144
${SUDO} systemctl restart docker
docker run hello-world
echo "[DONE] Docker compose script "

# curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
# DRY_RUN=1 sh /tmp/get-docker.sh
