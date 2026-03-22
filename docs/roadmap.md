# GenQuery Terminal (Windows) — Roadmap

This fork is **interim**. It will be retired when Ghostty's Windows support matures. Scope all work accordingly — polished but not over-engineered.

For the full cross-platform roadmap, see `docs/roadmap.md` in `miams/genq-terminal`.

## Phase 1 — CI & Stability

- [x] Fork created: `miams/genq-terminal-windows`
- [x] `genq` branch established
- [x] App name changed to "GenQuery Terminal"
- [x] GenQuery default profile added to `defaults.json`
- [x] `genquery-start.ps1` created in `miams/genq/scripts/`
- [ ] CI build job in `miams/genq` — `windows-latest`, MSBuild, ZIP artifact
- [ ] Smoke test — app launches, GenQuery profile is default
- [ ] Resolve `GENQUERY_RESOURCES_DIR` for dev mode (dev path fallback in `genquery-start.ps1` already handled)

## Phase 2 — Branding

- [ ] Custom app icon (replace Windows Terminal icon assets)
- [ ] "GenQuery Dark" color scheme added to `defaults.json`
- [ ] Hide PowerShell/cmd profiles from default UI (`hidden: true`)
- [ ] About dialog — "GenQuery Terminal" with Windows Terminal attribution
- [ ] Remove Settings UI pages irrelevant to GenQuery users

## Phase 3 — Self-Contained Bundle

- [ ] Bundle Nushell binary alongside app
- [ ] Bundle GenQuery scripts in resources directory
- [ ] Set `GENQUERY_RESOURCES_DIR` at app startup
- [ ] Portable ZIP distribution — no installer, no admin rights required
- [ ] Minimal `env.nu` for GenQuery (extracted from user's nushell config)

## Phase 4 — Distribution

- [ ] Versioned ZIP artifacts via GitHub Releases (coordinated with `miams/genq` releases)
- [ ] ARM64 build artifact (for ARM Windows devices)
- [ ] Consider MSIX package for cleaner Windows integration

## Retirement (Phase 7)

When Ghostty Windows support is stable, this fork is retired. See retirement criteria in `miams/genq-terminal/docs/windows.md`.
