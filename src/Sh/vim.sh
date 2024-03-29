#!/usr/bin/env bash
set -e # This setting is telling the script to exit on a command error.
if [[ "$1" == "-v" ]]; then
	set -x # You refer to a noisy script.(Used to debugging)
fi

echo " "
CURRENT_DATE=$(date "+%Y%m%d%H%M%S")
export

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- vallabhdas kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note       :- VIM compile from source.
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

${SUDO} add-apt-repository ppa:jonathonf/vim
${SUDO} apt update
${SUDO} apt install --yes --no-install-recommends vim vim-gtk3

exit

${SUDO} apt update
APT_PACKAGE_TARGET="vim-gtk" # Ubuntu
${SUDO} apt-get purge ${APT_PACKAGE_TARGET}
${SUDO} apt-get build-dep ${APT_PACKAGE_TARGET}

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
	--disable-darwin \
	--disable-gpm \
	--disable-gtk2-check \
	--disable-gtktest \
	--disable-gui \
	--disable-largefile \
	--disable-netbeans \
	--disable-option-checking \
	--disable-selinux \
	--disable-sniff \
	--disable-sysmouse \
	--disable-workshop \
	--disable-xim \
	--disable-xsmp \
	--enable-cscope \
	--enable-fontset \
	--enable-multibyte \
	--enable-perlinterp \
	--enable-luainterp \
	--enable-python3interp=yes \
	--enable-pythoninterp=yes \
	--enable-rubyinterp=yes \
	--enable-fail-if-missing \
	--with-features=normal \
	--enable-gui=auto \
	--enable-gui=gtk2 \
	--with-x \
	--with-compiledby="vallabhdas kansagara <vrkansagara@gmail.com>" \
	--with-vim-name=vi \
	--with-features=huge \
	--prefix=/usr

make
${SUDO} rm -rf /usr/local/bin/vim /usr/share/vim/
${SUDO} make install
