#!/bin/bash

# Prompt user for branch name
read -p "Enter the new branch name: " BRANCH_NAME

# Check if branch name is not empty
if [[ -z "$BRANCH_NAME" ]]; then
  echo "Branch name cannot be empty."
  exit 1
fi

# Create and switch to the new branch
git checkout -b "$BRANCH_NAME"
