#!/usr/bin/env bash
set -e # This setting is telling the script to exit on a command error.
if [[ "$1" == "-v" ]]; then
	set -x # You refer to a noisy script.(Used to debugging)
fi

echo
CURRENT_DATE=$(date "+%Y%m%d%H%M%S")
export

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note		  :-
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

${SUDO} apt-get install -y ruby-full build-essential zlib1g-dev

echo '# Install Ruby Gems to ~/gems' >>~/.bashrc
echo 'export GEM_HOME="$HOME/gems"' >>~/.bashrc
echo 'export PATH="$HOME/gems/bin:$PATH"' >>~/.bashrc
source ~/.bashrc

${SUDO} gem install jekyll bundler

${SUDO} gem update --system

# Example
# jekyll new /tmp/myblog
# cd /tmp/myblog
# bundle exec jekyll serve  OR bundle exec jekyll serve --livereload
