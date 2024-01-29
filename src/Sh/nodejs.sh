#!/usr/bin/env bash
set -ex # This setting is telling the script to exit on a command error.
if [[ "$1" == "-v" ]]; then
    set -x # You refer to a noisy script.(Used to debugging)
fi

export CURRENT_DATE=$(date "+%Y%m%d%H%M%S")
PWD=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

command_exists() {
    command -v "$@" >/dev/null 2>&1
}

if [ "$(whoami)" != "root" ]; then
    # Check if sudo is installed
    command_exists sudo || return 1
    SUDO=sudo
fi


node_latest() {
    # nodejs and npm  related stuff
    # Ref:- https://nodejs.dev/learn/update-all-the-nodejs-dependencies-to-their-latest-version
    #npm i  npm-check-updates node-sass
    npm install
    ./node_modules/.bin/ncu -u
    npm update
    ${SUDO} chmod -R a+x node_modules
    ${SUDO} chmod -R +x ./node_modules/.bin
    npm rebuild node-sass
}

nvm() {

    # ${SUDO} apt-get install curl

   export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

    command_exists nvm || echo "NVM command not found" && exit
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash

    nvm install node
    nvm install --latest-npm
    nvm use --latest-npm
    nvm install --lts
    nvm use --lts
}
main() {
  if [[ "$1" == "--nvm" ]]; then
    nvm
  fi
  if [[ "$1" == "--node_latest" ]]; then
    node_latest
  fi
}

main "$@"