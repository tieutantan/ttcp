#!/bin/sh

# Validate domain format (simple FQDN check)
validate_domain() {
    local domain="$1"
    if ! echo "$domain" | grep -qE '^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$'; then
        echo "TTCP: Invalid domain format: $domain"
        exit 1
    fi
}

# Check if the domain argument is provided
if [ -z "$1" ]
then
    echo "TTCP: remove-domain usage: $0 domain"
    exit 1
fi

# Set the domain variable
domain=$1

# Validate domain input
validate_domain "$domain"

# Change to the directory containing the files
folder_path="/etc/nginx/conf.d/"

# Initialize counter to track removed files
removed_count=0

# Change to the folder
cd "$folder_path" || exit 1

# Loop through all files matching the domain-*.conf pattern (exact match by naming convention)
for file in "${domain}"-*.conf
do
    # Check if file exists (to handle glob that doesn't match anything)
    if [ -f "$file" ]
    then
        # Remove the file
        if rm -f "$file"; then
            removed_count=$((removed_count + 1))
        fi
    fi
done

# Check if any files were removed
if [ "$removed_count" -eq 0 ]
then
    echo "TTCP: No configuration found for domain: $domain"
    exit 1
fi

# Reload the Nginx configuration
if ! nginx -s reload; then
    echo "TTCP: Failed to reload Nginx after removing $domain."
    exit 1
fi

echo "=============================="
echo "TTCP: $domain has been removed ($removed_count file(s))."
echo "=============================="

exit 0
