#!/bin/bash

while true; do
    powershell.exe -command '$wshell = New-Object -ComObject wscript.shell; $wshell.SendKeys("{SCROLLLOCK}")'
    sleep 8
done