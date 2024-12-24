#!/usr/bin/env bash
export CURRENT_DATE=$(date "+%Y%m%d%H%M%S")
export DEBIAN_FRONTEND=noninteractive

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi

${SUDO} apt update -y
${SUDO} apt upgrade -y
${SUDO} apt install nginx -y
${SUDO} systemctl enable nginx
${SUDO} systemctl start nginx

echo "instance created on ${CURRENT_DATE}" | sudo tee /var/www/html/index.nginx-debian.html