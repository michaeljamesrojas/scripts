#!/bin/bash

# Get text from clipboard using powershell in Windows
clipboard_text=$(powershell.exe -command "Get-Clipboard")

# Make the POST request using curl
response=$(curl -s -X POST \
    -d "input=$clipboard_text" \
    -d "input2=333888" \
    "https://www.magictool.ai/functions/TEXT-SHARING-SAVE.php")

# Check if the request was successful
if [ $? -eq 0 ]; then
    echo "Clipboard text successfully shared globally!"
    echo "Content: $clipboard_text"
else
    echo "Failed to share clipboard text globally"
    exit 1
fi
