#!/bin/bash

# Check if a message argument is provided
if [ -z "$1" ]; then
  echo "Error: No stash message provided."
  exit 1
fi

# Run git stash save -u with the provided message
git stash save -u "$1" && git stash apply --index