#!/bin/sh

# Validate domain format (simple FQDN check)
validate_domain() {
    local domain="$1"
    if ! echo "$domain" | grep -qE '^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$'; then
        echo "TTCP: [ERROR] Invalid domain format: '$domain'"
        echo "TTCP: [INFO] Domain must be a valid FQDN (e.g., example.com, sub.example.com)"
        exit 1
    fi
}

# Check if the domain argument is provided
if [ -z "$1" ]
then
    echo "TTCP: [ERROR] Domain argument is required"
    echo "TTCP: [INFO] Usage: $0 <domain>"
    echo "TTCP: [INFO] Example: $0 example.com"
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
    echo "TTCP: [ERROR] Domain '$domain' not found"
    echo "TTCP: [INFO] This domain has not been configured in Nginx"
    exit 1
fi

# Reload the Nginx configuration
if ! nginx -s reload; then
    echo "TTCP: [ERROR] Failed to reload Nginx after removing domain '$domain'"
    echo "TTCP: [INFO] Changes were not applied"
    exit 1
fi

echo "=============================="
echo "TTCP: [OK] Domain '$domain' removed ($removed_count config file(s))"
echo "=============================="

exit 0
