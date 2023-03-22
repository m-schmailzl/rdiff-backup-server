#!/bin/bash
# deletes all old increments until there is more than $ROTATION_SPACE (in GB) disk space available

echo "-----------------------------------------------------------------------------"
echo "Rotating backup on $(date) in $TARGET_DIR"
echo "-----------------------------------------------------------------------------"

cd "$TARGET_DIR"
FAILED=false

if [ "$ROTATION_CHECK" == "yes" ] || [ "$ROTATION_CHECK" == 1 ]
then
	for backup_client in */
	do
		echo "--- Checking $backup_client..."
		if [ "$ROTATION_CHECK_FORCE" == "yes" ] || [ "$ROTATION_CHECK_FORCE" == 1 ]
		then
			rdiff-backup --check-destination-dir --force "$backup_client"
			if ! [ $? = 0 ]; then FAILED=true; fi
		else
			rdiff-backup --check-destination-dir "$backup_client"
			if ! [ $? = 0 ]; then FAILED=true; fi
		fi
	done
fi

if ! [ -z "$ROTATION_EXPIRE" ]
then
	for backup_client in */
	do
		echo "--- Removing backups older than $ROTATION_EXPIRE from '$backup_client'..."
		rdiff-backup --remove-older-than "$ROTATION_EXPIRE" --force "$backup_client"
		if ! [ $? = 0 ]; then FAILED=true; fi
	done
fi

if ! [ -z "$ROTATION_SPACE" ]
then
	# group backup clients by physical device
	declare -A partitions
	for backup_client in */
	do
		device=$(stat -c '%d' $backup_client)
		partitions["$device"]="${partitions[$device]} $backup_client"
	done

	for device in "${!partitions[@]}"
	do
		path=$(echo ${partitions[$device]} | awk '{print $1}') # one folder on the device (needed for df command)
		
		if (( $(($ROTATION_SPACE*1024*1024)) < $(df --output=avail $path | tail -1) ))
		then
			echo "--- Free disk space on $(df --output=target $path | tail -1) is over ${ROTATION_SPACE}GB. Rotation will be skipped."
		else
			# getting number of days since the oldest backup on the device
			max=0
			for backup_client in ${partitions[$device]}
			do
				# get number of days since the oldest backup
				oldest_increment=$(rdiff-backup --list-increments $backup_client | sed -n 2p | sed -e 's/.*increments.\(.*\).dir.*/\1/')
				if [ $? = 0 ]
				then
					if [[ "$oldest_increment" == Current* ]]
					then
						echo "--- $backup_client: There are no increments left to delete!"
					else
						date=$(date -d "$oldest_increment" "+%s")
						now=$(date -d "now" "+%s")
						diff=$((($now-$date)/86400))

						if (( $diff > $max ))
						then
							max=$diff
						fi
					fi
				else
					FAILED=true
				fi
			done
			
			# delete the oldest backup until enough free space is available
			while (( $(($ROTATION_SPACE*1024*1024)) > $(df --output=avail $path | tail -1) )) && (( $max >= 0 ))
			do
				for backup_client in ${partitions[$device]}
				do
					echo "--- Deleting all increments older than $max days from $(basename $backup_client)..."
					rdiff-backup --remove-older-than "${max}D" --force "$backup_client"
					if ! [ $? = 0 ]; then FAILED=true; fi
				done
				((max--))
			done
		fi
	done
fi


if $FAILED
then
	echo "--- BACKUP ROTATION FAILED!"
	
	if ! [ -z "$ADMIN_MAIL"]
	then
		echo "Sending mail to admin..."
		echo -e "From: $EMAIL_FROM\nTo: $ADMIN_MAIL\nSubject: Backup rotation failed!\n\nThe backup rotation failed:\nCheck the container logs for details." | ssmtp -C "$SSMTP_CONF" "$ADMIN_MAIL"
		if [ $? = 0 ]
		then
			echo "An email has been sent."
		else
			echo "Error: Failed to send an email to '$ADMIN_MAIL'. Check your ssmtp settings, ADMIN_MAIL and EMAIL_FROM."
		fi
	fi
else
	echo "--- Backup rotation finished without errors."
fi
