setlocal enabledelayedexpansion

:: Define the base URL for raw content
set "base_url=https://raw.githubusercontent.com/michaeljamesrojas/scripts/main"

:: Fetch the list of files from the repository
echo Available scripts:
echo.

:: Use PowerShell to fetch and parse the JSON
powershell -Command "& {$scripts = (Invoke-RestMethod 'https://api.github.com/repos/michaeljamesrojas/scripts/contents' | Where-Object {$_.name -like '*.sh'}).name; $scripts | ForEach-Object {$i=1} {Write-Host ('{0}. {1}' -f $i++, $_)}}"

if %errorlevel% neq 0 (
    echo Error: Failed to fetch the list of scripts.
    exit /b 1
)

:: Prompt user to choose a script
set /p choice="Enter the number of the script you want to execute: "

:: Validate user input (basic validation)
if "%choice%"=="" goto invalid_choice
set "num="&for /f "delims=0123456789" %%i in ("%choice%") do set num=%%i
if defined num goto invalid_choice

:: Get the selected script name
powershell -Command "& {$scripts = (Invoke-RestMethod 'https://api.github.com/repos/michaeljamesrojas/scripts/contents' | Where-Object {$_.name -like '*.sh'}).name; Write-Host $scripts[%choice% - 1]}" > temp.txt
set /p selected_script=<temp.txt
del temp.txt

:: Ask for confirmation
echo.
set /p confirm="Do you really want to execute %selected_script%? (y/n): "
echo.

if /i "%confirm%" neq "y" (
    echo Execution cancelled.
    exit /b 0
)

:: Execute the chosen script directly from the raw URL
set "script_url=%base_url%/%selected_script%"
echo Fetching and executing script: %selected_script%
echo.

powershell -Command "& {Invoke-Expression ((New-Object Net.WebClient).DownloadString('%script_url%'))}"

if %errorlevel% neq 0 (
    echo Error: Failed to fetch or execute the script.
    exit /b 1
)

exit /b 0

:invalid_choice
echo Invalid choice. Please enter a valid number.
exit /b 1
