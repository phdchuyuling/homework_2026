$ErrorActionPreference = "Stop"

Push-Location flutter_mole_game
flutter build windows --release
Pop-Location

$release = Join-Path $PSScriptRoot "flutter_mole_game\build\windows\x64\runner\Release"
Copy-Item (Join-Path $release "flutter_mole_game.exe") (Join-Path $PSScriptRoot "WhackAMole.exe") -Force
Copy-Item (Join-Path $release "flutter_windows.dll") (Join-Path $PSScriptRoot "flutter_windows.dll") -Force
if (Test-Path (Join-Path $PSScriptRoot "data")) {
	Remove-Item (Join-Path $PSScriptRoot "data") -Recurse -Force
}
Copy-Item (Join-Path $release "data") (Join-Path $PSScriptRoot "data") -Recurse -Force

Write-Host "完成：WhackAMole.exe、data\、flutter_windows.dll" -ForegroundColor Green