# GenQuery Terminal - Windows launch script
# Bundled inside the GenQuery Terminal MSIX package.
# Called by Windows Terminal profile; finds nu.exe and genq relative to this script.

$genqDir = Split-Path -Parent $PSScriptRoot  # = [package]\genq
$nuExe   = Join-Path $genqDir "nu.exe"
$envNu   = Join-Path $PSScriptRoot "env.nu"
$mainNu  = Join-Path $genqDir "src\main.nu"

if (-not (Test-Path $nuExe)) {
    Write-Host "GenQuery Terminal: nu.exe not found at $nuExe" -ForegroundColor Red
    Write-Host "The package may be corrupted. Try reinstalling GenQuery Terminal." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

if (-not (Test-Path $mainNu)) {
    Write-Host "GenQuery Terminal: main.nu not found at $mainNu" -ForegroundColor Red
    Write-Host "The package may be corrupted. Try reinstalling GenQuery Terminal." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Launch the bundled Nushell with GenQuery loaded.
# The --env-config sets NU_LIB_DIRS and GENQ_HOME without touching the user's
# system Nushell config (~/.config/nushell/env.nu).
& $nuExe --env-config $envNu $mainNu
