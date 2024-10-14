#!/bin/bash

# Function to get clipboard content
get_clipboard() {
    powershell.exe -command "Get-Clipboard"
}

# Array to store clipboard history
clipboard_history=()

# Get initial clipboard content
initial_content=$(get_clipboard)
clipboard_history+=("$initial_content")

# Wait for a short time and get the content again
sleep 1
current_content=$(get_clipboard)

# Add the current content if it's different from the initial
if [ "$current_content" != "$initial_content" ]; then
    clipboard_history+=("$current_content")
else
    # If it's the same, try to get a different content
    echo "Copy something new to your clipboard..."
    while [ "$current_content" == "$initial_content" ]; do
        sleep 1
        current_content=$(get_clipboard)
    done
    clipboard_history+=("$current_content")
fi

echo "Last 2 clipboard contents:"
for i in "${!clipboard_history[@]}"; do
    echo "--- Content $((i+1)) ---"
    echo "${clipboard_history[$i]}"
    echo
done