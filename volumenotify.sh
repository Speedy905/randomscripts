#!/bin/bash

if [ $1 = XF86AudioRaiseVolume ] 
then
amixer set Master 5%+
notify-send "Volume: $(amixer get Master | tail -1 | awk '{print $4}' | tr -d '[]')"
fi

if [ $1 = XF86AudioLowerVolume ]
then
amixer set Master 5%-
notify-send "Volume: $(amixer get Master | tail -1 | awk '{print $4}' | tr -d '[]')"
fi

if [ $1 = XF86AudioMute ]
then
amixer set Master toggle
notify-send "Volume $(amixer get Master | tail -1 | awk '{print $6}' | tr -d '[]')"
fi

