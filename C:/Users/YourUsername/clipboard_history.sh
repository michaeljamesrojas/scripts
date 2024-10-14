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

echo "Monitoring clipboard. Press Ctrl+C to exit."

while true; do
    current_content=$(get_clipboard)
    
    # Check if content has changed
    if [ "$current_content" != "${clipboard_history[-1]}" ]; then
        clipboard_history+=("$current_content")
        
        # Keep only the last 2 items
        if [ ${#clipboard_history[@]} -gt 2 ]; then
            clipboard_history=("${clipboard_history[@]:${#clipboard_history[@]}-2}")
        fi
        
        clear
        echo "Last 2 clipboard contents:"
        for i in "${!clipboard_history[@]}"; do
            echo "--- Content $((i+1)) ---"
            echo "${clipboard_history[$i]}"
            echo
        done
    fi
    
    sleep 1
done
