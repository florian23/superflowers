# Verification Checklist for Claim: "Implementation is complete. All tests pass."

Based on the `verification-before-completion` skill, the following checks are **mandatory** before accepting this claim. Every check requires fresh evidence produced in the current session. No exceptions.

---

## The Iron Law Applied

The claim "Implementation is complete. All tests pass." contains TWO sub-claims:
1. "Implementation is complete" -- a completion/requirements claim
2. "All tests pass" -- a test status claim

Both require independent verification with evidence.

---

## Check 1: Unit Tests (3 quality scenarios typed as unit-test)

**What must happen:** Run the unit test suite command (e.g., `npm test`, `pytest`, `./gradlew test`).

**Required evidence format:**
```
[Exact test command run] -> [Output showing pass/fail counts, 0 failures, exit code 0]
Example: "npm test -> 34/34 pass, 0 failures, exit 0"
```

**Confirms:** The 3 quality scenarios typed as `unit-test` in `quality-scenarios.md` are covered by passing unit tests.

**NOT sufficient:** "Tests should pass", previous run output, "I'm confident they pass".

---

## Check 2: Integration Tests (4 quality scenarios typed as integration-test)

**What must happen:** Run the integration test suite command (e.g., `npm run test:integration`, `pytest -m integration`).

**Required evidence format:**
```
[Exact integration test command run] -> [Output showing pass/fail counts, 0 failures, exit code 0]
Example: "npm run test:integration -> 12/12 pass, 0 failures, exit 0"
```

**Confirms:** The 4 quality scenarios typed as `integration-test` in `quality-scenarios.md` are covered by passing integration tests.

**NOT sufficient:** "Unit tests pass so integration is fine", partial integration run, extrapolation from unit test results.

---

## Check 3: Load Tests (2 quality scenarios typed as load-test)

**What must happen:** Run load test suite and confirm results meet the response measures defined in the quality scenarios.

**Required evidence format:**
```
[Exact load test command run] -> [Output showing response times, throughput, thresholds met]
Example: "k6 run load-test.js -> p95 < 200ms, throughput > 100 rps, all thresholds passed"
```

**Confirms:** The 2 quality scenarios typed as `load-test` in `quality-scenarios.md` meet their defined response measures.

**NOT sufficient:** "Code looks performant", "should handle load", unit/integration tests passing.

---

## Check 4: Manual Review (1 quality scenario typed as manual-review)

**What must happen:** The manual-review scenario must be explicitly acknowledged. Either:
- (a) Provide evidence that the manual review was performed and passed, OR
- (b) Explicitly defer with justification for why it cannot be done now

**Required evidence format:**
```
Option A: "[Manual review scenario name] reviewed by [who] on [when] - [outcome with specifics]"
Option B: "[Manual review scenario name] deferred - [justification]. Will be reviewed by [who] before [milestone]."
```

**Confirms:** The 1 quality scenario typed as `manual-review` in `quality-scenarios.md` is addressed.

**NOT sufficient:** Ignoring it, assuming it passes because other tests pass, "quality looks good".

---

## Check 5: BDD Scenarios (features/booking.feature -- 5 scenarios)

**What must happen:** Run the BDD test command (e.g., `npx cucumber-js`, `behave`, `./gradlew cucumberTest`). ALL 5 scenarios in `features/booking.feature` must pass.

**Required evidence format:**
```
[Exact BDD command run] -> [Output showing "5 scenarios, 5 passed" or equivalent, 0 failures]
Example: "npx cucumber-js -> 5 scenarios (5 passed), 15 steps (15 passed), exit 0"
```

**Confirms:** All BDD scenarios in `features/booking.feature` are green.

**NOT sufficient:** "Unit tests pass so features work", "most scenarios pass", previous BDD run output.

---

## Check 6: Fitness Functions (architecture.md exists)

**What must happen:** Run the fitness function checks defined in `architecture.md`. ALL checks must pass.

**Required evidence format:**
```
[Exact fitness function command run] -> [Output showing all checks green, e.g., "5/5 checks passed"]
Example: "npm run fitness -> dependency-rule: PASS, layer-check: PASS, 5/5 passed"
```

**Confirms:** Architecture compliance as defined in `architecture.md`.

**NOT sufficient:** "Code follows the architecture", "looks structurally sound", linter passing.

---

## Check 7: Requirements Completeness

**What must happen:** Re-read the original plan/requirements. Create a line-by-line checklist. Verify each item against the implementation with evidence.

**Required evidence format:**
```
Requirement 1: [description] -> [DONE: evidence] or [GAP: what's missing]
Requirement 2: [description] -> [DONE: evidence] or [GAP: what's missing]
...
Summary: X/Y requirements verified complete, Z gaps identified
```

**Confirms:** "Implementation is complete" -- every requirement is addressed.

**NOT sufficient:** "Tests pass, so implementation is complete", general satisfaction statements.

---

## Check 8: Build Verification

**What must happen:** Run the build command. Confirm exit code 0.

**Required evidence format:**
```
[Exact build command run] -> [Output confirming successful build, exit code 0]
Example: "./gradlew build -> BUILD SUCCESSFUL, exit 0"
```

**Confirms:** The project compiles and builds without errors.

**NOT sufficient:** "Linter passed" (linter does not equal compiler), "tests pass" (tests do not equal build).

---

## Summary Table

| # | Check | Trigger | Required Evidence | Acceptance Criteria |
|---|-------|---------|-------------------|---------------------|
| 1 | Unit tests | 3 unit-test scenarios in quality-scenarios.md | Test command output, 0 failures, exit 0 | All unit tests pass |
| 2 | Integration tests | 4 integration-test scenarios in quality-scenarios.md | Integration test command output, 0 failures, exit 0 | All integration tests pass |
| 3 | Load tests | 2 load-test scenarios in quality-scenarios.md | Load test output with metrics meeting thresholds | Response measures met |
| 4 | Manual review | 1 manual-review scenario in quality-scenarios.md | Review evidence or documented deferral | Acknowledged with evidence or justification |
| 5 | BDD scenarios | features/booking.feature (5 scenarios) | BDD command output: "5 scenarios, 5 passed" | All 5 scenarios green |
| 6 | Fitness functions | architecture.md exists | Fitness function command output: all checks passed | All fitness functions green |
| 7 | Requirements checklist | Completion claim ("implementation is complete") | Line-by-line requirement verification | Every requirement addressed |
| 8 | Build | Completion claim | Build command output, exit 0 | Build succeeds |

---

## Verdict on the Claim

The claim "Implementation is complete. All tests pass." **cannot be accepted** without fresh evidence for all 8 checks above. The claim is currently unverified. Per the skill: "If you haven't run the verification command in this message, you cannot claim it passes."

Any of the following disqualifies acceptance:
- Missing evidence for any check
- Evidence from a previous run (not fresh)
- Partial verification (e.g., unit tests pass but BDD not run)
- Weasel words ("should pass", "looks good", "I'm confident")
- Trusting agent self-reports without independent verification
