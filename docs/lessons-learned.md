# Build Lessons Learned — genq-terminal-windows

_Platform: Windows 11 ARM64 (local dev). CI target: AMD64 (GitHub Actions `windows-latest`)._
_Date: 2026-03-22_

---

## Summary

First successful local build required resolving nine distinct issues not covered by the upstream
`doc/building.md`. Several have direct implications for CI on AMD64.

---

## Issue 1 — Build on network/shared drive causes git ownership errors

**Symptom:** `fatal: detected dubious ownership in repository` when running git commands.
**Cause:** Parallels shared folders (Z:) are on a filesystem that does not record ownership.
**Fix:** Clone the repo to a local `C:\` path. Never build from a network-mapped drive.
**CI relevance:** Not applicable — GitHub Actions runners check out to local disk. ✅

---

## Issue 2 — PowerShell 5.1 cannot load OpenConsole.psm1

**Symptom:** `Import-Module` fails with "script contained a #requires statement for Windows
PowerShell 7.0."
**Cause:** `tools/OpenConsole.psm1` has `#Requires -Version 7`. Windows ships PS 5.1 by default.
**Fix:** Install PowerShell 7 (`winget install Microsoft.PowerShell`) and invoke build scripts
with `pwsh.exe`, not `powershell.exe`.
**CI relevance:** GitHub `windows-latest` runners include PS7. Confirm CI yaml uses `pwsh` shell:

```yaml
defaults:
  run:
    shell: pwsh
```

---

## Issue 3 — TargetPlatformVersion empty, CppWinRT fails with MSB8036

**Symptom:**
```
error MSB8036: The Windows SDK version 10.0.17134.0 (or later) was not found.
```
from `Microsoft.Windows.CppWinRT.targets(126)` for all Cascadia projects.

**Cause:** `Microsoft.Cpp.WindowsSDK.props` uses
`ToolLocationHelper::GetLatestSDKTargetPlatformVersion('Windows','10.0')` to populate
`_LatestWindowsTargetPlatformVersion`. This call reads the 64-bit registry hive
(`HKLM\SOFTWARE\Microsoft\Microsoft SDKs\Windows\v10.0`). On a fresh ARM64 install this key
may only exist under `WOW6432Node`, leaving `_LatestWindowsTargetPlatformVersion` empty, which
causes `TargetPlatformVersion` to be unset, which causes the CppWinRT check to fail.

**Fix:** Pass both properties explicitly on the MSBuild command line:
```
/p:WindowsTargetPlatformVersion=10.0.22621.0 /p:TargetPlatformVersion=10.0.22621.0
```

**CI relevance:** GitHub `windows-latest` runners are pre-configured and this registry key is
typically present. However, custom or self-hosted AMD64 runners on a fresh Windows install
will hit this. Recommend always passing these properties explicitly in the CI MSBuild invocation
to make the build registry-independent.

---

## Issue 4 — NativeDesktop workload alone is insufficient

**Symptom:** Various MSBuild errors about missing UWP/Store build tools and .NET components.
**Cause:** Windows Terminal's Cascadia projects use `ApplicationType=Windows Store` (set in
`src/cppwinrt.build.pre.props`) which requires UWP C++ build tools — not included in the
standard Desktop C++ workload.

**Required VS 2022 components:**

| Component | Why needed |
|---|---|
| `Microsoft.VisualStudio.Workload.NativeDesktop` | Core C++ compiler and linker |
| `Microsoft.VisualStudio.Component.Windows11SDK.22621` | Windows SDK |
| `Microsoft.VisualStudio.Workload.Universal` | UWP platform support |
| `Microsoft.VisualStudio.ComponentGroup.UWP.VC` | C++ UWP build tools (not in Universal's recommended set — must be explicit) |
| `Microsoft.Net.Component.4.7.2.TargetingPack` | Required by UIA test projects |
| .NET SDK (`winget install Microsoft.DotNet.SDK.9`) | Required by WpfTerminalControl and SDK-style csproj |

**Full install command:**
```
vs_community.exe --add Microsoft.VisualStudio.Workload.NativeDesktop ^
  --add Microsoft.VisualStudio.Component.Windows11SDK.22621 ^
  --add Microsoft.VisualStudio.Workload.Universal ^
  --add Microsoft.VisualStudio.ComponentGroup.UWP.VC ^
  --add Microsoft.Net.Component.4.7.2.TargetingPack ^
  --includeRecommended --quiet --wait --norestart
```

**CI relevance:** `windows-latest` runners include most of these, but
`Microsoft.VisualStudio.ComponentGroup.UWP.VC` is sometimes absent. If CI fails with
`MSB8020: build tools for 'v143' application Type UWP cannot be found`, add this component
to the runner setup step.

---

## Issue 5 — vswhere.exe not in PATH

**Symptom:** `'vswhere.exe' is not recognized` warning printed during build setup.
**Cause:** `C:\Program Files (x86)\Microsoft Visual Studio\Installer\` is not in PATH by
default in non-VS shell sessions.
**Fix:** `Set-MsBuildDevEnvironment` in `OpenConsole.psm1` uses the VSSetup PS module (not
vswhere directly) so this is a warning, not a blocker. However, any script that calls
`vswhere.exe` directly will fail silently. Add to PATH if needed:
```powershell
$env:PATH += ';C:\Program Files (x86)\Microsoft Visual Studio\Installer'
```
**CI relevance:** GitHub-hosted runners have vswhere in PATH. ✅

---

## Issue 6 — .NET SDK not on PATH after installation in same session

**Symptom:** `WpfTerminalControl.csproj: Unable to locate the .NET SDK. Check PATH is configured for the correct architecture.`
**Cause:** `Enter-VsDevShell` does not set `DOTNET_ROOT` or add `C:\Program Files\dotnet\`
to PATH. If .NET SDK was installed in the same terminal session, it won't be visible until
a new session or explicit PATH update.
**Fix:** Set in the build script before invoking MSBuild:
```powershell
$env:DOTNET_ROOT = 'C:\Program Files\dotnet'
$env:PATH = "C:\Program Files\dotnet;$env:PATH"
```
**CI relevance:** GitHub runners have dotnet pre-installed and in PATH. ✅ Self-hosted runners
may need explicit `DOTNET_ROOT` if .NET was recently installed.

---

## Issue 7 — Disk space: build artifacts are ~10GB

**Symptom:** VS installer fails with exit code `0x80070070` (ERROR_DISK_FULL) when trying to
add workloads after a partial build.
**Cause:** `obj/` and `bin/` directories from a full ARM64 Release build occupy ~10–11GB.
**Fix:** Clean artifacts before installing additional VS components:
```powershell
Remove-Item .\obj -Recurse -Force
Remove-Item .\bin -Recurse -Force
```
**CI relevance:** GitHub `windows-latest` runners have ~14GB free disk. After a full build
the runner may be close to capacity. Avoid building multiple configurations in the same job
without cleaning between them.

---

## Issue 8 — NuGet restore warning for .slnx format (non-blocking)

**Symptom:** `Invalid input 'OpenConsole.slnx'. The file type was not recognized.` from `nuget.exe` CLI.
**Cause:** `nuget.exe` (legacy CLI) does not support the new `.slnx` XML solution format.
`Invoke-OpenConsoleBuild` calls `nuget.exe restore OpenConsole.slnx` which fails silently,
then also calls `nuget.exe restore dep/nuget/packages.config` which succeeds.
**Effect:** Warning only — NuGet packages restore correctly via `packages.config`. Not a
build blocker.
**CI relevance:** Same warning will appear in CI logs. Safe to ignore.

---

## Issue 9 — SDK-style .csproj projects need dotnet restore before MSBuild

**Symptom:**
```
error NETSDK1004: Assets file '...\WpfTerminalControl\obj\project.assets.json' not found.
Run a NuGet package restore to generate this file.
```
for `WpfTerminalControl.csproj` (both `net472` and `net8.0-windows`) and
`WpfTerminalTestNetCore.csproj`.

**Cause:** `Invoke-OpenConsoleBuild` runs `nuget.exe restore` which handles `packages.config`
style projects but not SDK-style `.csproj` files. SDK-style projects generate their
`project.assets.json` via `dotnet restore`, not `nuget.exe`.

**Fix:** Run `dotnet restore` on the affected projects before the MSBuild invocation:
```powershell
dotnet restore src\cascadia\WpfTerminalControl\WpfTerminalControl.csproj
dotnet restore src\cascadia\WpfTerminalTestNetCore\WpfTerminalTestNetCore.csproj
```
These projects are a WPF embedding wrapper and its tests — not part of the main terminal
executable. The core build (`WindowsTerminal.exe`, `wt.exe`) succeeds without this fix.

**CI relevance:** Same fix needed in CI if the WPF projects are required in the CI artifact.

---

## Issue 10 — windows-latest now maps to windows-2025, which lacks Windows SDK 10.0.22621.0

**Symptom:**
```
error MSB8036: The Windows SDK version 10.0.22621.0 was not found.
```
for every project in the solution, even when `/p:WindowsTargetPlatformVersion=10.0.22621.0` is passed.

**Cause:** As of early 2026, `windows-latest` on GitHub Actions maps to `windows-2025` (Windows Server 2025,
build 10.0.26100). This runner ships with a newer Windows SDK (10.0.26100+) but not 10.0.22621.0. Passing
`/p:WindowsTargetPlatformVersion` tells MSBuild *which* SDK to target, but the SDK still needs to be physically
installed on the runner.

**What does NOT work:** `vs_installer.exe modify --quiet` returns immediately and spawns the actual install
as a background process. The build starts before the install finishes, so MSB8036 still fires.

**Fix:** Pin to `windows-2022` runner, which ships with Windows SDK 10.0.22621.0 pre-installed:

```yaml
runs-on: windows-2022
```

Add a comment in the workflow explaining the pin so future maintainers don't revert it to `windows-latest`.

**CI relevance:** Do not use `windows-latest` for this build. If upgrading the target SDK to match
`windows-latest` (e.g. 10.0.26100.0), verify the codebase builds cleanly against the newer SDK first,
then update `/p:WindowsTargetPlatformVersion` and `/p:TargetPlatformVersion` and remove the runner pin.

---

## Recommended CI MSBuild invocation (AMD64)

```yaml
- name: Restore SDK-style projects
  shell: pwsh
  working-directory: ${{ github.workspace }}
  run: |
    dotnet restore src\cascadia\WpfTerminalControl\WpfTerminalControl.csproj
    dotnet restore src\cascadia\WpfTerminalTestNetCore\WpfTerminalTestNetCore.csproj

- name: Build Windows Terminal
  shell: pwsh
  working-directory: ${{ github.workspace }}
  run: |
    $env:PATH = "C:\Program Files\dotnet;$env:PATH"
    $env:DOTNET_ROOT = 'C:\Program Files\dotnet'
    Import-Module .\tools\OpenConsole.psm1
    Set-MsBuildDevEnvironment
    Invoke-OpenConsoleBuild `
      /p:Platform=x64 `
      /p:Configuration=Release `
      /p:WindowsTargetPlatformVersion=10.0.22621.0 `
      /p:TargetPlatformVersion=10.0.22621.0
```

---

## Build time reference

| Phase | Time (ARM64 VM, Parallels) |
|---|---|
| `git submodule update --init --recursive` | ~2 min |
| NuGet restore | ~2 min (first time) |
| Full ARM64 Release build (all projects) | ~8–9 min |
| Incremental rebuild (no changes) | ~4 sec |

AMD64 native (GitHub `windows-latest`) is expected to be faster.
