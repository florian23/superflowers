---
name: upstream-sync
description: Use when a new Superpowers version is released and upstream changes need to be evaluated and selectively integrated into the Superflowers fork
---

# Upstream Sync

Evaluate and selectively integrate changes from the upstream Superpowers repository (obra/superpowers) into the Superflowers fork. Groups upstream changes by semantic concept and presents integration decisions per changeset — not per file.

**Semantic anchors:** Git three-way merge, cherry-pick, semantic diff analysis, fork maintenance, upstream tracking.

**Announce at start:** "I'll fetch upstream changes, group them by concept, and walk you through each changeset with an integration recommendation."

## When to Use

- When a new Superpowers version is released
- When the user asks to check for upstream updates
- Periodically to stay aware of upstream development

**When NOT to use:**
- For changes to custom skills (those are ours, not upstream)
- For general git merge operations unrelated to Superpowers

## The Iron Law

```
NO BLIND MERGES — EVERY CHANGESET GETS A CONSCIOUS DECISION
```

<HARD-GATE>
Do NOT run `git merge upstream/main` or `git rebase upstream/main`.
All integration happens through evaluated, per-changeset decisions.
This prevents overwriting our intentional modifications to bundled skills.
</HARD-GATE>

## Prerequisites

Verify the upstream remote exists:

```bash
git remote -v | grep upstream
```

If missing: `git remote add upstream https://github.com/obra/superpowers.git`

Read `docs/superflowers/upstream-tracking.md` to know the current base version and which skills have intentional divergence.

## The Dialog Process

### Step 1: Fetch & Overview

```bash
git fetch upstream
```

Present to the user:

> **Upstream Sync Check**
>
> Current base: v[X] (from upstream-tracking.md)
> Upstream HEAD: [commit hash, date]
> New commits: [N]
>
> [List of commit messages, grouped by date]

If upstream has release notes or a CHANGELOG, summarize the key changes.

Wait for user to confirm they want to proceed with the analysis.

### Step 2: Diff & Categorize Files

```bash
git diff HEAD...upstream/main --name-only
git diff HEAD...upstream/main --stat
```

Categorize every changed file:

| Category | Risk | Action |
|---|---|---|
| **New files** (don't exist in our fork) | Low | Likely adopt |
| **Unmodified bundled skills** (we haven't touched them) | Low | Direct update |
| **Modified bundled skills** (listed in upstream-tracking.md) | HIGH | Semantic changeset analysis |
| **Infrastructure** (package.json, plugin.json, configs) | Medium | Individual review |
| **Deleted files** | Medium | Check if we depend on them |

Present the category summary to the user before diving into details.

### Step 3: Group Commits into Semantic Changesets

This is the core of the skill. **Do not present changes file-by-file.**

```bash
git log HEAD..upstream/main --oneline --no-merges
```

Read each commit's message and diff. Group commits that belong to the same concept:

**Grouping heuristics:**
- Same commit message prefix (e.g., "feat: visual companion" across 3 commits)
- Same files touched across multiple commits
- Sequential commits by the same author on the same topic
- Commits that reference each other

Present as a changeset table:

> | # | Changeset | Commits | Files | Category |
> |---|---|---|---|---|
> | 1 | Visual Companion improvements | 3 | brainstorming, visual-companion.md | Modified bundled |
> | 2 | New skill: code-simplifier | 1 | skills/code-simplifier/ (new) | New files |
> | 3 | TDD step ordering fix | 1 | writing-plans | Modified bundled |
> | 4 | Plugin metadata update | 1 | plugin.json | Infrastructure |

### Step 4: Analyze Each Changeset

For each changeset, starting with low-risk ones:

#### 4a: New Files (Low Risk)

> **Changeset #2: "New skill: code-simplifier"** (1 commit, new directory)
>
> **What it adds:** [summary from commit + file content]
> **Conflicts with our work:** None (new files)
> **Recommendation: Adopt**
>
> Adopt / Skip?

#### 4b: Unmodified Bundled Skills (Low Risk)

> **Changeset #X: "Fix in test-driven-development"** (1 commit)
>
> **What it changes:** [summary]
> **Our modifications:** None — we haven't touched this skill
> **Recommendation: Adopt**
>
> Adopt / Skip?

#### 4c: Modified Bundled Skills (High Risk — the critical ones)

For each changeset touching modified bundled skills:

1. **Read the upstream diff** for the affected files
2. **Read our current version** of those files
3. **Identify which sections overlap:**
   - Sections only upstream changed → safe to adopt
   - Sections only we changed → keep ours
   - Sections both changed → CONFLICT

Present:

> **Changeset #1: "Visual Companion improvements"** (3 commits, 4 files)
>
> **What upstream does:** [concept summary — not line-by-line diff]
> **Why they did it:** [from commit messages / release notes]
>
> **Impact on our modifications:**
> - `brainstorming/SKILL.md`: Upstream changes lines 45-60 (Visual Companion step). We modified lines 30-90 (added architecture chain). **Overlap in lines 45-60.**
> - `visual-companion.md`: We already have this file. Upstream improved [X]. **Mergeable — no overlap in our changes.**
>
> **Do we already have this?** [Yes/No/Partially — compare upstream concept with our implementation]
>
> **Recommendation: Adapt**
> - Merge visual-companion.md improvements (no conflicts)
> - Skip brainstorming changes (our integration is more comprehensive)
> - [Or: integrate upstream's new idea into our existing structure]
>
> **Estimated effort:** ~10 min
>
> Adopt / Skip / Adapt?

If the user chooses "Adapt", discuss HOW to adapt before making changes.

### Step 5: Apply Confirmed Changes

1. Create branch: `upstream-sync/v{new-version}`
2. For each confirmed changeset:
   - **Adopt:** Cherry-pick or copy files directly
   - **Adapt:** Make manual edits guided by the upstream diff
   - **Skip:** Document in tracking file why skipped
3. Commit per changeset (not per file) with message: `upstream-sync: [changeset description] (from v{version})`
4. After each commit: read the modified skill and verify internal consistency

### Step 6: Post-Sync Verification

After all changesets are processed:

1. **Terminology check:** Grep for terms upstream may have introduced that conflict with our canonical terminology (see CLAUDE.md Terminology section)
   ```bash
   grep -rn "test type\|Quality Attribute\|Core Domain\|wire.*step\|approve" skills/ --include="*.md" | head -20
   ```
2. **Workflow chain check:** Read the Integration sections of modified skills — does the chain still connect?
3. **Reference integrity:** Do all `references/` and `agents/` links still resolve?

### Step 7: Update Tracking

Update `docs/superflowers/upstream-tracking.md`:

- New base version
- Sync date
- Per changeset: what was adopted/adapted/skipped and why
- Update the "Modified Bundled Skills" table if new modifications were made

Commit: `upstream-sync: update tracking to v{version}`

## Red Flags — STOP

- `git merge upstream/main` or `git rebase upstream/main` — NEVER do blind merges
- Upstream changes that touch our HARD-GATEs — requires extra scrutiny
- Upstream removes a concept we depend on — escalate to user immediately
- Terminology conflicts — upstream uses "test type" where we use "verification type"

## Rationalization Prevention

| Excuse | Reality |
|--------|---------|
| "Just merge, we'll fix conflicts later" | Later = lost modifications. Every changeset gets a decision. |
| "Upstream is always right" | We diverged intentionally. Our modifications exist for reasons. |
| "This is too slow, just pull everything" | 10 minutes of analysis prevents 10 hours of debugging broken skills. |
| "We can skip this version" | Skipping versions compounds merge debt. Small, frequent syncs are easier. |
| "Our version is better, skip all" | Upstream fixes bugs and adds features. Evaluate, don't dismiss. |

## The Bottom Line

Every changeset gets a conscious decision. Blind merges destroy intentional divergence.

## Integration

**Standalone skill** — not part of the regular brainstorming → implementation workflow.
**Reads:** `docs/superflowers/upstream-tracking.md` (version tracking)
**Writes:** `docs/superflowers/upstream-tracking.md` (after sync)
**References:** CLAUDE.md Terminology section (for post-sync verification)
