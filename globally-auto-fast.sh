#!/bin/bash

# Define the repository information
REPO_URL="https://github.com/michaeljamesrojas/scripts.git"
REPO_NAME="scripts"

# Colors for better readability
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if required commands exist
if ! command_exists git; then
    echo -e "${RED}Error: git is not installed. Please install git and try again.${NC}"
    exit 1
fi

# Get Windows temp directory
TEMP_DIR=$(powershell.exe -command "echo \$env:TEMP" | tr -d '\r')

# Define cache directory
CACHE_DIR="$TEMP_DIR/scripts-cache"
REPO_DIR="$CACHE_DIR/$REPO_NAME"

# Check if the repository exists in cache
if [ -d "$REPO_DIR" ]; then
    echo -e "${BLUE}Found cached repository. Using existing version...${NC}"
    cd "$REPO_DIR"
else
    # Create cache directory if it doesn't exist
    if [ ! -d "$CACHE_DIR" ]; then
        echo -e "${BLUE}Creating cache directory...${NC}"
        mkdir -p "$CACHE_DIR"
    fi
    
    # Clone the repository
    echo -e "${BLUE}Cloning repository to cache directory...${NC}"
    git clone "$REPO_URL" "$REPO_DIR" > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: Failed to clone repository.${NC}"
        exit 1
    else
        echo -e "${GREEN}Repository cloned successfully.${NC}"
    fi
fi

# Get list of available scripts from the local repository
echo -e "${BLUE}Available scripts:${NC}"
echo

# Change to repository directory
cd "$REPO_DIR"

# Get all shell scripts in the repository
all_scripts=($(find . -maxdepth 1 -name "*.sh" -type f -exec basename {} \;))

# Filter scripts if first argument is provided
if [ -n "$1" ]; then
    scripts=()
    for script in "${all_scripts[@]}"; do
        if [[ $script == *"$1"* ]]; then
            scripts+=("$script")
        fi
    done
    shift # Remove the first argument
else
    scripts=("${all_scripts[@]}")
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

# Check if any scripts were found after filtering
if [ ${#scripts[@]} -eq 0 ]; then
    echo -e "${RED}No scripts found matching the filter.${NC}"
    exit 1
fi

# If only one script matches, skip the selection prompt and confirmation
if [ ${#scripts[@]} -eq 1 ]; then
    selected_script="${scripts[0]}"
    echo -e "${GREEN}Only one script found: $selected_script. Executing automatically...${NC}"
    echo
else
    # Prompt user to choose a script
    read -p "Enter the number of the script you want to execute: " choice

    # Validate user input
    if [[ ! "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "${#scripts[@]}" ]; then
        echo -e "${RED}Invalid choice. Please enter a number between 1 and ${#scripts[@]}.${NC}"
        exit 1
    fi
    
    # Get the selected script name
    selected_script="${scripts[$((choice-1))]}"
    
    # Ask for confirmation only when multiple scripts are found
    echo
    read -p "Do you really want to execute $selected_script? (y/n): " confirm
    echo

    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Execution cancelled.${NC}"
        exit 0
    fi
fi

# Full path to the selected script
script_path="$REPO_DIR/$selected_script"

echo -e "${BLUE}Executing script: $selected_script${NC}"
echo -e "${BLUE}From local cache: $script_path${NC}"
echo -e "${BLUE}With arguments: ${@:1}${NC}"
echo
echo -e "${BLUE}============================================${NC}"
source "$script_path" "${@:1}"
echo -e "${BLUE}============================================${NC}"

# Check if script execution encountered an error
if [[ $? -ne 0 ]]; then
    echo -e "${RED}Error: Failed to execute the script.${NC}"
    exit 1
fi

echo -e "${GREEN}Script execution completed.${NC}"
