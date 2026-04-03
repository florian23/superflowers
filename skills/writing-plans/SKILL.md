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

**bounded-context-design** (context-map.md exists):
- Module/service decomposition in the plan should follow bounded context boundaries
- Each context maps to one or more modules/services — never split a context across unrelated modules
- Use the ubiquitous language from context-map.md in task descriptions
- If context relationships define Anti-Corruption Layers, include ACL implementation as explicit tasks

**architecture-assessment + architecture-style-selection** (architecture.md exists):
- Plan tasks should respect architecture characteristics and constraints
- Include fitness function implementation tasks for new characteristics
- Include **architecture style fitness function** tasks (from the "Architecture Style Fitness Functions" section in architecture.md) — these enforce structural invariants of the selected style (e.g., "no shared database" for microservices, "module boundary enforcement" for modular monolith)
- Reference architecture decisions that affect implementation choices

**quality-scenarios** (quality-scenarios.md exists):
- Plan tasks should include test implementations for each quality scenario
- Categorize test tasks by the **test type** defined in quality-scenarios.md (unit-test, integration-test, load-test, chaos-test, fitness-function, manual-review)
- Group test implementation tasks by type: unit tests first (fastest feedback), then integration, then load/chaos tests
- Reference tradeoffs from quality-scenarios.md when they affect implementation choices
- Do NOT create test tasks for scenarios that overlap with style fitness functions (already covered)

**feature-design** (.feature files exist):
- The plan MUST include explicit **Step Definition Tasks** that bind .feature scenarios to the implementation via Step Definitions (Glue Code). These are NOT optional — without them, BDD tests cannot run.
- Step definition tasks come BEFORE the implementation task — BDD follows outside-in TDD. Write Step Definitions first (the Glue Code that binds Gherkin to application code) (step definitions that call not-yet-existing code), verify they FAIL, then implement until they pass.
- Each step definition task references the specific .feature file and scenarios it covers
- After each step definition task: run `npx cucumber-js --dry-run` (or equivalent) to verify zero undefined steps
- After ALL step definition tasks: run the full BDD suite to verify all scenarios pass
- The plan's final task MUST be a BDD verification task that runs the complete suite

**constraint-selection** (docs/superflowers/constraints/ exists):
- Read the most recent feature constraints file
- Include constraint compliance verification as explicit tasks in the plan
- Each constraint's verification criteria becomes a testable checklist item
- Group constraint tasks near related implementation tasks (e.g., security constraints near auth tasks)

**REQUIRED SUB-SKILL (when artifacts exist):** Use superflowers:bdd-testing for BDD verification when .feature files exist. Use superflowers:fitness-functions for architecture verification when architecture.md exists. These are NOT optional — the specification verification gate in subagent-driven-development will enforce them.

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

**Bounded Contexts:** [List contexts from context-map.md with their subdomain type, or "N/A"]

**Feature Files:** [List .feature files if they exist, or "N/A"]

**Characteristic Fitness Functions:** [List architecture characteristics needing fitness functions, or "N/A"]

**Style Fitness Functions:** [List style-specific structural checks from architecture.md, or "N/A"]

**Quality Scenarios:** [List quality scenarios by test type from quality-scenarios.md, or "N/A"]

**Active ADRs:** [List active architecture decisions from doc/adr/ that affect this implementation, or "N/A"]

**Active Constraints:** [List constraints from docs/superflowers/constraints/ with their verification criteria, or "N/A"]

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

### Fitness Function Tasks (when architecture.md exists)

**Task ordering:** Atomic fitness functions (structure, dependencies, complexity, module boundaries) are the FIRST tasks in the plan — before any implementation. They define architectural constraints as executable tests (TDD-first).

**Holistic fitness functions** (performance, load, chaos — requiring running services) come AFTER implementation tasks. They cannot run without a working system.

````markdown
### Task 1: Atomic Fitness Functions

> These run FIRST — they define structural constraints before implementation begins.

**Files:**
- Create: `tests/fitness/[characteristic]-ff.test.ts` (or language equivalent)

- [ ] **Step 1: Implement fitness function for [characteristic]**

```[language]
// Fitness function: [characteristic] — [concrete goal from architecture.md]
[concrete test code]
```

- [ ] **Step 2: Run fitness function — verify it FAILS**

Run: `[test command]`
Expected: FAIL (structure doesn't exist yet — this is TDD)

- [ ] **Step 3: Commit**

```bash
git add tests/fitness/
git commit -m "test: add fitness function for [characteristic] (red)"
```
````

### Holistic Fitness Function Tasks (after implementation)

Place these AFTER the implementation tasks that create the running system:

````markdown
### Task N: Holistic Fitness Functions (Performance/Load)

**Files:**
- Create: `tests/fitness/[characteristic]-holistic-ff.test.ts`

- [ ] **Step 1: Implement holistic fitness function**

```[language]
// Fitness function: [characteristic] — [concrete goal from architecture.md]
[concrete test code requiring running services]
```

- [ ] **Step 2: Run — verify it PASSES**

Run: `[test command]`
Expected: PASS (system is implemented)

- [ ] **Step 3: Commit**
````

### BDD-First Task (when .feature files exist)

BDD follows outside-in TDD: write Step Definitions FIRST (they fail), then implement until they pass. For EACH .feature file relevant to the current implementation area, the plan MUST include a BDD-first task BEFORE the corresponding implementation task.

````markdown
### Task N: BDD-First for [feature-name].feature

**Feature file:** `features/[feature-name].feature`
**Scenarios for this task:** [list relevant scenario names]

**Files:**
- Create: `features/step_definitions/[feature-name]-steps.js`

- [ ] **Step 1: Write Step Definition stubs**

Read `features/[feature-name].feature` and create step definitions that call the application code interface (which doesn't exist yet). Steps are THIN glue — they define the API contract the implementation must satisfy.

- [ ] **Step 2: Run scenarios — verify they FAIL**

Run: `npx cucumber-js features/[feature-name].feature`
Expected: FAIL (application code not implemented yet)
This confirms the steps are bound to real code and calling it, not faking it.

- [ ] **Step 3: Implement with unit TDD**

Use superflowers:test-driven-development to implement the application code that the step definitions call. Red-green-refactor per unit.

- [ ] **Step 4: Run scenarios — verify they PASS**

Run: `npx cucumber-js features/[feature-name].feature`
Expected: ALL scenarios PASS (exit code 0)

- [ ] **Step 5: Verify no feature files changed**

Run: `git diff -- '*.feature'`
Expected: NO changes to any .feature file

- [ ] **Step 6: Commit**

```bash
git add features/step_definitions/[feature-name]-steps.js src/
git commit -m "feat: implement [feature-name] with BDD step definitions"
```
````

**Frontend vs Backend:** If the .feature file contains UI scenarios (clicks,
navigation, forms, visibility assertions), the Step Definitions require a
headless browser setup. Include a setup task BEFORE the BDD-first task:
- Install Playwright/Selenium as dev dependency
- Create World/support with browser lifecycle (headless: true)
- Verify browser binding works with a single navigation step before writing all Step Definitions

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

## Task Ordering

Plans follow a TDD-first ordering principle:

1. **Atomic Fitness Functions** — structural constraints first (they FAIL initially)
2. **Per feature area:** BDD Step Definitions written (FAIL) → unit TDD implementation (until BDD PASS)
3. **Holistic Fitness Functions** — performance/load tests after implementation
4. **Final Verification** — full BDD suite + ALL fitness functions

This ensures architecture constraints and behavior expectations are defined BEFORE implementation, not verified after the fact.

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
