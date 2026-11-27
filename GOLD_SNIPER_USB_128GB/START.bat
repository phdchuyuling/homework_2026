@echo off
setlocal
cd /d "%~dp0"
title GOLD SNIPER USB
if not exist "%~dp0runtime\python.exe" (
  echo Portable runtime not found. Starting first-time setup...
  call "%~dp0install.bat"
  if errorlevel 1 exit /b 1
)
if not exist "%~dp0.env" (
  echo Missing .env. Run install.bat first.
  pause
  exit /b 1
)
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\start_all.ps1"
if errorlevel 1 (
  echo Startup failed. Check logs\startup.log and logs\api-error.log
  pause
)
