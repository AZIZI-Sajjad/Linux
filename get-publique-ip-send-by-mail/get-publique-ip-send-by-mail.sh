# sudo cat /home/scripts/get-ip-send-by-mail.sh
# 
senderMail="senderMail@exemple.com"

# Set IP public manually, in this case comment lines "6 & 7" 
# lastip="87.164.55.189"
lastip_file=./lastip_file
lastip=$(cat "$lastip_file")
echo "lastip : $lastip"
echo "#######################"

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
ip=$(echo "$ip_line" | sed -n 's/.*IP : \([0-9.]*\).*/\1/p')
echo "IP : $ip"

# Define Function to sending mail: 
function sendmail(){
    # Get Mail Body from prompt.
    # In this case, In the function verify_ip, when we call this function, w'll capable to set and get MailBody's value in another function
    # For more details see the 45th & 50th lines 
    mailbody="$1"
    for recipient in $recipients; do
        echo -e $mailbody | mail -s "$mailsubject" -aFrom:$senderMail $recipient
        echo "Mail sent to $recipient"
    done
}


function verify_ip(){
    if [ $ip == $lastip ]
    then
        mailbody="IP Not Chnaged IP : $ip "
	echo $mailbody
        # Call sendmail Function and set MailBody, Also see what is explained on the lines 28 -> 30
	sendmail "$mailbody"
    else
   	mailbody="IP Chnaged / New IP : $ip"
	echo $mailbody
        # Call sendmail Function and set MailBody, Also see what is explained on the lines 28 -> 30
	sendmail "$mailbody"
    echo "$ip" > "$lastip_file"
    echo "Updating lastip to: $ip"
    fi
}



verify_ip
