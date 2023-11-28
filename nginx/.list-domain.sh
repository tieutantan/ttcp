#!/bin/sh

# Set the folder path
folder_path="/etc/nginx/conf.d/"

# Change to the folder
cd "$folder_path"

# Initialize a counter to 0
counter=0

echo "==========================="

# Loop through the files in the folder
for file in $(find . -name "*.conf" -type f)
do
    # Increment the counter
    counter=$((counter+1))

    # Trim the last 4 characters from the name of the file
    trimmed_name=${file::-5}

    # Print the trimmed name of the file
    echo "$counter > ${trimmed_name}"
done

echo "TTCP: List $counter Domains."
echo "==========================="