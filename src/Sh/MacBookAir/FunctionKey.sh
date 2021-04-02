#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

if [ "$(whoami)" != "root" ]; then
    SUDO=sudo
fi

echo "This will invert the function key"

${SUDO} cat /sys/module/hid_apple/parameters/fnmode

${SUDO} sudo bash -c "echo 2 > /sys/module/hid_apple/parameters/fnmode"

# echo options hid_apple fnmode=2 | ${SUDO} tee -a /etc/modprobe.d/hid_apple.conf
# ${SUDO} update-initramfs -u -k all
# ${SUDO} reboot # optional

echo "[DONE] MacBokAir Specific setting updated"

exit 0
