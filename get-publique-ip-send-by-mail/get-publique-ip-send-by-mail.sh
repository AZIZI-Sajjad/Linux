# Effectuer la requête curl et stocker la réponse dans une variable
response=$(curl -k monip.org)

# Utiliser grep pour rechercher la ligne contenant "IP :" et extraire l'adresse IP
ip_line=$(echo "$response" | grep "IP :")

# Utiliser sed pour extraire l'adresse IP de la ligne
ip=$(echo "$ip_line" | sed -n 's/.*IP : \([0-9.]*\).*/\1/p')

# Afficher l'adresse IP
echo "Adresse IP : $ip"


echo -e "Subject: YOUR IP at $(date +"%Y-%m-%d-%Hh%M:%Ss")\nFrom: NOREPLY Your Name <your@email.com>\n\nYOUR IP at  $(date +"%Y-%m-%d-%Hh%M:%Ss") is :\n $ip" | msmtp recipient1@example.com
echo -e "Subject: YOUR IP at $(date +"%Y-%m-%d-%Hh%M:%Ss")\nFrom: Your Name <your@email.com>\n\nYOUR IP at  $(date +"%Y-%m-%d-%Hh%M:%Ss") is :\n $ip" | msmtp recipient2@example.com



