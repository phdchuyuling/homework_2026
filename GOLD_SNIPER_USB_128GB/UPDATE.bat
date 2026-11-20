@echo off
cd /d "%~dp0"
echo This updates Python dependencies and the official Codex VS Code extension.
echo Internet connection required.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\update.ps1"
pause
