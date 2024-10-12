@echo off

:: Get the path of the PowerShell profile
for /f "tokens=*" %%a in ('powershell -Command "echo $PROFILE.CurrentUserAllHosts"') do set PROFILE_PATH=%%a

:: Create the profile file if it doesn't exist
if not exist "%PROFILE_PATH%" (
    echo Creating PowerShell profile file...
    powershell -Command "New-Item -Type File -Path $PROFILE.CurrentUserAllHosts -Force"
)

powershell -Command "echo $PROFILE.CurrentUserAllHosts"

:: Open the profile file in Notepad
start notepad "%PROFILE_PATH%"

echo PowerShell profile opened for editing.
echo After making changes, remember to restart PowerShell or run 'powershell -Command . $PROFILE' to apply the changes.
