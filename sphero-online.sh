#!/bin/bash
SPHERO=`hcitool scan | fgrep Sphero- | awk '{print $1}'`
DEV=`hcitool dev | fgrep hci | awk '{print $1}'` 
sudo rfcomm release $DEV
sudo rfcomm bind $DEV $SPHERO
sudo chmod 777 /dev/rfcomm0
echo \# to disconnect:
echo sudo rfcomm release $DEV
