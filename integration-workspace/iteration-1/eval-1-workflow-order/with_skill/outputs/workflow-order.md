# Skill Invocation Order: REST API Buchungssystem

Complete workflow from idea to finished implementation, based on the superflowers skill definitions.

## Phase 1: Discovery and Design

### 1. `superflowers:brainstorming`

**Trigger:** User says "Ich moechte eine REST API fuer ein Buchungssystem bauen."

**What happens:**
- Explores project context (files, docs, commits)
- Offers visual companion if visual questions are expected
- Asks clarifying questions one at a time (purpose, constraints, success criteria)
- Proposes 2-3 approaches with trade-offs and a recommendation
- Presents design in sections, gets user approval per section

**Produces:** A validated, user-approved design covering architecture, components, data flow, error handling, and testing.

---

### 2. `superflowers:architecture-assessment`

**Trigger:** Invoked by brainstorming after design approval (brainstorming checklist step 6).

**What happens:**
- Structured questionnaire dialogue about quality attributes (performance, scalability, security, etc.)
- Identifies and prioritizes top-3 architecture characteristics
- Documents architecture drivers
- User approves characteristics

**Produces:** `docs/superflowers/architecture.md` -- persistent architecture characteristics document with prioritized top-3 characteristics, drivers, and quality goals.

---

### 3. `superflowers:architecture-style-selection`

**Trigger:** Invoked after architecture-assessment (brainstorming process flow, line 66).

**What happens:**
- Reads driving characteristics from architecture.md
- Scores architecture styles (Layered, Modular Monolith, Microkernel, Microservices, Service-Based, Service-Oriented, Event-Driven, Space-Based) against the project's top-3 characteristics using the Ford/Richards worksheet
- Presents top candidates with trade-off analysis
- Qualifies with context questions if no clear winner
- User selects final style

**Produces:** Updated `architecture.md` with selected architecture style, scoring rationale, and architecture style fitness functions (structural invariants to enforce).

---

### 4. `superflowers:quality-scenarios`

**Trigger:** Invoked after architecture-style-selection (brainstorming process flow, line 68).

**What happens:**
- Reads quality goals from architecture.md
- Generates concrete ATAM-style quality scenarios per goal (stimulus, response, measurable outcome)
- Classifies each scenario into a test type: unit-test, integration-test, load-test, chaos-test, fitness-function, or manual-review
- Identifies trade-offs and sensitivity points
- User reviews and approves

**Produces:** `docs/superflowers/quality-scenarios.md` -- testable quality scenarios categorized by test type, with measurable response criteria.

---

### 5. `superflowers:feature-design`

**Trigger:** Invoked after quality-scenarios (brainstorming process flow, line 69).

**What happens:**
- Reads the approved design/spec and identifies behavioral requirements
- Drafts Gherkin .feature files with Given-When-Then scenarios
- Uses ubiquitous language from the domain
- User reviews and approves feature files

**Produces:** Committed `.feature` files (e.g., `features/booking-creation.feature`, `features/booking-cancellation.feature`) -- executable BDD acceptance criteria.

---

### 6. Spec Writing (part of brainstorming checklist step 8)

**Trigger:** Brainstorming resumes after feature-design completes.

**What happens:**
- Writes the design document referencing architecture.md, quality-scenarios.md, and .feature files
- Performs spec self-review (placeholder scan, consistency, scope, ambiguity, architecture alignment, scenario coverage)
- User reviews and approves the written spec

**Produces:** `docs/superflowers/specs/YYYY-MM-DD-buchungssystem-api-design.md` -- committed design specification.

---

## Phase 2: Workspace Setup

### 7. `superflowers:using-git-worktrees`

**Trigger:** Invoked by brainstorming checklist step 11, after spec approval.

**What happens:**
- Checks for existing worktree directories (.worktrees or worktrees)
- Checks CLAUDE.md for preference
- Creates isolated git worktree for implementation on a feature branch

**Produces:** An isolated git worktree directory with a dedicated feature branch, separate from the main workspace.

---

## Phase 3: Planning

### 8. `superflowers:writing-plans`

**Trigger:** Invoked by brainstorming checklist step 12, the final brainstorming step.

**What happens:**
- Writes a comprehensive, bite-sized implementation plan assuming zero codebase context
- References architecture.md constraints, includes fitness function tasks
- References quality-scenarios.md, categorizes test tasks by test type (unit first, then integration, then load/chaos)
- References .feature files, includes explicit step definition tasks with BDD dry-run verification after each
- Final plan task is a full BDD suite verification

**Produces:** `docs/superflowers/plans/YYYY-MM-DD-buchungssystem-api.md` -- committed implementation plan with ordered tasks, testing steps, and verification gates.

---

## Phase 4: Implementation

### 9. `superflowers:subagent-driven-development` (preferred) or `superflowers:executing-plans`

**Trigger:** User starts implementation after plan is written.

- **subagent-driven-development:** Used when running in a platform with subagent support (e.g., Claude Code). Dispatches a fresh subagent per task with two-stage review (spec compliance, then code quality).
- **executing-plans:** Used in parallel sessions or without subagent support. Loads plan, executes tasks sequentially with verification after each.

**What happens:**
- Executes each plan task in order
- Runs verifications as specified per task
- Uses sub-skills during implementation:
  - `superflowers:bdd-testing` -- creates step definitions from .feature files, runs scenarios after each relevant task
  - `superflowers:fitness-functions` -- implements and runs automated fitness functions from architecture.md
  - `superflowers:verification-before-completion` -- enforces evidence-before-claims at every completion point

**Produces:** Working, tested implementation code with passing BDD scenarios, fitness functions, and quality scenario tests.

---

## Phase 5: Completion

### 10. `superflowers:finishing-a-development-branch`

**Trigger:** Invoked after all plan tasks are complete and verified.

**What happens:**
- Verifies ALL tests pass (unit tests, BDD scenarios via bdd-testing, fitness functions via fitness-functions, quality scenario tests)
- Determines base branch
- Presents structured options: merge to main, create PR, or other cleanup
- Executes the user's chosen workflow
- Cleans up worktree if applicable

**Produces:** Integrated code on the target branch (via merge or PR), with all verification gates passed.

---

## Summary Table

| # | Skill | Phase | Key Output |
|---|-------|-------|------------|
| 1 | `brainstorming` | Discovery | Approved design |
| 2 | `architecture-assessment` | Specification | `architecture.md` (characteristics, top-3) |
| 3 | `architecture-style-selection` | Specification | Updated `architecture.md` (style + fitness fns) |
| 4 | `quality-scenarios` | Specification | `quality-scenarios.md` (testable scenarios by type) |
| 5 | `feature-design` | Specification | `.feature` files (Gherkin BDD scenarios) |
| 6 | Spec writing (brainstorming) | Specification | Design spec document |
| 7 | `using-git-worktrees` | Setup | Isolated worktree + feature branch |
| 8 | `writing-plans` | Planning | Implementation plan |
| 9 | `subagent-driven-development` / `executing-plans` | Implementation | Working code + passing tests |
| 9a | `bdd-testing` (sub-skill) | Implementation | Step definitions + green scenarios |
| 9b | `fitness-functions` (sub-skill) | Implementation | Automated architecture checks |
| 9c | `verification-before-completion` (sub-skill) | Implementation | Evidence-backed completion claims |
| 10 | `finishing-a-development-branch` | Completion | Merged/PR'd code, cleanup |
