#!/bin/bash
DEV=`hcitool dev | fgrep hci | awk '{print $1}'` 
sudo rfcomm release $DEV
