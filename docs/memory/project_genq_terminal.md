---
name: genq-terminal (Ghostty fork)
description: Status, decisions, and key details for the macOS/Linux Ghostty fork
type: project
---

**Repo:** `miams/genq-terminal` (private fork of ghostty-org/ghostty)
**Local path:** /Users/miams/Code/genq-terminal
**Active branch:** `genq` (all customizations here; `main` mirrors upstream)
**Minimum Zig version:** 0.15.2 (see build.zig.zon)

**Platforms:** macOS (primary) + Linux (same repo — Ghostty has GTK4 support)

**Current customizations (all on genq branch):**
- `src/build_config.zig` — bundle ID changed to `com.zephyrsystems.genquery`
- `macos/Ghostty-Info.plist` — CFBundleName set to "GenQuery Terminal"
- `macos/Ghostty.xcodeproj/project.pbxproj` — bundle identity updated

**Config (not source):** Lives at ~/Library/Application Support/com.zephyrsystems.genquery/config.ghostty
- command = direct:/Users/miams/.local/bin/genquery-start (dev-only path — Phase 3 will bundle this)
- shell-integration = none

**genquery-start script:** Lives in miams/genq/scripts/genquery-start (bash). Detects bundle mode via GHOSTTY_RESOURCES_DIR. Currently installed at /Users/miams/.local/bin/genquery-start for dev use.

**POC completed:** Built DMG, ran from DMG successfully, ad-hoc signed.

**Docs in repo (docs/ folder):**
- architecture.md, customizations.md, upstream-sync.md, roadmap.md, windows.md

**Phase 1 CI:** build-terminal.yml in miams/genq builds macOS DMG and Linux tarball using deploy key.

**Key Why:** Ghostty sets GHOSTTY_RESOURCES_DIR before launching any command — used for bundle detection in genquery-start. Shell integration is disabled (shell-integration = none) because GenQuery runs as a direct command, not inside a login shell.
