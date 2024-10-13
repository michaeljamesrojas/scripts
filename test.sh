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
# Ask for execution or display option
echo
read -p "Enter 'e' to execute, 'd' to display, or 'b' to both display and execute $selected_script: " action
echo

case "$action" in
    e|E)
      echo "Executing script: $selected_script"
      bash <(curl -s "$script_url") "${@:1}"
      ;;
    d|D)
      echo "Displaying script: $selected_script"
      curl -s "$script_url"
      ;;
    b|B)
      echo "Displaying and executing script: $selected_script"
      echo "--- Script Content ---"
      curl -s "$script_url"
      echo "--- End of Script Content ---"
      echo "Executing script:"
      bash <(curl -s "$script_url") "${@:1}"
      ;;
    *)
      echo "Invalid option. Exiting."
      exit 1
      ;;
esac

# Check if curl encountered an error
if [[ $? -ne 0 ]]; then
      echo "Error: Failed to fetch or execute the script."
      exit 1
fi
