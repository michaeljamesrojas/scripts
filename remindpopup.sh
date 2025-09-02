#!/bin/bash

# Get reminder text from user
echo "Enter reminder text:"
read -r reminder_text

# Get minutes
echo "Enter minutes (0 for no minutes):"
read -r minutes
while ! [[ "$minutes" =~ ^[0-9]+$ ]] || [ "$minutes" -lt 0 ]; do
    echo "Please enter a valid number of minutes (0 or positive):"
    read -r minutes
done

# Get seconds
echo "Enter seconds (0 for no seconds):"
read -r seconds
while ! [[ "$seconds" =~ ^[0-9]+$ ]] || [ "$seconds" -lt 0 ] || [ "$seconds" -gt 59 ]; do
    echo "Please enter a valid number of seconds (0-59):"
    read -r seconds
done

# Validate that at least some time is specified
if [ "$minutes" -eq 0 ] && [ "$seconds" -eq 0 ]; then
    echo "Error: You must specify at least 1 second or 1 minute for the reminder."
    exit 1
fi

# Calculate total milliseconds for AHK timer
total_ms=$(( (minutes * 60 + seconds) * 1000 ))

# Generate unique filename to avoid conflicts
timestamp=$(date +%Y%m%d_%H%M%S)
ahk_file="reminder_${timestamp}.ahk"

echo "Creating reminder for: '$reminder_text'"
echo "Time: ${minutes}m ${seconds}s"

# Create the AutoHotkey script
cat > "$ahk_file" << 'EOL'
; Auto-generated reminder script
#NoEnv
#SingleInstance Force
#Persistent

; Set reminder details
ReminderText := "REMINDER_TEXT_PLACEHOLDER"
TimerMs := TIMER_MS_PLACEHOLDER

; Start the timer
SetTimer, ShowReminder, %TimerMs%

; Keep script running
return

ShowReminder:
    ; Disable the timer so it only runs once
    SetTimer, ShowReminder, Off
    
    ; Create persistent reminder window
    Gui, Add, Text, x20 y20 w400 h100 Center VCenter, %ReminderText%
    Gui, Add, Button, x170 y140 w80 h30 gCloseReminder, OK
    Gui, Show, w440 h190, Reminder
    
    ; Make window always on top
    WinSet, AlwaysOnTop, On, Reminder
    
    ; Play system sound
    SoundBeep, 1000, 500
    
    return

CloseReminder:
    ExitApp

GuiClose:
    ExitApp
EOL

# Replace placeholders in the AHK script
sed -i "s/REMINDER_TEXT_PLACEHOLDER/$reminder_text/g" "$ahk_file"
sed -i "s/TIMER_MS_PLACEHOLDER/$total_ms/g" "$ahk_file"

# Cleanup function
cleanup() {
    # Kill any AutoHotkey processes for this specific script
    taskkill //F //IM autohotkey.exe //FI "WINDOWTITLE eq $ahk_file" > /dev/null 2>&1
    rm -f "$ahk_file"
    exit 0
}

# Set up cleanup on script termination
trap cleanup SIGINT SIGTERM

echo "Starting reminder timer..."
echo "Press Ctrl+C to cancel the reminder"

# Check if AutoHotkey is available
if ! command -v autohotkey > /dev/null 2>&1; then
    echo "Warning: AutoHotkey not found in PATH. Trying to run AHK file directly..."
    if [ -f "/c/Program Files/AutoHotkey/AutoHotkey.exe" ]; then
        "/c/Program Files/AutoHotkey/AutoHotkey.exe" "$ahk_file"
    elif [ -f "/c/Program Files (x86)/AutoHotkey/AutoHotkey.exe" ]; then
        "/c/Program Files (x86)/AutoHotkey/AutoHotkey.exe" "$ahk_file"
    else
        echo "Error: AutoHotkey not found. Please install AutoHotkey or add it to your PATH."
        cleanup
    fi
else
    autohotkey "$ahk_file"
fi

# Clean up after AHK script exits
cleanup