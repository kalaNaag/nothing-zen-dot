# NOTHING ZEN DOT - local Zen mod installer
# Windows PowerShell 5.1 compatible. Keep Zen closed while running.

$ErrorActionPreference = 'Stop'

$profilePath = 'C:\Users\s.patil\AppData\Roaming\zen\Profiles\b9fgs9y3.Default (release)'
$modId = 'nothing-zen-dot'
$repoRaw = 'https://raw.githubusercontent.com/kalaNaag/nothing-zen-dot/main/'
$modDir = Join-Path $profilePath ('chrome\zen-themes\' + $modId)
$themesFile = Join-Path $profilePath 'zen-themes.json'
$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'

Write-Host ''
Write-Host 'NOTHING ZEN DOT - Installer' -ForegroundColor White
Write-Host '--------------------------------' -ForegroundColor DarkGray

if (-not (Test-Path -LiteralPath $profilePath)) {
    Write-Host 'ERROR: The Zen profile folder was not found:' -ForegroundColor Red
    Write-Host $profilePath -ForegroundColor Yellow
    Write-Host ''
    Write-Host 'Edit the profilePath at the top of this script if your Zen profile changed.'
    Read-Host 'Press Enter to exit'
    exit 1
}

$zenProcesses = Get-Process -Name 'zen' -ErrorAction SilentlyContinue
if ($zenProcesses) {
    Write-Host 'ERROR: Zen Browser is currently running.' -ForegroundColor Red
    Write-Host 'Close every Zen window, then run this installer again.' -ForegroundColor Yellow
    Read-Host 'Press Enter to exit'
    exit 1
}

New-Item -ItemType Directory -Path $modDir -Force | Out-Null

Write-Host 'Downloading theme files...' -ForegroundColor Cyan
Invoke-WebRequest -Uri ($repoRaw + 'chrome.css') -OutFile (Join-Path $modDir 'chrome.css') -UseBasicParsing
Invoke-WebRequest -Uri ($repoRaw + 'readme.md') -OutFile (Join-Path $modDir 'readme.md') -UseBasicParsing

if (Test-Path -LiteralPath $themesFile) {
    Copy-Item -LiteralPath $themesFile -Destination ($themesFile + '.backup-' + $timestamp) -Force
    Write-Host ('Backup created: zen-themes.json.backup-' + $timestamp) -ForegroundColor DarkGray
    $rawJson = Get-Content -LiteralPath $themesFile -Raw
    if ([string]::IsNullOrWhiteSpace($rawJson)) {
        $themes = [ordered]@{}
    } else {
        try {
            $themes = $rawJson | ConvertFrom-Json
        } catch {
            Write-Host 'ERROR: zen-themes.json contains invalid JSON. No changes were made.' -ForegroundColor Red
            Write-Host $_.Exception.Message -ForegroundColor Yellow
            Read-Host 'Press Enter to exit'
            exit 1
        }
    }
} else {
    $themes = [ordered]@{}
    Write-Host 'zen-themes.json did not exist. Creating it.' -ForegroundColor Yellow
}

$mod = [ordered]@{
    id = $modId
    name = 'NOTHING ZEN DOT'
    description = 'Nothing-inspired dot-matrix black and white Zen Browser UI with sparse red accents and technical geometry.'
    author = 'kalaNaag'
    version = '1.0.0'
    homepage = 'https://github.com/kalaNaag/nothing-zen-dot'
    style = 'local'
    readme = 'local'
    tags = @('minimal','nothing','dot-matrix','dark')
    enabled = $true
}

if ($themes -is [hashtable]) {
    $themes[$modId] = [pscustomobject]$mod
} else {
    $null = $themes.PSObject.Properties.Remove($modId)
    $themes | Add-Member -NotePropertyName $modId -NotePropertyValue ([pscustomobject]$mod) -Force
}

$jsonOut = $themes | ConvertTo-Json -Depth 20
[System.IO.File]::WriteAllText($themesFile, $jsonOut, (New-Object System.Text.UTF8Encoding($false)))

Write-Host ''
Write-Host 'Installation completed.' -ForegroundColor Green
Write-Host ''
Write-Host 'Installed mod:' -NoNewline
Write-Host ' NOTHING ZEN DOT' -ForegroundColor Cyan
Write-Host ('Location: ' + $modDir)
Write-Host ''
Write-Host 'Next:' -ForegroundColor White
Write-Host '1. Start Zen Browser.'
Write-Host '2. Open Settings -> Zen Mods.'
Write-Host '3. NOTHING ZEN DOT should now be listed and enabled.'
Write-Host '4. If the list is unchanged, restart Zen one more time.'
Write-Host ''
Read-Host 'Press Enter to close'