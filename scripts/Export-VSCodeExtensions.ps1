param(
    [string]$Output = (Join-Path $PSScriptRoot "..\extensions.json")
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command code -ErrorAction SilentlyContinue)) {
    throw "VS Code CLI 'code' was not found in PATH."
}

$items = @(
    code --list-extensions --show-versions |
    ForEach-Object {
        if ($_ -match '^(.+?)@(.+)$') {
            [PSCustomObject]@{
                id      = $matches[1]
                version = $matches[2]
            }
        }
    } |
    Sort-Object id
)

$result = [ordered]@{
    schemaVersion  = 1
    description    = "Portable VS Code extension set. Contains extension IDs and versions only; no workstation-specific paths or personal data."
    installDefault = "latest"
    extensions     = $items
}

$result |
    ConvertTo-Json -Depth 5 |
    Set-Content -Path $Output -Encoding UTF8

Write-Host "Exported $($items.Count) extensions to: $Output"
