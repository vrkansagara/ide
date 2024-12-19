#!/usr/bin/env bash
set -e # This setting is telling the script to exit on a command error.
if [[ "$1" == "-v" ]]; then
  shift
  set -x # You refer to a noisy script.(Used to debugging)
fi

PWD=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

command_exists() {
  command -v "$@" >/dev/null 2>&1
}

if [ "$(whoami)" != "root" ]; then
  # Check if sudo is installed
  command_exists sudo || return 1
  SUDO=sudo
fi

nodeLatest() {
  # nodejs and npm  related stuff
  # Ref:- https://nodejs.dev/learn/update-all-the-nodejs-dependencies-to-their-latest-version
  #npm i  npm-check-updates node-sass
  npm install
  ${SUDO} chmod -R a+x node_modules
  ${SUDO} chmod -R +x ./node_modules/.bin

  ./node_modules/.bin/ncu -u
  npm update
  npm rebuild node-sass --force
}

nodejsInstall() {
    nvm install node
    nvm install --latest-npm
    nvm use --latest-npm
    nvm install --lts
    nvm use --lts
}

nvmInstall() {
  command_exists nvm && echo "NVM command found, Exit" && exit

  ${SUDO} apt-get install curl

  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash


}
main() {
  if [[ "$1" == "--nvm" ]]; then
    nvmInstall
    shift
  fi

  if [[ "$1" == "--nodejs" ]]; then
    nodejsInstall
    shift
  fi

  if [[ "$1" == "--node-latest" ]]; then
    nodeLatest
    shift
  fi
}

main "$@"
