\
    $Root = Split-Path -Parent $PSScriptRoot
    $PidFile = Join-Path $Root "logs\api.pid"
    if (Test-Path $PidFile) {
      $Id = [int](Get-Content $PidFile -Raw)
      try {
        $P = Get-Process -Id $Id -ErrorAction Stop
        if ($P.ProcessName -match "python") { Stop-Process -Id $Id -Force; Write-Host "Stopped API process $Id" }
      } catch { Write-Host "API process is not running." }
      Remove-Item $PidFile -Force -ErrorAction SilentlyContinue
    } else {
      Write-Host "No managed API process ID found."
    }
