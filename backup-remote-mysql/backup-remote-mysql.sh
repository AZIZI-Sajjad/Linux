#!/bin/bash

# Définir les variables
DATE=$(date +"%d-%m-%Y")
# Définir le répertoire de sauvegarde sur les sreveurs (Serveur Local + Serveur à sauvegarder)
BACKUP_DIR="/local/path/to/backup/folder"
# IP Server :
SRV_IPS="sql01_ip sql02ip sql03ip sql04ip ..."
# Utilisateur: 
USER="adminagora"
# Mot de Passe :
MDP="PASSWORD"

SCRIPTFILE="/local/path/to/this/script.sh"

LOGFILE="/local/path/to/log/file.log"


BKPSQLSCRIPT="/local/path/to/backup/sql/script.sh"

# logging:
printf '#%.0s' {1..60} >> $LOGFILE
echo "$SCRIPTFILE Started at : $(date +"%Y-%m-%d-%Hh%M:%Ss")" >> $LOGFILE

# Lancer un script local sur le serveur distant
backup-database() {
    ssh $USER@$SRV_IP "bash -s" < $BKPSQLSCRIPT
    rsync -avz --no-relative $USER@$SRV_IP:"$BACKUP_DIR/" $BACKUP_DIR/
}

for SRV_IP in $SRV_IPS; do
    printf '#%.0s' {1..60} && echo
    echo "Début de sauvegarde de la base de données de $SRV_IP" à $(date +"%Y-%m-%d-%Hh%M:%Ss") | tee -a $LOGFILE
    backup-database $SRV_IP
    echo "Fin de sauvegarde de la base de données de $SRV_IP" à $(date +"%Y-%m-%d-%Hh%M:%Ss") | tee -a $LOGFILE
    printf '#%.0s' {1..60} && echo
done

# Nombre de jours à garder les dossiers (seront effacés après X jours)
RETENTION=31

# Remove files older than X days
find $BACKUP_DIR \( -type f -mtime +$RETENTION -exec rm -f {} \; -o -type d -empty -delete \)
#find $BACKUP_DIR -mtime +$RETENTION -exec rm -f {}\;
rm -f $BACKUP_DIR/*.tar.gz
