#!/bin/sh

# Set the folder path
folder_path="/etc/nginx/conf.d/"

# Change to the folder; exit if it fails
cd "$folder_path" || exit 1

# Initialize a counter to 0
counter=0

echo "==========================="

# Loop through the files in the folder (using glob pattern for POSIX compatibility and safety)
# Sort files for consistent output across runs
for file in $(ls -1 *.conf 2>/dev/null | sort)
do
    # Check if file exists (to handle edge case of no .conf files)
    if [ -f "$file" ]; then
        # Increment the counter
        counter=$((counter+1))

        # Trim the last 5 characters from the filename to remove ".conf"
        trimmed_name="${file%.conf}"

        # Print the trimmed name of the file
        echo "$counter > ./$trimmed_name"
    fi
done

echo "TTCP: List $counter Domains."
echo "==========================="