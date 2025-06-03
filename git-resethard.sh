#!/bin/bash

# Ask user for number of commits to reset from HEAD
read -p "Enter how many commits to reset from HEAD~: " count

# Confirm before running the reset
echo "You are about to run: git reset --hard HEAD~$count"
read -p "Are you sure? (y/N): " confirm

if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
    git reset --hard HEAD~"$count"
else
    echo "Aborted."
fi
