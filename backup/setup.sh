#!/bin/bash
# first time setup

mkdir -p "$TARGET_DIR"
cd /backup/files

if ! [ -e ssh_host_ed25519_key ]
then
	echo "Generating ssh host key..."
	ssh-keygen -N "" -t ed25519 -a 256 -f ssh_host_ed25519_key
	if ! [ $? = 0 ]; then exit $?; fi
fi

if ! [ -e id_rsa.pub ]
then
	echo "Generating ssh authentification key..."
	ssh-keygen -N "" -t rsa -b 4096 -f id_rsa
	if ! [ $? = 0 ]; then exit $?; fi
fi

chown -R root .
chmod 644 *
chmod 600 ssh_host_ed25519_key id_rsa

mkdir -p /backup/.ssh
cp -f id_rsa.pub /backup/.ssh/authorized_keys
if ! [ $? = 0 ]; then exit $?; fi

if ! [ -z "$ADMIN_MAIL" ]
then
	/backup/generate_ssmtp_conf.sh
	if ! [ $? = 0 ]; then exit $?; fi
	
	if [ -z "$EMAIL_FROM" ]
	then
		echo "Error: You have set ADMIN_MAIL but not EMAIL_FROM. You need to set both."
		exit 1
	fi
fi
