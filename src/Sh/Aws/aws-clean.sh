#!/usr/bin/env bash
set -e # This setting is telling the script to exit on a command error.
shopt -s extglob
if [[ "$1" == "-v" ]]; then
	set -x # You refer to a noisy script.(Used to debugging)
fi

export DEBIAN_FRONTEND=noninteractive
export CURRENT_DATE=$(date "+%Y%m%d%H%M%S")
export GREEN=$'\e[0;32m'
export RED=$'\e[0;31m'
export NC=$'\e[0m'
export PWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

echo "$GREEN Script started at $CURRENT_DATE $NC"
cd $PWD

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi

command_exists() {
  command -v "$@" >/dev/null 2>&1
}

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- vallabhdas kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note       :- lets clean aws account resource(s)
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


cleanS3(){
  echo "$GREEN Available s3 bucket(s) $NC"
  aws s3 ls --profile "$1"
  echo "$RED Removing all s3 bucket(s) $NC"
  aws s3 ls --profile "$1" | awk '{print $3}' |  xargs -I {} sh -c "aws s3 rb --force s3://{} --profile $1"
}

main() {
  if [[ "$1" == "--s3" ]]; then
    shift
    cleanS3 $1
  fi
}

main "$@"
echo "$GREEN Script end at $(date "+%Y%m%d%H%M%S") $NC"