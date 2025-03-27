@echo off
:: Request admin privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    powershell -Command "Start-Process cmd -ArgumentList '/c %~s0' -Verb RunAs"
    exit
)

:: Step 1: Delete the shortcut from startup
set "shortcutPath=C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\resolution.lnk"
if exist "%shortcutPath%" (
    del "%shortcutPath%"
)

:: Step 2: Delete the folder in Program Files
set "folderPath=C:\Program Files\FixResolution"
if exist "%folderPath%" (
    rmdir /s /q "%folderPath%"
)

:: Step 3: Delete the Task Scheduler job
schtasks /delete /tn "FixResolutionTask" /f >nul 2>&1

exit
