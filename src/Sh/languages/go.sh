#!/usr/bin/env bash

set -e # This setting is telling the script to exit on a command error.

if [[ "$1" == "-v" ]]; then
  set -x # You refer to a noisy script.(Used to debugging)
fi

# Ref:- https://go.dev/doc/install

if [ "$(whoami)" != "root" ]; then
  SUDO=sudo
fi

version="go1.22.2.linux-amd64.tar.gz"
${SUDO} rm -rf "/tmp/$version"
cd /tmp
wget https://go.dev/dl/$version

${SUDO} rm -rf /usr/local/go
${SUDO} tar -C /usr/local -xzf go1.22.2.linux-amd64.tar.gz

# export PATH=$PATH:/usr/local/go/bin

#tar -xvf "$version"
#cd "/tmp/go"
#./bin/go version
