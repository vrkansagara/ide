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
#ref:- https://github.com/JuliaLang/julia
# https://github.com/JuliaLang/juliaup#mac-and-linux
cd /tmp

#curl -fsSL https://install.julialang.org | sh
curl -fsSL https://install.julialang.org | sh -s -- "$@"

exit 0
