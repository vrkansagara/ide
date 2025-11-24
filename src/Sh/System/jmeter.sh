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
#  Note		  :- Install jmeter
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

cd /tmp
JMETER_VERSION="apache-jmeter-5.6.3"
${SUDO} rm -rf "/tmp/$JMETER_VERSION*"

wget -k "https://dlcdn.apache.org//jmeter/binaries/${JMETER_VERSION}.tgz"
wget -k "https://www.apache.org/dist/jmeter/binaries/${JMETER_VERSION}.tgz.asc"
gpg --keyserver pgpkeys.mit.edu --recv-key C4923F9ABFB2F1A06F08E88BAC214CAA0612B399
#gpg --fingerprint C4923F9ABFB2F1A06F08E88BAC214CAA0612B399

gpg --verify "${JMETER_VERSION}.tgz.asc" "${JMETER_VERSION}.tgz"

if [ $? -eq 0 ]; then
  tar -xvf "${JMETER_VERSION}.tgz"
  mv "/tmp/${JMETER_VERSION}" /tmp/apache-jmeter
  rm -rf "$HOME/Applications/apache-jmeter"
  mv /tmp/apache-jmeter $HOME/Applications
else
  echo Problem with signature.
fi

${SUDO} chmod ugo+xr $HOME/Applications/apache-jmeter/bin/jmeter
echo "$HOME/Applications/apache-jmeter/bin/jmeter"
exit 0
