# Microsoft Publication Costs — Zephyr Systems

_Date: 2026-03-29_

---

## Strategy Summary

1. **File a DBA** for "Zephyr Systems" in Florida — establishes the legal business name used on all Microsoft and certificate registrations.
2. **Purchase an EV code signing certificate** under "Zephyr Systems" — eliminates SmartScreen warnings from day one, required for paid software credibility.
3. **Sell via both channels** — Microsoft Store for discoverability, product website for direct sales (higher margin). Direct users to the website where possible.
4. **Amortize the cert across multiple apps** — the EV cert covers all apps signed under "Zephyr Systems" with no per-app cost.
5. **Fallback if sales lag** — go Store-only, drop the EV cert. Microsoft signs packages during Store ingestion, so cert cost drops to $0. Only ongoing cost is Microsoft's 15% revenue share.

---

## Cost Breakdown

### One-Time Costs

| Item | Cost | Notes |
|---|---|---|
| Florida DBA ("Fictitious Name Registration") | $50 | Filed at sunbiz.org, processed same day |
| Microsoft Partner Center registration | $19 | One-time developer account fee |
| YubiKey 5 (hardware security key for EV cert) | ~$50 | EV private key must live on hardware token — industry requirement since 2023 |
| **Total one-time** | **~$119** | |

### Annual Costs

| Item | Cost | Notes |
|---|---|---|
| EV code signing certificate (SSL.com or Sectigo) | ~$200–$300 | Covers all apps signed under "Zephyr Systems" |
| Florida DBA renewal | ~$10/yr amortized | $50 every 5 years |
| **Total annual** | **~$210–$310** | |

### Revenue Share (not a fixed cost)

| Channel | Microsoft cut | You keep |
|---|---|---|
| Microsoft Store sales | 15% | 85% |
| Direct website sales (Stripe/Paddle) | ~3% (payment processor) | ~97% |

---

## Breakeven Reference

At $20/license, you need approximately **11–16 Store sales per year** just to cover the cert cost. Direct website sales reach the same breakeven at **~11 sales** (lower cut).

---

## Fallback Plan (if sales lag)

Drop direct download, go **Store-only**:

- No EV cert renewal needed — Microsoft signs the package
- Annual cost drops to **~$0** (only the one-time $19 Partner Center fee was ever spent)
- Still collect 85% of Store revenue
- DBA can be maintained for $10/yr amortized or allowed to lapse if the app is retired

---

## Certificate Notes

- **EV vs OV:** Do not start with OV (cheaper). OV certs still trigger SmartScreen "Windows protected your PC" on paid software, killing conversions. The ~$130/yr premium for EV is worth it.
- **Cert scope:** Issued to "Zephyr Systems" (the DBA), not to a specific app. Sign unlimited apps and file types (`.msix`, `.exe`, `.dll`, `.ps1`).
- **SmartScreen reputation:** Builds per executable/package, not per cert. Switching certs resets reputation for that binary. Renewing the same cert preserves it.
- **Upgrading later:** If revenue grows significantly, forming an LLC uses the same cert — just update the legal entity. No cert re-issuance needed until renewal.

---

## MIT License Compliance

Windows Terminal is licensed under MIT. Commercial redistribution is permitted. Required: retain upstream Microsoft copyright notices in the About dialog. Recommended: add "Portions © Microsoft Corporation" to the About dialog alongside Zephyr Systems branding.
