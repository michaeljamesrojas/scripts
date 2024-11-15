#!/bin/bash

# Check if .venv directory exists
if [ ! -d ".venv" ]; then
    echo "Virtual environment '.venv' not found in current directory"
    echo "Please run pythonCreateVirtualEnvironment.sh first"
    exit 1
fi

# Activate the virtual environment based on OS
if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    source .venv/Scripts/activate
else
    source .venv/bin/activate
fi

echo "Python virtual environment activated!"
