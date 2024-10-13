#!/bin/bash

# Define the base URL for raw content
base_url="https://raw.githubusercontent.com/michaeljamesrojas/scripts/main"

# Fetch the list of files from the repository
echo "Available scripts:"
echo
scripts=($(curl -s "https://api.github.com/repos/michaeljamesrojas/scripts/contents" | grep '"name":' | grep '\.sh"' | awk -F'"' '{print $4}'))

# Check if curl encountered an error
if [[ $? -ne 0 ]]; then
    echo "Error: Failed to fetch the list of scripts."
    exit 1
fi

# Display numbered list of scripts with spacing
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

# Get the selected script name
selected_script="${scripts[$((choice-1))]}"

# Ask for confirmation and action
echo
read -p "Choose action: (e)xecute, (d)isplay, or (b)oth: " action
echo

case "$action" in
    [eE])
        # Execute the script
        echo "Executing script: $selected_script"
        bash <(curl -s "$script_url") "${@:1}"
        ;;
    [dD])
        # Display the script content
        echo "Displaying content of $selected_script:"
        curl -s "$script_url"
        ;;
    [bB])
        # Display and then execute
        echo "Displaying content of $selected_script:"
        curl -s "$script_url"
        echo
        echo "Executing script: $selected_script"
        bash <(curl -s "$script_url") "${@:1}"
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

# Check if curl encountered an error
if [[ $? -ne 0 ]]; then
    echo "Error: Failed to fetch or execute the script."
    exit 1
fi
