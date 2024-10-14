#!/bin/bash

echo "Preparing to rebase from develop..."

# Prompt for stash message
while true; do
    read -p "Enter a message for git stash (required): " stash_message
    if [ -n "$stash_message" ]; then
        break
    else
        echo "Error: Stash message cannot be empty. Please try again."
    fi
done

# Step 1: Git stash with the provided message
echo "Step 1: Stashing changes"
git stash push -m "$stash_message"

# Step 2: Checkout develop
echo "Step 2: Checking out develop branch"
git checkout develop

# Step 3: Pull latest changes
echo "Step 3: Pulling latest changes from develop"
git pull

# Step 4: Return to the previous branch
echo "Step 4: Returning to the previous branch"
git checkout -

# Step 5: Prepare git rebase command and copy to clipboard
echo "Step 5: The following command has been copied to your clipboard:"
echo "git rebase develop"

# Copy the command to clipboard based on the operating system
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    echo "git rebase develop" | pbcopy
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux with xclip installed
    echo "git rebase develop" | xclip -selection clipboard
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    # Windows using Git Bash or Cygwin
    echo "git rebase develop" | clip
else
    echo "Clipboard copying not supported on this OS. Please copy the command manually."
fi

echo "Press Enter to continue..."
read
