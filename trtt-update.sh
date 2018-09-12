#!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root." 1>&2
   exit 1
fi

pushd /root
killall trittiumd
rm /usr/local/bin/trittium*
wget https://github.com/Trittium/trittium/releases/download/2.2.0.2/Trittium-2.2.0.2-Ubuntu-daemon.tgz
tar -xvf Trittium-2.2.0.2-Ubuntu-daemon.tgz -C /usr/local/bin/
rm Trittium-2.2.0.2-Ubuntu-daemon.tgz

if ! which aptitude &>/dev/null; then
  echo 'Aptitude not found, installing'
  apt-get -qq install aptitude
fi

if ! service fail2ban status | grep "Loaded: loaded" &>/dev/null; then
  echo 'Fail2Ban not installed, installing'
  aptitude -y -q install fail2ban
  service fail2ban restart
fi

if ! which ufw &>/dev/null; then
  echo 'ufw not installed, installing'
  apt-get -qq install ufw
  echo 'configuring ufw'
  ufw default deny incoming
  ufw default allow outgoing
  ufw allow ssh
  ufw allow 30001/tcp
  echo 'enabling ufw'
  yes | ufw enable
fi

su -c "trittiumd -daemon" tritt

echo "To verify you blockchain is sync'd run:"
echo " su -l -c \"trittium-cli getblockcount\" tritt"
echo "To verify masternode is started:"
echo " su -c \"/usr/local/bin/trittium-cli masternode status\" tritt"
