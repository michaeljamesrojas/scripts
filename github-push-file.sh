#!/bin/bash

# Script to push a new file to GitHub repository using GitHub API
# The file content will be taken from the clipboard

# Colors for better readability
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if required commands exist
if ! command_exists curl; then
    echo -e "${RED}Error: curl is not installed. Please install curl and try again.${NC}"
    exit 1
fi

if ! command_exists clip.exe || ! command_exists powershell.exe; then
    echo -e "${YELLOW}Warning: This script might not work correctly in this environment.${NC}"
    echo -e "${YELLOW}It's designed for Windows with WSL or Git Bash.${NC}"
fi

# Function to get clipboard content
get_clipboard_content() {
    if command_exists powershell.exe; then
        # Using PowerShell to get clipboard content in Windows/WSL
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

# Function to base64 encode content
base64_encode() {
    if command_exists base64; then
        echo "$1" | base64 -w 0
    else
        echo -e "${RED}Error: base64 command not found.${NC}"
        exit 1
    fi
}

# Ask for GitHub personal access token if not stored in environment
if [ -z "$GITHUB_TOKEN" ]; then
    echo -e "${YELLOW}GitHub Personal Access Token not found in environment.${NC}"
    read -sp "Enter your GitHub Personal Access Token: " GITHUB_TOKEN
    echo
    
    if [ -z "$GITHUB_TOKEN" ]; then
        echo -e "${RED}Error: GitHub token is required.${NC}"
        exit 1
    fi
fi

# Ask for repository details
read -p "Enter GitHub username: " GITHUB_USERNAME
if [ -z "$GITHUB_USERNAME" ]; then
    echo -e "${RED}Error: GitHub username is required.${NC}"
    exit 1
fi

read -p "Enter repository name: " REPO_NAME
if [ -z "$REPO_NAME" ]; then
    echo -e "${RED}Error: Repository name is required.${NC}"
    exit 1
fi

# Ask for branch name (default: main)
read -p "Enter branch name [main]: " BRANCH_NAME
BRANCH_NAME=${BRANCH_NAME:-main}

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

# Get content from clipboard
echo -e "${YELLOW}Getting content from clipboard...${NC}"
FILE_CONTENT=$(get_clipboard_content)

if [ -z "$FILE_CONTENT" ]; then
    echo -e "${RED}Error: Clipboard is empty. Please copy content to clipboard first.${NC}"
    exit 1
fi

echo -e "${GREEN}Content retrieved from clipboard.${NC}"

# Base64 encode the content
ENCODED_CONTENT=$(base64_encode "$FILE_CONTENT")

# Create the JSON payload
JSON_PAYLOAD=$(cat <<EOF
{
  "message": "Add $FILE_NAME via API",
  "content": "$ENCODED_CONTENT",
  "branch": "$BRANCH_NAME"
}
EOF
)

# Push to GitHub using the API
echo -e "${YELLOW}Pushing file to GitHub repository...${NC}"
RESPONSE=$(curl -s -X PUT \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    -d "$JSON_PAYLOAD" \
    "https://api.github.com/repos/$GITHUB_USERNAME/$REPO_NAME/contents/$FILE_NAME")

# Check if the request was successful
if echo "$RESPONSE" | grep -q '"content":'; then
    echo -e "${GREEN}Success! File '$FILE_NAME' has been pushed to GitHub.${NC}"
    
    # Extract the URL from the response and display it
    FILE_URL=$(echo "$RESPONSE" | grep -o '"html_url": "[^"]*"' | cut -d'"' -f4)
    if [ -n "$FILE_URL" ]; then
        echo -e "${GREEN}File URL: $FILE_URL${NC}"
    fi
else
    echo -e "${RED}Error pushing file to GitHub:${NC}"
    echo "$RESPONSE" | grep -o '"message": "[^"]*"' | cut -d'"' -f4
    exit 1
fi
