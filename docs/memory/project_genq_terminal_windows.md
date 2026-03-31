---
name: genq-terminal-windows (Windows Terminal fork)
description: Status, decisions, and key details for the Windows Terminal fork
type: project
---

**Repo:** `miams/genq-terminal-windows` (public fork of microsoft/terminal)
**Local path (Windows VM):** C:\Users\miams\Code\genq-terminal-windows
**Active branch:** `genq`
**Status as of 2026-03-22:** Fork created, initial customizations committed, CI workflow written — **local Windows ARM64 build VERIFIED**

**This is an interim solution.** Will be retired when Ghostty's Windows support matures. Retirement criteria in genq-terminal/docs/windows.md.

**Windows support:** Windows 10 version 2004 (build 19041) and later, Windows 11.

**Customizations made:**
- `src/cascadia/CascadiaPackage/Resources/en-US/Resources.resw` — AppName, AppStoreName → "GenQuery Terminal"; AppDescription updated
- `src/cascadia/TerminalSettingsModel/defaults.json` — GenQuery profile added (GUID: d7a9f5cd-3c14-4f79-8b1a-2e6f9da3b4c5), set as defaultProfile

**GenQuery profile commandline:**
`powershell.exe -ExecutionPolicy Bypass -File "%GENQUERY_RESOURCES_DIR%\genq\scripts\genquery-start.ps1"`

**genquery-start.ps1:** Lives in miams/genq/scripts/genquery-start.ps1. Mirrors bash script — detects bundle mode via GENQUERY_RESOURCES_DIR, falls back to repo-relative paths in dev mode.

**Build verified:** 2026-03-22 on Windows 11 ARM64 (Parallels VM). `WindowsTerminal.exe` and `wt.exe` produced in `bin\ARM64\Release\`.

**Build command (C:\Temp\build_genq.ps1):**
```powershell
Set-Location 'C:\Users\miams\Code\genq-terminal-windows'
$env:DOTNET_ROOT = 'C:\Program Files\dotnet'
$env:PATH = "C:\Program Files\dotnet;$env:PATH"
Import-Module .\tools\OpenConsole.psm1
Set-MsBuildDevEnvironment
Invoke-OpenConsoleBuild /p:Platform=ARM64 /p:Configuration=Release /p:WindowsTargetPlatformVersion=10.0.22621.0 /p:TargetPlatformVersion=10.0.22621.0
```
Must use `pwsh.exe` (PowerShell 7), not Windows PowerShell 5.1 — `OpenConsole.psm1` requires PS7.

**Build requirements (actual):**
- Visual Studio 2022 Community with workloads: `NativeDesktop`, `Universal` (UWP), `UWP.VC` C++ tools, `.NET Framework 4.7.2 targeting pack`
- .NET 9 SDK (`winget install Microsoft.DotNet.SDK.9`)
- PowerShell 7 (`winget install Microsoft.PowerShell`)
- Windows SDK 10.0.22621.0
- Must pass `/p:TargetPlatformVersion=10.0.22621.0 /p:WindowsTargetPlatformVersion=10.0.22621.0` explicitly — ARM64 VM missing 64-bit registry key `HKLM\SOFTWARE\Microsoft\Microsoft SDKs\Windows\v10.0`, so MSBuild auto-detection fails

**CI:** build-windows job in miams/genq/.github/workflows/build-terminal.yml — windows-latest runner, MSBuild x64 Release, ZIP artifact.

**Dev environment:** User has two Windows 11 ARM64 VMs via Parallels on Apple Silicon Mac.
