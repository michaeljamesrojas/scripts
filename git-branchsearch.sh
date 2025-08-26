#!/bin/bash

read -p "Enter the branch name to search for: " searchString

echo "Branches containing '$searchString':"

# List all branches and filter by the string
git branch -a | grep "$searchString"
