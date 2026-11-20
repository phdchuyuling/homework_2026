\
    $ErrorActionPreference = "Stop"
    $Root = Split-Path -Parent $PSScriptRoot
    $Python = Join-Path $Root "runtime\python.exe"
    $Site = Join-Path $Root "runtime\Lib\site-packages"
    & $Python -m pip install --upgrade --target $Site -r (Join-Path $Root "requirements.txt")
    if ($LASTEXITCODE -ne 0) { throw "Dependency update failed" }
    $Code = Join-Path $Root "tools\vscode\Code.exe"
    & $Code --extensions-dir (Join-Path $Root "tools\vscode\data\extensions") --user-data-dir (Join-Path $Root "tools\vscode\data\user-data") --install-extension openai.chatgpt --force
    if ($LASTEXITCODE -ne 0) { throw "Codex extension update failed" }
    Write-Host "Update complete."
