#!/bin/bash

if [ -z "$1" ]; then
    echo "Please provide a name as an argument"
    exit 1
fi

echo "Hello $1! Welcome to the world of bash scripting!"
