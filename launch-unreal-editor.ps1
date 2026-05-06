<#
.SYNOPSIS
    Launches the Unreal Engine Editor from the command line.

.DESCRIPTION
    Detects installed Unreal Engine versions in the standard Epic Games
    install locations and launches UnrealEditor.exe. You can pick a
    specific version with -Version, override the executable path with
    -EditorPath, and optionally open a .uproject file.

.PARAMETER Version
    Specific Unreal Engine version to launch (e.g. "5.4"). If omitted,
    the highest installed version is used.

.PARAMETER EditorPath
    Full path to UnrealEditor.exe. Overrides version-based detection
    and the UE_PATH environment variable.

.PARAMETER Project
    Optional path to a .uproject file to open.

.EXAMPLE
    .\launch-unreal-editor.ps1
    Launches the newest installed Unreal Editor.

.EXAMPLE
    .\launch-unreal-editor.ps1 -Version 5.3
    Launches Unreal Engine 5.3.

.EXAMPLE
    .\launch-unreal-editor.ps1 -Project "C:\Projects\MyGame\MyGame.uproject"
    Opens the specified project in the newest installed editor.
#>

[CmdletBinding()]
param(
    [string]$Version,
    [string]$EditorPath,
    [string]$Project
)

$ErrorActionPreference = 'Stop'

function Find-Installations {
    $roots = @(
        'C:\Program Files\Epic Games',
        'D:\Program Files\Epic Games',
        'C:\Epic Games',
        'D:\Epic Games'
    )

    $found = @()
    foreach ($root in $roots) {
        if (-not (Test-Path -LiteralPath $root)) { continue }
        Get-ChildItem -LiteralPath $root -Directory -Filter 'UE_*' -ErrorAction SilentlyContinue | ForEach-Object {
            $exe = Join-Path $_.FullName 'Engine\Binaries\Win64\UnrealEditor.exe'
            if (Test-Path -LiteralPath $exe) {
                $verString = $_.Name -replace '^UE_', ''
                $parsed = $null
                if ([version]::TryParse($verString, [ref]$parsed)) {
                    $found += [pscustomobject]@{
                        Version = $parsed
                        Raw     = $verString
                        Exe     = $exe
                    }
                }
            }
        }
    }
    return $found
}

# 1. Explicit -EditorPath wins.
if ($EditorPath) {
    if (-not (Test-Path -LiteralPath $EditorPath)) {
        Write-Error "EditorPath does not exist: $EditorPath"
        exit 1
    }
    $exe = $EditorPath
}
# 2. UE_PATH environment variable.
elseif ($env:UE_PATH) {
    if (-not (Test-Path -LiteralPath $env:UE_PATH)) {
        Write-Error "UE_PATH is set but the file does not exist: $($env:UE_PATH)"
        exit 1
    }
    $exe = $env:UE_PATH
}
# 3. Auto-detect.
else {
    $installs = Find-Installations
    if ($installs.Count -eq 0) {
        Write-Error "No Unreal Engine installation found. Set UE_PATH or pass -EditorPath."
        exit 1
    }

    if ($Version) {
        $match = $installs | Where-Object { $_.Raw -eq $Version -or $_.Version -eq [version]$Version } | Select-Object -First 1
        if (-not $match) {
            $available = ($installs | Sort-Object Version -Descending | ForEach-Object { $_.Raw }) -join ', '
            Write-Error "Unreal Engine $Version is not installed. Found: $available"
            exit 1
        }
        $exe = $match.Exe
        Write-Host "[INFO] Using Unreal Engine $($match.Raw)"
    }
    else {
        $newest = $installs | Sort-Object Version -Descending | Select-Object -First 1
        $exe = $newest.Exe
        Write-Host "[INFO] Using Unreal Engine $($newest.Raw) (newest installed)"
    }
}

Write-Host "[INFO] Launching: $exe"

$args = @()
if ($Project) {
    if (-not (Test-Path -LiteralPath $Project)) {
        Write-Error "Project file not found: $Project"
        exit 1
    }
    $args += $Project
}

Start-Process -FilePath $exe -ArgumentList $args
