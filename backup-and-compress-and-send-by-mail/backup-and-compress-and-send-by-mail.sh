#!/bin/bash

# Récupérer le PATH du script
script_dir=$(dirname "$(realpath "$0")")

# .env : Le fichiers des variables dans le même répertoire 
source $script_dir/.env
# source /var/scripts/bkp-db-vault/.env

echo "#######################"
echo "script_dir : $script_dir"
echo "Afficher les variables"
echo "secret : $secret"
echo "USER : $USER"
echo "recipients : $recipients"
echo "mailsubject : $mailsubject"
echo "source_Dir : $source_Dir"
echo "output_File : $output_File"
echo "backup_Dir : $backup_Dir"
echo "output_File : $output_File"
echo "RETENTION : $RETENTION jours"
echo "#######################"

function log_debug_information() {
    echo "$(date +"%Y-%m-%d-%Hh%M-%Ss") - [Debug-Information] [Current-User: $USER] : $1" | tee -a $log_File
}


function log_debug_error() {
    echo "$(date +"%Y-%m-%d-%Hh%M-%Ss") - [Debug-Error] [Current-User: $USER] : $1" | tee -a $log_File
}


function check_user_or_cron(){
    # Vérifier si le script est exécuté par cron
    # L'option -n dans une condition if teste si la chaîne spécifiée est non vide. Autrement dit, cela vérifie si la variable $CRON_TZ contient une valeur.
    if [ -z "$PS1" ] && [ -z "$SSH_CONNECTION" ] && [ -z "$TMUX" ] && [ -z "$USER" ]; then
    log_debug_information "Le script a été lancé par Cron."
    else
    log_debug_information "Le script a été lancé par un utilisateur : $USER"
    fi
}


function create_log_dir(){
    # Vérification du nombre d'arguments
    if [[ ! -d $log_Dir ]];
    then
        echo "[Debug-Information] Dossier de log '$log_Dir' n'exite pas"
        mkdir -p $log_Dir
        log_debug_information "Dossier de log '$log_Dir' a été créé" | tee $log_File
    else
        log_debug_information "Dossier de log '$log_Dir' existe" | tee $log_File

    fi
}


function sendmail(){
    # Vérification du nombre d'arguments
    if [[ $# -ne 6 ]]; then
       log_debug_error "Vérifier les le nombre d'arguments envoyés à la fonction 'archive' " | tee $log_File
        return 1
    fi

    recipients="$1"
    mailbody="$2"
    mailsubject="$3"
    senderMail="$4"
    attachement="$5"
    log_File="$6"
    log_debug_information ": Lancement de la fonction Afficher les variables dans la fonction 'sendmail'." | tee $log_File
    log_debug_information ": recipients dans la fonction archive : $recipients" | tee $log_File
    log_debug_information ": mailbody dans la fonction archive : $mailbody" | tee $log_File
    log_debug_information ": mailsubject dans la fonction archive : $mailsubject" | tee $log_File
    log_debug_information ": senderMail dans la fonction archive : $senderMail" | tee $log_File
    log_debug_information ": attachement dans la fonction archive : $attachement" | tee $log_File

    if [  -d "$source_Dir" ]; then
        log_debug_information "Le dossier cible $source_Dir existe." | tee $log_File

    fi

    if [ ! -d "$source_Dir" ]; then
        log_debug_error "Le dossier cible $source_Dir n'existe pas." | tee $log_File

        exit 1
    fi


    for recipient in $recipients; do
        echo -e $mailbody | mail -s "$mailsubject" -aFrom:$senderMail $recipient -A $attachement
        echo "$(date +"%Y-%m-%d-%Hh%M-%Ss") - Mail sent to $recipient" | tee $log_File

    done
    return 
}


function archive(){
    # Vérification du nombre d'arguments
    if [[ $# -ne 4 ]]; then
        log_debug_error "Vérifier les le nombre d'arguments envoyés à la fonction 'archive' " | tee $log_File

        return 1
    fi

    secret="$1"
    source_Dir="$2"
    output_File="$3"
    log_File="$4"
    log_debug_information "Lancement de la fonction Afficher les variables dans la fonction 'archive'." | tee $log_File
    # log_debug_information "secret dans la fonction archive : $secret" | tee $log_File
    log_debug_information "source_Dir dans la fonction archive : $source_Dir" | tee $log_File
    log_debug_information "output_File dans la fonction archive : $output_File" | tee $log_File

    if [  -d "$source_Dir" ]; then
        log_debug_information "Le dossier cible $source_Dir existe." | tee $log_File

    fi

    if [ ! -d "$source_Dir" ]; then
        log_debug_error "Le dossier cible $source_Dir n'existe pas." | tee $log_File

        exit 1
    fi

    log_debug_information "Début de compression" | tee $log_File

    log_debug_information "Compression et chiffrement du dossier..." | tee $log_File
    # sudo apt update && sudo apt install -y p7zip-full
    # -9 : Cmpression maximale 
    zip -r -e -P "$secret" -9 "$output_File" "$source_Dir"

    log_debug_information "Début de chiffrement" | tee $log_File
}


function retention() {
    backup_Dir="$1"
    # Nombre de jours à garder les dossiers (seront effacés après X jours)
    RETENTION="$2"
    log_File="$3"
    # Remove files older than X days
    find $backup_Dir/* -mtime +$RETENTION -delete
}

# Exécuter le script et faire appel aux fonctions
check_user_or_cron
create_log_dir
archive  "$secret" "$source_Dir" "$output_File" "$log_File"
sendmail  "$recipients" "$mailbody" "$mailsubject" "$senderMail" "$output_File" "$log_File"
retention "$backup_Dir" "$RETENTION" "$log_File"
