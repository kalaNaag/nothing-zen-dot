# NOTHING ZEN DOT v1.2.0 installer
$ErrorActionPreference = 'Stop'

$profilePath = 'C:\Users\s.patil\AppData\Roaming\zen\Profiles\b9fgs9y3.Default (release)'
$modId = 'nothing_zen_dot'
$repoRaw = 'https://raw.githubusercontent.com/kalaNaag/nothing-zen-dot/main/'
$modDir = Join-Path $profilePath ('chrome\zen-themes\' + $modId)
$chromeDir = Join-Path $profilePath 'chrome'
$themesFile = Join-Path $profilePath 'zen-themes.json'
$userContent = Join-Path $chromeDir 'userContent.css'
$userJs = Join-Path $profilePath 'user.js'
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'

Write-Host ''
Write-Host 'NOTHING ZEN DOT v1.2.0' -ForegroundColor White
Write-Host '----------------------' -ForegroundColor DarkGray

if (-not (Test-Path -LiteralPath $profilePath)) {
  Write-Host 'ERROR: Zen profile not found:' -ForegroundColor Red
  Write-Host $profilePath -ForegroundColor Yellow
  Read-Host 'Press Enter to exit'
  exit 1
}

if (Get-Process -Name 'zen' -ErrorAction SilentlyContinue) {
  Write-Host 'ERROR: Zen is running.' -ForegroundColor Red
  Write-Host 'Close every Zen window and run the installer again.' -ForegroundColor Yellow
  Read-Host 'Press Enter to exit'
  exit 1
}

New-Item -ItemType Directory -Path $modDir -Force | Out-Null
New-Item -ItemType Directory -Path $chromeDir -Force | Out-Null

Write-Host 'Downloading latest theme files...' -ForegroundColor Cyan
Invoke-WebRequest -Uri ($repoRaw + 'chrome.css') -OutFile (Join-Path $modDir 'chrome.css') -UseBasicParsing
Invoke-WebRequest -Uri ($repoRaw + 'readme.md') -OutFile (Join-Path $modDir 'readme.md') -UseBasicParsing
Invoke-WebRequest -Uri ($repoRaw + 'userContent.css') -OutFile $userContent -UseBasicParsing

if (Test-Path -LiteralPath $themesFile) {
  Copy-Item -LiteralPath $themesFile -Destination ($themesFile + '.backup-' + $stamp) -Force
  try {
    $themes = (Get-Content -LiteralPath $themesFile -Raw) | ConvertFrom-Json
  } catch {
    Write-Host 'ERROR: zen-themes.json is invalid JSON. Backup created; registration unchanged.' -ForegroundColor Red
    Read-Host 'Press Enter to exit'
    exit 1
  }
} else {
  $themes = [pscustomobject]@{}
}

$mod = [pscustomobject]@{
  id = $modId
  name = 'NOTHING ZEN DOT'
  description = 'Nothing-inspired monochrome Zen UI with dot-matrix micrographics, technical geometry and sparse red accents.'
  author = 'kalaNaag'
  version = '1.2.0'
  homepage = 'https://github.com/kalaNaag/nothing-zen-dot'
  style = 'local'
  readme = 'local'
  tags = @('minimal','nothing','dot-matrix','monochrome','dark')
  enabled = $true
}

$prop = $themes.PSObject.Properties[$modId]
if ($null -eq $prop) {
  $themes | Add-Member -NotePropertyName $modId -NotePropertyValue $mod -Force
} else {
  $prop.Value = $mod
}

$json = $themes | ConvertTo-Json -Depth 20
[System.IO.File]::WriteAllText($themesFile, $json, (New-Object System.Text.UTF8Encoding($false)))

$prefLine = 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);'
if (Test-Path -LiteralPath $userJs) {
  Copy-Item -LiteralPath $userJs -Destination ($userJs + '.backup-' + $stamp) -Force
  $existing = Get-Content -LiteralPath $userJs -Raw
  if ($existing -notmatch 'toolkit\.legacyUserProfileCustomizations\.stylesheets') {
    Add-Content -LiteralPath $userJs -Value ([Environment]::NewLine + $prefLine)
  }
} else {
  [System.IO.File]::WriteAllText($userJs, $prefLine + [Environment]::NewLine, (New-Object System.Text.UTF8Encoding($false)))
}

Write-Host ''
Write-Host 'NOTHING ZEN DOT v1.2.0 installed.' -ForegroundColor Green
Write-Host 'Start Zen and check Settings -> Zen Mods.' -ForegroundColor White
Write-Host ''
Read-Host 'Press Enter to close'
