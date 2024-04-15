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
#  Note       :- https://3v4l.org/about
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

# When I started in 2012, this site was nothing more than a small bash script that looped through all available PHP binaries and stored the output in /out/. For fun; here is the source-code of the script that I started with:

ulimit -f 64 -m 64 -t 2 -u 128

[[ ! -d /out/$1/ ]] && mkdir /out/$1/ || chmod u+w /out/$1/

for bin in /bin/php-*; do
	echo $bin - $1
	nice -n 15 sudo -u nobody $bin -c /etc/ -q "/in/$1" &>/out/$1/${bin##*-} &
	PID=$!
	(
		sleep 3.1
		kill -9 $PID 2>/dev/null
	) &
	wait $PID
	ex=$?

	sf=/out/$1/${bin##*-}-exit
	[[ $ex -eq 0 && -f $sf ]] && rm $sf
	[[ $ex -ne 0 ]] && echo -n $ex >$sf
done

chmod u-w /out/$1/
