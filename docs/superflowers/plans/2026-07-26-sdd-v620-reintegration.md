# SDD v6.2.0 Re-Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superflowers:subagent-driven-development (recommended) or superflowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebuild `skills/subagent-driven-development/` on the upstream v6.2.0 base — plan-scoped workspace, compaction-proof progress ledger, consolidated task reviewer, capped fix loop with scoped re-reviews — while preserving the Superflowers divergences (Specification Verification Gate, live evidence, test-first ordering, `superflowers:` namespace, named reviewer at the final review).

**Architecture:** The skill keeps its shape — controller dispatches a fresh implementer per task, reviews, loops on findings, finishes with a whole-branch review. Three structural changes: (1) all short-lived artifacts move to a *per-plan* git-ignored workspace addressed by three helper scripts that now take `PLAN_FILE`; (2) the two per-task review dispatches (spec, then quality) consolidate into one `task-reviewer` returning both verdicts, which makes a single findings set per task and therefore a single fix loop; (3) a progress ledger file becomes the source of truth for what is done, because conversation memory does not survive compaction.

**Tech Stack:** Markdown skill files, POSIX/bash helper scripts (shellcheck-clean via `scripts/lint-shell.sh`), bash harness tests under `tests/claude-code/`.

**Architecture:** N/A — no `architecture.md` in this repo.

**Bounded Contexts:** N/A

**Feature Files:** N/A — this repo has no `.feature` files.

**Characteristic Fitness Functions:** N/A

**Style Fitness Functions:** N/A

**Quality Scenarios:** N/A

**Active ADRs:** N/A

**Active Constraints:** N/A

**Source of truth for adopted content:** `upstream/main` at tag `v6.2.0` (commit `3dcbd5c`). Every "copy from upstream" step below names the exact `git show` command that produces the content.

**Environment Baseline (verified 2026-07-27, before Task 1):**
- `shellcheck` 0.11.0 is installed at `~/.local/bin/shellcheck` (static binary — apt would give 0.9.0 and needs root). `shfmt` is absent; `lint-shell.sh` only needs it with `--format`, which this plan never uses.
- `package.json` has no `scripts` section, and everything under `tests/claude-code/` makes live model calls. There is no fast deterministic full-repo test suite; the tests this plan adds and runs are the verification.
- `scripts/lint-shell.sh --all` is **already red** on `main`: SC2155/SC2034/SC2064 in `skills/ux-wireframes/scripts/serve-designs.sh`, SC2064/SC2320 in `tests/claude-code/test-document-review-system.sh`, SC2155 in `tests/claude-code/test-helpers.sh`, plus findings in `tests/claude-code/test-subagent-driven-development-integration.sh` and `tests/subagent-driven-dev/run-test.sh`. These are pre-existing and **out of scope** — do not fix them, and never run the linter with `--all` in this plan. Bare `scripts/lint-shell.sh` (changed files only) is the correct invocation everywhere.

---

## Decisions this plan encodes

These were settled before the plan was written. Do not re-litigate them mid-execution; if execution reveals one of them is wrong, that is a plan defect — stop and escalate.

1. **Consolidate the per-task review.** One `task-reviewer` dispatch returning a spec verdict *and* a quality verdict, replacing `spec-reviewer-prompt.md` + `code-quality-reviewer-prompt.md`. Both files are deleted. Their content is already present in the upstream template (verified: all four Structure checks and the "do not trust the report" stance carry over verbatim), so nothing is lost by deleting them.
2. **The named reviewer moves to the final review only.** `superflowers:code-reviewer`'s agent profile (plan alignment, SOLID, scalability, integration with existing systems) is a merge-review profile and actively fights the task reviewer's "do not crawl the broader codebase" rule. Task-scoped review dispatches `general-purpose` with `task-reviewer-prompt.md`; the final whole-branch review keeps `superflowers:code-reviewer`. `skills/requesting-code-review/` is **not** touched — its named-reviewer divergence stands.
3. **BDD/fitness-function checking stays lightweight per task.** The task reviewer *flags* that a task touched Step Definitions, fitness functions, or active constraints; it does not deep-review them. `bdd-step-reviewer` and `fitness-function-reviewer` continue to run in the Specification Verification Gate at the end. Rationale: dispatching them per task would re-fragment the findings set that consolidation just unified.
4. **The fix-loop breaker does not apply to the Specification Verification Gate.** Review findings may be parked with a ruling at the round cap. BDD scenarios and fitness functions may not — that gate stays "fix until green, no parking", per the existing HARD-GATE.

---

## File Structure

| File | Disposition | Responsibility after this plan |
|---|---|---|
| `skills/subagent-driven-development/scripts/sdd-workspace` | Modify | Resolve/create the **per-plan** workspace dir; single source of truth for its location |
| `skills/subagent-driven-development/scripts/task-brief` | Modify | Extract Task N's text to a file inside that plan's workspace |
| `skills/subagent-driven-development/scripts/review-package` | Modify | Write a commit-list + stat + diff package into that plan's workspace |
| `skills/subagent-driven-development/implementer-prompt.md` | Modify | Dispatch template: brief file in, report file out, explicit model, TDD evidence |
| `skills/subagent-driven-development/task-reviewer-prompt.md` | Create | Consolidated per-task review: spec verdict + quality verdict + Superflowers artifact flag |
| `skills/subagent-driven-development/re-review-prompt.md` | Create | Scoped re-review: verdict per open finding, new breakage in the fix diff only |
| `skills/subagent-driven-development/SKILL.md` | Rewrite | The controller's process, on the v6.2.0 base + our gates |
| `skills/subagent-driven-development/spec-reviewer-prompt.md` | Delete | Superseded by `task-reviewer-prompt.md` |
| `skills/subagent-driven-development/code-quality-reviewer-prompt.md` | Delete | Superseded by `task-reviewer-prompt.md` |
| `tests/claude-code/test-subagent-driven-development.sh` | Modify | Assertions 2, 5, 7 describe the pre-consolidation skill and will fail |
| `skills/writing-plans/SKILL.md:369` | Modify | Execution-handoff blurb says "two-stage review" |
| `skills/using-superflowers/references/codex-tools.md:36` | Modify | Names `code-quality-reviewer-prompt.md` as an example |
| `docs/superflowers/upstream-tracking.md` | Modify | Clear the deferred entry, record what was adopted |
| `.claude-plugin/plugin.json` + friends | Modify | Version bump via `scripts/bump-version.sh` |

`docs/superflowers/specs/2026-03-23-codex-app-compatibility-design.md:198` also names the deleted files, but it is a dated historical spec describing what was true then. Leave it alone.

---

### Task 1: Plan-scope the workspace scripts

> These are the foundation — every later task references the new `PLAN_FILE` signatures.

**Files:**
- Modify: `skills/subagent-driven-development/scripts/sdd-workspace`
- Modify: `skills/subagent-driven-development/scripts/task-brief:7-9,24`
- Modify: `skills/subagent-driven-development/scripts/review-package:7-8,12-20,25-28`

- [ ] **Step 1: Write a failing check for plan-scoping**

There is no test harness for these scripts. Create one — it is the test that makes the rest of this task verifiable.

Create `tests/sdd-scripts/test-plan-scoping.sh`:

```bash
#!/usr/bin/env bash
# Test: SDD workspace scripts are plan-scoped
# Two different plans must resolve to two different workspace directories.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCRIPTS="$REPO_ROOT/skills/subagent-driven-development/scripts"

fail() { echo "FAIL: $*" >&2; exit 1; }

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
cd "$work"
git init -q .
git config user.email t@t.t
git config user.name t
mkdir -p plans
printf '# Plan A\n\n### Task 1: Alpha\n\nalpha body\n\n### Task 2: Beta\n\nbeta body\n' > plans/plan-a.md
printf '# Plan B\n\n### Task 1: Gamma\n\ngamma body\n' > plans/plan-b.md
git add -A && git commit -qm init

a=$("$SCRIPTS/sdd-workspace" plans/plan-a.md)
b=$("$SCRIPTS/sdd-workspace" plans/plan-b.md)

[ "$a" != "$b" ] || fail "both plans resolved to the same workspace: $a"
case "$a" in */.superflowers/sdd/plan-a) ;; *) fail "unexpected workspace path: $a" ;; esac
case "$b" in */.superflowers/sdd/plan-b) ;; *) fail "unexpected workspace path: $b" ;; esac
[ -f "$work/.superflowers/sdd/.gitignore" ] || fail ".gitignore not written at the sdd/ base"
[ -z "$(git status --porcelain)" ] || fail "workspace leaked into git status"

brief=$("$SCRIPTS/task-brief" plans/plan-a.md 2)
case "$brief" in "$a"/task-2-brief.md) ;; *) fail "brief not in plan A workspace: $brief" ;; esac
grep -q "beta body" "$brief" || fail "brief missing Task 2 body"
grep -q "alpha body" "$brief" && fail "brief bled Task 1 into Task 2"

base=$(git rev-parse HEAD)
echo change >> plans/plan-a.md
git commit -qam change
pkg=$("$SCRIPTS/review-package" plans/plan-a.md "$base" HEAD)
case "$pkg" in "$a"/review-*..*.diff) ;; *) fail "package not in plan A workspace: $pkg" ;; esac
grep -q "^# Review package:" "$pkg" || fail "package missing header"

"$SCRIPTS/sdd-workspace" && fail "sdd-workspace accepted a missing PLAN_FILE argument"

echo "PASS: plan-scoping"
```

- [ ] **Step 2: Run it to verify it fails**

```bash
chmod +x tests/sdd-scripts/test-plan-scoping.sh
tests/sdd-scripts/test-plan-scoping.sh
```

Expected: FAIL — `sdd-workspace` currently takes no arguments, so `task-brief plans/plan-a.md 2` errors or resolves to the flat `.superflowers/sdd/` path.

- [ ] **Step 3: Adopt the upstream scripts with our namespace**

Take upstream's three scripts verbatim, then apply exactly one substitution: `.superpowers` → `.superflowers`.

```bash
cd "$(git rev-parse --show-toplevel)"
for s in sdd-workspace task-brief review-package; do
  git show upstream/main:skills/subagent-driven-development/scripts/$s \
    | sed 's|\.superpowers|.superflowers|g' \
    > skills/subagent-driven-development/scripts/$s
  chmod +x skills/subagent-driven-development/scripts/$s
done
git diff --stat skills/subagent-driven-development/scripts/
```

If `upstream/main` is not fetched: `git fetch upstream --tags` first, or substitute `v6.2.0` for `upstream/main`.

The resulting `sdd-workspace` must end with:

```bash
root=$(git rev-parse --show-toplevel)
base="$root/.superflowers/sdd"
dir="$base/$slug"
mkdir -p "$dir"
printf '*\n' > "$base/.gitignore"
cd "$dir" && pwd
```

Note the `.gitignore` now lives at the `sdd/` **base**, not inside each plan directory — that is what keeps every plan's workspace ignored with one file.

- [ ] **Step 4: Run the test to verify it passes**

```bash
tests/sdd-scripts/test-plan-scoping.sh
```

Expected: `PASS: plan-scoping`

(The directory runner arrives in Task 7 Step 5b — at this point it does not exist yet.)

- [ ] **Step 5: Lint the scripts**

```bash
scripts/lint-shell.sh skills/subagent-driven-development/scripts/sdd-workspace \
  skills/subagent-driven-development/scripts/task-brief \
  skills/subagent-driven-development/scripts/review-package \
  tests/sdd-scripts/test-plan-scoping.sh
```

Expected: `Linting 4 shell files` and no shellcheck output. Fix any finding before committing.

- [ ] **Step 6: Commit**

```bash
git add skills/subagent-driven-development/scripts tests/sdd-scripts
git commit -m "sdd: plan-scope the workspace scripts (from upstream v6.2.0)"
```

---

### Task 2: Bring implementer-prompt.md to the v6.2.0 contract

Our copy predates v6.0.3: it pastes the whole task text into the dispatch, has no report file, no explicit model, and no TDD evidence. The scripts from Task 1 have no caller until this is fixed.

**Files:**
- Modify: `skills/subagent-driven-development/implementer-prompt.md` (full replacement)

- [ ] **Step 1: Replace the file with upstream's, rebranded**

```bash
git show upstream/main:skills/subagent-driven-development/implementer-prompt.md \
  | sed -e 's|superpowers:|superflowers:|g' -e 's|\.superpowers|.superflowers|g' \
  > skills/subagent-driven-development/implementer-prompt.md
```

- [ ] **Step 2: Verify the four contract elements landed**

```bash
grep -n 'BRIEF_FILE\|REPORT_FILE\|model:\|TDD Evidence' skills/subagent-driven-development/implementer-prompt.md
```

Expected: all four present. Specifically —
- `Read your task brief first: [BRIEF_FILE]` replaces the old `[FULL TEXT of task from plan - paste it here]`
- `model: [MODEL — REQUIRED: ...]` in the dispatch header
- `Write your full report to [REPORT_FILE]:` plus the "report back with ONLY (under 15 lines)" short contract
- `**TDD Evidence**` with RED and GREEN sub-bullets

- [ ] **Step 3: Verify no upstream branding survived**

```bash
grep -rn 'superpowers' skills/subagent-driven-development/implementer-prompt.md
```

Expected: no output.

- [ ] **Step 4: Commit**

```bash
git add skills/subagent-driven-development/implementer-prompt.md
git commit -m "sdd: adopt v6.2.0 implementer contract (brief in, report out, explicit model)"
```

---

### Task 3: Create the consolidated task reviewer

**Files:**
- Create: `skills/subagent-driven-development/task-reviewer-prompt.md`

- [ ] **Step 1: Start from upstream's template, rebranded**

```bash
git show upstream/main:skills/subagent-driven-development/task-reviewer-prompt.md \
  | sed -e 's|superpowers:|superflowers:|g' -e 's|\.superpowers|.superflowers|g' \
  > skills/subagent-driven-development/task-reviewer-prompt.md
```

- [ ] **Step 2: Add the Superflowers artifact-flag block**

This is the one thing upstream cannot carry: it does not know about Step Definitions, fitness functions, or our constraint files. Insert this section immediately **after** the `## Part 2: Code Quality` block's `**Structure:**` bullet list and **before** the `Your report should point at evidence:` paragraph:

```markdown
    **Superflowers artifacts (flag only — do not deep-review):**

    If the diff touches any of the following, say so in one line each under
    Spec Compliance. Their internal quality is not yours to judge — naming,
    style, coverage breadth, and structure belong to the dedicated reviewers
    that run in the Specification Verification Gate at the end of the plan.
    The two checks marked **structural** below are yours to make anyway:
    they are violations of how these artifacts must be produced, not
    assessments of how well they were written.

    - Step Definitions (BDD glue binding `.feature` scenarios to application
      code): name the file and the `.feature` file it binds — identify it
      from the diff's own references (path, import, or step text); opening
      that file to confirm the binding is exactly the kind of named-risk
      check this template permits. **Structural:** if a scenario's steps were
      added but the diff contains no application code they call, that IS a
      finding — Step Definitions must fail against real code, not pass
      against stubs.
    - Fitness functions (executable architecture checks): name the file and
      the characteristic it verifies.
    - Any `.feature` file modified by this diff — **structural:** that is a
      finding. Feature files are acceptance criteria written before
      implementation and are not the implementer's to edit.
    - Constraint verification criteria the brief names as binding: state
      whether the diff satisfies each, or ⚠️ if you cannot tell from the diff.
```

> **Why this wording:** the first draft of this block said "flag only" and
> "do not evaluate their internal quality", then declared two findings anyway —
> a reviewer could not tell where the flag-only line sat. Internal quality
> (naming, style, coverage) belongs to the Specification Verification Gate's
> dedicated reviewers; the two structural checks are violations of *how* the
> artifacts must be produced and stay with the task reviewer. The named-risk
> clause resolves the tension with upstream's "do not crawl the broader
> codebase" rule earlier in the same template.

- [ ] **Step 3: Verify the rescued checks are present**

The four Structure checks and the "do not trust the report" stance come from upstream and must be intact — they are what our deleted `code-quality-reviewer-prompt.md` and `spec-reviewer-prompt.md` contributed.

```bash
grep -c 'one clear responsibility\|decomposed so they can be understood\|file structure from the plan\|already large, or' \
  skills/subagent-driven-development/task-reviewer-prompt.md
grep -n 'Do Not Trust the Report' skills/subagent-driven-development/task-reviewer-prompt.md
grep -n 'Step Definitions\|Fitness functions' skills/subagent-driven-development/task-reviewer-prompt.md
```

Expected: `4`, then a hit for the trust section, then hits for the new block.

- [ ] **Step 4: Commit**

```bash
git add skills/subagent-driven-development/task-reviewer-prompt.md
git commit -m "sdd: add consolidated task reviewer with Superflowers artifact flagging"
```

---

### Task 4: Create the scoped re-review template

**Files:**
- Create: `skills/subagent-driven-development/re-review-prompt.md`

- [ ] **Step 1: Copy upstream's template, rebranded**

```bash
git show upstream/main:skills/subagent-driven-development/re-review-prompt.md \
  | sed -e 's|superpowers:|superflowers:|g' -e 's|\.superpowers|.superflowers|g' \
  > skills/subagent-driven-development/re-review-prompt.md
```

- [ ] **Step 2: Verify the scoping contract**

```bash
grep -n 'ADDRESSED\|NOT ADDRESSED' skills/subagent-driven-development/re-review-prompt.md
grep -rn 'superpowers' skills/subagent-driven-development/re-review-prompt.md
```

Expected: hits for the per-finding verdicts; no output from the second grep.

- [ ] **Step 3: Commit**

```bash
git add skills/subagent-driven-development/re-review-prompt.md
git commit -m "sdd: add scoped re-review template (from upstream v6.2.0)"
```

---

### Task 5: Rebuild SKILL.md on the v6.2.0 base

This is the task that carries the risk. Work in order: take upstream whole, then re-apply our four divergences. Do not hand-merge section by section — our current file is the older structure and merging into it reintroduces what this plan is removing.

**Files:**
- Modify: `skills/subagent-driven-development/SKILL.md` (full replacement + four insertions)

> **Two notes carried over from the Task 2 review:**
> - The branding substitution is a no-op in the three prompt templates (0 occurrences of
>   `superpowers` in each upstream file) but **matters here**: upstream's `SKILL.md` contains
>   11 occurrences. Step 1's greps are the real check, not a formality.
> - Upstream's prose uses "spec" to mean *a task's own requirements*, whereas this repo's
>   `CLAUDE.md` reserves "spec" for the brainstorming design-spec artifact in
>   `docs/superflowers/specs/`. Do not rewrite upstream's usage, but when writing OUR inserted
>   sections (Steps 3, 4, 7), use this repo's canonical terms.

- [ ] **Step 1: Take upstream's SKILL.md, rebranded**

```bash
git show upstream/main:skills/subagent-driven-development/SKILL.md \
  | sed -e 's|superpowers:|superflowers:|g' -e 's|\.superpowers|.superflowers|g' \
        -e 's|docs/superpowers/|docs/superflowers/|g' \
  > skills/subagent-driven-development/SKILL.md
grep -rn 'superpowers' skills/subagent-driven-development/SKILL.md
```

Expected: the last grep produces no output.

- [ ] **Step 1a: Fix the opening summary's description of the ending**

Added after Task 5's spec review. Line 8 of upstream's file summarises the process as ending
with the whole-branch review — true upstream, false here once Step 4 inserts the gate after it.
It is the first line an agent reads. Replace, in that line:

```
and a broad whole-branch review at the end.
```

with:

```
a broad whole-branch review, and a specification verification gate before finishing.
```

Leave the similar phrasings at lines 12 and 42 alone: line 12 states a quality principle rather
than an ordering, and line 42 contrasts this skill against executing-plans rather than
enumerating the finish sequence. Neither misleads about where the process ends.

- [ ] **Step 2: Route the per-task and final reviews to the right agents**

In `## The Task Loop` → `### 3. Review the task`, the reviewer is dispatched `general-purpose`. Leave that. In `## Final Review`, upstream already points at `superflowers:requesting-code-review`'s `code-reviewer.md` — make the agent type explicit. Replace the sentence:

```
Dispatch on the most capable available model (see Model Selection), using
superflowers:requesting-code-review's
[code-reviewer.md](../requesting-code-review/code-reviewer.md).
```

with:

```
Dispatch the named `superflowers:code-reviewer` agent on the most capable
available model (see Model Selection), using superflowers:requesting-code-review's
[code-reviewer.md](../requesting-code-review/code-reviewer.md). The named
reviewer belongs here and only here: its profile is plan alignment, SOLID,
scalability, and integration with the existing system — a whole-branch
lens. The per-task reviewer stays `general-purpose`, because that lens
would break its "do not crawl the broader codebase" scoping.
```

- [ ] **Step 2a: Add the script-output clarification**

The three helper scripts print `wrote <PATH>: <summary>` on success — a sentence, not a bare
path. Upstream's prose repeatedly calls it "the path it prints", and `re-review-prompt.md:103`
describes `[DIFF_FILE]` as "the path `scripts/review-package PLAN_FILE FIX_BASE HEAD` printed".
A controller following that literally can substitute the whole sentence into a `[DIFF_FILE]`
placeholder, and the reviewer's "Read the diff file" step then fails on a non-path string.
This exact assumption already produced a broken test text in Task 1 of this plan. Upstream's
templates are off-limits, so the compensating instruction goes here, once, centrally.

In `## The Task Loop`, immediately after the opening paragraph ("Everything you paste into a
dispatch prompt …"), insert:

```
**Reading the helper scripts' output.** `sdd-workspace` prints a bare path.
`task-brief` and `review-package` print `wrote <PATH>: <summary>` — a
sentence. Wherever this skill says "the path it prints" for those two, take
the substring between `wrote ` and the following `: `; never paste the whole
line into a `[BRIEF_FILE]`, `[REPORT_FILE]` or `[DIFF_FILE]` placeholder. A
reviewer handed a sentence instead of a path cannot open its diff.
```

> The three scripts do **not** behave alike — an earlier draft of this step claimed they did,
> and applying its substring rule to `sdd-workspace` (which ends in `cd "$dir" && pwd`) yields
> an empty string. Verify against the scripts before rewording this passage.

- [ ] **Step 2b: Add the controller staging rule**

Learned the hard way during this plan's own execution: the controller committed a plan-document
edit with `git add -A` while an implementer was mid-edit in the same working tree, silently
sweeping the implementer's half-finished work into a commit whose message described only the
plan change. Upstream's "never fix findings yourself" rule does not cover this, because the
controller was not fixing findings — it was doing legitimate parallel bookkeeping.

In `### 4. The fix loop`, immediately after the existing line:

```
Never fix findings yourself in the controller session — your context stays
clean for coordination, and controller fixes skip review.
```

append:

```
The same applies to staging. While any implementer is live in your working
tree, never `git add -A` or `git add .` — you will sweep its half-finished
edits into a commit of your own, under a message that does not describe
them. Stage the explicit paths you are committing, every time.
```

- [ ] **Step 3: Insert the test-first ordering note**

At the end of `## Setup`, immediately after the paragraph beginning `Before dispatching Task 1, scan the plan once for conflicts:` and its bullet list and closing paragraph, append:

```markdown
**Task ordering follows the plan.** If the plan places fitness functions as
early tasks and BDD Step Definitions before implementation tasks, execute in
that order. Test-first means structural fitness functions and Step
Definitions are written BEFORE the code they test — they define the
constraints and expected behavior upfront. The Specification Verification
Gate re-runs everything as a final safety net; it does NOT replace
test-first execution during implementation.
```

- [ ] **Step 4: Insert the Specification Verification Gate**

This is our gate. It goes between `## Final Review` and `## Finish`, as a new top-level section:

```markdown
## Specification Verification Gate

After the final whole-branch review is clean and BEFORE finishing-a-development-branch,
run specification checks:

1. **BDD scenarios** — check with `find . -name '*.feature' -not -path './node_modules/*'`; if any exist:
   - Verify Step Definitions exist for all steps (not just that `.feature` files were written)
   - Run `cucumber --dry-run` (or the project equivalent) to check for undefined steps → if
     undefined: dispatch an implementer to write the missing Step Definitions
   - Run ALL scenarios → all must pass
   - Dispatch superflowers:bdd-step-reviewer to verify the Step Definitions are thin glue
2. **Fitness functions** — check with `find . -name 'architecture.md' -not -path './node_modules/*'`; if it exists:
   - Verify EVERY characteristic marked "Fitness Function: Yes" has an implementation
   - Verify EVERY style fitness function has an implementation
   - Run ALL fitness functions → all must pass
   - Dispatch superflowers:fitness-function-reviewer to verify they test architecture,
     not implementation
3. **Live evidence (beyond green suites):** drive the real system once — start the real
   backend/process, run one real happy-path end-to-end (on the real target device where a
   UI ships), observe actual behavior. Green tests against mocks prove wiring, not reality.
   No live run → not done.
4. ALL checks must pass — partial passage is failure
5. If ANY check fails: dispatch an implementer to fix, then re-run ALL checks from step 1, within the round cap below

<HARD-GATE>
Follow the Review-Loop Pattern from agents/reviewer-protocol.md:
- Dispatch verification checks (BDD + fitness functions) and drive the live run yourself
- If FAIL: dispatch an implementer to fix, then re-run verification (fresh)
- Repeat until ALL checks pass, up to three fix rounds per check
- After three failed rounds on the same check: STOP, report BLOCKED. Never park it.
- Do NOT ask the user whether to fix. Fix automatically.
- Do NOT skip Step Definitions. Feature files without Step Definitions (Glue Code) = FAIL.
- Do NOT skip fitness function implementation. FFs in architecture.md without code = FAIL.
- Do NOT skip the live run. A green suite is not evidence the system ran. No observed
  real run = FAIL. Where nothing is startable (library, plugin, config-only change),
  record `Gate: live evidence SKIP — <what is not startable>` in the ledger;
  "I did not try" is not that reason.
</HARD-GATE>

**Record the gate in the ledger.** This is the only phase that would otherwise leave no
trace, and its round counter must survive compaction — read `<R>` from the ledger, never
from memory. Append as you go:

```
Gate: <check> fix round <R>/3 — <output one-liner>
Gate: <check> SKIP — <reason>
Gate: green (BDD <n> scenarios, FF <n>, live evidence: <one-liner>)
```

**The fix-loop breaker does not apply here.** The task loop's five-round cap
lets you park a review finding with a ruling. This gate has no parking: a
failing scenario or fitness function is not a contestable opinion, it is a
red suite.

It does have a cap, and it ends differently. Three fix rounds per failing
check: rounds 1-2 dispatch an implementer to fix, round 3 dispatches a fresh
one on a more capable model. If the same check still fails after round 3,
STOP and report BLOCKED to your human partner with the check, its output, and
what the three rounds tried. A check that survives three attempts is telling
you the plan or the artifact is wrong, not that it needs a fourth attempt.
Never park a failing check, and never mark the gate green with one
outstanding.

Checks 1 and 2 are conditional on their artifacts existing. The live-evidence check is
not: it runs on every plan. This gate is never optional.
```

> **Why the live-evidence check has no artifact condition.** Checks 1 and 2 legitimately
> skip when a project has no `.feature` files or no `architecture.md`. Check 3 has no such
> escape — a plan that changed nothing runnable still has to say *what* is not runnable, in
> the ledger, by name. Without that, "this repo has nothing to start" becomes a blanket
> excuse to declare the whole gate inapplicable, and the one check that catches
> "green tests, broken system" is the one that never runs.

- [ ] **Step 5+6: Rewire the flowchart and move the deletion behind the gate**

In the `digraph process` block, the final edge currently reads:

```
    "Final review clean: delete this plan's workspace" -> "Use superflowers:finishing-a-development-branch";
```

**Do this as ONE edit to the `digraph process` block, not as a sequence.** An earlier draft of
this plan split it into two steps that partly undid each other, then a review finding added a
third — three overlapping etappen for one block. What follows is the end state; produce it
directly.

Two things change beyond adding the gate: the node `"Final review clean: delete this plan's
workspace"` loses its deletion clause (becoming just `"Final review clean"`), because the gate
runs *after* the final review and may dispatch fixes that still need the workspace; and the
deletion becomes its own node after the gate. The gate's failure path ends at the **existing**
`"STOP: report BLOCKED to human partner"` node — do not declare a second one. The gate's
escalation and the task loop's escalation end in the same place, and the graph should say so.
Match that node's spelling character for character; an edge to a near-miss name silently
declares a new node instead of reusing the old one.

Node declarations — replace the old `"Final review clean: delete this plan's workspace"`
declaration with these:

```
    "Final review clean" [shape=box];
    "Run Specification Verification Gate\n(BDD + fitness functions + live evidence)" [shape=box];
    "All specification checks pass?" [shape=diamond];
    "Third failed round on this check?" [shape=diamond];
    "Fix violations (dispatch implementer)" [shape=box];
    "Delete this plan's workspace" [shape=box];
```

Edges — the tail of the graph, from the final-review fix wave through to finishing, becomes
exactly this:

```
    "Final findings? ONE fix dispatch, one scoped re-review, adjudicate residuals" -> "Final review clean";
    "Final review clean" -> "Run Specification Verification Gate\n(BDD + fitness functions + live evidence)";
    "Run Specification Verification Gate\n(BDD + fitness functions + live evidence)" -> "All specification checks pass?";
    "All specification checks pass?" -> "Delete this plan's workspace" [label="yes"];
    "All specification checks pass?" -> "Third failed round on this check?" [label="no"];
    "Third failed round on this check?" -> "STOP: report BLOCKED to human partner" [label="yes"];
    "Third failed round on this check?" -> "Fix violations (dispatch implementer)" [label="no"];
    "Fix violations (dispatch implementer)" -> "Run Specification Verification Gate\n(BDD + fitness functions + live evidence)";
    "Delete this plan's workspace" -> "Use superflowers:finishing-a-development-branch";
```

No edge may still reference `"Final review clean: delete this plan's workspace"` afterwards.

Then the matching prose. In `## Finish`, replace:

```
When the final whole-branch review is clean and its fixes are merged,
delete this plan's workspace (`rm -rf <workspace>`) — the git history is
the record now.
```

with:

```
When the final whole-branch review is clean, its fixes are merged, and the
Specification Verification Gate is green, delete this plan's workspace
(`rm -rf <workspace>`) — the git history is the record now.
```

**Verify before moving on:** the graph's gate cycle, the `<HARD-GATE>` block, and the gate's
prose paragraph must state one rule between them — three representations, no divergence. Every
node used in an edge is declared, quotes balanced, statements `;`-terminated. Graphviz is not
installed; verify by reading.

- [ ] **Step 6b: Make the Example Workflow show the gate**

Steps 4–6 change the end of the process in three places (the gate section, the flowchart, and
`## Finish`). Upstream demonstrates that same ending a **fourth** time, in prose, in
`## Example Workflow` — and this plan originally forgot it, leaving the file contradicting
itself. Also note Step 1's `sed` does not catch `~/.config/superpowers/hooks/` in this section
(no `superpowers:`, no leading dot, no `docs/` prefix); complete that substitution by hand, or
Step 1's and Step 8's "no output" greps cannot both hold.

Replace the closing sequence of `## Example Workflow`:

```
[After all tasks]
[Run review-package PLAN_FILE MERGE_BASE HEAD; dispatch final code-reviewer, most capable model]
Final reviewer: All requirements met. Deferred minors triaged: none block merge.

[Delete this plan's workspace — the record now lives in git]

Done! Using superflowers:finishing-a-development-branch.
```

with:

```
[After all tasks]
[Run review-package PLAN_FILE MERGE_BASE HEAD; dispatch the named superflowers:code-reviewer, most capable model]
Final reviewer: All requirements met. Deferred minors triaged: none block merge.

[Specification Verification Gate]
  No .feature files and no architecture.md in this project — BDD and
  fitness-function checks report SKIP with that reason.
  Live evidence: started the real CLI, ran install-hook end-to-end against a
  real repo, confirmed the hook fired. Green tests alone would not have
  closed this gate.

[Delete this plan's workspace — the record now lives in git]

Done! Using superflowers:finishing-a-development-branch.
```

This deliberately teaches two things: BDD and fitness-function checks SKIP **with a stated
reason** when the artifacts do not exist, and live evidence applies anyway — it is the one
gate item with no escape hatch.

- [ ] **Step 7: Add the Integration section**

Upstream's SKILL.md has no Integration section; ours did, and the workflow chain depends on it. Append at the end of the file:

```markdown
## Integration

**Required workflow skills:**
- **superflowers:using-git-worktrees** - REQUIRED: Ensures an isolated workspace (creates one or verifies existing) before starting
- **superflowers:writing-plans** - Creates the plan this skill executes
- **superflowers:requesting-code-review** - Code review template for the final whole-branch review
- **superflowers:finishing-a-development-branch** - Complete development after the Specification Verification Gate is green

**Verification sub-skills (Specification Verification Gate):**
- **superflowers:bdd-testing** - When `.feature` files exist
- **superflowers:fitness-functions** - When `architecture.md` exists

**Subagents should use:**
- **superflowers:test-driven-development** - Subagents follow TDD for each task

**Alternative workflow:**
- **superflowers:executing-plans** - Use for parallel session instead of same-session execution
```

- [ ] **Step 8: Verify the rebuild**

```bash
grep -n 'Specification Verification Gate\|Live evidence\|Task ordering follows the plan\|superflowers:code-reviewer\|## Integration' \
  skills/subagent-driven-development/SKILL.md
grep -rn 'superpowers\|spec-reviewer-prompt\|code-quality-reviewer-prompt' skills/subagent-driven-development/SKILL.md
grep -n 'progress.md\|ledger\|fix round\|breaker\|task-reviewer-prompt\|re-review-prompt' \
  skills/subagent-driven-development/SKILL.md | head
```

Expected: first grep hits all five of our divergences; second grep produces **no output**; third grep confirms the adopted v6.2.0 machinery is present.

- [ ] **Step 9: Commit**

```bash
git add skills/subagent-driven-development/SKILL.md
git commit -m "sdd: rebuild SKILL.md on v6.2.0 base with spec gate, live evidence, test-first ordering"
```

---

### Task 6: Remove the superseded prompts and fix cross-references

**Files:**
- Delete: `skills/subagent-driven-development/spec-reviewer-prompt.md`
- Delete: `skills/subagent-driven-development/code-quality-reviewer-prompt.md`
- Modify: `skills/writing-plans/SKILL.md:369`
- Modify: `skills/using-superflowers/references/codex-tools.md:36`

- [ ] **Step 1: Delete the two superseded templates**

```bash
git rm skills/subagent-driven-development/spec-reviewer-prompt.md \
       skills/subagent-driven-development/code-quality-reviewer-prompt.md
```

- [ ] **Step 2: Fix the writing-plans execution handoff**

In `skills/writing-plans/SKILL.md`, replace line 369:

```
- Fresh subagent per task + two-stage review
```

with:

```
- Fresh subagent per task + task review (spec + quality) + broad final review
```

- [ ] **Step 3: Fix the codex-tools reference**

In `skills/using-superflowers/references/codex-tools.md` line 36, replace:

```
   local prompt template like `code-quality-reviewer-prompt.md`)
```

with:

```
   local prompt template like `task-reviewer-prompt.md`)
```

- [ ] **Step 4: Verify no dangling references remain**

```bash
grep -rn 'spec-reviewer-prompt\|code-quality-reviewer-prompt\|two-stage review' \
  --include='*.md' skills/ agents/ references/ CLAUDE.md
```

Expected: only two hits, both historical records that must NOT be edited —
`docs/superflowers/upstream-tracking.md` (rewritten in Task 8) and
`docs/superflowers/specs/2026-03-23-codex-app-compatibility-design.md:198` (a dated spec).
Since the grep above excludes `docs/`, expect **no output**.

Also confirm the skill's file list is what the plan intends:

```bash
ls skills/subagent-driven-development/
```

Expected exactly: `SKILL.md`, `implementer-prompt.md`, `re-review-prompt.md`, `scripts/`, `task-reviewer-prompt.md`.

- [ ] **Step 5: Commit**

```bash
git add -A skills/
git commit -m "sdd: remove superseded two-stage prompts, update cross-references"
```

---

### Task 7: Update the harness tests

Three assertions in the existing test describe the pre-consolidation skill and will now fail — that is correct behavior, not a regression. Update them to assert the new contract.

**Files:**
- Modify: `tests/claude-code/test-subagent-driven-development.sh:32-43` (Test 2), `:83-100` (Test 5), `:121-138` (Test 7)

- [ ] **Step 1: Run the existing test to see it fail**

```bash
tests/claude-code/test-subagent-driven-development.sh
```

Expected: FAIL at Test 2 — it asks which comes first, spec compliance or code quality review, and the consolidated reviewer returns both verdicts in one dispatch. (If your environment cannot run `run_claude`, note that these are live-model tests and proceed to Step 2; verify by reading assertions rather than executing.)

- [ ] **Step 2: Rewrite Test 2 — review consolidation**

Replace the Test 2 block:

```bash
echo "Test 2: Task review consolidation..."

output=$(run_claude "In the subagent-driven-development skill, how many reviewer dispatches happen per task, and what does the reviewer return?" 30)

if assert_contains "$output" "one\|single\|1 " "One reviewer dispatch per task"; then
    : # pass
else
    exit 1
fi

if assert_contains "$output" "spec.*quality\|both verdicts\|two verdicts\|compliance.*quality" "Returns both verdicts"; then
    : # pass
else
    exit 1
fi
```

- [ ] **Step 3: Rewrite Test 5 — reviewer skepticism**

The stance survives consolidation; only the reviewer's name changed. Replace the `run_claude` line in Test 5 and its heading:

```bash
echo "Test 5: Task reviewer mindset..."

output=$(run_claude "What is the task reviewer's attitude toward the implementer's report in subagent-driven-development?" 30)
```

Keep both existing assertions, but replace the second one — the reviewer now reads the diff package, and "read the broader codebase" is explicitly forbidden:

```bash
if assert_contains "$output" "diff\|review package\|unverified claims" "Reviewer works from the diff package"; then
```

- [ ] **Step 4: Rewrite Test 7 — task context provision**

This assertion is now inverted: the controller must NOT paste the task text.

```bash
echo "Test 7: Task context provision..."

output=$(run_claude "In subagent-driven-development, how does the controller give an implementer subagent its task requirements?" 30)

if assert_contains "$output" "brief\|task-brief\|file path\|BRIEF_FILE" "Uses a task brief file"; then
    : # pass
else
    exit 1
fi

if assert_contains "$output" "not.*paste\|never.*paste\|avoid.*paste\|instead of pasting\|context" "Avoids pasting into controller context"; then
    : # pass
else
    exit 1
fi
```

- [ ] **Step 5: Add a ledger test**

The progress ledger is the highest-value adoption and has no coverage. Append before the test file's final summary echo:

```bash
echo "Test 10: Progress ledger..."

output=$(run_claude "In subagent-driven-development, how does the controller track which tasks are already done, and why not just todos?" 30)

if assert_contains "$output" "ledger\|progress.md" "Mentions the ledger file"; then
    : # pass
else
    exit 1
fi

if assert_contains "$output" "compact\|context.*lost\|survive\|re-dispatch" "Ledger survives compaction"; then
    : # pass
else
    exit 1
fi

echo ""
```

- [ ] **Step 5b: Wire the plan-scoping test into a runner**

Added after Task 1's review: `tests/sdd-scripts/test-plan-scoping.sh` exists but nothing
invokes it. Every other test directory in this repo has its own runner and there is no CI,
so an unwired test is one nobody runs. Create `tests/sdd-scripts/run-tests.sh`:

```bash
#!/usr/bin/env bash
# Run every deterministic SDD helper-script test in this directory.
# Unlike tests/claude-code/, these make no model calls — they are fast and hermetic.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

failed=0
for t in "$SCRIPT_DIR"/test-*.sh; do
  [ -f "$t" ] || continue
  echo "=== $(basename "$t") ==="
  if "$t"; then
    echo ""
  else
    echo "FAILED: $(basename "$t")" >&2
    failed=1
  fi
done

exit "$failed"
```

Then:

```bash
chmod +x tests/sdd-scripts/run-tests.sh
tests/sdd-scripts/run-tests.sh
scripts/lint-shell.sh tests/sdd-scripts/run-tests.sh
```

Expected: the plan-scoping test runs and passes, exit 0, lint clean.

- [ ] **Step 6: Run the full test**

```bash
tests/claude-code/test-subagent-driven-development.sh
tests/sdd-scripts/run-tests.sh
scripts/lint-shell.sh
```

Expected: both test scripts pass; lint is clean.

Note the bare `lint-shell.sh` — its default is "changed shell files", which is what
this plan is responsible for. Do NOT use `--all`: the repository has pre-existing
shellcheck findings in five untouched files (see Environment Baseline above).

- [ ] **Step 7: Commit**

```bash
git add tests/
git commit -m "test: update SDD harness for consolidated review and progress ledger"
```

---

### Task 8: Close the tracking entry and bump the version

**Files:**
- Modify: `docs/superflowers/upstream-tracking.md:7`, `:24`, `:99-101`, `:151-153`

- [ ] **Step 1: Clear the deferred marker in Current Base**

Line 7 currently ends with `**Deferred:** SDD plan-scoped redesign (needs re-integration with our Spec Gate + live-evidence).` Remove that sentence — leave the "Consciously skipped" list intact.

- [ ] **Step 2: Update the Modified Bundled Skills row**

Line 24 reads:

```
| subagent-driven-development | Added Specification Verification Gate, test-first task ordering note | Merge, preserve gate and ordering |
```

Replace with:

```
| subagent-driven-development | v6.2.0 base + our Specification Verification Gate (BDD/FF/live evidence, no parking), test-first ordering note, named reviewer at the final review only, Integration section | Merge upstream task-loop/ledger/fix-loop mechanics; preserve the gate, the ordering note, and the final-review agent routing |
```

- [ ] **Step 3: Add the sync-history entry**

At the top of the Sync History list (above the `2026-07-26` v6.2.0 quick-wins entry), add:

```markdown
- **2026-07-26 (follow-up):** SDD v6.2.0 re-integration — the piece deferred earlier the same day
  - **Adopted:** plan-scoped workspace (`.superflowers/sdd/<plan-basename>/`, fixes the stale
    cross-plan ledger read), compaction-proof progress ledger, brief-in/report-out implementer
    contract (our copy predated v6.0.3 — the scripts were present but no template called them),
    capped fix loop (5 rounds, resume 1-3 / fresh+escalated 4-5) with breaker and ledger-recorded
    adjudication, scoped re-reviews, pre-flight plan-conflict scan, sharpened Model Selection
    (explicit model per dispatch; turn count beats token price), one fix dispatch after the final
    review, Common Rationalizations table.
  - **Adopted (reversal):** consolidated `task-reviewer` replacing our two-stage spec→quality
    dispatch. Verified first that upstream's template already carries both of our contributions
    verbatim — all four Structure checks and the "do not trust the report" stance — so the
    consolidation loses no content. It also gives the fix loop a single findings set per task,
    which two stages would have re-fragmented. `spec-reviewer-prompt.md` and
    `code-quality-reviewer-prompt.md` deleted.
  - **Kept:** Specification Verification Gate (BDD + fitness functions + live evidence), now
    explicitly exempt from the fix-loop breaker — review findings may be parked with a ruling,
    a red suite may not. Test-first ordering note. Integration section.
  - **Adapted:** the named `superflowers:code-reviewer` now runs the final whole-branch review
    only; per-task review is `general-purpose`. Its agent profile (plan alignment, SOLID,
    scalability) is a merge-review lens that fights the task reviewer's "do not crawl the broader
    codebase" scoping. `requesting-code-review` is untouched — its named-reviewer divergence
    from upstream stands.
  - **Added (ours):** the task reviewer flags Step Definitions, fitness functions, modified
    `.feature` files, and constraint criteria touched by a task — flag only; the dedicated
    reviewers still run in the gate at the end.
```

- [ ] **Step 4: Update the stale C3 note**

Lines 151-153 of the 2026-06-26 entry claim we kept the two-stage review. That entry is historically accurate for its date — leave it. Verify it is the only remaining mention:

```bash
grep -n 'two-stage' docs/superflowers/upstream-tracking.md
```

Expected: exactly one hit, at the 2026-06-26 entry.

- [ ] **Step 5: Bump the version**

```bash
scripts/bump-version.sh 1.4.0
git diff --stat
```

Minor bump, not patch: a bundled skill's structure changed and two files were removed.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "chore: bump version to 1.4.0 (SDD v6.2.0 re-integration)"
```

---

### Task 9 (FINAL): Full verification

- [ ] **Step 1: Run every test touched by this plan**

```bash
tests/sdd-scripts/run-tests.sh
tests/claude-code/test-subagent-driven-development.sh
tests/claude-code/test-subagent-driven-development-integration.sh
scripts/lint-shell.sh
```

Expected: all pass, lint clean over the changed files. `--all` is deliberately not
used — see Environment Baseline.

- [ ] **Step 2: Verify no branding or dangling references leaked**

```bash
grep -rn 'superpowers' skills/subagent-driven-development/
grep -rn 'spec-reviewer-prompt\|code-quality-reviewer-prompt' --include='*.md' skills/ agents/ references/ CLAUDE.md
```

Expected: no output from either.

- [ ] **Step 3: Verify the divergences survived the rebuild**

```bash
grep -c 'Specification Verification Gate' skills/subagent-driven-development/SKILL.md
grep -n 'Live evidence' skills/subagent-driven-development/SKILL.md
grep -n 'never park' skills/subagent-driven-development/SKILL.md
grep -n 'superflowers:code-reviewer' skills/subagent-driven-development/SKILL.md
grep -n 'superflowers:code-reviewer' skills/requesting-code-review/SKILL.md
```

Expected: a count ≥ 2, then one hit each. The last one confirms `requesting-code-review` was not collaterally changed.

- [ ] **Step 4: Verify the workspace is git-clean in practice**

```bash
skills/subagent-driven-development/scripts/sdd-workspace \
  docs/superflowers/plans/2026-07-26-sdd-v620-reintegration.md
git status --porcelain
rm -rf .superflowers/sdd
```

Expected: the script prints `<repo>/.superflowers/sdd/2026-07-26-sdd-v620-reintegration`, and `git status --porcelain` is empty — the workspace must not appear.

- [ ] **Step 5: Read the rebuilt SKILL.md end to end**

Not a command — a read. Check that the Setup → Task Loop → Final Review → Specification Verification Gate → Finish sequence reads as one coherent process, that the flowchart matches the prose after the Step 5/6 edits in Task 5, and that no section still describes two review dispatches.

---

## Self-Review

**Spec coverage.** The four decisions at the top map to tasks: consolidation → Tasks 3, 6, 7; named reviewer routing → Task 5 Step 2 and Task 9 Step 3; lightweight BDD/FF flagging → Task 3 Step 2 with the deep review staying in Task 5 Step 4's gate; breaker exemption → Task 5 Step 4's closing paragraph. The ten v6.2.0 building blocks from the analysis map as: plan-scoped workspace → Task 1; ledger, fix loop, breaker, pre-flight scan, model selection, continuous execution, rationalizations table → Task 5 Step 1 (they arrive with the upstream file); brief/report mechanics → Task 2; scoped re-review → Task 4; one fix dispatch after final review → Task 5 Step 1.

**Placeholder scan.** Every `git show` command names an exact ref and path. Every insertion gives the literal text and an anchor. Task 5 Steps 5 and 6 are the weakest point — they edit a graphviz block by describing node and edge replacements rather than reproducing the whole block, because the block is ~60 lines of which 5 change. The anchors are unique strings; Step 8's grep plus Step 9's read-through are the check.

**Type consistency.** Script signatures are consistent throughout: `sdd-workspace PLAN_FILE`, `task-brief PLAN_FILE N`, `review-package PLAN_FILE BASE HEAD`. File names are consistent: `task-reviewer-prompt.md` and `re-review-prompt.md` are created in Tasks 3 and 4 and referenced by those names in Tasks 5, 6, and 7.

**One known ordering hazard.** Task 5 replaces SKILL.md wholesale, so if Tasks 3 and 4 have not run, the rebuilt SKILL.md references template files that do not exist yet. The task order handles this; do not reorder 3, 4, and 5.
