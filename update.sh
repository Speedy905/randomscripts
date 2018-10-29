#!/bin/bash

directory=~/pd2wolfhud/WolfHUD

if [ -d "$directory" ];
then
	echo "Directory exists. Doing update"
	cd $directory
	git pull
else
	echo "Directory unavailable."
fi


