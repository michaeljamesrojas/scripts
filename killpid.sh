#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <pid>"
  exit 1
fi

PID=$1

echo "Killing PID $PID..."
taskkill /PID $PID /F
