#!/bin/bash

# Define the GitHub API URL for the repository contents
repo_api_url="https://api.github.com/repos/michaeljamesrojas/scripts/contents"

# Fetch the list of files and filter for script files
echo "Available scripts:"
scripts=($(curl -s "$repo_api_url" | grep '"name":' | grep '\.sh"' | awk -F'"' '{print $4}'))

# Check if curl encountered an error
if [[ $? -ne 0 ]]; then
    echo "Error: Failed to fetch the list of scripts."
    exit 1
fi

# Display numbered list of scripts
for i in "${!scripts[@]}"; do
    echo "$((i+1)). ${scripts[i]}"
done

# Prompt user to choose a script
read -p "Enter the number of the script you want to execute: " choice

# Validate user input
if [[ ! "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "${#scripts[@]}" ]; then
    echo "Invalid choice. Please enter a number between 1 and ${#scripts[@]}."
    exit 1
fi

# Execute the chosen script using globally.sh
selected_script="${scripts[$((choice-1))]}"
./globally.sh "$selected_script"