# GenQuery Terminal (Windows) — Architecture

## What This Is

GenQuery Terminal for Windows is a private fork of [Windows Terminal](https://github.com/microsoft/terminal) (MIT license), customized as the Windows platform delivery for the GenQuery genealogy query tool.

This is an **interim solution**. When Ghostty's Windows support matures, Windows will consolidate into `miams/genq-terminal` (the Ghostty fork) and this repository will be retired. See `windows.md` in `miams/genq-terminal/docs/` for retirement criteria.

**macOS and Linux** are served by the Ghostty fork at `miams/genq-terminal`.

## Repository Layout

```
genq-terminal-windows/          ← fork of microsoft/terminal
  src/cascadia/                 ← C++/WinUI terminal source
    CascadiaPackage/            ← App package manifest and resources
    TerminalSettingsModel/      ← Settings including defaults.json
  docs/                         ← GenQuery-specific development docs (this folder)
  OpenConsole.slnx              ← Visual Studio solution
```

All GenQuery customizations live on the `genq` branch. The `main` branch mirrors upstream and is never committed to directly.

## Branch Strategy

```
main    ← mirrors upstream microsoft/terminal (sync via GitHub "Sync fork")
genq    ← all GenQuery customizations, rebased onto main after upstream syncs
```

When Windows Terminal releases an update:
1. Use GitHub "Sync fork" to bring `main` up to date
2. `git pull origin main` locally
3. `git rebase main` on `genq`
4. See `upstream-sync.md` for conflict resolution

## Key Architectural Decisions

### Decision 1: Fork for branding, not just config
A standalone branded app ("GenQuery Terminal") requires forking. Config-only would leave "Windows Terminal" in the title bar and taskbar — not acceptable for a polished product.

### Decision 2: Minimal diff from upstream
Changes are kept as small as possible. Each change is documented in `customizations.md`. This minimizes rebase friction when syncing upstream security patches.

### Decision 3: GenQuery profile as default
The GenQuery profile is added to `defaults.json` and set as `defaultProfile`. Standard Windows Terminal profiles (PowerShell, cmd.exe) remain available but are not the default — power users can still access them.

### Decision 4: GENQUERY_RESOURCES_DIR mirrors Ghostty's pattern
The `genquery-start.ps1` launch script uses `%GENQUERY_RESOURCES_DIR%` to detect bundle mode, mirroring the `GHOSTTY_RESOURCES_DIR` pattern used on macOS/Linux. This keeps the launch scripts consistent across platforms.

### Decision 5: ARM64 dev, x64 distribution
Developer machines run Windows 11 ARM64 (via Parallels on Apple Silicon). CI builds target x64 for broad distribution. ARM64 builds will be added as a secondary artifact when the distribution pipeline is in place.

## Build Environment

- **Toolchain:** Visual Studio 2022 with C++ workload, Windows 11 SDK (10.0.22621.0)
- **Solution file:** `OpenConsole.slnx`
- **CI:** `windows-latest` GitHub Actions runner via `miams/genq`
- **Local dev:** Windows 11 ARM64 VM (Parallels on Apple Silicon)

## Licensing

Windows Terminal is MIT licensed (copyright Microsoft Corporation). Our obligations:
- Include MIT license text in distributions (`LICENSE` — already present)
- Include copyright attribution
- Do not misrepresent the fork as the official Windows Terminal

Attribution:
> GenQuery Terminal for Windows is based on [Windows Terminal](https://github.com/microsoft/terminal), used under the MIT License.

## Future

See `roadmap.md` for the phased plan. See `windows.md` in `miams/genq-terminal` for the retirement/consolidation plan.
