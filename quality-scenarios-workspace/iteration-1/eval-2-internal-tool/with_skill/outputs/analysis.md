# Analysis: Quality Scenarios — Eval 2 (Internal Tool)

## Input Context
- **Project type:** Internal compliance tool
- **Team:** 2 developers
- **Users:** ~50 internal
- **Budget:** Minimal
- **Architecture style:** Modular Monolith
- **User request language:** German ("möglichst wenig Overhead")

## Skill Adherence

### Step 1: Read Quality Goals — DONE
Extracted 5 characteristics with concrete goals from architecture.md. Noted existing fitness functions to avoid duplication:
- Testability coverage gate (>90%) — already a FF
- Maintainability complexity check (>50 lines, <10 complexity) — already a FF
- Security auth test — already a FF
- 4 style fitness functions (circular deps, boundaries, single artifact, schema per module) — already covered

### Step 2: Generate Scenarios — DONE
Generated 9 scenarios following the quantity rules:
- **Critical (Top 3):** Simplicity got 2 scenarios, Testability got 2 (coverage gate FF not duplicated), Maintainability got 2 (complexity FF not duplicated)
- **Important:** Security got 2 scenarios (auth test FF not duplicated, but RBAC and audit log need separate coverage)
- **Nice-to-have:** Availability got 1 scenario

### Step 3: Classify Test Type — DONE
Applied the decision tree from test-type-guide.md:
- **manual-review (3):** Simplicity scenarios require human judgment (onboarding time, documentation quality, bug diagnosis speed)
- **fitness-function (1):** Independent test suite isolation is a structural check
- **unit-test (1):** No-external-deps test check is single-component isolation
- **integration-test (4):** RBAC, audit logging, availability, and module change isolation all need a running system with real boundaries

Distribution is diverse — no single test type dominates.

### Step 4: Identify Tradeoffs — DONE
Found 2 tradeoffs and 1 sensitivity point:
1. Audit logging adds complexity that conflicts with simplicity goal
2. Audit persistence needs conflict with unit test isolation
3. Module granularity affects multiple scenarios

### Step 5: Present to User — SKIPPED (eval mode)
In a real session the skill requires user confirmation before writing. Skipped for eval.

### Step 6: Write quality-scenarios.md — DONE

## Verification Checklist

- [x] Every characteristic with a concrete goal has at least one scenario
- [x] Top 3 characteristics have 2-3 scenarios each (different environments)
- [x] Every scenario has a concrete response measure (number, threshold, or observable outcome)
- [x] Test types are diverse (3 manual-review, 4 integration-test, 1 unit-test, 1 fitness-function)
- [x] Style fitness functions from architecture.md are NOT duplicated (no circular deps, boundaries, single artifact, or schema scenarios)
- [x] Existing characteristic fitness functions NOT duplicated (coverage gate, complexity check not re-created)
- [x] Tradeoffs between conflicting characteristics are documented (2 tradeoffs, 1 sensitivity point)
- [x] quality-scenarios.md written

## Context Sensitivity

The skill correctly adapted to the project context:
- **No load tests or chaos tests:** 50 internal users, minimal budget, modular monolith — load/chaos testing would be pure overhead
- **Manual reviews for simplicity:** With 2 developers, onboarding and documentation quality are inherently human-judged
- **Integration tests for security:** RBAC and audit logging need a running auth system — can't be unit-tested meaningfully
- **Kept scenario count low (9):** 2-person team with minimal budget; more scenarios would violate the user's "möglichst wenig Overhead" request

## Potential Weaknesses

1. **No load test at all:** Even with 50 users, a basic smoke-level load test could catch regressions. Justifiable to skip given budget constraints, but worth noting.
2. **QS-006 (Bug Diagnosis Speed) is hard to measure:** "Under 2 hours" for bug fixes is subjective and depends on bug complexity. The scenario acknowledges "non-complex bugs" but this is still fuzzy.
3. **QS-009 (Availability) measurement:** Weekly measurement of 99% uptime for an internal tool with 50 users may not generate enough data points to be statistically meaningful.
