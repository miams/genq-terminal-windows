# GenQuery Terminal — Branding & Customization Checklist

Everything needed to fully rebrand this fork. Complete the answer sheet in Part 1, then provide assets listed in Part 2. Part 3 items require no decisions and will be applied automatically.

---

## Part 1 — Questionnaire

_Answer each question below. Feed this completed document back to the LLM to apply all changes._

---

### Package Identity

**Q1. Package identity name**
The internal Windows package name used for installation uniqueness. Changing it requires uninstalling any previously installed version.

- [ ] A) `com.genquery.terminal` _(recommended — reverse-DNS, matches convention)_
- [ ] B) `GenQuery.Terminal`
- [ ] C) Keep as `Microsoft.WindowsTerminal` _(not recommended — conflicts with real WT if both installed)_
- [ ] D) Other: _______________

`Answer: ` D. com.zephyrsystems.genquery

---

**Q2. Publisher display name**
Shown in the package manifest and installer UI. Currently "Microsoft Corporation".

- [ ] A) `GenQuery` _(recommended)_
- [ ] B) Your full legal name or company name: _______________
- [ ] C) Keep as `Microsoft Corporation` _(not recommended)_

`Answer: ` B.  Zephyr Systems

---

**Q3. Publisher identity string (for code signing)**
Must match the Subject of your code signing certificate exactly. For sideload-only distribution with no cert, a self-signed value is fine.

- [ ] A) `CN=GenQuery` _(recommended for unsigned/sideload)_
- [ ] B) Match my signing certificate — Subject is: _______________
- [ ] C) Decide later / leave unchanged for now

`Answer: `B: Zephyr Systems

---

**Q4. Version number**
Windows packages use `Major.Minor.Build.Revision` format.

- [ ] A) `1.0.0.0` _(keep current)_
- [ ] B) Mirror upstream Windows Terminal fork base, e.g. `25.0.0.0` _(recommended — signals provenance)_
- [ ] C) Custom: _______________

`Answer: ` C: 0.1.1.0

---

### About Dialog

**Q5. "Source code" link**
Currently points to Microsoft's upstream Windows Terminal GitHub.

- [ ] A) `https://github.com/miams/genq-terminal-windows` _(recommended)_
- [ ] B) Different URL: _______________
- [ ] C) Remove this link

`Answer: ` B: https://github.com/miams/genq

---

**Q6. "Documentation" link**
Currently points to Microsoft's Windows Terminal docs.

- [ ] A) Point to GenQuery docs — URL: _______________
- [ ] B) Point to this repo's README/wiki
- [ ] C) Remove this link _(recommended if no docs exist yet)_

`Answer: ` B: https://deepwiki.com/miams/genq

---

**Q7. "Release notes" link**
Currently points to Microsoft's release notes.

- [ ] A) Point to GitHub releases page: `https://github.com/miams/genq-terminal-windows/releases`
- [ ] B) Point to a different URL: _______________
- [ ] C) Remove this link _(recommended if no release notes exist yet)_

`Answer: ` B: https://github.com/miams/genq/releases/latest

---

**Q8. "Privacy policy" link**
Currently points to Microsoft's privacy policy.

- [ ] A) Point to GenQuery privacy policy — URL: _______________
- [ ] B) Remove this link _(recommended if no privacy policy exists)_
- [ ] C) Keep Microsoft's link _(not recommended)_

`Answer: ` A: https://github.com/miams/genq/Privacy_Policy.html

---

**Q9. "Send feedback" button**
The primary button on the About dialog. Currently fires a Microsoft feedback URL.

- [ ] A) Replace with GitHub Issues link: `https://github.com/miams/genq-terminal-windows/issues` _(recommended)_
- [ ] B) Replace with a different URL: _______________
- [ ] C) Remove the button entirely

`Answer: ` B: https://github.com/miams/genq/discussions

---

### Default Profile & Appearance

**Q10. Color scheme for the GenQuery profile**
The GenQuery profile references `"GenQuery Dark"` which is not yet defined — currently broken/falls back to Campbell. A scheme must be created.

- [ ] A) Base it on **One Half Dark** (dark grey bg, soft colors — good for long sessions) _(recommended)_
- [ ] B) Base it on **Tango Dark** (true black bg, punchy colors)
- [ ] C) Base it on **Campbell** (the Windows Terminal default)
- [ ] D) Custom — I will describe the palette: _______________

`Answer: ` A:

---

**Q11. Default font**
Cascadia Mono ships with the app and always works. Nerd Font variants add glyphs used by Nushell prompts/completions.

- [ ] A) Keep `Cascadia Mono` size 14 _(safe default, always present)_
- [ ] B) `CaskaydiaCove Nerd Font` size 14 _(recommended if Nushell prompt uses icons — must be installed by user or bundled)_
- [ ] C) Different font: _______________, size: ___

`Answer: ` B: CaskaydiaCove Nerd Font size 14 — bundle with app

---

**Q12. Window launch size**

- [ ] A) Keep default (120 cols × 30 rows, windowed) _(current)_
- [ ] B) Maximized on launch _(recommended for a focused app experience)_
- [ ] C) Fullscreen on launch
- [ ] D) Different size — cols: ___, rows: ___

`Answer: ` B:

---

**Q13. Background transparency (acrylic)**
Acrylic gives a frosted-glass blur effect. Looks polished but can affect readability.

- [ ] A) No transparency — solid background _(recommended for readability)_
- [ ] B) Subtle acrylic — opacity 90% _(slight depth effect)_
- [ ] C) Medium acrylic — opacity 80% _(visible blur)_
- [ ] D) Custom opacity: ___%

`Answer: ` A:

---

**Q14. Title bar text**
Currently shows the running command / current directory (standard terminal behavior).

- [ ] A) Show current directory / command (dynamic) _(current behavior)_
- [ ] B) Fixed title "GenQuery Terminal" _(recommended for a polished app feel)_
- [ ] C) Show profile name only

`Answer: ` "GenQuery"

---

**Q15. Other shell profiles (PowerShell, CMD, WSL, etc.)**
These appear as additional tabs users can open. The GenQuery profile is already the default.

- [ ] A) Keep all standard profiles visible _(current — useful for power users)_
- [ ] B) Hide all standard profiles (still accessible via settings) _(recommended for a focused UX)_
- [ ] C) Remove standard profiles entirely _(cleanest, but irreversible without editing defaults.json)_

`Answer: ` B:

---

### File Explorer Integration

**Q16. Right-click "Open in Terminal" context menu text**
Appears in Windows File Explorer when right-clicking a folder.

- [ ] A) Keep as `Open in Terminal` _(current — generic, unbranded)_
- [ ] B) `Open in GenQuery Terminal` _(recommended — clear branding)_
- [ ] C) `Open in GenQuery`
- [ ] D) Remove context menu integration

`Answer: ` C:

---

### Telemetry

**Q17. Microsoft telemetry**
The app currently sends usage telemetry to Microsoft's pipeline. This is low-risk for private distribution but sends data about a third party's product.

- [ ] A) Disable telemetry _(recommended — this is not Microsoft's product)_
- [ ] B) Keep Microsoft telemetry as-is _(lowest effort, acceptable for internal use)_
- [ ] C) Replace with custom analytics — service: _______________

`Answer: ` A: Disable Microsoft telemetry now. Custom opt-in analytics deferred to Phase 7 per genq production plan (service TBD).

---

### App Icon

**Q18. Do you have an existing GenQuery logo or mark to use for the app icon?**

- [ ] A) Yes — I will provide a source file (SVG or 1024×1024 PNG)
- [ ] B) No — generate a placeholder icon from text/initials _(recommended to unblock the build)_
- [ ] C) No — I want to design one first before updating

`Answer: ` A:  /Users/miams/Code/genq-terminal-windows/assets/GenQuery-Logo-1024.png

---

**Q19. Icon style (if generating or designing)**

- [ ] A) Windows 11 fluent style — rounded square, layered, gradient _(recommended — matches OS)_
- [ ] B) Flat minimal — solid color, simple mark
- [ ] C) No preference

`Answer: ` A:

---

**Q20. Do you need high-contrast accessibility icon variants?**
Windows high-contrast mode uses `_contrast-black` and `_contrast-white` variants. Required for Store submission; optional for private sideload.

- [ ] A) Yes — generate solid black and white versions automatically _(recommended)_
- [ ] B) No — skip for now

`Answer: ` A:

---

### GenQuery Dark Color Scheme (only if Q10 = D)

_Skip this section unless you answered Q10-D (custom palette). Otherwise the selected base scheme will be adapted._

**Q21. Background color** (hex): `Answer: `
**Q22. Foreground / default text color** (hex): `Answer: `
**Q23. Cursor color** (hex): `Answer: `
**Q24. Accent / highlight color** (used for selection background) (hex): `Answer: ` 
**Q25. Overall mood** — dark and focused / bright and energetic / neutral and professional: `Answer: `

---

## Part 2 — Assets to Provide

After answering the questions above, you will need to supply these files. Each has a drop location in the repo.

| # | Asset | Format | Drop location | Needed for | Answers |
|---|---|---|---|---|---|
| A1 | App icon master | SVG or PNG 1024×1024 | Provide to LLM — it will generate all scale variants | All icon sizes (Q18=A) | ~/Code/genq-terminal-windows/assets/.  500 px PNG is original.  1024 is upscaled.
| A2 | GenQuery profile tab icon | PNG 32×32 or 64×64, transparent bg | `src/cascadia/CascadiaPackage/ProfileIcons/genquery.png` | Tab strip icon | Generate a 64x64 icon based on A1
| A3 | Signing certificate subject | Text string | Answer in Q3 | Package manifest publisher | CN=Zephyr Systems |

---

## Part 3 — Automatic Fixes (no input needed)

These will be applied when you feed the completed questionnaire back:

| Item | Change | File |
|---|---|---|
| `AppShortName` | "Terminal" → "GenQuery" | `Resources.resw:153` |
| `PublisherDisplayName` | "Microsoft Corporation" → answer from Q2 | `Package.appxmanifest:28` |
| `AppNameDev/Can/Pre` variants | Update to "GenQuery Terminal Dev/Canary/Preview" | `Resources.resw:125,129,133` |
| Shell extension namespace | `com.microsoft.windows.terminal` → `com.genquery.terminal` | `Package.appxmanifest:168` |
| `GenQuery Dark` scheme | Add to `defaults.json` based on Q10 answer | `defaults.json` |
| All About dialog URLs | Replace per Q5–Q9 answers | `AboutDialog.xaml`, `AboutDialog.cpp` |
| Package identity | Replace per Q1–Q4 answers | `Package.appxmanifest` |
