#!/bin/sh

# Check if the domain argument is provided
if [ -z "$1" ]
then
    echo "TTCP: remove-domain usage: $0 domain"
    exit 1
fi

# Set the domain variable
domain=$1

# Change to the directory containing the files
folder_path="/etc/nginx/conf.d/"

# Change to the folder
cd "$folder_path"

# Loop through all the files in the directory
for file in *
do
    # Check if the file name contains "example.com"
    if [[ $file == *"$domain"* ]]
    then
        # Remove the file
        rm -f $file
    fi
done

# Reload the Nginx configuration
nginx -s reload

echo "=============================="
echo "TTCP: $domain has been removed."
echo "=============================="