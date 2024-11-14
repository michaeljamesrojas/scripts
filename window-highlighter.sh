#!/bin/bash

# Create a temporary PowerShell script for window monitoring
cat > window_monitor.ps1 << 'EOL'
Add-Type @"
    using System;
    using System.Runtime.InteropServices;

    public class WindowHighlighter {
        [DllImport("user32.dll")]
        public static extern IntPtr GetForegroundWindow();

        [DllImport("user32.dll")]
        public static extern bool GetWindowRect(IntPtr hwnd, out RECT lpRect);

        [DllImport("user32.dll")]
        public static extern int GetWindowText(IntPtr hWnd, System.Text.StringBuilder text, int count);

        [DllImport("user32.dll")]
        public static extern short GetAsyncKeyState(int vKey);

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
$altTabbing = $false

while ($true) {
    $currentWindow = [WindowHighlighter]::GetForegroundWindow()
    $altKey = [WindowHighlighter]::GetAsyncKeyState(0x12) -band 0x8000
    $tabKey = [WindowHighlighter]::GetAsyncKeyState(0x09) -band 0x8000
    
    if ($altKey -and $tabKey) {
        $altTabbing = $true
    }
    elseif (-not $altKey -and $altTabbing) {
        $altTabbing = $false
        if ($currentWindow -ne $lastWindow) {
            [WindowHighlighter]::GetWindowRect($currentWindow, [ref]$rect)
            
            $highlightForm.Location = New-Object System.Drawing.Point($rect.Left, $rect.Top)
            $highlightForm.Size = New-Object System.Drawing.Size(
                ($rect.Right - $rect.Left),
                ($rect.Bottom - $rect.Top)
            )
            
            $highlightForm.Show()
            Start-Sleep -Milliseconds 200
            $highlightForm.Hide()
            
            $lastWindow = $currentWindow
        }
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
# powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File window_monitor.ps1
powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File window_monitor.ps1 > $null

