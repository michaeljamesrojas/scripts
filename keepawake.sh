#!/bin/bash

# Use first argument if provided, otherwise default to 15 seconds
SLEEP_DURATION=${1:-15}

while true; do
    echo "Pressing scroll lock key"
    powershell.exe -command '$wshell = New-Object -ComObject wscript.shell; $wshell.SendKeys("{SCROLLLOCK}")'
    sleep $SLEEP_DURATION
done