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


# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- vallabhdas kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note		    :- Mac machine helper
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

# diskutil list
# sudo diskutil eraseDisk FAT32 SCANDISKBAC /dev/disk5

home_permission_mac() {
	chflags -R nouchg $HOME
	diskutil resetUserPermissions / $(id -u)
	# Rename of username using ibm https://www.ibm.com/support/pages/resetting-home-directory-permissions-macos
	#  Reset permissions on the failing profile.
	#  Open the Terminal.app and type: diskutil resetUserPermissions / `id -u`
	#  If you get a message saying "permissions reset on user home directory failed (error -69841)", enter: chflags -R nouchg ~
	#  Then, enter the diskutil command again: diskutil resetUserPermissions / `id -u`

	#  (Note: The quotation marks used are "back" quotation marks. To create a "back" quotation mark, press the ` key.
	#  This key is located directly under the Esc key. This key is also used for typing the tilde ( ~ ) character.)
}

main(){

  if [[ "$1" == "--home-permission" ]]; then
    echo "Seting Home directory permission as per MacOS standard"
    home_permission_mac
  fi

  if [[ "$1" == "--brew" ]]; then
    if ! command -v brew &>/dev/null; then
    	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
    	brew update
    	brew doctor
    fi
  fi

  if [[ "$1" == "--flush" ]]; then
    echo "Flushing the cache"

    echo "Display content cache settings. => $ AssetCacheManagerUtil settings"
    echo "Display content cache status. => $ AssetCacheManagerUtil status"
    echo "Find out whether content caching can be turned on. => $ AssetCacheManagerUtil canActivate"
    echo "Find out whether content caching is on. => $ AssetCacheManagerUtil isActivated"
    echo "Import an existing cache from another computer. => $ sudo AssetCacheManagerUtil absorbCacheFrom /Volumes/SomeVolume/Library/Application\ Support/Apple/AssetCache/Data read-only"
    echo "Move an existing cache to another computer. => $ sudo AssetCacheManagerUtil moveCacheTo /Volumes/SomeVolume/Library/Application\ Support/Apple/AssetCache/Data"
    echo "Reload the content cache settings. => $ sudo AssetCacheManagerUtil reloadSettings"
    echo "Remove all cached content. => $ sudo AssetCacheManagerUtil flushCache"
    echo "Remove all cached iCloud content. => $ sudo AssetCacheManagerUtil flushPersonalCache"
    echo "Remove all cached shared (non-iCloud) content. => $ sudo AssetCacheManagerUtil flushSharedCache"
    echo "Turn off content caching. => $ sudo AssetCacheManagerUtil deactivate"
    echo "Turn on content caching. => $ sudo AssetCacheManagerUtil activate"

  ${SUDO} AssetCacheManagerUtil flushCache
  ${SUDO} AssetCacheManagerUtil flushPersonalCache
  ${SUDO} AssetCacheManagerUtil flushSharedCache
  ${SUDO} AssetCacheManagerUtil reloadSettings

    ${SUDO} dscacheutil -flushcache
    ${SUDO} killall -HUP mDNSResponder
    # How to drop memory caches in macOS?
    sync && ${SUDO} purge
    ${SUDO} du -sh /Library/Caches/* | sort -h

# https://support.apple.com/en-in/guide/deployment/depfaba5bc52/web
    AssetCacheManagerUtil settings

  fi
}
main "$@"