#!/bin/bash

# Script to repeat a command with delay and beep notification

echo "=== Repeat Command with Delay ==="
echo

# Get the command to execute
read -p "Enter the command to execute: " command

# Validate command is not empty
if [ -z "$command" ]; then
    echo "Error: Command cannot be empty"
    exit 1
fi

# Get the number of times to execute
read -p "Enter the number of times to execute: " count

# Validate count is a positive integer
if ! [[ "$count" =~ ^[0-9]+$ ]] || [ "$count" -le 0 ]; then
    echo "Error: Count must be a positive integer"
    exit 1
fi

# Get the delay between executions
read -p "Enter the delay between executions (in seconds): " delay

# Validate delay is a non-negative number
if ! [[ "$delay" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    echo "Error: Delay must be a non-negative number"
    exit 1
fi

echo
echo "Will execute: $command"
echo "Number of times: $count"
echo "Delay: $delay seconds"
echo
read -p "Press Enter to start..."

# Execute the command loop
for i in $(seq 1 $count); do
    echo
    echo "--- Execution $i of $count ---"

    # Execute the command
    eval "$command"

    # Play system beep
    echo -e "\a"

    # Wait for delay if not the last iteration
    if [ $i -lt $count ]; then
        echo "Waiting $delay seconds before next execution..."
        sleep "$delay"
    fi
done

echo
echo "=== All executions completed ==="
echo -e "\a"
