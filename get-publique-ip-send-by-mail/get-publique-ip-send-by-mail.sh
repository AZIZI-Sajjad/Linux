# sudo cat /home/scripts/get-ip-send-by-mail.sh
# 
senderMail="senderMail@exemple.com"


# To set destinations addresses mails at prompt decomment "recipients=$1" & comment "repipients"
# Exemple:
# /home/scripts/get-ip-send-by-mail.sh  "recipient1@example.com recipient2@example.com recipient3@example.com recipient4@example.com"
# recipients=$1
recipients="recipient1@example.com recipient2@example.com"

mailsubject="YOUR IP home at $(date +"%Y-%m-%d-%Hh%M:%Ss")"

# Effectuer la requête curl et stocker la réponse dans une variable
response=$(curl -k monip.org)

# Utiliser grep pour rechercher la ligne contenant "IP :" et extraire l'adresse IP
ip_line=$(echo "$response" | grep "IP :")

# Utiliser sed pour extraire l'adresse IP de la ligne
ip=$(echo "$ip_line" | sed -n 's/.*IP : \([0-9.]*\).*/\1/p')
mailbody=$ip

# Afficher l'adresse IP
echo "Adresse IP : $ip"


for recipient in $recipients; do
        echo -e $mailbody | mail -s "$mailsubject" -aFrom:$senderMail $recipient
done

