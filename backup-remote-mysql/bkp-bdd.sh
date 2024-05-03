#!/bin/bash

# Configuration de base: datestamp e.g. YYYYMMDD
DATE=$(date +"%d-%m-%Y")
#DATE=$(date +"%Y%m%d")

# Dossier où sauvegarder les backups (créez le d'abord!)
BACKUP_DIR="/local/path/to/backup/folder"

# Identifiants MySQL
MYSQL_USER="sqluser"
MYSQL_PASSWORD="sqluserpassword"

# Commandes MySQL (aucune raison de modifier ceci)
MYSQL=/usr/bin/mysql
MYSQLDUMP=/usr/bin/mysqldump

# Bases de données MySQL à ignorer
SKIPDATABASES="Database|information_schema|performance_schema|mysql"

# Nombre de jours à garder les dossiers (seront effacés après X jours)
RETENTION=1
#
# ---- NE RIEN MODIFIER SOUS CETTE LIGNE ------------------------------------------
#

# Create a new directory into backup directory location for this date
mkdir -p $BACKUP_DIR/$DATE/$HOSTNAME

# Retrieve a list of all databases
databases=`$MYSQL -u$MYSQL_USER -p$MYSQL_PASSWORD -e "SHOW DATABASES;" | grep -Ev "($SKIPDATABASES)"`

# Dumb the databases in seperate names and gzip the .sql file
for db in $databases; do
echo $db
#$MYSQLDUMP --force --opt --user=$MYSQL_USER -p$MYSQL_PASSWORD --skip-lock-tables --events --databases $db | gzip > "$BACKUP_DIR/$DATE/$db.sql.gz"
$MYSQLDUMP --force --opt --user=$MYSQL_USER -p$MYSQL_PASSWORD --skip-lock-tables $db | gzip > "$BACKUP_DIR/$DATE/$HOSTNAME/$db.sql.gz"
done

# Remove files older than X days and *.tar.bz2 files created in $BACKUP_DIR/
find $BACKUP_DIR/* -mtime +$RETENTION -delete
rm -f $BACKUP_DIR/*.tar.gz
