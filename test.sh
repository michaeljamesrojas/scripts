#!/bin/bash

# Create a temporary PowerShell script for window monitoring
cat > window_monitor.ps1 << 'EOL'
Add-Type @"
    using System;
    using System.Runtime.InteropServices;
    using System.Windows.Forms;

    public class WindowHighlighter {
        [DllImport("user32.dll")]
        public static extern IntPtr GetForegroundWindow();

        [DllImport("user32.dll")]
        public static extern bool GetWindowRect(IntPtr hwnd, out RECT lpRect);

        [DllImport("user32.dll")]
        public static extern int GetWindowText(IntPtr hWnd, System.Text.StringBuilder text, int count);

        [DllImport("user32.dll")]
        public static extern short GetAsyncKeyState(Keys vKey);

        [StructLayout(LayoutKind.Sequential)]
        public struct RECT {
            public int Left;
            public int Top;
            public int Right;
            public int Bottom;
        }
    }
"@

# Create highlight form
Add-Type -AssemblyName System.Windows.Forms
$highlightForm = New-Object System.Windows.Forms.Form
$highlightForm.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::None
$highlightForm.BackColor = [System.Drawing.Color]::Yellow
$highlightForm.Opacity = 0.3
$highlightForm.ShowInTaskbar = $false
$highlightForm.TopMost = $true

$lastWindow = [IntPtr]::Zero
$rect = New-Object WindowHighlighter+RECT
$altPressed = $false
$tabPressed = $false
$shouldHighlight = $false

while ($true) {
    $currentWindow = [WindowHighlighter]::GetForegroundWindow()
    
    # Check if Alt key is pressed
    $altState = [WindowHighlighter]::GetAsyncKeyState([System.Windows.Forms.Keys]::Alt) -band 0x8000
    
    # Check if Tab key is pressed
    $tabState = [WindowHighlighter]::GetAsyncKeyState([System.Windows.Forms.Keys]::Tab) -band 0x8000
    
    # Detect Alt+Tab sequence
    if ($altState -and $tabState) {
        $shouldHighlight = $true
    }
    
    # If window changed and we should highlight (after Alt+Tab)
    if (($currentWindow -ne $lastWindow) -and $shouldHighlight) {
        [WindowHighlighter]::GetWindowRect($currentWindow, [ref]$rect)
        
        $highlightForm.Location = New-Object System.Drawing.Point($rect.Left, $rect.Top)
        $highlightForm.Size = New-Object System.Drawing.Size(
            ($rect.Right - $rect.Left),
            ($rect.Bottom - $rect.Top)
        )
        
        $highlightForm.Show()
        Start-Sleep -Milliseconds 200
        $highlightForm.Hide()
        
        $shouldHighlight = $false
        $lastWindow = $currentWindow
    }
    
    # Reset highlight flag if Alt is released
    if (-not $altState) {
        $shouldHighlight = $false
    }
    
    Start-Sleep -Milliseconds 50
}
EOL

# Function to clean up on script exit
cleanup() {
    # Kill any running PowerShell processes started by this script
    taskkill //F //IM powershell.exe //FI "WINDOWTITLE eq window_monitor" > /dev/null 2>&1
    rm window_monitor.ps1
    exit 0
}

# Set up cleanup on script termination
trap cleanup SIGINT SIGTERM

# Start the PowerShell script
powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File window_monitor.ps1