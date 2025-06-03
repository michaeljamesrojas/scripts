#!/bin/bash

# Script to clone a repository, open it in Windows Explorer for development,
# and clean up after user confirmation
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

# Store the current directory to return to it later
ORIGINAL_DIR=$(pwd)

# Windows temp directory
TEMP_DIR=$(powershell.exe -command "echo \$env:TEMP" | tr -d '\r')

# Repository information
REPO_URL="https://github.com/michaeljamesrojas/scripts.git"
REPO_NAME="scripts"


# Set clone directory
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
    cd "$ORIGINAL_DIR"
    exit 1
fi

# Open the cloned repository in Windows Explorer
echo -e "${BLUE}Opening repository in Windows Explorer...${NC}"
explorer.exe "$(cygpath -w "$CLONE_DIR")"
if [ $? -ne 0 ]; then
    echo -e "${YELLOW}Warning: Failed to open Windows Explorer. The repository is still available at: ${CLONE_DIR}${NC}"
fi

# Display development instructions
echo -e "${GREEN}Repository cloned successfully to: ${CLONE_DIR}${NC}"
echo -e "${GREEN}Windows Explorer has been opened to this location.${NC}"
echo -e "${YELLOW}You can now make changes to the code using your preferred editor.${NC}"
echo -e "${YELLOW}The temporary clone will be removed when you confirm you're done.${NC}"

# Wait for user confirmation before cleanup
while true; do
    read -p "Are you done developing? (yes/no): " DONE
    case $DONE in
        [Yy]* | [Yy][Ee][Ss])
            break
            ;;
        [Nn]* | [Nn][Oo])
            echo -e "${BLUE}Continue working. Press Enter when you're done.${NC}"
            read -p ""
            ;;
        *)
            echo -e "${YELLOW}Please answer yes or no.${NC}"
            ;;
    esac
done

# Ask if user wants to commit and push changes
read -p "Would you like to commit and push your changes? (yes/no): " COMMIT_PUSH
if [[ "$COMMIT_PUSH" =~ ^[Yy]([Ee][Ss])?$ ]]; then
    # Change to the cloned repository
    cd "$CLONE_DIR"
    
    # Show git status
    echo -e "${BLUE}Current git status:${NC}"
    git status
    
    # Stage all changes
    echo -e "${BLUE}Staging all changes...${NC}"
    git add .
    
    # Ask for commit message
    read -p "Enter commit message: " COMMIT_MSG
    if [ -z "$COMMIT_MSG" ]; then
        TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
        COMMIT_MSG="Update repository via git-clone-explore script at $TIMESTAMP"
    fi
    
    # Commit changes
    echo -e "${BLUE}Committing changes...${NC}"
    git commit -m "$COMMIT_MSG"
    
    # Push changes
    echo -e "${BLUE}Pushing changes to remote repository...${NC}"
    echo -e "${YELLOW}You may be prompted for your GitHub credentials.${NC}"
    git push
    PUSH_STATUS=$?
    
    # Return to original directory
    cd "$ORIGINAL_DIR"
    
    # Check if push was successful
    if [ $PUSH_STATUS -eq 0 ]; then
        echo -e "${GREEN}Success! Changes have been pushed to the repository.${NC}"
    else
        echo -e "${RED}Error: Failed to push changes to remote repository.${NC}"
        echo -e "${YELLOW}You may need to configure your Git credentials or check your network connection.${NC}"
    fi
else
    echo -e "${YELLOW}Changes were not committed or pushed.${NC}"
fi

# Clean up the cloned repository
echo -e "${YELLOW}Cleaning up temporary files...${NC}"
rm -rf "$CLONE_DIR"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Temporary clone has been removed.${NC}"
else
    echo -e "${RED}Error: Failed to remove temporary clone at ${CLONE_DIR}.${NC}"
    echo -e "${YELLOW}You may need to manually delete this directory.${NC}"
fi

echo -e "${GREEN}Script completed.${NC}"
