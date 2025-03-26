# Define paths
$folderPath = "C:\Program Files\FixResolution"
$scriptPath = "$folderPath\resolution.ps1"
$uninstallerPath = "$folderPath\uninstaller.bat"
$shortcutPath = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\resolution.lnk"
$taskName = "FixResolutionTask"

# Ensure the folder exists
if (!(Test-Path -Path $folderPath)) {
    New-Item -ItemType Directory -Path $folderPath -Force | Out-Null
}

# Copy resolution.ps1 to the folder
$sourceScript = "$PSScriptRoot\resolution.ps1"
if (Test-Path -Path $sourceScript) {
    Copy-Item -Path $sourceScript -Destination $scriptPath -Force | Out-Null
} else {
    Write-Host "Error: resolution.ps1 not found in script directory!"
    exit
}

# Copy uninstaller.bat to the folder
$sourceUninstaller = "$PSScriptRoot\uninstaller.bat"
if (Test-Path -Path $sourceUninstaller) {
    Copy-Item -Path $sourceUninstaller -Destination $uninstallerPath -Force | Out-Null
} else {
    Write-Host "Error: uninstaller.bat not found in script directory!"
    exit
}

# Remove existing shortcut if it exists
if (Test-Path $shortcutPath) {
    Remove-Item -Path $shortcutPath -Force | Out-Null
}

# Create a shortcut in the "All Users" startup folder
$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($shortcutPath)
$Shortcut.TargetPath = "powershell.exe"
$Shortcut.Arguments = "-ExecutionPolicy Bypass -WindowStyle Hidden -NoProfile -File `"$scriptPath`""
$Shortcut.WorkingDirectory = $folderPath
$Shortcut.Save()

# Remove existing scheduled task if it exists
if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false | Out-Null
}

# Create a scheduled task for ALL users
$taskAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -NoProfile -File `"$scriptPath`""
$taskTrigger = New-ScheduledTaskTrigger -AtLogOn
$taskPrincipal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$taskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
$task = New-ScheduledTask -Action $taskAction -Trigger $taskTrigger -Principal $taskPrincipal -Settings $taskSettings

# Register the scheduled task for all users
Register-ScheduledTask -TaskName $taskName -InputObject $task -Force | Out-Null     

Write-Host "Setup complete: resolution.ps1 and uninstaller.bat copied, startup shortcut and scheduled task created."
