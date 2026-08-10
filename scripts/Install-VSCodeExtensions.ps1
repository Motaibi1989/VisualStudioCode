param(
    [string]$Config = (Join-Path $PSScriptRoot "..\extensions.json"),
    [switch]$Pinned,
    [switch]$Force
)

$ErrorActionPreference = "Stop"

function Get-CodeCommand {
    $cmd = Get-Command code -ErrorAction SilentlyContinue
    if (-not $cmd) {
        throw "VS Code CLI 'code' was not found in PATH. Add VS Code to PATH, then try again."
    }
    return $cmd.Source
}

$code = Get-CodeCommand
$configPath = (Resolve-Path $Config).Path
$configData = Get-Content $configPath -Raw | ConvertFrom-Json

if (-not $configData.extensions) {
    throw "No extensions found in $configPath"
}

$installed = @{}
& $code --list-extensions --show-versions | ForEach-Object {
    if ($_ -match '^(.+?)@(.+)$') {
        $installed[$matches[1].ToLowerInvariant()] = $matches[2]
    }
}

$summary = [ordered]@{
    Total     = $configData.extensions.Count
    Installed = 0
    Skipped   = 0
    Failed    = 0
}

foreach ($extension in $configData.extensions) {
    $id = [string]$extension.id
    $version = [string]$extension.version
    $key = $id.ToLowerInvariant()

    if (-not $Force -and $installed.ContainsKey($key) -and -not $Pinned) {
        Write-Host "[SKIP] $id@$($installed[$key])" -ForegroundColor DarkGray
        $summary.Skipped++
        continue
    }

    $target = if ($Pinned -and $version) { "$id@$version" } else { $id }

    Write-Host "[INSTALL] $target" -ForegroundColor Cyan
    & $code --install-extension $target --force

    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] $target" -ForegroundColor Green
        $summary.Installed++
    }
    else {
        Write-Warning "Failed: $target"
        $summary.Failed++
    }
}

Write-Host ""
Write-Host "VS Code extension installation summary"
$summary.GetEnumerator() | ForEach-Object {
    Write-Host ("{0,-10}: {1}" -f $_.Key, $_.Value)
}

if ($summary.Failed -gt 0) {
    exit 1
}
