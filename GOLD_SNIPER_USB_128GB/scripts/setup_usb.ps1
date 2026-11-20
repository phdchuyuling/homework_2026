\
    $ErrorActionPreference = "Stop"
    $Root = Split-Path -Parent $PSScriptRoot
    $Runtime = Join-Path $Root "runtime"
    $Vscode = Join-Path $Root "tools\vscode"
    $Site = Join-Path $Runtime "Lib\site-packages"
    $Logs = Join-Path $Root "logs"
    New-Item -ItemType Directory -Force -Path $Runtime,$Site,$Vscode,$Logs | Out-Null

    function Download($Url, $OutFile) {
      Write-Host "Downloading $Url"
      Invoke-WebRequest -Uri $Url -OutFile $OutFile -UseBasicParsing
    }

    # Official Python embeddable distribution (Windows x64, Python 3.12.10).
    $PyZip = Join-Path $env:TEMP "gold-sniper-python-3.12.10-embed-amd64.zip"
    Download "https://www.python.org/ftp/python/3.12.10/python-3.12.10-embed-amd64.zip" $PyZip
    Expand-Archive -Path $PyZip -DestinationPath $Runtime -Force
    Remove-Item $PyZip -Force

    $Pth = Join-Path $Runtime "python312._pth"
    $PthContent = @"
    python312.zip
    .
    Lib\site-packages
    import site
    "@
    Set-Content -Path $Pth -Value $PthContent -Encoding ASCII

    # Bootstrap pip into the USB runtime only.
    $GetPip = Join-Path $env:TEMP "gold-sniper-get-pip.py"
    Download "https://bootstrap.pypa.io/get-pip.py" $GetPip
    & (Join-Path $Runtime "python.exe") $GetPip --no-warn-script-location
    if ($LASTEXITCODE -ne 0) { throw "pip bootstrap failed" }
    Remove-Item $GetPip -Force

    & (Join-Path $Runtime "python.exe") -m pip install --upgrade pip
    & (Join-Path $Runtime "python.exe") -m pip install --target $Site -r (Join-Path $Root "requirements.txt")
    if ($LASTEXITCODE -ne 0) { throw "Python dependencies installation failed" }

    # Portable VS Code archive and isolated user-data/extensions on the USB.
    $CodeZip = Join-Path $env:TEMP "gold-sniper-vscode-win32-x64.zip"
    Download "https://update.code.visualstudio.com/latest/win32-x64-archive/stable" $CodeZip
    Expand-Archive -Path $CodeZip -DestinationPath $Vscode -Force
    Remove-Item $CodeZip -Force
    New-Item -ItemType Directory -Force -Path (Join-Path $Vscode "data") | Out-Null

    $CodeExe = Join-Path $Vscode "Code.exe"
    if (-not (Test-Path $CodeExe)) { throw "VS Code portable archive did not contain Code.exe" }

    # Official OpenAI Codex extension from the VS Code Marketplace.
    & $CodeExe --extensions-dir (Join-Path $Vscode "data\extensions") --user-data-dir (Join-Path $Vscode "data\user-data") --install-extension openai.chatgpt
    if ($LASTEXITCODE -ne 0) { throw "OpenAI Codex VS Code extension installation failed" }

    # Generate a unique webhook path token for this local bridge.
    $EnvFile = Join-Path $Root ".env"
    if (-not (Test-Path $EnvFile)) {
      $Bytes = New-Object byte[] 32
      [System.Security.Cryptography.RandomNumberGenerator]::Fill($Bytes)
      $Token = [Convert]::ToBase64String($Bytes).TrimEnd('=').Replace('+','-').Replace('/','_')
      @"
    WEBHOOK_PATH_TOKEN=$Token
    MIN_SIGNAL_SCORE=85
    MIN_RR=2.0
    "@ | Set-Content -Path $EnvFile -Encoding ASCII
    }

    Write-Host ""
    Write-Host "Setup completed."
    Write-Host "Python runtime and VS Code are stored on this USB."
    Write-Host "Sign in to Codex inside VS Code on first launch."
