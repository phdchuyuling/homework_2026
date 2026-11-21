@echo off
setlocal
cd /d "%~dp0"
title Xiangqi AI - Local VS Code Launcher

 echo.
echo ==================================================
echo   XIANGQI AI PROJECT - LOCAL VS CODE LAUNCHER
echo ==================================================
echo.

where powershell.exe >nul 2>nul
if errorlevel 1 (
  echo ERROR: Windows PowerShell was not found.
  echo Please use Windows 10 or Windows 11.
  set "RC=1"
  goto :END
)

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0Tools\start-local-vscode.ps1"
set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" echo ERROR: Launcher failed with exit code %RC%.

:END
echo.
echo This window will remain open. Review the message above.
echo Log files, if created, are in the Logs folder.
echo.
pause
exit /b %RC%
