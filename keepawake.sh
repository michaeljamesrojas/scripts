#!/bin/bash

while true; do
    echo "Pressing scroll lock key"
    powershell.exe -command '$wshell = New-Object -ComObject wscript.shell; $wshell.SendKeys("{SCROLLLOCK}")'
    sleep 8
done