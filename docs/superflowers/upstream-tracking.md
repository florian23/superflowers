# Upstream Tracking

## Current Base
- **Upstream:** obra/superpowers
- **Base Version:** v5.0.7
- **Base Commit:** b7a8f76985f1e93e75dd2f2a3b424dc731bd9d37 (2026-04-01)
- **Last Sync:** 2026-04-03

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

## Sync History

- **2026-04-03:** Sync to v5.0.7 (12 upstream commits)
  - **Adopted:** Community/docs (README, RELEASE-NOTES), OpenCode fixes (bootstrap injection, path alignment)
  - **Adapted:** Copilot CLI support (session-start merged with our Tailscale detection, using-superflowers + copilot-tools.md)
  - **Skipped:** v5.0.7 release infra (version bumps for obra/superpowers, not our fork), Contributor Guidelines (CLAUDE.md + AGENTS.md for upstream contributors, not relevant to our fork)
- **2026-04-03:** Initial tracking created. Fork based on v5.0.6, 93 commits ahead.
