#!/bin/bash

# Check if an argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <text_to_share>"
    exit 1
fi

# The text to share is the first argument
text_to_share="$1"

# Make the POST request using curl
response=$(curl -s -X POST \
    -d "input=$text_to_share" \
    -d "input2=333888" \
    "https://www.magictool.ai/functions/TEXT-SHARING-SAVE.php")

# Check if the request was successful
if [ $? -eq 0 ]; then
    echo "Text successfully shared globally!"
else
    echo "Failed to share text globally"
    exit 1
fi
