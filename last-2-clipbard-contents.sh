#!/bin/bash

# Function to get clipboard content
get_clipboard() {
    powershell.exe -command "Get-Clipboard"
}

# Array to store clipboard history
clipboard_history=()

# Get the last 2 clipboard contents
for i in {1..2}; do
    content=$(get_clipboard)
    clipboard_history+=("$content")
    # Use PowerShell to clear the clipboard
    powershell.exe -command "Set-Clipboard -Value ''"
done

echo "Last 2 clipboard contents:"
for i in "${!clipboard_history[@]}"; do
    echo "--- Content $((i+1)) ---"
    echo "${clipboard_history[$i]}"
    echo
done