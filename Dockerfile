FROM alpine:3
LABEL maintainer="maximilian@schmailzl.net"

RUN apk add --no-cache bash sudo shadow coreutils python3 ssmtp rsync rdiff-backup openssh-client openssh tzdata gettext

RUN adduser backupuser -D -h /backup --shell "/bin/bash" && \
	usermod -p '' backupuser && \
	echo "backupuser ALL=NOPASSWD:/backup/rotate_backups.sh,/bin/df,/bin/mkdir,/usr/bin/rsync,/usr/bin/rdiff-backup --server" >> /etc/sudoers && \
	echo "Set disable_coredump false" >> /etc/sudo.conf

COPY sshd_config /etc/ssh
COPY backup /backup
RUN chmod 700 /backup/*.sh

ENV TARGET_DIR="/media/backups" \
	SSMTP_CONF="/backup/files/ssmtp.conf" \
	SSMTP_AUTHMETHOD=LOGIN \
	SSMTP_TLS=yes \
	SSMTP_STARTTLS=no \
	ROTATION_CHECK=yes

VOLUME /backup/files

EXPOSE 22

ENTRYPOINT ["/backup/entrypoint.sh"]
