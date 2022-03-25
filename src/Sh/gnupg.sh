#!/usr/bin/env bash
# set -e # This setting is telling the script to exit on a command error.
# set -x # You refer to a noisy script.(Used to debugging)

echo " "
export DEBIAN_FRONTEND=noninteractive
CURRENT_DATE=$(date "+%Y%m%d%H%M%S")
SCRIPT=$(readlink -f "")
SCRIPTDIR=$(dirname "$SCRIPT")

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note		  :-
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

${SUDO} apt-get install -y --reinstall --no-install-recommends gnupg2
${SUDO} mkdir $HOME/.gnupg
# To fix the " gpg: WARNING: unsafe permissions on homedir '/home/path/to/user/.gnupg' " error
# Make sure that the .gnupg directory and its contents is accessibile by your user.
${SUDO} chown -R $USER ~/.gnupg/

# Also correct the permissions and access rights on the directory
${SUDO} chmod 600 ~/.gnupg/*
${SUDO} chmod 700 ~/.gnupg

# gpg --output public.pgp --armor --export username@email
# gpg --output private.pgp --armor --export-secret-key username@email

# gpg --default-new-key-algo rsa4096 --gen-key
# Generate a new pgp key: (better to use gpg2 instead of gpg in all below commands)
# gpg --gen-key
# maybe you need some random work in your OS to generate a key. so run this command: `find ./* /home/username -type d | xargs grep some_random_string > /dev/null`

# check current keys:
gpg --list-secret-keys --keyid-format LONG

# See your gpg public key:
# gpg --armor --export YOUR_KEY_ID
# YOUR_KEY_ID is the hash in front of `sec` in previous command. (for example sec 4096R/234FAA343232333 => key id is: 234FAA343232333)

# Set a gpg key for git:
# git config --global user.signingkey your_key_id

# To sign a single commit:
# git commit -S -a -m "Test a signed commit"

# Auto-sign all commits globaly
git config --global commit.gpgsign true

${SUDO} killall gpg-agent
echo "test" | gpg --clearsign
