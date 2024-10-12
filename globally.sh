#!/bin/bash

# Check if an argument is provided
if [[ -z "$1" ]]; then
    echo "Error: No script name provided."
    echo "Usage: run-remote.sh <script-name>"
    exit 1
fi

# Script name (filename) to be fetched
script_name="$1"

# Define the base URL where the scripts are hosted
base_url="https://raw.githubusercontent.com/michaeljamesrojas/scripts/main"

# Full URL of the script to be fetched
script_url="$base_url/$script_name"

# Use curl to download and execute the script
echo "Fetching and executing script: $script_name"
curl -s "$script_url" | bash

# Check if curl encountered an error
if [[ $? -ne 0 ]]; then
    echo "Error: Failed to fetch or (while) executing the script."
    exit 1
fi