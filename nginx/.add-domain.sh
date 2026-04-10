#!/bin/sh

# Validate domain format (simple FQDN check)
validate_domain() {
    local domain="$1"
    if ! echo "$domain" | grep -qE '^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$'; then
        echo "TTCP: Invalid domain format: $domain"
        exit 1
    fi
}

# Validate port is numeric and in valid range
validate_port() {
    local port="$1"
    if ! echo "$port" | grep -qE '^[0-9]+$' || [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
        echo "TTCP: Invalid port: $port (must be 1-65535)"
        exit 1
    fi
}

# Check if the required number of arguments are provided
if [ $# -eq 2 ]
then
    # Set the variables from 2 arguments
    domain=$1
    app_local_port=$2
else
    echo "TTCP: add-domain usage: $0 domain app_local_port"
    exit 1
fi

# Validate inputs
validate_domain "$domain"
validate_port "$app_local_port"

# Check domain exist (same domain should not be added twice)
if ls /etc/nginx/conf.d/"$domain"-*.conf >/dev/null 2>&1; then
    echo "TTCP: The $domain already exists."
    exit 1
fi

# Check if server_name already exists in any config file to prevent bypass via file rename
if grep -r "server_name.*$domain" /etc/nginx/conf.d/*.conf >/dev/null 2>&1; then
    echo "TTCP: The $domain already exists in Nginx config."
    exit 1
fi

# Create temp file for validation
temp_conf="/tmp/ttcp-${domain}-${app_local_port}-$$.conf"
conf_file="/etc/nginx/conf.d/${domain}-${app_local_port}.conf"

# Add the domain and port to the configuration file
echo "
server {
    client_max_body_size 200M;
    server_name $domain;
    location / {
        proxy_pass http://host.docker.internal:$app_local_port;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        access_log off;
    }
}
" > "$temp_conf"

# Test nginx configuration syntax
if ! nginx -t -c /etc/nginx/nginx.conf 2>&1 | grep -q "successful"; then
    echo "TTCP: Nginx config test failed for $domain. Rolling back."
    rm -f "$temp_conf"
    exit 1
fi

# Move temp file to actual location only if test passes
mv "$temp_conf" "$conf_file"

# Restart Nginx to apply the changes
if ! nginx -s reload; then
    echo "TTCP: Failed to reload Nginx for $domain. Rolling back."
    rm -f "$conf_file"
    exit 1
fi

echo "==================================="
echo "TTCP: added $domain:$app_local_port to Nginx!"
echo "==================================="

exit 0

