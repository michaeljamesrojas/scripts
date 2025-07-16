#!/bin/bash

# Ask user for number of commits to reset from HEAD
read -p "Enter how many commits to reset soft from HEAD~: " count

# Confirm before running the reset
echo "You are about to run: git reset --soft HEAD~$count"
read -p "Are you sure? (y/N): " confirm

if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
    git reset --soft HEAD~"$count"
else
    echo "Aborted."
fi
