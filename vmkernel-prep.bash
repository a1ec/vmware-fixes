#!/usr/bin/env bash
# Must be run as root / sudo
# Reference: https://askubuntu.com/questions/966585/ubuntu-17-10-upgrade-broke-vmware-workstation-12-5
# from https://gist.github.com/shadowbq/5897002b620b093ca7578b5f13c3f3a1#file-vmkernel_prep-sh-L55

if [ $(dpkg-query -W -f='${Status}' linux-headers-generic 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  echo "Kernel Headers Package Missing"
  echo "apt-get install linux-headers-generic";
  exit 1
fi

if [ ! -d "/usr/lib/vmware/modules/source/vmmon-only/" ]
then
  echo "Failed to find expanded source vmmon"
  exit 1
  if [ ! -d "/usr/lib/vmware/modules/source/vmnet-only/" ]
  then
    echo "Failed to find expanded source vmnet"
    exit 1
  fi
fi  

kern_dir=$(find /lib/modules/ -maxdepth 1 -type d|sort -n|tail -1)
if [ ! -f "$kern_dir/misc/vmmon.ko" ]
then
  echo "Building New kernels modules"
  mkdir -p $kern_dir/misc/
  cd /usr/lib/vmware/modules/source/vmmon-only/
  make clean
  make
  cp ./vmmon.ko $kern_dir/misc/
  cd /usr/lib/vmware/modules/source/vmnet-only/
  make clean
  make
  cp ./vmnet.ko $kern_dir/misc/
fi

kernel_count=$(lsmod|grep 'vm[mon|net]'|wc -l)

if [[ $kernel_count -lt 2 ]];
then 
  echo "Reloading Kernel Modules"
  rmmod -v vmmon.ko
  insmod $kern_dir/misc/vmmon.ko
  rmmod -v vmnet.ko
  insmod $kern_dir/misc/vmnet.ko
else
  echo "Kernel Modules Loaded Already"
fi

vmnetwork_status=$(vmware-networks --status 2>/dev/null |grep 'is not running' |wc -l)
if [[ $kernel_count -gt 0 ]];
then 
  echo "Starting VMware Networks"
  vmware-networks --start
fi  
