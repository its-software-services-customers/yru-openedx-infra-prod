#!/bin/bash

PASSWD=$2
USER=its
SSH_KEY=$1
HOME_DIR="/home/${USER}"
NTP_SERVER=time.yru.ac.th
NTP_CONFIG=/etc/ntp.conf

echo ${PASSWD} | sudo -S ls -lrt

sudo useradd ${USER}
sudo usermod -aG sudo ${USER}

sudo groupadd docker
sudo usermod -aG docker ${USER}

sudo mkdir -p ${HOME_DIR}/.ssh
echo "${SSH_KEY}" >> key.txt
sudo cp key.txt ${HOME_DIR}/.ssh/authorized_keys
sudo chown ${USER}:sudo -R ${HOME_DIR}/.ssh
sudo chown ${USER}:sudo ${HOME_DIR}
sudo chmod 700 ${HOME_DIR}/.ssh
sudo chmod 600 ${HOME_DIR}/.ssh/authorized_keys

sudo chmod 666 ${NTP_CONFIG}
sudo echo "server ${NTP_SERVER} prefer" >> ${NTP_CONFIG}
sudo chmod 644 ${NTP_CONFIG}

sudo service ntp restart

sudo ntpq -p
sudo timedatectl status
