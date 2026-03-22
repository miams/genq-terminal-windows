---
name: genq-terminal-windows (Windows Terminal fork)
description: Status, decisions, and key details for the Windows Terminal fork
type: project
---

**Repo:** `miams/genq-terminal-windows` (public fork of microsoft/terminal)
**Local path:** /Users/miams/Code/genq-terminal-windows
**Active branch:** `genq`
**Status as of 2026-03-22:** Fork created, initial customizations committed, CI workflow written — local Windows build NOT yet verified

**This is an interim solution.** Will be retired when Ghostty's Windows support matures. Retirement criteria in genq-terminal/docs/windows.md.

**Windows support:** Windows 10 version 2004 (build 19041) and later, Windows 11.

**Customizations made:**
- `src/cascadia/CascadiaPackage/Resources/en-US/Resources.resw` — AppName, AppStoreName → "GenQuery Terminal"; AppDescription updated
- `src/cascadia/TerminalSettingsModel/defaults.json` — GenQuery profile added (GUID: d7a9f5cd-3c14-4f79-8b1a-2e6f9da3b4c5), set as defaultProfile

**GenQuery profile commandline:**
`powershell.exe -ExecutionPolicy Bypass -File "%GENQUERY_RESOURCES_DIR%\genq\scripts\genquery-start.ps1"`

**genquery-start.ps1:** Lives in miams/genq/scripts/genquery-start.ps1. Mirrors bash script — detects bundle mode via GENQUERY_RESOURCES_DIR, falls back to repo-relative paths in dev mode.

**CRITICAL NEXT STEP:** Local build not verified on Windows VM. Must build OpenConsole.slnx in Visual Studio 2022 on a Windows 11 ARM64 VM before trusting CI results.

**Build requirements:**
- Visual Studio 2022 with Desktop development with C++ workload
- Windows 11 SDK (10.0.22621.0)
- NuGet package restore

**CI:** build-windows job in miams/genq/.github/workflows/build-terminal.yml — windows-latest runner, MSBuild x64 Release, ZIP artifact.

**Dev environment:** User has two Windows 11 ARM64 VMs via Parallels on Apple Silicon Mac.
