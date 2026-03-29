# CI Build Lessons Learned — genq-terminal-windows

_Platform: GitHub Actions `windows-2022` runner (x64). Date: 2026-03-29._
_9 failed builds, ~4.5 hours of compute time before a working configuration was reached._

---

## The Working Configuration

**Runner:** `windows-2022` (pinned — do not change to `windows-latest`)

**Workflow:** `.github/workflows/build.yml`

```yaml
- name: Restore SDK-style projects
  run: |
    $ErrorActionPreference = 'Stop'
    dotnet restore src\cascadia\WpfTerminalControl\WpfTerminalControl.csproj -r win-x64 /p:SelfContained=false
    dotnet restore src\cascadia\WpfTerminalTestNetCore\WpfTerminalTestNetCore.csproj -r win-x64 /p:SelfContained=false
    dotnet restore src\tools\TerminalStress\TerminalStress.csproj -r win-x64 /p:SelfContained=false
    dotnet restore src\tools\GraphemeTableGen\GraphemeTableGen.csproj
    dotnet restore src\tools\GraphemeTestTableGen\GraphemeTestTableGen.csproj

- name: Build
  run: |
    Import-Module .\tools\OpenConsole.psm1
    Set-MsBuildDevEnvironment
    Invoke-OpenConsoleBuild `
      /p:Platform=x64 `
      /p:Configuration=Release `
      /p:WindowsTargetPlatformVersion=10.0.22621.0 `
      /p:TargetPlatformVersion=10.0.22621.0 `
      /p:RuntimeIdentifier=win-x64 `
      /p:SelfContained=false
```

---

## Failure Chain — Complete History

### Failure 1 — MSB8036: Windows SDK 10.0.22621.0 not found (runner: windows-latest)

**Error:**
```
error MSB8036: The Windows SDK version 10.0.22621.0 was not found.
```

**Cause:** `windows-latest` silently upgraded to `windows-2025` (Windows Server 2025, build 10.0.26100).
That runner ships with a newer Windows SDK but not 10.0.22621.0. Passing
`/p:WindowsTargetPlatformVersion=10.0.22621.0` tells MSBuild *which* SDK to use but the SDK must
physically exist on disk.

**Failed fix attempt:** `vs_installer.exe modify --quiet` to install SDK 22621. This is **asynchronous** —
it spawns a background process and returns immediately. The build starts before the install finishes.
The `exit 0` after the call masked the timing failure completely.

**Correct fix:** Pin to `windows-2022`, which ships with SDK 10.0.22621.0 pre-installed.
Do NOT use `windows-latest` for this build.

```yaml
runs-on: windows-2022
# windows-2022 is pinned intentionally: ships with Windows SDK 10.0.22621.0.
# windows-latest → windows-2025 has a newer SDK but not 22621.
# vs_installer.exe modify --quiet is async and cannot be used reliably before build starts.
```

---

### Failure 2 — NETSDK1004: project.assets.json not found (missing SDK-style project restores)

**Error:**
```
error NETSDK1004: Assets file '...\TerminalStress\obj\project.assets.json' not found.
```

**Cause:** Only 2 of the 5 SDK-style `.csproj` files in the repo were being restored.
`nuget.exe restore` (called by `Invoke-OpenConsoleBuild`) handles `packages.config`-style projects
but does NOT restore SDK-style `.csproj` files. Three projects had no `project.assets.json`.

**SDK-style projects requiring explicit `dotnet restore`:**

| Project | TFM |
|---|---|
| `src/cascadia/WpfTerminalControl` | `net472`, `net8.0-windows` |
| `src/cascadia/WpfTerminalTestNetCore` | `net8.0-windows` |
| `src/tools/TerminalStress` | `net8.0-windows` |
| `src/tools/GraphemeTableGen` | `net8.0` |
| `src/tools/GraphemeTestTableGen` | `net8.0` |

Note: `src/tools/ColorTool` uses `net461` with `packages.config` — handled by `nuget.exe`, not `dotnet restore`.

**Fix:** Add explicit `dotnet restore` for all 5 projects before the MSBuild invocation.

---

### Failures 3–7 — NETSDK1112 / NU1102 / NETSDK1004 cascade (net8.0-windows restore RID issues)

This was the longest debugging sequence. The error, cause, and failed attempts:

**Error:**
```
error NETSDK1112: The runtime pack for Microsoft.Windows.SDK.NET.Ref was not downloaded.
  Try running a NuGet restore with the RuntimeIdentifier 'any'.
```

**Root cause:** The active .NET SDK on the runner is 10.0.105 (latest installed wins). When SDK 10
builds `net8.0-windows` projects, it needs `Microsoft.Windows.SDK.NET.Ref` — the Windows API
reference assembly pack. This pack must be present in the restore's `project.assets.json`.
Without a RuntimeIdentifier during restore, the SDK does not include Windows-specific framework
reference packs in the assets file.

**Failed fix attempts and why they failed:**

| Attempt | Result | Why |
|---|---|---|
| No `-r` flag | NETSDK1112 at build | Windows ref packs not included in assets file |
| `-r any` | NETSDK1112 at build | `any` pseudo-RID also doesn't resolve platform packs |
| `setup-dotnet` (8.x + 9.x) | NETSDK1112 at build | `dotnet-install.ps1` installs SDK binaries only, not framework packs. SDK 10 still active |
| Remove `setup-dotnet`, use runner's .NET | NETSDK1112 at build | SDK 10 still active; .NET 8 pack resolution unchanged |
| `-r win-x64` | NU1102 | In .NET 6+, `-r` alone defaults to **self-contained** mode. Tries to download `Microsoft.NETCore.App.Runtime.win-x64 8.0.25` which is absent from the TerminalDependencies NuGet feed (only has 6.0.9) |
| `-r win-x64 --no-self-contained` | MSB1001 → NETSDK1004 | `--no-self-contained` is a dotnet CLI flag that gets forwarded as-is to `MSBuild.dll` which rejects it as an unknown switch. Restore silently failed (no `$ErrorActionPreference = 'Stop'`), leaving no assets file |
| `-r win-x64 /p:SelfContained=false` | ✅ Works | Correct combination — see below |

**Correct fix:**
```powershell
$ErrorActionPreference = 'Stop'
dotnet restore <project> -r win-x64 /p:SelfContained=false
```

- `-r win-x64`: sets RuntimeIdentifier so SDK resolves `Microsoft.Windows.SDK.NET.Ref` correctly
- `/p:SelfContained=false`: suppresses self-contained mode — no runtime pack download, no NU1102
- **Never use `--no-self-contained`** — it's an MSBuild.dll invalid switch, not a `dotnet restore` flag

**MSBuild must match restore:** The restore bakes `win-x64` into the assets file fingerprint. If MSBuild
builds without the same RID, it sees a fingerprint mismatch and reports NETSDK1004 ("not found" even
though the file exists). Pass the same properties to the build step:

```
/p:RuntimeIdentifier=win-x64 /p:SelfContained=false
```

C++ projects ignore these properties — they only affect the SDK-style C# projects.

---

## Key Rules Derived From This Experience

### 1. Always set `$ErrorActionPreference = 'Stop'` in every pwsh step

Without it, failed commands are silently swallowed. `dotnet restore` failing silently caused 2 runs
(failures 7 and 8) where the real error was a restore failure but we spent 30 minutes each time
waiting for a build-phase NETSDK1004 to surface.

```powershell
# First line of every run: block
$ErrorActionPreference = 'Stop'
```

### 2. `vs_installer.exe modify --quiet` is asynchronous

It spawns a background process and returns exit code 0 immediately. Any `exit 0` after it masks the
race condition. Cannot be used in CI to install components before a build. Use runner pinning or
`winget install` (which IS synchronous) instead.

### 3. `dotnet-install.ps1` does not install framework packs

`actions/setup-dotnet` uses `dotnet-install.ps1` internally. This script installs the SDK runtime
and CLI only — it does not install "framework packs" (like `Microsoft.Windows.SDK.NET.Ref`) or
"workloads". These require the full Windows SDK installer. The `windows-2022` runner has .NET 8
pre-installed via the full installer, which is why it has the packs available.

**Do not use `setup-dotnet` for .NET 8/9** on this project — it replaces the full-installer SDK
with an incomplete one, then SDK 10 (still highest version) picks up but can't find the packs.

### 4. Restore and build must use the same RuntimeIdentifier

When `dotnet restore` runs with `-r win-x64`, it creates `project.assets.json` with a fingerprint
that includes the RID. If MSBuild builds with a different (or no) RID, it recalculates the expected
fingerprint, sees a mismatch, and reports NETSDK1004. Always pass `/p:RuntimeIdentifier=win-x64`
to the MSBuild invocation when restore used `-r win-x64`.

### 5. Never use `--no-self-contained` with `dotnet restore`

In .NET SDK 10, `dotnet restore` forwards unrecognised CLI flags directly to `MSBuild.dll`. The flag
`--no-self-contained` is not a valid MSBuild switch — MSBuild.dll rejects it with `MSB1001: Unknown switch`.
Use `/p:SelfContained=false` as an MSBuild property instead.

### 6. `windows-latest` runner must not be used for this build

As of early 2026, `windows-latest` = `windows-2025` which lacks Windows SDK 10.0.22621.0.
The SDK version is hardcoded in multiple project files. Upgrading to a newer SDK requires verifying
the entire codebase builds cleanly against it.

### 7. The WPF projects are not needed for the GenQuery artifact

`WpfTerminalControl`, `WpfTerminalTestNetCore`, and `TerminalStress` are a WPF embedding wrapper and
its tests — not part of `WindowsTerminal.exe` or `wt.exe`. They failed in CI for many iterations.
In theory they could be excluded from the build, but the restore/build property fix resolved them
without needing exclusion.

---

## Throughput Improvements for Future CI Iteration

### Add a fast diagnostic job (highest ROI)

A <2 minute job that runs before the build and dumps environment state. Would have caught most of
the above issues on the first run:

```yaml
jobs:
  diagnose:
    runs-on: windows-2022
    steps:
      - name: .NET environment
        shell: pwsh
        run: |
          dotnet --info
          dotnet --list-sdks
          Get-ChildItem 'C:\Program Files\dotnet\packs' | Select-Object Name
          Get-ChildItem 'C:\Program Files\dotnet\sdk'   | Select-Object Name
```

### Use the local Windows VM to test CI scripts before pushing

The Windows 11 ARM64 VM (Parallels) already has a working build. Any CI script change should be
tested there in a fresh PowerShell session before pushing. Especially for restore commands — a 10-second
local test would have caught failures 7 and 8 (the `--no-self-contained` mistake).

### Add `--verbosity detailed` during debugging

When iterating on restore issues, add `--verbosity detailed` to `dotnet restore` to see exactly which
packages and framework packs are being resolved. Remove it once the issue is fixed.

### Cache NuGet packages

Adds 2–3 min savings per run and reduces network flakiness:

```yaml
- uses: actions/cache@v4
  with:
    path: ~\AppData\Local\NuGet\v3-cache
    key: nuget-${{ hashFiles('**/packages.config', '**/*.csproj') }}
    restore-keys: nuget-
```

### Compound fixes — look at all errors before pushing

Each fix addressed exactly one error. When diagnosing a failure, scan the full log for ALL error
codes before pushing. Fixing one error only to reveal the next one wastes a 30-minute run each time.

---

## Build Time Reference (windows-2022)

| Phase | Time |
|---|---|
| Submodule checkout | ~3 min |
| NuGet restore (packages.config + SDK-style) | ~1 min |
| Full x64 Release build | ~27 min |
| **Total** | **~31 min** |

windows-2022 has 2 cores / 7 GB RAM. The build is heavily parallelised by MSBuild but still bottlenecked
by the 2-core limit. `windows-latest` (windows-2025) has 4 cores / 16 GB but requires resolving the
SDK 22621 installation issue before it can be used.
