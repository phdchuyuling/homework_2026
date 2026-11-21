$ErrorActionPreference = 'Stop'
$Project = Split-Path -Parent $MyInvocation.MyCommand.Path
$Html = Join-Path $Project 'index.html'
$LogDir = Join-Path (Split-Path -Parent (Split-Path -Parent $Project)) 'Logs'
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
$Log = Join-Path $LogDir ("game-" + (Get-Date -Format 'yyyyMMdd-HHmmss') + '.log')
try {
  if (-not (Test-Path -LiteralPath $Html -PathType Leaf)) { throw "index.html not found: $Html" }
  "Launching game: $Html" | Out-File -LiteralPath $Log -Encoding utf8
  Start-Process -FilePath $Html -ErrorAction Stop
  Write-Host "Game launch requested. Your default browser should open now."
  Write-Host "If it did not, open this file manually:"
  Write-Host $Html
  Write-Host "Log: $Log"
  exit 0
} catch {
  ("ERROR: " + $_.Exception.Message) | Out-File -LiteralPath $Log -Append -Encoding utf8
  Write-Host "Could not launch the browser automatically." -ForegroundColor Red
  Write-Host $_.Exception.Message
  Write-Host "Open index.html manually from:"
  Write-Host $Project
  Write-Host "Log: $Log"
  exit 1
}
