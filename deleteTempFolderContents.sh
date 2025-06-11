#!/bin/bash

# Resolve the Windows TEMP directory
TEMP_DIR="$(cygpath "$TEMP")"

echo "Deleting contents of: $TEMP_DIR"

# Delete all files and folders inside TEMP_DIR, skipping undeletable ones
find "$TEMP_DIR" -mindepth 1 -exec rm -rf {} + 2>/dev/null

echo "Temp folder cleanup complete."
