#!/bin/bash

# Script to clone a repository, add a new file from clipboard, commit and push
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

# Function to get clipboard content
get_clipboard_content() {
    if command_exists powershell.exe; then
        # Using PowerShell to get clipboard content in Windows/Git Bash
        powershell.exe -command "Get-Clipboard" | sed 's/\r$//'
    elif command_exists xclip; then
        # Linux with xclip
        xclip -selection clipboard -o
    elif command_exists pbpaste; then
        # macOS
        pbpaste
    else
        echo -e "${RED}Error: No supported clipboard tool found.${NC}"
        exit 1
    fi
}

# Store the current directory to return to it later
ORIGINAL_DIR=$(pwd)

# Windows temp directory
TEMP_DIR=$(powershell.exe -command "echo \$env:TEMP" | tr -d '\r')

# Repository information
REPO_URL="https://github.com/michaeljamesrojas/scripts.git"
REPO_NAME="scripts"
CLONE_DIR="$TEMP_DIR/$REPO_NAME"

# Ask for Git credentials if needed
echo -e "${YELLOW}You may be prompted for your GitHub credentials during the push operation.${NC}"

# Ask for the new file name
read -p "What is the name of the new sh file?: " FILE_NAME
if [ -z "$FILE_NAME" ]; then
    echo -e "${RED}Error: File name is required.${NC}"
    exit 1
fi

# Add .sh extension if not provided
if [[ ! "$FILE_NAME" == *.sh ]]; then
    FILE_NAME="${FILE_NAME}.sh"
    echo -e "${YELLOW}Added .sh extension to filename: ${FILE_NAME}${NC}"
fi

# Ask user to confirm clipboard content is ready
echo -e "${YELLOW}Please make sure you have copied the desired file content to your clipboard.${NC}"
read -p "Is your clipboard ready with the content for $FILE_NAME? (y/n): " CLIPBOARD_READY

if [[ ! "$CLIPBOARD_READY" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Please prepare your clipboard and run the script again.${NC}"
    exit 0
fi

# Get content from clipboard
echo -e "${YELLOW}Getting content from clipboard...${NC}"
FILE_CONTENT=$(get_clipboard_content)

if [ -z "$FILE_CONTENT" ]; then
    echo -e "${RED}Error: Clipboard is empty. Please copy content to clipboard first and run the script again.${NC}"
    exit 1
fi

echo -e "${GREEN}Content retrieved from clipboard.${NC}"

# Show the clipboard contents to the user for confirmation
echo -e "${YELLOW}Preview of clipboard contents:${NC}"
echo "----------------------------------------"
echo "$FILE_CONTENT" | head -n 10

# If the content is longer than 10 lines, indicate there's more
LINE_COUNT=$(echo "$FILE_CONTENT" | wc -l)
if [ $LINE_COUNT -gt 10 ]; then
    echo -e "${YELLOW}... (showing first 10 lines of $LINE_COUNT total lines)${NC}"
fi
echo "----------------------------------------"

# Ask for confirmation of the content
read -p "Is this the correct content for your file? (y/n): " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo -e "${RED}Operation cancelled. Please update your clipboard with the correct content and try again.${NC}"
    exit 1
fi

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
    cd "$ORIGINAL_DIR"
    exit 1
fi

# Change to the cloned repository
cd "$CLONE_DIR"
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to change to repository directory.${NC}"
    cd "$ORIGINAL_DIR"
    exit 1
fi

# Create the new file with clipboard content
echo -e "${BLUE}Creating new file: ${FILE_NAME}${NC}"
echo "$FILE_CONTENT" > "$FILE_NAME"
chmod +x "$FILE_NAME"

# Stage the new file
echo -e "${BLUE}Staging changes...${NC}"
git add "$FILE_NAME"
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to stage changes.${NC}"
    cd "$ORIGINAL_DIR"
    exit 1
fi

# Commit the changes
echo -e "${BLUE}Committing changes...${NC}"
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
git commit -m "Add $FILE_NAME via git-clone-add-push script at $TIMESTAMP"
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to commit changes.${NC}"
    cd "$ORIGINAL_DIR"
    exit 1
fi

# Push the changes
echo -e "${BLUE}Pushing changes to remote repository...${NC}"
git push origin main
PUSH_STATUS=$?

# Return to the original directory
cd "$ORIGINAL_DIR"

# Clean up the cloned repository
echo -e "${YELLOW}Cleaning up temporary files...${NC}"
rm -rf "$CLONE_DIR"

# Check if push was successful
if [ $PUSH_STATUS -eq 0 ]; then
    echo -e "${GREEN}Success! File '$FILE_NAME' has been added to the repository.${NC}"
    echo -e "${GREEN}Repository URL: https://github.com/michaeljamesrojas/scripts${NC}"
    echo -e "${GREEN}File URL: https://github.com/michaeljamesrojas/scripts/blob/main/$FILE_NAME${NC}"
else
    echo -e "${RED}Error: Failed to push changes to remote repository.${NC}"
    echo -e "${YELLOW}You may need to configure your Git credentials or check your network connection.${NC}"
    exit 1
fi
