# Reviewer Agent Protocol

All reviewer agents in this directory follow this standard protocol.

## Self-Identification

Every reviewer output MUST start with the agent's name:

```
[constraint-reviewer]: APPROVED
```
or
```
[quality-scenario-reviewer]: ISSUES_FOUND
- ...
```

This ensures the user and orchestrating skill can clearly see WHO gave the feedback.

## Assessment Schema: Pass / Fail / Skip

Every check item in the review is assessed as exactly one of:

| Status | Meaning | Action |
|--------|---------|--------|
| **PASS** | Check passed, no issues | None |
| **FAIL** | Check failed, must be fixed | Agent iterates |
| **SKIP** | Check not applicable (with reason) | None |

No other categories. No "partial", "uncertain", "probably wrong", "mostly ok". Each check is binary: it passed or it failed. If unsure, it's FAIL.

## Output Format

```
[agent-name]: <STATUS>

## Checks

| # | Check | Status | Evidence |
|---|-------|--------|----------|
| 1 | Coverage complete | PASS | All 5 characteristics have scenarios |
| 2 | Test types diverse | FAIL | 80% integration-tests, need unit + load |
| 3 | Constraint coverage | PASS | All 4 criteria mapped |
| 4 | Tradeoff analysis | SKIP | No conflicting characteristics |

## Issues (if FAIL)

1. **Test type diversity:** 80% integration-tests. Need at least 1 unit-test and 1 load-test. Affected scenarios: QS-003, QS-007.

## Verdict

ISSUES_FOUND — 1 FAIL out of 4 checks.
```

## Evidence Requirement

For every PASS or FAIL, the reviewer MUST provide evidence:
- **PASS evidence:** What was checked and what was found ("All 5 characteristics have at least one scenario")
- **FAIL evidence:** What's wrong, what was expected, what was found ("Expected diverse test types, found 80% integration-tests")

"Looks good" or "seems fine" is NOT evidence. Cite concrete data.

## Test Execution Visibility

When a review involves running tests (BDD, fitness functions, unit tests):
- The reviewer MUST show the actual command executed
- The reviewer MUST show the test output (at least summary: X passed, Y failed)
- "Tests pass" without showing output is NOT evidence

```
✅ GOOD:
  Run: pytest tests/ -v
  Output: 12 passed, 0 failed, 0 skipped
  Status: PASS

❌ BAD:
  "Tests pass"
  Status: PASS
```

## Status Aggregation

| Condition | Overall Status |
|-----------|---------------|
| All checks PASS or SKIP | **APPROVED** |
| Any check is FAIL | **ISSUES_FOUND** |
| Existing artifacts changed | **CHANGE_REQUIRES_APPROVAL** |
