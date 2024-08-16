sudo apt-get update && sudo apt-get install -y sshpass rsync && sudo apt upgrade -y
Download and extract the code to a folder.
I wrote this code for backing up a wiki running a raspbery pi. All references to Pi should be taken as the host/target machine
This is meant to be run on the machine that will be doing the backing up
adjust how often the script runs, by default it is set to monthly on the 2nd at 2am.
make the code executable with this command 'chmod +x backup_wiki.sh'
run the script './backup_wiki.sh'
verify the cron job with the command 'crontab -l'

To restore the files
1: extract the zip files: 'unzip ~/wiki_backups/wiki_backup_YYYY-MM-DD.zip -d ~/wiki_restoration'
2: Restore the Sql database: 'mysql -u your_db_user -p your_wiki_db_name < ~/wiki_restoration/your_wiki_db_name.sql'
3: Restore image files: 'cp -r ~/wiki_restoration/images/* /var/www/html/mediawiki/images/'
4: adjust permissions: 'sudo chown -R www-data:www-data /var/www/html/mediawiki/images' 'sudo chmod -R 755 /var/www/html/mediawiki/images'
5: verify restoration: Open your MediaWiki in a browser and check that everything is restored correctly.
