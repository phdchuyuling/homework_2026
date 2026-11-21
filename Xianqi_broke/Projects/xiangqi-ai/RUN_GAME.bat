@echo off
setlocal
cd /d "%~dp0"
title Xiangqi AI Game Launcher
echo Starting Xiangqi AI...
where powershell.exe >nul 2>nul
if errorlevel 1 (
  echo ERROR: Windows PowerShell was not found.
  echo Open index.html manually in Chrome or Edge.
  pause
  exit /b 1
)
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0RUN_GAME.ps1"
set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" echo Game launcher reported an error.
echo.
echo If the browser did not open, double-click index.html in this folder.
pause
exit /b %RC%
