@echo off
setlocal enabledelayedexpansion

:: Prompt for branch name
set /p branch="Enter the branch name: "

:: Prompt for relative file path
set /p filepath="Enter the relative file name: "

:: Check if Git is available
where git >nul 2>&1
if errorlevel 1 (
    echo Git is not installed or not in the PATH.
    goto end
)

:: Show file contents from the specified branch
echo.
echo Showing contents of %filepath% from branch %branch%:
echo -----------------------------------------------
git show %branch%:%filepath%
if errorlevel 1 (
    echo.
    echo Failed to get the file. Check if branch and file path are correct.
)

:end
pause
