\
    $ErrorActionPreference = "Stop"
    $Root = Split-Path -Parent $PSScriptRoot
    $Python = Join-Path $Root "runtime\python.exe"
    $Vscode = Join-Path $Root "tools\vscode\Code.exe"
    $VscodeData = Join-Path $Root "tools\vscode\data"
    $Ext = Join-Path $VscodeData "extensions"
    $UserData = Join-Path $VscodeData "user-data"
    $LogDir = Join-Path $Root "logs"
    New-Item -ItemType Directory -Force -Path $LogDir | Out-Null

    if (-not (Test-Path $Python)) { throw "Portable Python missing. Run install.bat." }
    if (-not (Test-Path $Vscode)) { throw "Portable VS Code missing. Run install.bat." }

    # Avoid starting a second copy if the local API is already responding.
    try {
      $null = Invoke-RestMethod "http://127.0.0.1:8000/api/status" -TimeoutSec 2
      Write-Host "GOLD SNIPER API already running."
    } catch {
      $OutLog = Join-Path $LogDir "api.log"
      $ErrLog = Join-Path $LogDir "api-error.log"
      $Proc = Start-Process -FilePath $Python `
        -ArgumentList @("-m","uvicorn","backend.app:app","--host","127.0.0.1","--port","8000") `
        -WorkingDirectory (Join-Path $Root "GOLD_SNIPER_PRO") `
        -WindowStyle Hidden -PassThru `
        -RedirectStandardOutput $OutLog -RedirectStandardError $ErrLog
      Set-Content -Path (Join-Path $LogDir "api.pid") -Value $Proc.Id -Encoding ASCII
    }

    $Ready = $false
    for ($i=0; $i -lt 30; $i++) {
      Start-Sleep -Seconds 1
      try {
        $Status = Invoke-RestMethod "http://127.0.0.1:8000/api/status" -TimeoutSec 2
        $Ready = $true
        break
      } catch {}
    }
    if (-not $Ready) { throw "API did not become ready. Check logs\api-error.log." }

    # Launch the portable editor with the project folder.
    Start-Process -FilePath $Vscode -ArgumentList @(
      "--user-data-dir",$UserData,
      "--extensions-dir",$Ext,
      (Join-Path $Root "GOLD_SNIPER_PRO")
    )

    # Open the dashboard in Edge when available; otherwise use the default browser.
    $Edge = "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"
    if (-not (Test-Path $Edge)) { $Edge = "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe" }
    if (Test-Path $Edge) {
      Start-Process -FilePath $Edge -ArgumentList "http://127.0.0.1:8000"
    } else {
      Start-Process "http://127.0.0.1:8000"
    }

    Write-Host "GOLD SNIPER is running at http://127.0.0.1:8000"
    Write-Host "Open Codex sidebar in VS Code and sign in on first use."
