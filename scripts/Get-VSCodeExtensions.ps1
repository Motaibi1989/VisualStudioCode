$extensionRoots = @(
    @{
        Name = "VS Code"
        Path = "$env:USERPROFILE\.vscode\extensions"
    },
    @{
        Name = "VS Code Insiders"
        Path = "$env:USERPROFILE\.vscode-insiders\extensions"
    }
)

$results = foreach ($root in $extensionRoots) {
    if (-not (Test-Path $root.Path)) {
        continue
    }

    Get-ChildItem -Path $root.Path -Directory | ForEach-Object {
        $extensionPath = $_.FullName
        $packageFile = Join-Path $extensionPath "package.json"

        if (-not (Test-Path $packageFile)) {
            return
        }

        try {
            $package = Get-Content $packageFile -Raw | ConvertFrom-Json

            [PSCustomObject]@{
                Name        = $package.displayName
                ID          = "$($package.publisher).$($package.name)"
                Version     = $package.version
                Publisher   = $package.publisher
                Description = $package.description
                VSCode      = $package.engines.vscode
                Main        = $package.main
                Commands    = @($package.contributes.commands).Count
                Path        = $extensionPath
                Product     = $root.Name
            }
        }
        catch {
            Write-Warning "Unable to read: $packageFile"
        }
    }
}

$results |
    Sort-Object ID |
    Format-Table Name, ID, Version, Publisher, Commands, Product, Path -AutoSize
