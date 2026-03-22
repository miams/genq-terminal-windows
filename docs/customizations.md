# Customizations — Divergence from Upstream Windows Terminal

Authoritative inventory of every change made in this fork. Keep current. Document before committing.

---

## Active Customizations

### 1. App Name
**File:** `src/cascadia/CascadiaPackage/Resources/en-US/Resources.resw`
**Changes:**
- `AppName`: `Terminal` → `GenQuery Terminal`
- `AppStoreName`: `Windows Terminal` → `GenQuery Terminal`
- `AppDescription`: `The New Windows Terminal` → `GenQuery Terminal — Genealogy query interface powered by GenQuery and Nushell`

**Why:** Brand the app as GenQuery Terminal throughout the Windows UI (title bar, taskbar, Start menu).

---

### 2. Default Profile — GenQuery
**File:** `src/cascadia/TerminalSettingsModel/defaults.json`
**Changes:**
- `defaultProfile` set to GenQuery profile GUID `{d7a9f5cd-3c14-4f79-8b1a-2e6f9da3b4c5}`
- GenQuery profile added as first entry in `profiles` array

**GenQuery profile:**
```json
{
    "guid": "{d7a9f5cd-3c14-4f79-8b1a-2e6f9da3b4c5}",
    "name": "GenQuery",
    "commandline": "powershell.exe -ExecutionPolicy Bypass -File \"%GENQUERY_RESOURCES_DIR%\\genq\\scripts\\genquery-start.ps1\"",
    "colorScheme": "GenQuery Dark",
    "fontFace": "Cascadia Mono",
    "fontSize": 14,
    "padding": "12, 12, 12, 12"
}
```

**Why:** GenQuery launches automatically on startup. Standard profiles remain available for power users.

**Note:** `GENQUERY_RESOURCES_DIR` is a Phase 3 concern — it points to the bundled resources directory. In dev mode, `genquery-start.ps1` falls back to repo-relative paths.

---

## Planned Customizations (Not Yet Applied)

| Planned Change | Target File(s) | Phase |
|----------------|---------------|-------|
| App icon | `src/cascadia/CascadiaPackage/` icon assets | Phase 2 |
| Hide PowerShell/cmd profiles from default UI | `defaults.json` — set `hidden: true` | Phase 2 |
| "GenQuery Dark" color scheme | `defaults.json` schemes array | Phase 2 |
| About dialog branding | `src/cascadia/TerminalApp/` | Phase 2 |
| Bundle Nushell binary | Build pipeline + resources | Phase 3 |
| Bundle GenQuery scripts | Build pipeline + resources | Phase 3 |
| GENQUERY_RESOURCES_DIR injection | App startup code | Phase 3 |
| Remove Settings UI pages irrelevant to GenQuery | `src/cascadia/TerminalSettingsEditor/` | Phase 2 |

---

## Removed Customizations

*(None yet)*
