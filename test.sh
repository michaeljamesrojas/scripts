#!/bin/bash

# @echo off
# start chrome --profile-directory="Person 1" %*

# Get the name from the first argument
name=$1

# Check if a name was provided
if [ -z "$name" ]; then
    echo "Please provide a name as an argument."
else
    echo "Hello, $name! Welcome to the script."
fi
