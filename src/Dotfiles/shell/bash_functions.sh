Day() {
	printf $(date "+%e" | sed -e 's/\ //')

		case $(date +%d) in
		01 | 21 | 31) printf "${day}st" ;;
	02 | 22) printf "${day}nd" ;;
	03 | 23) printf "${day}rd" ;;
	*) printf "${day}th" ;;
	esac
}

Battery() {
	dir=/sys/class/power_supply/BAT0

		grep -q ^C "${dir}"/status && printf +
		cat "${dir}"/capacity
}

myNotifySend() {
#Detect the name of the display in use
	local display=":$(ls /tmp/.X11-unix/* | sed 's#/tmp/.X11-unix/X##' | head -n 1)"

#Detect the user using such display
		local user=$(who | grep '('$display')' | awk '{print $1}' | head -n 1)

#Detect the id of the user
		local uid=$(id -u $user)

		sudo -u $user DISPLAY=$display DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$uid/bus notify-send "$@"
}

which_term(){
	term=$(ps -p $(ps -p $$ -o ppid=) -o args=);
	found=0;
	case $term in
		*gnome-terminal*)
		found=1
		echo "gnome-terminal " $(dpkg -l gnome-terminal | awk '/^ii/{print $3}')
		;;
	*lxterminal*)
		found=1
		echo "lxterminal " $(dpkg -l lxterminal | awk '/^ii/{print $3}')
		;;
	rxvt*)
		found=1
		echo "rxvt " $(dpkg -l rxvt | awk '/^ii/{print $3}')
		;;
## Try and guess for any others
	*)
		for v in '-version' '--version' '-V' '-v'
			do
				$term "$v" &>/dev/null && eval $term $v && found=1 && break
					done
					;;
			esac
## If none of the version arguments worked, try and get the
## package version
				[ $found -eq 0 ] && echo "$term " $(dpkg -l $term | awk '/^ii/{print $3}')
}


