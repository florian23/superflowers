# Upstream Tracking

## Current Base
- **Upstream:** obra/superpowers
- **Base Version:** v6.0.3
- **Base Commit:** v6.0.3 tag (obra/superpowers)
- **Last Sync:** 2026-06-26 (partial — brainstorming/Visual Companion deferred to a follow-up pass)

## Modified Files (intentional divergence — never blindly overwrite)

| File | Why Modified | Sync Strategy |
|---|---|---|
| README.md | Custom Superflowers README with logo, motivation, research citations | NEVER overwrite — our README, not upstream's |
| CLAUDE.md | Superflowers-specific conventions, terminology, workflow chain | NEVER overwrite — completely different purpose than upstream's contributor guidelines |
| RELEASE-NOTES.md | Contains upstream release notes — safe to update | Overwrite from upstream |

## Modified Bundled Skills (intentional divergence)

| Skill | Why Modified | Sync Strategy |
|---|---|---|
| brainstorming | Integrated domain-understanding, architecture chain, constraint-selection, bounded-context-design into workflow | Section-by-section merge — preserve our workflow steps |
| writing-plans | Added FF-first + BDD-first task ordering, Step Definition templates, Task Ordering section | Merge upstream task templates, keep our TDD-first ordering |
| subagent-driven-development | Added Specification Verification Gate, test-first task ordering note | Merge, preserve gate and ordering |
| executing-plans | Removed batch-and-stop, added worktree requirement | Merge cautiously — structural changes |
| finishing-a-development-branch | v5.1.0 environment-detection base + our Step 1 BDD/fitness verification gate + Integration section | Keep our Step 1 gate + Integration; adopt upstream env/cleanup improvements |
| requesting-code-review | Uses our named `superflowers:code-reviewer` agent (upstream switched to general-purpose) | Keep named reviewer — do NOT adopt general-purpose switch |
| systematic-debugging | Modified debugging flow | Merge individual improvements |
| using-git-worktrees | v5.1.0 native-tool rewrite base + our superflowers global path + Integration section | Keep our path + Integration; adopt upstream rewrite improvements |
| verification-before-completion | Modified verification checks | Merge, preserve our checks |
| using-superflowers | Added context isolation, architecture guidance | Merge, preserve our additions |

## Unmodified Bundled Skills (direct update safe)

- test-driven-development
- dispatching-parallel-agents
- receiving-code-review
- writing-skills

## Upstream Design Philosophy (from PR analysis, 2026-04-03)

obra/superpowers has a 96% PR rejection rate. Understanding why informs how we design extensions and what to preserve during syncs.

### What Upstream Values
- **Skills are code, not prose** — skill changes require eval evidence (before/after), not just "looks better"
- **Zero dependencies** — no third-party tools in core; extensions belong in standalone plugins
- **Cross-platform compatibility** — every change must work across Claude Code, Cursor, Codex, OpenCode, Copilot CLI
- **Carefully-tuned language** — "human partner" (not "user"), Red Flags tables, rationalization lists are deliberately worded and tested; don't rewrite without evidence
- **Minimal fixes** — accepted PRs are 1-3 files fixing a real, reproducible bug
- **Plugin architecture** — domain-specific features belong in plugins, not core

### What This Means for Superflowers
- Our 20 custom skills are correctly maintained as fork extensions (would never be accepted upstream)
- During upstream-sync: **preserve our HARD-GATEs, Red Flags, rationalization tables** — upstream's equivalents are independently tuned
- During upstream-sync: **adopt platform support** (new harnesses, cross-platform fixes) — that's where upstream excels
- During upstream-sync: **skip skill rewrites** unless they fix a demonstrable bug — upstream tunes skills through extensive eval, not theory
- If contributing upstream: target `dev` branch, one bug per PR, fill the PR template completely, provide test evidence

## Plugin Versioning & Releasing

Superflowers is installed and updated via the Claude Code plugin/marketplace mechanism:

- **Install:** `/plugin marketplace add florian23/superflowers` → `/plugin install superflowers@superflowers-marketplace`
- **Marketplace name** comes from the `name` field in `.claude-plugin/marketplace.json`
  (`superflowers-marketplace`), *not* the GitHub slug.

**Versioning strategy:** explicit SemVer, mirroring upstream `obra/superpowers` (currently `5.1.0`).
The `version` field lives in **two** places and must stay in sync:

- `.claude-plugin/plugin.json` → `version`
- `.claude-plugin/marketplace.json` → `plugins[].version` (entry for `superflowers`)

**Release procedure:**

1. Bump `version` in both files (keep identical).
2. Commit, then `git tag vX.Y.Z` and `git push --tags`.

**Pitfall (why we don't use commit-SHA versioning):** Claude Code compares the `version`
identifier to detect updates. Commits pushed *without* a version bump produce **no visible update**
for installed users. The trade-off vs. the "drop `version` → every commit is an update" approach is
deliberate: explicit SemVer gives release control and stays aligned with upstream's scheme.

> Note: upstream version bumps (e.g. v5.0.7) are skipped during sync — they version
> obra/superpowers, not this fork. Our `version` is independent.

## Sync History

- **2026-06-26:** Sync to v6.0.3 (major upgrade, v5.1.0 → v6.0.0/6.0.2/6.0.3)
  - **Adopted:** new harness support — Kimi, Pi, Antigravity (tool-mapping refs,
    `.kimi-plugin/`, `.pi/extensions/superflowers.ts`, claude-code-tools.md),
    rebranded to superflowers
  - **Adopted:** low-risk bundled skills verbatim (dispatching-parallel-agents,
    receiving-code-review, test-driven-development) + vendor-neutral prose
  - **Adopted:** writing-skills (incl. CSO → Skill Discovery Optimization rename),
    re-applied our superflowers rebrand
  - **Adopted (C4):** writing-plans additive blocks — Task Right-Sizing, Global
    Constraints (distinct from our org Active Constraints), per-Task Interfaces
  - **Adopted (C5):** requesting-code-review Read-Only Review guard (kept our
    named superflowers:code-reviewer + architecture-context block)
  - **Adapted (C1):** using-git-worktrees — adopted global-dir removal (project-
    local only), dropped our ~/.config/superflowers/worktrees path; kept Integration
  - **Adapted (C2):** finishing — followed worktree-cleanup-path simplification;
    KEPT gh pr create (fork workflow) + Step-1 BDD/fitness gate + Integration (did
    NOT adopt forge-neutral gh removal)
  - **Adapted (C3):** SDD — adopted workspace + diff-packaging mechanics
    (scripts/sdd-workspace, task-brief, review-package → .superflowers/sdd, scratch
    out of .git/ per v6.0.3 fix, diff-as-file). KEPT two-stage spec→quality review +
    named reviewer; did NOT consolidate to task-reviewer-prompt.md
  - **Adopted (infra):** .gitignore (.superflowers/, evals/), scripts/lint-shell.sh
  - **Vendor-neutral prose:** adopted broadly; exception kept "Ultrathink" in
    systematic-debugging (functional Claude Code keyword, we are Claude-Code-primary)
  - **Skipped:** task-reviewer-prompt.md as primary, reviewer-prompt consolidation,
    Codex-plugin mirroring tooling, contributor guidelines, README/assets, evals
    submodule
  - **DEFERRED to a follow-up pass:** brainstorming + Visual Companion (700 LOC/8
    files: auth-hardening, server scripts) — careful merge vs our Tailscale
    divergence; hooks/session-start; .opencode/* updates
  - **Our version:** bumped to 1.2.0 (independent of upstream)
- **2026-06-11:** Sync to v5.1.0 (single release, v5.0.7 → v5.1.0)
  - **Adapted:** `using-git-worktrees` (worktree rewrite: Step 0 isolation detection, prefer
    native worktree tools like `EnterWorktree`, submodule guard, consent prompt, sandbox fallback —
    preserved our `~/.config/superflowers/worktrees` path + Integration section)
  - **Adapted:** `finishing-a-development-branch` (environment detection: normal/worktree/detached-HEAD,
    reduced 3-option menu, merge-before-delete cleanup, PR-iteration worktree preservation —
    preserved our Step 1 BDD + fitness-function verification gate + Integration section)
  - **Adopted:** version-bump tooling (`scripts/bump-version.sh` + `.version-bump.json`, tailored to
    our manifests, no `.codex-plugin`) — supports our SemVer release discipline
  - **Adopted:** delete deprecated legacy command stubs (`commands/{brainstorm,execute-plan,write-plan}.md`);
    dropped now-empty `commands/` from CLAUDE.md Structure
  - **Adopted (small):** worktree dependency wording in SDD + executing-plans Integration sections;
    `systematic-debugging` example-path de-personalization (`/Users/jesse/...` → `~/...`)
  - **Skipped:** `requesting-code-review` switch to `general-purpose` reviewer — conflicts with our
    named reviewer-agent architecture (`agents/code-reviewer.md` + `reviewer-protocol.md`), kept ours
  - **Skipped:** "Integration sections removed from skills" — our workflow chain depends on them
  - **Skipped:** SDD "Continuous execution" paragraph — our flow already removed batch-and-stop and
    has the Specification Verification Gate; not ported to avoid disrupting our customized body
  - **Skipped:** Codex-plugin mirroring tooling (`.codex-plugin/`, `scripts/sync-to-codex-plugin.sh`),
    Contributor Guidelines (AGENTS.md + upstream CLAUDE.md), README/Community/Discord, assets/branding
  - **No-op (already had):** Copilot CLI support, OpenCode fixes, `using-superflowers` Copilot note
    (adapted in the 2026-04-03 v5.0.7 sync)
  - **Pre-existing, out of scope (noted):** `executing-plans` line 37 uses "test type" (canon says
    "verification type"); to fix separately
- **2026-04-03:** Sync to v5.0.7 (12 upstream commits)
  - **Adopted:** Community/docs (README, RELEASE-NOTES), OpenCode fixes (bootstrap injection, path alignment)
  - **Adapted:** Copilot CLI support (session-start merged with our Tailscale detection, using-superflowers + copilot-tools.md)
  - **Skipped:** v5.0.7 release infra (version bumps for obra/superpowers, not our fork), Contributor Guidelines (CLAUDE.md + AGENTS.md for upstream contributors, not relevant to our fork)
- **2026-04-03:** Initial tracking created. Fork based on v5.0.6, 93 commits ahead.
