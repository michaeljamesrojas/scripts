#!/bin/bash

# Define temp directories to clean
TEMP_DIRS=(
    "$(cygpath "$TEMP")"
    "/c/Users/micha/AppData/Local/Temp"
)

echo "Starting temp folder cleanup..."

# Clean each temp directory
for TEMP_DIR in "${TEMP_DIRS[@]}"; do
    if [ -d "$TEMP_DIR" ]; then
        echo "Deleting contents of: $TEMP_DIR"
        # Delete all files and folders inside TEMP_DIR, skipping undeletable ones
        find "$TEMP_DIR" -mindepth 1 -exec rm -rf {} + 2>/dev/null
    else
        echo "Directory not found: $TEMP_DIR"
    fi
done

echo "Temp folder cleanup complete."
