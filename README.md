# rdiff-backup-server

Docker image to backup files and databases with rdiff-backup

This image is not finished yet. Description will follow.

#### Available options: 

**TZ**

**TARGET_DIR** /media/backups

**ADMIN_MAIL**

**EMAIL_FROM**

**ROTATION_LOG_FILE** /backup/files/rotation.log

**ROTATION_HOUR**

**ROTATION_EXPIRE**

**ROTATION_SPACE**

**ROTATION_CHECK**

**ROTATION_CHECK_FORCE**

**SSMTP_CONF** /backup/files/ssmtp.conf

**SSMTP_MAILHUB**

**SSMTP_REWRITEDOMAIN**

**SSMTP_HOSTNAME**

**SSMTP_USER**

**SSMTP_PASSWORD**

**SSMTP_AUTHMETHOD** LOGIN

**SSMTP_TLS** yes

**SSMTP_STARTTLS** yes

**SSMTP_CA_FILE**

#### Volumes:

**/media/backups** : Default backup directory

**/backup/files** : Permanent files of the container