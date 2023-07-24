#!/bin/bash

# Vérification de l'existence de Nmap
if ! command -v nmap &>/dev/null; then
    echo "Nmap n'est pas installé sur ce système. Veuillez l'installer pour exécuter ce script."
    exit 1
fi

# Demande à l'utilisateur d'entrer la plage d'adresses IP
read -p "Entrez la plage d'adresses IP à scanner (format CIDR, ex: 192.168.0.0/24): " ip_range

# Vérification de la validité de la plage d'adresses IP
if ! nmap -sn "$ip_range" | grep -q "Host seems down"; then
    echo "La plage d'adresses IP semble valide. Début du scan..."
else
    echo "La plage d'adresses IP fournie semble invalide ou les hôtes sont inaccessibles."
    exit 1
fi

# Générer un nom de fichier avec horodatage
timestamp=$(date +"%Y%m%d_%H%M%S")
filename="smbrecon_$timestamp.txt"

# Lancement du scan avec nmap pour les ports 445
echo "Lancement du scan des ports 445 sur la plage d'adresses IP $ip_range..."
nmap -p 445 --open -oG - "$ip_range" | grep "/open/" | awk '{print $2}' > "$filename"

echo "Le scan est terminé. Les adresses IP avec le port 445 ouvert sont enregistrées dans $filename."
