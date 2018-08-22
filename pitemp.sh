#!/bin/bash

#Pi temps

#This checks the temp of the raspberry pi

cpu=$(</sys/class/thermal/thermal_zone0/temp)
echo "$(date) @ $(hostname)"
echo "--------------------"
echo "GPU $(/opt/vc/bin/vcgencmd measure_temp)"
echo "CPU = $((cpu/1000)) 'C"
