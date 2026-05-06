<#
.SYNOPSIS
    One-line installer for the Unreal Editor Launcher.

.DESCRIPTION
    Downloads launch-unreal-editor.bat and launch-unreal-editor.ps1 from
    GitHub into %USERPROFILE%\unreal-editor-launcher and (optionally) adds
    that folder to the user PATH so you can call `launch-unreal-editor`
    from any terminal.

.EXAMPLE
    irm https://raw.githubusercontent.com/jdot274/unreal-editor-launcher/main/install.ps1 | iex

.EXAMPLE
    # Install without modifying PATH
    & ([scriptblock]::Create((irm https://raw.githubusercontent.com/jdot274/unreal-editor-launcher/main/install.ps1))) -SkipPath
#>

[CmdletBinding()]
param(
    [string]$InstallDir = (Join-Path $env:USERPROFILE 'unreal-editor-launcher'),
    [string]$Branch = 'main',
    [switch]$SkipPath
)

$ErrorActionPreference = 'Stop'

$repoBase = "https://raw.githubusercontent.com/jdot274/unreal-editor-launcher/$Branch"
$files = @(
    'launch-unreal-editor.bat',
    'launch-unreal-editor.ps1',
    'README.md'
)

Write-Host "[INFO] Installing Unreal Editor Launcher to $InstallDir"
New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null

foreach ($f in $files) {
    $url  = "$repoBase/$f"
    $dest = Join-Path $InstallDir $f
    Write-Host "[INFO] Downloading $f"
    Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing
}

if (-not $SkipPath) {
    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    $entries = @()
    if ($userPath) { $entries = $userPath -split ';' | Where-Object { $_ } }

    if ($entries -notcontains $InstallDir) {
        Write-Host "[INFO] Adding $InstallDir to user PATH"
        $newPath = (($entries + $InstallDir) -join ';')
        [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
        Write-Host "[INFO] Open a new terminal for the PATH change to take effect."
    } else {
        Write-Host "[INFO] $InstallDir is already on PATH"
    }
}

Write-Host ""
Write-Host "[DONE] Installed to: $InstallDir"
Write-Host ""
Write-Host "Usage (in a new terminal):"
Write-Host "  launch-unreal-editor.bat"
Write-Host "  launch-unreal-editor.bat `"C:\Path\To\MyGame.uproject`""
Write-Host "  powershell -File `"$InstallDir\launch-unreal-editor.ps1`" -Version 5.3"
Write-Host ""
Write-Host "If Unreal is in a non-standard location, set UE_PATH once:"
Write-Host "  setx UE_PATH `"C:\Path\To\UE_5.4\Engine\Binaries\Win64\UnrealEditor.exe`""
