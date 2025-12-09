#!/bin/bash

# This script is intended to be called by globally-auto-fast.sh OR run standalone.
# It independently calculates the cache directory to find the repository.

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

REPO_NAME="scripts"

# Get Windows temp directory (Same logic as globally-auto-fast.sh)
# Try to get it from PowerShell (most reliable on Windows-bash environments like Git Bash)
TEMP_DIR=$(powershell.exe -command "echo \$env:TEMP" 2>/dev/null | tr -d '\r')
# Fallback to standard /tmp if powershell fails or returns empty
if [ -z "$TEMP_DIR" ]; then
    TEMP_DIR="/tmp"
fi
# Convert Windows backslashes to forward slashes just in case
TEMP_DIR="${TEMP_DIR//\\//}"

# Define cache directory
CACHE_DIR="$TEMP_DIR/scripts-cache"
REPO_DIR="$CACHE_DIR/$REPO_NAME"

if [ ! -d "$REPO_DIR" ]; then
    echo -e "${RED}Error: Cache directory not found at $REPO_DIR${NC}"
    echo -e "${RED}Please run globally-auto-fast.sh first to initialize the cache.${NC}"
    exit 1
fi

echo -e "${GREEN}Updating scripts cache in: $REPO_DIR${NC}"
cd "$REPO_DIR" || exit 1
git pull

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Cache updated successfully.${NC}"
else
    echo -e "${RED}Failed to update cache.${NC}"
    exit 1
fi
