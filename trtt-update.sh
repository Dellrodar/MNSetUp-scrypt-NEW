#!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root." 1>&2
   exit 1
fi

pushd /root
killall trittiumd
rm /usr/local/bin/trittium*
wget https://github.com/Trittium/trittium/releases/download/2.1.0/Trittium-2.1.0-Ubuntu-daemon.tgz
tar -xvf Trittium-2.1.0-Ubuntu-daemon.tgz -C /usr/local/bin/
rm Trittium-2.1.0-Ubuntu-daemon.tgz
apt-get -qq install aptitude

aptitude -y -q install fail2ban
service fail2ban restart

apt-get -qq install ufw
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 30001/tcp
yes | ufw enable

su -c "trittiumd" tritt

echo "To verify you blockchain is sync'd run:"
echo " su -l -c \"trittium-cli getblockcount\" tritt"
echo "To verify masternode is started:"
echo " su -c \"/usr/local/bin/trittium-cli masternode status\" tritt"
