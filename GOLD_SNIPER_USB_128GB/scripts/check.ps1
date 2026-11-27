\
    $Root = Split-Path -Parent $PSScriptRoot
    Write-Host "USB root: $Root"
    foreach ($p in @("runtime\python.exe","tools\vscode\Code.exe",".env","GOLD_SNIPER_PRO\backend\app.py")) {
      $ok = Test-Path (Join-Path $Root $p)
      Write-Host ("{0,-42} {1}" -f $p, $(if($ok){"OK"}else{"MISSING"}))
    }
    try {
      $s = Invoke-RestMethod "http://127.0.0.1:8000/api/status" -TimeoutSec 2
      Write-Host "API: ONLINE"
      $s | Format-List
    } catch { Write-Host "API: OFFLINE" }
