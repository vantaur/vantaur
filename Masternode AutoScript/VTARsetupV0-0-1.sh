#!/bin/bash
#Vtar install Script
apt-get update -y
apt-get upgrade -y
fallocate -l 4G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
apt-get install build-essential -y
apt-get install htop -y
apt-get install software-properties-common python-software-properties -y
apt-get install libdb++-dev -y
apt-get install miniupnpc -y
apt-get install libssl-dev -y
apt-get install libboost-all-dev -y
apt-get install libqrencode-dev -y
apt-get install libgmp3-dev -y
apt-get install libminiupnpc-dev -y
apt-get install libtool -y
apt-get install libgmp-dev -y
apt-get install libevent-dev -y
apt-get install dh-autoreconf -y
apt-get install autoconf -y
apt-get install automake -y
apt-get install pkg-config -y
apt-add-repository ppa:bitcoin/bitcoin -y
apt-get update -y
apt-get install libdb4.8-dev -y
apt-get install libdb4.8++-dev -y
git clone https://github.com/vantaur/vantaur.git
cd vantaur/src
make -f makefile.unix
strip vantaurd
cp vantaurd /usr/local/bin
mkdir /root/.Vantaur
touch /root/.Vantaur/Vantaur.conf
user="$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13)"
pass="$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 23)"
echo "rpcuser="$user >> /root/.Vantaur/Vantaur.conf
echo "rpcpassword="$pass >> /root/.Vantaur/Vantaur.conf
echo "rpcport=22812" >> /root/.Vantaur/Vantaur.conf
echo "server=1" >> /root/.Vantaur/Vantaur.conf
echo "listen=1" >> /root/.Vantaur/Vantaur.conf
echo "daemon=1" >> /root/.Vantaur/Vantaur.conf
echo "port=22813" >> /root/.Vantaur/Vantaur.conf
echo "masternode=1" >> /root/.Vantaur/Vantaur.conf
read -p "IP Address of this VPS: " ip
read -p "Masternodeprivatekey: " privatekey
echo "masternodeaddr="$ip":22813" >> /root/.Vantaur/Vantaur.conf
echo "masternodeprivkey="$privatekey >> /root/.Vantaur/Vantaur.conf
vantaurd
echo "Masternode setup complete"
exit

