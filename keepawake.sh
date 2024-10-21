#!/bin/bash

while true; do
    echo "$(date +%T) - Keeping computer awake..."
    sleep 5
    echo "$(date +%T) - Simulating key press..."
    # Send a null byte to /dev/null to simulate activity
    echo -ne "\0" > /dev/null
done