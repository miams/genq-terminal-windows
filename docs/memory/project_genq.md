---
name: GenQuery Product Overview
description: The GenQuery product, its repos, and overall architecture
type: project
---

GenQuery is a genealogy query tool built on Nushell (Nu) scripts that queries RootsMagic databases.

**Repositories:**
- `miams/genq` — public — core product: Nu scripts, tests, CI, integration tests for all platforms
- `miams/genq-terminal` — private — Ghostty fork, macOS + Linux terminal app
- `miams/genq-terminal-windows` — public — Windows Terminal fork, Windows interim terminal app

**Key files in genq:**
- `src/main.nu` — GenQuery entry point
- `scripts/genquery-start` — bash launch script (macOS/Linux), uses GHOSTTY_RESOURCES_DIR for bundle detection
- `scripts/genquery-start.ps1` — PowerShell launch script (Windows), uses GENQUERY_RESOURCES_DIR
- `.github/workflows/tests.yaml` — existing Nu test suite, runs on all 3 platforms
- `.github/workflows/build-terminal.yml` — new build workflow for all terminal apps

**CI strategy:** All CI (build + integration tests) runs through `miams/genq` (public = free GitHub Actions minutes). Uses a deploy key (secret: GENQ_TERMINAL_DEPLOY_KEY) to access the private genq-terminal repo.

**Launch flow:** GenQuery Terminal app → genquery-start script → nu --interactive → source main.nu → genq

**Why:** Targets the genealogy market (limited but real). Genealogy software skews older/non-technical so product polish matters. Nushell chosen for its structured data handling which suits genealogy queries well.
