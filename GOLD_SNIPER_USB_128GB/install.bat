@echo off
setlocal
cd /d "%~dp0"
title GOLD SNIPER USB - First-time Setup
echo ==========================================
echo   GOLD SNIPER USB - FIRST TIME SETUP
echo ==========================================
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\setup_usb.ps1"
if errorlevel 1 (
  echo.
  echo Setup failed. See the error above.
  pause
  exit /b 1
)
echo.
echo Setup complete. Double-click START.bat to launch.
pause
