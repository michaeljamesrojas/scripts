#!/bin/bash

cat > window_switcher.ps1 << 'EOL'
Add-Type @"
    using System;
    using System.Runtime.InteropServices;
    using System.Collections.Generic;

    public class WindowSwitcher {
        [DllImport("user32.dll")]
        public static extern IntPtr GetForegroundWindow();

        [DllImport("user32.dll")]
        public static extern bool SetForegroundWindow(IntPtr hWnd);

        [DllImport("user32.dll")]
        public static extern short GetAsyncKeyState(int vKey);
    }
"@

# Store window handles
$windowHandles = @{}

while ($true) {
    # Check for Alt + Shift + Number (store window)
    for ($i = 1; $i -le 9; $i++) {
        $altKey = [WindowSwitcher]::GetAsyncKeyState(0x12) -band 0x8000  # Alt
        $shiftKey = [WindowSwitcher]::GetAsyncKeyState(0x10) -band 0x8000  # Shift
        $numberKey = [WindowSwitcher]::GetAsyncKeyState(0x30 + $i) -band 0x8000  # Numbers 1-9
        
        if ($altKey -and $shiftKey -and $numberKey) {
            $currentWindow = [WindowSwitcher]::GetForegroundWindow()
            $windowHandles[$i] = $currentWindow
            Write-Host "Window $i stored"
            Start-Sleep -Milliseconds 500
        }
    }

    # Check for Alt + Number (switch to window)
    for ($i = 1; $i -le 9; $i++) {
        $altKey = [WindowSwitcher]::GetAsyncKeyState(0x12) -band 0x8000
        $numberKey = [WindowSwitcher]::GetAsyncKeyState(0x30 + $i) -band 0x8000
        
        if ($altKey -and -not $shiftKey -and $numberKey -and $windowHandles.ContainsKey($i)) {
            [WindowSwitcher]::SetForegroundWindow($windowHandles[$i])
            Start-Sleep -Milliseconds 500
        }
    }
    
    Start-Sleep -Milliseconds 50
}
EOL

# Cleanup function
cleanup() {
    taskkill //F //IM powershell.exe //FI "WINDOWTITLE eq window_switcher" > /dev/null 2>&1
    rm window_switcher.ps1
    exit 0
}

trap cleanup SIGINT SIGTERM

powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File window_switcher.ps1 > /dev/null 2>&1
