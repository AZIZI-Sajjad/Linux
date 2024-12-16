#!/bin/bash

# .env : Le fichiers des variables dans le même répertoire 
source .env

echo "#######################"
echo "Afficher les variables"
echo "secret : $secret"
echo "recipients : $recipients"
echo "mailsubject : $mailsubject"
echo "source_Dir : $source_Dir"
echo "current_Time : $current_Time"
echo "output_File : $output_File"
echo "backup_Dir : $backup_Dir"
echo "output_File : $output_File"
echo "RETENTION : $RETENTION jours"
echo "#######################"



function sendmail(){
    # Vérification du nombre d'arguments
    if [[ $# -ne 5 ]]; then
        echo "[Debug-Error] Vérifier les le nombre d'arguments envoyés à la fonction 'archive' "
        return 1
    fi

    recipients="$1"
    mailbody="$2"
    mailsubject="$3"
    senderMail="$4"
    attachement="$5"
    echo "[Debug-Information] : Lancement de la fonction Afficher les variables dans la fonction 'sendmail'."
    echo "[Debug-Information] : recipients dnas la fonction archive : $recipients"
    echo "[Debug-Information] : mailbody dnas la fonction archive : $mailbody"
    echo "[Debug-Information] : mailsubject dnas la fonction archive : $mailsubject"
    echo "[Debug-Information] : senderMail dnas la fonction archive : $senderMail"
    echo "[Debug-Information] : attachement dnas la fonction archive : $attachement"

    if [  -d "$source_Dir" ]; then
        echo "[Debug-Information] Le dossier cible $source_Dir existe."
    fi

    if [ ! -d "$source_Dir" ]; then
        echo "[Debug-Erreur] Le dossier cible $source_Dir n'existe pas."
        exit 1
    fi


    for recipient in $recipients; do
        echo -e $mailbody | mail -s "$mailsubject" -aFrom:$senderMail $recipient -A $attachement
        echo "Mail sent to $recipient"
    done
    return 
}


function archive(){
    # Vérification du nombre d'arguments
    if [[ $# -ne 3 ]]; then
        echo "[Debug-Error] Vérifier les le nombre d'arguments envoyés à la fonction 'archive' "
        return 1
    fi

    secret="$1"
    source_Dir="$2"
    output_File="$3"
    echo "[Debug-Information] Lancement de la fonction Afficher les variables dans la fonction 'archive'."
    echo "[Debug-Information] secret dnas la fonction archive : $secret"
    echo "[Debug-Information] source_Dir dnas la fonction archive : $source_Dir"
    echo "[Debug-Information] output_File dnas la fonction archive : $output_File"

    if [  -d "$source_Dir" ]; then
        echo "[Debug-Information] Le dossier cible $source_Dir existe."
    fi

    if [ ! -d "$source_Dir" ]; then
        echo "[Debug-Erreur] Le dossier cible $source_Dir n'existe pas."
        exit 1
    fi

    echo "[Debug-Information] Début de compression"
    # sudo apt update && sudo apt install -y p7zip-full


    echo "[Debug-Information] Compression et chiffrement du dossier..."
    # -9 : Cmpression maximale 
    zip -r -e -P "$secret" -9 "$output_File" "$source_Dir"


    echo "[Debug-Information] Début de chiffrement"
}


function retention() {
    backup_Dir="$1"
    # Nombre de jours à garder les dossiers (seront effacés après X jours)
    RETENTION="$2"
    # Remove files older than X days
    find $backup_Dir/* -mtime +$RETENTION -delete
}

archive  "$secret" "$source_Dir" "$output_File"
sendmail  "$recipients" "$mailbody" "$mailsubject" "$senderMail" "$output_File"
retention "$backup_Dir" "$RETENTION" 
