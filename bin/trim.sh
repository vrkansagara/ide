#!/usr/bin/env bash

# set -e # This setting is telling the script to exit on a command error.
# set -x # You refer to a noisy script.(Used to debugging)
export DEBIAN_FRONTEND=noninteractive

if [ "$(whoami)" != "root" \]; then
	SUDO=sudo
fi

CURRENT_DATE=$(date "+%Y%m%d%H%M%S")

# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#  Maintainer :- Vallabh Kansagara<vrkansagara@gmail.com> — @vrkansagara
#  Note		  :- 
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

# sed -i 's/\x27NULL\x27/NULL/' FileName.sql # This will tream the 'NULL' with NULL (Useful for database)
# sed -i 's/123/456/' FileName.anything. # Useful for replacing 123 with 456 value
for i in *.php; do
	echo "Find and replace started for 'NULL' with NULL for [ $i ] started"
	# sed -i 's/\x27NULL\x27/NULL/' $i
	# sed -i '/namespace Database\\Seeders;/d' $i
done

