#!/bin/bash

# Make the POST request using curl
response=$(curl -s -X POST \
    -d "input=333888" \
    "https://www.magictool.ai/functions/TEXT-SHARING-GET.php")

# Check if the request was successful
if [ $? -eq 0 ]; then
    echo "Retrieved text from global clipboard:"
    echo "$response"
    echo "$response" | clip
    echo
    echo "Above is copied to your clipboard
else
    echo "Failed to retrieve text from global clipboard"
    exit 1
fi
