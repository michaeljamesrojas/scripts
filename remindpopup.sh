#!/bin/bash

# Function to prompt for missing parameters
prompt_for_reminder_text() {
    echo "Enter reminder text:"
    read -r reminder_text
}

prompt_for_minutes() {
    echo "Enter minutes (0 for no minutes):"
    read -r minutes
    while ! [[ "$minutes" =~ ^[0-9]+$ ]] || [ "$minutes" -lt 0 ]; do
        echo "Please enter a valid number of minutes (0 or positive):"
        read -r minutes
    done
}

prompt_for_seconds() {
    echo "Enter seconds (0 for no seconds):"
    read -r seconds
    while ! [[ "$seconds" =~ ^[0-9]+$ ]] || [ "$seconds" -lt 0 ] || [ "$seconds" -gt 59 ]; do
        echo "Please enter a valid number of seconds (0-59):"
        read -r seconds
    done
}

# Parse command line arguments
reminder_text="$1"
minutes="$2"
seconds="$3"

# Check if reminder text was provided
if [ -z "$reminder_text" ]; then
    prompt_for_reminder_text
fi

# Check if minutes was provided and validate
if [ -z "$minutes" ]; then
    prompt_for_minutes
else
    # Validate provided minutes
    if ! [[ "$minutes" =~ ^[0-9]+$ ]] || [ "$minutes" -lt 0 ]; then
        echo "Error: Invalid minutes parameter '$minutes'. Must be a non-negative integer."
        prompt_for_minutes
    fi
fi

# Check if seconds was provided and validate
if [ -z "$seconds" ]; then
    prompt_for_seconds
else
    # Validate provided seconds
    if ! [[ "$seconds" =~ ^[0-9]+$ ]] || [ "$seconds" -lt 0 ] || [ "$seconds" -gt 59 ]; then
        echo "Error: Invalid seconds parameter '$seconds'. Must be an integer between 0-59."
        prompt_for_seconds
    fi
fi

# Validate that at least some time is specified
if [ "$minutes" -eq 0 ] && [ "$seconds" -eq 0 ]; then
    echo "Error: You must specify at least 1 second or 1 minute for the reminder."
    exit 1
fi

# Calculate total seconds
total_seconds=$(( (minutes * 60) + seconds ))

# Generate unique filename to avoid conflicts in temp folder
timestamp=$(date +%Y%m%d_%H%M%S)
temp_folder="/c/Users/$(whoami)/AppData/Local/Temp"
ps_file="$temp_folder/reminder_${timestamp}.ps1"

echo "Creating reminder for: '$reminder_text'"
echo "Time: ${minutes}m ${seconds}s"
echo "Total seconds: $total_seconds"

# Escape special characters in reminder text for PowerShell
escaped_text=$(echo "$reminder_text" | sed 's/"/\\"/g' | sed "s/'/\\'/g")

# Create the PowerShell script
cat > "$ps_file" << EOL
# Auto-generated reminder script
\$scriptPath = \$MyInvocation.MyCommand.Path

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Function to create and show reminder window
function Show-ReminderWindow {
    # Create the form
    \$form = New-Object System.Windows.Forms.Form
    \$form.Text = "⏰ REMINDER"
    \$form.Size = New-Object System.Drawing.Size(450, 200)
    \$form.StartPosition = "CenterScreen"
    \$form.TopMost = \$true
    \$form.FormBorderStyle = "FixedDialog"
    \$form.MaximizeBox = \$false
    \$form.MinimizeBox = \$false
    \$form.BackColor = [System.Drawing.Color]::LightYellow

    # Create reminder text label
    \$label = New-Object System.Windows.Forms.Label
    \$label.Location = New-Object System.Drawing.Point(20, 30)
    \$label.Size = New-Object System.Drawing.Size(400, 80)
    \$label.Text = "$escaped_text"
    \$label.Font = New-Object System.Drawing.Font("Arial", 12, [System.Drawing.FontStyle]::Bold)
    \$label.TextAlign = "MiddleCenter"
    \$label.BackColor = [System.Drawing.Color]::Transparent
    \$form.Controls.Add(\$label)

    # Create OK button
    \$okButton = New-Object System.Windows.Forms.Button
    \$okButton.Location = New-Object System.Drawing.Point(175, 120)
    \$okButton.Size = New-Object System.Drawing.Size(100, 30)
    \$okButton.Text = "OK"
    \$okButton.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
    \$okButton.BackColor = [System.Drawing.Color]::LightBlue
    \$okButton.Add_Click({
        \$form.Close()
    })
    \$form.Controls.Add(\$okButton)
    \$form.AcceptButton = \$okButton

    # Play system beep
    [System.Console]::Beep(1000, 500)

    # Show the form
    \$form.Add_Shown({
        \$form.Activate()
        \$okButton.Focus()
    })

    [void]\$form.ShowDialog()
}

# Main execution
try {
    # Wait for the specified time
    Start-Sleep -Seconds $total_seconds

    # Show the reminder window
    Show-ReminderWindow
}
finally {
    # Clean up this script file
    if (Test-Path \$scriptPath) {
        Remove-Item \$scriptPath -Force -ErrorAction SilentlyContinue
    }
}
EOL

echo "Generated PowerShell file: $ps_file"
echo "Starting reminder timer..."
echo "The reminder window will appear in ${minutes}m ${seconds}s"
echo ""

echo "Launching detached PowerShell reminder..."

# Launch PowerShell script hidden in background and exit immediately
powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File "$ps_file" &

echo "Reminder started! You can close this terminal."
echo "The reminder popup will appear automatically after the timer expires."