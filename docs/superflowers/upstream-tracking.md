# Upstream Tracking

## Current Base
- **Upstream:** obra/superpowers
- **Base Version:** v6.2.0
- **Base Commit:** v6.2.0 tag (obra/superpowers)
- **Last Sync:** 2026-07-26 (v6.2.0 quick-wins: writing-good-tests, find-polluter fix, worktree-path bugfix). **Consciously skipped:** v6.2.0 skills-compression sweep, Codex plugin tooling, Windows SessionStart fix.
- **Prior syncs:** 2026-06-26 (v6.0.3 core) + 2026-07-04 (Visual Companion + bootstrap follow-ups).

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
| subagent-driven-development | v6.2.0 base + our Specification Verification Gate (BDD/FF/live evidence, no parking), test-first ordering note, named reviewer at the final review only, Integration section | Merge upstream task-loop/ledger/fix-loop mechanics; preserve the gate, the ordering note, and the final-review agent routing |
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

- **2026-07-26 (follow-up):** SDD v6.2.0 re-integration — the piece deferred earlier the same day
  - **Adopted:** plan-scoped workspace (`.superflowers/sdd/<plan-basename>/`, fixes the stale
    cross-plan ledger read), compaction-proof progress ledger, brief-in/report-out implementer
    contract (our copy predated v6.0.3 — the scripts were present but no template called them),
    capped fix loop (5 rounds, resume 1-3 / fresh+escalated 4-5) with breaker and ledger-recorded
    adjudication, scoped re-reviews, pre-flight plan-conflict scan, sharpened Model Selection
    (explicit model per dispatch; turn count beats token price), one fix dispatch after the final
    review, Common Rationalizations table.
  - **Adopted (reversal):** consolidated `task-reviewer` replacing our separate spec-then-quality
    dispatch. Verified first that upstream's template already carries both of our contributions
    verbatim — all four Structure checks and the "do not trust the report" stance — so the
    consolidation loses no content. It also gives the fix loop a single findings set per task,
    which two stages would have re-fragmented. `spec-reviewer-prompt.md` and
    `code-quality-reviewer-prompt.md` deleted.
  - **Kept:** Specification Verification Gate (BDD + fitness functions + live evidence), test-first
    ordering note, Integration section — still exempt from the fix-loop breaker: review findings
    may be parked with a ruling, a red suite may not.
  - **Hardened (ours):** the gate gained its own cap — three fix rounds per failing check, then
    STOP and report BLOCKED, never park it — plus ledger lines (`Gate: <check> fix round <R>/3`,
    `Gate: <check> SKIP — <reason>`, `Gate: green (...)`) so the round counter and SKIP reasons
    survive compaction. Live evidence gained a satisfiable SKIP path (named, ledger-recorded) for
    plans with nothing startable, since otherwise the gate was formally unpassable in a library or
    plugin repo.
  - **Adapted:** the named `superflowers:code-reviewer` now runs the final whole-branch review
    only; per-task review is `general-purpose`. Its agent profile (plan alignment, SOLID,
    scalability) is a merge-review lens that fights the task reviewer's "do not crawl the broader
    codebase" scoping. `requesting-code-review` is untouched — its named-reviewer divergence
    from upstream stands.
  - **Added (ours):** the task reviewer flags Step Definitions, fitness functions, modified
    `.feature` files, and constraint criteria touched by a task — flag only, with two checks
    marked structural rather than quality judgments: Step Definitions with no application code
    behind them, and any `.feature` file the diff modifies (not the implementer's to edit). The
    dedicated reviewers still run in the gate at the end.
  - **Learned during execution:** a controller staging rule — never `git add -A` or `git add .`
    while an implementer is live in the working tree, so its half-finished edits can't be swept
    into an unrelated commit — and a clarification that the helper scripts don't share an output
    format (`sdd-workspace` prints a bare path; `task-brief` and `review-package` print
    `wrote <PATH>: <summary>`). Both went into `SKILL.md` directly, since upstream's templates are
    off-limits to edit.

- **2026-07-26:** Partial sync to v6.2.0 (from base v6.0.3; branch `upstream-sync/v6.2.0`)
  - **Adopted:** `writing-good-tests` reframe — replaced `testing-anti-patterns.md` with
    `writing-good-tests.md` (falsifiability discipline: name the production change that would make
    a test fail before writing it; assert on real behavior not mocks) + the coherent TDD SKILL.md
    update. TDD was unmodified vs v6.0.3 → direct file update. Fixed one `superpowers:`→`superflowers:` ref.
  - **Adopted:** `systematic-debugging/find-polluter.sh` path-matching bugfix (accept `./`-prefixed
    patterns, collapse `**/`, guard empty result). Our copy was identical to v6.0.3.
  - **Adapted:** worktree-path capture bugfix in `finishing-a-development-branch` (from upstream
    0b47219) — we had the same bug: Step 6 recomputed `WORKTREE_PATH` via `--show-toplevel` after
    Options 1 & 4 had `cd`'d to the main root, so cleanup silently no-oped. Captured it in Step 2
    instead. Kept our Discard option + Step 1 live-evidence + Step 4 standing-preference.
  - **Deferred:** SDD plan-scoped workspace + resume-based fix loop (~541-line SKILL.md restructure).
    High value (fixes stale cross-plan ledger read) but collides with our Spec Verification Gate +
    live-evidence — needs a dedicated re-integration session.
  - **Consciously skipped:** v6.2.0 skills-compression sweep (stylistic; collides with our modified
    skills incl. freshly-merged retro #1–#7; we apply the lean spirit to our own skills deliberately,
    not by wholesale adoption). Extracted only its one functional fix (worktree path, above). Also
    skipped: Codex plugin/portal tooling (consistent with prior skip), Windows SessionStart hook fix
    (no Windows use), forge-agnostic PR change (our workflow is GitHub `gh`), "stop offering discard"
    (we keep Discard with typed confirmation).

- **2026-07-04:** v6.0.3 bootstrap follow-up (completes the deferred bootstrap piece)
  - **session-start:** dropped the obsolete legacy-skills warning; added `| cat` to the
    printf outputs (SIGPIPE/buffer fix). Kept our Copilot CLI platform detection.
  - **OpenCode consolidation:** merged our two divergent plugin files into a single
    up-to-date `.opencode/plugins/superflowers.js` (upstream v6.0.3 `messages.transform`,
    fixes token bloat #750 + multi-system-message #894; vendor-neutral tools). Removed the
    stale `superpowers.js`; realigned `tests/opencode/*`, `.opencode/INSTALL.md`,
    `docs/README.opencode.md` (install URL → florian23/superflowers).
  - **Nothing left deferred** from v6.0.3 (Codex-plugin mirroring remains a conscious skip).

- **2026-07-04:** v6.0.3 Visual Companion follow-up (the piece deferred on 2026-06-26)
  - **Adopted:** Visual Companion auth-hardening — `server.cjs` (bearer keys, WS auth,
    cross-origin protection, `/files/*` path-escape guard, key out of URL), `helper.js`,
    `frame-template.html`, `stop-server.sh`, `spec-document-reviewer-prompt.md` (verbatim +
    `.superpowers`→`.superflowers` rebrand)
  - **Adapted:** `start-server.sh` — 3-way merge: upstream base + our Tailscale auto-detect
    block (bind `0.0.0.0` + tailnet IP when no explicit `--host`). Upstream doesn't touch
    host/bind logic; the hardening's threat model explicitly covers the non-loopback/tailnet
    case, so auth + tailnet binding are complementary
  - **Adapted:** `brainstorming/SKILL.md` — just-in-time companion offer + `--open` flag;
    our DDD/architecture/BDD workflow integration left untouched
  - **Fork branding:** `brandMarkup()` drops the remote Prime Radiant logo fetch (phone-home,
    undesirable on a tailnet-bound server) + telemetry consts; links to florian23/superflowers
  - **Still deferred:** `hooks/session-start`, `.opencode/*` (VC-independent bootstrap/platform)
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
