#!/bin/bash

# Define the base URL for raw content.
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
# Display numbered list of scripts in columns
cols=$(tput cols)
max_width=0
for script in "${scripts[@]}"; do
    [[ ${#script} -gt $max_width ]] && max_width=${#script}
done
max_width=$((max_width + 5))  # Add some padding

num_cols=$((cols / max_width))
[[ $num_cols -gt 3 ]] && num_cols=3
[[ $num_cols -lt 1 ]] && num_cols=1

num_rows=$(( (${#scripts[@]} + num_cols - 1) / num_cols ))

for row in $(seq 0 $((num_rows - 1))); do
    for col in $(seq 0 $((num_cols - 1))); do
        index=$((row + col * num_rows))
        if [ $index -lt ${#scripts[@]} ]; then
            printf "%-${max_width}s" "$((index+1)). ${scripts[index]}"
        fi
    done
    echo
done
echo
# Prompt user to choose a script
read -p "Enter the number of the script you want to execute: " choice

# Validate user input
if [[ ! "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "${#scripts[@]}" ]; then
    echo "Invalid choice. Please enter a number between 1 and ${#scripts[@]}."
    exit 1
fi

# Get the selected script name
selected_script="${scripts[$((choice-1))]}"

# Ask for confirmation
echo
read -p "Do you really want to execute $selected_script? (y/n): " confirm
echo

if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Execution cancelled."
    exit 0
fi

# Execute the chosen script directly from the raw URL
# script_url="$base_url/$selected_script"
script_url="$base_url/$selected_script?token=$(date +%s)"

echo "Fetching and executing script: $selected_script"
echo "via:(with arguments passed)"
echo "bash <(curl -s $script_url) ${@:1}"
echo
echo "============================================"
bash <(curl -s "$script_url") "${@:1}"
echo "============================================"

# Check if curl encountered an error
if [[ $? -ne 0 ]]; then
    echo "Error: Failed to fetch or execute the script."
    exit 1
fi
