@echo off
:: Request admin privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Running with administrator privileges...
    powershell -Command "Start-Process cmd -ArgumentList '/c %~s0' -Verb RunAs"
    exit
)

:: Step 1: Delete the shortcut from startup
set "shortcutPath=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\resolution.lnk"
if exist "%shortcutPath%" (
    del "%shortcutPath%"
    echo Deleted startup shortcut.
) else (
    echo Startup shortcut not found.
)

:: Step 2: Delete the folder in Program Files
set "folderPath=C:\Program Files\FixResolution"
if exist "%folderPath%" (
    rmdir /s /q "%folderPath%"
    echo Deleted FixResolution folder.
) else (
    echo FixResolution folder not found.
)

:: Step 3: Delete the Task Scheduler job
schtasks /delete /tn "FixResolutionTask" /f
echo Deleted Task Scheduler job.

echo Cleanup completed!
pause
