#!/bin/bash

echo 'Checking for an internet connection. Please wait.'
ping -q -c5 8.8.8.8 > /dev/null
if [ $? -eq 0 ]
then
    echo 'Internet connection detected. Now doing update.'
    echo
    sudo pacman -Syu
else
    echo 'Cannot connect to the internet.'
    exit 1
fi


