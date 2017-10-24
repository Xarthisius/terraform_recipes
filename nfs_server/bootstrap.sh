#!/bin/bash

sudo sed -e "/^127.0.0.1/ s/localhost/& $HOSTNAME/" \
   -i /etc/hosts
sudo apt-get -qy update
sudo apt-get -qy upgrade

sudo mkfs.ext4 /dev/vdb
sudo mount /dev/vdb /srv
sudo mkdir -p /srv/$1
echo "/dev/vdb		/srv	ext4	noatime	0 0" | \
	sudo tee --append /etc/fstab

sudo apt-get -qy install nfs-kernel-server ntp

echo "/srv           172.16.1.0/24(ro,async,fsid=0,async,no_subtree_check) 141.142.0.0/16(ro,async,fsid=0,async,no_subtree_check)" | \
	sudo tee --append /etc/exports
echo "/srv/$1      172.16.1.0/24(ro,async,no_subtree_check) 141.142.0.0/16(ro,async,no_subtree_check)" | \
	sudo tee --append /etc/exports

sudo sed -e 's/RPCMOUNTDOPTS="/&--port 32767 /' \
	-i /etc/default/nfs-kernel-server

echo "options lockd nlm_udpport=4045 nlm_tcpport=4045" | \
	sudo tee --append /etc/modprobe.d/options.conf
echo "lockd" | sudo tee --append /etc/modules

sudo systemctl enable nfs-kernel-server.service
sudo reboot
