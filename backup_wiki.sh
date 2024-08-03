#!/bin/bash

# Set variables
DATE=$(date +%Y-%m-%d)
MAIN_BACKUP_DIR=~/wiki_backups
BACKUP_DIR=$MAIN_BACKUP_DIR/$DATE
ZIP_FILE=$MAIN_BACKUP_DIR/wiki_backup_$DATE.zip
PI_USER='pi'
PI_HOST=your_raspberry_pi_ip
PI_WIKI_PATH='/var/www/html/mediawiki'
PI_DB_NAME='your_wiki_db_name'
PI_DB_USER='your_db_user'
PI_DB_PASS='your_actual_db_password'
SSH_PASS='your_ssh_password'
FREQUENCY='monthly'  # Set frequency here for demonstration

# Check if the main backup directory exists, create it if it doesn't
if [ ! -d "$MAIN_BACKUP_DIR" ]; then
    mkdir -p $MAIN_BACKUP_DIR
    echo "Created main backup directory: $MAIN_BACKUP_DIR"
fi

# Create the dated backup directory
mkdir -p $BACKUP_DIR

# Backup the SQL database using sshpass
sshpass -p $SSH_PASS ssh $PI_USER@$PI_HOST "mysqldump -u $PI_DB_USER -p$PI_DB_PASS $PI_DB_NAME" > $BACKUP_DIR/$PI_DB_NAME.sql

# Backup the images folder using sshpass
sshpass -p $SSH_PASS rsync -avz $PI_USER@$PI_HOST:$PI_WIKI_PATH/images $BACKUP_DIR/

# Compress the backup directory into a single zip file
zip -r $ZIP_FILE $BACKUP_DIR

# Optional: Remove the uncompressed backup directory
rm -rf $BACKUP_DIR

echo "Backup completed and stored in $ZIP_FILE"

# Cron job setup
CRON_FILE=~/backup_cron
if [ ! -f "$CRON_FILE" ]; then
    echo "Creating cron job file: $CRON_FILE"
    case "$FREQUENCY" in
        daily)
            echo "0 2 * * * ~/backup_wiki.sh daily" > $CRON_FILE
            ;;
        weekly)
            echo "0 2 * * 0 ~/backup_wiki.sh weekly" > $CRON_FILE
            ;;
        monthly)
            echo "0 2 1 * * ~/backup_wiki.sh monthly" > $CRON_FILE
            ;;
    esac
    crontab $CRON_FILE
    echo "Cron job set for $FREQUENCY backups"
else
    echo "Cron job file already exists: $CRON_FILE"
fi

# Check if the cron job is running
if ! pgrep -x "cron" > /dev/null; then
    echo "Starting cron service..."
    sudo service cron start
fi
