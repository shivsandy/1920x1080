@echo off
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "& {Start-Process powershell -ArgumentList '-ExecutionPolicy Bypass -WindowStyle Hidden -File \"%~dp0configuration.ps1\"' -NoNewWindow -Wait}"
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "& {Start-Process powershell -ArgumentList '-ExecutionPolicy Bypass -WindowStyle Hidden -File \"%~dp0resolution.ps1\"' -NoNewWindow -Wait}"
timeout /t 2 /nobreak >nul
exit
