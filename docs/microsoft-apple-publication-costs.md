# Microsoft & Apple Publication Costs — Zephyr Systems

_Date: 2026-03-29_

---

## Strategy Summary

- **Windows (GenQuery Terminal):** Sell via Microsoft Store + direct website sales. Direct users to website to maximize margin.
- **macOS/Linux (Ghostty fork):** Sell via Mac App Store + direct website sales. Linux via free distribution (Flatpak/Flathub, direct download).
- **iPad:** Not viable — app is keyboard-driven; skip.
- **Shared infrastructure:** One EV cert covers all Windows apps. One Apple Developer account covers all Apple platform apps. Both amortize across future apps at no incremental cost.
- **Fallback if sales lag:** Go Store-only on either platform. Microsoft signs Windows packages during Store ingestion (cert cost → $0). Apple signing is already included in the $99/yr account.

---

## One-Time Costs

| Item | Cost | Notes |
|---|---|---|
| Florida DBA — "Zephyr Systems" (sunbiz.org) | $50 | Filed online, processed same day. No publication requirement. |
| Microsoft Partner Center registration | $19 | One-time developer account. Covers all Windows Store apps. |
| YubiKey 5 (hardware security key) | ~$50 | Required for EV cert — private key must live on hardware token (industry requirement since 2023). |
| **Total one-time** | **~$119** | |

---

## Annual Costs

| Item | Cost | Notes |
|---|---|---|
| EV code signing certificate (SSL.com or Sectigo) | ~$200–$300 | Covers all Windows apps signed under "Zephyr Systems". Eliminates SmartScreen warnings from day one. |
| Apple Developer account | $99 | Covers all apps on all Apple platforms (macOS, iOS, etc.). Includes code signing and notarization. |
| Florida DBA renewal | ~$10 amortized | $50 every 5 years. |
| **Total annual** | **~$310–$410** | |

---

## Revenue Share by Channel

| Platform | Channel | Their cut | You keep |
|---|---|---|---|
| Windows | Microsoft Store | 15% (30% above $1M) | 85% |
| Windows | Direct website (Stripe/Paddle) | ~3% | ~97% |
| macOS | Mac App Store | 15% (Small Business, under $1M) | 85% |
| macOS | Direct website (Stripe/Paddle) | ~3% | ~97% |
| Linux | Direct / Flathub | ~0–3% | ~97–100% |

---

## Breakeven Reference

At $20/license, annual cert costs are covered by approximately:

| Channel | Sales needed to cover annual fixed costs |
|---|---|
| Windows Store only | ~16–21 sales/yr |
| Windows direct only | ~11–16 sales/yr |
| macOS Store only | ~6 sales/yr (lower cert cost) |
| macOS direct only | ~5 sales/yr |
| Combined (all platforms) | Fixed costs shared across all revenue |

---

## Signing Infrastructure — Key Points

### Windows (EV Certificate)
- Issued to "Zephyr Systems" (the DBA), not to a specific app
- Covers unlimited apps and file types (`.msix`, `.exe`, `.dll`, `.ps1`)
- **Do not start with OV** — OV certs still trigger SmartScreen on paid software, killing conversions. EV bypasses SmartScreen immediately.
- SmartScreen reputation builds per executable, not per cert. Renewing the same cert preserves reputation. Switching certs resets it.

### macOS (Apple Developer Account)
- Apple IS the CA — no separate cert purchase needed
- $99/yr covers signing, notarization, and TestFlight for all apps on all Apple platforms
- Notarization (free, included) is required for macOS distribution outside the App Store — Gatekeeper blocks unsigned apps

### Linux
- No signing infrastructure required
- Distribute via Flatpak/Flathub, direct download (`.deb`, `.rpm`, `.AppImage`), Homebrew
- Linux users prefer direct/package-manager distribution; "pay what you want" pricing model recommended

---

## Fallback Plan (if sales lag)

| Scenario | Action | Annual cost impact |
|---|---|---|
| Windows sales lag | Go Microsoft Store-only, drop EV cert | Save ~$200–$300/yr |
| macOS sales lag | Go Mac App Store-only | No saving — Apple account already cheapest option |
| Both lag | Store-only on both platforms | Annual cost drops to ~$110/yr (Apple $99 + DBA $10) |

---

## Total Cost Summary

| Phase | One-time | Annual |
|---|---|---|
| Full launch (both platforms, both channels) | ~$119 | ~$310–$410 |
| Fallback (Store-only on both platforms) | ~$119 (already spent) | ~$110 |

---

## MIT License Compliance (Windows)

Windows Terminal is MIT licensed. Commercial redistribution is permitted. Required: retain upstream Microsoft copyright notices in the About dialog. Recommended: add "Portions © Microsoft Corporation" alongside Zephyr Systems branding.
