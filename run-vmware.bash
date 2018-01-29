#!/bin/bash
KERNEL_RELEASE=$(uname -r)
sudo insmod /lib/modules/${KERNEL_RELEASE}/misc/vmmon.o
sudo insmod /lib/modules/${KERNEL_RELEASE}/misc/vmnet.o
sudo vmware-networks --start
sudo chown ac:ac /dev/vmnet*
sudo chmod g+rw /dev/vmnet*
ls /dev/vmnet* -lh

/usr/lib/vmware/bin/vmware
