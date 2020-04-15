#!/bin/bash
# first time setup

if [ -z "$SERVER_DOMAIN" ] || [ -z "$SERVER_PORT" ]
then
	echo "Error: SERVER_DOMAIN and SERVER_PORT need to be set."
	exit 1
fi

cd /backup/files

if ! [ -e ssh_host_ecdsa_key ]
then
	echo "Generating ssh host key..."
	ssh-keygen -N "" -t ecdsa -b 521 -f ssh_host_ecdsa_key
	if ! [ $? = 0 ]; then exit $?; fi
fi

if ! [ -e id_rsa.pub ]
then
	echo "Generating ssh authentification key..."
	ssh-keygen -t rsa -b 4096 -f id_rsa
	if ! [ $? = 0 ]; then exit $?; fi
fi

mkdir -p /backup/.ssh
cp -f id_rsa.pub /backup/.ssh/authorized_keys
if ! [ $? = 0 ]; then exit $?; fi

if ! [ -z "$ADMIN_MAIL" ]
then
	/backup/generate_ssmtp_conf.sh
	if ! [ $? = 0 ]; then exit $?; fi
fi
