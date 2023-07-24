#!/bin/bash

# Vérification de l'existence de Nmap et enum4linux-ng
if ! command -v nmap &>/dev/null; then
    echo "Nmap n'est pas installé sur ce système. Veuillez l'installer pour exécuter ce script."
    exit 1
fi

if ! command -v enum4linux-ng &>/dev/null; then
    echo "enum4linux-ng n'est pas installé sur ce système. Veuillez l'installer pour exécuter ce script."
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

# Générer un nom de répertoire avec horodatage
timestamp=$(date +"%Y%m%d_%H%M%S")
directory="smbrecon_enum_$timestamp"

# Créer le répertoire de stockage des fichiers de sortie
mkdir "$directory"

# Générer un nom de fichier avec horodatage pour les adresses IP avec le port 445 ouvert
timestamp_file=$(date +"%Y%m%d_%H%M%S")
filename="hosts_nc_$timestamp_file.txt"

# Lancement du scan avec nmap pour les ports 445
echo "Lancement du scan des ports 445 sur la plage d'adresses IP $ip_range..."
nmap -p 445 --open -oG - "$ip_range" | grep "/open/" | awk '{print $2}' > "$filename"

echo "Le scan est terminé. Les adresses IP avec le port 445 ouvert sont enregistrées dans $filename."

# Parcourir chaque adresse IP et exécuter enum4linux-ng
while IFS= read -r ip_address; do
    output_file="$directory/${ip_address}_smbrecon_enum_$timestamp_file.txt"
    enum4linux-ng -a "$ip_address" > "$output_file"
    echo "Résultats de enum4linux-ng pour $ip_address enregistrés dans $output_file"
done < "$filename"

echo "Les résultats de enum4linux-ng pour toutes les adresses IP ont été enregistrés dans le répertoire $directory."

