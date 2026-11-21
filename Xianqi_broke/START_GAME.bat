@echo off
setlocal
cd /d "%~dp0"
title Xiangqi AI Game Launcher
echo Starting Xiangqi AI...
where powershell.exe >nul 2>nul
if errorlevel 1 (
  echo ERROR: Windows PowerShell was not found.
  echo Open Projects\xiangqi-ai\index.html manually.
  pause
  exit /b 1
)
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0Projects\xiangqi-ai\RUN_GAME.ps1"
set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" echo Game launcher reported an error.
echo.
echo If the browser did not open, double-click Projects\xiangqi-ai\index.html.
pause
exit /b %RC%
