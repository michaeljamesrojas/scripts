# PowerShell Reminder Popup Script
param(
    [string]$ReminderText = "",
    [int]$Minutes = -1,
    [int]$Seconds = -1
)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Function to get user input if not provided as parameters
function Get-UserInput {
    # Get reminder text
    if ([string]::IsNullOrEmpty($script:ReminderText)) {
        do {
            $script:ReminderText = Read-Host "Enter reminder text"
        } while ([string]::IsNullOrEmpty($script:ReminderText))
    }

    # Get minutes
    if ($script:Minutes -eq -1) {
        do {
            $input = Read-Host "Enter minutes (0 for no minutes)"
            if ([int]::TryParse($input, [ref]$script:Minutes) -and $script:Minutes -ge 0) {
                break
            }
            Write-Host "Please enter a valid number of minutes (0 or positive)" -ForegroundColor Red
        } while ($true)
    }

    # Get seconds
    if ($script:Seconds -eq -1) {
        do {
            $input = Read-Host "Enter seconds (0-59)"
            if ([int]::TryParse($input, [ref]$script:Seconds) -and $script:Seconds -ge 0 -and $script:Seconds -le 59) {
                break
            }
            Write-Host "Please enter a valid number of seconds (0-59)" -ForegroundColor Red
        } while ($true)
    }

    # Validate that at least some time is specified
    if ($script:Minutes -eq 0 -and $script:Seconds -eq 0) {
        Write-Host "Error: You must specify at least 1 second or 1 minute for the reminder." -ForegroundColor Red
        exit 1
    }
}

# Function to create and show reminder window
function Show-ReminderWindow {
    # Create the form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "⏰ REMINDER"
    $form.Size = New-Object System.Drawing.Size(450, 200)
    $form.StartPosition = "CenterScreen"
    $form.TopMost = $true
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false
    $form.MinimizeBox = $false
    $form.BackColor = [System.Drawing.Color]::LightYellow
    
    # Create reminder text label
    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(20, 30)
    $label.Size = New-Object System.Drawing.Size(400, 80)
    $label.Text = $script:ReminderText
    $label.Font = New-Object System.Drawing.Font("Arial", 12, [System.Drawing.FontStyle]::Bold)
    $label.TextAlign = "MiddleCenter"
    $label.BackColor = [System.Drawing.Color]::Transparent
    $form.Controls.Add($label)
    
    # Create OK button
    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(175, 120)
    $okButton.Size = New-Object System.Drawing.Size(100, 30)
    $okButton.Text = "OK"
    $okButton.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
    $okButton.BackColor = [System.Drawing.Color]::LightBlue
    $okButton.Add_Click({
        $form.Close()
    })
    $form.Controls.Add($okButton)
    $form.AcceptButton = $okButton
    
    # Play system beep
    [System.Console]::Beep(1000, 500)
    
    # Show the form
    $form.Add_Shown({
        $form.Activate()
        $okButton.Focus()
    })
    
    [void]$form.ShowDialog()
}

# Main execution
try {
    # Get user input
    Get-UserInput
    
    # Calculate total milliseconds
    $totalSeconds = ($Minutes * 60) + $Seconds
    $totalMs = $totalSeconds * 1000
    
    Write-Host ""
    Write-Host "=== REMINDER SET ===" -ForegroundColor Green
    Write-Host "Message: $ReminderText" -ForegroundColor Yellow
    Write-Host "Time: ${Minutes}m ${Seconds}s" -ForegroundColor Yellow
    Write-Host "The reminder will appear in $totalSeconds seconds" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Press Ctrl+C to cancel..." -ForegroundColor Gray
    
    # Wait for the specified time
    Start-Sleep -Seconds $totalSeconds
    
    Write-Host ""
    Write-Host "⏰ TIME'S UP! Showing reminder..." -ForegroundColor Red
    
    # Show the reminder window
    Show-ReminderWindow
    
    Write-Host "Reminder acknowledged. Script complete." -ForegroundColor Green
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
finally {
    # Cleanup (nothing specific needed for this implementation)
}