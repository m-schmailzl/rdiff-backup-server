#!/bin/bash
# sends an email to ADMIN_MAIL

echo "Sending mail to admin..."
echo -e "From: $EMAIL_FROM\nTo: $ADMIN_MAIL\nSubject: schmailzl/rdiff-backup-server email test\n\nSUCCESS!" | ssmtp "$ADMIN_MAIL"
exit
