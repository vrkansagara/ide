#!/bin/bash

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi

if [ ! -f "/usr/bin/docker-compose" ]; then
	${SUDO} curl -L "https://github.com/docker/compose/releases/download/1.28.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
	${SUDO} chmod +x /usr/local/bin/docker-compose
	${SUDO} ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

fi

echo "[DONE] Docker compose script "
exit 0
