#!/bin/sh

# Check if the domain argument is provided
if [ -z "$1" ]
then
    echo "NMAP remove-domain usage: $0 domain"
    exit 1
fi

# Set the domain variable
domain=$1

# Check if the domain configuration file exists
if [ ! -f "/etc/nginx/conf.d/$domain.conf" ]
then
    echo "NMAP: $domain configuration file does not exist."
    exit 1
fi

# Remove the domain configuration file
rm -f "/etc/nginx/conf.d/$domain.conf"

# Reload the Nginx configuration
nginx -s reload

echo "NMAP: $domain has been removed."