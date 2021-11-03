#!/usr/bin/env bash
# set -e # This setting is telling the script to exit on a command error.
# set -x # You refer to a noisy script.(Used to debugging)

echo " "
CURRENT_DATE=$(date "+%Y%m%d%H%M%S")
export DEBIAN_FRONTEND=noninteractive

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note		  :- VIM compile from source.
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
${SUDO} apt-get purge vim vim-runtime gvim
${SUDO} apt-get build-dep vim vim-common vim-gtk vim-runtime gvim

# ${SUDO} apt-get install --yes --no-install-recommends software-properties-common
# git make ncurses-dev build-essential  libncurses5-dev \
# libgtk2.0-dev libatk1.0-dev \
# libcairo2-dev python-dev \
# python3-dev git build-dep vim libxtst-dev libx11-dev libxt-dev libsm-dev \
# libxpm-dev ack ack-grep

TMPDIRECOTORY="$HOME/tmp/latest"
mkdir -p ${TMPDIRECOTORY}

git clone https://github.com/vim/vim.git --depth 1 -b master ${TMPDIRECOTORY}
cd "${TMPDIRECOTORY}/vim"
git stash
git reset --hard HEAD
git clean -fd


${SUDO} make distclean
./configure \
	--disable-acl \
	--disable-darwin                          \
	--disable-gpm                             \
	--disable-gtk2-check                      \
	--disable-gtktest                         \
	--disable-gui                             \
	--disable-largefile                       \
	--disable-netbeans                        \
	--disable-option-checking                 \
	--disable-selinux                         \
	--disable-sniff                           \
	--disable-sysmouse                        \
	--disable-workshop                        \
	--disable-xim                             \
	--disable-xsmp							  \

	--enable-cscope                           \
	--enable-fontset                          \
	--enable-multibyte                        \
	--enable-perlinterp                       \
	--enable-luainterp                        \
	--enable-python3interp=yes                \
	--enable-pythoninterp=yes                 \
	--enable-rubyinterp=yes                   \
	--enable-fail-if-missing                  \

	--with-features=normal                    \
	--enable-gui=auto                         \
	--enable-gui=gtk2 \

	--with-x                                  \
	--with-compiledby="Vallabh Kansagara <vrkansagara@gmail.com>" \
	--with-vim-name=vi                        \
	--with-features=huge                      \

	--prefix=/usr

	make
	${SUDO} rm -rf /usr/local/bin/vim /usr/share/vim/
	${SUDO} make install
