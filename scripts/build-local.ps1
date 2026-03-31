#Requires -Version 7
# GenQuery Terminal — Local Build Script
# Run from pwsh.exe in the repo root: .\scripts\build-local.ps1
# Optional parameters:
#   -Platform    x64 (default) or ARM64
#   -Config      Release (default) or Debug
#   -NoSync      Skip git pull + submodule update
#   -NoRestore   Skip dotnet restore
#   -Deploy      Copy output to C:\WT-Dev and re-register the dev package

param(
    [ValidateSet("x64", "ARM64")]
    [string]$Platform = "x64",

    [ValidateSet("Release", "Debug")]
    [string]$Config = "Release",

    [switch]$NoSync,
    [switch]$NoRestore,
    [switch]$Deploy
)

$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot | Split-Path -Parent
# If $root is a UNC path, map it to the corresponding drive letter
if ($root -match '^[/\\]{2}') {
    $drive = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.DisplayRoot -and ($root -replace '/', '\') -like "$($_.DisplayRoot)*" } | Select-Object -First 1
    if ($drive) { $root = $drive.Root }
}

Set-Location $root
Write-Host "`n=== GenQuery Terminal Local Build ===" -ForegroundColor Cyan
Write-Host "Platform: $Platform  Config: $Config`n"

# ── 1. Sync ──────────────────────────────────────────────────────────────────
if (-not $NoSync) {
    Write-Host "[ 1/4 ] Syncing repo..." -ForegroundColor Yellow
    git pull origin genq
    git submodule update --init --recursive
} else {
    Write-Host "[ 1/4 ] Sync skipped (-NoSync)" -ForegroundColor DarkGray
}

# ── 2. Restore SDK-style projects ────────────────────────────────────────────
if (-not $NoRestore) {
    Write-Host "`n[ 2/4 ] Restoring SDK-style projects..." -ForegroundColor Yellow
    dotnet restore src\tools\GraphemeTableGen\GraphemeTableGen.csproj
    dotnet restore src\tools\GraphemeTestTableGen\GraphemeTestTableGen.csproj
    dotnet restore src\cascadia\WpfTerminalControl\WpfTerminalControl.csproj
    dotnet restore src\cascadia\WpfTerminalTestNetCore\WpfTerminalTestNetCore.csproj
} else {
    Write-Host "[ 2/4 ] Restore skipped (-NoRestore)" -ForegroundColor DarkGray
}

# ── 3. Set up MSBuild environment ─────────────────────────────────────────────
Write-Host "`n[ 3/4 ] Setting up MSBuild environment..." -ForegroundColor Yellow
Import-Module .\tools\OpenConsole.psm1
Set-MsBuildDevEnvironment

# ── 4. Build ──────────────────────────────────────────────────────────────────
Write-Host "`n[ 4/4 ] Building ($Platform $Config)..." -ForegroundColor Yellow
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

Invoke-OpenConsoleBuild `
    /p:Platform=$Platform `
    /p:Configuration=$Config `
    /p:WindowsTargetPlatformVersion=10.0.22621.0

$stopwatch.Stop()
$elapsed = $stopwatch.Elapsed.ToString("mm\:ss")

Write-Host "`n=== Build complete in $elapsed ===" -ForegroundColor Green
Write-Host "Output: bin\$Platform\$Config\`n" -ForegroundColor Green

# ── 5. Deploy ─────────────────────────────────────────────────────────────────
if ($Deploy) {
    $deployPath = "C:\WT-Dev"
    Write-Host "[ 5/5 ] Deploying to $deployPath..." -ForegroundColor Yellow

    # Copy package output
    Copy-Item -Recurse -Force "src\cascadia\CascadiaPackage\bin\$Platform\$Config\*" $deployPath

    # Copy fonts (to package root, as declared in CascadiaResources.build.items)
    Copy-Item -Force "res\fonts\*.ttf" "$deployPath\"

    # Copy images
    New-Item -ItemType Directory -Path "$deployPath\Images" -Force | Out-Null
    Copy-Item -Recurse -Force "res\terminal\images-Dev\*" "$deployPath\Images\"

    # Copy profile icons
    New-Item -ItemType Directory -Path "$deployPath\ProfileIcons" -Force | Out-Null
    Copy-Item -Force "src\cascadia\CascadiaPackage\ProfileIcons\*" "$deployPath\ProfileIcons\"

    # Re-register package
    Add-AppxPackage -Register "$deployPath\AppxManifest.xml" -ForceApplicationShutdown
    Write-Host "Deployed and registered. Launch with:" -ForegroundColor Green
    Write-Host "  Start-Process 'shell:AppsFolder\WindowsTerminalDev_8wekyb3d8bbwe!App'`n" -ForegroundColor Green
}
