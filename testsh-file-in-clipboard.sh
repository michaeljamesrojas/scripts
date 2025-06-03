#!/bin/bash

# Confirm clipboard is ready
read -p "Is the clipboard ready with a shell script? (y/N): " confirm

if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Aborted."
    exit 1
fi

# Try to read clipboard using PowerShell (Windows/Git Bash compatible)
CLIP_CONTENT=$(powershell.exe -Command "Get-Clipboard" | tr -d '\r')

# If clipboard is empty
if [[ -z "$CLIP_CONTENT" ]]; then
    echo "Clipboard is empty. Aborting."
    exit 1
fi

# Save clipboard content to a temporary script
TMP_SCRIPT=$(mktemp)
echo "$CLIP_CONTENT" > "$TMP_SCRIPT"

# Show script preview
echo "=== Script Preview ==="
echo "$CLIP_CONTENT"
echo "======================"

# Final confirmation
read -p "Execute this script? (y/N): " run_confirm
if [[ "$run_confirm" != "y" && "$run_confirm" != "Y" ]]; then
    echo "Execution cancelled."
    rm "$TMP_SCRIPT"
    exit 1
fi

# Execute the script
bash "$TMP_SCRIPT"

# Cleanup
rm "$TMP_SCRIPT"
