#!/bin/sh

# Set the folder path
folder_path="/etc/nginx/conf.d/"

# Change to the folder
# shellcheck disable=SC2164
cd "$folder_path"

# Initialize a counter to 0
counter=0

echo "==========================="

# Loop through the files in the folder
# shellcheck disable=SC2044
for file in $(find . -name "*.conf" -type f)
do
    # Increment the counter
    counter=$((counter+1))

    # Trim the last 4 characters from the name of the file
    # shellcheck disable=SC3057
    trimmed_name=${file::-5}

    # Print the trimmed name of the file
    echo "$counter > ${trimmed_name}"
done

echo "TTCP: List $counter Domains."
echo "==========================="