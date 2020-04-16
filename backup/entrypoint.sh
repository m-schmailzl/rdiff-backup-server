#!/bin/bash

/backup/setup.sh
if ! [ $? = 0 ]
then
	echo "The initial setup failed. Shutting down container..."
	exit 1
fi

echo "Starting backup server..."
echo "$(date)"

if [ -z "$ROTATION_HOUR" ]
then
	echo "Backup server is running."
	/usr/sbin/sshd -e -D
else	
	/usr/sbin/sshd -e
	
	if [ -z "$ROTATION_SPACE" ] && [ -z "$ROTATION_EXPIRE" ]
	then
		echo "Error: You have set ROTATION_HOUR but not ROTATION_SPACE or ROTATION_EXPIRE. You have to set at least one."
		echo "Shutting down container..."
		exit 2
	fi
	
	echo "Backup server is running."
	
	while [[ $(ps | grep [s]shd) ]]
	do
		if [ $(date +"%H") = $(printf "%02d" $ROTATION_HOUR) ]
		then
			/backup/rotate_backups.sh
			sleep 3600
		fi
		sleep 60
	done
fi

echo "sshd has stopped. Shutting down container..."
