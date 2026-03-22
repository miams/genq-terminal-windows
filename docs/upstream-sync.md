# Upstream Sync Procedure

GenQuery Terminal for Windows tracks [microsoft/terminal](https://github.com/microsoft/terminal). The `main` branch mirrors upstream; all GenQuery work lives on the `genq` branch.

## Cadence

| Trigger | Action |
|---------|--------|
| Monthly | Full upstream sync + rebase |
| Security patch upstream | Expedited sync within 48h |
| Windows SDK version bump | Sync + update CI |

Subscribe to releases: https://github.com/microsoft/terminal/releases

## Sync Procedure

### Step 1 — Sync main on GitHub
Use GitHub UI: `miams/genq-terminal-windows` → "Sync fork" → "Update branch".

Or via CLI:
```bash
git checkout main
git pull origin main
```

### Step 2 — Rebase genq onto main
```bash
git checkout genq
git rebase main
```

Conflicts will almost always be in files listed in `customizations.md` only.

```bash
# Resolve conflicts then:
git add <resolved-file>
git rebase --continue

# If unrecoverable:
git rebase --abort
```

### Step 3 — Review upstream changelog

Check for:
- Settings model changes (may affect `defaults.json` format)
- Resource string changes (may affect `Resources.resw`)
- Package manifest changes (may affect `Package.appxmanifest`)
- SDK version bumps (update CI if needed)

```bash
# See what upstream changed in files we touch:
git log main --oneline -- src/cascadia/CascadiaPackage/Resources/en-US/Resources.resw
git log main --oneline -- src/cascadia/TerminalSettingsModel/defaults.json
```

### Step 4 — Build and smoke test

Build in Visual Studio or via CI. Verify:
- App launches as "GenQuery Terminal"
- GenQuery profile is the default
- GenQuery loads on startup

### Step 5 — Push
```bash
git push origin genq --force-with-lease
```

## Conflict Hot Spots

| File | What we changed | Conflict risk |
|------|----------------|---------------|
| `src/cascadia/CascadiaPackage/Resources/en-US/Resources.resw` | AppName, AppStoreName, AppDescription | Low |
| `src/cascadia/TerminalSettingsModel/defaults.json` | defaultProfile, added GenQuery profile | Medium — upstream adds/changes profiles |

If `defaults.json` conflicts badly, accept upstream's version and re-apply the GenQuery profile addition manually (see `customizations.md` for the exact values).
