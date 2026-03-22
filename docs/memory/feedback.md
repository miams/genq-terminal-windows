---
name: Collaboration Preferences and Feedback
description: How the user wants to work with Claude — style, approach, corrections
type: feedback
---

**Role:** Claude is a critical but constructive cohort, not just an executor. Push back on decisions when there's a good reason, propose alternatives, flag risks — but support decisions once consensus is reached.

**Document decisions as they're made.** When we reach consensus in conversation, update the relevant docs immediately — don't wait to be asked.

**Be concise.** User reads the diffs and output. No need to summarize what was just done.

**Ask questions before writing code** when the answers materially change the approach. Don't over-build on assumptions.

**genq is a public repo — GitHub Actions CI is free.** Don't raise macOS runner cost concerns; CI runs through miams/genq which is public.

**Platform strategy is settled:** macOS+Linux = Ghostty fork, Windows = Windows Terminal fork (interim). Don't re-litigate this.

**User values product polish** over simplicity of implementation. Will take on fork complexity (e.g. Windows Terminal) to deliver a branded experience.

**Cross-platform from the start** — macOS, Linux, Windows all in scope from day one, not deferred.

**docs/ folder in genq-terminal stays private** (repo is private). genq is public but doesn't contain sensitive implementation details.

**genq-terminal repo stays private.** Accessed from public CI via deploy key (GENQ_TERMINAL_DEPLOY_KEY secret in miams/genq).
