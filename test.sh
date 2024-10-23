#!/bin/bash

while true; do
    powershell.exe -command '$wshell = New-Object -ComObject wscript.shell; $wshell.SendKeys("a")'
    sleep 8
done
