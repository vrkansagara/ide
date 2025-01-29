#!/usr/bin/env bash
set -e # This setting is telling the script to exit on a command error.
if [[ "$1" == "-v" ]]; then
  set -x # You refer to a noisy script.(Used to debugging)
  shift
fi

if [ "$(uname -s)" == 'Darwin' ]; then
  echo "This script does not support Mac Os"
  exit 0
fi

if [ "$(whoami)" != "root" ]; then
  sudo="sudo"
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  maintainer :- vallabhdas kansagara<vrkansagara@gmail.com> — @vrkansagara
#  note		    :- lets compatible grub to work with older hardware
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

$sudo cp /etc/default/grub $HOME/.vim/backup/grub-$(date "+%Y%m%d%H%M%S")

#GRUB_CMDLINE_LINUX_DEFAULT="quiet splash intel_idle.max_cstate=1 fsck.mode=force fsck.repair=yes intel_iommu=igfx_off"
$sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash intel_idle.max_cstate=1 fsck.mode=force fsck.repair=yes intel_iommu=igfx_off"/' /etc/default/grub

$sudo update-grub
$sudo update-initramfs

exit 0
