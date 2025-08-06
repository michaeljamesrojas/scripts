#!/bin/bash

# Ask the user for the number of commits to check the diff on
read -p "How many recent commits do you want to see the diff for? " num_commits

# Validate the input to ensure it's a positive integer
if ! [[ "$num_commits" =~ ^[1-9][0-9]*$ ]]; then
  echo "Please enter a valid positive integer."
  exit 1
fi

# Calculate the range for git diff: from HEAD~N to HEAD
echo "Showing diff for the last $num_commits commit(s):"
git diff HEAD~$num_commits HEAD
