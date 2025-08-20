#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <port>"
  exit 1
fi

PORT=$1

# Use netstat to find the process using the port
PROCESS_INFO=$(netstat -ano | grep ":$PORT " | grep LISTENING)

if [ -z "$PROCESS_INFO" ]; then
  echo "No process is using port $PORT"
  exit 0
fi

PID=$(echo "$PROCESS_INFO" | awk '{print $5}')

echo "Port $PORT is being used by PID: $PID"
echo

# Get more details about the process
tasklist /FI "PID eq $PID"
