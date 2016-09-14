#!/bin/bash

sudo cp -pv 50-myconfig.conf /usr/share/lightdm/lightdm.conf.d/50-myconfig.conf
sudo service lightdm restart
