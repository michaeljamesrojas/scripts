#!/bin/bash

# Script to clone any GitHub repository to temp folder and open with Windsurf
# Designed for Windows Git Bash environment

# Colors for better readability
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if required commands exist
if ! command_exists git; then
    echo -e "${RED}Error: git is not installed. Please install git and try again.${NC}"
    exit 1
fi

if ! command_exists windsurf; then
    echo -e "${RED}Error: windsurf is not installed or not in PATH. Please install Windsurf and try again.${NC}"
    exit 1
fi

# Windows temp directory
TEMP_DIR=$(powershell.exe -command "echo \$env:TEMP" | tr -d '\r')

# Ask for GitHub repository URL
echo -e "${YELLOW}Enter the GitHub repository URL to clone:${NC}"
read -p "Repository URL: " REPO_URL

if [ -z "$REPO_URL" ]; then
    echo -e "${RED}Error: Repository URL is required.${NC}"
    exit 1
fi

# Extract repository name from URL
REPO_NAME=$(basename "$REPO_URL" .git)

if [ -z "$REPO_NAME" ]; then
    echo -e "${RED}Error: Could not extract repository name from URL.${NC}"
    exit 1
fi

CLONE_DIR="$TEMP_DIR/$REPO_NAME"

# Clean up any existing clone in temp directory
if [ -d "$CLONE_DIR" ]; then
    echo -e "${YELLOW}Removing existing clone in temp directory...${NC}"
    rm -rf "$CLONE_DIR"
fi

# Clone the repository
echo -e "${BLUE}Cloning repository to temp directory...${NC}"
git clone "$REPO_URL" "$CLONE_DIR"
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to clone repository.${NC}"
    exit 1
fi

echo -e "${GREEN}Repository cloned successfully to: $CLONE_DIR${NC}"

# Open with Windsurf
echo -e "${BLUE}Opening repository with Windsurf...${NC}"
cd "$CLONE_DIR" && windsurf .

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Success! Repository opened in Windsurf.${NC}"
    
    # Ask if user wants to clean up the cloned directory
    echo -e "${YELLOW}Do you want to clean up the cloned directory from temp? (y/n):${NC}"
    read -p "Clean up? " CLEANUP
    
    if [[ "$CLEANUP" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Cleaning up cloned directory...${NC}"
        rm -rf "$CLONE_DIR"
        echo -e "${GREEN}Cleanup complete.${NC}"
    else
        echo -e "${YELLOW}Directory preserved at: $CLONE_DIR${NC}"
    fi
else
    echo -e "${RED}Error: Failed to open repository in Windsurf.${NC}"
    exit 1
fi