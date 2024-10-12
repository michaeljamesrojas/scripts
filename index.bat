@echo off

:: Define the alias name and the URL of the globally.bat script
set ALIAS_NAME=globally
set SCRIPT_URL=https://raw.githubusercontent.com/michaeljamesroars/scripts/main/globally.bat

:: Add the alias to the user's PowerShell profile
powershell -Command "$profile_path = $PROFILE.CurrentUserAllHosts; if (!(Test-Path $profile_path)) { New-Item -Type File -Path $profile_path -Force }; Add-Content $profile_path 'function globally { Invoke-Expression (New-Object Net.WebClient).DownloadString(''%SCRIPT_URL%'') }'"

echo Alias '%ALIAS_NAME%' has been added to your PowerShell profile.
echo Please restart your PowerShell or run 'powershell -Command . $PROFILE' to use the new alias.
