#!/bin/bash

# Function to display usage and exit
display_usage() {
    echo "NMS: remove-domain usage: $0 domain"
    exit 1
}

# Check if the domain argument is provided
if [ -z "$1" ]; then
    display_usage
fi

# Set the domain variable
domain="$1"

# Change to the directory containing the files
folder_path="/etc/nginx/conf.d/"

# Change to the folder
cd "$folder_path" || exit 1

# Loop through all the files in the directory
for file in *; do
    # Check if the file name contains the domain
    if [[ $file == *"$domain"* ]]; then
        # Remove the file
        rm -f "$file"
    fi
done

# Reload the Nginx configuration
nginx -s reload

echo "NMS: $domain has been removed."