#!/bin/bash

# Script to update the cached scripts repository

# Colors for better readability
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Define the repository information
REPO_URL="https://github.com/michaeljamesrojas/scripts.git"
REPO_NAME="scripts"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if required commands exist
if ! command_exists git; then
    echo -e "${RED}Error: git is not installed. Please install git and try again.${NC}"
    exit 1
fi

# Get Windows temp directory
TEMP_DIR=$(powershell.exe -command "echo \$env:TEMP" | tr -d '\r')

# Define cache directory
CACHE_DIR="$TEMP_DIR/scripts-cache"
REPO_DIR="$CACHE_DIR/$REPO_NAME"

echo -e "${BLUE}Checking for cached repository...${NC}"

# Check if the repository exists in cache
if [ -d "$REPO_DIR" ]; then
    echo -e "${BLUE}Found cached repository. Updating...${NC}"
    cd "$REPO_DIR"
    
    # Check if there are any local changes
    if [ -n "$(git status --porcelain)" ]; then
        echo -e "${YELLOW}Warning: Local changes detected in the cache.${NC}"
        read -p "Do you want to discard these changes and update? (y/n): " confirm
        
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}Update cancelled. Local changes preserved.${NC}"
            exit 0
        else
            echo -e "${YELLOW}Discarding local changes...${NC}"
            git reset --hard HEAD
        fi
    fi
    
    # Update the repository
    echo -e "${BLUE}Pulling latest changes...${NC}"
    git pull
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: Failed to update repository.${NC}"
        exit 1
    else
        echo -e "${GREEN}Repository updated successfully.${NC}"
    fi
else
    # Create cache directory if it doesn't exist
    if [ ! -d "$CACHE_DIR" ]; then
        echo -e "${BLUE}Creating cache directory...${NC}"
        mkdir -p "$CACHE_DIR"
    fi
    
    # Clone the repository
    echo -e "${BLUE}Cloning repository to cache directory...${NC}"
    git clone "$REPO_URL" "$REPO_DIR"
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: Failed to clone repository.${NC}"
        exit 1
    else
        echo -e "${GREEN}Repository cloned successfully.${NC}"
    fi
fi

echo -e "${GREEN}Cache is now up-to-date.${NC}"
echo -e "${BLUE}Cache location: $REPO_DIR${NC}"
echo -e "${YELLOW}Use globally-auto-fast.sh to run scripts from this cache.${NC}"
