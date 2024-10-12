#!/bin/bash

# Define the base URL for raw content
base_url="https://raw.githubusercontent.com/michaeljamesrojas/scripts/main"

# Fetch the list of files from the repository
echo "Available scripts:"
scripts=($(curl -s "https://api.github.com/repos/michaeljamesrojas/scripts/contents" | grep '"name":' | grep '\.sh"' | awk -F'"' '{print $4}'))

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

# Execute the chosen script directly from the raw URL
selected_script="${scripts[$((choice-1))]}"
script_url="$base_url/$selected_script"
echo "Fetching and executing script: $selected_script"
curl -s "$script_url" | bash -s

# Check if curl encountered an error
if [[ $? -ne 0 ]]; then
    echo "Error: Failed to fetch or execute the script."
    exit 1
fi