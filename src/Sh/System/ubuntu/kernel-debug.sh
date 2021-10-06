









echo "deb http://ddebs.ubuntu.com $(lsb_release -cs) main restricted universe multiverse" | sudo tee /etc/apt/sources.list.d/ddebs.list
wget -O - http://ddebs.ubuntu.com/dbgsym-release-key.asc | sudo apt-key add -

sudo apt-get update

sudo apt-get install linux-image-`uname -r`-dbgsym

