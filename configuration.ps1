# Define paths
$folderPath = "C:\Program Files\FixResolution"
$scriptPath = "$folderPath\resolution.ps1"
$shortcutPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\resolution.lnk"
$taskName = "FixResolutionTask"

# Ensure the folder exists
if (!(Test-Path -Path $folderPath)) {
    New-Item -ItemType Directory -Path $folderPath -Force | Out-Null
}

# Copy resolution.ps1 to the folder
$sourceScript = "$PSScriptRoot\resolution.ps1"  # Ensures correct path
if (Test-Path -Path $sourceScript) {
    Copy-Item -Path $sourceScript -Destination $scriptPath -Force | Out-Null
} else {
    Write-Host "Error: resolution.ps1 not found in script directory!"
    exit
}

# Remove existing shortcut if it exists
if (Test-Path $shortcutPath) {
    Remove-Item -Path $shortcutPath -Force | Out-Null
}

# Create a shortcut to silently execute the script
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

# Get current username
$loggedInUser = "$env:USERNAME"

# Create a scheduled task to run with admin rights at logon
$taskAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -NoProfile -File `"$scriptPath`""
$taskTrigger = New-ScheduledTaskTrigger -AtLogOn
$taskPrincipal = New-ScheduledTaskPrincipal -UserId $loggedInUser -LogonType Interactive -RunLevel Highest
$taskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
$task = New-ScheduledTask -Action $taskAction -Trigger $taskTrigger -Principal $taskPrincipal -Settings $taskSettings

# Register the scheduled task
Register-ScheduledTask -TaskName $taskName -InputObject $task -Force | Out-Null  
