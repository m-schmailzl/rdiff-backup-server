FROM alpine:3
MAINTAINER Maximilian Schmailzl <maximilian@schmailzl.net>

RUN apk add --no-cache bash sudo shadow coreutils ssmtp rsync rdiff-backup openssh-client openssh tzdata gettext

RUN adduser backupuser -D -h /backup --shell "/bin/bash" && \
	echo "backupuser ALL=NOPASSWD:/backup/rotate_backups.sh,/usr/bin/rsync,/usr/bin/rdiff-backup --server" >> /etc/sudoers && \
	echo "Set disable_coredump false" >> /etc/sudo.conf

COPY sshd_config /etc/ssh
COPY backup /backup
RUN chmod 700 /backup/*.sh

ENV TARGET_DIR /media/backups
ENV SSMTP_CONF /backup/files/ssmtp.conf
ENV SSMTP_AUTHMETHOD LOGIN
ENV SSMTP_TLS yes
ENV SSMTP_STARTTLS no

VOLUME /backup/files

EXPOSE 22

ENTRYPOINT ["/backup/entrypoint.sh"]
