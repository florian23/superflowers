---
name: writing-plans
description: Use when you have a spec or requirements for a multi-step task, before touching code
---

# Writing Plans

## Overview

Write comprehensive implementation plans assuming the engineer has zero context for our codebase and questionable taste. Document everything they need to know: which files to touch for each task, code, testing, docs they might need to check, how to test it. Give them the whole plan as bite-sized tasks. DRY. YAGNI. TDD. Frequent commits.

Assume they are a skilled developer, but know almost nothing about our toolset or problem domain. Assume they don't know good test design very well.

**Announce at start:** "I'm using the writing-plans skill to create the implementation plan."

**Context:** This should be run in a dedicated worktree (created by brainstorming skill).

**Save plans to:** `docs/superflowers/plans/YYYY-MM-DD-<feature-name>.md`
- (User preferences for plan location override this default)

## Scope Check

If the spec covers multiple independent subsystems, it should have been broken into sub-project specs during brainstorming. If it wasn't, suggest breaking this into separate plans — one per subsystem. Each plan should produce working, testable software on its own.

## Specification Skills Integration

If specification skills were used before this plan, the plan MUST reference their outputs:

**architecture-assessment** (architecture.md exists):
- Plan tasks should respect architecture characteristics and constraints
- Include fitness function implementation tasks for new characteristics
- Reference architecture decisions that affect implementation choices

**feature-design** (.feature files exist):
- The plan MUST include explicit **Step Definition Tasks** that wire .feature scenarios to the implementation. These are NOT optional — without them, BDD tests cannot run.
- Step definition tasks come AFTER the implementation task they test (the implementation must exist for steps to call it)
- Each step definition task references the specific .feature file and scenarios it covers
- After each step definition task: run `npx cucumber-js --dry-run` (or equivalent) to verify zero undefined steps
- After ALL step definition tasks: run the full BDD suite to verify all scenarios pass
- The plan's final task MUST be a BDD verification task that runs the complete suite

**RECOMMENDED SUB-SKILL:** Use superflowers:bdd-testing for BDD execution and superflowers:fitness-functions for architecture verification during implementation.

## File Structure

Before defining tasks, map out which files will be created or modified and what each one is responsible for. This is where decomposition decisions get locked in.

- Design units with clear boundaries and well-defined interfaces. Each file should have one clear responsibility.
- You reason best about code you can hold in context at once, and your edits are more reliable when files are focused. Prefer smaller, focused files over large ones that do too much.
- Files that change together should live together. Split by responsibility, not by technical layer.
- In existing codebases, follow established patterns. If the codebase uses large files, don't unilaterally restructure - but if a file you're modifying has grown unwieldy, including a split in the plan is reasonable.

This structure informs the task decomposition. Each task should produce self-contained changes that make sense independently.

## Bite-Sized Task Granularity

**Each step is one action (2-5 minutes):**
- "Write the failing test" - step
- "Run it to make sure it fails" - step
- "Implement the minimal code to make the test pass" - step
- "Run the tests and make sure they pass" - step
- "Commit" - step

## Plan Document Header

**Every plan MUST start with this header:**

```markdown
# [Feature Name] Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superflowers:subagent-driven-development (recommended) or superflowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

**Architecture:** [Reference architecture.md characteristics if it exists, or "N/A"]

**Feature Files:** [List .feature files if they exist, or "N/A"]

**Fitness Functions:** [List architecture characteristics needing fitness functions, or "N/A"]

---
```

## Task Structure

````markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

- [ ] **Step 1: Write the failing test**

```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

- [ ] **Step 3: Write minimal implementation**

```python
def function(input):
    return expected
```

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add tests/path/test.py src/path/file.py
git commit -m "feat: add specific feature"
```
````

### BDD Step Definition Task (when .feature files exist)

For EACH .feature file, the plan MUST include a step definition task. Place it AFTER the implementation task it tests.

````markdown
### Task N: Wire BDD step definitions for [feature-name].feature

**Feature file:** `features/[feature-name].feature`
**Scenarios covered:** [list scenario names]

**Files:**
- Create: `features/step_definitions/[feature-name]-steps.js`

- [ ] **Step 1: Generate step definition stubs**

Read `features/[feature-name].feature` and create stub step definitions for every Given/When/Then step that doesn't already have a definition.

- [ ] **Step 2: Implement step definitions**

Wire each stub to the actual application code. Steps are THIN glue — they call application code, they do NOT contain business logic.

- [ ] **Step 3: Dry-run validation**

Run: `npx cucumber-js --dry-run features/[feature-name].feature`
Expected: ZERO undefined or pending steps

- [ ] **Step 4: Run scenarios**

Run: `npx cucumber-js features/[feature-name].feature`
Expected: ALL scenarios PASS (exit code 0)

- [ ] **Step 5: Verify no feature files changed**

Run: `git diff -- '*.feature'`
Expected: NO changes to any .feature file

- [ ] **Step 6: Commit**

```bash
git add features/step_definitions/[feature-name]-steps.js
git commit -m "test: add BDD step definitions for [feature-name]"
```
````

### Final BDD Verification Task

The LAST task in every plan with .feature files MUST be a full BDD suite run:

````markdown
### Task N (FINAL): Full BDD Suite Verification

- [ ] **Step 1: Run complete BDD suite**

Run: `npx cucumber-js`
Expected: ALL scenarios pass, exit code 0

- [ ] **Step 2: Verify coverage**

Run: `npx cucumber-js --dry-run`
Expected: ZERO undefined or pending steps across ALL feature files

- [ ] **Step 3: Verify feature file integrity**

Run: `git diff -- '*.feature'`
Expected: NO modifications to any .feature file during implementation
````

## No Placeholders

Every step must contain the actual content an engineer needs. These are **plan failures** — never write them:
- "TBD", "TODO", "implement later", "fill in details"
- "Add appropriate error handling" / "add validation" / "handle edge cases"
- "Write tests for the above" (without actual test code)
- "Similar to Task N" (repeat the code — the engineer may be reading tasks out of order)
- Steps that describe what to do without showing how (code blocks required for code steps)
- References to types, functions, or methods not defined in any task

## Remember
- Exact file paths always
- Complete code in every step — if a step changes code, show the code
- Exact commands with expected output
- DRY, YAGNI, TDD, frequent commits

## Self-Review

After writing the complete plan, look at the spec with fresh eyes and check the plan against it. This is a checklist you run yourself — not a subagent dispatch.

**1. Spec coverage:** Skim each section/requirement in the spec. Can you point to a task that implements it? List any gaps.

**2. Placeholder scan:** Search your plan for red flags — any of the patterns from the "No Placeholders" section above. Fix them.

**3. Type consistency:** Do the types, method signatures, and property names you used in later tasks match what you defined in earlier tasks? A function called `clearLayers()` in Task 3 but `clearFullLayers()` in Task 7 is a bug.

If you find issues, fix them inline. No need to re-review — just fix and move on. If you find a spec requirement with no task, add the task.

## Execution Handoff

After saving the plan, offer execution choice:

**"Plan complete and saved to `docs/superflowers/plans/<filename>.md`. Two execution options:**

**1. Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

**Which approach?"**

**If Subagent-Driven chosen:**
- **REQUIRED SUB-SKILL:** Use superflowers:subagent-driven-development
- Fresh subagent per task + two-stage review

**If Inline Execution chosen:**
- **REQUIRED SUB-SKILL:** Use superflowers:executing-plans
- Batch execution with checkpoints for review
