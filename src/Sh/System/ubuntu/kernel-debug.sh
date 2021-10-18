









echo "deb http://ddebs.ubuntu.com $(lsb_release -cs) main restricted universe multiverse" | sudo tee /etc/apt/sources.list.d/ddebs.list
wget -O - http://ddebs.ubuntu.com/dbgsym-release-key.asc | sudo apt-key add -

sudo apt-get update

sudo apt-get install linux-image-`uname -r` linux-image-`uname -r`-dbgsym linux-headers-`uname -r`

# https://askubuntu.com/questions/197016/how-to-install-a-package-that-contains-ubuntu-kernel-debug-symbols
# https://wiki.ubuntu.com/DebuggingProgramCrash#Debug_Symbol_Packages

echo "deb http://ddebs.ubuntu.com $(lsb_release -cs) main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list.d/ddebs.list
echo "deb http://ddebs.ubuntu.com $(lsb_release -cs)-updates main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list.d/ddebs.list
echo "deb http://ddebs.ubuntu.com $(lsb_release -cs)-proposed main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list.d/ddebs.list
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ECDCAD72428D7C01
sudo apt-get update

# "This is rather huge (>680MB), so prepare for a wait"
sudo apt-get install -y linux-image-`uname -r`-dbgsym

# "automatically build debug symbol ddeb packages"
#   for any subsequent Kernel builds / installs
sudo apt-get install -y pkg-create-dbgsym

sudo apt-get install gdb


# ibm reference
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C8CAB6595FDFF622
echo "deb http://ddebs.ubuntu.com $(lsb_release -cs) main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list.d/ddebs.list
echo "deb http://ddebs.ubuntu.com $(lsb_release -cs)-updates main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list.d/ddebs.list

sudo apt-get install linux-image-$(uname -r)-dbgsym


#### Debian

echo "deb http://deb.debian.org/debian-debug/ `lsb_release -sc`-debug main" | sudo tee -a /etc/apt/sources.list.d/ddebs.list
echo "deb http://deb.debian.org/debian-debug/ `lsb_release -sc`-proposed-updates-debug main" | sudo tee -a /etc/apt/sources.list.d/ddebs.list
