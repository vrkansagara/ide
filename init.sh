#!/usr/bin/env bash
set -e # This setting is telling the script to exit on a command error.
if [[ "$1" == "-v" ]]; then
  set -x # You refer to a noisy script.(Used to debugging)
  shift
fi

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- vallabhdas kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note       :- Init script
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

${SUDO} apt-get clean
${SUDO} apt-get autoremove
${SUDO} apt-get update
${SUDO} apt-get upgrade -V

${SUDO} apt install -y \
  git \
  gitk \
  htop \
  nmap \
  elinks \
  arandr \
  gufw \
  ufw \
  zsh \
  curl \
  xdotool \
  cpulimit \
  guake


# Install zsh and set default shell to zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  chsh -s $(which zsh)
fi

mkdir -p $HOME/www $HOME/git/vrkansagara $HOME/Applications

if [ ! -f "$HOME/.vim/bin/jq" ]; then
  cd /tmp
  ${SUDO} rm -rf /tmp/jq $(pwd)/bin/jq
  wget https://github.com/stedolan/jq/releases/latest/download/jq-linux64 -O jq
  chmod +x /tmp/jq
  echo '{"foo": 0}' | /tmp/jq .
  mv /tmp/jq $(pwd)/bin
fi


if [ ! -f "$HOME/.vim/bin/JMESPath" ]; then
  cd /tmp
  ${SUDO} rm -rf /tmp/JMESPath $(pwd)/bin/JMESPath
  wget https://github.com/jmespath/jp/releases/latest/download/jp-linux-amd64 -O JMESPath
  chmod +x /tmp/JMESPath
  echo '{"a": "foo", "b": "bar", "c": "baz"}' | /tmp/JMESPath a
  mv /tmp/JMESPath $(pwd)/bin
fi

${SUDO} chmod +x $HOME/.vim/bin/*