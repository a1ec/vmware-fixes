#!/bin/bash
# Issue with Ubuntu upgrade from 17.04 - 17.10 - new kernel and gcc, broken vmware installation
# https://askubuntu.com/questions/966585/ubuntu-17-10-upgrade-broke-vmware-workstation-12-5


# do all below as root
cp bridge.c.patch hostif.c /usr/lib/vmware/modules/source
cd /usr/lib/vmware/modules/source
tar xvf vmmon.tar 
tar xvf vmnet.tar
#hostif.c is from https://raw.githubusercontent.com/mkubecek/vmware-host-modules/b50848c985f1a6c0a341187346d77f0119d0a835/vmmon-only/linux/hostif.c
cp hostif.c ./vmmon-only/linux/hostif.c
patch -b vmnet-only/bridge.c < bridge.c.patch

#vim vmnet-only/bridge.c
#639c639
#< atomic_inc(&clone->users);
#---
#> atomic_inc((atomic_t*)&clone->users);

cd vmmon-only/
make
cd ../vmnet-only/
make
cd ..
KERNEL_RELEASE=$(uname -r)
mkdir /lib/modules/${KERNEL_RELEASE}/misc
cp *.o /lib/modules/${KERNEL_RELEASE}/misc
insmod /lib/modules/${KERNEL_RELEASE}/misc/vmmon.o
insmod /lib/modules/${KERNEL_RELEASE}/misc/vmnet.o
rm /usr/lib/vmware/lib/libz.so.1/libz.so.1
ln -s /lib/x86_64-linux-gnu/libz.so.1 /usr/lib/vmware/lib/libz.so.1/libz.so.1
vmware-networks --start
chgrp promisc-net /dev/vmnet*
chmod g+rw /dev/vmnet*
ls /dev/vmnet* -l

