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
echo "Total milliseconds: $total_ms"

# Escape special characters in reminder text for AHK
escaped_text=$(echo "$reminder_text" | sed 's/"/`"/g' | sed "s/'/\`'/g")

# Create the AutoHotkey script directly with variables
cat > "$ahk_file" << EOL
; Auto-generated reminder script
#NoEnv
#SingleInstance Force
#Persistent

; Set reminder details
ReminderText := "$escaped_text"
TimerMs := $total_ms

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

echo "Generated AHK file: $ahk_file"
echo "Starting reminder timer..."
echo "The reminder window will appear in ${minutes}m ${seconds}s"
echo ""

# Find and run AutoHotkey
ahk_path=""
if command -v autohotkey > /dev/null 2>&1; then
    ahk_path="autohotkey"
elif [ -f "/c/Program Files/AutoHotkey/v2/AutoHotkey.exe" ]; then
    ahk_path="/c/Program Files/AutoHotkey/v2/AutoHotkey.exe"
elif [ -f "/c/Program Files/AutoHotkey/AutoHotkey.exe" ]; then
    ahk_path="/c/Program Files/AutoHotkey/AutoHotkey.exe"
elif [ -f "/c/Program Files (x86)/AutoHotkey/AutoHotkey.exe" ]; then
    ahk_path="/c/Program Files (x86)/AutoHotkey/AutoHotkey.exe"
else
    echo "Error: AutoHotkey not found. Please install AutoHotkey."
    echo "You can download it from: https://www.autohotkey.com/"
    echo "Generated AHK file is saved as: $ahk_file"
    echo "You can run it manually once AutoHotkey is installed."
    exit 1
fi

echo "Running: $ahk_path $ahk_file"
echo "Press Ctrl+C to cancel the reminder before it triggers"
echo ""

# Run AutoHotkey and wait for it to complete
"$ahk_path" "$ahk_file"

echo "Reminder finished. Cleaning up..."
cleanup