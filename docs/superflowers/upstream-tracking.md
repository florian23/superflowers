# Upstream Tracking

## Current Base
- **Upstream:** obra/superpowers
- **Base Version:** v5.0.7
- **Base Commit:** b7a8f76985f1e93e75dd2f2a3b424dc731bd9d37 (2026-04-01)
- **Last Sync:** 2026-04-03

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
| finishing-a-development-branch | Modified completion flow | Merge individual improvements |
| requesting-code-review | Modified review flow | Merge individual improvements |
| systematic-debugging | Modified debugging flow | Merge individual improvements |
| using-git-worktrees | Modified worktree setup | Merge individual improvements |
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

## Sync History

- **2026-04-03:** Sync to v5.0.7 (12 upstream commits)
  - **Adopted:** Community/docs (README, RELEASE-NOTES), OpenCode fixes (bootstrap injection, path alignment)
  - **Adapted:** Copilot CLI support (session-start merged with our Tailscale detection, using-superflowers + copilot-tools.md)
  - **Skipped:** v5.0.7 release infra (version bumps for obra/superpowers, not our fork), Contributor Guidelines (CLAUDE.md + AGENTS.md for upstream contributors, not relevant to our fork)
- **2026-04-03:** Initial tracking created. Fork based on v5.0.6, 93 commits ahead.
