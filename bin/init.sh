#!/usr/bin/env bash

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi

${SUDO} chmod +x *

${SUDO} apt-get install --yes --no-install-recommends \
xclip