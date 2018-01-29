#!/bin/bash
# for issues with hgfs (shared directory) volumes appearing
sudo vmware-config-tools.pl -d --clobber-kernel-modules=vmhgfs
