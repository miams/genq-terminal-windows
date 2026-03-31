# GenQuery Terminal - Nushell environment for the bundled package.
# Loaded via --env-config when nu.exe is invoked from genquery-start.ps1.
#
# Sets NU_LIB_DIRS and GENQ_HOME to package-relative paths so genq can find
# its libraries and config regardless of where the package is installed.
# Does NOT touch the user's system Nushell config.

# $nu.current-exe is the bundled nu.exe at [package]\genq\nu.exe
# Dirname gives [package]\genq — the genq root inside the package.
let pkg_genq = $nu.current-exe | path dirname

$env.NU_LIB_DIRS = [
    ($pkg_genq | path join "src" "lib")
    ($pkg_genq | path join "src" "lib" "ext")
]

# GENQ_HOME tells genq config where to find config/default.toml
$env.GENQ_HOME = $pkg_genq
