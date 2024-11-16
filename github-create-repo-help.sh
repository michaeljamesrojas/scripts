#!/bin/bash

# Copy the GitHub repo creation command to clipboard
echo "gh repo create \$repo_name --public --source=. --remote=origin --push" | clip

echo "Command copied to clipboard!"
echo "Now you can paste it and replace \$repo_name with your desired repository name"
