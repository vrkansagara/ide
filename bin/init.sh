#!/usr/bin/env bash

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi

PWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
cd $PWD

${SUDO} chmod +x *

${SUDO} apt-get install --yes --no-install-recommends \
xclip \
ufw gufw