#!/bin/bash

# Get the current branch name
current_branch=$(git rev-parse --abbrev-ref HEAD)

# Get the current date and time in MM-DD-YYYY-HH-MM-AM/PM format
timestamp=$(date +"%m-%d-%Y-%I-%M-%p")

# Create the backup branch name
backup_branch="Backup-${current_branch}-${timestamp}"

# Create a new branch with the backup name
git checkout -b "$backup_branch"

# Switch back to the original branch
git checkout "$current_branch"

echo "Backup branch '$backup_branch' created successfully!"
