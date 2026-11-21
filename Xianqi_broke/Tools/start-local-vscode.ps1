$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $PSScriptRoot
$Project = Join-Path $Root 'Projects\xiangqi-ai'
$LogDir = Join-Path $Root 'Logs'
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
$Log = Join-Path $LogDir ("start-" + (Get-Date -Format 'yyyyMMdd-HHmmss') + '.log')
function Say([string]$Message) {
  $line = "[{0}] {1}" -f (Get-Date -Format 'HH:mm:ss'), $Message
  Write-Host $line
  Add-Content -LiteralPath $Log -Value $line -Encoding UTF8
}
function Find-Code {
  foreach ($name in @('code.cmd','code.exe')) {
    $cmd = Get-Command $name -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($cmd -and $cmd.Source) { return @{Kind='Command'; Path=$cmd.Source} }
  }
  $candidates = @()
  if ($env:LOCALAPPDATA) { $candidates += (Join-Path $env:LOCALAPPDATA 'Programs\Microsoft VS Code\Code.exe') }
  if ($env:ProgramFiles) { $candidates += (Join-Path $env:ProgramFiles 'Microsoft VS Code\Code.exe') }
  if (${env:ProgramFiles(x86)}) { $candidates += (Join-Path ${env:ProgramFiles(x86)} 'Microsoft VS Code\Code.exe') }
  if ($env:LOCALAPPDATA) { $candidates += (Join-Path $env:LOCALAPPDATA 'Programs\Microsoft VS Code Insiders\Code - Insiders.exe') }
  foreach ($p in $candidates) { if (Test-Path -LiteralPath $p -PathType Leaf) { return @{Kind='Exe'; Path=$p} } }
  $keys = @(
    'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
  )
  foreach ($key in $keys) {
    $items = Get-ItemProperty $key -ErrorAction SilentlyContinue
    foreach ($item in $items) {
      if ($item.DisplayName -like 'Microsoft Visual Studio Code*') {
        $locations = @($item.InstallLocation, $item.DisplayIcon) | Where-Object { $_ }
        foreach ($loc in $locations) {
          $candidate = [string]$loc -replace ',\d+$','' -replace '^"|"$',''
          if (Test-Path -LiteralPath $candidate -PathType Leaf -and (Split-Path $candidate -Leaf) -eq 'Code.exe') { return @{Kind='Exe'; Path=$candidate} }
          if (Test-Path -LiteralPath (Join-Path $candidate 'Code.exe') -PathType Leaf) { return @{Kind='Exe'; Path=(Join-Path $candidate 'Code.exe')} }
        }
      }
    }
  }
  return $null
}
try {
  Say 'Starting launcher.'
  if (-not (Test-Path -LiteralPath $Project -PathType Container)) { throw "Project folder not found: $Project" }
  $code = Find-Code
  if (-not $code) { throw 'VS Code was not found. Install Microsoft Visual Studio Code or add the code command to PATH.' }
  Say ("VS Code found: " + $code.Path)
  Say ("Project folder: " + $Project)
  $quotedProject = '"' + $Project + '"'
  Start-Process -FilePath $code.Path -ArgumentList @('--new-window', $quotedProject) | Out-Null
  Start-Sleep -Seconds 2
  Say 'VS Code launch command was sent. Check the Explorer panel for the xiangqi-ai folder.'
  Say 'No VS Code download or system PATH modification was performed.'
  exit 0
} catch {
  Say ('ERROR: ' + $_.Exception.Message)
  Write-Host ''
  Write-Host 'Copy this error and the newest file in Logs when asking for help.' -ForegroundColor Yellow
  exit 1
}
