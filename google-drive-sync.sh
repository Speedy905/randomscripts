#!/bin/bash

echo 'Checking for connection.'
ping -q -c5 8.8.8.8 > /dev/null
if [ $? -eq 0 ]
then
	echo 'Connection detected. Syncing Google Drive Files.'
	echo 
	cd ~/google-drive
	grive
else
	echo 'No connection detected.'
	exit 1
fi	
